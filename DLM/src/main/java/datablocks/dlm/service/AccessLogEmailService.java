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

    // ========== 기존: 관리자 알림 ==========

    @Async
    public void sendAlertNotification(AccessLogAlertVO alert) {
        String[] recipients = getRecipients();
        if (recipients == null) return;

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipients);
            helper.setSubject("[접속기록관리] 이상행위 감지 - " + alert.getSeverity() + " | " + alert.getAlertTitle());
            helper.setText(buildAlertHtml(alert), true);

            mailSender.send(message);
            LogUtil.log("INFO", "AccessLogEmail: Alert notification sent for alertId=" + alert.getAlertId());
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send alert notification", e);
        }
    }

    // ========== 소명 워크플로우 이메일 ==========

    /**
     * 대상자에게 소명 요청 이메일 발송
     */
    @Async
    public void sendJustificationRequest(AccessLogAlertVO alert, String baseUrl, String token, String expireHours) {
        if (!isEmailReady()) return;

        String targetEmail = alert.getTargetUserEmail();
        if (targetEmail == null || targetEmail.trim().isEmpty()) {
            LogUtil.log("WARN", "AccessLogEmail: No target email for alertId=" + alert.getAlertId());
            return;
        }

        try {
            String justifyUrl = baseUrl + "/accesslog/justify/" + token;

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(targetEmail);
            helper.setSubject("[접속기록관리] 이상행위 소명 요청 - " + alert.getAlertTitle());
            helper.setText(buildJustificationRequestHtml(alert, justifyUrl, expireHours), true);

            mailSender.send(message);
            LogUtil.log("INFO", "AccessLogEmail: Justification request sent to " + targetEmail + " for alertId=" + alert.getAlertId());
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send justification request", e);
        }
    }

    /**
     * 관리자에게 소명 완료 알림
     */
    @Async
    public void sendJustificationCompleteNotice(AccessLogAlertVO alert, String justifiedBy) {
        String[] recipients = getRecipients();
        if (recipients == null) return;

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipients);
            helper.setSubject("[접속기록관리] 소명 제출 완료 - " + alert.getAlertTitle());
            helper.setText(buildNoticeHtml("소명이 제출되었습니다",
                    "대상자 <strong>" + escapeHtml(alert.getTargetUserName()) + "</strong>이(가) 소명을 제출했습니다. 관리자 검토가 필요합니다.",
                    alert, "#0d9488"), true);

            mailSender.send(message);
            LogUtil.log("INFO", "AccessLogEmail: Justification complete notice sent for alertId=" + alert.getAlertId());
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send justification complete notice", e);
        }
    }

    /**
     * 대상자에게 재소명 요청 이메일 발송
     */
    @Async
    public void sendReJustificationRequest(AccessLogAlertVO alert, String baseUrl, String newToken, String rejectComment) {
        if (!isEmailReady()) return;

        String targetEmail = alert.getTargetUserEmail();
        if (targetEmail == null || targetEmail.trim().isEmpty()) return;

        try {
            String justifyUrl = baseUrl + "/accesslog/justify/" + newToken;

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(targetEmail);
            helper.setSubject("[접속기록관리] 재소명 요청 - " + alert.getAlertTitle());
            helper.setText(buildReJustificationHtml(alert, justifyUrl, rejectComment), true);

            mailSender.send(message);
            LogUtil.log("INFO", "AccessLogEmail: Re-justification request sent to " + targetEmail);
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send re-justification request", e);
        }
    }

    /**
     * 관리자에게 SLA 초과 알림
     */
    @Async
    public void sendOverdueNotice(AccessLogAlertVO alert) {
        String[] recipients = getRecipients();
        if (recipients == null) return;

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipients);
            helper.setSubject("[접속기록관리] 소명 기한 초과 - " + alert.getAlertTitle());
            helper.setText(buildNoticeHtml("소명 기한이 초과되었습니다",
                    "대상자 <strong>" + escapeHtml(alert.getTargetUserName()) + "</strong>이(가) 기한 내 소명하지 않았습니다.",
                    alert, "#f59e0b"), true);

            mailSender.send(message);
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send overdue notice", e);
        }
    }

    /**
     * 관리자에게 에스컬레이션 알림
     */
    @Async
    public void sendEscalationNotice(AccessLogAlertVO alert) {
        String[] recipients = getRecipients();
        if (recipients == null) return;

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipients);
            helper.setSubject("[접속기록관리] 장기 미처리 알림 - " + alert.getAlertTitle());
            helper.setText(buildNoticeHtml("장기 미처리 알림",
                    "대상자 <strong>" + escapeHtml(alert.getTargetUserName()) + "</strong>의 이상행위 알림이 장기간 처리되지 않았습니다. 즉시 확인이 필요합니다.",
                    alert, "#dc2626"), true);

            mailSender.send(message);
        } catch (Exception e) {
            logger.error("AccessLogEmail: Failed to send escalation notice", e);
        }
    }

    // ========== Private Helpers ==========

    private boolean isEmailReady() {
        if (mailSender == null) {
            LogUtil.log("WARN", "AccessLogEmail: JavaMailSender not configured, skipping");
            return false;
        }
        AccessLogConfigVO enabledCfg = mapper.selectConfigByKey("EMAIL_ENABLED");
        if (enabledCfg == null || !"Y".equals(enabledCfg.getConfigValue())) {
            LogUtil.log("INFO", "AccessLogEmail: EMAIL_ENABLED is N, skipping");
            return false;
        }
        return true;
    }

    private String[] getRecipients() {
        if (!isEmailReady()) return null;

        AccessLogConfigVO recipientsCfg = mapper.selectConfigByKey("EMAIL_RECIPIENTS");
        if (recipientsCfg == null || recipientsCfg.getConfigValue() == null
                || recipientsCfg.getConfigValue().trim().isEmpty()) {
            LogUtil.log("WARN", "AccessLogEmail: No recipients configured");
            return null;
        }
        String[] recipients = recipientsCfg.getConfigValue().split(",");
        for (int i = 0; i < recipients.length; i++) {
            recipients[i] = recipients[i].trim();
        }
        return recipients;
    }

    private String severityColor(String severity) {
        if (severity == null) return "#1d4ed8";
        switch (severity) {
            case "HIGH": return "#dc2626";
            case "MEDIUM": return "#d97706";
            case "LOW": return "#059669";
            default: return "#1d4ed8";
        }
    }

    // ========== HTML Builders ==========

    private String buildAlertHtml(AccessLogAlertVO alert) {
        String color = severityColor(alert.getSeverity());
        return emailWrap(color,
                "이상행위 감지",
                alertInfoTable(alert)
                + "<div style='margin-top:20px;padding:12px;background:#f1f5f9;border-radius:4px;text-align:center;'>"
                + "<a href='http://localhost:8080/accesslog/index' style='color:" + color + ";font-weight:bold;'>접속기록관리 바로가기</a>"
                + "</div>"
        );
    }

    private String buildJustificationRequestHtml(AccessLogAlertVO alert, String justifyUrl, String expireHours) {
        String color = severityColor(alert.getSeverity());
        return emailWrap(color,
                "이상행위 소명 요청",
                "<p style='font-size:14px;color:#334155;margin:0 0 16px;'>"
                + escapeHtml(alert.getTargetUserName()) + "님, 접속기록 모니터링에서 아래 이상행위가 탐지되었습니다.</p>"
                + alertInfoTable(alert)
                + "<div style='margin:24px 0;text-align:center;'>"
                + "<a href='" + justifyUrl + "' style='display:inline-block;padding:14px 32px;background:" + color
                + ";color:#fff;text-decoration:none;border-radius:8px;font-weight:bold;font-size:15px;'>소명 입력하기</a>"
                + "</div>"
                + "<div style='padding:12px;background:#fef3c7;border-radius:4px;font-size:13px;color:#92400e;'>"
                + "&#9888; 이 링크는 <strong>" + expireHours + "시간</strong> 후 만료됩니다.<br>"
                + "&#9888; <strong>48시간</strong> 내 소명하지 않을 경우 상위 관리자에게 보고됩니다.</div>"
        );
    }

    private String buildReJustificationHtml(AccessLogAlertVO alert, String justifyUrl, String rejectComment) {
        String color = "#d97706";
        return emailWrap(color,
                "재소명 요청",
                "<p style='font-size:14px;color:#334155;margin:0 0 16px;'>"
                + escapeHtml(alert.getTargetUserName()) + "님, 관리자가 추가 소명을 요청했습니다.</p>"
                + "<div style='padding:16px;background:#fef3c7;border:1px solid #fde68a;border-radius:8px;margin-bottom:16px;'>"
                + "<strong style='color:#92400e;'>관리자 의견:</strong><br>"
                + "<span style='color:#78350f;'>" + escapeHtml(rejectComment) + "</span></div>"
                + alertInfoTable(alert)
                + "<div style='margin:24px 0;text-align:center;'>"
                + "<a href='" + justifyUrl + "' style='display:inline-block;padding:14px 32px;background:" + color
                + ";color:#fff;text-decoration:none;border-radius:8px;font-weight:bold;font-size:15px;'>재소명 입력하기</a></div>"
        );
    }

    private String buildNoticeHtml(String title, String message, AccessLogAlertVO alert, String color) {
        return emailWrap(color, title,
                "<p style='font-size:14px;color:#334155;margin:0 0 16px;'>" + message + "</p>"
                + alertInfoTable(alert)
                + "<div style='margin-top:20px;padding:12px;background:#f1f5f9;border-radius:4px;text-align:center;'>"
                + "<a href='http://localhost:8080/accesslog/index' style='color:" + color + ";font-weight:bold;'>접속기록관리 바로가기</a></div>"
        );
    }

    private String alertInfoTable(AccessLogAlertVO alert) {
        String color = severityColor(alert.getSeverity());
        return "<table style='width:100%;border-collapse:collapse;'>"
                + "<tr><td style='padding:8px;font-weight:bold;width:120px;'>심각도</td>"
                + "<td style='padding:8px;'><span style='background:" + color + ";color:#fff;padding:4px 12px;border-radius:4px;'>"
                + alert.getSeverity() + "</span></td></tr>"
                + "<tr><td style='padding:8px;font-weight:bold;'>알림 제목</td><td style='padding:8px;'>" + escapeHtml(alert.getAlertTitle()) + "</td></tr>"
                + "<tr><td style='padding:8px;font-weight:bold;'>규칙 코드</td><td style='padding:8px;'>" + escapeHtml(alert.getRuleCode()) + "</td></tr>"
                + "<tr><td style='padding:8px;font-weight:bold;'>대상 사용자</td><td style='padding:8px;'>"
                + escapeHtml(alert.getTargetUserName()) + " (" + escapeHtml(alert.getTargetUserId()) + ")</td></tr>"
                + "<tr><td style='padding:8px;font-weight:bold;'>상세 내용</td><td style='padding:8px;'>" + escapeHtml(alert.getAlertDetail()) + "</td></tr>"
                + "<tr><td style='padding:8px;font-weight:bold;'>감지 시간</td><td style='padding:8px;'>" + escapeHtml(alert.getDetectedTime()) + "</td></tr>"
                + "</table>";
    }

    private String emailWrap(String color, String headerTitle, String bodyContent) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body style='font-family:Arial,sans-serif;'>"
                + "<div style='max-width:600px;margin:0 auto;border:1px solid #e2e8f0;border-radius:8px;overflow:hidden;'>"
                + "<div style='background:" + color + ";color:#fff;padding:20px;'>"
                + "<h2 style='margin:0;'>" + headerTitle + "</h2></div>"
                + "<div style='padding:20px;'>" + bodyContent + "</div></div></body></html>";
    }

    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
