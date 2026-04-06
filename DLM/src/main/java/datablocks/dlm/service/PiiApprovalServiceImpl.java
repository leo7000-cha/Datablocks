package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalVO;
import datablocks.dlm.mapper.PiiApprovalMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiApprovalServiceImpl implements PiiApprovalService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalServiceImpl.class);
	@Autowired
	private PiiApprovalMapper mapper;


	@Override
	public List<PiiApprovalVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}

	@Override
	public List<PiiApprovalVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiApprovalVO appapprovalline) {
		
		 LogUtil.log("INFO", "register......" + appapprovalline);
		 
//		 mapper.insert(appapprovalline); 
		 mapper.insertSelectKey(appapprovalline); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String approvalid) {
		
		LogUtil.log("INFO", "remove...." + approvalid);
		 
		return mapper.delete(approvalid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiApprovalVO get(String approvalid) {
		
		 LogUtil.log("INFO", "get......" + approvalid);
		 
		 return mapper.read(approvalid);
	}

	@Override
	@Transactional
	public boolean modify(PiiApprovalVO appapprovalline) {
		
		LogUtil.log("INFO", "modify......" + appapprovalline);
		
		return mapper.update(appapprovalline) == 1;
	}
	
}
