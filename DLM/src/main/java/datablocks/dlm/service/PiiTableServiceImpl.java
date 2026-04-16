package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.mapper.PiiDatabaseMapper;
import datablocks.dlm.mapper.PiiTableMapper;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.*;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiTableServiceImpl implements PiiTableService {
	private static final Logger logger = LoggerFactory.getLogger(PiiTableServiceImpl.class);
	@Autowired
	private PiiTableMapper mapper;
	@Autowired
	private PiiDatabaseMapper databaseMapper;
	@Autowired
	private ArchiveNamingService archiveNamingService;

	@Override
	public List<PiiTableVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		return mapper.getList();
	}

	
	@Override
	public List<PiiTableVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiTableWithMetaVO> getListWithMeta(Criteria cri) {

		LogUtil.log("INFO", "getListWithMetaWithPaging: " + cri);

		return mapper.getListWithMetaWithPaging(cri);
	}

	@Override
	public List<PiiTablePkVO> getTableList(Criteria cri) {
		
		LogUtil.log("INFO", "getTableList with criteria: " + cri);
		
		return mapper.getTablePkListWithPaging(cri);
	}
	@Override
	public List<PiiTableNewArcTabVO> getListNewArcTabCols(Criteria cri) {

		LogUtil.log("INFO", "getListNewArcTabCols with criteria: " + cri);
		return mapper.getListNewArcTabCols(cri);
	}

	@Override
	public List<PiiLayoutGapVO> getLayoutGapList(Criteria cri) {

		LogUtil.log("INFO", "get List with criteria: " + cri);
		return mapper.getLayoutGapListWithPaging(cri);
	}
		
	@Override
	@Transactional
	public void register(PiiTableVO piitable) {
		
		 LogUtil.log("INFO", "register......" + piitable);
		  
		 mapper.insert(piitable); 
		 }
	@Override
	@Transactional
	public int registerArcTab(PiiStepTableVO piisteptable, Criteria cri) {

		LogUtil.log("INFO", "registerArcTab......cri  " + cri);
		int resultcnt = 0;
		if(getTotalCountNewArcTab(cri) == 0){

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

				// 1) CREATE TABLE DDL 구성
				sqlInsert.append("CREATE TABLE " + archiveTablePath + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype()," (PII_ORDER_ID DECIMAL(15) ,PII_BASE_DATE DATETIME ,PII_CUST_ID VARCHAR(50) ,PII_JOB_ID VARCHAR(200) ,PII_DESTRUCT_DATE DATETIME ") );

				// 2) 소스 DB 컬럼 메타 조회
				String srcMetaSql = SqlUtil.getArcTabCreate(dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
				if (srcMetaSql != null && !srcMetaSql.isEmpty()) {
					stmt = conn.createStatement();
					rs = stmt.executeQuery(srcMetaSql);
					rs.setFetchSize(600);
					while (rs.next()) {
						// ★ 소스 컬럼도 아카이브 DB 타입으로 변환
						sqlInsert.append(", " + SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(), rs.getString(1)));
					}
				} else {
					logger.warn("warn: getArcTabCreate returned empty for source dbtype=" + dbVO.getDbtype());
				}

				sqlInsert.append(SqlUtil.getArcTabCreateSql(dbArcVO.getDbtype(),") ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4"));
				// Row Size 초과 시 큰 VARCHAR부터 TEXT로 자동 변환 후 CREATE TABLE 실행 (MariaDB/MySQL만 적용)
				String finalDdl = SqlUtil.optimizeDdlForRowSize(dbArcVO.getDbtype(), sqlInsert.toString());
				LogUtil.log("INFO", "PiiTableServiceImpl registerArcTab DDL: " + finalDdl);
				stmtArc = connArc.createStatement();
				resultcnt = stmtArc.executeUpdate(finalDdl);
				conn.commit();
				connArc.commit();

				// 3) PII 5개 컬럼 인덱스 생성
				String[] indexDdls = SqlUtil.getArcTableIndexDdls(dbArcVO.getDbtype(), arcSchema, piisteptable.getTable_name());
				Statement stmtIdx = connArc.createStatement();
				for (String idxDdl : indexDdls) {
					try {
						stmtIdx.executeUpdate(idxDdl);
					} catch (Exception idxEx) {
						logger.warn("warn: registerArcTab INDEX FAIL: " + idxDdl + " | " + idxEx.getMessage());
					}
				}
				connArc.commit();
				JdbcUtil.close(stmtIdx);

				// 4) 카탈로그 INSERT
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
					logger.warn("warn: getInsDlmarcPiitable returned empty for arc dbtype=" + dbArcVO.getDbtype());
				}
			} catch(Exception e) {
				JdbcUtil.rollback(conn);
				JdbcUtil.rollback(connArc);
				JdbcUtil.rollback(connHome);
				logger.error("PiiTableServiceImpl registerArcTab DDL error: " + e.getMessage() + " | DDL: " + sqlInsert.toString(), e);
			} finally {
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

		LogUtil.log("DEBUG", "registerArcTabCols......cri  " + cri);
		int resultcnt = 0;
		if(getTotalCountNewArcTabCols(cri)>0){
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
				// ALTER TABLE ADD COLUMN: 소스에서 중립타입 DDL 생성 후 아카이브 DB 타입으로 변환
				PiiDatabaseVO dbArcVO2 = databaseMapper.read("DLMARC");
				stmt = conn.createStatement();
				stmtArc = connArc.createStatement();
				List<PiiTableNewArcTabVO> newArcTabVOList = getListNewArcTabCols(cri);
				for (PiiTableNewArcTabVO newArcTabVO : newArcTabVOList) {
					String colsSql = SqlUtil.getArcTabColsCreate(ArchiveNamingService.CONFIG_TYPE_PII, dbVO.getDbtype(), piisteptable.getDb(), piisteptable.getOwner(), piisteptable.getTable_name(), newArcTabVO.getColumn_name());
					if (colsSql == null || colsSql.isEmpty()) {
						logger.warn("warn: getArcTabColsCreate returned empty for source dbtype=" + dbVO.getDbtype() + " column=" + newArcTabVO.getColumn_name());
						continue;
					}
					rs = stmt.executeQuery(colsSql);
					rs.setFetchSize(600);

					while (rs.next()) {
						// ★ ALTER TABLE DDL도 아카이브 DB 타입으로 변환
						String alterDdl = SqlUtil.getArcTabCreateSql(dbArcVO2.getDbtype(), rs.getString(1));
						LogUtil.log("INFO", "PiiTableServiceImpl registerArcTabCols ALTER DDL: " + alterDdl);
						try {
							resultcnt += stmtArc.executeUpdate(alterDdl);
						} catch (SQLException rowSizeEx) {
							if (SqlUtil.isRowSizeTooLargeError(rowSizeEx)) {
								// Row size 초과 → 추가되는 컬럼만 VARCHAR(n) → TEXT 변환 후 재시도
								String fixedDdl = SqlUtil.convertVarcharToTextForRowSize(alterDdl);
								LogUtil.log("WARN", "[ROW_SIZE_FIX] registerArcTabCols: ALTER TABLE retry with TEXT: " + newArcTabVO.getColumn_name());
								LogUtil.log("INFO", "PiiTableServiceImpl registerArcTabCols RETRY DDL: " + fixedDdl);
								JdbcUtil.close(stmtArc);
								stmtArc = connArc.createStatement();
								resultcnt += stmtArc.executeUpdate(fixedDdl);
							} else {
								throw rowSizeEx;
							}
						}
					}
				}
				conn.commit();
				connArc.commit();

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
				logger.warn("warn "+"registerArcTabCols - insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlArcInsert.toString());
				logger.warn("warn "+"registerArcTabCols -insert catalog info into TBL_PIITABLE: sqlArcInsert: "+ sqlHomeInsert.toString());

				stmtArc = connArc.createStatement();
				stmtArcIns = connArc.prepareStatement(sqlArcInsert.toString());LogUtil.log("INFO", "stmtArcIns");
				stmtArcHome = connHome.prepareStatement(sqlHomeInsert.toString());LogUtil.log("INFO", "stmtArcHome");
//				logger.warn("warn "+"registerArcTabCols - SqlUtil.getInsDlmarcPiitable(db "+SqlUtil.getInsDlmarcPiitable(ArchiveNamingService.CONFIG_TYPE_PII, dbArcVO.getDbtype(), "DLMARC", piisteptable.getOwner(), piisteptable.getTable_name()));

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
//					logger.warn("warn "+"registerArcTabCols - commit");
					connArc.commit();
					connHome.commit();
				}

			} catch(SQLException e) {
				JdbcUtil.rollback(conn);
				JdbcUtil.rollback(connArc);
				JdbcUtil.rollback(connHome);
				logger.error("PiiTableServiceImpl registerArcTabCols SQLException: " + e.getMessage(), e);
			} finally {
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
	public boolean remove(String db
			,String owner
			,String table_name
			,String column_name) {
		
		LogUtil.log("INFO", "remove...." + db +":"+ owner +":"+ table_name);
		 
		return mapper.delete(db, owner, table_name, column_name) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}
	@Override
	public int getTotalCountNewArcTab(Criteria cri) {

		LogUtil.log("INFO", "getTotalCountNewArcTab total count");
		return mapper.getTotalCountNewArcTab(cri);
	}
	@Override
	public int getTotalCountNewArcTabCols(Criteria cri) {

		LogUtil.log("INFO", "getTotalCountNewArcTabCols total count");
		return mapper.getTotalCountNewArcTabCols(cri);
	}
	@Override
	public int getTableTotal(Criteria cri) {
		
		LogUtil.log("INFO", "getTableTotal count");
		return mapper.getTableTotalCount(cri);
	}
	@Override
	public int getLayoutGapTotal(Criteria cri) {

		LogUtil.log("INFO", "getLayoutGapTotal count");
		return mapper.getLayoutGapTotalCount(cri);
	}

	@Override
	public PiiTableVO get(String db ,String owner ,String table_name ,String column_name) {
		
		 LogUtil.log("INFO", "get......" + db +":"+ owner +":"+ table_name);
		 
		 return mapper.read(db, owner, table_name, column_name);
	}

	@Override
	public List<PiiTableVO> getTable(String db	,String owner ,String table_name) {
		
		LogUtil.log("INFO", "get......" + db +":"+ owner +":"+ table_name);
		
		return mapper.readTable(db, owner, table_name);
	}
	
	@Override
	public int getTableCnt(String db, String owner ,String table_name) {
		
		LogUtil.log("INFO", "getTableCnt......" + db +":"+ owner +":"+ table_name);
		
		return mapper.getTableCnt(db, owner, table_name);
	}
	
	@Override
	@Transactional
	public boolean modify(PiiTableVO piitable) {
		
		LogUtil.log("INFO", "modify......" + piitable);
		
		return mapper.update(piitable) == 1;
	}


}
