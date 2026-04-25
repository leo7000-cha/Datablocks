<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="logsContent">
    <!-- Quick Filter (수집 경로별 빠른 진입) -->
    <div class="quickfilter-row" id="quickFilterRow">
        <button type="button" class="qf-chip active" data-collect="">
            <i class="fas fa-layer-group"></i> 전체
        </button>
        <button type="button" class="qf-chip" data-collect="DB_AUDIT">
            <i class="fas fa-database"></i> DB Audit
        </button>
        <button type="button" class="qf-chip" data-collect="DB_DAC">
            <i class="fas fa-shield-alt"></i> DB 접근제어
        </button>
        <button type="button" class="qf-chip" data-collect="WAS_AGENT">
            <i class="fas fa-server"></i> WAS Agent
        </button>
        <button type="button" class="qf-chip" data-collect="WAS_SDK">
            <i class="fas fa-network-wired"></i> 처리계 SDK
        </button>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar" style="flex-wrap:wrap; gap:10px;">
        <input type="text" id="filterStartDate" class="fp-date" style="width:150px;" placeholder="FROM" autocomplete="off">
        <span style="color:#94a3b8; font-size:0.85rem;">~</span>
        <input type="text" id="filterEndDate" class="fp-date" style="width:150px;" placeholder="TO" autocomplete="off">
        <input type="text" id="filterUser" placeholder="사용자" style="width:120px;">
        <select id="filterAction" style="width:130px;">
            <option value="">작업유형</option>
            <option value="SELECT">SELECT</option>
            <option value="UPDATE">UPDATE</option>
            <option value="DELETE">DELETE</option>
            <option value="INSERT">INSERT</option>
            <option value="DOWNLOAD">DOWNLOAD</option>
            <option value="HTTP_ACCESS">HTTP_ACCESS</option>
        </select>
        <select id="filterPiiGrade" style="width:110px;">
            <option value="">PII등급</option>
            <option value="1">1급</option>
            <option value="2">2급</option>
            <option value="3">3급</option>
        </select>
        <input type="text" id="filterTable" placeholder="테이블/서비스/URI" style="width:170px;">
        <select id="filterSourceType" style="width:130px;">
            <option value="">수집 방식</option>
            <option value="DB_AUDIT">DB Audit</option>
            <option value="DB_DAC">DB 접근제어</option>
            <option value="WAS_AGENT">WAS Agent</option>
            <option value="WAS_SDK">처리계 SDK</option>
        </select>
        <input type="hidden" id="filterAmount" value="100">
        <button class="btn-monitor" onclick="searchLogs(1)"><i class="fas fa-search"></i> 조회</button>
        <button class="btn-outline" onclick="exportLogs()" id="btnExport" style="display:none;"><i class="fas fa-download"></i> Excel</button>
    </div>

    <!-- 필터 안내 -->
    <div id="logFilterGuide" style="padding:60px 20px; text-align:center;">
        <div style="width:80px; height:80px; background:#f1f5f9; border-radius:50%; display:flex; align-items:center; justify-content:center; margin:0 auto 20px;">
            <i class="fas fa-filter" style="font-size:2rem; color:#94a3b8;"></i>
        </div>
        <h3 style="font-size:1.1rem; font-weight:600; color:#475569; margin-bottom:8px;">조회 조건을 입력해 주세요</h3>
        <p style="color:#94a3b8; font-size:0.88rem; line-height:1.6; margin-bottom:0;">
            조회 기간(FROM ~ TO)은 필수이며, 최대 <strong style="color:#0d9488;">1개월</strong>까지 조회 가능합니다.<br>
            사용자, 작업유형, 테이블명 등 추가 조건을 입력하면 더 빠르게 조회할 수 있습니다.
        </p>
    </div>

    <!-- Results -->
    <div class="content-panel" id="logResultPanel" style="display:none;">
        <div class="panel-header">
            <h3 class="panel-title">접속기록 <span id="logTotalCount" style="color:var(--monitor-primary); font-size:0.85rem;"></span></h3>
        </div>
        <div class="panel-body" style="padding:0; overflow-x:auto;">
            <table class="monitor-table" id="logTable">
                <thead>
                    <tr>
                        <th>No</th><th>접속일시</th><th>사용자</th><th>접속IP</th><th>작업유형</th>
                        <th>대상DB·테이블 / Service·URI</th><th>처리 컬럼 / SQL</th>
                        <th>PII등급</th><th>결과</th><th>수집 방식</th>
                    </tr>
                </thead>
                <tbody id="logTableBody">
                </tbody>
            </table>
        </div>
        <!-- Pagination -->
        <div class="pagination-wrap" id="logPagination"></div>
    </div>
