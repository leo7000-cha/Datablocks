package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ErrorHistVO;
import datablocks.dlm.mapper.ErrorHistMapper;
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
public class ErrorHistServiceImpl implements ErrorHistService {
	private static final Logger logger = LoggerFactory.getLogger(ErrorHistServiceImpl.class);
	@Autowired
	private ErrorHistMapper mapper;


	@Override
	public List<ErrorHistVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<ErrorHistVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(ErrorHistVO errorHist) {
		
		 LogUtil.log("INFO", "register......" + errorHist);
		 
//		 mapper.insert(piicode); 
		 mapper.insertSelectKey(errorHist);
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
	public ErrorHistVO get(String id) {
		
		 LogUtil.log("INFO", "get......" + id);
		 
		 return mapper.read(id);
	}

	@Override
	@Transactional
	public boolean modify(ErrorHistVO errorHist) {
		
		LogUtil.log("INFO", "modify......" + errorHist);
		
		return mapper.update(errorHist) == 1;
	}
	
}
