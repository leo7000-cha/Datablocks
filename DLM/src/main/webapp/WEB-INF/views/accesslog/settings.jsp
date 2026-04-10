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
                                <c:choose>
                                    <c:when test="${config.configValue == 'Y' || config.configValue == 'N'}">
                                        <label class="toggle-switch">
                                            <input type="checkbox" id="cfg_${config.configId}"
                                                   ${config.configValue == 'Y' ? 'checked' : ''}
                                                   onchange="saveToggleConfig('${config.configId}', this.checked)">
                                            <span class="toggle-slider"></span>
                                        </label>
                                    </c:when>
                                    <c:otherwise>
                                        <input type="text" id="cfg_${config.configId}" value="${config.configValue}"
                                               style="padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; width:150px;">
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="status-badge info">${config.configType}</span></td>
                            <td>${config.description}</td>
                            <td>
                                <c:if test="${config.configValue != 'Y' && config.configValue != 'N'}">
                                    <button class="btn-outline" style="padding:4px 10px; font-size:0.75rem;" onclick="saveConfig('${config.configId}')">저장</button>
                                </c:if>
                            </td>
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
                <thead><tr><th>코드</th><th>규칙명</th><th>조건 설명</th><th>심각도</th><th>활성</th><th>작업</th></tr></thead>
                <tbody>
                    <c:forEach var="rule" items="${alertRules}">
                        <tr>
                            <td><strong>${rule.ruleCode}</strong></td>
                            <td>${rule.ruleName}</td>
                            <td style="font-size:0.8rem; color:#475569;">
                                <c:choose>
                                    <c:when test="${rule.conditionType == 'VOLUME'}">
                                        <i class="fas fa-chart-bar" style="color:#0ea5e9; margin-right:4px;"></i>
                                        ${rule.timeWindowMin}분 내 <strong>${rule.thresholdValue}건</strong> 초과 시 탐지
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'TIME_RANGE'}">
                                        <i class="fas fa-moon" style="color:#8b5cf6; margin-right:4px;"></i>
                                        <strong>${rule.timeRangeStart}~${rule.timeRangeEnd}</strong> 시간대 접속 시 탐지
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'ACCESS_DENIED'}">
                                        <i class="fas fa-ban" style="color:#ef4444; margin-right:4px;"></i>
                                        ${rule.timeWindowMin}분 내 접속 거부 <strong>${rule.thresholdValue}회</strong> 초과 시
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'PII_GRADE'}">
                                        <i class="fas fa-shield-halved" style="color:#f59e0b; margin-right:4px;"></i>
                                        ${rule.timeWindowMin}분 내 ${rule.targetPiiGrade}급 PII <strong>${rule.thresholdValue}건</strong> 초과 시
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'REPEAT'}">
                                        <i class="fas fa-repeat" style="color:#0d9488; margin-right:4px;"></i>
                                        ${rule.timeWindowMin}분 내 동일 테이블 <strong>${rule.thresholdValue}회</strong> 초과 시
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'NEW_IP'}">
                                        <i class="fas fa-network-wired" style="color:#6366f1; margin-right:4px;"></i>
                                        최근 <strong>90일</strong> 내 이력 없는 IP에서 접속 시
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'INACTIVE'}">
                                        <i class="fas fa-user-clock" style="color:#dc2626; margin-right:4px;"></i>
                                        <strong>${rule.thresholdValue}일</strong>간 미사용 계정이 접속 시
                                    </c:when>
                                    <c:when test="${rule.conditionType == 'HOLIDAY'}">
                                        <i class="fas fa-calendar-xmark" style="color:#e11d48; margin-right:4px;"></i>
                                        <strong>주말/공휴일</strong>에 접속 시 탐지 (영업일 달력 연계)
                                    </c:when>
                                    <c:otherwise>
                                        ${rule.conditionType}
                                        <c:if test="${rule.thresholdValue != null}"> / 임계값: ${rule.thresholdValue}</c:if>
                                        <c:if test="${rule.timeWindowMin != null}"> / ${rule.timeWindowMin}분</c:if>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="status-badge ${rule.severity == 'HIGH' ? 'high' : rule.severity == 'MEDIUM' ? 'medium' : rule.severity == 'LOW' ? 'low' : 'info'}">${rule.severity}</span></td>
                            <td>
                                <label class="toggle-switch">
                                    <input type="checkbox" ${rule.isActive == 'Y' ? 'checked' : ''}
                                           onchange="toggleRule('${rule.ruleId}', this.checked)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </td>
                            <td>
                                <button class="btn-outline" style="padding:4px 10px; font-size:0.75rem;" onclick="openRuleModal('${rule.ruleId}')">
                                    <i class="fas fa-pen" style="font-size:0.65rem;"></i> 수정
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Rule Edit Modal -->
    <div id="ruleModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
        <div style="background:#fff; border-radius:12px; padding:24px; width:520px; max-height:80vh; overflow-y:auto; box-shadow:0 20px 60px rgba(0,0,0,0.3);">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h3 style="margin:0; font-size:1.1rem; color:#1e293b;">탐지 규칙 수정</h3>
                <button onclick="closeRuleModal()" style="background:none; border:none; font-size:1.2rem; color:#94a3b8; cursor:pointer;">&times;</button>
            </div>
            <input type="hidden" id="edit_ruleId">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">규칙 코드</label>
                    <input type="text" id="edit_ruleCode" readonly style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; background:#f8fafc; color:#94a3b8; box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">규칙명</label>
                    <input type="text" id="edit_ruleName" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">심각도</label>
                    <select id="edit_severity" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;">
                        <option value="HIGH">HIGH</option>
                        <option value="MEDIUM">MEDIUM</option>
                        <option value="LOW">LOW</option>
                        <option value="INFO">INFO</option>
                    </select>
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">조건 유형</label>
                    <input type="text" id="edit_conditionType" readonly style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; background:#f8fafc; color:#94a3b8; box-sizing:border-box;">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">임계값</label>
                    <input type="number" id="edit_thresholdValue" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;" placeholder="건수 또는 일수">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">시간 윈도우 (분)</label>
                    <input type="number" id="edit_timeWindowMin" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;" placeholder="분 단위">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">시간대 시작</label>
                    <input type="text" id="edit_timeRangeStart" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;" placeholder="HH:MM (예: 22:00)">
                </div>
                <div>
                    <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">시간대 종료</label>
                    <input type="text" id="edit_timeRangeEnd" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;" placeholder="HH:MM (예: 06:00)">
                </div>
            </div>
            <div style="margin-top:12px;">
                <label style="font-size:0.8rem; font-weight:600; color:#475569; display:block; margin-bottom:4px;">설명</label>
                <input type="text" id="edit_description" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:6px; width:100%; box-sizing:border-box;">
            </div>
            <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:20px; padding-top:16px; border-top:1px solid #e2e8f0;">
                <button class="btn-outline" onclick="closeRuleModal()">취소</button>
                <button class="btn-monitor" onclick="saveRule()"><i class="fas fa-check"></i> 저장</button>
            </div>
        </div>
    </div>

    <!-- Hash Verification -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">해시 무결성 검증</h3>
            <div>
                <input type="date" id="hashVerifyDate" style="padding:6px 10px; border:1px solid #e2e8f0; border-radius:6px; margin-right:8px;">
                <button class="btn-monitor" onclick="runHashVerify()"><i class="fas fa-shield-check"></i> 수동 검증</button>
            </div>
        </div>
        <div class="panel-body">
            <!-- 검증 결과 -->
            <div id="hashVerifyResult" style="padding:12px; background:#f8fafc; border-radius:8px; text-align:center; color:#64748b; margin-bottom:20px;">
                날짜를 선택하고 검증을 실행하면 해당일 접속기록의 해시 체인 무결성을 확인합니다. (미선택 시 전일자)
            </div>

            <!-- 스케줄 설정 -->
            <div style="display:flex; align-items:center; gap:16px; padding:12px; background:#f0fdf4; border:1px solid #bbf7d0; border-radius:8px; margin-bottom:20px;">
                <i class="fas fa-clock" style="color:#16a34a; font-size:1.2rem;"></i>
                <div style="flex:1;">
                    <strong>자동 검증 스케줄</strong>
                    <span style="color:#64748b; font-size:0.85rem; margin-left:8px;">매월 1일 새벽 02:00 자동 실행 (전월 접속기록 전수 검증)</span>
                </div>
                <span class="status-badge completed">활성</span>
            </div>

            <!-- 검증 이력 테이블 -->
            <h4 style="font-size:0.9rem; color:#334155; margin-bottom:12px;">검증 이력</h4>
            <table class="monitor-table" id="hashVerifyHistoryTable">
                <thead>
                    <tr>
                        <th>검증일시</th>
                        <th>검증 대상</th>
                        <th>총 건수</th>
                        <th>정상</th>
                        <th>위반</th>
                        <th>상태</th>
                    </tr>
                </thead>
                <tbody id="hashVerifyHistoryBody">
                    <tr><td colspan="6" style="text-align:center; color:#94a3b8; padding:20px;">로딩 중...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
