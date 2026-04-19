<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="reportsContent">
    <!-- 법규 안내 -->
    <div style="display:flex; gap:16px; margin-bottom:20px;">
        <div style="flex:1; display:flex; align-items:flex-start; gap:12px; padding:14px 18px; background:linear-gradient(135deg,#dbeafe 0%,#eff6ff 100%); border:1px solid #93c5fd; border-radius:10px;">
            <i class="fas fa-file-lines" style="color:#2563eb; font-size:1.2rem; margin-top:2px;"></i>
            <div>
                <div style="font-weight:700; color:#1e40af; font-size:0.88rem; margin-bottom:4px;">접속기록 보고서</div>
                <div style="color:#1e3a5f; font-size:0.78rem; line-height:1.7;">
                    <strong>개인정보보호법 안전성확보조치 기준 제8조</strong>에 따라 접속기록을 <strong>월 1회 이상 점검</strong>하고 결과를 기록해야 합니다.<br>
                    보고서를 생성하여 감사 증빙자료로 활용하고, 이상행위 및 컴플라이언스 준수 현황을 체계적으로 관리할 수 있습니다.
                </div>
                <div style="margin-top:8px; padding:8px 12px; background:rgba(255,255,255,0.6); border-radius:6px; border:1px solid #bfdbfe; font-size:0.73rem; color:#1e40af; line-height:1.6;">
                    <i class="fas fa-gavel" style="margin-right:4px;"></i>
                    <strong>제8조 제3항</strong> — 월 1회 이상 접속기록 점검 &nbsp;|&nbsp;
                    <strong>전자금융감독규정 제14조</strong> — 가동기록 1년 보존 &nbsp;|&nbsp;
                    <strong>ISMS-P</strong><span style="font-weight:400;">(정보보호 및 개인정보보호 관리체계 인증, KISA 운영)</span> — 보안 인증 감사 자료
                </div>
            </div>
        </div>
        <div style="width:340px; flex-shrink:0; padding:14px 18px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px;">
            <div style="font-weight:600; color:#475569; font-size:0.82rem; margin-bottom:8px;">
                <i class="fas fa-clipboard-list" style="color:#2563eb; margin-right:6px;"></i>보고서 유형
            </div>
            <div style="font-size:0.75rem; color:#64748b; line-height:1.9;">
                <span style="display:inline-block; background:#dbeafe; color:#1d4ed8; padding:1px 8px; border-radius:4px; font-weight:600; margin-right:4px;">R1</span> 정기 점검 보고서 (법적 의무)<br>
                <span style="display:inline-block; background:#fef3c7; color:#92400e; padding:1px 8px; border-radius:4px; font-weight:600; margin-right:4px;">R2</span> 이상행위 탐지 보고서<br>
                <span style="display:inline-block; background:#d1fae5; color:#065f46; padding:1px 8px; border-radius:4px; font-weight:600; margin-right:4px;">R3</span> 사용자 행동 분석 보고서<br>
                <span style="display:inline-block; background:#fce7f3; color:#9d174d; padding:1px 8px; border-radius:4px; font-weight:600; margin-right:4px;">R4</span> 법규 준수 현황 보고서
            </div>
        </div>
    </div>

    <!-- 보고서 생성 폼 -->
    <div class="content-panel" style="margin-bottom:20px;">
        <div class="panel-header">
            <h3 class="panel-title"><i class="fas fa-plus-circle" style="color:var(--monitor-primary); margin-right:6px;"></i>보고서 생성</h3>
        </div>
        <div class="panel-body" style="padding:20px;">
            <div style="display:flex; gap:16px; align-items:flex-end; flex-wrap:wrap;">
                <div>
                    <label style="display:block; font-size:0.78rem; font-weight:600; color:#475569; margin-bottom:5px;">보고서 유형</label>
                    <select id="genReportType" style="width:260px; padding:8px 12px; border:1px solid #cbd5e1; border-radius:8px; font-size:0.85rem;">
                        <option value="PERIODIC">정기 점검 보고서 (R1)</option>
                        <option value="ANOMALY">이상행위 탐지 보고서 (R2)</option>
                        <option value="USER_BEHAVIOR">사용자 행동 분석 보고서 (R3)</option>
                        <option value="COMPLIANCE">법규 준수 현황 보고서 (R4)</option>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:0.78rem; font-weight:600; color:#475569; margin-bottom:5px;">시작일</label>
                    <input type="text" id="genDateFrom" class="fp-date" style="width:160px; padding:8px 12px; border:1px solid #cbd5e1; border-radius:8px; font-size:0.85rem;" placeholder="YYYY-MM-DD" autocomplete="off">
                </div>
                <div>
                    <label style="display:block; font-size:0.78rem; font-weight:600; color:#475569; margin-bottom:5px;">종료일</label>
                    <input type="text" id="genDateTo" class="fp-date" style="width:160px; padding:8px 12px; border:1px solid #cbd5e1; border-radius:8px; font-size:0.85rem;" placeholder="YYYY-MM-DD" autocomplete="off">
                </div>
                <div>
                    <button id="btnGenerate" class="btn-monitor" style="padding:8px 24px; font-size:0.85rem;" onclick="generateReport()">
                        <i class="fas fa-file-export"></i> 보고서 생성
                    </button>
                </div>
            </div>
            <div style="margin-top:10px; font-size:0.73rem; color:#94a3b8;">
                <i class="fas fa-info-circle" style="margin-right:4px;"></i>
                정기 점검 보고서는 전월 1일~말일 기간으로 매월 생성하는 것을 권장합니다. 생성된 보고서는 Excel(XLSX) 파일로 다운로드할 수 있습니다.
            </div>
        </div>
    </div>

    <!-- 필터 바 -->
    <div class="filter-bar">
        <select id="filterType" style="width:220px;" onchange="searchReports(1)">
            <option value="">유형 (전체)</option>
            <option value="PERIODIC">정기 점검</option>
            <option value="ANOMALY">이상행위 탐지</option>
            <option value="USER_BEHAVIOR">사용자 행동 분석</option>
            <option value="COMPLIANCE">법규 준수</option>
        </select>
        <select id="filterStatus" style="width:160px;" onchange="searchReports(1)">
            <option value="">상태 (전체)</option>
            <option value="COMPLETED">완료</option>
            <option value="GENERATING">생성중</option>
            <option value="FAILED">실패</option>
        </select>
        <input type="text" id="filterDateFrom" class="fp-date" style="width:150px;" placeholder="생성일 FROM" autocomplete="off">
        <span style="color:#94a3b8; font-size:0.85rem;">~</span>
        <input type="text" id="filterDateTo" class="fp-date" style="width:150px;" placeholder="생성일 TO" autocomplete="off">
        <button class="btn-monitor" onclick="searchReports(1)"><i class="fas fa-search"></i> 조회</button>
    </div>

    <!-- 보고서 목록 -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">보고서 목록 <span style="color:var(--monitor-primary); font-size:0.85rem;">(<span id="reportTotal">${total}</span>건)</span></h3>
        </div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table" id="reportTable">
                <thead>
                    <tr>
                        <th style="width:50px;">No</th>
                        <th style="width:120px;">유형</th>
                        <th>보고서명</th>
                        <th style="width:100px;">분석기간</th>
                        <th style="width:80px;">상태</th>
                        <th style="width:150px;">생성일시</th>
                        <th style="width:80px;">생성자</th>
                        <th style="width:150px;">작업</th>
                    </tr>
                </thead>
                <tbody id="reportTbody">
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr><td colspan="8" style="text-align:center; padding:40px; color:#94a3b8;">
                                <i class="fas fa-file-circle-question" style="font-size:2rem; display:block; margin-bottom:10px;"></i>
                                생성된 보고서가 없습니다. 위에서 보고서를 생성해보세요.
                            </td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="r" items="${list}" varStatus="st">
                                <tr>
                                    <td style="text-align:center;">${st.count}</td>
                                    <td><span class="report-type-badge ${r.reportType}">${r.reportType == 'PERIODIC' ? '정기 점검' : r.reportType == 'ANOMALY' ? '이상행위' : r.reportType == 'USER_BEHAVIOR' ? '사용자 행동' : r.reportType == 'COMPLIANCE' ? '법규 준수' : r.reportType}</span></td>
                                    <td style="font-weight:500;">${r.reportName}</td>
                                    <td style="font-size:0.78rem; color:#64748b;">${r.dateFrom}~${r.dateTo}</td>
                                    <td>
                                        <span class="status-badge ${r.reportStatus}">
                                            ${r.reportStatus == 'COMPLETED' ? '완료' : r.reportStatus == 'GENERATING' ? '생성중' : '실패'}
                                        </span>
                                    </td>
                                    <td style="font-size:0.8rem; color:#64748b;">${r.generatedAt}</td>
                                    <td style="text-align:center;">${r.generatedBy}</td>
                                    <td style="text-align:center;">
                                        <c:if test="${r.reportStatus == 'COMPLETED'}">
                                            <button class="btn-sm btn-primary" onclick="downloadReport(${r.reportId})" title="다운로드">
                                                <i class="fas fa-download"></i>
                                            </button>
                                            <button class="btn-sm btn-info" onclick="viewReportDetail(${r.reportId})" title="상세보기">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </c:if>
                                        <button class="btn-sm btn-danger" onclick="deleteReport(${r.reportId})" title="삭제">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 보고서 상세 모달 -->
    <div id="reportDetailModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center;">
        <div style="background:#fff; border-radius:12px; width:800px; max-height:80vh; overflow-y:auto; box-shadow:0 25px 50px -12px rgba(0,0,0,0.25);">
            <div style="padding:20px 24px; border-bottom:1px solid #e2e8f0; display:flex; align-items:center; justify-content:space-between;">
                <h3 style="margin:0; font-size:1.1rem; color:#1e293b;"><i class="fas fa-file-lines" style="color:#2563eb; margin-right:8px;"></i>보고서 상세</h3>
                <button onclick="closeDetailModal()" style="background:none; border:none; font-size:1.2rem; color:#94a3b8; cursor:pointer;"><i class="fas fa-times"></i></button>
            </div>
            <div id="reportDetailContent" style="padding:24px;"></div>
        </div>
    </div>
