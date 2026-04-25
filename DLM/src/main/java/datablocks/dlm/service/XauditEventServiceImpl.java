package datablocks.dlm.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.domain.XauditEventVO;
import datablocks.dlm.jdbc.XauditDataSourceHolder;

/**
 * X-Audit SDK 이벤트 수신 서비스 (2026-04-25 V3 리팩토링 — 수신 전용).
 *
 * <p>수신 파이프라인:
 * <pre>
 *   SDK POST → XauditEventVO  (외부 DTO, SDK 계약)
 *            → AccessLogVO   (내부 flat facade, Master+Sidecar 매핑)
 *            → AccessLogService.registerAccessLogBatch
 *                 → insertAccessLog (Master)
 *                 → insertAccessLogDetail (Sidecar, hasDetail() 일 때만)
 * </pre>
 *
 * <p>4 가지 수집 경로 (DB_AUDIT / DB_DAC / WAS_AGENT / WAS_SDK) 중 WAS_SDK 를 담당.
 * 저장 대상은 모두 TBL_ACCESS_LOG + TBL_ACCESS_LOG_DETAIL 로 일원화.
 *
 * <p>조회 화면은 통합 접속기록 화면(/accesslog/logs) 이 collect_type='WAS_SDK' 필터로
 * 처리하므로 본 서비스에 별도 조회 메서드는 두지 않는다.
 */
@Service
public class XauditEventServiceImpl implements XauditEventService {

    private static final Logger log = LoggerFactory.getLogger(XauditEventServiceImpl.class);
    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PK = DateTimeFormatter.ofPattern("yyyyMMdd");

    private static final String ACTION_HTTP_ACCESS   = "HTTP_ACCESS";
    private static final String COLLECT_TYPE_WAS_SDK = "WAS_SDK";
    private static final String ACCESS_CHANNEL_WAS   = "WAS";

    @Autowired private AccessLogService accessLogService; // 쓰기 — Master+Sidecar
    @Autowired private XauditDataSourceHolder xauditDsHolder;

    @Override
    public int receiveBatch(List<XauditEventVO> events) {
        if (events == null || events.isEmpty()) return 0;
        if (!xauditDsHolder.isReady()) {
            throw new IllegalStateException("XAUDIT_DB DataSource not ready");
        }
        List<AccessLogVO> logs = convert(events);
        if (logs.isEmpty()) return 0;
        accessLogService.registerAccessLogBatch(logs);
        return logs.size();
    }

    /** XauditEventVO 리스트를 AccessLogVO 리스트로 변환 (accessTime/partitionKey 보정 포함). */
    private List<AccessLogVO> convert(List<XauditEventVO> events) {
        String nowAccessTime = LocalDateTime.now().format(TS);
        String nowPartition  = LocalDateTime.now().format(PK);
        List<AccessLogVO> out = new ArrayList<>(events.size());
        for (XauditEventVO ev : events) {
            if (ev == null) continue;
            if (isBlank(ev.getAccessTime()))   ev.setAccessTime(nowAccessTime);
            if (isBlank(ev.getPartitionKey())) ev.setPartitionKey(nowPartition);

            boolean isAccess = "ACCESS".equalsIgnoreCase(ev.getType());
            boolean isSql    = "SQL".equalsIgnoreCase(ev.getType());
            if (!isAccess && !isSql) continue;

            out.add(toAccessLog(ev, isAccess));
        }
        return out;
    }

    /**
     * XauditEventVO → AccessLogVO 매핑.
     * <ul>
     *   <li>ACCESS 이벤트: action_type='HTTP_ACCESS', duration_ms = 요청 전체 시간</li>
     *   <li>SQL    이벤트: action_type=sqlType, duration_ms = 개별 SQL 시간,
     *       sql_text/bind_params 는 Sidecar 로 자동 라우팅</li>
     * </ul>
     */
    private AccessLogVO toAccessLog(XauditEventVO ev, boolean isAccess) {
        AccessLogVO a = new AccessLogVO();
        // 공통
        a.setSourceSystemId(ev.getServiceName());
        a.setUserAccount(ev.getUserId());
        a.setUserName(ev.getUserName());
        a.setDepartment(ev.getDepartment());
        a.setAccessTime(ev.getAccessTime());
        a.setClientIp(ev.getClientIp());
        a.setSessionId(ev.getSessionId());
        a.setCollectType(COLLECT_TYPE_WAS_SDK);
        a.setAccessChannel(ACCESS_CHANNEL_WAS);
        a.setPartitionKey(ev.getPartitionKey());
        // WAS 컨텍스트 (Master)
        a.setReqId(ev.getReqId());
        a.setServiceName(ev.getServiceName());
        a.setMenuId(ev.getMenuId());
        a.setUri(ev.getUri());
        a.setHttpMethod(ev.getHttpMethod());
        // Sidecar (가변 대형)
        a.setUserAgent(ev.getUserAgent());

        if (isAccess) {
            a.setActionType(ACTION_HTTP_ACCESS);
            a.setHttpStatus(ev.getHttpStatus());
            a.setDurationMs(ev.getTotalDurationMs());
            a.setResultCode(safe(ev.getResultCode(), "SUCCESS"));
        } else {
            a.setActionType(safe(ev.getSqlType(), "OTHER"));
            a.setTargetDb(ev.getTargetDb());
            a.setTargetTable(ev.getTargetTable());
            a.setAffectedRows(ev.getAffectedRows());
            a.setDurationMs(ev.getDurationMs());
            a.setResultCode(isBlank(ev.getErrorMessage()) ? "SUCCESS" : "FAIL");
            a.setPiiTypeCodes(trim(ev.getPiiDetected(), 200));
            a.setPiiDetectedFlag(isBlank(ev.getPiiDetected()) ? "N" : "Y");
            // Sidecar 필드
            a.setSqlId(ev.getSqlId());
            a.setSqlText(ev.getSqlText());
            a.setBindParams(ev.getBindParams());
            a.setErrorMessage(ev.getErrorMessage());
        }
        return a;
    }

    private static String safe(String s, String def) { return (s == null || s.isEmpty()) ? def : s; }
    private static boolean isBlank(String s) { return s == null || s.isEmpty(); }
    private static String trim(String s, int max) {
        if (s == null) return null;
        return s.length() <= max ? s : s.substring(0, max);
    }
}
