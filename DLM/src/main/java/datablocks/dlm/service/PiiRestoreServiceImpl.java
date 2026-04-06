package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.DmlExecutor;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.security.Principal;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor // final 필드만 생성자 주입
public class PiiRestoreServiceImpl implements PiiRestoreService {

	// **의존성 주입 필드 (final로 선언)**
	private final PiiRestoreMapper mapper;
	private final PiiApprovalReqMapper approvalreqmapper;
	private final PiiDatabaseMapper databaseMapper;
	private final PiiOrderMapper orderMapper;
	private final PiiConfigMapper configMapper;
	private final PiiOrderStepMapper orderstepMapper;
	private final PiiOrderStepTableUpdateMapper ordersteptableudpateMapper;
	private final PiiStepTableUpdateMapper steptableupdateMapper;
	private final PiiOrderStepTableMapper ordersteptableMapper;
	private final PiiStepTableMapper steptableMapper;
	private final MemberMapper memberMapper;
	private final DmlExecutor dlmexe;
	private final ArchiveNamingService archiveNamingService;
	private final PiiApprovalStepReqMapper approvalStepReqMapper;

	private PiiDatabaseVO coreDbVO;
	private PiiDatabaseVO homeDbVO;
	private String homeDbType;
	@Value("${xone.home-db-name:DLM}") private String HOME_DB;
	@Value("${xone.system-name:CORE}") private String SYSTEM_NM;
	@PostConstruct
	public void init() {
		this.coreDbVO = databaseMapper.readBySystem(SYSTEM_NM);
		this.homeDbVO = databaseMapper.read(HOME_DB);
		this.homeDbType = this.homeDbVO.getDbtype();
	}

	@Override
	public List<PiiRestoreVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiCustidVO> getArcCustBrowseList(String applicant) {

		LogUtil.log("INFO", "getArcCustBrowseList: " );

		return mapper.getArcCustBrowseList(applicant);
	}

	@Override
	public List<PiiRestoreVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "getList with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}
	
	@Override
	public List<PiiActOrderVO> getActOrderList(Criteria cri) {
		
		LogUtil.log("INFO", "getActOrderList with criteria: " + cri);
		
		return mapper.getActOrderList(cri);
	}
	
	@Override
	public String register(List<PiiRestoreVO> restorelist, Principal principal, String reqreason, String aprvlineid, String applytype) {
		
		LogUtil.log("INFO", "register(List<PiiRestoreVO>....."+ aprvlineid +"  "+applytype +"  "+ restorelist.toString() );
		String rst = "success";
		for(PiiRestoreVO piirestore : restorelist) {
			try {
				int maxRestoreid = mapper.getMaxRestoreid() + 1;
				piirestore.setRestoreid(maxRestoreid);
				piirestore.setApply_type(applytype);
				LogUtil.log("INFO", "insert(piirestore)....."+ piirestore );
				mapper.insert(piirestore);
				PiiApprovalReqVO approvalreq = new PiiApprovalReqVO();
				approvalreq.setJobid(maxRestoreid+"");
				approvalreq.setReqreason(reqreason);

				//approvalreqmapper.insert(piiapprovalreqvo);
				checkin(approvalreq, principal, aprvlineid, applytype);

				// update Extract table's status for the custid of restoration.
				updateRestoreCustStatus(piirestore.getOld_orderid(),piirestore.getCustid(),"APPLY_"+applytype);

			} catch (Exception e) {
				logger.warn("warn "+piirestore.toString());
				logger.warn("warn "+"register(PiiRestoreVO piirestore)=> "+e.getMessage());
				rst = e.getMessage();
				break;
			}
		}
		return rst;
			
	}

