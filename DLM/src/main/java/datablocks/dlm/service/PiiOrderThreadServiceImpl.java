package datablocks.dlm.service;

import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiOrderThreadVO;
import datablocks.dlm.mapper.PiiOrderThreadMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiOrderThreadServiceImpl implements PiiOrderThreadService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderThreadServiceImpl.class);
	@Autowired
	private PiiOrderThreadMapper mapper;


	@Override
	public List<PiiOrderThreadVO> getList(int orderid, String jobid, String version) {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList(orderid, jobid, version);
	}

	@Override
	@Transactional
	public boolean delete(int orderid) {

		LogUtil.log("INFO", "delete...." + orderid);
		return mapper.delete(orderid) == 1;
	}
	@Override
	@Transactional
	public int deleteEndOkTabs() {

		LogUtil.log("INFO", "deleteEndOkTabs...." );
		return mapper.deleteEndOkTabs();
	}

	@Override
	public int getListCnt(int orderid, String jobid, String version) {

		LogUtil.log("INFO", "getListCnt "+ orderid +" "+ jobid +" "+ version);
		return mapper.getListCnt(orderid, jobid, version);
	}

	@Override
	public PiiOrderThreadVO get(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "get "+ orderid +" "+ jobid +" "+ version);
		return mapper.read(orderid, jobid, version, stepid, seq1, seq2, seq3);
	}

	@Override
	@Transactional
	public int register(PiiOrderThreadVO piiorderthread) {
		
		 LogUtil.log("INFO", "register......" + piiorderthread);
		 
		 return mapper.insert(piiorderthread);
		 
	}
		 


	
}
