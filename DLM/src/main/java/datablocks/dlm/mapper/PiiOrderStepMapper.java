package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiOrderStepRunStatusVO;
import datablocks.dlm.domain.PiiOrderStepVO;

public interface PiiOrderStepMapper {

   //@Select("select * from piiorder")
	public List<PiiOrderStepVO> getList();
	public List<PiiOrderStepVO> getOrderStepList(@Param("orderid") int orderid);
	public List<PiiOrderStepVO> getRunnableOrderStepList(@Param("orderid") int orderid);
	public List<PiiOrderStepRunStatusVO> getRunStatusList(@Param("orderid") int orderid);
	
	public List<PiiOrderStepVO> getListWithPaging(Criteria cri);

	public void insert(PiiOrderStepVO piiorderstep);

	public void insertSelectKey(PiiOrderStepVO piiorderstep);

	public PiiOrderStepVO read(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);
	public PiiOrderStepVO readByStepseq(@Param("orderid") int orderid, @Param("stepseq") int stepseq);
	public PiiOrderStepVO readByStepEXE(@Param("orderid") int orderid);
	public PiiOrderStepVO readFirstStep(@Param("orderid") int orderid);

	public int deletebyorderid(@Param("orderid") int orderid);
	public int delete(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);
	public int updatebefore(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);
	public int updateend(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid);

	public int update(PiiOrderStepVO piiorderstep);
	public int updateactionflag(PiiOrderStepVO piiorderstep);
	public int rerun(@Param("orderid") int orderid);
	
	public int getTotalCount(Criteria cri);

}
