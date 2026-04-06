package datablocks.dlm.service;

import datablocks.dlm.domain.PiiStepTableUpdateVO;
import datablocks.dlm.mapper.PiiStepTableUpdateMapper;
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
public class PiiStepTableUpdateServiceImpl implements PiiStepTableUpdateService {
	private static final Logger logger = LoggerFactory.getLogger(PiiStepTableUpdateServiceImpl.class);
	@Autowired
	private PiiStepTableUpdateMapper mapper;

	@Override
	public List<PiiStepTableUpdateVO> getJobList(String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getJobList(jobid, version);
	}
	
	@Override
	public List<PiiStepTableUpdateVO> getList(String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get List: " );
		
		return mapper.getList(jobid, version, stepid, seq1, seq2, seq3);
	}
	
	@Override
	@Transactional
	public void register(PiiStepTableUpdateVO piisteptableupdate) {
		
		 LogUtil.log("INFO", "register......" + piisteptableupdate.toString());
		 
		 mapper.insert(piisteptableupdate); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(PiiStepTableUpdateVO piisteptableupdate) {
		
		LogUtil.log("INFO", "remove...." + piisteptableupdate.toString());
		 
		return mapper.delete(piisteptableupdate) == 1;
	}
	@Override
	@Transactional
	public boolean removebyseq(String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "removebytable...." );
		
		return mapper.deletebyseq(jobid, version, stepid, seq1, seq2, seq3) == 1;
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
	public int getTotal(String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(jobid, version, stepid, seq1, seq2, seq3);
	}

	@Override
	public PiiStepTableUpdateVO get(PiiStepTableUpdateVO piisteptableupdate) {
		
		 LogUtil.log("INFO", "get......" + piisteptableupdate);
		 
		 return mapper.read(piisteptableupdate);
	}

	@Override
	@Transactional
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "checkout......" + jobid+"-"+version);
		
		mapper.checkout(jobid, version);
	}

	@Override
	@Transactional
	public boolean modify(PiiStepTableUpdateVO piisteptableupdate) {
		
		LogUtil.log("INFO", "modify......" + piisteptableupdate);
		
		return mapper.update(piisteptableupdate) == 1;
	}

	@Override
	@Transactional
	public String modifysteptableupdate(List<PiiStepTableUpdateVO> steptableupdatelist) {
		
		LogUtil.log("INFO", "modifysteptableupdate......");
		
    	try {
    		for(PiiStepTableUpdateVO piisteptableupdate : steptableupdatelist) {
    			removebyseq(piisteptableupdate.getJobid(), piisteptableupdate.getVersion(), piisteptableupdate.getStepid(), piisteptableupdate.getSeq1(), piisteptableupdate.getSeq2(), piisteptableupdate.getSeq3());
    			break;
    		}
    		for(PiiStepTableUpdateVO piisteptableupdate : steptableupdatelist) {
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
