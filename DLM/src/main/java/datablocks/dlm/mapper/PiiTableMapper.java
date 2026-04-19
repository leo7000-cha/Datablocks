package datablocks.dlm.mapper;

import java.util.List;
import java.util.Map;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

//import org.apache.ibatis.annotations.Select;


public interface PiiTableMapper {

	// @Select("select * from PIICONFKEYMAP)
	public List<PiiTableVO> getList();
		
	public List<PiiTableVO> getListWithPaging(Criteria cri);
	public List<PiiTableVO> getListExact(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name);
	public List<PiiTableNewArcTabVO> getListNewArcTabCols(Criteria cri);
	public List<PiiTableWithMetaVO> getListWithMetaWithPaging(Criteria cri);
	public List<PiiTablePkVO> getTablePkListWithPaging(Criteria cri);

	public List<Map<String, String>> getArchiveTargetOwners();
	public List<PiiLayoutGapVO> getLayoutGapForOwner(@Param("db") String db
			, @Param("srcOwner") String srcOwner
			, @Param("archiveOwner") String archiveOwner);
	public void insert(PiiTableVO piiTable);

	//public PiiTableVO read(PiiTableVO piiTable);
	public PiiTableVO read(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name
			, @Param("column_name") String column_name
			);
	public List<PiiTableVO> readTable(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name
			);
	public int getTableCnt(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name
			);

	public int delete(@Param("db") String db
			, @Param("owner") String owner
			, @Param("table_name") String table_name
			, @Param("column_name") String column_name
			);
	
	public int update(PiiTableVO piiTable);
	
	public int getTotalCount(Criteria cri);
	public int getTotalCountNewArcTab(Criteria cri);
	public int getTotalCountNewArcTabCols(Criteria cri);
	public int getTableTotalCount(Criteria cri);

}
