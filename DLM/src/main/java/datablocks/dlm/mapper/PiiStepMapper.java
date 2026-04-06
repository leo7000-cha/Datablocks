package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiStepVO;
import datablocks.dlm.domain.PiiStepseqVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiStepMapper {

   //@Select("select * from piistep")
	public List<PiiStepVO> getList();
	
	public List<PiiStepVO> getJobList(@Param("jobid") String jobid, @Param("version") String version);
	
	public List<PiiStepVO> getListWithPaging(Criteria cri);

	public void insert(PiiStepVO PiiStep);

	public void insertSelectKey(PiiStepVO PiiStep);

	public void checkout(@Param("jobid") String jobid,@Param("version") String version);
	public void checkin(@Param("jobid") String jobid,@Param("version") String version);
	public int reject(PiiApprovalReqVO approvalreqVO);
	public int approve(PiiApprovalReqVO approvalreqVO);
	//public PiiStepVO read(PiiStepVO PiiStep);
	public PiiStepVO read(@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);

	public int getCountWithSteptype(@Param("jobid") String jobid, @Param("version") String version, @Param("steptype") String steptype);
	public PiiStepVO readWithSteptype(@Param("jobid") String jobid, @Param("version") String version, @Param("steptype") String steptype);
	public PiiStepVO readWithStepEXE(@Param("jobid") String jobid, @Param("version") String version);
	public int delete(@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);
	public int deleteJobStep(@Param("jobid") String jobid, @Param("version") String version);
	
	public int update(PiiStepVO PiiStep);
	public int update_seq(PiiStepseqVO piistepseq);
	public int update_status(@Param("status") String status, @Param("policy_id") String policy_id);
	public int updateStepStatus(@Param("jobid") String jobid, @Param("version") String version, @Param("steptype") String steptype, @Param("status") String status);

	public int getTotalCount(Criteria cri);
	public int getMaxStepseq(@Param("jobid") String jobid);

}
