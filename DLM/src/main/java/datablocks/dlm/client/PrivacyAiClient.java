package datablocks.dlm.client;

import java.util.*;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * DLM Privacy-AI HTTP Client
 * Privacy-AI 서비스의 /api/v1/privacy/detect 엔드포인트를 호출하여
 * 테이블 단위 AI PII 탐지 결과를 반환한다.
 */
@Component
public class PrivacyAiClient {

    private static final Logger logger = LoggerFactory.getLogger(PrivacyAiClient.class);
    private static final ObjectMapper mapper = new ObjectMapper();

    private final RestTemplate restTemplate;

    public PrivacyAiClient() {
        this.restTemplate = new RestTemplate();
        // timeout은 RestTemplate 기본값 사용 (무한대) → Privacy-AI 내부에서 LLM timeout 관리
    }

    /**
     * AI PII 탐지 결과
     */
    public static class AiDetectResult {
        public String piiType;
        public int score;
        public String reason;

        public AiDetectResult(String piiType, int score, String reason) {
            this.piiType = piiType;
            this.score = score;
            this.reason = reason;
        }
    }

    /**
     * 컬럼 정보 (메타 + 샘플)
     */
    public static class ColumnDetectInfo {
        public String name;
        public String type;
        public String comment;
        public List<String> samples;

        public ColumnDetectInfo(String name, String type, String comment, List<String> samples) {
            this.name = name;
            this.type = type;
            this.comment = comment != null ? comment : "";
            this.samples = samples != null ? samples : Collections.emptyList();
        }
    }

    /**
     * 테이블 단위 AI PII 탐지 호출
     *
     * @param privacyAiUrl Privacy-AI 서비스 URL (예: http://dlm-privacy-ai:8000)
     * @param tableName    테이블명
     * @param schemaName   스키마명
     * @param columns      컬럼 정보 리스트
     * @return 컬럼명 → AiDetectResult 매핑. 실패 시 빈 Map 반환 (score=0 fallback)
     */
    public Map<String, AiDetectResult> detectPii(String privacyAiUrl, String tableName,
                                                   String schemaName, List<ColumnDetectInfo> columns) {
        Map<String, AiDetectResult> resultMap = new HashMap<>();

        if (privacyAiUrl == null || privacyAiUrl.isEmpty() || columns == null || columns.isEmpty()) {
            return resultMap;
        }

        try {
            // Build request JSON
            ObjectNode requestBody = mapper.createObjectNode();
            requestBody.put("table_name", tableName);
            requestBody.put("schema_name", schemaName != null ? schemaName : "");

            ArrayNode columnsArray = mapper.createArrayNode();
            for (ColumnDetectInfo col : columns) {
                ObjectNode colNode = mapper.createObjectNode();
                colNode.put("name", col.name);
                colNode.put("type", col.type);
                colNode.put("comment", col.comment);
                ArrayNode samplesArray = mapper.createArrayNode();
                if (col.samples != null) {
                    for (String sample : col.samples) {
                        if (sample != null) {
                            samplesArray.add(sample);
                        }
                    }
                }
                colNode.set("samples", samplesArray);
                columnsArray.add(colNode);
            }
            requestBody.set("columns", columnsArray);

            String url = privacyAiUrl.replaceAll("/+$", "") + "/api/v1/privacy/detect";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<String> entity = new HttpEntity<>(mapper.writeValueAsString(requestBody), headers);

            long startTime = System.currentTimeMillis();
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
            long elapsed = System.currentTimeMillis() - startTime;

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                JsonNode root = mapper.readTree(response.getBody());
                JsonNode results = root.get("results");
                if (results != null && results.isArray()) {
                    for (JsonNode item : results) {
                        String colName = item.has("column") ? item.get("column").asText() : "";
                        String piiType = item.has("pii_type") && !item.get("pii_type").isNull()
                                ? item.get("pii_type").asText() : null;
                        int score = item.has("score") ? item.get("score").asInt(0) : 0;
                        String reason = item.has("reason") ? item.get("reason").asText("") : "";
                        resultMap.put(colName, new AiDetectResult(piiType, score, reason));
                    }
                }
                logger.info("AI detect success: table={}, columns={}, elapsed={}ms, tokens={}",
                        tableName, columns.size(), elapsed,
                        root.has("token_usage") ? root.get("token_usage").asInt(0) : 0);
            }

        } catch (Exception e) {
            logger.error("AI detect failed for table {}: {}", tableName, e.getMessage());
            // Return empty map → caller treats missing entries as aiScore=0
        }

        return resultMap;
    }

    /**
     * LLM 연결 상태 확인
     */
    public Map<String, Object> checkLlmStatus(String privacyAiUrl) {
        Map<String, Object> status = new HashMap<>();
        try {
            String url = privacyAiUrl.replaceAll("/+$", "") + "/api/v1/privacy/llm-status";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                JsonNode root = mapper.readTree(response.getBody());
                status.put("enabled", root.has("enabled") && root.get("enabled").asBoolean());
                status.put("connected", root.has("connected") && root.get("connected").asBoolean());
                status.put("model", root.has("model") ? root.get("model").asText("") : "");
                status.put("error", root.has("error") ? root.get("error").asText("") : "");
                return status;
            }
        } catch (Exception e) {
            status.put("enabled", false);
            status.put("connected", false);
            status.put("model", "");
            status.put("error", "Privacy-AI 연결 실패: " + e.getMessage());
        }
        return status;
    }
}
