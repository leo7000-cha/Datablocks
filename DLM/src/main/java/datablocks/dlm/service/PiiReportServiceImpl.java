package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiExtractVO;
import datablocks.dlm.domain.PiiReportVO;
import datablocks.dlm.mapper.PiiApprovalReqMapper;
import datablocks.dlm.mapper.PiiReportMapper;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiReportServiceImpl implements PiiReportService {
	private static final Logger logger = LoggerFactory.getLogger(PiiReportServiceImpl.class);
	@Autowired
	private PiiReportMapper mapper;
	@Autowired
	private PiiApprovalReqMapper approvalreqmapper;

	@Override
	public List<PiiReportVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiReportVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public String register(Criteria cri, Principal principal, String reqreason, String aprvlineid, String applytype) {

		LogUtil.log("INFO", "register.....cri => " + cri);
		PiiApprovalReqVO approvalreq = new PiiApprovalReqVO();
		PiiReportVO piireport = new PiiReportVO();
		try {
			int maxReportid = mapper.getMaxReportid() + 1;
			String applyId = applytype+"_APPROVAL";
			piireport.setReportid(maxReportid);
			piireport.setPhase("APPROVING");
			piireport.setAprvlineid(aprvlineid);
			piireport.setApprovalid(applyId);
			piireport.setReport_type(cri.getSearch6());
			piireport.setDate_from(cri.getSearch4());
			piireport.setDate_to(cri.getSearch5());
			piireport.setVal1("");
			if(cri.getSearch6().equalsIgnoreCase("REAL_DOC_REPORT"))
				piireport.setVal1(cri.getSearch2());

			piireport.setVal2("");
			piireport.setVal3("");
			piireport.setApply_date("");
			piireport.setApply_userid(principal.getName());
			piireport.setApprove_date("");
			piireport.setApprove_userid("");
			mapper.insert(piireport);
			approvalreq.setReqid(""+(approvalreqmapper.getMaxReqid()+1));
			approvalreq.setAprvlineid(aprvlineid);
			approvalreq.setApprovalid(applyId);
			approvalreq.setSeq("1");
			approvalreq.setPhase("APPLY");
			approvalreq.setJobid(maxReportid+"");
			approvalreq.setVersion("1");
			approvalreq.setRequesterid(principal.getName());
			approvalreq.setRequestername(principal.getName());
			approvalreq.setRegdate("");
			approvalreq.setUpddate("");
			approvalreq.setReqreason(reqreason);

			approvalreqmapper.insert(approvalreq);
		}catch (Exception e) {
			logger.warn("warn "+"Fail to apply Restoration => reportid: "+approvalreq.getJobid()+"  "+e.getMessage());
			return "Fail to apply Restoration";
		}
			return "success";
	}

	@Override
	@Transactional
	public boolean remove(String reportid) {
		
		LogUtil.log("INFO", "remove...." + reportid);
		 
		return mapper.delete(reportid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiReportVO get(String reportid) {
		
		 LogUtil.log("INFO", "get......" + reportid);
		 
		 return mapper.read(reportid);
	}

	@Override
	@Transactional
	public boolean modify(PiiReportVO piireport) {
		
		LogUtil.log("INFO", "modify......" + piireport);
		
		return mapper.update(piireport) == 1;
	}

	@Override
	public int getMaxReportid() {

		LogUtil.log("INFO", "getMaxReportid");
		return mapper.getMaxReportid();
	}
	@Override
	@Transactional
	public boolean requestapproval(int reportid) {

		LogUtil.log("INFO", "requestapproval.....reportid." + reportid);
		return mapper.requestapproval(reportid) == 1;
	}

	@Override
	@Transactional
	public boolean approve(PiiApprovalReqVO approvalreqVO) {

		LogUtil.log("INFO", "approve....reportid.." + approvalreqVO.getJobid());
		return mapper.approve(StrUtil.parseInt(approvalreqVO.getJobid())) == 1;
	}

	@Override
	@Transactional
	public boolean reject(PiiApprovalReqVO approvalreqVO) {

		LogUtil.log("INFO", "reject....reportid.." + approvalreqVO.getJobid());
		approvalreqmapper.reject(approvalreqVO);
		return mapper.reject(StrUtil.parseInt(approvalreqVO.getJobid())) == 1;
	}
}
