package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiMemberVO;
import datablocks.dlm.domain.Criteria;

public interface PiiMemberService {

	public void register(PiiMemberVO member);

	public PiiMemberVO get(String userid);

	public boolean modify(PiiMemberVO member);
	public boolean modifyWithoutPw(PiiMemberVO member);

	public boolean remove(String userid);

	public List<PiiMemberVO> getList();

	public List<PiiMemberVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public int getPwdElapsedCount(String userid);



}