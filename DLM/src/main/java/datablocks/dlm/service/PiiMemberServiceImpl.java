package datablocks.dlm.service;

import datablocks.dlm.domain.AuthVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiMemberVO;
import datablocks.dlm.mapper.PiiAuthMapper;
import datablocks.dlm.mapper.PiiMemberMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiMemberServiceImpl implements PiiMemberService {
	private static final Logger logger = LoggerFactory.getLogger(PiiMemberServiceImpl.class);
	@Autowired
	private PiiMemberMapper mapper;
	private PiiAuthMapper authmapper;

	@Override
	public List<PiiMemberVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiMemberVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiMemberVO member) {
		
		 LogUtil.log("INFO", "register......" + member);
		 
		 mapper.insert(member); 
		 
		 AuthVO auth = new AuthVO();
		 auth.setUserid(member.getUserid());
		 auth.setAuth("ROLE_USER");
		 authmapper.insert(auth); 
		 
	}
		 
	@Override
	@Transactional
	public boolean remove(String userid) {
		
		LogUtil.log("INFO", "remove...." + userid);
		authmapper.deleteByUserid(userid);
		return mapper.delete(userid) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public int getPwdElapsedCount(String userid) {

		LogUtil.log("INFO", "getPwdElapsedCount");
		return mapper.getPwdElapsedCount(userid);
	}

	@Override
	public PiiMemberVO get(String userid) {
		
		 LogUtil.log("INFO", "get......" + userid);
		 
		 return mapper.read(userid);
	}

	@Override
	@Transactional
	public boolean modify(PiiMemberVO member) {
		
		LogUtil.log("INFO", "modify......" + member);
		
		return mapper.update(member) == 1;
	}
	
	@Override
	@Transactional
	public boolean modifyWithoutPw(PiiMemberVO member) {
		
		LogUtil.log("INFO", "modifyWithoutPw......" + member);
		
		return mapper.updateWithoutPw(member) == 1;
	}
	
}
