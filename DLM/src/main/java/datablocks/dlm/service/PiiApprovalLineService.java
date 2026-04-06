package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalLineVO;

import java.util.List;

public interface PiiApprovalLineService {

	public void register(PiiApprovalLineVO piiapprovallIne);

	public PiiApprovalLineVO get(String aprvlineid);

	public boolean modify(PiiApprovalLineVO piiapprovallIne);

	public boolean remove(String aprvlineid);

	public List<PiiApprovalLineVO> getList();
	public List<PiiApprovalLineVO> getListbyApprovalid(String approvalid);

	public List<PiiApprovalLineVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}