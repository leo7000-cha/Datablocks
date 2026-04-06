package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiCodeVO;
import datablocks.dlm.mapper.PiiCodeMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiCodeServiceImpl implements PiiCodeService {
	private static final Logger logger = LoggerFactory.getLogger(PiiCodeServiceImpl.class);
	@Autowired
	private PiiCodeMapper mapper;


	@Override
	public List<PiiCodeVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiCodeVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiCodeVO piicode) {
		
		 LogUtil.log("INFO", "register......" + piicode);
		 
//		 mapper.insert(piicode); 
		 mapper.insertSelectKey(piicode); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String code_id, String item_val) {
		
		LogUtil.log("INFO", "remove...." + code_id);
		 
		return mapper.delete(code_id, item_val) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiCodeVO get(String code_id, String item_val) {
		
		 LogUtil.log("INFO", "get......" + code_id);
		 
		 return mapper.read(code_id, item_val);
	}

	@Override
	@Transactional
	public boolean modify(PiiCodeVO piicode) {
		
		LogUtil.log("INFO", "modify......" + piicode);
		
		return mapper.update(piicode) == 1;
	}
	
}
