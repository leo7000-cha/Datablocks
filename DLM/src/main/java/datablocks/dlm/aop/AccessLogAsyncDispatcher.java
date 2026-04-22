package datablocks.dlm.aop;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import datablocks.dlm.domain.AccessLogVO;
import datablocks.dlm.service.AccessLogService;

/**
 * AOP가 수집한 AccessLogVO 를 별도 스레드풀에서 DB 에 적재.
 *
 * Aspect 와 분리된 Bean 이어야 {@code @Async} 프록시가 적용된다 (자가호출 금지).
 * 예외는 모두 흡수하여 비즈니스 흐름에 영향 없음.
 */
@Component
public class AccessLogAsyncDispatcher {

    private static final Logger log = LoggerFactory.getLogger(AccessLogAsyncDispatcher.class);

    @Autowired
    private AccessLogService accessLogService;

    @Autowired
    private AccessLogAopConfig aopConfig;

    @Async("accessLogAopExecutor")
    public void dispatch(AccessLogVO vo) {
        try {
            accessLogService.registerAccessLogFromAop(vo);
        } catch (Exception e) {
            aopConfig.incrementDropped();
            log.warn("[AOP] access log persist failed: user={}, menu={}, err={}",
                    vo != null ? vo.getUserAccount() : null,
                    vo != null ? vo.getTargetTable() : null,
                    e.getMessage());
        }
    }
}
