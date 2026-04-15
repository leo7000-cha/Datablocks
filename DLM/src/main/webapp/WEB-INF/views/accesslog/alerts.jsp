<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="alertsContent">
    <!-- 법규 안내 -->
    <div style="display:flex; gap:16px; margin-bottom:20px;">
        <div style="flex:1; display:flex; align-items:flex-start; gap:12px; padding:14px 18px; background:linear-gradient(135deg,#fef3c7 0%,#fffbeb 100%); border:1px solid #fcd34d; border-radius:10px;">
            <i class="fas fa-triangle-exclamation" style="color:#d97706; font-size:1.2rem; margin-top:2px;"></i>
            <div>
                <div style="font-weight:700; color:#92400e; font-size:0.88rem; margin-bottom:4px;">이상행위 탐지·소명 관리</div>
                <div style="color:#78350f; font-size:0.78rem; line-height:1.7;">
                    <strong>개인정보보호법 제29조</strong> 및 <strong>개인정보의 안전성 확보조치 기준(개인정보보호위원회 고시) 제5조</strong>에 따라
                    개인정보처리시스템에 대한 <strong>비인가 접근 시도를 탐지</strong>하고 대응해야 합니다.<br>
                    이상행위가 감지되면 담당자에게 소명을 요청하고, 사유를 기록·보존하여 감사 증적을 확보합니다.
                </div>
                <div style="margin-top:8px; padding:8px 12px; background:rgba(255,255,255,0.6); border-radius:6px; border:1px solid #fde68a; font-size:0.73rem; color:#92400e; line-height:1.6;">
                    <i class="fas fa-gavel" style="margin-right:4px;"></i>
                    <strong>안전성 확보조치 기준 제5조</strong> — 비인가 접근 탐지 및 통제 &nbsp;|&nbsp;
                    <strong>제8조</strong> — 접속기록 보관·점검(월 1회) &nbsp;|&nbsp;
                    <strong>전자금융감독규정 제13조</strong> — 금융기관 이상거래 탐지 의무
                </div>
            </div>
        </div>
        <div style="width:340px; flex-shrink:0; padding:14px 18px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px;">
            <div style="font-weight:600; color:#475569; font-size:0.82rem; margin-bottom:8px;"><i class="fas fa-list-check" style="color:#6366f1; margin-right:6px;"></i>처리 흐름</div>
            <div style="font-size:0.75rem; color:#64748b; line-height:1.8;">
                <span style="display:inline-block; width:18px; height:18px; background:#ef4444; color:#fff; border-radius:50%; text-align:center; line-height:18px; font-size:0.65rem; font-weight:700; margin-right:4px;">1</span> 이상행위 <strong>자동 탐지</strong><br>
                <span style="display:inline-block; width:18px; height:18px; background:#f59e0b; color:#fff; border-radius:50%; text-align:center; line-height:18px; font-size:0.65rem; font-weight:700; margin-right:4px;">2</span> 담당자에게 <strong>소명 요청</strong> (이메일 발송)<br>
                <span style="display:inline-block; width:18px; height:18px; background:#3b82f6; color:#fff; border-radius:50%; text-align:center; line-height:18px; font-size:0.65rem; font-weight:700; margin-right:4px;">3</span> 담당자 <strong>소명 제출</strong> → 관리자 검토<br>
                <span style="display:inline-block; width:18px; height:18px; background:#10b981; color:#fff; border-radius:50%; text-align:center; line-height:18px; font-size:0.65rem; font-weight:700; margin-right:4px;">4</span> <strong>승인 완료</strong> — 감사 증적 보존
            </div>
        </div>
    </div>

    <div class="filter-bar">
        <select id="filterSeverity" style="width:160px;" onchange="searchAlerts(1)">
            <option value="">심각도 (전체)</option>
            <option value="HIGH" ${pageMaker.cri.search12 == 'HIGH' ? 'selected' : ''}>높음 (HIGH)</option>
            <option value="MEDIUM" ${pageMaker.cri.search12 == 'MEDIUM' ? 'selected' : ''}>보통 (MEDIUM)</option>
            <option value="LOW" ${pageMaker.cri.search12 == 'LOW' ? 'selected' : ''}>낮음 (LOW)</option>
            <option value="INFO" ${pageMaker.cri.search12 == 'INFO' ? 'selected' : ''}>정보 (INFO)</option>
        </select>
        <select id="filterRuleCode" style="width:200px;" onchange="searchAlerts(1)">
            <option value="">규칙 (전체)</option>
            <c:forEach var="rule" items="${ruleList}">
                <option value="${rule.ruleCode}" ${pageMaker.cri.search13 == rule.ruleCode ? 'selected' : ''}>${rule.ruleCode} - ${rule.ruleName}</option>
            </c:forEach>
        </select>
        <select id="filterAlertStatus" style="width:200px;" onchange="searchAlerts(1)">
            <option value="">상태 (전체)</option>
            <option value="NEW" ${pageMaker.cri.search11 == 'NEW' ? 'selected' : ''}>신규</option>
            <option value="NOTIFIED" ${pageMaker.cri.search11 == 'NOTIFIED' ? 'selected' : ''}>소명요청</option>
            <option value="JUSTIFIED" ${pageMaker.cri.search11 == 'JUSTIFIED' ? 'selected' : ''}>소명제출</option>
            <option value="RESOLVED" ${pageMaker.cri.search11 == 'RESOLVED' ? 'selected' : ''}>승인완료</option>
            <option value="RE_JUSTIFY" ${pageMaker.cri.search11 == 'RE_JUSTIFY' ? 'selected' : ''}>재소명</option>
            <option value="OVERDUE" ${pageMaker.cri.search11 == 'OVERDUE' ? 'selected' : ''}>소명기한초과</option>
            <option value="ESCALATED" ${pageMaker.cri.search11 == 'ESCALATED' ? 'selected' : ''}>미응답경고</option>
            <option value="DISMISSED" ${pageMaker.cri.search11 == 'DISMISSED' ? 'selected' : ''}>무시</option>
        </select>
        <input type="text" id="filterTargetUser" placeholder="대상자" style="width:140px;" value="${pageMaker.cri.search2}" onkeydown="if(event.key==='Enter') searchAlerts(1)">
        <input type="text" id="filterDateFrom" class="fp-date" style="width:150px;" value="${pageMaker.cri.search7}" placeholder="FROM" autocomplete="off">
        <span style="color:#94a3b8; font-size:0.85rem;">~</span>
        <input type="text" id="filterDateTo" class="fp-date" style="width:150px;" value="${pageMaker.cri.search8}" placeholder="TO" autocomplete="off">
        <button class="btn-monitor" onclick="searchAlerts(1)"><i class="fas fa-search"></i> 조회</button>
    </div>

    <div class="content-panel">
        <div class="panel-header" style="display:flex; align-items:center;">
            <h3 class="panel-title">이상행위 알림 <span style="color:var(--monitor-primary); font-size:0.85rem;">(${total}건)</span></h3>
            <div id="bulkActions" style="display:none; margin-left:auto; gap:8px; align-items:center;">
                <span id="selectedCount" style="font-size:0.8rem; color:#64748b;">0건 선택</span>
                <button class="btn-monitor" style="padding:5px 14px; font-size:0.8rem;" onclick="bulkApprove()">
                    <i class="fas fa-check"></i> 일괄 승인
                </button>
                <button class="btn-outline" style="padding:5px 14px; font-size:0.8rem; color:#ea580c; border-color:#fb923c; background:#fff7ed;" onclick="bulkDismiss()">
                    <i class="fas fa-ban"></i> 일괄 무시
                </button>
            </div>
        </div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table">
                <thead><tr><th style="width:36px;"><input type="checkbox" id="checkAll" onclick="toggleCheckAll(this)"></th><th style="white-space:nowrap;">심각도</th><th>규칙</th><th>알림 내용</th><th>대상자</th><th style="width:22%;">소명요약</th><th>탐지시간</th><th style="white-space:nowrap;">상태</th><th style="white-space:nowrap;">처리</th></tr></thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty list}">
                            <c:forEach var="alert" items="${list}">
                                <tr style="cursor:pointer;" onclick="showAlertDetail(${alert.alertId})">
                                    <td onclick="event.stopPropagation();">
                                        <c:if test="${alert.status == 'NEW' || alert.status == 'NOTIFIED' || alert.status == 'OVERDUE' || alert.status == 'ESCALATED' || alert.status == 'JUSTIFIED'}">
                                            <input type="checkbox" class="alert-check" value="${alert.alertId}" data-status="${alert.status}" data-rule-id="${alert.ruleId}" data-rule-code="${alert.ruleCode}" data-target-user="${alert.targetUserId}" data-severity="${alert.severity}" onclick="updateBulkUI()">
                                        </c:if>
                                    </td>
                                    <td style="white-space:nowrap;"><span class="status-badge ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">${alert.severity == 'HIGH' ? '높음' : alert.severity == 'MEDIUM' ? '보통' : alert.severity == 'LOW' ? '낮음' : '정보'}</span></td>
                                    <td>${alert.ruleCode}</td>
                                    <td>${alert.alertTitle}</td>
                                    <td>${alert.targetUserName}</td>
                                    <td style="font-size:0.8rem; color:#475569; line-height:1.4; word-break:break-all; position:relative;" class="summary-cell">
                                        <c:if test="${not empty alert.justificationSummary}"><div class="summary-clamp" style="display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;">${alert.justificationSummary}</div><div class="summary-tooltip">${alert.justificationSummary}</div></c:if>
                                        <c:if test="${empty alert.justificationSummary}"><span style="color:#cbd5e1;">-</span></c:if>
                                    </td>
                                    <td style="white-space:nowrap;">${alert.detectedTime}</td>
                                    <td style="white-space:nowrap;"><span class="status-badge
                                        ${alert.status == 'NEW' ? 'new-alert' :
                                          alert.status == 'NOTIFIED' ? 'running' :
                                          alert.status == 'JUSTIFIED' ? 'medium' :
                                          alert.status == 'RESOLVED' ? 'completed' :
                                          alert.status == 'RE_JUSTIFY' ? 'high' :
                                          alert.status == 'OVERDUE' ? 'error' :
                                          alert.status == 'ESCALATED' ? 'error' : 'stopped'}">
                                        ${alert.status == 'NEW' ? '신규' :
                                          alert.status == 'NOTIFIED' ? '소명요청' :
                                          alert.status == 'JUSTIFIED' ? '소명제출' :
                                          alert.status == 'RESOLVED' ? '승인완료' :
                                          alert.status == 'RE_JUSTIFY' ? '재소명' :
                                          alert.status == 'OVERDUE' ? '소명기한초과' :
                                          alert.status == 'ESCALATED' ? '미응답경고' :
                                          alert.status == 'DISMISSED' ? '무시' : alert.status}</span></td>
                                    <td style="white-space:nowrap;" onclick="event.stopPropagation();">
                                        <c:if test="${alert.status == 'NEW'}">
                                            <button class="btn-outline" style="padding:4px 10px; font-size:0.75rem;" onclick="openNotifyModal(${alert.alertId}, '${alert.targetUserName}')"><i class="fas fa-envelope"></i> 소명메일발송</button>
                                        </c:if>
                                        <c:if test="${alert.status == 'JUSTIFIED'}">
                                            <button class="btn-outline" style="padding:4px 10px; font-size:0.75rem; background:var(--monitor-primary); color:#fff;" onclick="showAlertDetail(${alert.alertId})">검토</button>
                                        </c:if>
                                        <c:if test="${alert.status == 'NEW' || alert.status == 'NOTIFIED' || alert.status == 'OVERDUE' || alert.status == 'ESCALATED'}">
                                            <button class="btn-outline" style="padding:4px 8px; font-size:0.7rem; color:#ea580c; border-color:#fdba74; background:#fff7ed;" onclick="openDismissModal(${alert.alertId}, '${alert.ruleId}', '${alert.ruleCode}', '${alert.targetUserId}', '${alert.severity}')">무시</button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="9" style="text-align:center; padding:40px; color:#94a3b8;">이상행위 알림이 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <!-- Pagination -->
        <c:if test="${total > 0}">
        <div class="pagination-wrap">
            <c:if test="${pageMaker.prev}">
                <a href="javascript:void(0)" onclick="searchAlerts(${pageMaker.startPage - 1})"><i class="fas fa-chevron-left"></i></a>
            </c:if>
            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                <c:choose>
                    <c:when test="${pageMaker.cri.pagenum == num}">
                        <span class="active-page">${num}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0)" onclick="searchAlerts(${num})">${num}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${pageMaker.next}">
                <a href="javascript:void(0)" onclick="searchAlerts(${pageMaker.endPage + 1})"><i class="fas fa-chevron-right"></i></a>
            </c:if>
        </div>
        </c:if>
    </div>
