package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ProgOrderHistOkVO;
import datablocks.dlm.domain.ProgOrderHistVO;
import datablocks.dlm.mapper.ProgOrderHistMapper;
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
public class ProgOrderHIstServiceImpl implements ProgOrderHistService {
	private static final Logger logger = LoggerFactory.getLogger(ProgOrderHIstServiceImpl.class);
	@Autowired
	private ProgOrderHistMapper mapper;


	@Override
	public List<ProgOrderHistVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<ProgOrderHistOkVO> getListEndedOK() {

		LogUtil.log("INFO", "getListEndedOK: " );

		return mapper.getListEndedOK();
	}

	@Override
	public List<ProgOrderHistVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(ProgOrderHistVO progOrderHist) {
		
		 LogUtil.log("INFO", "register......" + progOrderHist);
		 
//		 mapper.insert(piicode); 
		 mapper.insertSelectKey(progOrderHist);
	}
		 
	@Override
	@Transactional
	public boolean remove(String orderid) {
		
		LogUtil.log("INFO", "remove...." + orderid);
		 
		return mapper.delete(orderid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public ProgOrderHistVO get(String orderid) {
		
		 LogUtil.log("INFO", "get......" + orderid);
		 
		 return mapper.read(orderid);
	}

	@Override
	@Transactional
	public boolean modify(ProgOrderHistVO progOrderHist) {
		
		LogUtil.log("INFO", "modify......" + progOrderHist);
		
		return mapper.update(progOrderHist) == 1;
	}
	
}
