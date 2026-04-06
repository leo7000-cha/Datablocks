package datablocks.dlm.mapper;

import datablocks.dlm.domain.MetaTableVO;
import datablocks.dlm.domain.OrderDdlVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface OrderDdlMapper {

	public List<OrderDdlVO> getList();

	public List<OrderDdlVO> getListWithPaging(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3);

	public void insert(OrderDdlVO Innerstep);

	public void insertSelectKey(OrderDdlVO Innerstep);

	public OrderDdlVO read(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3
			, @Param("object_type") String object_type, @Param("object_owner") String object_owner, @Param("object_name") String object_name
	);
	public int update(OrderDdlVO Innerstep);
	public int delete(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int deletebyorderid(@Param("orderid") int orderid);

	public int getTotalCount(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3);

}

