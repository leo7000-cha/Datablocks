package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiSystemVO;
import datablocks.dlm.domain.Criteria;

public interface PiiSystemService {

	public void register(PiiSystemVO piisystem);

	public PiiSystemVO get(String system_id);

	public boolean modify(PiiSystemVO piisystem);

	public boolean remove(String system_id);

	public List<PiiSystemVO> getList();

	public List<PiiSystemVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}