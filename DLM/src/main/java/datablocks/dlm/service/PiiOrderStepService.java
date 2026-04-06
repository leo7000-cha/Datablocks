package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiArcTableVO;
import datablocks.dlm.domain.PiiOrderStepRunStatusVO;
import datablocks.dlm.domain.PiiOrderStepVO;

public interface PiiOrderStepService {

	public void register(PiiOrderStepVO piiorderstep);

	public PiiOrderStepVO get(int orderid, String jobid, String version, String stepid) ;
	public PiiOrderStepVO getByStepseq(int orderid, int stepseq) ;
	public PiiOrderStepVO getFirstStep(int orderid) ;
	public PiiOrderStepVO getByStepEXE(int orderid) ;
	public List<PiiOrderStepVO> getOrderStepList(int orderid) ;
	public List<PiiOrderStepVO> getRunnableOrderStepList(int orderid);
	public List<PiiOrderStepRunStatusVO> getRunStatusList(int orderid) ;

	public boolean modify(PiiOrderStepVO piiorderstep);
	public boolean updatebefore(int orderid, String jobid, String version, String stepid) ;
	public boolean updateend(int orderid, String jobid, String version, String stepid) ;
	public boolean updateactionflag(PiiOrderStepVO piiorderstep);
	public boolean rerun(int orderid);

	public boolean remove(int orderid, String jobid, String version, String stepid) ;
	public boolean removebyorderid(int orderid) ;

	public List<PiiOrderStepVO> getList();

	public List<PiiOrderStepVO> getList(Criteria cri);

	//추가PiiOrdeSteprVO.java
	public int getTotal(Criteria cri);


}