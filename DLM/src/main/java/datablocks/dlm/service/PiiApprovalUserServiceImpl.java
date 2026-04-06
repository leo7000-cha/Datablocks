package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.domain.PiiApprovalUserVO;
import datablocks.dlm.mapper.PiiApprovalUserMapper;
import datablocks.dlm.mapper.PiiApprovalUserMapper;
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
public class PiiApprovalUserServiceImpl implements PiiApprovalUserService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalUserServiceImpl.class);
	@Autowired
	private PiiApprovalUserMapper mapper;


	@Override
	public List<PiiApprovalUserVO> getList() {

		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiApprovalUserVO> getListByAprvlineid(String aprvlineid) {

		LogUtil.log("INFO", "getListByAprvlineid: " );

		return mapper.getListByAprvlineid(aprvlineid);
	}

	@Override
	public List<PiiApprovalUserVO> getList(Criteria cri) {

		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	public void register(PiiApprovalUserVO appapprovaluser) {

		LogUtil.log("INFO", "register......" + appapprovaluser);

//		 mapper.insert(appapprovaluser); 
		mapper.insertSelectKey(appapprovaluser);
	}

	@Override
	public boolean remove(String aprvlineid, String seq) {

		LogUtil.log("INFO", "remove...." + aprvlineid+" "+seq);

		return mapper.delete(aprvlineid, seq) == 1;
	}

	@Override
	public boolean removeByStep(String aprvlineid, String seq) {

		LogUtil.log("INFO", "removeByStep...." + aprvlineid+" "+seq);

		mapper.deleteByStep(aprvlineid, seq);

		return true;
	}
	@Override
	public boolean deleteByAprvlineid(String aprvlineid) {

		LogUtil.log("INFO", "deleteByAprvlineid...." + aprvlineid);

		mapper.deleteByAprvlineid(aprvlineid);

		return true;
	}

	@Override
	public int getTotal(Criteria cri) {

		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiApprovalUserVO get(String aprvlineid, String seq) {

		LogUtil.log("INFO", "get......" + aprvlineid+" "+seq);

		return mapper.read(aprvlineid, seq);
	}
	@Override
	public List<PiiTwoStringVO> getAllUser(String approvalid) {

		LogUtil.log("INFO", "getAllUser......"+approvalid);

		return mapper.readAllUser(approvalid);
	}

	@Override
	public boolean modify(PiiApprovalUserVO appapprovaluser) {

		LogUtil.log("INFO", "modify......" + appapprovaluser);

		return mapper.update(appapprovaluser) == 1;
	}

}
