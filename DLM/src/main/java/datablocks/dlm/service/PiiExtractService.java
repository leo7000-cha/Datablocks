package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;

public interface PiiExtractService {

	public PiiExtractVO getBySsnToRestore(String ssn, String valtype);
	public PiiExtractVO getByCustidToRestore(String ssn);
	public PiiExtractVO getByCustidOrderid(String custid, int orderid);
	public int getCountBySsnToRestore(String ssn, String valtype);
	public int getCountByCustidToRestore(String ssn);
	public List<PiiExtractVO> getList(Criteria cri);
	public List<PiiCustStatVO> getCustStatList(Criteria cri);
	public List<PiiCustStatVO> getCustStatListDaily(Criteria cri);
	public List<PiiCustStatVO> getCustStatListMonthly(Criteria cri);
	public List<PiiCustStatConsentVO> getCustStatList_consent(Criteria cri);

	public int getTotal(Criteria cri);
	public int getCustStatTotal(Criteria cri);
	public int getCustStatTotal_consent(Criteria cri);

	public PiiExtractRunRusultYearStatVO getRunExtractResultSumStat() ;

}