</div>

<!-- 소명요청 모달 -->
<div id="notifyModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; display:none; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:460px; width:90%; padding:24px;">
        <h3 style="margin:0 0 16px; font-size:1.1rem; color:#1e293b;"><i class="fas fa-envelope"></i> 소명메일발송</h3>
        <p style="font-size:0.85rem; color:#64748b; margin:0 0 16px;">대상자: <strong id="notifyTargetName"></strong></p>
        <input type="hidden" id="notifyAlertId">
        <div style="margin-bottom:12px;">
            <label style="display:block; font-size:0.85rem; font-weight:600; color:#334155; margin-bottom:4px;">대상자 이메일 *</label>
            <input type="email" id="notifyEmail" placeholder="user@example.com"
                   style="width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem;">
        </div>
        <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
            <button class="btn-outline" onclick="closeNotifyModal()">취소</button>
            <button class="btn-monitor" onclick="sendNotification()" style="padding:8px 20px;">
                <i class="fas fa-paper-plane"></i> 발송
            </button>
        </div>
    </div>
</div>

<!-- ========== 무시 처리 모달 (단건 + 일괄 공용) ========== -->
<div id="dismissModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:540px; width:94%; padding:0; overflow:hidden;">
        <!-- 헤더 -->
        <div style="background:#f1f5f9; padding:16px 20px; border-bottom:1px solid #e2e8f0;">
            <h3 id="dismissModalTitle" style="margin:0; font-size:1.05rem; color:#1e293b;"><i class="fas fa-ban" style="color:#ea580c;"></i> 알림 무시 처리</h3>
            <p id="dismissModalDesc" style="margin:6px 0 0; font-size:0.82rem; color:#64748b; display:none;"></p>
        </div>
        <div style="padding:20px;">
            <!-- 법적 안내 -->
            <div style="display:flex; align-items:flex-start; gap:10px; padding:12px 14px; background:#fef3c7; border:1px solid #fde68a; border-radius:8px; margin-bottom:16px;">
                <i class="fas fa-triangle-exclamation" style="color:#d97706; margin-top:2px;"></i>
                <div style="font-size:0.8rem; color:#92400e; line-height:1.6;">
                    <strong>안전성 확보조치 기준 제8조</strong>에 따라 이상행위 알림 처리 내역은 기록이 보관됩니다.
                    무시 사유는 <strong>필수</strong>이며, 감사 시 근거자료로 활용됩니다.
                </div>
            </div>

            <input type="hidden" id="dismissAlertId">
            <input type="hidden" id="dismissRuleId">
            <input type="hidden" id="dismissRuleCode">
            <input type="hidden" id="dismissTargetUserId">
            <input type="hidden" id="dismissSeverity">
            <input type="hidden" id="dismissMode" value="single">

            <!-- 무시 사유 (필수) -->
            <div style="margin-bottom:16px;">
                <label style="display:block; font-size:0.85rem; font-weight:600; color:#334155; margin-bottom:6px;">
                    무시 사유 <span style="color:#dc2626;">*</span>
                </label>
                <select id="dismissReasonType" onchange="onDismissReasonChange()" style="width:100%; padding:8px 10px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem; margin-bottom:8px;">
                    <option value="">-- 사유를 선택하세요 --</option>
                    <option value="오탐 (정상 업무 행위)">오탐 (정상 업무 행위)</option>
                    <option value="테스트/점검 중 발생">테스트/점검 중 발생</option>
                    <option value="배치 작업으로 인한 대량 접근">배치 작업으로 인한 대량 접근</option>
                    <option value="승인된 긴급 작업">승인된 긴급 작업</option>
                    <option value="OTHER">직접 입력</option>
                </select>
                <textarea id="dismissComment" rows="3" placeholder="구체적인 사유를 입력하세요 (필수)"
                          style="width:100%; padding:8px 10px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem; resize:vertical; min-height:60px;"></textarea>
            </div>

            <!-- 향후 알림 예외 등록 옵션 -->
            <div id="suppressionSection" style="padding:14px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; margin-bottom:16px;">
                <label style="display:flex; align-items:flex-start; gap:10px; cursor:pointer;">
                    <input type="checkbox" id="dismissCreateSuppression" style="margin-top:3px;">
                    <div>
                        <strong id="suppressionLabel" style="font-size:0.85rem; color:#1e293b;">이 사용자의 같은 규칙 알림을 앞으로도 무시</strong>
                        <div id="suppressionDesc" style="font-size:0.78rem; color:#64748b; margin-top:4px; line-height:1.5;">
                            동일 사용자 + 동일 탐지 규칙에 대해 일정 기간 알림을 생성하지 않습니다.
                            예외 규칙은 <strong>유효기간이 있으며</strong>, 만료 시 자동 해제됩니다.
                        </div>
                    </div>
                </label>

                <div id="suppressionOptions" style="display:none; margin-top:12px; padding-top:12px; border-top:1px solid #e2e8f0;">
                    <div style="margin-bottom:10px;">
                        <label style="display:block; font-size:0.82rem; font-weight:600; color:#334155; margin-bottom:4px;">예외 유효기간 <span style="color:#dc2626;">*</span></label>
                        <select id="suppressionDuration" style="width:100%; padding:8px 10px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem;">
                            <option value="30">30일</option>
                            <option value="90" selected>90일 (권장)</option>
                            <option value="180">180일</option>
                            <option value="365">1년</option>
                        </select>
                        <div style="font-size:0.75rem; color:#94a3b8; margin-top:4px;">무기한 예외는 허용되지 않습니다. 만료 후 재등록이 필요합니다.</div>
                    </div>
                    <div>
                        <label style="display:block; font-size:0.82rem; font-weight:600; color:#334155; margin-bottom:4px;">정기 검토 주기</label>
                        <select id="suppressionReviewCycle" style="width:100%; padding:8px 10px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem;">
                            <option value="30">매월 (30일)</option>
                            <option value="90" selected>분기 (90일, 권장)</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- 일괄 대상 요약 (일괄 모드에서만 표시) -->
            <div id="bulkDismissSummary" style="display:none; padding:10px 14px; background:#f1f5f9; border:1px solid #e2e8f0; border-radius:8px; margin-bottom:16px; font-size:0.82rem; color:#475569;"></div>

            <!-- 버튼 -->
            <div style="display:flex; gap:8px; justify-content:flex-end;">
                <button class="btn-outline" onclick="closeDismissModal()">취소</button>
                <button id="dismissConfirmBtn" class="btn-monitor" style="padding:8px 20px; background:#ea580c; border-color:#ea580c;" onclick="executeDismiss()">
                    <i class="fas fa-ban"></i> 무시 처리
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 일괄 승인 모달 (승인 전용) -->
<div id="bulkActionModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:480px; width:90%; padding:24px;">
        <h3 id="bulkActionTitle" style="margin:0 0 16px; font-size:1.1rem; color:#1e293b;"></h3>
        <p id="bulkActionDesc" style="font-size:0.85rem; color:#64748b; margin:0 0 16px;"></p>
        <div style="margin-bottom:12px;">
            <label style="display:block; font-size:0.85rem; font-weight:600; color:#334155; margin-bottom:4px;">검토 의견 <span style="color:#dc2626;">*</span></label>
            <textarea id="bulkActionComment" rows="4" placeholder="검토 의견을 입력하세요 (필수)"
                      style="width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; resize:vertical; min-height:80px;"></textarea>
        </div>
        <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
            <button class="btn-outline" onclick="closeBulkActionModal()">취소</button>
            <button id="bulkActionConfirmBtn" class="btn-monitor" style="padding:8px 20px;" onclick="executeBulkAction()"></button>
        </div>
    </div>
