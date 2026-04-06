package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.DepartmentVO;
import datablocks.dlm.mapper. DepartmentMapper;
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
public class DepartmentServiceImpl implements DepartmentService {
	private static final Logger logger = LoggerFactory.getLogger(DepartmentServiceImpl.class);
	@Autowired
	private  DepartmentMapper mapper;


	@Override
	public List<DepartmentVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<DepartmentVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(DepartmentVO dept) {
		
		 LogUtil.log("INFO", "register......" + dept);
		 
//		 mapper.insert(dept);
		 mapper.insertSelectKey(dept);
	}
		 
	@Override
	@Transactional
	public boolean remove(String deptcode) {
		
		LogUtil.log("INFO", "remove...." + deptcode);
		 
		return mapper.delete(deptcode) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public DepartmentVO get(String deptcode) {
		
		 LogUtil.log("INFO", "get......" + deptcode);
		 
		 return mapper.read(deptcode);
	}

	@Override
	@Transactional
	public boolean modify(DepartmentVO dept) {
		
		LogUtil.log("INFO", "modify......" + dept);
		
		return mapper.update(dept) == 1;
	}
	
}
