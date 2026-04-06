package datablocks.dlm.service;

import datablocks.dlm.domain.PiiStepTableWaitVO;
import datablocks.dlm.mapper.PiiStepTableWaitMapper;
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
public class PiiStepTableWaitServiceImpl implements PiiStepTableWaitService {
	private static final Logger logger = LoggerFactory.getLogger(PiiStepTableWaitServiceImpl.class);
	@Autowired
	private PiiStepTableWaitMapper mapper;

	@Override
	public List<PiiStepTableWaitVO> getJobList(String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getJobList(jobid, version);
	}
	
	@Override
	public List<PiiStepTableWaitVO> getList(String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "get List: " );
		
		return mapper.getList(jobid, version, stepid, db, owner, table_name);
	}
	
	@Override
	@Transactional
	public void register(PiiStepTableWaitVO piisteptablewait) {
		
		 LogUtil.log("INFO", "register......" + piisteptablewait.toString());
		 
		 mapper.insert(piisteptablewait); 
	}
		 
	@Override
	@Transactional
	public boolean remove(PiiStepTableWaitVO piisteptablewait) {
		
		LogUtil.log("INFO", "remove...." + piisteptablewait.toString());
		 
		return mapper.delete(piisteptablewait) == 1;
	}
	@Override
	@Transactional
	public boolean removebytable(String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "removebytable...." );
		
		return mapper.deletebytable(jobid, version, stepid, db, owner, table_name) == 1;
	}
	@Override
	@Transactional
	public boolean removebyjobid(String jobid, String version) {
		
		LogUtil.log("INFO", "removebyjobid...." + jobid+" "+version);
		
		return mapper.deletebyjobid(jobid, version) == 1;
	}
	@Override
	@Transactional
	public boolean removebystepid(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "removebystepid...." + jobid+" "+version+" "+stepid);
		
		return mapper.deletebystepid(jobid, version, stepid) == 1;
	}

	@Override
	public int getTotal(String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(jobid, version, stepid, db, owner, table_name);
	}

	@Override
	public PiiStepTableWaitVO get(PiiStepTableWaitVO piisteptablewait) {
		
		 LogUtil.log("INFO", "get......" + piisteptablewait);
		 
		 return mapper.read(piisteptablewait);
	}

	@Override
	@Transactional
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "checkout......" + jobid+"-"+version);
		
		mapper.checkout(jobid, version);
	}

	@Override
	@Transactional
	public boolean modify(PiiStepTableWaitVO piisteptablewait) {
		
		LogUtil.log("INFO", "modify......" + piisteptablewait);
		
		return mapper.update(piisteptablewait) == 1;
	}

	@Override
	@Transactional
	public String modifysteptablewait(List<PiiStepTableWaitVO> steptablewaitlist) {
		
		LogUtil.log("INFO", "modifysteptablewait......");
		
    	try {
    		for(PiiStepTableWaitVO piisteptablewait : steptablewaitlist) {
    			removebytable(piisteptablewait.getJobid(), piisteptablewait.getVersion(), piisteptablewait.getStepid(), piisteptablewait.getDb(), piisteptablewait.getOwner(), piisteptablewait.getTable_name());
    			break;
    		}
    		for(PiiStepTableWaitVO piisteptablewait : steptablewaitlist) {
    			if(piisteptablewait.getType().equalsIgnoreCase("PRE")) {
    				register(piisteptablewait);
    			}
    		}
    	}catch (Exception e) {
    		logger.warn("warn "+"Fail to modify wait table list "+e.getMessage());
    		return "Fail to modify wait table list";
    	}
		
		return "success";
	}

	
}
