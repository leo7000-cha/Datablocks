package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiCodeVO;
import datablocks.dlm.domain.Criteria;

public interface PiiCodeService {

	public void register(PiiCodeVO piicode);

	public PiiCodeVO get(String code_id, String item_val);

	public boolean modify(PiiCodeVO piicode);

	public boolean remove(String code_id, String item_val);

	public List<PiiCodeVO> getList();

	public List<PiiCodeVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}