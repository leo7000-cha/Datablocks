package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiSystemVO;
import org.apache.ibatis.annotations.Param;

public interface PiiSystemMapper {

   //@Select("select * from piisystem")
	public List<PiiSystemVO> getList();
	
	public List<PiiSystemVO> getListWithPaging(Criteria cri);

	public void insert(PiiSystemVO piisystem);

	public void insertSelectKey(PiiSystemVO piisystem);

	//public PiiSystemVO read(PiiSystemVO PiiSystem);
	public PiiSystemVO read(@Param("system_id") String system_id);

	public int delete(@Param("system_id") String system_id);
	
	public int update(PiiSystemVO piisystem);
	
	public int getTotalCount(Criteria cri);

}
