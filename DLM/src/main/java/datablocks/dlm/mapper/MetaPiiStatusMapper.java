package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.MetaTableGapVO;
import datablocks.dlm.domain.MetaPiiStatusVO;
import datablocks.dlm.domain.PiiStepTableTargetVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface MetaPiiStatusMapper {

    public List<MetaPiiStatusVO> getList();
    public List<MetaPiiStatusVO> getListByDb();

    public void insert();
    public MetaPiiStatusVO read(@Param("system_name") String system_name
            , @Param("db") String db
            , @Param("owner") String owner);

    public int delete();
    public int update(MetaPiiStatusVO metatable);

}
