package datablocks.dlm.service;

import datablocks.dlm.domain.PiiOrderStepTableWaitVO;
import datablocks.dlm.mapper.PiiOrderStepTableWaitMapper;
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
public class PiiOrderStepTableWaitServiceImpl implements PiiOrderStepTableWaitService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderStepTableWaitServiceImpl.class);
	@Autowired
	private PiiOrderStepTableWaitMapper mapper;


	@Override
	public List<PiiOrderStepTableWaitVO> getList(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "get List: " );
		
		return mapper.getList(orderid, jobid, version, stepid, db, owner, table_name);
	}
	
	@Override
	@Transactional
	public void register(PiiOrderStepTableWaitVO piisteptablewait) {
		
		 LogUtil.log("INFO", "register......" + piisteptablewait.toString());
		 
		 mapper.insert(piisteptablewait); 
	}
		 
	@Override
	@Transactional
	public boolean remove(PiiOrderStepTableWaitVO piisteptablewait) {
		
		LogUtil.log("INFO", "remove...." + piisteptablewait.toString());
		 
		return mapper.delete(piisteptablewait) == 1;
	}
	@Override
	@Transactional
	public boolean removebytable(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "removebytable...." );
		
		return mapper.deletebytable(orderid, jobid, version, stepid, db, owner, table_name) == 1;
	}
	
	@Override
	@Transactional
	public boolean removebyorderid(int orderid) {
		
		LogUtil.log("INFO", "removebyjobid...." + orderid+" ");
		
		return mapper.deletebyorderid(orderid) == 1;
	}

	@Override
	public int getTotal(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(orderid, jobid, version, stepid, db, owner, table_name);
	}

	@Override
	public PiiOrderStepTableWaitVO get(PiiOrderStepTableWaitVO piisteptablewait) {
		
		 LogUtil.log("INFO", "get......" + piisteptablewait);
		 
		 return mapper.read(piisteptablewait);
	}

	@Override
	@Transactional
	public boolean modify(PiiOrderStepTableWaitVO piisteptablewait) {
		
		LogUtil.log("INFO", "modify......" + piisteptablewait);
		
		return mapper.update(piisteptablewait) == 1;
	}
	
	@Override
	@Transactional
	public String modifysteptablewait(List<PiiOrderStepTableWaitVO> steptablewaitlist) {
		
		LogUtil.log("INFO", "modifysteptablewait......");
		
    	try {
    		for(PiiOrderStepTableWaitVO piisteptablewait : steptablewaitlist) {
    			removebytable(piisteptablewait.getOrderid(), piisteptablewait.getJobid(), piisteptablewait.getVersion(), piisteptablewait.getStepid(), piisteptablewait.getDb(), piisteptablewait.getOwner(), piisteptablewait.getTable_name());
    			break;
    		}
    		for(PiiOrderStepTableWaitVO piisteptablewait : steptablewaitlist) {
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
