<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%-- ========== 법규 준수 판정 로직 (JSTL 변수) ========== --%>
<c:set var="retentionYears" value="${compliance.retentionYears != null ? compliance.retentionYears : 0}" />
<c:set var="thisMonthVerify" value="${compliance.thisMonthHashVerifyCount != null ? compliance.thisMonthHashVerifyCount : 0}" />
<c:set var="invalidHash" value="${compliance.invalidHashCount != null ? compliance.invalidHashCount : 0}" />
<c:set var="activeRules" value="${compliance.activeRuleCount != null ? compliance.activeRuleCount : 0}" />
<c:set var="totalRules" value="${compliance.totalRuleCount != null ? compliance.totalRuleCount : 0}" />
<c:set var="overdueAlerts" value="${compliance.overdueAlertCount != null ? compliance.overdueAlertCount : 0}" />
<c:set var="escalatedAlerts" value="${compliance.escalatedAlertCount != null ? compliance.escalatedAlertCount : 0}" />
<c:set var="justifiedWaiting" value="${compliance.justifiedWaitingCount != null ? compliance.justifiedWaitingCount : 0}" />
<c:set var="activeSources" value="${stats.activeSourceCount != null ? stats.activeSourceCount : 0}" />

<%-- 준수 여부 판정 --%>
<c:set var="recordOk" value="${activeSources > 0}" />
<c:set var="retentionOk" value="${retentionYears >= 1}" />
<c:set var="reviewOk" value="${thisMonthVerify > 0}" />
<c:set var="tamperOk" value="${invalidHash == 0 && stats.hashVerifyStatus != 'INVALID'}" />
<c:set var="detectOk" value="${activeRules > 0}" />
<c:set var="responseOk" value="${overdueAlerts == 0 && escalatedAlerts == 0}" />

<%-- 전체 점수 계산 --%>
<c:set var="complianceScore" value="${0}" />
<c:if test="${recordOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>
<c:if test="${retentionOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>
<c:if test="${reviewOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>
<c:if test="${tamperOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>
<c:if test="${detectOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>
<c:if test="${responseOk}"><c:set var="complianceScore" value="${complianceScore + 1}" /></c:if>

