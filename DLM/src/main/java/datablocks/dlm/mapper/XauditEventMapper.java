package datablocks.dlm.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.XauditEventVO;

/**
 * X-Audit 이벤트 수신/조회 매퍼.
 */
public interface XauditEventMapper {

    // ===== 수신 =====
    int insertAccessLog(XauditEventVO vo);
    int insertAccessLogBatch(@Param("list") List<XauditEventVO> list);

    int insertSqlLog(XauditEventVO vo);
    int insertSqlLogBatch(@Param("list") List<XauditEventVO> list);

    /** 해시체인용 — 가장 최근 hash_cur */
    String selectLastAccessHash();
    String selectLastSqlHash();

    // ===== 조회 =====
    List<XauditEventVO> selectAccessList(Criteria cri);
    int                  selectAccessTotal(Criteria cri);

    List<XauditEventVO> selectSqlByReqId(@Param("reqId") String reqId);

    List<XauditEventVO> selectSqlList(Criteria cri);
    int                  selectSqlTotal(Criteria cri);

    /** 대시보드: 시간대별 요청 수 */
    List<Map<String, Object>> selectHourlyTrend(@Param("date") String yyyymmdd);

    /** 대시보드: 서비스별 요청 수 */
    List<Map<String, Object>> selectServiceDistribution(@Param("date") String yyyymmdd);

    /** 대시보드: PII 탐지 집계 */
    List<Map<String, Object>> selectPiiDistribution(@Param("date") String yyyymmdd);

    /** 대시보드: 요약 카운트 */
    Map<String, Object> selectDashboardCounts(@Param("date") String yyyymmdd);
}
