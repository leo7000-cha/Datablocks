package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.PiiOrderStepTableUpdateWithPkYnVO;
import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiOrderStepTableUpdateVO;

public interface PiiOrderStepTableUpdateMapper {

	public List<PiiOrderStepTableUpdateVO> getJobList(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version);
	public List<PiiOrderStepTableUpdateVO> getList(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public List<PiiOrderStepTableUpdateWithPkYnVO> getListWithPkYn(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);

	public void insert(PiiOrderStepTableUpdateVO PiiOrderStepTableUpdate);

	public PiiOrderStepTableUpdateVO read(PiiOrderStepTableUpdateVO PiiOrderStepTableUpdate);

	public int delete(PiiOrderStepTableUpdateVO PiiOrderStepTableUpdate);
	public int deletebyorderid(@Param("orderid") int orderid);
	public int deletebyseq(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int deletebyjobid(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version);
	public int deletebystepid(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	
	public int update(PiiOrderStepTableUpdateVO PiiOrderStepTableUpdate);
	
	public int getTotalCount(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	

}
