package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

public interface PiiExtractMapper {

   //@Select("select * from piistep")

	public PiiExtractVO readBySsnToRestore(@Param("ssn") String ssn, @Param("valtype") String valtype);
	public PiiExtractVO readByCustidToRestore(@Param("ssn") String ssn);
	public PiiExtractVO readByCustidOrderid(@Param("custid") String custid, @Param("orderid") int orderid);
	public int readCountBySsnToRestore(@Param("ssn")String ssn, @Param("valtype") String valtype);
	public int readCountByCustidToRestore(@Param("ssn")String ssn);
	public List<PiiExtractVO> getListWithPaging(Criteria cri);
	public List<PiiCustStatVO> getCustStatListWithPaging(Criteria cri);
	public void delete_piicuststat();
	public void insertCustStatListAllDays();
	public void insertCustStatListAllMonths();
	public void insertCustStatListNotExistDay();
	public List<PiiCustStatVO> getCustStatListDaily(Criteria cri);
	public List<PiiCustStatVO> getCustStatListMonthly(Criteria cri);
	public List<PiiCustStatConsentVO> getCustStatListWithPaging_consent(Criteria cri);


	public void delete_piicuststatyear();
	public void insertextractrunresultyearstat();
	public void insertextractrunresultsumstat();
	public PiiExtractRunRusultYearStatVO getRunExtractResultSumStat();
	public int getTotalCount(Criteria cri);
	public int getCustStatTotalCount(Criteria cri);
	public int getCustStatTotalCount_consent(Criteria cri);

	public void insertPurgeStats(@Param("policyPrefix") String policyPrefix,
								 @Param("excludeReason") String excludeReason,
								 @Param("cutoffDate") java.util.Date cutoffDate);
	public void insertPurgeLog(@Param("policyPrefix") String policyPrefix,
							   @Param("excludeReason") String excludeReason,
							   @Param("cutoffDate") java.util.Date cutoffDate);
	public int deletePurgedRecords(@Param("policyPrefix") String policyPrefix,
								   @Param("excludeReason") String excludeReason,
								   @Param("cutoffDate") java.util.Date cutoffDate);

}
