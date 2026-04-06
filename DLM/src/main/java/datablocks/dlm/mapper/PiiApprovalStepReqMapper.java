package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalStepReqVO;
import datablocks.dlm.domain.PiiApprovalUserVO;
import datablocks.dlm.domain.PiiApprovalVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiApprovalStepReqMapper {

	// @Select("select * from PIICONFKEYMAP)
	public List<PiiApprovalStepReqVO> getList();
		
	public List<PiiApprovalStepReqVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalStepReqVO piiapprovalstepreq);

	public PiiApprovalStepReqVO read(@Param("reqid") String reqid);

	public int delete(@Param("reqid") String reqid);
	
	public int update(PiiApprovalStepReqVO piiapprovalstepreq);

	public int getTotalCount(Criteria cri);
	
	public int approve(PiiApprovalStepReqVO approvalreqVO);
	public int reject(PiiApprovalStepReqVO approvalreqVO);

}
