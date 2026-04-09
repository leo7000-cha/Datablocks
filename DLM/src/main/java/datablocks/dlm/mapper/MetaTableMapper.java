package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.MetaTableGapVO;
import datablocks.dlm.domain.MetaTableVO;
import datablocks.dlm.domain.PiiStepTableTargetVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface MetaTableMapper {

    //@Select("select * from metatable")
    public List<MetaTableVO> getList();

    public List<MetaTableVO> getListWithPaging(Criteria cri);
    public List<MetaTableVO> getListForOneTable(Criteria cri);
    public List<MetaTableGapVO> getListWithPaging_GapVO(Criteria cri);

    public void insert(MetaTableVO metatable);
    public void insertSelectKey(MetaTableVO metatable);

    //public MetaTableVO read(MetaTableVO MetaTable);
    public MetaTableVO read(@Param("db") String db
            , @Param("owner") String owner
            , @Param("table_name") String table_name
            , @Param("column_name") String column_name);

    public List<MetaTableVO> getListOneTable(@Param("db") String db
            , @Param("owner") String owner
            , @Param("table_name") String table_name);
    public List<MetaTableVO> getListOneTableScramble(@Param("db") String db
            , @Param("owner") String owner
            , @Param("table_name") String table_name);
    public List<PiiStepTableTargetVO> getListEntireTableToScramble(@Param("jobid") String jobid
            , @Param("version") String version, @Param("stepid") String stepid);

    public int delete(MetaTableVO metatable);

    public int update(MetaTableVO metatable);
    public int piiupdate(MetaTableVO metatable);
    public int vefifyupdate(MetaTableVO metatable);
    public int getTotalCount(Criteria cri);
    public int getTotalCount_GapVO(Criteria cri);

    public java.util.Map<String, Object> getStats();

    public java.util.List<java.util.Map<String, Object>> getDistinctDbOwners();

    /** PII 메타데이터 캐시용 — piitype이 설정된 모든 컬럼 조회 */
    public List<MetaTableVO> selectPiiColumnsForCache();

}