</div>

<!-- 알림 상세 모달 -->
<div id="alertDetailModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; display:none; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:720px; width:94%; max-height:88vh; overflow-y:auto; padding:0;" id="alertDetailBody"></div>
</div>

<style>
.summary-tooltip {
    display: none;
    position: absolute;
    left: 0; top: 100%;
    z-index: 100;
    background: #1e293b;
    color: #f1f5f9;
    padding: 10px 14px;
    border-radius: 8px;
    font-size: 0.82rem;
    line-height: 1.5;
    white-space: pre-wrap;
    word-break: break-all;
    min-width: 260px;
    max-width: 420px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.25);
    pointer-events: none;
}
.summary-cell:hover .summary-tooltip {
    display: block;
}
</style>

<script>
var _currentPage = ${pageMaker.cri.pagenum};

// Flatpickr 초기화
$(function() {
    var fpOpts = { locale: 'ko', dateFormat: 'Y-m-d', allowInput: true, onChange: function(s,d,i){ i._input.blur(); } };
    flatpickr('#filterDateFrom', fpOpts);
    flatpickr('#filterDateTo', fpOpts);
});

function searchAlerts(pageNo) {
    if (!pageNo) pageNo = 1;
    var amount = 20;
    var params = {
        search12: $('#filterSeverity').val(),
        search13: $('#filterRuleCode').val(),
        search11: $('#filterAlertStatus').val(),
        search2: $('#filterTargetUser').val(),
        search7: $('#filterDateFrom').val(),
        search8: $('#filterDateTo').val(),
        pagenum: pageNo, amount: amount, offset: (pageNo - 1) * amount
    };
    $.get('/accesslog/alerts', params, function(html) { $('#mainContent').html(html); });
}

