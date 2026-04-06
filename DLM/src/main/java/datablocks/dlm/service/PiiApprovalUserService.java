package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;
import datablocks.dlm.domain.PiiApprovalUserVO;
import org.apache.ibatis.annotations.Param;

public interface PiiApprovalUserService {

	public void register(PiiApprovalUserVO piiapprovaluser);

	public PiiApprovalUserVO get(String aprvlineid, String seq);
	public List<PiiTwoStringVO> getAllUser(String approvalid);

	public boolean modify(PiiApprovalUserVO piiapprovaluser);

	public boolean remove(String aprvlineid, String seq);
	public boolean removeByStep(String aprvlineid, String seq);
	public boolean deleteByAprvlineid(String aprvlineid);

	public List<PiiApprovalUserVO> getList();
	public List<PiiApprovalUserVO> getListByAprvlineid(String aprvlineid);
	public List<PiiApprovalUserVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);

}