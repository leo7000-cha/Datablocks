package datablocks.dlm.service;

import datablocks.dlm.domain.BoardAttachVO;
import datablocks.dlm.domain.BoardVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.mapper.BoardAttachMapper;
import datablocks.dlm.mapper.BoardMapper;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
public class BoardServiceImpl implements BoardService {
	private static final Logger logger = LoggerFactory.getLogger(BoardServiceImpl.class);
	@Autowired
	private BoardMapper mapper;

	@Autowired
	private BoardAttachMapper attachMapper;

	@Transactional
	@Override
	public void register(BoardVO board) {

		LogUtil.log("INFO", "register......" + board);

		mapper.insertSelectKey(board);

		if (board.getAttachList() == null || board.getAttachList().size() <= 0) {
			return;
		}

		board.getAttachList().forEach(attach -> {

			attach.setBno(board.getBno());
			attachMapper.insert(attach);
		});
	}

	@Override
	public BoardVO get(Long bno) {

		LogUtil.log("INFO", "get......" + bno);

		return mapper.read(bno);

	}

	@Transactional
	@Override
	public boolean modify(BoardVO board) {

		LogUtil.log("INFO", "modify......" + board);

		attachMapper.deleteAll(board.getBno());

		boolean modifyResult = mapper.update(board) == 1;
		
		if (modifyResult && board.getAttachList() != null) {

			board.getAttachList().forEach(attach -> {

				attach.setBno(board.getBno());
				attachMapper.insert(attach);
			});
		}

		return modifyResult;
	}

	// @Override
	// public boolean modify(BoardVO board) {
	//
	// LogUtil.log("INFO", "modify......" + board);
	//
	// return mapper.update(board) == 1;
	// }

	// @Override
	// public boolean remove(Long bno) {
	//
	// LogUtil.log("INFO", "remove...." + bno);
	//
	// return mapper.delete(bno) == 1;
	// }

	@Transactional
	@Override
	public boolean remove(Long bno) {

		LogUtil.log("INFO", "remove...." + bno);

		attachMapper.deleteAll(bno);

		return mapper.delete(bno) == 1;
	}

	// @Override
	// public List<BoardVO> getList() {
	//
	// LogUtil.log("INFO", "getList..........");
	//
	// return mapper.getList();
	// }

	@Override
	public List<BoardVO> getList(Criteria cri) {

		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}

	@Override
	public int getTotal(Criteria cri) {

		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public List<BoardAttachVO> getAttachList(Long bno) {

		LogUtil.log("INFO", "get Attach list by bno" + bno);

		return attachMapper.findByBno(bno);
	}

	@Override
	public void removeAttach(Long bno) {

		LogUtil.log("INFO", "remove all attach files");

		attachMapper.deleteAll(bno);
	}

}
