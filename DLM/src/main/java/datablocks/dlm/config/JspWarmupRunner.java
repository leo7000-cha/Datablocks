package datablocks.dlm.config;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * 부팅 직후 localhost 로 자기 자신에게 HTTP 요청을 날려 Tomcat / Jasper / Spring 디스패처를 미리 웜업한다.
 * 첫 사용자가 /piidiscovery 류 대형 JSP 에서 겪던 "처음만 느림" 현상을 완화한다.
 *
 * 인증이 없는 /customLogin, /accessError 를 먼저 쳐서 Jasper 엔진을 부팅시키고,
 * 이어서 /piidiscovery/index 에 prefetch 성 요청을 보낸다. 로그인 리다이렉트로 302 가 떨어지더라도
 * Jasper 는 매핑된 JSP 를 이미 컴파일해 두므로 첫 실사용자 체감은 크게 개선된다.
 */
@Component
public class JspWarmupRunner {

    private static final Logger log = LoggerFactory.getLogger(JspWarmupRunner.class);

    @Value("${server.port:8080}")
    private int serverPort;

    @Value("${dlm.warmup.enabled:true}")
    private boolean enabled;

    @EventListener(ApplicationReadyEvent.class)
    public void warmup() {
        if (!enabled) {
            return;
        }
        // 기동 직후 별도 스레드에서 비동기 실행 (메인 기동 스레드 블로킹 금지)
        Thread t = new Thread(this::runWarmup, "dlm-jsp-warmup");
        t.setDaemon(true);
        t.start();
    }

    private void runWarmup() {
        // /customLogin, /accessError 는 permitAll 이라 인증 없이 컴파일 유도 가능.
        // 나머지 JSP 는 /__warmup/jsp?view=... 로 우회 (WarmupController 가 loopback 제한 + view whitelist).
        List<String> paths = List.of(
                "/customLogin",
                "/accessError",
                "/__warmup/jsp?view=hub",
                "/__warmup/jsp?view=index",
                "/__warmup/jsp?view=piidashboard/dashboard",
                "/__warmup/jsp?view=piidiscovery/index",
                "/__warmup/jsp?view=piidiscovery/dashboard",
                "/__warmup/jsp?view=piidiscovery/jobs",
                "/__warmup/jsp?view=piidiscovery/results",
                "/__warmup/jsp?view=piidiscovery/columns",
                "/__warmup/jsp?view=piidiscovery/rules",
                "/__warmup/jsp?view=piidiscovery/settings",
                "/__warmup/jsp?view=accesslog/index",
                "/__warmup/jsp?view=accesslog/settings",
                "/__warmup/jsp?view=piijob/list",
                "/__warmup/jsp?view=piirecovery/list",
                "/__warmup/jsp?view=piirecovery/orderlist",
                "/__warmup/jsp?view=piirecovery/joblist"
        );

        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(3))
                .followRedirects(HttpClient.Redirect.NEVER)
                .build();

        String base = "http://127.0.0.1:" + serverPort;
        long started = System.currentTimeMillis();
        int ok = 0;

        for (String p : paths) {
            try {
                HttpRequest req = HttpRequest.newBuilder()
                        .uri(URI.create(base + p))
                        .timeout(Duration.ofSeconds(30))
                        .header("User-Agent", "DLM-Warmup/1.0")
                        .GET()
                        .build();
                HttpResponse<Void> res = client.send(req, HttpResponse.BodyHandlers.discarding());
                log.warn("[INFO] JSP warmup {} -> {}", p, res.statusCode());
                ok++;
            } catch (Exception e) {
                log.warn("JSP warmup failed {}: {}", p, e.getMessage());
            }
        }

        log.warn("[INFO] JSP warmup done ({} / {} in {}ms)", ok, paths.size(), System.currentTimeMillis() - started);
    }
}
