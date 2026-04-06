package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDatabaseVO;

public interface PiiDatabaseService {

	public void register(PiiDatabaseVO piidatabase);

	public PiiDatabaseVO get(String db);
	public PiiDatabaseVO getBySystem(String system);

	public boolean modify(PiiDatabaseVO piidatabase);
	public boolean modifyWithoutPw(PiiDatabaseVO piidatabase);

	public boolean remove(String db);

	public List<PiiDatabaseVO> getList();

	public List<PiiDatabaseVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}