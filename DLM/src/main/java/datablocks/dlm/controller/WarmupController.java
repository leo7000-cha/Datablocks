package datablocks.dlm.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Collections;
import java.util.Enumeration;
import java.util.Map;
import java.util.Set;

/**
 * JSP 웜업 전용 엔드포인트.
 *
 * 보안 정책:
 *  1) SecurityConfig 에서 /__warmup/** 는 permitAll (인증 우회).
 *  2) 호출자의 RemoteAddr 가 loopback (127.0.0.1/::1) 이 아니면 404.
 *  3) 허용된 view name 만 렌더 (화이트리스트).
 *
 * 동작: JSP 스펙의 'jsp_precompile=true' 파라미터를 붙여 Jasper 에게 컴파일만 유도하고 실행은 생략한다.
 *       첫 실사용자의 대형 JSP 첫 진입 지연을 제거한다. 실행이 생략되므로 인증/모델 누락 런타임 오류가 없다.
 */
@Controller
@RequestMapping("/__warmup")
public class WarmupController {

    private static final Logger log = LoggerFactory.getLogger(WarmupController.class);

    private static final Set<String> ALLOWED_VIEWS = Set.of(
            "hub",
            "index",
            "customLogin",
            "piidashboard/dashboard",
            "piidiscovery/index",
            "piidiscovery/dashboard",
            "piidiscovery/jobs",
            "piidiscovery/results",
            "piidiscovery/columns",
            "piidiscovery/rules",
            "piidiscovery/piipolicy",
            "piidiscovery/settings",
            "accesslog/index",
            "accesslog/settings",
            "piijob/list",
            "piijob/get",
            "piistep/list",
            "piirecovery/list",
            "piirecovery/orderlist",
            "piirecovery/joblist"
    );

    @GetMapping("/jsp")
    @ResponseBody
    public String warmupJsp(@RequestParam("view") String view,
                            HttpServletRequest request,
                            HttpServletResponse response) {
        String addr = request.getRemoteAddr();
        boolean local = "127.0.0.1".equals(addr) || "0:0:0:0:0:0:0:1".equals(addr) || "::1".equals(addr);
        if (!local || !ALLOWED_VIEWS.contains(view)) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return "";
        }
        String jspPath = "/WEB-INF/views/" + view + ".jsp";
        try {
            HttpServletRequest precompileReq = new PrecompileRequestWrapper(request);
            RequestDispatcher rd = request.getRequestDispatcher(jspPath);
            if (rd == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return "";
            }
            // jsp_precompile 플래그가 붙은 요청으로 include → Jasper 는 .jsp 를 컴파일하되 실행 skip
            rd.include(precompileReq, response);
            return "OK " + view;
        } catch (Exception e) {
            log.debug("Warmup include failed for {}: {}", view, e.toString());
            return "SKIP " + view;
        }
    }

    /** 원 요청의 파라미터에 jsp_precompile=true 를 추가해 노출하는 래퍼. */
    private static final class PrecompileRequestWrapper extends HttpServletRequestWrapper {
        PrecompileRequestWrapper(HttpServletRequest req) { super(req); }

        @Override
        public String getParameter(String name) {
            if ("jsp_precompile".equals(name)) return "true";
            return super.getParameter(name);
        }

        @Override
        public Map<String, String[]> getParameterMap() {
            Map<String, String[]> base = super.getParameterMap();
            java.util.HashMap<String, String[]> merged = new java.util.HashMap<>(base);
            merged.put("jsp_precompile", new String[]{"true"});
            return Collections.unmodifiableMap(merged);
        }

        @Override
        public Enumeration<String> getParameterNames() {
            java.util.Set<String> names = new java.util.LinkedHashSet<>();
            Enumeration<String> base = super.getParameterNames();
            while (base.hasMoreElements()) names.add(base.nextElement());
            names.add("jsp_precompile");
            return Collections.enumeration(names);
        }

        @Override
        public String[] getParameterValues(String name) {
            if ("jsp_precompile".equals(name)) return new String[]{"true"};
            return super.getParameterValues(name);
        }

        @Override
        public String getQueryString() {
            String q = super.getQueryString();
            return (q == null || q.isEmpty()) ? "jsp_precompile=true" : q + "&jsp_precompile=true";
        }
    }
}
