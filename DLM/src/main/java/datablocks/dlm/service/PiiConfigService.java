package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiConfigVO;
import datablocks.dlm.domain.Criteria;

public interface PiiConfigService {

	public void register(PiiConfigVO config);

	public PiiConfigVO get(String cfgkey);

	public boolean modify(PiiConfigVO config);
	public boolean modifyVal(String cfgkey, String value);

	public boolean remove(String cfgkey);

	public List<PiiConfigVO> getList();

	public List<PiiConfigVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);

	public boolean refreshConfig();

}