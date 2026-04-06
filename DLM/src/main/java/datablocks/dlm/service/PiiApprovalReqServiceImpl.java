package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiApprovalReqServiceImpl implements PiiApprovalReqService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalReqServiceImpl.class);
	@Autowired
	private PiiApprovalReqMapper mapper;

//	@Autowired
//	private PiiApprovalUserMapper approvalUserMapper;
//	@Autowired
//	private PiiApprovalStepReqMapper approvalStepReqMapper;
//	@Autowired
//	private PiiApprovalStepMapper approvalStepMapper;
//	@Autowired
//	private PiiRestoreMapper restoreMapper;


	@Override
	public List<PiiApprovalReqVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		return mapper.getList();
	}

	
	@Override
	public List<PiiApprovalReqWithApproverVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiApprovalReqVO piiapprovalreq) {
		
		 LogUtil.log("INFO", "register......" + piiapprovalreq);
		  
		 mapper.insert(piiapprovalreq); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(String reqid) {
		
		LogUtil.log("INFO", "remove...." + reqid);
		 
		return mapper.delete(reqid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getMaxReqid() {
		
		LogUtil.log("INFO", "get Max Reqid");
		return mapper.getMaxReqid();
	}
	
	@Override
	public PiiApprovalReqVO getLastApprovalReq(String approvalid, String requesterid) {
		
		 LogUtil.log("INFO", "getLastApprovalReq......" + approvalid + " "+ requesterid);
		 
		 return mapper.getLastApprovalReq(approvalid, requesterid);
	}
	@Override
	public PiiApprovalUserVO getSameDeptApprovalUser(String approvalid, String deptid) {

		 LogUtil.log("INFO", "getSameDeptApprovalUser......" + approvalid + " "+ deptid);

		 return mapper.getSameDeptApprovalUser(approvalid, deptid);
	}

	@Override
	public PiiApprovalReqVO get(String reqid) {

		 LogUtil.log("INFO", "get......" + reqid);

		 return mapper.read(reqid);
	}
	@Override
	public PiiApprovalVO getApproval(String approvalid) {
		
		LogUtil.log("INFO", "get......" + approvalid);
		
		return mapper.readapproval(approvalid);
	}
	@Override
	public PiiApprovalUserVO getApprovalUser(String approvalid) {
		
		LogUtil.log("INFO", "get......" + approvalid);
		
		return mapper.readapprovaluser(approvalid);
	}

	/*
	 * public PiiApprovalReqVO getApproval(String approvalid) ; public
	 * PiiApprovalReqVO getApprovalUser(String approvalid) ;
	 */
	@Override
	@Transactional
	public boolean modify(PiiApprovalReqVO piiapprovalreq) {
		
		LogUtil.log("INFO", "modify......" + piiapprovalreq);
		
		return mapper.update(piiapprovalreq) == 1;
	}
	@Override
	@Transactional
	public boolean modifyApprover(PiiApprovalReqVO piiapprovalreq) {

		LogUtil.log("INFO", "modifyApprover......" + piiapprovalreq);

		return mapper.updateApprover(piiapprovalreq) == 1;
	}

	@Override
	@Transactional
	public boolean approve(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "approve......" + approvalreqVO);

		return mapper.approve(approvalreqVO) == 1;
	}
	@Override
	@Transactional
	public boolean approveAll(List<PiiApprovalReqVO> approvalreqVOlist, UserDetails userDetails) {
		
		LogUtil.log("INFO", "approveAll.....approvalreqVOlist.size() = " + approvalreqVOlist.size());
		return true;
	}

	@Override
	@Transactional
	public boolean reject(PiiApprovalReqVO approvalreqVO) {

		LogUtil.log("INFO", "reject......" + approvalreqVO);

		return mapper.reject(approvalreqVO) == 1;
	}

	@Override
	public boolean hasSameDeptApproverInLine(String aprvlineid, String deptid) {
		LogUtil.log("INFO", "hasSameDeptApproverInLine......" + aprvlineid + " " + deptid);
		return mapper.hasSameDeptApproverInLine(aprvlineid, deptid) > 0;
	}


}
