package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.AuthToChangeVO;
import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;

public interface PiiAuthMapper {

   
	public List<AuthVO> getList();
	
	public List<AuthVO> getListWithPaging(Criteria cri);

	public void insert(AuthVO auth);

	public void insertSelectKey(AuthVO auth);

	//public AuthVO read(AuthVO PiiAuth);
	public AuthVO read(AuthVO auth);

	public int delete(AuthVO auth);
	public int deleteByUserid(String userid);

	public int update(AuthToChangeVO auth);
	
	public int getTotalCount(Criteria cri);

}
