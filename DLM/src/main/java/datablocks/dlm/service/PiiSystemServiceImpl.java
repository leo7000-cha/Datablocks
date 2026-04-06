package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiSystemVO;
import datablocks.dlm.mapper.PiiSystemMapper;
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
public class PiiSystemServiceImpl implements PiiSystemService {
	private static final Logger logger = LoggerFactory.getLogger(PiiSystemServiceImpl.class);
	@Autowired
	private PiiSystemMapper mapper;

	@Override
	public List<PiiSystemVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiSystemVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiSystemVO piisystem) {
		
		 LogUtil.log("INFO", "register......" + piisystem);
		 
//		 mapper.insert(piisystem); 
		 mapper.insertSelectKey(piisystem); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String system_id) {
		
		LogUtil.log("INFO", "remove...." + system_id);
		 
		return mapper.delete(system_id) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiSystemVO get(String system_id) {
		
		 LogUtil.log("INFO", "get......" + system_id);
		 
		 return mapper.read(system_id);
	}

	@Override
	@Transactional
	public boolean modify(PiiSystemVO piisystem) {
		
		LogUtil.log("INFO", "modify......" + piisystem);
		
		return mapper.update(piisystem) == 1;
	}
	
}
