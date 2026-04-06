package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;
import datablocks.dlm.domain.PiiApprovalReqVO;
import org.apache.ibatis.annotations.Param;
import org.springframework.security.core.userdetails.UserDetails;

public interface PiiApprovalReqService {

	public void register(PiiApprovalReqVO piiapprovalreq);

	public PiiApprovalReqVO getLastApprovalReq(String approvalid, String requesterid);
	public PiiApprovalUserVO getSameDeptApprovalUser(String approvalid, String deptid);
	public PiiApprovalReqVO get(String reqid) ;
	public PiiApprovalVO getApproval(String approvalid) ;
	public PiiApprovalUserVO getApprovalUser(String approvalid) ;

	public boolean modify(PiiApprovalReqVO piiapprovalreq);
	public boolean modifyApprover(PiiApprovalReqVO piiapprovalreq);

	public boolean remove(String reqid) ;

	public List<PiiApprovalReqVO> getList();

	public List<PiiApprovalReqWithApproverVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public int getMaxReqid();

	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean approveAll(List<PiiApprovalReqVO> approvalreqVOlist, UserDetails userDetails);
	public boolean reject(PiiApprovalReqVO approvalreqVO);

	public boolean hasSameDeptApproverInLine(String aprvlineid, String deptid);

}