	@Override
	public PiiApprovalReqVO registerFromPlatform(PiiExtractVO extractVO, String reqreason, String aprvlineid, String applytype, int stepcnt, String requserid, String requsername) {

		LogUtil.log("INFO", "registerFromPlatform(extractVO....."+extractVO );
		String rst = "success";
		PiiRestoreVO piirestore = new PiiRestoreVO();
		PiiApprovalReqVO piiapprovalreqvo = null;
		try {
			int maxRestoreid = mapper.getMaxRestoreid() + 1;
			piirestore.setRestoreid(maxRestoreid);
			piirestore.setPhase("APPLY");
			piirestore.setApply_type(applytype);
			piirestore.setOld_orderid(extractVO.getOrderid());
			piirestore.setNew_orderid(0);
			String keymapid = orderMapper.read(extractVO.getOrderid()).getKeymap_id();
			piirestore.setKeymap_id(keymapid);
			piirestore.setBasedate(extractVO.getBasedate());
			piirestore.setCustid(extractVO.getCustid());
			piirestore.setCust_nm(extractVO.getCust_nm());
			piirestore.setBirth_dt(extractVO.getBirth_dt());
			piirestore.setRsdnt_altrntv_id(extractVO.getRsdnt_altrntv_id());
			piirestore.setCust_pin(null);
			piirestore.setOld_jobid(extractVO.getJobid());
			piirestore.setOld_version(null);
			piirestore.setNew_jobid(null);
			piirestore.setStatus("NEW");
			piirestore.setBrowse_deadline_dt(null);
			piirestore.setApprove_date(null);
			piirestore.setRegdate(null);
			piirestore.setUpddate(null);
			piirestore.setReguserid(requserid);
			piirestore.setUpduserid(requsername);
			LogUtil.log("INFO", "before ##33 mapper.insert(piirestore);....."+ piirestore.toString() );
			mapper.insert(piirestore);
			PiiApprovalReqVO approvalreq = new PiiApprovalReqVO();
			approvalreq.setJobid(maxRestoreid+"");
			approvalreq.setReqreason(reqreason);
			LogUtil.log("INFO", "after ##33 mapper.insert(piirestore);....."+ approvalreq.toString() );
			piiapprovalreqvo = checkinFromPlatform(approvalreq, aprvlineid, applytype, stepcnt, requserid, requsername);
			LogUtil.log("INFO", "after checkinFromPlatform....."+ approvalreq.toString() );
			// update Extract table's status for the custid of restoration.
			updateRestoreCustStatus(piirestore.getOld_orderid(),piirestore.getCustid(),"APPLY_"+applytype);
			LogUtil.log("INFO", "after updateRestoreCustStatus....."+ approvalreq.toString() );
		} catch (Exception e) {
			logger.warn("warn "+piirestore.toString());
			logger.warn("warn "+"register(PiiRestoreVO piirestore)=> "+e.getMessage());
			e.printStackTrace();
//			rst = e.getMessage();
		}

		return piiapprovalreqvo;

	}

