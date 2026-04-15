<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="logsContent">
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
        </select>
        <select id="filterPiiGrade" style="width:110px;">
            <option value="">PII등급</option>
            <option value="1">1급</option>
            <option value="2">2급</option>
            <option value="3">3급</option>
        </select>
        <input type="text" id="filterTable" placeholder="테이블명" style="width:150px;">
        <select id="filterSourceType" style="width:130px;">
            <option value="">수집 방식</option>
            <option value="DB_AUDIT">DB Audit</option>
            <option value="DB_DAC">접근제어</option>
            <option value="WAS_AGENT">WAS Agent</option>
        </select>
        <select id="filterAmount" style="width:100px;">
            <option value="20">20건</option>
            <option value="50" selected>50건</option>
            <option value="100">100건</option>
        </select>
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
            기간, 사용자, 작업유형, 테이블명, 수집 방식 중 <strong style="color:#0d9488;">1개 이상</strong>의 조건을 입력 후 조회 버튼을 눌러 주세요.<br>
            대량 데이터 보호를 위해 조건 없이 전체 조회는 지원하지 않습니다.
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
                        <th>대상DB</th><th>대상테이블</th><th>PII등급</th><th>결과</th><th>수집 방식</th>
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
    var today = new Date().toISOString().split('T')[0];
    var fpOpts = { locale: 'ko', dateFormat: 'Y-m-d', allowInput: true, onChange: function(s,d,i){ i._input.blur(); } };
    flatpickr('#filterStartDate', fpOpts);
    flatpickr('#filterEndDate', Object.assign({}, fpOpts, { defaultDate: today }));
});

function validateFilters() {
    var startDate = $('#filterStartDate').val();
    var endDate = $('#filterEndDate').val();
    var user = $('#filterUser').val().trim();
    var action = $('#filterAction').val();
    var piiGrade = $('#filterPiiGrade').val();
    var table = $('#filterTable').val().trim();
    var sourceType = $('#filterSourceType').val();

    if (!startDate && !endDate && !user && !action && !piiGrade && !table && !sourceType) {
        return false;
    }
    return true;
}

function formatCollectType(type) {
    if (type === 'DB_AUDIT') return '<span class="status-badge info" style="font-size:0.68rem;">DB Audit</span>';
    if (type === 'DB_DAC') return '<span class="status-badge info" style="font-size:0.68rem;background:#fef3c7;color:#92400e;">접근제어</span>';
    if (type === 'WAS_AGENT') return '<span class="status-badge info" style="font-size:0.68rem;background:#ede9fe;color:#7c3aed;">WAS Agent</span>';
    return type || '';
}

function searchLogs(pageNum) {
    if (!validateFilters()) {
        // 흔들림 애니메이션으로 안내
        var $guide = $('#logFilterGuide');
        $guide.show();
        $('#logResultPanel').hide();
        $guide.css('animation', 'none');
        setTimeout(function() { $guide.css('animation', 'shake 0.4s'); }, 10);
        return;
    }

    _logCurrentPage = pageNum || 1;
    var amount = parseInt($('#filterAmount').val());

    var params = {
        pageNum: _logCurrentPage,
        amount: amount,
        search7: $('#filterStartDate').val() ? $('#filterStartDate').val() + ' 00:00:00' : '',
        search8: $('#filterEndDate').val() ? $('#filterEndDate').val() + ' 23:59:59' : '',
        search2: $('#filterUser').val().trim(),
        search3: $('#filterAction').val(),
        search6: $('#filterPiiGrade').val(),
        search5: $('#filterTable').val().trim(),
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

        var startNo = total - ((pageMaker.cri.pageNum - 1) * amount);
        list.forEach(function(log, i) {
            var actionBadge = log.actionType === 'DELETE' ? 'high' : log.actionType === 'DOWNLOAD' ? 'medium' : 'info';
            var piiHtml = '';
            if (log.piiGrade) {
                var piiBadge = log.piiGrade === '1' ? 'high' : log.piiGrade === '2' ? 'medium' : 'low';
                piiHtml = '<span class="status-badge ' + piiBadge + '">' + log.piiGrade + '급</span>';
            }
            var resultBadge = log.resultCode === 'SUCCESS' ? 'completed' : log.resultCode === 'DENIED' ? 'high' : 'stopped';
            tbody.append(
                '<tr onclick="showLogDetail(' + log.logId + ')" style="cursor:pointer;">' +
                '<td>' + (startNo - i) + '</td>' +
                '<td style="white-space:nowrap;">' + (log.accessTime || '') + '</td>' +
                '<td>' + (log.userAccount || '') + '</td>' +
                '<td>' + (log.clientIp || '') + '</td>' +
                '<td><span class="status-badge ' + actionBadge + '">' + (log.actionType || '') + '</span></td>' +
                '<td>' + (log.targetDb || '') + '</td>' +
                '<td>' + (log.targetTable || '') + '</td>' +
                '<td>' + piiHtml + '</td>' +
                '<td><span class="status-badge ' + resultBadge + '">' + (log.resultCode || '') + '</span></td>' +
                '<td>' + formatCollectType(log.collectType) + '</td>' +
                '</tr>'
            );
        });

        // 페이징 렌더링
        renderLogPagination(pageMaker);
    });
}

