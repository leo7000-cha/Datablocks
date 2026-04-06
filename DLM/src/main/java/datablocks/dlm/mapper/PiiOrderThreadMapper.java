package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import datablocks.dlm.domain.PiiOrderThreadVO;

public interface PiiOrderThreadMapper {

	public List<PiiOrderThreadVO> getList(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version);
	public int getListCnt(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version);
	
	public int insert(PiiOrderThreadVO piiorderthread);

	public PiiOrderThreadVO read(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	
	public int delete(@Param("orderid") int orderid);
	public int deleteEndOkTabs();

}
