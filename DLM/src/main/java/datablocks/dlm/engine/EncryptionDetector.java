package datablocks.dlm.engine;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 암호화/해시 데이터 탐지 유틸리티
 * 샘플 데이터를 개별 분석하여 암호화 상태, 방법, 비율을 판별
 *
 * 탐지 전략 (per-value 분석):
 * 1. 각 샘플 값을 개별적으로 암호화 여부 판정
 * 2. 암호화된 값의 비율(ratio)을 계산
 * 3. 과반수 방법(method)으로 최종 결과 결정
 *
 * 이 방식의 장점:
 * - 평문과 암호화가 혼재된 컬럼 탐지 가능
 * - 마이그레이션 중인 컬럼 식별 가능 (ratio 50-89%)
 * - NULL/빈값은 분모에서 제외하여 정확한 비율 산출
 */
public class EncryptionDetector {

    // 상수
    public static final String STATUS_NONE = "NONE";
    public static final String STATUS_HASHED = "HASHED";
    public static final String STATUS_ENCRYPTED = "ENCRYPTED";
    public static final String STATUS_UNKNOWN = "UNKNOWN";

    private static final Pattern HEX_PATTERN = Pattern.compile("[0-9a-fA-F]+");
    private static final Pattern BASE64_PATTERN = Pattern.compile("[A-Za-z0-9+/]+={0,2}");

    // 최소 문자열 길이: 너무 짧으면 오탐 가능성
    private static final int MIN_VALUE_LENGTH = 16;
    // 엔트로피 임계값
    private static final double ENTROPY_THRESHOLD_HEX = 3.5;
    private static final double ENTROPY_THRESHOLD_GENERAL = 4.0;

    /**
     * 암호화 탐지 결과 (비율 포함)
     */
    public static class EncryptionResult {
        public final String status;    // NONE, HASHED, ENCRYPTED, UNKNOWN
        public final String method;    // SHA-256, MD5, BCrypt, AES/Base64 등
        public final int ratio;        // 암호화 비율 (0-100%)

        public EncryptionResult(String status, String method, int ratio) {
            this.status = status;
            this.method = method;
            this.ratio = ratio;
        }
    }

    /**
     * 개별 값의 암호화 판정 결과 (내부용)
     */
    private static class ValueClassification {
        final String status;   // NONE, HASHED, ENCRYPTED, UNKNOWN
        final String method;   // 구체적 방법

        ValueClassification(String status, String method) {
            this.status = status;
            this.method = method;
        }
    }

    /**
     * 샘플 값 목록을 분석하여 암호화 상태, 방법, 비율을 판별
     *
     * @param sampleValues 샘플 데이터 목록 (최대 5건)
     * @return EncryptionResult (status + method + ratio)
     */
    public static EncryptionResult detect(List<String> sampleValues) {
        // Guard: null 또는 빈 목록
        if (sampleValues == null || sampleValues.isEmpty()) {
            return new EncryptionResult(STATUS_NONE, null, 0);
        }

        // 유효한 값만 필터링 (null, 빈 문자열 제외 — 짧은 값도 평문으로 분류 포함)
        List<String> validValues = sampleValues.stream()
                .filter(v -> v != null && !v.trim().isEmpty())
                .map(String::trim)
                .collect(Collectors.toList());

        if (validValues.isEmpty()) {
            return new EncryptionResult(STATUS_NONE, null, 0);
        }

        // 각 값을 개별 분류
        List<ValueClassification> classifications = validValues.stream()
                .map(EncryptionDetector::classifyValue)
                .collect(Collectors.toList());

        // 암호화된 값 카운트 (HASHED, ENCRYPTED, UNKNOWN)
        long encryptedCount = classifications.stream()
                .filter(c -> !STATUS_NONE.equals(c.status))
                .count();

        // 비율 계산 (유효값 대비 암호화 비율)
        int ratio = (int) Math.round((double) encryptedCount / validValues.size() * 100);

        // 비율이 0이면 NONE
        if (ratio == 0) {
            return new EncryptionResult(STATUS_NONE, null, 0);
        }

        // 과반수 방법(method) 결정: 가장 많이 탐지된 status+method 조합
        Map<String, Integer> methodCounts = new HashMap<>();
        Map<String, String> methodToStatus = new HashMap<>();

        for (ValueClassification c : classifications) {
            if (!STATUS_NONE.equals(c.status)) {
                String key = c.status + "|" + (c.method != null ? c.method : "");
                methodCounts.merge(key, 1, Integer::sum);
                methodToStatus.put(key, c.status);
            }
        }

        // 최다 빈도 방법 선택
        String bestKey = methodCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(STATUS_UNKNOWN + "|");

        String[] parts = bestKey.split("\\|", -1);
        String bestStatus = parts[0];
        String bestMethod = parts.length > 1 && !parts[1].isEmpty() ? parts[1] : null;

        return new EncryptionResult(bestStatus, bestMethod, ratio);
    }

