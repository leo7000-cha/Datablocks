package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.*;
import lombok.AllArgsConstructor;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor.HSSFColorPredefined;
import org.apache.poi.ss.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;


@Service
@AllArgsConstructor
public class PiiStepTableServiceImpl implements PiiStepTableService {
	private static final Logger logger = LoggerFactory.getLogger(PiiStepTableServiceImpl.class);
	@Autowired
	private PiiStepTableMapper mapper;
	@Autowired
	private PiiStepTableWaitMapper steptablewaitmapper;
	@Autowired
	private PiiStepTableUpdateMapper steptableupdatemapper;
	@Autowired
	private PiiStepMapper stepmapper;
	@Autowired
	private PiiTableMapper tableMapper;
	@Autowired
	private PiiStepTableUpdateMapper updatetableMapper;
	@Autowired
	private PiiUploadTemplateMapper uploadtemplatemapper;
	@Autowired
	private PiiConfigMapper configMapper;
	@Autowired
	private PiiDatabaseMapper databaseMapper;
	@Autowired
	private MetaTableMapper metaTableMapper;
	@Autowired
	private ArchiveNamingService archiveNamingService;

	@Override
	public List<PiiStepTableVO> getJobTableList(String jobid,String version) {
		
		LogUtil.log("INFO", "info$ "+"getJobTableList List: " );
		return mapper.getJobTableList(jobid,version);
	}
	
	@Override
	public List<PiiStepTableVO> getJobStepTableList(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "info$ "+"getJobStepTableList List: " );
		
