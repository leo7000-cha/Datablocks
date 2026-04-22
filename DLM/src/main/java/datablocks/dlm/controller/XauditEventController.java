package datablocks.dlm.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import datablocks.dlm.domain.XauditEventVO;
import datablocks.dlm.service.XauditEventService;

/**
 * X-Audit SDK 수신 엔드포인트 (고객사 처리계 → DLM).
 *
 * 이 컨트롤러는 /api/xaudit/** 로 묶이며 SecurityConfig 에서 permitAll + CSRF 무시.
 * API Key 검증은 신규 SDK Phase 에서 별도 Interceptor 로 추가 가능.
 */
@Controller
@RequestMapping("/api/xaudit")
public class XauditEventController {

    private static final Logger log = LoggerFactory.getLogger(XauditEventController.class);

    @Autowired
    private XauditEventService service;

    @PostMapping(path = "/events", consumes = "application/json")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> receiveEvents(@RequestBody List<XauditEventVO> events) {
        Map<String, Object> resp = new HashMap<>();
        try {
            int n = service.receiveBatch(events);
            resp.put("success", true);
            resp.put("received", events == null ? 0 : events.size());
            resp.put("inserted", n);
        } catch (Exception e) {
            log.warn("[X-Audit] receive failed: {}", e.toString());
            resp.put("success", false);
            resp.put("message", e.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
        return ResponseEntity.ok(resp);
    }
}
