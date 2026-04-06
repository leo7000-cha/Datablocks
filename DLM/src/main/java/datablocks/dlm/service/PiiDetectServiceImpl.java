package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDetectConfigVO;
import datablocks.dlm.domain.PiiDetectResultVO;
import datablocks.dlm.mapper.PiiDetectMapper;
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
public class PiiDetectServiceImpl implements PiiDetectService {
	private static final Logger logger = LoggerFactory.getLogger(PiiDetectServiceImpl.class);
	@Autowired
	private PiiDetectMapper mapper;

	@Override
	public List<PiiDetectConfigVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiDetectConfigVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiDetectConfigVO config) {
		
		 LogUtil.log("INFO", "register......" + config);
		 
		 mapper.insert(config); 
		 
	}
		 
	@Override
	public boolean remove(String conf_id) {
		
		LogUtil.log("INFO", "remove...." + conf_id);
		 
		return mapper.delete(conf_id) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiDetectConfigVO get(String conf_id) {
		
		 LogUtil.log("INFO", "get......" + conf_id);
		 
		 return mapper.read(conf_id);
	}

	@Override
	@Transactional
	public boolean modify(PiiDetectConfigVO config) {
		
		LogUtil.log("INFO", "modify......" + config);
		
		return mapper.update(config) == 1;
	}


	@Override
	public int getResultTotal(Criteria cri) {

		LogUtil.log("INFO", "getResultTotal count");
		return mapper.getResultTotalCount(cri);
	}
	@Override
	public List<PiiDetectResultVO> getResultList(Criteria cri) {

		LogUtil.log("INFO", "getResultList with criteria: " + cri);
		return mapper.getListResultWithPaging(cri);
	}
}
