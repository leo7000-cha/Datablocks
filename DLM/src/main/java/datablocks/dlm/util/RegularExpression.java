package datablocks.dlm.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RegularExpression {
	 public static final String pattern1 = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$!%*#?&])[A-Za-z[0-9]$@$!%*#?&]{8,20}$"; // 영문, 숫자, 특수문자
	 public static final String pattern2 = "^[A-Za-z[0-9]]{10,20}$"; // 영문, 숫자
	 public static final String pattern3 = "^[[0-9]$@$!%*#?&]{10,20}$"; //영문,  특수문자
	 public static final String pattern4 = "^[[A-Za-z]$@$!%*#?&]{10,20}$"; // 특수문자, 숫자
	 public static final String pattern5 = "(\\w)\\1\\1\\1"; // 같은 문자, 숫자

	 Matcher match;

	 /**
	  * 비밀번호 정규식 체크
	  * @param pwd
	  * @return
	  */
	 public boolean pwdRegularExpressionChk(String newPwd, String oldPwd, String userId) {

	  boolean chk = false;

	  // 특수문자, 영문, 숫자 조합 (8~10 자리)
	  match = Pattern.compile(pattern1).matcher(newPwd);
	  if(match.find()) {
	   chk = true;
	  }

	  // 영문, 숫자 (10~20 자리)
	  match = Pattern.compile(pattern2).matcher(newPwd);
	  if(match.find()) {
	   chk = true;
	  }

	  // 영문, 특수문자 (10~20 자리)
	  match = Pattern.compile(pattern3).matcher(newPwd);
	  if(match.find()) {
	   chk = true;
	  }

	  // 특수문자, 숫자 (10~20 자리)
	  match = Pattern.compile(pattern4).matcher(newPwd);
	  if(match.find()) {
	   chk = true;
	  }

	  if(chk) {
	   // 연속문자 4자리
	   if(samePwd(newPwd)) {
	    return false;
	   }

	   // 같은문자 4자리
	   if(continuousPwd(newPwd)) {
	    return false;
	   }
	   
	   // 이전 아이디 4자리
	   if(newPwd.equals(oldPwd)) {
	    return false;
	   }

	   // 아이디와 동일 문자 4자리
	   if(sameId(newPwd, userId)) {
	    return false;
	   }

	  }

	  return true;

	 }

	 

	 /**
	  * 같은 문자, 숫자 4자리 체크
	  * @param pwd
	  * @return
	  */
	 public boolean samePwd(String pwd) {
	  match = Pattern.compile(pattern5).matcher(pwd);
	  return match.find() ? true : false;
	 }

	 /**
	  * 연속 문자, 숫자 4자리 체크
	  * @param pwd
	  * @return
	  */
	 public boolean continuousPwd(String pwd) {
	  int o = 0;
	  int d = 0;
	  int p = 0;
	  int n = 0;  
	  int limit = 4;

	  for(int i=0; i<pwd.length(); i++) {
	   char tempVal = pwd.charAt(i);
	   if(i > 0 && (p = o - tempVal) > -2 && (n = p == d ? n + 1 :0) > limit -3) {
		   return true;
	   }
	   d = p;
	   o = tempVal;
	  }

	  return false;
	 }

	 /**
	  * 아이디와 동일 문자 4자리 체크
	  * @param pwd
	  * @param id
	  * @return
	  */
	 public boolean sameId(String pwd, String id) {
	  for(int i=0; i<pwd.length()-3; i++) {
	   if(id.contains(pwd.substring(i, i+4))) {
	    return true;
	   }
	  }
	  
	  return false;
	 }
}
