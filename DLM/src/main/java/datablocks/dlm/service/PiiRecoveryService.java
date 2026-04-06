package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;

public interface PiiRecoveryService {

	public boolean jobregister(PiiRecoveryVO PiiRecovery);
	public boolean orderregister(PiiRecoveryVO PiiRecovery);

	public PiiRecoveryVO get(int recoveryid);
	public PiiRecoveryVO getByOldOrderid(int old_orderid);
	public PiiRecoveryVO getByNewOrderid(int new_orderid);

	public boolean modify(PiiRecoveryVO PiiRecovery);
	public boolean modifyStatus(int orderid);
	
	public boolean requestapproval(int recoveryid);
	public boolean approve(int recoveryid);
	public boolean reject(int recoveryid);

	public boolean remove(int recoveryid);

	public List<PiiRecoveryVO> getList();
	public List<PiiRecoveryVO> getList(Criteria cri);
	public List<PiiOrderVO> getOrderList(Criteria cri);
	public List<PiiOrderJobVO> getOrderJobListWithPaging(Criteria cri);
	public List<PiiOrderJobVO> getOrderJobList();
	public List<PiiJobOrderVO> getRecoveryJobList();

	public int getTotal(Criteria cri);
	
	public boolean orderRecoveryOrder(PiiRecoveryVO PiiRecovery);
	public boolean orderRecoveryJob(PiiRecoveryVO PiiRecovery);
	public void orderRecoveryJ(PiiRecoveryVO PiiRecovery);
	public void orderRecoveryO(PiiRecoveryVO PiiRecovery);
	public int getMaxRecoveryid();
}