	@Override
	public boolean remove(int restoreid) {
		
		LogUtil.log("INFO", "remove...." + restoreid);
		 
		return mapper.delete(restoreid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getMaxRestoreid() {
		
		LogUtil.log("INFO", "getMaxRestoreid");
		return mapper.getMaxRestoreid();
	}
	@Override
	public int getActOrderListTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getActOrderListTotalCount(cri);
	}

	@Override
	public PiiRestoreVO get(int restoreid) {
		
		 LogUtil.log("INFO", "get......" + restoreid);
		 
		 return mapper.read(restoreid);
	}

	@Override
	public boolean modify(PiiRestoreVO piirestore) {
		
		LogUtil.log("INFO", "modify......" + piirestore);
		
		return mapper.update(piirestore) == 1;
	}
	@Override
	public boolean modifyApprovalInfo(PiiRestoreVO piirestore) {

		LogUtil.log("INFO", "modifyApprovalInfo......" + piirestore);

		return mapper.updateApprovalInfo(piirestore) == 1;
	}
	@Override
	public boolean modifyStatus(int orderid) {
		
		LogUtil.log("INFO", "modifyStatus......" + orderid);
		
		return mapper.updateStatus(orderid) == 1;
	}

	@Override
	public boolean requestapproval(int restoreid) {
		LogUtil.log("INFO", "requestapproval.....restoreid." + restoreid);
		return mapper.requestapproval(restoreid) == 1;
	}
	
	@Override
	public boolean approve(PiiApprovalReqVO approvalreqVO) {
		int upcnt = mapper.approve(StrUtil.parseInt(approvalreqVO.getJobid()));
		LogUtil.log("INFO", "approve....restoreid.." + approvalreqVO.getJobid() +"  upcnt:"+upcnt);
		return upcnt == 1;
	}
	
	@Override
	public boolean reject(PiiApprovalReqVO approvalreqVO) {
		LogUtil.log("INFO", "reject....restoreid.." + approvalreqVO.getJobid());
		approvalreqmapper.reject(approvalreqVO);
		return mapper.reject(StrUtil.parseInt(approvalreqVO.getJobid())) == 1;
	}
	@Override
	public boolean updateRestoreCustStatus(int orderid, String custid, String status) {
		LogUtil.log("INFO","updateRestoreCustStatus==="+orderid +" @@@ -  "+ custid +"  -  "+ status);

		String strQuery = "update cotdl.tbl_piiextract " +
				"set exclude_reason = '" + status + "' " +
				"  , restore_date= "+ SqlUtil.getCurrentDate(coreDbVO.getDbtype()) +" " +
				"where orderid= " + orderid + " and custid= '" + custid + "'" +
				"  and ARCHIVE_DATE is not null and ARC_DEL_DATE is null";
		LogUtil.log("INFO", " updateRestoreCustStatus -  "+ strQuery);
		try {
			dlmexe.exeQuery(coreDbVO, strQuery);
		} catch (Exception e) {
			logger.warn("warn "+"updateRestoreCustStatus - Exception: " + e.getMessage());

		}

		return mapper.updateRestoreCustStatus(orderid, custid, status) == 1;
	}
	@Override
	public int modifyExtractBrowseStatus() {
		LogUtil.log("INFO", "modifyExtractBrowseStatus......" );

		String strQuery = "update cotdl.tbl_piiextract " +
				"set exclude_reason = null " +
				"where exists (" +
								"select 1 " +
								"from cotdl.tbl_piirestore r " +
								"where cotdl.tbl_piiextract.orderid = r.old_orderid " +
								"and cotdl.tbl_piiextract.custid = r.custid " +
								"and r.status='APPROVED_BROWSE' " +
								"and r.status=cotdl.tbl_piiextract.exclude_reason " +
								"and r.browse_deadline_dt < "+ SqlUtil.getCurrentDate(coreDbVO.getDbtype()) +" " +
							")  " +
				"  and exclude_reason != 'RESTORE'"
				;
		try {
			dlmexe.exeQuery(coreDbVO, strQuery);
		} catch (Exception e) {
			logger.warn("warn "+"modifyExtractBrowseStatus - Exception: " + e.getMessage());

		}
		return mapper.updateExtractBrowseStatus();
	}

	@Override
	public String checkin(PiiApprovalReqVO approvalreq, Principal principal, String aprvlineid,  String applytype) {
		
		LogUtil.log("INFO", "checkin......" + approvalreq);
		String applyId;
		if(applytype.equalsIgnoreCase("RESTORE"))
			applyId = "RESTORE_APPROVAL";
		else
			applyId = "BROWSE_APPROVAL";
		try {
			mapper.requestapproval(StrUtil.parseInt(approvalreq.getJobid()));// PIIRESTORE 업데이트 Jobid 는 restoreid

			PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
			piiapprovalreqvo.setReqid(""+(approvalreqmapper.getMaxReqid()+1));
			piiapprovalreqvo.setAprvlineid(aprvlineid);
			piiapprovalreqvo.setSeq("1");
			piiapprovalreqvo.setApprovalid(applyId);
			piiapprovalreqvo.setJobid(approvalreq.getJobid());
			piiapprovalreqvo.setVersion(approvalreq.getVersion());
			piiapprovalreqvo.setRequesterid(principal.getName());
			piiapprovalreqvo.setRequestername(memberMapper.read(principal.getName()).getUserName());
			piiapprovalreqvo.setRegdate("");
			piiapprovalreqvo.setUpddate("");
			piiapprovalreqvo.setReqreason(approvalreq.getReqreason());
			if ("자동복원결재라인".equals(aprvlineid)) {
				piiapprovalreqvo.setPhase("FINAL_APPROVAL");
			} else {
				piiapprovalreqvo.setPhase("APPLY");
			}
			approvalreqmapper.insert(piiapprovalreqvo);

			// 자동결재 라인인 경우: 이력 남기고 즉시 최종승인 처리
			if ("자동복원결재라인".equals(aprvlineid)) {
				PiiApprovalStepReqVO stepReq = new PiiApprovalStepReqVO();
				stepReq.setReqid(piiapprovalreqvo.getReqid());
				stepReq.setAprvlineid(piiapprovalreqvo.getAprvlineid());
				stepReq.setSeq(piiapprovalreqvo.getSeq());
				stepReq.setStepname("AUTO");
				stepReq.setStatus("APPROVED");
				stepReq.setApproverid("SYSTEM");
				stepReq.setApprovername("SYSTEM");
				stepReq.setComment("Auto approved");
				approvalStepReqMapper.insert(stepReq);

				this.approve(piiapprovalreqvo);
				LogUtil.log("INFO", "Auto-approved " + applyId + ": restoreid=" + approvalreq.getJobid());
			}

		}catch (Exception e) {
			logger.warn("warn "+"Fail to apply Restoration => restoreid: "+approvalreq.getJobid()+"  "+e.getMessage());
			return "Fail to apply Restoration";
		}
		return "success";
	}
	@Override
	public PiiApprovalReqVO checkinFromPlatform(PiiApprovalReqVO approvalreq, String aprvlineid, String applytype, int stepcnt, String requserid, String requsername) {

		LogUtil.log("INFO", "checkinFromPlatform......" + approvalreq);
		PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
		try {
			mapper.requestapproval(StrUtil.parseInt(approvalreq.getJobid()));// Jobid => restoreid

			piiapprovalreqvo.setReqid(""+(approvalreqmapper.getMaxReqid()+1));
			piiapprovalreqvo.setAprvlineid(aprvlineid);
			piiapprovalreqvo.setSeq(stepcnt+"");
			piiapprovalreqvo.setApprovalid("RESTORE_APPROVAL");
			piiapprovalreqvo.setPhase("FINAL_APPROVAL");
			piiapprovalreqvo.setJobid(approvalreq.getJobid());
			piiapprovalreqvo.setVersion(approvalreq.getVersion());
			piiapprovalreqvo.setRequesterid(requserid);
			piiapprovalreqvo.setRequestername(requsername);
			piiapprovalreqvo.setRegdate("");
			piiapprovalreqvo.setUpddate("");
			piiapprovalreqvo.setReqreason(approvalreq.getReqreason());
			LogUtil.log("INFO", "approvalreqmapper.insert(piiapprovalreqvo);: "+piiapprovalreqvo);
			approvalreqmapper.insert(piiapprovalreqvo);
		}catch (Exception e) {
			logger.warn("warn "+"Fail to apply Restoration => restoreid: "+approvalreq.getJobid()+"  "+e.getMessage());
		}
		return piiapprovalreqvo;
	}

	@Override
	public PiiOrderVO orderRestoreJob(PiiRestoreVO piirestore, String reqFrom) {

		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");

		// 오늘 날짜를 basedate로 사용
		Date today = new Date();
		String basedate = yyyymmdd.format(today);

		// 현재 시간 기준 LocalDateTime 생성
		LocalDateTime now = LocalDateTime.now();

		//String curtime = yyyymmddhms.format(today);
		PiiOrderVO piiorder = new PiiOrderVO();
		PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();

		String db = null;
		String dbtype = null;

		String treadcnt = "5";
		String commitcnt = "10";
		if("PLATFORM".equalsIgnoreCase(reqFrom)){
			try {
				if (!StrUtil.checkString( EnvConfig.getConfig("DLM_RESTORE_THREADCNT")))
					treadcnt =  EnvConfig.getConfig("DLM_RESTORE_THREADCNT");
			} catch (NullPointerException ex) {

			}
		}
		try {
			if (!StrUtil.checkString( EnvConfig.getConfig("DLM_RESTORE_COMMITCNT")))
				commitcnt =  EnvConfig.getConfig("DLM_RESTORE_COMMITCNT");
		} catch (NullPointerException ex) {

		}

		String jobid_new = "RESTORE_CUSTID_"+reqFrom+":" + piirestore.getCustid();
		String jobname_new = "고객복원:" + piirestore.getCustid();
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

		int stepSeq = 0;
		List<PiiOrderVO> restorableOrderList = orderMapper.getRestorableList(piirestore.getCustid());
		LogUtil.log("INFO", "#### restorableOrderList.size(): " + restorableOrderList.size());
		/**
		 * step 1 - Restore
		 * Restore order와 orderstep, ordersteptable 생성
		 * */
		for (PiiOrderVO piirestoreorder : restorableOrderList) {
			stepSeq++;
			if(stepSeq == 1) {
				piiorder.setOrderid(newOrderId);
				piiorder.setBasedate(basedate);
				piiorder.setRuncnt(0);
				piiorder.setJobid(jobid_new);
				piiorder.setVersion("1");
				piiorder.setJobname(jobname_new);
				piiorder.setSystem(piirestoreorder.getSystem());
				piiorder.setKeymap_id(piirestoreorder.getKeymap_id());
				piiorder.setJobtype(piirestoreorder.getJobtype());
				piiorder.setPolicy_id(piirestoreorder.getPolicy_id());
				piiorder.setRuntype("RESTORE");
				piiorder.setCalendar(piirestoreorder.getCalendar());
				piiorder.setTime(piirestoreorder.getTime());
				piiorder.setStatus("Wait condition");
				piiorder.setConfirmflag("N");
				piiorder.setHoldflag("N");
				piiorder.setForceokflag("N");
				piiorder.setKillflag("N");
				piiorder.setEststarttime(basedate+" "+"00:00:01");
				// 현재 시간에서 stepSeq분 증가된 시간
				//LocalDateTime estTime = now.plusMinutes(stepSeq);
				//piiorder.setEststarttime(estTime.format(outputFormatter));
				piiorder.setRunningtime(null);
				piiorder.setRealstarttime(null);
				piiorder.setRealendtime(null);
				piiorder.setJob_owner_id1(piirestoreorder.getJob_owner_id1());
				piiorder.setJob_owner_name1(piirestoreorder.getJob_owner_name1());
				piiorder.setJob_owner_id2(piirestoreorder.getJob_owner_id2());
				piiorder.setJob_owner_name2(piirestoreorder.getJob_owner_name2());
				piiorder.setJob_owner_id3(piirestoreorder.getJob_owner_id3());
				piiorder.setJob_owner_name3(piirestoreorder.getJob_owner_name3());
				piiorder.setOrderdate(null);
				piiorder.setOrderuserid(piirestore.getReguserid());
				LogUtil.log("INFO", "orderMapper.register(piiorder) => "+ piiorder.toString());
				orderMapper.insert(piiorder);
			}
			String stepidNew = "EXE_RESTORE_D"+stepSeq;
			List<PiiOrderStepVO> orderStepList = orderstepMapper.getOrderStepList(piirestoreorder.getOrderid());
			boolean hasExeUpdate = orderStepList.stream()
					.anyMatch(step -> step.getSteptype().contains("EXE_UPDATE"));

			if (hasExeUpdate) {
				stepidNew = "EXE_RESTORE_U" + stepSeq;
			}

			if (stepidNew.equalsIgnoreCase("EXE_RESTORE_U"+stepSeq)) {
				List<PiiOrderStepTableUpdateVO> orderStepTableUpdateVOList = ordersteptableudpateMapper.getJobList(piirestoreorder.getOrderid(), piirestoreorder.getJobid(), piirestoreorder.getVersion());
				LogUtil.log("INFO", "orderStepTableUpdateVOList.size()="+orderStepTableUpdateVOList.size());
				for (int i = 0; i < orderStepTableUpdateVOList.size(); i++) {
					PiiOrderStepTableUpdateVO jobupdatevo = orderStepTableUpdateVOList.get(i);
					jobupdatevo.setOrderid(newOrderId);
					jobupdatevo.setStepid(stepidNew);
					ordersteptableudpateMapper.insert(jobupdatevo);
				}
				/** 데이터가 없으면 sql 에러가 발생하여 방지를 위해 StepTableUpdate 에서 직접 가지고 온다.*/
				if(orderStepTableUpdateVOList.size() == 0){
					List<PiiStepTableUpdateVO> steptableupdatelist = steptableupdateMapper.getJobMaxList(piirestoreorder.getJobid());
					PiiOrderStepTableUpdateVO piiordersteptableupdate = new PiiOrderStepTableUpdateVO();
					LogUtil.log("INFO", "steptableupdateMapper.getJobMaxList   steptableupdatelist.size()="+steptableupdatelist.size());
					for (PiiStepTableUpdateVO steptableupdate : steptableupdatelist) {
						piiordersteptableupdate.setOrderid(newOrderId);
						piiordersteptableupdate.setJobid(steptableupdate.getJobid());
						piiordersteptableupdate.setVersion(steptableupdate.getVersion());
						piiordersteptableupdate.setStepid(stepidNew);
						piiordersteptableupdate.setSeq1(steptableupdate.getSeq1());
						piiordersteptableupdate.setSeq2(steptableupdate.getSeq2());
						piiordersteptableupdate.setSeq3(steptableupdate.getSeq3());
						piiordersteptableupdate.setColumn_name(steptableupdate.getColumn_name());
						piiordersteptableupdate.setUpdate_val(steptableupdate.getUpdate_val());
						piiordersteptableupdate.setStatus(steptableupdate.getStatus());
						ordersteptableudpateMapper.insert(piiordersteptableupdate);
					}
				}
			}

			for (PiiOrderStepVO piirestoreorderstep : orderStepList) {
				if (!piirestoreorderstep.getSteptype().contains("EXE_ARCHIVE")) continue;

				LogUtil.log("INFO", "for (PiiOrderStepVO piirestoreorderstep : orderStepList) {     stepid=" + piirestoreorderstep.getStepid() +
						", steptype=" + piirestoreorderstep.getSteptype() +
						", stepname=" + piirestoreorderstep.getStepname());

				String stepname_new = stepidNew + ":" + piirestore.getCustid();
				String steptype_new = "EXE_RESTORE";
				String exetype_new = "RESTORE";

				piiorderstep.setOrderid(newOrderId);
				piiorderstep.setStatus("Wait condition");
				piiorderstep.setConfirmflag("N");
				piiorderstep.setHoldflag("N");
				piiorderstep.setForceokflag("N");
				piiorderstep.setKillflag("N");
				piiorderstep.setBasedate(basedate);
				piiorderstep.setThreadcnt(treadcnt); // 20230426 컨피그 변수로 처리
				piiorderstep.setCommitcnt(commitcnt); // 20230426 컨피그 변수로 처리 ; 복원은 운영중 수행 되므로 온라인 트랙젝션을 고려하여 낮게 설정되도록 기본 10
				piiorderstep.setRuncnt("0");
				piiorderstep.setJobid(jobid_new);
				piiorderstep.setVersion("1");
				piiorderstep.setStepid(stepidNew);
				piiorderstep.setStepname(stepname_new);
				piiorderstep.setSteptype(steptype_new);
				piiorderstep.setStepseq(stepSeq+"");
				piiorderstep.setDb(piirestoreorderstep.getDb());
				piiorderstep.setTotaltabcnt("" + steptableMapper.getTotalTabCnt(piirestoreorderstep.getJobid(), piirestoreorderstep.getVersion(), piirestoreorderstep.getStepid()));
				piiorderstep.setSuccesstabcnt("0");
				//        	piiorderstep.setRunningtime(" ");
				//        	piiorderstep.setRealstarttime(" ");
				//        	piiorderstep.setRealendtime(" ");
				piiorderstep.setOrderuserid(piirestore.getReguserid());
				LogUtil.log("INFO", "Restore orderstepMapper.insert(piiorderstep);:"+piiorderstep.getStepid());
				orderstepMapper.insert(piiorderstep);

				List<PiiOrderStepTableVO> ordersteptablelist = ordersteptableMapper.getStepTableList(piirestoreorderstep.getOrderid(), piirestoreorderstep.getStepid());
				for (PiiOrderStepTableVO piirestoreordersteptable : ordersteptablelist) {
					//LogUtil.log("INFO", "Restore for (PiiOrderStepTableVO piirestoreordersteptable : ordersteptablelist) {:"+piirestoreordersteptable.getSteptype());
					piiordersteptable.setOrderid(newOrderId);
					piiordersteptable.setStatus("Wait condition");
					piiordersteptable.setForceokflag("N");
					piiordersteptable.setBasedate(basedate);
					piiordersteptable.setJobid(jobid_new);
					piiordersteptable.setVersion("1");
					piiordersteptable.setStepid(stepidNew);
					piiordersteptable.setStepname(stepname_new);
					piiordersteptable.setSteptype(steptype_new);
					piiordersteptable.setStepseq(stepSeq+"");
					piiordersteptable.setDb(piirestoreordersteptable.getDb());
					piiordersteptable.setOwner(piirestoreordersteptable.getOwner());
					piiordersteptable.setTable_name(piirestoreordersteptable.getTable_name());
					piiordersteptable.setPagitype(piirestoreordersteptable.getPagitype());
					piiordersteptable.setPagitypedetail(piirestoreordersteptable.getPagitypedetail());
					piiordersteptable.setExetype(exetype_new);
					piiordersteptable.setArchiveflag(piirestoreordersteptable.getArchiveflag());
					piiordersteptable.setPreceding(Integer.toString(piirestoreorderstep.getOrderid()));// for Restore...this column is used for original orderid
					piiordersteptable.setSuccedding(piirestore.getCustid());// for Restore...this column is used for custid
					piiordersteptable.setSeq1(piirestoreordersteptable.getSeq1());
					piiordersteptable.setSeq2(piirestoreordersteptable.getSeq2());
					piiordersteptable.setSeq3(piirestoreordersteptable.getSeq3());
					piiordersteptable.setPipeline(piirestoreordersteptable.getPipeline());
					piiordersteptable.setPk_col(piirestoreordersteptable.getPk_col());
					piiordersteptable.setWhere_col(piirestoreordersteptable.getWhere_col());
					piiordersteptable.setWhere_key_name(piirestoreordersteptable.getWhere_key_name());
					piiordersteptable.setParallelcnt(null);
					piiordersteptable.setCommitcnt(commitcnt); // 20230426 컨피그 변수로 처리 ; 복원은 운영중 수행 되므로 온라인 트랙젝션을 고려하여 낮게 설정되도록 기본 10

					piiordersteptable.setWherestr("PII_ORDER_ID='" + piirestoreorderstep.getOrderid() + "' and PII_CUST_ID='" + piirestore.getCustid() + "' ");
					String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, piirestoreordersteptable.getDb(), piirestoreordersteptable.getOwner(), piirestoreordersteptable.getTable_name());
					piiordersteptable.setSqlstr("insert into " + piirestoreordersteptable.getOwner() + "." + piirestoreordersteptable.getTable_name() + " select * from " + archiveTablePath + " where " + piiordersteptable.getWherestr());
					if (stepidNew.substring(0,13).equalsIgnoreCase("EXE_RESTORE_U")) {
						piiordersteptable.setSqlstr("update " + piirestoreordersteptable.getOwner() + "." + piirestoreordersteptable.getTable_name() + " set #UPDATECOLS where (" + piirestoreordersteptable.getPk_col() + ") in(select " + piirestoreordersteptable.getPk_col() + " from " + archiveTablePath + " where " + piiordersteptable.getWherestr() + " )");
					}

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
			}
		}

		/**
		 * step 2 - EXE_FINISH 1
		 *  PIIORDERSTEP
		 * */
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
		piiorderstep.setStepname("Delete keymap of the custid:" + piirestore.getCustid());
		piiorderstep.setSteptype("EXE_FINISH");
		piiorderstep.setStepseq((++stepSeq+"")+"");
		piiorderstep.setTotaltabcnt("1");
		piiorderstep.setSuccesstabcnt("0");
//    	piiorderstep.setRunningtime(" ");
//    	piiorderstep.setRealstarttime(" ");
//    	piiorderstep.setRealendtime(" ");
		piiorderstep.setOrderuserid(piirestore.getReguserid());
		orderstepMapper.insert(piiorderstep);

		/**
		 * step 2 - EXE_FINISH 2
		 * 	PIIORDERSTEPTABLE - "DELETE from " + "COTDL" + "." + "TBL_PIIKEYMAP_HIST" + " WHERE " + piiordersteptable.getWherestr());
		 * */
		int seq2 = 0;
		List<PiiStepVO> piirestoresteplist = orderMapper.getRestoreStepArcList(piirestore.getCustid());
		LogUtil.log("INFO", "##EXE_FINISH2## orderMapper.getRestoreStepArcList.size(): " + piirestoresteplist.size());
		for (PiiStepVO restorearcstep : piirestoresteplist) {

			if(restorearcstep.getDb().equalsIgnoreCase(db)) {
				LogUtil.log("INFO", "##EXE_FINISH2## if(restorearcstep.getDb().equalsIgnoreCase(db)) {: continue;  " + restorearcstep.getDb());
				continue;
			}
			db = restorearcstep.getDb();

			seq2 = seq2 + 100;

			//-----STEPTABLE 1
			piiordersteptable.setOrderid(newOrderId);
			piiordersteptable.setStatus("Wait condition");
			piiordersteptable.setForceokflag("N");
			piiordersteptable.setBasedate(basedate);
			piiordersteptable.setJobid(jobid_new);
			piiordersteptable.setVersion("1");
			piiordersteptable.setStepid("EXE_FINISH");
			piiordersteptable.setStepname("EXE_FINISH");
			piiordersteptable.setSteptype("EXE_FINISH");
			piiordersteptable.setStepseq(stepSeq+"" + "");
			piiordersteptable.setDb(restorearcstep.getDb());
			piiordersteptable.setOwner("COTDL");
			piiordersteptable.setTable_name("TBL_PIIKEYMAP_HIST");
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
			piiordersteptable.setWhere_col("keymap_id,basedate,custid");
			piiordersteptable.setWhere_key_name(null);
			piiordersteptable.setParallelcnt(null);
			piiordersteptable.setCommitcnt("3000");

			//Transformation by DB Type
			dbtype = databaseMapper.read(piiordersteptable.getDb()).getDbtype();
			String wherestr = "keymap_id='" + piirestore.getKeymap_id() + "' and " + "BASEDATE = TO_DATE('" + piirestore.getBasedate() + "','yyyy/mm/dd')" + " and custid='" + piirestore.getCustid() + "' ";
			if (piiordersteptable.getExetype().equals("BROADCAST")) {
				dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
			}
			wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

			piiordersteptable.setWherestr(wherestr);
			piiordersteptable.setSqlstr("DELETE from " + "COTDL" + "." + "TBL_PIIKEYMAP_HIST" + " WHERE " + piiordersteptable.getWherestr());
			LogUtil.log("INFO", "##EXE_FINISH2## for (PiiStepVO restorearcstep : piirestoresteplist) {: " + restorearcstep.toString());
			ordersteptableMapper.insert(piiordersteptable);
		}

		/**
		 * step 2 - EXE_FINISH 3
		 * 	PIIORDERSTEPTABLE from STEPTABLEETC
		 * */
		if(steptableMapper.readEtcCnt("RESTORE_CUSTID","EXE_FINISH") == 1) {
			PiiStepTableVO stepTableETCVO = steptableMapper.readEtc("RESTORE_CUSTID", "EXE_FINISH");
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
			String sqlstr = stepTableETCVO.getSqlstr() //+ "\r\n"
					+ " (select custid from cotdl.tbl_piiextract " + " \r\n"
					+ "   where ORDERID = " + piirestore.getOld_orderid() + " \r\n"
					+ "     and CUSTID  = '" + piirestore.getCustid() + "'" + " \r\n"
					+ " )";
			piiordersteptable.setWherestr("  ");
			piiordersteptable.setSqlstr(sqlstr);
			LogUtil.log("INFO", "##EXE_FINISH## PIIORDERSTEPTABLE from STEPTABLEETC : " + piiordersteptable.toString());
			ordersteptableMapper.insert(piiordersteptable);
		}

		//-----STEPTABLE 2
		seq2 = seq2 + 100;
		piiordersteptable.setDb(coreDbVO.getDb());// Config DB
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIEXTRACT");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(seq2);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setWhere_col("orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");
		piiordersteptable.setWherestr("  ");

		piiordersteptable.setSqlstr("update COTDL.TBL_PIIEXTRACT" + " \r\n"
				+ "   set RESTORE_DATE = " + SqlUtil.getCurrentDate(coreDbVO.getDbtype()) + " ,EXCLUDE_REASON = 'RESTORE' " + " \r\n"
				+ " where ORDERID = " + piirestore.getOld_orderid() + " \r\n"
				+ "   and CUSTID  = '" + piirestore.getCustid() + "'" + " \r\n"
		);
		LogUtil.log("INFO", "##EXE_FINISH## PIIORDERSTEPTABLE for TBL_PIIEXTRACT 1 : db=" +coreDbVO.getDb()+"-->"+ piiordersteptable.toString());
		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 3
		seq2 = seq2 + 100;
		piiordersteptable.setDb(homeDbVO.getDb());// Config DB
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIEXTRACT");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(seq2);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setWhere_col("orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");
		piiordersteptable.setWherestr("  ");

		piiordersteptable.setSqlstr("update COTDL.TBL_PIIEXTRACT" + " \r\n"
				+ "   set RESTORE_DATE = " + SqlUtil.getCurrentDate(homeDbVO.getDbtype()) + " ,EXCLUDE_REASON = 'RESTORE' " + " \r\n"
				+ " where ORDERID = " + piirestore.getOld_orderid() + " \r\n"
				+ "   and CUSTID  = '" + piirestore.getCustid() + "'"
		);
		LogUtil.log("INFO", "##EXE_FINISH## PIIORDERSTEPTABLE for TBL_PIIEXTRACT 2 : db=" +homeDbVO.getDb()+"-->"+ piiordersteptable.toString());
		ordersteptableMapper.insert(piiordersteptable);

		//-----STEPTABLE 4
		seq2 = seq2 + 100;
		piiordersteptable.setDb(HOME_DB);// Config DB
		piiordersteptable.setOwner("COTDL");
		piiordersteptable.setTable_name("TBL_PIIRESTORE");
		piiordersteptable.setSeq1(10);
		piiordersteptable.setSeq2(seq2);
		piiordersteptable.setSeq3(10);
		piiordersteptable.setWhere_col("new_orderid");
		piiordersteptable.setWhere_key_name(null);
		piiordersteptable.setParallelcnt(null);
		piiordersteptable.setCommitcnt("3000");
		piiordersteptable.setWherestr("  ");
		piiordersteptable.setSqlstr("UPDATE COTDL.TBL_PIIRESTORE"
				+ " SET STATUS= 'Ended OK'"
				+ " WHERE NEW_ORDERID = " + newOrderId
		);
		ordersteptableMapper.insert(piiordersteptable);
		//-----------------------------------------------------------------------------
		//update Restore status
		piirestore.setStatus("ORDERED");
		piirestore.setNew_orderid(newOrderId);
		LogUtil.log("INFO", "before ##22 mapper.update(piirestore); => "+ piirestore.toString());
		mapper.updateApprovalInfo(piirestore);
		LogUtil.log("INFO", "after ##22 mapper.update(piirestore); => "+ "success");


		return piiorder;
	}
	
}
