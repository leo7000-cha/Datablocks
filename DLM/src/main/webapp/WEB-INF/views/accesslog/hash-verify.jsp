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
                <label for="hashVerifyDate" style="font-size:0.82rem; color:#475569; font-weight:600; white-space:nowrap;">검증 대상일</label>
                <input type="text" id="hashVerifyDate" class="fp-date" style="padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem; height:40px; box-sizing:border-box;" placeholder="날짜 선택" autocomplete="off">
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

            <!-- 검증 이력: 월별 요약 -->
            <h4 style="font-size:0.9rem; color:#334155; margin-bottom:12px;">검증 이력</h4>
            <div id="hashVerifyMonthlyContainer">
                <div style="text-align:center; color:#94a3b8; padding:20px;">로딩 중...</div>
            </div>
        </div>
    </div>
</div>

<script>
$(function() {
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    flatpickr('#hashVerifyDate', { locale: 'ko', dateFormat: 'Y-m-d', allowInput: true, defaultDate: yesterday });
    loadMonthlySummary();
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
            if (res.status === 'NO_DATA') {
                $('#hashVerifyResult').html(
                    '<div style="font-size:1.1rem; color:#f59e0b; margin-bottom:8px; font-weight:600;"><i class="fas fa-circle-exclamation"></i> 해당 날짜에 접속기록이 없습니다.</div>' +
                    '<div style="color:#475569;">검증 대상: <strong>' + date + '</strong> | 저장된 접속기록이 0건이므로 검증을 수행할 수 없습니다. 다른 날짜를 선택해 주세요.</div>'
                );
            } else {
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
            }
            loadMonthlySummary();
        },
        error: function() { $('#hashVerifyResult').html('<span style="color:#ef4444;">검증에 실패했습니다. 잠시 후 다시 시도해주세요.</span>'); }
    });
}

/* ========== 월별 요약 → 일별 상세 ========== */
function loadMonthlySummary() {
    $.get('/accesslog/api/hash-verify/monthly', function(data) {
        var container = $('#hashVerifyMonthlyContainer');
        container.empty();
        if (!data || data.length === 0) {
            container.html('<div style="text-align:center; color:#94a3b8; padding:20px;">아직 검증 이력이 없습니다.</div>');
            return;
        }
        data.forEach(function(m) {
            var ym = m.yearMonth;
            var label = ym.replace('-', '년 ') + '월';
            var hasInvalid = (m.invalidDays || 0) > 0;
            var allValid = !hasInvalid && (m.validDays || 0) > 0;

            // 판정 배지
            var badge;
            if (hasInvalid) {
                badge = '<span class="status-badge error">위반 감지</span>';
            } else if (allValid) {
                badge = '<span class="status-badge completed">정상</span>';
            } else {
                badge = '<span class="status-badge" style="background:#fef3c7; color:#92400e;">기록 없음</span>';
            }

            // 요약 수치 — 라벨:값 칩 형태
            var verifiedDays = m.verifiedDays || 0;
            var validDays = m.validDays || 0;
            var invDays = m.invalidDays || 0;
            var noData = m.noDataDays || 0;
            // 위반의심 = INVALID + NO_DATA(기록자체 없는 날)를 제외한 순수 위반
            var chipStyle = 'display:inline-block; padding:3px 10px; border-radius:6px; font-size:0.78rem; font-weight:600; margin-right:6px;';
            var stats = ''
                + '<span style="' + chipStyle + 'background:#f1f5f9; color:#475569;">검증 일수 <strong style="margin-left:4px;">' + verifiedDays + '</strong></span>'
                + '<span style="' + chipStyle + 'background:#ecfdf5; color:#059669;">정상 <strong style="margin-left:4px;">' + validDays + '</strong></span>'
                + '<span style="' + chipStyle + (invDays > 0 ? 'background:#fef2f2; color:#dc2626;' : 'background:#f1f5f9; color:#94a3b8;') + '">위반 의심 <strong style="margin-left:4px;">' + invDays + '</strong></span>'
                + '<span style="' + chipStyle + 'background:#f1f5f9; color:#64748b; font-weight:500;">접속기록 <strong style="margin-left:4px;">' + (m.totalRecords || 0).toLocaleString() + '건</strong></span>';

            var monthId = 'hv-month-' + ym;
            var html =
                '<div style="border:1px solid #e2e8f0; border-radius:10px; margin-bottom:10px; overflow:hidden;">' +
                    '<div class="hv-month-row" onclick="toggleMonthDetail(\'' + ym + '\')" ' +
                         'style="display:flex; align-items:center; gap:14px; padding:14px 18px; cursor:pointer; transition:background 0.15s; background:' + (hasInvalid ? '#fef2f2' : '#f8fafc') + ';">' +
                        '<i class="fas fa-chevron-right hv-chevron" id="hv-chevron-' + ym + '" style="color:#94a3b8; font-size:0.75rem; transition:transform 0.2s;"></i>' +
                        '<div style="font-weight:700; font-size:0.92rem; color:#1e293b; min-width:100px;">' + label + '</div>' +
                        '<div style="flex:1;">' + stats + '</div>' +
                        badge +
                    '</div>' +
                    '<div id="' + monthId + '" style="display:none; border-top:1px solid #e2e8f0;"></div>' +
                '</div>';
            container.append(html);
        });
    });
}

