package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.InnerStepVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface InnerStepService {

	public void register(InnerStepVO config);

	public InnerStepVO get(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq);

	public boolean modifyStart(InnerStepVO config);
	public boolean modifyEnd(InnerStepVO config);
	public boolean modifyResult(InnerStepVO config);

	public boolean remove(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq);

	public List<InnerStepVO> getList();

	public List<InnerStepVO> getList(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq);

	//추가
	public int getTotal(int orderid, String stepid, int seq1
			, int seq2, int seq3, int inner_step_seq);
	public long getTotalPartition(int orderid, String stepid, int seq1
			, int seq2, int seq3);
	public List<InnerStepVO> getListPartition(int orderid, String stepid, int seq1
			, int seq2, int seq3);



}