    /**
     * 개별 값의 암호화 여부 판정
     */
    private static ValueClassification classifyValue(String value) {
        if (value == null || value.isEmpty()) {
            return new ValueClassification(STATUS_NONE, null);
        }

        int len = value.length();

        // 너무 짧은 값은 평문으로 간주
        if (len < MIN_VALUE_LENGTH) {
            return new ValueClassification(STATUS_NONE, null);
        }

        // 1. Known prefix 체크 (최우선)
        if (value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$")) {
            return new ValueClassification(STATUS_HASHED, "BCrypt");
        }
        if (value.startsWith("$argon2")) {
            return new ValueClassification(STATUS_HASHED, "Argon2");
        }
        if (value.startsWith("{SSHA}") || value.startsWith("{SHA}") || value.startsWith("{PBKDF2}")) {
            return new ValueClassification(STATUS_HASHED, "LDAP-SHA");
        }

        // 2. Hex 문자셋 + 알려진 해시 길이
        if (isHexString(value)) {
            String hashMethod = matchKnownHashLength(len);
            if (hashMethod != null) {
                // 엔트로피 추가 검증: 실제 랜덤인지 확인
                double entropy = shannonEntropy(value);
                if (entropy >= ENTROPY_THRESHOLD_HEX) {
                    return new ValueClassification(STATUS_HASHED, hashMethod);
                }
            }
            // 알려지지 않은 길이지만 Hex + 높은 엔트로피
            if (len >= 32) {
                double entropy = shannonEntropy(value);
                if (entropy >= ENTROPY_THRESHOLD_HEX) {
                    return new ValueClassification(STATUS_HASHED, "HASH(" + len + "chars)");
                }
            }
        }

        // 3. Base64 + 높은 엔트로피 → 대칭 암호화
        if (isBase64String(value) && len % 4 == 0 && len >= 24) {
            double entropy = shannonEntropy(value);
            if (entropy >= ENTROPY_THRESHOLD_GENERAL) {
                return new ValueClassification(STATUS_ENCRYPTED, "AES/Base64");
            }
        }

        // 4. 높은 엔트로피 (Hex도 Base64도 아닌 경우)
        double entropy = shannonEntropy(value);
        if (entropy >= ENTROPY_THRESHOLD_GENERAL && len >= 32) {
            return new ValueClassification(STATUS_UNKNOWN, null);
        }

        // 5. Default: 평문
        return new ValueClassification(STATUS_NONE, null);
    }

    /**
     * Hex 문자열 판별 (0-9, a-f, A-F만 포함)
     */
    private static boolean isHexString(String s) {
        return s != null && !s.isEmpty() && HEX_PATTERN.matcher(s).matches();
    }

    /**
     * Base64 문자열 판별 (A-Z, a-z, 0-9, +, /, = 만 포함)
     */
    private static boolean isBase64String(String s) {
        return s != null && !s.isEmpty() && BASE64_PATTERN.matcher(s).matches();
    }

    /**
     * 알려진 해시 길이 매칭 (Hex 기준)
     */
    private static String matchKnownHashLength(int length) {
        switch (length) {
            case 32:  return "MD5";
            case 40:  return "SHA-1";
            case 56:  return "SHA-224";
            case 64:  return "SHA-256";
            case 96:  return "SHA-384";
            case 128: return "SHA-512";
            default:  return null;
        }
    }

    /**
     * Shannon 엔트로피 계산
     * H = -sum(p_i * log2(p_i))
     * 완전 랜덤 Hex: ~4.0, 완전 랜덤 Base64: ~5.9, 일반 텍스트: ~2.5-3.5
     */
    private static double shannonEntropy(String s) {
        if (s == null || s.isEmpty()) {
            return 0.0;
        }

        int[] freq = new int[256];
        for (char c : s.toCharArray()) {
            if (c < 256) {
                freq[c]++;
            }
        }

        double entropy = 0.0;
        double len = s.length();
        for (int f : freq) {
            if (f > 0) {
                double p = f / len;
                entropy -= p * (Math.log(p) / Math.log(2));
            }
        }
        return entropy;
    }
}
