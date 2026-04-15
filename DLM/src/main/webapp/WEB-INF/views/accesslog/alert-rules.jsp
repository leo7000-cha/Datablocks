<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="alertRulesContent">
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
</div>

<script>
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
        success: function(res) { if (!res.success) showToast('저장 실패', true); },
        error: function() { showToast('저장 실패', true); }
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
                showToast('규칙이 저장되었습니다.', false);
                $('.nav-link[data-page=alert-rules]').click();
            } else {
                showToast('저장 실패', true);
            }
        },
        error: function() { showToast('저장 실패', true); }
    });
}
</script>