$(function() {
    // 기본 날짜: 전일자
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    $('#hashVerifyDate').val(yesterday.toISOString().split('T')[0]);

    // 검증 이력 로드
    loadHashVerifyHistory();
});

function saveConfig(configId) {
    var value = $('#cfg_' + configId).val();
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: value }),
        success: function(res) { if (res.success) alert('저장되었습니다.'); else alert('저장 실패'); }
    });
}

function saveToggleConfig(configId, checked) {
    var value = checked ? 'Y' : 'N';
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: value }),
        success: function(res) { if (!res.success) alert('저장 실패'); },
        error: function() { alert('저장 실패'); }
    });
}

function runHashVerify() {
    var date = $('#hashVerifyDate').val();
    if (!date) {
        var yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        date = yesterday.toISOString().split('T')[0];
    }
    $('#hashVerifyResult').html('<i class="fas fa-spinner fa-spin"></i> ' + date + ' 접속기록 검증 중...');
    $.ajax({
        url: '/accesslog/api/hash-verify',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ date: date }),
        success: function(res) {
            var statusColor = res.status === 'VALID' ? '#10b981' : '#ef4444';
            var icon = res.status === 'VALID' ? 'fa-check-circle' : 'fa-times-circle';
            var invalidInfo = '';
            if (res.invalidRecords > 0 && res.firstInvalidId) {
                invalidInfo = '<div style="margin-top:8px; color:#ef4444; font-size:0.85rem;">최초 위반 레코드 ID: ' + res.firstInvalidId + '</div>';
            }
            $('#hashVerifyResult').html(
                '<div style="font-size:1.2rem; color:' + statusColor + '; margin-bottom:8px;"><i class="fas ' + icon + '"></i> ' + res.status + '</div>' +
                '<div>검증 대상: <strong>' + date + '</strong> | ' + res.totalRecords + '건 | 정상: ' + res.validRecords + '건 | 위반: <span style="color:' + (res.invalidRecords > 0 ? '#ef4444' : '#10b981') + '; font-weight:600;">' + res.invalidRecords + '건</span></div>' +
                invalidInfo
            );
            loadHashVerifyHistory();
        },
        error: function() { $('#hashVerifyResult').html('<span style="color:#ef4444;">검증 실패</span>'); }
    });
}