</div>

<script>
var _logCurrentPage = 1;

$(function() {
    var today = new Date();
    var weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 7);
    var todayStr = today.toISOString().split('T')[0];
    var weekAgoStr = weekAgo.toISOString().split('T')[0];
    var fpOpts = { locale: 'ko', dateFormat: 'Y-m-d', allowInput: true, onChange: function(s,d,i){ i._input.blur(); } };
    flatpickr('#filterStartDate', Object.assign({}, fpOpts, { defaultDate: weekAgoStr }));
    flatpickr('#filterEndDate', Object.assign({}, fpOpts, { defaultDate: todayStr }));

    // Quick filter chip → 수집 방식 드롭다운 동기화 + 즉시 조회
    $('#quickFilterRow').on('click', '.qf-chip', function() {
        var collect = $(this).data('collect') || '';
        $('.qf-chip').removeClass('active');
        $(this).addClass('active');
        $('#filterSourceType').val(collect);
        searchLogs(1);
    });

    // 수집 방식 드롭다운 변경 시 chip 동기화
    $('#filterSourceType').on('change', function() {
        var v = $(this).val() || '';
        $('.qf-chip').removeClass('active');
        $('.qf-chip[data-collect="' + v + '"]').addClass('active');
    });
});

function validateFilters() {
    var startDate = $('#filterStartDate').val();
    var endDate = $('#filterEndDate').val();

    if (!startDate || !endDate) {
        dlmAlert('조회 기간(FROM ~ TO)을 모두 입력해 주세요.');
        return false;
    }

    var start = new Date(startDate);
    var end = new Date(endDate);
    var diffDays = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    if (diffDays < 0) {
        dlmAlert('시작일이 종료일보다 이후입니다.');
        return false;
    }
    if (diffDays > 31) {
        dlmAlert('조회 기간은 최대 1개월(31일)까지 가능합니다.\n기간을 줄이거나 추가 조건을 입력해 주세요.');
        return false;
    }
    return true;
}

function formatCollectType(type) {
    if (type === 'DB_AUDIT') return '<span class="status-badge info" style="font-size:0.68rem;">DB Audit</span>';
    if (type === 'DB_DAC') return '<span class="status-badge info" style="font-size:0.68rem;background:#fef3c7;color:#92400e;">DB 접근제어</span>';
    if (type === 'WAS_AGENT') return '<span class="status-badge info" style="font-size:0.68rem;background:#ede9fe;color:#7c3aed;">WAS Agent</span>';
    if (type === 'WAS_SDK') return '<span class="status-badge info" style="font-size:0.68rem;background:#cffafe;color:#0e7490;">처리계 SDK</span>';
    return type || '';
}

