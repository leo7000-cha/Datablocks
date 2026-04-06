package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ErrorHistVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ErrorHistMapper {

	public List<ErrorHistVO> getList();
	
	public List<ErrorHistVO> getListWithPaging(Criteria cri);

	public void insert(ErrorHistVO errorHist);

	public void insertSelectKey(ErrorHistVO errorHist);

	//public ErrorHistVO read(ErrorHistVO PiiCode);
	public ErrorHistVO read(@Param("id") String id);

	public int delete(@Param("id") String id);
	
	public int update(ErrorHistVO errorHist);
	
	public int getTotalCount(Criteria cri);

}
