package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiPolicyVO;

public interface PiiPolicyService {

	public void register(PiiPolicyVO piipolicy);

	public PiiPolicyVO get(String policy_id, String version);
	public PiiPolicyVO getCurrent(String policy_id);

	public boolean modify(PiiPolicyVO piipolicy);

	public boolean remove(String policy_id, String version);

	public List<PiiPolicyVO> getList();

	public List<PiiPolicyVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	
	public void checkout(String policy_id, String version);
	public void checkin(String policy_id, String version);
	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean reject(PiiApprovalReqVO approvalreqVO);
	
	public List<PiiPolicyVO> getAllVersionList(String policy_id);
	public int getMaxVersionByPolicy(String policy_id);

}