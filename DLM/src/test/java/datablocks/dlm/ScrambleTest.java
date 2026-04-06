package datablocks.dlm;

import datablocks.dlm.util.Scramble;

public class ScrambleTest {
    	public static void main(String[] args) {
			String[] parts = "SCRAMBLE_RRN_ALL".split("_");
			String detail = parts[1];
			String fromTo = parts[2];
			System.out.println(detail+"=="+fromTo);
			String prefix = "0123456789".substring(0, 7); // 시작 위치 이전 문자열
			String targetChars = "0123456789".substring(7);
			System.out.println(prefix+"=="+targetChars);

			String str = "987654321";
			String lastFourChars = str.substring(str.length() - 4);
			System.out.println(lastFourChars);
			String orderlast4 = str.substring(str.length() - 4);
			System.out.println(orderlast4);
			System.out.println("-------------^^^^^^^^^^^^^-----------------");
			try {
				System.out.println(Scramble.getScrResult("0014", null, "SCRAMBLE_RRN_ALL"));
			} catch (Exception e){
				System.out.println(e.toString());
				e.printStackTrace();
			}
			System.out.println("-------------^^^^^^^^^^^^^-----------------");
		System.out.println(Scramble.getScrResult("0014", "7401261899517A","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("0014", "7401261899517A","SCRAMBLE_RRN_AFTER7"));
		System.out.println("--------------------------------");
			System.out.println("-------------^^^2^^^^^^^^^^-----------------");
			try {
				System.out.println(Scramble.getScrResult(null, "SCRAMBLE_RRN_ALL"));
			} catch (Exception e){
				System.out.println(e.toString());
				e.printStackTrace();
			}
			System.out.println("-------------^^^2^^^^^^^^^^-----------------");
		System.out.println(Scramble.getScrResult("7401261899517A","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("7401261899517A","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("7401261899517A","SCRAMBLE_RRN_AFTER7"));
//		System.out.println(Scramble.getScrResult("0015", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0016", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0017", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0018", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0019", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0020", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0021", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0022", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0023", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0024", "7401261899517","SCRAMBLE_RRN_ALL"));
//		System.out.println(Scramble.getScrResult("0025", "7401261899517","SCRAMBLE_RRN_ALL"));

//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0014", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0015", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0016", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0017", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0018", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0019", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0020", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0021", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0022", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0023", "7401261899517","SCRAMBLE_RRN_ALL")));
//			System.out.println(Scramble.isValidJuminNo(Scramble.getScrResult("0024", "7401261899517","SCRAMBLE_RRN_ALL")));
			System.out.println(Scramble.isValidJuminNo("7407011319149"));
			System.out.println("~~~~~~~~~~~~~1111~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0014", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0015", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0016", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0017", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0018", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0019", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0020", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0021", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0022", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0023", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0024", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("0025", "1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println("~~~~~~~~~~~~~~2222~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			System.out.println(Scramble.isValidCorpNo(Scramble.getScrResult("1101117796836","SCRAMBLE_CORPNO_ALL")));
			System.out.println("~~~~~~~~~~~~~~3333~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
			System.out.println(Scramble.isValidBizNo(Scramble.getScrResult("0025","6938102094","SCRAMBLE_BIZNO_ALL")));
			System.out.println(Scramble.isValidBizNo(Scramble.getScrResult("6938102094","SCRAMBLE_BIZNO_ALL")));
		System.out.println(Scramble.getScrResult("7401261899517","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("7401261899517","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("1611153047419","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("7401261899517","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("1611153047419","SCRAMBLE_RRN_ALL"));
		System.out.println(Scramble.getScrResult("740126","SCRAMBLE_YYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("19740126","SCRAMBLE_YYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("LEO7000@NAVER.COM","SCRAMBLE_EMAIL_ALL"));
//		System.out.println(Scramble.getScrResult("161115","SCRAMBLE_YYMMDD_ALL"));
//		System.out.println(Scramble.getScrResult("810813","SCRAMBLE_YYMMDD_ALL"));
//		System.out.println(Scramble.getScrResult("700927","SCRAMBLE_YYMMDD_ALL"));
//		System.out.println(Scramble.getScrResult("70/09/27","SCRAMBLE_YYMMDD_ALL"));
//		System.out.println(Scramble.getScrResult("70-09-27","SCRAMBLE_YYMMDD_ALL"));
//			System.out.println(Scramble.getScrResult("710327","SCRAMBLE_YYMMDD_ALL"));
//			System.out.println(Scramble.getScrResult("71/03/27","SCRAMBLE_YYMMDD_ALL"));
//			System.out.println(Scramble.getScrResult("71-03-27","SCRAMBLE_YYMMDD_ALL"));

			System.out.println(Scramble.getScrResult("780327","SCRAMBLE_YYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("78/03/27","SCRAMBLE_YYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("78-03-27","SCRAMBLE_YYMMDD_ALL"));

			System.out.println(Scramble.getScrResult("19780327","SCRAMBLE_YYYYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("1978/03/27","SCRAMBLE_YYYYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("1978-03-27","SCRAMBLE_YYYYMMDD_ALL"));

			System.out.println(Scramble.getScrResult("19740126","SCRAMBLE_YYYYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("1974/01/26","SCRAMBLE_YYYYMMDD_ALL"));
			System.out.println(Scramble.getScrResult("1974-01-26","SCRAMBLE_YYYYMMDD_ALL"));
		System.out.println(Scramble.getScrResult("#DEC#","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("zxcvasdfqwer","SCRAMBLE_NORMAL_LAST8"));
//		System.out.println(Scramble.getScrResult("zxcvasdfqwer","SCRAMBLE_NORMAL_FIRST8"));
//		System.out.println(Scramble.getScrResult("zxcvasdfqwer","SCRAMBLE_NORMAL_AFTER3"));
//		System.out.println(Scramble.getScrResult("zxcvasdfqwer","FIXED_1111"));
//		System.out.println(Scramble.getScrResult("zxcvasdfqwer","FIXED_*"));


//		System.out.println(Scramble.getScrResult("김민석 Kim Min Seok 850126","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("김석훈 Kim Seok Hoon 850126","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("박새미 Kim Sae Mi 810713","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("김다미 Kim Da Mi 810713","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("차지환 Cha Ji Hwan 1611151234567","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("차성환 Cha Ji Hyeok 1711161234567","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("차우혁 Cha Ji Hwan 1611151234567","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("차주혁 Cha Ji Hyeok 1711161234567 !@#$%  ","SCRAMBLE_NORMAL_ALL"));
//        System.out.println(Scramble.getScrResult("9sgr$^!@$2s#$366#*a18612++(+*%5^+426*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("sreg(99$^!@$2s#aeCT#*a18612++(+*%5^+426*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("$%s(99$^!@$2s#$366#*a18612++(+*%5^+426*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("%#7(99$^!@$2s#$366#*a18612++(+*%5^+426*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("sreg(99$^!@$2s#aeCT#*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("$%s(99$^!@$2s#$366#*","SCRAMBLE_NORMAL_ALL"));
//		System.out.println(Scramble.getScrResult("%#7(99$^!@$2s#$366#*a","SCRAMBLE_NORMAL_ALL"));
//
//		System.out.println("*SCRAMBLE".replace("SCRAMBLE", Scramble.getScrResult("%#7(99$^!@$2s#$366#*a","SCRAMBLE_NORMAL_ALL")));

	}
}
