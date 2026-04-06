package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiPolicyVO;
import datablocks.dlm.mapper.PiiApprovalReqMapper;
import datablocks.dlm.mapper.PiiPolicyMapper;
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
public class PiiPolicyServiceImpl implements PiiPolicyService {
	private static final Logger logger = LoggerFactory.getLogger(PiiPolicyServiceImpl.class);
	@Autowired
	private PiiPolicyMapper mapper;
	@Autowired
	private PiiApprovalReqMapper approvalreqmapper;

	@Override
	public List<PiiPolicyVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiPolicyVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	public List<PiiPolicyVO> getAllVersionList(String policy_id) {
		
		LogUtil.log("INFO", "getAllVersionList: " + policy_id);
		
		return mapper.getAllVersionList(policy_id);
	}
	@Override
	public int getMaxVersionByPolicy(String policy_id) {
		
		LogUtil.log("INFO", "get total Max version");
		return mapper.getMaxVersionByPolicy(policy_id);
	}

	
	@Override
	@Transactional
	public void register(PiiPolicyVO piipolicy) {
		
		 LogUtil.log("INFO", "register......" + piipolicy);
		 
//		 mapper.insert(piipolicy); 
		 mapper.insertSelectKey(piipolicy); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String policy_id, String version) {
		
		LogUtil.log("INFO", "remove...." + policy_id +" "+version);
		 
		return mapper.delete(policy_id, version) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiPolicyVO get(String policy_id, String version) {
		
		 LogUtil.log("INFO", "get......" + policy_id +" "+version);
		 
		 return mapper.read(policy_id, version);
	}
	@Override
	public PiiPolicyVO getCurrent(String policy_id) {
		
		LogUtil.log("INFO", "getcurrent......" + policy_id );
		
		return mapper.readCurrent(policy_id);
	}

	@Override
	@Transactional
	public boolean modify(PiiPolicyVO piipolicy) {
		
		LogUtil.log("INFO", "modify......" + piipolicy);
		
		return mapper.update(piipolicy) == 1;
	}
	
	@Override
	@Transactional
	public void checkout(String policy_id, String version) {
		
		LogUtil.log("INFO", "checkout......" + policy_id+"-"+version);
		
		mapper.checkout(policy_id, version);
	}
	@Override
	@Transactional
	public void checkin(String policy_id, String version) {
		
		LogUtil.log("INFO", "checkin......" + policy_id+"-"+version);
		
		mapper.checkin(policy_id, version);
	}
	@Override
	@Transactional
	public boolean approve(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "approve......" + approvalreqVO);
		mapper.setold(approvalreqVO);
		return mapper.approve(approvalreqVO) == 1;
	}
	
	@Override
	@Transactional
	public boolean reject(PiiApprovalReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "reject......" + approvalreqVO);
		approvalreqmapper.reject(approvalreqVO);
		return mapper.reject(approvalreqVO) == 1;
	}
	
}