function renderLogPagination(pm) {
    var html = '';
    if (pm.prev) {
        html += '<a href="javascript:void(0)" onclick="searchLogs(' + (pm.startPage - 1) + ')"><i class="fas fa-chevron-left"></i></a>';
    }
    for (var p = pm.startPage; p <= pm.endPage; p++) {
        if (p === pm.cri.pageNum) {
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
        var detail = '<div style="padding:20px;">' +
            '<h4>접속기록 상세 (#' + log.logId + ')</h4>' +
            '<table class="monitor-table"><tbody>' +
            '<tr><td><strong>접속일시</strong></td><td>' + (log.accessTime||'') + '</td></tr>' +
            '<tr><td><strong>사용자</strong></td><td>' + (log.userAccount||'') + ' (' + (log.userName||'') + ')</td></tr>' +
            '<tr><td><strong>접속IP</strong></td><td>' + (log.clientIp||'') + '</td></tr>' +
            '<tr><td><strong>작업유형</strong></td><td>' + (log.actionType||'') + '</td></tr>' +
            '<tr><td><strong>대상</strong></td><td>' + (log.targetDb||'') + '.' + (log.targetSchema||'') + '.' + (log.targetTable||'') + '</td></tr>' +
            '<tr><td><strong>PII등급</strong></td><td>' + (log.piiGrade||'-') + '</td></tr>' +
            '<tr><td><strong>결과</strong></td><td>' + (log.resultCode||'') + '</td></tr>' +
            '<tr><td><strong>수집 방식</strong></td><td>' + formatCollectType(log.collectType) + '</td></tr>' +
            '<tr><td><strong>접근 경로</strong></td><td>' + (log.accessChannel||'') + '</td></tr>' +
            '<tr><td><strong>해시</strong></td><td style="font-size:0.75rem;word-break:break-all;">' + (log.hashValue||'') + '</td></tr>' +
            '</tbody></table></div>';
        if ($('#logDetailModal').length === 0) {
            $('body').append('<div id="logDetailModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:9999;display:flex;align-items:center;justify-content:center;"><div style="background:#fff;border-radius:12px;max-width:600px;width:90%;max-height:80vh;overflow-y:auto;" id="logDetailBody"></div></div>');
            $('#logDetailModal').on('click', function(e) { if (e.target === this) $(this).hide(); });
        }
        $('#logDetailBody').html(detail + '<div style="text-align:right;padding:0 20px 20px;"><button class="btn-outline" onclick="$(\'#logDetailModal\').hide()">닫기</button></div>');
        $('#logDetailModal').show();
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
@keyframes shake {
    0%, 100% { transform: translateX(0); }
    20%, 60% { transform: translateX(-6px); }
    40%, 80% { transform: translateX(6px); }
}
</style>
