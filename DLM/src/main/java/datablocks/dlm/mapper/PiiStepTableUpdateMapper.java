package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiStepTableUpdateVO;

public interface PiiStepTableUpdateMapper {

	public List<PiiStepTableUpdateVO> getJobList(@Param("jobid") String jobid,@Param("version") String version);
	public List<PiiStepTableUpdateVO> getJobMaxList(@Param("jobid") String jobid);
	public List<PiiStepTableUpdateVO> getList(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);

	public void insert(PiiStepTableUpdateVO PiiStepTableUpdate);

	public PiiStepTableUpdateVO read(PiiStepTableUpdateVO PiiStepTableUpdate);

	public int delete(PiiStepTableUpdateVO PiiStepTableUpdate);
	public int deletebyseq(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int deletebyjobid(@Param("jobid") String jobid,@Param("version") String version);
	public int deletebystepid(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	
	public int update(PiiStepTableUpdateVO PiiStepTableUpdate);
	
	public int getTotalCount(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	
	public void checkout(@Param("jobid") String jobid,@Param("version") String version);

}
