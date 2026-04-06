package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SqlUtil;
import datablocks.dlm.util.StrUtil;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TestDataServiceImpl implements TestDataService {
	private static final Logger logger = LoggerFactory.getLogger(TestDataServiceImpl.class);
	private final TestDataMapper mapper;
	private final PiiApprovalReqMapper approvalreqmapper;
	private final PiiDatabaseMapper databaseMapper;
	private final PiiJobMapper jobMapper;
	private final PiiOrderMapper orderMapper;
	private final PiiConfigMapper configMapper;
	private final PiiOrderStepMapper orderstepMapper;
	private final PiiOrderStepTableMapper ordersteptableMapper;
	private final PiiStepMapper stepMapper;
	private final PiiStepTableMapper steptableMapper;
	private final MemberMapper memberMapper;
	private final TestDataIdTypeService testDataIdTypeService;
	private final PiiApprovalStepReqMapper approvalStepReqMapper;

	@Override
	public List<TestDataVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}

	@Override
	public List<TestDataVO> getDisposalList(String basedate) {

		LogUtil.log("INFO", " getDisposalList: " );

		return mapper.getDisposalList(basedate);
	}

	@Override
	public boolean updateDisposalSchedule(UpdateDisposalScheDateVO dto) {
		// DTO 객체에 유효성 검사 등 비즈니스 로직을 추가할 수 있습니다.
		if (dto.getTestdataid() == null || dto.getDisposalScheDate() == null) {
			// 예외 처리 또는 false 반환
			return false;
		}
		int rowsAffected = mapper.updateDisposalScheDate(dto);
		return rowsAffected == 1;
	}
	@Override
	public List<TestDataVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "getList with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	public String register(Principal principal, List<String> custidlist, List<String> custidlistNew, String reqreason, String aprvlineid, String applytype, String system, String sourceDB, String targetDB, String jobid, String idtype) {
		
		LogUtil.log("INFO", "register(List<TestDataVO>....."+ aprvlineid +"  "+applytype +"  "+ custidlist.toString() );
		String rst = "success";
		TestDataVO testdata = new TestDataVO();
		PiiApprovalReqVO piiapprovalreqvo = null;
		try {
			String custids = String.join(",", custidlist);
			String custidsNew = String.join(",", custidlistNew);
			int maxTestdataid = mapper.getMaxTestdataid() + 1;
			testdata.setTestdataid(maxTestdataid);
			testdata.setSystem(system);
			testdata.setSourcedb(sourceDB);
			testdata.setTargetdb(targetDB);
			testdata.setPhase("APPLY");
			testdata.setApply_type(applytype);
//			testdata.setNew_orderid(null);
			testdata.setJobid(jobid);
			testdata.setIdtype(idtype);
			testdata.setCustid(custids);
			testdata.setCustid_new(custidsNew);
			testdata.setCust_nm(null);
			testdata.setSsn(null);
			testdata.setNew_jobid(null);
			testdata.setStatus("NEW");
//			testdata.setApprove_date("");
//			testdata.setRegdate("");
//			testdata.setUpddate("");
			testdata.setReguserid(principal.getName());
			testdata.setUpduserid(memberMapper.read(principal.getName()).getUserName());
			//LogUtil.log("INFO", "before ##33 mapper.insert(testdata);....."+ testdata.toString() );
			mapper.insert(testdata);
			PiiApprovalReqVO approvalreq = new PiiApprovalReqVO();
			approvalreq.setJobid(maxTestdataid+"");
			approvalreq.setReqreason(reqreason);

			checkin(approvalreq, principal, aprvlineid, applytype);

		} catch (Exception e) {
			e.printStackTrace();
			logger.warn("warn "+"register(TestDataVO piitestdata)=> " + e.getMessage() + testdata.toString());
			rst = e.getMessage();
		}

		return rst;
			
	}

	@Override
	public PiiApprovalReqVO registerFromPlatform(List<String> custidlist, String reqreason, String aprvlineid, String applytype, int stepcnt, String requserid, String requsername, String system, String sourceDB, String targetDB, String jobid, String idtype) {

		LogUtil.log("INFO", "registerFromPlatform(extractVO....."+custidlist.toString() );
		String rst = "success";
		TestDataVO testdata = new TestDataVO();
		PiiApprovalReqVO piiapprovalreqvo = null;
		try {
			// 쉼표로 구분하여 String으로 변환합니다.
			String custids = String.join(",", custidlist);
			int maxTestdataid = mapper.getMaxTestdataid() + 1;
			testdata.setTestdataid(maxTestdataid);
			testdata.setSystem(system);
			testdata.setSourcedb(sourceDB);
			testdata.setTargetdb(targetDB);
			testdata.setPhase("APPLY");
			testdata.setApply_type(applytype);
//			testdata.setNew_orderid(null);
			testdata.setJobid(jobid);
			testdata.setIdtype(idtype);
			testdata.setCustid(custids);
			testdata.setCustid_new(null);
			testdata.setCust_nm(null);
			testdata.setSsn(null);
			testdata.setNew_jobid(null);
			testdata.setStatus("NEW");
//			testdata.setApprove_date("");
//			testdata.setRegdate("");
//			testdata.setUpddate("");
			testdata.setReguserid(requserid);
			testdata.setUpduserid(requsername);

			//LogUtil.log("INFO", "before ##33 mapper.insert(testdata);....."+ testdata.toString() );
			mapper.insert(testdata);
			PiiApprovalReqVO approvalreq = new PiiApprovalReqVO();
			approvalreq.setJobid(maxTestdataid+"");
			approvalreq.setReqreason(reqreason);
			//LogUtil.log("INFO", "after ##33 mapper.insert(piitestdata);....."+ approvalreq.toString() );
			piiapprovalreqvo = checkinFromPlatform(approvalreq, aprvlineid, applytype, stepcnt, requserid, requsername);
		} catch (Exception e) {
			logger.warn("warn "+testdata.toString());
			logger.warn("warn "+"register(TestDataVO piitestdata)=> "+e.getMessage());
			e.printStackTrace();
//			rst = e.getMessage();
		}

		return piiapprovalreqvo;

	}

	@Override
	public boolean remove(int testdataid) {
		
		LogUtil.log("INFO", "remove...." + testdataid);
		 
		return mapper.delete(testdataid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getMaxTestdataid() {
		
		LogUtil.log("INFO", "getMaxTestdataid");
		return mapper.getMaxTestdataid();
	}


	@Override
	public TestDataVO get(int testdataid) {

		 LogUtil.log("INFO", "get......" + testdataid);

		 return mapper.read(testdataid);
	}
	@Override
	public List<MasterKeymapVO> getListMasterKeymap(int new_orderid) {

		 LogUtil.log("INFO", "getListMasterKeymap......" + new_orderid);

		 return mapper.getListMasterKeymap(new_orderid);
	}

	@Override
	public boolean modify(TestDataVO piitestdata) {
		
		LogUtil.log("INFO", "modify......" + piitestdata);
		
		return mapper.update(piitestdata) == 1;
	}
	@Override
	public boolean modifyApprovalInfo(TestDataVO piitestdata) {

		LogUtil.log("INFO", "modifyApprovalInfo......" + piitestdata);

		return mapper.updateApprovalInfo(piitestdata) == 1;
	}
	@Override
	public boolean modifyStatus(int orderid) {
		
		LogUtil.log("INFO", "modifyStatus......" + orderid);
		
		return mapper.updateStatus(orderid) == 1;
	}
	@Override
	public boolean modifyDisposalStatus(int testdataid) {

		LogUtil.log("INFO", "modifyDisposalStatus......" + testdataid);

		return mapper.updateDisposalStatus(testdataid) == 1;
	}

	@Override
	public boolean requestapproval(int testdataid) {
		
		LogUtil.log("INFO", "requestapproval.....testdataid." + testdataid);
		return mapper.requestapproval(testdataid) == 1;
	}
	
	@Override
	public boolean approve(PiiApprovalReqVO approvalreqVO) {

		LogUtil.log("INFO", "approve....testdataid.." + approvalreqVO.getJobid());
		return mapper.approve(StrUtil.parseInt(approvalreqVO.getJobid())) == 1;
	}
	
	@Override
	public boolean reject(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "reject....testdataid.." + approvalreqVO.getJobid());
		approvalreqmapper.reject(approvalreqVO);
		return mapper.reject(StrUtil.parseInt(approvalreqVO.getJobid())) == 1;
	}
	
	@Override
	public String checkin(PiiApprovalReqVO approvalreq, Principal principal, String aprvlineid,  String applytype) {
		
		LogUtil.log("INFO", "checkin......" +aprvlineid+"-"+ approvalreq.toString());
		String applyId = null;
		if(applytype.equalsIgnoreCase("TESTDATA"))
			applyId = "TESTDATA_APPROVAL";
		
		try {
			mapper.requestapproval(StrUtil.parseInt(approvalreq.getJobid()));// PIITESTDATA 업데이트 Jobid 는 testdataid

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
			if("자동테스트데이터결재라인".equals(piiapprovalreqvo.getAprvlineid())){
				piiapprovalreqvo.setPhase("FINAL_APPROVAL");
			}else{
				piiapprovalreqvo.setPhase("APPLY");
			}
			approvalreqmapper.insert(piiapprovalreqvo);
			//logger.warn("WARN "+"insert: "+piiapprovalreqvo.toString());
			// ===== 자동결재 라인인 경우: 이력만 남기고 즉시 최종승인 처리 =====
			if ("자동테스트데이터결재라인".equalsIgnoreCase(piiapprovalreqvo.getAprvlineid())) {

				// 1) 스텝 승인 이력(SYSTEM) 남기기
				PiiApprovalStepReqVO stepReq = new PiiApprovalStepReqVO();
				stepReq.setReqid(piiapprovalreqvo.getReqid());
				stepReq.setAprvlineid(piiapprovalreqvo.getAprvlineid());
				stepReq.setSeq(piiapprovalreqvo.getSeq());        // 보통 "1"
				stepReq.setStepname("AUTO");
				stepReq.setStatus("APPROVED");
				stepReq.setApproverid("SYSTEM");
				stepReq.setApprovername("SYSTEM");
				stepReq.setComment("Auto approved");
				approvalStepReqMapper.insert(stepReq);

				// 3) TESTDATA 도메인 반영 + 오더
				boolean ok = this.approve(piiapprovalreqvo);
				if (!ok) {
					throw new IllegalStateException("Auto-approval failed to apply testdata: " + piiapprovalreqvo);
				}

				TestDataVO testDataVO = this.get(StrUtil.parseInt(piiapprovalreqvo.getJobid()));
				try {//logger.warn("WARN"+"orderTestdataJob: "+testDataVO.toString());
					this.orderTestdataJob(testDataVO);
				} catch (Exception e) {
					logger.warn("warn /TESTDATA_APPROVAL auto order failed {} {}", piiapprovalreqvo, e.getMessage());
					throw e;
				}
			}


		}catch (Exception e) {
			logger.warn("warn "+"Fail to apply Testdata => testdataid: "+approvalreq.getJobid()+"  "+e.getMessage());
			return "Fail to apply Testdata";
		}
		return "success";
	}
	@Override
	public PiiApprovalReqVO checkinFromPlatform(PiiApprovalReqVO approvalreq, String aprvlineid, String applytype, int stepcnt, String requserid, String requsername) {

		LogUtil.log("INFO", "checkinFromPlatform......" + approvalreq);
		PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
		try {
			mapper.requestapproval(StrUtil.parseInt(approvalreq.getJobid()));// Jobid => testdataid

			piiapprovalreqvo.setReqid(""+(approvalreqmapper.getMaxReqid()+1));
			piiapprovalreqvo.setAprvlineid(aprvlineid);
			piiapprovalreqvo.setSeq(stepcnt+"");
			piiapprovalreqvo.setApprovalid("TESTDATA_APPROVAL");
			piiapprovalreqvo.setPhase("FINAL_APPROVAL");
			piiapprovalreqvo.setJobid(approvalreq.getJobid());
			piiapprovalreqvo.setVersion(approvalreq.getVersion());
			piiapprovalreqvo.setRequesterid(requserid);
			piiapprovalreqvo.setRequestername(requsername);
			piiapprovalreqvo.setRegdate("");
			piiapprovalreqvo.setUpddate("");
			piiapprovalreqvo.setReqreason(approvalreq.getReqreason());
			//LogUtil.log("INFO", "approvalreqmapper.insert(piiapprovalreqvo);: "+piiapprovalreqvo);
			approvalreqmapper.insert(piiapprovalreqvo);
		}catch (Exception e) {
			logger.warn("warn "+"checkinFromPlatform Fail to apply Testdata => testdataid: "+approvalreq.getJobid()+"  "+e.getMessage());
		}
		return piiapprovalreqvo;
	}

	@Override
	// JPA 제거 후 auto-commit=true로 동작하므로 @Transactional 불필요
	// Lock wait timeout 방지를 위해 트랜잭션 제거
	public PiiOrderVO orderTestdataJob(TestDataVO piitestdata) {

		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		//SimpleDateFormat yyyymmddhms = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		Date today = new Date();
		String basedate = yyyymmdd.format(today);
		//String curtime = yyyymmddhms.format(today);
		PiiOrderVO piiorder = new PiiOrderVO();
		PiiOrderStepVO piiorderstep = new PiiOrderStepVO();
		PiiOrderStepTableVO piiordersteptable = new PiiOrderStepTableVO();

		String jobid = piitestdata.getJobid(); //"TESTDATA_AUTO_GEN";
		String jobid_new = jobid + piitestdata.getTestdataid();
		String jobname_new = "테스트데이터 자동생성 신청:" + piitestdata.getCustid();
		String sourceDb  = piitestdata.getSourcedb();
		String targetDb = piitestdata.getTargetdb();
		String idtype = piitestdata.getIdtype();

		/** CUSTID 인 경우 신청 정보가 "custid,custid,...." 이므로 그대로 쓰고 그 외 경우는  testDataIdType에 정의된 고객번호를 추출하는 sql을 직접  세팅한다 20240326 */
		String custidsfortestdata = StrUtil.wrapWithQuotes(piitestdata.getCustid());
		String custidsfortestdataNew = piitestdata.getCustid_new();
		if(!"CUSTID".equalsIgnoreCase(idtype)){
			TestDataIdTypeVO dataIdTypeVO = testDataIdTypeService.get(idtype);
			custidsfortestdata = dataIdTypeVO.getSqlstr().replaceAll("(?i)#APPLYIDS", custidsfortestdata);
		}

		LogUtil.log("INFO", "piitestdata===="+piitestdata.toString());
		LogUtil.log("INFO", "custidsfortestdata===="+custidsfortestdata);
		PiiJobVO piijob = jobMapper.read(jobid, jobMapper.getMaxVersionCheckinByJob(jobid)+"");
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

		LogUtil.log("INFO", "basedate="+basedate+"  jobid_new="+jobid_new);
		piiorder.setOrderid(newOrderId);
		piiorder.setBasedate(basedate);
		piiorder.setRuncnt(0);
		piiorder.setJobid(jobid_new);
		piiorder.setVersion(piijob.getVersion());
		piiorder.setJobname(jobname_new);
		piiorder.setSystem(piijob.getSystem());
		piiorder.setPolicy_id(null);
		piiorder.setKeymap_id(piijob.getKeymap_id());
		piiorder.setJobtype(piijob.getJobtype());
		piiorder.setRuntype(piijob.getRuntype());
		piiorder.setCalendar(piijob.getCalendar());
		piiorder.setTime(piijob.getTime());
		piiorder.setStatus("Wait condition");
		piiorder.setConfirmflag(piijob.getConfirmflag());
		piiorder.setHoldflag("N");
		piiorder.setForceokflag("N");
		piiorder.setKillflag("N");
		piiorder.setEststarttime(basedate + " " + "00:01" + ":00");
		piiorder.setRunningtime(" ");
		piiorder.setRealstarttime(" ");
		piiorder.setRealendtime(" ");
		piiorder.setJob_owner_id1(piijob.getJob_owner_id1());
		piiorder.setJob_owner_name1(piijob.getJob_owner_name1());
		piiorder.setJob_owner_id2(piijob.getJob_owner_id2());
		piiorder.setJob_owner_name2(piijob.getJob_owner_name2());
		piiorder.setJob_owner_id3(piitestdata.getReguserid());
		piiorder.setJob_owner_name3(piitestdata.getUpduserid());

		piiorder.setOrderdate(" ");
		piiorder.setOrderuserid(piitestdata.getReguserid());
		orderMapper.insert(piiorder);

		List<PiiStepVO> steplist = stepMapper.getJobList(piijob.getJobid(), piijob.getVersion());
		for (PiiStepVO piistep : steplist) {
			if (piistep.getStatus().equals("INACTIVE"))
				continue;

			piiorderstep.setOrderid(newOrderId);

			if (piistep.getStatus().equals("HOLD"))
				piiorderstep.setStatus("Hold");
			else
				piiorderstep.setStatus("Wait condition");

			piiorderstep.setConfirmflag("N");
			piiorderstep.setHoldflag("N");
			piiorderstep.setForceokflag("N");
			piiorderstep.setKillflag("N");
			piiorderstep.setBasedate(basedate);
			piiorderstep.setThreadcnt(piistep.getThreadcnt());
			piiorderstep.setCommitcnt(piistep.getCommitcnt());
			piiorderstep.setRuncnt("0");
			piiorderstep.setJobid(piistep.getJobid());
			piiorderstep.setVersion(piistep.getVersion());
			piiorderstep.setStepid(piistep.getStepid());
			piiorderstep.setStepname(piistep.getStepname());
			piiorderstep.setSteptype(piistep.getSteptype());
			piiorderstep.setStepseq(piistep.getStepseq());
			if (piistep.getStepid().equals("GEN_KEYMAP")
					|| piistep.getStepid().equals("MIG_KEYMAP")
					|| piistep.getStepid().equals("GEN_MASTER_KEYMAP")
					|| piistep.getStepid().equals("EXE_TRANSFORM") ) {
				piiorderstep.setDb(sourceDb);
			}
			else if (piistep.getStepid().equals("BROADCAST_MASTERKEY")
					|| piistep.getStepid().equals("EXE_FINISH")) {
				piiorderstep.setDb(targetDb);
			}

			piiorderstep.setTotaltabcnt("" + steptableMapper.getTotalTabCnt(piijob.getJobid(), piijob.getVersion(), piistep.getStepid()));
			piiorderstep.setSuccesstabcnt("0");
			piiorderstep.setRunningtime(" ");
			piiorderstep.setRealstarttime(" ");
			piiorderstep.setRealendtime(" ");
			piiorderstep.setOrderuserid(piijob.getReguserid());
			/** 20231004 scramble 관련 추가*/
			piiorderstep.setData_handling_method(piistep.getData_handling_method());
			piiorderstep.setProcessing_method(piistep.getProcessing_method());
			piiorderstep.setFk_disable_flag(piistep.getFk_disable_flag());
			piiorderstep.setIndex_unusual_flag(piistep.getIndex_unusual_flag());
			piiorderstep.setVal1(piistep.getVal1());
			piiorderstep.setVal2(piistep.getVal2());
			piiorderstep.setVal3(piistep.getVal3());
			piiorderstep.setVal4(piistep.getVal4());
			piiorderstep.setVal5(piistep.getVal5());
			orderstepMapper.insert(piiorderstep);

			List<PiiStepTableVO> steptablelist = steptableMapper.getJobStepTableList(piijob.getJobid(), piijob.getVersion(), piistep.getStepid());
			for (PiiStepTableVO piisteptable : steptablelist) {
				piiordersteptable.setOrderid(newOrderId);
				piiordersteptable.setStatus("Wait condition");
				piiordersteptable.setForceokflag("N");
				piiordersteptable.setBasedate(basedate);
				piiordersteptable.setJobid(piistep.getJobid());
				piiordersteptable.setVersion(piistep.getVersion());
				piiordersteptable.setStepid(piistep.getStepid());
				piiordersteptable.setStepname(piistep.getStepname());
				piiordersteptable.setSteptype(piistep.getSteptype());
				piiordersteptable.setStepseq(piistep.getStepseq());
				if (piistep.getStepid().equals("MIG_KEYMAP")
						|| piistep.getStepid().equals("GEN_MASTER_KEYMAP")
						|| piistep.getStepid().equals("EXE_TRANSFORM")) {
					piiordersteptable.setDb(targetDb);
				} else if (piistep.getStepid().equals("GEN_KEYMAP")) {
					piiordersteptable.setDb(sourceDb);
				} else if (piistep.getStepid().equals("BROADCAST_MASTERKEY")
						|| piistep.getStepid().equals("EXE_FINISH")) {
					piiordersteptable.setDb(piisteptable.getDb());
				}
				piiordersteptable.setOwner(piisteptable.getOwner());
				piiordersteptable.setTable_name(piisteptable.getTable_name());
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPagitype())) {
						piiordersteptable.setPagitype(piisteptable.getPagitype());
					}else {
						piiordersteptable.setPagitype(piistep.getFk_disable_flag());
					}
					if (!StrUtil.checkString(piisteptable.getPagitypedetail())) {
						piiordersteptable.setPagitypedetail(piisteptable.getPagitypedetail());
					}else {
						piiordersteptable.setPagitypedetail(piistep.getIndex_unusual_flag());
					}
				}else {
					piiordersteptable.setPagitype(piisteptable.getPagitype());
					piiordersteptable.setPagitypedetail(piisteptable.getPagitypedetail());
				}
				piiordersteptable.setExetype(piisteptable.getExetype());
				piiordersteptable.setArchiveflag(piisteptable.getArchiveflag());
				if (piistep.getSteptype().equals("GEN_KEYMAP")) {// Exceptionallly used for GEN_KEYMAP step
					piiordersteptable.setPreceding(piisteptable.getKeymap_id());
					piiordersteptable.setSuccedding(piisteptable.getKey_name());
				}
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPreceding())) {
						piiordersteptable.setPreceding(piisteptable.getPreceding());
					}else {
						piiordersteptable.setPreceding(piistep.getData_handling_method());
					}
					if (!StrUtil.checkString(piisteptable.getSuccedding())) {
						piiordersteptable.setSuccedding(piisteptable.getSuccedding());
					}else {
						piiordersteptable.setSuccedding(piistep.getProcessing_method());
					}
				}
				piiordersteptable.setSeq1(piisteptable.getSeq1());
				piiordersteptable.setSeq2(piisteptable.getSeq2());
				piiordersteptable.setSeq3(piisteptable.getSeq3());
				if (piistep.getSteptype().equals("EXE_SCRAMBLE") || piistep.getSteptype().equals("EXE_ILM") || piistep.getSteptype().equals("EXE_MIGRATE") || piistep.getSteptype().equals("EXE_SYNC")) {// Exceptionallly used for EXE_SCRAMBLE step  20231017
					if (!StrUtil.checkString(piisteptable.getPipeline())) {
						piiordersteptable.setPipeline(piisteptable.getPipeline());
					}else {
						piiordersteptable.setPipeline(piistep.getVal1());
					}
				}else {
					piiordersteptable.setPipeline(piisteptable.getPipeline());
				}
				piiordersteptable.setPk_col(piisteptable.getPk_col());
				piiordersteptable.setWhere_col(piisteptable.getWhere_col());
				piiordersteptable.setWhere_key_name(piisteptable.getWhere_key_name());
				piiordersteptable.setParallelcnt(piisteptable.getParallelcnt());
				if (piisteptable.getCommitcnt() == null || piisteptable.getCommitcnt().length() == 0) {
					piiordersteptable.setCommitcnt(piistep.getCommitcnt());
				} else {
					piiordersteptable.setCommitcnt(piisteptable.getCommitcnt());
				}

				String dbtype = null;
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
				String wherestr = "NULL";
				String sqlstr = "NULL";

				try {
					wherestr = piisteptable.getWherestr();

					if (!StrUtil.checkString(wherestr)) {
						if (!StrUtil.checkString(del_deadline))
							wherestr = wherestr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
						if (!StrUtil.checkString(arc_del_deadline))
							wherestr = wherestr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
						if (!StrUtil.checkString(piistep.getDb()))
							wherestr = wherestr.replaceAll("(?i)#DATABASEID", piistep.getDb());
//						if (!StrUtil.checkString(piijob.getKeymap_id()))
//							wherestr = wherestr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());
						wherestr = wherestr.replaceAll("(?i)#KEYMAP_ID", newOrderId + "");// 20240129 for 테스트데이터 신청 키맵은 ORDERID로

						try {
							if (!StrUtil.checkString( EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT")))
								wherestr = wherestr.replaceAll("(?i)#DLM_EXTRACT_MAX_CNT",  EnvConfig.getConfig("DLM_EXTRACT_MAX_CNT"));
						} catch (NullPointerException ex) {

						}

						String basedate_ymd = basedate.replace("/", "");
						wherestr = wherestr.replaceAll("(?i)#BASEDATEYMD", basedate_ymd);// #BASEDATEYMD 가 #BASEDATE 보다 먼저와야
						wherestr = wherestr.replaceAll("(?i)#BASEDATE", basedate);
						wherestr = wherestr.replaceAll("(?i)#ORDERID", newOrderId + "");
						wherestr = wherestr.replaceAll("(?i)#JOBID", piistep.getJobid());
						wherestr = wherestr.replaceAll("(?i)#STEPID", piistep.getStepid());
						wherestr = wherestr.replaceAll("(?i)#DBNAME", piisteptable.getDb());// 20220517 for Catalog batch
						wherestr = wherestr.replaceAll("(?i)#CUSTIDSFORTESTDATA", custidsfortestdata);// 20240326 여러 타입의 신청id가 있어서 고객번호를 생성하는 쿼리 또는 고객번호로 세팅함

						/** 고정고객번호로 테스트데이터 신청 요건 반영을 위해 20250111*/
						// #CUSTIDSFIEXED 앞의 고객번호 칼럼명을 추출
						//LogUtil.log("INFO", wherestr);
						String[] oldIds = custidsfortestdata.split(",");
						String[] newIds = custidsfortestdataNew.split(",");
						if(oldIds.length == newIds.length) { // 자바에서 ",,,".split(",")의 길이는 0이므로 에러 방지를 위해
							String custidColName = SqlUtil.getColumnNameBeforeMapping(wherestr, "#CUSTIDSFIEXED");
							StringBuilder caseStr = new StringBuilder("CASE CAST(" + custidColName + " AS VARCHAR(100)) ");
							//LogUtil.log("INFO", oldIds + " == " + newIds + "  ==  " + caseStr);
							for (int i = 0; i < oldIds.length; i++) {
								caseStr.append("WHEN ").append(oldIds[i].trim()).append(" THEN '").append(newIds[i].trim()).append("' ");
							}
							caseStr.append("ELSE NULL END AS CUSTIDSFIEXED");
							//LogUtil.log("INFO", oldIds+"  "+newIds+"  "+caseStr);
							wherestr = wherestr.replaceAll("(?i)#CUSTIDSFIEXED", caseStr.toString());
							//LogUtil.log("INFO", oldIds+"  "+newIds+"  "+wherestr);
						}
					}
				} catch (NullPointerException ex) {
					logger.warn("warn "+"Wherestr is NULL => NullPointerException: "+piiordersteptable.getJobid()+" "+piiordersteptable.getTable_name());
					ex.printStackTrace();
					throw ex;
				}

				//BROADCAST의 경우만 step의 원천db 정보를 읽고 그 외는 모두 테이블레벨의 db 정보를 읽는데 위에서 이미 세팅되었다.
				if (piisteptable.getExetype().equals("BROADCAST")) {
					dbtype = databaseMapper.read(piiorderstep.getDb()).getDbtype();
				}

				wherestr = SqlUtil.convertDateformat(dbtype, wherestr);

				piiordersteptable.setWherestr(wherestr);
				try {
					sqlstr = piisteptable.getSqlstr();
					if (!StrUtil.checkString(sqlstr)) {
						if (!StrUtil.checkString(del_deadline))
							sqlstr = sqlstr.replaceAll("(?i)#DEL_DEADLINE", del_deadline);
						if (!StrUtil.checkString(arc_del_deadline))
							sqlstr = sqlstr.replaceAll("(?i)#ARC_DEL_DEADLINE", arc_del_deadline);
						if (!StrUtil.checkString(piistep.getDb()))
							sqlstr = sqlstr.replaceAll("(?i)#DATABASEID", piistep.getDb());
//						if (!StrUtil.checkString(piijob.getKeymap_id()))
//							sqlstr = sqlstr.replaceAll("(?i)#KEYMAP_ID", piijob.getKeymap_id());
						sqlstr = sqlstr.replaceAll("(?i)#KEYMAP_ID", newOrderId + "");// 20240129 for 테스트데이터 신청 키맵은 ORDERID로
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
						sqlstr = sqlstr.replaceAll("(?i)#CUSTIDSFORTESTDATA", custidsfortestdata);// 20240129 for 테스트데이터 신청 고객번호 리스트

						/** 고정고객번호로 테스트데이터 신청 요건 반영을 위해 20250111*/

						String[] newIds = custidsfortestdataNew.split(",");
						String[] oldIds = custidsfortestdata.split(",");
						if(oldIds.length == newIds.length) { // 자바에서 ",,,".split(",")의 길이는 0이므로 에러 방지를 위해
							// #CUSTIDSFIEXED 앞의 고객번호 칼럼명을 추출
							String custidColName = SqlUtil.getColumnNameBeforeMapping(sqlstr, "#CUSTIDSFIEXED");
							StringBuilder caseStr = new StringBuilder("CASE CAST(" + custidColName + " AS VARCHAR(100)) ");
							for (int i = 0; i < oldIds.length; i++) {
								caseStr.append("WHEN ").append(oldIds[i].trim()).append(" THEN '").append(newIds[i].trim()).append("' ");
							}
							caseStr.append("ELSE NULL END AS CUSTIDSFIEXED");
							sqlstr = sqlstr.replaceAll("(?i)#CUSTIDSFIEXED", caseStr.toString());
						}
					}
				} catch (NullPointerException ex) {
					logger.warn("warn "+"Sqlstr is NULL => NullPointerException: " + piiordersteptable.getJobid() + " " + piiordersteptable.getTable_name());
					ex.printStackTrace();
					throw ex;
				}
				sqlstr = SqlUtil.convertDateformat(dbtype, sqlstr);
				piiordersteptable.setSqlstr(sqlstr);

				//20210423 Add hint by cha
				if (piistep.getSteptype().equals("GEN_KEYMAP") || piistep.getSteptype().equals("EXE_ARCHIVE") || piistep.getSteptype().equals("EXE_DELETE")) {
					String hint = "";
					String joinHint = null;

					// 1. ConfigKey 결정
					if (piiordersteptable.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP B")) {
						joinHint = EnvConfig.getConfig("DLM_KEYMAP_JOIN_HINT");
					} else if (piiordersteptable.getWherestr().toUpperCase().contains("COTDL.TBL_PIIKEYMAP_HIST B")) {
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

						piiordersteptable.setWherestr(
								piiordersteptable.getWherestr().replaceFirst("(?i)SELECT ", replacement)
						);
						piiordersteptable.setSqlstr(
								piiordersteptable.getSqlstr().replaceFirst("(?i)SELECT ", replacement)
						);
					}
				}

				// Arc fields are not used
//	        	piiordersteptable.setArccnt(null);
//	        	piiordersteptable.setArctime(null);
//	        	piiordersteptable.setArcstart(null);
//	        	piiordersteptable.setArcend(null);

				piiordersteptable.setExecnt("0");
				piiordersteptable.setExetime(null);
				piiordersteptable.setExestart(null);
				piiordersteptable.setExeend(null);
				piiordersteptable.setSqlmsg(null);
/* 20250302 added*/
				piiordersteptable.setHintselect(piisteptable.getHintselect());
				piiordersteptable.setHintinsert(piisteptable.getHintinsert());
				piiordersteptable.setUval1(piisteptable.getUval1());
				piiordersteptable.setUval2(piistep.getVal2());
				piiordersteptable.setUval3(piisteptable.getUval3());
				piiordersteptable.setUval4(piisteptable.getUval4());
				piiordersteptable.setUval5(piisteptable.getUval5());

				ordersteptableMapper.insert(piiordersteptable);
			}
		}
		//-----------------------------------------------------------------------------
		//update Testdata status
		piitestdata.setStatus("ORDERED");
		piitestdata.setNew_orderid(newOrderId);
		//LogUtil.log("INFO", "before ##22 mapper.update(piitestdata); => "+ piitestdata.toString());
		mapper.updateApprovalInfo(piitestdata);
		//LogUtil.log("INFO", "after ##22 mapper.update(piitestdata); => "+ "success");


		return piiorder;
	}

	public List<TestDataCombinedStatusVO> getTestDataStatus(String startDate, String endDate) {
		// 실제 비즈니스 로직 (예: 날짜 유효성 검사, 권한 체크 등)을 추가할 수 있습니다.
		return mapper.getCombinedTestDataStatus(startDate, endDate);
	}
}
