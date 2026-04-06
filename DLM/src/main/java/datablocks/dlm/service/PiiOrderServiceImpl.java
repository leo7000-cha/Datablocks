package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.exception.OrderDupException;
import datablocks.dlm.mapper.*;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiOrderServiceImpl implements PiiOrderService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderServiceImpl.class);
	@Autowired
	private PiiStepMapper stepMapper;
	@Autowired
	private PiiOrderStepMapper orderstepMapper;
	@Autowired
	private PiiStepTableMapper steptableMapper;

	@Autowired
	private PiiOrderJobWaitMapper orderjobwaitMapper;

	@Autowired
	private PiiOrderStepTableWaitMapper ordersteptablewaitMapper;

	@Autowired
	private PiiOrderStepTableUpdateMapper ordersteptableudpateMapper;

	@Autowired
	private PiiOrderThreadMapper threadMapper;

	@Autowired
	private PiiDatabaseMapper databaseMapper;

	@Autowired
	private PiiJobMapper jobMapper;
	@Autowired
	private PiiOrderMapper orderMapper;
	@Autowired
	private PiiConfigMapper configMapper;
	@Autowired
	private PiiOrderStepTableMapper ordersteptableMapper;
	@Autowired
	private PiiJobWaitMapper jobwaitMapper;

	@Autowired
	private PiiStepTableWaitMapper steptablewaitMapper;

	@Autowired
	private PiiStepTableUpdateMapper steptableupdateMapper;
	@Autowired
	private PiiPolicyMapper policyMapper;
	@Autowired
	private InnerStepMapper innerStepMapper;

	@Autowired
	private PiiBizDayMapper bizdayMapper;

	@Autowired
	private ArchiveNamingService archiveNamingService;


	@Override
	public List<PiiOrderVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		return orderMapper.getList();
	}
	
	@Override
	public List<PiiOrderVO> getRunableList() {

		LogUtil.log("INFO", "getRunableList: " );
		return orderMapper.getRunableList();
	}

	
	@Override
	public List<PiiOrderVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return orderMapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiOrderVO> getListDetail(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return orderMapper.getListWithPagingDetail(cri);
	}

	@Override
	@Transactional
	public void register(PiiOrderVO piiorder) {
		
		 LogUtil.log("INFO", "register......" + piiorder);

		orderMapper.insert(piiorder);
		 }
		 
	@Override
	@Transactional
	public boolean remove(int orderid) {

		LogUtil.log("INFO", "remove...." + orderid);
		// SOURCE DB의 TMP 테이블 선 DROP (innerstep 삭제 전)
		dropOrphanTmpTablesForOrder(orderid);

		threadMapper.delete(orderid);
		ordersteptableudpateMapper.deletebyorderid(orderid);
		ordersteptablewaitMapper.deletebyorderid(orderid);
		orderjobwaitMapper.deletebyorderid(orderid);
		ordersteptableMapper.deletebyorderid(orderid);
		orderstepMapper.deletebyorderid(orderid);
		innerStepMapper.deletebyorderid(orderid);
		return orderMapper.delete(orderid) == 1;
	}

	private void dropOrphanTmpTablesForOrder(int orderid) {
		try {
			// innerstep에서 step 10 레코드 중 step 40이 없는 건 조회
			List<InnerStepVO> orphans = innerStepMapper.getOrphanedTmpSteps();
			if (orphans == null || orphans.isEmpty()) return;

			AES256Util aes = new AES256Util();

			for (InnerStepVO orphan : orphans) {
				if (orphan.getOrderid() != orderid) continue;

				try {
					PiiOrderStepTableVO stepTable = ordersteptableMapper.readWithSeq(
							orphan.getOrderid(), orphan.getStepid(),
							orphan.getSeq1(), orphan.getSeq2(), orphan.getSeq3());
					if (stepTable == null) continue;

					PiiDatabaseVO dbVO = databaseMapper.read(stepTable.getDb());
					if (dbVO == null) continue;

					try (Connection conn = ConnectionProvider.getConnection(
							dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(),
							dbVO.getId_type(), dbVO.getId(), dbVO.getDb(),
							dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()))) {

						String tableName = stepTable.getTable_name();
						// new naming: X_{orderid}_{tableName}
						SqlUtil.dropTable(conn, dbVO.getDbtype(), "COTDL",
								SqlUtil.makeTmpTableName(tableName, orderid));
						// old naming fallback: {tableName}{orderid}
						SqlUtil.dropTable(conn, dbVO.getDbtype(), "COTDL",
								tableName + orderid);
					}
				} catch (Exception e) {
					LogUtil.log("WARN", "[TMP-CLEANUP] Failed for orderid=" + orderid
							+ " stepid=" + orphan.getStepid() + ": " + e.getMessage());
				}
			}
		} catch (Exception e) {
			LogUtil.log("WARN", "[TMP-CLEANUP] TMP cleanup failed: orderid=" + orderid + ": " + e.getMessage());
			// best-effort: SOURCE DB 접속 실패해도 order 삭제는 정상 진행
		}
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return orderMapper.getTotalCount(cri);
	}
	@Override
	public int getRecoveredCntWithJobidBasedate(String jobid,String basedate) {
		
		LogUtil.log("INFO", "getRecoveredCntWithJobidBasedate");
		return orderMapper.getRecoveredCntWithJobidBasedate(jobid,basedate);
	}
    @Override
	public int getMaxOrderid() {

		LogUtil.log("INFO", "getMaxOrderid");
		return orderMapper.getMaxOrderid();
	}
	@Override
	public int getRunableListCnt() {

		LogUtil.log("INFO", "getRunableListCnt");
		return orderMapper.getRunableListCnt();
	}
	@Override
	public List<PiiOrderVO> getRestorableList(String custid) {

		LogUtil.log("INFO", "getRestorableList");
		return orderMapper.getRestorableList(custid);
	}
	@Override
	public List<PiiStepVO> getRestoreStepArcList(String custid) {

		LogUtil.log("INFO", "getRestoreStepArcList");
		return orderMapper.getRestoreStepArcList(custid);
	}
	@Override
	public int getSameOrderCnt(String jobid, String version, String basedate) {

		LogUtil.log("INFO", "getSameOrderCnt");
		return orderMapper.getSameOrderCnt(jobid, version, basedate);
	}
	@Override
	public int getSteptypeCnt(int orderid, String steptype) {

		LogUtil.log("INFO", "getSteptypeCnt");
		return orderMapper.getSteptypeCnt(orderid, steptype);
	}
	@Override
	public PiiOrderVO get(int orderid) {
		
		 LogUtil.log("INFO", "get......" + orderid);
		 
		 return orderMapper.read(orderid);
	}
	@Override
	public PiiOrderVO getMaxOrderOkByJobid(String jobid) {
		
		LogUtil.log("INFO", "get......" + jobid);
		
		return orderMapper.readMaxOrderOkByJobid(jobid);
	}
	@Override
	public PiiOrderRunRusultStatVO getRunResultStat() {
		
		LogUtil.log("INFO", "getRunResultRtat......" );
		
		return orderMapper.readrunresultstat();
	}

	@Override
	@Transactional
	public boolean modify(PiiOrderVO piiorder) {
		
		LogUtil.log("INFO", "modify......" + piiorder);
		
		return orderMapper.update(piiorder) == 1;
	}
	@Override
	public boolean updatebefore(int orderid) {

		LogUtil.log("INFO", "updatebefore......" + orderid);

		return orderMapper.updatebefore(orderid) == 1;
	}
	@Override
	public boolean updateend(int orderid) {

		LogUtil.log("INFO", "updateend......" + orderid);

		return orderMapper.updateend(orderid) == 1;
	}
	@Override
	@Transactional
	public boolean updatestatus(int orderid, String status) {

		LogUtil.log("INFO", "updatestatus......" + orderid+" "+status);

		return orderMapper.updatestatus(orderid, status) == 1;
	}

	@Override
	@Transactional
	public boolean updateactionflag(PiiOrderVO piiorder) {
		
		LogUtil.log("INFO", "updateactionflag......" + piiorder);
		
		return orderMapper.updateactionflag(piiorder) == 1;
	}

	@Override
	@Transactional
	public boolean rerun(int orderid) {
		
		LogUtil.log("INFO", "rerun......" + orderid);
		
		return orderMapper.rerun(orderid) == 1;
	}

	@Override
	public List<PiiOrderJobVO> getOrderJobList() {

		LogUtil.log("INFO", "getOrderJobList List with criteria: " );

		return orderMapper.getOrderJobList();
	}

	@Transactional
	public int orderOneJob(String jobid, String version, String basedate, String rundate) {

		PiiOrderVO piiorderVO = new PiiOrderVO();
		PiiOrderStepVO piiorderstepVO = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptableVO = new PiiOrderStepTableVO();
		PiiOrderJobWaitVO piiorderjobwaitVO = new PiiOrderJobWaitVO();
		PiiOrderStepTableWaitVO piiordersteptablewaitVO = new PiiOrderStepTableWaitVO();
		PiiOrderStepTableUpdateVO piiordersteptableupdateVO = new PiiOrderStepTableUpdateVO();

		PiiJobVO piijob = jobMapper.read(jobid, version);
		if(!"SYNC".equalsIgnoreCase(piijob.getJobtype())) {
			if (orderMapper.getSameOrderCnt(jobid, version, basedate) > 0)
				throw new OrderDupException("It's already been ordered by that date");
		}

		int newOrderId = orderMapper.getMaxOrderid() + 1;

		try {
			String currentOrderIdValue = configMapper.read("DLM_CURRENT_ORDERID").getValue();
			int maxOrderId = Integer.parseInt(currentOrderIdValue) + 1;
			newOrderId = Math.max(newOrderId, maxOrderId);
		} catch (NullPointerException ex) {
			logger.warn("DLM_CURRENT_ORDERID is not defined in config tables. Using default order ID: " + newOrderId);
		} finally {
			configMapper.updateVal("DLM_CURRENT_ORDERID", String.valueOf(newOrderId));
		}

		PiiPolicyVO piipolicy;

		String wherestr = "";
		String sqlstr = "";

		Date today = new Date();
		String basedate_ymd = basedate.replace("/", "");

		LogUtil.log("INFO", "basedate"+basedate+"rundate"+rundate);
		piiorderVO.setOrderid(newOrderId);
		piiorderVO.setBasedate(basedate);
		piiorderVO.setRuncnt(0);
		piiorderVO.setJobid(piijob.getJobid());
		piiorderVO.setVersion(piijob.getVersion());
		piiorderVO.setJobname(piijob.getJobname());
		piiorderVO.setSystem(piijob.getSystem());
		piiorderVO.setPolicy_id(piijob.getPolicy_id());
		piiorderVO.setKeymap_id(piijob.getKeymap_id());
		piiorderVO.setJobtype(piijob.getJobtype());
		piiorderVO.setRuntype(piijob.getRuntype());
		piiorderVO.setCalendar(piijob.getCalendar());
		piiorderVO.setTime(piijob.getTime());
		piiorderVO.setStatus("Wait condition");

		if (orderMapper.getRecoveredCntWithJobidBasedate(piijob.getJobid(), basedate) == 0) {LogUtil.log("INFO", "getRecoveredCntWithJobidBasedate111111111111111"+basedate+"rundate"+rundate);
			piiorderVO.setConfirmflag(piijob.getConfirmflag());
		} else {
			piiorderVO.setConfirmflag("Y");LogUtil.log("INFO", "getRecoveredCntWithJobidBasedate222222222"+basedate+"rundate"+rundate);
		}
		piiorderVO.setHoldflag("N");
		piiorderVO.setForceokflag("N");
		piiorderVO.setKillflag("N");
		String jobTime = StrUtil.checkString(piijob.getTime()) ? "00:00" : piijob.getTime();
		piiorderVO.setEststarttime(rundate + " " + jobTime + ":00");
		piiorderVO.setRunningtime(" ");
		piiorderVO.setRealstarttime(" ");
		piiorderVO.setRealendtime(" ");
		piiorderVO.setJob_owner_id1(piijob.getJob_owner_id1());
		piiorderVO.setJob_owner_name1(piijob.getJob_owner_name1());
		piiorderVO.setJob_owner_id2(piijob.getJob_owner_id2());
		piiorderVO.setJob_owner_name2(piijob.getJob_owner_name2());
		piiorderVO.setJob_owner_id3(piijob.getJob_owner_id3());
		piiorderVO.setJob_owner_name3(piijob.getJob_owner_name3());

		piiorderVO.setOrderdate(" ");
		piiorderVO.setOrderuserid(piijob.getReguserid());
		orderMapper.insert(piiorderVO);
		LogUtil.log("INFO", "2");
		List<PiiStepVO> steplist = stepMapper.getJobList(piijob.getJobid(), piijob.getVersion());
		for (PiiStepVO piistep : steplist) {
			if (piistep.getStatus().equals("INACTIVE"))
				continue;
			LogUtil.log("INFO", "!@#$ piistep.toString : " + piistep.toString());
			piiorderstepVO.setOrderid(newOrderId);

			if (piistep.getStatus().equals("HOLD"))
				piiorderstepVO.setStatus("Hold");
			else
				piiorderstepVO.setStatus("Wait condition");

			piiorderstepVO.setConfirmflag("N");
			piiorderstepVO.setHoldflag("N");
			piiorderstepVO.setForceokflag("N");
			piiorderstepVO.setKillflag("N");
			piiorderstepVO.setBasedate(basedate);
			piiorderstepVO.setThreadcnt(piistep.getThreadcnt());
			piiorderstepVO.setCommitcnt(piistep.getCommitcnt());
			piiorderstepVO.setRuncnt("0");
			piiorderstepVO.setJobid(piistep.getJobid());
			piiorderstepVO.setVersion(piistep.getVersion());
			piiorderstepVO.setStepid(piistep.getStepid());
			piiorderstepVO.setStepname(piistep.getStepname());
			piiorderstepVO.setSteptype(piistep.getSteptype());
			piiorderstepVO.setStepseq(piistep.getStepseq());
			piiorderstepVO.setDb(piistep.getDb());
			piiorderstepVO.setTotaltabcnt("" + steptableMapper.getTotalTabCnt(piijob.getJobid(), piijob.getVersion(), piistep.getStepid()));
			piiorderstepVO.setSuccesstabcnt("0");
			piiorderstepVO.setRunningtime(" ");
			piiorderstepVO.setRealstarttime(" ");
			piiorderstepVO.setRealendtime(" ");
			piiorderstepVO.setOrderuserid(piijob.getReguserid());
			/** 20231004 scramble 관련 추가*/
			piiorderstepVO.setData_handling_method(piistep.getData_handling_method());
			piiorderstepVO.setProcessing_method(piistep.getProcessing_method());
			piiorderstepVO.setFk_disable_flag(piistep.getFk_disable_flag());
			piiorderstepVO.setIndex_unusual_flag(piistep.getIndex_unusual_flag());
			piiorderstepVO.setVal1(piistep.getVal1());
			piiorderstepVO.setVal2(piistep.getVal2());
			piiorderstepVO.setVal3(piistep.getVal3());
			piiorderstepVO.setVal4(piistep.getVal4());
			piiorderstepVO.setVal5(piistep.getVal5());
			orderstepMapper.insert(piiorderstepVO);

			List<PiiStepTableVO> steptablelist = steptableMapper.getJobStepTableList(piijob.getJobid(), piijob.getVersion(), piistep.getStepid());
			for (PiiStepTableVO piisteptable : steptablelist) {
				//LogUtil.log("INFO","!@#$ piisteptable.toString : " + piisteptable.toString());
				piiordersteptableVO.setOrderid(newOrderId);
				piiordersteptableVO.setStatus("Wait condition");
				piiordersteptableVO.setForceokflag("N");
				piiordersteptableVO.setBasedate(basedate);
				piiordersteptableVO.setJobid(piistep.getJobid());
				piiordersteptableVO.setVersion(piistep.getVersion());
				piiordersteptableVO.setStepid(piistep.getStepid());
				piiordersteptableVO.setStepname(piistep.getStepname());
				piiordersteptableVO.setSteptype(piistep.getSteptype());
				piiordersteptableVO.setStepseq(piistep.getStepseq());
				piiordersteptableVO.setDb(piisteptable.getDb());
				piiordersteptableVO.setOwner(piisteptable.getOwner());
				piiordersteptableVO.setTable_name(piisteptable.getTable_name());
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPagitype())) {
						piiordersteptableVO.setPagitype(piisteptable.getPagitype());
					}else {
						piiordersteptableVO.setPagitype(piistep.getFk_disable_flag());
					}
					if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
						piiordersteptableVO.setPagitypedetail(piisteptable.getPagitypedetail());
					}else {
						piiordersteptableVO.setPagitypedetail(piistep.getIndex_unusual_flag());
					}
				}else {
					piiordersteptableVO.setPagitype(piisteptable.getPagitype());
					piiordersteptableVO.setPagitypedetail(piisteptable.getPagitypedetail());
				}
				piiordersteptableVO.setExetype(piisteptable.getExetype());
				piiordersteptableVO.setArchiveflag(piisteptable.getArchiveflag());
				if (piistep.getSteptype().equals("GEN_KEYMAP")) {// Exceptionallly used for GEN_KEYMAP step
					piiordersteptableVO.setPreceding(piisteptable.getKeymap_id());
					piiordersteptableVO.setSuccedding(piisteptable.getKey_name());
				}
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPreceding())) {
						piiordersteptableVO.setPreceding(piisteptable.getPreceding());
					}else {
						piiordersteptableVO.setPreceding(piistep.getData_handling_method());
					}
					if (!StrUtil.checkString(piisteptable.getSuccedding())) {
						piiordersteptableVO.setSuccedding(piisteptable.getSuccedding());
					}else {
						piiordersteptableVO.setSuccedding(piistep.getProcessing_method());
					}
				}
				piiordersteptableVO.setSeq1(piisteptable.getSeq1());
				piiordersteptableVO.setSeq2(piisteptable.getSeq2());
				piiordersteptableVO.setSeq3(piisteptable.getSeq3());
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPipeline())) {
						piiordersteptableVO.setPipeline(piisteptable.getPipeline());
					}else {
						piiordersteptableVO.setPipeline(piistep.getVal1());
					}
				}else {
					piiordersteptableVO.setPipeline(piisteptable.getPipeline());
				}
				piiordersteptableVO.setPk_col(piisteptable.getPk_col());
				piiordersteptableVO.setWhere_col(piisteptable.getWhere_col());
				piiordersteptableVO.setWhere_key_name(piisteptable.getWhere_key_name());
				piiordersteptableVO.setParallelcnt(piisteptable.getParallelcnt());

