package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.security.Principal;
import java.util.List;

@Service
@RequiredArgsConstructor // Lombok이 모든 final 필드를 받는 생성자 생성
public class PiiJobServiceImpl implements PiiJobService {
	private static final Logger logger = LoggerFactory.getLogger(PiiJobServiceImpl.class);
	private final PiiJobMapper mapper;
	private final PiiApprovalReqMapper approvalreqmapper;
	private final PiiStepMapper stepmapper;
	private final PiiStepTableMapper steptablemapper;
	private final PiiJobWaitMapper jobwaitmapper;
	private final PiiStepTableWaitMapper steptablewaitmapper;
	private final PiiStepTableUpdateMapper steptableupdatemapper;
	private final PiiApprovalReqMapper approvalReqMapper;
	private final PiiApprovalStepReqMapper approvalStepReqMapper;
	private final ArchiveNamingService archiveNamingService;

	@Override
	public List<PiiJobVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiJobVO> getTestdataAutoGenList() {

		LogUtil.log("INFO", "getTestdataAutoGenList: " );

		return mapper.getTestdataAutoGenList();
	}

	@Override
	public List<PiiKeymapPkVO> getKeymapList() {
		
		LogUtil.log("INFO", "getKeymapList List: " );
		
		return mapper.getKeymapList();
	}
	
	@Override
	public List<PiiJobVO> getActiveList(Criteria cri) {
		
		LogUtil.log("INFO", "get getActiveList with criteria: " + cri);
		
		return mapper.getActiveList(cri);
	}

