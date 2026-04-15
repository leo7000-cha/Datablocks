<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="hashVerifyContent">
    <!-- 법적 근거 안내 -->
    <div style="display:flex; align-items:flex-start; gap:14px; padding:16px 20px; background:linear-gradient(135deg, #eff6ff 0%, #f0f9ff 100%); border:1px solid #bfdbfe; border-radius:10px; margin-bottom:20px;">
        <i class="fas fa-scale-balanced" style="color:#2563eb; font-size:1.4rem; margin-top:2px;"></i>
        <div style="flex:1;">
            <div style="font-weight:700; color:#1e40af; margin-bottom:6px; font-size:0.95rem;">왜 이 검증이 필요한가요?</div>
            <div style="color:#475569; font-size:0.85rem; line-height:1.7;">
                <strong>개인정보보호법 제29조</strong> 및 <strong>개인정보의 안전성 확보조치 기준 제8조</strong>에 따라,
                개인정보처리시스템의 접속기록은 <strong>위조·변조 방지</strong> 조치를 취해야 합니다.<br>
                이 화면에서는 저장된 접속기록이 누군가에 의해 <strong>몰래 수정되거나 삭제되지 않았는지</strong> 자동으로 확인합니다.
                각 기록에 고유한 디지털 서명(해시)을 부여하여, 하나라도 변경되면 즉시 탐지됩니다.
            </div>
            <div style="margin-top:10px; padding:10px 14px; background:rgba(255,255,255,0.7); border-radius:6px; border:1px solid #dbeafe;">
                <div style="font-weight:600; color:#1e40af; font-size:0.8rem; margin-bottom:6px;"><i class="fas fa-gavel" style="margin-right:4px;"></i> 관련 법규 요약</div>
                <div style="color:#475569; font-size:0.78rem; line-height:1.7;">
                    <strong>안전성 확보조치 기준 제8조 제2항</strong> — 접속기록의 위·변조 여부를 <strong style="color:#dc2626;">월 1회 이상</strong> 정기적으로 점검해야 합니다.<br>
                    <strong>안전성 확보조치 기준 제8조 제1항</strong> — 접속기록을 <strong>최소 2년</strong> 이상 보관해야 하며, 5만명 이상 고유식별정보 처리 시 <strong>최소 5년</strong>입니다.<br>
                    <strong>전자금융감독규정 제13조</strong> — 금융기관은 중요원장 접속기록을 <strong>5년 이상</strong> 보관하고, 위·변조 방지 조치를 갖추어야 합니다.
                </div>
            </div>
        </div>
    </div>

    <!-- 검증 실행 -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">저장기록 위·변조 검증</h3>
            <div style="display:flex; align-items:center; gap:10px;">
                <input type="text" id="hashVerifyDate" class="fp-date" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem; height:40px; box-sizing:border-box;" placeholder="검증 대상일" autocomplete="off">
                <button class="btn-monitor" style="height:40px; box-sizing:border-box; white-space:nowrap;" onclick="runHashVerify()"><i class="fas fa-shield-check"></i> 검증 즉시 실행</button>
            </div>
        </div>
        <div class="panel-body">
            <!-- 검증 방법 간단 설명 -->
            <div style="display:flex; gap:16px; margin-bottom:20px;">
                <div style="flex:1; padding:14px; background:#f8fafc; border-radius:8px; border:1px solid #e2e8f0;">
                    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">
                        <i class="fas fa-link" style="color:#6366f1;"></i>
                        <strong style="color:#334155; font-size:0.85rem;">어떻게 검증하나요?</strong>
                    </div>
                    <div style="color:#64748b; font-size:0.82rem; line-height:1.6;">
                        모든 접속기록은 저장 시 이전 기록과 <strong>체인처럼 연결</strong>됩니다.
                        중간에 하나라도 변경되면 연결이 끊어져 <strong>위·변조를 즉시 발견</strong>할 수 있습니다.
                    </div>
                </div>
                <div style="flex:1; padding:14px; background:#f8fafc; border-radius:8px; border:1px solid #e2e8f0;">
                    <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">
                        <i class="fas fa-circle-question" style="color:#6366f1;"></i>
                        <strong style="color:#334155; font-size:0.85rem;">결과 해석</strong>
                    </div>
                    <div style="color:#64748b; font-size:0.82rem; line-height:1.6;">
                        <span style="color:#10b981; font-weight:600;">정상</span> — 모든 기록이 원본 그대로 보존됨<br>
                        <span style="color:#ef4444; font-weight:600;">위반</span> — 일부 기록이 변경 또는 삭제된 것으로 의심됨
                    </div>
                </div>
            </div>

            <!-- 검증 결과 -->
            <div id="hashVerifyResult" style="padding:16px; background:#f8fafc; border-radius:8px; text-align:center; color:#64748b; margin-bottom:20px;">
                날짜를 선택하고 <strong>검증 즉시 실행</strong>을 클릭하면, 해당일 접속기록이 원본 그대로 보존되었는지 확인합니다. (미선택 시 전일자)
            </div>

            <!-- 자동 검증 스케줄 -->
            <div style="padding:14px 18px; background:#f0fdf4; border:1px solid #bbf7d0; border-radius:8px; margin-bottom:20px;">
                <div style="display:flex; align-items:center; gap:16px;">
                    <i class="fas fa-clock" style="color:#16a34a; font-size:1.2rem;"></i>
                    <div style="flex:1;">
                        <strong>자동 검증 스케줄</strong>
                        <span style="color:#64748b; font-size:0.85rem; margin-left:8px;">매월 1일 새벽 자동 실행 — 지난달 접속기록 전체를 자동으로 점검합니다.</span>
                    </div>
                    <span class="status-badge completed">활성</span>
                </div>
                <div style="margin-top:8px; padding-left:36px; color:#475569; font-size:0.78rem; line-height:1.5;">
                    <i class="fas fa-circle-info" style="color:#16a34a; margin-right:4px;"></i>
                    법적 요구사항(<strong>월 1회 이상</strong> 점검)을 충족하기 위한 자동 스케줄입니다.
                    스케줄 변경은 <strong>환경설정 &gt; 일반 &gt; 해시 검증 스케줄</strong>에서 가능합니다.
                </div>
            </div>

            <!-- 검증 이력 테이블 -->
            <h4 style="font-size:0.9rem; color:#334155; margin-bottom:12px;">검증 이력</h4>
            <table class="monitor-table" id="hashVerifyHistoryTable">
                <thead>
                    <tr>
                        <th>검증일시</th>
                        <th>검증 대상일</th>
                        <th>전체 기록 수</th>
                        <th>정상</th>
                        <th>위반 의심</th>
                        <th>판정</th>
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
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    flatpickr('#hashVerifyDate', { locale: 'ko', dateFormat: 'Y-m-d', allowInput: true, defaultDate: yesterday });
    loadHashVerifyHistory();
});

