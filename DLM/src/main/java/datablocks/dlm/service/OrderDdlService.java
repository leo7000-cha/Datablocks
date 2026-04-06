package datablocks.dlm.service;

import datablocks.dlm.domain.OrderDdlVO;
import datablocks.dlm.domain.PiiApprovalLineVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface OrderDdlService {

	public void register(OrderDdlVO config);

	public OrderDdlVO get(int orderid, String stepid, int seq1
			, int seq2, int seq3
			, String object_type, String object_owner, String object_name);

	public boolean modify(OrderDdlVO config);
	public boolean remove(int orderid, String stepid, int seq1
			, int seq2, int seq3);

	public List<OrderDdlVO> getList();

	public List<OrderDdlVO> getList(int orderid, String stepid, int seq1
			, int seq2, int seq3);
	
	public int getTotal(int orderid, String stepid, int seq1
			, int seq2, int seq3);




}