// ========== Alert Rule ==========
var ruleData = {};
<c:forEach var="rule" items="${alertRules}">
ruleData['${rule.ruleId}'] = {
    ruleId: '${rule.ruleId}', ruleCode: '${rule.ruleCode}', ruleName: '${rule.ruleName}',
    severity: '${rule.severity}', conditionType: '${rule.conditionType}',
    thresholdValue: '${rule.thresholdValue}', timeWindowMin: '${rule.timeWindowMin}',
    timeRangeStart: '${rule.timeRangeStart}', timeRangeEnd: '${rule.timeRangeEnd}',
    description: '${rule.description}'
};
</c:forEach>

function toggleRule(ruleId, checked) {
    $.ajax({
        url: '/accesslog/api/alert-rule/' + ruleId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ isActive: checked ? 'Y' : 'N' }),
        success: function(res) { if (!res.success) alert('저장 실패'); },
        error: function() { alert('저장 실패'); }
    });
}

function openRuleModal(ruleId) {
    var r = ruleData[ruleId];
    if (!r) return;
    $('#edit_ruleId').val(r.ruleId);
    $('#edit_ruleCode').val(r.ruleCode);
    $('#edit_ruleName').val(r.ruleName);
    $('#edit_severity').val(r.severity);
    $('#edit_conditionType').val(r.conditionType);
    $('#edit_thresholdValue').val(r.thresholdValue === 'null' ? '' : r.thresholdValue);
    $('#edit_timeWindowMin').val(r.timeWindowMin === 'null' ? '' : r.timeWindowMin);
    $('#edit_timeRangeStart').val(r.timeRangeStart === 'null' ? '' : r.timeRangeStart);
    $('#edit_timeRangeEnd').val(r.timeRangeEnd === 'null' ? '' : r.timeRangeEnd);
    $('#edit_description').val(r.description);
    $('#ruleModal').css('display', 'flex');
}

