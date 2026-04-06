package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiPolicyVO;

public interface PiiPolicyMapper {

	public List<PiiPolicyVO> getList();
	
	public List<PiiPolicyVO> getListWithPaging(Criteria cri);

	public void insert(PiiPolicyVO PiiPolicy);

	public void insertSelectKey(PiiPolicyVO PiiPolicy);

	public PiiPolicyVO read(@Param("policy_id") String policy_id, @Param("version") String version);
	public PiiPolicyVO readCurrent(@Param("policy_id") String policy_id);

	public int delete(String policy_id,@Param("version") String version);
	
	public int update(PiiPolicyVO PiiPolicy);
	
	public int getTotalCount(Criteria cri);
	public void checkout(@Param("policy_id") String policy_id,@Param("version") String version);
	public void checkin(@Param("policy_id") String policy_id,@Param("version") String version);
	public int reject(PiiApprovalReqVO approvalreqVO);
	public int approve(PiiApprovalReqVO approvalreqVO);
	public int setold(PiiApprovalReqVO approvalreqVO);
	
	public List<PiiPolicyVO> getAllVersionList(@Param("policy_id") String policy_id);
	public int getMaxVersionByPolicy(@Param("policy_id") String policy_id);
}
