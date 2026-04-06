package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalVO;

import java.util.List;

public interface PiiApprovalService {

	public void register(PiiApprovalVO piiapproval);

	public PiiApprovalVO get(String approverid);

	public boolean modify(PiiApprovalVO piiapproval);

	public boolean remove(String approverid);

	public List<PiiApprovalVO> getList();

	public List<PiiApprovalVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}