// 소명 요청 모달
function openNotifyModal(alertId, targetName) {
    $('#notifyAlertId').val(alertId);
    $('#notifyTargetName').text(targetName);
    $('#notifyEmail').val('');
    $.get('/accesslog/api/alert/' + alertId + '/detail', function(res) {
        if (res && res.memberInfo && res.memberInfo.email) {
            $('#notifyEmail').val(res.memberInfo.email);
        }
    });
    $('#notifyModal').css('display','flex');
}
function openNotifyModalWithEmail(alertId, targetName, email) {
    $('#notifyAlertId').val(alertId);
    $('#notifyTargetName').text(targetName);
    $('#notifyEmail').val(email || '');
    $('#notifyModal').css('display','flex');
}
function closeNotifyModal() { $('#notifyModal').hide(); }

function sendNotification() {
    var alertId = $('#notifyAlertId').val();
    var email = $('#notifyEmail').val().trim();
    if (!email) { dlmAlert('이메일을 입력하세요.'); return; }
    $.ajax({
        url: '/accesslog/api/alert/' + alertId + '/notify',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ targetEmail: email }),
        success: function(res) {
            closeNotifyModal();
            if (res.success) {
                showToast('소명 요청 이메일이 발송되었습니다.', false);
                searchAlerts(_currentPage);
            } else {
                showToast(res.message || '발송 실패', true);
            }
        },
        error: function() { showToast('발송 중 오류가 발생했습니다.', true); }
    });
}


// ========== 무시 처리 모달 (단건 + 일괄 공용) ==========
var _dismissBulkIds = [];

