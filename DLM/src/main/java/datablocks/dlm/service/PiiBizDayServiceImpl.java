package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiBizDayVO;
import datablocks.dlm.mapper.PiiBizDayMapper;
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
public class PiiBizDayServiceImpl implements PiiBizDayService {
	private static final Logger logger = LoggerFactory.getLogger(PiiBizDayServiceImpl.class);
	@Autowired
	private PiiBizDayMapper mapper;


	@Override
	public List<PiiBizDayVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiBizDayVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiBizDayVO piibizday) {
		
		 LogUtil.log("INFO", "register......" + piibizday);
		 
//		 mapper.insert(piibizday); 
		 mapper.insertSelectKey(piibizday); 
	}
		 
	@Override
	@Transactional
	public boolean remove(PiiBizDayVO piibizday) {
		
		LogUtil.log("INFO", "remove...." + piibizday.toString());
		 
		return mapper.delete(piibizday) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiBizDayVO get(String base_dt) {
		
		 LogUtil.log("INFO", "get......" + base_dt);
		 
		 return mapper.read(base_dt);
	}

	@Override
	@Transactional
	public boolean modify(PiiBizDayVO piibizday) {
		
		LogUtil.log("INFO", "modify......" + piibizday);
		
		return mapper.update(piibizday) == 1;
	}

	@Override
	@Transactional
	public String getDeadline(String basedate, String cnt) {

		LogUtil.log("INFO", "getDeadline......" + basedate +"  "+cnt);

		return mapper.getDeadline(basedate, cnt)+"";
	}
	@Override
	@Transactional
	public String getArcDeadline(String basedate, String cnt) {

		LogUtil.log("INFO", "getArcDeadline......" + basedate +"  "+cnt);

		return mapper.getArcDeadline(basedate, cnt)+"";
	}

	
}
