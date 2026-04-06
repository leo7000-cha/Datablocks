package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ReplyPageDTO;
import datablocks.dlm.domain.ReplyVO;

public interface ReplyService {

	public int register(ReplyVO vo);

	public ReplyVO get(Long rno);

	public int modify(ReplyVO vo);

	public int remove(Long rno);

	public List<ReplyVO> getList(Criteria cri, Long bno);
	
	public ReplyPageDTO getListPage(Criteria cri, Long bno);

}
