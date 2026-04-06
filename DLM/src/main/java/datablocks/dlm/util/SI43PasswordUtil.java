package datablocks.dlm.util;

import java.security.MessageDigest;
import java.util.Base64;

public final class SI43PasswordUtil {

    private SI43PasswordUtil() {}

    /** 사진 코드의 상수: "04" */
    private static final String ALGORITHM_ID = "04";

    /** 평문 → 고객사 방식 암호문(Base64 텍스트) */
    public static String mkpwd(String pwd) {
        byte[] madePwd = null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            // 사진에선 문자셋 미지정 (시스템 기본 인코딩 사용)
            madePwd = setPwd(md.digest(pwd.getBytes()));
        } catch (Exception e) {
            madePwd = null; // 사진 코드 그대로
        }
        // return Base64Encode(decodeHex(algorythmID + encodeHex(madePwd)));
        return base64Encode(
                decodeHex(ALGORITHM_ID + encodeHex(madePwd))
        );
    }

    /** 사진의 setPwd: 단순 바이트 복사 */
    private static byte[] setPwd(byte[] a) {
        if (a == null) return null;
        byte[] ret = new byte[a.length];
        for (int i = 0; i < ret.length; i++) ret[i] = a[i];
        return ret;
    }

    /** 사진의 encodeHex: 바이트 배열 -> 대문자 HEX 문자열 */
    private static String encodeHex(byte[] a) {
        if (a == null) return null;
        final String HEXA = "0123456789ABCDEF";
        byte[] temp = new byte[a.length * 2];
        int x = 0;
        for (int i = 0; i < a.length; i++) {
            int v = a[i] & 0xFF;
            temp[x++] = (byte) HEXA.charAt((v >> 4) & 0x0F);
            temp[x++] = (byte) HEXA.charAt(v & 0x0F);
        }
        return new String(temp);
    }

    /** 사진의 decodeHex: HEX(2글자=1바이트) -> 바이트 배열 */
    private static byte[] decodeHex(String s) {
        if (s == null) return null;
        int len = s.length() / 2;
        byte[] temp = new byte[len];
        for (int i = 0; i < len; i++) {
            int p = i * 2;
            int hi = checkHexa((byte) s.charAt(p));
            int lo = checkHexa((byte) s.charAt(p + 1));
            temp[i] = (byte) ((hi << 4) + (lo << 0));
        }
        return temp;
    }

    /** 사진의 checkHexa 그대로(A..F, a..f, 0..9) */
    private static int checkHexa(byte ch) {
        if ((ch >= 65) && (ch <= 70))  return ch - 65 + 10;  // 'A'..'F'
        if ((ch >= 97) && (ch <= 102)) return ch - 97 + 10;  // 'a'..'f'
        if ((ch >= 48) && (ch <= 57))  return ch - 48;       // '0'..'9'
        return -1;
    }

    /** 사진의 Base64Encode(data) 대응 */
    private static String base64Encode(byte[] data) {
        // 사진은 new String(Base64.encode(data)) 형태 — 동일 텍스트 결과
        return Base64.getEncoder().encodeToString(data);
    }
}

