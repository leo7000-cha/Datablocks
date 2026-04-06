package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.TestDataIdTypeVO;
import datablocks.dlm.mapper.TestDataIdTypeMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class TestDataIdTypeServiceImpl implements TestDataIdTypeService {
	private static final Logger logger = LoggerFactory.getLogger(TestDataIdTypeServiceImpl.class);
	@Autowired
	private TestDataIdTypeMapper mapper;

	@Override
	public List<TestDataIdTypeVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<TestDataIdTypeVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(TestDataIdTypeVO testdataidtype) {
		
		 LogUtil.log("INFO", "register......" + testdataidtype);
		 
//		 mapper.insert(testdataidtype); 
		 mapper.insertSelectKey(testdataidtype); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String id) {
		
		LogUtil.log("INFO", "remove...." + id);
		 
		return mapper.delete(id) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public TestDataIdTypeVO get(String id) {
		
		 LogUtil.log("INFO", "get......" + id);
		 
		 return mapper.read(id);
	}

	@Override
	@Transactional
	public boolean modify(TestDataIdTypeVO testdataidtype) {
		
		LogUtil.log("INFO", "modify......" + testdataidtype);
		
		return mapper.update(testdataidtype) == 1;
	}
	
}
