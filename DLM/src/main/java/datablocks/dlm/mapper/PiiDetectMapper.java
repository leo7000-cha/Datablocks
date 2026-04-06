package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDetectConfigVO;
import datablocks.dlm.domain.PiiDetectResultVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiDetectMapper {

   
	public List<PiiDetectConfigVO> getList();
	
	public List<PiiDetectConfigVO> getListWithPaging(Criteria cri);

	public void insert(PiiDetectConfigVO config);

	public void insertSelectKey(PiiDetectConfigVO config);

	public PiiDetectConfigVO read(@Param("conf_id") String conf_id);

	public int delete(@Param("conf_id") String conf_id);
	
	public int update(PiiDetectConfigVO config);
	
	public int getTotalCount(Criteria cri);

	public List<PiiDetectResultVO> getListResultWithPaging(Criteria cri);
	public int getResultTotalCount(Criteria cri);

}
