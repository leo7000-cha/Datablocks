package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ReplyPageDTO;
import datablocks.dlm.domain.ReplyVO;
import datablocks.dlm.mapper.BoardMapper;
import datablocks.dlm.mapper.ReplyMapper;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service

public class ReplyServiceImpl implements ReplyService {
	private static final Logger logger = LoggerFactory.getLogger(ReplyServiceImpl.class);
	@Autowired
	private ReplyMapper mapper;

	@Autowired
	private BoardMapper boardMapper;

	@Transactional
	@Override
	public int register(ReplyVO vo) {

		LogUtil.log("INFO", "register......" + vo);

		boardMapper.updateReplyCnt(vo.getBno(), 1);

		return mapper.insert(vo);

	}

	@Override
	public ReplyVO get(Long rno) {

		LogUtil.log("INFO", "get......" + rno);

		return mapper.read(rno);

	}

	@Override
	@Transactional
	public int modify(ReplyVO vo) {

		LogUtil.log("INFO", "modify......" + vo);

		return mapper.update(vo);

	}

	// @Override
	// public int remove(Long rno) {
	//
	// LogUtil.log("INFO", "remove...." + rno);
	//
	// return mapper.delete(rno);
	//
	// }

	@Transactional
	@Override
	public int remove(Long rno) {

		LogUtil.log("INFO", "remove...." + rno);

		ReplyVO vo = mapper.read(rno);

		boardMapper.updateReplyCnt(vo.getBno(), -1);
		return mapper.delete(rno);

	}

	@Override
	public List<ReplyVO> getList(Criteria cri, Long bno) {

		LogUtil.log("INFO", "get Reply List of a Board " + bno);

		return mapper.getListWithPaging(cri, bno);

	}

	@Override
	public ReplyPageDTO getListPage(Criteria cri, Long bno) {

		return new ReplyPageDTO(mapper.getCountByBno(bno), mapper.getListWithPaging(cri, bno));
	}

}
