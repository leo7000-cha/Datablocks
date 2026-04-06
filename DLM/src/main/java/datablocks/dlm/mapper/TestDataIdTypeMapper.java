package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.TestDataIdTypeVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface TestDataIdTypeMapper {

   //@Select("select * from testdataidtype")
	public List<TestDataIdTypeVO> getList();
	
	public List<TestDataIdTypeVO> getListWithPaging(Criteria cri);

	public void insert(TestDataIdTypeVO testdataidtype);

	public void insertSelectKey(TestDataIdTypeVO testdataidtype);

	//public TestDataIdTypeVO read(TestDataIdTypeVO PiiSystem);
	public TestDataIdTypeVO read(@Param("id") String id);

	public int delete(@Param("id") String id);
	
	public int update(TestDataIdTypeVO testdataidtype);
	
	public int getTotalCount(Criteria cri);

}
