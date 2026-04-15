<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="suppressionsContent">
    <!-- 법적 근거 안내 -->
    <div style="display:flex; align-items:flex-start; gap:14px; padding:14px 18px; background:linear-gradient(135deg, #eff6ff 0%, #f0f9ff 100%); border:1px solid #bfdbfe; border-radius:10px; margin-bottom:16px;">
        <i class="fas fa-scale-balanced" style="color:#2563eb; font-size:1.3rem; margin-top:2px;"></i>
        <div style="flex:1;">
            <div style="font-weight:700; color:#1e40af; margin-bottom:4px; font-size:0.9rem;">알림 예외 규칙 관리</div>
            <div style="color:#475569; font-size:0.82rem; line-height:1.6;">
                <strong>안전성 확보조치 기준 제8조</strong>에 따라 이상행위 탐지의 예외 처리는 <strong>사유 기록, 유효기간 설정, 정기 검토</strong>가 필수입니다.
                모든 등록/변경/비활성화 이력은 감사 로그에 자동 보관되며, 만료된 규칙은 자동 해제됩니다.
            </div>
        </div>
    </div>

    <!-- 필터 -->
    <div class="filter-bar">
        <select id="filterSuppressionActive" style="width:140px;" onchange="searchSuppressions(1)">
            <option value="">상태 (전체)</option>
            <option value="Y" ${pageMaker.cri.search11 == 'Y' ? 'selected' : ''}>활성</option>
            <option value="N" ${pageMaker.cri.search11 == 'N' ? 'selected' : ''}>비활성</option>
        </select>
        <select id="filterSuppressionRule" style="width:200px;" onchange="searchSuppressions(1)">
            <option value="">규칙 (전체)</option>
            <c:forEach var="rule" items="${ruleList}">
                <option value="${rule.ruleId}" ${pageMaker.cri.search12 == rule.ruleId ? 'selected' : ''}>${rule.ruleCode} - ${rule.ruleName}</option>
            </c:forEach>
        </select>
        <input type="text" id="filterSuppressionUser" placeholder="대상자" style="width:140px;" value="${pageMaker.cri.search2}" onkeydown="if(event.key==='Enter') searchSuppressions(1)">
        <button class="btn-monitor" onclick="searchSuppressions(1)"><i class="fas fa-search"></i> 조회</button>
    </div>

    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">알림 예외 규칙 <span style="color:var(--monitor-primary); font-size:0.85rem;">(${total}건)</span></h3>
        </div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table">
                <thead>
                    <tr>
                        <th>규칙</th>
                        <th>대상자</th>
                        <th>예외 사유</th>
                        <th>유효기간</th>
                        <th>다음 검토</th>
                        <th>상태</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty list}">
                            <c:forEach var="s" items="${list}">
                                <tr style="cursor:pointer;" onclick="showSuppressionDetail(${s.suppressionId})">
                                    <td>
                                        <div style="font-weight:600; font-size:0.85rem;">${s.ruleCode}</div>
                                        <div style="font-size:0.75rem; color:#64748b;">${s.ruleName}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty s.targetUserId}">${s.targetUserId}</c:when>
                                            <c:otherwise><span style="color:#94a3b8; font-style:italic;">전체 사용자</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; font-size:0.82rem;" title="${s.reason}">${s.reason}</td>
                                    <td style="white-space:nowrap; font-size:0.82rem;">
                                        <div>${s.effectiveFrom}</div>
                                        <div style="color:#64748b;">~ ${s.effectiveUntil}</div>
                                    </td>
                                    <td style="white-space:nowrap; font-size:0.82rem;">
                                        <c:choose>
                                            <c:when test="${s.isActive == 'Y' && not empty s.nextReviewAt}">
                                                <span style="color:#d97706;">${s.nextReviewAt}</span>
                                            </c:when>
                                            <c:otherwise><span style="color:#94a3b8;">-</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="white-space:nowrap;">
                                        <c:choose>
                                            <c:when test="${s.isActive == 'Y'}"><span class="status-badge completed">활성</span></c:when>
                                            <c:otherwise><span class="status-badge stopped">비활성</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="white-space:nowrap;" onclick="event.stopPropagation();">
                                        <c:if test="${s.isActive == 'Y'}">
                                            <button class="btn-outline" style="padding:4px 8px; font-size:0.7rem;" onclick="reviewSuppression(${s.suppressionId})">
                                                <i class="fas fa-clipboard-check"></i> 검토
                                            </button>
                                            <button class="btn-outline" style="padding:4px 8px; font-size:0.7rem; color:#dc2626; border-color:#fca5a5;" onclick="deactivateSuppression(${s.suppressionId})">
                                                <i class="fas fa-power-off"></i> 해제
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="7" style="text-align:center; padding:40px; color:#94a3b8;">등록된 예외 규칙이 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <c:if test="${total > 0}">
        <div class="pagination-wrap">
            <c:if test="${pageMaker.prev}">
                <a href="javascript:void(0)" onclick="searchSuppressions(${pageMaker.startPage - 1})"><i class="fas fa-chevron-left"></i></a>
            </c:if>
            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                <c:choose>
                    <c:when test="${pageMaker.cri.pagenum == num}">
                        <span class="active-page">${num}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:void(0)" onclick="searchSuppressions(${num})">${num}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${pageMaker.next}">
                <a href="javascript:void(0)" onclick="searchSuppressions(${pageMaker.endPage + 1})"><i class="fas fa-chevron-right"></i></a>
            </c:if>
        </div>
        </c:if>
    </div>
