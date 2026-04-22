package datablocks.dlm.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.XauditEventVO;
import datablocks.dlm.mapper.XauditEventMapper;

@Service
public class XauditEventServiceImpl implements XauditEventService {

    private static final Logger log = LoggerFactory.getLogger(XauditEventServiceImpl.class);
    private static final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    private static final DateTimeFormatter PK = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final int BATCH_SIZE = 500;

    @Autowired
    private XauditEventMapper mapper;

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public int receiveBatch(List<XauditEventVO> events) {
        if (events == null || events.isEmpty()) return 0;

        List<XauditEventVO> accessList = new ArrayList<>();
        List<XauditEventVO> sqlList    = new ArrayList<>();
        String nowAccessTime = LocalDateTime.now().format(TS);
        String nowPartition  = LocalDateTime.now().format(PK);

        for (XauditEventVO ev : events) {
            if (ev == null) continue;
            // accessTime/partitionKey 가 빠져있으면 서버 시각으로 보정
            if (isBlank(ev.getAccessTime()))   ev.setAccessTime(nowAccessTime);
            if (isBlank(ev.getPartitionKey())) ev.setPartitionKey(nowPartition);
            if ("ACCESS".equalsIgnoreCase(ev.getType())) accessList.add(ev);
            else if ("SQL".equalsIgnoreCase(ev.getType())) sqlList.add(ev);
        }

        int inserted = 0;
        if (!accessList.isEmpty()) {
            String prev = safe(mapper.selectLastAccessHash(), "GENESIS");
            for (XauditEventVO v : accessList) {
                v.setHashPrev(prev);
                String cur = hash("ACCESS", v);
                v.setHashCur(cur);
                prev = cur;
            }
            inserted += chunkInsert(accessList, true);
        }
        if (!sqlList.isEmpty()) {
            String prev = safe(mapper.selectLastSqlHash(), "GENESIS");
            for (XauditEventVO v : sqlList) {
                v.setHashPrev(prev);
                String cur = hash("SQL", v);
                v.setHashCur(cur);
                prev = cur;
            }
            inserted += chunkInsert(sqlList, false);
        }
        return inserted;
    }

    private int chunkInsert(List<XauditEventVO> all, boolean access) {
        int total = 0;
        for (int i = 0; i < all.size(); i += BATCH_SIZE) {
            List<XauditEventVO> chunk = all.subList(i, Math.min(all.size(), i + BATCH_SIZE));
            total += access ? mapper.insertAccessLogBatch(chunk) : mapper.insertSqlLogBatch(chunk);
        }
        return total;
    }

    /**
     * 해시 입력: type|reqId|userId|accessTime|sqlText|prevHash
     * sqlText 는 ACCESS 에서는 uri+httpMethod 로 대체해 양쪽이 동일 함수로 처리되도록.
     */
    private String hash(String kind, XauditEventVO v) {
        try {
            StringBuilder sb = new StringBuilder();
            sb.append(kind).append('|')
              .append(safe(v.getReqId(),"")).append('|')
              .append(safe(v.getUserId(),"")).append('|')
              .append(safe(v.getAccessTime(),"")).append('|');
            if ("SQL".equals(kind)) {
                sb.append(safe(v.getSqlType(),"")).append(':')
                  .append(safe(v.getSqlText(),""));
            } else {
                sb.append(safe(v.getHttpMethod(),"")).append(':')
                  .append(safe(v.getUri(),""));
            }
            sb.append('|').append(safe(v.getHashPrev(),""));
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bs = md.digest(sb.toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(64);
            for (byte b : bs) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            log.warn("[X-Audit] hash calc failed: {}", e.toString());
            return "ERROR";
        }
    }

    private static String safe(String s, String def) { return (s == null || s.isEmpty()) ? def : s; }
    private static boolean isBlank(String s) { return s == null || s.isEmpty(); }

    // ===== 조회 =====
    @Override public List<XauditEventVO> getAccessList(Criteria cri) { return mapper.selectAccessList(cri); }
    @Override public int                 getAccessTotal(Criteria cri) { return mapper.selectAccessTotal(cri); }
    @Override public List<XauditEventVO> getSqlList(Criteria cri)    { return mapper.selectSqlList(cri); }
    @Override public int                 getSqlTotal(Criteria cri)   { return mapper.selectSqlTotal(cri); }
    @Override public List<XauditEventVO> getSqlByReqId(String reqId) { return mapper.selectSqlByReqId(reqId); }

    @Override public Map<String, Object> getDashboardCounts(String d) { return mapper.selectDashboardCounts(d); }
    @Override public List<Map<String, Object>> getHourlyTrend(String d) { return mapper.selectHourlyTrend(d); }
    @Override public List<Map<String, Object>> getServiceDistribution(String d) { return mapper.selectServiceDistribution(d); }
    @Override public List<Map<String, Object>> getPiiDistribution(String d) { return mapper.selectPiiDistribution(d); }
}
