package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.TestDataIdTypeVO;

import java.util.List;

public interface TestDataIdTypeService {

	public void register(TestDataIdTypeVO testdataidtype);

	public TestDataIdTypeVO get(String id);

	public boolean modify(TestDataIdTypeVO testdataidtype);

	public boolean remove(String id);

	public List<TestDataIdTypeVO> getList();

	public List<TestDataIdTypeVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}