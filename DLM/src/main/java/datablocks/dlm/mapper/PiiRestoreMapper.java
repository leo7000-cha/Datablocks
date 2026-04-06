package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiRestoreMapper {

	public List<PiiRestoreVO> getList();
	public List<PiiCustidVO> getArcCustBrowseList(@Param("applicant") String applicant);
	public List<PiiRestoreVO> getListWithPaging(Criteria cri);
	public List<PiiActOrderVO> getActOrderList(Criteria cri);

	public void insert(PiiRestoreVO PiiRestore);
	public void insertSelectKey(PiiRestoreVO PiiRestore);

	public int requestapproval(@Param("restoreid") int restoreid);
	public int reject(@Param("restoreid") int restoreid);
	public int approve(@Param("restoreid") int restoreid);

	public PiiRestoreVO read(@Param("restoreid") int restoreid);

	public int delete(@Param("restoreid") int restoreid);
	
	
	public int update(PiiRestoreVO PiiRestore);
	public int updateApprovalInfo(PiiRestoreVO PiiRestore);
	public int updateStatus(@Param("new_orderid") int new_orderid);
	public int updateExtractBrowseStatus();

	public int getTotalCount(Criteria cri);
	public int getActOrderListTotalCount(Criteria cri);
	public int getMaxRestoreid();
	public int updateRestoreCustStatus(@Param("orderid") int orderid, @Param("custid") String custid, @Param("status") String status);

}
