package datablocks.dlm.xaudit.core;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 감사 이벤트를 비동기 전송 워커에 전달하는 중간 큐.
 *
 * 포화 시 offer() 가 false 를 반환 → DROP + warn (동기 전송 하지 않음).
 * 서비스 응답 지연이 절대 발생하지 않도록 설계.
 */
public class XauditEventQueue {

    private static final Logger log = LoggerFactory.getLogger(XauditEventQueue.class);

    private final BlockingQueue<XauditEvent> queue;
    private final AtomicLong enqueued = new AtomicLong();
    private final AtomicLong dropped  = new AtomicLong();

    public XauditEventQueue(int capacity) {
        this.queue = new LinkedBlockingQueue<>(Math.max(capacity, 100));
    }

    public void offer(XauditEvent ev) {
        if (ev == null) return;
        if (queue.offer(ev)) {
            enqueued.incrementAndGet();
        } else {
            long n = dropped.incrementAndGet();
            if (n == 1 || n % 1000 == 0) {
                log.warn("[X-Audit] event queue full, dropped {} events so far", n);
            }
        }
    }

    /** 최대 batchSize 개를 최대 maxWaitMs 동안 모아서 반환. drained 개수 반환. */
    public int drainTo(List<XauditEvent> sink, int batchSize, long maxWaitMs) throws InterruptedException {
        XauditEvent first = queue.poll(maxWaitMs, TimeUnit.MILLISECONDS);
        if (first == null) return 0;
        sink.add(first);
        queue.drainTo(sink, batchSize - 1);
        return sink.size();
    }

    public int size() { return queue.size(); }
    public long enqueuedCount() { return enqueued.get(); }
    public long droppedCount()  { return dropped.get(); }

    /** 셧다운 시 잔여 이벤트 flush 용 (non-blocking drain) */
    public List<XauditEvent> drainAll() {
        List<XauditEvent> all = new ArrayList<>(queue.size());
        queue.drainTo(all);
        return all;
    }
}
