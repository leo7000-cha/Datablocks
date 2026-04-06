package datablocks.dlm.util;

import java.util.Map;

public class StrUtil {
	
	public static boolean checkString(String str) {
		  return str == null || str.trim().isEmpty();
		}
	public static int parseInt(String str) {
		if (str == null || str.trim().isEmpty()) {
			return 0; // 또는 다른 적절한 기본값
		}
		try {
			return Integer.parseInt(str.trim());
		} catch (NumberFormatException e) {
			// 로그 기록 또는 다른 처리
			return 0; // 또는 다른 적절한 기본값
		}
	}
	public static long parseLong(String str) {
		if (str == null || str.trim().isEmpty()) {
			return 0L; // 또는 다른 적절한 기본값
		}
		try {
			return Long.parseLong(str.trim());
		} catch (NumberFormatException e) {
			// 로그 기록 또는 다른 처리
			return 0L; // 또는 다른 적절한 기본값
		}
	}
	public static double parseDouble(String str) {
		if (str == null || str.trim().isEmpty()) {
			return 0.0; // 또는 다른 적절한 기본값
		}
		try {
			return Double.parseDouble(str.trim());
		} catch (NumberFormatException e) {
			// 로그 기록 또는 다른 처리
			return 0.0; // 또는 다른 적절한 기본값
		}
	}
	public static String changeNotNull(String str) {
		if(checkString(str)){
			return "";
		}else
			return str;
	}
	public static String expandStr(String str) {
		String rst = null;
		int length = str.length();
		for (int i = 0; i < length; i++) {
			if (i  == 0)
				rst =  ""+ str.charAt(i);
			else
				rst =  rst + " "+ str.charAt(i);
		}
		return rst;
	}
	public static String trim(String str) {
		String rst = "";
		int length = str.length();
		char ch ;
		for (int i = 0; i < length; i++) {
			ch = str.charAt(i);
			if (ch != ' ' && ch != '\t' && ch != '\r' && ch != '\n' ) {
				rst =  rst + ""+ str.charAt(i);
			}
		}
		return rst;
	}
	public static String wrapValuesInQuotes(String inputString) {
		// 쉼표로 문자열을 분리하여 배열로 만듭니다.
		String[] valuesArray = inputString.split(",");

		// 각 값을 작은 따옴표로 감싸고 다시 문자열로 조합합니다.
		StringBuilder resultStringBuilder = new StringBuilder();
		for (String value : valuesArray) {
			resultStringBuilder.append("'").append(value.trim()).append("', ");
		}

		// 마지막 쉼표 제거
		String resultString = resultStringBuilder.toString().replaceAll(", $", "");

		return resultString;
	}

	public static String wrapWithQuotes(String input) {
		String[] items = input.split(",");
		StringBuilder result = new StringBuilder();

		for (int i = 0; i < items.length; i++) {
			result.append("'").append(items[i].trim()).append("'");
			if (i < items.length - 1) {
				result.append(",");
			}
		}

		return result.toString();
	}


}
