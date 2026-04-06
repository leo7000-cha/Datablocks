package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalStepUserVO;
import datablocks.dlm.domain.PiiApprovalStepVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiApprovalStepMapper {

	//@Select("select * from approvalstep")
	public List<PiiApprovalStepVO> getList();
	public List<PiiApprovalStepVO> getListByaAprvlineid(@Param("aprvlineid") String aprvlineid);
	public List<PiiApprovalStepUserVO> getStepUserListByaAprvlineid(@Param("aprvlineid") String aprvlineid);

	public List<PiiApprovalStepVO> getListWithPaging(Criteria cri);

	public void insert(PiiApprovalStepVO approvalstep);

	public void insertSelectKey(PiiApprovalStepVO approvalstep);

	public PiiApprovalStepVO read(@Param("aprvlineid") String aprvlineid,@Param("seq")  String seq);
	public PiiApprovalStepVO readNextStep(@Param("aprvlineid") String aprvlineid,@Param("seq")  String seq);
	public int readNextStepCount(@Param("aprvlineid") String aprvlineid,@Param("seq")  String seq);

	public int delete(@Param("aprvlineid") String aprvlineid,@Param("seq")  String seq);
	public int deleteByLine(@Param("aprvlineid") String aprvlineid);

	public int update(PiiApprovalStepVO approvalstep);
	public int updateSeq(PiiApprovalStepVO approvalstep);

	public int getTotalCount(Criteria cri);

}
