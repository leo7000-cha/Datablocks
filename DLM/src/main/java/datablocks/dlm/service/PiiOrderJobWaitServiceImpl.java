package datablocks.dlm.service;

import datablocks.dlm.domain.PiiOrderJobWaitVO;
import datablocks.dlm.mapper.PiiOrderJobWaitMapper;
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
public class PiiOrderJobWaitServiceImpl implements PiiOrderJobWaitService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderJobWaitServiceImpl.class);
	@Autowired
	private PiiOrderJobWaitMapper mapper;

	@Override
	public List<PiiOrderJobWaitVO> getList(int orderid, String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList(orderid, jobid, version);
	}
	
	@Override
	@Transactional
	public void register(PiiOrderJobWaitVO piiorderjobwait) {
		
		 LogUtil.log("INFO", "register......" + piiorderjobwait.toString());
		 
		 mapper.insert(piiorderjobwait); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(PiiOrderJobWaitVO piiorderjobwait) {
		
		LogUtil.log("INFO", "remove...." + piiorderjobwait.toString());
		 
		return mapper.delete(piiorderjobwait) == 1;
	}
	@Override
	@Transactional
	public boolean removebyorderid(int orderid) {

		LogUtil.log("INFO", "remove...." + orderid);

		return mapper.deletebyorderid(orderid) == 1;
	}


	@Override
	public int getTotal(int orderid,String jobid, String version) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount( orderid,jobid,version);
	}

	@Override
	public PiiOrderJobWaitVO get(PiiOrderJobWaitVO piiorderjobwait) {
		
		 LogUtil.log("INFO", "get......" + piiorderjobwait);
		 
		 return mapper.read(piiorderjobwait);
	}


	@Override
	@Transactional
	public boolean modify(PiiOrderJobWaitVO piiorderjobwait) {
		
		LogUtil.log("INFO", "modify......" + piiorderjobwait);
		
		return mapper.update(piiorderjobwait) == 1;
	}



	
}