<div id="dashboardContent">

    <!-- ============================================================ -->
    <!-- SECTION 1: 법규 준수 현황 (Regulatory Compliance Overview)    -->
    <!-- ============================================================ -->
    <div class="compliance-section">
        <div class="compliance-header">
            <div class="compliance-header-left">
                <div class="compliance-header-icon"><i class="fas fa-scale-balanced"></i></div>
                <div>
                    <h2 class="compliance-title">개인정보 접속기록 관리 법규 준수현황</h2>
                    <p class="compliance-subtitle">개인정보보호법 제29조 · 안전성 확보조치 기준 제8조</p>
                </div>
            </div>
            <div class="compliance-score">
                <div class="score-ring ${complianceScore == 6 ? 'perfect' : complianceScore >= 4 ? 'good' : 'warn'}">
                    <span class="score-number">${complianceScore}</span>
                    <span class="score-total">/6</span>
                </div>
                <div class="score-label">
                    <c:choose>
                        <c:when test="${complianceScore == 6}">전 항목 적합</c:when>
                        <c:when test="${complianceScore >= 4}">일부 점검 필요</c:when>
                        <c:otherwise>즉시 조치 필요</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- 법규 항목별 준수 카드 그리드 -->
        <div class="compliance-grid">

            <!-- 1. 접속기록 저장 (제8조 제1항) -->
            <div class="compliance-card ${recordOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${recordOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제8조 제1항</span>
                    <span class="cc-result ${recordOk ? 'pass' : 'fail'}">${recordOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">접속기록 저장</h4>
                <p class="cc-desc">개인정보처리시스템 접속기록을 안전하게 저장</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">수집 시스템</span>
                        <span class="cc-metric-value">${activeSources} / ${stats.totalSourceCount != null ? stats.totalSourceCount : 0}</span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">오늘 수집</span>
                        <span class="cc-metric-value">${stats.todayAccessCount != null ? stats.todayAccessCount : 0}건</span>
                    </div>
                </div>
                <c:if test="${!recordOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=sources]').click()">수집 대상 등록 필요</a></div>
                </c:if>
            </div>

            <!-- 2. 접속기록 보관 (제8조 제2항) -->
            <div class="compliance-card ${retentionOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${retentionOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제8조 제2항</span>
                    <span class="cc-result ${retentionOk ? 'pass' : 'fail'}">${retentionOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">접속기록 보관</h4>
                <p class="cc-desc">최소 6개월 이상 보관 (5만명 이상: 2년)</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">설정 보관기간</span>
                        <span class="cc-metric-value">${retentionYears}년</span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">법정 최소기준</span>
                        <span class="cc-metric-value">6개월</span>
                    </div>
                </div>
                <c:if test="${!retentionOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=settings]').click()">보관기간 설정 변경 필요</a></div>
                </c:if>
            </div>

            <!-- 3. 정기 점검 (제8조 제3항) -->
            <div class="compliance-card ${reviewOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${reviewOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제8조 제3항</span>
                    <span class="cc-result ${reviewOk ? 'pass' : 'fail'}">${reviewOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">접속기록 정기 점검</h4>
                <p class="cc-desc">월 1회 이상 접속기록 확인·점검</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">이번 달 점검</span>
                        <span class="cc-metric-value ${thisMonthVerify > 0 ? '' : 'danger-text'}">${thisMonthVerify}회</span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">최근 점검일</span>
                        <span class="cc-metric-value">${compliance.lastMonthlyReviewDate != null ? compliance.lastMonthlyReviewDate : '없음'}</span>
                    </div>
                </div>
                <c:if test="${!reviewOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=hash-verify]').click()">점검 실시 필요</a></div>
                </c:if>
            </div>

            <!-- 4. 위·변조 방지 (제8조 제4항) -->
            <div class="compliance-card ${tamperOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${tamperOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제8조 제4항</span>
                    <span class="cc-result ${tamperOk ? 'pass' : 'fail'}">${tamperOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">위·변조 방지</h4>
                <p class="cc-desc">접속기록의 위조·변조 방지 조치</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">무결성 상태</span>
                        <span class="cc-metric-value">
                            <c:choose>
                                <c:when test="${stats.hashVerifyStatus == 'VALID'}"><span style="color:var(--monitor-success)">정상</span></c:when>
                                <c:when test="${stats.hashVerifyStatus == 'INVALID'}"><span style="color:var(--monitor-danger)">위변조 탐지</span></c:when>
                                <c:otherwise><span style="color:var(--monitor-warning)">미검증</span></c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">위변조 건수</span>
                        <span class="cc-metric-value ${invalidHash > 0 ? 'danger-text' : ''}">${invalidHash}건</span>
                    </div>
                </div>
                <c:if test="${!tamperOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=hash-verify]').click()">즉시 확인 필요</a></div>
                </c:if>
            </div>

            <!-- 5. 이상행위 탐지 (제29조) -->
            <div class="compliance-card ${detectOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${detectOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제29조</span>
                    <span class="cc-result ${detectOk ? 'pass' : 'fail'}">${detectOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">이상행위 탐지</h4>
                <p class="cc-desc">비정상 접속행위 탐지·차단 체계 운영</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">탐지 규칙</span>
                        <span class="cc-metric-value">${activeRules} / ${totalRules}</span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">오늘 탐지</span>
                        <span class="cc-metric-value">${stats.alertCount != null ? stats.alertCount : 0}건</span>
                    </div>
                </div>
                <c:if test="${!detectOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=alert-rules]').click()">탐지 규칙 활성화 필요</a></div>
                </c:if>
            </div>

            <!-- 6. 소명·대응 처리 (제29조) -->
            <div class="compliance-card ${responseOk ? 'pass' : 'fail'}">
                <div class="cc-header">
                    <div class="cc-status-dot ${responseOk ? 'pass' : 'fail'}"></div>
                    <span class="cc-law-tag">제29조</span>
                    <span class="cc-result ${responseOk ? 'pass' : 'fail'}">${responseOk ? '적합' : '미흡'}</span>
                </div>
                <h4 class="cc-title">이상행위 대응</h4>
                <p class="cc-desc">탐지된 이상행위에 대한 소명·조치</p>
                <div class="cc-metrics">
                    <div class="cc-metric">
                        <span class="cc-metric-label">기한 초과</span>
                        <span class="cc-metric-value ${overdueAlerts > 0 ? 'danger-text' : ''}">${overdueAlerts}건</span>
                    </div>
                    <div class="cc-metric">
                        <span class="cc-metric-label">승인 대기</span>
                        <span class="cc-metric-value ${justifiedWaiting > 0 ? 'warning-text' : ''}">${justifiedWaiting}건</span>
                    </div>
                </div>
                <c:if test="${!responseOk}">
                    <div class="cc-action"><i class="fas fa-arrow-right"></i> <a href="javascript:void(0)" onclick="$('.nav-link[data-page=alerts]').click()">미처리 알림 확인</a></div>
                </c:if>
            </div>

        </div>
    </div>

    <!-- ============================================================ -->
    <!-- SECTION 2: 이상행위 알림 현황 (상태별)                          -->
    <!-- ============================================================ -->
    <c:set var="alertTotal" value="${(stats.alertNewCount != null ? stats.alertNewCount : 0)
        + (stats.alertNotifiedCount != null ? stats.alertNotifiedCount : 0)
        + (stats.alertJustifiedCount != null ? stats.alertJustifiedCount : 0)
        + (stats.alertResolvedCount != null ? stats.alertResolvedCount : 0)
        + (stats.alertDismissedCount != null ? stats.alertDismissedCount : 0)
        + (stats.alertReJustifyCount != null ? stats.alertReJustifyCount : 0)
        + (stats.alertOverdueCount != null ? stats.alertOverdueCount : 0)
        + (stats.alertEscalatedCount != null ? stats.alertEscalatedCount : 0)}" />
    <c:set var="alertPending" value="${(stats.alertNewCount != null ? stats.alertNewCount : 0)
        + (stats.alertNotifiedCount != null ? stats.alertNotifiedCount : 0)
        + (stats.alertReJustifyCount != null ? stats.alertReJustifyCount : 0)
        + (stats.alertOverdueCount != null ? stats.alertOverdueCount : 0)
        + (stats.alertEscalatedCount != null ? stats.alertEscalatedCount : 0)
        + (stats.alertJustifiedCount != null ? stats.alertJustifiedCount : 0)}" />

    <c:set var="alertDone" value="${(stats.alertResolvedCount != null ? stats.alertResolvedCount : 0)
        + (stats.alertDismissedCount != null ? stats.alertDismissedCount : 0)}" />

    <div class="content-panel" style="margin-bottom:20px;">
        <div class="panel-header">
            <h3 class="panel-title">이상행위 알림 현황 <span style="font-weight:400; font-size:0.82rem; color:#94a3b8; margin-left:6px;">전체 ${alertTotal}건</span></h3>
            <a href="javascript:void(0)" onclick="$('.nav-link[data-page=alerts]').click()" style="font-size:0.8rem; color:var(--monitor-primary); text-decoration:none;">전체 보기 &rarr;</a>
        </div>
        <div class="panel-body" style="padding:14px 18px;">
            <div style="display:flex; gap:16px;">
                <!-- 처리 필요 영역 -->
                <div style="flex:1; min-width:0;">
                    <div class="alert-group-header pending">
                        <span class="ag-icon"><i class="fas fa-clock"></i></span>
                        <span class="ag-title">처리 필요</span>
                        <span class="ag-count">${alertPending}</span>
                    </div>
                    <div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:8px; margin-top:10px;">
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#3b82f6;"></div>
                            <div class="asc-label">신규</div>
                            <div class="asc-value" style="color:#3b82f6;">${stats.alertNewCount != null ? stats.alertNewCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#0ea5e9;"></div>
                            <div class="asc-label">소명요청</div>
                            <div class="asc-value" style="color:#0ea5e9;">${stats.alertNotifiedCount != null ? stats.alertNotifiedCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#d97706;"></div>
                            <div class="asc-label">소명완료</div>
                            <div class="asc-value" style="color:#d97706;">${stats.alertJustifiedCount != null ? stats.alertJustifiedCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#8b5cf6;"></div>
                            <div class="asc-label">재소명</div>
                            <div class="asc-value" style="color:#8b5cf6;">${stats.alertReJustifyCount != null ? stats.alertReJustifyCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact ${(stats.alertOverdueCount != null && stats.alertOverdueCount > 0) ? 'alert-urgent' : ''}" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#ef4444;"></div>
                            <div class="asc-label">기한초과</div>
                            <div class="asc-value" style="color:#ef4444;">${stats.alertOverdueCount != null ? stats.alertOverdueCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact ${(stats.alertEscalatedCount != null && stats.alertEscalatedCount > 0) ? 'alert-urgent' : ''}" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#dc2626;"></div>
                            <div class="asc-label">미응답경고</div>
                            <div class="asc-value" style="color:#dc2626;">${stats.alertEscalatedCount != null ? stats.alertEscalatedCount : 0}</div>
                        </div>
                    </div>
                </div>

                <!-- 구분선 -->
                <div style="width:1px; background:#e2e8f0; align-self:stretch;"></div>

                <!-- 처리 완료 영역 -->
                <div style="width:220px; flex-shrink:0;">
                    <div class="alert-group-header done">
                        <span class="ag-icon"><i class="fas fa-check-circle"></i></span>
                        <span class="ag-title">처리 완료</span>
                        <span class="ag-count">${alertDone}</span>
                    </div>
                    <div style="display:grid; grid-template-columns:1fr; gap:8px; margin-top:10px;">
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#10b981;"></div>
                            <div class="asc-label">승인완료</div>
                            <div class="asc-value" style="color:#10b981;">${stats.alertResolvedCount != null ? stats.alertResolvedCount : 0}</div>
                        </div>
                        <div class="alert-status-card compact" onclick="$('.nav-link[data-page=alerts]').click()">
                            <div class="asc-dot" style="background:#94a3b8;"></div>
                            <div class="asc-label">무시</div>
                            <div class="asc-value" style="color:#94a3b8;">${stats.alertDismissedCount != null ? stats.alertDismissedCount : 0}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ============================================================ -->
    <!-- SECTION 3: 최근 이상행위 + 시스템 현황                          -->
    <!-- ============================================================ -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px;">
        <!-- 최근 이상행위 알림 -->
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title">최근 이상행위 알림</h3>
                <a href="javascript:void(0)" onclick="$('.nav-link[data-page=alerts]').click()" style="font-size:0.8rem; color:var(--monitor-primary); text-decoration:none;">전체 보기 &rarr;</a>
            </div>
            <div class="panel-body">
                <c:choose>
                    <c:when test="${not empty latestAlerts}">
                        <table class="monitor-table">
                            <thead><tr><th>심각도</th><th>알림</th><th>대상자</th><th>상태</th></tr></thead>
                            <tbody>
                                <c:forEach var="alert" items="${latestAlerts}">
                                    <tr>
                                        <td><span class="status-badge ${alert.severity == 'HIGH' ? 'high' : alert.severity == 'MEDIUM' ? 'medium' : alert.severity == 'LOW' ? 'low' : 'info'}">${alert.severity}</span></td>
                                        <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${alert.alertTitle}</td>
                                        <td>${alert.targetUserName}</td>
                                        <td><span class="status-badge ${alert.status == 'NEW' ? 'new-alert' : alert.status == 'RESOLVED' ? 'completed' : alert.status == 'OVERDUE' || alert.status == 'ESCALATED' ? 'error' : 'stopped'}">${alert.status}</span></td>
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

        <!-- 시스템별 수집 현황 -->
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title">시스템별 수집 현황</h3>
                <a href="javascript:void(0)" onclick="$('.nav-link[data-page=sources]').click()" style="font-size:0.8rem; color:var(--monitor-primary); text-decoration:none;">관리 &rarr;</a>
            </div>
            <div class="panel-body" style="padding:0;">
                <c:choose>
                    <c:when test="${not empty sources}">
                        <div class="source-card-list">
                            <c:forEach var="src" items="${sources}">
                                <div class="source-card ${src.status == 'RUNNING' ? 'active' : src.status == 'ERROR' ? 'error' : 'inactive'}">
                                    <div class="source-card-top">
                                        <div class="source-card-icon ${src.status == 'RUNNING' ? 'active' : src.status == 'ERROR' ? 'error' : 'inactive'}">
                                            <i class="fas ${src.sourceType == 'WAS_AGENT' ? 'fa-server' : src.sourceType == 'DB_DAC' ? 'fa-shield-alt' : 'fa-database'}"></i>
                                        </div>
                                        <div class="source-card-info">
                                            <div class="source-card-name">${src.sourceName}</div>
                                            <div class="source-card-meta">
                                                <span class="source-tag">${src.dbType}</span>
                                                <span class="source-tag type">${src.sourceType == 'DB_AUDIT' ? 'DB감사' : src.sourceType == 'DB_DAC' ? 'DB 접근제어' : src.sourceType == 'WAS_AGENT' ? 'Agent' : src.sourceType}</span>
                                                <c:if test="${not empty src.hostname}"><span class="source-host">${src.hostname}</span></c:if>
                                            </div>
                                        </div>
                                        <div class="source-card-status">
                                            <span class="source-status-dot ${src.status == 'RUNNING' ? 'active' : src.status == 'ERROR' ? 'error' : 'inactive'}"></span>
                                            <span class="source-status-text ${src.status == 'RUNNING' ? 'active' : src.status == 'ERROR' ? 'error' : 'inactive'}">${src.status == 'RUNNING' ? '수집중' : src.status == 'ERROR' ? '오류' : '중지'}</span>
                                        </div>
                                    </div>
                                    <div class="source-card-bottom">
                                        <div class="source-stat">
                                            <span class="source-stat-label">누적 수집</span>
                                            <span class="source-stat-value">
                                                <fmt:formatNumber value="${src.totalCollected != null ? src.totalCollected : 0}" pattern="#,###"/>건
                                            </span>
                                        </div>
                                        <div class="source-stat">
                                            <span class="source-stat-label">마지막 수집</span>
                                            <span class="source-stat-value time">${src.lastCollectTime != null ? src.lastCollectTime : '-'}</span>
                                        </div>
                                    </div>
                                    <c:if test="${src.status == 'ERROR' && not empty src.errorMsg}">
                                        <div class="source-card-error"><i class="fas fa-exclamation-triangle"></i> ${src.errorMsg}</div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
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

    <!-- ============================================================ -->
    <!-- SECTION 4: 차트 (하단)                                        -->
    <!-- ============================================================ -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:20px;">
        <div class="content-panel">
            <div class="panel-header"><h3 class="panel-title">시간대별 접속 추이</h3></div>
            <div class="panel-body" style="padding:8px 14px;"><div style="height:200px;"><canvas id="hourlyChart"></canvas></div></div>
        </div>
        <div class="content-panel">
            <div class="panel-header"><h3 class="panel-title">작업유형별 분포</h3></div>
            <div class="panel-body" style="padding:8px 14px;"><div style="height:200px;"><canvas id="actionChart"></canvas></div></div>
        </div>
    </div>

    <!-- ============================================================ -->
    <!-- SECTION 5: 수집 경로별 분포 + 처리계 SDK 상위 서비스           -->
    <!-- ============================================================ -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:20px;">
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title">수집 경로별 분포</h3>
                <a href="javascript:void(0)" onclick="$('.nav-link[data-page=logs]').click()" style="font-size:0.8rem; color:var(--monitor-primary); text-decoration:none;">기록 보기 &rarr;</a>
            </div>
            <div class="panel-body" style="padding:8px 14px;"><div style="height:200px;"><canvas id="collectChart"></canvas></div></div>
        </div>
        <div class="content-panel">
            <div class="panel-header">
                <h3 class="panel-title">처리계 SDK 상위 서비스 <span style="font-weight:400; font-size:0.78rem; color:#94a3b8; margin-left:6px;">오늘</span></h3>
            </div>
            <div class="panel-body" id="topServicesBody" style="padding:14px 18px;">
                <div style="text-align:center; color:#94a3b8; font-size:0.85rem; padding:30px 0;">
                    <i class="fas fa-spinner fa-spin"></i> 로딩 중...
                </div>
            </div>
        </div>
    </div>

</div>

<!-- ========== 법규 준수현황 전용 스타일 ========== -->
<style>
/* Compliance Section */
.compliance-section {
    background: linear-gradient(135deg, #f0fdfa 0%, #ecfdf5 50%, #f0f9ff 100%);
    border: 1px solid #99f6e4;
    border-radius: 16px;
    padding: 24px;
    margin-bottom: 24px;
    position: relative;
    overflow: hidden;
}
.compliance-section::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -20%;
    width: 400px;
    height: 400px;
    background: radial-gradient(circle, rgba(13,148,136,0.06) 0%, transparent 70%);
    pointer-events: none;
}
.compliance-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    position: relative;
}
.compliance-header-left {
    display: flex;
    align-items: center;
    gap: 14px;
}
.compliance-header-icon {
    width: 48px;
    height: 48px;
    background: linear-gradient(135deg, var(--monitor-primary), #0e7490);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(13,148,136,0.25);
}
.compliance-header-icon i { color: #fff; font-size: 1.3rem; }
.compliance-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #0f172a;
    margin: 0 0 4px 0;
}
.compliance-subtitle {
    font-size: 0.78rem;
    color: #64748b;
    margin: 0;
}

/* Score Ring */
.compliance-score {
    text-align: center;
}
.score-ring {
    width: 68px;
    height: 68px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 6px;
    border: 4px solid;
    position: relative;
}
.score-ring.perfect { border-color: var(--monitor-success); background: #d1fae5; }
.score-ring.good { border-color: var(--monitor-warning); background: #fef3c7; }
.score-ring.warn { border-color: var(--monitor-danger); background: #fee2e2; }
.score-number { font-size: 1.5rem; font-weight: 800; color: #0f172a; }
.score-total { font-size: 0.85rem; font-weight: 500; color: #64748b; }
.score-label {
    font-size: 0.75rem;
    font-weight: 600;
    color: #475569;
}

/* Compliance Grid */
.compliance-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
}

/* Compliance Card */
.compliance-card {
    background: #fff;
    border-radius: 12px;
    padding: 16px;
    border-left: 4px solid;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    transition: transform 0.15s, box-shadow 0.15s;
}
.compliance-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}
.compliance-card.pass { border-left-color: var(--monitor-success); }
.compliance-card.fail { border-left-color: var(--monitor-danger); }

.cc-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
}
.cc-status-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
}
.cc-status-dot.pass { background: var(--monitor-success); box-shadow: 0 0 6px rgba(16,185,129,0.4); }
.cc-status-dot.fail { background: var(--monitor-danger); box-shadow: 0 0 6px rgba(239,68,68,0.4); animation: pulse-dot 2s ease-in-out infinite; }
@keyframes pulse-dot {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}
.cc-law-tag {
    font-size: 0.65rem;
    font-weight: 600;
    background: #f1f5f9;
    color: #475569;
    padding: 2px 8px;
    border-radius: 4px;
    letter-spacing: 0.3px;
}
.cc-result {
    margin-left: auto;
    font-size: 0.72rem;
    font-weight: 700;
    padding: 2px 10px;
    border-radius: 10px;
}
.cc-result.pass { background: #d1fae5; color: #059669; }
.cc-result.fail { background: #fee2e2; color: #dc2626; }

.cc-title {
    font-size: 0.92rem;
    font-weight: 700;
    color: #1e293b;
    margin: 0 0 4px 0;
}
.cc-desc {
    font-size: 0.73rem;
    color: #94a3b8;
    margin: 0 0 12px 0;
    line-height: 1.4;
}

.cc-metrics {
    display: flex;
    gap: 12px;
}
.cc-metric {
    flex: 1;
    background: #f8fafc;
    border-radius: 8px;
    padding: 8px 10px;
    text-align: center;
}
.cc-metric-label {
    display: block;
    font-size: 0.65rem;
    color: #94a3b8;
    margin-bottom: 3px;
    font-weight: 500;
}
.cc-metric-value {
    display: block;
    font-size: 0.85rem;
    font-weight: 700;
    color: #334155;
}
.cc-metric-value.danger-text { color: var(--monitor-danger); }
.cc-metric-value.warning-text { color: var(--monitor-warning); }

.cc-action {
    margin-top: 10px;
    padding-top: 8px;
    border-top: 1px dashed #e2e8f0;
    font-size: 0.73rem;
    color: var(--monitor-danger);
    font-weight: 600;
}
.cc-action a {
    color: var(--monitor-danger);
    text-decoration: none;
}
.cc-action a:hover { text-decoration: underline; }

/* Override stats-grid to 4 columns */
.stats-grid { grid-template-columns: repeat(4, 1fr); }

/* Alert Group Header */
.alert-group-header {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 0.82rem;
    font-weight: 700;
}
.alert-group-header.pending { background: #fef3c7; color: #92400e; }
.alert-group-header.done { background: #d1fae5; color: #065f46; }
.ag-icon { font-size: 0.85rem; }
.ag-title { flex: 1; }
.ag-count { font-size: 1.1rem; font-weight: 800; }

/* Alert Status Cards */
.alert-status-card {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.15s;
}
.alert-status-card.compact {
    padding: 8px 10px;
    gap: 8px;
}
.alert-status-card:hover {
    border-color: #cbd5e1;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    transform: translateY(-1px);
}
.alert-status-card.alert-urgent {
    background: #fef2f2;
    border-color: #fecaca;
    animation: pulse-urgent 2s ease-in-out infinite;
}
@keyframes pulse-urgent {
    0%, 100% { border-color: #fecaca; }
    50% { border-color: #f87171; }
}
.asc-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
}
.asc-label {
    flex: 1;
    font-size: 0.76rem;
    color: #64748b;
    font-weight: 500;
    line-height: 1.3;
}
.asc-value {
    font-size: 1.05rem;
    font-weight: 800;
    min-width: 24px;
    text-align: right;
}

/* Source Card List */
.source-card-list {
    display: flex;
    flex-direction: column;
    gap: 0;
}
.source-card {
    padding: 14px 18px;
    border-bottom: 1px solid #f1f5f9;
    transition: background 0.15s;
}
.source-card:last-child { border-bottom: none; }
.source-card:hover { background: #f8fafc; }
.source-card.error { background: #fef7f7; }
.source-card-top {
    display: flex;
    align-items: center;
    gap: 12px;
}
.source-card-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    font-size: 0.9rem;
}
.source-card-icon.active { background: #d1fae5; color: #059669; }
.source-card-icon.error { background: #fee2e2; color: #dc2626; }
.source-card-icon.inactive { background: #f1f5f9; color: #94a3b8; }
.source-card-info { flex: 1; min-width: 0; }
.source-card-name {
    font-size: 0.85rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 3px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.source-card-meta {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;
}
.source-tag {
    font-size: 0.65rem;
    font-weight: 600;
    padding: 1px 6px;
    border-radius: 4px;
    background: #f1f5f9;
    color: #64748b;
}
.source-tag.type {
    background: #ede9fe;
    color: #7c3aed;
}
.source-host {
    font-size: 0.65rem;
    color: #94a3b8;
}
.source-card-status {
    display: flex;
    align-items: center;
    gap: 5px;
    flex-shrink: 0;
}
.source-status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
}
.source-status-dot.active { background: #10b981; box-shadow: 0 0 6px rgba(16,185,129,0.4); }
.source-status-dot.error { background: #ef4444; animation: pulse-dot 2s ease-in-out infinite; }
.source-status-dot.inactive { background: #cbd5e1; }
.source-status-text {
    font-size: 0.72rem;
    font-weight: 600;
}
.source-status-text.active { color: #059669; }
.source-status-text.error { color: #dc2626; }
.source-status-text.inactive { color: #94a3b8; }
.source-card-bottom {
    display: flex;
    gap: 16px;
    margin-top: 8px;
    padding-left: 48px;
}
.source-stat {
    display: flex;
    align-items: center;
    gap: 6px;
}
.source-stat-label {
    font-size: 0.65rem;
    color: #94a3b8;
    font-weight: 500;
}
.source-stat-value {
    font-size: 0.78rem;
    font-weight: 700;
    color: #334155;
}
.source-stat-value.time {
    font-weight: 500;
    font-size: 0.7rem;
    color: #64748b;
}
.source-card-error {
    margin-top: 6px;
    padding: 5px 10px 5px 48px;
    font-size: 0.68rem;
    color: #dc2626;
    background: #fef2f2;
    border-radius: 4px;
}
.source-card-error i { margin-right: 4px; }

/* Responsive */
@media (max-width: 1200px) {
    .compliance-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 768px) {
    .compliance-grid { grid-template-columns: 1fr; }
    .compliance-header { flex-direction: column; gap: 16px; }
    .stats-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>

<script>
$(function() {
    // Load chart data via API
    $.get('/accesslog/api/dashboard-stats', function(data) {
        if (data.charts) {
            renderHourlyChart(data.charts.hourlyTrend || []);
            renderActionChart(data.charts.actionTypeDistribution || []);
            renderCollectChart(data.charts.collectTypeDistribution || []);
            renderTopServices(data.charts.topServices || []);
        }
    });

    var COLLECT_LABEL = {
        'DB_AUDIT': 'DB Audit',
        'DB_DAC': 'DB 접근제어',
        'WAS_AGENT': 'WAS Agent',
        'WAS_SDK': '처리계 SDK'
    };
    var COLLECT_COLOR = {
        'DB_AUDIT': '#0ea5e9',
        'DB_DAC': '#f59e0b',
        'WAS_AGENT': '#8b5cf6',
        'WAS_SDK': '#0d9488'
    };

    function renderCollectChart(data) {
        var labels = [], values = [], colors = [];
        data.forEach(function(d) {
            var t = d.collectType || 'UNKNOWN';
            labels.push(COLLECT_LABEL[t] || t);
            values.push(d.cnt);
            colors.push(COLLECT_COLOR[t] || '#94a3b8');
        });
        if (labels.length === 0) { labels = ['데이터 없음']; values = [1]; colors = ['#e2e8f0']; }
        new Chart(document.getElementById('collectChart'), {
            type: 'doughnut',
            data: { labels: labels, datasets: [{ data: values, backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { padding: 8, usePointStyle: true, pointStyle: 'circle', font: { size: 11 } } } }, cutout: '60%' }
        });
    }

    function renderTopServices(data) {
        var $body = $('#topServicesBody');
        if (!data || data.length === 0) {
            $body.html('<div style="text-align:center; color:#94a3b8; font-size:0.85rem; padding:30px 0;">처리계 SDK 수집이 없습니다.</div>');
            return;
        }
        var max = Math.max.apply(null, data.map(function(d){ return Number(d.cnt) || 0; }));
        var html = '<div style="display:flex; flex-direction:column; gap:10px;">';
        data.forEach(function(s) {
            var pct = max > 0 ? Math.round((Number(s.cnt) / max) * 100) : 0;
            html +=
                '<div>' +
                  '<div style="display:flex; justify-content:space-between; font-size:0.82rem; margin-bottom:4px;">' +
                    '<span style="font-weight:600; color:#1e293b; max-width:65%; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="' + (s.serviceName||'') + '">' + (s.serviceName || '-') + '</span>' +
                    '<span style="color:#0d9488; font-weight:700;">' + Number(s.cnt).toLocaleString() + '</span>' +
                  '</div>' +
                  '<div style="height:6px; background:#f1f5f9; border-radius:999px; overflow:hidden;">' +
                    '<div style="height:100%; width:' + pct + '%; background:linear-gradient(90deg, #0d9488, #06b6d4); border-radius:999px;"></div>' +
                  '</div>' +
                '</div>';
        });
        html += '</div>';
        $body.html(html);
    }

    function renderHourlyChart(data) {
        var labels = [], values = [];
        for (var i = 0; i < 24; i++) {
            labels.push(i + '시');
            var found = data.find(function(d) { return d.hour == i; });
            values.push(found ? found.cnt : 0);
        }
        new Chart(document.getElementById('hourlyChart'), {
            type: 'line',
            data: { labels: labels, datasets: [{ label: '접속 건수', data: values, borderColor: '#0d9488', backgroundColor: 'rgba(13,148,136,0.1)', fill: true, tension: 0.4, pointRadius: 2, pointHoverRadius: 5 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }

    function renderActionChart(data) {
        var labels = [], values = [], colors = ['#0d9488','#0ea5e9','#f59e0b','#ef4444','#8b5cf6','#64748b'];
        data.forEach(function(d) { labels.push(d.actionType); values.push(d.cnt); });
        if (labels.length === 0) { labels = ['데이터 없음']; values = [1]; colors = ['#e2e8f0']; }
        new Chart(document.getElementById('actionChart'), {
            type: 'doughnut',
            data: { labels: labels, datasets: [{ data: values, backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { padding: 8, usePointStyle: true, pointStyle: 'circle', font: { size: 11 } } } }, cutout: '60%' }
        });
    }
});
</script>
