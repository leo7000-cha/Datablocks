package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.Criteria;
//import org.apache.ibatis.annotations.Select;
import datablocks.dlm.domain.PiiConfTableVO;
import org.apache.ibatis.annotations.Param;

public interface PiiConfTableMapper {

	// @Select("select * from PIICONFKEYMAP)
	public List<PiiConfTableVO> getList();
	
	public List<PiiConfTableVO> getListWithPaging(Criteria cri);

	public void insert(PiiConfTableVO piiConfTable);

	//public PiiConfTableVO read(PiiConfTableVO piiConfTable);
	public PiiConfTableVO read(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name);

	public int delete(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name);
	
	public int update(PiiConfTableVO piiConfTable);
	
	public int getTotalCount(Criteria cri);

}
