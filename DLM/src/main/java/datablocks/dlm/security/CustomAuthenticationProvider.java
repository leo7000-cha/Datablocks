package datablocks.dlm.security;

import bankware.corebanking.external.servicecall.AfsServiceCall;
import bankware.corebanking.external.servicecall.BxmBody;
import com.bankware.fastjson.JSONArray;
import com.bankware.fastjson.JSONObject;
import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.mapper.PiiDatabaseMapper;
import datablocks.dlm.security.domain.CustomUser;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.SI43PasswordUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


@Service
public class CustomAuthenticationProvider implements AuthenticationProvider {
	private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationProvider.class);
	@Autowired
	UserDetailsService userDetailsServcie;
	@Autowired
	PasswordEncoder pwEncoding;
	@Autowired
	private PiiDatabaseMapper databaseMapper;

	@Override
	// 인증 로직
	public Authentication authenticate(Authentication authentication)
			throws AuthenticationException {

		/* 사용자가 입력한 정보 */
		String userId = authentication.getName();
		String userPw = (String) authentication.getCredentials();
		/** userDetails.getPassword() =  DB에 저장된 비밀번호(암호화된 값)*/

		String pwdType = EnvConfig.getConfig("PWD_TYPE");
		if (pwdType == null || pwdType.isEmpty()) {
			pwdType = "INTRNL";
		}
		/* DB에서 가져온 정보 (커스터마이징 가능) */
		CustomUser userDetails = (CustomUser) userDetailsServcie.loadUserByUsername(userId);

		// DB에 정보가 없는 경우 예외 발생 (아이디/패스워드 잘못됐을 때와 동일한 것이 좋음)
		// ID 및 PW 체크해서 안맞을 경우 (matches를 이용한 암호화 체크를 해야함)
		if (userDetails == null || !userId.equals(userDetails.getUsername()) || "".equals(userPw) || userPw == null ) {
			throw new BadCredentialsException(userId);
		}

		/* 인증 진행 */
		LogUtil.log("INFO", "authenticate: userId=" + userId);

/*			
		// 패스워드 체크
		} else if (!pwEncoding.matches(userPw, userDetails.getPassword())) {
			throw new BadCredentialsException(userId);
	
		// 계정 정보 맞으면 나머지 부가 메소드 체크 (이부분도 필요한 부분만 커스터마이징 하면 됨)
		// 잠긴 계정일 경우
		} else if (!userDetails.isAccountNonLocked()) {
			throw new LockedException(userId);

		// 비활성화된 계정일 경우
		} else if (!userDetails.isEnabled()) {
			throw new DisabledException(userId);

		// 만료된 계정일 경우
		} else if (!userDetails.isAccountNonExpired()) {
			throw new AccountExpiredException(userId);

		// 비밀번호가 만료된 경우
		} else if (!userDetails.isCredentialsNonExpired()) {
			throw new CredentialsExpiredException(userId);       
		}*/

		// 다 썼으면 패스워드 정보는 지워줌 (객체를 계속 사용해야 하므로)
		//userDetails.setPassword(null);
		
		String site = EnvConfig.getConfig("SITE");
		/** SELECT enc(?) FROM dual */
		String selEncPwdSql = EnvConfig.getConfig("DLM_ENC_PWD_SQL");

		//-----Additional authenticate depend on the site------------------------------------------------------------------------------
		if("HANACARD".equalsIgnoreCase(site)) {
			String domainUrl = null;
			String instCd = null;
			String srvcCd = null;
			if ("INTRNL".equalsIgnoreCase(pwdType)
					|| "ADMIN".equalsIgnoreCase(userId)
					|| userId.toUpperCase().startsWith("MEMBER")
					|| userId.toUpperCase().startsWith("USER")) {
				if (!pwEncoding.matches(userPw, userDetails.getPassword())) {
					throw new BadCredentialsException(userId);
				}
			} else {
				try {
					domainUrl = EnvConfig.getConfig("DOMAIN_URL");
					instCd = EnvConfig.getConfig("INST_CD");
					srvcCd = EnvConfig.getConfig("LOGIN_SRVC_CD");
				} catch (NullPointerException e) {
					logger.warn("warn "+"CustomAuthenticationProvider AfsServiceCall information is null=> NullPointerException :DOMAIN_URL, INST_CD, INST_CD in ENV_CONFIG" + e.toString());
					e.printStackTrace();
				}
				BxmBody bxmBody = new BxmBody(userId, userPw);

				HttpURLConnection conn = null;
				try {
					AfsServiceCall svcCall = new AfsServiceCall();
					conn = svcCall.callService(instCd, domainUrl, srvcCd, bxmBody);
					boolean isSuccess = _isLoginSuccess(conn.getInputStream());
					if (!isSuccess) {
						logger.warn("warn "+"CustomAuthenticationProvider  isSuccess=> false");
						throw new BadCredentialsException(userId);
					}
				} catch (Throwable e) {
					logger.warn("warn "+"CustomAuthenticationProvider svcCall.callService(instCd, domainUrl, srvcCd, bxmBody)=> instCd:" + instCd + " domainUrl:" + domainUrl + " srvcCd:" + srvcCd + " => " + e.toString());
					throw new BadCredentialsException(userId);
				} finally {
					if (conn != null) {
						conn.disconnect();
					}
				}
			}
		}
		else if("DGBCAP".equalsIgnoreCase(site)) {
			if ("INTRNL".equalsIgnoreCase(pwdType)
					|| "ADMIN".equalsIgnoreCase(userId)
					|| userId.toUpperCase().startsWith("MEMBER")
					|| userId.toUpperCase().startsWith("USER")) {
				if (!pwEncoding.matches(userPw, userDetails.getPassword())) {
					throw new BadCredentialsException(userId);
				}
			}else {
				AES256Util aes = null;
				try {
					aes = new AES256Util();
				} catch(Exception e) {

				}
				Connection conn = null;
				PreparedStatement pstmt = null;
				ResultSet rs = null;
				String encryptedPwd = null;
				try {
					PiiDatabaseVO dbVO = databaseMapper.read("DAONDB");
					conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
					//pstmt = conn.prepareStatement("select userpw from cotdl.tbl_member where userid = ?");
					pstmt = conn.prepareStatement(selEncPwdSql);

					//pstmt.setString(1, userId);
					pstmt.setString(1, userPw);
					rs = pstmt.executeQuery();

					while (rs.next()) {
						encryptedPwd =  rs.getString(1);LogUtil.log("INFO", rs.getString(1));
					}

					rs.close();
					pstmt.close();
					conn.close();

				} catch (Exception e) {
					logger.warn("warn "+" CustomAuthenticationProvider DGBCAP: " + e.getMessage());
				}
				/**
				 * encryptedPwd : 사용자가 입력한 패스워드를 기존 처리계 db 방식으로 암호화된 값을 가져온다.
				 * userDetails.getPassword() : 처리계 사용자테이블(pwd 암호화값 포함)을 동기화 해서 저장해 놓은 TBL_MEMBER 에서 암호화된 패스워드
				 * 이 두개를 비교한다.
				 * */
				if(!userDetails.getPassword().equalsIgnoreCase(encryptedPwd)) {
					logger.warn("warn "+"!userDetails.getPassword().equalsIgnoreCase(encryptedPwd)  isSuccess => false");
					logger.warn("warn "+"userId="+userId+"   password mismatch");
					logger.warn("warn "+"selEncPwdSql = "+selEncPwdSql);
					logger.warn("warn "+"userDetails.getPassword() = "+userDetails.getPassword());
					logger.warn("warn "+"encryptedPwd              = "+encryptedPwd);

					throw new BadCredentialsException(userId);
				}
			}
		}
		else if("JBCAP".equalsIgnoreCase(site)) {
			if ("INTRNL".equalsIgnoreCase(pwdType)
					|| "ADMIN".equalsIgnoreCase(userId)
					|| userId.toUpperCase().startsWith("MEMBER")
					|| userId.toUpperCase().startsWith("USER")) {
				if (!pwEncoding.matches(userPw, userDetails.getPassword())) {
					throw new BadCredentialsException(userId);
				}
			}else {
				AES256Util aes = null;
				try {
					aes = new AES256Util();
				} catch(Exception e) {

				}
				Connection conn = null;
				PreparedStatement pstmt = null;
				ResultSet rs = null;

				String encryptedPwd = SI43PasswordUtil.mkpwd(userPw);
//				try {
//					PiiDatabaseVO dbVO = databaseMapper.read("PCCS");
//					conn = ConnectionProvider.getConnection(dbVO.getDbtype(), dbVO.getHostname(), dbVO.getPort(), dbVO.getId_type(), dbVO.getId(), dbVO.getDb(), dbVO.getDbuser(), aes.decrypt(dbVO.getPwd()));
//					//pstmt = conn.prepareStatement("select userpw from cotdl.tbl_member where userid = ?");
//					pstmt = conn.prepareStatement(selEncPwdSql);
//
//					/** 사용자가 입력한 패스워드를 기존 처리계 db 방식으로 암호화된 값을 가져온다.*/
//					pstmt.setString(1, userPw);
//					rs = pstmt.executeQuery();
//
//					while (rs.next()) {
//						encryptedPwd =  rs.getString(1);LogUtil.log("INFO", rs.getString(1));
//					}
//
//					rs.close();
//					pstmt.close();
//					conn.close();
//
//				} catch (Exception e) {
//					logger.warn("warn "+" CustomAuthenticationProvider JBCAP: " + e.getMessage());
//				}

				/**
				 * encryptedPwd : 사용자가 입력한 패스워드를 기존 처리계 db 방식으로 암호화된 값을 가져온다.
				 * userDetails.getPassword() : 처리계 사용자테이블(pwd 암호화값 포함)을 동기화 해서 저장해 놓은 TBL_MEMBER 에서 암호화된 패스워드
				 * 이 두개를 비교한다.
				 * */
				if(!userDetails.getPassword().equalsIgnoreCase(encryptedPwd)) {
					logger.warn("warn "+"!userDetails.getPassword().equalsIgnoreCase(encryptedPwd)  isSuccess => false");
					logger.warn("warn "+"userId="+userId+"   password mismatch");
					logger.warn("warn "+"selEncPwdSql = "+selEncPwdSql);
					logger.warn("warn "+"userDetails.getPassword() = "+userDetails.getPassword());
					logger.warn("warn "+"encryptedPwd              = "+encryptedPwd);

					throw new BadCredentialsException(userId);
				}
			}
		}
		else if (!pwEncoding.matches(userPw, userDetails.getPassword())) {
			throw new BadCredentialsException(userId);
		}
		
		//-----------------------------------------------------------------------------------------------------------------------------

		/* 최종 리턴 시킬 새로 만든 Authentication 객체 */
		Authentication newAuth = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

		return newAuth;
	}

	@Override
	// 위의 authenticate 메소드에서 반환한 객체가 유효한 타입이 맞는지 검사
	// null 값이거나 잘못된 타입을 반환했을 경우 인증 실패로 간주
	public boolean supports(Class<?> authentication) {

		// 스프링 Security가 요구하는 UsernamePasswordAuthenticationToken 타입이 맞는지 확인
		return authentication.equals(UsernamePasswordAuthenticationToken.class);
	}
	
	private static boolean _isLoginSuccess(InputStream responseMsg) {
		boolean isSuccess = false;

		BufferedReader br = new BufferedReader(new InputStreamReader(responseMsg));
		StringBuilder sb = new StringBuilder();

		try {
			String line;
			while ((line = br.readLine()) != null) {
				sb.append(line);
			}
			JSONObject result = (JSONObject) JSONObject.parse(sb.toString());
			if (sb.toString().contains("messageCode")) {
				isSuccess = false;
				JSONObject out = (JSONObject) result.get("header");
				JSONArray errorMessages = (JSONArray)out.get("msgs");
				JSONObject messageObject = errorMessages.getJSONObject(0);
				String messageCode = messageObject.getString("messageCode");
				String message = messageObject.getString("message");
				System.out.println(messageCode + ": " + message);
			}
			else {
				JSONObject out = (JSONObject) result.get("LogInSvcGetLoginUserOut");
				String userNm = (String) out.getString("nm");
				if (userNm != null && !userNm.isEmpty()) {
					isSuccess = true;
				}
			}
		} catch (IOException e) {
			logger.warn("warn "+"CustomAuthenticationProvider _isLoginSuccess(InputStream responseMsg) => "+e.toString());
			e.printStackTrace();
			return false;
		} finally {
			try {
				br.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		return isSuccess;
	}
}
