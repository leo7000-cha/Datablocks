package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiCodeVO;
import datablocks.dlm.domain.InnerStepVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface InnerStepMapper {

	public List<InnerStepVO> getList();

	public List<InnerStepVO> getListWithPaging(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("inner_step_seq") int inner_step_seq);

	public void insert(InnerStepVO Innerstep);

	public void insertSelectKey(InnerStepVO Innerstep);

	public InnerStepVO read(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("inner_step_seq") int inner_step_seq);

	public int delete(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("inner_step_seq") int inner_step_seq);
	public int deletebyorderid(@Param("orderid") int orderid);
	public int updateStart(InnerStepVO Innerstep);
	public int updateEnd(InnerStepVO Innerstep);
	public int updateResult(InnerStepVO Innerstep);

	public List<InnerStepVO> getListPartition(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public long getTotalPartition(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
				, @Param("seq2") int seq2, @Param("seq3") int seq3);

	public int getTotalCount(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1
			, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("inner_step_seq") int inner_step_seq);

	public List<InnerStepVO> getOrphanedTmpSteps();

}

