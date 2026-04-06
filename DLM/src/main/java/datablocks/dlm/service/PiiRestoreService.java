package datablocks.dlm.service;

import java.security.Principal;
import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiRestoreService {

	public String register(List<PiiRestoreVO> restorelist, Principal principal, String reqreason, String aprvlineid, String applytype);
	public PiiApprovalReqVO registerFromPlatform(PiiExtractVO extractVO, String reqreason, String aprvlineid, String applytype, int stepcnt, String requserid, String requsernam);
	public PiiRestoreVO get(int restoreid);

	public boolean modify(PiiRestoreVO PiiRestore);
	public boolean modifyApprovalInfo(PiiRestoreVO PiiRestore);
	public boolean modifyStatus(int orderid);
	public int modifyExtractBrowseStatus();

	public boolean requestapproval(int restoreid);
	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean reject(PiiApprovalReqVO approvalreqVO);

	public boolean remove(int restoreid);

	public List<PiiRestoreVO> getList();
	public List<PiiCustidVO> getArcCustBrowseList(String applicant);
	public List<PiiRestoreVO> getList(Criteria cri);
	public List<PiiActOrderVO> getActOrderList(Criteria cri);

	public int getTotal(Criteria cri);
	public int getActOrderListTotal(Criteria cri);
	public int getMaxRestoreid();

	public String checkin(PiiApprovalReqVO approvalreq, Principal principal, String aprvlineid, String applytype);
	public PiiApprovalReqVO checkinFromPlatform(PiiApprovalReqVO approvalreq, String aprvlineid,  String applytype, int stepcnt, String requserid, String requsernam);
	public boolean updateRestoreCustStatus(int orderid, String custid, String status);
	public PiiOrderVO orderRestoreJob(PiiRestoreVO piirestore, String reqFrom);
}
