package datablocks.dlm.service;

import datablocks.dlm.domain.AccessLogAlertVO;
import datablocks.dlm.domain.AccessLogConfigVO;
import datablocks.dlm.mapper.AccessLogMapper;
import datablocks.dlm.util.LogUtil;

import jakarta.mail.internet.MimeMessage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * 접속기록 이메일 알림 서비스
 * SMTP 미설정 시 graceful degradation
 */
@Service
public class AccessLogEmailService {

    private static final Logger logger = LoggerFactory.getLogger(AccessLogEmailService.class);

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Autowired
    private AccessLogMapper mapper;

    @Async
    public void sendAlertNotification(AccessLogAlertVO alert) {
        if (mailSender == null) {
            LogUtil.log("WARN", "AccessLogEmail: JavaMailSender not configured, skipping email");
            return;
        }

        try {
            AccessLogConfigVO enabledCfg = mapper.selectConfigByKey("EMAIL_ENABLED");
            if (enabledCfg == null || !"Y".equals(enabledCfg.getConfigValue())) {
                LogUtil.log("INFO", "AccessLogEmail: EMAIL_ENABLED is N, skipping");
                return;
            }

            AccessLogConfigVO recipientsCfg = mapper.selectConfigByKey("EMAIL_RECIPIENTS");
            if (recipientsCfg == null || recipientsCfg.getConfigValue() == null
                    || recipientsCfg.getConfigValue().trim().isEmpty()) {
                LogUtil.log("WARN", "AccessLogEmail: No recipients configured");
                return;
            }

            String[] recipients = recipientsCfg.getConfigValue().split(",");
            for (int i = 0; i < recipients.length; i++) {
                recipients[i] = recipients[i].trim();
            }

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipients);
            helper.setSubject("[DLM 접속기록] 이상행위 감지 - " + alert.getSeverity() + " | " + alert.getAlertTitle());
            helper.setText(buildHtmlContent(alert), true);

            mailSender.send(message);
            LogUtil.log("INFO", "AccessLogEmail: Alert notification sent for alertId=" + alert.getAlertId());
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send alert notification", e);
        }
    }

    private String buildHtmlContent(AccessLogAlertVO alert) {
        String severityColor;
        switch (alert.getSeverity()) {
            case "HIGH": severityColor = "#dc2626"; break;
            case "MEDIUM": severityColor = "#d97706"; break;
            case "LOW": severityColor = "#059669"; break;
            default: severityColor = "#1d4ed8"; break;
        }

        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body style='font-family:Arial,sans-serif;'>"
            + "<div style='max-width:600px;margin:0 auto;border:1px solid #e2e8f0;border-radius:8px;overflow:hidden;'>"
            + "<div style='background:" + severityColor + ";color:#fff;padding:20px;'>"
            + "<h2 style='margin:0;'>DLM 이상행위 감지</h2></div>"
            + "<div style='padding:20px;'>"
            + "<table style='width:100%;border-collapse:collapse;'>"
            + "<tr><td style='padding:8px;font-weight:bold;width:120px;'>심각도</td>"
            + "<td style='padding:8px;'><span style='background:" + severityColor + ";color:#fff;padding:4px 12px;border-radius:4px;'>"
            + alert.getSeverity() + "</span></td></tr>"
            + "<tr><td style='padding:8px;font-weight:bold;'>알림 제목</td><td style='padding:8px;'>" + escapeHtml(alert.getAlertTitle()) + "</td></tr>"
            + "<tr><td style='padding:8px;font-weight:bold;'>규칙 코드</td><td style='padding:8px;'>" + escapeHtml(alert.getRuleCode()) + "</td></tr>"
            + "<tr><td style='padding:8px;font-weight:bold;'>대상 사용자</td><td style='padding:8px;'>"
            + escapeHtml(alert.getTargetUserName()) + " (" + escapeHtml(alert.getTargetUserId()) + ")</td></tr>"
            + "<tr><td style='padding:8px;font-weight:bold;'>상세 내용</td><td style='padding:8px;'>" + escapeHtml(alert.getAlertDetail()) + "</td></tr>"
            + "<tr><td style='padding:8px;font-weight:bold;'>감지 시간</td><td style='padding:8px;'>" + escapeHtml(alert.getDetectedTime()) + "</td></tr>"
            + "</table>"
            + "<div style='margin-top:20px;padding:12px;background:#f1f5f9;border-radius:4px;text-align:center;'>"
            + "<a href='http://localhost:8080/accesslog/index' style='color:" + severityColor + ";font-weight:bold;'>DLM 접속기록관리 바로가기</a>"
            + "</div></div></div></body></html>";
    }

    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
