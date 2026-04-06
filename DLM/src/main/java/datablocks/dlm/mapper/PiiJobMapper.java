package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiJobMapper {

   //@Select("select * from piijob")
	public List<PiiJobVO> getList();
	public List<PiiJobVO> getTestdataAutoGenList();
	public List<PiiJobVO> getAllVersionList(@Param("jobid") String jobid);
	public List<PiiKeymapPkVO> getKeymapList();
	public List<PiiJobVO> getActiveList(Criteria cri);
	public List<PiiJobVO> getExeJobList(@Param("basedate") String basedate);
	
	public List<PiiJobVO> getListWithPaging(Criteria cri);

	public void insert(PiiJobVO PiiJob);

	public void insertSelectKey(PiiJobVO PiiJob);

	public void checkout(@Param("jobid") String jobid,@Param("version") String version);
	public void checkin(@Param("jobid") String jobid,@Param("version") String version);
	public int reject(PiiApprovalReqVO approvalreqVO);
	public int approve(PiiApprovalReqVO approvalreqVO);
	public int setold(PiiApprovalReqVO approvalreqVO);
	//public PiiJobVO read(PiiJobVO PiiJob);
	public PiiJobVO read(@Param("jobid") String jobid,@Param("version") String version);

	public int delete(@Param("jobid") String jobid,@Param("version") String version);
	
	
	public int update(PiiJobVO PiiJob);
	
	public int getTotalCount(Criteria cri);
	public int getPiiTotalCount();
	public int getMaxVersionByJob(@Param("jobid") String jobid);
	public int getMaxVersionCheckinByJob(@Param("jobid") String jobid);

}
