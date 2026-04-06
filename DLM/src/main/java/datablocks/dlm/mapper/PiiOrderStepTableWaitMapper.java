package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiOrderStepTableWaitVO;

public interface PiiOrderStepTableWaitMapper {

	public List<PiiOrderStepTableWaitVO> getList(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);

	public void insert(PiiOrderStepTableWaitVO piiordersteptablewait);

	public PiiOrderStepTableWaitVO read(PiiOrderStepTableWaitVO piiordersteptablewait);

	public int delete(PiiOrderStepTableWaitVO piiordersteptablewait);
	public int deletebyorderid(@Param("orderid") int orderid);
	public int deletebytable(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);
	public int update(PiiOrderStepTableWaitVO piiordersteptablewait);
	
	public int getTotalCount(@Param("orderid") int orderid, @Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);


}
