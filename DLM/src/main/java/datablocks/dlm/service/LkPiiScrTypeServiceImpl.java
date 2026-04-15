package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.LkPiiScrTypeVO;
import datablocks.dlm.mapper.LkPiiScrTypeMapper;
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
public class LkPiiScrTypeServiceImpl implements LkPiiScrTypeService {
	private static final Logger logger = LoggerFactory.getLogger(LkPiiScrTypeServiceImpl.class);
	@Autowired
	private LkPiiScrTypeMapper mapper;

	@Override
	public List<LkPiiScrTypeVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<LkPiiScrTypeVO> getListAll() {
		return mapper.getListAll();
	}

	@Override
	public List<LkPiiScrTypeVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(LkPiiScrTypeVO piiscrtype) {
		
		 LogUtil.log("INFO", "register......" + piiscrtype);
		 
//		 mapper.insert(piiscrtype); 
		 mapper.insertSelectKey(piiscrtype); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String piicode) {
		
		LogUtil.log("INFO", "remove...." + piicode);
		 
		return mapper.delete(piicode) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public LkPiiScrTypeVO get(String piicode) {
		
		 LogUtil.log("INFO", "get......" + piicode);
		 
		 return mapper.read(piicode);
	}

	@Override
	@Transactional
	public boolean modify(LkPiiScrTypeVO piiscrtype) {
		
		LogUtil.log("INFO", "modify......" + piiscrtype);
		
		return mapper.update(piiscrtype) == 1;
	}

	@Override
	@Transactional
	public void updateVisible(String piicode, String visible) {
		LogUtil.log("INFO", "updateVisible: " + piicode + " -> " + visible);
		mapper.updateVisible(piicode, visible);
	}

}
