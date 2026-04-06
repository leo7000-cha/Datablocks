package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiRecoveryServiceImpl implements PiiRecoveryService {
	private static final Logger logger = LoggerFactory.getLogger(PiiRecoveryServiceImpl.class);
	@Autowired
	private PiiRecoveryMapper mapper;
	@Autowired
	private PiiDatabaseMapper databaseMapper;
	@Autowired
	private PiiJobMapper jobMapper;
	@Autowired
	private PiiOrderMapper orderMapper;
	@Autowired
	private PiiConfigMapper configMapper;
	@Autowired
	private PiiOrderStepMapper orderstepMapper;
	@Autowired
	private PiiOrderStepTableUpdateMapper ordersteptableudpateMapper;
	@Autowired
	private PiiOrderStepTableMapper ordersteptableMapper;
	@Autowired
	private PiiStepTableMapper steptableMapper;
	@Autowired
	private ArchiveNamingService archiveNamingService;

	@Override
	public List<PiiRecoveryVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiRecoveryVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}
	
	@Override
	public List<PiiOrderVO> getOrderList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getOrderList(cri);
	}
	
	@Override
	public List<PiiOrderJobVO> getOrderJobListWithPaging(Criteria cri) {
		
		LogUtil.log("INFO", "getOrderJobListWithPaging List with criteria: " + cri);
		
		return mapper.getOrderJobListWithPaging(cri);
	}
	@Override
	public List<PiiOrderJobVO> getOrderJobList() {

		LogUtil.log("INFO", "getOrderJobList List with criteria: " );

		return mapper.getOrderJobList();
	}
	public List<PiiJobOrderVO> getRecoveryJobList() {

		LogUtil.log("INFO", "getRecoveryJobList List with criteria: " );

		return mapper.getRecoveryJobList();
	}

	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거
	public boolean jobregister(PiiRecoveryVO piirecovery) {

		 LogUtil.log("INFO", "jobregister......" + piirecovery);

//		 mapper.insert(piirecovery);
		 mapper.insertSelectKey(piirecovery);

		if(orderRecoveryJob(piirecovery))
			return true;
		else
			return false;
	}

	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거
	public boolean orderregister(PiiRecoveryVO piirecovery) {

		LogUtil.log("INFO", "orderregister......" + piirecovery);

//		 mapper.insert(piirecovery);
		mapper.insertSelectKey(piirecovery);

		if(orderRecoveryOrder(piirecovery))
			return true;
		else
			return false;
	}
		 
	@Override
	@Transactional
	public boolean remove(int recoveryid) {
		
		LogUtil.log("INFO", "remove...." + recoveryid);
		 
		return mapper.delete(recoveryid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiRecoveryVO get(int recoveryid) {
		
		 LogUtil.log("INFO", "get......" + recoveryid);
		 
		 return mapper.read(recoveryid);
	}
	@Override
	public PiiRecoveryVO getByOldOrderid(int old_orderid) {
		
		LogUtil.log("INFO", "getByOldOrderid......" + old_orderid);
		
		return mapper.readByOldOrderid(old_orderid);
	}
	@Override
	public PiiRecoveryVO getByNewOrderid(int new_orderid) {
		
		LogUtil.log("INFO", "getByNewOrderid......" + new_orderid);
		
		return mapper.readByNewOrderid(new_orderid);
	}

	@Override
	@Transactional
	public boolean modify(PiiRecoveryVO piirecovery) {
		
		LogUtil.log("INFO", "modify......" + piirecovery);
		
		return mapper.update(piirecovery) == 1;
	}
	@Override
	@Transactional
	public boolean modifyStatus(int orderid) {
		
		LogUtil.log("INFO", "modifyStatus......" + orderid);
		
		return mapper.updateStatus(orderid) == 1;
	}

	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거
	public boolean orderRecoveryOrder(PiiRecoveryVO piirecovery) {

		LogUtil.log("INFO", "order..recovery.." + piirecovery);
		try {
			orderRecoveryO(piirecovery);
			return true;
		} catch (Exception e) {
			return false;
		}
	}
	
	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거
	public boolean orderRecoveryJob(PiiRecoveryVO piirecovery) {

		LogUtil.log("INFO", "order..recovery.." + piirecovery);
		try {
			orderRecoveryJ(piirecovery);
			return true;
		} catch (Exception e) {
			return false;
		}
	}
	
	@Override
	@Transactional
	public boolean requestapproval(int recoveryid) {
		
		LogUtil.log("INFO", "requestapproval.....recoveryid." + recoveryid);
		return mapper.approve(recoveryid) == 1;
	}
	
	@Override
	@Transactional
	public boolean approve(int recoveryid) {
		
		LogUtil.log("INFO", "approve....recoveryid.." + recoveryid);
		return mapper.approve(recoveryid) == 1;
	}
	
	@Override
	@Transactional
	public boolean reject(int recoveryid) {
		
		LogUtil.log("INFO", "reject....recoveryid.." + recoveryid);
		return mapper.reject(recoveryid) == 1;
	}

	@Override
	public int getMaxRecoveryid() {
		
		LogUtil.log("INFO", "getMaxRecoveryid");
		return mapper.getMaxRecoveryid();
	}

	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거 (긴 작업으로 인한 Lock 유지 문제)
	public void orderRecoveryJ(PiiRecoveryVO piirecovery)  {
		Date today = new Date();
		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		SimpleDateFormat yyyymmddhms = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		String basedate = yyyymmdd.format(today);
		String curtime = yyyymmddhms.format(today);

		PiiOrderVO piiorder = new PiiOrderVO();
		PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
		String db = null;
		int oldorderid = piirecovery.getOld_orderid();
		String homeDB = "DLM";
		String homeDBType = databaseMapper.read(homeDB).getDbtype();
		//LogUtil.log("INFO", "orderMapper.read(piirecovery.getOld_orderid()) => "+ oldorderid);
		PiiJobVO piirecoveryjob = jobMapper.read(piirecovery.getOld_jobid(), piirecovery.getOld_version());

		String jobid_new = piirecovery.getNew_jobid();
		String jobname_new = piirecoveryjob.getJobname() + "_복구:All";
		String version = piirecovery.getOld_version();
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

		piiorder.setOrderid(newOrderId);
		piiorder.setBasedate(basedate);
		piiorder.setRuncnt(0);
		piiorder.setJobid(jobid_new);
		piiorder.setVersion(piirecoveryjob.getVersion());
		piiorder.setJobname(jobname_new);
		piiorder.setSystem(piirecoveryjob.getSystem());
		piiorder.setKeymap_id(piirecoveryjob.getKeymap_id());
		piiorder.setJobtype(piirecoveryjob.getJobtype());
		piiorder.setPolicy_id(piirecoveryjob.getPolicy_id());
		piiorder.setRuntype("RECOVERY");
		piiorder.setCalendar(piirecoveryjob.getCalendar());
		piiorder.setTime(piirecoveryjob.getTime());
		piiorder.setStatus("Wait condition");
		piiorder.setConfirmflag("N");
		piiorder.setHoldflag("N");
		piiorder.setForceokflag("N");
		piiorder.setKillflag("N");
		piiorder.setEststarttime(curtime);
		piiorder.setRunningtime(null);
		piiorder.setRealstarttime(null);
		piiorder.setRealendtime(null);
		piiorder.setJob_owner_id1(piirecoveryjob.getJob_owner_id1());
		piiorder.setJob_owner_name1(piirecoveryjob.getJob_owner_name1());
		piiorder.setJob_owner_id2(piirecoveryjob.getJob_owner_id2());
		piiorder.setJob_owner_name2(piirecoveryjob.getJob_owner_name2());
		piiorder.setJob_owner_id3(piirecoveryjob.getJob_owner_id3());
		piiorder.setJob_owner_name3(piirecoveryjob.getJob_owner_name3());
		piiorder.setOrderdate(null);
		piiorder.setOrderuserid(piirecovery.getReguserid());
		//LogUtil.log("INFO", "orderMapper.register(piiorder) => "+ piiorder.toString());
		orderMapper.insert(piiorder);

		String stepid_new = "EXE_RECOVERY_D";
		List<PiiOrderStepVO> ordersteplist = orderstepMapper.getOrderStepList(oldorderid);
		for (PiiOrderStepVO piirecoveryjobstep : ordersteplist) {
			if (piirecoveryjobstep.getSteptype().equalsIgnoreCase("EXE_UPDATE"))
				stepid_new = "EXE_RECOVERY_U";
		}

		Boolean extractStepExist = false;
		for (PiiOrderStepVO orderstep : ordersteplist) {
			if (orderstep.getSteptype().equalsIgnoreCase("EXE_EXTRACT")) {
				extractStepExist = true;
			}
		}

		if (stepid_new.equalsIgnoreCase("EXE_RECOVERY_U")) {
			List<PiiOrderStepTableUpdateVO> jobupdatelist = ordersteptableudpateMapper.getJobList(oldorderid, piirecovery.getOld_jobid(), piirecovery.getOld_version());
			for (int i = 0; i < jobupdatelist.size(); i++) {
				LogUtil.log("INFO", jobupdatelist.get(i).toString());
				PiiOrderStepTableUpdateVO jobupdatevo = jobupdatelist.get(i);
				jobupdatevo.setOrderid(newOrderId);
				jobupdatevo.setStepid(stepid_new);
				ordersteptableudpateMapper.insert(jobupdatevo);
			}
		}

		for (PiiOrderStepVO piirecoveryjobstep : ordersteplist) {LogUtil.log("INFO", "piiorderstep====run()==="+piirecoveryjobstep.getSteptype());
			if (!piirecoveryjobstep.getSteptype().contains("EXE_ARCHIVE")) continue;

			String stepname_new = "RECOVERY ALL";
			String steptype_new = "EXE_RECOVERY";
			String exetype_new = "RECOVERY";

			piiorderstep.setOrderid(newOrderId);
			piiorderstep.setStatus("Wait condition");
			piiorderstep.setConfirmflag("N");
			piiorderstep.setHoldflag("N");
			piiorderstep.setForceokflag("N");
			piiorderstep.setKillflag("N");
			piiorderstep.setBasedate(basedate);
			piiorderstep.setThreadcnt("3");
			piiorderstep.setCommitcnt("3000");
			piiorderstep.setRuncnt("0");
			piiorderstep.setJobid(jobid_new);
			piiorderstep.setVersion(piirecoveryjobstep.getVersion());
			piiorderstep.setStepid(stepid_new);
			piiorderstep.setStepname(stepname_new);
			piiorderstep.setSteptype(steptype_new);
			piiorderstep.setStepseq("1");
			piiorderstep.setDb(piirecoveryjobstep.getDb());
			piiorderstep.setTotaltabcnt("" + steptableMapper.getTotalTabCnt(piirecoveryjobstep.getJobid(), piirecoveryjobstep.getVersion(), piirecoveryjobstep.getStepid()));
			piiorderstep.setSuccesstabcnt("0");
//        	piiorderstep.setRunningtime(" ");
//        	piiorderstep.setRealstarttime(" ");
//        	piiorderstep.setRealendtime(" ");
			piiorderstep.setOrderuserid(piirecovery.getReguserid());
			orderstepMapper.insert(piiorderstep);

			List<PiiOrderStepTableVO> ordersteptablelist = ordersteptableMapper.getStepTableList(oldorderid, piirecoveryjobstep.getStepid());
			for (PiiOrderStepTableVO piirecoveryjobsteptable : ordersteptablelist) {
				piiordersteptable.setOrderid(newOrderId);
				piiordersteptable.setStatus("Wait condition");
				piiordersteptable.setForceokflag("N");
				piiordersteptable.setBasedate(basedate);
				piiordersteptable.setJobid(jobid_new);
				piiordersteptable.setVersion(piirecoveryjobsteptable.getVersion());
				piiordersteptable.setStepid(stepid_new);
				piiordersteptable.setStepname(stepname_new);
				piiordersteptable.setSteptype(steptype_new);
				piiordersteptable.setStepseq("1");
				piiordersteptable.setDb(piirecoveryjobsteptable.getDb());
				piiordersteptable.setOwner(piirecoveryjobsteptable.getOwner());
				piiordersteptable.setTable_name(piirecoveryjobsteptable.getTable_name());
				piiordersteptable.setPagitype(piirecoveryjobsteptable.getPagitype());
				piiordersteptable.setPagitypedetail(piirecoveryjobsteptable.getPagitypedetail());
				piiordersteptable.setExetype(exetype_new);
				piiordersteptable.setArchiveflag(piirecoveryjobsteptable.getArchiveflag());
				piiordersteptable.setPreceding(Integer.toString(piirecovery.getOld_orderid()));
				piiordersteptable.setSuccedding("");
				piiordersteptable.setSeq1(piirecoveryjobsteptable.getSeq1());
				piiordersteptable.setSeq2(piirecoveryjobsteptable.getSeq2());
				piiordersteptable.setSeq3(piirecoveryjobsteptable.getSeq3());
				piiordersteptable.setPipeline(piirecoveryjobsteptable.getPipeline());
				piiordersteptable.setPk_col(piirecoveryjobsteptable.getPk_col());
				piiordersteptable.setWhere_col(piirecoveryjobsteptable.getWhere_col());
				piiordersteptable.setWhere_key_name(piirecoveryjobsteptable.getWhere_key_name());
				piiordersteptable.setParallelcnt(null);
				piiordersteptable.setCommitcnt("3000");

				piiordersteptable.setWherestr("pii_job_id='" + piirecovery.getOld_jobid() + "'");
				String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piirecoveryjobsteptable.getDb(), piirecoveryjobsteptable.getOwner(), piirecoveryjobsteptable.getTable_name());
				if (stepid_new.equalsIgnoreCase("EXE_RECOVERY")) {
					piiordersteptable.setSqlstr("insert into " + piirecoveryjobsteptable.getOwner() + "." + piirecoveryjobsteptable.getTable_name() + " select * from " + archiveTablePath + " where " + piiordersteptable.getWherestr());
				} else if (stepid_new.equalsIgnoreCase("EXE_RECOVERY_U")) {
					piiordersteptable.setSqlstr("update " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " set #UPDATECOLS where (" + piiordersteptable.getPk_col() + ") in(select " + piiordersteptable.getPk_col() + " from " + archiveTablePath + " WHERE " + piiordersteptable.getWherestr() + " )");
				}

				ordersteptableMapper.insert(piiordersteptable);

				db = piirecoveryjobsteptable.getDb();
			}
		}
		// step 2. DELETE keymap data of the ORDERID
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
		piiorderstep.setVersion(piirecoveryjob.getVersion());
		piiorderstep.setStepid("EXE_FINISH");
		piiorderstep.setStepname("Delete keymap of the ORDERID:" + oldorderid);
		piiorderstep.setSteptype("EXE_FINISH");
		piiorderstep.setStepseq("2");
		piiorderstep.setTotaltabcnt("1");
		piiorderstep.setSuccesstabcnt("0");
//    	piiorderstep.setRunningtime(" ");
//    	piiorderstep.setRealstarttime(" ");
//    	piiorderstep.setRealendtime(" ");
		piiorderstep.setOrderuserid(piirecovery.getReguserid());
		orderstepMapper.insert(piiorderstep);

		//-----STEPTABLE 1
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion(piirecoveryjob.getVersion());
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(db);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIKEYMAP_HIST");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(100);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col("keymap_id,basedate");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		//Transformation by DB Type
		String dbtype = databaseMapper.read(piiordersteptable.getDb()).getDbtype();
		String wherestr = "keymap_id='" + piirecovery.getKeymap_id() + "'";

		wherestr = SqlUtil.convertDateformat(dbtype, wherestr);
		piiordersteptable.setWherestr(wherestr);

		piiordersteptable.setSqlstr(
				SqlUtil.convertDateformat(dbtype, "delete from " + "cotdl" + "." + "tbl_piikeymap_hist" + " \r\n"
						+ " where " + piiordersteptable.getWherestr() + " \r\n"
						)
		);
		LogUtil.log("INFO", piiordersteptable.getSqlstr());
		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 3
		piiordersteptable.setDb(homeDB);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIRECOVERY");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(300);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setWhere_col("new_orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");
		piiordersteptable.setWherestr("  ");
		piiordersteptable.setSqlstr(
				"update cotdl.tbl_piirecovery"
						+ "   set status= (select status from cotdl.tbl_piiorderstep where orderid= " + newOrderId + " and steptype='EXE_RECOVERY')"
						+ " where new_orderid = " + newOrderId
		);
		ordersteptableMapper.insert(piiordersteptable);
		LogUtil.log("INFO", piiordersteptable.getSqlstr());

		//-----STEPTABLE 4
		piiordersteptable.setDb(homeDB);// Config DB
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIORDER");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(400);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setWhere_col("new_orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");
		piiordersteptable.setWherestr("  ");
		piiordersteptable.setSqlstr(
				SqlUtil.convertDateformat(homeDBType,"update COTDL.TBL_PIIORDER" + " \r\n"
						+ " set status = 'Recovered'" + " \r\n"
						+ " where jobid = '" + piirecoveryjob.getJobid() + "'" + " \r\n"
						+ "   and basedate in ( \r\n"
						+ "                   SELECT distinct BASEDATE \r\n"
						+ "                     FROM COTDL.TBL_PIIEXTRACT \r\n"
						+ "                    where JOBID = '" + piirecoveryjob.getJobid() + "' \r\n"
						+ "                      and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
						+ "                ) "
						+ " and status not in ('Recovered','Wait condition')"
				)
		);
		ordersteptableMapper.insert(piiordersteptable);
		LogUtil.log("INFO", piiordersteptable.getSqlstr());

		int seq2 = 400;
		if(extractStepExist) {
			//-----------------------------------------------------------------------------------------------------------
			//-----STEPTABLE from SteptableETC
			//-----------------------------------------------------------------------------------------------------------
			if(steptableMapper.readEtcCnt("RECOVERY_JOB","EXE_FINISH") == 1) {
				PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("RECOVERY_JOB", "EXE_FINISH");
				piiordersteptable.setDb(stepTableETCVO.getDb());
				piiordersteptable.setOwner(stepTableETCVO.getOwner());
				piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
				piiordersteptable.setSeq1(10);
				seq2 = seq2 + 100;
				piiordersteptable.setSeq2(seq2);
				piiordersteptable.setSeq3(10);
				piiordersteptable.setWhere_col("orderid");
				piiordersteptable.setWhere_key_name(null);
				piiordersteptable.setParallelcnt(null);
				piiordersteptable.setCommitcnt("3000");
				piiordersteptable.setWherestr("  ");
				//Transformation by DB Type
				String sqlstr = stepTableETCVO.getSqlstr()
						+ " (select CUSTID from COTDL.TBL_PIIEXTRACT " + " \r\n"
						+ "   where JOBID = '" + piirecoveryjob.getJobid() + "' \r\n"
						+ "     and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null" + " \r\n"
						+ " )";
				piiordersteptable.setWherestr("  ");
				piiordersteptable.setSqlstr(sqlstr);

				ordersteptableMapper.insert(piiordersteptable);
			}
			//-----STEPTABLE 5
			piiordersteptable.setDb(db);
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIIEXTRACT");
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setWhere_col("orderid");
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");
			piiordersteptable.setWherestr("  ");
			/* Apply Archive del max date for more accurate management 20211214*/
			piiordersteptable.setSqlstr(
					SqlUtil.convertDateformat(dbtype, "delete from COTDL.TBL_PIIEXTRACT " + " \r\n"
							+ "where JOBID = '" + piirecoveryjob.getJobid() + "' \r\n"
							+ "  and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
					)
			);
			ordersteptableMapper.insert(piiordersteptable);
			LogUtil.log("INFO", piiordersteptable.getSqlstr());
			//-----STEPTABLE 6
			piiordersteptable.setDb(homeDB);
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIIEXTRACT");
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setWhere_col("orderid");
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");
			piiordersteptable.setWherestr("  ");
			/* Apply Archive del max date for more accurate management 20211214*/
			piiordersteptable.setSqlstr(
					SqlUtil.convertDateformat(homeDBType, "delete from COTDL.TBL_PIIEXTRACT " + " \r\n"
							+ "where JOBID = '" + piirecoveryjob.getJobid() + "' \r\n"
							+ "  and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
					)
			);
			ordersteptableMapper.insert(piiordersteptable);
		}
		//-----------------------------------------------------------------------------
		//update Recovery status
		piirecovery.setStatus("ORDERED");
		piirecovery.setNew_orderid(newOrderId);
		mapper.update(piirecovery);
	}

	public void orderRecoveryO(PiiRecoveryVO piirecovery) {
		Date today = new Date();
		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		//SimpleDateFormat yyyymmddhms = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		String basedate = yyyymmdd.format(today);
//		String curtime = yyyymmddhms.format(today);

		PiiOrderVO piiorder = new PiiOrderVO();
		PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();
		String db = null;
		int oldorderid = piirecovery.getOld_orderid();
		String homeDB = "DLM";
		String homeDBType = databaseMapper.read(homeDB).getDbtype();
		//LogUtil.log("INFO", "orderMapper.read(piirecovery.getOld_orderid()) => "+ oldorderid);
		PiiOrderVO piirecoveryorder = orderMapper.read(oldorderid);

		String jobid_new = piirecoveryorder.getJobid() + "_Recovery:" + oldorderid;
		String jobname_new = piirecoveryorder.getJobname() + "_복구:" + oldorderid;
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

		piiorder.setOrderid(newOrderId);
		piiorder.setBasedate(piirecoveryorder.getBasedate());
		piiorder.setRuncnt(0);
		piiorder.setJobid(jobid_new);
		piiorder.setVersion(piirecoveryorder.getVersion());
		piiorder.setJobname(jobname_new);
		piiorder.setSystem(piirecoveryorder.getSystem());
		piiorder.setKeymap_id(piirecoveryorder.getKeymap_id());
		piiorder.setJobtype(piirecoveryorder.getJobtype());
		piiorder.setPolicy_id(piirecoveryorder.getPolicy_id());
		piiorder.setRuntype("RECOVERY");
		piiorder.setCalendar(piirecoveryorder.getCalendar());
		piiorder.setTime(piirecoveryorder.getTime());
		piiorder.setStatus("Wait condition");
		piiorder.setConfirmflag("N");
		piiorder.setHoldflag("N");
		piiorder.setForceokflag("N");
		piiorder.setKillflag("N");
		piiorder.setEststarttime(piirecoveryorder.getEststarttime());
		piiorder.setRunningtime(null);
		piiorder.setRealstarttime(null);
		piiorder.setRealendtime(null);
		piiorder.setJob_owner_id1(piirecoveryorder.getJob_owner_id1());
		piiorder.setJob_owner_name1(piirecoveryorder.getJob_owner_name1());
		piiorder.setJob_owner_id2(piirecoveryorder.getJob_owner_id2());
		piiorder.setJob_owner_name2(piirecoveryorder.getJob_owner_name2());
		piiorder.setJob_owner_id3(piirecoveryorder.getJob_owner_id3());
		piiorder.setJob_owner_name3(piirecoveryorder.getJob_owner_name3());
		piiorder.setOrderdate(null);
		piiorder.setOrderuserid(piirecovery.getReguserid());
		//LogUtil.log("INFO", "orderMapper.register(piiorder) => "+ piiorder.toString());
		orderMapper.insert(piiorder);

		String stepid_new = "EXE_RECOVERY_D";
		List<PiiOrderStepVO> ordersteplist = orderstepMapper.getOrderStepList(oldorderid);
		for (PiiOrderStepVO orderstep : ordersteplist) {
			if (orderstep.getSteptype().equalsIgnoreCase("EXE_UPDATE"))
				stepid_new = "EXE_RECOVERY_U";
		}
		Boolean extractStepExist = false;
		for (PiiOrderStepVO orderstep : ordersteplist) {
			if (orderstep.getSteptype().equalsIgnoreCase("EXE_EXTRACT")) {
				extractStepExist = true;
			}
		}

		if (stepid_new.equalsIgnoreCase("EXE_RECOVERY_U")) {
			List<PiiOrderStepTableUpdateVO> jobupdatelist = ordersteptableudpateMapper.getJobList(oldorderid, piirecovery.getOld_jobid(), piirecovery.getOld_version());
			for (int i = 0; i < jobupdatelist.size(); i++) {
				LogUtil.log("INFO", jobupdatelist.get(i).toString());
				PiiOrderStepTableUpdateVO jobupdatevo = jobupdatelist.get(i);
				jobupdatevo.setOrderid(newOrderId);
				jobupdatevo.setStepid(stepid_new);
				ordersteptableudpateMapper.insert(jobupdatevo);
			}
		}

		for (PiiOrderStepVO piirecoveryorderstep : ordersteplist) {LogUtil.log("INFO", "piiorderstep====run()==="+piirecoveryorderstep.getSteptype());
			if (!piirecoveryorderstep.getSteptype().contains("EXE_ARCHIVE")) continue;

			String stepname_new = "RECOVERY ORDERID:" + oldorderid;
			String steptype_new = "EXE_RECOVERY";
			String exetype_new = "RECOVERY";

			piiorderstep.setOrderid(newOrderId);
			piiorderstep.setStatus("Wait condition");
			piiorderstep.setConfirmflag("N");
			piiorderstep.setHoldflag("N");
			piiorderstep.setForceokflag("N");
			piiorderstep.setKillflag("N");
			piiorderstep.setBasedate(basedate);
			piiorderstep.setThreadcnt("3");
			piiorderstep.setCommitcnt("3000");
			piiorderstep.setRuncnt("0");
			piiorderstep.setJobid(jobid_new);
			piiorderstep.setVersion(piirecoveryorderstep.getVersion());
			piiorderstep.setStepid(stepid_new);
			piiorderstep.setStepname(stepname_new);
			piiorderstep.setSteptype(steptype_new);
			piiorderstep.setStepseq("1");
			piiorderstep.setDb(piirecoveryorderstep.getDb());
			piiorderstep.setTotaltabcnt("" + steptableMapper.getTotalTabCnt(piirecoveryorderstep.getJobid(), piirecoveryorderstep.getVersion(), piirecoveryorderstep.getStepid()));
			piiorderstep.setSuccesstabcnt("0");
//        	piiorderstep.setRunningtime(" ");
//        	piiorderstep.setRealstarttime(" ");
//        	piiorderstep.setRealendtime(" ");
			piiorderstep.setOrderuserid(piirecovery.getReguserid());
			orderstepMapper.insert(piiorderstep);

			List<PiiOrderStepTableVO> ordersteptablelist = ordersteptableMapper.getStepTableList(oldorderid, piirecoveryorderstep.getStepid());
			for (PiiOrderStepTableVO piirecoveryordersteptable : ordersteptablelist) {
				piiordersteptable.setOrderid(newOrderId);
				piiordersteptable.setStatus("Wait condition");
				piiordersteptable.setForceokflag("N");
				piiordersteptable.setBasedate(basedate);
				piiordersteptable.setJobid(jobid_new);
				piiordersteptable.setVersion(piirecoveryordersteptable.getVersion());
				piiordersteptable.setStepid(stepid_new);
				piiordersteptable.setStepname(stepname_new);
				piiordersteptable.setSteptype(steptype_new);
				piiordersteptable.setStepseq("1");
				piiordersteptable.setDb(piirecoveryordersteptable.getDb());
				piiordersteptable.setOwner(piirecoveryordersteptable.getOwner());
				piiordersteptable.setTable_name(piirecoveryordersteptable.getTable_name());
				piiordersteptable.setPagitype(piirecoveryordersteptable.getPagitype());
				piiordersteptable.setPagitypedetail(piirecoveryordersteptable.getPagitypedetail());
				piiordersteptable.setExetype(exetype_new);
				piiordersteptable.setArchiveflag(piirecoveryordersteptable.getArchiveflag());
				piiordersteptable.setPreceding(Integer.toString(piirecovery.getOld_orderid()));
				piiordersteptable.setSuccedding("");
				piiordersteptable.setSeq1(piirecoveryordersteptable.getSeq1());
				piiordersteptable.setSeq2(piirecoveryordersteptable.getSeq2());
				piiordersteptable.setSeq3(piirecoveryordersteptable.getSeq3());
				piiordersteptable.setPipeline(piirecoveryordersteptable.getPipeline());
				piiordersteptable.setPk_col(piirecoveryordersteptable.getPk_col());
				piiordersteptable.setWhere_col(piirecoveryordersteptable.getWhere_col());
				piiordersteptable.setWhere_key_name(piirecoveryordersteptable.getWhere_key_name());
				piiordersteptable.setParallelcnt(null);
				piiordersteptable.setCommitcnt("3000");

				piiordersteptable.setWherestr("pii_order_id='" + oldorderid + "'");
				String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piirecoveryordersteptable.getDb(), piirecoveryordersteptable.getOwner(), piirecoveryordersteptable.getTable_name());
				piiordersteptable.setSqlstr("insert into " + piirecoveryordersteptable.getOwner() + "." + piirecoveryordersteptable.getTable_name() + " select * from " + archiveTablePath + " where " + piiordersteptable.getWherestr());
				if (stepid_new.equalsIgnoreCase("EXE_RECOVERY_U")) {
					piiordersteptable.setSqlstr("update " + piiordersteptable.getOwner() + "." + piiordersteptable.getTable_name() + " set #UPDATECOLS where (" + piiordersteptable.getPk_col() + ") in(  select " + piiordersteptable.getPk_col() + " from " + archiveTablePath + " where " + piiordersteptable.getWherestr() + " )");
				}

				ordersteptableMapper.insert(piiordersteptable);

				db = piirecoveryordersteptable.getDb();
			}
		}
		// step 2. DELETE keymap data of the ORDERID
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
		piiorderstep.setVersion(piirecoveryorder.getVersion());
		piiorderstep.setStepid("EXE_FINISH");
		piiorderstep.setStepname("Delete keymap of the ORDERID:" + oldorderid);
		piiorderstep.setSteptype("EXE_FINISH");
		piiorderstep.setStepseq("2");
		piiorderstep.setTotaltabcnt("1");
		piiorderstep.setSuccesstabcnt("0");
//    	piiorderstep.setRunningtime(" ");
//    	piiorderstep.setRealstarttime(" ");
//    	piiorderstep.setRealendtime(" ");
		piiorderstep.setOrderuserid(piirecovery.getReguserid());
		orderstepMapper.insert(piiorderstep);

		//-----STEPTABLE 1
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion(piirecoveryorder.getVersion());
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(homeDB);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIRECOVERY");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(100);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col("new_orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		piiordersteptable.setSqlstr("update cotdl.tbl_piirecovery"
				+ " set status= (select status from cotdl.tbl_piiorderstep where orderid= " + newOrderId + " and steptype='EXE_RECOVERY')"
				+ " where new_orderid = " + newOrderId
		);
		ordersteptableMapper.insert(piiordersteptable);
		//-----STEPTABLE 2
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion(piirecoveryorder.getVersion());
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(homeDB);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIORDER");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(200);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col("new_orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		piiordersteptable.setSqlstr("update cotdl.tbl_piiorder"
				+ " set status = 'Recovered'"
				+ " where orderid = " + oldorderid
		);
		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 3
		piiordersteptable.setOrderid(newOrderId);
		piiordersteptable.setStatus("Wait condition");
		piiordersteptable.setForceokflag("N");
		piiordersteptable.setBasedate(basedate);
		piiordersteptable.setJobid(jobid_new);
		piiordersteptable.setVersion(piirecoveryorder.getVersion());
		piiordersteptable.setStepid("EXE_FINISH");
		piiordersteptable.setStepname("EXE_FINISH");
		piiordersteptable.setSteptype("EXE_FINISH");
		piiordersteptable.setStepseq("2");
		piiordersteptable.setDb(db);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIKEYMAP_HIST");
		piiordersteptable.setPagitype(null);
		piiordersteptable.setPagitypedetail(null);
		piiordersteptable.setExetype("FINISH");
		piiordersteptable.setArchiveflag(null);
		piiordersteptable.setPreceding(null);
		piiordersteptable.setSuccedding(null);
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(300);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col("keymap_id,basedate");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		//Transformation by DB Type
		String dbtype = databaseMapper.read(piiordersteptable.getDb()).getDbtype();
		String wherestr = "keymap_id='" + piirecovery.getKeymap_id() + "' and " + "basedate = TO_DATE('" + piirecovery.getBasedate() + "','yyyy/mm/dd')";
		if (piiordersteptable.getExetype().equals("BROADCAST")) {
			dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
		}
		wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

		piiordersteptable.setWherestr(wherestr);
		piiordersteptable.setSqlstr("delete from " + "cotdl" + "." + "tbl_piikeymap_hist" + " where " + piiordersteptable.getWherestr());

		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 4
		piiordersteptable.setDb(db);
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIKEYMAP");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(400);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setPipeline(null);
		piiordersteptable.setWhere_col("keymap_id,basedate");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");

		//Transformation by DB Type
		//String dbtype = databaseMapper.get(piiordersteptable.getDb()).getDbtype();
		wherestr = "keymap_id='" + piirecovery.getKeymap_id() + "' and " + "basedate = TO_DATE('" + piirecovery.getBasedate() + "','yyyy/mm/dd')";
		if (piiordersteptable.getExetype().equals("BROADCAST")) {
			//dbtype = databaseMapper.get("DLM").getDbtype();
			dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
		}
		wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

		piiordersteptable.setWherestr(wherestr);
		piiordersteptable.setSqlstr("delete from " + "cotdl" + "." + "tbl_piikeymap" + " where " + piiordersteptable.getWherestr());

		ordersteptableMapper.insert(piiordersteptable);
		int seq2=400;
		if(extractStepExist) {

			//-----------------------------------------------------------------------------------------------------------
			//-----STEPTABLE from SteptableETC
			//-----------------------------------------------------------------------------------------------------------
			if(steptableMapper.readEtcCnt("RECOVERY_ORDER","EXE_FINISH") == 1) {
				PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("RECOVERY_ORDER", "EXE_FINISH");
				piiordersteptable.setDb(stepTableETCVO.getDb());
				piiordersteptable.setOwner(stepTableETCVO.getOwner());
				piiordersteptable.setTable_name(stepTableETCVO.getTable_name());
				piiordersteptable.setSeq1(10);
				seq2 = seq2 + 100;
				piiordersteptable.setSeq2(seq2);
				piiordersteptable.setSeq3(10);
				piiordersteptable.setWhere_col("orderid");
				piiordersteptable.setWhere_key_name(null);
				piiordersteptable.setParallelcnt(null);
				piiordersteptable.setCommitcnt("3000");
				piiordersteptable.setWherestr("  ");
				//Transformation by DB Type
				String sqlstr = stepTableETCVO.getSqlstr()
						+ " (select CUSTID from COTDL.TBL_PIIEXTRACT "+ " \r\n"
						+ "   where ORDERID = " + oldorderid + " \r\n"
						+ "     and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null" + " \r\n"
						+ " )";
				piiordersteptable.setWherestr("  ");
				piiordersteptable.setSqlstr(sqlstr);

				ordersteptableMapper.insert(piiordersteptable);
			}

			//-----STEPTABLE 5
			piiordersteptable.setDb(db);
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIIEXTRACT");
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setWhere_col("orderid");
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");
			piiordersteptable.setWherestr("  ");
			piiordersteptable.setSqlstr("delete from COTDL.TBL_PIIEXTRACT" + " \r\n"
					+ " where ORDERID = " + oldorderid + " \r\n"
					+ "   and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
			);
			ordersteptableMapper.insert(piiordersteptable);

			//-----STEPTABLE 6
			piiordersteptable.setDb(homeDB);
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIIEXTRACT");
			piiordersteptable.setSeq1(10);
			seq2 = seq2 + 100;
			piiordersteptable.setSeq2(seq2);
			piiordersteptable.setSeq3(10);
			piiordersteptable.setWhere_col("orderid");
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");
			piiordersteptable.setWherestr("  ");
			piiordersteptable.setSqlstr("delete from COTDL.TBL_PIIEXTRACT" + " \r\n"
					+ " where ORDERID = " + oldorderid + " \r\n"
					+ "   and ARCHIVE_DATE is not null and RESTORE_DATE is null and ARC_DEL_DATE is null"
			);
			ordersteptableMapper.insert(piiordersteptable);



		}

		//-----------------------------------------------------------------------------
		//update Recovery status
		piirecovery.setStatus("ORDERED");
		piirecovery.setNew_orderid(newOrderId);
		mapper.update(piirecovery);
	}

}
