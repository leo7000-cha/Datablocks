package datablocks.dlm.agent.buffer;

import datablocks.dlm.agent.AgentConfig;
import datablocks.dlm.agent.model.AccessLogEntry;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 비동기 로그 버퍼.
 * WAS 스레드에서 논블로킹 offer → 별도 데몬 스레드(LogShipper)가 drain.
 */
public class LogBuffer {

    private static final LogBuffer INSTANCE = new LogBuffer();

    private LinkedBlockingQueue<AccessLogEntry> queue;
    private final AtomicLong dropCount = new AtomicLong(0);
    private final AtomicLong totalOffered = new AtomicLong(0);

    private LogBuffer() {}

    public static LogBuffer getInstance() {
        return INSTANCE;
    }

    public void init(AgentConfig config) {
        int capacity = config.getBufferCapacity();
        this.queue = new LinkedBlockingQueue<>(capacity);
        System.out.println("[XAudit-Agent] LogBuffer initialized: capacity=" + capacity);
    }

    /**
     * 논블로킹 offer. 큐 가득 차면 드롭 (WAS 성능 보호).
     * @return true if added, false if dropped
     */
    public boolean offer(AccessLogEntry entry) {
        if (queue == null) return false;
        totalOffered.incrementAndGet();
        boolean added = queue.offer(entry);
        if (!added) {
            dropCount.incrementAndGet();
        }
        return added;
    }

    /**
     * LogShipper가 호출. 최대 batchSize개를 큐에서 꺼냄.
     */
    public List<AccessLogEntry> drain(int batchSize) {
        List<AccessLogEntry> batch = new ArrayList<>(batchSize);
        if (queue != null) {
            queue.drainTo(batch, batchSize);
        }
        return batch;
    }

    public int size() {
        return queue != null ? queue.size() : 0;
    }

    public long getDropCount() {
        return dropCount.get();
    }

    public long getTotalOffered() {
        return totalOffered.get();
    }
}
