package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiOrderService {

	public void register(PiiOrderVO piiorder);

	public PiiOrderVO get(int orderid) ;
	public PiiOrderVO getMaxOrderOkByJobid(String jobid) ;
	public PiiOrderRunRusultStatVO getRunResultStat() ;

	public boolean modify(PiiOrderVO piiorder);
	public boolean updateactionflag(PiiOrderVO piiorder);
	public boolean updatebefore(int orderid);
	public boolean updateend(int orderid);
	public boolean updatestatus(int orderid, String status);
	public boolean rerun(int orderid);

	public boolean remove(int orderid) ;

	public List<PiiOrderVO> getList();
	public List<PiiOrderVO> getRunableList();
	public List<PiiOrderVO> getRestorableList(String custid);
	public List<PiiStepVO> getRestoreStepArcList(String custid);
	public List<PiiOrderVO> getList(Criteria cri);

	public List<PiiOrderVO> getListDetail(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public int getMaxOrderid();
	public int getRunableListCnt();
	public int getRecoveredCntWithJobidBasedate(String jobid,String basedate);
	public int getSameOrderCnt(String jobid, String version, String basedate);
	public int getSteptypeCnt(int orderid, String steptype);
	public List<PiiOrderJobVO> getOrderJobList();

	public int orderOneJob(String jobid, String version, String basedate, String rundate);
	public void orderArcdelJob(String jobid, String version, String basedate, String rundate);

}