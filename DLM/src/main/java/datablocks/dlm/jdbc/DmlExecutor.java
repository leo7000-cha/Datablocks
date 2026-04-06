package datablocks.dlm.jdbc;

import com.zaxxer.hikari.HikariDataSource;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.CustomException;
import datablocks.dlm.exception.GapUpdRowException;
import datablocks.dlm.service.ArchiveNamingService;
import datablocks.dlm.service.ErrorHistService;
import datablocks.dlm.service.InnerStepService;
import datablocks.dlm.service.OrderDdlService;
import datablocks.dlm.service.PiiOrderStepTableService;
import datablocks.dlm.util.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;
import java.util.Map.Entry;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import static datablocks.dlm.util.SqlUtil.getDefaultValue;

@Slf4j
@Service
@RequiredArgsConstructor
public class DmlExecutor {
    private final PiiOrderStepTableService ordersteptableSV;
    private final InnerStepService innerStepSV;
    private final OrderDdlService orderDdlSV;
    private final ErrorHistService errorHistSV;
    private final ArchiveNamingService archiveNamingService;

    // 최선의 DML 실행 메서드 (execUpdate)
// - 성공 시 commit, 실패 시 rollback
// - 자원 자동 해제(try-with-resources)
// - 실행 시간/영향 행수/SQL 길이 로그
    public long exeQuery(PiiDatabaseVO dbVO, String sql) throws Exception {
        if (sql == null || sql.isBlank()) {
            throw new IllegalArgumentException("SQL is blank");
        }

        final long startNs = System.nanoTime();
        AES256Util aes = new AES256Util();

        try (Connection conn = ConnectionProvider.getConnection(
                dbVO.getDbtype(),
                dbVO.getHostname(),
                dbVO.getPort(),
                dbVO.getId_type(),
                dbVO.getId(),
                dbVO.getDb(),
                dbVO.getDbuser(),
                aes.decrypt(dbVO.getPwd()))) {

            conn.setAutoCommit(false);

            try (Statement stmt = conn.createStatement()) {
                // 무한대기 방지
                stmt.setQueryTimeout(60); // 초, 환경에 맞게 조정

                long affected = stmt.executeUpdate(sql);
                conn.commit();

                long ms = (System.nanoTime() - startNs) / 1_000_000;
                // SQL 전문은 남기지 않고 길이/프리뷰만(보안·성능 고려)
                String preview = safeSqlPreview(sql, 200);

                // log.info("...") 사용 중이면 아래 라인에서 log를 logger로 바꿔도 됩니다.
                logger.info("execUpdate success db={} host={} user={} affected={} sqlLen={} ms={} preview='{}'",
                        dbVO.getDb(), dbVO.getHostname(), dbVO.getDbuser(),
                        affected, sql.length(), ms, preview);

                // (선택) Statement/Connection 경고 로그
                for (SQLWarning w = stmt.getWarnings(); w != null; w = w.getNextWarning()) {
                    logger.warn("SQLWarning state={} code={} msg={}", w.getSQLState(), w.getErrorCode(), w.getMessage());
                }

                return affected;

            } catch (Exception e) {
                // 원인 로그
                long ms = (System.nanoTime() - startNs) / 1_000_000;
                logger.error("execUpdate failed db={} host={} user={} sqlLen={} ms={} msg={}",
                        dbVO.getDb(), dbVO.getHostname(), dbVO.getDbuser(),
                        sql.length(), ms, e.getMessage(), e);

                // 실패 시 반드시 롤백
                try {
                    conn.rollback();
                } catch (Exception rb) {
                    // 롤백 자체 실패 로그 + 원래 예외에 첨부
                    logger.warn("Rollback failed after execUpdate error", rb);
                    e.addSuppressed(rb);
                }
                throw e; // 재던져 상위에서 처리
            }
            // conn/stmt는 try-with-resources로 자동 close (풀 반납)
        }
    }

    /** 로그용 SQL 프리뷰: 공백 정리 + 최대 n자만 출력 */
    private static String safeSqlPreview(String sql, int max) {
        if (sql == null) return "";
        String s = sql.replaceAll("\\s+", " ").trim();
        return (s.length() <= max) ? s : (s.substring(0, max) + "...");
    }

    public Optional<ProgJobInfoVO> selectMcmmByProgJobNm(PiiDatabaseVO dbVO, String progJobNm, String selectQuery) throws Exception {
        AES256Util aes = new AES256Util();

        final String sql = selectQuery;
               /* "SELECT " +
                        "  PROG_JOB_NM    AS progJobNm, " +
                        "  BGNN_CHNG_DVCD AS bgnnChngDvcd, " +
                        "  PARAM_BASE_DT  AS paramBaseDt " +
                        "FROM coownser.MCMM_ETT_JOB_MST_M " +
                        "WHERE PROG_JOB_NM = ?";*/

        // DW DB에 접속 (dbVO가 DW를 가리키도록 세팅되어 있어야 함)
        try (Connection conn = ConnectionProvider.getConnection(
                dbVO.getDbtype(),
                dbVO.getHostname(),
                dbVO.getPort(),
                dbVO.getId_type(),
                dbVO.getId(),
                dbVO.getDb(),        // DW DB 스키마/카탈로그
                dbVO.getDbuser(),
                aes.decrypt(dbVO.getPwd()));
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, progJobNm);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return Optional.empty();

                ProgJobInfoVO row = new ProgJobInfoVO();
                row.setProgJobNm(rs.getString("progJobNm"));
                row.setBgnnChngDvcd(rs.getString("bgnnChngDvcd"));
                row.setParamBaseDt(rs.getString("paramBaseDt"));
                return Optional.of(row);
            }
        }
    }


    /** Exectue Archive and Delete&Update
     *
     * connTarget : table's db
     * connInsert : isolation db
     * 테이블 단위 파기 수행 함수
     * */

    public long exeDLM(Connection connTarget, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols, List<PiiOrderStepTableUpdateVO> piisteptableupdatelist, PiiOrderStepVO orderstepexe, int delStepFlag, String dbtype_source) throws Exception {
        LogUtil.log("INFO", "exeDLM: piiordersteptable: " + piiordersteptable.toString());
        StringBuilder sqlSelect = new StringBuilder();
        StringBuilder sqlSelectCols = new StringBuilder();
        StringBuilder sqlInsert = new StringBuilder();
        StringBuilder sqlDelete = new StringBuilder();
        StringBuilder sqlUpdate = new StringBuilder();

        StringBuilder sqlInsertIntoTarget = new StringBuilder();// 파기 대상이 PK인 경우 DEL/INSERT 방식 처리하기 위함

        String steptype = piiordersteptable.getSteptype();

        // 대체키 업데이트 로직 적용을 위해 추가함 20221004 by Cha
        String updateVal = null;
        int cntScramble = 0;
        boolean isScramble = false;

        // 업데이트 칼럼에 PK가 존재하는지 체크
        boolean isPkColExistInUpdateCols = false;
        // ARCHIVE에서 출발하든 EXE  STEP에서 직접 출발하든 EXE DLE, UP이 있는지 구분값
        boolean existExeUpdate = false;
        boolean existExeDelete = false;
        boolean existExeDelUp = false;
        if (orderstepexe != null) {
            if (steptype.equalsIgnoreCase("EXE_UPDATE")
                    || orderstepexe.getSteptype().equalsIgnoreCase("EXE_UPDATE")) { //아카이브 단계에서도 EXE_DELETE or EXE_UPDATE 를 수행하기 위해 해당 step 정보를 가져옴.
                existExeUpdate = true;
            } else if (steptype.equalsIgnoreCase("EXE_DELETE")
                    || orderstepexe.getSteptype().equalsIgnoreCase("EXE_DELETE")) {
                existExeDelete = true;
            }
            if (existExeDelete || existExeUpdate) {
                existExeDelUp = true;
            }
        }


        // 즉시파기를 위해 분리보관 시 해당 칼럼명, 인덱스 받기 위해 20230113 by Cha
        Map<String, Integer> noArchashMap = new HashMap<String, Integer>();
        boolean existNoarcCol = false;
        boolean isNoarcCol = false;
        /* set current row count
         * */
        //get current execnt
        long curExecnt;
        try {
            curExecnt = StrUtil.parseLong(piiordersteptable.getExecnt());
        } catch (Exception e) {
            curExecnt = 0;
        }

        long rowcount = 0;
        long rowcount_commited = 0;
        if (delStepFlag == 1) { //Delete job -> keep count from curExecnt
            rowcount = curExecnt;
            rowcount_commited = curExecnt;
        } else {                 //Update job  -> 재수행 되어도 업데이트 카운트는 전체가 되므로
            if (curExecnt > 0 && steptype.equalsIgnoreCase("EXE_ARCHIVE")) {//If there's execnt in the previous run, should delete data from Archive table using ORDERID, TABLE_NAME
                //delete archive data
                String archiveTable = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
                try (Statement stmtDel = connInsert.createStatement()) {
                    stmtDel.executeUpdate("delete from " + archiveTable + " where pii_order_id=" + piiordersteptable.getOrderid());
                }
                JdbcUtil.commit(connInsert);
            }
        }
        //set commit cnt
        int commitcnt = 3000;
        try {
            commitcnt = Integer.parseInt(piiordersteptable.getCommitcnt());
            if ("DPRDATECLE".equalsIgnoreCase(piiordersteptable.getTable_name())) {
                LogUtil.log("INFO", "DPRDATECLE  :  commitcnt="+commitcnt+"    piiordersteptable.getCommitcnt():"+piiordersteptable.getCommitcnt());
            }
        } catch (Exception e) {
            commitcnt = 3000;
        }

        //set sql hint if parallel cnt is defined
        String hint = "";
        if (!StrUtil.checkString(piiordersteptable.getParallelcnt())) {
            hint = "/*+ parallel(" + piiordersteptable.getParallelcnt() + ") */";
        }

        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
            if (!StrUtil.checkString(piiordersteptable.getWherestr()))
                sqlSelect.append(" " + piiordersteptable.getWherestr());

            // INSERT SQL 생성
            String tableName = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
            sqlInsert.append("insert into ").append(tableName).append(" values (");

            // 기본 컬럼들의 ? 추가
            int totalColumns = piitablecols.size();
            for (int i = 0; i < totalColumns; i++) {
                if (i == 0) {
                    sqlInsert.append("?");
                } else {
                    sqlInsert.append(",?");
                }
            }

            // 아카이브 관리 컬럼들 추가 (5개)
            String[] archiveColumns = {
                    "PII_ORDER_ID",
                    "PII_BASE_DATE",
                    "PII_CUST_ID",
                    "PII_JOB_ID",
                    "PII_DESTRUCT_DATE"
            };
            for (String archiveCol : archiveColumns) {
                sqlInsert.append(",?");
            }
            sqlInsert.append(")");
        }

        PiiTableVO piitable = null;
        HashMap<String, String> updatecols = new HashMap<String, String>();
        if (existExeUpdate) {
            sqlUpdate.append("update " + hint + " " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " ");
            sqlUpdate.append("set ");
            PiiOrderStepTableUpdateVO piisteptableupdate;
            for (int i = 0; i < piisteptableupdatelist.size(); i++) {
                piisteptableupdate = piisteptableupdatelist.get(i);
                updateVal = piisteptableupdate.getUpdate_val();
                updatecols.put(piisteptableupdate.getColumn_name(), piisteptableupdate.getUpdate_val());
                // 대체키 업데이트 로직 적용을 위해 추가함 20221004 by Cha
                if (updateVal.toUpperCase().contains("SCRAMBLE")) {
                    updateVal = "?";
                    isScramble = true;
                    cntScramble++;  //LogUtil.log("INFO", "@@@@ if(updateVal.toUpperCase().contain cntScramble  =cntScramble=  " +cntScramble+"  "+updateVal.toUpperCase());
                }
                // 즉시파기를 위해 분리보관 시 해당 칼럼값을 NULL로 업데이트함 20230113 by Cha
                if (updateVal.toUpperCase().contains("NOARC")) {
                    for (int c = 0; c < piitablecols.size(); c++) {
                        piitable = piitablecols.get(c);
                        if (piitable.getColumn_name().equalsIgnoreCase(piisteptableupdate.getColumn_name())) {
                            if ("Y".equalsIgnoreCase(piitable.getNullable())) {
                                updateVal = "NULL";
                            } else {
                                if (piitable.getData_type().toUpperCase().contains("CHAR")) {
                                    updateVal = "*";
                                } else if (piitable.getData_type().toUpperCase().contains("NUMBER") || piitable.getData_type().toUpperCase().contains("DECIMAL")) {
                                    updateVal = "0";
                                } else {
                                    updateVal = updateVal.replaceAll("(?i)NOARC", "");
                                }
                            }
                        }

                    }

                    noArchashMap.put(piisteptableupdate.getColumn_name(), 1);
                    existNoarcCol = true;
                }

                if (i == 0)
                    sqlUpdate.append(piisteptableupdate.getColumn_name() + "=" + updateVal + "");
                else
                    sqlUpdate.append(", " + piisteptableupdate.getColumn_name() + "=" + updateVal + "");
            }
            sqlUpdate.append(" where ");
        }

        sqlDelete.append("delete " + hint + " from " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " ");
        sqlDelete.append("where ");


        HashMap<String, Integer> pkcols = new HashMap<String, Integer>();

        int colindex = 1;
        int colcnt = 0;
        boolean catalogpkexistflg = false;

        // 대체키는 먼저 대체키 value를 처리해야하므로 Scramble 칼럼 이후 부터 where 조건의 PK 칼럼 세팅
        if (isScramble) colindex = cntScramble + 1;

        for (int i = 0; i < piitablecols.size(); i++) {
            piitable = piitablecols.get(i);
            if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
                pkcols.put(piitable.getColumn_name(), colindex++);
                if (colcnt == 0) {
                    sqlUpdate.append(piitable.getColumn_name() + "=" + "?" + "");
                    sqlDelete.append(piitable.getColumn_name() + "=" + "?" + "");
                    //sqlSelectCols.append(piitable.getColumn_name());
                } else {
                    sqlUpdate.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    //sqlSelectCols.append(", "+ piitable.getColumn_name());
                }
                colcnt++;
                catalogpkexistflg = true;
            }
            //UPDATE DELETE STEP ONLY CASE  20230305  ARCHIVE STEP을 제외하고 단독으로 UPDATE DELETE 돌릴때 SCRAMBLE 시 오류 수정
            if (i == 0) {
                sqlSelectCols.append(piitable.getColumn_name());
            } else {
                sqlSelectCols.append(", " + piitable.getColumn_name());
            }
        }

		/*	20210517 by Cha
		    Use JOB configuration of the table's pk_cols when pk doesn't exist in COTDL.TBL_PIITABLE( Catalog information )
		*/
        if (!catalogpkexistflg) {
            String[] array = piiordersteptable.getPk_col().replaceAll("[() ]", "").split(",");
            for (int i = 0; i < array.length; i++) {
                pkcols.put(array[i], colindex++);
                if (colcnt == 0) {
                    sqlUpdate.append(array[i] + "=" + "?" + "");
                    sqlDelete.append(array[i] + "=" + "?" + "");
                    //sqlSelectCols.append(array[i]);
                } else {
                    sqlUpdate.append(" and " + array[i] + "=" + "?" + "");
                    sqlDelete.append(" and " + array[i] + "=" + "?" + "");
                    //sqlSelectCols.append(", "+ array[i]);
                }
                colcnt++;
            }
        }

        if (!steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
            sqlSelect.append("SELECT " + hint);
            sqlSelect.append(sqlSelectCols.toString());
            sqlSelect.append(" from ");
            if ("BACKDATED".equalsIgnoreCase(piiordersteptable.getPagitypedetail()))
                sqlSelect.append(piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " A, COTDL.TBL_PIIKEYMAP_HIST B where ");
            else
                sqlSelect.append(piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " A, COTDL.TBL_PIIKEYMAP B where ");

            sqlSelect.append(piiordersteptable.getWherestr());
        }

        //sqlSelect.append(" ORDER BY DEPID");//tmp

        PreparedStatement pstmt_archive = null;
        PreparedStatement pstmt_execute = null;

        Statement stmt = null;
        ResultSet rs = null;
        int colid = 0;
        boolean isCommitcnt1 = false;
        if(commitcnt == 1) { isCommitcnt1 = true;}
        if(isCommitcnt1) {
            LogUtil.log("WARN", "sqlSelect  :  " + sqlSelect.toString());
            LogUtil.log("WARN", "sqlDelete  :  " + sqlDelete.toString());
            LogUtil.log("WARN", "sqlInsert  :  " + sqlInsert.toString());
            LogUtil.log("WARN", "sqlInsertIntoTarget  :  " + sqlInsertIntoTarget.toString());
            LogUtil.log("WARN", "update     :  " + sqlUpdate.toString());
            LogUtil.log("WARN", "@@@@   steptype =" + steptype);
            LogUtil.log("WARN", "pkcols.toString() =" + pkcols.toString());
        }
        try {
            if(isCommitcnt1) LogUtil.log("INFO", "=== PreparedStatement 생성 시작 ===");
            if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                if(isCommitcnt1) LogUtil.log("INFO", "sqlInsert length: " + sqlInsert.toString());
                pstmt_archive = connInsert.prepareStatement(sqlInsert.toString());
                if(isCommitcnt1) LogUtil.log("INFO", "Archive PreparedStatement created successfully");
            }

            if (existExeUpdate) { //아카이브 단계에서도 EXE_DELETE or EXE_UPDATE 를 수행하기 위해 해당 step 정보를 가져옴.
                if(isCommitcnt1) LogUtil.log("INFO", "sqlUpdate: [" + sqlUpdate.toString() + "]");
                pstmt_execute = connTarget.prepareStatement(sqlUpdate.toString());
                if(isCommitcnt1) LogUtil.log("INFO", "Update PreparedStatement created successfully");
            } else if (existExeDelete) {//아카이브 단계에서도 EXE_DELETE or EXE_UPDATE 를 수행하기 위해 해당 step 정보를 가져옴.
                if(isCommitcnt1) LogUtil.log("INFO", "sqlDelete: [" + sqlDelete.toString() + "]");
                pstmt_execute = connTarget.prepareStatement(sqlDelete.toString());
                if(isCommitcnt1) LogUtil.log("INFO", "Delete  PreparedStatement created successfully");
            }
            stmt = connTarget.createStatement();//LogUtil.log("INFO", "sqlSelect: "+sqlSelect.toString());
            if(isCommitcnt1) LogUtil.log("INFO", "connTarget.createStatement() successfully   created");
            rs = stmt.executeQuery(sqlSelect.toString());
            if(isCommitcnt1) LogUtil.log("INFO", "SELECT executed successfully   sqlSelect: [" + sqlSelect.toString() + "]");

            rs.setFetchSize(600);
            while (rs.next()) {// ROW 단위 데이터 SELECT
                if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                    pstmt_archive.setBigDecimal(1, rs.getBigDecimal(1));
                    pstmt_archive.setDate(2, rs.getDate(2));
                    pstmt_archive.setString(3, rs.getString(3));
                    pstmt_archive.setString(4, rs.getString(4));
                    pstmt_archive.setDate(5, rs.getDate(5));
                }

                if(isCommitcnt1) LogUtil.log("INFO", "pstmt_archive 5 cols successfully  set");
