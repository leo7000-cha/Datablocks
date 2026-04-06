package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfigVO;

public interface PiiConfigMapper {

   
	public List<PiiConfigVO> getList();
	
	public List<PiiConfigVO> getListWithPaging(Criteria cri);

	public void insert(PiiConfigVO config);

	public void insertSelectKey(PiiConfigVO config);

	public PiiConfigVO read(@Param("cfgkey") String cfgkey);

	public int delete(@Param("cfgkey") String cfgkey);
	
	public int update(PiiConfigVO config);
	public int updateVal(@Param("cfgkey") String cfgkey, @Param("value") String value);
	
	public int getTotalCount(Criteria cri);

}
