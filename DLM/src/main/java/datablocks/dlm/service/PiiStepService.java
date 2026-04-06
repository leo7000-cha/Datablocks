package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiStepVO;
import datablocks.dlm.domain.PiiStepseqVO;

import java.util.List;

public interface PiiStepService {

	public void register(PiiStepVO piistep);

	public PiiStepVO get(String jobid, String version, String stepid);
	public PiiStepVO getWithSteptype(String jobid, String version, String steptype);
	public PiiStepVO getWithStepEXE(String jobid, String version);
	public int getCountWithSteptype(String jobid, String version, String steptype);

	public boolean updateStepStatus(String jobid, String version, String steptype, String status);
	public boolean modify(PiiStepVO piistep);
	public boolean modify_seq(PiiStepseqVO piistepseq);
	public boolean modify_status(String status, String policy_id);

	public boolean remove(PiiStepVO piistep);
	public void removeJobStep(String jobid, String version);

	public List<PiiStepVO> getList();
	
	public List<PiiStepVO> getJobList(String jobid, String version);

	public List<PiiStepVO> getList(Criteria cri);

	public void checkout(String jobid, String version);
	
	//추가
	public int getTotal(Criteria cri);
	

}