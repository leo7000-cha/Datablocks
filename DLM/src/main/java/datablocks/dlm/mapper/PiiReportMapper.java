package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiReportVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiReportMapper {

   //@Select("select * from piireport")
	public List<PiiReportVO> getList();
	
	public List<PiiReportVO> getListWithPaging(Criteria cri);

	public void insert(PiiReportVO piireport);

	public void insertSelectKey(PiiReportVO piireport);

	//public PiiReportVO read(PiiReportVO PiiReport);
	public PiiReportVO read(String reportid);

	public int delete(@Param("reportid") String reportid);
	
	public int update(PiiReportVO piireport);
	
	public int getTotalCount(Criteria cri);
	public int getMaxReportid();

	public int requestapproval(@Param("reportid") int reportid);
	public int reject(@Param("reportid") int reportid);
	public int approve(@Param("reportid") int reportid);

}