</div>

<!-- 상세/감사 로그 모달 -->
<div id="suppressionDetailModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:680px; width:94%; max-height:85vh; overflow-y:auto; padding:0;" id="suppressionDetailBody"></div>
</div>

<!-- 검토 모달 -->
<div id="reviewModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:460px; width:90%; padding:24px;">
        <h3 style="margin:0 0 16px; font-size:1.05rem; color:#1e293b;"><i class="fas fa-clipboard-check" style="color:var(--monitor-primary);"></i> 예외 규칙 정기 검토</h3>
        <p style="font-size:0.82rem; color:#64748b; margin:0 0 16px;">이 예외 규칙이 여전히 유효한지 검토하고 의견을 기록합니다.</p>
        <input type="hidden" id="reviewSuppressionId">
        <div style="margin-bottom:12px;">
            <label style="display:block; font-size:0.85rem; font-weight:600; color:#334155; margin-bottom:4px;">검토 의견 <span style="color:#dc2626;">*</span></label>
            <textarea id="reviewComment" rows="4" placeholder="예외 규칙의 유효성에 대한 검토 의견을 입력하세요"
                      style="width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; resize:vertical;"></textarea>
        </div>
        <div style="display:flex; gap:8px; justify-content:flex-end;">
            <button class="btn-outline" onclick="$('#reviewModal').hide()">취소</button>
            <button class="btn-monitor" style="padding:8px 20px;" onclick="executeReview()"><i class="fas fa-check"></i> 검토 완료</button>
        </div>
    </div>
</div>

<!-- 해제 모달 -->
<div id="deactivateModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:460px; width:90%; padding:24px;">
        <h3 style="margin:0 0 16px; font-size:1.05rem; color:#dc2626;"><i class="fas fa-power-off"></i> 예외 규칙 해제</h3>
        <p style="font-size:0.82rem; color:#64748b; margin:0 0 16px;">이 예외 규칙을 비활성화하면 해당 조건의 알림이 다시 생성됩니다.</p>
        <input type="hidden" id="deactivateSuppressionId">
        <div style="margin-bottom:12px;">
            <label style="display:block; font-size:0.85rem; font-weight:600; color:#334155; margin-bottom:4px;">해제 사유 <span style="color:#dc2626;">*</span></label>
            <textarea id="deactivateReason" rows="3" placeholder="해제 사유를 입력하세요"
                      style="width:100%; padding:10px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.9rem; resize:vertical;"></textarea>
        </div>
        <div style="display:flex; gap:8px; justify-content:flex-end;">
            <button class="btn-outline" onclick="$('#deactivateModal').hide()">취소</button>
            <button class="btn-monitor" style="padding:8px 20px; background:#dc2626; border-color:#dc2626;" onclick="executeDeactivate()"><i class="fas fa-power-off"></i> 해제</button>
        </div>
    </div>
