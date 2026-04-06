package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.mapper.PiiDatabaseMapper;
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
public class PiiDatabaseServiceImpl implements PiiDatabaseService {
	private static final Logger logger = LoggerFactory.getLogger(PiiDatabaseServiceImpl.class);
	@Autowired
	private PiiDatabaseMapper mapper;


	@Override
	public List<PiiDatabaseVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}

	
	@Override
	public List<PiiDatabaseVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiDatabaseVO piidatabase) {
		
		 LogUtil.log("INFO", "register......" + piidatabase);
		 
//		 mapper.insert(piidatabase); 
		 mapper.insertSelectKey(piidatabase); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String db) {
		
		LogUtil.log("INFO", "remove...." + db);
		 
		return mapper.delete(db) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiDatabaseVO get(String db) {
		
		 LogUtil.log("INFO", "get......" + db);
		 
		 return mapper.read(db);
	}
	@Override
	public PiiDatabaseVO getBySystem(String system) {

		 LogUtil.log("INFO", "getBySystem......" + system);

		 return mapper.readBySystem(system);
	}


	@Override
	@Transactional
	public boolean modify(PiiDatabaseVO piidatabase) {
		
		LogUtil.log("INFO", "modify......" + piidatabase);
		
		return mapper.update(piidatabase) == 1;
	}
	
	@Override
	@Transactional
	public boolean modifyWithoutPw(PiiDatabaseVO piidatabase) {
		
		LogUtil.log("INFO", "modifyWithoutPw......" + piidatabase);
		
		return mapper.updateWithoutPw(piidatabase) == 1;
	}
	
}
