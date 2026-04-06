package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiArcTableVO;
import datablocks.dlm.domain.PiiOrderReportVO;
import datablocks.dlm.domain.PiiOrderStepTableVO;
import org.apache.ibatis.annotations.Param;

public interface PiiOrderStepTableService {

	public void register(PiiOrderStepTableVO piiordersteptable);

	public PiiOrderStepTableVO get(int orderid, String jobid, String version, String stepid,String db,String owner,String table_name) ;
	public PiiOrderStepTableVO getWithSeq(int orderid, String stepid, int seq1, int seq2, int seq3);

	public boolean modifyOrderTableDetail(PiiOrderStepTableVO piiordersteptable);
	public boolean modify(PiiOrderStepTableVO piiordersteptable);
	public boolean updateactionflag(PiiOrderStepTableVO piiordersteptable);

	// Added 20221123
	public boolean updatebefore(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public boolean updateend(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3, String status, long execnt, String sqlmsg);
	public boolean updateendBySteptype(int orderid, String jobid, String version,  int seq1, int seq2, int seq3, String status, long execnt, String sqlmsg);
	public boolean deletebyorderid(int orderid) ;
	public boolean updatecnt(int orderid, String stepid, int seq1, int seq2, int seq3, long execnt);
	public int readArchiveCntWithSeq(int orderid, String exetype, int seq1, int seq2, int seq3);
	public int readArchiveRowCntWithSeq(int orderid, String exetype, int seq1, int seq2, int seq3);
	public int readCntBeforeAsc(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public int readCntBeforeDesc(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public int readWaitTableList(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name);


	public boolean rerun(int orderid);
	public int getRestoreTableNotCompleteCount(int orderid);

	public boolean remove(int orderid, String jobid, String version, String stepid,int seq1, int seq2, int seq3) ;

	public List<PiiOrderStepTableVO> getList();
	public List<PiiArcTableVO> getArcTableList();
	public List<PiiOrderReportVO> getOrderReportList(Criteria cri);
	public List<PiiOrderStepTableVO> getList(Criteria cri);
	public List<PiiOrderStepTableVO> getStepTableList(int orderid, String stepid);
	public List<PiiOrderStepTableVO> getStepTableListasc(int orderid, String stepid);
	public List<PiiOrderStepTableVO> getStepTableList_keymap(int orderid, String stepid);
	public List<PiiOrderStepTableVO> getRunnableStepTableList(int orderid, String stepid);

	//추가PiiOrdeSteprVO.java
	public int getTotal(Criteria cri);
	public int getTotalReportCount(Criteria cri);

}