		return mapper.getJobStepTableList(jobid, version, stepid);
	}
	@Override
	public List<PiiStepTableVO> getStepTableList(Criteria cri) {
		
		LogUtil.log("INFO", "info$ "+"getStepTableList List: " );
		
		return mapper.getStepTableList(cri);
	}
	@Override
	public List<PiiStepTableVO> getExeStepTableList(Criteria cri) {

		LogUtil.log("INFO", "info$ "+"getExeStepTableList List: " );

		return mapper.getExeStepTableList(cri);
	}
	
	@Override
	public List<PiiStepTableVO> getList() {
		
		LogUtil.log("INFO", "info$ "+"get List: " );
		
		return mapper.getList();
	}
	@Override
	public List<PiiStepTableVO> getArcStepTableList() {
		
		LogUtil.log("INFO", "info$ "+"getArcStepTableList : " );
		
		return mapper.getArcStepTableList();
	}
	
	@Override
	public List<PiiStepTableVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "info$ "+"get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiStepTableWithWaitVO> getListWithWait(Criteria cri) {
		
		LogUtil.log("INFO", "info$ "+"getListWithWait List with criteria: " + cri);
		
		return mapper.getListWithPagingWithWait(cri);
	}
	@Override
	public List<PiiConfKeymapRefVO> getList_Keymap(String jobid,String version){
		
		LogUtil.log("INFO", "info$ "+"get keymap_id List with jobid: " + jobid +" : "+version);
		
		return mapper.getList_Keymap(jobid, version);
	}
	@Override
	public void createArcTable(PiiStepTableVO piisteptable){
		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		LogUtil.log("INFO", "info$ "+"0 createArcTable...begin...:"+formatter.format(calendar.getTime())+"  " + piisteptable);
		boolean auto_mgmt_flag = true;
		try {
			if ("Y".equalsIgnoreCase( EnvConfig.getConfig("DLM_ARC_TAB_AUTO_MGMT_FLAG"))) {
				auto_mgmt_flag = true;
			}else{
				auto_mgmt_flag = false;
			}
		} catch (NullPointerException ex) {
			auto_mgmt_flag = false;
			logger.warn("warn "+"NullPointerException DLM_ORDER_FLAG="+ex.toString());
		}
		if(auto_mgmt_flag) {
			//New arc table creation
			if(piisteptable.getExetype().equalsIgnoreCase("DELETE")
					|| piisteptable.getExetype().equalsIgnoreCase("UPDATE")) {
				Criteria cri = new Criteria();
				cri.setSearch4(piisteptable.getDb());
				cri.setSearch5(piisteptable.getOwner());
				cri.setSearch6(piisteptable.getTable_name());
				// 동적 아카이브 owner 설정 (Config 기반 네이밍)
				try {
					PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
					String arcOwner = archiveNamingService.getArchiveSchemaName(
							ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDb(), piisteptable.getOwner());
					cri.setArchiveOwner(arcOwner);
				} catch (Exception ex) {
					logger.warn("warn: Failed to resolve archive owner for Criteria: " + ex.getMessage());
				}
				LogUtil.log("INFO", "info$ "+"call= "+"registerArcTab");
				//calendar = Calendar.getInstance();logger.warn("warn "+"1 createArcTable registerArcTab(piisteptable, cri) - begin" +formatter.format(calendar.getTime())+"  " );
				registerArcTab(piisteptable, cri);
				//calendar = Calendar.getInstance();logger.warn("warn "+"2 createArcTable registerArcTabCols(piisteptable, cri) - begin"+formatter.format(calendar.getTime())+"  " );
				registerArcTabCols(piisteptable, cri);
				//calendar = Calendar.getInstance();logger.warn("warn "+"3 createArcTable registerArcTabCols(piisteptable, cri) - end"+formatter.format(calendar.getTime())+"  " );
			}

		}
	}

	@Override
	@Transactional
	public String register(PiiStepTableVO piisteptable) {
		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		LogUtil.log("INFO", "info$ "+"register......"+formatter.format(calendar.getTime())+"  " + piisteptable);
		if(!"EXE_TRANSFORM".equalsIgnoreCase(piisteptable.getStepid()))
		if(getExistSameTableCnt(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name(), piisteptable.getExetype()) > 0){
			return "dup";
		}

		// create archive table if not exists
		String arcDdlWarning = null;
		try {
			LogUtil.log("INFO", "info$ "+"start = >create archive table if not exist......"+piisteptable);
			createArcTable(piisteptable);
			// registerArcTab에서 오류 발생 시 parallelcnt에 에러 정보 임시 저장됨
			if (piisteptable.getParallelcnt() != null && piisteptable.getParallelcnt().startsWith("ARC_DDL_ERROR:")) {
				arcDdlWarning = piisteptable.getParallelcnt();
				piisteptable.setParallelcnt(null); // 원래 값 복원
			}
		} catch (Exception e){
			arcDdlWarning = "ARC_DDL_ERROR:" + e.getMessage();
			logger.warn("warn: Exception creating archive table: " + e.getMessage() + " | " + piisteptable);
		}

		/** To avoid DB2 sql error for number format data updating if the data is '' */
		if(StrUtil.checkString(piisteptable.getParallelcnt())) {
			piisteptable.setParallelcnt(null);;
		}
		if(StrUtil.checkString(piisteptable.getCommitcnt())) {
			piisteptable.setCommitcnt(null);
		}
		if(StrUtil.checkString(piisteptable.getPipeline())) {
			piisteptable.setPipeline(null);
		}
		
    	/* Change data into Uppercase */
    	if(!StrUtil.checkString(piisteptable.getDb()))piisteptable.setDb(piisteptable.getDb().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getOwner()))piisteptable.setOwner(piisteptable.getOwner().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getTable_name()))piisteptable.setTable_name(piisteptable.getTable_name().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPagitype()))piisteptable.setPagitype(piisteptable.getPagitype().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPagitypedetail()))piisteptable.setPagitypedetail(piisteptable.getPagitypedetail().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getExetype()))piisteptable.setExetype(piisteptable.getExetype().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPk_col()))piisteptable.setPk_col(piisteptable.getPk_col().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getWhere_col()))piisteptable.setWhere_col(piisteptable.getWhere_col().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getWhere_key_name()))piisteptable.setWhere_key_name(piisteptable.getWhere_key_name().toUpperCase());
    	
    	if(!StrUtil.checkString(piisteptable.getKeymap_id()))piisteptable.setKeymap_id(piisteptable.getKeymap_id().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getKey_name()))piisteptable.setKey_name(piisteptable.getKey_name().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getKey_cols()))piisteptable.setKey_cols(piisteptable.getKey_cols().toUpperCase());
    	//piisteptable.setKey_refstr(piisteptable.getKey_refstr().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getSqltype()))piisteptable.setSqltype(piisteptable.getSqltype().toUpperCase());
    	
    	if(piisteptable.getExetype().equalsIgnoreCase("BROADCAST")) {
			StringBuilder sqlInsert = new StringBuilder();
	    	sqlInsert.append("insert into " +  piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- Target DB : "+piisteptable.getDb()+"\n");
			sqlInsert.append("select * from " + piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- "+"DB in Step "+"\n");
			if(!StrUtil.checkString(piisteptable.getWherestr())) {sqlInsert.append(" where " + piisteptable.getWherestr()); }
			piisteptable.setSqlstr(sqlInsert.toString());
    	}else if(piisteptable.getExetype().equalsIgnoreCase("HOMECAST")) {
			StringBuilder sqlInsert = new StringBuilder();
			sqlInsert.append("insert into " +  piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- "+"DB in Step"+"\n");
			sqlInsert.append("select * from " + piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- Sorce DB : "+piisteptable.getDb()+"\n");
			if(!StrUtil.checkString(piisteptable.getWherestr())) {sqlInsert.append(" where " + piisteptable.getWherestr()); }
			piisteptable.setSqlstr(sqlInsert.toString());
    	}
		LogUtil.log("WARN", "piisteptable=" + piisteptable.toString());
		mapper.insertSelectKey(piisteptable);

		//for synchronizing Archive table configuration
		int arctab = stepmapper.getCountWithSteptype(piisteptable.getJobid(), piisteptable.getVersion(), "EXE_ARCHIVE");
		if(arctab == 1 && (piisteptable.getExetype().equals("DELETE") || piisteptable.getExetype().equals("UPDATE"))) {
			String wherestr = "select #ORDERID AS PII_ORDER_ID, B.BASEDATE AS PII_BASE_DATE, B.CUSTID AS PII_CUST_ID,'"+piisteptable.getJobid()+"' AS PII_JOB_ID, B.EXPECTED_ARC_DEL_DATE AS PII_DESTRUCT_DATE , A.* FROM "
								+piisteptable.getOwner()+ "." +piisteptable.getTable_name()
								+ " A, COTDL.TBL_PIIKEYMAP B WHERE " + piisteptable.getWherestr();
			String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
			String sqlstr	= "insert into " + archiveTablePath + " "
								+ wherestr;
			piisteptable.setStepid("EXE_ARCHIVE");
			piisteptable.setExetype("ARCHIVE");
			//piisteptable.setParallelcnt(null);
			//piisteptable.setCommitcnt(null);
			piisteptable.setWherestr(wherestr);
			piisteptable.setSqlstr(sqlstr);
			mapper.insertSelectKey(piisteptable);

		}
		// 아카이브 DDL 오류가 있었으면 경고 메시지 포함하여 리턴 (등록은 완료됨)
		if (arcDdlWarning != null) {
			return "arc_ddl_warn:" + arcDdlWarning;
		}
		return "success";

	}
	@Override
	@Transactional
	public String registerEntireToScramble(String jobid, String version, String stepid) {

		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		LogUtil.log("INFO", "info$ "+"registerEntireToScramble......"+formatter.format(calendar.getTime())+"  " + jobid+"  " + version+"  " + stepid);

		List<PiiStepTableTargetVO> stepTableTargetVOList = metaTableMapper.getListEntireTableToScramble(jobid, version, stepid);
		LogUtil.log("WARN", " stepTableTargetVOList.size() = "+stepTableTargetVOList.size());
		if(stepTableTargetVOList.size() == 0) {
			return "No scramble target table to add";
		}
		PiiStepTableVO piisteptable = new PiiStepTableVO();
		piisteptable.setJobid(jobid);
		piisteptable.setVersion(version);
		piisteptable.setStepid(stepid);
		piisteptable.setExetype("SCRAMBLE");
//		piisteptable.setDb();
//		piisteptable.setOwner();
//		piisteptable.setTable_name();
		piisteptable.setSeq1(10);
//		piisteptable.setSeq2(1);
		piisteptable.setSeq3(10);
		piisteptable.setWherestr("1=1");

		int succssCnt = 0;
		int failCnt = 0;
		StringBuilder errorTabs = new StringBuilder();

		PiiStepTableTargetVO stepTableTargetVO = null;
		int tmpint = 10;
		for(int p = 0; p < stepTableTargetVOList.size(); p++) {
			stepTableTargetVO = stepTableTargetVOList.get(p);
			LogUtil.log("INFO", "info$ "+stepTableTargetVO.toString()+"  && "+tmpint);
			List<PiiTableVO> piitablelist = tableMapper.getListExact(stepTableTargetVO.getDb(), stepTableTargetVO.getOwner(),stepTableTargetVO.getTable_name() );

			piisteptable.setPk_col(null);
			for (PiiTableVO piitable : piitablelist) {
				if (("Y").equalsIgnoreCase(piitable.getPk_yn())) {
					piisteptable.setPk_col(piitable.getColumn_name());
					succssCnt++;
					break;
				}
			}
			if(StrUtil.checkString(piisteptable.getPk_col())){
				errorTabs.append(stepTableTargetVO.getTable_name()+",");
				failCnt++;
				continue;
			}else {
				piisteptable.setDb(stepTableTargetVO.getDb());
				piisteptable.setOwner(stepTableTargetVO.getOwner());
				piisteptable.setTable_name(stepTableTargetVO.getTable_name());
				piisteptable.setSeq2(stepTableTargetVO.getSeq2()+tmpint);
				tmpint = tmpint+10;
				mapper.insertSelectKey(piisteptable);
			}

		}
		// Remove the last comma from errorTabs
		String errorTabsString = errorTabs.toString();
		if (errorTabsString.endsWith(",")) {
			errorTabsString = errorTabsString.substring(0, errorTabsString.length() - 1);
		}
		return "Total : " + stepTableTargetVOList.size() +
				" Success : " + succssCnt +
				"\n fail : " + failCnt +
				"\n(" + errorTabsString + ")";


	}

	@Override
	@Transactional
	public List<PiiStepTableTargetVO> getListEntireToScramble(String jobid, String version, String stepid) {

		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		LogUtil.log("INFO", "info$ "+"registerEntireToScramble......"+formatter.format(calendar.getTime())+"  " + jobid+"  " + version+"  " + stepid);

		List<PiiStepTableTargetVO> stepTableTargetVOList = metaTableMapper.getListEntireTableToScramble(jobid, version, stepid);

		return stepTableTargetVOList;
	}
	@Override
	@Transactional
	public String remove(PiiStepTableVO piisteptable) {
		
		LogUtil.log("INFO", "info$ "+"remove...." + piisteptable);

		/* To avoid DB2 sql error for number format data updating if the data is '' */
    	if(StrUtil.checkString(piisteptable.getParallelcnt())) {
    		piisteptable.setParallelcnt(null);;
		}
    	if(StrUtil.checkString(piisteptable.getCommitcnt())) {
    		piisteptable.setCommitcnt(null);
    	}
    	if(StrUtil.checkString(piisteptable.getPipeline())) {
    		piisteptable.setPipeline(null);
    	}
		
    	try {
	    	steptableupdatemapper.deletebyseq(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
			steptablewaitmapper.deletebytable(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
			mapper.deleteBySeq(piisteptable);
    	}catch (Exception e) {
    		logger.warn("warn "+"Del/Upd step table "+e.getMessage());
    		return "Fail to remove the Del/Upd step table";
    	}
		
		//for synchronizing Archive table configuration
		int arctab = getWithSeqExetype(piisteptable.getJobid(), piisteptable.getVersion(), "ARCHIVE", piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
		if(arctab == 1 && (piisteptable.getExetype().equals("DELETE") || piisteptable.getExetype().equals("UPDATE"))) {
			piisteptable.setStepid("EXE_ARCHIVE");
	    	try {
		    	steptableupdatemapper.deletebyseq(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
				steptablewaitmapper.deletebytable(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
				mapper.deleteBySeq(piisteptable);
	    	}catch (Exception e) {
	    		logger.warn("warn "+"EXE_ARCHIVE "+e.getMessage());
	    		return "Fail to remove Archive step table";
	    	}
		}
		
		return "success";
		
	}
	
	@Override
	@Transactional
	public void removeStepTable(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "info$ "+"removeStepTable...." + stepid);
		steptableupdatemapper.deletebystepid(jobid, version, stepid);
		steptablewaitmapper.deletebystepid(jobid, version, stepid);
		mapper.deleteStepTable(jobid, version, stepid);
		
		//for synchronizing Archive table configuration
		String steptype = stepmapper.read(jobid, version, stepid).getSteptype();
		stepmapper.getCountWithSteptype(jobid, version, stepid);
		int arctab = stepmapper.getCountWithSteptype(jobid, version, "EXE_ARCHIVE");
		if(arctab == 1 && (steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE"))) {
			mapper.deleteStepTable(jobid, version, "EXE_ARCHIVE");
		}
	}
	@Override
	@Transactional
	public void removeJobTable(String jobid, String version) {
		
		LogUtil.log("INFO", "info$ "+"removeJobTable...." + jobid);
		steptableupdatemapper.deletebyjobid(jobid, version);
		steptablewaitmapper.deletebyjobid(jobid, version);
		mapper.deleteJobTable(jobid, version);
	}

	@Override
	public int getTotalDistinctTabCount() {
		
		LogUtil.log("INFO", "info$ "+"getTotalDistinctTabCount total count");
		return mapper.getTotalDistinctTabCount();
	}
	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "info$ "+"get total count");
		return mapper.getTotalCount(cri);
	}
	@Override
	public int getTotalCountExeStepTable(Criteria cri) {

		LogUtil.log("INFO", "info$ "+"getTotalCountExeStepTable");
		return mapper.getTotalCountExeStepTable(cri);
	}
	@Override
	public int getTotalTabCnt(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "info$ "+"get total count");
		return mapper.getTotalTabCnt(jobid, version, stepid);
	}
	@Override
	public int getExistSameTableCnt(String jobid, String version,String db,String owner,String table_name, String exetype) {

		LogUtil.log("INFO", "info$ "+"getExistSameTableCnt");
		return mapper.getExistSameTableCnt(jobid, version, db, owner, table_name, exetype);
	}
	@Override
	public PiiStepMaxSeqVO getStepMaxseq(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "info$ "+"getStepMaxseq");
		return mapper.getStepMaxseq(jobid, version, stepid);
	}

	@Override
	public List<PiiStepTableCntVO> getTotalTabCntWithExetype() {
		
		LogUtil.log("INFO", "info$ "+"get total count");
		return mapper.getTotalTabCntWithExetype();
	}

	@Override
	public List<PiiTableConfigStatusVO> getTableConfigStatus() {
		
		LogUtil.log("INFO", "info$ "+"getTableConfigStatus-dashboard");
		return mapper.getTableConfigStatus();
	}
	
	@Override
	public PiiStepTableVO get(String jobid,String version ,String stepid, String db, String owner, String table_name) {
		
		 LogUtil.log("INFO", "info$ "+"get......" + stepid+" "+table_name);
		 
		 return mapper.read(jobid, version, stepid, db, owner, table_name);
	}

	@Override
	public PiiStepTableVO getEtc(String jobid, String stepid) {

		LogUtil.log("INFO", "info$ "+"getEtc......" + jobid+"  "+stepid);
		return mapper.readEtc(jobid, stepid );
	}
	@Override
	public int getEtcCnt(String jobid, String stepid) {

		LogUtil.log("INFO", "info$ "+"getEtcCnt......" + jobid+"  "+stepid);
		return mapper.readEtcCnt(jobid, stepid );
	}
	@Override
	public PiiStepTableVO getWithSeq(String jobid,String version ,String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "info$ "+"get......" +stepid+" "+ seq1 +" "+ seq2 +" "+ seq3 +" ");
		
		return mapper.readWithSeq(jobid, version, stepid, seq1, seq2, seq3);
	}
	
	public int getWithSeqExetype(String jobid,String version ,String exetype, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "info$ "+"get......" +exetype+" "+ seq1 +" "+ seq2 +" "+ seq3 +" ");
		
		return mapper.readWithSeqExetype(jobid, version, exetype, seq1, seq2, seq3);
	}

	@Override
	@Transactional
	public String modify(PiiStepTablePkNewVO piisteptable) {
		try {
			LogUtil.log("INFO", "modify......" + piisteptable.getSeq2()+"-"+piisteptable.getSeq2_new()+"-"+mapper.readWithSeqExetype(piisteptable.getJobid(), piisteptable.getVersion() ,piisteptable.getExetype(), piisteptable.getSeq1(), piisteptable.getSeq2_new(), piisteptable.getSeq3()));
		if (piisteptable.getSeq2() != piisteptable.getSeq2_new() &&
				mapper.readWithSeqExetype(piisteptable.getJobid(), piisteptable.getVersion() ,piisteptable.getExetype(), piisteptable.getSeq1(), piisteptable.getSeq2_new(), piisteptable.getSeq3()) > 0) {
			logger.error("modify method encountered an error: " + "The specified SEQ already exists");
			throw new RuntimeException("The specified SEQ already exists");
		}

		/* To avoid DB2 sql error for number format data updating if the data is '' */
    	if(StrUtil.checkString(piisteptable.getParallelcnt())) {
    		piisteptable.setParallelcnt(null);;
		}
    	if(StrUtil.checkString(piisteptable.getCommitcnt())) {
    		piisteptable.setCommitcnt(null);
    	}
    	if(StrUtil.checkString(piisteptable.getPipeline())) {
    		piisteptable.setPipeline(null);
    	}
		
    	/* Change data into Uppercase */
    	if(!StrUtil.checkString(piisteptable.getDb()))piisteptable.setDb(piisteptable.getDb().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getOwner()))piisteptable.setOwner(piisteptable.getOwner().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getTable_name()))piisteptable.setTable_name(piisteptable.getTable_name().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPagitype()))piisteptable.setPagitype(piisteptable.getPagitype().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPagitypedetail()))piisteptable.setPagitypedetail(piisteptable.getPagitypedetail().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getExetype()))piisteptable.setExetype(piisteptable.getExetype().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getPk_col()))piisteptable.setPk_col(piisteptable.getPk_col().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getWhere_col()))piisteptable.setWhere_col(piisteptable.getWhere_col().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getWhere_key_name()))piisteptable.setWhere_key_name(piisteptable.getWhere_key_name().toUpperCase());
    	
    	if(!StrUtil.checkString(piisteptable.getKeymap_id()))piisteptable.setKeymap_id(piisteptable.getKeymap_id().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getKey_name()))piisteptable.setKey_name(piisteptable.getKey_name().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getKey_cols()))piisteptable.setKey_cols(piisteptable.getKey_cols().toUpperCase());
    	//piisteptable.setKey_refstr(piisteptable.getKey_refstr().toUpperCase());
    	if(!StrUtil.checkString(piisteptable.getSqltype()))piisteptable.setSqltype(piisteptable.getSqltype().toUpperCase());

    	if(piisteptable.getExetype().equalsIgnoreCase("BROADCAST")) {
			StringBuilder sqlInsert = new StringBuilder();
	    	sqlInsert.append("insert into " +  piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- Target DB : "+piisteptable.getDb()+"\n");
			sqlInsert.append("select * from " + piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- "+"DB in Step"+"\n");
			if(!StrUtil.checkString(piisteptable.getWherestr())) {sqlInsert.append(" where " + piisteptable.getWherestr()); }
			piisteptable.setSqlstr(sqlInsert.toString());
    	}else if(piisteptable.getExetype().equalsIgnoreCase("HOMECAST")) {
			StringBuilder sqlInsert = new StringBuilder();
			sqlInsert.append("insert into " +  piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- "+"DB in Step"+"\n");
			sqlInsert.append("select * from " + piisteptable.getOwner() +"."+ piisteptable.getTable_name() + " -- Sorce DB : "+piisteptable.getDb()+"\n");
			if(!StrUtil.checkString(piisteptable.getWherestr())) {sqlInsert.append(" where " + piisteptable.getWherestr()); }
			piisteptable.setSqlstr(sqlInsert.toString());
    	}
    	
		if (mapper.update(piisteptable) != 1) {
			logger.error("modify method encountered an error: " + "Fail to modify Del/Upd table configuration");
			throw new RuntimeException("Fail to modify Del/Upd table configuration");
		}
		
		/* for synchronizing Archive table configuration */
		int arctab = getWithSeqExetype(piisteptable.getJobid(), piisteptable.getVersion(), "ARCHIVE", piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
		if(arctab == 1 && (piisteptable.getExetype().equals("DELETE") || piisteptable.getExetype().equals("UPDATE"))) {
			String wherestr = "select #ORDERID AS PII_ORDER_ID, B.BASEDATE AS PII_BASE_DATE, B.CUSTID AS PII_CUST_ID,'"+piisteptable.getJobid()+"' AS PII_JOB_ID, B.EXPECTED_ARC_DEL_DATE AS PII_DESTRUCT_DATE , A.* FROM "
								+piisteptable.getOwner()+ "." +piisteptable.getTable_name()
								+ " A, COTDL.TBL_PIIKEYMAP B WHERE " + piisteptable.getWherestr();
			String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
			String sqlstr	= "insert into " + archiveTablePath + " "
								+ wherestr;
			piisteptable.setStepid("EXE_ARCHIVE");
			piisteptable.setExetype("ARCHIVE");
			piisteptable.setWherestr(wherestr);
			piisteptable.setSqlstr(sqlstr);
			
			if (!modifyArchiveFromDel(piisteptable)) {
				logger.error("modify method encountered an error: " + "Fail to modify Archive table configuration");
				throw new RuntimeException("Fail to modify Archive table configuration");
			}
		}
		
		return "success";
		} catch (Exception e) {
			// 예외가 발생한 경우
			// 예외 처리 후 적절한 메시지를 반환
			logger.error("modify method encountered an error: " + e.getMessage());
			throw new RuntimeException(e.getMessage());
		}
		
	}

	@Override
	@Transactional
	public boolean modifyArchiveFromDel(PiiStepTablePkNewVO piisteptable) {
		
		LogUtil.log("INFO", "info$ "+"modify......" + piisteptable);
		
		/* To avoid DB2 sql error for number format data updating if the data is '' */
    	if(StrUtil.checkString(piisteptable.getParallelcnt())) {
    		piisteptable.setParallelcnt(null);;
		}
    	if(StrUtil.checkString(piisteptable.getCommitcnt())) {
    		piisteptable.setCommitcnt(null);
    	}
    	if(StrUtil.checkString(piisteptable.getPipeline())) {
    		piisteptable.setPipeline(null);
    	}
		return mapper.updateArchiveFromDel(piisteptable) == 1;
	}
	
	@Override
	@Transactional
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "info$ "+"get......" + jobid+"-"+version);
		
		mapper.checkout(jobid, version);
	}

    @Override
	@Transactional
    public String uploadExcelSteptable(MultipartFile[] uploadFile, String jobid, String version, String stepid, String userid) {
    		
		String rst = "successfully uploaded";
		List<PiiAttachFileDTO> list = new ArrayList<>();
		List<PiiStepTableVO> datalist = new ArrayList<>();
		String uploadFolder = "C:\\upload";

		int dupcnt = 0;
		int registercnt = 0;
		int uploadedcnt = 0;
		// make folder --------
		File uploadPath = new File(uploadFolder, uploadFolder);

		if (uploadPath.exists() == false) {
			uploadPath.mkdirs();
		}
		// make yyyy/MM/dd folder

		for (MultipartFile multipartFile : uploadFile) {

			PiiAttachFileDTO attachDTO = new PiiAttachFileDTO();

			String uploadFileName = multipartFile.getOriginalFilename();

			// IE has file path
			uploadFileName = uploadFileName.substring(uploadFileName.lastIndexOf("\\") + 1);
			LogUtil.log("INFO", "info$ "+"only file name: " + uploadFileName);
			attachDTO.setFileName(uploadFileName);

			UUID uuid = UUID.randomUUID();

			uploadFileName = uuid.toString() + "_" + uploadFileName;

			try {
//        				File saveFile = new File(uploadPath, uploadFileName);
//        				multipartFile.transferTo(saveFile);
				attachDTO.setUuid(uuid.toString());
				attachDTO.setUploadPath(uploadFolder);

//        				// add to List         
				list.add(attachDTO);
				
				Workbook wb = excelUtil.getWorkbook(multipartFile);

			    Sheet worksheet = wb.getSheetAt(0);
			    String exetype = excelUtil.getValue(worksheet.getRow(0).getCell(0));
			    int startline = 3;
				uploadedcnt = worksheet.getPhysicalNumberOfRows()-startline+1;
			    String steptype = stepmapper.read(jobid, version, stepid).getSteptype();
			    LogUtil.log("info", "info$ "+exetype+"  startline:"+startline+"  steptype:"+steptype+"  datarow:"+(worksheet.getPhysicalNumberOfRows()-startline+1));
			    //rst = (worksheet.getPhysicalNumberOfRows()-startline+1) + " rows - successfully uploaded";
			    /** Validation */
			    for (int i = startline-1; i < worksheet.getPhysicalNumberOfRows(); i++) { // from 11st line 
					Row row = worksheet.getRow(i);

					if(steptype.equalsIgnoreCase("EXE_KEYMAP")) {
						if(0 == tableMapper.getTableCnt(excelUtil.getValue(row.getCell(9)), excelUtil.getValue(row.getCell(10)) ,excelUtil.getValue(row.getCell(11)))) {
							return "line:" +(i+1)+ " The table does not exist in the Catalog info => "+excelUtil.getValue(row.getCell(10)) +" "+ excelUtil.getValue(row.getCell(11)) +" "+ excelUtil.getValue(row.getCell(12));
						}
				    }else if(!steptype.equalsIgnoreCase("EXE_EXTRACT")){
						if(0 == tableMapper.getTableCnt(excelUtil.getValue(row.getCell(3)), excelUtil.getValue(row.getCell(4)) ,excelUtil.getValue(row.getCell(5)))) {
							return "line:" +(i+1)+ " The table does not exist in the Catalog info => "+excelUtil.getValue(row.getCell(3)) +" "+ excelUtil.getValue(row.getCell(4)) +" "+ excelUtil.getValue(row.getCell(5));
						}
				    }
					if(!jobid.equalsIgnoreCase(excelUtil.getValue(row.getCell(0)))) {
						return "line:" +(i+1)+ " Jobid is not the same as "+jobid+" => "+excelUtil.getValue(row.getCell(0));
						//throw new UploadFileValidateException("line:" +(i+1)+ " Jobid is not the same as "+jobid+" => "+excelUtil.getValue(row.getCell(0)));
					}
					if(!version.equalsIgnoreCase(excelUtil.getValue(row.getCell(1)))){
						return "line:" +(i+1)+ " Version is not the same as "+version+" => "+excelUtil.getValue(row.getCell(1));
						//throw new UploadFileValidateException("line:" +(i+1)+ " Version is not the same as "+version+" => "+excelUtil.getValue(row.getCell(1)));
					}
					if(!stepid.equalsIgnoreCase(excelUtil.getValue(row.getCell(2)))){
						return "line:" +(i+1)+ " Stepid is not the same as "+stepid+" => "+excelUtil.getValue(row.getCell(2));
						//throw new UploadFileValidateException("line:" +(i+1)+ " Stepid is not the same as "+stepid+" => "+excelUtil.getValue(row.getCell(2)));
					}
					if(!exetype.equalsIgnoreCase(excelUtil.getValue(row.getCell(6)))){
						return "line:" +(i+1)+ " EXETYPE is not the same as "+exetype+" => "+excelUtil.getValue(row.getCell(6));
						//throw new UploadFileValidateException("line:" +(i+1)+ "  EXETYPE is not the same as "+exetype+" => "+excelUtil.getValue(row.getCell(6)));
					}

					if(steptype.equalsIgnoreCase("EXE_UPDATE"))
					{
						if(StrUtil.checkString(excelUtil.getValue(row.getCell(13)))) {
							return "line:" +(i+1)+ " Update cols must be defined "+" => "+excelUtil.getValue(row.getCell(13));
							//throw new UploadFileValidateException("line:" +(i+1)+ " Update cols must be defined "+" => "+excelUtil.getValue(row.getCell(15)));
						}
					}
					if(steptype.equalsIgnoreCase("EXE_DELETE")) {
						if(!StrUtil.checkString(excelUtil.getValue(row.getCell(13))) && StrUtil.checkString(excelUtil.getValue(row.getCell(14)))) {
							return "line:" +(i+1)+ " Wait Table must be defined "+" => "+excelUtil.getValue(row.getCell(13))+"."+excelUtil.getValue(row.getCell(14));
						}
						if(StrUtil.checkString(excelUtil.getValue(row.getCell(13))) && !StrUtil.checkString(excelUtil.getValue(row.getCell(14)))) {
							return "line:" +(i+1)+ " Wait Table must be defined "+" => "+excelUtil.getValue(row.getCell(13))+"."+excelUtil.getValue(row.getCell(14));
						}
					}
					if(steptype.equalsIgnoreCase("EXE_SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN"))
					{
						if(StrUtil.checkString(excelUtil.getValue(row.getCell(7)))) {
							return "line:" +(i+1)+ " SEQ must be defined "+" => "+excelUtil.getValue(row.getCell(7));
						}
					}

					if(steptype.equalsIgnoreCase("EXE_MIGRATE") || (steptype.equalsIgnoreCase("EXE_SCRAMBLE") && !jobid.startsWith("TESTDATA_AUTO_GEN")))
					{
						if(StrUtil.checkString(excelUtil.getValue(row.getCell(12)))) {
							return "line:" +(i+1)+ " WHERESTR must be defined "+" => "+excelUtil.getValue(row.getCell(12));
						}
					}
			    }

			    //Delete all rows of the tables in requested Job's step
			    removeStepTable(jobid, version, stepid);
				//steptableupdatemapper.deletebystepid(jobid, version, stepid);
				//steptablewaitmapper.deletebystepid(jobid, version, stepid);
				//mapper.deleteStepTable(jobid, version, stepid);
				LogUtil.log("info", "info$ "+"row     " + worksheet.getPhysicalNumberOfRows() + "  startline:" + startline+";");

				for (int i = startline-1; i < worksheet.getPhysicalNumberOfRows(); i++) { // from 11st line
					//LogUtil.log("WARN", "info$ "+"row "+i+"  [  "+worksheet.getPhysicalNumberOfRows());
					Row row = worksheet.getRow(i);
					PiiStepTableVO piisteptable = new PiiStepTableVO();
					piisteptable.setJobid(jobid);
					piisteptable.setVersion(version);
					piisteptable.setStepid(stepid);
				    if(steptype.equalsIgnoreCase("EXE_KEYMAP")) {
				    	piisteptable.setDb(excelUtil.getValue(row.getCell(10)));
						piisteptable.setOwner(excelUtil.getValue(row.getCell(11)));
						piisteptable.setTable_name(excelUtil.getValue(row.getCell(12)));
						piisteptable.setPagitype(null);
						piisteptable.setPagitypedetail(null);
						piisteptable.setExetype("KEYMAP");
						piisteptable.setArchiveflag(null);
						piisteptable.setStatus(null);
						piisteptable.setPreceding(null);
						piisteptable.setSuccedding(null);
						piisteptable.setSeq1(10);//piisteptable.setSeq1(excelUtil.getValueInt(row.getCell(6)));
						piisteptable.setSeq2(excelUtil.getValueInt(row.getCell(6)));
						piisteptable.setSeq3(10);//piisteptable.setSeq3(excelUtil.getValueInt(row.getCell(8)));
				    }else if(steptype.equalsIgnoreCase("EXE_EXTRACT")) {
						piisteptable.setDb(excelUtil.getValue(row.getCell(3)));
						piisteptable.setOwner("COTDL");
						piisteptable.setTable_name("TBL_PIIEXTRACT");
						piisteptable.setPagitype(null);
						piisteptable.setPagitypedetail(excelUtil.getValue(row.getCell(4)));
						piisteptable.setPk_col(excelUtil.getValue(row.getCell(5)));
						piisteptable.setExetype(excelUtil.getValue(row.getCell(6)));
						piisteptable.setArchiveflag(null);
						piisteptable.setStatus(null);
						piisteptable.setPreceding(null);
						piisteptable.setSuccedding(null);
						piisteptable.setSeq1(10);
						piisteptable.setSeq2(excelUtil.getValueInt(row.getCell(7)));
						piisteptable.setSeq3(10);
						piisteptable.setSqlstr(excelUtil.getValue(row.getCell(8)));
			    	}else{
						piisteptable.setDb(excelUtil.getValue(row.getCell(3)));
						piisteptable.setOwner(excelUtil.getValue(row.getCell(4)));
						piisteptable.setTable_name(excelUtil.getValue(row.getCell(5)));
						piisteptable.setPagitype(null);
						piisteptable.setPagitypedetail(null);
						piisteptable.setExetype(excelUtil.getValue(row.getCell(6)));
						piisteptable.setArchiveflag(null);
						piisteptable.setStatus(null);
						piisteptable.setPreceding(null);
						piisteptable.setSuccedding(null);
						piisteptable.setSeq1(10);//piisteptable.setSeq1(excelUtil.getValueInt(row.getCell(7)));
						piisteptable.setSeq2(excelUtil.getValueInt(row.getCell(7)));
						piisteptable.setSeq3(10);//piisteptable.setSeq1(excelUtil.getValueInt(row.getCell(9)));
				    }
					piisteptable.setPipeline(null);
					if(steptype.equalsIgnoreCase("EXE_DELETE") || steptype.equalsIgnoreCase("EXE_UPDATE") ) {
						piisteptable.setPk_col(excelUtil.getValue(row.getCell(8)));
						piisteptable.setWhere_col(excelUtil.getValue(row.getCell(9)));
						piisteptable.setWhere_key_name(excelUtil.getValue(row.getCell(10)));
						piisteptable.setParallelcnt(excelUtil.getValue(row.getCell(11)));
						piisteptable.setCommitcnt(excelUtil.getValue(row.getCell(12)));
					}
					if(steptype.equalsIgnoreCase("EXE_SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN") ) {
						logger.warn("@@@@@@@@@@---1-"+excelUtil.getValue(row.getCell(8))+"  "+jobid +"  "+steptype );
						piisteptable.setPk_col(excelUtil.getValue(row.getCell(8)));
						piisteptable.setWhere_col(excelUtil.getValue(row.getCell(9)));
						piisteptable.setWhere_key_name(excelUtil.getValue(row.getCell(10)));

					}else if(steptype.equalsIgnoreCase("EXE_MIGRATE") || (steptype.equalsIgnoreCase("EXE_SCRAMBLE") && !jobid.startsWith("TESTDATA_AUTO_GEN"))){
						// 엑셀 → 객체 매핑 (셀 인덱스 8~13 기준)
						piisteptable.setPk_col(excelUtil.getValue(row.getCell(8)));          // 셀 8: pk_col
						piisteptable.setPipeline(excelUtil.getValue(row.getCell(9)));        // 셀 9: pipeline
						piisteptable.setPreceding(excelUtil.getValue(row.getCell(10)));      // 셀 10: preceding
						piisteptable.setPagitypedetail(excelUtil.getValue(row.getCell(11))); // 셀 11: pagitypedetail
						piisteptable.setWherestr(excelUtil.getValue(row.getCell(12)));       // 셀 12: wherestr
						piisteptable.setHintselect(excelUtil.getValue(row.getCell(13)));     // 셀 13: hintselect

					}
					//20230125 고유영구파기 기한 추가
					if(steptype.equalsIgnoreCase("EXE_DELETE") ) {
						piisteptable.setPagitypedetail(excelUtil.getValue(row.getCell(15)));
					}
					if(steptype.equalsIgnoreCase("EXE_UPDATE") ) {
						piisteptable.setPagitypedetail(excelUtil.getValue(row.getCell(14)));
					}

					if(steptype.equalsIgnoreCase("EXE_FINISH") || steptype.equalsIgnoreCase("EXE_ETC")) {
						piisteptable.setSqlstr(excelUtil.getValue(row.getCell(8)));
					}
					if(steptype.equalsIgnoreCase("EXE_BROADCAST")) {
						piisteptable.setWherestr(excelUtil.getValue(row.getCell(8)));
						piisteptable.setSqlstr("INSERT INTO "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+"\r\n"
								+ "SELECT * FROM "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+"\r\n"
								+ excelUtil.getValue(row.getCell(8))
								);
					}
					piisteptable.setKeymap_id(null);
					piisteptable.setKey_name(null);
					piisteptable.setKey_cols(null);
					piisteptable.setKey_refstr(null);
					piisteptable.setSqltype(null);
					piisteptable.setRegdate(null);
					piisteptable.setUpddate(null);
					piisteptable.setReguserid(userid);
					piisteptable.setUpduserid(userid);

					if(steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE")) {
						/* PK information */
						List<PiiTableVO> piitablecols = tableMapper.readTable(piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
						if(piitablecols.size() == 0) {
							return "Table catalog information doesn't exist in COTDL.TBL_PIITABLE => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name();
							//throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name());
						}
						StringBuilder pkcols = new StringBuilder();
						PiiTableVO piitable = null;
						int colcnt = 0;
						boolean catalogpkexistflg = false;
						for(int p = 0; p < piitablecols.size(); p++){
							piitable = piitablecols.get(p);
							if(("Y").equalsIgnoreCase(piitable.getPk_yn())) {
								if(colcnt == 0) {
									pkcols.append(piitable.getColumn_name());
								}else {
									pkcols.append(", "+ piitable.getColumn_name());
								}
								colcnt++;
								catalogpkexistflg = true;
				 		   }
				     	}
						if(catalogpkexistflg) {
							piisteptable.setPk_col(pkcols.toString());
						}else {
							if(StrUtil.checkString(piisteptable.getPk_col())) {
								return "Must define unique columns for PK in the upload template because PK doesn't exist => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name();
								//throw new PKNotDefinedException("Must define unique columns for PK in the upload template because PK doesn't exist => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name());
							}
						}
					}

					if(steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE") || (steptype.equalsIgnoreCase("EXE_SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN") )) {
						/** wherestr information */
						if(StrUtil.checkString(piisteptable.getWhere_key_name()) && steptype.equals("EXE_SCRAMBLE")) {
							piisteptable.setWherestr(excelUtil.getValue(row.getCell(11)));
						}else {
							String wherestr = "B.KEY_NAME = '" + piisteptable.getWhere_key_name() + "' AND B.KEYMAP_ID = '#KEYMAP_ID' AND B.BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')";
							String[] whereCols = piisteptable.getWhere_col().split(",");
							for (int j = 0; j < whereCols.length; j++) {
								wherestr += " AND A." + whereCols[j] + " = B.VAL" + (j + 1);
							}
							piisteptable.setWherestr(wherestr);

							/* sqlstr information */
							String sqlstr = "";
							if (steptype.equalsIgnoreCase("EXE_DELETE")) {
								sqlstr = "DELETE FROM " + piisteptable.getOwner() + "." + piisteptable.getTable_name() + "\r\n"
										+ " WHERE (" + StrUtil.trim(piisteptable.getPk_col()) + ") IN( SELECT A." + StrUtil.trim(piisteptable.getPk_col()).replace(",", ",A.") + " from " + piisteptable.getOwner() + "." + piisteptable.getTable_name() + " A, COTDL.TBL_PIIKEYMAP B where " + piisteptable.getWherestr() + ")";
							} else if (steptype.equalsIgnoreCase("EXE_UPDATE")) {
								sqlstr = "UPDATE " + piisteptable.getOwner() + "." + piisteptable.getTable_name() + "\r\n"
										+ " SET #UPDATECOLS "
										+ "WHERE (" + StrUtil.trim(piisteptable.getPk_col()) + ") IN( SELECT A." + StrUtil.trim(piisteptable.getPk_col()).replace(",", ",A.") + " from " + piisteptable.getOwner() + "." + piisteptable.getTable_name() + " A, COTDL.TBL_PIIKEYMAP B where " + piisteptable.getWherestr() + ")";
							}
							piisteptable.setSqlstr(sqlstr);
						}
					}else if(steptype.equals("EXE_KEYMAP") ) { // KEYMAP UPLOAD not used, just use tempate with insert sql
//						piisteptable.setPk_col(excelUtil.getValue(row.getCell(5)));
//						piisteptable.setWhere_col(excelUtil.getValue(row.getCell(12)));
//						piisteptable.setWhere_key_name(excelUtil.getValue(row.getCell(13)));
//						piisteptable.setParallelcnt(excelUtil.getValue(row.getCell(14)));
//						piisteptable.setCommitcnt(null);
//						piisteptable.setWherestr(excelUtil.getValue(row.getCell(17)));
//						piisteptable.setSqlstr("INSERT INTO COTDL.TBL_PIIKEYMAP_TMP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, VAL1, EXPECTED_ARC_DEL_DATE ) " +" \r\n " +excelUtil.getValue(row.getCell(17)));
//						piisteptable.setKeymap_id(excelUtil.getValue(row.getCell(3)));
//						piisteptable.setKey_name(excelUtil.getValue(row.getCell(4)));
//						piisteptable.setKey_cols(excelUtil.getValue(row.getCell(8)));
//						piisteptable.setKey_refstr(excelUtil.getValue(row.getCell(18)));
//						piisteptable.setSqltype(excelUtil.getValue(row.getCell(15)));
					}else if(steptype.equals("EXE_BROADCAST") || steptype.equals("EXE_FINISH") ) {
						//Already defined
					}

					/* Change data into Uppercase */
			    	if(!StrUtil.checkString(piisteptable.getDb()))piisteptable.setDb(piisteptable.getDb().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getOwner()))piisteptable.setOwner(piisteptable.getOwner().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getTable_name()))piisteptable.setTable_name(piisteptable.getTable_name().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getPagitype()))piisteptable.setPagitype(piisteptable.getPagitype().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getPagitypedetail()))piisteptable.setPagitypedetail(piisteptable.getPagitypedetail().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getExetype()))piisteptable.setExetype(piisteptable.getExetype().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getPk_col()))piisteptable.setPk_col(piisteptable.getPk_col().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getWhere_col()))piisteptable.setWhere_col(piisteptable.getWhere_col().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getWhere_key_name()))piisteptable.setWhere_key_name(piisteptable.getWhere_key_name().toUpperCase());

			    	if(!StrUtil.checkString(piisteptable.getKeymap_id()))piisteptable.setKeymap_id(piisteptable.getKeymap_id().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getKey_name()))piisteptable.setKey_name(piisteptable.getKey_name().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getKey_cols()))piisteptable.setKey_cols(piisteptable.getKey_cols().toUpperCase());
			    	//piisteptable.setKey_refstr(piisteptable.getKey_refstr().toUpperCase());
			    	if(!StrUtil.checkString(piisteptable.getSqltype()))piisteptable.setSqltype(piisteptable.getSqltype().toUpperCase());
					String result = register(piisteptable);
					if("dup".equalsIgnoreCase(result)){
						dupcnt++;
					}else{
						registercnt++;
					}

					/* *Update columns register */
					if(steptype.equalsIgnoreCase("EXE_UPDATE")){
						updatetableMapper.deletebyseq(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
						String[] array = excelUtil.getValue(row.getCell(13)).split(",");
						PiiStepTableUpdateVO piisteptableupdate = new PiiStepTableUpdateVO();
				        for (int ui = 0; ui < array.length; ui++) {
							String[] calval = array[ui].split("=", 2); // 2차 분할 (LIMIT=2 설정)

							// 값 정제 (공백 제거 + 대문자 변환)
							String columnName = calval[0].trim().toUpperCase();
							String columnValue = (calval.length > 1) ? calval[1].trim() : "";

				        	//LogUtil.log("INFO", "info$ "+"Update columns register String[] calval   "+columnName+   "   "+ columnValue );
							piisteptableupdate.setJobid(jobid);
							piisteptableupdate.setVersion(version);
							piisteptableupdate.setStepid(stepid);
							piisteptableupdate.setSeq1(piisteptable.getSeq1());
							piisteptableupdate.setSeq2(piisteptable.getSeq2());
							piisteptableupdate.setSeq3(piisteptable.getSeq3());
							piisteptableupdate.setColumn_name(columnName);
							piisteptableupdate.setUpdate_val(columnValue);
							piisteptableupdate.setStatus("ACTIVE");

							updatetableMapper.insert(piisteptableupdate);
						}
					}

					/* *Wait table register for DELETE */
					if(steptype.equalsIgnoreCase("EXE_DELETE")
							//|| steptype.equalsIgnoreCase("EXE_UPDATE")  // not need wait table config for UPDATE
							){
						if(!StrUtil.checkString(excelUtil.getValue(row.getCell(13)))) {
								//String[] array = excelUtil.getValue(row.getCell(13)).split(",");
								PiiStepTableWaitVO piisteptablewait = new PiiStepTableWaitVO();
								//"INFO", "info$ "+StrUtil.trim(excelUtil.getValue(row.getCell(15))).toUpperCase()+"="+StrUtil.trim(excelUtil.getValue(row.getCell(16))).toUpperCase());
					        	piisteptablewait.setJobid(jobid);
					        	piisteptablewait.setVersion(version);
					        	piisteptablewait.setStepid(stepid);
								piisteptablewait.setDb(piisteptable.getDb());
								piisteptablewait.setOwner(piisteptable.getOwner());
								piisteptablewait.setTable_name(piisteptable.getTable_name());
								piisteptablewait.setType("PRE");
								piisteptablewait.setDb_w(piisteptable.getDb());
								piisteptablewait.setOwner_w(StrUtil.trim(excelUtil.getValue(row.getCell(13))).toUpperCase());
								piisteptablewait.setTable_name_w(StrUtil.trim(excelUtil.getValue(row.getCell(14))).toUpperCase());

								steptablewaitmapper.insert(piisteptablewait);
						}
					}
			    }
			} catch (Exception e) {
				logger.warn(e.getMessage());
				e.printStackTrace();
				return e.getMessage();
				//throw e;
			}
		} // end for
		//return new ResponseEntity<>(list, HttpStatus.OK);
		rst = "successfully processed <br> uploaded:"+uploadedcnt+"  <br> registered:"+registercnt+"  <br> duplicated:"+dupcnt;
		return rst;
	}

	@Override
	@Transactional
	public String uploadExcelSteptableFromDB(String jobid, String version, String stepid, String userid) {

		String rst = "successfully uploaded";
		List<PiiStepTableVO> datalist = new ArrayList<>();
		Criteria cri = new Criteria();
		cri.setSearch1(jobid);
		cri.setSearch2(version);
		cri.setSearch3(stepid);
		LogUtil.log("INFO", "info$ "+cri.toString());

		int dupcnt = 0;
		int registercnt = 0;
		int uploadedcnt = 0;

		List<PiiUploadTemplateVO> list = uploadtemplatemapper.getListWithPaging(cri);
		if(list.size() == 0) {
			return " No upload tempate data exists";
		}
			try {

				String steptype = stepmapper.read(jobid, version, stepid).getSteptype();


				//Delete all rows of the tables in requested Job's step
				removeStepTable(jobid, version, stepid);
				//steptableupdatemapper.deletebystepid(jobid, version, stepid);
				//steptablewaitmapper.deletebystepid(jobid, version, stepid);
				//mapper.deleteStepTable(jobid, version, stepid);


				for(int i=0; i<list.size(); i++) {
					PiiUploadTemplateVO row = list.get(i);
					PiiStepTableVO piisteptable = new PiiStepTableVO();
					piisteptable.setJobid(jobid);
					piisteptable.setVersion(version);
					piisteptable.setStepid(stepid);

						piisteptable.setDb(row.getDb());//getDb()
						piisteptable.setOwner(row.getOwner());
						piisteptable.setTable_name(row.getTable_name());
						piisteptable.setPagitype(null);
						piisteptable.setPagitypedetail(null);
						piisteptable.setExetype(row.getExetype());
						piisteptable.setArchiveflag(null);
						piisteptable.setStatus(null);
						piisteptable.setPreceding(null);
						piisteptable.setSuccedding(null);
						piisteptable.setSeq1(10);//piisteptable.setSeq1(excelUtil.getValueInt(row.getCell(7)));
						piisteptable.setSeq2(row.getSeq());
						piisteptable.setSeq3(10);//piisteptable.setSeq1(excelUtil.getValueInt(row.getCell(9)));

					piisteptable.setPipeline(null);
					if(steptype.equalsIgnoreCase("EXE_DELETE") || steptype.equalsIgnoreCase("EXE_UPDATE") ) {
						piisteptable.setPk_col(row.getPk_col());
						piisteptable.setWhere_col(row.getWhere_col());
						piisteptable.setWhere_key_name(row.getWhere_key_name());
						piisteptable.setParallelcnt(row.getParallelcnt());
						piisteptable.setCommitcnt(row.getCommitcnt());
					}

					//20230125 고유영구파기 기한 추가
					if(steptype.equalsIgnoreCase("EXE_DELETE") ) {
						piisteptable.setPagitypedetail(row.getPagitypedetail());
					}
					if(steptype.equalsIgnoreCase("EXE_UPDATE") ) {
						piisteptable.setPagitypedetail(row.getPagitypedetail());
					}

					piisteptable.setKeymap_id(null);
					piisteptable.setKey_name(null);
					piisteptable.setKey_cols(null);
					piisteptable.setKey_refstr(null);
					piisteptable.setSqltype(null);
					piisteptable.setRegdate(null);
					piisteptable.setUpddate(null);
					piisteptable.setReguserid(userid);
					piisteptable.setUpduserid(userid);

					if(steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE")) {
						/* PK information */
						List<PiiTableVO> piitablecols = tableMapper.readTable(piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
						if(piitablecols.size() == 0) {
							return "Table catalog information doesn't exist in COTDL.TBL_PIITABLE => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name();
							//throw new TableCatalogNullException("Table catalog information doesn't exist in COTDL.TBL_PIITABLE => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name());
						}
						StringBuilder pkcols = new StringBuilder();
						PiiTableVO piitable = null;
						int colcnt = 0;
						boolean catalogpkexistflg = false;
						for(int p = 0; p < piitablecols.size(); p++){
							piitable = piitablecols.get(p);
							if(("Y").equalsIgnoreCase(piitable.getPk_yn())) {
								if(colcnt == 0) {
									pkcols.append(piitable.getColumn_name());
								}else {
									pkcols.append(", "+ piitable.getColumn_name());
								}
								colcnt++;
								catalogpkexistflg = true;
							}
						}
						if(catalogpkexistflg) {
							piisteptable.setPk_col(pkcols.toString());
						}else {
							if(StrUtil.checkString(piisteptable.getPk_col())) {
								return "Must define unique columns for PK in the upload template because PK doesn't exist => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name();
								//throw new PKNotDefinedException("Must define unique columns for PK in the upload template because PK doesn't exist => "+piisteptable.getDb()+":"+piisteptable.getOwner()+"."+piisteptable.getTable_name());
							}
						}
					}

					if(steptype.equals("EXE_DELETE") || steptype.equals("EXE_UPDATE") || steptype.equals("EXE_SCRAMBLE")) {
						/* wherestr information */
						String wherestr = "B.KEY_NAME = '"+piisteptable.getWhere_key_name()+"' AND B.KEYMAP_ID = '#KEYMAP_ID' AND B.BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')";
						String[] whereCols = piisteptable.getWhere_col().split(",");
						for (int j = 0; j < whereCols.length; j++) {
							wherestr += " AND A."+whereCols[j]+" = B.VAL"+(j+1);
						}
						piisteptable.setWherestr(wherestr);

						/* sqlstr information */
						String sqlstr = "";
						if(steptype.equalsIgnoreCase("EXE_DELETE")) {
							sqlstr = "DELETE FROM "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+"\r\n"
									+" WHERE ("+ StrUtil.trim(piisteptable.getPk_col()) + ") IN( SELECT A."+ StrUtil.trim(piisteptable.getPk_col()).replace(",",",A.") +" from "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+" A, COTDL.TBL_PIIKEYMAP B where "+piisteptable.getWherestr() + ")";
						}
						else if(steptype.equalsIgnoreCase("EXE_UPDATE"))
						{
							sqlstr = "UPDATE "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+"\r\n"
									+" SET #UPDATECOLS "
									+ "WHERE ("+ StrUtil.trim(piisteptable.getPk_col()) + ") IN( SELECT A."+ StrUtil.trim(piisteptable.getPk_col()).replace(",",",A.") +" from "+piisteptable.getOwner()+"."+piisteptable.getTable_name()+" A, COTDL.TBL_PIIKEYMAP B where "+piisteptable.getWherestr() + ")";
						}
						piisteptable.setSqlstr(sqlstr);
					}else if(steptype.equals("EXE_BROADCAST") || steptype.equals("EXE_FINISH") ) {
						//Already defined
					}

					/* Change data into Uppercase */
					if(!StrUtil.checkString(piisteptable.getDb()))piisteptable.setDb(piisteptable.getDb().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getOwner()))piisteptable.setOwner(piisteptable.getOwner().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getTable_name()))piisteptable.setTable_name(piisteptable.getTable_name().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getPagitype()))piisteptable.setPagitype(piisteptable.getPagitype().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getPagitypedetail()))piisteptable.setPagitypedetail(piisteptable.getPagitypedetail().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getExetype()))piisteptable.setExetype(piisteptable.getExetype().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getPk_col()))piisteptable.setPk_col(piisteptable.getPk_col().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getWhere_col()))piisteptable.setWhere_col(piisteptable.getWhere_col().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getWhere_key_name()))piisteptable.setWhere_key_name(piisteptable.getWhere_key_name().toUpperCase());

					if(!StrUtil.checkString(piisteptable.getKeymap_id()))piisteptable.setKeymap_id(piisteptable.getKeymap_id().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getKey_name()))piisteptable.setKey_name(piisteptable.getKey_name().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getKey_cols()))piisteptable.setKey_cols(piisteptable.getKey_cols().toUpperCase());
					//piisteptable.setKey_refstr(piisteptable.getKey_refstr().toUpperCase());
					if(!StrUtil.checkString(piisteptable.getSqltype()))piisteptable.setSqltype(piisteptable.getSqltype().toUpperCase());

					String result = register(piisteptable);
					if("dup".equalsIgnoreCase(result)){
						dupcnt++;
					}else{
						registercnt++;
					}
					/* *Update columns register */
					if(steptype.equalsIgnoreCase("EXE_UPDATE")){
						updatetableMapper.deletebyseq(piisteptable.getJobid(), piisteptable.getVersion(), piisteptable.getStepid(), piisteptable.getSeq1(), piisteptable.getSeq2(), piisteptable.getSeq3());
						String[] array = row.getUpdate_cols().split(",");
						PiiStepTableUpdateVO piisteptableupdate = new PiiStepTableUpdateVO();
						for (int ui = 0; ui < array.length; ui++) {
							String[] calval = array[ui].split("\\^\\=\\^");
							LogUtil.log("INFO", "info$ "+"Update columns register String[] calval   "+calval[0].toUpperCase()+   "   "+ calval[1] );
							piisteptableupdate.setJobid(jobid);
							piisteptableupdate.setVersion(version);
							piisteptableupdate.setStepid(stepid);
							piisteptableupdate.setSeq1(piisteptable.getSeq1());
							piisteptableupdate.setSeq2(piisteptable.getSeq2());
							piisteptableupdate.setSeq3(piisteptable.getSeq3());
							piisteptableupdate.setColumn_name(StrUtil.trim(calval[0].toUpperCase()));
							piisteptableupdate.setUpdate_val(StrUtil.trim(calval[1]));
							piisteptableupdate.setStatus("ACTIVE");

							updatetableMapper.insert(piisteptableupdate);
						}
					}

					/* *Wait table register for DELETE */
					if(steptype.equalsIgnoreCase("EXE_DELETE")
						//|| steptype.equalsIgnoreCase("EXE_UPDATE")  // not need wait table config for UPDATE
					){
						if(!StrUtil.checkString(row.getPre_owner())) {
							//String[] array = row.getCell(13)).split(",");
							PiiStepTableWaitVO piisteptablewait = new PiiStepTableWaitVO();

							piisteptablewait.setJobid(jobid);
							piisteptablewait.setVersion(version);
							piisteptablewait.setStepid(stepid);
							piisteptablewait.setDb(piisteptable.getDb());
							piisteptablewait.setOwner(piisteptable.getOwner());
							piisteptablewait.setTable_name(piisteptable.getTable_name());
							piisteptablewait.setType("PRE");
							piisteptablewait.setDb_w(piisteptable.getDb());
							piisteptablewait.setOwner_w(StrUtil.trim(row.getPre_owner()).toUpperCase());
							piisteptablewait.setTable_name_w(StrUtil.trim(row.getPre_table_name()).toUpperCase());

							steptablewaitmapper.insert(piisteptablewait);

						}
					}


				}

			} catch (Exception e) {
				return e.getMessage();
				//throw e;
			}

			//rst = list.size() + " rows - successfully uploaded";
			uploadedcnt = list.size();
			rst = "successfully processed <br> uploaded:"+uploadedcnt+"  <br> registered:"+registercnt+"  <br> duplicated:"+dupcnt;
		return rst;
	}

	@Override
	@Transactional
	public int registerArcTab(PiiStepTableVO piisteptable, Criteria cri) {

		LogUtil.log("INFO", "info$ "+"registerArcTab......cri  " + cri);
		int resultcnt = 0;LogUtil.log("INFO", "info$ "+"@@###registerArcTab..11....piisteptable  "+cri+"   " +tableMapper.getTotalCountNewArcTab(cri)+"   "+tableMapper.getTotalCountNewArcTab(cri)+"  "+ piisteptable.toString());
		if(tableMapper.getTotalCountNewArcTab(cri) == 0){

			PiiDatabaseVO dbVO = databaseMapper.read(piisteptable.getDb());
			PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
			PiiDatabaseVO dbHomeVO = databaseMapper.read("DLM");
			AES256Util aes = null;
			try {
				aes = new AES256Util();
			} catch(Exception e) {
			}
			Connection conn = null;
			Connection connArc = null;
			Connection connHome = null;
			Statement stmt = null;
			Statement stmtArc = null;
			ResultSet rs = null;
			StringBuilder sqlInsert = new StringBuilder();

			PreparedStatement stmtArcIns = null;
			PreparedStatement stmtArcHome = null;
			try {
//				logger.warn("warn "+"Connection creation dbVO"+ dbVO.toString());
//				logger.warn("warn "+"Connection creation dbArcVO"+ dbArcVO.toString());
//				logger.warn("warn "+"Connection creation dbHomeVO"+ dbHomeVO.toString());
				conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
				connArc = ConnectionProvider.getConnection(dbArcVO.getDbtype(), dbArcVO.getHostname(), dbArcVO.getPort(), dbArcVO.getId_type(), dbArcVO.getId(), dbArcVO.getDb(), dbArcVO.getDbuser(), aes.decrypt(dbArcVO.getPwd()));
				connHome = ConnectionProvider.getConnection(dbHomeVO.getDbtype(), dbHomeVO.getHostname(), dbHomeVO.getPort(), dbHomeVO.getId_type(), dbHomeVO.getId(), dbHomeVO.getDb(), dbHomeVO.getDbuser(), aes.decrypt(dbHomeVO.getPwd()));
				conn.setAutoCommit(false);
				connArc.setAutoCommit(false);
				connHome.setAutoCommit(false);
			} catch(Exception e) {
				e.printStackTrace();
			}
			try {
				String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
				String arcSchema = archiveNamingService.getArchiveSchemaName(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDb(), piisteptable.getOwner());

				// 1) CREATE TABLE DDL 구성: PII 5개 컬럼 (중립→아카이브DB 변환)
				sqlInsert.append("CREATE TABLE " + archiveTablePath + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype()," (PII_ORDER_ID DECIMAL(15) ,PII_BASE_DATE DATETIME ,PII_CUST_ID VARCHAR(50) ,PII_JOB_ID VARCHAR(200) ,PII_DESTRUCT_DATE DATETIME ") );

				// 2) 소스 DB에서 컬럼 메타 조회 (중립 타입으로 출력)
				String srcMetaSql = SqlUtil.getArcTabCreate(dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
				if (srcMetaSql != null && !srcMetaSql.isEmpty()) {
					stmt = conn.createStatement();
					rs = stmt.executeQuery(srcMetaSql);
					rs.setFetchSize(600);
					while (rs.next()) {
						// ★ 핵심 수정: 소스 컬럼도 아카이브 DB 타입으로 변환
						sqlInsert.append(", " + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(), rs.getString(1)));
					}
				} else {
					logger.warn("warn: getArcTabCreate returned empty SQL for source dbtype=" + dbVO.getDbtype() + ". Archive table will have PII columns only.");
				}

				// 3) 닫기 절 (아카이브 DB에 맞게 변환)
				sqlInsert.append(SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(),") ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4"));

				// 4) CREATE TABLE 실행
				stmtArc = connArc.createStatement();
				LogUtil.log("INFO", "info$ registerArcTab CREATE TABLE DDL: " + sqlInsert.toString());
				resultcnt = stmtArc.executeUpdate(sqlInsert.toString());
				conn.commit();
				connArc.commit();

				// 5) PII 5개 컬럼 인덱스 생성 (실패해도 테이블 등록은 유지)
				String[] indexDdls = SqlUtil.getArcTableIndexDdls(dbArcVO.getDbtype(), arcSchema, piisteptable.getTable_name());
				Statement stmtIdx = connArc.createStatement();
				for (String idxDdl : indexDdls) {
					try {
						stmtIdx.executeUpdate(idxDdl);
						LogUtil.log("INFO", "info$ registerArcTab INDEX OK: " + idxDdl);
					} catch (Exception idxEx) {
						logger.warn("warn: registerArcTab INDEX FAIL: " + idxDdl + " | " + idxEx.getMessage());
					}
				}
				connArc.commit();
				JdbcUtil.close(stmtIdx);

				// 6) 아카이브 DB 카탈로그 정보를 TBL_PIITABLE에 INSERT
				String catalogSql = SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name());
				if (catalogSql != null && !catalogSql.isEmpty()) {
					StringBuilder sqlArcInsert = new StringBuilder();
					StringBuilder sqlHomeInsert = new StringBuilder();
					sqlArcInsert.append("insert into cotdl.tbl_piitable values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					sqlHomeInsert.append("insert into cotdl.tbl_piitable values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

					stmtArc = connArc.createStatement();
					stmtArcIns = connArc.prepareStatement(sqlArcInsert.toString());
					stmtArcHome = connHome.prepareStatement(sqlHomeInsert.toString());
					rs = stmtArc.executeQuery(catalogSql);
					rs.setFetchSize(600);

					while (rs.next()) {
						for (int col = 1; col <= 16; col++) {
							if (col == 5 || col == 7 || col == 10) {
								stmtArcIns.setBigDecimal(col, rs.getBigDecimal(col));
								stmtArcHome.setBigDecimal(col, rs.getBigDecimal(col));
							} else if (col == 13 || col == 14) {
								stmtArcIns.setDate(col, rs.getDate(col));
								stmtArcHome.setDate(col, rs.getDate(col));
							} else {
								stmtArcIns.setString(col, rs.getString(col));
								stmtArcHome.setString(col, rs.getString(col));
							}
						}
						stmtArcIns.addBatch();
						stmtArcHome.addBatch();
					}
					stmtArcIns.executeBatch();
					stmtArcIns.clearBatch();
					stmtArcHome.executeBatch();
					stmtArcHome.clearBatch();
					connArc.commit();
					connHome.commit();
				} else {
					logger.warn("warn: getInsDlmarcPiitable returned empty SQL for arc dbtype=" + dbArcVO.getDbtype());
				}
			} catch(Exception e) {
				JdbcUtil.rollback(conn);
				JdbcUtil.rollback(connArc);
				JdbcUtil.rollback(connHome);
				logger.error("registerArcTab DDL error: " + e.getMessage() + " | DDL: " + sqlInsert.toString(), e);
				// 에러 정보를 piisteptable에 보관하여 호출부에서 UI 알림 가능
				piisteptable.setParallelcnt("ARC_DDL_ERROR:" + e.getMessage() + "|DDL:" + sqlInsert.toString());
			} finally {
				// ★ 수정: catch에서 rollback 한 후 다시 commit 하는 버그 제거
				JdbcUtil.close(rs);
				JdbcUtil.close(stmt);
				JdbcUtil.close(stmtArc);
				JdbcUtil.close(stmtArcIns);
				JdbcUtil.close(stmtArcHome);
				JdbcUtil.close(conn);
				JdbcUtil.close(connArc);
				JdbcUtil.close(connHome);
			}

		}
		return resultcnt;
	}
	@Override
	@Transactional
	public int registerArcTabCols(PiiStepTableVO piisteptable, Criteria cri) {

		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		LogUtil.log("INFO", "info$ "+"#0 registerArcTabCols...begin...:"+formatter.format(calendar.getTime())+"  " + piisteptable);
		int resultcnt = 0;LogUtil.log("INFO", "info$ "+"@@registerArcTabCols..11....piisteptable  "+tableMapper.getTotalCountNewArcTabCols(cri)+ "" + cri +"   "+piisteptable.toString());
		if(tableMapper.getTotalCountNewArcTabCols(cri) > 0){
			PiiDatabaseVO dbVO = databaseMapper.read(piisteptable.getDb());
			PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
			PiiDatabaseVO dbHomeVO = databaseMapper.read("DLM");
			AES256Util aes = null;
			try {
				aes = new AES256Util();
			} catch(Exception e) {

			}
			Connection conn = null;
			Connection connArc = null;
			Connection connHome = null;
			Statement stmt = null;
			Statement stmtArc = null;
			ResultSet rs = null;
			PreparedStatement stmtArcIns = null;
			PreparedStatement stmtArcHome = null;

			try {
				conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
				connArc = ConnectionProvider.getConnection(dbArcVO.getDbtype(), dbArcVO.getHostname(), dbArcVO.getPort(), dbArcVO.getId_type(), dbArcVO.getId(), dbArcVO.getDb(), dbArcVO.getDbuser(), aes.decrypt(dbArcVO.getPwd()));
				connHome = ConnectionProvider.getConnection(dbHomeVO.getDbtype(), dbHomeVO.getHostname(), dbHomeVO.getPort(), dbHomeVO.getId_type(), dbHomeVO.getId(), dbHomeVO.getDb(), dbHomeVO.getDbuser(), aes.decrypt(dbHomeVO.getPwd()));
				conn.setAutoCommit(false);
				connArc.setAutoCommit(false);
				connHome.setAutoCommit(false);
			} catch(Exception e) {
				logger.warn("warn "+"Connection creation exception");
				logger.warn("warn "+dbVO.toString());
				logger.warn("warn "+dbArcVO.toString());
				logger.warn("warn "+dbHomeVO.toString());
				e.printStackTrace();
			}
			try {
				// ALTER TABLE ADD COLUMN: 소스 DB에서 중립타입 DDL 생성 후 아카이브 DB 타입으로 변환하여 실행
				PiiDatabaseVO dbArcVO2 = databaseMapper.read("DLMARC");
				stmt = conn.createStatement();
				stmtArc = connArc.createStatement();
				calendar = Calendar.getInstance();LogUtil.log("INFO", "info$ "+"#1 registerArcTabCols..tableMapper.getListNewArcTabCols(cri) .begin...:"+formatter.format(calendar.getTime())+"  "+cri);
				List<PiiTableNewArcTabVO> newArcTabVOList = tableMapper.getListNewArcTabCols(cri);
				logger.warn("warn "+"@@@@@registerArcTabCols..getListNewArcTabCols=>" + newArcTabVOList.size() + "     cri="+cri);
				for (PiiTableNewArcTabVO newArcTabVO : newArcTabVOList) {
					String colsSql = SqlUtil.getArcTabColsCreate(ArchiveNamingService.CONFIG_TYPE_PII, dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name(), newArcTabVO.getColumn_name());
					if (colsSql == null || colsSql.isEmpty()) {
						logger.warn("warn: getArcTabColsCreate returned empty for source dbtype=" + dbVO.getDbtype() + " column=" + newArcTabVO.getColumn_name());
						continue;
					}
					rs = stmt.executeQuery(colsSql);
					rs.setFetchSize(600);

					while (rs.next()) {
						// ★ 핵심 수정: ALTER TABLE DDL도 아카이브 DB 타입으로 변환
						String alterDdl = SqlUtil.getArcTabCreateSql(dbArcVO2.getDbtype(), rs.getString(1));
						LogUtil.log("INFO", "info$ registerArcTabCols ALTER DDL: " + alterDdl);
						resultcnt += stmtArc.executeUpdate(alterDdl);
					}
				}
				conn.commit();
				connArc.commit();
				calendar = Calendar.getInstance();
				// insert catalog info into TBL_PIITABLE
				StringBuilder sqlArcInsert = new StringBuilder();
				StringBuilder sqlHomeInsert = new StringBuilder();
				sqlArcInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
				sqlArcInsert.append("?" );//DB
				sqlArcInsert.append(",?" );//OWNER
				sqlArcInsert.append(",?" );//TABLE_NAME
				sqlArcInsert.append(",?" );//COLUMN_NAME
				sqlArcInsert.append(",?" );//COLUMN_ID
				sqlArcInsert.append(",?" );//PK_YN
				sqlArcInsert.append(",?" );//PK_POSITION
				sqlArcInsert.append(",?" );//FULL_DATA_TYPE
				sqlArcInsert.append(",?" );//DATA_TYPE
				sqlArcInsert.append(",?" );//DATA_LENGTH
				sqlArcInsert.append(",?" );//NULLABLE
				sqlArcInsert.append(",?" );//COMMENTS
				sqlArcInsert.append(",?" );//REGDATE
				sqlArcInsert.append(",?" );//UPDDATE
				sqlArcInsert.append(",?" );//REGUSERID
				sqlArcInsert.append(",?" );//UPDUSERID
				sqlArcInsert.append(" ) ");

				sqlHomeInsert.append("insert into " + "cotdl.tbl_piitable "+ "values (");
				sqlHomeInsert.append("?" );//DB
				sqlHomeInsert.append(",?" );//OWNER
				sqlHomeInsert.append(",?" );//TABLE_NAME
				sqlHomeInsert.append(",?" );//COLUMN_NAME
				sqlHomeInsert.append(",?" );//COLUMN_ID
				sqlHomeInsert.append(",?" );//PK_YN
				sqlHomeInsert.append(",?" );//PK_POSITION
				sqlHomeInsert.append(",?" );//FULL_DATA_TYPE
				sqlHomeInsert.append(",?" );//DATA_TYPE
				sqlHomeInsert.append(",?" );//DATA_LENGTH
				sqlHomeInsert.append(",?" );//NULLABLE
				sqlHomeInsert.append(",?" );//COMMENTS
				sqlHomeInsert.append(",?" );//REGDATE
				sqlHomeInsert.append(",?" );//UPDDATE
				sqlHomeInsert.append(",?" );//REGUSERID
				sqlHomeInsert.append(",?" );//UPDUSERID
				sqlHomeInsert.append(" ) ");
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlArcInsert.toString());
//				logger.warn("warn "+"insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlHomeInsert.toString());

				stmtArc = connArc.createStatement();
				stmtArcIns = connArc.prepareStatement(sqlArcInsert.toString());LogUtil.log("INFO", "info$ "+"stmtArcIns");
				stmtArcHome = connHome.prepareStatement(sqlHomeInsert.toString());LogUtil.log("INFO", "info$ "+"stmtArcHome");
//				logger.warn("warn "+"SqlUtil.getInsDlmarcPiitable(db "+SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name()));

				for (PiiTableNewArcTabVO newArcTabVO : newArcTabVOList) {
					rs = stmtArc.executeQuery(SqlUtil.getInsDlmarcPiitableCols(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name(), newArcTabVO.getColumn_name()));
					rs.setFetchSize(600);
					while (rs.next()) {// ROW 단위 데이터 SELECT
						stmtArcIns.setString(1, rs.getString(1));
						stmtArcIns.setString(2, rs.getString(2));
						stmtArcIns.setString(3, rs.getString(3));
						stmtArcIns.setString(4, rs.getString(4));
						stmtArcIns.setBigDecimal(5, rs.getBigDecimal(5));
						stmtArcIns.setString(6, rs.getString(6));
						stmtArcIns.setBigDecimal(7, rs.getBigDecimal(7));
						stmtArcIns.setString(8, rs.getString(8));
						stmtArcIns.setString(9, rs.getString(9));
						stmtArcIns.setBigDecimal(10, rs.getBigDecimal(10));
						stmtArcIns.setString(11, rs.getString(11));
						stmtArcIns.setString(12, rs.getString(12));
						stmtArcIns.setDate(13, rs.getDate(13));
						stmtArcIns.setDate(14, rs.getDate(14));
						stmtArcIns.setString(15, rs.getString(15));
						stmtArcIns.setString(16, rs.getString(16));

						stmtArcHome.setString(1, rs.getString(1));
						stmtArcHome.setString(2, rs.getString(2));
						stmtArcHome.setString(3, rs.getString(3));
						stmtArcHome.setString(4, rs.getString(4));
						stmtArcHome.setBigDecimal(5, rs.getBigDecimal(5));
						stmtArcHome.setString(6, rs.getString(6));
						stmtArcHome.setBigDecimal(7, rs.getBigDecimal(7));
						stmtArcHome.setString(8, rs.getString(8));
						stmtArcHome.setString(9, rs.getString(9));
						stmtArcHome.setBigDecimal(10, rs.getBigDecimal(10));
						stmtArcHome.setString(11, rs.getString(11));
						stmtArcHome.setString(12, rs.getString(12));
						stmtArcHome.setDate(13, rs.getDate(13));
						stmtArcHome.setDate(14, rs.getDate(14));
						stmtArcHome.setString(15, rs.getString(15));
						stmtArcHome.setString(16, rs.getString(16));

						stmtArcIns.addBatch();
						stmtArcHome.addBatch();
					}
					stmtArcIns.executeBatch();
					stmtArcIns.clearBatch();
					stmtArcHome.executeBatch();
					stmtArcHome.clearBatch();

					connArc.commit();
					connHome.commit();

				}
				//calendar = Calendar.getInstance();logger.warn("warn "+"#3 registerArcTabCols..commit() .end...:"+formatter.format(calendar.getTime())+"  ");
			} catch(SQLException e) {
				JdbcUtil.rollback(conn);
				JdbcUtil.rollback(connArc);
				JdbcUtil.rollback(connHome);
				calendar = Calendar.getInstance();
				logger.error("registerArcTabCols SQLException: " + e.getMessage(), e);
			} finally {
				// ★ 수정: catch에서 rollback 한 후 다시 commit 하는 버그 제거
				JdbcUtil.close(rs);
				JdbcUtil.close(stmt);
				JdbcUtil.close(stmtArc);
				JdbcUtil.close(stmtArcIns);
				JdbcUtil.close(stmtArcHome);
				JdbcUtil.close(conn);
				JdbcUtil.close(connArc);
				JdbcUtil.close(connHome);
			}

		}
		return resultcnt;
	}

	@Override
	public Map<String, String> getTDUpdateWhereClauseData(String jobid, String version, String stepid, String owner, String table_name) {
		return mapper.getTDUpdateWhereClauseData(jobid, version, stepid, owner, table_name);
	}

	/**
	 * 아카이브 DDL 상태 확인: 아카이브 테이블 존재 여부 + CREATE TABLE DDL 스크립트 반환
	 */
	@Override
	public Map<String, Object> checkArcDdlStatus(PiiStepTableVO piisteptable) {
		logger.info("[checkArcDdlStatus] START - db={}, owner={}, table={}",
				piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
		Map<String, Object> result = new LinkedHashMap<>();
		result.put("status", "UNKNOWN");
		result.put("ddl", "");

		try {
			PiiDatabaseVO dbVO = databaseMapper.read(piisteptable.getDb());
			PiiDatabaseVO dbArcVO = databaseMapper.read("DLMARC");
			logger.info("[checkArcDdlStatus] source dbtype={}, arc dbtype={}", dbVO.getDbtype(), dbArcVO.getDbtype());
			AES256Util aes = new AES256Util();

			String arcSchema = archiveNamingService.getArchiveSchemaName(
					ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDb(), piisteptable.getOwner());
			String archiveTablePath = arcSchema + "." + piisteptable.getTable_name();
			logger.info("[checkArcDdlStatus] arcSchema={}, archiveTablePath={}", arcSchema, archiveTablePath);
			result.put("archiveTablePath", archiveTablePath);

			// 아카이브 DB에서 테이블 존재 확인
			Connection connArc = null;
			Statement stmtArc = null;
			ResultSet rs = null;
			try {
				connArc = ConnectionProvider.getConnection(dbArcVO.getDbtype(), dbArcVO.getHostname(),
						dbArcVO.getPort(), dbArcVO.getId_type(), dbArcVO.getId(),
						dbArcVO.getDb(), dbArcVO.getDbuser(), aes.decrypt(dbArcVO.getPwd()));

				String checkSql;
				if (dbArcVO.getDbtype().equalsIgnoreCase("ORACLE") || dbArcVO.getDbtype().equalsIgnoreCase("TIBERO")) {
					checkSql = "SELECT COUNT(1) FROM ALL_TABLES WHERE OWNER = '" + arcSchema + "' AND TABLE_NAME = '" + piisteptable.getTable_name() + "'";
				} else if (dbArcVO.getDbtype().equalsIgnoreCase("POSTGRESQL")) {
					checkSql = "SELECT COUNT(1) FROM information_schema.tables WHERE UPPER(table_schema) = '" + arcSchema + "' AND UPPER(table_name) = '" + piisteptable.getTable_name() + "'";
				} else {
					checkSql = "SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '" + arcSchema + "' AND TABLE_NAME = '" + piisteptable.getTable_name() + "'";
				}

				logger.info("[checkArcDdlStatus] checkSql={}", checkSql);
				stmtArc = connArc.createStatement();
				rs = stmtArc.executeQuery(checkSql);
				if (rs.next() && rs.getInt(1) > 0) {
					result.put("status", "EXISTS");
					result.put("message", "아카이브 테이블이 정상 존재합니다: " + archiveTablePath);
					logger.info("[checkArcDdlStatus] table EXISTS");
				} else {
					result.put("status", "NOT_EXISTS");
					result.put("message", "아카이브 테이블이 존재하지 않습니다: " + archiveTablePath);
					logger.info("[checkArcDdlStatus] table NOT_EXISTS");
				}
			} finally {
				JdbcUtil.close(rs);
				JdbcUtil.close(stmtArc);
				JdbcUtil.close(connArc);
			}

			// CREATE TABLE DDL 스크립트 생성 (실행은 안 함)
			StringBuilder ddl = new StringBuilder();
			ddl.append("CREATE TABLE " + archiveTablePath +
					SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(),
							" (PII_ORDER_ID DECIMAL(15) ,PII_BASE_DATE DATETIME ,PII_CUST_ID VARCHAR(50) ,PII_JOB_ID VARCHAR(200) ,PII_DESTRUCT_DATE DATETIME "));

			String srcMetaSql = SqlUtil.getArcTabCreate(dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
			if (srcMetaSql != null && !srcMetaSql.isEmpty()) {
				Connection conn = null;
				Statement stmt = null;
				ResultSet rs2 = null;
				try {
					conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(),
							dbVO.getPort(), dbVO.getId_type(), dbVO.getId(),
							dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
					stmt = conn.createStatement();
					rs2 = stmt.executeQuery(srcMetaSql);
					while (rs2.next()) {
						ddl.append(", " + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(), rs2.getString(1)));
					}
				} finally {
					JdbcUtil.close(rs2);
					JdbcUtil.close(stmt);
					JdbcUtil.close(conn);
				}
			}
			ddl.append(SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(), ") ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4"));
			result.put("ddl", ddl.toString());

			// 인덱스 DDL도 포함
			String[] indexDdls = SqlUtil.getArcTableIndexDdls(dbArcVO.getDbtype(), arcSchema, piisteptable.getTable_name());
			result.put("indexDdls", indexDdls);

		} catch (Exception e) {
			result.put("status", "ERROR");
			result.put("message", "확인 중 오류: " + e.getMessage());
			logger.error("[checkArcDdlStatus] ERROR: {}", e.getMessage(), e);
		}
		logger.info("[checkArcDdlStatus] END - status={}", result.get("status"));
		return result;
	}

	/**
	 * 아카이브 DDL 재실행: createArcTable 재호출 후 결과 반환
	 */
	@Override
	public Map<String, Object> retryArcDdl(PiiStepTableVO piisteptable) {
		logger.info("[retryArcDdl] START - db={}, owner={}, table={}, exetype={}",
				piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name(), piisteptable.getExetype());
		Map<String, Object> result = new LinkedHashMap<>();
		try {
			piisteptable.setParallelcnt(null);
			createArcTable(piisteptable);

			if (piisteptable.getParallelcnt() != null && piisteptable.getParallelcnt().startsWith("ARC_DDL_ERROR:")) {
				result.put("status", "FAIL");
				result.put("message", piisteptable.getParallelcnt());
				logger.warn("[retryArcDdl] FAIL: {}", piisteptable.getParallelcnt());
				piisteptable.setParallelcnt(null);
			} else {
				result.put("status", "OK");
				result.put("message", "아카이브 DDL 재실행 성공");
				logger.info("[retryArcDdl] OK");
			}
		} catch (Exception e) {
			result.put("status", "FAIL");
			result.put("message", "재실행 오류: " + e.getMessage());
			logger.error("[retryArcDdl] ERROR: {}", e.getMessage(), e);
		}
		logger.info("[retryArcDdl] END - status={}", result.get("status"));
		return result;
	}
}