function formatTargetCell(log) {
    // WAS_SDK 는 service_name + URI, 그 외는 target_db.target_table
    if (log.collectType === 'WAS_SDK') {
        var svc = log.serviceName || '';
        var uri = log.uri || '';
        var top = svc ? '<strong>' + escHtml(svc) + '</strong>' : '<span style="color:#cbd5e1;">-</span>';
        var bottom = uri ? '<div style="color:#64748b; font-size:0.72rem; margin-top:2px;">' + (log.httpMethod || '') + ' ' + escHtml(uri) + '</div>' : '';
        return top + bottom;
    }
    var db = log.targetDb || '';
    var tbl = log.targetTable || '';
    if (!db && !tbl) return '<span style="color:#cbd5e1;">-</span>';
    var top = tbl ? '<strong>' + escHtml(tbl) + '</strong>' : '<span style="color:#cbd5e1;">-</span>';
    var bottom = db ? '<div style="color:#64748b; font-size:0.72rem; margin-top:2px;">' + escHtml(db) + '</div>' : '';
    return top + bottom;
}

function formatColsCell(log) {
    // WAS_SDK SQL 행은 sqlText 짧게, ACCESS 행은 dash, 기타는 targetColumns
    if (log.collectType === 'WAS_SDK') {
        if (log.actionType === 'HTTP_ACCESS') {
            return '<span style="color:#cbd5e1;">(요청 본문)</span>';
        }
        var sql = log.sqlText || '';
        var sqlShort = sql.length > 60 ? sql.substring(0, 60) + '…' : sql;
        return sql ? '<span class="sql-cell" title="' + escHtml(sql) + '">' + escHtml(sqlShort) + '</span>' : '<span style="color:#cbd5e1;">-</span>';
    }
    var cols = log.targetColumns || '';
    var colsShort = cols.length > 40 ? cols.substring(0, 40) + '…' : cols;
    return cols ? '<span class="sql-cell" title="' + escHtml(cols) + '">' + escHtml(colsShort) + '</span>' : '<span style="color:#cbd5e1;">-</span>';
}

function searchLogs(pageNum) {
    if (!validateFilters()) {
        var $guide = $('#logFilterGuide');
        $guide.show();
        $('#logResultPanel').hide();
        $guide.css('animation', 'none');
        setTimeout(function() { $guide.css('animation', 'shake 0.4s'); }, 10);
        return;
    }

    _logCurrentPage = pageNum || 1;
    var amount = parseInt($('#filterAmount').val());
    var tableOrUri = $('#filterTable').val().trim();

    var params = {
        pagenum: _logCurrentPage,
        amount: amount,
        search7: $('#filterStartDate').val() ? $('#filterStartDate').val() + ' 00:00:00' : '',
        search8: $('#filterEndDate').val() ? $('#filterEndDate').val() + ' 23:59:59' : '',
        search2: $('#filterUser').val().trim(),
        search3: $('#filterAction').val(),
        search6: $('#filterPiiGrade').val(),
        search5: tableOrUri,
        search11: $('#filterSourceType').val()
    };

    $('#logFilterGuide').hide();
    $('#logResultPanel').show();
    $('#logTableBody').html('<tr><td colspan="10" style="text-align:center; padding:40px; color:#94a3b8;"><i class="fas fa-spinner fa-spin"></i> 조회 중...</td></tr>');

    $.get('/accesslog/api/logs', params, function(res) {
        var list = res.list || [];
        var total = res.total || 0;
        var pageMaker = res.pageMaker;

        $('#logTotalCount').text('(' + total.toLocaleString() + '건)');
        $('#btnExport').toggle(total > 0);

        var tbody = $('#logTableBody');
        tbody.empty();

        if (list.length === 0) {
            tbody.html('<tr><td colspan="10" style="text-align:center; padding:40px; color:#94a3b8;">조건에 맞는 접속기록이 없습니다.</td></tr>');
            $('#logPagination').empty();
            return;
        }

        var startNo = total - ((pageMaker.cri.pagenum - 1) * amount);
        list.forEach(function(log, i) {
            var actionBadge = log.actionType === 'DELETE' ? 'high'
                            : log.actionType === 'DOWNLOAD' ? 'medium'
                            : log.actionType === 'HTTP_ACCESS' ? 'completed'
                            : 'info';
            var piiHtml = '-';
            if (log.piiGrade) {
                var piiBadge = log.piiGrade === '1' ? 'high' : log.piiGrade === '2' ? 'medium' : 'low';
                piiHtml = '<span class="status-badge ' + piiBadge + '">' + log.piiGrade + '급</span>';
            }
            var collectHtml = log.collectType ? formatCollectType(log.collectType) : '<span style="color:#cbd5e1;">-</span>';
            var resultBadge = log.resultCode === 'SUCCESS' ? 'completed' : log.resultCode === 'DENIED' ? 'high' : log.resultCode === 'FAIL' ? 'error' : 'stopped';

            tbody.append(
                '<tr onclick="showLogDetail(' + log.logId + ')" style="cursor:pointer;">' +
                '<td>' + (startNo - i) + '</td>' +
                '<td style="white-space:nowrap;">' + (log.accessTime || '') + '</td>' +
                '<td>' + (log.userAccount || '') + '</td>' +
                '<td>' + (log.clientIp || '') + '</td>' +
                '<td><span class="status-badge ' + actionBadge + '">' + (log.actionType || '') + '</span></td>' +
                '<td>' + formatTargetCell(log) + '</td>' +
                '<td>' + formatColsCell(log) + '</td>' +
                '<td>' + piiHtml + '</td>' +
                '<td><span class="status-badge ' + resultBadge + '">' + (log.resultCode || '') + '</span></td>' +
                '<td>' + collectHtml + '</td>' +
                '</tr>'
            );
        });

        renderLogPagination(pageMaker);
    });
}

