package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalLineVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiApprovalLineMapper {

	//@Select("select * from approvalline")
	public List<PiiApprovalLineVO> getList();
	public List<PiiApprovalLineVO> getListbyApprovalid(@Param("approvalid") String approvalid);

	public List<PiiApprovalLineVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalLineVO approvalline);

	public void insertSelectKey(PiiApprovalLineVO approvalline);

	public PiiApprovalLineVO read(@Param("aprvlineid") String aprvlineid);

	public int delete(@Param("aprvlineid") String aprvlineid);

	public int update(PiiApprovalLineVO approvalline);

	public int getTotalCount(Criteria cri);

}
