package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalStepUserVO;
import datablocks.dlm.domain.PiiApprovalStepVO;

import java.util.List;

public interface PiiApprovalStepService {

	public void register(PiiApprovalStepVO piiapprovalstep);
	public PiiApprovalStepVO get(String aprvlineid, String seq);
	public PiiApprovalStepVO getNextStep(String aprvlineid, String seq);
	public int getNextStepCount(String aprvlineid, String seq);

	public boolean modify(PiiApprovalStepVO piiapprovalstep);
	public boolean modifySeq(PiiApprovalStepVO piiapprovalstep);

	public boolean remove(String aprvlineid, String seq);
	public boolean removeByLine(String aprvlineid);
	public boolean saveAllStep(List<PiiApprovalStepUserVO> steplist);
	public List<PiiApprovalStepVO> getList();
	public List<PiiApprovalStepVO> getListByaAprvlineid(String aprvlineid);
	public List<PiiApprovalStepUserVO> getStepUserListByaAprvlineid(String aprvlineid);

	public List<PiiApprovalStepVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}