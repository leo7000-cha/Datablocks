<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="logsContent">
    <!-- Filter Bar -->
    <div class="filter-bar">
        <input type="date" id="filterStartDate" placeholder="시작일">
        <input type="date" id="filterEndDate" placeholder="종료일">
        <input type="text" id="filterUser" placeholder="사용자" style="width:120px;">
        <select id="filterAction">
            <option value="">작업유형</option>
            <option value="SELECT">SELECT</option>
            <option value="UPDATE">UPDATE</option>
            <option value="DELETE">DELETE</option>
            <option value="INSERT">INSERT</option>
            <option value="DOWNLOAD">DOWNLOAD</option>
        </select>
        <select id="filterPiiGrade">
            <option value="">PII등급</option>
            <option value="1">1급</option>
            <option value="2">2급</option>
            <option value="3">3급</option>
        </select>
        <input type="text" id="filterTable" placeholder="테이블명" style="width:150px;">
        <button class="btn-monitor" onclick="searchLogs()"><i class="fas fa-search"></i> 조회</button>
        <button class="btn-outline" onclick="exportLogs()"><i class="fas fa-download"></i> Excel</button>
    </div>

    <!-- Results -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">접속기록 <span id="logTotalCount" style="color:var(--monitor-primary); font-size:0.85rem;">(${total}건)</span></h3>
        </div>
        <div class="panel-body" style="padding:0; overflow-x:auto;">
            <table class="monitor-table" id="logTable">
                <thead>
                    <tr>
                        <th>No</th><th>접속일시</th><th>사용자</th><th>접속IP</th><th>작업유형</th>
                        <th>대상DB</th><th>대상테이블</th><th>PII등급</th><th>결과</th><th>채널</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty list}">
                            <c:forEach var="log" items="${list}" varStatus="s">
                                <tr onclick="showLogDetail(${log.logId})" style="cursor:pointer;">
                                    <td>${s.index + 1}</td>
                                    <td style="white-space:nowrap;">${log.accessTime}</td>
                                    <td>${log.userAccount}</td>
                                    <td>${log.clientIp}</td>
                                    <td><span class="status-badge ${log.actionType == 'DELETE' ? 'high' : log.actionType == 'DOWNLOAD' ? 'medium' : 'info'}">${log.actionType}</span></td>
                                    <td>${log.targetDb}</td>
                                    <td>${log.targetTable}</td>
                                    <td>
                                        <c:if test="${not empty log.piiGrade}">
                                            <span class="status-badge ${log.piiGrade == '1' ? 'high' : log.piiGrade == '2' ? 'medium' : 'low'}">${log.piiGrade}급</span>
                                        </c:if>
                                    </td>
                                    <td><span class="status-badge ${log.resultCode == 'SUCCESS' ? 'completed' : log.resultCode == 'DENIED' ? 'high' : 'stopped'}">${log.resultCode}</span></td>
                                    <td>${log.accessChannel}</td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="10" style="text-align:center; padding:40px; color:#94a3b8;">접속기록이 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
function searchLogs() {
    var params = {
        search7: $('#filterStartDate').val() ? $('#filterStartDate').val() + ' 00:00:00' : '',
        search8: $('#filterEndDate').val() ? $('#filterEndDate').val() + ' 23:59:59' : '',
        search2: $('#filterUser').val(),
        search3: $('#filterAction').val(),
        search6: $('#filterPiiGrade').val(),
        search5: $('#filterTable').val(),
        amount: 100
    };
    $.get('/accesslog/logs', params, function(html) { $('#mainContent').html(html); });
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
    form.append('<input name="${_csrf.parameterName}" value="${_csrf.token}">');
    form.append('<input name="amount" value="10000">');
    $('body').append(form);
    form.submit();
    form.remove();
}
</script>