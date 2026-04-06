package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.InnerStepVO;
import datablocks.dlm.mapper.InnerStepMapper;
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
public class InnerStepServiceImpl implements InnerStepService {
	private static final Logger logger = LoggerFactory.getLogger(InnerStepServiceImpl.class);
	@Autowired
	private InnerStepMapper mapper;

	@Override
	public List<InnerStepVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<InnerStepVO> getList(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq) {
		
		LogUtil.log("INFO", "get List with criteria: " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3+" "+ inner_step_seq );
		
		return mapper.getListWithPaging(orderid, stepid, seq1
				, seq2, seq3, inner_step_seq);
	}

	@Override
	@Transactional
	public void register(InnerStepVO innerstep) {
		
		 LogUtil.log("INFO", "register......" + innerstep);
		 
		 mapper.insert(innerstep); 
		 
	}
		 
	@Override
	public boolean remove(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq) {
		
		LogUtil.log("INFO", "remove...." + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3 +" "+ inner_step_seq);
		 
		return mapper.delete(orderid, stepid, seq1
				, seq2, seq3, inner_step_seq) == 1;
	}

	@Override
	public int getTotal(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq) {
		
		LogUtil.log("INFO", "get total count  " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3 +" "+ inner_step_seq);
		return mapper.getTotalCount(orderid, stepid, seq1
				, seq2, seq3, inner_step_seq);
	}
	@Override
	public long getTotalPartition(int orderid, String stepid, int seq1
			, int seq2, int seq3) {

		LogUtil.log("INFO", "getTotalPartition " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3);
		return mapper.getTotalPartition(orderid, stepid, seq1
				, seq2, seq3);
	}
	@Override
	public List<InnerStepVO> getListPartition(int orderid, String stepid, int seq1
			, int seq2, int seq3) {

		LogUtil.log("INFO", "getListPartition  " + orderid +" "+ stepid +" "+ seq1
				+" "+ seq2 +" "+ seq3);
		return mapper.getListPartition(orderid, stepid, seq1
				, seq2, seq3);
	}

	@Override
	public InnerStepVO get(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq) {
		
		 LogUtil.log("INFO", "get......" + orderid +" "+ stepid +" "+ seq1
				 +" "+ seq2 +" "+ seq3 +" "+ inner_step_seq);
		 
		 return mapper.read(orderid, stepid, seq1
			, seq2, seq3, inner_step_seq);
	}

	@Override
	@Transactional
	public boolean modifyStart(InnerStepVO innerstep) {
		
		LogUtil.log("INFO", "modifyStart......" + innerstep);
		
		return mapper.updateStart(innerstep) == 1;
	}

	@Override
	@Transactional
	public boolean modifyEnd(InnerStepVO innerstep) {

		LogUtil.log("INFO", "modifyEnd......" + innerstep);

		return mapper.updateEnd(innerstep) == 1;
	}

	@Override
	@Transactional
	public boolean modifyResult(InnerStepVO innerstep) {

		LogUtil.log("INFO", "updateResult......" + innerstep);

		return mapper.updateResult(innerstep) == 1;
	}
}
