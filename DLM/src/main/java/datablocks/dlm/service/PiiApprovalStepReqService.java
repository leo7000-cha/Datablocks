package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalStepReqVO;
import datablocks.dlm.domain.PiiApprovalUserVO;
import datablocks.dlm.domain.PiiApprovalVO;

import java.util.List;

public interface PiiApprovalStepReqService {

	public void register(PiiApprovalStepReqVO piiapprovalstepreq);

	public PiiApprovalStepReqVO get(String reqid) ;

	public boolean modify(PiiApprovalStepReqVO piiapprovalstepreq);

	public boolean remove(String reqid) ;

	public List<PiiApprovalStepReqVO> getList();

	public List<PiiApprovalStepReqVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);

	public boolean approve(PiiApprovalStepReqVO approvalreqVO);
	public boolean reject(PiiApprovalStepReqVO approvalreqVO);


}

