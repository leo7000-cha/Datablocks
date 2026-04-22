package datablocks.dlm.service;

import java.util.List;
import java.util.Map;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.XauditEventVO;

public interface XauditEventService {

    /** 배치 수신 — ACCESS/SQL 타입별로 분리 후 해시체인 생성 + bulk insert */
    int receiveBatch(List<XauditEventVO> events);

    // 조회
    List<XauditEventVO> getAccessList(Criteria cri);
    int                 getAccessTotal(Criteria cri);

    List<XauditEventVO> getSqlList(Criteria cri);
    int                 getSqlTotal(Criteria cri);

    List<XauditEventVO> getSqlByReqId(String reqId);

    // 대시보드
    Map<String, Object> getDashboardCounts(String yyyymmdd);
    List<Map<String, Object>> getHourlyTrend(String yyyymmdd);
    List<Map<String, Object>> getServiceDistribution(String yyyymmdd);
    List<Map<String, Object>> getPiiDistribution(String yyyymmdd);
}
