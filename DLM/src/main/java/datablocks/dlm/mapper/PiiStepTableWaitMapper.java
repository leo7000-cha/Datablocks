package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiStepTableWaitVO;

public interface PiiStepTableWaitMapper {

	public List<PiiStepTableWaitVO> getJobList(@Param("jobid") String jobid,@Param("version") String version);
	public List<PiiStepTableWaitVO> getList(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);

	public void insert(PiiStepTableWaitVO PiiStepTableWait);

	public PiiStepTableWaitVO read(PiiStepTableWaitVO PiiStepTableWait);

	public int delete(PiiStepTableWaitVO PiiStepTableWait);
	public int deletebytable(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);
	public int deletebyjobid(@Param("jobid") String jobid,@Param("version") String version);
	public int deletebystepid(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	
	public int update(PiiStepTableWaitVO PiiStepTableWait);
	
	public int getTotalCount(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);
	
	public void checkout(@Param("jobid") String jobid,@Param("version") String version);

}
