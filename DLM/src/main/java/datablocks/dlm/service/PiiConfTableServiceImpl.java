package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfTableVO;
import datablocks.dlm.mapper.PiiConfTableMapper;
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
public class PiiConfTableServiceImpl implements PiiConfTableService {
	private static final Logger logger = LoggerFactory.getLogger(PiiConfTableServiceImpl.class);
	@Autowired
	private PiiConfTableMapper mapper;


	@Override
	public List<PiiConfTableVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiConfTableVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiConfTableVO piiconftable) {
		
		 LogUtil.log("INFO", "register......" + piiconftable);
		  
		 mapper.insert(piiconftable); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(String db,
			String owner,
			String table_name
			) {
		
		LogUtil.log("INFO", "remove...." + db +":"+ owner +":"+ table_name);
		 
		return mapper.delete(db, owner, table_name) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiConfTableVO get(String db,
			String owner,
			String table_name) {
		
		 LogUtil.log("INFO", "get......" + db +":"+ owner +":"+ table_name);
		 
		 return mapper.read(db, owner, table_name);
	}

	@Override
	@Transactional
	public boolean modify(PiiConfTableVO piiconftable) {
		
		LogUtil.log("INFO", "modify......" + piiconftable);
		
		return mapper.update(piiconftable) == 1;
	}

	@Override
	public void testJobMethod() {
		
		LogUtil.log("INFO", "testJobMethod......");
	}



	
}
