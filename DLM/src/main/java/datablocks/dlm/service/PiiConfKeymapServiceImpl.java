package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfKeymapRefVO;
import datablocks.dlm.domain.PiiConfKeymapVO;
import datablocks.dlm.mapper.PiiConfKeymapMapper;
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
public class PiiConfKeymapServiceImpl implements PiiConfKeymapService {
	private static final Logger logger = LoggerFactory.getLogger(PiiConfKeymapServiceImpl.class);
	@Autowired
	private PiiConfKeymapMapper mapper;


	@Override
	public List<PiiConfKeymapVO> getList() {
		
		//LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiConfKeymapRefVO> getList_distinct(String keymap_id) {
		
		//LogUtil.log("INFO", "get getList_distinct: " );
		return mapper.getList_distinct(keymap_id);
	}
	@Override
	public List<PiiConfKeymapVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiConfKeymapVO piiconfkeymap) {
		
		 LogUtil.log("INFO", "register......" + piiconfkeymap);
		 
//		 mapper.insert(piiconfkeymap); 
		 mapper.insertSelectKey(piiconfkeymap); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(String keymap_id, String key_name, String db, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "remove...." + key_name);
		 
		return mapper.delete(keymap_id, key_name, db, seq1, seq2, seq3) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiConfKeymapVO get(String keymap_id, String key_name, String db, int seq1, int seq2, int seq3) {
		
		 LogUtil.log("INFO", "get......" + key_name);
		 
		 return mapper.read(keymap_id, key_name, db, seq1, seq2, seq3);
	}

	@Override
	@Transactional
	public boolean modify(PiiConfKeymapVO piiconfkeymap) {
		
		LogUtil.log("INFO", "modify......" + piiconfkeymap);
		
		return mapper.update(piiconfkeymap) == 1;
	}

	@Override
	public void testJobMethod() {
		
		LogUtil.log("INFO", "testJobMethod......");
	}



	
}