	@Override
	public List<PiiJobVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}
	
	@Override
	public List<PiiJobVO> getAllVersionList(String jobid) {
		
		LogUtil.log("INFO", "getAllVersionList with jobid: " + jobid);
		
		return mapper.getAllVersionList(jobid);
	}
	@Override
	public List<PiiJobVO> getExeJobList(String basedate) {

		LogUtil.log("INFO", "getExeJobList with basedate: " + basedate);

		return mapper.getExeJobList(basedate);
	}
	
	@Override
	@Transactional
	public void register(PiiJobVO piijob, String db) {
		
		 LogUtil.log("INFO", "register......" + piijob);
//		 mapper.insert(piijob); 
		 mapper.insertSelectKey(piijob); 
		 
		 PiiStepVO piistep = new PiiStepVO();
		 piistep.setJobid(piijob.getJobid());
		 piistep.setVersion("1");
		 piistep.setStepid("EXE_EXTRACT");
		 piistep.setStepname(piijob.getJobname()+" 대상 추출");
		 piistep.setSteptype("EXE_EXTRACT");
		 piistep.setStepseq("1");
		 piistep.setDb(db);
		 piistep.setStatus("ACTIVE");
		 piistep.setPhase("CHECKOUT");
		 piistep.setThreadcnt("1");
		 piistep.setCommitcnt("3000");
		 //piistep.setEnddate(NULL);
		 //piistep.setRegdate(NULL);
		 //piistep.setUpddate(NULL);
		 piistep.setReguserid(piijob.getReguserid());
		 piistep.setUpduserid(piijob.getUpduserid());

		 stepmapper.insert(piistep);
		 piistep.setStepid("GEN_KEYMAP");
		 piistep.setStepname(piijob.getJobname()+" 키맵 생성");
		 piistep.setSteptype("GEN_KEYMAP");
		 piistep.setStepseq("2");
		 piistep.setThreadcnt("1");
		 stepmapper.insert(piistep);
		 piistep.setStepid("EXE_ARCHIVE");
		 piistep.setStepname(piijob.getJobname()+" 데이터 아카이브");
		 piistep.setSteptype("EXE_ARCHIVE");
		 piistep.setStepseq("3");
		 piistep.setThreadcnt("5");
		 stepmapper.insert(piistep);
		 piistep.setStepid("EXE_DELETE");
		 piistep.setStepname(piijob.getJobname()+" 삭제 수행");
		 piistep.setSteptype("EXE_DELETE");
		 piistep.setStepseq("4");
		 piistep.setThreadcnt("5");
		 stepmapper.insert(piistep);
		 piistep.setStepid("EXE_BROADCAST");
		 piistep.setStepname(piijob.getJobname()+" BROADCAST");
		 piistep.setSteptype("EXE_BROADCAST");
		 piistep.setStepseq("5");
		 piistep.setThreadcnt("5");
		 stepmapper.insert(piistep);
		 piistep.setStepid("EXE_FINISH");
		 piistep.setStepname(piijob.getJobname()+" 마무리");
		 piistep.setSteptype("EXE_FINISH");
		 piistep.setStepseq("6");
		 piistep.setThreadcnt("1");
		 stepmapper.insert(piistep);
		 
		 
		 }
		 
	@Override
	@Transactional
	public void copy(PiiJobVO piijob_copy ,String jobid, String version) {
		
		LogUtil.log("INFO", "copy...." + piijob_copy.getJobid());
		String wherestr = null;
		String sqlstr = null;
		//piijob_copy.setSystem("");

		mapper.insert(piijob_copy);
		List<PiiStepVO> steplist = stepmapper.getJobList(jobid, version);
		for(int i=0;i<steplist.size();i++){
			PiiStepVO stepvo = steplist.get(i);
			//if(stepvo.getSteptype().equalsIgnoreCase("EXE_ARCHIVE") || stepvo.getSteptype().equalsIgnoreCase("EXE_DELETE")) {
	            stepvo.setJobid(piijob_copy.getJobid());
	            stepvo.setVersion("1");
	            //stepvo.setStatus("ACTIVE"); just use the same status from original step
	            stepvo.setPhase("CHECKOUT");
	            stepmapper.insert(stepvo);
	            
	            List<PiiStepTableVO> steptablelist = steptablemapper.getJobStepTableList(jobid, version, stepvo.getStepid());
	            for(int j=0;j<steptablelist.size();j++){
	            	PiiStepTableVO steptablevo = steptablelist.get(j);
	            	steptablevo.setJobid(piijob_copy.getJobid());
	            	steptablevo.setVersion("1");
	            	if(!StrUtil.checkString(steptablevo.getWherestr())) {
	        			wherestr = steptablevo.getWherestr().replaceAll(jobid, piijob_copy.getJobid());
		            	steptablevo.setWherestr(wherestr);
	            	}
	            	if(!StrUtil.checkString(steptablevo.getSqlstr())) {
	            		sqlstr = steptablevo.getSqlstr().replaceAll(jobid, piijob_copy.getJobid());
	            		steptablevo.setSqlstr(sqlstr);
	            	}
	            	steptablemapper.insert(steptablevo);
	            }
			//}
        }
		
		List<PiiStepTableWaitVO> steptablewaitlist = steptablewaitmapper.getJobList(jobid, version);
		for(int i=0;i<steptablewaitlist.size();i++){
			PiiStepTableWaitVO steptablewaitvo = steptablewaitlist.get(i);
			steptablewaitvo.setJobid(piijob_copy.getJobid());
			steptablewaitvo.setVersion("1");
			steptablewaitmapper.insert(steptablewaitvo);
        }
		
		List<PiiJobWaitVO> jobwaitlist = jobwaitmapper.getList(jobid, version);
		for(int i=0;i<jobwaitlist.size();i++){
			PiiJobWaitVO jobwaitvo = jobwaitlist.get(i);
			jobwaitvo.setJobid(piijob_copy.getJobid());
			jobwaitvo.setVersion("1");
			jobwaitmapper.insert(jobwaitvo);
        }
	
		List<PiiStepTableUpdateVO> jobupdatelist = steptableupdatemapper.getJobList(jobid, version);
		for(int i=0;i<jobupdatelist.size();i++){
			PiiStepTableUpdateVO jobupdatevo = jobupdatelist.get(i);
			jobupdatevo.setJobid(piijob_copy.getJobid());
			jobupdatevo.setVersion("1");
			steptableupdatemapper.insert(jobupdatevo);
		}
		
	}
	
	@Override
	@Transactional
	public void copyBackdated(PiiJobVO piijob_copy ,String jobid, String version) {
		
		LogUtil.log("INFO", "copyBackdated...." + piijob_copy.toString());
		String wherestr = null;
		String sqlstr = null;
		
		piijob_copy.setConfirmflag("Y");
		piijob_copy.setRuntype("BACKDATED");
		mapper.insert(piijob_copy);
		
		List<PiiStepVO> steplist = stepmapper.getJobList(jobid, version);
		for(int i=0;i<steplist.size();i++){
			PiiStepVO stepvo = steplist.get(i);
			if (stepvo.getSteptype().equalsIgnoreCase("EXE_ARCHIVE")
					|| stepvo.getSteptype().equalsIgnoreCase("EXE_DELETE")
					|| stepvo.getSteptype().equalsIgnoreCase("EXE_UPDATE")
					) {
				stepvo.setJobid(piijob_copy.getJobid());
				stepvo.setVersion("1");
				stepvo.setStatus("ACTIVE");
				stepvo.setPhase("CHECKIN");
				stepmapper.insert(stepvo);
				
				List<PiiStepTableVO> steptablelist = steptablemapper.getJobStepTableList(jobid, version, stepvo.getStepid());
				for(int j=0;j<steptablelist.size();j++){
					PiiStepTableVO steptablevo = steptablelist.get(j);
					steptablevo.setJobid(piijob_copy.getJobid());
					steptablevo.setVersion("1");
					steptablevo.setPagitypedetail("BACKDATED");
					
					wherestr = steptablevo.getWherestr().replaceAll("(?i)COTDL.TBL_PIIKEYMAP ", "COTDL.TBL_PIIKEYMAP_HIST ");
					wherestr = wherestr.replaceAll("(?i)= TO_DATE\\('#BASEDATE'", "<= TO_DATE\\('#BASEDATE'");
					
					sqlstr = steptablevo.getSqlstr().replaceAll("(?i)COTDL.TBL_PIIKEYMAP ", "COTDL.TBL_PIIKEYMAP_HIST ");
					sqlstr = sqlstr.replaceAll("(?i)= TO_DATE\\('#BASEDATE'", "<= TO_DATE\\('#BASEDATE'");
					
					steptablevo.setWherestr(wherestr);
					steptablevo.setSqlstr(sqlstr);
					steptablemapper.insert(steptablevo);
				}
			}
		}
		
		List<PiiStepTableUpdateVO> jobupdatelist = steptableupdatemapper.getJobList(jobid, version);
		for(int i=0;i<jobupdatelist.size();i++){
			PiiStepTableUpdateVO jobupdatevo = jobupdatelist.get(i);
			jobupdatevo.setJobid(piijob_copy.getJobid());
			jobupdatevo.setVersion("1");
			steptableupdatemapper.insert(jobupdatevo);
		}
	
	}
	
	@Override
	@Transactional
	public void copyRecovery(PiiJobVO piijob_copy ,String jobid, String version) {
		
		LogUtil.log("INFO", "copyRecovery...." + piijob_copy.toString());
		String wherestr = null;
		String sqlstr = null;
		PiiStepVO stepvo = null;
		PiiStepTableVO steptablevo = null;
		String steptype_new = "EXE_RECOVERY";
		String stepid_new = "EXE_RECOVERY";
		String exetype_new = "RECOVERY";
		String pagitypedetail_new = null;
		String stepid_old = null;
		String steptype_old = null;

		piijob_copy.setConfirmflag("Y");
		piijob_copy.setRuntype("RECOVERY");
		
		mapper.insert(piijob_copy);

		List<PiiStepVO> steplist = stepmapper.getJobList(jobid, version);
		for(int i=0;i<steplist.size();i++){
			stepvo = steplist.get(i);
			stepid_old = stepvo.getStepid();
			steptype_old = stepvo.getSteptype();
			steptype_new = "EXE_RECOVERY";
			stepid_new = "EXE_RECOVERY";
			exetype_new = "RECOVERY";
			if (steptype_old.equalsIgnoreCase("EXE_DELETE")	|| steptype_old.equalsIgnoreCase("EXE_UPDATE") ) {
				
				if (steptype_old.equalsIgnoreCase("EXE_DELETE")) {
					stepid_new = "EXE_RECOVERY";
					pagitypedetail_new = "RECOVERY";
				}else {
					stepid_new = "EXE_RECOVERY_U";
					pagitypedetail_new = "RECOVERY_U";
				}
				stepvo.setStepid(stepid_new);
				stepvo.setStepname(stepid_new);
				stepvo.setSteptype(steptype_new);
				stepvo.setJobid(piijob_copy.getJobid());
				stepvo.setVersion("1");
				stepvo.setStepseq("1");
				stepvo.setStatus("ACTIVE");
				stepvo.setPhase("CHECKIN");
				stepmapper.insert(stepvo);
				
				List<PiiStepTableVO> steptablelist = steptablemapper.getJobStepTableList(jobid, version, stepid_old);
				LogUtil.log("INFO", "copyRecovery...." + jobid +"-"+ version);
				for(int j=0;j<steptablelist.size();j++){
					steptablevo = steptablelist.get(j);
					steptablevo.setJobid(piijob_copy.getJobid());
					steptablevo.setVersion("1");

					steptablevo.setStepid(stepid_new);
					steptablevo.setExetype(exetype_new);
					steptablevo.setPagitypedetail(pagitypedetail_new);
					steptablevo.setWherestr("PII_JOB_ID='"+jobid+"'  AND PII_BASE_DATE <= TO_DATE('#BASEDATE','yyyy/mm/dd') ");
					String archiveTablePath = archiveNamingService.getArchiveTablePath(ArchiveNamingService.CONFIG_TYPE_PII, steptablevo.getDb(), steptablevo.getOwner(), steptablevo.getTable_name());
					steptablevo.setSqlstr("insert into "+steptablevo.getOwner()+"."+steptablevo.getTable_name()+" SELECT * FROM "+archiveTablePath+" WHERE "+steptablevo.getWherestr());
					if (steptype_old.equalsIgnoreCase("EXE_UPDATE")) {
						steptablevo.setSqlstr("UPDATE "+steptablevo.getOwner()+"."+steptablevo.getTable_name()+" SET #UPDATECOLS WHERE (" + steptablevo.getPk_col() +") IN(  SELECT " + steptablevo.getPk_col() +" FROM "+archiveTablePath+" WHERE "+steptablevo.getWherestr()+" )");
					}
					steptablemapper.insert(steptablevo);
				}
			}
		}

		List<PiiStepTableUpdateVO> jobupdatelist = steptableupdatemapper.getJobList(jobid, version);
		for(int i=0;i<jobupdatelist.size();i++){
			PiiStepTableUpdateVO jobupdatevo = jobupdatelist.get(i);
			jobupdatevo.setJobid(piijob_copy.getJobid());
			jobupdatevo.setVersion("1");
			jobupdatevo.setStepid("EXE_RECOVERY_U");
			steptableupdatemapper.insert(jobupdatevo);
		}
		/* No needs EXE_FINISH
		 * 
		 */		
//		stepvo.setStepid("EXE_FINISH");
//		stepvo.setStepname("EXE_FINISH");
//		stepvo.setSteptype("EXE_FINISH");
//		stepvo.setStepseq("2");
//		stepmapper.insert(stepvo);
//		
//		steptablevo.setStepid("EXE_FINISH");
//		steptablevo.setOwner("COTDL");
//		steptablevo.setTable_name("TBL_PIIKEYMAP_HIST");
//		steptablevo.setPagitype(null);
//		steptablevo.setPagitypedetail(null);
//		steptablevo.setExetype("FINISH");
//		steptablevo.setArchiveflag(null);
//		steptablevo.setPreceding(null);
//		steptablevo.setSuccedding(null);
//		steptablevo.setSeq1(10);
//		steptablevo.setSeq2(100);
//		steptablevo.setSeq3(10);
//		steptablevo.setPipeline(null);
//		steptablevo.setWhere_col("keymap_id,basedate");
//		steptablevo.setWhere_key_name(null);
//		steptablevo.setParallelcnt("1");
//		steptablevo.setCommitcnt("3000");
//		steptablevo.setWherestr("keymap_id='#KEYMAP_ID' and "+"BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')");
//		steptablevo.setSqlstr("DELETE from "+"COTDL"+"."+"TBL_PIIKEYMAP_HIST"+" WHERE "+steptablevo.getWherestr());
//		steptablemapper.insert(steptablevo);
		
	}
	
	@Override
	@Transactional
	public boolean remove(String jobid, String version) {
		
		LogUtil.log("INFO", "remove...." + jobid);
		steptableupdatemapper.deletebyjobid(jobid, version);
		steptablewaitmapper.deletebyjobid(jobid, version);
		jobwaitmapper.deleteJob(jobid, version);
		steptablemapper.deleteJobTable(jobid, version);
		stepmapper.deleteJobStep(jobid, version);
		return mapper.delete(jobid,version) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getPiiTotalCount() {

		LogUtil.log("INFO", "getPiiTotalCount");
		return mapper.getPiiTotalCount();
	}

	@Override
	public int getMaxVersionByJob(String jobid) {
		
		LogUtil.log("INFO", "getMaxVersionByJob max(cast(version as INTEGER))");
		return mapper.getMaxVersionByJob(jobid);
	}
	@Override
	public int getMaxVersionCheckinByJob(String jobid) {

		LogUtil.log("INFO", "getMaxVersionCheckinByJob max(cast(version as INTEGER))");
		return mapper.getMaxVersionCheckinByJob(jobid);
	}

	@Override
	public PiiJobVO get(String jobid, String version) {
		
		 LogUtil.log("INFO", "get......" + jobid);
		 
		 return mapper.read(jobid,version);
	}

	@Override
	@Transactional
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "checkout......" + jobid+"-"+version);

		stepmapper.checkout(jobid, version);
		steptablemapper.checkout(jobid, version);
		steptablewaitmapper.checkout(jobid, version);
		steptableupdatemapper.checkout(jobid, version);
		jobwaitmapper.checkout(jobid, version);
		
		mapper.checkout(jobid, version);

	}
	@Override
	@Transactional
	public String checkin(PiiApprovalReqVO approvalreq, Principal principal) {
		
		LogUtil.log("INFO", "checkin......" + approvalreq);
		try {	
			mapper.checkin(approvalreq.getJobid(), approvalreq.getVersion());
			stepmapper.checkin(approvalreq.getJobid(), approvalreq.getVersion());

			PiiApprovalReqVO piiapprovalreqvo = new PiiApprovalReqVO();
			piiapprovalreqvo.setReqid(""+(approvalReqMapper.getMaxReqid()+1));
			piiapprovalreqvo.setAprvlineid(approvalreq.getAprvlineid());
			piiapprovalreqvo.setSeq("1");
			piiapprovalreqvo.setApprovalid(approvalreq.getApprovalid());
			piiapprovalreqvo.setJobid(approvalreq.getJobid());
			piiapprovalreqvo.setVersion(approvalreq.getVersion());
			piiapprovalreqvo.setRequesterid(principal.getName());
			piiapprovalreqvo.setRequestername(principal.getName());
			piiapprovalreqvo.setRegdate("");
			piiapprovalreqvo.setUpddate("");
			piiapprovalreqvo.setReqreason(approvalreq.getReqreason());
			if("자동JOB결재라인".equalsIgnoreCase(piiapprovalreqvo.getAprvlineid())){
				piiapprovalreqvo.setPhase("FINAL_APPROVAL");
			}else{
				piiapprovalreqvo.setPhase("APPLY");
			}
			approvalReqMapper.insert(piiapprovalreqvo);

			if("자동JOB결재라인".equals(piiapprovalreqvo.getAprvlineid())){
				PiiApprovalStepReqVO stepReq = new PiiApprovalStepReqVO();
				stepReq.setReqid(piiapprovalreqvo.getReqid());
				stepReq.setAprvlineid(piiapprovalreqvo.getAprvlineid());
				stepReq.setSeq(piiapprovalreqvo.getSeq());
				stepReq.setStepname("AUTO");
				stepReq.setStatus("APPROVED");
				stepReq.setApproverid("SYSTEM");
				stepReq.setApprovername("SYSTEM");
				stepReq.setComment("Auto approved (no human review).");
				// regdate는 DB default(now) 쓰는게 안전
				approvalStepReqMapper.insert(stepReq);
				this.approve(piiapprovalreqvo);
			}

		}catch (Exception e) {
			logger.warn("warn "+"Fail to Check IN "+approvalreq.getJobid()+"  "+e.getMessage());
			return "Fail to Check IN";
		}
		return "success";
	}
	
	@Override
	@Transactional
	public boolean modify(PiiJobVO piijob) {
		
		LogUtil.log("INFO", "modify......" + piijob);
		
		steptablemapper.updateKeymapId(piijob);
		return mapper.update(piijob) == 1;
	}

	@Override
	@Transactional
	public boolean approve(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "approve......" + approvalreqVO);
		mapper.setold(approvalreqVO);
		stepmapper.approve(approvalreqVO);
		return mapper.approve(approvalreqVO) == 1;
	}
	
	@Override
	@Transactional
	public boolean reject(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "reject......" + approvalreqVO);
		approvalreqmapper.reject(approvalreqVO);
		stepmapper.reject(approvalreqVO);
		return mapper.reject(approvalreqVO) == 1;
	}
	

	
}
