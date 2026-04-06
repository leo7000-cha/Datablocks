package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

//import org.apache.ibatis.annotations.Select;
import datablocks.dlm.domain.PiiApprovalReqVO;

public interface PiiApprovalReqMapper {

	// @Select("select * from PIICONFKEYMAP)
	public List<PiiApprovalReqVO> getList();
		
	public List<PiiApprovalReqWithApproverVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalReqVO piiApprovalReq);

	//public PiiApprovalReqVO read(PiiApprovalReqVO piiApprovalReq);
	public PiiApprovalReqVO read(@Param("reqid") String reqid);
	public PiiApprovalReqVO getLastApprovalReq(@Param("approvalid") String approvalid, @Param("requesterid") String requesterid);
	public PiiApprovalUserVO getSameDeptApprovalUser(@Param("approvalid") String approvalid, @Param("deptid") String deptid);
	public PiiApprovalVO readapproval(@Param("approvalid") String approvalid);
	public PiiApprovalUserVO readapprovaluser(@Param("approvalid") String approvalid);

	public int delete(@Param("reqid") String reqid);
	
	public int update(PiiApprovalReqVO piiApprovalReq);
	public int updateApprover(PiiApprovalReqVO piiApprovalReq);

	public int getTotalCount(Criteria cri);
	public int getMaxReqid();
	
	public int approve(PiiApprovalReqVO approvalreqVO);
	public int reject(PiiApprovalReqVO approvalreqVO);

	public int hasSameDeptApproverInLine(@Param("aprvlineid") String aprvlineid, @Param("deptid") String deptid);

}
