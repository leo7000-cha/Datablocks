package datablocks.dlm.aop.util;

import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletRequest;

/**
 * HttpServletRequest 에서 클라이언트 IP/UA 추출.
 * X-Forwarded-For → X-Real-IP → remoteAddr 순으로 탐색.
 * WAF/프록시 체인에서 가장 앞단 IP 채택.
 *
 * 주의: 신뢰 가능한 프록시 내부에서만 XFF 를 신뢰해야 하며,
 * 외부 직접 요청에서는 remoteAddr 만 사용. 본 구현은 WAF 종단 이후를 전제한다.
 */
@Component
public class ClientInfoExtractor {

    public String getClientIp(HttpServletRequest request) {
        if (request == null) return null;
        String ip = request.getHeader("X-Forwarded-For");
        if (isBlank(ip)) ip = request.getHeader("X-Real-IP");
        if (isBlank(ip)) ip = request.getRemoteAddr();
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }

    public String getUserAgent(HttpServletRequest request) {
        if (request == null) return null;
        return request.getHeader("User-Agent");
    }

    private boolean isBlank(String s) {
        return s == null || s.isEmpty() || "unknown".equalsIgnoreCase(s);
    }
}
