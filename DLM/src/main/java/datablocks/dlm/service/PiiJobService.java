package datablocks.dlm.service;

import java.security.Principal;
import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiJobVO;
import datablocks.dlm.domain.PiiKeymapPkVO;

public interface PiiJobService {

	public void register(PiiJobVO piijob, String db);
	public void copy(PiiJobVO piijob ,String jobid, String version);
	public void copyBackdated(PiiJobVO piijob ,String jobid, String version);
	public void copyRecovery(PiiJobVO piijob ,String jobid, String version);

	public PiiJobVO get(String jobid, String version);

	public boolean modify(PiiJobVO piijob);
	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean reject(PiiApprovalReqVO approvalreqVO);

	public boolean remove(String jobid, String version);

	public List<PiiJobVO> getList();
	public List<PiiJobVO> getTestdataAutoGenList();
	public List<PiiJobVO> getAllVersionList(String jobid);
	public List<PiiKeymapPkVO> getKeymapList();

	public List<PiiJobVO> getActiveList(Criteria cri);
	public List<PiiJobVO> getExeJobList(String basedate);
	public List<PiiJobVO> getList(Criteria cri);
	
	public void checkout(String jobid, String version);
	
	public String checkin(PiiApprovalReqVO approvalreq, Principal principal);
	//추가
	public int getTotal(Criteria cri);
	public int getPiiTotalCount();
	public int getMaxVersionByJob(String jobid);
	public int getMaxVersionCheckinByJob(String jobid);

}