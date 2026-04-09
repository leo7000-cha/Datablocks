<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<div id="dashboardContent">
    <!-- Summary Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-card-header"><div class="stat-icon primary"><i class="fas fa-file-lines"></i></div></div>
            <div class="stat-value">${stats.todayAccessCount != null ? stats.todayAccessCount : 0}</div>
            <div class="stat-label">오늘 접속 건수</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header"><div class="stat-icon danger"><i class="fas fa-triangle-exclamation"></i></div></div>
            <div class="stat-value">${stats.alertCount != null ? stats.alertCount : 0}</div>
            <div class="stat-label">이상행위 탐지</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header"><div class="stat-icon warning"><i class="fas fa-clock"></i></div></div>
            <div class="stat-value">${stats.unresolvedAlertCount != null ? stats.unresolvedAlertCount : 0}</div>
            <div class="stat-label">미처리 알림</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header"><div class="stat-icon success"><i class="fas fa-server"></i></div></div>
            <div class="stat-value">${stats.activeSourceCount != null ? stats.activeSourceCount : 0} / ${stats.totalSourceCount != null ? stats.totalSourceCount : 0}</div>
            <div class="stat-label">모니터링 시스템</div>
        </div>
    </div>

    <!-- Charts Row -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:24px;">
        <div class="content-panel">
            <div class="panel-header"><h3 class="panel-title">시간대별 접속 추이</h3></div>
            <div class="panel-body"><canvas id="hourlyChart" height="200"></canvas></div>
        </div>
        <div class="content-panel">
            <div class="panel-header"><h3 class="panel-title">작업유형별 분포</h3></div>
            <div class="panel-body"><canvas id="actionChart" height="200"></canvas></div>
        </div>
    </div>

    <!-- Recent Alerts -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">최근 이상행위 알림</h3>
            <a href="javascript:void(0)" onclick="$('.nav-link[data-page=alerts]').click()" style="font-size:0.8rem; color:var(--monitor-primary); text-decoration:none;">전체 보기 &rarr;</a>
        </div>
        <div class="panel-body">
            <c:choose>
                <c:when test="${not empty latestAlerts}">
                    <table class="monitor-table">
                        <thead><tr><th>심각도</th><th>알림</th><th>대상자</th><th>탐지시간</th><th>상태</th></tr></thead>
                        <tbody>
                            <c:forEach var="alert" items="${latestAlerts}">
                                <tr>
                                    <td><span class="status-badge ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">${alert.severity}</span></td>
                                    <td>${alert.alertTitle}</td>
                                    <td>${alert.targetUserName}</td>
                                    <td>${alert.detectedTime}</td>
                                    <td><span class="status-badge ${alert.status == 'NEW' ? 'new-alert' : alert.status == 'RESOLVED' ? 'completed' : 'stopped'}">${alert.status}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state" style="padding:30px;"><p>탐지된 이상행위가 없습니다.</p></div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- System Status -->
    <div class="content-panel">
        <div class="panel-header"><h3 class="panel-title">시스템별 수집 현황</h3></div>
        <div class="panel-body">
            <c:choose>
                <c:when test="${not empty sources}">
                    <table class="monitor-table">
                        <thead><tr><th>시스템</th><th>DB유형</th><th>상태</th><th>최근 수집</th><th>누적 건수</th></tr></thead>
                        <tbody>
                            <c:forEach var="src" items="${sources}">
                                <tr>
                                    <td><strong>${src.sourceName}</strong></td>
                                    <td>${src.dbType}</td>
                                    <td><span class="status-badge ${src.status == 'RUNNING' ? 'running' : src.status == 'ERROR' ? 'error' : 'stopped'}">${src.status}</span></td>
                                    <td>${src.lastCollectTime != null ? src.lastCollectTime : '-'}</td>
                                    <td>${src.totalCollected != null ? src.totalCollected : 0}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state" style="padding:30px;">
                        <p>등록된 수집 대상이 없습니다.</p>
                        <button class="btn-monitor" onclick="$('.nav-link[data-page=sources]').click()"><i class="fas fa-plus"></i> 수집 대상 등록</button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
$(function() {
    // Load chart data via API
    $.get('/accesslog/api/dashboard-stats', function(data) {
        if (data.charts) {
            renderHourlyChart(data.charts.hourlyTrend || []);
            renderActionChart(data.charts.actionTypeDistribution || []);
        }
    });

    function renderHourlyChart(data) {
        var labels = [], values = [];
        for (var i = 0; i < 24; i++) {
            labels.push(i + '시');
            var found = data.find(function(d) { return d.hour == i; });
            values.push(found ? found.cnt : 0);
        }
        new Chart(document.getElementById('hourlyChart'), {
            type: 'line',
            data: { labels: labels, datasets: [{ label: '접속 건수', data: values, borderColor: '#0d9488', backgroundColor: 'rgba(13,148,136,0.1)', fill: true, tension: 0.4 }] },
            options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true } } }
        });
    }

    function renderActionChart(data) {
        var labels = [], values = [], colors = ['#0d9488','#0ea5e9','#f59e0b','#ef4444','#8b5cf6','#64748b'];
        data.forEach(function(d) { labels.push(d.actionType); values.push(d.cnt); });
        if (labels.length === 0) { labels = ['데이터 없음']; values = [1]; colors = ['#e2e8f0']; }
        new Chart(document.getElementById('actionChart'), {
            type: 'doughnut',
            data: { labels: labels, datasets: [{ data: values, backgroundColor: colors }] },
            options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
        });
    }
});
</script>