package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.PiiExtractMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiExtractServiceImpl implements PiiExtractService {
	private static final Logger logger = LoggerFactory.getLogger(PiiExtractServiceImpl.class);
	@Autowired
	private PiiExtractMapper mapper;

	@Override
	public PiiExtractVO getBySsnToRestore(String ssn, String valtype) {
		
		LogUtil.log("INFO", "getBySsnToRestore: " + ssn +", "+ valtype);
		
		return mapper.readBySsnToRestore(ssn, valtype);
	}
	@Override
	public PiiExtractVO getByCustidToRestore(String ssn) {

		LogUtil.log("INFO", "getByCustidToRestore: " + ssn);

		return mapper.readByCustidToRestore(ssn);
	}
	@Override
	public PiiExtractVO getByCustidOrderid(String custid, int orderid) {

		LogUtil.log("INFO", "getByCustidOrderid: " + custid +" , "+orderid);

		return mapper.readByCustidOrderid(custid, orderid);
	}
	@Override
	public int getCountBySsnToRestore(String ssn, String valtype) {

		LogUtil.log("INFO", "getCountBySsnToRestore: " + ssn +" ,"+ valtype);

		return mapper.readCountBySsnToRestore(ssn, valtype);
	}
	@Override
	public int getCountByCustidToRestore(String ssn) {

		LogUtil.log("INFO", "getCountByCustidToRestore: " + ssn);

		return mapper.readCountByCustidToRestore(ssn);
	}
	@Override
	public List<PiiExtractVO> getList(Criteria cri) {

		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiCustStatVO> getCustStatList(Criteria cri) {
		
		LogUtil.log("INFO", "getCustStatList with criteria: " + cri);
		
		return mapper.getCustStatListWithPaging(cri);
	}
	@Override
	public List<PiiCustStatVO> getCustStatListDaily(Criteria cri) {

		LogUtil.log("INFO", "getCustStatListDaily with criteria: " + cri);

		return mapper.getCustStatListDaily(cri);
	}
	@Override
	public List<PiiCustStatVO> getCustStatListMonthly(Criteria cri) {

		LogUtil.log("INFO", "getCustStatListMonthly with criteria: " + cri);

		return mapper.getCustStatListMonthly(cri);
	}
	@Override
	public List<PiiCustStatConsentVO> getCustStatList_consent(Criteria cri) {

		LogUtil.log("INFO", "getCustStatList with criteria: " + cri);

		return mapper.getCustStatListWithPaging_consent(cri);
	}

	@Override
	public PiiExtractRunRusultYearStatVO getRunExtractResultSumStat() { // 누적 테이터를 표현해서 이것만 쓰임
		
		LogUtil.log("INFO", "getRunExtractResultSumStat......" );
		
		return mapper.getRunExtractResultSumStat();
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getCustStatTotal(Criteria cri) {
		
		LogUtil.log("INFO", "getCustStatTotal total count");
		return mapper.getCustStatTotalCount(cri);
	}
	@Override
	public int getCustStatTotal_consent(Criteria cri) {

		LogUtil.log("INFO", "getCustStatTotal total count");
		return mapper.getCustStatTotalCount_consent(cri);
	}

	
	
}
