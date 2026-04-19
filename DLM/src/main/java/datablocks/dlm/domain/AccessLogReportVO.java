package datablocks.dlm.domain;

import lombok.Data;

/**
 * 접속기록 보고서 VO
 */
@Data
public class AccessLogReportVO {
    private Long reportId;
    private String reportType;      // PERIODIC / ANOMALY / USER_BEHAVIOR / COMPLIANCE / AI_ANALYSIS
    private String reportName;
    private String reportStatus;    // GENERATING / COMPLETED / FAILED
    private String dateFrom;        // YYYY-MM-DD
    private String dateTo;          // YYYY-MM-DD
    private String reportFormat;    // PDF / XLSX
    private String generatedBy;
    private String generatedAt;
    private String completedAt;
    private Long fileSize;
    private String summaryJson;
    private String errorMsg;
}
