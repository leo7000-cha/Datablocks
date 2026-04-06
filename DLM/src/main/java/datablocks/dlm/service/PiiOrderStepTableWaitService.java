package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiOrderStepTableWaitVO;

public interface PiiOrderStepTableWaitService {

	public void register(PiiOrderStepTableWaitVO piisteptablewait);
	public PiiOrderStepTableWaitVO get(PiiOrderStepTableWaitVO piisteptablewait);
	public String modifysteptablewait(List<PiiOrderStepTableWaitVO> steptablewaitlist);
	public boolean modify(PiiOrderStepTableWaitVO piisteptablewait);
	public boolean remove(PiiOrderStepTableWaitVO piisteptablewait);
	public boolean removebytable(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name);
	public boolean removebyorderid(int orderid);
	public List<PiiOrderStepTableWaitVO> getList(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name);
	public int getTotal(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name);

}