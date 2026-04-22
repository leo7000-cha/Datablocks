package datablocks.dlm.xaudit.core;

import com.alibaba.ttl.TransmittableThreadLocal;

/**
 * 요청 컨텍스트를 스레드로 전파하는 홀더.
 *
 * 일반 {@code ThreadLocal} 이 아닌 Alibaba {@link TransmittableThreadLocal} 사용 —
 * {@code @Async} / {@code CompletableFuture} / {@code ThreadPoolTaskExecutor}
 * 에서 스레드가 재사용돼도 컨텍스트가 정확히 전파되도록 하기 위함.
 *
 * Filter {@code finally} 블록에서 반드시 {@link #clear()} 호출 — ThreadLocal 누수 방지.
 */
public final class XauditContextHolder {

    private static final TransmittableThreadLocal<XauditContext> HOLDER = new TransmittableThreadLocal<>();

    private XauditContextHolder() {}

    public static void set(XauditContext ctx) {
        HOLDER.set(ctx);
    }

    public static XauditContext get() {
        return HOLDER.get();
    }

    public static boolean hasContext() {
        return HOLDER.get() != null;
    }

    public static void clear() {
        HOLDER.remove();
    }
}
