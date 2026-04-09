<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="settingsContent">
    <!-- General Config -->
    <div class="content-panel">
        <div class="panel-header"><h3 class="panel-title">일반 설정</h3></div>
        <div class="panel-body">
            <table class="monitor-table">
                <thead><tr><th>설정 키</th><th>값</th><th>유형</th><th>설명</th><th>작업</th></tr></thead>
                <tbody>
                    <c:forEach var="config" items="${configs}">
                        <tr>
                            <td><code>${config.configKey}</code></td>
                            <td>
                                <input type="text" id="cfg_${config.configId}" value="${config.configValue}"
                                       style="padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; width:150px;">
                            </td>
                            <td><span class="status-badge info">${config.configType}</span></td>
                            <td>${config.description}</td>
                            <td><button class="btn-outline" style="padding:4px 10px; font-size:0.75rem;" onclick="saveConfig('${config.configId}')">저장</button></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Alert Rules -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">이상행위 탐지 규칙</h3>
        </div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table">
                <thead><tr><th>코드</th><th>규칙명</th><th>심각도</th><th>조건유형</th><th>임계값</th><th>시간범위</th><th>활성</th></tr></thead>
                <tbody>
                    <c:forEach var="rule" items="${alertRules}">
                        <tr>
                            <td><strong>${rule.ruleCode}</strong></td>
                            <td>${rule.ruleName}</td>
                            <td><span class="status-badge ${rule.severity == 'HIGH' ? 'high' : rule.severity == 'MEDIUM' ? 'medium' : rule.severity == 'LOW' ? 'low' : 'info'}">${rule.severity}</span></td>
                            <td>${rule.conditionType}</td>
                            <td>${rule.thresholdValue != null ? rule.thresholdValue : '-'}</td>
                            <td>${rule.timeWindowMin != null ? rule.timeWindowMin.toString().concat('분') : rule.timeRangeStart != null ? rule.timeRangeStart.concat('~').concat(rule.timeRangeEnd) : '-'}</td>
                            <td><span class="status-badge ${rule.isActive == 'Y' ? 'completed' : 'stopped'}">${rule.isActive == 'Y' ? '활성' : '비활성'}</span></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Hash Verification -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">해시 무결성 검증</h3>
            <button class="btn-monitor" onclick="runHashVerify()"><i class="fas fa-shield-check"></i> 검증 실행</button>
        </div>
        <div class="panel-body">
            <div id="hashVerifyResult" style="padding:10px; background:#f8fafc; border-radius:8px; text-align:center; color:#64748b;">
                검증을 실행하면 오늘 접속기록의 해시 체인 무결성을 확인합니다.
            </div>
        </div>
    </div>
</div>

<script>
function saveConfig(configId) {
    var value = $('#cfg_' + configId).val();
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: value }),
        success: function(res) { if (res.success) alert('저장되었습니다.'); else alert('저장 실패'); }
    });
}

function runHashVerify() {
    $('#hashVerifyResult').html('<i class="fas fa-spinner fa-spin"></i> 검증 중...');
    $.ajax({
        url: '/accesslog/api/hash-verify',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({}),
        success: function(res) {
            var statusColor = res.status === 'VALID' ? '#10b981' : '#ef4444';
            var icon = res.status === 'VALID' ? 'fa-check-circle' : 'fa-times-circle';
            $('#hashVerifyResult').html(
                '<div style="font-size:1.2rem; color:' + statusColor + '; margin-bottom:8px;"><i class="fas ' + icon + '"></i> ' + res.status + '</div>' +
                '<div>검증 대상: ' + res.totalRecords + '건 | 정상: ' + res.validRecords + '건 | 위반: ' + res.invalidRecords + '건</div>'
            );
        },
        error: function() { $('#hashVerifyResult').html('<span style="color:#ef4444;">검증 실패</span>'); }
    });
}
</script>