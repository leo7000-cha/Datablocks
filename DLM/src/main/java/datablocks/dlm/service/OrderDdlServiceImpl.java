package datablocks.dlm.service;

import datablocks.dlm.domain.OrderDdlVO;
import datablocks.dlm.domain.PiiApprovalLineVO;
import datablocks.dlm.mapper.OrderDdlMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class OrderDdlServiceImpl implements OrderDdlService {
	private static final Logger logger = LoggerFactory.getLogger(OrderDdlServiceImpl.class);
	@Autowired
	private OrderDdlMapper mapper;

	@Override
	public List<OrderDdlVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<OrderDdlVO> getList(int orderid, String stepid, int seq1
			, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get List with criteria: " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3 );
		
		return mapper.getListWithPaging(orderid, stepid, seq1
				, seq2, seq3);
	}
//	@Override
//	public List<OrderDdlVO> getExeList(int orderid, String stepid, int seq1
//			, int seq2, int seq3) {
//
//		LogUtil.log("INFO", "get List with criteria: " + orderid +" "+ stepid +" "+ seq1
//				+" "+ seq2 +" "+ seq3 );
//
//		return mapper.getExeListWithPaging(orderid, stepid, seq1
//				, seq2, seq3);
//	}
	@Override
	@Transactional
	public void register(OrderDdlVO innerstep) {
		
		 LogUtil.log("INFO", "register......" + innerstep);
		 
		 mapper.insert(innerstep); 
		 
	}
	@Override
	@Transactional
	public boolean modify(OrderDdlVO innerstep) {

		LogUtil.log("INFO", "modify......" + innerstep);

		return mapper.update(innerstep) == 1;
	}
	@Override
	public boolean remove(int orderid, String stepid, int seq1
			, int seq2, int seq3) {
		
		LogUtil.log("INFO", "remove...." + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3 );
		 
		return mapper.delete(orderid, stepid, seq1
				, seq2, seq3) == 1;
	}

	@Override
	public int getTotal(int orderid, String stepid, int seq1
			, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get total count  " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3);
		return mapper.getTotalCount(orderid, stepid, seq1
				, seq2, seq3);
	}

	@Override
	public OrderDdlVO get(int orderid, String stepid, int seq1
			, int seq2, int seq3
			, String object_type, String object_owner, String object_name) {
		
		 LogUtil.log("INFO", "get......" + orderid +" "+ stepid +" "+ seq1
				 +" "+ seq2 +" "+ seq3 );
		 
		 return mapper.read(orderid, stepid, seq1
			, seq2, seq3, object_type, object_owner, object_name);
	}


}
