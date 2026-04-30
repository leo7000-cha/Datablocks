<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- Dashboard CSS -->
<link rel="stylesheet" href="/resources/css/dashboard-refactor.css">
<link rel="stylesheet" href="/resources/css/dashboard-hero-v2.css">
<link rel="stylesheet" href="/resources/css/dashboard-modernize-v2.css">

<!-- Main Dashboard Container -->
<div class="dashboard-container dashboard-modernize-v2" id="piidashboardlist">
    <div class="dashboard-scroll">

        <!-- ========== HEADER SECTION ========== -->
        <div class="dashboard-header dashboard-hero-v2">
            <div class="header-title">
                <h4><i class="fas fa-shield-alt"></i> <spring:message code="dashboard.purgeTitle" text="X-Purge — 개인정보 파기 통합 관리"/></h4>
                <p class="header-subtitle"><spring:message code="dashboard.subtitle" text="파기 정책·작업 실행·복원과 감사 증적까지, 한 화면에서 통합 관리합니다"/></p>
            </div>
            <div class="header-date">
                <i class="far fa-calendar-alt"></i>
                <span id="currentDate"></span>
            </div>
            <div class="dashboard-hero-illustration" aria-hidden="true">
                <svg viewBox="0 0 240 150" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <linearGradient id="heroShield" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stop-color="#6366f1"/>
                            <stop offset="100%" stop-color="#8b5cf6"/>
                        </linearGradient>
                        <linearGradient id="heroFlowL" x1="0%" y1="0%" x2="100%" y2="0%">
                            <stop offset="0%" stop-color="#06b6d4" stop-opacity="0"/>
                            <stop offset="50%" stop-color="#06b6d4" stop-opacity="0.75"/>
                            <stop offset="100%" stop-color="#06b6d4" stop-opacity="0"/>
                        </linearGradient>
                        <linearGradient id="heroFlowR" x1="0%" y1="0%" x2="100%" y2="0%">
                            <stop offset="0%" stop-color="#10b981" stop-opacity="0"/>
                            <stop offset="50%" stop-color="#10b981" stop-opacity="0.75"/>
                            <stop offset="100%" stop-color="#10b981" stop-opacity="0"/>
                        </linearGradient>
                    </defs>

                    <!-- Background data nodes (DB cylinders) -->
                    <g opacity="0.5">
                        <ellipse cx="34" cy="34" rx="15" ry="4" fill="#6366f1"/>
                        <path d="M19 34 Q19 42 34 42 Q49 42 49 34" fill="none" stroke="#6366f1" stroke-width="1.5"/>
                        <line x1="19" y1="34" x2="19" y2="40" stroke="#6366f1" stroke-width="1.5"/>
                        <line x1="49" y1="34" x2="49" y2="40" stroke="#6366f1" stroke-width="1.5"/>

                        <ellipse cx="206" cy="118" rx="13" ry="3.5" fill="#8b5cf6"/>
                        <path d="M193 118 Q193 125 206 125 Q219 125 219 118" fill="none" stroke="#8b5cf6" stroke-width="1.5"/>
                        <line x1="193" y1="118" x2="193" y2="123" stroke="#8b5cf6" stroke-width="1.5"/>
                        <line x1="219" y1="118" x2="219" y2="123" stroke="#8b5cf6" stroke-width="1.5"/>
                    </g>

                    <!-- Flow lines (animated dashes) -->
                    <path d="M48 40 Q88 65 118 75" fill="none" stroke="url(#heroFlowL)" stroke-width="1.6" stroke-dasharray="4 4">
                        <animate attributeName="stroke-dashoffset" from="0" to="-16" dur="2s" repeatCount="indefinite"/>
                    </path>
                    <path d="M196 116 Q150 95 122 85" fill="none" stroke="url(#heroFlowR)" stroke-width="1.6" stroke-dasharray="4 4">
                        <animate attributeName="stroke-dashoffset" from="0" to="16" dur="2.4s" repeatCount="indefinite"/>
                    </path>

                    <!-- Central shield -->
                    <g transform="translate(120, 75)">
                        <path d="M0 -42 L28 -31 L28 5 Q28 26 0 42 Q-28 26 -28 5 L-28 -31 Z"
                              fill="url(#heroShield)" opacity="0.96"/>
                        <path d="M0 -35 L22 -25 L22 3 Q22 21 0 33 Q-22 21 -22 3 L-22 -25 Z"
                              fill="white" opacity="0.94"/>
                        <!-- lock icon -->
                        <rect x="-9" y="-2" width="18" height="15" rx="2.5" fill="#4f46e5"/>
                        <path d="M-6 -2 V -9 Q-6 -16 0 -16 Q6 -16 6 -9 V -2"
                              fill="none" stroke="#4f46e5" stroke-width="2.2" stroke-linecap="round"/>
                        <circle cx="0" cy="5" r="2" fill="white"/>
                        <line x1="0" y1="5" x2="0" y2="10" stroke="white" stroke-width="2" stroke-linecap="round"/>
                    </g>

                    <!-- Sparkle accents -->
                    <circle cx="72" cy="22" r="2" fill="#f59e0b">
                        <animate attributeName="opacity" values="0.3;1;0.3" dur="2.5s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="176" cy="44" r="1.8" fill="#10b981">
                        <animate attributeName="opacity" values="0.3;1;0.3" dur="3s" begin="0.5s" repeatCount="indefinite"/>
                    </circle>
                    <circle cx="56" cy="124" r="1.8" fill="#06b6d4">
                        <animate attributeName="opacity" values="0.3;1;0.3" dur="2.8s" begin="1s" repeatCount="indefinite"/>
                    </circle>
                </svg>
            </div>
        </div>

        <!-- ========== 데이터 계산 ========== -->
        <c:set var="totalColumns" value="0"/>
        <c:set var="totalNotConfirmed" value="0"/>
        <c:set var="totalPiiColumns" value="0"/>
        <c:set var="totalNotRegistered" value="0"/>
        <c:set var="totalRegistered" value="0"/>
        <c:forEach var="status" items="${piiallstatus}">
            <c:set var="totalColumns" value="${totalColumns + status.total_columns}"/>
            <c:set var="totalNotConfirmed" value="${totalNotConfirmed + status.pii_notconfirmed}"/>
            <c:set var="totalPiiColumns" value="${totalPiiColumns + status.pii_columns}"/>
            <c:set var="totalNotRegistered" value="${totalNotRegistered + status.pii3_notregistered}"/>
            <c:set var="totalRegistered" value="${totalRegistered + status.pii_columns - status.pii3_notregistered}"/>
        </c:forEach>
        <c:set var="totalConfirmed" value="${totalColumns - totalNotConfirmed}"/>

        <!-- ========== PIPELINE SECTION (Data Flow) ========== -->
        <c:set var="confirmRate" value="${totalColumns > 0 ? (totalConfirmed * 100 / totalColumns) : 0}"/>
        <c:set var="piiRate" value="${totalConfirmed > 0 ? (totalPiiColumns * 100 / totalConfirmed) : 0}"/>
        <c:set var="regRate" value="${totalPiiColumns > 0 ? (totalRegistered * 100 / totalPiiColumns) : 0}"/>
        <div class="flow-pipeline" data-key="데이터 파이프라인">
            <!-- Node 1: 전체 컬럼 -->
            <div class="flow-node flow-node-total">
                <div class="flow-node-icon"><i class="fas fa-database"></i></div>
                <div class="flow-node-body">
                    <span class="flow-node-label"><spring:message code="dashboard.totalColumns" text="전체 컬럼"/></span>
                    <span class="flow-node-value"><fmt:formatNumber value="${totalColumns}" pattern="#,##0"/></span>
                </div>
            </div>
            <!-- Flow 1 → 2 -->
            <div class="flow-link flow-link-1">
                <div class="flow-link-track">
                    <div class="flow-link-fill flow-fill-blue" style="width:<fmt:formatNumber value="${confirmRate}" pattern="#,##0"/>%"></div>
                </div>
                <span class="flow-link-rate"><fmt:formatNumber value="${confirmRate}" pattern="#,##0.0"/>%</span>
            </div>
            <!-- Node 2: 컬럼 확인 -->
            <div class="flow-node flow-node-confirmed">
                <div class="flow-node-icon"><i class="fas fa-clipboard-check"></i></div>
                <div class="flow-node-body">
                    <span class="flow-node-label"><spring:message code="dashboard.columnConfirm" text="컬럼 확인"/></span>
                    <span class="flow-node-value"><fmt:formatNumber value="${totalConfirmed}" pattern="#,##0"/></span>
                </div>
            </div>
            <!-- Flow 2 → 3 -->
            <div class="flow-link flow-link-2">
                <div class="flow-link-track">
                    <div class="flow-link-fill flow-fill-amber" style="width:<fmt:formatNumber value="${piiRate}" pattern="#,##0"/>%"></div>
                </div>
                <span class="flow-link-rate"><fmt:formatNumber value="${piiRate}" pattern="#,##0.0"/>%</span>
            </div>
            <!-- Node 3: 개인정보 -->
            <div class="flow-node flow-node-pii">
                <div class="flow-node-icon"><i class="fas fa-user-shield"></i></div>
                <div class="flow-node-body">
                    <span class="flow-node-label"><spring:message code="dashboard.piiColumn" text="개인정보"/></span>
                    <span class="flow-node-value"><fmt:formatNumber value="${totalPiiColumns}" pattern="#,##0"/></span>
                </div>
            </div>
            <!-- Flow 3 → 4 -->
            <div class="flow-link flow-link-3">
                <div class="flow-link-track">
                    <div class="flow-link-fill flow-fill-green" style="width:<fmt:formatNumber value="${regRate}" pattern="#,##0"/>%"></div>
                </div>
                <span class="flow-link-rate"><fmt:formatNumber value="${regRate}" pattern="#,##0.0"/>%</span>
            </div>
            <!-- Node 4: 파기 등록 -->
            <div class="flow-node flow-node-registered">
                <div class="flow-node-icon"><i class="fas fa-check-double"></i></div>
                <div class="flow-node-body">
                    <span class="flow-node-label"><spring:message code="dashboard.destroyRegister" text="파기 등록"/></span>
                    <span class="flow-node-value"><fmt:formatNumber value="${totalRegistered}" pattern="#,##0"/></span>
                </div>
            </div>
        </div>

        <!-- ========== ACTION + JOB SECTION ========== -->
        <div class="dashboard-row">
            <!-- 처리 필요 항목 -->
            <div class="dashboard-section section-action" data-key="처리 필요 항목">
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-exclamation-triangle"></i>
                            <h5><spring:message code="dashboard.actionRequired" text="처리 필요"/></h5>
                        </div>
                    </div>
                    <div class="section-body">
                        <div class="action-items">
                            <!-- 컬럼 확인 필요 -->
                            <c:set var="notConfirmRate" value="${totalColumns > 0 ? (totalNotConfirmed * 100 / totalColumns) : 0}"/>
                            <div class="action-item action-item-warning"
                                 onclick="$('#content_home').load('/metatable/list?pagenum=1&amount=100&search15=N', function() { ingHide(); });"
                                 style="cursor: pointer;">
                                <div class="action-icon">
                                    <i class="fas fa-search"></i>
                                </div>
                                <div class="action-info">
                                    <span class="action-label"><spring:message code="dashboard.columnNotConfirmed" text="컬럼 미확인"/></span>
                                    <span class="action-desc"><spring:message code="dashboard.total" text="전체"/> <fmt:formatNumber value="${totalColumns}" pattern="#,##0"/><spring:message code="dashboard.count" text="건"/> <spring:message code="dashboard.among" text="중"/> <spring:message code="dashboard.notConfirmedDesc" text="미확인"/></span>
                                </div>
                                <div class="action-stats">
                                    <div class="action-value">
                                        <fmt:formatNumber value="${totalNotConfirmed}" pattern="#,##0"/>
                                        <span class="action-unit"><spring:message code="dashboard.count" text="건"/></span>
                                    </div>
                                    <div class="action-percent">
                                        <fmt:formatNumber value="${notConfirmRate}" pattern="#,##0.0"/>%
                                    </div>
                                </div>
                                <div class="action-progress-wrapper">
                                    <div class="action-progress">
                                        <div class="action-progress-bar action-progress-warning" style="width: <fmt:formatNumber value="${notConfirmRate}" pattern="#,##0"/>%"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- 파기 미등록 (Destroy Not Registered) -->
                            <c:set var="notRegRate" value="${totalPiiColumns > 0 ? (totalNotRegistered * 100 / totalPiiColumns) : 0}"/>
                            <div class="action-item action-item-danger"
                                 onclick="$('#content_home').load('/metatable/piicolregstatlist?pagenum=1&amount=100&search6=PII_POLICY3&search5=N', function() { ingHide(); });"
                                 style="cursor: pointer;">
                                <div class="action-icon">
                                    <i class="fas fa-file-excel"></i>
                                </div>
                                <div class="action-info">
                                    <span class="action-label"><spring:message code="dashboard.destroyNotRegistered" text="파기 미등록"/></span>
                                    <span class="action-desc"><spring:message code="dashboard.piiColumn" text="개인정보"/><spring:message code="common.column" text="컬럼"/> <fmt:formatNumber value="${totalPiiColumns}" pattern="#,##0"/><spring:message code="dashboard.count" text="건"/> <spring:message code="dashboard.among" text="중"/> <spring:message code="dashboard.notRegisteredDesc" text="미등록"/></span>
                                </div>
                                <div class="action-stats">
                                    <div class="action-value">
                                        <fmt:formatNumber value="${totalNotRegistered}" pattern="#,##0"/>
                                        <span class="action-unit"><spring:message code="dashboard.count" text="건"/></span>
                                    </div>
                                    <div class="action-percent">
                                        <fmt:formatNumber value="${notRegRate}" pattern="#,##0.0"/>%
                                    </div>
                                </div>
                                <div class="action-progress-wrapper">
                                    <div class="action-progress">
                                        <div class="action-progress-bar action-progress-danger" style="width: <fmt:formatNumber value="${notRegRate}" pattern="#,##0"/>%"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Job Status - Error Focus (JOB 오류 현황) -->
            <div class="dashboard-section section-job" data-key="JOB 수행 현황">
                <div class="section-card">
                    <div class="section-header"
                         onclick="$('#content_home').load('/piiorder/list?pagenum=1&amount=100', function() { ingHide(); });"
                         style="cursor: pointer;">
                        <div class="section-title">
                            <i class="fas fa-cogs"></i>
                            <h5><spring:message code="etc.jobExecutionStatus" text="JOB 수행 현황"/></h5>
                        </div>
                    </div>
                    <div class="section-body section-body-job">
                        <div class="job-error-focus">
                            <!-- Error Alert Card -->
                            <c:choose>
                                <c:when test="${jobresultlist.ko > 0}">
                                    <div class="job-alert job-alert-error"
                                         onclick="$('#content_home').load('/piiorder/list?pagenum=1&amount=100&search4=Ended+not+OK', function() { ingHide(); });">
                                        <div class="job-alert-icon">
                                            <i class="fas fa-exclamation-triangle"></i>
                                        </div>
                                        <div class="job-alert-content">
                                            <span class="job-alert-value"><c:out value="${jobresultlist.ko}"/></span>
                                            <span class="job-alert-label"><spring:message code="job.error" text="오류"/></span>
                                        </div>
                                        <span class="job-alert-action"><spring:message code="job.checkImmediately" text="즉시 확인 필요"/> <i class="fas fa-chevron-right"></i></span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="job-alert job-alert-ok">
                                        <div class="job-alert-icon">
                                            <i class="fas fa-check-circle"></i>
                                        </div>
                                        <div class="job-alert-content">
                                            <span class="job-alert-label-ok"><spring:message code="job.normal" text="정상"/></span>
                                        </div>
                                        <span class="job-alert-desc"><spring:message code="job.noError" text="오류 없음"/></span>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <!-- Other Stats -->
                            <div class="job-other-stats">
                                <div class="job-stat-item">
                                    <span class="job-stat-label"><spring:message code="job.wait" text="대기"/></span>
                                    <span class="job-stat-value"><c:out value="${jobresultlist.wait}"/></span>
                                </div>
                                <div class="job-stat-item">
                                    <span class="job-stat-label"><spring:message code="job.running" text="실행중"/></span>
                                    <span class="job-stat-value job-stat-running"><c:out value="${jobresultlist.run}"/></span>
                                </div>
                                <div class="job-stat-item">
                                    <span class="job-stat-label"><spring:message code="job.completed" text="정상완료"/></span>
                                    <span class="job-stat-value job-stat-ok"><c:out value="${jobresultlist.ok}"/></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== SYSTEM STATUS HEATMAP ========== -->
        <div class="heatmap-section" data-key="시스템별 현황">
            <div class="section-card">
                <div class="section-header">
                    <div class="section-title">
                        <i class="fas fa-th"></i>
                        <h5><spring:message code="dashboard.systemDestroyStatus" text="시스템별 파기 등록 현황"/></h5>
                    </div>
                </div>
                <div class="section-body">
                    <div class="table-container">
                        <table class="heatmap-table">
                            <thead>
                                <tr>
                                    <th class="text-center"><spring:message code="common.system" text="시스템"/></th>
                                    <th class="text-center">DB</th>
                                    <th class="text-center"><spring:message code="dashboard.totalColumns" text="전체 컬럼"/></th>
                                    <th class="text-center"><spring:message code="dashboard.columnConfirm" text="컬럼 확인"/></th>
                                    <th class="text-center"><spring:message code="dashboard.confirmRate" text="확인률"/></th>
                                    <th class="text-center"><spring:message code="dashboard.piiColumn" text="개인정보"/></th>
                                    <th class="text-center"><spring:message code="dashboard.destroyRegister" text="파기 등록"/></th>
                                    <th class="text-center"><spring:message code="dashboard.registerRate" text="등록률"/></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="status" items="${piiallstatus}">
                                    <c:set var="sysConfirmed" value="${status.total_columns - status.pii_notconfirmed}"/>
                                    <c:set var="sysConfirmRate" value="${status.total_columns > 0 ? (sysConfirmed * 100 / status.total_columns) : 0}"/>
                                    <c:set var="sysRegistered" value="${status.pii_columns - status.pii3_notregistered}"/>
                                    <c:set var="sysRegRate" value="${status.pii_columns > 0 ? (sysRegistered * 100 / status.pii_columns) : 0}"/>
                                    <tr>
                                        <td class="text-center"><span class="cell-system"><c:out value="${status.system_name}"/></span></td>
                                        <td class="text-center"><span class="cell-db"><c:out value="${status.db}"/></span></td>
                                        <td class="text-center"><fmt:formatNumber value="${status.total_columns}" pattern="#,##0"/></td>
                                        <td class="text-center"><fmt:formatNumber value="${sysConfirmed}" pattern="#,##0"/></td>
                                        <td class="text-center">
                                            <span class="rate-badge ${sysConfirmRate >= 90 ? 'rate-good' : (sysConfirmRate >= 70 ? 'rate-warning' : 'rate-danger')}">
                                                <fmt:formatNumber value="${sysConfirmRate}" pattern="#,##0"/>%
                                            </span>
                                        </td>
                                        <td class="text-center"><fmt:formatNumber value="${status.pii_columns}" pattern="#,##0"/></td>
                                        <td class="text-center"><fmt:formatNumber value="${sysRegistered}" pattern="#,##0"/></td>
                                        <td class="text-center">
                                            <span class="rate-badge ${sysRegRate >= 90 ? 'rate-good' : (sysRegRate >= 70 ? 'rate-warning' : 'rate-danger')}">
                                                <fmt:formatNumber value="${sysRegRate}" pattern="#,##0"/>%
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== CHARTS SECTION - 3 columns ========== -->
        <div class="charts-grid-3">
            <!-- 누적 파기 현황 -->
            <div class="chart-section" data-key="누적 고객 파기 현황">
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-chart-area"></i>
                            <h5><spring:message code="etc.cumulativePurgeStatus" text="누적 파기 현황"/></h5>
                        </div>
                    </div>
                    <div class="section-body section-body-chart">
                        <div class="chart-container-md">
                            <canvas id="ChartSum"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 일별 파기 현황 -->
            <div class="chart-section" data-key="일별 파기 현황">
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-calendar-day"></i>
                            <h5><spring:message code="etc.dailyPurgeStatus" text="일별 파기 현황"/></h5>
                        </div>
                    </div>
                    <div class="section-body section-body-chart">
                        <div class="chart-container-md">
                            <canvas id="ChartDaily"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 월별 파기 현황 -->
            <div class="chart-section" data-key="월별 파기 현황">
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-calendar-alt"></i>
                            <h5><spring:message code="etc.monthlyPurgeStatus" text="월별 파기 현황"/></h5>
                        </div>
                    </div>
                    <div class="section-body section-body-chart">
                        <div class="chart-container-md">
                            <canvas id="ChartMonthly"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== 실물 파기 현황 (별도 행) ========== -->
        <div class="charts-grid-3">
            <div class="chart-section" data-key="실물 파기 현황">
                <div class="section-card">
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-file-alt"></i>
                            <h5><spring:message code="etc.physicalPurgeStatus" text="실물 파기 현황"/></h5>
                        </div>
                    </div>
                    <div class="section-body section-body-chart">
                        <div class="chart-container-md">
                            <canvas id="realDocMonthly"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== NOTICE SECTION ========== -->
        <div class="notice-section" data-key="공지 사항" style="display:none;">
            <div class="section-card">
                <div class="section-header">
                    <div class="section-title">
                        <i class="fas fa-bullhorn"></i>
                        <h5><spring:message code="etc.notice" text="공지사항"/></h5>
                    </div>
                </div>
                <div class="section-body">
                    <div class="notice-list">
                        <c:if test="${not empty notice1}">
                            <div class="notice-item">
                                <i class="fas fa-info-circle"></i>
                                <span><c:out value="${notice1}"/></span>
                            </div>
                        </c:if>
                        <c:if test="${not empty notice2}">
                            <div class="notice-item">
                                <i class="fas fa-info-circle"></i>
                                <span><c:out value="${notice2}"/></span>
                            </div>
                        </c:if>
                        <c:if test="${not empty notice3}">
                            <div class="notice-item">
                                <i class="fas fa-info-circle"></i>
                                <span><c:out value="${notice3}"/></span>
                            </div>
                        </c:if>
                        <c:if test="${not empty notice4}">
                            <div class="notice-item">
                                <i class="fas fa-info-circle"></i>
                                <span><c:out value="${notice4}"/></span>
                            </div>
                        </c:if>
                        <c:if test="${not empty notice5}">
                            <div class="notice-item">
                                <i class="fas fa-info-circle"></i>
                                <span><c:out value="${notice5}"/></span>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- ========== SCRIPTS ========== -->
