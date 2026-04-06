package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiJobWaitVO;

public interface PiiJobWaitService {

	public void register(PiiJobWaitVO piijobwait);
	public PiiJobWaitVO get(PiiJobWaitVO piijobwait);
	public boolean modify(PiiJobWaitVO piijobwait);
	public boolean remove(PiiJobWaitVO piijobwait);
	public boolean removeJob(String jobid, String version);
	public List<PiiJobWaitVO> getList(String jobid, String version);
	public void checkout(String jobid, String version);
	public int getTotal(String jobid, String version);

}