function openDismissModal(alertId, ruleId, ruleCode, targetUserId, severity) {
    // 단건 모드
    _dismissBulkIds = [];
    $('#dismissMode').val('single');
    $('#dismissAlertId').val(alertId);
    $('#dismissRuleId').val(ruleId);
    $('#dismissRuleCode').val(ruleCode);
    $('#dismissTargetUserId').val(targetUserId);
    $('#dismissSeverity').val(severity);
    $('#dismissModalTitle').html('<i class="fas fa-ban" style="color:#ea580c;"></i> 알림 무시 처리');
    $('#dismissModalDesc').hide();
    $('#suppressionSection').show();
    $('#suppressionLabel').text('이 사용자의 같은 규칙 알림을 앞으로도 무시');
    $('#suppressionDesc').html('체크하면 동일 사용자 + 동일 규칙의 <strong>다른 미처리 알림도 함께 무시 처리 되고</strong>, 앞으로 일정 기간 알림이 생성되지 않습니다. 예외 규칙은 <strong>유효기간이 있으며</strong>, 만료 시 자동 해제됩니다.');
    $('#bulkDismissSummary').hide();
    $('#existingSuppressionNotice').remove();
    $('#dismissConfirmBtn').html('<i class="fas fa-ban"></i> 무시 처리');
    _resetDismissForm();
    // 기존 예외 규칙 존재 여부 확인
    _checkExistingSuppression(ruleId, targetUserId);
    $('#dismissModal').css('display','flex');
    setTimeout(function() { $('#dismissReasonType').focus(); }, 100);
}

function _checkExistingSuppression(ruleId, targetUserId) {
    if (!ruleId || !targetUserId) return;
    _checkExistingSuppressionList([{ ruleId: ruleId, ruleCode: $('#dismissRuleCode').val() || ruleId, userId: targetUserId }]);
}

/** 조합 목록에 대해 기존 활성 예외 규칙 존재 여부를 확인하여 안내 표시 */
function _checkExistingSuppressionList(comboList) {
    $('#existingSuppressionNotice').remove();
    if (!comboList || comboList.length === 0) return;
    var found = [], done = 0;
    comboList.forEach(function(c) {
        if (!c.ruleId || !c.userId) { done++; return; }
        $.get('/accesslog/api/suppression/check', { ruleId: c.ruleId, targetUserId: c.userId }, function(res) {
            if (res.exists) {
                found.push({ ruleCode: c.ruleCode || c.ruleId, userId: c.userId, until: res.effectiveUntil, reason: res.reason });
            }
        }).always(function() {
            done++;
            if (done >= comboList.length && found.length > 0) _renderSuppressionNotice(found);
        });
    });
}

function _renderSuppressionNotice(items) {
    $('#existingSuppressionNotice').remove();
    var html = '<div id="existingSuppressionNotice" style="padding:12px 14px; background:#dbeafe; border:1px solid #93c5fd; border-radius:8px; margin-bottom:12px;">'
        + '<div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">'
        + '<i class="fas fa-circle-info" style="color:#2563eb;"></i>'
        + '<strong style="font-size:0.82rem; color:#1e40af;">이미 활성 중인 예외 규칙 ' + items.length + '건</strong>'
        + '</div>';
    items.forEach(function(it) {
        html += '<div style="display:flex; align-items:center; gap:6px; padding:6px 10px; background:#eff6ff; border-radius:6px; margin-bottom:4px; font-size:0.78rem; color:#1e40af;">'
            + '<i class="fas fa-shield-halved" style="color:#3b82f6; font-size:0.7rem;"></i>'
            + '<span><strong>' + escHtml(it.ruleCode) + '</strong> / ' + escHtml(it.userId) + '</span>'
            + '<span style="margin-left:auto; color:#64748b;">만료: ' + escHtml(it.until) + '</span>'
            + '</div>';
    });
    html += '<div style="font-size:0.75rem; color:#64748b; margin-top:6px;">예외 등록 시 기존 예외의 <strong>유효기간이 연장</strong>됩니다. (중복 생성 안 됨)</div>';
    html += '</div>';
    $('#suppressionSection').before(html);
}

function openBulkDismissModal(ids) {
    // 일괄 모드
    _dismissBulkIds = ids;
    $('#dismissMode').val('bulk');
    $('#dismissAlertId').val('');
    $('#dismissModalTitle').html('<i class="fas fa-ban" style="color:#ea580c;"></i> 일괄 무시 처리');
    $('#dismissModalDesc').text('선택한 ' + ids.length + '건의 알림을 무시 처리합니다.').show();

    // 선택된 알림의 규칙+사용자 조합 분석
    var combos = _analyzeBulkAlerts(ids);
    $('#suppressionSection').show();
    if (combos.unique === 1) {
        $('#dismissRuleId').val(combos.ruleId);
        $('#dismissRuleCode').val(combos.ruleCode);
        $('#dismissTargetUserId').val(combos.targetUserId);
        $('#dismissSeverity').val(combos.severity);
        $('#suppressionLabel').text('동일 사용자 + 동일 규칙의 알림을 앞으로도 무시 처리');
        $('#suppressionDesc').html('체크하면 동일 사용자 + 동일 규칙의 <strong>다른 미처리 알림도 함께 무시 처리 되고</strong>, 앞으로 일정 기간 알림이 생성되지 않습니다.');
    } else {
        // 여러 규칙/사용자 → 조합별로 각각 예외 등록
        $('#dismissRuleId').val('');
        $('#dismissRuleCode').val('');
        $('#dismissTargetUserId').val('');
        $('#dismissSeverity').val('');
        $('#suppressionLabel').text('각 사용자+규칙 조합별로 알림을 앞으로도 무시 처리');
        $('#suppressionDesc').html('선택된 알림이 <strong>' + combos.unique + '개 조합</strong>(규칙+대상자)으로 구성되어 있습니다. 체크하면 조합별로 <strong>미처리 알림이 모두 무시 처리 되고</strong>, 각각 예외 규칙이 등록됩니다.');
    }

    // 대상 요약 테이블
    if (combos.list.length > 0) {
        var summary = '<div style="font-weight:600; margin-bottom:6px;">무시 대상 요약</div>';
        summary += '<div style="display:flex; flex-wrap:wrap; gap:4px;">';
        combos.list.forEach(function(c) {
            summary += '<span style="background:#e2e8f0; padding:2px 8px; border-radius:4px; font-size:0.78rem;">' + escHtml(c.ruleCode) + ' / ' + escHtml(c.userId) + ' (' + c.count + '건)</span>';
        });
        summary += '</div>';
        $('#bulkDismissSummary').html(summary).show();
    }

    // 기존 예외 규칙 존재 여부 확인
    _checkExistingSuppressionList(combos.list);

    $('#dismissConfirmBtn').html('<i class="fas fa-ban"></i> ' + ids.length + '건 일괄 무시');
    _resetDismissForm();
    $('#dismissModal').css('display','flex');
    setTimeout(function() { $('#dismissReasonType').focus(); }, 100);
}