<script type="text/javascript">
    // Display current date
    document.getElementById('currentDate').textContent = new Date().toLocaleDateString('ko-KR', {
        year: 'numeric', month: 'long', day: 'numeric', weekday: 'long'
    });

    // Dashboard visibility config
    const configStr = "<c:out value='${dashboardShow}' />";
    const config = {};
    configStr.split(',').forEach(pair => {
        const [key, val] = pair.trim().split(':');
        config[key] = val;
    });

    document.querySelectorAll('[data-key]').forEach(el => {
        const key = el.getAttribute('data-key');
        if (config[key] && config[key].toUpperCase() === 'N') {
            el.style.display = 'none';
        }
    });
</script>

<script type="text/javascript">
    $(function () {
        $("#menupath").html("<i class='fas fa-tachometer-alt'></i> <spring:message code="memu.dashboard" text="Dashboard"/>");
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
    });
</script>

<!-- Chart.js -->
<script src="/resources/vendor/chart.js/chart.umd.min.js"></script>


<!-- Cumulative Line Chart -->
<script type="text/javascript">
    var ym11 = "<c:out value="${custstatsumlist.ym_11}"/>";
    var ym10 = "<c:out value="${custstatsumlist.ym_10}"/>";
    var ym9 = "<c:out value="${custstatsumlist.ym_9}"/>";
    var ym8 = "<c:out value="${custstatsumlist.ym_8}"/>";
    var ym7 = "<c:out value="${custstatsumlist.ym_7}"/>";
    var ym6 = "<c:out value="${custstatsumlist.ym_6}"/>";
    var ym5 = "<c:out value="${custstatsumlist.ym_5}"/>";
    var ym4 = "<c:out value="${custstatsumlist.ym_4}"/>";
    var ym3 = "<c:out value="${custstatsumlist.ym_3}"/>";
    var ym2 = "<c:out value="${custstatsumlist.ym_2}"/>";
    var ym1 = "<c:out value="${custstatsumlist.ym_1}"/>";
    var ym0 = "<c:out value="${custstatsumlist.ym_0}"/>";

    var contextSum = document.getElementById('ChartSum');
    if (contextSum) {
        var gradientSum = contextSum.getContext('2d').createLinearGradient(0, 0, 0, 200);
        gradientSum.addColorStop(0, 'rgba(99, 102, 241, 0.4)');
        gradientSum.addColorStop(1, 'rgba(99, 102, 241, 0.02)');

        new Chart(contextSum, {
            type: 'line',
            data: {
                labels: [ym11, ym10, ym9, ym8, ym7, ym6, ym5, ym4, ym3, ym2, ym1, ym0],
                datasets: [{
                    label: '<spring:message code="etc.cumulativePurgeCustomerCount" text="누적 파기 고객 수"/>',
                    fill: true,
                    data: [
                        <c:out value="${custstatsumlist.cnt_11}"/>,
                        <c:out value="${custstatsumlist.cnt_10}"/>,
                        <c:out value="${custstatsumlist.cnt_9}"/>,
                        <c:out value="${custstatsumlist.cnt_8}"/>,
                        <c:out value="${custstatsumlist.cnt_7}"/>,
                        <c:out value="${custstatsumlist.cnt_6}"/>,
                        <c:out value="${custstatsumlist.cnt_5}"/>,
                        <c:out value="${custstatsumlist.cnt_4}"/>,
                        <c:out value="${custstatsumlist.cnt_3}"/>,
                        <c:out value="${custstatsumlist.cnt_2}"/>,
                        <c:out value="${custstatsumlist.cnt_1}"/>,
                        <c:out value="${custstatsumlist.cnt_0}"/>
                    ],
                    backgroundColor: gradientSum,
                    borderColor: '#6366f1',
                    borderWidth: 2,
                    tension: 0.4,
                    pointBackgroundColor: '#6366f1',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: "rgba(30, 41, 59, 0.95)",
                        bodyColor: "#f8fafc",
                        titleColor: "#f8fafc",
                        padding: 12,
                        cornerRadius: 8,
                        callbacks: {
                            label: function(context) {
                                return new Intl.NumberFormat('ko-KR').format(context.raw) + ' 건';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.05)' },
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('ko-KR').format(value);
                            },
                            font: { size: 11 }
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { font: { size: 11 } }
                    }
                }
            }
        });
    }
