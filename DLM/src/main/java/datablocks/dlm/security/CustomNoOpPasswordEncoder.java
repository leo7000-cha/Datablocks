package datablocks.dlm.security;

import datablocks.dlm.util.LogUtil;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class CustomNoOpPasswordEncoder implements PasswordEncoder {
	private static final Logger logger = LoggerFactory.getLogger(CustomNoOpPasswordEncoder.class);

	public String encode(CharSequence rawPassword) {

		LogUtil.log("INFO", "before encode :" + rawPassword);

		return rawPassword.toString();
	}

	public boolean matches(CharSequence rawPassword, String encodedPassword) {

		LogUtil.log("INFO", "matches: " + rawPassword + ":" + encodedPassword);
        
		return rawPassword.toString().equals(encodedPassword);
	}

}