function runHashVerify() {
    var date = $('#hashVerifyDate').val();
    if (!date) {
        var yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        date = yesterday.toISOString().split('T')[0];
    }
    $('#hashVerifyResult').html('<i class="fas fa-spinner fa-spin"></i> ' + date + ' 접속기록을 점검하고 있습니다...');
    $.ajax({
        url: '/accesslog/api/hash-verify',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ date: date }),
        success: function(res) {
            var isValid = res.status === 'VALID';
            var statusColor = isValid ? '#10b981' : '#ef4444';
            var icon = isValid ? 'fa-check-circle' : 'fa-times-circle';
            var statusText = isValid ? '정상 — 모든 기록이 원본 그대로 보존되어 있습니다.' : '위반 감지 — 일부 기록이 변경된 것으로 의심됩니다.';
            var invalidInfo = '';
            if (res.invalidRecords > 0 && res.firstInvalidId) {
                invalidInfo = '<div style="margin-top:8px; color:#ef4444; font-size:0.85rem;">최초 위반 의심 기록 ID: ' + res.firstInvalidId + '</div>';
            }
            $('#hashVerifyResult').html(
                '<div style="font-size:1.1rem; color:' + statusColor + '; margin-bottom:8px; font-weight:600;"><i class="fas ' + icon + '"></i> ' + statusText + '</div>' +
                '<div style="color:#475569;">검증 대상: <strong>' + date + '</strong> | 전체 ' + res.totalRecords + '건 | 정상 ' + res.validRecords + '건 | 위반 의심 <span style="color:' + (res.invalidRecords > 0 ? '#ef4444' : '#10b981') + '; font-weight:600;">' + res.invalidRecords + '건</span></div>' +
                invalidInfo
            );
            loadHashVerifyHistory();
        },
        error: function() { $('#hashVerifyResult').html('<span style="color:#ef4444;">검증에 실패했습니다. 잠시 후 다시 시도해주세요.</span>'); }
    });
}

function loadHashVerifyHistory() {
    $.get('/accesslog/api/hash-verify', function(data) {
        var tbody = $('#hashVerifyHistoryBody');
        tbody.empty();
        if (!data || data.length === 0) {
            tbody.html('<tr><td colspan="6" style="text-align:center; color:#94a3b8; padding:20px;">아직 검증 이력이 없습니다.</td></tr>');
            return;
        }
        data.forEach(function(row) {
            var isValid = row.status === 'VALID';
            var statusBadge = isValid
                ? '<span class="status-badge completed">정상</span>'
                : '<span class="status-badge error">위반 감지</span>';
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