//				logger.warn("warn "+"^^^ piisteptable.getCommitcnt() : " + piisteptable.getTable_name() +":"+ piisteptable.getCommitcnt() + " piistep.getCommitcnt() : " + piistep.getCommitcnt());
				if (piisteptable.getCommitcnt() == null || piisteptable.getCommitcnt().length() == 0) {
					piiordersteptableVO.setCommitcnt(piistep.getCommitcnt());
				} else {
					piiordersteptableVO.setCommitcnt(piisteptable.getCommitcnt());
				}

				String dbtype;
				try {
					dbtype = databaseMapper.read(piisteptable.getDb()).getDbtype();
				} catch (Exception ex) {
					logger.warn("warn "+"piisteptable.getDb()=>" + piisteptable.getDb() + "  " + ex.getMessage());
					throw ex;
				}
				String del_deadline = "NULL";
				String arc_del_deadline = "NULL";
				String del_deadline_unit = "NULL";
				String arc_del_deadline_unit = "NULL";

				if (piijob.getJobtype().equalsIgnoreCase("PII")) {
					piipolicy = policyMapper.readCurrent(piijob.getPolicy_id());
					del_deadline_unit = piipolicy.getDel_deadline_unit();
					arc_del_deadline_unit = piipolicy.getArc_del_deadline_unit();
					//Transformation by DB Type
					logger.info(dbtype +" : "+ del_deadline_unit +" : "+ piipolicy.getDel_deadline() +" : "+ bizdayMapper.getDeadline(basedate_ymd, piipolicy.getDel_deadline()));
					del_deadline = SqlUtil.getDelDeadlineDate(dbtype, del_deadline_unit, piipolicy.getDel_deadline(), bizdayMapper.getDeadline(basedate_ymd, piipolicy.getDel_deadline()));
					logger.info(dbtype +" : del_deadline="+del_deadline);
					if(piijob.getPolicy_id().equalsIgnoreCase("PII_POLICY3")) {
						arc_del_deadline = SqlUtil.getArcDelDeadlineDatePolicy3(dbtype, piipolicy.getArchive_flag(), arc_del_deadline_unit, piipolicy.getArc_del_deadline(), bizdayMapper.getArcDeadline(basedate_ymd, piipolicy.getArc_del_deadline()));
					}else{
						arc_del_deadline = SqlUtil.getArcDelDeadlineDate(dbtype, piipolicy.getArchive_flag(), arc_del_deadline_unit, piipolicy.getArc_del_deadline(), bizdayMapper.getArcDeadline(basedate_ymd, piipolicy.getArc_del_deadline()));
					}
				}

				try {
					wherestr = piisteptable.getWherestr();
					if (!StrUtil.checkString(wherestr)) {
						if (!StrUtil.checkString(del_deadline))
							wherestr = wherestr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
						if (!StrUtil.checkString(arc_del_deadline))
							wherestr = wherestr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
						if (!StrUtil.checkString(piistep.getDb()))
							wherestr = wherestr.replaceAll("(?i)#DATABASEID", piistep.getDb());
						if (!StrUtil.checkString(piijob.getKeymap_id()))
							wherestr = wherestr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());

						/** keymap에 이미 영구파기일이 extract 테이블에서부터 세팅 되어 있어서 아래부분 필요없음, 특히 소급 파기서 문제됨 20231208*/
						/*//테이블별 별도 영구파기 기한 반영 20220114 by Cha
						if (piisteptable.getExetype().equals("ARCHIVE") || piisteptable.getExetype().equals("UPDATE") || piisteptable.getExetype().equals("DELETE")) {
							if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
								wherestr = wherestr.replaceAll("(?i)B.EXPECTED_ARC_DEL_DATE", SqlUtil.getArcDelDeadlineDate(dbtype, "Y", "M", piisteptable.getPagitypedetail(), ""));
							}
						}*/

						try {
							if (!StrUtil.checkString( EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT")))
								wherestr = wherestr.replaceAll("(?i)#DLM_EXTRACT_MAX_CNT",  EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT"));
						} catch (NullPointerException ex) {

						}
						wherestr = wherestr.replaceAll("(?i)#BASEDATEYMD", basedate_ymd);
						wherestr = wherestr.replaceAll("(?i)#BASEDATE", basedate);
						wherestr = wherestr.replaceAll("(?i)#ORDERID", newOrderId + "");
						wherestr = wherestr.replaceAll("(?i)#JOBID", piistep.getJobid());
						wherestr = wherestr.replaceAll("(?i)#STEPID", piistep.getStepid());
						wherestr = wherestr.replaceAll("(?i)#DBNAME", piisteptable.getDb());// 20220517 for Catalog batch
					}
				} catch (NullPointerException ex) {
					logger.warn("warn "+"Wherestr is NULL => NullPointerException: "+piiordersteptableVO.getJobid()+" "+piiordersteptableVO.getTable_name());
					ex.printStackTrace();
					throw ex;
				}

				//BROADCAST의 경우만 step의 원천db 정보를 읽고 그 외는 모두 테이블레벨의 db 정보를 읽는데 위에서 이미 세팅되었다.
				if (piisteptable.getExetype().equals("BROADCAST")) {
					dbtype = databaseMapper.read(piiorderstepVO.getDb()).getDbtype();
				}

				wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

				piiordersteptableVO.setWherestr(wherestr);
				try {
					sqlstr = piisteptable.getSqlstr();
					if (!StrUtil.checkString(sqlstr)) {
						if (!StrUtil.checkString(del_deadline))
							sqlstr = sqlstr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
						if (!StrUtil.checkString(arc_del_deadline))
							sqlstr = sqlstr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
						if (!StrUtil.checkString(piistep.getDb()))
							sqlstr = sqlstr.replaceAll("(?i)#DATABASEID", piistep.getDb());
						if (!StrUtil.checkString(piijob.getKeymap_id()))
							sqlstr = sqlstr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());
						/** keymap에 이미 영구파기일이 extract 테이블에서부터 세팅 되어 있어서 아래부분 필요없음, 특히 소급 파기서 문제됨 20231208*/
						/*//테이블별 별도 영구파기 기한 반영 20220114 by Cha
						if (piisteptable.getExetype().equals("ARCHIVE") || piisteptable.getExetype().equals("UPDATE") || piisteptable.getExetype().equals("DELETE")) {
							if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
								sqlstr = sqlstr.replaceAll("(?i)B.EXPECTED_ARC_DEL_DATE", SqlUtil.getArcDelDeadlineDate(dbtype, "Y", "M", piisteptable.getPagitypedetail(), ""));
							}
						}*/

						try {
							if (!StrUtil.checkString( EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT")))
								sqlstr = sqlstr.replaceAll("(?i)#DLM_EXTRACT_MAX_CNT",  EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT"));
						} catch (NullPointerException ex) {
							logger.warn("warn "+"DLM_EXTRACT_MAX_CNT NullPointerException " + ex.toString());
						}

						sqlstr = sqlstr.replaceAll("(?i)#BASEDATE", basedate);
						sqlstr = sqlstr.replaceAll("(?i)#ORDERID", newOrderId + "");
						sqlstr = sqlstr.replaceAll("(?i)#JOBID", piistep.getJobid());
						sqlstr = sqlstr.replaceAll("(?i)#STEPID", piistep.getStepid());
						sqlstr = sqlstr.replaceAll("(?i)#DBNAME", piisteptable.getDb());// 20220517 for Catalog batch
					}
				} catch (NullPointerException ex) {
					logger.warn("warn "+"Sqlstr is NULL => NullPointerException: " + piiordersteptableVO.getJobid() + " " + piiordersteptableVO.getTable_name());
					ex.printStackTrace();
					throw ex;
				}
				sqlstr = SqlUtil.convertDateformat(dbtype, sqlstr);
				piiordersteptableVO.setSqlstr(sqlstr);

				//20210423 Add hint by cha
				if (piistep.getSteptype().equals("GEN_KEYMAP") || piistep.getSteptype().equals("EXE_ARCHIVE") || piistep.getSteptype().equals("EXE_DELETE") || piistep.getSteptype().equals("EXE_UPDATE")) {
					String hint = "";
					String joinHint = null;

					// 1. ConfigKey 결정
					if (piiordersteptableVO.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP B")) {
						joinHint = EnvConfig.getConfig("DLM_KEYMAP_JOIN_HINT");
					} else if (piiordersteptableVO.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP_HIST B")) {
						joinHint = EnvConfig.getConfig("DLM_KEYMAP_HIST_JOIN_HINT");
					}

					// 2. joinHint 처리
					if (!StrUtil.checkString(joinHint)) {
						hint = joinHint.replace("/*+", "").replace("*/", "").trim();
					}

					// 3. 병렬 처리 힌트 추가
					if (!StrUtil.checkString(piisteptable.getParallelcnt())) {
						hint += " parallel(" + piisteptable.getParallelcnt().replace("/*+", "").replace("*/", "").trim() + ")";
					}

					// 4. 추가 선택 힌트 처리
					if (!StrUtil.checkString(piisteptable.getHintselect())) {
						hint += " " + piisteptable.getHintselect().replace("/*+", "").replace("*/", "").trim();
					}

					// 5. 최종 힌트 포맷팅 및 SQL 업데이트
					if (!StrUtil.checkString(hint)) {
						hint = "/*+ " + hint + " */";
						String replacement = "SELECT " + hint + " ";

						piiordersteptableVO.setWherestr(
								piiordersteptableVO.getWherestr().replaceFirst("(?i)SELECT ", replacement)
						);
						piiordersteptableVO.setSqlstr(
								piiordersteptableVO.getSqlstr().replaceFirst("(?i)SELECT ", replacement)
						);
					}
				}
				//LogUtil.log("INFO", "5");
				// Arc fields are not used
//	        	piiordersteptableVO.setArccnt(null);
//	        	piiordersteptableVO.setArctime(null);
//	        	piiordersteptableVO.setArcstart(null);
//	        	piiordersteptableVO.setArcend(null);

				piiordersteptableVO.setExecnt("0");
				piiordersteptableVO.setExetime(null);
				piiordersteptableVO.setExestart(null);
				piiordersteptableVO.setExeend(null);
				piiordersteptableVO.setSqlmsg(null);

				/** Target이 입력되지 않은 default 인 경우는...... step의 TargetDB 정보와   piisteptable의 owner, table_name 정보를 세팅한다. 20240123  */
				if (piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {
					if(StrUtil.checkString(piisteptable.getWhere_col())) {
						piiordersteptableVO.setWhere_col(piistep.getDb());
						piiordersteptableVO.setWhere_key_name(piisteptable.getOwner());
						piiordersteptableVO.setSqlstr(piisteptable.getTable_name());
					}
				}
				/* 20250302 added*/
				piiordersteptableVO.setHintselect(piisteptable.getHintselect());
				piiordersteptableVO.setHintinsert(piisteptable.getHintinsert());
				String uval1 = piisteptable.getUval1();
				String processedVal1 = ""; // 초기화

				if (uval1 != null) {
					processedVal1 = uval1.replaceAll("(?i)#BASEDATE", basedate);
				} else {
					// null일 경우 처리 로직 (예: 빈 문자열 또는 특정 기본값 할당)
					processedVal1 = "";
				}
				piiordersteptableVO.setUval1(processedVal1);
				/** Create tmp 작업 시 parallel hit max 값을 지정한다.*/
				piiordersteptableVO.setUval2(piistep.getVal2());
				piiordersteptableVO.setUval3(piisteptable.getUval3());
				piiordersteptableVO.setUval4(piisteptable.getUval4());
				piiordersteptableVO.setUval5(piisteptable.getUval5());
				ordersteptableMapper.insert(piiordersteptableVO);
			}
		}
		//-------order wait tables----------------------------------------------------------------------
		List<PiiJobWaitVO> jobwaitlist = jobwaitMapper.getList(piijob.getJobid(), piijob.getVersion());
		for (PiiJobWaitVO piijobwait : jobwaitlist) {
			piiorderjobwaitVO.setOrderid(newOrderId);
			piiorderjobwaitVO.setJobid(piijobwait.getJobid());
			piiorderjobwaitVO.setVersion(piijobwait.getVersion());
			piiorderjobwaitVO.setType(piijobwait.getType());
			piiorderjobwaitVO.setJobid_w(piijobwait.getJobid_w());
			piiorderjobwaitVO.setJobname_w(piijobwait.getJobname_w());

			orderjobwaitMapper.insert(piiorderjobwaitVO);
		}
		List<PiiStepTableWaitVO> steptablewaitlist = steptablewaitMapper.getJobList(piijob.getJobid(), piijob.getVersion());
		for (PiiStepTableWaitVO steptablewait : steptablewaitlist) {
			piiordersteptablewaitVO.setOrderid(newOrderId);
			piiordersteptablewaitVO.setJobid(steptablewait.getJobid());
			piiordersteptablewaitVO.setVersion(steptablewait.getVersion());
			piiordersteptablewaitVO.setStepid(steptablewait.getStepid());
			piiordersteptablewaitVO.setDb(steptablewait.getDb());
			piiordersteptablewaitVO.setOwner(steptablewait.getOwner());
			piiordersteptablewaitVO.setTable_name(steptablewait.getTable_name());
			piiordersteptablewaitVO.setType(steptablewait.getType());
			piiordersteptablewaitVO.setDb_w(steptablewait.getDb_w());
			piiordersteptablewaitVO.setOwner_w(steptablewait.getOwner_w());
			piiordersteptablewaitVO.setTable_name_w(steptablewait.getTable_name_w());

			ordersteptablewaitMapper.insert(piiordersteptablewaitVO);
		}
		List<PiiStepTableUpdateVO> steptableupdatelist = steptableupdateMapper.getJobList(piijob.getJobid(), piijob.getVersion());
		for (PiiStepTableUpdateVO steptableupdate : steptableupdatelist) {
			piiordersteptableupdateVO.setOrderid(newOrderId);
			piiordersteptableupdateVO.setJobid(steptableupdate.getJobid());
			piiordersteptableupdateVO.setVersion(steptableupdate.getVersion());
			piiordersteptableupdateVO.setStepid(steptableupdate.getStepid());
			piiordersteptableupdateVO.setSeq1(steptableupdate.getSeq1());
			piiordersteptableupdateVO.setSeq2(steptableupdate.getSeq2());
			piiordersteptableupdateVO.setSeq3(steptableupdate.getSeq3());
			piiordersteptableupdateVO.setColumn_name(steptableupdate.getColumn_name());
			piiordersteptableupdateVO.setUpdate_val(steptableupdate.getUpdate_val());
			piiordersteptableupdateVO.setStatus(steptableupdate.getStatus());

			ordersteptableudpateMapper.insert(piiordersteptableupdateVO);

		}
		//-----------------------------------------------------------------------------
		return newOrderId;
	}

	@Transactional
	public void orderArcdelJob(String jobid, String version, String basedate, String rundate) {
		String jobtime = "12:01";
		String threadcnt = "4";
		if (orderMapper.getSameOrderCnt(jobid, version, basedate) > 0)
			throw new OrderDupException("It's already been ordered by that date");

		try {
			String orderflag =  EnvConfig.getConfig("DLM_ORDER_FLAG");
			if (!"Y".equalsIgnoreCase(orderflag)) {
				return;
			}
		} catch (NullPointerException ex) {
		}
		try {
			String arcorderflag =  EnvConfig.getConfig("DLM_ORDER_ARCDELJOB_FLAG");
			if (!"Y".equalsIgnoreCase(arcorderflag)) {
				return;
			}
		} catch (NullPointerException ex) {
		}
		try {
			jobtime =  EnvConfig.getConfig("DLM_ARCDELJOB_TIME");
		} catch (NullPointerException ex) {
		}
		try {
			threadcnt =  EnvConfig.getConfig("DLM_ARCDELJOB_THREADCNT");
		} catch (NullPointerException ex) {
		}
		String site = null;
		try {
			site =  EnvConfig.getConfig("SITE");
		} catch (NullPointerException e) {

		}


		PiiOrderVO piiorder = new PiiOrderVO();
		PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
		PiiDatabaseVO arcDBvo = databaseMapper.read("DLMARC");
		PiiDatabaseVO dlmDBvo = databaseMapper.read("DLM");
		PiiDatabaseVO coreDBvo = databaseMapper.readBySystem("CORE");

		String jobid_new = "ARC_DATA_DELETE";
		String jobname_new = "분리보관_데이터_파기";
		int newOrderId = orderMapper.getMaxOrderid() + 1;

		try {
			String currentOrderIdValue = configMapper.read("DLM_CURRENT_ORDERID").getValue();
			int maxOrderId = Integer.parseInt(currentOrderIdValue) + 1;
			newOrderId = Math.max(newOrderId, maxOrderId);
		} catch (NullPointerException ex) {
			logger.warn("DLM_CURRENT_ORDERID is not defined in config tables. Using default order ID: " + newOrderId);
		} finally {
			configMapper.updateVal("DLM_CURRENT_ORDERID", String.valueOf(newOrderId));
		}

		int seq = 1;
		piiorder.setOrderid(newOrderId);
		piiorder.setBasedate(basedate);
		piiorder.setRuncnt(0);
		piiorder.setJobid(jobid_new);
		piiorder.setVersion("1");
		piiorder.setJobname(jobname_new);
		piiorder.setSystem("ARCHIVE_DB");
		piiorder.setKeymap_id(null);
		piiorder.setJobtype("PII");
		piiorder.setPolicy_id(null);
		piiorder.setRuntype("DLM_BATCH");
		piiorder.setCalendar("ALLDAYS");
		piiorder.setTime(jobtime);
		//piiorder.setStatus("Hold");
		piiorder.setStatus("Wait condition");
		piiorder.setConfirmflag("Y");
		piiorder.setHoldflag("N");
		piiorder.setForceokflag("N");
		piiorder.setKillflag("N");
		piiorder.setEststarttime(rundate + " " + jobtime + ":00");
		piiorder.setRunningtime(null);
		piiorder.setRealstarttime(null);
		piiorder.setRealendtime(null);
		piiorder.setJob_owner_id1(null);
		piiorder.setJob_owner_name1(null);
		piiorder.setJob_owner_id2(null);
		piiorder.setJob_owner_name2(null);
		piiorder.setJob_owner_id3(null);
		piiorder.setJob_owner_name3(null);
		piiorder.setOrderdate(null);
		piiorder.setOrderuserid(null);
		LogUtil.log("INFO", "orderMapper.insert(piiorder) => "+ piiorder.toString());
		orderMapper.insert(piiorder);

		String stepid_new = "EXE_ARC_DELETE";
		String stepname_new = "EXE_ARC_DELETE";
		String steptype_new = "EXE_ARC_DELETE";
		String exetype_new = "ARC_DELETE";

		piiorderstep.setOrderid(newOrderId);
		piiorderstep.setStatus("Wait condition");
		piiorderstep.setConfirmflag("N");
		piiorderstep.setHoldflag("N");
		piiorderstep.setForceokflag("N");
		piiorderstep.setKillflag("N");
		piiorderstep.setBasedate(basedate);
		piiorderstep.setThreadcnt(threadcnt);
		piiorderstep.setCommitcnt("3000");
		piiorderstep.setRuncnt("0");
		piiorderstep.setJobid(jobid_new);
		piiorderstep.setVersion("1");
		piiorderstep.setStepid(stepid_new);
		piiorderstep.setStepname(stepname_new);
		piiorderstep.setSteptype(steptype_new);
		piiorderstep.setStepseq("1");
		piiorderstep.setDb(arcDBvo.getDb());
		piiorderstep.setTotaltabcnt("0");
		piiorderstep.setSuccesstabcnt("0");
//        	piiorderstep.setRunningtime(" ");
//        	piiorderstep.setRealstarttime(" ");
//        	piiorderstep.setRealendtime(" ");
		piiorderstep.setOrderuserid(null);
		orderstepMapper.insert(piiorderstep);

		//JOB's all tables in EXE_ARCIVE steptype.
		List<PiiStepTableVO> steptablelist = steptableMapper.getArcStepTableList();
		for (PiiStepTableVO piisteptable : steptablelist) {
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid(stepid_new);
			piiordersteptable.setStepname(stepname_new);
			piiordersteptable.setSteptype(steptype_new);
			piiordersteptable.setStepseq("1");
			piiordersteptable.setDb(arcDBvo.getDb());
			String archiveOwner = archiveNamingService.getArchiveSchemaName(ArchiveNamingService.CONFIG_TYPE_PII, arcDBvo.getDb(), piisteptable.getOwner());
			piiordersteptable.setOwner(archiveOwner);
			piiordersteptable.setTable_name(piisteptable.getTable_name());
			piiordersteptable.setPagitype(null);
			piiordersteptable.setPagitypedetail(null);
			piiordersteptable.setExetype(exetype_new);
			piiordersteptable.setArchiveflag(null);
			piiordersteptable.setPreceding(null);
			piiordersteptable.setSuccedding(null);
			piiordersteptable.setSeq1(1);
			piiordersteptable.setSeq2(100);
			piiordersteptable.setSeq3(seq++);
			piiordersteptable.setPipeline(null);
			piiordersteptable.setPk_col(null);
			piiordersteptable.setWhere_col(null);
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			String dbtype = databaseMapper.read(piiordersteptable.getDb()).getDbtype();
			String wherestr = " pii_destruct_date <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";
			if (piiordersteptable.getExetype().equals("BROADCAST")) {
				//dbtype = databaseMapper.read("DLM").getDbtype();
				dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
			}
			wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
			piiordersteptable.setWherestr(wherestr);
			String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, arcDBvo.getDb(), piisteptable.getOwner(), piisteptable.getTable_name());
			piiordersteptable.setSqlstr("delete from " + archiveTablePath + " where " + wherestr);
			// Arc fields are not used
//	        	piiordersteptable.setArccnt(null);
//	        	piiordersteptable.setArctime(null);
//	        	piiordersteptable.setArcstart(null);
//	        	piiordersteptable.setArcend(null);

			piiordersteptable.setExecnt("0");
//	        	piiordersteptable.setExetime(null);
//	        	piiordersteptable.setExestart(null);
//	        	piiordersteptable.setExeend(null);
//	        	piiordersteptable.setSqlmsg(null);
			ordersteptableMapper.insert(piiordersteptable);

		}


		// step 2. EXE_FINISH for EXE_ARC_DELETE
		piiorderstep.setOrderid(newOrderId);
		piiorderstep.setStatus("Wait condition");
		piiorderstep.setConfirmflag("N");
		piiorderstep.setHoldflag("N");
		piiorderstep.setForceokflag("N");
		piiorderstep.setKillflag("N");
		piiorderstep.setBasedate(basedate);
		piiorderstep.setThreadcnt("1");
		piiorderstep.setCommitcnt("3000");
		piiorderstep.setRuncnt("0");
		piiorderstep.setJobid(jobid_new);
		piiorderstep.setVersion("1");
		piiorderstep.setStepid("EXE_FINISH");
		piiorderstep.setStepname("EXE_FINISH");
		piiorderstep.setSteptype("EXE_FINISH");
		piiorderstep.setStepseq("2");
		piiorderstep.setTotaltabcnt("1");
		piiorderstep.setSuccesstabcnt("0");
//	     	piiorderstep.setRunningtime(" ");
//	     	piiorderstep.setRealstarttime(" ");
//	     	piiorderstep.setRealendtime(" ");
		piiorderstep.setOrderuserid(null);
		orderstepMapper.insert(piiorderstep);

		int seq2 = 100;

		//-----STEPTABLE 1  FOR TBL_PIIEXTRACT CORE
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion("1");
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(coreDBvo.getDb());
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIEXTRACT");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(seq2);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col(null);
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		//Transformation by DB Type
		String dbtype = coreDBvo.getDbtype();
		String wherestr = " EXPECTED_ARC_DEL_DATE <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";

		piiordersteptable.setWherestr(wherestr);
		piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
						"update COTDL.TBL_PIIEXTRACT set EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
				)
		);
		LogUtil.log("INFO", piiordersteptable.getSqlstr());
		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 2  FOR TBL_PIIEXTRACT DLM
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion("1");
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(dlmDBvo.getDb());
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIEXTRACT");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		seq2 = seq2 + 100;
		piiordersteptable.setSeq2(seq2);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col(null);
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		//Transformation by DB Type
		dbtype = dlmDBvo.getDbtype();
		wherestr = " EXPECTED_ARC_DEL_DATE <= TO_DATE('" + basedate + " 23:59:59','yyyy/mm/dd HH24:MI:SS')";

		piiordersteptable.setWherestr(wherestr);
		/*하나카드 1Qnet은 CUST_PIN=null 이부분 제거 => 공통고객번호로 사용함, 그 외는 주민번호이므로 영구파기 시 삭제 20230613*/
		if("HANACARD_1Qnet".equalsIgnoreCase(site)) {
			piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
							"update COTDL.TBL_PIIEXTRACT set EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
					)
			);
		}else{
			piiordersteptable.setSqlstr(SqlUtil.convertDateformat(dbtype,
							"update COTDL.TBL_PIIEXTRACT set CUST_PIN=null, EXCLUDE_REASON='DELARC' , ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')" + " where " + wherestr + " and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
					)
			);
		}
		LogUtil.log("INFO", piiordersteptable.getSqlstr());
		ordersteptableMapper.insert(piiordersteptable);

		//-----------------------------------------------------------------------------------------------------------
		//-----STEPTABLE from SteptableETC (고객마스터 테이블 고객상태 업데이트)
		//-----------------------------------------------------------------------------------------------------------
		if(steptableMapper.readEtcCnt("ARC_DATA_DELETE","EXE_FINISH") == 1) {
			PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("ARC_DATA_DELETE", "EXE_FINISH");
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid("EXE_FINISH");
			piiordersteptable.setStepname("EXE_FINISH");
			piiordersteptable.setSteptype("EXE_FINISH");
			piiordersteptable.setStepseq("2");
			piiordersteptable.setDb(stepTableETCVO.getDb());
			piiordersteptable.setOwner(stepTableETCVO.getOwner());
			piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
			piiordersteptable.setPagitype(null);
			piiordersteptable.setPagitypedetail(null);
			piiordersteptable.setExetype("FINISH");
			piiordersteptable.setArchiveflag(null);
			piiordersteptable.setPreceding(null);
			piiordersteptable.setSuccedding(null);
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setPipeline(null);
			piiordersteptable.setWhere_col(null);
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			dbtype = databaseMapper.read(stepTableETCVO.getDb()).getDbtype();
			wherestr = "EXCLUDE_REASON='DELARC' and ARC_DEL_DATE=TO_DATE('" + basedate + "','yyyy/mm/dd')";
			wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
			String sqlstr = stepTableETCVO.getSqlstr()
					+ " (select custid from cotdl.tbl_piiextract " + " \r\n"
					+ "   where "+ wherestr + " \r\n"
					+ " )";
			piiordersteptable.setWherestr("  ");
			piiordersteptable.setSqlstr(sqlstr);
			LogUtil.log("INFO", piiordersteptable.getSqlstr());
			ordersteptableMapper.insert(piiordersteptable);
		}
		//-----------------------------------------------------------------------------------------------------------
		//-----STEPTABLE from SteptableETC (insert into TBL_PIICONTRACT  실물파기를 위한 영구파기 고객 계약정보 추출)
		//-----------------------------------------------------------------------------------------------------------
		if(steptableMapper.readEtcCnt("ARC_DATA_DELETE_CONTRACT","EXE_FINISH") == 1) {
			PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("ARC_DATA_DELETE_CONTRACT", "EXE_FINISH");
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid("EXE_FINISH");
			piiordersteptable.setStepname("EXE_FINISH");
			piiordersteptable.setSteptype("EXE_FINISH");
			piiordersteptable.setStepseq("2");
			piiordersteptable.setDb(stepTableETCVO.getDb());   // CORE에서
			piiordersteptable.setOwner(stepTableETCVO.getOwner());
			piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
			piiordersteptable.setPagitype(null);
			piiordersteptable.setPagitypedetail(null);
			piiordersteptable.setExetype("FINISH");
			piiordersteptable.setArchiveflag(null);
			piiordersteptable.setPreceding(null);
			piiordersteptable.setSuccedding(null);
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setPipeline(null);
			piiordersteptable.setWhere_col(null);
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			dbtype = databaseMapper.read(stepTableETCVO.getDb()).getDbtype();
			String sqlstr = stepTableETCVO.getSqlstr();
			sqlstr = SqlUtil.convertDateformat(dbtype, sqlstr);
			sqlstr = sqlstr.replaceAll("(?i)#BASEDATE", basedate);
			piiordersteptable.setWherestr(" ");
			piiordersteptable.setSqlstr(sqlstr);
			LogUtil.log("INFO", piiordersteptable.getSqlstr());
			ordersteptableMapper.insert(piiordersteptable);
		}
		boolean broadcaststepexist = false;
		int broadcaststepseq2 = 0;
		if(steptableMapper.readEtcCnt("ARC_DATA_DELETE_CONTRACT","EXE_FINISH") == 1) {
			PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("ARC_DATA_DELETE_CONTRACT", "EXE_FINISH");
			// step 3. EXE_BROADCAST for TBL_PIICONTRACT
			broadcaststepexist = true;
			piiorderstep.setOrderid(newOrderId);
			piiorderstep.setDb(stepTableETCVO.getDb());
			piiorderstep.setStatus("Wait condition");
			piiorderstep.setConfirmflag("N");
			piiorderstep.setHoldflag("N");
			piiorderstep.setForceokflag("N");
			piiorderstep.setKillflag("N");
			piiorderstep.setBasedate(basedate);
			piiorderstep.setThreadcnt("1");
			piiorderstep.setCommitcnt("3000");
			piiorderstep.setRuncnt("0");
			piiorderstep.setJobid(jobid_new);
			piiorderstep.setVersion("1");
			piiorderstep.setStepid("EXE_BROADCAST");
			piiorderstep.setStepname("EXE_BROADCAST");
			piiorderstep.setSteptype("EXE_BROADCAST");
			piiorderstep.setStepseq("3");
			piiorderstep.setTotaltabcnt("1");
			piiorderstep.setSuccesstabcnt("0");
			//	     	piiorderstep.setRunningtime(" ");
			//	     	piiorderstep.setRealstarttime(" ");
			//	     	piiorderstep.setRealendtime(" ");
			piiorderstep.setOrderuserid(null);
			orderstepMapper.insert(piiorderstep);

			//-----STEPTABLE 1 for insert into TBL_PIICONTRACT
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid("EXE_BROADCAST");
			piiordersteptable.setStepname("EXE_BROADCAST");
			piiordersteptable.setSteptype("EXE_BROADCAST");
			piiordersteptable.setStepseq("3");
			piiordersteptable.setDb(dlmDBvo.getDb());
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIICONTRACT");
			piiordersteptable.setPagitype(null);
			piiordersteptable.setPagitypedetail(null);
			piiordersteptable.setExetype("BROADCAST");
			piiordersteptable.setArchiveflag(null);
			piiordersteptable.setPreceding(null);
			piiordersteptable.setSuccedding(null);
			piiordersteptable.setSeq1(10);
			broadcaststepseq2 = broadcaststepseq2 + 100;
			piiordersteptable.setSeq2(broadcaststepseq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setPipeline(null);
			piiordersteptable.setWhere_col(null);
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			dbtype = coreDBvo.getDbtype();
			wherestr = "to_char(BASEDATE,'yyyy/mm/dd') = '" + basedate + "'";
			wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

			piiordersteptable.setWherestr(wherestr);
			piiordersteptable.setSqlstr(
					"INSERT INTO COTDL.TBL_PIICONTRACT\n" +
							"\tSELECT * FROM COTDL.TBL_PIICONTRACT\n" +
							"\t WHERE " + wherestr
			);
			LogUtil.log("INFO", piiordersteptable.getSqlstr());
			ordersteptableMapper.insert(piiordersteptable);
		}

		if(steptableMapper.readEtcCnt("ARC_DATA_DELETE_EDMS","EXE_BROADCAST") == 1) {
			PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("ARC_DATA_DELETE_EDMS", "EXE_BROADCAST");
			// step 3. EXE_BROADCAST for TBL_PIICONTRACT
			if(!broadcaststepexist) {
				piiorderstep.setOrderid(newOrderId);
				piiorderstep.setDb(coreDBvo.getDb());
				piiorderstep.setStatus("Wait condition");
				piiorderstep.setConfirmflag("N");
				piiorderstep.setHoldflag("N");
				piiorderstep.setForceokflag("N");
				piiorderstep.setKillflag("N");
				piiorderstep.setBasedate(basedate);
				piiorderstep.setThreadcnt("1");
				piiorderstep.setCommitcnt("3000");
				piiorderstep.setRuncnt("0");
				piiorderstep.setJobid(jobid_new);
				piiorderstep.setVersion("1");
				piiorderstep.setStepid("EXE_BROADCAST");
				piiorderstep.setStepname("EXE_BROADCAST");
				piiorderstep.setSteptype("EXE_BROADCAST");
				piiorderstep.setStepseq("3");
				piiorderstep.setTotaltabcnt("1");
				piiorderstep.setSuccesstabcnt("0");
				//	     	piiorderstep.setRunningtime(" ");
				//	     	piiorderstep.setRealstarttime(" ");
				//	     	piiorderstep.setRealendtime(" ");
				piiorderstep.setOrderuserid(null);
				orderstepMapper.insert(piiorderstep);
			}
			//-----STEPTABLE 1 for insert into TBL_PIICONTRACT
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid("EXE_BROADCAST");
			piiordersteptable.setStepname("EXE_BROADCAST");
			piiordersteptable.setSteptype("EXE_BROADCAST");
			piiordersteptable.setStepseq("3");
			piiordersteptable.setDb(stepTableETCVO.getDb());
			piiordersteptable.setOwner(stepTableETCVO.getOwner());
			piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
			piiordersteptable.setPagitype(null);
			piiordersteptable.setPagitypedetail(null);
			piiordersteptable.setExetype("BROADCAST");
			piiordersteptable.setArchiveflag(null);
			piiordersteptable.setPreceding(null);
			piiordersteptable.setSuccedding(null);
			piiordersteptable.setSeq1(10);
			broadcaststepseq2 = broadcaststepseq2 + 100;
			piiordersteptable.setSeq2(broadcaststepseq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setPipeline(null);
			piiordersteptable.setWhere_col(null);
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			dbtype = coreDBvo.getDbtype();
			wherestr = stepTableETCVO.getWherestr();

			wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
			String basedate_ymd = basedate.replace("/", "");
			wherestr = wherestr.replaceAll("(?i)#BASEDATEYMD", basedate_ymd);
			wherestr = wherestr.replaceAll("(?i)#BASEDATE", basedate);
			piiordersteptable.setWherestr(wherestr);
			piiordersteptable.setSqlstr(
					"INSERT INTO COTDL.TBL_PIIKEYMAP_HIST\n" +
							"\tSELECT * FROM COTDL.TBL_PIIKEYMAP_HIST\n" +
							"\t WHERE " + wherestr
			);
//            logger.warn("warn "+piiordersteptable.getSqlstr());
			ordersteptableMapper.insert(piiordersteptable);
		}
	}

}