function renderLogPagination(pm) {
    var html = '';
    if (pm.prev) {
        html += '<a href="javascript:void(0)" onclick="searchLogs(' + (pm.startPage - 1) + ')"><i class="fas fa-chevron-left"></i></a>';
    }
    for (var p = pm.startPage; p <= pm.endPage; p++) {
        if (p === pm.cri.pagenum) {
            html += '<span class="active-page">' + p + '</span>';
        } else {
            html += '<a href="javascript:void(0)" onclick="searchLogs(' + p + ')">' + p + '</a>';
        }
    }
    if (pm.next) {
        html += '<a href="javascript:void(0)" onclick="searchLogs(' + (pm.endPage + 1) + ')"><i class="fas fa-chevron-right"></i></a>';
    }
    $('#logPagination').html(html);
}

function showLogDetail(logId) {
    $.get('/accesslog/api/logs/' + logId, function(log) {
        var rows = '';
        rows += '<tr><td><strong>접속일시</strong></td><td>' + (log.accessTime||'') + '</td></tr>';
        rows += '<tr><td><strong>사용자</strong></td><td>' + (log.userAccount||'') + (log.userName ? ' (' + log.userName + ')' : '') + '</td></tr>';
        rows += '<tr><td><strong>접속IP</strong></td><td>' + (log.clientIp||'') + '</td></tr>';
        rows += '<tr><td><strong>작업유형</strong></td><td>' + (log.actionType||'') + '</td></tr>';

        if (log.collectType === 'WAS_SDK') {
            rows += '<tr><td><strong>서비스</strong></td><td>' + escHtml(log.serviceName||'-') + '</td></tr>';
            rows += '<tr><td><strong>요청 URI</strong></td><td><code style="font-size:0.78rem;">' + escHtml((log.httpMethod||'') + ' ' + (log.uri||'')) + '</code></td></tr>';
            if (log.fullUri) rows += '<tr><td><strong>Full URI</strong></td><td style="font-size:0.78rem;word-break:break-all;">' + escHtml(log.fullUri) + '</td></tr>';
            if (log.menuId) rows += '<tr><td><strong>메뉴 ID</strong></td><td>' + escHtml(log.menuId) + '</td></tr>';
            if (log.httpStatus != null) rows += '<tr><td><strong>HTTP 상태</strong></td><td>' + log.httpStatus + '</td></tr>';
            if (log.durationMs != null) rows += '<tr><td><strong>소요시간</strong></td><td>' + log.durationMs + ' ms</td></tr>';
            if (log.sqlId) rows += '<tr><td><strong>SQL ID</strong></td><td>' + escHtml(log.sqlId) + '</td></tr>';
            if (log.sqlText) rows += '<tr><td><strong>SQL</strong></td><td><pre style="font-size:0.78rem;background:#0f172a;color:#e2e8f0;padding:10px;border-radius:6px;max-height:240px;overflow:auto;white-space:pre-wrap;word-break:break-all;margin:0;">' + escHtml(log.sqlText) + '</pre></td></tr>';
            if (log.bindParams) rows += '<tr><td><strong>Bind</strong></td><td><code style="font-size:0.75rem;word-break:break-all;">' + escHtml(log.bindParams) + '</code></td></tr>';
            if (log.errorMessage) rows += '<tr><td><strong>오류</strong></td><td style="color:#dc2626;">' + escHtml(log.errorMessage) + '</td></tr>';
        } else {
            rows += '<tr><td><strong>대상</strong></td><td>' + (log.targetDb||'') + (log.targetSchema ? '.' + log.targetSchema : '') + (log.targetTable ? '.' + log.targetTable : '') + '</td></tr>';
            if (log.targetColumns) rows += '<tr><td><strong>처리 컬럼</strong></td><td>' + escHtml(log.targetColumns) + '</td></tr>';
            if (log.searchCondition) rows += '<tr><td><strong>검색 조건</strong></td><td><code style="font-size:0.75rem;word-break:break-all;">' + escHtml(log.searchCondition) + '</code></td></tr>';
            if (log.sqlText) rows += '<tr><td><strong>SQL</strong></td><td><pre style="font-size:0.78rem;background:#0f172a;color:#e2e8f0;padding:10px;border-radius:6px;max-height:240px;overflow:auto;white-space:pre-wrap;word-break:break-all;margin:0;">' + escHtml(log.sqlText) + '</pre></td></tr>';
            if (log.affectedRows != null) rows += '<tr><td><strong>처리 건수</strong></td><td>' + log.affectedRows + '</td></tr>';
        }

        rows += '<tr><td><strong>PII등급</strong></td><td>' + (log.piiGrade||'-') + (log.piiTypeCodes ? ' (' + escHtml(log.piiTypeCodes) + ')' : '') + '</td></tr>';
        rows += '<tr><td><strong>결과</strong></td><td>' + (log.resultCode||'') + '</td></tr>';
        rows += '<tr><td><strong>수집 방식</strong></td><td>' + formatCollectType(log.collectType) + (log.accessChannel ? ' / ' + log.accessChannel : '') + '</td></tr>';
        rows += '<tr><td><strong>해시</strong></td><td style="font-size:0.7rem;word-break:break-all;color:#64748b;">' + (log.hashValue||'') + '</td></tr>';

        var headerExtra = '';
        if (log.reqId) {
            headerExtra = ' <button class="btn-monitor" style="font-size:0.75rem;padding:6px 12px;margin-left:8px;" onclick="showRequestDrilldown(\'' + log.reqId + '\')"><i class="fas fa-sitemap"></i> 요청 전체 보기</button>';
        }

        var detail =
            '<div style="padding:20px;">' +
              '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">' +
                '<h4 style="margin:0;">접속기록 상세 #' + log.logId + headerExtra + '</h4>' +
                '<button class="btn-outline" style="padding:6px 12px;font-size:0.78rem;" onclick="$(\'#logDetailModal\').hide()"><i class="fas fa-times"></i></button>' +
              '</div>' +
              '<table class="monitor-table"><tbody>' + rows + '</tbody></table>' +
            '</div>';

        if ($('#logDetailModal').length === 0) {
            $('body').append('<div id="logDetailModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:9999;align-items:flex-start;justify-content:center;padding:40px 20px;overflow-y:auto;"><div id="logDetailBody" style="background:#fff;border-radius:12px;max-width:760px;width:100%;"></div></div>');
            $('#logDetailModal').on('click', function(e) { if (e.target === this) $(this).hide(); });
        }
        $('#logDetailBody').html(detail);
        $('#logDetailModal').css('display','flex');
    });
}

