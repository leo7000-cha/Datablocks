package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.AuthToChangeVO;
import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;

public interface PiiAuthService {

	public void register(AuthVO auth);

	public AuthVO get(AuthVO auth);

	public boolean modify(AuthToChangeVO auth);

	public boolean remove(AuthVO auth);
	public boolean removeByUserid(String userid);

	public List<AuthVO> getList();

	public List<AuthVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}