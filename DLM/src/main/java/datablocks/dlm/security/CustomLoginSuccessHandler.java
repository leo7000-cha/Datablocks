package datablocks.dlm.security;

import datablocks.dlm.mapper.PiiMemberMapper;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;


public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler {
	private static final Logger logger = LoggerFactory.getLogger(CustomLoginSuccessHandler.class);

	@Autowired
	private PiiMemberMapper mapper;
	
	@Autowired
	PasswordEncoder pwEncoding;
	
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication auth)
			throws IOException, ServletException {

		
//		logger.warn("warn "+"Login Success");
//		UserDetails userDetails = (UserDetails) auth.getPrincipal();
//		logger.warn("warn "+"getUsername: " + userDetails.getUsername());
//		logger.warn("warn "+"getPassword: " + userDetails.getPassword());
//		
//		PiiMemberVO memebervo = mapper.read(userDetails.getUsername());
//		logger.warn("warn "+"getUpdatedate: " + memebervo.getUpdatedate());
//		
//		
//		if (DateUtil.calDateBetweenAandB(memebervo.getUpdatedate(), "2021/06/18") >= 90) {
//			logger.warn("warn "+"90 days have passed, change the pwassword");
//			//response.sendRedirect("/customChangePW");return;
//		}else{
//			logger.warn("warn "+"90 days have not passed, go ahead");
//		}
//		
//		
//		if (pwEncoding.matches("#"+userDetails.getUsername(), memebervo.getUserpw())) {
//			//PWD is just initialized, need to reset the pwd
//			logger.warn("warn "+"The pwd is just initialized, need to reset the pwd");
//			//response.sendRedirect("/changePwd");
//		}
//		
		
	
/*		
		List<String> roleNames = new ArrayList<>();

		auth.getAuthorities().forEach(authority -> {

			roleNames.add(authority.getAuthority());

		});

		//LogUtil.log("INFO", "ROLE NAMES: " + roleNames);

		if (roleNames.contains("ROLE_ADMIN")) {

//			response.sendRedirect("/sample/admin");
			response.sendRedirect("/");
			return;
		}

		if (roleNames.contains("ROLE_MEMBER")) {

//			response.sendRedirect("/sample/member");
			response.sendRedirect("/");
			return;
		}
*/
		LogUtil.log("INFO", "Login SUCCESS - user=" + auth.getName() + ", authorities=" + auth.getAuthorities() + ", sessionId=" + request.getSession().getId());
		response.sendRedirect("/");
	}
}