// ==================== 요청(reqId) 드릴다운 ====================
function showRequestDrilldown(reqId) {
    $.get('/accesslog/api/logs/by-req/' + encodeURIComponent(reqId), function(rows) {
        if (!rows || rows.length === 0) {
            dlmAlert('해당 요청에 매칭되는 행이 없습니다.\n(req_id=' + reqId + ')');
            return;
        }

        var head = rows.find(function(r){ return r.actionType === 'HTTP_ACCESS'; }) || rows[0];
        var sqls = rows.filter(function(r){ return r.actionType !== 'HTTP_ACCESS'; });

        var sqlRows = '';
        if (sqls.length === 0) {
            sqlRows = '<tr><td colspan="5" style="text-align:center; padding:24px; color:#94a3b8;">이 요청에서 실행된 SQL 이 없습니다.</td></tr>';
        } else {
            sqls.forEach(function(s, i) {
                var sql = s.sqlText || '';
                var sqlShort = sql.length > 80 ? sql.substring(0,80)+'…' : sql;
                var pii = s.piiTypeCodes ? '<span class="status-badge medium">' + escHtml(s.piiTypeCodes) + '</span>' : '<span style="color:#cbd5e1;">-</span>';
                sqlRows +=
                    '<tr onclick="showLogDetail(' + s.logId + ')" style="cursor:pointer;">' +
                    '<td>' + (i+1) + '</td>' +
                    '<td><span class="status-badge ' + (s.resultCode === 'FAIL' ? 'error' : 'info') + '">' + escHtml(s.actionType||'') + '</span></td>' +
                    '<td><code style="font-size:0.72rem;color:#475569;">' + escHtml((s.targetDb||'') + (s.targetTable ? '.' + s.targetTable : '')) + '</code></td>' +
                    '<td class="sql-cell" title="' + escHtml(sql) + '">' + escHtml(sqlShort) + '</td>' +
                    '<td>' + pii + '</td>' +
                    '<td style="text-align:right;color:#94a3b8;">' + (s.durationMs != null ? s.durationMs + ' ms' : '-') + '</td>' +
                    '</tr>';
            });
        }

        var headHtml =
            '<div style="background:#f8fafc;border-radius:10px;padding:14px 16px;margin-bottom:14px;border:1px solid #e2e8f0;">' +
              '<div style="display:flex;gap:18px;flex-wrap:wrap;font-size:0.82rem;">' +
                '<div><span style="color:#94a3b8;">서비스</span> <strong>' + escHtml(head.serviceName||'-') + '</strong></div>' +
                '<div><span style="color:#94a3b8;">사용자</span> <strong>' + escHtml(head.userAccount||'-') + '</strong></div>' +
                '<div><span style="color:#94a3b8;">시간</span> <strong>' + escHtml(head.accessTime||'-') + '</strong></div>' +
                '<div><span style="color:#94a3b8;">HTTP</span> <strong>' + escHtml((head.httpMethod||'') + ' ' + (head.uri||'')) + '</strong>' +
                  (head.httpStatus != null ? ' <span class="status-badge ' + (head.httpStatus >= 400 ? 'error' : 'completed') + '">' + head.httpStatus + '</span>' : '') + '</div>' +
                (head.durationMs != null ? '<div><span style="color:#94a3b8;">총 소요</span> <strong>' + head.durationMs + ' ms</strong></div>' : '') +
              '</div>' +
              '<div style="font-size:0.7rem;color:#94a3b8;margin-top:6px;">req_id: <code>' + escHtml(reqId) + '</code></div>' +
            '</div>';

        var html =
            '<div style="padding:20px;">' +
              '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">' +
                '<h4 style="margin:0;"><i class="fas fa-sitemap" style="color:var(--monitor-primary);"></i> 요청 전체 흐름 <span style="color:#94a3b8;font-size:0.82rem;font-weight:400;">(SQL ' + sqls.length + '건)</span></h4>' +
                '<button class="btn-outline" style="padding:6px 12px;font-size:0.78rem;" onclick="$(\'#reqDrillModal\').hide()"><i class="fas fa-times"></i></button>' +
              '</div>' +
              headHtml +
              '<div style="overflow-x:auto;">' +
                '<table class="monitor-table">' +
                  '<thead><tr><th style="width:40px;">#</th><th>유형</th><th>대상</th><th>SQL</th><th>PII</th><th style="text-align:right;">시간</th></tr></thead>' +
                  '<tbody>' + sqlRows + '</tbody>' +
                '</table>' +
              '</div>' +
            '</div>';

        if ($('#reqDrillModal').length === 0) {
            $('body').append('<div id="reqDrillModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:10000;align-items:flex-start;justify-content:center;padding:40px 20px;overflow-y:auto;"><div id="reqDrillBody" style="background:#fff;border-radius:12px;max-width:980px;width:100%;"></div></div>');
            $('#reqDrillModal').on('click', function(e) { if (e.target === this) $(this).hide(); });
        }
        $('#reqDrillBody').html(html);
        $('#reqDrillModal').css('display','flex');
    }).fail(function() {
        dlmAlert('요청 흐름을 불러올 수 없습니다.');
    });
}

