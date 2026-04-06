package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.LkPiiScrTypeVO;

import java.util.List;

public interface LkPiiScrTypeService {

	public void register(LkPiiScrTypeVO piiscrtype);

	public LkPiiScrTypeVO get(String piicode);

	public boolean modify(LkPiiScrTypeVO piiscrtype);

	public boolean remove(String piicode);

	public List<LkPiiScrTypeVO> getList();

	public List<LkPiiScrTypeVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}