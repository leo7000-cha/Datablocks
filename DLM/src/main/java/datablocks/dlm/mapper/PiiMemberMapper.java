package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiMemberVO;

public interface PiiMemberMapper {

   
	public List<PiiMemberVO> getList();
	
	public List<PiiMemberVO> getListWithPaging(Criteria cri);

	public void insert(PiiMemberVO member);

	public void insertSelectKey(PiiMemberVO member);

	public PiiMemberVO read(String userid);

	public int delete(String userid);
	
	public int update(PiiMemberVO member);
	public int updateWithoutPw(PiiMemberVO member);
	
	public int getTotalCount(Criteria cri);
	public int getPwdElapsedCount(String userid);


}
