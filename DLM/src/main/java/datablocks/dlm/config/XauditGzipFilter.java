package datablocks.dlm.config;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.GZIPInputStream;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;

/**
 * Content-Encoding: gzip 요청을 자동 해제하는 Filter.
 *
 * X-Audit SDK 가 배치 이벤트를 gzip 압축해서 보내므로 DLM 서버에서 디코딩 필요.
 * Tomcat/Spring Boot 는 기본적으로 request gzip 디코딩을 지원하지 않음.
 *
 * {@code /api/xaudit/**} URL 에만 적용하여 기존 엔드포인트 영향 zero.
 */
@Configuration
public class XauditGzipFilter {

    @Bean
    public FilterRegistrationBean<Filter> xauditGzipRequestFilter() {
        FilterRegistrationBean<Filter> reg = new FilterRegistrationBean<>();
        reg.setFilter(new GzipRequestFilter());
        reg.addUrlPatterns("/api/xaudit/*");
        reg.setName("xauditGzipRequestFilter");
        reg.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return reg;
    }

    static class GzipRequestFilter implements Filter {
        @Override
        public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
                throws IOException, ServletException {
            if (req instanceof HttpServletRequest) {
                HttpServletRequest hreq = (HttpServletRequest) req;
                String enc = hreq.getHeader("Content-Encoding");
                if (enc != null && enc.toLowerCase().contains("gzip")) {
                    chain.doFilter(new GzipInflatingRequest(hreq), res);
                    return;
                }
            }
            chain.doFilter(req, res);
        }
    }

    static class GzipInflatingRequest extends HttpServletRequestWrapper {
        private final byte[] body;

        GzipInflatingRequest(HttpServletRequest req) throws IOException {
            super(req);
            try (GZIPInputStream gis = new GZIPInputStream(req.getInputStream());
                 ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = gis.read(buf)) > 0) bos.write(buf, 0, n);
                this.body = bos.toByteArray();
            }
        }

        @Override public int getContentLength() { return body.length; }
        @Override public long getContentLengthLong() { return body.length; }
        @Override public String getHeader(String name) {
            if ("Content-Encoding".equalsIgnoreCase(name)) return null;
            if ("Content-Length".equalsIgnoreCase(name))  return String.valueOf(body.length);
            return super.getHeader(name);
        }

        @Override
        public ServletInputStream getInputStream() {
            InputStream src = new ByteArrayInputStream(body);
            return new ServletInputStream() {
                @Override public int read() throws IOException { return src.read(); }
                @Override public boolean isFinished() {
                    try { return src.available() == 0; } catch (IOException e) { return true; }
                }
                @Override public boolean isReady() { return true; }
                @Override public void setReadListener(jakarta.servlet.ReadListener rl) { /* no-op */ }
            };
        }
    }
}