function closeRuleModal() {
    $('#ruleModal').hide();
}

function saveRule() {
    var ruleId = $('#edit_ruleId').val();
    $.ajax({
        url: '/accesslog/api/alert-rule/' + ruleId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({
            ruleName: $('#edit_ruleName').val(),
            severity: $('#edit_severity').val(),
            thresholdValue: $('#edit_thresholdValue').val() || null,
            timeWindowMin: $('#edit_timeWindowMin').val() || null,
            timeRangeStart: $('#edit_timeRangeStart').val() || null,
            timeRangeEnd: $('#edit_timeRangeEnd').val() || null,
            description: $('#edit_description').val()
        }),
        success: function(res) {
            if (res.success) {
                closeRuleModal();
                $('.nav-link[data-page=settings]').click();
            } else {
                alert('저장 실패');
            }
        },
        error: function() { alert('저장 실패'); }
    });
}

function loadHashVerifyHistory() {
    $.get('/accesslog/api/hash-verify', function(data) {
        var tbody = $('#hashVerifyHistoryBody');
        tbody.empty();
        if (!data || data.length === 0) {
            tbody.html('<tr><td colspan="6" style="text-align:center; color:#94a3b8; padding:20px;">검증 이력이 없습니다.</td></tr>');
            return;
        }
        data.forEach(function(row) {
            var statusBadge = row.status === 'VALID'
                ? '<span class="status-badge completed">VALID</span>'
                : '<span class="status-badge error">INVALID</span>';
            var invalidStyle = row.invalidRecords > 0 ? 'color:#ef4444; font-weight:600;' : '';
            tbody.append(
                '<tr>' +
                '<td>' + (row.completedAt || row.regDate || '-') + '</td>' +
                '<td>' + (row.verifyDate || '-') + '</td>' +
                '<td>' + (row.totalRecords || 0) + '</td>' +
                '<td>' + (row.validRecords || 0) + '</td>' +
                '<td style="' + invalidStyle + '">' + (row.invalidRecords || 0) + '</td>' +
                '<td>' + statusBadge + '</td>' +
                '</tr>'
            );
        });
    });
}
</script>