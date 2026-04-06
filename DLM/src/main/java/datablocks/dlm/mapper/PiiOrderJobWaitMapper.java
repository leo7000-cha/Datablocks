package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiOrderJobWaitVO;

public interface PiiOrderJobWaitMapper {

	public List<PiiOrderJobWaitVO> getList(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version);
	
	public void insert(PiiOrderJobWaitVO piiorderjobwait);

	public PiiOrderJobWaitVO read(PiiOrderJobWaitVO piiorderjobwait);

	public int delete(PiiOrderJobWaitVO piiorderjobwait);
	public int deletebyorderid(@Param("orderid") int orderid);
	
	public int update(PiiOrderJobWaitVO piiorderjobwait);
	
	public int getTotalCount(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version);

}
