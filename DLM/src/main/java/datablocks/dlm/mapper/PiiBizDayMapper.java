package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiBizDayVO;
import datablocks.dlm.domain.Criteria;

public interface PiiBizDayMapper {

	public List<PiiBizDayVO> getList();
	
	public List<PiiBizDayVO> getListWithPaging(Criteria cri);

	public void insert(PiiBizDayVO bizday);

	public void insertSelectKey(PiiBizDayVO bizday);

	public PiiBizDayVO read(@Param("base_dt") String base_dt);

	public int delete(PiiBizDayVO bizday);
	
	public int update(PiiBizDayVO bizday);
	
	public int getTotalCount(Criteria cri);
	
	public String getDeadline(@Param("basedate") String basedate, @Param("cnt") String cnt);
	public String getArcDeadline(@Param("basedate") String basedate, @Param("cnt") String cnt);

}
