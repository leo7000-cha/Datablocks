<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Dashboard Content -->
<div id="dashboardContent">

    <!-- ===== Summary Stats (Primary) ===== -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon primary"><i class="fas fa-database"></i></div>
            </div>
            <div class="stat-value">${stats.totalTablesScanned != null ? stats.totalTablesScanned : 0}</div>
            <div class="stat-label">스캔된 테이블</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon danger"><i class="fas fa-shield-halved"></i></div>
            </div>
            <div class="stat-value">${stats.piiColumnsDetected != null ? stats.piiColumnsDetected : 0}</div>
            <div class="stat-label">탐지된 개인정보 컬럼</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon success"><i class="fas fa-check-circle"></i></div>
            </div>
            <div class="stat-value">${stats.confirmedPii != null ? stats.confirmedPii : 0}</div>
            <div class="stat-label">PII 확정</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon warning"><i class="fas fa-clock"></i></div>
                <c:if test="${stats.pendingReview != null && stats.pendingReview > 0}">
                    <a href="javascript:void(0)" onclick="$('.nav-link[data-page=results]').click()" style="font-size:0.75rem; color:var(--discovery-primary);">검토 &rarr;</a>
                </c:if>
            </div>
            <div class="stat-value">${stats.pendingReview != null ? stats.pendingReview : 0}</div>
            <div class="stat-label">검토 대기</div>
        </div>
    </div>

    <!-- ===== Secondary Stats ===== -->
    <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:24px;">
        <div style="background:#fff; border-radius:8px; padding:12px 16px; box-shadow:0 1px 2px rgba(0,0,0,0.06); display:flex; align-items:center; gap:10px;">
            <i class="fas fa-columns" style="color:#6366f1; font-size:0.9rem;"></i>
            <div>
                <div style="font-size:1.1rem; font-weight:600; color:#1e293b;">${stats.totalColumnsScanned != null ? stats.totalColumnsScanned : 0}</div>
                <div style="font-size:0.75rem; color:#94a3b8;">스캔된 컬럼</div>
            </div>
        </div>
        <div style="background:#fff; border-radius:8px; padding:12px 16px; box-shadow:0 1px 2px rgba(0,0,0,0.06); display:flex; align-items:center; gap:10px;">
            <i class="fas fa-ban" style="color:#ef4444; font-size:0.9rem;"></i>
            <div>
                <div style="font-size:1.1rem; font-weight:600; color:#1e293b;">${stats.excludedCount != null ? stats.excludedCount : 0}</div>
                <div style="font-size:0.75rem; color:#94a3b8;">제외 (오탐)</div>
            </div>
        </div>
        <div style="background:#fff; border-radius:8px; padding:12px 16px; box-shadow:0 1px 2px rgba(0,0,0,0.06); display:flex; align-items:center; gap:10px;">
            <i class="fas fa-list-check" style="color:#0ea5e9; font-size:0.9rem;"></i>
            <div>
                <div style="font-size:1.1rem; font-weight:600; color:#1e293b;">${stats.totalScans != null ? stats.totalScans : 0}</div>
                <div style="font-size:0.75rem; color:#94a3b8;">활성 스캔 작업</div>
            </div>
        </div>
        <div style="background:#fff; border-radius:8px; padding:12px 16px; box-shadow:0 1px 2px rgba(0,0,0,0.06); display:flex; align-items:center; gap:10px;">
            <i class="fas fa-calendar" style="color:#10b981; font-size:0.9rem;"></i>
            <div>
                <div style="font-size:1.1rem; font-weight:600; color:#1e293b;">${not empty stats.lastScanDate ? stats.lastScanDate : '-'}</div>
                <div style="font-size:0.75rem; color:#94a3b8;">최근 스캔</div>
            </div>
        </div>
    </div>

    <!-- ===== Charts Row ===== -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:24px;">
        <!-- PII Type Distribution (Doughnut) -->
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title"><i class="fas fa-chart-pie" style="color:#6366f1; margin-right:8px;"></i>개인정보 유형 분포</h3>
            </div>
            <div class="panel-body" style="display:flex; align-items:center; justify-content:center; min-height:240px;">
                <div id="piiTypeChartWrap" style="position:relative; width:100%; max-width:360px;">
                    <canvas id="piiTypeChart"></canvas>
                </div>
                <div id="piiTypeEmpty" style="display:none; text-align:center; color:#94a3b8;">
                    <i class="fas fa-chart-pie" style="font-size:2rem; margin-bottom:8px; opacity:0.3;"></i>
                    <p style="margin:0; font-size:0.85rem;">아직 탐지된 개인정보가 없습니다</p>
                </div>
            </div>
        </div>

        <!-- Confidence Score Distribution (Bar) -->
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title"><i class="fas fa-chart-bar" style="color:#0ea5e9; margin-right:8px;"></i>신뢰도 점수 분포</h3>
            </div>
            <div class="panel-body" style="display:flex; align-items:center; justify-content:center; min-height:240px;">
                <div id="scoreChartWrap" style="position:relative; width:100%;">
                    <canvas id="scoreChart"></canvas>
                </div>
                <div id="scoreEmpty" style="display:none; text-align:center; color:#94a3b8;">
                    <i class="fas fa-chart-bar" style="font-size:2rem; margin-bottom:8px; opacity:0.3;"></i>
                    <p style="margin:0; font-size:0.85rem;">점수 데이터가 없습니다</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ===== Recent Scan Jobs ===== -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title"><i class="fas fa-history" style="color:#f59e0b; margin-right:8px;"></i>최근 스캔 작업</h3>
            <a href="javascript:void(0)" onclick="$('.nav-link[data-page=jobs]').click()" style="font-size:0.8rem; color:var(--discovery-primary);">전체 보기 &rarr;</a>
        </div>
        <div class="panel-body" style="padding:0;">
            <c:choose>
                <c:when test="${not empty recentScans}">
                    <table class="discovery-table" style="margin:0;">
                        <thead>
                            <tr>
                                <th style="padding:12px 20px;">작업명</th>
                                <th>대상 DB</th>
                                <th>상태</th>
                                <th style="text-align:center;">실행 횟수</th>
                                <th>최근 실행</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="scan" items="${recentScans}">
                                <tr>
                                    <td style="padding:10px 20px;"><strong>${scan.jobName}</strong></td>
                                    <td>${scan.targetDb}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty scan.lastExecutionStatus}">
                                                <span class="status-badge ${fn:toLowerCase(scan.lastExecutionStatus)}">
                                                    <i class="fas fa-circle"></i> ${scan.lastExecutionStatus}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge pending">
                                                    <i class="fas fa-circle"></i> 미실행
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center;">${scan.executionCount != null ? scan.executionCount : 0}</td>
                                    <td style="color:#64748b; font-size:0.85rem;">${not empty scan.lastExecutionDate ? scan.lastExecutionDate : '-'}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state" style="padding:40px 20px;">
                        <div class="empty-state-icon">
                            <i class="fas fa-radar"></i>
                        </div>
                        <h3>등록된 스캔 작업이 없습니다</h3>
                        <p>스캔 작업 메뉴에서 새 작업을 생성하여 개인정보 탐지를 시작하세요.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ===== Top Tables with PII ===== -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title"><i class="fas fa-table" style="color:#ef4444; margin-right:8px;"></i>개인정보 다수 포함 테이블</h3>
            <a href="javascript:void(0)" onclick="$('.nav-link[data-page=results]').click()" style="font-size:0.8rem; color:var(--discovery-primary);">결과 보기 &rarr;</a>
        </div>
        <div class="panel-body" style="padding:0;">
            <div id="topTablesLoading" style="text-align:center; padding:40px;">
                <i class="fas fa-spinner fa-spin" style="color:#94a3b8;"></i>
            </div>
            <table class="discovery-table" id="topTablesTable" style="margin:0; display:none;">
                <thead>
                    <tr>
                        <th style="padding:12px 20px; width:40px;">#</th>
                        <th>테이블</th>
                        <th style="text-align:center;">개인정보 컬럼</th>
                        <th style="text-align:center;">개인정보 유형</th>
                        <th style="text-align:center;">최고 점수</th>
                    </tr>
                </thead>
                <tbody id="topTablesBody">
                </tbody>
            </table>
            <div id="topTablesEmpty" style="display:none;" class="empty-state" >
                <div class="empty-state-icon">
                    <i class="fas fa-table"></i>
                </div>
                <h3>개인정보 테이블이 없습니다</h3>
                <p>스캔을 실행하여 데이터베이스 테이블의 개인정보를 탐지하세요.</p>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    var contextPath = '${pageContext.request.contextPath}';
    var chartColors = ['#6366f1','#0ea5e9','#10b981','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#f97316','#64748b'];

    function loadDashboardCharts() {
        $.ajax({
            url: contextPath + '/piidiscovery/api/dashboard-charts',
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                renderPiiTypeChart(data.piiTypeDistribution || []);
                renderScoreChart(data.scoreDistribution);
                renderTopTables(data.topPiiTables || []);
            },
            error: function() {
                $('#piiTypeChartWrap').hide();
                $('#piiTypeEmpty').show();
                $('#scoreChartWrap').hide();
                $('#scoreEmpty').show();
                $('#topTablesLoading').hide();
                $('#topTablesEmpty').show();
            }
        });
    }

    function renderPiiTypeChart(data) {
        if (!data || data.length === 0) {
            $('#piiTypeChartWrap').hide();
            $('#piiTypeEmpty').show();
            return;
        }
        var labels = [], values = [], colors = [];
        for (var i = 0; i < data.length; i++) {
            labels.push(data[i].piiTypeName || data[i].piiTypeCode);
            values.push(Number(data[i].cnt));
            colors.push(chartColors[i % chartColors.length]);
        }
        var ctx = document.getElementById('piiTypeChart');
        if (ctx && typeof Chart !== 'undefined') {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: colors,
                        borderWidth: 0,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    cutout: '55%',
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: { padding: 12, usePointStyle: true, pointStyle: 'circle', font: { size: 11, family: 'Inter' } }
                        }
                    }
                }
            });
        }
    }

    function renderScoreChart(data) {
        if (!data || (Number(data.highCount || 0) + Number(data.mediumCount || 0) + Number(data.lowCount || 0)) === 0) {
            $('#scoreChartWrap').hide();
            $('#scoreEmpty').show();
            return;
        }
        var ctx = document.getElementById('scoreChart');
        if (ctx && typeof Chart !== 'undefined') {
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['높음 (80-100)', '보통 (50-79)', '낮음 (1-49)'],
                    datasets: [{
                        data: [Number(data.highCount || 0), Number(data.mediumCount || 0), Number(data.lowCount || 0)],
                        backgroundColor: ['#ef4444', '#f59e0b', '#94a3b8'],
                        borderRadius: 6,
                        barPercentage: 0.5
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    indexAxis: 'y',
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: {
                            beginAtZero: true,
                            ticks: { precision: 0, font: { size: 11, family: 'Inter' } },
                            grid: { color: '#f1f5f9' }
                        },
                        y: {
                            ticks: { font: { size: 11, family: 'Inter' } },
                            grid: { display: false }
                        }
                    }
                }
            });
        }
    }

    function renderTopTables(data) {
        $('#topTablesLoading').hide();
        if (!data || data.length === 0) {
            $('#topTablesEmpty').show();
            return;
        }
        var tbody = $('#topTablesBody');
        tbody.empty();
        for (var i = 0; i < data.length; i++) {
            var row = data[i];
            var tablePath = (row.schemaName ? row.schemaName + '.' : '') + row.tableName;
            if (row.dbName) tablePath = row.dbName + '.' + tablePath;
            var scoreColor = Number(row.maxScore) >= 80 ? '#ef4444' : (Number(row.maxScore) >= 50 ? '#f59e0b' : '#94a3b8');
            tbody.append(
                '<tr>' +
                '<td style="padding:10px 20px; color:#94a3b8; font-weight:500;">' + (i + 1) + '</td>' +
                '<td style="font-weight:500;">' + tablePath + '</td>' +
                '<td style="text-align:center;"><span style="background:#fee2e2; color:#ef4444; padding:2px 10px; border-radius:12px; font-size:0.8rem; font-weight:600;">' + row.piiColumnCount + '</span></td>' +
                '<td style="text-align:center;">' + row.piiTypeCount + '</td>' +
                '<td style="text-align:center;"><span style="color:' + scoreColor + '; font-weight:600;">' + row.maxScore + '</span></td>' +
                '</tr>'
            );
        }
        $('#topTablesTable').show();
    }

    // Load chart data after dashboard content is rendered
    loadDashboardCharts();
})();
</script>
