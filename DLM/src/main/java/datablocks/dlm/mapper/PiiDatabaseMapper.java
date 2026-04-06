package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDatabaseVO;
import org.apache.ibatis.annotations.Param;

public interface PiiDatabaseMapper {

   
	public List<PiiDatabaseVO> getList();

	public List<PiiDatabaseVO> getListWithPaging(Criteria cri);

	public void insert(PiiDatabaseVO PiiDatabase);

	public void insertSelectKey(PiiDatabaseVO PiiDatabase);

	public PiiDatabaseVO read(@Param("db") String db);
	public PiiDatabaseVO readBySystem(@Param("system") String system);

	public int delete(@Param("db") String db);
	
	public int update(PiiDatabaseVO PiiDatabase);
	public int updateWithoutPw(PiiDatabaseVO PiiDatabase);
	
	public int getTotalCount(Criteria cri);

}
