package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import datablocks.dlm.domain.PiiApprovalUserVO;
import org.apache.ibatis.annotations.Param;

public interface PiiApprovalUserMapper {

	public List<PiiApprovalUserVO> getList();
	public List<PiiApprovalUserVO> getListByAprvlineid(@Param("aprvlineid") String aprvlineid);

	public List<PiiApprovalUserVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalUserVO approvaluser);

	public void insertSelectKey(PiiApprovalUserVO approvaluser);

	public PiiApprovalUserVO read(@Param("aprvlineid") String aprvlineid ,@Param("seq")  String seq);
	public List<PiiTwoStringVO> readAllUser(@Param("approvalid") String approvalid);

	public int delete(@Param("aprvlineid") String aprvlineid ,@Param("seq")  String seq);
	public int deleteByStep(@Param("aprvlineid") String aprvlineid ,@Param("seq")  String seq);
	public int deleteByAprvlineid(@Param("aprvlineid") String aprvlineid );
	public int update(PiiApprovalUserVO approvaluser);

	public int getTotalCount(Criteria cri);

}