</div>

<script>
var _suppressionPage = ${pageMaker.cri.pagenum};

function searchSuppressions(pageNo) {
    if (!pageNo) pageNo = 1;
    var amount = 20;
    var params = {
        search11: $('#filterSuppressionActive').val(),
        search12: $('#filterSuppressionRule').val(),
        search2: $('#filterSuppressionUser').val(),
        pagenum: pageNo, amount: amount, offset: (pageNo - 1) * amount
    };
    $.get('/accesslog/suppressions', params, function(html) { $('#mainContent').html(html); });
}

function showSuppressionDetail(id) {
    $.get('/accesslog/api/suppression/' + id, function(res) {
        if (!res || !res.suppression) { showToast('데이터를 불러올 수 없습니다.', true); return; }
        var s = res.suppression;
        var auditLog = res.auditLog || [];

        var html = '';
        // 헤더
        html += '<div style="background:#475569; color:#fff; padding:14px 20px; display:flex; align-items:center; justify-content:space-between;">';
        html += '<span style="font-weight:700; font-size:1rem;">예외 규칙 상세</span>';
        html += '<button onclick="$(\'#suppressionDetailModal\').hide()" style="background:none;border:none;color:#fff;font-size:1.2rem;cursor:pointer;"><i class="fas fa-times"></i></button>';
        html += '</div>';

        html += '<div style="padding:16px 20px;">';
        // 기본 정보
        html += '<div style="display:grid; grid-template-columns:1fr 1fr; gap:10px 16px; margin-bottom:16px; font-size:0.85rem;">';
        html += '<div><span style="color:#94a3b8;">규칙</span><div style="font-weight:600;">' + escHtml(s.ruleCode) + ' — ' + escHtml(s.ruleName||'') + '</div></div>';
        html += '<div><span style="color:#94a3b8;">대상자</span><div style="font-weight:600;">' + (s.targetUserId ? escHtml(s.targetUserId) : '<span style="color:#94a3b8;">전체</span>') + '</div></div>';
        html += '<div><span style="color:#94a3b8;">등록 시 심각도</span><div>' + escHtml(s.severityAtTime||'-') + '</div></div>';
        html += '<div><span style="color:#94a3b8;">상태</span><div>' + (s.isActive === 'Y' ? '<span class="status-badge completed">활성</span>' : '<span class="status-badge stopped">비활성</span>') + '</div></div>';
        html += '<div style="grid-column:1/3;"><span style="color:#94a3b8;">예외 사유</span><div style="background:#f8fafc; padding:8px 10px; border-radius:6px; margin-top:2px;">' + escHtml(s.reason) + '</div></div>';
        html += '<div><span style="color:#94a3b8;">유효기간</span><div>' + escHtml(s.effectiveFrom||'') + ' ~ ' + escHtml(s.effectiveUntil||'') + '</div></div>';
        html += '<div><span style="color:#94a3b8;">검토 주기</span><div>' + s.reviewCycleDays + '일</div></div>';
        html += '<div><span style="color:#94a3b8;">등록자 / 승인자</span><div>' + escHtml(s.regUserId||'-') + ' / ' + escHtml(s.approvedBy||'-') + '</div></div>';
        html += '<div><span style="color:#94a3b8;">다음 검토일</span><div style="color:#d97706;">' + escHtml(s.nextReviewAt||'-') + '</div></div>';
        html += '</div>';

        // 비활성화 정보
        if (s.isActive === 'N' && s.deactivatedBy) {
            html += '<div style="background:#fef2f2; border:1px solid #fecaca; border-radius:8px; padding:10px 14px; margin-bottom:14px; font-size:0.82rem;">';
            html += '<strong style="color:#dc2626;">비활성화:</strong> ' + escHtml(s.deactivatedBy) + ' (' + escHtml(s.deactivatedAt||'') + ')';
            html += '<div style="color:#7f1d1d; margin-top:4px;">' + escHtml(s.deactivateReason||'-') + '</div>';
            html += '</div>';
        }

        // 감사 로그
        html += '<h4 style="font-size:0.88rem; color:#334155; margin:16px 0 10px; border-top:1px solid #e2e8f0; padding-top:14px;">변경 이력 (감사 로그)</h4>';
        if (auditLog.length > 0) {
            html += '<div style="max-height:250px; overflow-y:auto;">';
            html += '<table class="monitor-table" style="font-size:0.8rem;">';
            html += '<thead><tr><th>일시</th><th>유형</th><th>내용</th><th>수행자</th></tr></thead><tbody>';
            for (var i = 0; i < auditLog.length; i++) {
                var log = auditLog[i];
                var typeColor = {'CREATE':'#10b981','REVIEW':'#6366f1','DEACTIVATE':'#dc2626','EXTEND':'#d97706'}[log.actionType] || '#475569';
                html += '<tr><td style="white-space:nowrap;">' + escHtml(log.actionAt||'') + '</td>';
                html += '<td><span style="color:' + typeColor + '; font-weight:600;">' + escHtml(log.actionType) + '</span></td>';
                html += '<td style="max-width:260px; word-break:break-all;">' + escHtml(log.actionDetail||'-') + '</td>';
                html += '<td>' + escHtml(log.actionBy||'-') + '</td></tr>';
            }
            html += '</tbody></table></div>';
        } else {
            html += '<div style="text-align:center; color:#94a3b8; padding:16px;">감사 로그가 없습니다.</div>';
        }

        html += '</div>';
        $('#suppressionDetailBody').html(html);
        $('#suppressionDetailModal').css('display','flex');
    });
}

