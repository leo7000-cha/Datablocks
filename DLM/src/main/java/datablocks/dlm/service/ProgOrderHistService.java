package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ProgOrderHistOkVO;
import datablocks.dlm.domain.ProgOrderHistVO;

import java.util.List;

public interface ProgOrderHistService {

	public void register(ProgOrderHistVO progOrderHist);

	public ProgOrderHistVO get(String orderid);

	public boolean modify(ProgOrderHistVO progOrderHist);

	public boolean remove(String orderid);

	public List<ProgOrderHistVO> getList();
	public List<ProgOrderHistOkVO> getListEndedOK();

	public List<ProgOrderHistVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}