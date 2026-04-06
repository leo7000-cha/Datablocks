package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.PiiApprovalLineMapper;
import datablocks.dlm.mapper.PiiApprovalStepMapper;
import datablocks.dlm.mapper.PiiApprovalUserMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.apache.ibatis.annotations.Param;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiApprovalStepServiceImpl implements PiiApprovalStepService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalStepServiceImpl.class);

	private PiiApprovalLineMapper approvalLineMapper;
	private PiiApprovalUserMapper approvalUserMapper;
	private PiiApprovalStepMapper mapper;


	@Override
	public List<PiiApprovalStepVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiApprovalStepVO> getListByaAprvlineid(String aprvlineid) {

		LogUtil.log("INFO", "getListByaAprvlineid: " );

		return mapper.getListByaAprvlineid(aprvlineid);
	}
	@Override
	public List<PiiApprovalStepUserVO> getStepUserListByaAprvlineid(String aprvlineid) {

		LogUtil.log("INFO", "getStepUserListByaAprvlineid: " );

		return mapper.getStepUserListByaAprvlineid(aprvlineid);
	}

	@Override
	public List<PiiApprovalStepVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiApprovalStepVO appapprovalstep) {

		 LogUtil.log("INFO", "register......" + appapprovalstep);

//		 mapper.insert(appapprovalstep);
		 mapper.insertSelectKey(appapprovalstep);
	}

	@Override
	@Transactional
	public boolean remove(String aprvlineid, String seq) {
		
		LogUtil.log("INFO", "remove...." + aprvlineid+" "+seq);
		 
		return mapper.delete(aprvlineid, seq) == 1;
	}
	@Override
	@Transactional
	public boolean removeByLine(String aprvlineid) {

		LogUtil.log("INFO", "removeByLine...." + aprvlineid);

		mapper.deleteByLine(aprvlineid);
		return true;
	}

	@Override
	@Transactional
	public boolean saveAllStep(List<PiiApprovalStepUserVO> steplist) {

		LogUtil.log("INFO", "saveAllStep...." + steplist);

		boolean okflag = false;
		PiiApprovalLineVO lineVo = null;
		PiiApprovalStepVO piiapprovalstep = new PiiApprovalStepVO();
		PiiApprovalUserVO piiapprovaluser = new PiiApprovalUserVO();
		for (PiiApprovalStepUserVO stepUserVO : steplist) {
			lineVo = approvalLineMapper.read(stepUserVO.getAprvlineid());
			break;
		}

		mapper.deleteByLine(lineVo.getAprvlineid());
		approvalUserMapper.deleteByAprvlineid(lineVo.getAprvlineid());
		for (PiiApprovalStepUserVO stepuser : steplist) {

			piiapprovalstep.setAprvlineid(stepuser.getAprvlineid());
			piiapprovalstep.setSeq(stepuser.getSeq());
			piiapprovalstep.setStepname(stepuser.getStepname());
			piiapprovalstep.setApprovalid(stepuser.getApprovalid());
			piiapprovalstep.setApprovalname(stepuser.getApprovalname());

			piiapprovaluser.setAprvlineid(stepuser.getAprvlineid());
			piiapprovaluser.setSeq(stepuser.getSeq());
			piiapprovaluser.setStepname(stepuser.getStepname());
			piiapprovaluser.setApproverid(stepuser.getApproverid());
			piiapprovaluser.setApprovername(stepuser.getApprovername());

			mapper.insert(piiapprovalstep);
			approvalUserMapper.insert(piiapprovaluser);
		}

		return true;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiApprovalStepVO get(String aprvlineid, String seq) {
		
		 LogUtil.log("INFO", "get......" + aprvlineid);
		 
		 return mapper.read(aprvlineid, seq);
	}
	@Override
	public PiiApprovalStepVO getNextStep(String aprvlineid, String seq) {

		 LogUtil.log("INFO", "getNextStep......" + aprvlineid);

		 return mapper.readNextStep(aprvlineid, seq);
	}
	@Override
	public int getNextStepCount(String aprvlineid, String seq) {

		 LogUtil.log("INFO", "getNextStepCount......" + aprvlineid);

		 return mapper.readNextStepCount(aprvlineid, seq);
	}

	@Override
	@Transactional
	public boolean modify(PiiApprovalStepVO appapprovalstep) {
		
		LogUtil.log("INFO", "modify......" + appapprovalstep);
		
		return mapper.update(appapprovalstep) == 1;
	}
	@Override
	@Transactional
	public boolean modifySeq(PiiApprovalStepVO piiapprovalstep) {

		LogUtil.log("INFO", "modify......" + piiapprovalstep);

		return mapper.updateSeq(piiapprovalstep) == 1;
	}

}