</script>

<!-- Daily Bar Chart -->
<script type="text/javascript">
    let monlist = [
        <c:forEach items="${custstatlistdaily}" var="month">'<c:out value="${month.mon}" />',</c:forEach>
    ];
    let policy2list = [
        <c:forEach items="${custstatlistdaily}" var="month">'<c:out value="${month.archive_cnt2}" />',</c:forEach>
    ];
    let policy3list = [
        <c:forEach items="${custstatlistdaily}" var="month">'<c:out value="${month.archive_cnt3}" />',</c:forEach>
    ];

    var context = document.getElementById('ChartDaily');
    if (context) {
        new Chart(context, {
            type: 'bar',
            data: {
                labels: monlist,
                datasets: [
                    {
                        label: '<spring:message code="etc.rejectCancel" text="상담 거절/취소"/>',
                        data: policy2list,
                        backgroundColor: 'rgba(245, 158, 11, 0.8)',
                        borderRadius: 4
                    },
                    {
                        label: '<spring:message code="etc.noActviceTransactions" text="거래 없는 고객"/>',
                        data: policy3list,
                        backgroundColor: 'rgba(99, 102, 241, 0.8)',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: { usePointStyle: true, font: { size: 11 }, padding: 15 }
                    },
                    tooltip: {
                        backgroundColor: "rgba(30, 41, 59, 0.95)",
                        bodyColor: "#f8fafc",
                        titleColor: "#f8fafc",
                        padding: 12,
                        cornerRadius: 8
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.05)' },
                        ticks: {
                            callback: function(value) { return new Intl.NumberFormat('ko-KR').format(value); },
                            font: { size: 11 }
                        }
                    },
                    x: { grid: { display: false }, ticks: { font: { size: 10 } } }
                }
            }
        });
    }
