package datablocks.dlm.xaudit.core;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;
import java.util.zip.GZIPOutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import datablocks.dlm.xaudit.spring.XauditProperties;

/**
 * 큐에서 이벤트를 꺼내 gzip + JSON 으로 DLM 수집 서버에 배치 POST.
 *
 * - HttpURLConnection 만 사용 (외부 HTTP 클라이언트 의존성 zero)
 * - 실패 시 exponential backoff, 3회 재시도 후 버림
 * - 호출자 스레드 영향 zero (전용 daemon thread)
 */
public class XauditHttpSender {

    private static final Logger log = LoggerFactory.getLogger(XauditHttpSender.class);

    private static final ObjectMapper MAPPER = new ObjectMapper()
            .disable(SerializationFeature.FAIL_ON_EMPTY_BEANS)
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    private final XauditEventQueue queue;
    private final XauditProperties props;

    private final AtomicBoolean running = new AtomicBoolean(false);
    private final AtomicLong sentBatches = new AtomicLong();
    private final AtomicLong sentEvents  = new AtomicLong();
    private final AtomicLong failedBatches = new AtomicLong();

    private ExecutorService workers;

    public XauditHttpSender(XauditEventQueue queue, XauditProperties props) {
        this.queue = queue;
        this.props = props;
    }

    public void start() {
        if (!running.compareAndSet(false, true)) return;
        int n = Math.max(1, props.getBatch().getWorkerThreads());
        workers = Executors.newFixedThreadPool(n, r -> {
            Thread t = new Thread(r, "xaudit-sender");
            t.setDaemon(true);
            return t;
        });
        for (int i = 0; i < n; i++) workers.submit(this::loop);
        log.info("[X-Audit] HTTP sender started (workers={}, url={})", n, props.getServer().getUrl());
    }

    public void stop() {
        if (!running.compareAndSet(true, false)) return;
        if (workers != null) {
            workers.shutdown();
            try {
                workers.awaitTermination(5, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        // 잔여 이벤트 1회 flush 시도
        List<XauditEvent> leftover = queue.drainAll();
        if (!leftover.isEmpty()) {
            try { postOnce(leftover); } catch (Exception ignore) {}
        }
        log.info("[X-Audit] HTTP sender stopped (sent={} failed={})",
                sentBatches.get(), failedBatches.get());
    }

    private void loop() {
        List<XauditEvent> batch = new java.util.ArrayList<>(props.getBatch().getSize());
        while (running.get()) {
            batch.clear();
            try {
                int n = queue.drainTo(batch, props.getBatch().getSize(),
                        props.getBatch().getFlushIntervalMs());
                if (n == 0) continue;
                sendWithRetry(batch);
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                break;
            } catch (Throwable t) {
                // sender 루프는 절대 죽으면 안됨
                log.warn("[X-Audit] sender loop error: {}", t.toString());
            }
        }
    }

    private void sendWithRetry(List<XauditEvent> batch) {
        long backoff = 200L;
        for (int attempt = 1; attempt <= 3; attempt++) {
            try {
                postOnce(batch);
                sentBatches.incrementAndGet();
                sentEvents.addAndGet(batch.size());
                return;
            } catch (Exception e) {
                if (attempt == 3) {
                    failedBatches.incrementAndGet();
                    log.warn("[X-Audit] send failed after {} attempts, dropping batch of {}: {}",
                            attempt, batch.size(), e.toString());
                    return;
                }
                try { Thread.sleep(backoff); } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt(); return;
                }
                backoff *= 2;
            }
        }
    }

    private void postOnce(List<XauditEvent> batch) throws IOException {
        byte[] payload = MAPPER.writeValueAsBytes(batch);
        byte[] gz;
        try (ByteArrayOutputStream bos = new ByteArrayOutputStream();
             GZIPOutputStream g = new GZIPOutputStream(bos)) {
            g.write(payload);
            g.finish();
            gz = bos.toByteArray();
        }
        URL url = new URL(props.getServer().getUrl());
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setConnectTimeout(props.getServer().getConnectTimeoutMs());
        con.setReadTimeout(props.getServer().getReadTimeoutMs());
        con.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        con.setRequestProperty("Content-Encoding", "gzip");
        con.setRequestProperty("X-Xaudit-Service", nullSafe(props.getServiceName()));
        if (!isBlank(props.getServer().getApiKey())) {
            con.setRequestProperty("X-API-KEY", props.getServer().getApiKey());
        }
        try (OutputStream os = con.getOutputStream()) {
            os.write(gz);
        }
        int code = con.getResponseCode();
        if (code < 200 || code >= 300) {
            String err = readAll(con.getErrorStream());
            throw new IOException("HTTP " + code + ": " + (err == null ? "" : err));
        }
        // 성공 응답 폐기
        try (InputStream in = con.getInputStream()) {
            byte[] buf = new byte[1024];
            while (in.read(buf) > 0) {/* drain */}
        } catch (IOException ignore) {}
    }

    private static String readAll(InputStream in) {
        if (in == null) return null;
        try (ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
            byte[] buf = new byte[1024];
            int n;
            while ((n = in.read(buf)) > 0) bos.write(buf, 0, n);
            return new String(bos.toByteArray(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            return null;
        }
    }

    private static boolean isBlank(String s) { return s == null || s.isEmpty(); }
    private static String nullSafe(String s) { return s == null ? "" : s; }

    public long getSentBatches()   { return sentBatches.get(); }
    public long getSentEvents()    { return sentEvents.get(); }
    public long getFailedBatches() { return failedBatches.get(); }
}
