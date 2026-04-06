package datablocks.dlm.security;

import datablocks.dlm.domain.MemberVO;
import datablocks.dlm.mapper.MemberMapper;
import datablocks.dlm.security.domain.CustomUser;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;


public class CustomUserDetailsService implements UserDetailsService {
	private static final Logger logger = LoggerFactory.getLogger(CustomUserDetailsService.class);
	@Autowired
	private MemberMapper memberMapper;

	@Override
	public CustomUser loadUserByUsername(String userName) throws UsernameNotFoundException {

		LogUtil.log("INFO", "Load User By UserName : " + userName);

		// userName means userid
		MemberVO vo = memberMapper.read(userName);

		LogUtil.log("INFO", "queried by member mapper: " + vo);

		return vo == null ? null : new CustomUser(vo);
	} 

}
