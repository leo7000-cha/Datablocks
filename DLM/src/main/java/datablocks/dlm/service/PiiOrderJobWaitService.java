package datablocks.dlm.service;

import datablocks.dlm.domain.PiiOrderJobWaitVO;

import java.util.List;

public interface PiiOrderJobWaitService {

	public void register(PiiOrderJobWaitVO piisteptablewait);
	public PiiOrderJobWaitVO get(PiiOrderJobWaitVO piisteptablewait);
	public boolean modify(PiiOrderJobWaitVO piisteptablewait);
	public boolean remove(PiiOrderJobWaitVO piisteptablewait);
	public boolean removebyorderid(int orderid);
	public List<PiiOrderJobWaitVO> getList(int orderid, String jobid, String version);
	public int getTotal(int orderid, String jobid, String version);

}