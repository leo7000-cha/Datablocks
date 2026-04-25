package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.XauditEventVO;

/**
 * X-Audit SDK 수신 서비스 인터페이스.
 *
 * <p>2026-04-25 리팩토링: 조회 화면(/xaudit/**) 이 통합 접속기록 화면(/accesslog/**)
 * 으로 흡수되면서 조회 메서드는 제거됨. 본 서비스는 SDK 수신 전용.
 */
public interface XauditEventService {

    /** 배치 수신 — ACCESS/SQL 이벤트를 AccessLogVO 로 변환 후 통합 테이블에 적재. */
    int receiveBatch(List<XauditEventVO> events);
}
