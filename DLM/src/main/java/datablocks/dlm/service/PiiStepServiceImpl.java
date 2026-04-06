package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiStepVO;
import datablocks.dlm.domain.PiiStepseqVO;
import datablocks.dlm.mapper.PiiStepMapper;
import datablocks.dlm.mapper.PiiStepTableMapper;
import datablocks.dlm.mapper.PiiStepTableUpdateMapper;
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
public class PiiStepServiceImpl implements PiiStepService {
	private static final Logger logger = LoggerFactory.getLogger(PiiStepServiceImpl.class);
	@Autowired
	private PiiStepMapper mapper;

	@Autowired
	private PiiStepTableMapper steptablemapper;
	
	@Autowired
	private PiiStepTableWaitMapper steptablewaitmapper;
	
	@Autowired
	private PiiStepTableUpdateMapper steptableupdatemapper;

	@Override
	public List<PiiStepVO> getJobList(String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getJobList(jobid, version);
	}
	@Override
	public List<PiiStepVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		
		return mapper.getList();
	}
	
	@Override
	public List<PiiStepVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiStepVO piistep) {
		
		 LogUtil.log("INFO", "register......" + piistep);
		 piistep.setStepseq(mapper.getMaxStepseq(piistep.getJobid())+"");
//		 mapper.insert(piistep);

		 mapper.insertSelectKey(piistep); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(PiiStepVO piistep) {
		
		LogUtil.log("INFO", "remove...." + piistep);

		//for synchronizing Archive table configuration
		int arctab = getCountWithSteptype(piistep.getJobid(), piistep.getVersion(), "EXE_ARCHIVE");
		if(arctab == 1 && (piistep.getSteptype().equals("EXE_DELETE") || piistep.getSteptype().equals("EXE_UPDATE"))) {
			PiiStepVO arcstep = mapper.readWithSteptype(piistep.getJobid(), piistep.getVersion(), "EXE_ARCHIVE");
			steptableupdatemapper.deletebystepid(arcstep.getJobid(), arcstep.getVersion(), arcstep.getStepid());
			steptablewaitmapper.deletebystepid(arcstep.getJobid(), arcstep.getVersion(), arcstep.getStepid());
			steptablemapper.deleteStepTable(arcstep.getJobid(), arcstep.getVersion(), arcstep.getStepid());
		}
		
		steptableupdatemapper.deletebystepid(piistep.getJobid(), piistep.getVersion(), piistep.getStepid());
		steptablewaitmapper.deletebystepid(piistep.getJobid(), piistep.getVersion(), piistep.getStepid());
		steptablemapper.deleteStepTable(piistep.getJobid(), piistep.getVersion(), piistep.getStepid());
		return mapper.delete(piistep.getJobid(), piistep.getVersion(), piistep.getStepid()) == 1;
	}
	
	@Override
	@Transactional
	public void removeJobStep(String jobid, String version) {
		// this is not used. if you use this function, need to call remove(PiiStepVO piistep) for all steps of the job......
		LogUtil.log("INFO", "removeJobStep...." + jobid);
		
		mapper.deleteJobStep(jobid, version);
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiStepVO get(String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "get......" + stepid);
		return mapper.read(jobid, version, stepid );
	}

	@Override
	public PiiStepVO getWithSteptype(String jobid, String version, String steptype) {
		
		 LogUtil.log("INFO", "getWithSteptype......" + jobid+" "+version+" "+steptype);
		 return mapper.readWithSteptype(jobid, version, steptype );
	}
	@Override
	public PiiStepVO getWithStepEXE(String jobid, String version) {
		
		LogUtil.log("INFO", "getWithSteptype......" + jobid+" "+version);
		return mapper.readWithStepEXE(jobid, version );
	}
	@Override
	public int getCountWithSteptype(String jobid, String version, String steptype) {
		
		LogUtil.log("INFO", "getCountWithSteptype......" + jobid+"  "+steptype);
		
		return mapper.getCountWithSteptype(jobid, version, steptype );
	}

	@Override
	@Transactional
	public boolean modify(PiiStepVO piistep) {
		
		LogUtil.log("INFO", "modify......" + piistep);

		return mapper.update(piistep) == 1;
	}
	@Override
	@Transactional
	public boolean modify_seq(PiiStepseqVO piistepseq) {
		
		LogUtil.log("INFO", "modify_seq......" + piistepseq.toString());
		
		return mapper.update_seq(piistepseq) == 1;
	}
	@Override
	@Transactional
	public boolean modify_status(String status, String policy_id) {
		
		LogUtil.log("INFO", "modify_status......" + status + " "+ policy_id);
		
		return mapper.update_status(status, policy_id) == 1;
	}
	@Override
	public boolean updateStepStatus(String jobid, String version, String steptype, String status) {

		LogUtil.log("INFO", "modify_status......" + jobid + " "+ version+ " "+ steptype);

		return mapper.updateStepStatus(jobid, version, steptype, status) == 1;
	}
	@Override
	@Transactional
	public void checkout(String jobid, String version) {
		
		LogUtil.log("INFO", "get......" + jobid+"-"+version);
		
		mapper.checkout(jobid, version);
	}

	
}
