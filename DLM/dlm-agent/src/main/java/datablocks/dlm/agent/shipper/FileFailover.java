package datablocks.dlm.agent.shipper;

import datablocks.dlm.agent.AgentConfig;
import datablocks.dlm.agent.model.AccessLogEntry;
import com.google.gson.Gson;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * 전송 실패 시 로컬 파일에 저장 (폴백).
 * DLM 서버 복구 후 수동 또는 자동 재전송 가능.
 */
public class FileFailover {

    private static final FileFailover INSTANCE = new FileFailover();
    private static final Gson GSON = new Gson();

    private String failoverDir;

    private FileFailover() {}

    public static FileFailover getInstance() {
        return INSTANCE;
    }

    public void init(AgentConfig config) {
        this.failoverDir = config.getFailoverDir();
        try {
            Path dir = Paths.get(failoverDir);
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
            }
        } catch (IOException e) {
            System.err.println("[XAudit-Agent] Failed to create failover dir: " + e.getMessage());
        }
    }

    /**
     * 전송 실패 배치를 파일로 저장.
     */
    public void save(List<AccessLogEntry> batch) {
        if (batch == null || batch.isEmpty()) return;

        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss_SSS").format(new Date());
        String fileName = "dlm-agent-failover-" + timestamp + ".json";
        Path filePath = Paths.get(failoverDir, fileName);

        try (Writer writer = new BufferedWriter(
                new OutputStreamWriter(new FileOutputStream(filePath.toFile()), StandardCharsets.UTF_8))) {
            GSON.toJson(batch, writer);
            System.out.println("[XAudit-Agent] Failover saved: " + filePath + " (" + batch.size() + " entries)");
        } catch (IOException e) {
            System.err.println("[XAudit-Agent] Failover save failed: " + e.getMessage());
        }
    }
}
