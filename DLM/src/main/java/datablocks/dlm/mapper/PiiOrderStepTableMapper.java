package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.PiiArcTableVO;
import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiOrderReportVO;
import datablocks.dlm.domain.PiiOrderStepTableVO;

public interface PiiOrderStepTableMapper {

   //@Select("select * from piiorder")
	public List<PiiOrderStepTableVO> getList();
	public List<PiiArcTableVO> getArcTableList();
	public List<PiiOrderStepTableVO> getStepTableList(@Param("orderid") int orderid, @Param("stepid") String stepid);
	public List<PiiOrderStepTableVO> getStepTableListasc(@Param("orderid") int orderid, @Param("stepid") String stepid);
	public List<PiiOrderStepTableVO> getStepTableList_keymap(@Param("orderid") int orderid, @Param("stepid") String stepid);
	public List<PiiOrderStepTableVO> getRunnableStepTableList(@Param("orderid") int orderid, @Param("stepid") String stepid);
	public int getWaitTableList(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("db") String db, @Param("owner") String owner, @Param("table_name") String table_name);

	public List<PiiOrderStepTableVO> getListWithPaging(Criteria cri);
	public List<PiiOrderReportVO> getOrderReportList(Criteria cri);
	
	public void insert(PiiOrderStepTableVO piiordersteptable);

	public void insertSelectKey(PiiOrderStepTableVO piiordersteptable);

	public PiiOrderStepTableVO read(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("db") String db, @Param("owner") String owner, @Param("table_name") String table_name);
	public PiiOrderStepTableVO readWithSeq(@Param("orderid") int orderid, @Param("stepid") String stepid,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int readArchiveCntWithSeq(@Param("orderid") int orderid, @Param("exetype") String exetype,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int readArchiveRowCntWithSeq(@Param("orderid") int orderid, @Param("exetype") String exetype,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int readCntBeforeAsc(@Param("orderid") int orderid,@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int readCntBeforeDesc(@Param("orderid") int orderid,@Param("jobid") String jobid,@Param("version") String version,@Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	
	public int deletebyorderid(@Param("orderid") int orderid);
	public int delete(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int updateOrderDetail(PiiOrderStepTableVO piiordersteptable);
	public int updatebefore(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	public int updateend(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("status") String status, @Param("execnt") long execnt, @Param("sqlmsg") String sqlmsg);
	public int updateendBySteptype(@Param("orderid") int orderid,@Param("jobid") String jobid, @Param("version") String version, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("status") String status, @Param("execnt") long execnt, @Param("sqlmsg") String sqlmsg);
	public int updatecnt(@Param("orderid") int orderid, @Param("stepid") String stepid, @Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3, @Param("execnt") long execnt);
	
	public int update(PiiOrderStepTableVO piiordersteptable);
	public int updateactionflag(PiiOrderStepTableVO piiordersteptable);
	public int rerun(@Param("orderid") int orderid);
	public int getRestoreTableNotCompleteCount(@Param("orderid") int orderid);
	public List<PiiOrderStepTableVO> getListInMigrateStep(@Param("orderid") int orderid);

	public int getTotalCount(Criteria cri);
	public int getTotalReportCount(Criteria cri);

}
