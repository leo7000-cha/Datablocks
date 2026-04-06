package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiStepTableUpdateVO;

public interface PiiStepTableUpdateService {

	public void register(PiiStepTableUpdateVO piisteptableupdate);
	public PiiStepTableUpdateVO get(PiiStepTableUpdateVO piisteptableupdate);

	public String modifysteptableupdate(List<PiiStepTableUpdateVO> steptableupdatelist);
	public boolean modify(PiiStepTableUpdateVO piisteptableupdate);
	public boolean remove(PiiStepTableUpdateVO piisteptableupdate);
	public boolean removebyseq(String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public boolean removebyjobid(String jobid, String version);
	public boolean removebystepid(String jobid, String version, String stepid);
	public List<PiiStepTableUpdateVO> getJobList(String jobid, String version);
	public List<PiiStepTableUpdateVO> getList(String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public void checkout(String jobid, String version);
	public int getTotal(String jobid, String version, String stepid, int seq1, int seq2, int seq3);

}