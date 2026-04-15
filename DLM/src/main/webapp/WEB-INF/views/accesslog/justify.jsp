<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>이상행위 소명</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; box-sizing: border-box; }
        body { background: #f8fafc; margin: 0; padding: 20px; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .justify-container { max-width: 640px; width: 100%; }
        .card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; }
        .card-header { padding: 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; }
        .card-header .icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .card-header .icon.high { background: #fee2e2; color: #dc2626; }
        .card-header .icon.medium { background: #fef3c7; color: #d97706; }
        .card-header .icon.low { background: #d1fae5; color: #059669; }
        .card-header .icon.info { background: #dbeafe; color: #1d4ed8; }
        .card-header h1 { font-size: 1.25rem; font-weight: 700; color: #1e293b; margin: 0; }
        .card-header p { font-size: 0.85rem; color: #64748b; margin: 4px 0 0; }
        .card-body { padding: 24px; }
        .alert-info { display: grid; grid-template-columns: 120px 1fr; gap: 12px; margin-bottom: 24px; }
        .alert-info dt { font-weight: 600; color: #64748b; font-size: 0.85rem; padding: 4px 0; }
        .alert-info dd { color: #334155; font-size: 0.9rem; margin: 0; padding: 4px 0; }
        .severity-badge { display: inline-flex; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .severity-badge.high { background: #fee2e2; color: #dc2626; }
        .severity-badge.medium { background: #fef3c7; color: #d97706; }
        .severity-badge.low { background: #d1fae5; color: #059669; }
        .severity-badge.info { background: #dbeafe; color: #1d4ed8; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-weight: 600; color: #334155; font-size: 0.85rem; margin-bottom: 6px; }
        .form-group input, .form-group textarea {
            width: 100%; padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 0.9rem; color: #334155; transition: border-color 0.2s;
        }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #0d9488; box-shadow: 0 0 0 3px rgba(13,148,136,0.1); }
        .form-group textarea { min-height: 120px; resize: vertical; }
        .form-group .hint { font-size: 0.75rem; color: #94a3b8; margin-top: 4px; }
        .btn-submit {
            width: 100%; padding: 14px; background: linear-gradient(135deg, #0d9488, #0f766e);
            color: #fff; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(13,148,136,0.4); }
        .btn-submit:disabled { opacity: 0.5; cursor: not-allowed; transform: none; box-shadow: none; }
        .error-card { text-align: center; padding: 60px 24px; }
        .error-card .error-icon { width: 64px; height: 64px; background: #fee2e2; color: #dc2626; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 16px; }
        .error-card h2 { font-size: 1.1rem; color: #1e293b; margin: 0 0 8px; }
        .error-card p { color: #64748b; font-size: 0.9rem; }
        .success-card { text-align: center; padding: 60px 24px; }
        .success-card .success-icon { width: 64px; height: 64px; background: #d1fae5; color: #059669; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 16px; }
        .success-card h2 { font-size: 1.1rem; color: #1e293b; margin: 0 0 8px; }
        .success-card p { color: #64748b; font-size: 0.9rem; }
        .brand { text-align: center; margin-top: 24px; font-size: 0.75rem; color: #94a3b8; }
    </style>
</head>
<body>
<div class="justify-container">
    <c:choose>
        <c:when test="${not empty error}">
            <div class="card">
                <div class="error-card">
                    <div class="error-icon">!</div>
                    <h2>${error}</h2>
                    <p>문의사항이 있으시면 보안관리자에게 연락해 주십시오.</p>
                </div>
            </div>
        </c:when>
        <c:when test="${not empty alert}">
            <div class="card" id="formCard">
                <div class="card-header">
                    <div class="icon ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">&#9888;</div>
                    <div>
                        <h1>이상행위 소명 요청</h1>
                        <p>아래 탐지 내역을 확인하고 소명(사유)을 입력해 주십시오.</p>
                    </div>
                </div>
                <div class="card-body">
                    <dl class="alert-info">
                        <dt>심각도</dt>
                        <dd><span class="severity-badge ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">${alert.severity == 'HIGH' ? '높음' : alert.severity == 'MEDIUM' ? '보통' : alert.severity == 'LOW' ? '낮음' : '정보'} (${alert.severity})</span></dd>
                        <dt>탐지 규칙</dt>
                        <dd>${alert.ruleName} (${alert.ruleCode})</dd>
                        <dt>알림 내용</dt>
                        <dd>${alert.alertTitle}</dd>
                        <dt>상세</dt>
                        <dd>${alert.alertDetail}</dd>
                        <dt>대상자</dt>
                        <dd>${alert.targetUserName} (${alert.targetUserId})</dd>
                        <dt>탐지 시간</dt>
                        <dd>${alert.detectedTime}</dd>
                    </dl>

                    <div class="form-group">
                        <label for="justifiedBy">소명자 성명 *</label>
                        <input type="text" id="justifiedBy" placeholder="성명을 입력하세요" value="${alert.targetUserName}">
                    </div>
                    <div class="form-group">
                        <label for="justification">소명 사유 *</label>
                        <textarea id="justification" placeholder="해당 행위에 대한 사유를 상세히 입력해 주십시오."></textarea>
                        <div class="hint">업무 목적, 사유, 관련 승인 내역 등을 포함하여 작성해 주십시오.</div>
                    </div>
                    <button class="btn-submit" id="btnSubmit" onclick="submitJustification()">소명 제출</button>
                </div>
            </div>
            <div class="card" id="successCard" style="display:none;">
                <div class="success-card">
                    <div class="success-icon">&#10003;</div>
                    <h2>소명이 제출되었습니다</h2>
                    <p>관리자 검토 후 처리 결과를 안내드리겠습니다.</p>
                </div>
            </div>
        </c:when>
    </c:choose>
    <div class="brand">X-Audit 접속기록관리</div>
</div>

<c:if test="${not empty alert}">
<script src="/resources/vendor/jquery/jquery.min.js"></script>
<script>
function dlmAlert(msg, callback) {
    var $m = $('#_dlmAlertOverlay');
    if ($m.length === 0) {
        $('body').append(
            '<div id="_dlmAlertOverlay" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.4);z-index:100000;align-items:center;justify-content:center;">' +
            '  <div style="background:#fff;border-radius:14px;max-width:380px;width:90%;padding:28px 24px 20px;box-shadow:0 12px 40px rgba(0,0,0,0.18);text-align:center;">' +
            '    <div style="width:48px;height:48px;background:#fef3c7;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 14px;">' +
            '      <span style="color:#f59e0b;font-size:1.3rem;font-weight:bold;">!</span>' +
            '    </div>' +
            '    <div id="_dlmAlertMsg" style="font-size:0.9rem;color:#334155;line-height:1.6;white-space:pre-line;margin-bottom:20px;"></div>' +
            '    <button id="_dlmAlertOk" style="background:linear-gradient(135deg,#0d9488,#0f766e);color:#fff;border:none;padding:10px 36px;border-radius:8px;font-size:0.85rem;font-weight:600;cursor:pointer;">확인</button>' +
            '  </div>' +
            '</div>'
        );
        $m = $('#_dlmAlertOverlay');
        $m.on('click', '#_dlmAlertOk', function() {
            $m.hide();
            var cb = $m.data('callback');
            if (typeof cb === 'function') cb();
        });
        $(document).on('keydown', function(e) {
            if (e.key === 'Escape' && $m.is(':visible')) { $m.hide(); }
        });
    }
    $('#_dlmAlertMsg').text(msg);
    $m.data('callback', callback || null);
    $m.css('display','flex');
    setTimeout(function() { $('#_dlmAlertOk').focus(); }, 50);
}
function submitJustification() {
    var justification = $('#justification').val().trim();
    var justifiedBy = $('#justifiedBy').val().trim();
    if (!justification) { dlmAlert('소명 사유를 입력해 주십시오.'); return; }
    if (!justifiedBy) { dlmAlert('소명자 성명을 입력해 주십시오.'); return; }

    $('#btnSubmit').prop('disabled', true).text('제출 중...');
    $.ajax({
        url: '/accesslog/justify/${token}/submit',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ justification: justification, justifiedBy: justifiedBy }),
        success: function(res) {
            if (res.success) {
                $('#formCard').hide();
                $('#successCard').show();
            } else {
                dlmAlert(res.message || '제출에 실패했습니다.');
                $('#btnSubmit').prop('disabled', false).text('소명 제출');
            }
        },
        error: function() {
            dlmAlert('서버 오류가 발생했습니다.');
            $('#btnSubmit').prop('disabled', false).text('소명 제출');
        }
    });
}
</script>
</c:if>
</body>
</html>