function _analyzeBulkAlerts(ids) {
    var comboMap = {};
    var ruleId, ruleCode, targetUserId, severity;
    $('.alert-check:checked').each(function() {
        var $el = $(this);
        if (ids.indexOf(parseInt($el.val())) < 0) return;
        var rid = $el.data('rule-id') || '';
        var rc = $el.data('rule-code') || '';
        var tu = $el.data('target-user') || '';
        var sev = $el.data('severity') || '';
        var key = rid + '|' + tu;
        if (!comboMap[key]) comboMap[key] = { ruleId: rid, ruleCode: rc, userId: tu, severity: sev, count: 0 };
        comboMap[key].count++;
        ruleId = rid; ruleCode = rc; targetUserId = tu; severity = sev;
    });
    var list = Object.values(comboMap);
    return {
        unique: list.length,
        ruleId: ruleId, ruleCode: ruleCode, targetUserId: targetUserId, severity: severity,
        list: list
    };
}

function _resetDismissForm() {
    $('#dismissReasonType').val('');
    $('#dismissComment').val('');
    $('#dismissCreateSuppression').prop('checked', true).prop('disabled', false);
    $('#suppressionOptions').show();
}

function closeDismissModal() {
    $('#dismissModal').hide();
    _dismissBulkIds = [];
    _dismissProcessing = false;
    $('#dismissConfirmBtn').prop('disabled', false).css('opacity', 1);
}

function onDismissReasonChange() {
    var v = $('#dismissReasonType').val();
    if (v && v !== 'OTHER') {
        $('#dismissComment').val(v);
    } else if (v === 'OTHER') {
        $('#dismissComment').val('').focus();
    }
}

$('#dismissCreateSuppression').on('change', function() {
    $('#suppressionOptions').toggle(this.checked);
});

var _dismissProcessing = false;

function executeDismiss() {
    var comment = $('#dismissComment').val().trim();
    if (!comment) { dlmAlert('무시 사유를 입력하세요. (필수)'); $('#dismissComment').focus(); return; }
    if (_dismissProcessing) return;
    _dismissProcessing = true;
    $('#dismissConfirmBtn').prop('disabled', true).css('opacity', 0.6);

    var mode = $('#dismissMode').val();
    var createSuppression = !$('#dismissCreateSuppression').prop('disabled') && $('#dismissCreateSuppression').is(':checked');

    // ── 예외 등록 ON → 통합 API 1회 호출 (서버에서 DB 전체 무시 + 예외 등록) ──
    if (createSuppression) {
        var combos;
        if (mode === 'bulk') {
            combos = _analyzeBulkAlerts(_dismissBulkIds);
        } else {
            combos = {
                list: [{ ruleId: $('#dismissRuleId').val(), ruleCode: $('#dismissRuleCode').val(),
                          userId: $('#dismissTargetUserId').val(), severity: $('#dismissSeverity').val() }]
            };
        }

        var durationDays = parseInt($('#suppressionDuration').val());
        var reviewCycle = parseInt($('#suppressionReviewCycle').val());
        var until = new Date();
        until.setDate(until.getDate() + durationDays);
        var effectiveUntil = until.toISOString().replace('T', ' ').substring(0, 19);

        // alertIds: 선택된 알림 (예외 등록 없는 상태여도 이것들은 확실히 무시)
        var alertIds = (mode === 'bulk') ? _dismissBulkIds : [parseInt($('#dismissAlertId').val())];

        var comboPayload = combos.list.map(function(c) {
            return {
                ruleId: c.ruleId, ruleCode: c.ruleCode,
                targetUserId: c.userId, severity: c.severity,
                effectiveUntil: effectiveUntil, reviewCycleDays: reviewCycle
            };
        });

        $.ajax({
            url: '/accesslog/api/alert/dismiss-with-suppression',
            type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ alertIds: alertIds, comment: comment, combos: comboPayload }),
            success: function(res) {
                if (!res.success) { showToast(res.message || '처리 실패', true); _dismissProcessing = false; $('#dismissConfirmBtn').prop('disabled', false).css('opacity', 1); return; }
                closeDismissModal();
                var msg = res.dismissed + '건 무시 처리 완료.';
                var supps = res.suppressions || [];
                var created = 0, extended = 0;
                supps.forEach(function(s) { if (s.action === 'EXTENDED') extended++; else created++; });
                if (created > 0) msg += ' 예외 규칙 ' + created + '건 등록.';
                if (extended > 0) msg += ' 기존 예외 ' + extended + '건 연장.';
                showToast(msg, false);
                searchAlerts(_currentPage);
            },
            error: function() {
                closeDismissModal();
                showToast('처리 중 오류가 발생했습니다.', true);
                searchAlerts(_currentPage);
            }
        });

    // ── 예외 등록 OFF → 선택한 알림만 무시 ──
    } else {
        if (mode === 'bulk') {
            $.ajax({
                url: '/accesslog/api/alert/bulk-dismiss',
                type: 'POST', contentType: 'application/json',
                data: JSON.stringify({ alertIds: _dismissBulkIds, comment: comment }),
                success: function(res) {
                    closeDismissModal();
                    if (!res.success) { showToast(res.message || '처리 실패', true); return; }
                    showToast(res.updated + '건 무시 처리 완료.', false);
                    searchAlerts(_currentPage);
                },
                error: function() { closeDismissModal(); showToast('처리 중 오류가 발생했습니다.', true); searchAlerts(_currentPage); }
            });
        } else {
            $.ajax({
                url: '/accesslog/api/alert/' + $('#dismissAlertId').val() + '/resolve',
                type: 'POST', contentType: 'application/json',
                data: JSON.stringify({ status: 'DISMISSED', comment: comment }),
                success: function(res) {
                    closeDismissModal();
                    if (!res.success) { showToast('처리 실패', true); return; }
                    showToast('무시 처리되었습니다.', false);
                    searchAlerts(_currentPage);
                },
                error: function() { closeDismissModal(); showToast('처리 중 오류가 발생했습니다.', true); searchAlerts(_currentPage); }
            });
        }
    }
}

