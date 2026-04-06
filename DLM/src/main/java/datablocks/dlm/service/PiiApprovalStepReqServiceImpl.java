package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalStepReqVO;
import datablocks.dlm.mapper.PiiApprovalStepReqMapper;
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
public class PiiApprovalStepReqServiceImpl implements PiiApprovalStepReqService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalStepReqServiceImpl.class);
	@Autowired
	private PiiApprovalStepReqMapper mapper;


	@Override
	public List<PiiApprovalStepReqVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		return mapper.getList();
	}

	
	@Override
	public List<PiiApprovalStepReqVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiApprovalStepReqVO piiapprovalstepreq) {
		
		 LogUtil.log("INFO", "register......" + piiapprovalstepreq);
		  
		 mapper.insert(piiapprovalstepreq); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(String reqid) {
		
		LogUtil.log("INFO", "remove...." + reqid);
		 
		return mapper.delete(reqid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiApprovalStepReqVO get(String reqid) {

		 LogUtil.log("INFO", "get......" + reqid);

		 return mapper.read(reqid);
	}

	@Override
	@Transactional
	public boolean modify(PiiApprovalStepReqVO piiapprovalstepreq) {
		
		LogUtil.log("INFO", "modify......" + piiapprovalstepreq);
		
		return mapper.update(piiapprovalstepreq) == 1;
	}

	@Override
	@Transactional
	public boolean approve(PiiApprovalStepReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "approve......" + approvalreqVO);

		return mapper.approve(approvalreqVO) == 1;
	}

	@Override
	@Transactional
	public boolean reject(PiiApprovalStepReqVO approvalreqVO) {
		
		LogUtil.log("INFO", "reject......" + approvalreqVO);
		
		return mapper.reject(approvalreqVO) == 1;
	}
	


}
