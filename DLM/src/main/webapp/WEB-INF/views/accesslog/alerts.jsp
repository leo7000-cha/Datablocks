<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="alertsContent">
    <div class="filter-bar">
        <select id="filterSeverity">
            <option value="">심각도</option>
            <option value="HIGH">높음</option>
            <option value="MEDIUM">보통</option>
            <option value="LOW">낮음</option>
            <option value="INFO">정보</option>
        </select>
        <select id="filterAlertStatus">
            <option value="">상태</option>
            <option value="NEW">신규</option>
            <option value="ACKNOWLEDGED">확인</option>
            <option value="RESOLVED">처리완료</option>
            <option value="DISMISSED">무시</option>
        </select>
        <button class="btn-monitor" onclick="searchAlerts()"><i class="fas fa-search"></i> 조회</button>
    </div>

    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">이상행위 알림 <span style="color:var(--monitor-primary); font-size:0.85rem;">(${total}건)</span></h3>
        </div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table">
                <thead><tr><th>심각도</th><th>규칙</th><th>알림 내용</th><th>대상자</th><th>탐지시간</th><th>상태</th><th>처리</th></tr></thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty list}">
                            <c:forEach var="alert" items="${list}">
                                <tr>
                                    <td><span class="status-badge ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">${alert.severity}</span></td>
                                    <td>${alert.ruleCode}</td>
                                    <td>${alert.alertTitle}</td>
                                    <td>${alert.targetUserName}</td>
                                    <td style="white-space:nowrap;">${alert.detectedTime}</td>
                                    <td><span class="status-badge ${alert.status == 'NEW' ? 'new-alert' : alert.status == 'RESOLVED' ? 'completed' : 'stopped'}">${alert.status}</span></td>
                                    <td>
                                        <c:if test="${alert.status == 'NEW' || alert.status == 'ACKNOWLEDGED'}">
                                            <button class="btn-outline" style="padding:4px 10px; font-size:0.75rem;" onclick="resolveAlert(${alert.alertId})">처리</button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="7" style="text-align:center; padding:40px; color:#94a3b8;">이상행위 알림이 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function searchAlerts() {
    var params = { search12: $('#filterSeverity').val(), search11: $('#filterAlertStatus').val(), amount: 100 };
    $.get('/accesslog/alerts', params, function(html) { $('#mainContent').html(html); });
}

function resolveAlert(alertId) {
    var comment = prompt('처리 의견을 입력하세요');
    if (comment === null) return;
    $.ajax({
        url: '/accesslog/api/alert/' + alertId + '/resolve',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ status: 'RESOLVED', comment: comment }),
        success: function(res) { if (res.success) searchAlerts(); else alert('처리 실패'); }
    });
}
</script>