// ========== 알림 상세 ==========
function showAlertDetail(alertId) {
    $.get('/accesslog/api/alert/' + alertId + '/detail', function(res) {
        if (!res || !res.alert) { showToast('데이터를 불러올 수 없습니다.', true); return; }
        var a = res.alert;
        var memberEmail = (res.memberInfo && res.memberInfo.email) ? res.memberInfo.email : '';

        var statusLabel = { 'NEW':'신규','NOTIFIED':'소명요청','JUSTIFIED':'소명제출','RESOLVED':'승인완료',
                            'RE_JUSTIFY':'재소명','OVERDUE':'소명기한초과','ESCALATED':'미응답경고','DISMISSED':'무시' };
        var statusClass = { 'NEW':'new-alert','NOTIFIED':'running','JUSTIFIED':'medium','RESOLVED':'completed',
                            'RE_JUSTIFY':'high','OVERDUE':'error','ESCALATED':'error','DISMISSED':'stopped' };
        var severityLabel = { 'HIGH':'높음','MEDIUM':'보통','LOW':'낮음','INFO':'정보' };
        var sevColor = { 'HIGH':'#dc2626','MEDIUM':'#d97706','LOW':'#059669','INFO':'#1d4ed8' };
        var sc = sevColor[a.severity] || '#1d4ed8';

        var html = '';
        html += '<div style="background:' + sc + ';color:#fff;padding:14px 20px;display:flex;align-items:center;justify-content:space-between;">';
        html += '<div style="display:flex;align-items:center;gap:10px;">';
        html += '<span style="font-size:1.1rem;font-weight:700;">' + (severityLabel[a.severity]||a.severity) + '</span>';
        html += '<span style="opacity:0.85;font-size:0.85rem;">' + (a.ruleCode||'') + '</span>';
        html += '<span class="status-badge ' + (statusClass[a.status]||'') + '" style="font-size:0.75rem;">' + (statusLabel[a.status]||a.status) + '</span>';
        html += '</div>';
        html += '<button onclick="$(\'#alertDetailModal\').hide()" style="background:none;border:none;color:#fff;font-size:1.2rem;cursor:pointer;padding:0 4px;"><i class="fas fa-times"></i></button>';
        html += '</div>';

        html += '<div style="padding:16px 20px;">';
        html += '<div style="font-size:1rem;font-weight:600;color:#1e293b;margin-bottom:12px;">' + escHtml(a.alertTitle) + '</div>';

        html += '<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;margin-bottom:14px;font-size:0.85rem;">';
        html += '<div><span style="color:#94a3b8;">대상자</span><div style="font-weight:600;color:#1e293b;">' + escHtml(a.targetUserName) + ' <span style="font-weight:400;color:#64748b;">(' + escHtml(a.targetUserId) + ')</span></div></div>';
        html += '<div><span style="color:#94a3b8;">탐지시간</span><div style="font-weight:600;color:#1e293b;">' + escHtml(a.detectedTime) + '</div></div>';
        html += '<div style="grid-column:1/3;"><span style="color:#94a3b8;">상세</span><div style="color:#334155;background:#f8fafc;padding:8px 10px;border-radius:6px;margin-top:2px;">' + escHtml(a.alertDetail||'-') + '</div></div>';
        html += '</div>';

        if (a.justification) {
            html += '<div style="background:#f0fdfa;border:1px solid #99f6e4;border-radius:8px;padding:12px 14px;margin-bottom:12px;">';
            html += '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">';
            html += '<span style="font-weight:600;color:#0d9488;font-size:0.82rem;"><i class="fas fa-comment-dots"></i> 대상자 소명</span>';
            html += '<span style="font-size:0.72rem;color:#64748b;">' + escHtml(a.justifiedBy||'') + ' | ' + escHtml(a.justifiedAt||'') + '</span>';
            html += '</div>';
            html += '<div style="font-size:0.88rem;color:#334155;white-space:pre-wrap;max-height:200px;overflow-y:auto;padding:8px 0;">' + escHtml(a.justification) + '</div>';
            html += '</div>';
        }

        if (a.approverId) {
            html += '<div style="background:#f1f5f9;border:1px solid #e2e8f0;border-radius:8px;padding:12px 14px;margin-bottom:12px;">';
            html += '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">';
            html += '<span style="font-weight:600;color:#475569;font-size:0.82rem;"><i class="fas fa-check-circle"></i> 관리자 처리</span>';
            html += '<span style="font-size:0.72rem;color:#64748b;">' + escHtml(a.approverId) + ' | ' + escHtml(a.approvedAt||'') + '</span>';
            html += '</div>';
            html += '<div style="font-size:0.88rem;color:#334155;">' + escHtml(a.approvalComment||'-') + '</div>';
            html += '</div>';
        }

        // 무시 처리 정보
        if (a.status === 'DISMISSED' && a.resolvedBy) {
            html += '<div style="background:#f1f5f9;border:1px solid #e2e8f0;border-radius:8px;padding:12px 14px;margin-bottom:12px;">';
            html += '<span style="font-weight:600;color:#64748b;font-size:0.82rem;"><i class="fas fa-ban"></i> 무시 처리</span>';
            html += '<span style="font-size:0.72rem;color:#64748b; margin-left:8px;">' + escHtml(a.resolvedBy) + ' | ' + escHtml(a.resolvedTime||'') + '</span>';
            html += '<div style="font-size:0.88rem;color:#334155;margin-top:6px;">' + escHtml(a.resolveComment||'-') + '</div>';
            html += '</div>';
        }

        if (a.status === 'NEW') {
            html += '<div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">';
            html += '<button class="btn-outline" onclick="$(\'#alertDetailModal\').hide(); openNotifyModalWithEmail(' + a.alertId + ', \'' + escHtml(a.targetUserName||'') + '\', \'' + escHtml(memberEmail) + '\')"><i class=\"fas fa-envelope\"></i> 소명메일발송</button>';
            html += '<button class="btn-outline" style="color:#ea580c;border-color:#fdba74;background:#fff7ed;" onclick="$(\'#alertDetailModal\').hide(); openDismissModal(' + a.alertId + ', \'' + escHtml(a.ruleId||'') + '\', \'' + escHtml(a.ruleCode||'') + '\', \'' + escHtml(a.targetUserId||'') + '\', \'' + escHtml(a.severity||'') + '\')">무시</button>';
            html += '</div>';
        }
        if (a.status === 'JUSTIFIED') {
            html += '<textarea id="approvalComment" rows="4" style="width:100%;padding:8px 10px;border:1px solid #e2e8f0;border-radius:8px;font-size:0.85rem;resize:vertical;min-height:80px;margin-bottom:10px;" placeholder="검토 의견을 입력하세요"></textarea>';
            html += '<div style="display:flex;gap:8px;justify-content:flex-end;">';
            html += '<button class="btn-outline" style="color:#dc2626;border-color:#dc2626;" onclick="rejectAlert(' + a.alertId + ')"><i class="fas fa-redo"></i> 재소명</button>';
            html += '<button class="btn-monitor" style="padding:8px 20px;" onclick="approveAlert(' + a.alertId + ')"><i class="fas fa-check"></i> 승인</button>';
            html += '</div>';
        }

        html += '</div>';
        $('#alertDetailBody').html(html);
        $('#alertDetailModal').css('display','flex');
    });
}