//				logger.info(piiordersteptable.getTable_name() +"1 * exeDLM SCRAMBLE row : rs= "+ rs.toString());
                //UPDATE 대체키 세팅
                int updatevalIndex = 0;
                if (isScramble) {
                    for (int i = 0; i < piitablecols.size(); i++) {
                        piitable = piitablecols.get(i);
                        colid = StrUtil.parseInt(piitable.getColumn_id());//LogUtil.log("INFO", "@@  colid"+colid+"  "+piitable.toString());
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            colid = colid + 5; //for the archive management cols
                        }
                        //--------------------------------------------------
                        if (existExeUpdate) {//LogUtil.log("INFO", "@@ 10 "+piitable.getColumn_name() +"   "+updatecols.get(piitable.getColumn_name()));
                            if (updatecols.containsKey(piitable.getColumn_name())) {//LogUtil.log("INFO", "@@ 1 "+piitable.getColumn_name() +"   "+updatecols.get(piitable.getColumn_name()));
                                String updateval = updatecols.get(piitable.getColumn_name()).toUpperCase().replace("'", "");
                                if (updateval.contains("SCRAMBLE")) {
                                    //LogUtil.log("INFO", "@@ 2 "+piitable.getColumn_name() +"    "+updateval+"     updatevalIndex="+updatevalIndex +"  "+sqlUpdate.toString());
                                    //LogUtil.log("INFO", "@@ 3 "+piitable.getColumn_name() +"    "+updateval+"     updatevalIndex="+updatevalIndex +"  "+sqlSelect.toString());
                                    //LogUtil.log("INFO", "@@ 4    colid= "+colid +"   rs.getString(colid)="+rs.getString(colid)+"     updatevalIndex="+updatevalIndex);
                                    // 스크램블에 글자 추가 로직 적용 20230207  ]!1#00~=[$~4f!~822!:i => "*" ]!1#00~=[$~4f!~822!:i
                                    pstmt_execute.setString(++updatevalIndex, updateval.replace("SCRAMBLE", Scramble.getScrResult(rs.getString(colid), "SCRAMBLE_NORMAL_ALL")));
                                }
                            }
                        }
                    }
                }
                if(isCommitcnt1) LogUtil.log("INFO", "UPDATE 대체키 세팅 successfully done");
				/*---------------------------------------------------------------------------------------
				   COLUMN 단위 데이터 처리 BEGIN
				-----------------------------------------------------------------------------------------*/
                int colid_target = 0;
                for (int i = 0; i < piitablecols.size(); i++) {
                    piitable = piitablecols.get(i);
                    colid = StrUtil.parseInt(piitable.getColumn_id());
                    colid_target = StrUtil.parseInt(piitable.getColumn_id());

                    isNoarcCol = false;
                    if (existNoarcCol)
                        if (noArchashMap.containsKey(piitable.getColumn_name())) {
                            isNoarcCol = true;
                        }

                    if(isCommitcnt1) LogUtil.log("INFO", "1 -----piiordersteptable.getTable_name()"+piiordersteptable.getTable_name()+"-"+piitable.getColumn_name());
//					if(piiordersteptable.getTable_name().equalsIgnoreCase("REGIMPUTATION"))
//						LogUtil.log("INFO", "exeDLM piitable.getData_type(): "+ piitable.getData_type()+"-"+piitable.getColumn_name());

                    if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                        colid = colid + 5; //for the archive management cols
                    }
					/*---------------------------------------------------------------------------------------
					   BEGIN => COLUMN TYPE 별 데이터 처리
					-----------------------------------------------------------------------------------------*/
                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                    ) {
                        //if(isCommitcnt1) LogUtil.log("INFO", "2 ---------- for (int i = 0; i < piitablecols.size(); i++)");
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if(commitcnt == 1) {
                                LogUtil.log("INFO", "Archive processing - Column: " + piitable.getColumn_name() + ", colid: " + colid + ", isNoarcCol: " + isNoarcCol);
                            }

                            if (rs.getObject(colid) == null || isNoarcCol) {
                                pstmt_archive.setNull(colid, Types.VARCHAR);
                                if(commitcnt == 1) LogUtil.log("INFO", "Archive setNull success - colid: " + colid);
                            } else {
                                pstmt_archive.setString(colid, rs.getString(colid));
                                if(commitcnt == 1) LogUtil.log("INFO", "Archive setString success - colid: " + colid + ", value: " + rs.getString(colid));
                            }
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if(commitcnt == 1) {
                                LogUtil.log("INFO", "Execute processing - Column: " + piitable.getColumn_name() + ", pkcols index: " + pkcols.get(piitable.getColumn_name()));
                            }

                            if (rs.getObject(colid) == null) {
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                                if(commitcnt == 1) LogUtil.log("INFO", "Execute setNull success - index: " + pkcols.get(piitable.getColumn_name()));
                            } else {
                                pstmt_execute.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colid));
                                if(commitcnt == 1) LogUtil.log("INFO", "Execute setString success - index: " + pkcols.get(piitable.getColumn_name()) + ", value: " + rs.getString(colid));
                            }

                            if(commitcnt == 1) {
                                LogUtil.log("INFO", "1@@ VARCHAR update "+piiordersteptable.getTable_name() +":"+piitable.getColumn_name() +":"+ pkcols.get(piitable.getColumn_name()) + "=" + rs.getString(colid));
                            }
                        }

                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BIGINT);
                            else pstmt_archive.setBigDecimal(colid, rs.getBigDecimal(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if(isCommitcnt1) {
                                LogUtil.log("INFO", "1@@ NUMBER update "+piiordersteptable.getTable_name() +":"+piitable.getColumn_name() +":"+ pkcols.get(piitable.getColumn_name()) + "=" + rs.getString(colid)); //pstmt_execute 는 EXE_UPDATE, EXE_DELETE 동일하게 WHERE 조건문의 ? 만 세팅하면 됨
                            }
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_execute.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colid));
                        }
						/*if(isPkColExistInUpdateCols) {
							if (upcols.containsKey(piitable.getColumn_name())) {  //pstmt_execute 는 EXE_UPDATE, EXE_DELETE 동일하게 WHERE 조건문의 ? 만 세팅하면 됨
								if(isNoarcCol){
									pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);
								}
							}else{
								if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);
								else pstmt_insert_into_target.setBigDecimal(colid_target , rs.getBigDecimal(colid));
							}
						}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.DATE);
                            else pstmt_archive.setDate(colid, rs.getDate(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                            else pstmt_execute.setDate(pkcols.get(piitable.getColumn_name()), rs.getDate(colid));
                        }
						/*if(isPkColExistInUpdateCols) {
							if (upcols.containsKey(piitable.getColumn_name())) {  //pstmt_execute 는 EXE_UPDATE, EXE_DELETE 동일하게 WHERE 조건문의 ? 만 세팅하면 됨
								if(isNoarcCol){
									pstmt_insert_into_target.setNull(colid_target, Types.DATE);
								}
							}else{
								if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.DATE);
								else pstmt_insert_into_target.setDate(colid_target , rs.getDate(colid));
							}
						}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol)
                                pstmt_archive.setNull(colid, Types.TIMESTAMP);
                            else pstmt_archive.setTimestamp(colid, rs.getTimestamp(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_execute.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colid));
                        } /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);else pstmt_insert_into_target.setTimestamp(colid_target , rs.getTimestamp(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol)
                                pstmt_archive.setNull(colid, Types.TIMESTAMP);
                            else pstmt_archive.setTimestamp(colid, rs.getTimestamp(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_execute.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colid));
                        } /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);else pstmt_insert_into_target.setTimestamp(colid_target , rs.getTimestamp(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol)
                                pstmt_archive.setNull(colid, Types.TIMESTAMP);
                            else pstmt_archive.setTimestamp(colid, rs.getTimestamp(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_execute.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colid));
                        } /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.TIMESTAMP);else pstmt_insert_into_target.setTimestamp(colid_target , rs.getTimestamp(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("CHAR")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.CHAR);
                            else pstmt_archive.setString(colid, rs.getString(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.CHAR);
                            else pstmt_execute.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colid));
                        }                           /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.CHAR);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.CHAR);else pstmt_insert_into_target.setString(colid_target , rs.getString(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.FLOAT);
                            else pstmt_archive.setFloat(colid, rs.getFloat(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                            else pstmt_execute.setFloat(pkcols.get(piitable.getColumn_name()), rs.getFloat(colid));
                        }                          /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.FLOAT);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.FLOAT);else pstmt_insert_into_target.setFloat(colid_target , rs.getFloat(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BIGINT);
                            else pstmt_archive.setLong(colid, rs.getLong(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else pstmt_execute.setLong(pkcols.get(piitable.getColumn_name()), rs.getLong(colid));
                        }                            /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);else pstmt_insert_into_target.setLong(colid_target , rs.getLong(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.DOUBLE);
                            else pstmt_archive.setDouble(colid, rs.getDouble(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                            else pstmt_execute.setDouble(pkcols.get(piitable.getColumn_name()), rs.getDouble(colid));
                        }                    /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.DOUBLE);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.DOUBLE);else pstmt_insert_into_target.setDouble(colid_target , rs.getDouble(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BOOLEAN);
                            else pstmt_archive.setBoolean(colid, rs.getBoolean(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                            else pstmt_execute.setBoolean(pkcols.get(piitable.getColumn_name()), rs.getBoolean(colid));
                        }              /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.BOOLEAN);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BOOLEAN);else pstmt_insert_into_target.setBoolean(colid_target , rs.getBoolean(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BIGINT);
                            else pstmt_archive.setBigDecimal(colid, rs.getBigDecimal(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_execute.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colid));
                        }    /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BIGINT);else pstmt_insert_into_target.setBigDecimal(colid_target , rs.getBigDecimal(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BLOB);
                            else pstmt_archive.setBlob(colid, rs.getBlob(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_execute.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colid));
                        }                                /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.BLOB);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BLOB);else pstmt_insert_into_target.setBlob(colid_target , rs.getBlob(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.BLOB);
                            else pstmt_archive.setBlob(colid, rs.getBlob(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_execute.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colid));
                        }                                /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.BLOB);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.BLOB);else pstmt_insert_into_target.setBlob(colid_target , rs.getBlob(colid));}}*/
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.CLOB);
                            else pstmt_archive.setClob(colid, rs.getClob(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                            else pstmt_execute.setClob(pkcols.get(piitable.getColumn_name()), rs.getClob(colid));
                        }                                /*if(isPkColExistInUpdateCols) {if (upcols.containsKey(piitable.getColumn_name())) {if(isNoarcCol){pstmt_insert_into_target.setNull(colid_target, Types.CLOB);}}else{if(rs.getObject(colid) == null || isNoarcCol) pstmt_insert_into_target.setNull(colid_target, Types.CLOB);else pstmt_insert_into_target.setClob(colid_target , rs.getClob(colid));}}*/
                    }

                    //else if(piitable.getData_type().equalsIgnoreCase("ROWID")) {if(steptype.equalsIgnoreCase("EXE_ARCHIVE")) {if(rs.getObject(colid) == null || isNoarcCol) pstmt_archive.setNull(colid, Types.ROWID); else pstmt_archive.setRowid(colid , rs.getRowid(colid));} if(existExeDelUp && pkcols.containsKey(piitable.getColumn_name())){if (rs.getObject(colid) == null) pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.ROWID); else pstmt_execute.setRowid(pkcols.get(piitable.getColumn_name()) , rs.getRowid(colid));}}
                    else {
                        //throw new RuntimeException("Unsupported argument, cannot be bound to SQL statement: " );
                        LogUtil.log("INFO", "Unsupported argument, cannot be bound to SQL statement: " + "exeDLM : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                            if (rs.getObject(colid) == null || isNoarcCol)
                                pstmt_archive.setNull(colid, Types.VARCHAR);
                            else
                                pstmt_archive.setString(colid, rs.getString(colid));
                        }
                        if (existExeDelUp && pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colid) == null)
                                pstmt_execute.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else
                                pstmt_execute.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colid));
                        }
                    }
                }

                /*
                 * Execution part
                 */
                //if this step come from EXE_ARCHIVE
                if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                    pstmt_archive.addBatch();
                }
                //Delete or Update step
                if (existExeDelUp) {//LogUtil.log("INFO", "#@  existExeDelUp");
                    pstmt_execute.addBatch();
					/*if(isPkColExistInUpdateCols) {//LogUtil.log("INFO", "#@ existExeDelUp isPkColExistInUpdateCols");
						pstmt_insert_into_target.addBatch();
					}*/
                }

                rowcount++;
                //LogUtil.log("INFO", "exeDLM : rowcount:"+rowcount+"   commitcnt:"+commitcnt);
                if ((rowcount) % commitcnt == 0) {
                    if(commitcnt == 1) {
                        LogUtil.log("INFO", "exeDLM : rowcount:" + rowcount + "   commitcnt:" + commitcnt);
                    }
                    if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                        pstmt_archive.executeBatch();// Execute every 3000 items.
                        pstmt_archive.clearBatch();// Batch
                    }
                    if (existExeDelUp) {
                        pstmt_execute.executeBatch();// Execute every commitcnt items.
                        pstmt_execute.clearBatch();
						/*if(isPkColExistInUpdateCols) {
							pstmt_insert_into_target.executeBatch();// Execute every commitcnt items.
							pstmt_insert_into_target.clearBatch();
						}*/
                    }
                    if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                        JdbcUtil.commit(connInsert);
                    }
                    JdbcUtil.commit(connTarget);
                    /* Execution status update
                     * this committed row count is used for Rerun case of UPDATE execution that needs delete archive data to avoid duplication of archive data
                     * */
                    rowcount_commited = rowcount;
                    //LogUtil.log("INFO", "exeDLM : rowcount_commited:"+rowcount_commited);
                    // update comitted count at every commitcnt*6
                    if ((rowcount) % (commitcnt * 6) == 0) {//LogUtil.log("INFO", "exeDLM : (rowcount) % (commitcnt*6) == 0 rowcount_commited updatecnt:"+rowcount_commited);
                        ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
//						if(steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
//							ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount);
//						}
                    }
                }

            }

            if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                pstmt_archive.executeBatch();// Execute every 3000 items.
                pstmt_archive.clearBatch();// Batch
            }

            if (existExeDelUp) {
                pstmt_execute.executeBatch();// Execute every commitcnt items.
                pstmt_execute.clearBatch();
				/*if(isPkColExistInUpdateCols) {
					pstmt_insert_into_target.executeBatch();// Execute every commitcnt items.
					pstmt_insert_into_target.clearBatch();
				}*/
            }

            if (steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
                JdbcUtil.commit(connInsert);
            }
            JdbcUtil.commit(connTarget);
            pkcols.clear();

            rowcount_commited = rowcount;

        } catch (SQLException e) {
            JdbcUtil.rollback(connInsert);
            JdbcUtil.rollback(connTarget);
            LogUtil.log("INFO", "exeDLM SQLException ex: "+ e.getMessage());
            // 에러 기록용 VO 생성
            ErrorHistVO err = new ErrorHistVO();
            err.setModule_name("PII_PURGE");
            err.setError_message(e.getMessage());
            err.setStack_trace(piiordersteptable.toString());
            // 서비스 호출
            errorHistSV.register(err);
            e.printStackTrace();
            throw e;
        } finally {
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
            if (orderstepexe != null) {
                ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
            }
            // commit은 catch에서 rollback하지 않은 경우(정상 흐름)에만 수행됨
            // catch에서 이미 rollback + throw 하므로 finally에서 중복 commit 제거
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(pstmt_archive);
            JdbcUtil.close(pstmt_execute);
        }

        return rowcount_commited;
    }

    public long exeRecovery(Connection connSelect, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols, String dbtype_source) throws Exception {

        StringBuilder sqlDelete = new StringBuilder();
        /** 20240610 복원시 pk dup 경우 해결을 위해 추가함*/
        StringBuilder sqlDelete_target = new StringBuilder();
        StringBuilder sqlSelect = new StringBuilder();
        StringBuilder sqlInsert = new StringBuilder();
        PiiTableVO piitable = null;
        boolean restoreFlag = piiordersteptable.getExetype().equals("RESTORE") ? true : false;

        String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
        sqlDelete.append(" delete from " + archiveTablePath);
        if (!StrUtil.checkString(piiordersteptable.getWherestr()))
            sqlDelete.append(" where " + piiordersteptable.getWherestr());

        sqlDelete_target.append(" delete from " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name());
        if (!StrUtil.checkString(piiordersteptable.getWherestr()))
            sqlDelete_target.append(" where 1=1 ");

        sqlSelect.append("select ");
        sqlSelect.append(" * from " + archiveTablePath + " ");

        if (!StrUtil.checkString(piiordersteptable.getWherestr()))
            sqlSelect.append(" where " + piiordersteptable.getWherestr());
        //LogUtil.log("INFO", "exeRecovery :sqlSelect: "+ sqlSelect.toString());

        sqlInsert.append("insert into " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " " + "values (");
        for (int i = 0; i < piitablecols.size(); i++) {
            piitable = piitablecols.get(i);
            if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                if (i == 0) sqlInsert.append("CHAR_TO_CLOB(?)");
                else sqlInsert.append(",CHAR_TO_CLOB(?)");
            } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                if (i == 0) sqlInsert.append("CHAR_TO_BLOB(?)");
                else sqlInsert.append(",CHAR_TO_BLOB(?)");
            } else {
                if (i == 0) sqlInsert.append("?");
                else sqlInsert.append(",?");
            }
        }
        sqlInsert.append(" ) ");
        //LogUtil.log("INFO", "exeRecovery : sqlInsert: "+ sqlInsert.toString());


        HashMap<String, Integer> pkcols = new HashMap<String, Integer>();

        int colindex = 1;
        boolean catalogpkexistflg = false;
        for (int i = 0; i < piitablecols.size(); i++) {
            piitable = piitablecols.get(i);
            if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
                pkcols.put(piitable.getColumn_name(), colindex++);
                sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                sqlDelete_target.append(" and " + piitable.getColumn_name() + "=" + "?" + "");

                catalogpkexistflg = true;
            }
        }

		/*
		    Use JOB configuration of the table's pk_cols when pk constraint doesn't exist in COTDL.TBL_PIITABLE( Catalog information )
		*/
        if (!catalogpkexistflg) {
            String[] array = piiordersteptable.getPk_col().replaceAll("[() ]", "").split(",");
            for (int i = 0; i < array.length; i++) {
                pkcols.put(array[i], colindex++);
                sqlDelete.append(" and " + array[i] + "=" + "?" + "");
                sqlDelete_target.append(" and " + array[i] + "=" + "?" + "");
            }
        }

        logger.info(sqlInsert.toString());
        logger.info(sqlDelete.toString());
        if(restoreFlag)
            logger.info(sqlDelete_target.toString());

        //get current execnt
        long rowcount = 0;
        long rowcount_commited = 0;
        try {
            rowcount = StrUtil.parseLong(piiordersteptable.getExecnt());
        } catch (Exception e) {
            rowcount = 0;
        }
        rowcount_commited = rowcount;

        //set commit cnt
        int commitcnt = 3000;
        try {
            commitcnt = Integer.parseInt(piiordersteptable.getCommitcnt());
        } catch (Exception e) {
            commitcnt = 3000;
        }
        //LogUtil.log("INFO", "######## exeRecovery = "+commitcnt);
        PreparedStatement pstmt_ins = null;
        PreparedStatement pstmt_del = null;
        PreparedStatement pstmt_del_target = null;
        Statement stmt = null;
        ResultSet rs = null;
        int colid = 0;
        int colidarc = 0;
        try {
            if(restoreFlag)
                pstmt_del_target = connInsert.prepareStatement(sqlDelete_target.toString());

            pstmt_ins = connInsert.prepareStatement(sqlInsert.toString());
            pstmt_del = connSelect.prepareStatement(sqlDelete.toString());

            stmt = connSelect.createStatement();
            rs = stmt.executeQuery(sqlSelect.toString());
            rs.setFetchSize(600);
            while (rs.next()) {
                for (int i = 0; i < piitablecols.size(); i++) {
                    piitable = piitablecols.get(i);
                    colid = StrUtil.parseInt(piitable.getColumn_id());//LogUtil.log("INFO", "exeRecovery piitable.getData_type(): "+ piitable.getData_type()+"-"+piitable.getColumn_name()+"-"+colid);
                    colidarc = colid + 5; //for the Archive mamagement columns

                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
//							|| piitable.getData_type().equalsIgnoreCase("CLOB")
                    ) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.VARCHAR);
                        else pstmt_ins.setString(colid, rs.getString(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            }else {
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BIGINT);
                        else pstmt_ins.setBigDecimal(colid, rs.getBigDecimal(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            }else {
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.DATE);
                        else pstmt_ins.setDate(colid, rs.getDate(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                            } else {
                                pstmt_del.setDate(pkcols.get(piitable.getColumn_name()), rs.getDate(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setDate(pkcols.get(piitable.getColumn_name()), rs.getDate(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.TIMESTAMP);
                        else pstmt_ins.setTimestamp(colid, rs.getTimestamp(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            } else {
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.TIMESTAMP);
                        else pstmt_ins.setTimestamp(colid, rs.getTimestamp(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            } else {
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.TIMESTAMP);
                        else pstmt_ins.setTimestamp(colid, rs.getTimestamp(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            } else {
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setTimestamp(pkcols.get(piitable.getColumn_name()), rs.getTimestamp(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CHAR")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.CHAR);
                        else pstmt_ins.setString(colid, rs.getString(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CHAR);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.CHAR);
                            } else {
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.FLOAT);
                        else pstmt_ins.setFloat(colid, rs.getFloat(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                            } else {
                                pstmt_del.setFloat(pkcols.get(piitable.getColumn_name()), rs.getFloat(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setFloat(pkcols.get(piitable.getColumn_name()), rs.getFloat(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BIGINT);
                        else pstmt_ins.setLong(colid, rs.getLong(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            } else {
                                pstmt_del.setLong(pkcols.get(piitable.getColumn_name()), rs.getLong(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setLong(pkcols.get(piitable.getColumn_name()), rs.getLong(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.DOUBLE);
                        else pstmt_ins.setDouble(colid, rs.getDouble(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                            } else {
                                pstmt_del.setDouble(pkcols.get(piitable.getColumn_name()), rs.getDouble(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setDouble(pkcols.get(piitable.getColumn_name()), rs.getDouble(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BOOLEAN);
                        else pstmt_ins.setBoolean(colid, rs.getBoolean(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                            } else {
                                pstmt_del.setBoolean(pkcols.get(piitable.getColumn_name()), rs.getBoolean(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setBoolean(pkcols.get(piitable.getColumn_name()), rs.getBoolean(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BIGINT);
                        else pstmt_ins.setBigDecimal(colid, rs.getBigDecimal(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            } else {
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setBigDecimal(pkcols.get(piitable.getColumn_name()), rs.getBigDecimal(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BLOB);
                        else pstmt_ins.setBlob(colid, rs.getBlob(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            } else {
                                pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colidarc));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.BLOB);
                        else pstmt_ins.setBlob(colid, rs.getBlob(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            } else {
                                pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setBlob(pkcols.get(piitable.getColumn_name()), rs.getBlob(colidarc));
                            }
                        }
                    }
//					else if(piitable.getData_type().equalsIgnoreCase("CLOB")) 	 	{if(rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.CLOB); else pstmt_ins.setClob(colid , rs.getClob(colidarc)); 	if(pkcols.containsKey(piitable.getColumn_name())){if(rs.getObject(colidarc) == null) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB); else pstmt_del.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));}}
//					else if(piitable.getData_type().equalsIgnoreCase("CLOB")) 	 	{if(rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.CLOB); else pstmt_ins.setClob(colid , rs.getClob(colidarc)); 	if(pkcols.containsKey(piitable.getColumn_name())){if(rs.getObject(colidarc) == null) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB); else pstmt_del.setObject(pkcols.get(piitable.getColumn_name()), rs.getClob(colidarc));}}
                    else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.CLOB);
                        else pstmt_ins.setClob(colid, rs.getClob(colidarc));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                            } else {
                                pstmt_del.setClob(pkcols.get(piitable.getColumn_name()), rs.getClob(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setClob(pkcols.get(piitable.getColumn_name()), rs.getClob(colidarc));
                            }
                        }
                    }

                    //else if(piitable.getData_type().equalsIgnoreCase("ROWID")) 	 	{if(rs.getObject(colidarc) == null) pstmt_ins.setNull(colid, Types.ROWID); else pstmt_ins.setRowid(colid , rs.getRowid(colidarc)); 	if(pkcols.containsKey(piitable.getColumn_name())){if(rs.getObject(colidarc) == null) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.ROWID); else pstmt_del.setRowid(pkcols.get(piitable.getColumn_name()), rs.getRowid(colidarc));}}
                    else {
                        //throw new RuntimeException("Unsupported argument, cannot be bound to SQL statement: " );
                        LogUtil.log("INFO", "exeRecovery Unsupported argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (rs.getObject(colidarc) == null) {
                            pstmt_ins.setNull(colid, Types.VARCHAR);
                        } else {
                            pstmt_ins.setString(colid, rs.getString(colidarc));
                        }
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colidarc) == null) {
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                                if(restoreFlag)
                                    pstmt_del_target.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            } else {
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                                if(restoreFlag)
                                    pstmt_del_target.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colidarc));
                            }
                        }
                    }
                }

                LogUtil.log("INFO", "exeRecovery rowcount:" + rowcount);
                if(restoreFlag) {
                    pstmt_del_target.addBatch();
                }
                pstmt_ins.addBatch();
                pstmt_del.addBatch();

                rowcount++;
                if ((rowcount) % commitcnt == 0) {// Execute every commitcnt items.
                    //delete Target data to avoid PK dup
                    if(restoreFlag) {
                        pstmt_del_target.executeBatch();
                        pstmt_del_target.clearBatch();
                    }
                    //insert data to Target
                    pstmt_ins.executeBatch();
                    pstmt_ins.clearBatch();
                    JdbcUtil.commit(connInsert);
                    //delete pii archive data
                    pstmt_del.executeBatch();
                    pstmt_del.clearBatch();
                    JdbcUtil.commit(connSelect);

                    rowcount_commited = rowcount;

                    // every commitcnt*6 status update
                    if ((rowcount) % (commitcnt * 6) == 0) {
                        ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
//						if(steptype.equalsIgnoreCase("EXE_ARCHIVE")) {
//							ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), orderstepexe.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount);
//						}
                    }
                }
            }

            if (rowcount > 0) {//for processing the remaining data
                //delete Target data to avoid PK dup
                if(restoreFlag) {
                    pstmt_del_target.executeBatch();
                    pstmt_del_target.clearBatch();
                }
                //insert data to Target
                pstmt_ins.executeBatch();
                pstmt_ins.clearBatch();
                JdbcUtil.commit(connInsert);
                //delete pii archive data
                pstmt_del.executeBatch();
                pstmt_del.clearBatch();
                JdbcUtil.commit(connSelect);
                rowcount_commited = rowcount;
            }

        } catch (SQLException e) {
            JdbcUtil.rollback(connInsert);
            JdbcUtil.rollback(connSelect);
            logger.warn("warn "+"exeRecovery SQLException ex: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
            JdbcUtil.commit(connInsert);
            JdbcUtil.commit(connSelect);
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(pstmt_ins);
            JdbcUtil.close(pstmt_del);
            if(restoreFlag)
                JdbcUtil.close(pstmt_del_target);
        }

        return rowcount_commited;
    }

    public long exeRecoveryUpdate(Connection connSelect, Connection connUpdate, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols, List<PiiOrderStepTableUpdateVO> piisteptableupdatelist, String dbtype_source, String gapupdrowexception) throws Exception {

        StringBuilder sqlDelete = new StringBuilder();
        StringBuilder sqlSelect = new StringBuilder();
        StringBuilder sqlUpdate = new StringBuilder();

        PiiTableVO piitable = null;
        PiiOrderStepTableUpdateVO piisteptableupdate = null;
        String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piiordersteptable.getDb(), piiordersteptable.getOwner(), piiordersteptable.getTable_name());
        sqlDelete.append(" delete from " + archiveTablePath);
        if (!StrUtil.checkString(piiordersteptable.getWherestr()))
            sqlDelete.append(" where " + piiordersteptable.getWherestr());

        sqlSelect.append("select ");

//		HashMap<String, Integer> upcolpkcols = new HashMap<String, Integer>();
        HashMap<Integer, String> upcolpkcols = new HashMap<Integer, String>();
        HashMap<Integer, String> onlypkcols = new HashMap<Integer, String>();
        HashMap<String, Integer> pkcols = new HashMap<String, Integer>();
        HashMap<String, String> scramblecols = new HashMap<String, String>();
        int colindex = 1;
        int pkcolindex = 1;
        int scramblecolindex = 1;

        sqlUpdate.append("update " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " ");
        sqlUpdate.append("set ");
        for (int i = 0; i < piisteptableupdatelist.size(); i++) {
            piisteptableupdate = piisteptableupdatelist.get(i);
            upcolpkcols.put(colindex++, piisteptableupdate.getColumn_name());

            // PK칼럼 업데이트 파기 경우 복원 시 원래의 칼럼값을 파기와 동일하게 스크램블한 값으로 원천을 찾아야 하므로 추가함 20230208 by Cha
            if (piisteptableupdate.getUpdate_val().toUpperCase().contains("SCRAMBLE")) {
                scramblecols.put(piisteptableupdate.getColumn_name(), piisteptableupdate.getUpdate_val().toUpperCase().replace("'", ""));
            }

            if (i == 0) {
                sqlUpdate.append(piisteptableupdate.getColumn_name() + "=" + "?" + "");
                sqlSelect.append(piisteptableupdate.getColumn_name() + " ");
            } else {
                sqlUpdate.append(", " + piisteptableupdate.getColumn_name() + "=" + "?" + "");
                sqlSelect.append(", " + piisteptableupdate.getColumn_name() + " ");
            }
        }
        sqlUpdate.append(" where ");

        int colcnt = 0;

        boolean catalogpkexistflg = false;
        for (int i = 0; i < piitablecols.size(); i++) {
            piitable = piitablecols.get(i);
            if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
                onlypkcols.put(colindex, piitable.getColumn_name());
                upcolpkcols.put(colindex++, piitable.getColumn_name());
                pkcols.put(piitable.getColumn_name(), pkcolindex++);
                if (colcnt == 0) {
                    sqlUpdate.append(piitable.getColumn_name() + "=" + "?" + "");
                    sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    sqlSelect.append(", " + piitable.getColumn_name() + " ");
                } else {
                    sqlUpdate.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    sqlSelect.append(", " + piitable.getColumn_name() + " ");
                }
                colcnt++;
                catalogpkexistflg = true;
            }
        }

		/*
		    Use configuration of the table's pk_cols when pk doesn't exist in COTDL.TBL_PIITABLE( Catalog information )
		*/
        //colindex=1;
        if (!catalogpkexistflg) {
            String[] array = piiordersteptable.getPk_col().replaceAll("[() ]", "").split(",");
            for (int i = 0; i < array.length; i++) {
                upcolpkcols.put(colindex++, array[i]);
                pkcols.put(array[i], pkcolindex++);
                if (colcnt == 0) {
                    sqlUpdate.append(array[i] + "=" + "?" + "");
                    sqlDelete.append(" and " + array[i] + "=" + "?" + "");
                    sqlSelect.append(", " + array[i] + " ");
                } else {
                    sqlUpdate.append(" and " + array[i] + "=" + "?" + "");
                    sqlDelete.append(" and " + array[i] + "=" + "?" + "");
                    sqlSelect.append(", " + array[i] + " ");
                }
                colcnt++;
            }
        }

        //LogUtil.log("INFO", "exeRecoveryUpdate: sqlUpdate: "+sqlUpdate+"=="+ pkcols.toString());
        sqlSelect.append(" from " + archiveTablePath + " ");
        sqlSelect.append(" where " + piiordersteptable.getWherestr());

        //get current execnt
        long rowcount = 0;
        long rowcount_per_batch = 0;
        long rowcount_update = 0;
        long rowcount_commited = 0;
        try {
            rowcount = StrUtil.parseLong(piiordersteptable.getExecnt());
        } catch (Exception e) {
            rowcount = 0;
        }
        rowcount_commited = rowcount;

        //set commit cnt
        int commitcnt = 3000;
        try {
            commitcnt = Integer.parseInt(piiordersteptable.getCommitcnt());
        } catch (Exception e) {
            commitcnt = 3000;
        }
        //LogUtil.log("INFO", "######## exeRecoveryUpdate   = "+commitcnt);
        PreparedStatement pstmt_upd = null;
        PreparedStatement pstmt_del = null;
        Statement stmt = null;
        ResultSet rs = null;
        int colseq = 0;
        String colname = null;
        try {
            LogUtil.log("INFO", "sqlUpdate: "+sqlUpdate.toString());
            LogUtil.log("INFO", "sqlDelete: "+sqlDelete.toString());
            pstmt_upd = connUpdate.prepareStatement(sqlUpdate.toString());
            pstmt_del = connSelect.prepareStatement(sqlDelete.toString());
            stmt = connSelect.createStatement();
            rs = stmt.executeQuery(sqlSelect.toString());
            rs.setFetchSize(600);
            while (rs.next()) {
                for (Entry<Integer, String> entry : upcolpkcols.entrySet()) {
                    colseq = entry.getKey();
                    colname = entry.getValue();

                    for (int i = 0; i < piitablecols.size(); i++) {
                        piitable = piitablecols.get(i);
                        if (colname.equalsIgnoreCase(piitablecols.get(i).getColumn_name())) {
                            break;
                        }
                    }

//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : sqlSelect.toString():"+sqlSelect.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : sqlUpdate.toString():"+sqlUpdate.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : sqlDelete.toString():"+sqlDelete.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : table:"+piitable.getTable_name()+" type:"+piitable.getData_type()+"  Column_name:"+ piitable.getColumn_name() +"  colseq:"+colseq+"  rs.getString(colseq):"+rs.getString(colseq)+"  upcolpkcols.toString():"+upcolpkcols.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : scramblecols:"+scramblecols.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : upcolpkcols:"+upcolpkcols.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : pkcols:"+pkcols.toString());
//					LogUtil.log("INFO", "exeRecoveryUpdate $$$$$$$$$$$$$$$ : onlypkcols:"+onlypkcols.toString());
                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                    ) {//LogUtil.log("INFO", "@@ 0 colseq colname"+"  "+colseq+"  "+colname +"  "+rs.getString(colseq));
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.VARCHAR);
                        else {//LogUtil.log("INFO", "@@ 1 colname"+colname);
                            if (onlypkcols.containsKey(colseq) && scramblecols.containsKey(colname)) {
                                pstmt_upd.setString(colseq, scramblecols.get(colname).replace("SCRAMBLE", Scramble.getScrResult(rs.getString(colseq), "SCRAMBLE_NORMAL_ALL")));
                            } else {//LogUtil.log("INFO", "@@ 3 colname  "+colname);
                                pstmt_upd.setString(colseq, rs.getString(colseq));
                            }
                        }
                        if (pkcols.containsKey(colname)) {// Archive data DELETE 만 수행 하는 부분
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.VARCHAR);
                            else pstmt_del.setString(pkcols.get(colname), rs.getString(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BIGINT);
                        else pstmt_upd.setBigDecimal(colseq, rs.getBigDecimal(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BIGINT);
                            else pstmt_del.setBigDecimal(pkcols.get(colname), rs.getBigDecimal(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.DATE);
                        else pstmt_upd.setDate(colseq, rs.getDate(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.DATE);
                            else pstmt_del.setDate(pkcols.get(colname), rs.getDate(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.TIMESTAMP);
                        else pstmt_upd.setTimestamp(colseq, rs.getTimestamp(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.TIMESTAMP);
                            else pstmt_del.setTimestamp(pkcols.get(colname), rs.getTimestamp(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.TIMESTAMP);
                        else pstmt_upd.setTimestamp(colseq, rs.getTimestamp(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.TIMESTAMP);
                            else pstmt_del.setTimestamp(pkcols.get(colname), rs.getTimestamp(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.TIMESTAMP);
                        else pstmt_upd.setTimestamp(colseq, rs.getTimestamp(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.TIMESTAMP);
                            else pstmt_del.setTimestamp(pkcols.get(colname), rs.getTimestamp(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CHAR")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.CHAR);
                        else pstmt_upd.setString(colseq, rs.getString(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.CHAR);
                            else pstmt_del.setString(pkcols.get(colname), rs.getString(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.FLOAT);
                        else pstmt_upd.setFloat(colseq, rs.getFloat(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.FLOAT);
                            else pstmt_del.setFloat(pkcols.get(colname), rs.getFloat(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BIGINT);
                        else pstmt_upd.setLong(colseq, rs.getLong(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BIGINT);
                            else pstmt_del.setLong(pkcols.get(colname), rs.getLong(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.DOUBLE);
                        else pstmt_upd.setDouble(colseq, rs.getDouble(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.DOUBLE);
                            else pstmt_del.setDouble(pkcols.get(colname), rs.getDouble(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BOOLEAN);
                        else pstmt_upd.setBoolean(colseq, rs.getBoolean(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BOOLEAN);
                            else pstmt_del.setBoolean(pkcols.get(colname), rs.getBoolean(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BIGINT);
                        else pstmt_upd.setBigDecimal(colseq, rs.getBigDecimal(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BIGINT);
                            else pstmt_del.setBigDecimal(pkcols.get(colname), rs.getBigDecimal(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BLOB);
                        else pstmt_upd.setBlob(colseq, rs.getBlob(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(colname), rs.getBlob(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.BLOB);
                        else pstmt_upd.setBlob(colseq, rs.getBlob(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(colname), rs.getBlob(colseq));
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.CLOB);
                        else pstmt_upd.setClob(colseq, rs.getClob(colseq));
                        if (pkcols.containsKey(colname)) {
                            if (rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.CLOB);
                            else pstmt_del.setClob(pkcols.get(colname), rs.getClob(colseq));
                        }
                    }

                    //else if(piitable.getData_type().equalsIgnoreCase("ROWID")) 	 {if(rs.getObject(colseq) == null) pstmt_upd.setNull(colseq, Types.ROWID); else pstmt_upd.setRowid(colseq , rs.getRowid(colseq)); 	if(pkcols.containsKey(colname)){if(rs.getObject(colseq) == null) pstmt_del.setNull(pkcols.get(colname), Types.ROWID); else pstmt_del.setRowid(pkcols.get(colname), rs.getRowid(colseq));}}
                    else {
                        LogUtil.log("INFO", "exeRecoveryUpdate Unsupported argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (rs.getObject(colseq) == null) {
                            pstmt_upd.setNull(colseq, Types.VARCHAR);
                        } else {
                            pstmt_upd.setString(colseq, rs.getString(colseq));
                        }
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (rs.getObject(colseq) == null)
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), rs.getString(colseq));
                        }
                    }
                }
//				LogUtil.log("INFO", "exeRecovery rowcount:" + rowcount);

                pstmt_upd.addBatch();
                pstmt_del.addBatch();
                rowcount++;
                rowcount_per_batch++;


                if ((rowcount) % commitcnt == 0) {// Execute every commitcnt items.
                    pstmt_upd.executeBatch();

                    rowcount_update = pstmt_upd.getUpdateCount();
//					LogUtil.log("INFO", "0 GapUpdRowException() "+piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name()+" Target row="+rowcount_update+"  Archive row="+rowcount_per_batch);
                    if (gapupdrowexception.equalsIgnoreCase("Y")) {
                        if (rowcount_update != rowcount_per_batch) {
                            pstmt_upd.clearBatch();
                            pstmt_del.clearBatch();
                            JdbcUtil.rollback(connUpdate);
                            JdbcUtil.rollback(connSelect);
                            JdbcUtil.close(rs);
                            JdbcUtil.close(stmt);
                            JdbcUtil.close(pstmt_upd);
                            JdbcUtil.close(pstmt_del);
                            logger.warn("warn "+"1 GapUpdRowException() " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " Target row=" + rowcount_update + "  Archive row=" + rowcount_per_batch);
                            throw new GapUpdRowException("GapUpdRowException() " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " Target row=" + rowcount_update + "  Archive row=" + rowcount_per_batch);
                        }
                    }
                    //	LogUtil.log("INFO", "Same cnt ### Target row="+rowcount_update+"  Archive row="+rowcount_per_batch);

                    pstmt_upd.clearBatch();
                    JdbcUtil.commit(connUpdate);
                    //delete pii archive data
                    pstmt_del.executeBatch();
                    pstmt_del.clearBatch();
                    JdbcUtil.commit(connSelect);

                    rowcount_commited = rowcount;
                    rowcount_per_batch = 0;

                    // every commitcnt*6 status update
                    if ((rowcount) % (commitcnt * 6) == 0) {
                        ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
                    }
                }
            }

            if (rowcount > 0) {
                //for processing the remaining data
                pstmt_upd.executeBatch();

                rowcount_update = pstmt_upd.getUpdateCount();
//				LogUtil.log("INFO", "00 GapUpdRowException() "+piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name()+" Target row="+rowcount_update+"  Archive row="+rowcount_per_batch);
                if (gapupdrowexception.equalsIgnoreCase("Y")) {
                    if (rowcount_per_batch > 0 & rowcount_update > 0) {
                        if (rowcount_update != rowcount_per_batch) {
                            JdbcUtil.close(rs);
                            JdbcUtil.close(stmt);
                            JdbcUtil.close(pstmt_upd);
                            JdbcUtil.close(pstmt_del);
                            logger.warn("warn "+"2 GapUpdRowException() " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " Target row=" + rowcount_update + "  Archive row=" + rowcount_per_batch);
                            throw new GapUpdRowException("GapUpdRowException() " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + "Target row=" + rowcount_update + "  Archive row=" + rowcount_per_batch);
                        }
                    }
                }
                //	LogUtil.log("INFO", "Same cnt ### Target row="+rowcount_update+"  Archive row="+rowcount_per_batch);

                pstmt_upd.clearBatch();
                JdbcUtil.commit(connUpdate);
                //delete pii archive data
                pstmt_del.executeBatch();
                pstmt_del.clearBatch();
                JdbcUtil.commit(connSelect);

                rowcount_commited = rowcount;
                rowcount_per_batch = 0;
            }

        } catch (GapUpdRowException e) {
            pstmt_upd.clearBatch();
            pstmt_del.clearBatch();
            JdbcUtil.rollback(connUpdate);
            JdbcUtil.rollback(connSelect);
            logger.warn("warn "+"exeRecoveryUpdate GapUpdRowException ex: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } catch (SQLException e) {
            pstmt_upd.clearBatch();
            pstmt_del.clearBatch();
            JdbcUtil.rollback(connUpdate);
            JdbcUtil.rollback(connSelect);
            logger.warn("warn "+"exeRecoveryUpdate SQLException ex: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount_commited);
            JdbcUtil.commit(connUpdate);
            JdbcUtil.commit(connSelect);
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(pstmt_upd);
            JdbcUtil.close(pstmt_del);
        }

        return rowcount;
    }

    public long exeBroadcast(Connection connSelect, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols, String dbtype_source) throws Exception {
        //StringBuilder sqlDelete = new StringBuilder();
        StringBuilder sqlSelect = new StringBuilder();
        StringBuilder sqlInsert = new StringBuilder();

        String selTable = piiordersteptable.getTable_name();
        if (selTable.equalsIgnoreCase("TBL_PIIKEYMAP_HIST"))
            selTable = selTable.replaceAll("(?i)TBL_PIIKEYMAP_HIST", "TBL_PIIKEYMAP");

        sqlSelect.append("select ");
        sqlSelect.append(" A.* from " + piiordersteptable.getOwner() + "." + selTable + " A");

        if (!StrUtil.checkString(piiordersteptable.getWherestr()))
            sqlSelect.append(" where " + piiordersteptable.getWherestr());

//		LogUtil.log("INFO", "exeBroadcast: connSelect: "+ connSelect.toString());
//		LogUtil.log("INFO", "exeBroadcast: connInsert: "+ connInsert.toString());
//		LogUtil.log("INFO", "exeBroadcast:sqlSelect: "+ sqlSelect.toString());

        sqlInsert.append("insert into " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " " + "values (");
        for (int i = 0; i < piitablecols.size(); i++) {
            if (i == 0) sqlInsert.append("?");
            else sqlInsert.append(",?");
        }
        sqlInsert.append(" ) ");
//		LogUtil.log("INFO", "exeBroadcast: sqlInsert: "+ sqlInsert.toString());

        /** get current execnt */
        long rowcount = 0;
        try {
            rowcount = StrUtil.parseLong(piiordersteptable.getExecnt());
        } catch (Exception e) {
            rowcount = 0;
        }

        PiiTableVO piitable = null;
        PreparedStatement pstmt = null;
        Statement stmt = null;
        ResultSet rs = null;
        int colid = 0;
        try {
            pstmt = connInsert.prepareStatement(sqlInsert.toString());
            stmt = connSelect.createStatement();
            rs = stmt.executeQuery(sqlSelect.toString());
            rs.setFetchSize(600);
            while (rs.next()) {
                for (int i = 0; i < piitablecols.size(); i++) {
                    piitable = piitablecols.get(i);
                    colid = StrUtil.parseInt(piitable.getColumn_id());//LogUtil.log("INFO", "exeBroadcast piitable.getData_type(): "+ piitable.getData_type()+"-"+piitable.getColumn_name());

                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                    ) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.VARCHAR);
                        else pstmt.setString(colid, rs.getString(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, rs.getBigDecimal(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.DATE);
                        else pstmt.setDate(colid, rs.getDate(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, rs.getTimestamp(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, rs.getTimestamp(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, rs.getTimestamp(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("CHAR")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.CHAR);
                        else pstmt.setString(colid, rs.getString(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.FLOAT);
                        else pstmt.setFloat(colid, rs.getFloat(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setLong(colid, rs.getLong(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("BIGDECIMAL")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, rs.getBigDecimal(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.DOUBLE);
                        else pstmt.setDouble(colid, rs.getDouble(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BOOLEAN);
                        else pstmt.setBoolean(colid, rs.getBoolean(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, rs.getBigDecimal(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, rs.getBlob(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, rs.getBlob(colid));
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.CLOB);
                        else pstmt.setClob(colid, rs.getClob(colid));
                    }

                    //else if (piitable.getData_type().equalsIgnoreCase("ROWID")) 		{if (rs.getObject(colid) == null) pstmt.setNull(colid, Types.ROWID); 	else pstmt.setRowid(		colid 	, rs.getRowid(colid));}
                    else {
                        LogUtil.log("INFO", "exeBroadcast defined argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (rs.getObject(colid) == null)
                            pstmt.setNull(colid, Types.VARCHAR);
                        else
                            pstmt.setString(colid, rs.getString(colid));
                    }
                }
//				LogUtil.log("INFO", "exeBroadcast rowcount:" + rowcount);
                pstmt.addBatch();
                rowcount++;
                if ((rowcount) % 3000 == 0) {//LogUtil.log("INFO", "1 exeBroadcast (rowcount) % 3000 == 0):" + rowcount);
                    pstmt.executeBatch();// Execute every commitcnt items.
                    pstmt.clearBatch();
                    JdbcUtil.commit(connInsert);
                    // 3000*6 행마다 카운트 업데이트 (UI 실시간 반영)
                    if ((rowcount) % (3000 * 6) == 0) {
                        ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount);
                    }
                }
            }
//			LogUtil.log("INFO", "exeBroadcast rowcount:" + rowcount);
            if (rowcount > 0) {//LogUtil.log("INFO", "2 exeBroadcast (rowcount) % 3000 == 0):" + rowcount);
                //for processing the remaining data
                pstmt.executeBatch();
                pstmt.clearBatch();
                JdbcUtil.commit(connInsert);
            }

        } catch (SQLException e) {
            JdbcUtil.rollback(connInsert);
            LogUtil.log("INFO", "exeBroadcast SQLException ex: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), rowcount);
            JdbcUtil.commit(connInsert);
            JdbcUtil.close(rs);
            JdbcUtil.close(stmt);
            JdbcUtil.close(pstmt);
        }

        return rowcount;
    }
    public long exeSYNC(Connection connSelect, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, boolean sourceDelflag, String stopHourFromTo, int commit_loop_cnt) throws Exception {
        String dbtype_source = sourceDBvo.getDbtype();
        String dbtype_target = targetDBvo.getDbtype();
        String db_source = sourceDBvo.getDb();
        String db_target = targetDBvo.getDb();
        boolean samedb = db_source.equals(db_target);
        /** 작업 시작 */
        LogUtil.log("INFO", ": exeSYNC : start" + piiordersteptable.toString());
        /** 작업 병렬수 */
        int batchSize = StrUtil.parseInt(piiordersteptable.getCommitcnt());

        StringBuilder sqlSelect = new StringBuilder("SELECT OPERATION, OPERATION_TIME, OPERATION_DATE, PROCESSING_TIME, ");
        StringBuilder sqlInsert = new StringBuilder();
        StringBuilder sqlDelete = new StringBuilder();
        // Hashtable 생성
        Hashtable<String, Integer> sourceCols = new Hashtable<>();
        // List<MetaTableVO>의 데이터를 Hashtable에 넣기
        for (PiiTableVO tableVO : piitablecols_source) {
            sourceCols.put(tableVO.getColumn_name(), StrUtil.parseInt(tableVO.getColumn_id()));
        }

        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();

        String owner_mig_target = piiordersteptable.getWhere_key_name();
        String table_name_mig_target = piiordersteptable.getSqlstr();

        int pkcolindex = 1;
        HashMap<String, Integer> pkcols = new HashMap<String, Integer>();

        sqlDelete.append("delete " + "" + " from " + owner + "." + table_name + " where ");
        sqlInsert.append("insert /*+ APPEND NOLOGGING */ into " + owner + "." + table_name + " " + "values (");

        LogUtil.log("INFO", "exeSYNC : piitablecols_source.size(): " + piitablecols_source.size());
        for (int i = 0; i < piitablecols_source.size(); i++) {
            if (i > 0) {
                sqlInsert.append(", ");
                sqlSelect.append(", ");
            }
            sqlInsert.append("?");
            PiiTableVO piitable = piitablecols_source.get(i);
            String columnType = piitable.getData_type();
            String columnName = piitable.getColumn_name();
            if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
                pkcols.put(piitable.getColumn_name(), pkcolindex++);
                if (i == 0) {
                    sqlDelete.append(piitable.getColumn_name() + "=" + "?" + "");
                } else {
                    sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                }

            }
            sqlSelect.append(columnName);

        }
        sqlInsert.append(")");

        sqlSelect.append(" from " + "cotdl"+ "." + table_name + "_TG where ");
        sqlSelect.append(piiordersteptable.getWherestr());
        sqlSelect.append(" order by OPERATION_TIME");

        LogUtil.log("INFO", " exeSYNC: sqlSelect: " + sqlSelect.toString());
        LogUtil.log("INFO", " exeSYNC: sqlInsert: " + sqlInsert.toString());
        LogUtil.log("INFO", " exeSYNC: sqlDelete: " + sqlDelete.toString());

        long totalCount = 0; //전체 카운트 select 해서 처리하는 전체 count
        try (
                PreparedStatement pstmt = connInsert.prepareStatement(sqlInsert.toString());
                PreparedStatement pstmt_del = connInsert.prepareStatement(sqlDelete.toString());
                Statement stmtSelect = connSelect.createStatement();
                ResultSet rs = stmtSelect.executeQuery(sqlSelect.toString())
        ) {
            connInsert.setAutoCommit(false);
            connSelect.setAutoCommit(false);
            rs.setFetchSize(600);
            while (rs.next()) {
                String operation = rs.getString("OPERATION");
                /** 데이터 추출 및 preparedStatement에 세팅 */
                for (int i = 0; i < piitablecols_target.size(); i++) {
                    PiiTableVO piitable = piitablecols_target.get(i);
                    int colid = StrUtil.parseInt(piitable.getColumn_id());
                    /** 4개의 관리필드를 고려하여 select 테이블을 +4를 추가해준다 OPERATION, OPERATION_TIME, OPERATION_DATE, PROCESSING_TIME */
                    Object colVal = rs.getObject(colid+4);
                    LogUtil.log("INFO", colid+"==="+piitable.getColumn_name());
                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                            || piitable.getData_type().equalsIgnoreCase("CHAR")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.VARCHAR);
                        else {
                            pstmt.setString(colid, String.valueOf(colVal));
                        }
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else {
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                            }
                        }

                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, (BigDecimal) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), (BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DATE);
                        else {
                            //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                            java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                            java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                            pstmt.setDate(colid, sqlDate);
                        }
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                            else {
                                //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                                java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                                pstmt_del.setDate(pkcols.get(piitable.getColumn_name()), sqlDate);
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.FLOAT);
                        else pstmt.setFloat(colid, (Float) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                            else pstmt_del.setFloat(pkcols.get(piitable.getColumn_name()), (Float) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setLong(colid, (Long) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else pstmt_del.setLong(pkcols.get(piitable.getColumn_name()), (Long) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DOUBLE);
                        else pstmt.setDouble(colid, (Double) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                            else
                                pstmt_del.setDouble(pkcols.get(piitable.getColumn_name()), (Double) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BOOLEAN);
                        else pstmt.setBoolean(colid, (Boolean) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                            else
                                pstmt_del.setBoolean(pkcols.get(piitable.getColumn_name()), (Boolean) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, (BigDecimal) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), (BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.CLOB);
                        else pstmt.setClob(colid, (Clob) colVal);
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                            else pstmt_del.setClob(pkcols.get(piitable.getColumn_name()), (Clob) colVal);
                        }
                    }

                    //else if (piitable.getData_type().equalsIgnoreCase("ROWID")) 		{if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.ROWID); 	else pstmt.setRowid(		colid 	, rs.getRowid(colid));}
                    else {
                        LogUtil.log("INFO", "warn "+"EXE_SYNC defined argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                            pstmt.setNull(colid, Types.VARCHAR);
                        else
                            pstmt.setString(colid, String.valueOf(colVal));
                        if (pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                        }
                    }
                }

                switch (operation) {
                    case "I": // Insert operation
                        LogUtil.log("INFO", "warn "+"#### exeSYNC Insert operation " + totalCount);
                        pstmt.executeUpdate();
                        break;
                    case "U": // Update operation
                        LogUtil.log("INFO", "warn "+"#### exeSYNC Update operation " + totalCount);
                        pstmt_del.executeUpdate();
                        pstmt.executeUpdate();
                        break;
                    case "D": // Delete operation
                        LogUtil.log("INFO", "warn "+"#### exeSYNC Delete operation " + totalCount);
                        pstmt_del.executeUpdate();
                        break;
                }

                totalCount++;
                if (totalCount % batchSize == 0) {
                    JdbcUtil.commit(connSelect);
                    //JdbcUtil.commit(connInsert);
                    //LogUtil.log("INFO", "##if (totalCount % batchSize )## exeSYNC " + table_name + " "  + "   totalCount: " + totalCount);
                }
            }

            JdbcUtil.commit(connInsert);
            //JdbcUtil.commit(connSelect);
            //long endTime = System.currentTimeMillis(); // 종료 시간 기록
            LogUtil.log("INFO", "#### exeSYNC completed : " +  piiordersteptable.getTable_name() + " " + "   totalCount: " + totalCount);

        } catch (Exception e) {
            JdbcUtil.rollback(connInsert);
            JdbcUtil.rollback(connSelect);
            e.printStackTrace();
            logger.warn("warn "+"Exception - exeSYNC =" + piiordersteptable.toString());
            throw e;
        }
        return totalCount;
    }
    public long exeScramble(Connection connSelect, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, Hashtable<String, MetaTableVO> scrambleCols, Hashtable<String, MetaTableVO> masterkeyCols, Hashtable<String, LkPiiScrTypeVO> lkPiiScrTypeCols, String sqlldr_path, Map<String, String> dataMap, int commit_loop_cnt, String site) throws Exception {
        String dbtype_source = sourceDBvo.getDbtype();
        String dbtype_target = targetDBvo.getDbtype();
        String db_source = sourceDBvo.getDb();
        String db_target = targetDBvo.getDb();
        boolean samedb = db_source.equals(db_target);
        boolean isTestDataAutoGen = piiordersteptable.getJobid().startsWith("TESTDATA_AUTO_GEN");

        AES256Util finalAes = new AES256Util();
        LogUtil.log("INFO", ": exeScramble: start" + piiordersteptable.toString());
        /** FK 비활성화 ==> ㅑINDEX 작업에 함께 처리함*/
        boolean isFkDisable = false;
        /*if ("Y".equalsIgnoreCase(piiordersteptable.getPagitype())) {
            isFkDisable = true;
        }*/
        /** INDEX FK 비활성화 & 활성화 */
        boolean isIndexDisable = false;
        boolean isIndexEnable = false;
        if ("Y".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^exeScramble^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = true;
            isIndexEnable = true;
        } else if ("N".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^exeScramble^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = false;
            isIndexEnable = false;
        } else if ("YN".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^IexeScramble^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = true;
            isIndexEnable = false;
        }
        /** 데이터 처리 방법 */
        String data_handling_method = piiordersteptable.getPreceding();
        /** 변환 작업 방식 */
        String processing_method = piiordersteptable.getSuccedding();
        /** 변환 작업 병렬수 */
        int numScrambleThreads = StrUtil.parseInt(piiordersteptable.getPipeline());
        //int maxQueueSize = numScrambleThreads;
        /** 분산 개수 */
        int numDistributed = numScrambleThreads * 3;
        if(numScrambleThreads >= 15){
            numDistributed = numScrambleThreads * 40;
        } else if(numScrambleThreads >= 10){
            numDistributed = numScrambleThreads * 30;
        } else if(numScrambleThreads >= 5){
            numDistributed = numScrambleThreads * 25;
        } else if(numScrambleThreads >  1){
            numDistributed = numScrambleThreads * 20;
        }
        /** 변환 작업 병렬수 */
        int batchSize = StrUtil.parseInt(piiordersteptable.getCommitcnt());
        int commitcnt = batchSize;
        boolean delforupdate = false;
        /* TMP_TABLE: Distributed Parallel Processing */
        if ("TMP_TABLE".equals(processing_method) && "REPLACEINSERT".equals(data_handling_method)) {
            delforupdate = true;
        }
        boolean truncFlag = false;
        /* TMP_TABLE: Distributed Parallel Processing */
        if ("TMP_TABLE".equals(processing_method) && "TRUNCSERT".equals(data_handling_method)) {
            truncFlag = true;
        }
        StringBuilder sqlSelect = new StringBuilder("SELECT ");
        StringBuilder sqlInsert = new StringBuilder();
        StringBuilder sqlDelete = new StringBuilder();
        StringBuilder columnlist = new StringBuilder();
        // Hashtable 생성
        Hashtable<String, Integer> sourceCols = new Hashtable<>();
        // List<MetaTableVO>의 데이터를 Hashtable에 넣기
        for (PiiTableVO tableVO : piitablecols_source) {
            sourceCols.put(tableVO.getColumn_name(), StrUtil.parseInt(tableVO.getColumn_id()));
        }

        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();
        String table_name_patition = SqlUtil.makeTmpTableName(piiordersteptable.getTable_name(), piiordersteptable.getOrderid());
        /**
         * 스크램블은...원천과 타겟의 owner, tablename 이 동일한 상태에서 진행한다.
         * */
        String owner_mig_target = owner;
        String table_name_mig_target = table_name;

        int pkcolindex = 1;
        HashMap<String, Integer> pkcols = new HashMap<String, Integer>();
        String hintSelectSTR = "";
        if(isTestDataAutoGen) {
            hintSelectSTR = " LEADING(B A) INDEX(B IX_TBL_PIIKEYMAP_PII01) " +
                    Objects.toString(piiordersteptable.getHintselect(), "").replaceAll("[\\*/]", "");

        }
        sqlDelete.append("delete " + "" + " from " + owner + "." + table_name + " where ");
        sqlInsert.append("insert /*+ APPEND NOLOGGING */ into " + owner + "." + table_name + " (#COLUNMLIST)" + " values (");
        logger.info("info$ exeScramble: source({}) {}, target({}) {}",
                piitablecols_source.size(), piitablecols_source,
                piitablecols_target.size(), piitablecols_target);

        /** source 와 target 의 테이블 칼럼 일치 대상 확인을 위해 20240520 */
        // piitablecols_target의 칼럼 이름들을 Set으로 저장 (빠른 검색을 위해)
        Set<String> targetColumns = new HashSet<>();
        for (PiiTableVO targetCol : piitablecols_target) {
            targetColumns.add(targetCol.getColumn_name());
        }
        Set<String> sourceColumns = new HashSet<>();
        for (PiiTableVO sourceCol : piitablecols_source) {
            LogUtil.log("DEBUG", " exeILM: sourceCol: "+ sourceCol.getTable_name() +" "+ sourceCol.getColumn_name() +" "+ StrUtil.parseInt(sourceCol.getColumn_id()));
            sourceColumns.add(sourceCol.getColumn_name());
        }
        String defaultValue;
        LogUtil.log("DEBUG", "exeScramble: targetColumns: " + targetColumns.size() +" "+ targetColumns.toString());
        for (int i = 0; i < piitablecols_target.size(); i++) {
            PiiTableVO piitable = piitablecols_target.get(i);
            String columnType = piitable.getData_type();
            String columnName = piitable.getColumn_name();
            MetaTableVO metaTableVO = scrambleCols.get(columnName);
            LogUtil.log("DEBUG", columnName );

            if (i > 0) {
                sqlInsert.append(", ");
                columnlist.append(", ");
            }
            columnlist.append(columnName);

            /** target에 있고 SOURCE에 없는 경우 20251026 */
            if (columnName != null && !sourceColumns.contains(columnName)) {
                defaultValue = getDefaultValue(targetDBvo.getDbtype(), columnType);
                sqlInsert.append(defaultValue);
                //logger.warn(" 111 " + columnName);
            }
            else {
                if (i > 0) {
                    sqlSelect.append(", ");
                }
                /** 암호화 칼럼 select insert 로직 */
                if (scrambleCols.containsKey(piitable.getColumn_name())
                        && !StrUtil.checkString(metaTableVO.getEncript_flag())
                        && "Y".equalsIgnoreCase(metaTableVO.getEncript_flag())) {
                    LkPiiScrTypeVO lkPiiScrTypeVO = lkPiiScrTypeCols.get(metaTableVO.getPiitype());
                    /** DB타입의 암호화 칼럼 처리 로직 업데이트 ===> NULL 공백, 평문 처리*/
                    if ("DB".equalsIgnoreCase(lkPiiScrTypeVO.getEncdecfunctype())) {
                        String encFuc = lkPiiScrTypeVO.getEncfunc().replaceAll("(?i)#COLNAME", "SUBSTR(?, 6)");
                        String decFuc = lkPiiScrTypeVO.getDecfunc().replaceAll("(?i)#COLNAME", columnName);

                        String decStr = "CASE " +
                                "WHEN " + columnName + " IS NULL " +
                                "OR COALESCE(TRIM(" + columnName + "), '1') = '1' " +
                                "OR LENGTH(" + columnName + ") < 15 " +
                                "THEN " + columnName + " " +
                                "ELSE CONCAT('#DEC#', " + decFuc + ")" +
                                "END AS " + columnName;

                        /* 바인딩이 5개 추가된다. 기존 하나는 기존대로 아래서 처리 된다. 20250302*/
                        String encStr = "CASE " +
                                "WHEN ? IS NULL OR COALESCE(TRIM(?), '1') = '1' THEN ? " +
                                "WHEN SUBSTR(?, 1, 5) = '#DEC#' THEN " + encFuc + " " +
                                "ELSE ? " +
                                "END";

                        sqlSelect.append(decStr);
                        sqlInsert.append(encStr);
                        //logger.warn(" 222 " + columnName);
                    } else if ("JAVA API".equalsIgnoreCase(lkPiiScrTypeVO.getEncdecfunctype())) {
                        /** "JAVA API" 처리는 데이터 읽어와서 해야함...sql 레벨에서 처리 없음 */
                        sqlSelect.append(columnName);
                        sqlInsert.append("?");
                        //logger.warn(" 333 " + columnName);
                    }
                } else {
                    sqlSelect.append(columnName);
                    sqlInsert.append("?");
                    //logger.warn(" 444 " + columnName);
                }

                if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
                    pkcols.put(piitable.getColumn_name(), pkcolindex++);
                    if (i == 0) {
                        sqlDelete.append(piitable.getColumn_name() + "=" + "?" + "");
                    } else {
                        sqlDelete.append(" and " + piitable.getColumn_name() + "=" + "?" + "");
                    }
                }
            }
        }
        sqlInsert.append(")");
        String fromWhereStr = null;

        /** Scramble 도 Wizard로 where col, key 선택하여 wherestr 만들면.....select 쿼리에 적용함  SELECT 해서 _PT에 INSERT 할때의 SELECT 조건임      20240225*/
        if (StrUtil.checkString(piiordersteptable.getWhere_col()) && StrUtil.checkString(piiordersteptable.getWhere_key_name())) {
            fromWhereStr = owner + "." + table_name + " A where " + piiordersteptable.getWherestr();
        } else {
            fromWhereStr = owner + "." + table_name + " A, COTDL.TBL_PIIKEYMAP B where " + piiordersteptable.getWherestr();
        }
        /** _PT 테이블에서 전체 조회 하기 때문에 이렇게 세팅함.*/
        sqlSelect.append(" from " + owner + "." + table_name + " where 1=1");
        //sqlSelect.append(piiordersteptable.getWherestr());
        //LogUtil.log("INFO", " sqlSelect " + sqlSelect.toString());

        String insertTargetSql = sqlInsert.toString();
        /** select 칼럼 기준으로 insert  칼럼 세팅  20240430*/
        insertTargetSql = insertTargetSql.replaceAll("(?i)#COLUNMLIST", columnlist.toString());
        LogUtil.log("INFO", ": sqlSelect: " + sqlSelect.toString());
        LogUtil.log("INFO", ": sqlInsert: " + sqlInsert.toString());
        logger.info(String.valueOf(piiordersteptable));
        //logger.info(String.valueOf(piitablecols));

        String firstKey = piiordersteptable.getPk_col();
        String firstKeyType = "DEFAULT";

        if(!StrUtil.checkString(firstKey))
            for (int i = 0; i < piitablecols_source.size(); i++) {
                PiiTableVO piitable = piitablecols_source.get(i);
                String columnType = piitable.getData_type();
                String columnName = piitable.getColumn_name();
                if (columnName.equalsIgnoreCase(firstKey)) {
                    firstKeyType = columnType;
                    break;
                }
            }
        /** 분산기준키가 세팅되지 않았고 PK 인덱스가 없을 경우 첫번째 칼럼을 분산 기준 키로 세팅*/
        if(StrUtil.checkString(firstKey)){
            for (int i = 0; i < piitablecols_source.size(); i++) {
                PiiTableVO piitable = piitablecols_source.get(i);
                String columnType = piitable.getData_type();
                String columnName = piitable.getColumn_name();
                if ("1".equalsIgnoreCase(piitable.getColumn_id())) {
                    firstKeyType = columnType;
                    firstKey = columnName;
                    break;
                }
            }
        }
        long sum_deleteTmpCnt = 0;
        long sum_insertTmpCnt = 0;
        long sum_scrambleCnt = 0;
        long totalCount = 0; //전체 카운트 select 해서 처리하는 전체 count
        long intTotalCount = 0; //insert 한 전체 count

        InnerStepVO innerStepVO = null;
        boolean goFlag = false;

        /** ###################################################################################################################
         * 	exeScramble -- Delete dup data
         * ################################################################################################################### */
        if ("DELDUPINSERT".equals(data_handling_method)) {
            logger.warn("info$ " + "## : 5 Delete dup data : " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 5);
            if (innerStepVO == null) { //LogUtil.log("INFO", "## : 10 1 drop & crate tmp: if (innerStepVO == null)" + owner + "." + table_name);
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(5);
//                innerStepVO.setInner_step_name("drop & crate & insert part_tmp & truncate target");
                innerStepVO.setInner_step_name("Delete dup data");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
                sum_deleteTmpCnt = StrUtil.parseLong(innerStepVO.getExecnt());
            } else {
                LogUtil.log("INFO", "## : 5 Delete dup data :  goFlag = true;" + owner + "." + table_name);
                goFlag = true;
            }

            if (goFlag) {
                try {
                    //LogUtil.log("INFO", "exeScramble ====== Delete dup data : ");
                    sum_deleteTmpCnt = SqlUtil.deleteDupData(connInsert, dbtype_target, owner_mig_target,
                            table_name_mig_target, piiordersteptable.getWherestr(), numScrambleThreads, isTestDataAutoGen);
                    LogUtil.log("INFO", "exeScramble ====== Delete dup data completed cnt: " + sum_deleteTmpCnt);
                } catch (Exception e) {
                    innerStepVO.setMessage(e.toString());
                    innerStepVO.setStatus("Ended not OK");
                    innerStepSV.modifyEnd(innerStepVO);
                    e.printStackTrace();
                    logger.warn("warn " + "Exception - exeScramble = drop & crate tmp : " + piiordersteptable.toString());
                    throw e;
                }
                innerStepVO.setExecnt(sum_deleteTmpCnt + "");
                innerStepVO.setMessage(null);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);

            }
        }
        /** ###################################################################################################################
         * 	exeScramble -- drop & crate partition tmp table & insert into partition tmp table & truncate target table
         * ################################################################################################################### */
        /* TMP_TABLE: Distributed Parallel Processing */
        if ("TMP_TABLE".equals(processing_method)) {
            LogUtil.log("INFO", "## : 10 drop & crate tmp: " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 10);
            if (innerStepVO == null) {
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(10);
//                innerStepVO.setInner_step_name("drop & crate & insert part_tmp & truncate target");
                innerStepVO.setInner_step_name("Insert Tmp Table");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
                sum_insertTmpCnt = StrUtil.parseLong(innerStepVO.getExecnt());
            } else {
                goFlag = true;
            }

            if (goFlag) {
                try {
                    String results = SqlUtil.createCotdlPartTmpTable(connSelect, dbtype_source, owner, table_name, piiordersteptable.getOrderid(), firstKey, firstKeyType, numDistributed);
                    LogUtil.log("INFO", "exeScramble ====== before insertPartTmpFromTargetAndTrunc : " + results);
                    sum_insertTmpCnt = SqlUtil.insertPartTmpFromTargetAndTrunc(connSelect, connInsert
                            , dbtype_source, owner, table_name
                            ,  dbtype_target, owner_mig_target, table_name_mig_target
                            , piiordersteptable.getOrderid(), piiordersteptable.getWherestr(), truncFlag, numScrambleThreads, fromWhereStr, hintSelectSTR, piiordersteptable.getUval1(), piiordersteptable.getUval2());
                    LogUtil.log("INFO", "exeScramble ====== after insertPartTmpFromTargetAndTrunc : " + results);
                } catch (Exception e) {
                    innerStepVO.setMessage(e.toString());
                    innerStepVO.setStatus("Ended not OK");
                    innerStepSV.modifyEnd(innerStepVO);
                    e.printStackTrace();
                    logger.warn("warn "+"Exception - drop & crate partition tmp table & insert into partition tmp table & truncate target table : " +  owner +" : "+ table_name +" : "+ piiordersteptable.getOrderid());
                    throw e;
                }
                innerStepVO.setExecnt(sum_insertTmpCnt + "");
                innerStepVO.setMessage(null);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);

            }
        }
        /** ###################################################################################################################
         * 	exeScramble -- Index disable
         * ################################################################################################################### */
        if (isIndexDisable) {
            LogUtil.log("INFO", "## : 20 Index disable: " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 20);
            if (innerStepVO == null) {
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(20);
                innerStepVO.setInner_step_name("Index Disable");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
            } else {
                goFlag = true;
            }
            if (goFlag) {
                String indexes = null;
                try {     /* exeScramble */
                    indexes = disableIndexConsSaveDDL(piiordersteptable, dbtype_target, connInsert, db_target);
                } catch (Exception e) {
                    innerStepVO.setMessage(e.toString());
                    innerStepVO.setStatus("Ended not OK");
                    innerStepSV.modifyEnd(innerStepVO);
                    e.printStackTrace();
                    logger.warn("warn "+"Exception - Index disable : " + piiordersteptable.toString());
                    throw e;
                }
                innerStepVO.setMessage(indexes);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);
            }
        }
        /** ###################################################################################################################
         * 	exeScramble -- Scramble
         * ################################################################################################################### */
        if (true) {
            LogUtil.log("INFO","Start 30 Testdata data processing: " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 30);
            if (innerStepVO == null) {
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(30);
                innerStepVO.setInner_step_name("Scramble");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
                totalCount = StrUtil.parseLong(innerStepVO.getExecnt());
            } else {
                goFlag = true;
                totalCount = 0;
            }
            if (goFlag) {
                long firstTime = System.currentTimeMillis(); // 각 행의 시작 시각 기록
                LogUtil.log("INFO", "Begin " + table_name + " " + " Start Time: " + new Timestamp(firstTime) + " numScrambleThreads: " + numScrambleThreads);
                /**
                 * TMP_TABLE: Distributed Parallel Processing 테이블 방식 처리....병렬처리방식임  default임
                 * */
                if ("TMP_TABLE".equals(processing_method)) {
                    /** 수행 시점에 이미 처리한 파티션은 목록에 메세지에 있다. 이 파티션들은 제외 하고 처리해야 함.*/
                    // 연결 풀 생성
                    HikariDataSource dataSourceInsert = null;
                    HikariDataSource dataSourceSelect = null;
                    try {
                        List<InnerStepVO> partitionList = innerStepSV.getListPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                        //finalaes = new AES256Util();
                        if (numScrambleThreads == 1) {
                            List<String> partitionNames = SqlUtil.getPartitionNames(connSelect, dbtype_source, owner, table_name_patition);
                            LogUtil.log("INFO", "#### Scramble partitionNames.size() ;" + partitionNames.size() + "   piiordersteptable: " + piiordersteptable.toString());
                            int currentIndex = 0; // 고유한 값을 증가시킴
                            for (String partition : partitionNames) {
                                currentIndex++;
                                boolean partitionExists = partitionList.stream()
                                        .anyMatch(innerStepVOpart -> innerStepVOpart.getResult().contains(partition));

                                if (partitionExists) {
                                    continue;
                                }
                                try {
                                    transformAndInsert(piiordersteptable, partition, sqlSelect.toString(), insertTargetSql, sqlDelete.toString(), targetColumns
                                            , piitablecols_source, piitablecols_target, pkcols, scrambleCols, masterkeyCols, lkPiiScrTypeCols, finalAes, batchSize, currentIndex, innerStepVO
                                            , sourceDBvo, targetDBvo, samedb, processing_method, data_handling_method, dataMap, commit_loop_cnt, site);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    throw e;
                                }

                            }

                        } else if (numScrambleThreads > 1) {
                            List<String> partitionNames = SqlUtil.getPartitionNames(connSelect, dbtype_source, owner, table_name_patition);
                            ExecutorService executor = Executors.newFixedThreadPool(numScrambleThreads);
                            LogUtil.log("INFO", "#### Scramble partitionNames.size()   " + partitionNames.size() + "   piiordersteptable: " + piiordersteptable.toString());
                            // 연결 풀 생성
                            dataSourceInsert = ConnectionProvider.getDataSource(numScrambleThreads, targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), finalAes.decrypt(targetDBvo.getPwd()));
                            if(!samedb) {
                                dataSourceSelect = ConnectionProvider.getDataSource(numScrambleThreads, sourceDBvo.getDbtype(), sourceDBvo.getHostname(), sourceDBvo.getPort(), sourceDBvo.getId_type(), sourceDBvo.getId(), sourceDBvo.getDb(), sourceDBvo.getDbuser(), finalAes.decrypt(sourceDBvo.getPwd()));
                            } else {
                                dataSourceSelect = dataSourceInsert;
                            }
                            int currentIndex = 0; // 고유한 값을 증가시킴
                            List<Future<?>> futures = new ArrayList<>();
                            AtomicBoolean partitionError = new AtomicBoolean(false);
                            AtomicBoolean killRequested = new AtomicBoolean(false);
                            AtomicReference<String> firstErrorMsg = new AtomicReference<>(null);
                            java.util.concurrent.atomic.AtomicLong memoryScrambleCnt = new java.util.concurrent.atomic.AtomicLong(0);
                            for (String partition : partitionNames) {
                                // 에러 발생 시 새 파티션 제출 중단
                                if (partitionError.get()) {
                                    LogUtil.log("WARN", "Skipping partition " + partition
                                            + " due to previous partition error: table=" + table_name);
                                    break;
                                }
                                // Kill 신호 확인 - 새 파티션 제출 전 체크
                                if (killRequested.get()) {
                                    LogUtil.log("WARN", "Skipping partition " + partition
                                            + " due to kill request: table=" + table_name);
                                    break;
                                }
                                currentIndex++;
                                boolean partitionExists = partitionList.stream()
                                        .anyMatch(innerStepVOpart -> innerStepVOpart.getResult().contains(partition));

                                if (partitionExists) {
                                    // If the partition exists in the result, continue to the next iteration
                                    continue;
                                }
                                if (currentIndex > 1 && currentIndex <= numScrambleThreads) {
                                    Thread.sleep(200);
                                }
                                InnerStepVO finalInnerStepVO = innerStepVO;
                                int finalCurrentIndex = currentIndex;
                                String finalInsertTargetSql = insertTargetSql;
                                Future<?> future = executor.submit(() -> {
                                    try {
                                        long partitionCnt = transformAndInsert(piiordersteptable, partition, sqlSelect.toString(), finalInsertTargetSql, sqlDelete.toString(), targetColumns
                                                , piitablecols_source, piitablecols_target, pkcols, scrambleCols, masterkeyCols, lkPiiScrTypeCols, finalAes, batchSize, finalCurrentIndex, finalInnerStepVO
                                                , sourceDBvo, targetDBvo, samedb, processing_method, data_handling_method, dataMap, commit_loop_cnt, site, killRequested);
                                        memoryScrambleCnt.addAndGet(partitionCnt);
                                    } catch (Exception e) {
                                        partitionError.set(true);
                                        firstErrorMsg.compareAndSet(null, partition + ": " + e.getMessage());
                                        logger.error("Scramble partition failed: partition={}, table={}, error={}",
                                                partition, piiordersteptable.getTable_name(), e.getMessage(), e);
                                    }
                                });
                                futures.add(future);
                            }
                            // 작업 완료까지 대기 (이미 제출된 파티션은 완료까지 대기 - 커밋 중간에 끊기면 안됨)
                            executor.shutdown();
                            for (Future<?> future : futures) {
                                future.get();
                            }
                            // 파티션 에러 확인 → "Ended not OK" + 예외 전파
                            // Future.get() 완료 후이므로 모든 스레드 완료 보장됨
                            if (partitionError.get()) {
                                sum_scrambleCnt = memoryScrambleCnt.get();
                                long dbCnt = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                                if (dbCnt != sum_scrambleCnt) {
                                    logger.warn("Scramble count mismatch on error: memory={}, db={}. Using memory count.", sum_scrambleCnt, dbCnt);
                                }
                                innerStepVO.setExecnt("" + sum_scrambleCnt);
                                String errorDetail = "Partition error (success=" + sum_scrambleCnt + "): " + firstErrorMsg.get();
                                if (errorDetail.length() > 2000) {
                                    errorDetail = errorDetail.substring(0, 2000);
                                }
                                innerStepVO.setMessage(errorDetail);
                                innerStepVO.setStatus("Ended not OK");
                                innerStepSV.modifyEnd(innerStepVO);
                                throw new Exception("Scramble partition failed. successCnt=" + sum_scrambleCnt + ". " + firstErrorMsg.get());
                            }
                        }
                        sum_scrambleCnt = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                        innerStepVO.setExecnt("" + sum_scrambleCnt);
                        LogUtil.log("INFO", "#### Scramble completed $$$" + table_name_patition + "   sum_scrambleCnt: " + sum_scrambleCnt);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - Scramble Serial: " + piiordersteptable.toString());
                        throw e;
                    } finally {
                        // DataSource 정리 - 물리 커넥션 확실히 해제
                        if (dataSourceSelect != null && dataSourceSelect != dataSourceInsert) {
                            try { dataSourceSelect.close(); } catch (Exception ignored) {}
                        }
                        if (dataSourceInsert != null) {
                            try { dataSourceInsert.close(); } catch (Exception ignored) {}
                        }
                    }
                }

                innerStepVO.setMessage("TargetCnt:" + sum_insertTmpCnt + " = " + "scrambleCnt:" + sum_scrambleCnt);
                //innerStepVO.setExecnt("" + totalCount);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);
            }
        }

        boolean goafterscramble = false;
        InnerStepVO innerStepVOscramble = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                , 30);
        if (innerStepVOscramble == null) {
            goafterscramble = false;
        } else if ("Ended OK".equals(innerStepVOscramble.getStatus())) {
            goafterscramble = true;
        } else {
            goafterscramble = false;
        }

        if (goafterscramble) {

            /** ###################################################################################################################
             * 	exeScramble -- Drop tmp
             * ################################################################################################################### */
            if ("TMP_TABLE".equals(processing_method)) {/* TMP_TABLE: Distributed Parallel Processing */
                LogUtil.log("INFO", " 40 Drop tmp: " + "COTDL" + "." + table_name_patition);
                innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , 40);
                if (innerStepVO == null) {
                    innerStepVO = new InnerStepVO();
                    innerStepVO.setOrderid(piiordersteptable.getOrderid());
                    innerStepVO.setStepid(piiordersteptable.getStepid());
                    innerStepVO.setSeq1(piiordersteptable.getSeq1());
                    innerStepVO.setSeq2(piiordersteptable.getSeq2());
                    innerStepVO.setSeq3(piiordersteptable.getSeq3());
                    innerStepVO.setInner_step_seq(40);
                    innerStepVO.setInner_step_name("Drop tmp");
                    innerStepVO.setStatus("RUNNING");
                    innerStepSV.register(innerStepVO);
                    goFlag = true;
                } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                    goFlag = false;
                } else {
                    goFlag = true;
                }
                if (goFlag) {
                    try {
                        SqlUtil.dropTable(connSelect, dbtype_source, "COTDL", table_name_patition);
                        LogUtil.log("INFO", "Completed ======> drop tmp : COTDL." + table_name_patition);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - Drop tmp : " + piiordersteptable.toString());
                        throw e;
                    }
                    innerStepVO.setMessage(table_name_patition + " is droped");
                    innerStepVO.setStatus("Ended OK");
                    innerStepSV.modifyEnd(innerStepVO);
                }
            }
            /** ###################################################################################################################
             * 	exeScramble -- Index Rebuild
             * ################################################################################################################### */
            if (isIndexEnable) {
                innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , 50);
                if (innerStepVO == null) {
                    innerStepVO = new InnerStepVO();
                    innerStepVO.setOrderid(piiordersteptable.getOrderid());
                    innerStepVO.setStepid(piiordersteptable.getStepid());
                    innerStepVO.setSeq1(piiordersteptable.getSeq1());
                    innerStepVO.setSeq2(piiordersteptable.getSeq2());
                    innerStepVO.setSeq3(piiordersteptable.getSeq3());
                    innerStepVO.setInner_step_seq(50);
                    innerStepVO.setInner_step_name("Index Rebuild");
                    innerStepVO.setStatus("RUNNING");
                    innerStepSV.register(innerStepVO);
                    goFlag = true;
                } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                    goFlag = false;
                } else {
                    goFlag = true;
                }
                if (goFlag) {
                    String indexes = "";
                    try {
                        /** Index, constraint enable instead of Recreating  20250220*/
                        LogUtil.log("INFO", "SCRAMBLE ###### - Index Rebuild : " + piiordersteptable.toString());
                        indexes = exeRecreateIndexCons(piiordersteptable, targetDBvo, finalAes, numScrambleThreads);
                        //indexes = exeReBuildIndexCons(piiordersteptable, targetDBvo, finalAes, numScrambleThreads);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - Index Rebuild : " + piiordersteptable.toString());
                        throw e;
                    }
                    innerStepVO.setMessage(indexes);
                    innerStepVO.setStatus("Ended OK");
                    innerStepSV.modifyEnd(innerStepVO);
                }
            }

        }
        /**--------------------------------------------------------------------------------------------------------------------*/
        return sum_scrambleCnt;
    }
    /** ILM 과 MIGRATE 두가지를 처리한다.*/
    public long exeILM(Connection connSelect, Connection connInsert, PiiOrderStepTableVO piiordersteptable, List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, boolean sourceDelflag, String stopHourFromTo, int commit_loop_cnt) throws Exception {
        String dbtype_source = sourceDBvo.getDbtype();
        String dbtype_target = targetDBvo.getDbtype();
        String db_source = sourceDBvo.getDb();
        String db_target = targetDBvo.getDb();
        boolean samedb = db_source.equals(db_target);

        /** 특정 시간대 작업 피하기 */
        if (!StrUtil.checkString(stopHourFromTo)) {
            String[] hours = stopHourFromTo.split("-");
            int stopHour = StrUtil.parseInt(hours[0].trim());
            int resumeHour = StrUtil.parseInt(hours[1].trim());
            // Get the current time in Seoul time zone
            Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"));
            int hour = calendar.get(Calendar.HOUR_OF_DAY);
            if ((stopHour <= resumeHour && hour >= stopHour && hour < resumeHour) || (stopHour > resumeHour && (hour >= stopHour || hour < resumeHour))) {

                // Adjust resumeHour for wraparound
                resumeHour = (resumeHour + 24) % 24;

                // Calculate hours to wait
                int hoursToWait;
                if (hour >= stopHour) {
                    hoursToWait = resumeHour - hour;
                } else {
                    hoursToWait = stopHour - hour;
                }

                long waitTimeMillis = hoursToWait * 60 * 60 * 1000;
                LogUtil.log("INFO", "Waiting until after " + resumeHour + ". Current time: {}, Hours to wait: {}, waitTimeMillis: {}", calendar.getTime(), hoursToWait, waitTimeMillis);
                try {
                    Thread.sleep(waitTimeMillis);
                } catch (InterruptedException e) {
                    logger.error("Error during wait: {}", e.getMessage());
                }
                LogUtil.log("INFO", "Wait completed. Resuming execution.");
            }
        }

        /** 작업 시작 */
        AES256Util finalAes = new AES256Util();
        logger.warn("INFO "+": ILM , MIGRATION: start" + piiordersteptable.toString());
        /** INDEX FK 비활성화 & 활성화 */
        boolean isIndexDisable = false;
        boolean isIndexEnable = false;
        if ("Y".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^ILM MIGRATION^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = true;
            isIndexEnable = true;
        } else if ("N".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^ILM MIGRATION^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = false;
            isIndexEnable = false;
        } else if ("YN".equalsIgnoreCase(piiordersteptable.getPagitypedetail())) {//LogUtil.log("INFO", "^^^^ILM MIGRATION^^^INDEX FK 비활성화^^^^^^^^ true  "+piiordersteptable.getPagitypedetail());
            isIndexDisable = true;
            isIndexEnable = false;
        }
        /** 데이터 처리 방법 */
        String data_handling_method = piiordersteptable.getPreceding();
        /** 변환 작업 방식 */
        String processing_method = piiordersteptable.getSuccedding();
        /** 변환 작업 병렬수 */
        int numScrambleThreads = StrUtil.parseInt(piiordersteptable.getPipeline());
        //int maxQueueSize = numScrambleThreads;

        /** 분산 개수 */
        int numDistributed = numScrambleThreads * 3;
        if(numScrambleThreads >= 15){
            numDistributed = numScrambleThreads * 40;
        } else if(numScrambleThreads >= 10){
            numDistributed = numScrambleThreads * 30;
        } else if(numScrambleThreads >= 5){
            numDistributed = numScrambleThreads * 25;
        } else if(numScrambleThreads >  1){
            numDistributed = numScrambleThreads * 20;
        }
        /** 변환 작업 병렬수 */
        int batchSize = StrUtil.parseInt(piiordersteptable.getCommitcnt());
        int commitcnt = batchSize;

        boolean truncFlag = false;
        /* TMP_TABLE: Distributed Parallel Processing */
        if ("TMP_TABLE".equals(processing_method) && "TRUNCSERT".equals(data_handling_method)) {
            truncFlag = true;
        }

        LogUtil.log("INFO", "exeILM: piitablecols_source.size(): " + piitablecols_source.size());
        // piitablecols_target의 칼럼 이름들을 Set으로 저장 (빠른 검색을 위해)  20250216
        Set<String> targetColumns = new HashSet<>();
        for (PiiTableVO targetCol : piitablecols_target) {
            LogUtil.log("DEBUG", " exeILM: targetCol: "+ targetCol.getTable_name() +" "+ targetCol.getColumn_name() +" "+ StrUtil.parseInt(targetCol.getColumn_id()));
            targetColumns.add(targetCol.getColumn_name());
        }
        Set<String> sourceColumns = new HashSet<>();
        for (PiiTableVO sourceCol : piitablecols_source) {
            LogUtil.log("DEBUG", " exeILM: sourceCol: "+ sourceCol.getTable_name() +" "+ sourceCol.getColumn_name() +" "+ StrUtil.parseInt(sourceCol.getColumn_id()));
            sourceColumns.add(sourceCol.getColumn_name());
        }

        StringBuilder sqlSelect = new StringBuilder("SELECT ");
        StringBuilder sqlInsert = new StringBuilder();
        StringBuilder sqlDelete = new StringBuilder();

        Map<String, Integer> pkcols = new HashMap<>();

        List<String> insertPlaceholders = new ArrayList<>();
        List<String> insertColumns = new ArrayList<>();
        List<String> selectColumns = new ArrayList<>();
        List<String> deleteConditions = new ArrayList<>();

        String timestampStr = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        LogUtil.log("INFO", " exeILM: timestampStr: " + timestampStr);
        String defaultValue;
        int pkcolindex = 1;
        for (PiiTableVO piitable : piitablecols_target) {
            String columnName = piitable.getColumn_name();
            String columnType = piitable.getData_type(); // 컬럼 타입 가져오기
            int length = StrUtil.parseInt(piitable.getData_length()); // 컬럼 타입 가져오기
            insertColumns.add(columnName);
            if (sourceColumns.contains(columnName)) {// Source에 존재하는 경우
                insertPlaceholders.add("?");
                selectColumns.add(columnName);
            } else {// Source에 없는 경우
                // [우선 순위 1] DW_LDNG_DTTM 특별 처리
                if ("DW_LDNG_DTTM".equalsIgnoreCase(columnName) && "VARCHAR2".equalsIgnoreCase(columnType) && length >= 16) {
                    insertPlaceholders.add("'" + timestampStr + "'"); // VARCHAR2(16) 포맷팅
                }
                else {// [우선 순위 2] 일반 기본값 처리
                    defaultValue = getDefaultValue(targetDBvo.getDbtype(), columnType);
                    insertPlaceholders.add(defaultValue);
                }
            }

            // Primary Key 처리
            if ("Y".equalsIgnoreCase(piitable.getPk_yn())) {
                pkcols.put(columnName, pkcolindex++);
                deleteConditions.add(columnName + " = ?");
            }
        }

        String insertPlaceholdersStr = String.join(", ", insertPlaceholders);
        String insertColumnsStr = String.join(", ", insertColumns);
        String selectColumnsStr = String.join(", ", selectColumns);
        String deleteConditionsStr = "";
        if (!deleteConditions.isEmpty()) {
            deleteConditionsStr = String.join(" and ", deleteConditions);
        }

        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();
        String table_name_patition = SqlUtil.makeTmpTableName(piiordersteptable.getTable_name(), piiordersteptable.getOrderid());

        String owner_mig_target = piiordersteptable.getWhere_key_name();
        String table_name_mig_target  = piiordersteptable.getSqlstr();

        String hintSelectSTR = Objects.toString(piiordersteptable.getHintselect(), "").replaceAll("[\\*/]", "");
        LogUtil.log("INFO", " exeILM: piiordersteptable.getHintselect(): " + piiordersteptable.getHintselect() +"  hintSelectSTR: "+ hintSelectSTR);
        if("EXE_MIGRATE".equalsIgnoreCase(piiordersteptable.getSteptype())) { /* Target은 piiordersteptable에 세팅되어진다.*/
            /** MIGRATE 은 Target을 delete 한다.*/
            sqlDelete.append("delete " + "" + " from " + owner_mig_target + "." + table_name_mig_target + " where ");
            sqlInsert.append("insert /*+ APPEND NOLOGGING */ into " + owner_mig_target + "." + table_name_mig_target + " ("+insertColumnsStr+") "
                    + " values ("+insertPlaceholdersStr+")");
        } else {
            /** ILM 은 Source를 delete 한다. Target은 ILM 아카이브 스키마 */
            String ilmArchiveOwner = archiveNamingService.getArchiveSchemaName(ArchiveNamingService.CONFIG_TYPE_ILM, db_target, owner);
            sqlDelete.append("delete " + "" + " from " + owner + "." + table_name + " where ");
            sqlInsert.append("insert /*+ APPEND NOLOGGING */ into " + ilmArchiveOwner + "." + table_name + " ("+insertColumnsStr+") "
                    + " values ("+insertPlaceholdersStr+")");
        }
        sqlSelect.append(selectColumnsStr);
        sqlSelect.append(" from " + owner + "." + table_name + " where ");
        sqlSelect.append(piiordersteptable.getWherestr());
        sqlDelete.append(deleteConditionsStr);

        String insertTargetSql = sqlInsert.toString();
        LogUtil.log("INFO", " exeILM: sqlSelect: " + sqlSelect.toString());
        LogUtil.log("INFO", " exeILM: sqlInsert: " + sqlInsert.toString());
        LogUtil.log("INFO", " exeILM: sqlDelete: " + sqlDelete.toString());
        //logger.info(String.valueOf(piiordersteptable));
        //logger.info(String.valueOf(piitablecols));

        String firstKey = piiordersteptable.getPk_col();
        String firstKeyType = "DEFAULT";
//        if (!pkcols.isEmpty()) {
//            firstKey = pkcols.keySet().iterator().next(); // 첫 번째 키 얻기
//        }
        if(!StrUtil.checkString(firstKey))
            for (int i = 0; i < piitablecols_source.size(); i++) {
                PiiTableVO piitable = piitablecols_source.get(i);
                String columnType = piitable.getData_type();
                String columnName = piitable.getColumn_name();
                if (columnName.equalsIgnoreCase(firstKey)) {
                    firstKeyType = columnType;
                    break;
                }
            }
        /** 분산기준키가 세팅되지 않았고 PK 인덱스가 없을 경우 첫번째 칼럼을 분산기분키로*/
        if(StrUtil.checkString(firstKey)){
            for (int i = 0; i < piitablecols_source.size(); i++) {
                PiiTableVO piitable = piitablecols_source.get(i);
                String columnType = piitable.getData_type();
                String columnName = piitable.getColumn_name();
                if ("1".equalsIgnoreCase(piitable.getColumn_id())) {
                    firstKeyType = columnType;
                    firstKey = columnName;
                    break;
                }
            }
        }
        long sum_deleteTmpCnt = 0;
        long sum_insertTmpCnt = 0;
        long sum_scrambleCnt = 0;
        long totalCount = 0; //전체 카운트 select 해서 처리하는 전체 count
        long intTotalCount = 0; //insert 한 전체 count

        InnerStepVO innerStepVO = null;
        boolean goFlag = false;
        /** ###################################################################################################################
         * 	ILM MIGRATION -- Delete dup data
         * ################################################################################################################### */
        if ("DELDUPINSERT".equals(data_handling_method)) {
            logger.warn("info$ " + "## : 5 Delete dup data : " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 5);
            if (innerStepVO == null) { //LogUtil.log("INFO", "## : 10 1 drop & crate tmp: if (innerStepVO == null)" + owner + "." + table_name);
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(5);
//                innerStepVO.setInner_step_name("drop & crate & insert part_tmp & truncate target");
                innerStepVO.setInner_step_name("Delete dup data");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
                sum_deleteTmpCnt = StrUtil.parseLong(innerStepVO.getExecnt());
            } else {
                LogUtil.log("INFO", "## : 5 Delete dup data :  goFlag = true;" + owner + "." + table_name);
                goFlag = true;
            }

            if (goFlag) {
                try {
                    //LogUtil.log("INFO", "Migration ILM ====== Delete dup data : ");
                    sum_deleteTmpCnt = SqlUtil.deleteDupData(connInsert, dbtype_target, owner_mig_target,
                            table_name_mig_target, piiordersteptable.getWherestr(), numScrambleThreads, false);
                    LogUtil.log("INFO", "Migration ILM ====== Delete dup data completed cnt: " + sum_deleteTmpCnt);
                } catch (Exception e) {
                    innerStepVO.setMessage(e.toString());
                    innerStepVO.setStatus("Ended not OK");
                    innerStepSV.modifyEnd(innerStepVO);
                    e.printStackTrace();
                    logger.warn("warn " + "Exception - drop & crate tmp : " + piiordersteptable.toString());
                    throw e;
                }
                innerStepVO.setExecnt(sum_deleteTmpCnt + "");
                innerStepVO.setMessage(null);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);

            }
        }
        /** ###################################################################################################################
         * 	ILM MIGRATION -- drop & crate partition tmp table & insert into partition tmp table & truncate target table
         * ################################################################################################################### */
        LogUtil.log("INFO","#### : 10 drop & crate tmp: " + owner + "." + table_name);

        innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                , 10);
        if (innerStepVO == null) { //LogUtil.log("INFO", "## : 10 1 drop & crate tmp: if (innerStepVO == null)" + owner + "." + table_name);
            innerStepVO = new InnerStepVO();
            innerStepVO.setOrderid(piiordersteptable.getOrderid());
            innerStepVO.setStepid(piiordersteptable.getStepid());
            innerStepVO.setSeq1(piiordersteptable.getSeq1());
            innerStepVO.setSeq2(piiordersteptable.getSeq2());
            innerStepVO.setSeq3(piiordersteptable.getSeq3());
            innerStepVO.setInner_step_seq(10);
//                innerStepVO.setInner_step_name("drop & crate & insert part_tmp & truncate target");
            innerStepVO.setInner_step_name("insert part_tmp");
            innerStepVO.setStatus("RUNNING");
            innerStepSV.register(innerStepVO);
            goFlag = true;
        } else if ("Ended OK".equals(innerStepVO.getStatus())) {
            goFlag = false;
            sum_insertTmpCnt = StrUtil.parseLong(innerStepVO.getExecnt());//LogUtil.log("INFO", "## : 40 3 drop & crate tmp: if (innerStepVO == null)" + owner + "." + table_name+ " | " + innerStepVO.getStatus()+ "|" + sum_insertTmpCnt);
        } else {LogUtil.log("INFO", "## : 10 drop & crate tmp:  goFlag = true;" + owner + "." + table_name);
            goFlag = true;
        }

        if (goFlag) {
            try {
                String results = SqlUtil.createCotdlPartTmpTable(connSelect, dbtype_source, owner, table_name, piiordersteptable.getOrderid(), firstKey, firstKeyType, numDistributed);
                LogUtil.log("INFO", "Migration ILM ====== before insertPartTmpFromTargetAndTrunc : " + results+"    hintSelectSTR:"+hintSelectSTR);
                sum_insertTmpCnt = SqlUtil.insertPartTmpFromTargetAndTrunc(connSelect, connInsert
                        , dbtype_source, owner, table_name
                        , dbtype_target, owner_mig_target, table_name_mig_target
                        , piiordersteptable.getOrderid(), piiordersteptable.getWherestr(), truncFlag, numScrambleThreads, null, hintSelectSTR, piiordersteptable.getUval1(), piiordersteptable.getUval2());
                LogUtil.log("INFO", "Migration ILM ====== before insertPartTmpFromTargetAndTrunc : " + results);
                //LogUtil.log("INFO", "after insertPartTmpFromTargetAndTrunc : sum_insertTmpCnt: " + sum_insertTmpCnt);
            } catch (Exception e) {
                innerStepVO.setMessage(e.toString());
                innerStepVO.setStatus("Ended not OK");
                innerStepSV.modifyEnd(innerStepVO);
                e.printStackTrace();
                logger.warn("warn "+"Exception - drop & crate tmp : " + piiordersteptable.toString());
                throw e;
            }
            innerStepVO.setExecnt(sum_insertTmpCnt + "");
            innerStepVO.setMessage(null);
            innerStepVO.setStatus("Ended OK");
            innerStepSV.modifyEnd(innerStepVO);

        }

        /** ###################################################################################################################
         * 	Index disable  --  ILM MIGRATION
         * ################################################################################################################### */
        if (isIndexDisable) {
            LogUtil.log("WARN","#### : 20 ILM MIGRATION Index disable start: " + owner + "." + table_name);
            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 20);
            if (innerStepVO == null) {
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(20);
                innerStepVO.setInner_step_name("Index Disable");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                goFlag = false;
            } else {
                goFlag = true;
            }
            if (goFlag) {
                String indexes = null;
                try {         /* exeILM */
                    indexes = disableIndexConsSaveDDL(piiordersteptable, dbtype_target, connInsert, db_target);
                } catch (Exception e) {
                    innerStepVO.setMessage(e.toString());
                    innerStepVO.setStatus("Ended not OK");
                    innerStepSV.modifyEnd(innerStepVO);
                    e.printStackTrace();
                    logger.warn("warn "+"Exception - ILM MIGRATION Index disable : " + piiordersteptable.toString());
                    throw e;
                }
                innerStepVO.setMessage(indexes);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);
            }
        }
        /** ###################################################################################################################
         * 	exeILM  -  MIGRATE & ILM data processing
         * ################################################################################################################### */
        if (true) {

            innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                    , 30);
            //LogUtil.log("WARN","#### : 30 MIGRATE & ILM data processing: " + owner + "." + table_name);
            if (innerStepVO == null) {LogUtil.log("INFO", "## : 30 2 MIGRATE & ILM data processing:" + owner + "." + table_name);
                innerStepVO = new InnerStepVO();
                innerStepVO.setOrderid(piiordersteptable.getOrderid());
                innerStepVO.setStepid(piiordersteptable.getStepid());
                innerStepVO.setSeq1(piiordersteptable.getSeq1());
                innerStepVO.setSeq2(piiordersteptable.getSeq2());
                innerStepVO.setSeq3(piiordersteptable.getSeq3());
                innerStepVO.setInner_step_seq(30);
                innerStepVO.setInner_step_name("Migrate");
                innerStepVO.setStatus("RUNNING");
                innerStepSV.register(innerStepVO);
                goFlag = true;//LogUtil.log("INFO", "## : 30 2 drop & crate tmp: goFlag = false;" +innerStepVO.getStatus());
            } else if ("Ended OK".equals(innerStepVO.getStatus())) {LogUtil.log("INFO", "## : 30 3 MIGRATE & ILM data processing: goFlag = false;" +innerStepVO.getStatus());
                goFlag = false;
                totalCount = StrUtil.parseLong(innerStepVO.getExecnt());
            } else {LogUtil.log("INFO", "## : 30 4 MIGRATE & ILM data processing: goFlag = false;" +innerStepVO.getStatus());
                goFlag = true;
                totalCount = 0;
            }
            //LogUtil.log("WARN", "## : 30 5 MIGRATE & ILM data processing: goFlag = false;" +innerStepVO.getStatus());
            if (goFlag) {
                long firstTime = System.currentTimeMillis(); // 각 행의 시작 시각 기록
                LogUtil.log("INFO", "Begin " + table_name + " " + " Start Time: " + new Timestamp(firstTime) + " numScrambleThreads: " + numScrambleThreads);
                /**
                 * TMP_TABLE: Distributed Parallel Processing
                 * */
                if ("TMP_TABLE".equals(processing_method)) {
                    /** 수행 시점에 이미 처리한 파티션은 목록에 메세지에 있다. 이 파티션들은 제외 하고 처리해야 함.*/
                    /*// 연결 풀 생성
                    HikariDataSource dataSourceInsert = null;
                    HikariDataSource dataSourceSelect = null;*/
                    try {
                        List<InnerStepVO> partitionList = innerStepSV.getListPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                        //finalaes = new AES256Util();
                        if (numScrambleThreads == 1) {
                            List<String> partitionNames = SqlUtil.getPartitionNames(connSelect, dbtype_source, owner, table_name_patition);
                            LogUtil.log("INFO", "1 #### exeILM partition.size() ;" + partitionNames.size() + "   piiordersteptable: " + piiordersteptable.getTable_name());
                            /*dataSourceInsert = ConnectionProvider.getDataSource(numScrambleThreads, targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), finalAes.decrypt(targetDBvo.getPwd()));
                            if(!samedb) {
                                dataSourceSelect = ConnectionProvider.getDataSource(numScrambleThreads, sourceDBvo.getDbtype(), sourceDBvo.getHostname(), sourceDBvo.getPort(), sourceDBvo.getId_type(), sourceDBvo.getId(), sourceDBvo.getDb(), sourceDBvo.getDbuser(), finalAes.decrypt(sourceDBvo.getPwd()));
                            } else {
                                dataSourceSelect = dataSourceInsert;
                            }
                            HikariDataSource finaldataSourceInsert = null;
                            HikariDataSource finaldataSourceSelect = null;*/
                            int currentIndex = 0; // 고유한 값을 증가시킴
                            for (String partition : partitionNames) {
                                /** 특정 시간대 작업 피하기 */
                                if (!StrUtil.checkString(stopHourFromTo)) {
                                    String[] hours = stopHourFromTo.split("-");
                                    int stopHour = StrUtil.parseInt(hours[0].trim());
                                    int resumeHour = StrUtil.parseInt(hours[1].trim());
                                    // Get the current time in Seoul time zone
                                    Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"));
                                    int hour = calendar.get(Calendar.HOUR_OF_DAY);
                                    if ((stopHour <= resumeHour && hour >= stopHour && hour < resumeHour) || (stopHour > resumeHour && (hour >= stopHour || hour < resumeHour))) {

                                        // Adjust resumeHour for wraparound
                                        resumeHour = (resumeHour + 24) % 24;

                                        // Calculate hours to wait
                                        int hoursToWait;
                                        if (hour >= stopHour) {
                                            hoursToWait = resumeHour - hour;
                                        } else {
                                            hoursToWait = stopHour - hour;
                                        }

                                        long waitTimeMillis = hoursToWait * 60 * 60 * 1000;
                                        LogUtil.log("INFO", "Waiting until after " + resumeHour + ". Current time: {}, Hours to wait: {}, waitTimeMillis: {}", calendar.getTime(), hoursToWait, waitTimeMillis);
                                        try {
                                            Thread.sleep(waitTimeMillis);
                                        } catch (InterruptedException e) {
                                            logger.error("Error during wait: {}", e.getMessage());
                                        }
                                        LogUtil.log("INFO", "Wait completed. Resuming execution.");
                                    }
                                }
                                /** 작업 시작 */
                                currentIndex++;
                                boolean partitionExists = partitionList.stream()
                                        .anyMatch(innerStepVOpart -> innerStepVOpart.getResult().contains(partition));
                                //LogUtil.log("WARN", "1111 partitionNames.size():" + partitionNames.size() + "   currentIndex: " + currentIndex+ "   partition: " + partition+ "   partitionExists: " + partitionExists+ "   partitionExists: " + partitionList.toString());
                                if (partitionExists) {
                                    continue;
                                }
                                try {
                                    DelAndInsert(piiordersteptable, partition, sqlSelect.toString(), insertTargetSql, sqlDelete.toString(), targetColumns
                                            ,piitablecols_source, piitablecols_target, pkcols, finalAes, batchSize, currentIndex, innerStepVO
                                            , sourceDBvo, targetDBvo, sourceDelflag, data_handling_method, commit_loop_cnt);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    throw e;
                                }

                            }

                        }
                        else if (numScrambleThreads > 1) {
                            List<String> partitionNames = SqlUtil.getPartitionNames(connSelect, dbtype_source, owner, table_name_patition);
                            ExecutorService executor = Executors.newFixedThreadPool(numScrambleThreads);
                            LogUtil.log("info", "2 #### ILM MIGRATION partitionNames.size():" + partitionNames.size() + "   table_name_patition: " + table_name_patition);
                            int currentIndex = 0; // 고유한 값을 증가시킴
                            List<Future<?>> futures = new ArrayList<>();
                            AtomicBoolean partitionError = new AtomicBoolean(false);
                            AtomicReference<String> firstErrorMsg = new AtomicReference<>(null);
                            for (String partition : partitionNames) {
                                // 에러 발생 시 새 파티션 제출 중단
                                if (partitionError.get()) {
                                    LogUtil.log("WARN", "Skipping partition " + partition
                                            + " due to previous partition error: table=" + table_name);
                                    break;
                                }
                                currentIndex++;
                                boolean partitionExists = partitionList.stream()
                                        .anyMatch(innerStepVOpart -> innerStepVOpart.getResult().contains(partition));
                                if (partitionExists) { // If the partition exists in the result, continue to the next iteration
                                    continue;
                                }
                                /** 특정 시간대 작업 피하기 */
                                if (!StrUtil.checkString(stopHourFromTo)) {
                                    String[] hours = stopHourFromTo.split("-");
                                    int stopHour = StrUtil.parseInt(hours[0].trim());
                                    int resumeHour = StrUtil.parseInt(hours[1].trim());
                                    // Get the current time in Seoul time zone
                                    Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"));
                                    int hour = calendar.get(Calendar.HOUR_OF_DAY);
                                    if ((stopHour <= resumeHour && hour >= stopHour && hour < resumeHour) || (stopHour > resumeHour && (hour >= stopHour || hour < resumeHour))) {

                                        // Adjust resumeHour for wraparound
                                        resumeHour = (resumeHour + 24) % 24;

                                        // Calculate hours to wait
                                        int hoursToWait;
                                        if (hour >= stopHour) {
                                            hoursToWait = resumeHour - hour;
                                        } else {
                                            hoursToWait = stopHour - hour;
                                        }

                                        long waitTimeMillis = hoursToWait * 60 * 60 * 1000;
                                        LogUtil.log("INFO", "Waiting until after " + resumeHour + ". Current time: {}, Hours to wait: {}, waitTimeMillis: {}", calendar.getTime(), hoursToWait, waitTimeMillis);
                                        try {
                                            Thread.sleep(waitTimeMillis);
                                        } catch (InterruptedException e) {
                                            logger.error("Error during wait: {}", e.getMessage());
                                        }
                                        LogUtil.log("INFO", "Wait completed. Resuming execution.");
                                    }
                                }
                                /** 작업 시작 */
                                if (currentIndex > 1 && currentIndex <= numScrambleThreads) {
                                    Thread.sleep(200);
                                }
                                InnerStepVO finalInnerStepVO = innerStepVO;
                                int finalCurrentIndex = currentIndex;
                                Future<?> future = executor.submit(() -> {
                                    try {
                                        DelAndInsert(piiordersteptable, partition, sqlSelect.toString(), insertTargetSql, sqlDelete.toString(), targetColumns
                                                ,piitablecols_source, piitablecols_target, pkcols, finalAes, batchSize, finalCurrentIndex, finalInnerStepVO
                                                , sourceDBvo, targetDBvo, sourceDelflag, data_handling_method, commit_loop_cnt);
                                    } catch (Exception e) {
                                        partitionError.set(true);
                                        firstErrorMsg.compareAndSet(null, partition + ": " + e.getMessage());
                                        logger.error("ILM/MIGRATE partition failed: partition={}, table={}, error={}",
                                                partition, piiordersteptable.getTable_name(), e.getMessage(), e);
                                    }
                                });
                                futures.add(future);
                            }
                            // 작업 완료까지 대기 (이미 제출된 파티션은 완료까지 대기 - 커밋 중간에 끊기면 안됨)
                            executor.shutdown();
                            for (Future<?> future : futures) {
                                future.get();
                            }
                            // 파티션 에러 확인 → "Ended not OK" + 예외 전파
                            if (partitionError.get()) {
                                sum_scrambleCnt = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                                innerStepVO.setExecnt("" + sum_scrambleCnt);
                                String errorDetail = "Partition error (success=" + sum_scrambleCnt + "): " + firstErrorMsg.get();
                                if (errorDetail.length() > 2000) {
                                    errorDetail = errorDetail.substring(0, 2000);
                                }
                                innerStepVO.setMessage(errorDetail);
                                innerStepVO.setStatus("Ended not OK");
                                innerStepSV.modifyEnd(innerStepVO);
                                throw new Exception("ILM/MIGRATE partition failed. successCnt=" + sum_scrambleCnt + ". " + firstErrorMsg.get());
                            }

                        }
                        sum_scrambleCnt = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                        innerStepVO.setExecnt("" + sum_scrambleCnt);
                        //long endTime = System.currentTimeMillis(); // 종료 시간 기록
                        LogUtil.log("INFO", "#### ILM MIGRATION completed ##" + table_name_patition + "   sum_scrambleCnt: " + sum_scrambleCnt);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - ILM MIGRATION: " + piiordersteptable.toString());
                        throw e;
                    }
                }
                innerStepVO.setMessage("Target:" + sum_insertTmpCnt + " = " + "ILM/MIG:" + sum_scrambleCnt);
                //innerStepVO.setExecnt("" + totalCount);
                innerStepVO.setStatus("Ended OK");
                innerStepSV.modifyEnd(innerStepVO);
            }
        }

        boolean goafterscramble = false;
        InnerStepVO innerStepVOscramble = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                , 30);
        if (innerStepVOscramble == null) {
            goafterscramble = false;
        } else if ("Ended OK".equals(innerStepVOscramble.getStatus())) {
            goafterscramble = true;
        } else {
            goafterscramble = false;
        }

        if (goafterscramble) {

            /** ###################################################################################################################
             * 	Drop tmp
             * ################################################################################################################### */
            if ("TMP_TABLE".equals(processing_method)) {/* TMP_TABLE: Distributed Parallel Processing */
                LogUtil.log("WARN","#### : 40 Drop tmp: " + "COTDL" + "." + table_name_patition);
                innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , 40);
                if (innerStepVO == null) {
                    innerStepVO = new InnerStepVO();
                    innerStepVO.setOrderid(piiordersteptable.getOrderid());
                    innerStepVO.setStepid(piiordersteptable.getStepid());
                    innerStepVO.setSeq1(piiordersteptable.getSeq1());
                    innerStepVO.setSeq2(piiordersteptable.getSeq2());
                    innerStepVO.setSeq3(piiordersteptable.getSeq3());
                    innerStepVO.setInner_step_seq(40);
                    innerStepVO.setInner_step_name("Drop tmp");
                    innerStepVO.setStatus("RUNNING");
                    innerStepSV.register(innerStepVO);
                    goFlag = true;
                } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                    goFlag = false;
                } else {
                    goFlag = true;
                }
                if (goFlag) {
                    try {
                        SqlUtil.dropTable(connSelect, dbtype_source, "COTDL", table_name_patition);
                        LogUtil.log("INFO", "drop tmp : COTDL." + table_name_patition);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - Drop tmp : " + piiordersteptable.toString());
                        throw e;
                    }
                    innerStepVO.setMessage(table_name_patition + " is droped");
                    innerStepVO.setStatus("Ended OK");
                    innerStepSV.modifyEnd(innerStepVO);
                }
            }
            /** ###################################################################################################################
             * 	Index Rebuild
             * ################################################################################################################### */
            if (isIndexEnable) {
                LogUtil.log("WARN","#### : 50 Index Rebuild " + "." + piiordersteptable.getOwner()+ "." + piiordersteptable.getTable_name() + "===>" + piiordersteptable.getWhere_col()  + "." + piiordersteptable.getWhere_key_name()  + "." + piiordersteptable.getSqlstr() );
                innerStepVO = innerStepSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , 50);
                if (innerStepVO == null) {
                    innerStepVO = new InnerStepVO();
                    innerStepVO.setOrderid(piiordersteptable.getOrderid());
                    innerStepVO.setStepid(piiordersteptable.getStepid());
                    innerStepVO.setSeq1(piiordersteptable.getSeq1());
                    innerStepVO.setSeq2(piiordersteptable.getSeq2());
                    innerStepVO.setSeq3(piiordersteptable.getSeq3());
                    innerStepVO.setInner_step_seq(50);
                    innerStepVO.setInner_step_name("Index Rebuild");
                    innerStepVO.setStatus("RUNNING");
                    innerStepSV.register(innerStepVO);
                    goFlag = true;
                } else if ("Ended OK".equals(innerStepVO.getStatus())) {
                    goFlag = false;
                } else {
                    goFlag = true;
                }
                if (goFlag) {
                    String indexes = "";
                    try {
                        /** Index, constraint enable instead of Recreating  20250220*/
                        logger.info("info "+" #####  ILM MIGRATION ##### - Index Rebuild : " + piiordersteptable.toString());
                        indexes = exeRecreateIndexCons(piiordersteptable, targetDBvo, finalAes, numScrambleThreads);
                        //indexes = exeReBuildIndexCons(piiordersteptable, targetDBvo, finalAes, numScrambleThreads);
                    } catch (Exception e) {
                        innerStepVO.setMessage(e.toString());
                        innerStepVO.setStatus("Ended not OK");
                        innerStepSV.modifyEnd(innerStepVO);
                        e.printStackTrace();
                        logger.warn("warn "+"Exception - Index Rebuild : " + piiordersteptable.toString());
                        throw e;
                    }
                    innerStepVO.setMessage(indexes);
                    innerStepVO.setStatus("Ended OK");
                    innerStepSV.modifyEnd(innerStepVO);
                }
            }
        }
        /**--------------------------------------------------------------------------------------------------------------------*/
        return sum_scrambleCnt;
    }
    public long transformAndInsert(PiiOrderStepTableVO piiordersteptable, String partition_name, String sqlSelect, String insertTargetSql, String sqlDelete, Set<String> targetColumns
            , List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, Map<String, Integer> pkcols, Hashtable<String, MetaTableVO> scrambleCols, Hashtable<String, MetaTableVO> masterkeyCols, Hashtable<String, LkPiiScrTypeVO> lkPiiScrTypeCols, AES256Util aes, int batchSize, int currentIndex, InnerStepVO innerStepVO
            , PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, boolean samedb, String processing_method, String data_handling_method, Map<String, String> dataMap, int commit_loop_cnt
            , String site
    ) throws Exception {
        return transformAndInsert(piiordersteptable, partition_name, sqlSelect, insertTargetSql, sqlDelete, targetColumns
                , piitablecols_source, piitablecols_target, pkcols, scrambleCols, masterkeyCols, lkPiiScrTypeCols, aes, batchSize, currentIndex, innerStepVO
                , sourceDBvo, targetDBvo, samedb, processing_method, data_handling_method, dataMap, commit_loop_cnt, site, null);
    }

    public long transformAndInsert(PiiOrderStepTableVO piiordersteptable, String partition_name, String sqlSelect, String insertTargetSql, String sqlDelete, Set<String> targetColumns
            , List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, Map<String, Integer> pkcols, Hashtable<String, MetaTableVO> scrambleCols, Hashtable<String, MetaTableVO> masterkeyCols, Hashtable<String, LkPiiScrTypeVO> lkPiiScrTypeCols, AES256Util aes, int batchSize, int currentIndex, InnerStepVO innerStepVO
            , PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, boolean samedb, String processing_method, String data_handling_method, Map<String, String> dataMap, int commit_loop_cnt
            , String site, AtomicBoolean killRequested
    ) throws Exception
    {
        long totalCount = 0; // 처리건수
        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();
        String orderid = piiordersteptable.getOrderid()+"";
        String orderlast4 = orderid.substring(orderid.length() - 4);// 자동적재 시 회차별 유니크한 rrn 세팅위함 20240501
        LogUtil.log("INFO", "transformAndInsert curIndex = " + currentIndex + " " + table_name + "(" + partition_name + ")" +"  "+data_handling_method +"  "+piiordersteptable.getExetype());

        String sqlSelectPatition = sqlSelect.replace(" from " + owner + "." + table_name + " where ", " from " + "COTDL" + "." + table_name + " where ");
        sqlSelectPatition = sqlSelectPatition.replace(piiordersteptable.getTable_name(), SqlUtil.makeTmpTableName(piiordersteptable.getTable_name(), piiordersteptable.getOrderid()) + " PARTITION " + "(" + partition_name + ")");
        LogUtil.log("INFO", "# transformAndInsert sqlSelectPatition=" + sqlSelectPatition);
        LogUtil.log("INFO", "# transformAndInsert insertTargetSql=" + insertTargetSql);
        LogUtil.log("INFO", "# transformAndInsert sqlDelete=" + sqlDelete);
        LogUtil.log("INFO", "# transformAndInsert pkcols=" + pkcols.toString());
        LogUtil.log("INFO", "# transformAndInsert piitablecols_source=" + piitablecols_source.toString());


        boolean delforupdate = false;
        /* TMP_TABLE: Distributed Parallel Processing */
        if ("TMP_TABLE".equals(processing_method) && "REPLACEINSERT".equals(data_handling_method)) {
            delforupdate = true;
        }
        int bindCount = (int) sqlDelete.chars().filter(ch -> ch == '?').count();
        if (delforupdate) {
            if (bindCount == 0) {
                delforupdate = false; // 바인드 없으면 굳이 per-row delete 안 함
            } else if (pkcols == null || pkcols.isEmpty()) {
                throw new IllegalStateException("sqlDelete has " + bindCount + " bind(s) but pkcols is empty. sqlDelete=" + sqlDelete);
            } else if (pkcols.size() < bindCount) {
                throw new IllegalStateException("pkcols size (" + pkcols.size() + ") < bind count (" + bindCount + "). pkcols=" + pkcols + ", sqlDelete=" + sqlDelete);
            }
        }
        LogUtil.log("INFO", "# transformAndInsert delforupdate=" + delforupdate +" , processing_method:"+processing_method+" , 처리방식:"+data_handling_method+" , bindCount:"+bindCount);

        try (
                Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                Connection connSelect = (samedb) ? connInsert : ConnectionProvider.getConnection(sourceDBvo.getDbtype(), sourceDBvo.getHostname(), sourceDBvo.getPort(), sourceDBvo.getId_type(), sourceDBvo.getId(), sourceDBvo.getDb(), sourceDBvo.getDbuser(), aes.decrypt(sourceDBvo.getPwd()));
                PreparedStatement pstmt_del = connInsert.prepareStatement(sqlDelete);
                PreparedStatement pstmt = connInsert.prepareStatement(insertTargetSql);
                Statement stmtSelect = connSelect.createStatement();
                ResultSet rs = stmtSelect.executeQuery(sqlSelectPatition)
        ) {
            connInsert.setAutoCommit(false);
            connSelect.setAutoCommit(false);

            // 현재 세션에서 UNUSABLE 인덱스 무시  UNUSABLE 상태에서는 인덱스 업데이트가 발생하지 않기 때문에 대량 데이터 적재가 더 빨라
            /*try (Statement stmt = connInsert.createStatement()) {
                stmt.execute("ALTER SESSION SET SKIP_UNUSABLE_INDEXES = TRUE");
            } catch (SQLException e) {
                logger.info("WARN: ALTER SESSION SET SKIP_UNUSABLE_INDEXES = TRUE 실행 중 오류 발생 - " + e.getMessage());
            }*/
            boolean hasDeleteBatch = false;
            rs.setFetchSize(600);
            while (rs.next()) {
                // ① 행별 PK 바인딩 플래그 초기화
                boolean pkBoundInThisRow = false;
                int colid = 0 ;
                for (int i = 0; i < piitablecols_source.size(); i++) {
                    PiiTableVO piitable = piitablecols_source.get(i);
                    /** source 와 target 의 테이블 칼럼 동시 존재 할때만 sql에 칼럼 추가 20240520    검색속도향상   20250216 */
                    if (piitable.getColumn_name() != null && !targetColumns.contains(piitable.getColumn_name())) {
                        continue;
                    }
                    colid++;
                    Object colVal = rs.getObject(piitable.getColumn_name());

                    //LogUtil.log("DEBUG"," transformAndInsert  while (rs.next()) { for (int i = 0; i < piitablecols_source.size(); i++) =>"+ piitable.getTable_name()+"-"+ piitable.getColumn_name()+"-"+piitable.getData_type()+"-"+piitable.getData_type());
                    /** 변환타입 확인 및 스크램블 적용  */
                    String strVal = String.valueOf(colVal);
                    /*if (strVal == null || strVal.isBlank() || strVal.equals("null")){

                        // colVal 값이 null 또는 빈 문자열 또는 "null" 문자열인 경우 처리 변환타입 확인 및 스크램블 적용 안함
                    } else {*/
                    if (scrambleCols.containsKey(piitable.getColumn_name())) {
                        MetaTableVO metaTableVO = scrambleCols.get(piitable.getColumn_name());
//new---------------20250303--------------------------------------------------------
                        boolean isTestDataAutoGen = piiordersteptable.getJobid().startsWith("TESTDATA_AUTO_GEN");

                        if (!StrUtil.checkString(metaTableVO.getScramble_type())) {
                            if (!StrUtil.checkString(metaTableVO.getEncript_flag())) {
                                if ("Y".equalsIgnoreCase(metaTableVO.getEncript_flag())) {
                                    //LogUtil.log("DEBUG", (isTestDataAutoGen ? "TESTDATA_AUTO_GEN " : "") + "metaTableVO.getEncript_flag()" + piitable.getTable_name() + "-" + piitable.getColumn_name() + " : " + metaTableVO.getEncript_flag() + (isTestDataAutoGen ? " colVal=" + String.valueOf(colVal) : ""));

                                    LkPiiScrTypeVO lkPiiScrTypeVO = lkPiiScrTypeCols.get(metaTableVO.getPiitype());

                                    if ("DB".equalsIgnoreCase(lkPiiScrTypeVO.getEncdecfunctype())) {
                                        // "#DEC#"로 시작하는지 확인
                                        boolean isDec = strVal.startsWith("#DEC#");
                                        // "#DEC#"로 시작하는 경우, 해당 부분 제거
                                        if (isDec) {
                                            strVal = strVal.substring("#DEC#".length()); // "#DEC#" 이후의 문자열만 남김
                                        }
//                                            LogUtil.log("DEBUG", "isDec 1   able: {}, Column: {}, colVal: {}",
//                                                    piitable.getTable_name(), piitable.getColumn_name(), colVal);
                                        colVal = isTestDataAutoGen
                                                ? Scramble.getScrResult(orderlast4, strVal, metaTableVO.getScramble_type())
                                                : Scramble.getScrResult(strVal, metaTableVO.getScramble_type());
//                                            LogUtil.log("DEBUG", "isDec 2   able: {}, Column: {}, colVal: {}",
//                                                    piitable.getTable_name(), piitable.getColumn_name(), colVal);
                                        // isDec가 true인 경우, 결과값 맨 앞에 "#DEC#"를 붙임
                                        if (isDec) {
                                            colVal = "#DEC#" + colVal;
                                        }
                                        //LogUtil.log("DEBUG", "isDec 3   able: {}, Column: {}, colVal: {}",
                                        //        piitable.getTable_name(), piitable.getColumn_name(), colVal);

                                        for (int b = 0; b < 5; b++) {
                                            //LogUtil.log("DEBUG", piitable.getTable_name() + ":" + piitable.getColumn_name() + "  colid=" + colid + " colVal=" + String.valueOf(colVal));
                                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) {
                                                pstmt.setNull(colid, Types.VARCHAR);
                                            } else {
                                                pstmt.setString(colid, String.valueOf(colVal));
                                            }
                                            colid++;
                                        }
                                    } else if ("JAVA API".equalsIgnoreCase(lkPiiScrTypeVO.getEncdecfunctype())) {
                                        String decVal = EncUtil.processData(lkPiiScrTypeVO.getPiicode(), site, false, strVal);
                                        String scrVal = isTestDataAutoGen
                                                ? Scramble.getScrResult(orderlast4, decVal, metaTableVO.getScramble_type())
                                                : Scramble.getScrResult(decVal, metaTableVO.getScramble_type());
                                        colVal = EncUtil.processData(lkPiiScrTypeVO.getPiicode(), site, true, scrVal);
                                    }
                                } else {
                                    colVal = isTestDataAutoGen
                                            ? Scramble.getScrResult(orderlast4, strVal, metaTableVO.getScramble_type())
                                            : Scramble.getScrResult(strVal, metaTableVO.getScramble_type());
                                }
                            } else {
                                colVal = isTestDataAutoGen
                                        ? Scramble.getScrResult(orderlast4, strVal, metaTableVO.getScramble_type())
                                        : Scramble.getScrResult(strVal, metaTableVO.getScramble_type());
                            }
                        }
                    }

                    /** MasterKeymap 데이터를 적용함 "TESTDATA_AUTO_GEN" JOBID로 시작하면 적용 20240128 */
                    /*if (strVal == null || strVal.isBlank() || strVal.equals("null"))*/
                    if (piiordersteptable.getJobid().startsWith("TESTDATA_AUTO_GEN")) {
                        //LogUtil.log("DEBUG", "Table: {}, Column: {}, masterkeyCols: {}, dataMap.size(): {}",
                         //       piitable.getTable_name(), piitable.getColumn_name(), masterkeyCols.toString(), dataMap.size());
                        if (masterkeyCols.containsKey(piitable.getColumn_name())) {//LogUtil.log("INFO", "warn"+"MasterKeymap 데이터를 적용함 =>222 "+ piitable.getColumn_name()+"  "+ colVal);
                            MetaTableVO metaTableVO = masterkeyCols.get(piitable.getColumn_name());
                            //LogUtil.log("DEBUG", "Table: {}, Column: {}, MasterKey: {}, colVal: {} dataMap contains key: {}",
                             //       piitable.getTable_name(), piitable.getColumn_name(), metaTableVO.getMasterkey(), colVal, dataMap.containsKey(metaTableVO.getMasterkey() + ":" + String.valueOf(colVal)));

                            if (!StrUtil.checkString(metaTableVO.getMasterkey())) {
                                //LogUtil.log("DEBUG", "warn"+"MasterKeymap 데이터를 적용함 =>333 "+metaTableVO.getMasterkey()+"  "+ piitable.getColumn_name()+"  "+ colVal);
                                Object mappedValue = dataMap.get(metaTableVO.getMasterkey() + ":" + String.valueOf(colVal));

                                if (mappedValue != null) {
                                    colVal = mappedValue;
                                    LogUtil.log("DEBUG", "warn"+"##### MasterKeymap Exist OK=> Masterkey: {} | Table: {} | Column: {} | mappedValue: {}",
                                            metaTableVO.getMasterkey() ,
                                            piitable.getTable_name(),
                                            piitable.getColumn_name(),
                                            String.valueOf(colVal));
                                } else {
                                    LogUtil.log("DEBUG", "warn ##### MasterKeymap NOT Exist => Masterkey: {} | Table: {} | Column: {} | val: {}",
                                            metaTableVO.getMasterkey(),
                                            piitable.getTable_name(),
                                            piitable.getColumn_name(),
                                            String.valueOf(colVal));
                                }
                            }
                        }
                    }
                    /*}*/
                    //LogUtil.log("DEBUG",piitable.getTable_name()+":"+piitable.getColumn_name()+"  colid="+colid+" colVal="+String.valueOf(colVal)+ " Data_type="+piitable.getData_type());
                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                            || piitable.getData_type().equalsIgnoreCase("CHAR")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.VARCHAR);
                        else {//logger.info(String.valueOf(colVal)+"  ###############");
                            pstmt.setString(colid, String.valueOf(colVal));
                        }
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else {//logger.info(String.valueOf(colVal)+"  ###############");
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, new BigDecimal(String.valueOf(colVal))); //(BigDecimal) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), new BigDecimal(String.valueOf(colVal))); //(BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DATE);
                        else {
                            //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                            java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                            java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                            pstmt.setDate(colid, sqlDate);
                        }
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                            else {
                                //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                                java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                                pstmt_del.setDate(pkcols.get(piitable.getColumn_name()), sqlDate);
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.FLOAT);
                        else pstmt.setFloat(colid, (Float) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                            else pstmt_del.setFloat(pkcols.get(piitable.getColumn_name()), (Float) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setLong(colid, (Long) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else pstmt_del.setLong(pkcols.get(piitable.getColumn_name()), (Long) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DOUBLE);
                        else pstmt.setDouble(colid, (Double) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                            else
                                pstmt_del.setDouble(pkcols.get(piitable.getColumn_name()), (Double) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BOOLEAN);
                        else pstmt.setBoolean(colid, (Boolean) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                            else
                                pstmt_del.setBoolean(pkcols.get(piitable.getColumn_name()), (Boolean) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, (BigDecimal) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), (BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.CLOB);
                        else pstmt.setClob(colid, (Clob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                            else pstmt_del.setClob(pkcols.get(piitable.getColumn_name()), (Clob) colVal);
                        }
                    }

                    //else if (piitable.getData_type().equalsIgnoreCase("ROWID")) 		{if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.ROWID); 	else pstmt.setRowid(		colid 	, rs.getRowid(colid));}
                    else {
                        logger.info("info "+"exescramble defined argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                            pstmt.setNull(colid, Types.VARCHAR);
                        else
                            pstmt.setString(colid, String.valueOf(colVal));
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) { pkBoundInThisRow = true; // ② 실제 PK 바인딩 시점
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                        }
                    }
                }
                LogUtil.log("DEBUG", "exeScramble totalCount:" + totalCount);
                pstmt.addBatch();
                if (delforupdate) {
                    if (pkBoundInThisRow) {
                        pstmt_del.addBatch();
                        hasDeleteBatch = true;  // ← 마지막 executeBatch 수행 여부 표시
                    } else {
                        LogUtil.log("DEBUG", "Delete PK not bound for this row. pkcols=" + pkcols + ", sqlDelete=" + sqlDelete);
                    }
                }
                totalCount++;
                if (totalCount % batchSize == 0) {
                    LogUtil.log("INFO", "exeScramble totalCount % batchSize == 0 pstmt.executeBatch(); before" + totalCount);
                    // DELETE+INSERT를 savepoint로 묶어 원자성 보장
                    Savepoint sp = null;
                    if (delforupdate) {
                        sp = connInsert.setSavepoint("batch_" + totalCount);
                    }
                    try {
                        if (delforupdate) {
                            if (pkBoundInThisRow) {
                                pstmt_del.executeBatch();
                                pstmt_del.clearBatch();
                                hasDeleteBatch = false;
                            } else {
                                LogUtil.log("DEBUG", "Delete PK not bound for this row. pkcols=" + pkcols + ", sqlDelete=" + sqlDelete);
                            }
                        }
                        pstmt.executeBatch();
                        pstmt.clearBatch();
                        // releaseSavepoint 불필요: commit/rollback 시 자동 해제됨
                        // (Oracle/Tibero는 releaseSavepoint 미지원 — SQLFeatureNotSupportedException)
                    } catch (Exception batchEx) {
                        if (sp != null) {
                            logger.error("DELETE+INSERT batch failed, rolling back to savepoint: {}", batchEx.getMessage());
                            connInsert.rollback(sp);
                        }
                        throw batchEx;
                    }
                    LogUtil.log("INFO", "exeScramble totalCount % batchSize == 0 pstmt.executeBatch(); after" + totalCount);
                    /*파티션별 commit 컨프롤을 위해*/
                    if(commit_loop_cnt != 0) {
                        if (totalCount % (batchSize * commit_loop_cnt) == 0) {
                            JdbcUtil.commit(connSelect);
                            JdbcUtil.commit(connInsert);
                        }
                    }
                    // Kill 신호 확인 - 배치 커밋 시점마다 체크
                    if (killRequested != null && killRequested.get()) {
                        logger.warn("Kill requested during transformAndInsert: table={}, partition={}, processed={}",
                                table_name, partition_name, totalCount);
                        JdbcUtil.rollback(connInsert);
                        if (!samedb) {
                            JdbcUtil.rollback(connSelect);
                        }
                        throw new InterruptedException("Kill requested: table=" + table_name + " partition=" + partition_name + " processed=" + totalCount);
                    }
                    LogUtil.log("INFO", "##if ((rowcount) % batchSize == 0)## Scramble insert thread " + table_name + " "  + "   totalCount: " + totalCount);
                }
            }
            /** Last 마지막으로 나머지 배치 실행 - savepoint로 원자성 보장 */
            Savepoint spFinal = null;
            if (delforupdate) {
                spFinal = connInsert.setSavepoint("batch_final");
            }
            try {
                if (delforupdate) {
                    if (hasDeleteBatch) {
                        pstmt_del.executeBatch();
                        pstmt_del.clearBatch();
                    } else {
                        LogUtil.log("DEBUG", "Last 마지막으로 나머지 배치 실행  pstmt_del.executeBatch()  대상 없음  pkcols=" + pkcols + ", sqlDelete=" + sqlDelete);
                    }
                }
                pstmt.executeBatch();
                pstmt.clearBatch();
                // releaseSavepoint 불필요: commit/rollback 시 자동 해제됨
            } catch (Exception batchEx) {
                if (spFinal != null) {
                    logger.error("Final DELETE+INSERT batch failed, rolling back to savepoint: {}", batchEx.getMessage());
                    connInsert.rollback(spFinal);
                }
                throw batchEx;
            }

            JdbcUtil.commit(connInsert);
            JdbcUtil.commit(connSelect);
            /** Last 마지막으로 나머지 배치 실행 */
            LogUtil.log("INFO", "#### Scramble Serial completed $  " + piiordersteptable.getTable_name() + " " + "   totalCount: " + totalCount);

            InnerStepVO innerStepVO_PT = new InnerStepVO();
            innerStepVO_PT.setOrderid(piiordersteptable.getOrderid());
            innerStepVO_PT.setStepid(piiordersteptable.getStepid());
            innerStepVO_PT.setSeq1(piiordersteptable.getSeq1());
            innerStepVO_PT.setSeq2(piiordersteptable.getSeq2());
            innerStepVO_PT.setSeq3(piiordersteptable.getSeq3());
            innerStepVO_PT.setInner_step_seq(100 + currentIndex);
            innerStepVO_PT.setInner_step_name("partition: "+currentIndex);
            innerStepVO_PT.setStatus("Ended OK");
            innerStepVO_PT.setExecnt(totalCount + "");
            innerStepVO_PT.setMessage("(" + partition_name + ")");
            innerStepVO_PT.setResult(partition_name);
            LogUtil.log("INFO", "#### Scramble Serial innerStepVO_PT  " + innerStepVO_PT.toString());
            innerStepSV.register(innerStepVO_PT);
            // 파티션 완료 시 누적 카운트를 ordersteptable에 반영 (UI 실시간 업데이트)
            long runningTotal = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), runningTotal);

        } catch (Exception e) {
            logger.error("Exception occurred while scrambling serial for table: {}. Details: {}",
                    piiordersteptable.getTable_name(), e.getMessage(), e);
            throw new CustomException(e.getMessage(), e);
        }
        return totalCount;
    }

    public long DelAndInsert(PiiOrderStepTableVO piiordersteptable, String partition_name, String sqlSelect, String insertTargetSql, String sqlDelete, Set<String> targetColumns
            , List<PiiTableVO> piitablecols_source, List<PiiTableVO> piitablecols_target, Map<String, Integer> pkcols, AES256Util aes, int batchSize, int currentIndex, InnerStepVO innerStepVO
            , PiiDatabaseVO sourceDBvo, PiiDatabaseVO targetDBvo, boolean sourceDelflag, String data_handling_method, int commit_loop_cnt) throws Exception {
        long totalCount = 0; // 처리건수
        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();
        LogUtil.log("INFO", "DelAndInsert start  currentIndex = " + currentIndex + " " + table_name + "(" + partition_name + ")" +"  "+data_handling_method +"  "+piiordersteptable.getExetype());
        /** ILM = TURE, MIGRATE = FALSE   DelAndInsert 호출 시 세팅 되어 들어온다*/
        boolean delforupdate = sourceDelflag;
        if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
            if("REPLACEINSERT".equalsIgnoreCase(data_handling_method)) {
                /** Migrate 인경우 REPLACEINSERT 이면 Target PK중복을 delete  그 외 INSERT, TRUNCSERT 는 insert만 진행*/
                //LogUtil.log("INFO", "@@@@@@@  true  "+"Migrate 인경우 REPLACEINSERT 이면 Target PK중복을 delete");
                delforupdate = true;
            } else {
                delforupdate = false;
            }
        }
        else if("ILM".equalsIgnoreCase(piiordersteptable.getExetype())){
            delforupdate = sourceDelflag;
        }
        LogUtil.log("DEBUG", "data_handling_method:" + data_handling_method);
//        if(delforupdate)
//        LogUtil.log("INFO", "@@@@@@@"+piiordersteptable.getExetype()+"   "+data_handling_method);

        String insertTargetSqlNew = insertTargetSql;
//        if ("Y".equalsIgnoreCase(piiordersteptable.getPagitype())) {
//            if("EXE_MIGRATE".equalsIgnoreCase(piiordersteptable.getSteptype())) { /* Target은 piiordersteptable에 세팅되어진다.*/
//                LogUtil.log("INFO", "#### ILM 시작 EXE_MIGRATE insertTargetSql=" + piiordersteptable.getWhere_key_name() + "." + piiordersteptable.getSqlstr() +":"+ currentIndex);
//                insertTargetSqlNew = insertTargetSqlNew.replace(piiordersteptable.getWhere_key_name() + "." + piiordersteptable.getSqlstr(), "COTDL" + "." + piiordersteptable.getSqlstr() + currentIndex);
//                LogUtil.log("INFO", "#### ILM 시작 EXE_MIGRATE insertTargetSqlNew=" + insertTargetSqlNew);
//            } else {
//                insertTargetSqlNew = insertTargetSqlNew.replace(owner + "." + table_name, "COTDL" + "." + table_name + currentIndex);
//            }
//        }

        String sqlSelectPatition = sqlSelect.replace(" from " + owner + "." + table_name + " where ", " from " + "COTDL" + "." + table_name + " where ");
        sqlSelectPatition = sqlSelectPatition.replace(piiordersteptable.getTable_name(), SqlUtil.makeTmpTableName(piiordersteptable.getTable_name(), piiordersteptable.getOrderid()) + " PARTITION " + "(" + partition_name + ")");
//        LogUtil.log("INFO", "#### ILM 시작 sqlSelectPatition=" + sqlSelectPatition);
        LogUtil.log("DEBUG", "#### ILM 시작 insertTargetSql=" + insertTargetSqlNew);
        LogUtil.log("DEBUG", "#### ILM 시작 sqlSelectPatition=" + sqlSelectPatition);
        LogUtil.log("DEBUG", "#### ILM 시작 sqlDelete=" + sqlDelete);
        LogUtil.log("DEBUG", "#### ILM 시작 targetDBvo=" + targetDBvo);
        LogUtil.log("DEBUG", "#### ILM 시작 sourceDBvo=" + sourceDBvo);

        try (
                Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                Connection connSelect = ConnectionProvider.getConnection(sourceDBvo.getDbtype(), sourceDBvo.getHostname(), sourceDBvo.getPort(), sourceDBvo.getId_type(), sourceDBvo.getId(), sourceDBvo.getDb(), sourceDBvo.getDbuser(), aes.decrypt(sourceDBvo.getPwd()));
                /** Migrate 인경우..Target을 delete 하고 ILM 인경우 Source를 delete 한다. 20240223*/
                //PreparedStatement pstmt_del = connSelect.prepareStatement(sqlDelete);
                PreparedStatement pstmt_del = ("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())) ? connInsert.prepareStatement(sqlDelete) : connSelect.prepareStatement(sqlDelete);
                PreparedStatement pstmt = connInsert.prepareStatement(insertTargetSqlNew);
                Statement stmtSelect = connSelect.createStatement();
                ResultSet rs = stmtSelect.executeQuery(sqlSelectPatition)
        ) {
            connInsert.setAutoCommit(false);
            connSelect.setAutoCommit(false);

            rs.setFetchSize(600);
            while (rs.next()) {//LogUtil.log("DEBUG", " while (rs.next()):" );
                /** 데이터 추출 및 preparedStatement에 세팅 */
                for (int i = 0; i < piitablecols_source.size(); i++) {
                    PiiTableVO piitable = piitablecols_source.get(i);
                    /** source 와 target 의 테이블 칼럼 동시 존재 할때만 sql에 칼럼 추가 20240520    검색속도향상   20250216 */
                    if (piitable.getColumn_name() != null && !targetColumns.contains(piitable.getColumn_name())) {
                        LogUtil.log("DEBUG"," DelAndInsert  소스 타겟 칼럼 없는 경우  =>"+ piitable.getTable_name()+"-"+ piitable.getColumn_name()+"-"+piitable.getData_type()+"-"+piitable.getData_type());
                        continue;
                    }

                    int colid = StrUtil.parseInt(piitable.getColumn_id());
                    Object colVal = rs.getObject(colid);
                    //LogUtil.log("DEBUG"," DelAndInsert  while (rs.next()) { =>"+ piitable.getTable_name()+"-"+ piitable.getColumn_name()+"-"+piitable.getData_type()+"-"+piitable.getData_type());
                    if (piitable.getData_type().equalsIgnoreCase("VARCHAR2")
                            || piitable.getData_type().equalsIgnoreCase("VARCHAR")
                            || piitable.getData_type().equalsIgnoreCase("CHARACTER VARYING")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMTEXT")
                            || piitable.getData_type().equalsIgnoreCase("LONGTEXT")
                            || piitable.getData_type().equalsIgnoreCase("TEXT")
                            || piitable.getData_type().equalsIgnoreCase("CHAR")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.VARCHAR);
                        else {//logger.info(String.valueOf(colVal)+"  ###############");
                            pstmt.setString(colid, String.valueOf(colVal));
                        }
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else {//logger.info(String.valueOf(colVal)+"  ###############");
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("NUMBER")
                            || piitable.getData_type().equalsIgnoreCase("NUMERIC")
                            || piitable.getData_type().equalsIgnoreCase("DECIMAL")
                            || piitable.getData_type().equalsIgnoreCase("INT")
                            || piitable.getData_type().equalsIgnoreCase("BIGINT")
                            || piitable.getData_type().equalsIgnoreCase("MEDIUMINT")
                            || piitable.getData_type().equalsIgnoreCase("SMALLINT")
                            || piitable.getData_type().equalsIgnoreCase("TINYINT")
                    ) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else {
                            //LogUtil.log("WARN", "colid: "+colid +"   colid: "+piitable.getColumn_name() +"         colVal: "+ colVal);
                            pstmt.setBigDecimal(colid, (BigDecimal) colVal);
                        }
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), (BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DATE);
                        else {
                            //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                            java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                            java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                            pstmt.setDate(colid, sqlDate);
                        }
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DATE);
                            else {
                                //pstmt.setDate(colid, new java.sql.Date(((Timestamp) colVal).getTime()));
                                java.util.Date utilDate = new Date(((Timestamp) colVal).getTime());
                                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
                                pstmt_del.setDate(pkcols.get(piitable.getColumn_name()), sqlDate);
                            }
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DATETIME")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("TIMESTAMP(6)")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.TIMESTAMP);
                        else pstmt.setTimestamp(colid, (Timestamp) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.TIMESTAMP);
                            else
                                pstmt_del.setTimestamp(pkcols.get(piitable.getColumn_name()), (Timestamp) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("FLOAT")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.FLOAT);
                        else pstmt.setFloat(colid, (Float) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.FLOAT);
                            else pstmt_del.setFloat(pkcols.get(piitable.getColumn_name()), (Float) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONG")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setLong(colid, (Long) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else pstmt_del.setLong(pkcols.get(piitable.getColumn_name()), (Long) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("DOUBLE")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.DOUBLE);
                        else pstmt.setDouble(colid, (Double) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.DOUBLE);
                            else
                                pstmt_del.setDouble(pkcols.get(piitable.getColumn_name()), (Double) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BOOLEAN")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BOOLEAN);
                        else pstmt.setBoolean(colid, (Boolean) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BOOLEAN);
                            else
                                pstmt_del.setBoolean(pkcols.get(piitable.getColumn_name()), (Boolean) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("INTEGER")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BIGINT);
                        else pstmt.setBigDecimal(colid, (BigDecimal) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BIGINT);
                            else
                                pstmt_del.setBigDecimal(pkcols.get(piitable.getColumn_name()), (BigDecimal) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("BLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("LONGBLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.BLOB);
                        else pstmt.setBlob(colid, (Blob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.BLOB);
                            else pstmt_del.setBlob(pkcols.get(piitable.getColumn_name()), (Blob) colVal);
                        }
                    } else if (piitable.getData_type().equalsIgnoreCase("CLOB")) {
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.CLOB);
                        else pstmt.setClob(colid, (Clob) colVal);
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.CLOB);
                            else pstmt_del.setClob(pkcols.get(piitable.getColumn_name()), (Clob) colVal);
                        }
                    }

                    //else if (piitable.getData_type().equalsIgnoreCase("ROWID")) 		{if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null")) pstmt.setNull(colid, Types.ROWID); 	else pstmt.setRowid(		colid 	, rs.getRowid(colid));}
                    else {
                        logger.info("info "+"DelAndInsert defined argument : table:" + piitable.getTable_name() + " type:" + piitable.getData_type() + "  Column_name:" + piitable.getColumn_name());
                        if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                            pstmt.setNull(colid, Types.VARCHAR);
                        else
                            pstmt.setString(colid, String.valueOf(colVal));
                        if (delforupdate && pkcols.containsKey(piitable.getColumn_name())) {
                            if (colVal == null || String.valueOf(colVal).equalsIgnoreCase("null"))
                                pstmt_del.setNull(pkcols.get(piitable.getColumn_name()), Types.VARCHAR);
                            else
                                pstmt_del.setString(pkcols.get(piitable.getColumn_name()), String.valueOf(colVal));
                        }
                    }
                }
                //LogUtil.log("DEBUG", "exeScramble rowcount:" );
                pstmt.addBatch();
                if (delforupdate) {
                    pstmt_del.addBatch();
                }
                totalCount++;
                if (totalCount % batchSize == 0) {
                    // DELETE+INSERT를 savepoint로 묶어 원자성 보장
                    Savepoint sp = null;
                    if (delforupdate) {
                        sp = connInsert.setSavepoint("batch_" + totalCount);
                    }
                    try {
                        if (delforupdate) {
                            pstmt_del.executeBatch();
                            pstmt_del.clearBatch();
                        }
                        pstmt.executeBatch();
                        pstmt.clearBatch();
                        // releaseSavepoint 불필요: commit/rollback 시 자동 해제됨
                    } catch (Exception batchEx) {
                        if (sp != null) {
                            logger.error("DelAndInsert batch failed, rolling back to savepoint: {}", batchEx.getMessage());
                            connInsert.rollback(sp);
                        }
                        throw batchEx;
                    }
                    /*파티션별 commit 컨트롤을 위해*/
                    if(commit_loop_cnt != 0) {
                        if (totalCount % (batchSize * commit_loop_cnt) == 0) {
                            JdbcUtil.commit(connSelect);
                            JdbcUtil.commit(connInsert);
                        }
                    }
                }
            }
            LogUtil.log("DEBUG", "Last 마지막으로 나머지 배치 실행:1" );
            /** Last 마지막으로 나머지 배치 실행 - savepoint로 원자성 보장 */
            Savepoint spFinal = null;
            if (delforupdate) {
                spFinal = connInsert.setSavepoint("batch_final");
            }
            try {
                if (delforupdate) {
                    pstmt_del.executeBatch();
                    pstmt_del.clearBatch();
                }
                pstmt.executeBatch();
                pstmt.clearBatch();
                // releaseSavepoint 불필요: commit/rollback 시 자동 해제됨
            } catch (Exception batchEx) {
                if (spFinal != null) {
                    logger.error("DelAndInsert final batch failed, rolling back to savepoint: {}", batchEx.getMessage());
                    connInsert.rollback(spFinal);
                }
                throw batchEx;
            }
            JdbcUtil.commit(connInsert);
            JdbcUtil.commit(connSelect);
            //long endTime = System.currentTimeMillis(); // 종료 시간 기록
            LogUtil.log("INFO", "#### DelAndInsert completed : currentIndex="+currentIndex+"  " +  piiordersteptable.getTable_name() + " " + "   totalCount: " + totalCount);
            InnerStepVO innerStepVO_PT = new InnerStepVO();
            innerStepVO_PT.setOrderid(piiordersteptable.getOrderid());
            innerStepVO_PT.setStepid(piiordersteptable.getStepid());
            innerStepVO_PT.setSeq1(piiordersteptable.getSeq1());
            innerStepVO_PT.setSeq2(piiordersteptable.getSeq2());
            innerStepVO_PT.setSeq3(piiordersteptable.getSeq3());
            innerStepVO_PT.setInner_step_seq(100 + currentIndex);
            innerStepVO_PT.setInner_step_name("partition: "+currentIndex);
            innerStepVO_PT.setStatus("Ended OK");
            innerStepVO_PT.setExecnt(totalCount + "");
            innerStepVO_PT.setMessage("(" + partition_name + ")");
            innerStepVO_PT.setResult(partition_name);
            innerStepSV.register(innerStepVO_PT);
            // 파티션 완료 시 누적 카운트를 ordersteptable에 반영 (UI 실시간 업데이트)
            long runningTotal = innerStepSV.getTotalPartition(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
            ordersteptableSV.updatecnt(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3(), runningTotal);
            LogUtil.log("DEBUG", "innerStepSV.register(innerStepVO_PT):" );
        } catch (Exception e) {
            // connInsert/connSelect은 try-with-resources로 자동 close
            // DriverManager 커넥션 close() 시 uncommitted TX는 자동 rollback됨
            e.printStackTrace();
            logger.warn("warn "+"Exception - DelAndInsert: currentIndex="+currentIndex+"  " + piiordersteptable.getTable_name()+"  " + e.getMessage());
            throw new CustomException(e.getMessage(), e);
        }
        return totalCount;
    }
    public String disableIndexConsSaveDDL(PiiOrderStepTableVO piiordersteptable, String dbtype_target, Connection connInsert, String db_target) throws Exception {
        /*SCRAMBLE 은 동일 OWNER TABLE 임.*/
        String sql = "";
        String owner = piiordersteptable.getOwner();
        String table_name = piiordersteptable.getTable_name();
        /** MIGRATE 은 소스 와 타겟 테이블이 다르다.*/
        if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
            owner = piiordersteptable.getWhere_key_name();
            table_name = piiordersteptable.getSqlstr();
        }
        String sqlAllIndexCons = SqlUtil.getSqlAllIndexCons(dbtype_target, owner, table_name);
        String sqlChildConstraint = SqlUtil.getChildTableConstraintsSql(dbtype_target, owner, table_name);
        LogUtil.log("INFO", "warn "+"####### disableIndexConsSaveDDL - Scramble INDEX DDL SAVE & Unusable: " + owner + "  " + table_name + "  " + piiordersteptable);

        StringBuilder result = new StringBuilder();
        try (
                PreparedStatement statementIndex = connInsert.prepareStatement(sqlAllIndexCons);
                PreparedStatement stmtChildCstraint = connInsert.prepareStatement(sqlChildConstraint);
                ResultSet resultSet = statementIndex.executeQuery();
                ResultSet rsChildCstraint = stmtChildCstraint.executeQuery();
                Statement statement = connInsert.createStatement()
        ) {
            /** FK Child contraints   Disable 만 시킴....나중에 별도로....Enable 작업은 해야함..*/
            while (rsChildCstraint.next()) {
                String index_owner = rsChildCstraint.getString("INDEX_OWNER");
                String index_name = rsChildCstraint.getString("INDEX_NAME");
                String table_ownerChild = rsChildCstraint.getString("TABLE_OWNER");
                String table_nameChild = rsChildCstraint.getString("TABLE_NAME");
                String status = rsChildCstraint.getString("STATUS");
                String constraint_type = rsChildCstraint.getString("CONSTRAINT_TYPE");
                String object_type = rsChildCstraint.getString("OBJECT_TYPE");
                String constraint_ddl = rsChildCstraint.getString("CONSTRAINT_DDL");
                LogUtil.log("INFO", "11===####"+object_type+"===####"+index_owner+"===####"+index_name);
                OrderDdlVO orderDdlVO = orderDdlSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , object_type, index_owner, index_name);
                if (orderDdlVO != null) {
                    continue;
                } else {
                    orderDdlVO = new OrderDdlVO();
                    orderDdlVO.setOrderid(piiordersteptable.getOrderid());
                    orderDdlVO.setStepid(piiordersteptable.getStepid());
                    orderDdlVO.setSeq1(piiordersteptable.getSeq1());
                    orderDdlVO.setSeq2(piiordersteptable.getSeq2());
                    orderDdlVO.setSeq3(piiordersteptable.getSeq3());
                    orderDdlVO.setDb(db_target);
                    orderDdlVO.setOwner(table_ownerChild);
                    orderDdlVO.setTable_name(table_nameChild);
                    orderDdlVO.setConstraint_type(constraint_type);
                    orderDdlVO.setObject_type(object_type);
                    orderDdlVO.setObject_owner(index_owner);
                    orderDdlVO.setObject_name(index_name);
                    orderDdlVO.setStatus(status);
                    orderDdlVO.setDdl(constraint_ddl);
                }
                /** 기존 contraints drop 방식에서 disable 방식으로 전환 => 훨씬 단순하다....  20250220 */
//                if("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type) ){
                sql = SqlUtil.getSqlDropIndexCons(dbtype_target, index_owner, index_name, constraint_type, object_type, table_ownerChild, table_nameChild);
//                } else {
//                    sql = SqlUtil.getSqlUnusableIndexCons(dbtype_target, index_owner, index_name, constraint_type, object_type, table_ownerChild, table_nameChild);
//                }
                //String
                LogUtil.log("INFO", "info$ :getSqlUnusableIndexCons  object_type:" +object_type + " index_name:" + index_name + " sql:" + sql);
                if (!StrUtil.checkString(sql)) {
                    LogUtil.log("INFO", "info$ getSqlUnusableIndexCons##" + object_type + "===####" + index_owner + "===####" + index_name + ":" + sql);
                    try {
                        statement.executeUpdate(sql);
                    } catch (SQLException e) {
                        logger.warn("warn "+"Exception - getSqlUnusableIndexCons @@@ FK Child contraints @@@@@@@@@@@@@@ : " + object_type + "===####" + index_owner + "===####" + index_name + ":" + sql + "=" + e.toString());
                    }
                }

                orderDdlSV.register(orderDdlVO);
                result.append(index_name + ", ");

            }

            /** FK Child contraints가  Disable 된 이후 PK UNIQUE 도 삭제가 가능함.*/
            while (resultSet.next()) {
                String index_owner = resultSet.getString("INDEX_OWNER");
                String index_name = resultSet.getString("INDEX_NAME");
                //String table_owner = resultSet.getString("TABLE_OWNER");
                //String table_name = resultSet.getString("TABLE_NAME");
                String status = resultSet.getString("STATUS");
                String constraint_type = resultSet.getString("CONSTRAINT_TYPE");
                String object_type = resultSet.getString("OBJECT_TYPE");
                String constraint_ddl = resultSet.getString("CONSTRAINT_DDL");
                // 기존 "PARALLEL" 문자열이 잇으면 제거 하고 추가하기
                if(object_type.equalsIgnoreCase("INDEX")) {
                    constraint_ddl = constraint_ddl.replaceAll("\\bPARALLEL\\b", "") + "PARALLEL";
                }
                OrderDdlVO orderDdlVO = orderDdlSV.get(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3()
                        , object_type, index_owner, index_name);
                if (orderDdlVO != null) {
                    continue;
                } else {
                    orderDdlVO = new OrderDdlVO();
                    orderDdlVO.setOrderid(piiordersteptable.getOrderid());
                    orderDdlVO.setStepid(piiordersteptable.getStepid());
                    orderDdlVO.setSeq1(piiordersteptable.getSeq1());
                    orderDdlVO.setSeq2(piiordersteptable.getSeq2());
                    orderDdlVO.setSeq3(piiordersteptable.getSeq3());
                    orderDdlVO.setDb(db_target);
                    orderDdlVO.setOwner(owner);
                    orderDdlVO.setTable_name(table_name);
                    orderDdlVO.setConstraint_type(constraint_type);
                    orderDdlVO.setObject_type(object_type);
                    orderDdlVO.setObject_owner(index_owner);
                    orderDdlVO.setObject_name(index_name);
                    orderDdlVO.setStatus(status);
                    orderDdlVO.setDdl(constraint_ddl);
                }
                if (!StrUtil.checkString(constraint_ddl)) {
                    LogUtil.log("INFO", "disableIndexConsSaveDDL## "+dbtype_target+" | "+ index_owner+" | "+ index_name+" | "+ constraint_type+" | "+ object_type+" | "+ owner+" | "+ table_name);
                    /** 기존 index drop 방식에서 unusable 방식으로 전환 => 훨씬 단순하다....  20250220 */
//                    if("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type) ){
                    sql = SqlUtil.getSqlDropIndexCons(dbtype_target, index_owner, index_name, constraint_type, object_type, owner, table_name);
//                    } else {
//                        sql = SqlUtil.getSqlUnusableIndexCons(dbtype_target, index_owner, index_name, constraint_type, object_type, owner, table_name);
//                    }

                    LogUtil.log("INFO", "info$ getSqlUnusableIndexCons:" +object_type + " | " + constraint_type+ " | " + index_owner+"."+ index_name + ":sql=" + sql);
                    if (!StrUtil.checkString(sql)) {
                        //LogUtil.log("INFO", "info  getSqlUnusableIndexCons ####" + object_type + "===####" + index_owner + "===####" + index_name + ":" + sql);
                        try {
                            statement.executeUpdate(sql);
                        } catch (SQLException e) {
                            logger.warn("warn "+"Exception - getSqlUnusableIndexCons # : " + object_type + "===####" + index_owner + "===####" + index_name + ":" + sql + "=" + e.toString());
                        }
                    }
                }
                orderDdlSV.register(orderDdlVO);
                result.append(index_name + ", ");

            }

        } catch (Exception e) {
            e.printStackTrace();
            logger.warn("warn "+"Exception - Scramble INDEX DDL SAVE & Unusable: " + piiordersteptable.toString());
            logger.warn("warn "+"Exception - Scramble INDEX DDL SAVE & Unusable: " + e.getMessage());
            throw e;
        }
        return result.toString();
    }

    public String exeRecreateIndexCons(PiiOrderStepTableVO piiordersteptable, PiiDatabaseVO targetDBvo, AES256Util aes, int numScrambleThreads) throws Exception {
        /** 병렬처리 하다가 Tibero에서 에러가 나는 경우가 있어...일단 1 로  세팅함*/
        int numIndexThread = 1;//numScrambleThreads;
        StringBuilder result = new StringBuilder();
        if(numIndexThread>1) {
            ExecutorService executor = Executors.newFixedThreadPool(numIndexThread);
            LogUtil.log("INFO", "#### Scramble exeRecreateIndexCons ; numIndexThread;" + numIndexThread + "   piiordersteptable: " + piiordersteptable.toString());
            List<Future<?>> futures = new ArrayList<>();

            List<OrderDdlVO> orderDdlVOS = orderDdlSV.getList(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
            for (OrderDdlVO orderDdlVO : orderDdlVOS) {
                if ("OK".equals(orderDdlVO.getResult())) {
                    continue;
                }
                if (!"INDEX".equals(orderDdlVO.getObject_type())) {
                    continue;
                }
                String ddlSql = orderDdlVO.getDdl();

                LogUtil.log("INFO", "Index DDL START numIndexThread>1: " + orderDdlVO.toString());
                // 새로운 OrderDdlVO 객체 생성
                OrderDdlVO orderDdlVONew = new OrderDdlVO();
                // 현재 orderDdlVO의 필드 값을 복사하여 새로운 객체에 할당
                orderDdlVONew.setOrderid(orderDdlVO.getOrderid());
                orderDdlVONew.setStepid(orderDdlVO.getStepid());
                orderDdlVONew.setSeq1(orderDdlVO.getSeq1());
                orderDdlVONew.setSeq2(orderDdlVO.getSeq2());
                orderDdlVONew.setSeq3(orderDdlVO.getSeq3());
                orderDdlVONew.setDb(orderDdlVO.getDb());
                orderDdlVONew.setOwner(orderDdlVO.getOwner());
                orderDdlVONew.setTable_name(orderDdlVO.getTable_name());
                orderDdlVONew.setConstraint_type(orderDdlVO.getConstraint_type());
                orderDdlVONew.setObject_type(orderDdlVO.getObject_type());
                orderDdlVONew.setObject_owner(orderDdlVO.getObject_owner());
                orderDdlVONew.setObject_name(orderDdlVO.getObject_name());
                orderDdlVONew.setStatus(orderDdlVO.getStatus());
                orderDdlVONew.setResult(orderDdlVO.getResult());
                // orderDdlVONew.setDdl(orderDdlVO.getDdl());
                // ... 필요한 다른 필드들에 대해 복사

                // 나머지 로직은 orderDdlVONew 객체를 사용하도록 수정
                Future<?> future = executor.submit(() -> {
                    try (
                            Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                            Statement statement = connInsert.createStatement()
                    ) {
                        // DDL SQL 문 실행
                        statement.executeUpdate(ddlSql);
                        orderDdlVONew.setResult("OK");
                        orderDdlSV.modify(orderDdlVONew);
                        result.append(orderDdlVONew.getObject_name() + "(" + orderDdlVONew.getStatus() + "), ");
                        LogUtil.log("INFO", "INDEX DDL executed successfully: " + orderDdlVONew.getObject_type() + " " + orderDdlVONew.getObject_name());
                    } catch (Exception e) {
                        e.printStackTrace();
                        orderDdlVONew.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVONew);
                        LogUtil.log("INFO", "Exception  INDEX DDL failed : " + ddlSql, e);
                    }
                });
                futures.add(future);
            }

            // 작업 완료까지 대기
            executor.shutdown();
            // 모든 작업이 끝날 때까지 기다림
            for (Future<?> future : futures) {
                future.get(); // 각 작업이 끝날 때까지 대기
            }
            LogUtil.log("INFO", "CONSTRAINT START numIndexThread > : " + "All created");

            for (OrderDdlVO orderDdlVO : orderDdlVOS) {
                if ("OK".equalsIgnoreCase(orderDdlVO.getResult())) {
                    continue;
                }
                if (!"CONSTRAINT".equalsIgnoreCase(orderDdlVO.getObject_type())) {
                    continue;
                }
                LogUtil.log("INFO", "#####1### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + "   " + piiordersteptable.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name());
                /** Child table constraints 는...disabled 처리는 되나.나중에 일괄로 enable 해야해서 여기서는 제외함*/
                /** MIGRATE 은 소스 와 타겟 테이블이 다르다.*/
                String TargetTable = piiordersteptable.getTable_name();
                if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
                    //TargetOwner = piiordersteptable.getWhere_key_name();
                    TargetTable = piiordersteptable.getSqlstr();
                }
                if (!TargetTable.equalsIgnoreCase(orderDdlVO.getTable_name())) {
                    continue;
                }
                String ddlSql = orderDdlVO.getDdl();
                LogUtil.log("INFO", "#####2### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name()+ " = " + ddlSql);
                try (
                        Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                        Statement statement = connInsert.createStatement()
                ) {
                    // DDL SQL 문 실행
                    if (!StrUtil.checkString(ddlSql)) {
                        statement.executeUpdate(ddlSql);
                    } else {
                        ddlSql = "ALTER TABLE " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name();
                        statement.executeUpdate(ddlSql);
                    }
                    orderDdlVO.setResult("OK");
                    orderDdlSV.modify(orderDdlVO);
                    result.append(orderDdlVO.getObject_name() + "(" + orderDdlVO.getStatus() + "), ");
                    LogUtil.log("INFO", "CONSTRAINT DDL executed successfully: " + orderDdlVO.getObject_type() + " " + orderDdlVO.getObject_name() + " = " + ddlSql);
                } catch (Exception e) {
                    e.printStackTrace();
                    orderDdlVO.setResult("FAIL");
                    orderDdlSV.modify(orderDdlVO);
                    logger.warn("warn "+"예외 - 스크램블 인덱스 DDL 실행: " + ddlSql, e);
                }

            }
            LogUtil.log("WARN", "Index CONSTRAINT executed successfully: " + "All created");

        }
        else {
            String ddlSql = null;
            try (
                    Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                    Statement statement = connInsert.createStatement()
            ) {
                List<OrderDdlVO> orderDdlVOS = orderDdlSV.getList(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                for (OrderDdlVO orderDdlVO : orderDdlVOS) {
                    if ("OK".equals(orderDdlVO.getResult())) {
                        continue;
                    }
                    if (!"INDEX".equals(orderDdlVO.getObject_type())) {
                        continue;
                    }
                    ddlSql = orderDdlVO.getDdl()
                            .trim()
                            .replace("\"", "")   // 큰따옴표 제거
                            .replaceAll("\\s+", " ")
                            .replaceAll("[\\r\\n]+", " ");  // 개행 문자(\r, \n) 공백으로 치환
                    LogUtil.log("INFO", "exeRecreateIndexCons # start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " | " + orderDdlVO.getObject_name() + " | " + "Executing SQL: [" + ddlSql + "]");
                    try {
                        if (!StrUtil.checkString(ddlSql)) {
                            // 인덱스에 대해 PARALLEL로 생성 실행
                            statement.executeUpdate(ddlSql);
                            LogUtil.log("INFO", "exeRecreateIndexCons #  after ddlSql : " + ddlSql);
                            // 이후, 인덱스에 대해 PARALLEL을 NO로 변경하는 쿼리 실행
                            String noParallelSql = "ALTER INDEX " + orderDdlVO.getObject_owner() + "." + orderDdlVO.getObject_name() + " NOPARALLEL";
                            noParallelSql = noParallelSql
                                    .trim()
                                    .replace("\"", "")   // 큰따옴표 제거
                                    .replaceAll("\\s+", " ")
                                    .replaceAll("[\\r\\n]+", " ");  // 개행 문자(\r, \n) 공백으로 치환
                            LogUtil.log("INFO", "exeRecreateIndexCons #  before alterSql : " + noParallelSql);
                            statement.executeUpdate(noParallelSql);  // PARALLEL을 NO로 변경
                            LogUtil.log("INFO", "exeRecreateIndexCons #  after alterSql : " + noParallelSql);

                        } else {
                            ddlSql = "ALTER TABLE " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name();
                            statement.executeUpdate(ddlSql);
                        }
                        orderDdlVO.setResult("OK");
                        orderDdlSV.modify(orderDdlVO);
                        result.append(orderDdlVO.getObject_name() + ", ");
                        LogUtil.log("INFO", "INDEX DDL executed successfully: " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " Index " + orderDdlVO.getObject_name());
                    } catch (Exception e){
                        orderDdlVO.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVO);
                        logger.warn("WARN "+"Exception - Index DDL failed: "+ e.getMessage() +"  "+ orderDdlVO.toString());
                    }
                }
                for (OrderDdlVO orderDdlVO : orderDdlVOS) {
                    if ("OK".equals(orderDdlVO.getResult())) {
                        continue;
                    }
                    if (!"CONSTRAINT".equals(orderDdlVO.getObject_type())) {
                        continue;
                    }
                    /** Child table constraints 는...disabled 처리는 되나.나중에 일괄로 enable 해야해서 여기서는 제외함*/
                    String TargetTable = piiordersteptable.getTable_name();
                    if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
                        //TargetOwner = piiordersteptable.getWhere_key_name();
                        TargetTable = piiordersteptable.getSqlstr();
                    }
                    if (!TargetTable.equalsIgnoreCase(orderDdlVO.getTable_name())) {
                        continue;
                    }
                    ddlSql = orderDdlVO.getDdl()
                            .trim()
                            .replace("\"", "")   // 큰따옴표 제거
                            .replaceAll("\\s+", " ")
                            .replaceAll("[\\r\\n]+", " ");  // 개행 문자(\r, \n) 공백으로 치환
                    LogUtil.log("INFO", "#exeRecreateIndexCons# CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " " + orderDdlVO.getObject_name() + " ddlSql:" + ddlSql);
                    try {
                        // DDL SQL 문 실행
                        if (!StrUtil.checkString(ddlSql)) {
                            LogUtil.log("INFO", "#exeRecreateIndexCons# CONSTRAINT start 1 before: " + " ddlSql:" + ddlSql);
                            statement.executeUpdate(ddlSql);
                            LogUtil.log("INFO", "#exeRecreateIndexCons# CONSTRAINT start 1 after: " + " ddlSql:" + ddlSql);
                        } else {
                            ddlSql = "ALTER TABLE " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name();
                            LogUtil.log("INFO", "#exeRecreateIndexCons# CONSTRAINT start 2: " + " ddlSql:" + ddlSql);
                            statement.executeUpdate(ddlSql);
                        }
                        orderDdlVO.setResult("OK");
                        orderDdlSV.modify(orderDdlVO);
                        result.append(orderDdlVO.getObject_name() + ", ");
                        LogUtil.log("INFO", "$$$$ CONSTRAINT DDL executed successfully: " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " CONSTRAINT " + orderDdlVO.getObject_name());
                    } catch (Exception e){
                        orderDdlVO.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVO);
                        logger.warn("warn "+"%%%% Exception - CONSTRAINT DDL failed: " + e.getMessage() +"  ddlSql:"+  ddlSql);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                logger.warn("warn "+"Exception - Scramble Index DDL executed: " + e.getMessage() +"  "+  ddlSql);
                //throw e;
            }

        }


        return result.toString();
    }

    public String exeReBuildIndexCons(PiiOrderStepTableVO piiordersteptable, PiiDatabaseVO targetDBvo, AES256Util aes, int numScrambleThreads) throws Exception {
        /** 병렬처리 하다가 Tibero에서 에러가 나는 경우가 있어...일단 1 로  세팅함*/
        int numIndexThread = 1;//numScrambleThreads;
        StringBuilder result = new StringBuilder();
        if(numIndexThread>1) {
            ExecutorService executor = Executors.newFixedThreadPool(numIndexThread);
            LogUtil.log("INFO", "warn "+"#### exeReBuildIndexCons ; numIndexThread;" + numIndexThread + "   piiordersteptable: " + piiordersteptable.toString());
            List<Future<?>> futures = new ArrayList<>();

            List<OrderDdlVO> orderDdlVOS = orderDdlSV.getList(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
            LogUtil.log("INFO", "warn "+"#### exeReBuildIndexCons ; orderDdlVOS.size;" + orderDdlVOS.size());
            for (OrderDdlVO orderDdlVO : orderDdlVOS) {LogUtil.log("INFO", "warn "+"#### exeReBuildIndexCons $$$$$orderDdlVO ;" + orderDdlVO.toString());
                if ("OK".equals(orderDdlVO.getResult())) {
                    continue;
                }
                if (!"INDEX".equals(orderDdlVO.getObject_type())) {
                    continue;
                }
                //String ddlSql = orderDdlVO.getDdl();

                LogUtil.log("INFO", "Index DDL START numIndexThread>1: " + orderDdlVO.toString());
                // 새로운 OrderDdlVO 객체 생성
                OrderDdlVO orderDdlVONew = new OrderDdlVO();
                // 현재 orderDdlVO의 필드 값을 복사하여 새로운 객체에 할당
                orderDdlVONew.setOrderid(orderDdlVO.getOrderid());
                orderDdlVONew.setStepid(orderDdlVO.getStepid());
                orderDdlVONew.setSeq1(orderDdlVO.getSeq1());
                orderDdlVONew.setSeq2(orderDdlVO.getSeq2());
                orderDdlVONew.setSeq3(orderDdlVO.getSeq3());
                orderDdlVONew.setDb(orderDdlVO.getDb());
                orderDdlVONew.setOwner(orderDdlVO.getOwner());
                orderDdlVONew.setTable_name(orderDdlVO.getTable_name());
                orderDdlVONew.setConstraint_type(orderDdlVO.getConstraint_type());
                orderDdlVONew.setObject_type(orderDdlVO.getObject_type());
                orderDdlVONew.setObject_owner(orderDdlVO.getObject_owner());
                orderDdlVONew.setObject_name(orderDdlVO.getObject_name());
                orderDdlVONew.setStatus(orderDdlVO.getStatus());
                orderDdlVONew.setResult(orderDdlVO.getResult());
                // orderDdlVONew.setDdl(orderDdlVO.getDdl());
                // ... 필요한 다른 필드들에 대해 복사

                // 나머지 로직은 orderDdlVONew 객체를 사용하도록 수정
                Future<?> future = executor.submit(() -> {
                    try (
                            Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                            Statement statement = connInsert.createStatement()
                    ) {
                        /** drop create 에서 disable enable로 변경 20250220*/
                        String[] rebuildSqls = SqlUtil.getRebuildIndexSql(
                                targetDBvo.getDbtype(),
                                orderDdlVO.getOwner(),
                                orderDdlVO.getTable_name(),
                                orderDdlVO.getObject_owner(),
                                orderDdlVO.getObject_name(),
                                numScrambleThreads
                        );
                        LogUtil.log("INFO", "info "+"@@@ rebuildSqls: " + rebuildSqls);
                        // 반환된 모든 쿼리를 반복 실행
                        for (String sql : rebuildSqls) {
                            if (sql != null && !sql.trim().isEmpty()) {  // 쿼리 유효성 체크
                                try {
                                    LogUtil.log("INFO", "info ### rebuildSqls="+ sql );
                                    statement.executeUpdate(sql);
                                } catch (Exception index) {
                                    /** PK  인덱스는
                                     * PRIMARY KEY나 UNIQUE 제약 조건을 생성하면 인덱스가 자동으로 생성됩니다.
                                     * 제약 조건을 비활성화(ALTER TABLE ... DISABLE CONSTRAINT) 하면 해당 자동 생성 인덱스는 삭제됩니다.
                                     * 삭제된 인덱스는 REBUILD 불가하며, 제약 조건을 다시 활성화하면 인덱스가 새로 생성됩니다.
                                     * */
                                    logger.warn("warn "+"###FAIL---> rebuildSql: " + sql);
                                }
                            }
                        }
                        orderDdlVONew.setResult("OK");
                        orderDdlSV.modify(orderDdlVONew);
                        result.append(orderDdlVONew.getObject_name() + "(" + orderDdlVONew.getStatus() + "), ");
                        LogUtil.log("INFO", "인덱스 Rebuild 성공적으로 실행되었습니다: " + rebuildSqls);
                    } catch (Exception e) {
                        e.printStackTrace();
                        orderDdlVONew.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVONew);
                        LogUtil.log("INFO", "예외 - 스크램블 인덱스 Rebuild 실행: " + orderDdlVO.toString(), e);
                    }
                });
                futures.add(future);
            }

            // 작업 완료까지 대기
            executor.shutdown();
            // 모든 작업이 끝날 때까지 기다림
            for (Future<?> future : futures) {
                future.get(); // 각 작업이 끝날 때까지 대기
            }
            LogUtil.log("INFO", "CONSTRAINT START numIndexThread > : " + "All created");

            for (OrderDdlVO orderDdlVO : orderDdlVOS) {
                if ("OK".equalsIgnoreCase(orderDdlVO.getResult())) {
                    continue;
                }
                if (!"CONSTRAINT".equalsIgnoreCase(orderDdlVO.getObject_type())) {
                    continue;
                }
                LogUtil.log("INFO", "#####1### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + "   " + piiordersteptable.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name());
                /** Child table constraints 는...disabled 처리는 되나.나중에 일괄로 enable 해야해서 여기서는 제외함*/
                String TargetTable = piiordersteptable.getTable_name();
                if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
                    //TargetOwner = piiordersteptable.getWhere_key_name();
                    TargetTable = piiordersteptable.getSqlstr();
                }
                if (!TargetTable.equalsIgnoreCase(orderDdlVO.getTable_name())) {
                    continue;
                }
                LogUtil.log("INFO", "#####2### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name());
                String strEnable = null;
                try (
                        Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                        Statement statement = connInsert.createStatement()
                ) {
                    strEnable = SqlUtil.getEnableConstraintSql(targetDBvo.getDbtype(), orderDdlVO.getOwner(), orderDdlVO.getTable_name(), orderDdlVO.getObject_name());
                    logger.info("info "+"#####@@@### strEnable : " + strEnable);
                    statement.executeUpdate(strEnable);
                    orderDdlVO.setResult("OK");
                    orderDdlSV.modify(orderDdlVO);
                    result.append(orderDdlVO.getObject_name() + "(" + orderDdlVO.getStatus() + "), ");
                    logger.info("info "+"CONSTRAINT Enable 이 성공적으로 실행되었습니다: " + strEnable);
                } catch (Exception e) {
                    e.printStackTrace();
                    orderDdlVO.setResult("FAIL");
                    orderDdlSV.modify(orderDdlVO);
                    logger.warn("warn "+"예외 - CONSTRAINT Enable : " + strEnable, e);
                }

            }
            LogUtil.log("INFO", "Index CONSTRAINT executed successfully: " + "All created");

        }
        else {
            LogUtil.log("INFO", "warn "+"#### exeReBuildIndexCons ; numIndexThread;" + numIndexThread + "   piiordersteptable: " + piiordersteptable.toString());
            String[] rebuildSqls = null;
            String strEnableCons = null;
            try (
                    Connection connInsert = ConnectionProvider.getConnection(targetDBvo.getDbtype(), targetDBvo.getHostname(), targetDBvo.getPort(), targetDBvo.getId_type(), targetDBvo.getId(), targetDBvo.getDb(), targetDBvo.getDbuser(), aes.decrypt(targetDBvo.getPwd()));
                    Statement statement = connInsert.createStatement()
            ) {
                List<OrderDdlVO> orderDdlVOS = orderDdlSV.getList(piiordersteptable.getOrderid(), piiordersteptable.getStepid(), piiordersteptable.getSeq1(), piiordersteptable.getSeq2(), piiordersteptable.getSeq3());
                LogUtil.log("INFO", "warn " + "#### exeReBuildIndexCons ; orderDdlVOS.size: " + orderDdlVOS.size() +
                        ", orderid: " + piiordersteptable.getOrderid() +
                        ", stepid: " + piiordersteptable.getStepid() +
                        ", seq1: " + piiordersteptable.getSeq1() +
                        ", seq2: " + piiordersteptable.getSeq2() +
                        ", seq3: " + piiordersteptable.getSeq3());

                for (OrderDdlVO orderDdlVO : orderDdlVOS) {LogUtil.log("INFO", "warn "+"1. INDEX #### exeReBuildIndexCons $$$$$orderDdlVO ;" + orderDdlVO.toString());
                    if ("OK".equals(orderDdlVO.getResult())) {
                        continue;
                    }
                    if (!"INDEX".equals(orderDdlVO.getObject_type())) {
                        continue;
                    }
                    LogUtil.log("INFO", "warn "+" ########## INDEX start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " " + orderDdlVO.getObject_name());
                    try {
                        /** drop create 에서 disable enable로 변경 20250220*/
                        rebuildSqls = SqlUtil.getRebuildIndexSql(
                                targetDBvo.getDbtype(),
                                orderDdlVO.getOwner(),
                                orderDdlVO.getTable_name(),
                                orderDdlVO.getObject_owner(),
                                orderDdlVO.getObject_name(),
                                numScrambleThreads
                        );
                        LogUtil.log("INFO", "info #### : rebuildSqls="+ rebuildSqls.toString() );
                        // 반환된 모든 쿼리를 반복 실행
                        for (String sql : rebuildSqls) {
                            if (sql != null && !sql.trim().isEmpty()) {  // 쿼리 유효성 체크
                                try {
                                    LogUtil.log("INFO", "info  ### rebuildSqls="+ sql );
                                    statement.executeUpdate(sql);
                                    orderDdlVO.setResult("OK");
                                    orderDdlSV.modify(orderDdlVO);
                                    result.append(orderDdlVO.getObject_name() + ", ");
                                    LogUtil.log("INFO", "INDEX Rebuild executed successfully: " + sql);
                                } catch (Exception e){
                                    orderDdlVO.setResult("FAIL");
                                    orderDdlSV.modify(orderDdlVO);
                                    logger.warn("warn "+"Exception - Index Rebuild failed: "+ e.getMessage() +"  "+ sql);
                                }
                            }
                        }

                    } catch (Exception e){
                        orderDdlVO.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVO);
                        logger.warn("warn "+"Exception - Index Rebuild failed: "+ e.getMessage() +"  "+ rebuildSqls);
                    }
                }
                for (OrderDdlVO orderDdlVO : orderDdlVOS) {LogUtil.log("INFO", "warn "+"2. CONSTRAINT #### exeReBuildIndexCons $$$$$orderDdlVO ;" + orderDdlVO.toString());
                    if ("OK".equals(orderDdlVO.getResult())) {
                        continue;
                    }
                    if (!"CONSTRAINT".equals(orderDdlVO.getObject_type())) {
                        continue;
                    }
                    LogUtil.log("INFO", "info$ "+"#####1### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + "   " + piiordersteptable.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name());
                    /** Child table constraints 는...disabled 처리는 되나.나중에 일괄로 enable 해야해서 여기서는 제외함*/
                    String TargetTable = piiordersteptable.getTable_name();
                    if("MIGRATE".equalsIgnoreCase(piiordersteptable.getExetype())){
                        //TargetOwner = piiordersteptable.getWhere_key_name();
                        TargetTable = piiordersteptable.getSqlstr();
                    }
                    if (!TargetTable.equalsIgnoreCase(orderDdlVO.getTable_name())) {
                        continue;
                    }
                    LogUtil.log("INFO", "info$ "+"#####2### CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " ENABLE CONSTRAINT " + orderDdlVO.getObject_name());
                    LogUtil.log("INFO", "info$ "+"######## CONSTRAINT start : " + orderDdlVO.getOwner() + "." + orderDdlVO.getTable_name() + " " + orderDdlVO.getObject_name());

                    try {
                        /** drop create 에서 disable enable로 변경 20250220*/
                        strEnableCons = SqlUtil.getEnableConstraintSql(targetDBvo.getDbtype(), orderDdlVO.getOwner(), orderDdlVO.getTable_name(), orderDdlVO.getObject_name());
                        LogUtil.log("INFO", "info "+"#####@@@### strEnable : " + strEnableCons);
                        statement.executeUpdate(strEnableCons);

                        orderDdlVO.setResult("OK");
                        orderDdlSV.modify(orderDdlVO);
                        result.append(orderDdlVO.getObject_name() + ", ");
                        LogUtil.log("INFO", "info "+"@@@ CONSTRAINT Enable executed successfully: " + strEnableCons);
                    } catch (Exception e){
                        orderDdlVO.setResult("FAIL");
                        orderDdlSV.modify(orderDdlVO);
                        logger.warn("warn "+"%%%% Exception - CONSTRAINT enable로 failed: " + strEnableCons);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                logger.warn("warn "+"Exception - Scramble Index DDL executed: " + e.getMessage() +"  "+  strEnableCons);
                //throw e;
            }

        }
        return result.toString();
    }

    public boolean someErrorOccurs() {
        // 오류를 발생시킵니다.
        throw new RuntimeException("Some error occurred");
    }

}
	
	

