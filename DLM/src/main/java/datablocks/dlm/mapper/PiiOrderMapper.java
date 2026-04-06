package datablocks.dlm.mapper;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiOrderMapper {

   //@Select("select * from piiorder")
	public List<PiiOrderVO> getList();

	public List<PiiOrderVO> getRunableList();
	
	public List<PiiOrderVO> getListWithPaging(Criteria cri);
	public List<PiiOrderVO> getListWithPagingDetail(Criteria cri);
	public List<PiiOrderVO> getRestorableList(@Param("custid") String custid);
	public List<PiiStepVO> getRestoreStepArcList(@Param("custid") String custid);

	public void insert(PiiOrderVO PiiOrder);

	public void insertSelectKey(PiiOrderVO PiiOrder);

	public PiiOrderVO read(@Param("orderid") int orderid);
	public PiiOrderVO readMaxOrderOkByJobid(@Param("jobid") String jobid);
	public PiiOrderRunRusultStatVO readrunresultstat();

	public int delete(int orderid);
	
	public int updatebefore(int orderid);
	public int updateend(int orderid);
	public int update(PiiOrderVO PiiOrder);
	public int updateactionflag(PiiOrderVO PiiOrder);
	public int updatestatus(@Param("orderid") int orderid, @Param("status") String status);
	
	public int rerun(@Param("orderid") int orderid);
	
	public int getTotalCount(Criteria cri);
	public int getMaxOrderid();
	public int getRunableListCnt();
	public int getAutoGenTestdataRunningCnt();
	public int getTestdataPurgeRunningCnt();
	public int getRestoreRunningCnt();
	public int getRecoveredCntWithJobidBasedate(@Param("jobid") String jobid, @Param("basedate") String basedate );
	public int getSameOrderCnt(@Param("jobid") String jobid, @Param("version") String version, @Param("basedate") String basedate );
	public int getSteptypeCnt(@Param("orderid") int orderid, @Param("steptype") String steptype );
	public List<PiiOrderJobVO> getOrderJobList();
	public int deleteCompletedNonPiiOrders(@Param("cutoffDate") java.util.Date cutoffDate);
}
