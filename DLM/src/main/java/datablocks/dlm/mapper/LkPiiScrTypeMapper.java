package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.LkPiiScrTypeVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface LkPiiScrTypeMapper {

   //@Select("select * from piiscrtype")
	public List<LkPiiScrTypeVO> getList();
	
	public List<LkPiiScrTypeVO> getListWithPaging(Criteria cri);

	public void insert(LkPiiScrTypeVO piiscrtype);

	public void insertSelectKey(LkPiiScrTypeVO piiscrtype);

	//public LkPiiScrTypeVO read(LkPiiScrTypeVO PiiSystem);
	public LkPiiScrTypeVO read(@Param("piicode") String piicode);

	public int delete(@Param("piicode") String piicode);
	
	public int update(LkPiiScrTypeVO piiscrtype);
	
	public int getTotalCount(Criteria cri);

}