function escHtml(s) { return s ? $('<div>').text(s).html() : ''; }

// 검토
function reviewSuppression(id) {
    $('#reviewSuppressionId').val(id);
    $('#reviewComment').val('');
    $('#reviewModal').css('display','flex');
    setTimeout(function() { $('#reviewComment').focus(); }, 100);
}
function executeReview() {
    var comment = $('#reviewComment').val().trim();
    if (!comment) { dlmAlert('검토 의견을 입력하세요.'); return; }
    $.ajax({
        url: '/accesslog/api/suppression/' + $('#reviewSuppressionId').val() + '/review',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ comment: comment }),
        success: function(res) {
            $('#reviewModal').hide();
            if (res.success) { showToast('검토가 완료되었습니다.', false); searchSuppressions(_suppressionPage); }
            else showToast('처리 실패', true);
        }
    });
}

// 해제
function deactivateSuppression(id) {
    $('#deactivateSuppressionId').val(id);
    $('#deactivateReason').val('');
    $('#deactivateModal').css('display','flex');
    setTimeout(function() { $('#deactivateReason').focus(); }, 100);
}
function executeDeactivate() {
    var reason = $('#deactivateReason').val().trim();
    if (!reason) { dlmAlert('해제 사유를 입력하세요.'); return; }
    $.ajax({
        url: '/accesslog/api/suppression/' + $('#deactivateSuppressionId').val() + '/deactivate',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ reason: reason }),
        success: function(res) {
            $('#deactivateModal').hide();
            if (res.success) { showToast('예외 규칙이 해제되었습니다.', false); searchSuppressions(_suppressionPage); }
            else showToast('처리 실패', true);
        }
    });
}

// 모달 외부 클릭 닫기
$(document).off('click.suppressionModals').on('click.suppressionModals', '#suppressionDetailModal, #reviewModal, #deactivateModal', function(e) {
    if (e.target === this) $(this).hide();
});
</script>