</div>

<style>
.report-type-badge {
    display:inline-block; padding:3px 10px; border-radius:6px; font-size:0.75rem; font-weight:600;
}
.report-type-badge.PERIODIC { background:#dbeafe; color:#1d4ed8; }
.report-type-badge.ANOMALY { background:#fef3c7; color:#92400e; }
.report-type-badge.USER_BEHAVIOR { background:#d1fae5; color:#065f46; }
.report-type-badge.COMPLIANCE { background:#fce7f3; color:#9d174d; }
.report-type-badge.AI_ANALYSIS { background:#e0e7ff; color:#4338ca; }

.status-badge { display:inline-block; padding:3px 10px; border-radius:6px; font-size:0.73rem; font-weight:600; }
.status-badge.COMPLETED { background:#d1fae5; color:#065f46; }
.status-badge.GENERATING { background:#fef3c7; color:#92400e; }
.status-badge.FAILED { background:#fee2e2; color:#991b1b; }

.btn-sm { padding:4px 10px; border:none; border-radius:6px; cursor:pointer; font-size:0.75rem; transition:all 0.15s; }
.btn-sm.btn-primary { background:#dbeafe; color:#1d4ed8; }
.btn-sm.btn-primary:hover { background:#bfdbfe; }
.btn-sm.btn-info { background:#e0e7ff; color:#4338ca; }
.btn-sm.btn-info:hover { background:#c7d2fe; }
.btn-sm.btn-danger { background:#fee2e2; color:#991b1b; }
.btn-sm.btn-danger:hover { background:#fecaca; }

.detail-section { margin-bottom:20px; }
.detail-section h4 { font-size:0.9rem; color:#1e293b; margin-bottom:10px; padding-bottom:6px; border-bottom:2px solid #e2e8f0; }
.detail-grid { display:grid; grid-template-columns:repeat(3, 1fr); gap:12px; }
.detail-card { background:#f8fafc; padding:14px; border-radius:8px; border:1px solid #e2e8f0; }
.detail-card .label { font-size:0.72rem; color:#94a3b8; font-weight:600; text-transform:uppercase; margin-bottom:4px; }
.detail-card .value { font-size:1.1rem; font-weight:700; color:#1e293b; }
.checklist-item { display:flex; align-items:center; gap:10px; padding:10px 14px; background:#f8fafc; border-radius:8px; margin-bottom:6px; border:1px solid #e2e8f0; }
.checklist-item .pass { color:#059669; font-weight:700; }
.checklist-item .fail { color:#dc2626; font-weight:700; }
</style>

<script>
$(function() {
    // Flatpickr 날짜 선택기 초기화
    if (typeof flatpickr !== 'undefined') {
        flatpickr('#genDateFrom', { dateFormat: 'Y-m-d', defaultDate: getLastMonthFirst() });
        flatpickr('#genDateTo', { dateFormat: 'Y-m-d', defaultDate: getLastMonthLast() });
        flatpickr('#filterDateFrom', { dateFormat: 'Y-m-d' });
        flatpickr('#filterDateTo', { dateFormat: 'Y-m-d' });
    }
});

function getLastMonthFirst() {
    var d = new Date();
    d.setMonth(d.getMonth() - 1);
    return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-01';
}
function getLastMonthLast() {
    var d = new Date();
    d.setDate(0);
    return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
}

function generateReport() {
    var reportType = $('#genReportType').val();
    var dateFrom = $('#genDateFrom').val();
    var dateTo = $('#genDateTo').val();

    if (!dateFrom || !dateTo) {
        alert('기간을 선택해주세요.');
        return;
    }
    if (dateFrom > dateTo) {
        alert('시작일이 종료일보다 늦을 수 없습니다.');
        return;
    }

    var typeNames = { PERIODIC:'정기 점검', ANOMALY:'이상행위 탐지', USER_BEHAVIOR:'사용자 행동 분석', COMPLIANCE:'법규 준수 현황' };
    if (!confirm(typeNames[reportType] + ' 보고서를 생성하시겠습니까?\n기간: ' + dateFrom + ' ~ ' + dateTo)) return;

    var $btn = $('#btnGenerate');
    $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 생성 중...');

    $.ajax({
        url: '/accesslog/api/report/generate',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ reportType: reportType, dateFrom: dateFrom, dateTo: dateTo, reportFormat: 'XLSX' }),
        success: function(res) {
            if (res.success) {
                alert('보고서가 생성되었습니다.');
                searchReports(1);
            } else {
                alert('보고서 생성 실패: ' + (res.message || ''));
            }
        },
        error: function() { alert('서버 오류가 발생했습니다.'); },
        complete: function() { $btn.prop('disabled', false).html('<i class="fas fa-file-export"></i> 보고서 생성'); }
    });
}

function searchReports(page) {
    var params = {
        pageNum: page || 1,
        amount: 20,
        search1: $('#filterType').val(),
        search2: $('#filterStatus').val(),
        search7: $('#filterDateFrom').val(),
        search8: $('#filterDateTo').val()
    };

    $.get('/accesslog/api/report/list', params, function(res) {
        if (!res.success) return;
        $('#reportTotal').text(res.total);
        var tbody = $('#reportTbody');
        tbody.empty();

        if (!res.list || res.list.length === 0) {
            tbody.append('<tr><td colspan="8" style="text-align:center; padding:40px; color:#94a3b8;">' +
                '<i class="fas fa-file-circle-question" style="font-size:2rem; display:block; margin-bottom:10px;"></i>' +
                '조건에 맞는 보고서가 없습니다.</td></tr>');
            return;
        }

        var typeNames = { PERIODIC:'정기 점검', ANOMALY:'이상행위', USER_BEHAVIOR:'사용자 행동', COMPLIANCE:'법규 준수', AI_ANALYSIS:'AI 분석' };
        var statusNames = { COMPLETED:'완료', GENERATING:'생성중', FAILED:'실패' };

        $.each(res.list, function(i, r) {
            var actions = '';
            if (r.reportStatus === 'COMPLETED') {
                actions += '<button class="btn-sm btn-primary" onclick="downloadReport(' + r.reportId + ')" title="다운로드"><i class="fas fa-download"></i></button> ';
                actions += '<button class="btn-sm btn-info" onclick="viewReportDetail(' + r.reportId + ')" title="상세보기"><i class="fas fa-eye"></i></button> ';
            }
            actions += '<button class="btn-sm btn-danger" onclick="deleteReport(' + r.reportId + ')" title="삭제"><i class="fas fa-trash"></i></button>';

            tbody.append(
                '<tr>' +
                '<td style="text-align:center;">' + (i + 1) + '</td>' +
                '<td><span class="report-type-badge ' + r.reportType + '">' + (typeNames[r.reportType] || r.reportType) + '</span></td>' +
                '<td style="font-weight:500;">' + r.reportName + '</td>' +
                '<td style="font-size:0.78rem; color:#64748b;">' + r.dateFrom + '~' + r.dateTo + '</td>' +
                '<td><span class="status-badge ' + r.reportStatus + '">' + (statusNames[r.reportStatus] || r.reportStatus) + '</span></td>' +
                '<td style="font-size:0.8rem; color:#64748b;">' + (r.generatedAt || '') + '</td>' +
                '<td style="text-align:center;">' + (r.generatedBy || '') + '</td>' +
                '<td style="text-align:center;">' + actions + '</td>' +
                '</tr>'
            );
        });
    });
}

function downloadReport(reportId) {
    window.location.href = '/accesslog/api/report/' + reportId + '/download';
}

function deleteReport(reportId) {
    if (!confirm('이 보고서를 삭제하시겠습니까?')) return;
    $.ajax({
        url: '/accesslog/api/report/' + reportId,
        type: 'DELETE',
        success: function(res) {
            if (res.success) {
                searchReports(1);
            } else {
                alert('삭제 실패: ' + (res.message || ''));
            }
        }
    });
}

function viewReportDetail(reportId) {
    $.get('/accesslog/api/report/' + reportId + '/detail', function(res) {
        if (!res.success || !res.report) { alert('보고서를 찾을 수 없습니다.'); return; }
        var r = res.report;
        var data = {};
        try { data = JSON.parse(r.summaryJson || '{}'); } catch(e) {}

        var html = '';

        // 기본 정보
        html += '<div class="detail-section">';
        html += '<h4><i class="fas fa-info-circle" style="color:#2563eb; margin-right:6px;"></i>기본 정보</h4>';
        html += '<div class="detail-grid">';
        html += '<div class="detail-card"><div class="label">보고서 유형</div><div class="value" style="font-size:0.9rem;">' + r.reportName + '</div></div>';
        html += '<div class="detail-card"><div class="label">분석 기간</div><div class="value" style="font-size:0.9rem;">' + r.dateFrom + ' ~ ' + r.dateTo + '</div></div>';
        html += '<div class="detail-card"><div class="label">생성 일시</div><div class="value" style="font-size:0.9rem;">' + r.generatedAt + '</div></div>';
        html += '</div></div>';

        // 보고서 유형별 요약
        if (r.reportType === 'PERIODIC' || r.reportType === 'ANOMALY') {
            html += '<div class="detail-section">';
            html += '<h4><i class="fas fa-chart-bar" style="color:#059669; margin-right:6px;"></i>요약 통계</h4>';
            html += '<div class="detail-grid">';
            html += cardHtml('총 접속 건수', formatNum(data.totalAccessCount));
            if (data.userCount != null) html += cardHtml('접속자 수', formatNum(data.userCount) + '명');
            if (data.afterHoursCount != null) html += cardHtml('업무시간 외 접속', formatNum(data.afterHoursCount) + '건');
            if (data.heavyRepeatCount != null) html += cardHtml('대량 반복 조회', formatNum(data.heavyRepeatCount) + '건');
            html += cardHtml('이상행위 탐지', formatNum(data.totalAlertCount) + '건');
            if (data.resolvedAlertCount != null) html += cardHtml('승인 완료', formatNum(data.resolvedAlertCount) + '건');
            if (data.pendingAlertCount != null) html += cardHtml('미처리', formatNum(data.pendingAlertCount) + '건');
            html += '</div></div>';
        }

        if (r.reportType === 'USER_BEHAVIOR') {
            html += '<div class="detail-section">';
            html += '<h4><i class="fas fa-users" style="color:#7c3aed; margin-right:6px;"></i>사용자 행동 요약</h4>';
            html += '<div class="detail-grid">';
            html += cardHtml('분석 대상 사용자', formatNum(data.userCount) + '명');
            html += cardHtml('업무시간 외 접속', formatNum(data.afterHoursCount) + '건');
            var deptCount = data.deptAccessStats ? data.deptAccessStats.length : 0;
            html += cardHtml('부서 수', deptCount + '개');
            html += '</div></div>';
        }

        // 컴플라이언스 체크리스트
        if (r.reportType === 'COMPLIANCE' && data.complianceChecklist) {
            html += '<div class="detail-section">';
            html += '<h4><i class="fas fa-clipboard-check" style="color:#059669; margin-right:6px;"></i>컴플라이언스 체크리스트</h4>';
            $.each(data.complianceChecklist, function(i, item) {
                var icon = item.status === 'PASS'
                    ? '<i class="fas fa-check-circle pass" style="font-size:1.1rem;"></i>'
                    : '<i class="fas fa-times-circle fail" style="font-size:1.1rem;"></i>';
                html += '<div class="checklist-item">' + icon +
                    '<div style="flex:1;"><div style="font-weight:600; font-size:0.82rem; color:#1e293b;">' + item.requirement + '</div>' +
                    '<div style="font-size:0.73rem; color:#64748b; margin-top:2px;">' + item.regulation + '</div></div>' +
                    '<div style="font-size:0.78rem; color:#64748b;">' + item.detail + '</div>' +
                    '<span class="' + (item.status === 'PASS' ? 'pass' : 'fail') + '" style="font-size:0.8rem;">' + item.status + '</span>' +
                    '</div>';
            });
            html += '</div>';
        }

        // 다운로드 버튼
        html += '<div style="text-align:center; margin-top:20px; padding-top:16px; border-top:1px solid #e2e8f0;">';
        html += '<button class="btn-monitor" onclick="downloadReport(' + r.reportId + ')" style="padding:10px 32px;">';
        html += '<i class="fas fa-download" style="margin-right:6px;"></i>Excel 다운로드</button>';
        html += '</div>';

        $('#reportDetailContent').html(html);
        $('#reportDetailModal').css('display', 'flex');
    });
}

function closeDetailModal() { $('#reportDetailModal').hide(); }
$(document).on('click', '#reportDetailModal', function(e) {
    if (e.target === this) closeDetailModal();
});

function cardHtml(label, value) {
    return '<div class="detail-card"><div class="label">' + label + '</div><div class="value">' + (value || '-') + '</div></div>';
}
function formatNum(n) { return n != null ? Number(n).toLocaleString() : '0'; }
</script>
