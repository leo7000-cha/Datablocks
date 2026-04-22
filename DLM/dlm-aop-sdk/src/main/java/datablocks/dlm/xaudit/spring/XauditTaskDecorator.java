package datablocks.dlm.xaudit.spring;

import java.util.Map;

import org.slf4j.MDC;
import org.springframework.core.task.TaskDecorator;

import datablocks.dlm.xaudit.core.XauditContext;
import datablocks.dlm.xaudit.core.XauditContextHolder;

/**
 * {@code ThreadPoolTaskExecutor#setTaskDecorator} 에 넣어주는 데코레이터.
 *
 * @Async / CompletableFuture 호출 시 부모 스레드의 X-Audit 컨텍스트와 MDC 를
 * 자식 스레드로 안전하게 전파·복원한다.
 *
 * 고객사가 별도 Executor 를 쓰는 경우 이 빈을 주입해 적용하면 된다.
 */
public class XauditTaskDecorator implements TaskDecorator {

    @Override
    public Runnable decorate(Runnable runnable) {
        XauditContext parentCtx = XauditContextHolder.get();
        Map<String, String> parentMdc = MDC.getCopyOfContextMap();
        return () -> {
            XauditContext prevCtx = XauditContextHolder.get();
            Map<String, String> prevMdc = MDC.getCopyOfContextMap();
            try {
                if (parentCtx != null) XauditContextHolder.set(parentCtx);
                if (parentMdc != null) MDC.setContextMap(parentMdc);
                runnable.run();
            } finally {
                if (prevCtx != null) XauditContextHolder.set(prevCtx);
                else                 XauditContextHolder.clear();
                if (prevMdc != null) MDC.setContextMap(prevMdc);
                else                 MDC.clear();
            }
        };
    }
}
