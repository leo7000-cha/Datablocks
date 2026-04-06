package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalReqVO;
import datablocks.dlm.domain.PiiReportVO;

import java.security.Principal;
import java.util.List;

public interface PiiReportService {

	public String register(Criteria cri, Principal principal, String reqreason, String aprvlineid, String applytype);

	public PiiReportVO get(String reportid);

	public boolean modify(PiiReportVO piireport);

	public boolean remove(String reportid);

	public List<PiiReportVO> getList();

	public List<PiiReportVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public int getMaxReportid();

	public boolean requestapproval(int reportid);
	public boolean approve(PiiApprovalReqVO approvalreqVO);
	public boolean reject(PiiApprovalReqVO approvalreqVO);



}