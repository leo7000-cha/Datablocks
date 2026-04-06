package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiStepTableWaitVO;

public interface PiiStepTableWaitService {

	public void register(PiiStepTableWaitVO piisteptablewait);
	public PiiStepTableWaitVO get(PiiStepTableWaitVO piisteptablewait);
	public String modifysteptablewait(List<PiiStepTableWaitVO> steptablewaitlist);
	public boolean modify(PiiStepTableWaitVO piisteptablewait);
	public boolean remove(PiiStepTableWaitVO piisteptablewait);
	public boolean removebytable(String jobid, String version, String stepid, String db, String owner, String table_name);
	public boolean removebyjobid(String jobid, String version);
	public boolean removebystepid(String jobid, String version, String stepid);
	public List<PiiStepTableWaitVO> getJobList(String jobid, String version);
	public List<PiiStepTableWaitVO> getList(String jobid, String version, String stepid, String db, String owner, String table_name);
	public void checkout(String jobid, String version);
	public int getTotal(String jobid, String version, String stepid, String db, String owner, String table_name);

}