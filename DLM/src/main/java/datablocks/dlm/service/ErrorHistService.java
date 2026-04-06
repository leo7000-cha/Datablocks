package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ErrorHistVO;

import java.util.List;

public interface ErrorHistService {

	public void register(ErrorHistVO errorHist);

	public ErrorHistVO get(String id);

	public boolean modify(ErrorHistVO errorHist);

	public boolean remove(String id);

	public List<ErrorHistVO> getList();

	public List<ErrorHistVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}