package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiApprovalMapper {

	//@Select("select * from approval")
	public List<PiiApprovalVO> getList();

	public List<PiiApprovalVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalVO approval);

	public void insertSelectKey(PiiApprovalVO approval);

	public PiiApprovalVO read(@Param("approvalid")  String approvalid);

	public int delete(@Param("approvalid")  String approvalid);

	public int update(PiiApprovalVO approval);

	public int getTotalCount(Criteria cri);

}
