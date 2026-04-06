package datablocks.dlm.service;

import datablocks.dlm.domain.PiiOrderStepTableUpdateVO;
import datablocks.dlm.domain.PiiOrderStepTableUpdateWithPkYnVO;
import datablocks.dlm.mapper.PiiOrderStepTableUpdateMapper;
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
public class PiiOrderStepTableUpdateServiceImpl implements PiiOrderStepTableUpdateService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderStepTableUpdateServiceImpl.class);
	@Autowired
	private PiiOrderStepTableUpdateMapper mapper;

	@Override
	public List<PiiOrderStepTableUpdateVO> getJobList(int orderid, String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getJobList(orderid, jobid, version);
	}
	
	@Override
	public List<PiiOrderStepTableUpdateVO> getList(int orderid, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get List: " );
		
		return mapper.getList(orderid, stepid, seq1, seq2, seq3);
	}
	@Override
	public List<PiiOrderStepTableUpdateWithPkYnVO> getListWithPkYn(int orderid, String stepid, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "getListWithPkYn List: " );

		return mapper.getListWithPkYn(orderid, stepid, seq1, seq2, seq3);
	}

	@Override
	@Transactional
	public void register(PiiOrderStepTableUpdateVO piisteptableupdate) {
		
		 LogUtil.log("INFO", "register......" + piisteptableupdate.toString());
		 
		 mapper.insert(piisteptableupdate); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(PiiOrderStepTableUpdateVO piisteptableupdate) {
		
		LogUtil.log("INFO", "remove...." + piisteptableupdate.toString());
		 
		return mapper.delete(piisteptableupdate) == 1;
	}
	@Override
	public boolean removebyseq(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "removebytable...." );
		
		return mapper.deletebyseq(orderid, jobid, version, stepid, seq1, seq2, seq3) == 1;
	}
	@Override
	@Transactional
	public boolean removebyjobid(int orderid, String jobid, String version) {
		
		LogUtil.log("INFO", "removebyjobid...." + jobid+" "+version);
		
		return mapper.deletebyjobid(orderid, jobid, version) == 1;
	}
	@Override
	@Transactional
	public boolean removebystepid(int orderid, String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "removebystepid...." + jobid+" "+version+" "+stepid);
		
		return mapper.deletebystepid(orderid, jobid, version, stepid) == 1;
	}

	@Override
	public int getTotal(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(orderid, jobid, version, stepid, seq1, seq2, seq3);
	}

	@Override
	public PiiOrderStepTableUpdateVO get(PiiOrderStepTableUpdateVO piisteptableupdate) {
		
		 LogUtil.log("INFO", "get......" + piisteptableupdate);
		 
		 return mapper.read(piisteptableupdate);
	}


	@Override
	@Transactional
	public boolean modify(PiiOrderStepTableUpdateVO piisteptableupdate) {
		
		LogUtil.log("INFO", "modify......" + piisteptableupdate);
		
		return mapper.update(piisteptableupdate) == 1;
	}

	@Override
	@Transactional
	public String modifyordersteptableupdate(List<PiiOrderStepTableUpdateVO> steptableupdatelist) {
		
		LogUtil.log("INFO", "modifyordersteptableupdate......");
		
    	try {
    		for(PiiOrderStepTableUpdateVO piisteptableupdate : steptableupdatelist) {
    			removebyseq(piisteptableupdate.getOrderid(), piisteptableupdate.getJobid(), piisteptableupdate.getVersion(), piisteptableupdate.getStepid(), piisteptableupdate.getSeq1(), piisteptableupdate.getSeq2(), piisteptableupdate.getSeq3());
    			break;
    		}
    		for(PiiOrderStepTableUpdateVO piisteptableupdate : steptableupdatelist) {
    			if(piisteptableupdate.getStatus().equalsIgnoreCase("ACTIVE")) {
    				register(piisteptableupdate);
    			}
    		}
    	}catch (Exception e) {
    		logger.warn("warn "+"Fail to modify update configuration of table "+e.getMessage());
    		return "Fail to modify update configuration of table";
    	}
		
		return "success";
	}
	


	
}
