package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiJobWaitVO;

public interface PiiJobWaitMapper {

	public List<PiiJobWaitVO> getList(@Param("jobid") String jobid,@Param("version") String version);
	
	public void insert(PiiJobWaitVO PiiJobWait);

	public PiiJobWaitVO read(PiiJobWaitVO PiiJobWait);

	public int delete(PiiJobWaitVO PiiJobWait);
	public int deleteJob(@Param("jobid") String jobid,@Param("version") String version);
	
	public int update(PiiJobWaitVO PiiJobWait);
	
	public int getTotalCount(@Param("jobid") String jobid,@Param("version") String version);
	
	public void checkout(@Param("jobid") String jobid,@Param("version") String version);
}