function approveAlert(alertId) {
    var comment = $('#approvalComment').val() || '';
    $.ajax({
        url: '/accesslog/api/alert/' + alertId + '/approve',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ comment: comment }),
        success: function(res) {
            $('#alertDetailModal').hide();
            if (res.success) { showToast('승인 처리되었습니다.', false); searchAlerts(_currentPage); }
            else showToast('승인 실패', true);
        }
    });
}

function rejectAlert(alertId) {
    var comment = $('#approvalComment').val();
    if (!comment || !comment.trim()) { dlmAlert('재소명 사유를 입력하세요.'); return; }
    $.ajax({
        url: '/accesslog/api/alert/' + alertId + '/reject',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ comment: comment }),
        success: function(res) {
            $('#alertDetailModal').hide();
            if (res.success) { showToast('재소명 요청되었습니다.', false); searchAlerts(_currentPage); }
            else showToast('처리 실패', true);
        }
    });
}

function escHtml(s) { return s ? $('<div>').text(s).html() : ''; }

// ========== 일괄 처리 ==========
function toggleCheckAll(el) {
    $('.alert-check').prop('checked', el.checked);
    updateBulkUI();
}
function updateBulkUI() {
    var count = $('.alert-check:checked').length;
    if (count > 0) {
        $('#bulkActions').css('display','flex');
        $('#selectedCount').text(count + '건 선택');
    } else {
        $('#bulkActions').hide();
        $('#checkAll').prop('checked', false);
    }
}
function getCheckedIds(filterStatus) {
    var ids = [];
    $('.alert-check:checked').each(function() {
        if (!filterStatus || filterStatus.indexOf($(this).data('status')) >= 0) {
            ids.push(parseInt($(this).val()));
        }
    });
    return ids;
}
var _bulkActionType = '';
var _bulkActionIds = [];

function bulkDismiss() {
    var ids = getCheckedIds(['NEW','NOTIFIED','OVERDUE','ESCALATED']);
    if (ids.length === 0) { dlmAlert('무시 처리 가능한 알림이 없습니다.\n(신규/소명요청/소명기한초과/미응답경고만 가능)'); return; }
    openBulkDismissModal(ids);
}
var _bulkApproveIds = [];
function bulkApprove() {
    var ids = getCheckedIds(['JUSTIFIED']);
    if (ids.length === 0) { dlmAlert('승인 가능한 알림이 없습니다.\n(소명제출 상태만 승인 가능)'); return; }
    _bulkApproveIds = ids;
    $('#bulkActionTitle').html('<i class="fas fa-check-circle" style="color:var(--monitor-primary);"></i> 일괄 승인 처리');
    $('#bulkActionDesc').text('선택한 ' + ids.length + '건의 소명을 승인합니다.');
    $('#bulkActionComment').val('').attr('placeholder', '검토 의견을 입력하세요 (필수)');
    $('#bulkActionConfirmBtn').html('<i class="fas fa-check"></i> 승인').css({'background':'','border-color':''});
    $('#bulkActionModal').css('display','flex');
    $('#bulkActionComment').focus();
}
function closeBulkActionModal() {
    $('#bulkActionModal').hide();
    _bulkApproveIds = [];
}
function executeBulkAction() {
    var comment = $('#bulkActionComment').val().trim();
    if (!comment) { dlmAlert('검토 의견을 입력하세요.'); $('#bulkActionComment').focus(); return; }
    $.ajax({
        url: '/accesslog/api/alert/bulk-approve',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ alertIds: _bulkApproveIds, comment: comment }),
        success: function(res) {
            closeBulkActionModal();
            if (res.success) { showToast(res.updated + '건이 승인 처리되었습니다.', false); searchAlerts(_currentPage); }
            else showToast(res.message || '처리 실패', true);
        }
    });
}

// 모달 외부 클릭 닫기
$(document).off('click.alertModals').on('click.alertModals', '#notifyModal, #alertDetailModal, #bulkActionModal, #dismissModal', function(e) {
    if (e.target === this) {
        $(this).hide();
        if (this.id === 'dismissModal') { _dismissBulkIds = []; }
        if (this.id === 'bulkActionModal') { _bulkApproveIds = []; }
    }
});
</script>
