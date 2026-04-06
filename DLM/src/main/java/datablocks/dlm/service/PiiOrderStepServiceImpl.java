package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiOrderStepRunStatusVO;
import datablocks.dlm.domain.PiiOrderStepVO;
import datablocks.dlm.mapper.PiiOrderStepMapper;
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
public class PiiOrderStepServiceImpl implements PiiOrderStepService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderStepServiceImpl.class);
	@Autowired
	private PiiOrderStepMapper mapper;


	@Override
	public List<PiiOrderStepVO> getList() {
		LogUtil.log("INFO", "get List: " );
		return mapper.getList();
	}

	@Override
	public List<PiiOrderStepVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "getList(Criteria cri): " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiOrderStepVO piiorderstep) {
		
		 LogUtil.log("INFO", "register......" + piiorderstep);
		  
		 mapper.insert(piiorderstep); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(int orderid, String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "remove...." + orderid +" "+ jobid+" "+ version+" "+ stepid);
		 
		return mapper.delete(orderid, jobid, version, stepid) == 1;
	}
@Override
	@Transactional
	public boolean removebyorderid(int orderid) {

		LogUtil.log("INFO", "removebyorderid...." + orderid );

		return mapper.deletebyorderid(orderid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "getTotal");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiOrderStepVO get(int orderid, String jobid, String version, String stepid) {
		
		LogUtil.log("INFO", "get...." + orderid +" "+ jobid+" "+ version+" "+ stepid);
		 
		 return mapper.read(orderid, jobid, version, stepid);
	}

	@Override
	public PiiOrderStepVO getByStepseq(int orderid, int stepseq) {
		
		LogUtil.log("INFO", "getByStepseq...." + orderid +" "+ stepseq);
		
		return mapper.readByStepseq(orderid, stepseq);
	}
	
	@Override
	public PiiOrderStepVO getFirstStep(int orderid) {
		
		LogUtil.log("INFO", "getFirstStep...." + orderid);
		
		return mapper.readFirstStep(orderid);
	}
	@Override
	public PiiOrderStepVO getByStepEXE(int orderid) {

		LogUtil.log("INFO", "getByStepEXE...." + orderid);

		return mapper.readByStepEXE(orderid);
	}

	@Override
	public List<PiiOrderStepVO> getOrderStepList(int orderid) {
		
		LogUtil.log("INFO", "getOrderStepList...." + orderid );
		
		return mapper.getOrderStepList(orderid);
	}
	@Override
	public List<PiiOrderStepVO> getRunnableOrderStepList(int orderid) {

		LogUtil.log("INFO", "getRunnableOrderStepList...." + orderid );

		return mapper.getRunnableOrderStepList(orderid);
	}

	@Override
	public List<PiiOrderStepRunStatusVO> getRunStatusList(int orderid) {
		
		LogUtil.log("INFO", "getRunStatusList...." + orderid);
		
		return mapper.getRunStatusList(orderid);
	}
	
	@Override
	@Transactional
	public boolean modify(PiiOrderStepVO piiorderstep) {
		
		LogUtil.log("INFO", "modify......" + piiorderstep);
		
		return mapper.update(piiorderstep) == 1;
	}
	@Override
	public boolean updatebefore(int orderid, String jobid, String version, String stepid) {

		LogUtil.log("INFO", "updatebefore......" + orderid +" "+ jobid+" "+ version+" "+ stepid);

		return mapper.updatebefore(orderid, jobid, version, stepid) == 1;
	}
	@Override
	public boolean updateend(int orderid, String jobid, String version, String stepid) {

		LogUtil.log("INFO", "updateend......" + orderid +" "+ jobid+" "+ version+" "+ stepid);

		return mapper.updateend(orderid, jobid, version, stepid)== 1;
	}

	@Override
	public boolean updateactionflag(PiiOrderStepVO piiorderstep) {

		LogUtil.log("INFO", "updateactionflag......" + piiorderstep);

		return mapper.updateactionflag(piiorderstep) == 1;
	}

	@Override
	public boolean rerun(int orderid) {

		LogUtil.log("INFO", "orderid......" + orderid);

		return mapper.rerun(orderid) == 1;
	}
	

}
