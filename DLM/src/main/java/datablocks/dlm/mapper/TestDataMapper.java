package datablocks.dlm.mapper;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface TestDataMapper {

	public List<TestDataVO> getList();
	public List<TestDataVO> getDisposalList(@Param("basedate") String basedate);
	public List<TestDataVO> getListWithPaging(Criteria cri);
	public void insert(TestDataVO TestData);
	public void insertSelectKey(TestDataVO TestData);
	public int requestapproval(@Param("testdataid") int testdataid);
	public int reject(@Param("testdataid") int testdataid);
	public int approve(@Param("testdataid") int testdataid);
	public TestDataVO read(@Param("testdataid") int testdataid);
	public int delete(@Param("testdataid") int testdataid);
	public int update(TestDataVO TestData);
	public int updateApprovalInfo(TestDataVO TestData);
	public int updateDisposalStatus(@Param("testdataid") int testdataid);
	int updateDisposalScheDate(UpdateDisposalScheDateVO dto);

	public int updateStatus(@Param("new_orderid") int new_orderid);
	public int getTotalCount(Criteria cri);
	public int getMaxTestdataid();
	public List<MasterKeymapVO> getListMasterKeymap(@Param("new_orderid") int new_orderid);
	public int deleteMasterKeymapByOrderId(@Param("orderid") int orderid);
	List<TestDataCombinedStatusVO> getCombinedTestDataStatus(
			@Param("startDate") String startDate,
			@Param("endDate") String endDate
	);

}