function exportLogs() {
    var reason = prompt('다운로드 사유를 입력하세요 (법적 의무)');
    if (!reason) return;
    var form = $('<form method="POST" action="/accesslog/api/logs/download"></form>');
    form.append('<input name="reason" value="' + reason + '">');
    form.append('<input name="search7" value="' + ($('#filterStartDate').val() ? $('#filterStartDate').val() + ' 00:00:00' : '') + '">');
    form.append('<input name="search8" value="' + ($('#filterEndDate').val() ? $('#filterEndDate').val() + ' 23:59:59' : '') + '">');
    form.append('<input name="search2" value="' + ($('#filterUser').val() || '') + '">');
    form.append('<input name="search3" value="' + ($('#filterAction').val() || '') + '">');
    form.append('<input name="search6" value="' + ($('#filterPiiGrade').val() || '') + '">');
    form.append('<input name="search5" value="' + ($('#filterTable').val() || '') + '">');
    form.append('<input name="search11" value="' + ($('#filterSourceType').val() || '') + '">');
    form.append('<input name="${_csrf.parameterName}" value="${_csrf.token}">');
    form.append('<input name="amount" value="10000">');
    $('body').append(form);
    form.submit();
    form.remove();
}
</script>

<style>
/* Quick Filter Chips */
.quickfilter-row {
    display: flex;
    gap: 8px;
    margin-bottom: 14px;
    flex-wrap: wrap;
}
.qf-chip {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 999px;
    padding: 7px 14px;
    font-size: 0.78rem;
    font-weight: 600;
    color: #64748b;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: all 0.15s;
}
.qf-chip i { font-size: 0.78rem; opacity: 0.7; }
.qf-chip:hover {
    border-color: var(--monitor-primary);
    color: var(--monitor-primary);
    background: #f0fdfa;
}
.qf-chip.active {
    background: linear-gradient(135deg, var(--monitor-primary), var(--monitor-primary-dark));
    border-color: var(--monitor-primary-dark);
    color: #fff;
    box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
}
.qf-chip.active i { opacity: 1; }

.sql-cell {
    display: inline-block;
    max-width: 300px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-size: 0.78rem;
    color: #64748b;
    cursor: default;
    vertical-align: middle;
}
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    20%, 60% { transform: translateX(-6px); }
    40%, 80% { transform: translateX(6px); }
}
</style>
