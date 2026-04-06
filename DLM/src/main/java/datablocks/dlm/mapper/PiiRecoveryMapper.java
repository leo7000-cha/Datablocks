package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiRecoveryMapper {

	public List<PiiRecoveryVO> getList();
	public List<PiiRecoveryVO> getListWithPaging(Criteria cri);
	public List<PiiOrderVO> getOrderList(Criteria cri);
	public List<PiiOrderJobVO> getOrderJobListWithPaging(Criteria cri);
	public List<PiiOrderJobVO> getOrderJobList();
	public List<PiiJobOrderVO> getRecoveryJobList();

	public void insert(PiiRecoveryVO PiiRecovery);
	public void insertSelectKey(PiiRecoveryVO PiiRecovery);

	public int requestapproval(@Param("recoveryid") int recoveryid);
	public int reject(@Param("recoveryid") int recoveryid);
	public int approve(@Param("recoveryid") int recoveryid);

	public PiiRecoveryVO read(@Param("recoveryid") int recoveryid);
	public PiiRecoveryVO readByOldOrderid(@Param("old_orderid") int old_orderid);
	public PiiRecoveryVO readByNewOrderid(@Param("new_orderid") int new_orderid);

	public int delete(@Param("recoveryid") int recoveryid);
	
	
	public int update(PiiRecoveryVO PiiRecovery);
	public int updateStatus(@Param("new_orderid") int new_orderid);
	
	public int getTotalCount(Criteria cri);
	public int getMaxRecoveryid();
	public void checkin(@Param("jobid") String jobid);

}
