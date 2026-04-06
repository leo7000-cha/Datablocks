package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiApprovalLineVO;
import datablocks.dlm.mapper.PiiApprovalLineMapper;
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
public class PiiApprovalLineServiceImpl implements PiiApprovalLineService {
	private static final Logger logger = LoggerFactory.getLogger(PiiApprovalLineServiceImpl.class);
	@Autowired
	private PiiApprovalLineMapper mapper;


	@Override
	public List<PiiApprovalLineVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	@Override
	public List<PiiApprovalLineVO> getListbyApprovalid(String approvalid) {

		LogUtil.log("INFO", "getListbyApprovalid: approvalid=" +approvalid);

		return mapper.getListbyApprovalid(approvalid);
	}

	@Override
	public List<PiiApprovalLineVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiApprovalLineVO appapprovalline) {
		
		 LogUtil.log("INFO", "register......" + appapprovalline);
		 
//		 mapper.insert(appapprovalline); 
		 mapper.insertSelectKey(appapprovalline); 
	}
		 
	@Override
	@Transactional
	public boolean remove(String aprvlineid) {
		
		LogUtil.log("INFO", "remove...." + aprvlineid);
		 
		return mapper.delete(aprvlineid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiApprovalLineVO get(String aprvlineid) {
		
		 LogUtil.log("INFO", "get......" + aprvlineid);
		 
		 return mapper.read(aprvlineid);
	}

	@Override
	@Transactional
	public boolean modify(PiiApprovalLineVO appapprovalline) {
		
		LogUtil.log("INFO", "modify......" + appapprovalline);
		
		return mapper.update(appapprovalline) == 1;
	}
	
}