</script>

<!-- Monthly Bar Chart -->
<script type="text/javascript">
    let monlistM = [
        <c:forEach items="${custstatlistmonthly}" var="month">'<c:out value="${month.mon}" />',</c:forEach>
    ];
    let policy2listM = [
        <c:forEach items="${custstatlistmonthly}" var="month">'<c:out value="${month.archive_cnt2}" />',</c:forEach>
    ];
    let policy3listM = [
        <c:forEach items="${custstatlistmonthly}" var="month">'<c:out value="${month.archive_cnt3}" />',</c:forEach>
    ];

    var contextMonthly = document.getElementById('ChartMonthly');
    if (contextMonthly) {
        new Chart(contextMonthly, {
            type: 'bar',
            data: {
                labels: monlistM,
                datasets: [
                    {
                        label: '<spring:message code="etc.rejectCancel" text="상담 거절/취소"/>',
                        data: policy2listM,
                        backgroundColor: 'rgba(245, 158, 11, 0.8)',
                        borderRadius: 4
                    },
                    {
                        label: '<spring:message code="etc.noActviceTransactions" text="거래 없는 고객"/>',
                        data: policy3listM,
                        backgroundColor: 'rgba(99, 102, 241, 0.8)',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: { usePointStyle: true, font: { size: 11 }, padding: 15 }
                    },
                    tooltip: {
                        backgroundColor: "rgba(30, 41, 59, 0.95)",
                        bodyColor: "#f8fafc",
                        titleColor: "#f8fafc",
                        padding: 12,
                        cornerRadius: 8
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.05)' },
                        ticks: {
                            callback: function(value) { return new Intl.NumberFormat('ko-KR').format(value); },
                            font: { size: 11 }
                        }
                    },
                    x: { grid: { display: false }, ticks: { font: { size: 10 } } }
                }
            }
        });
    }
