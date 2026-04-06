package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

import java.security.Principal;
import java.util.List;

public interface TestDataService {

	public String register(Principal principal, List<String> custidlist, List<String> custidlistNew, String reqreason, String aprvlineid, String applytype, String system, String sourceDB, String targetDB, String jobid, String idtype);
	public PiiApprovalReqVO registerFromPlatform(List<String> custidlist, String reqreason, String aprvlineid, String applytype, int stepcnt, String requserid, String requsernam, String system, String sourceDB, String targetDB, String jobid, String idtype);
	public TestDataVO get(int testdataid);

	public boolean modify(TestDataVO TestData);
	public boolean modifyApprovalInfo(TestDataVO TestData);
	public boolean modifyStatus(int orderid);
	public boolean modifyDisposalStatus(int testdataid);

	public boolean requestapproval(int testdataid);
	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean reject(PiiApprovalReqVO approvalreqVO);

	public boolean remove(int testdataid);

	public List<TestDataVO> getList();
	public List<TestDataVO> getDisposalList(String basedate);
	/**
	 * 파기 예정일을 업데이트합니다.
	 * @param dto 업데이트할 데이터 정보를 담은 DTO
	 * @return 성공 시 true, 실패 시 false 또는 영향을 받은 행의 수(int)
	 */
	boolean updateDisposalSchedule(UpdateDisposalScheDateVO dto);
	public List<TestDataVO> getList(Criteria cri);

	public int getTotal(Criteria cri);
	public int getMaxTestdataid();

	public String checkin(PiiApprovalReqVO approvalreq, Principal principal, String aprvlineid, String applytype);
	public PiiApprovalReqVO checkinFromPlatform(PiiApprovalReqVO approvalreq, String aprvlineid,  String applytype, int stepcnt, String requserid, String requsernam);

	public PiiOrderVO orderTestdataJob(TestDataVO piitestdata);
	public List<MasterKeymapVO> getListMasterKeymap(int new_orderid);

	public List<TestDataCombinedStatusVO> getTestDataStatus(String startDate, String endDate);
}
