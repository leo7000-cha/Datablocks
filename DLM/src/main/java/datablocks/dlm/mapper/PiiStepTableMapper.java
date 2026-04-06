package datablocks.dlm.mapper;

import java.util.List;
import java.util.Map;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiStepTableMapper {

   //@Select("select * from piisteptable")
	public List<PiiStepTableVO> getList();
	
	public List<PiiStepTableVO> getJobTableList(@Param("jobid") String jobid,@Param("version") String version);
	public List<PiiStepTableVO> getJobStepTableList(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	public List<PiiStepTableVO> getStepTableList(Criteria cri);
	public List<PiiStepTableVO> getExeStepTableList(Criteria cri);
	public List<PiiStepTableVO> getArcStepTableList();
	public List<PiiConfKeymapRefVO> getList_Keymap(@Param("jobid") String jobid,@Param("version") String version);
	public List<PiiStepTableVO> getListWithPaging(Criteria cri);
	public List<PiiStepTableWithWaitVO> getListWithPagingWithWait(Criteria cri);

	public void insert(PiiStepTableVO PiiStepTable);

	public void insertSelectKey(PiiStepTableVO PiiStepTable);

	public void checkout(@Param("jobid") String jobid,@Param("version") String version);
	
	//public PiiStepTableVO read(PiiStepTableVO PiiStepTable);
	public PiiStepTableVO read(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name);
	public PiiStepTableVO readEtc(@Param("jobid") String jobid ,@Param("stepid") String stepid);
	public int readEtcCnt(@Param("jobid") String jobid ,@Param("stepid") String stepid);
	public PiiStepTableVO readWithSeq(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int readWithSeqExetype(@Param("jobid") String jobid,@Param("version") String version,@Param("exetype") String exetype,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);


	public int delete(PiiStepTableVO PiiStepTable);
	public int deleteBySeq(PiiStepTableVO PiiStepTable);
	public int deleteStepTable(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	public int deleteJobTable(@Param("jobid") String jobid,@Param("version") String version);
	
	public int update(PiiStepTablePkNewVO PiiStepTable);
	public int updateKeymapId(PiiJobVO piijob);
	public int updateArchiveFromDel(PiiStepTablePkNewVO PiiStepTable);
	public int getExistSameTableCnt(@Param("jobid") String jobid,@Param("version") String version,@Param("db") String db,@Param("owner") String owner,@Param("table_name") String table_name, @Param("exetype") String exetype);

	public int getTotalDistinctTabCount();
	public int getTotalCount(Criteria cri);
	public int getTotalCountExeStepTable(Criteria cri);
	public int getTotalTabCnt(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	public PiiStepMaxSeqVO getStepMaxseq(@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid);
	public List<PiiStepTableCntVO> getTotalTabCntWithExetype();
	public List<PiiTableConfigStatusVO> getTableConfigStatus();
	public Map<String, String> getTDUpdateWhereClauseData(
			@Param("jobid") String jobid,
			@Param("version") String version,
			@Param("stepid") String stepid,
			@Param("owner") String owner,
			@Param("table_name") String table_name);
}