function toggleMonthDetail(ym) {
    var detailDiv = $('#hv-month-' + ym);
    var chevron = $('#hv-chevron-' + ym);

    if (detailDiv.is(':visible')) {
        detailDiv.slideUp(200);
        chevron.css('transform', 'rotate(0deg)');
        return;
    }

    chevron.css('transform', 'rotate(90deg)');

    // 이미 로드된 경우 그냥 열기
    if (detailDiv.data('loaded')) {
        detailDiv.slideDown(200);
        return;
    }

    detailDiv.html('<div style="text-align:center; padding:16px; color:#94a3b8;"><i class="fas fa-spinner fa-spin"></i> 일별 상세 조회 중...</div>');
    detailDiv.slideDown(200);

    $.get('/accesslog/api/hash-verify/month/' + ym, function(days) {
        if (!days || days.length === 0) {
            detailDiv.html('<div style="text-align:center; padding:16px; color:#94a3b8;">해당 월에 검증 이력이 없습니다.</div>');
            return;
        }
        var table =
            '<table class="monitor-table" style="margin:0; border-radius:0;">' +
            '<thead><tr>' +
                '<th style="width:120px;">검증 대상일</th>' +
                '<th>전체 기록 수</th>' +
                '<th>정상</th>' +
                '<th>위반 의심</th>' +
                '<th style="width:90px;">판정</th>' +
                '<th style="width:130px;">최종 검증일시</th>' +
                '<th style="width:70px;">검증횟수</th>' +
            '</tr></thead><tbody>';
        days.forEach(function(d) {
            var isValid = d.status === 'VALID';
            var isNoData = d.status === 'NO_DATA';
            var badge = isNoData
                ? '<span class="status-badge" style="background:#fef3c7; color:#92400e; font-size:0.75rem;">기록 없음</span>'
                : (isValid
                    ? '<span class="status-badge completed" style="font-size:0.75rem;">정상</span>'
                    : '<span class="status-badge error" style="font-size:0.75rem;">위반</span>');
            var invalidStyle = (d.invalidRecords || 0) > 0 ? 'color:#ef4444; font-weight:600;' : '';
            var runInfo = (d.runCount || 1) > 1
                ? '<span style="color:#6366f1; font-weight:600;">' + d.runCount + '회</span>'
                : '<span style="color:#94a3b8;">1회</span>';
            var completedAt = d.completedAt || '-';
            if (completedAt.length > 16) completedAt = completedAt.substring(0, 16);
            table +=
                '<tr>' +
                '<td style="font-weight:600;">' + (d.verifyDate || '-') + '</td>' +
                '<td>' + (d.totalRecords || 0) + '</td>' +
                '<td>' + (d.validRecords || 0) + '</td>' +
                '<td style="' + invalidStyle + '">' + (d.invalidRecords || 0) + '</td>' +
                '<td>' + badge + '</td>' +
                '<td style="font-size:0.78rem; color:#64748b;">' + completedAt + '</td>' +
                '<td style="text-align:center;">' + runInfo + '</td>' +
                '</tr>';
        });
        table += '</tbody></table>';
        detailDiv.html(table);
        detailDiv.data('loaded', true);
    });
}
</script>
