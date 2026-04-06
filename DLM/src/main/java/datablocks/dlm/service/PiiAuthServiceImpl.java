package datablocks.dlm.service;

import datablocks.dlm.domain.AuthToChangeVO;
import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.mapper.PiiAuthMapper;
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
public class PiiAuthServiceImpl implements PiiAuthService {
	private static final Logger logger = LoggerFactory.getLogger(PiiAuthServiceImpl.class);
	@Autowired
	private PiiAuthMapper mapper;


	@Override
	public List<AuthVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<AuthVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	public void register(AuthVO auth) {
		
		 LogUtil.log("INFO", "register......" + auth);
//		 mapper.insert(auth); 
		 mapper.insertSelectKey(auth); 
	}
		 
	@Override
	@Transactional
	public boolean remove(AuthVO auth) {
		
		LogUtil.log("INFO", "remove...." + auth);
		return mapper.delete(auth) == 1;
	}

	@Override
	@Transactional
	public boolean removeByUserid(String userid) {

		LogUtil.log("INFO", "removeByUserid...." + userid);
		return mapper.deleteByUserid(userid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public AuthVO get(AuthVO auth) {
		
		 LogUtil.log("INFO", "get......" + auth);
		 
		 return mapper.read(auth);
	}

	@Override
	@Transactional
	public boolean modify(AuthToChangeVO auth) {
		
		LogUtil.log("INFO", "modify......" + auth);
		
		return mapper.update(auth) == 1;
	}
	
}