</script>

<!-- Real Document Bar Chart -->
<script type="text/javascript">
    let monlistR = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">'<c:out value="${month.mon}" />',</c:forEach>
    ];
    let acountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">'<c:out value="${month.acount}" />',</c:forEach>
    ];
    let ncountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">'<c:out value="${month.ncount}" />',</c:forEach>
    ];
    let ycountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">'<c:out value="${month.ycount}" />',</c:forEach>
    ];

    var contextRealDoc = document.getElementById('realDocMonthly');
    if (contextRealDoc) {
        new Chart(contextRealDoc, {
            type: 'bar',
            data: {
                labels: monlistR,
                datasets: [
                    {
                        label: '<spring:message code="etc.real_doc_del_target" text="파기 대상"/>',
                        data: acountlist,
                        backgroundColor: 'rgba(99, 102, 241, 0.7)',
                        borderRadius: 4
                    },
                    {
                        label: '<spring:message code="etc.real_doc_del_complete" text="미완료"/>',
                        data: ncountlist,
                        backgroundColor: 'rgba(239, 68, 68, 0.7)',
                        borderRadius: 4
                    },
                    {
                        label: '<spring:message code="etc.real_doc_del_not_complete" text="완료"/>',
                        data: ycountlist,
                        backgroundColor: 'rgba(16, 185, 129, 0.7)',
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: { usePointStyle: true, font: { size: 11 }, padding: 12 }
                    },
                    tooltip: {
                        backgroundColor: "rgba(30, 41, 59, 0.95)",
                        bodyColor: "#f8fafc",
                        titleColor: "#f8fafc",
                        padding: 12,
                        cornerRadius: 8
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.05)' },
                        ticks: {
                            callback: function(value) { return new Intl.NumberFormat('ko-KR').format(value); },
                            font: { size: 11 }
                        }
                    },
                    x: { grid: { display: false }, ticks: { font: { size: 10 } } }
                }
            }
        });
    }
</script>

<!-- Password Change Check -->
<script type="text/javascript">
    $(function(){
        <sec:authentication property="principal.member.userid" var="userid"/>
        <c:if test="${userid ne 'admin' }">
        if("<c:out value='${needtochangepwd}'/>" == "INI"){
            showConfirm("<spring:message code="etc.pwdfirst" text="비밀번호가 초기 상태입니다. 지금 변경하시겠습니까?"/>", function(){
                searchAction_pwd("<c:out value='${userid}'/>");
            });
        }
        if("<c:out value='${needtochangepwd}'/>" == "EXPIRED"){
            showConfirm("<spring:message code="etc.pwdreset" text="비밀번호가 6개월 이상 변경되지 않았습니다. 지금 변경하시겠습니까?"/>", function(){
                searchAction_pwd("<c:out value='${userid}'/>");
            });
        }
        </c:if>
    });

    searchAction_pwd = function(userid) {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piimember/modify?userid=" + userid + "&pagenum=1&amount=100",
            dataType: "html",
            error: function(request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function(data) {
                ingHide();
                $('#content_home').html(data);
            }
        });
    }
</script>
