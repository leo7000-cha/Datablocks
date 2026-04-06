package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.PiiContractMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiContractServiceImpl implements PiiContractService {
	private static final Logger logger = LoggerFactory.getLogger(PiiContractServiceImpl.class);
	@Autowired
	private PiiContractMapper mapper;

	@Override
	public List<PiiContractVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiContractVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiContractStatVO> getStatList(Criteria cri) {

		LogUtil.log("INFO", "getStatList List with criteria: " + cri);

		return mapper.getStatListWithPaging(cri);
	}
	@Override
	public List<PiiContractStatVO> getStatList12Month() {

		LogUtil.log("INFO", "getStatList12Month: " );

		return mapper.getStatList12Month();
	}

	@Override
	@Transactional
	public void register(PiiContractVO contract) {
		
		 LogUtil.log("INFO", "register......" + contract);
		 
		 mapper.insert(contract); 
		 
	}
		 
	@Override
	public boolean remove(String custid, String contractno) {
		
		LogUtil.log("INFO", "remove...." + custid + "  "+contractno);
		 
		return mapper.delete(custid, contractno) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}
	@Override
	public int getStatTotal(Criteria cri) {

		LogUtil.log("INFO", "getStatTotal total count");
		return mapper.getStatTotalCount(cri);
	}

	@Override
	public PiiContractVO get(String custid, String contractno) {
		
		 LogUtil.log("INFO", "get......" + custid + "  "+contractno);
		 
		 return mapper.read(custid, contractno);
	}

	@Override
	@Transactional
	public boolean modify(PiiContractVO contract) {
		
		LogUtil.log("INFO", "modify......" + contract);
		
		return mapper.update(contract) == 1;
	}
	@Override
	@Transactional
	public boolean modifyStatus(PiiContractVO contract) {

		LogUtil.log("INFO", "modifyStatus......" + contract);

		return mapper.updateStatus(contract) == 1;
	}
	@Override
	@Transactional
	public String modifyStatusListAsY(List<PiiContractVO> contractlist, Principal principal) {

		LogUtil.log("INFO", "update(List<PiiContractVO>....."+contractlist.toString() );
		String rst = "success";
		for(PiiContractVO piicontract : contractlist) {
			try {
				piicontract.setStatus("Y");
				piicontract.setReal_doc_del_userid(principal.getName());
				mapper.updateStatus(piicontract);
			} catch (Exception e) {
				logger.warn("warn "+piicontract.toString());
				logger.warn("warn "+"update(PiiContractVO piicontract)=> "+e.getMessage());
				rst = e.getMessage();
				break;
			}
		}
		return rst;

	}

	@Override
	public List<PiiContractVO> getDistinctMgmtDept() {
		LogUtil.log("INFO", "getDistinctMgmtDept");
		return mapper.getDistinctMgmtDept();
	}
}
