package datablocks.dlm.service;

import datablocks.dlm.domain.PiiJobWaitVO;
import datablocks.dlm.mapper.PiiJobWaitMapper;
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
public class PiiJobWaitServiceImpl implements PiiJobWaitService {
	private static final Logger logger = LoggerFactory.getLogger(PiiJobWaitServiceImpl.class);
	@Autowired
	private PiiJobWaitMapper mapper;

	@Override
	public List<PiiJobWaitVO> getList(String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList(jobid, version);
	}
	
	@Override
	@Transactional
	public void register(PiiJobWaitVO piijobwait) {
		
		 LogUtil.log("INFO", "register......" + piijobwait.toString());
		 
		 mapper.insert(piijobwait); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(PiiJobWaitVO piijobwait) {
		
		LogUtil.log("INFO", "remove...." + piijobwait.toString());
		 
		return mapper.delete(piijobwait) == 1;
	}

	@Override
	@Transactional
	public boolean removeJob(String jobid, String version) {
		
		LogUtil.log("INFO", "removeJob...." + jobid +"  "+version);
		
		return mapper.deleteJob(jobid, version) == 1;
	}
	
	@Override
	public int getTotal(String jobid, String version) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(jobid,version);
	}

	@Override
	public PiiJobWaitVO get(PiiJobWaitVO piijobwait) {
		
		 LogUtil.log("INFO", "get......" + piijobwait);
		 
		 return mapper.read(piijobwait);
	}

	@Override
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "checkout......" + jobid+"-"+version);
		
		mapper.checkout(jobid, version);
	}

	@Override
	@Transactional
	public boolean modify(PiiJobWaitVO piijobwait) {
		
		LogUtil.log("INFO", "modify......" + piijobwait);
		
		return mapper.update(piijobwait) == 1;
	}



	
}
