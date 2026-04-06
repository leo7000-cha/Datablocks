<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- 탐지 결과 Content -->
<div id="resultsContent">
    <!-- Execution Progress Panel (동적으로 표시) -->
    <div id="executionProgressPanel" style="display: none; margin-bottom: 20px;">
        <div class="content-panel">
            <div class="panel-header d-flex justify-content-between align-items-center" style="padding: 15px 20px;">
                <div class="d-flex align-items-center gap-3">
                    <h3 class="panel-title mb-0">
                        <i class="fas fa-sync-alt fa-spin text-primary me-2" id="scanningIcon"></i>
                        <span id="executionTitle">스캔 진행</span>
                    </h3>
                    <span class="badge badge-primary" id="executionStatus" style="margin-left: 10px;">실행중</span>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-sm btn-outline-primary" id="btnRefreshProgress" onclick="refreshProgress()">
                        <i class="fas fa-sync-alt"></i> 새로고침
                    </button>
                    <button class="btn btn-sm btn-outline-info" id="btnResumeScan" style="display:none;" onclick="resumeCurrentScan()">
                        <i class="fas fa-redo"></i> 이어서 실행
                    </button>
                    <button class="btn btn-sm btn-outline-danger" id="btnCancelScan" onclick="cancelCurrentScan()">
                        <i class="fas fa-stop"></i> 취소
                    </button>
                </div>
            </div>
            <div class="panel-body" style="padding: 20px;">
                <!-- Progress Stats -->
                <div class="progress-stats-grid">
                    <div class="progress-stat-item">
                        <div class="progress-stat-value" id="statProgress">0%</div>
                        <div class="progress-stat-label">진행률</div>
                    </div>
                    <div class="progress-stat-item">
                        <div class="progress-stat-value">
                            <span id="statScannedTables">0</span> / <span id="statTotalTables">0</span>
                        </div>
                        <div class="progress-stat-label">테이블</div>
                    </div>
                    <div class="progress-stat-item">
                        <div class="progress-stat-value" id="statColumns">0</div>
                        <div class="progress-stat-label">스캔된 컬럼</div>
                    </div>
                    <div class="progress-stat-item">
                        <div class="progress-stat-value text-danger" id="statPiiCount">0</div>
                        <div class="progress-stat-label">개인정보 탐지</div>
                    </div>
                    <div class="progress-stat-item">
                        <div class="progress-stat-value" id="statElapsed">0s</div>
                        <div class="progress-stat-label">경과 시간</div>
                    </div>
                    <div class="progress-stat-item">
                        <div class="progress-stat-value" id="statRemaining">-</div>
                        <div class="progress-stat-label">남은 시간</div>
                    </div>
                </div>

                <!-- Progress Bar -->
                <div class="progress" style="height: 24px; margin-top: 15px; border-radius: 12px;">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" id="mainProgressBar"
                         style="width: 0%; background: linear-gradient(90deg, #6366f1, #0ea5e9);"></div>
                </div>

                <!-- Currently Scanning Tables (Thread별 동시 스캔) -->
                <div class="current-table-info mt-3">
                    <span class="text-muted">현재 스캔 중 (<span id="scanningThreadCount">0</span> 스레드):</span>
                    <div id="currentScanningTables" class="d-flex flex-wrap gap-2 mt-2">
                        <code class="scanning-table-tag">-</code>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Table Scan Status (접을 수 있는 패널) -->
    <div id="tableScanStatusPanel" style="display: none; margin-bottom: 20px;">
        <div class="content-panel">
            <div class="panel-header d-flex justify-content-between align-items-center" style="padding: 12px 20px; cursor: pointer;" onclick="toggleTableList()">
                <div class="d-flex align-items-center gap-2">
                    <i class="fas fa-table"></i>
                    <h3 class="panel-title mb-0">테이블 스캔 상태</h3>
                    <span class="badge badge-secondary" style="margin-left: 10px;" id="tableStatusCount">0 테이블</span>
                </div>
                <i class="fas fa-chevron-down" id="tableListToggleIcon"></i>
            </div>
            <div class="panel-body" id="tableListBody" style="display: none; max-height: 300px; overflow-y: auto; padding: 0;">
                <table class="discovery-table" style="margin: 0;">
                    <thead style="position: sticky; top: 0; background: white;">
                        <tr>
                            <th style="width: 50px;">No.</th>
                            <th>스키마</th>
                            <th>테이블명</th>
                            <th style="width: 100px;">컬럼</th>
                            <th style="width: 80px;">개인정보</th>
                            <th style="width: 100px;">시간</th>
                            <th style="width: 100px;">상태</th>
                        </tr>
                    </thead>
                    <tbody id="tableStatusBody">
                        <!-- 동적으로 채워짐 -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="content-panel" style="margin-bottom: 20px;">
        <div class="panel-body" style="padding: 14px 20px;">
            <div class="d-flex align-items-center justify-content-between flex-wrap" style="gap: 12px;">
                <div class="d-flex align-items-center flex-wrap" style="gap: 8px;">
                    <select class="form-control form-control-sm filter-field" style="width: 340px !important;" id="filterExecution">
                        <option value="">실행 이력</option>
                    </select>
                    <select class="form-control form-control-sm filter-field" style="width: 140px !important;" id="filterPiiType">
                        <option value="">개인정보 유형</option>
                        <c:forEach var="piiType" items="${piiTypeList}">
                            <option value="${piiType.piiTypeCode}">${piiType.piiTypeName}</option>
                        </c:forEach>
                    </select>
                    <select class="form-control form-control-sm filter-field" id="filterScore">
                        <option value="">점수</option>
                        <option value="high">높음 (80+)</option>
                        <option value="medium">보통 (50-79)</option>
                        <option value="low">낮음 (0-49)</option>
                    </select>
                    <select class="form-control form-control-sm filter-field" style="width: 140px !important;" id="filterStatus">
                        <option value="">상태</option>
                        <option value="PENDING">검토 대기</option>
                        <option value="NOT_PII">PII 아님</option>
                        <option value="CONFIRMED">PII 확정</option>
                        <option value="EXCLUDED">오탐 제외</option>
                    </select>
                    <select class="form-control form-control-sm filter-field" style="width: 130px !important;" id="filterDb">
                        <option value="">데이터베이스</option>
                    </select>
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterSchema" placeholder="스키마 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterTable" placeholder="테이블 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterColumn" placeholder="컬럼 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <button class="btn btn-sm btn-primary filter-btn" type="button" onclick="applyFilters()">
                        <i class="fas fa-search"></i> 검색
                    </button>
                </div>
                <div class="d-flex align-items-center" style="gap: 8px;">
                    <button class="btn btn-sm btn-outline-secondary action-btn" onclick="clearFilters()">
                        <i class="fas fa-redo"></i> 초기화
                    </button>
                    <button class="btn btn-sm btn-outline-primary action-btn" onclick="refreshAll()">
                        <i class="fas fa-sync-alt"></i> 새로고침
                    </button>
                    <span class="text-muted" id="selectedCount" style="display: none; margin: 0 4px;">
                        <strong id="selectedNum">0</strong> 건 선택
                    </span>
                    <button class="btn btn-outline-success btn-sm action-btn" id="btnConfirmSelected" onclick="confirmSelected('CONFIRMED')" disabled>
                        <i class="fas fa-check"></i> 확인
                    </button>
                    <button class="btn btn-outline-warning btn-sm action-btn" id="btnExcludeSelected" onclick="confirmSelected('EXCLUDED')" disabled>
                        <i class="fas fa-ban"></i> 제외
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Results Table -->
    <div class="content-panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div>
                <h3 class="panel-title">탐지 결과</h3>
                <span style="color: #64748b; font-size: 0.85rem;">총 <strong id="totalCount">${pageMaker.total}</strong> 건 탐지</span>
            </div>
        </div>
        <div class="panel-body" style="padding: 0;">
            <div id="resultsTableWrapper">
                <c:choose>
                    <c:when test="${not empty resultList}">
                        <table class="discovery-table" id="resultsTable" style="white-space: nowrap;">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">
                                        <input type="checkbox" id="selectAll" onclick="toggleSelectAll()">
                                    </th>
                                    <th style="width: 160px;">스캔 일시</th>
                                    <th>데이터베이스</th>
                                    <th>스키마</th>
                                    <th>테이블</th>
                                    <th>컬럼</th>
                                    <th>데이터 타입</th>
                                    <th>개인정보 유형</th>
                                    <th style="width: 100px;">점수</th>
                                    <th>방법</th>
                                    <th style="width: 100px;">상태</th>
                                    <th style="width: 100px;">작업</th>
                                </tr>
                            </thead>
                            <tbody id="resultsBody">
                                <c:forEach var="result" items="${resultList}">
                                    <tr data-id="${result.resultId}" data-status="${result.confirmStatus}">
                                        <td><input type="checkbox" class="result-checkbox" value="${result.resultId}" onclick="updateSelection()"></td>
                                        <td><small>${result.scanDate}</small></td>
                                        <td>${result.dbName}</td>
                                        <td>${result.schemaName}</td>
                                        <td><strong>${result.tableName}</strong></td>
                                        <td><code>${result.columnName}</code></td>
                                        <td><span class="badge badge-secondary">${result.dataType}</span></td>
                                        <td><span class="badge badge-info">${result.piiTypeName}</span></td>
                                        <td>
                                            <span class="score-badge ${result.score >= 80 ? 'high' : (result.score >= 50 ? 'medium' : 'low')}"
                                                  style="cursor: pointer;"
                                                  onclick="showDetailModal('${result.resultId}')"
                                                  title="클릭하여 상세 보기">
                                                ${result.score}% <i class="fas fa-search-plus" style="font-size: 0.7em; margin-left: 3px;"></i>
                                            </span>
                                        </td>
                                        <td>
                                            <c:if test="${result.metaMatch == 'Y'}"><span class="badge badge-info" style="margin-right: 3px;">메타</span></c:if>
                                            <c:if test="${result.patternMatch == 'Y'}"><span class="badge badge-success" style="margin-right: 3px;">패턴</span></c:if>
                                            <c:if test="${result.aiMatch == 'Y'}"><span class="badge badge-warning">AI</span></c:if>
                                        </td>
                                        <td>
                                            <span class="status-badge ${result.confirmStatus.toLowerCase()}">
                                                <c:choose>
                                                    <c:when test="${result.confirmStatus == 'PENDING'}">검토 대기</c:when>
                                                    <c:when test="${result.confirmStatus == 'NOT_PII'}">PII 아님</c:when>
                                                    <c:when test="${result.confirmStatus == 'CONFIRMED'}">PII 확정</c:when>
                                                    <c:when test="${result.confirmStatus == 'EXCLUDED'}">오탐 제외</c:when>
                                                    <c:otherwise>${result.confirmStatus}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <c:choose>
                                                    <c:when test="${result.confirmStatus == 'NOT_PII'}">
                                                        <button class="btn btn-outline-primary" title="개인정보로 표시" onclick="confirmSingle('${result.resultId}', 'PENDING')">
                                                            <i class="fas fa-exclamation-triangle"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:if test="${result.confirmStatus != 'CONFIRMED'}">
                                                            <button class="btn btn-outline-success" title="PII 확정" onclick="confirmSingle('${result.resultId}', 'CONFIRMED')">
                                                                <i class="fas fa-check"></i>
                                                            </button>
                                                        </c:if>
                                                        <c:if test="${result.confirmStatus != 'EXCLUDED'}">
                                                            <button class="btn btn-outline-secondary" title="제외" onclick="confirmSingle('${result.resultId}', 'EXCLUDED')">
                                                                <i class="fas fa-ban"></i>
                                                            </button>
                                                        </c:if>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state" id="emptyState">
                            <div class="empty-state-icon">
                                <i class="fas fa-search"></i>
                            </div>
                            <h3>탐지 결과가 없습니다</h3>
                            <p>스캔 작업 페이지에서 스캔을 실행하여 개인정보 컬럼을 탐지하세요.</p>
                            <button class="btn-primary-discovery" onclick="loadPageContent('jobs')">
                                <i class="fas fa-play"></i>
                                스캔 작업으로 이동
                            </button>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <!-- Pagination -->
        <div id="paginationWrapper">
            <c:if test="${not empty resultList}">
                <div class="panel-footer" style="padding: 12px 20px; border-top: 1px solid #e2e8f0;">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted" style="font-size: 0.85rem;">
                            전체 ${pageMaker.total} 건 중 ${pageMaker.cri.amount} 건 표시
                        </span>
                        <nav>
                            <ul class="pagination pagination-sm mb-0">
                                <c:if test="${pageMaker.prev}">
                                    <li class="page-item"><a class="page-link" href="#" onclick="goToPage(${pageMaker.startPage - 1})">&laquo;</a></li>
                                </c:if>
                                <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                                    <li class="page-item ${pageMaker.cri.pagenum == num ? 'active' : ''}">
                                        <a class="page-link" href="#" onclick="goToPage(${num})">${num}</a>
                                    </li>
                                </c:forEach>
                                <c:if test="${pageMaker.next}">
                                    <li class="page-item"><a class="page-link" href="#" onclick="goToPage(${pageMaker.endPage + 1})">&raquo;</a></li>
                                </c:if>
                            </ul>
                        </nav>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Detail Modal -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document" style="max-width: 1300px;">
        <div class="modal-content">
            <div class="modal-header" style="padding: 16px 24px; background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                <h5 class="modal-title" style="font-size: 1.1rem; font-weight: 600;"><i class="fas fa-info-circle text-primary"></i> 개인정보 탐지 상세</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" id="detailContent" style="padding: 24px;">
                <div class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <p class="mt-2">로딩중...</p>
                </div>
            </div>
            <div class="modal-footer" style="padding: 12px 24px; background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<style>
.progress-stats-grid {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 15px;
}
.progress-stat-item {
    text-align: center;
    padding: 10px;
    background: #f8fafc;
    border-radius: 8px;
}
.progress-stat-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1e293b;
}
.progress-stat-label {
    font-size: 0.75rem;
    color: #64748b;
    text-transform: uppercase;
    margin-top: 4px;
}
.current-table-info {
    padding: 10px 15px;
    background: #f1f5f9;
    border-radius: 6px;
    font-size: 0.875rem;
}
.current-table-info code {
    background: #e2e8f0;
    padding: 2px 8px;
    border-radius: 4px;
    margin-left: 8px;
}
.scanning-table-tag {
    display: inline-flex;
    align-items: center;
    background: linear-gradient(135deg, #fef3c7, #fde68a);
    color: #92400e;
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 0.8rem;
    font-weight: 500;
    border: 1px solid #fcd34d;
    margin: 0;
}
.table-status-waiting { color: #64748b; }
.table-status-scanning { color: #f59e0b; font-weight: 600; }
.table-status-completed { color: #10b981; }
.table-status-skipped { color: #94a3b8; }
.score-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 600;
}
.score-badge.high { background: #dcfce7; color: #166534; }
.score-badge.medium { background: #fef3c7; color: #92400e; }
.score-badge.low { background: #fee2e2; color: #991b1b; }
.status-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
}
.status-badge.pending { background: #e2e8f0; color: #475569; }
.status-badge.confirmed { background: #dcfce7; color: #166534; }
.status-badge.excluded { background: #fee2e2; color: #991b1b; }
.status-badge.not_pii { background: #f1f5f9; color: #94a3b8; }
.status-badge.running { background: #fef3c7; color: #92400e; }
.status-badge.completed { background: #dcfce7; color: #166534; }
.status-badge.failed { background: #fee2e2; color: #991b1b; }

/* Detail Modal Styles */
.detail-grid {
    display: flex;
    flex-direction: row;
    gap: 24px;
}
.detail-left {
    display: flex;
    flex-direction: row;
    gap: 24px;
    flex: 1;
}
.detail-right {
    flex: 0 0 380px;
}
.detail-section {
    background: #f8fafc;
    border-radius: 10px;
    padding: 20px;
    flex: 1;
    border: 1px solid #e2e8f0;
}
.detail-section h6 {
    color: #1e293b;
    font-weight: 600;
    margin-bottom: 16px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e2e8f0;
    font-size: 1rem;
}
.detail-section h6 i {
    margin-right: 10px;
    color: #6366f1;
}
.detail-section .table {
    margin-bottom: 0;
    background: white;
    font-size: 0.95rem;
}
.detail-section .table th {
    background: #f1f5f9;
    font-weight: 600;
    color: #475569;
    padding: 10px 14px;
    width: 110px;
    border: 1px solid #e2e8f0;
}
.detail-section .table td {
    padding: 10px 14px;
    border: 1px solid #e2e8f0;
}
.sample-data-box {
    background: #1e293b;
    border-radius: 8px;
    padding: 16px;
    font-family: 'Consolas', 'Monaco', monospace;
    font-size: 0.9rem;
    height: 100%;
    min-height: 260px;
    max-height: 320px;
    overflow-y: auto;
}
.sample-item {
    color: #e2e8f0;
    padding: 8px 0;
    border-bottom: 1px solid #334155;
    font-size: 0.9rem;
}
.sample-item:last-child {
    border-bottom: none;
}
.sample-num {
    display: inline-block;
    width: 28px;
    color: #94a3b8;
    font-weight: 500;
    text-align: right;
    margin-right: 10px;
}

/* Filter Bar Styles */
.filter-field {
    width: 120px !important;
    height: 32px !important;
    font-size: 0.85rem !important;
    border-radius: 4px !important;
}
.filter-field:focus {
    border-color: #6366f1;
    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
}
.filter-btn {
    height: 32px !important;
    padding: 0 14px !important;
    font-size: 0.85rem !important;
    border-radius: 4px !important;
    white-space: nowrap;
}
.filter-btn i {
    margin-right: 4px;
}
.action-btn {
    height: 32px !important;
    padding: 0 12px !important;
    font-size: 0.85rem !important;
    border-radius: 4px !important;
    white-space: nowrap;
}
.action-btn i {
    margin-right: 4px;
}
</style>

<script>
var contextPath = '${pageContext.request.contextPath}';
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

// i18n Messages for JavaScript
var i18nResults = {
    scanCompletedWithPii: '<spring:message code="discovery.scan_completed_with_pii" javaScriptEscape="true"/>',
    scanFailed: '<spring:message code="discovery.scan_failed_with_error" javaScriptEscape="true"/>',
    scanCancelled: '<spring:message code="discovery.scan_cancelled_msg" javaScriptEscape="true"/>',
    progressUpdated: '<spring:message code="discovery.progress_updated" javaScriptEscape="true"/>',
    cancelScan: '<spring:message code="discovery.cancel_scan" javaScriptEscape="true"/>',
    cancelInProgressScan: '<spring:message code="discovery.cancel_in_progress_scan" javaScriptEscape="true"/>',
    cancelAction: '<spring:message code="discovery.cancel_action" javaScriptEscape="true"/>',
    scanCancelledSuccess: '<spring:message code="discovery.scan_cancelled" javaScriptEscape="true"/>',
    cancelScanError: '<spring:message code="discovery.cancel_scan_error" javaScriptEscape="true"/>',
    resumeScan: '<spring:message code="discovery.resume_scan" text="스캔 재시작" javaScriptEscape="true"/>',
    resumeScanConfirm: '<spring:message code="discovery.resume_scan_confirm" text="완료된 테이블은 건너뛰고 이어서 실행하시겠습니까?" javaScriptEscape="true"/>',
    resumeAction: '<spring:message code="discovery.resume" text="재시작" javaScriptEscape="true"/>',
    scanResumed: '<spring:message code="discovery.scan_resumed" text="스캔이 재시작되었습니다 (완료된 테이블 스킵)" javaScriptEscape="true"/>',
    resumeScanError: '<spring:message code="discovery.resume_scan_error" text="스캔 재시작 중 오류 발생" javaScriptEscape="true"/>',
    errorLoadingResults: '<spring:message code="discovery.error_loading_results" javaScriptEscape="true"/>',
    refreshComplete: '<spring:message code="discovery.refresh_complete" javaScriptEscape="true"/>',
    confirmAsPii: '<spring:message code="discovery.confirm_as_pii_status" javaScriptEscape="true"/>',
    excluded: '<spring:message code="discovery.excluded_status" javaScriptEscape="true"/>',
    confirmPii: '<spring:message code="discovery.confirm_pii" javaScriptEscape="true"/>',
    markFalsePositive: '<spring:message code="discovery.mark_false_positive" javaScriptEscape="true"/>',
    itemsToConfirm: '<spring:message code="discovery.items_to_confirm" javaScriptEscape="true"/>'
};

// 현재 실행 ID (URL 파라미터에서 가져옴)
var paramExecutionId = '${param.executionId}';
var currentExecutionId = (paramExecutionId && paramExecutionId.trim() !== '') ? paramExecutionId : null;
var progressInterval = null;
var isTableListExpanded = false;
var completionHandled = false;  // 완료 처리 중복 방지 플래그

console.log('[Results] Initialized with executionId:', currentExecutionId);

$(document).ready(function() {
    // 기본 필터값 설정: Pending(PII)
    $('#filterStatus').val('PENDING');

    // 필터 이벤트 바인딩
    $('#filterExecution, #filterPiiType, #filterScore, #filterStatus, #filterDb').change(applyFilters);
    $('#filterSchema, #filterTable, #filterColumn').keypress(function(e) { if (e.which === 13) applyFilters(); });

    // Execution 목록 로드
    loadExecutionList();

    // Database 목록 로드
    loadDatabaseList();

    // executionId가 있으면 진행 상황 모니터링 시작
    if (currentExecutionId) {
        $('#filterExecution').val(currentExecutionId);
        startProgressMonitoring();
    }

    updateSelection();
});

function loadDatabaseList() {
    $.get(contextPath + '/piidiscovery/api/databases', function(databases) {
        var html = '<option value="">데이터베이스</option>';
        if (databases && databases.length > 0) {
            databases.forEach(function(db) {
                html += '<option value="' + db.db + '">' + db.db + '</option>';
            });
        }
        $('#filterDb').html(html);
    });
}

// ========== Execution Progress ==========
// 날짜에서 초 제거 (yyyy-MM-dd HH:mm:ss → yyyy-MM-dd HH:mm)
function formatDateNoSeconds(dateStr) {
    if (!dateStr) return '알 수 없음';
    // "2025-02-14 10:30:45" → "2025-02-14 10:30"
    return dateStr.replace(/:\d{2}$/, '');
}

function loadExecutionList() {
    $.get(contextPath + '/piidiscovery/api/executions', function(response) {
        var html = '<option value="">실행 이력</option>';
        // API 응답 형식: {executions: [...], total: n}
        var executions = response.executions || response;
        if (executions && executions.length > 0) {
            executions.forEach(function(exec) {
                var selected = (currentExecutionId === exec.executionId) ? ' selected' : '';
                var statusIcon = exec.status === 'RUNNING' ? ' (진행중)' : '';
                var displayDate = formatDateNoSeconds(exec.startTime);
                var jobLabel = exec.jobName ? '[' + exec.jobName + '] ' : '';
                html += '<option value="' + exec.executionId + '"' + selected + '>' +
                        jobLabel + displayDate + ' - ' + translateStatus(exec.status) + statusIcon + '</option>';
            });
        }
        $('#filterExecution').html(html);

        // currentExecutionId가 있으면 명시적으로 선택
        if (currentExecutionId) {
            $('#filterExecution').val(currentExecutionId);
            // Progress API로 실시간 상태를 확인 (DB 상태보다 정확)
            checkAndShowProgress(currentExecutionId);
            loadResults();
        }
        // currentExecutionId가 없으면 가장 최근(RUNNING 우선, 없으면 첫번째) 선택
        else if (executions && executions.length > 0) {
            var runningExec = executions.find(function(e) { return e.status === 'RUNNING'; });
            var latestExec = runningExec || executions[0];
            if (latestExec) {
                currentExecutionId = latestExec.executionId;
                $('#filterExecution').val(currentExecutionId);
                // Progress API로 실시간 상태를 확인 (DB 상태보다 정확)
                checkAndShowProgress(currentExecutionId);
                loadResults();
            }
        }
    });
}

// 완료된 상태에서 통계만 한 번 로드 (반복 갱신 없음)
function loadProgressStats() {
    if (!currentExecutionId) return;

    $.ajax({
        url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/progress',
        type: 'GET',
        success: function(progress) {
            if (!progress) return;

            // 통계만 업데이트
            $('#statProgress').text((progress.progress || 0) + '%');
            $('#statTotalTables').text(progress.totalTables || 0);
            $('#statScannedTables').text(progress.scannedTables || 0);
            $('#statColumns').text(progress.scannedColumns || 0);
            $('#statPiiCount').text(progress.piiCount || 0);
            $('#statElapsed').text(formatDuration(progress.elapsedSeconds || 0));
            $('#statRemaining').text('-');

            // 프로그레스 바 (완료 상태)
            $('#mainProgressBar')
                .css('width', (progress.progress || 0) + '%')
                .removeClass('progress-bar-animated')
                .css('background', '#10b981');
        }
    });
}

// Progress Panel 표시 (상태에 따라 일부 영역 숨김)
// Progress API로 실시간 상태 확인 후 적절한 패널 표시
function checkAndShowProgress(executionId) {
    $.ajax({
        url: contextPath + '/piidiscovery/api/executions/' + executionId + '/progress',
        type: 'GET',
        success: function(progress) {
            if (!progress) return;
            var realStatus = progress.status || 'UNKNOWN';
            showProgressPanel(realStatus);
            updateProgressDisplay(progress);
            if (realStatus === 'RUNNING' || realStatus === 'PENDING') {
                startProgressMonitoring();
            }
        },
        error: function() {
            // Progress API 실패 시 패널 숨김
            $('#executionProgressPanel').hide();
        }
    });
}

// Progress 통계 표시 업데이트 (완료 상태에서 수치 반영)
function updateProgressDisplay(progress) {
    $('#statProgress').text((progress.progress || 0) + '%');
    $('#statTotalTables').text(progress.totalTables || 0);
    $('#statScannedTables').text(progress.scannedTables || 0);
    $('#statColumns').text(progress.scannedColumns || 0);
    $('#statPiiCount').text(progress.piiCount || 0);
    $('#statElapsed').text(formatDuration(progress.elapsedSeconds || 0));
    $('#statRemaining').text(progress.estimatedRemaining || '-');
    $('#mainProgressBar').css('width', (progress.progress || 0) + '%');

    var status = progress.status || 'UNKNOWN';
    $('#executionStatus').text(translateStatus(status))
        .removeClass('badge-primary badge-success badge-danger badge-warning')
        .addClass(status === 'COMPLETED' ? 'badge-success' :
                 status === 'FAILED' ? 'badge-danger' :
                 status === 'RUNNING' ? 'badge-warning' : 'badge-primary');

    if (status === 'COMPLETED') {
        $('#mainProgressBar').removeClass('progress-bar-animated').css('background', '#10b981');
    } else if (status === 'FAILED') {
        $('#mainProgressBar').removeClass('progress-bar-animated').css('background', '#ef4444');
    }
}

function showProgressPanel(status) {
    $('#executionProgressPanel').show();

    if (status === 'COMPLETED' || status === 'FAILED' || status === 'CANCELLED') {
        // 완료된 상태면 불필요한 영역 숨김
        $('.current-table-info').hide();
        $('#tableScanStatusPanel').hide();
        $('#scanningIcon').removeClass('fa-spin');
        $('#btnCancelScan').hide();
        $('#btnRefreshProgress').hide();
        // FAILED/CANCELLED일 때 Resume 버튼 표시
        if (status === 'FAILED' || status === 'CANCELLED') {
            $('#btnResumeScan').show();
        } else {
            $('#btnResumeScan').hide();
        }
    } else {
        // RUNNING 상태면 모든 영역 표시
        $('.current-table-info').show();
        $('#tableScanStatusPanel').show();
        $('#btnCancelScan').show();
        $('#btnRefreshProgress').show();
        $('#btnResumeScan').hide();
    }
}

function startProgressMonitoring() {
    if (!currentExecutionId) return;

    // showProgressPanel이 이미 호출되었으므로 여기서는 생략
    // RUNNING 상태에서 필요한 영역 표시
    $('.current-table-info').show();
    $('#tableScanStatusPanel').show();

    // 즉시 한 번 업데이트
    updateProgress();

    // 2초마다 업데이트
    progressInterval = setInterval(updateProgress, 2000);
}

function updateProgress() {
    if (!currentExecutionId) return;

    $.ajax({
        url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/progress',
        type: 'GET',
        success: function(progress) {
            if (!progress) return;

            // 상태 업데이트
            var status = progress.status || 'UNKNOWN';
            $('#executionStatus').text(translateStatus(status))
                .removeClass('badge-primary badge-success badge-danger badge-warning')
                .addClass(status === 'COMPLETED' ? 'badge-success' :
                         status === 'FAILED' ? 'badge-danger' :
                         status === 'RUNNING' ? 'badge-warning' : 'badge-primary');

            // 통계 업데이트
            $('#statProgress').text((progress.progress || 0) + '%');
            $('#statTotalTables').text(progress.totalTables || 0);
            $('#statScannedTables').text(progress.scannedTables || 0);
            $('#statColumns').text(progress.scannedColumns || 0);
            $('#statPiiCount').text(progress.piiCount || 0);
            $('#statElapsed').text(formatDuration(progress.elapsedSeconds || 0));
            $('#statRemaining').text(progress.estimatedRemaining || '-');

            // 프로그레스 바
            $('#mainProgressBar').css('width', (progress.progress || 0) + '%');

            // 현재 스캔 중인 테이블들 (멀티스레드)
            updateCurrentScanningTables(progress.tableList, progress.threadCount);

            // 테이블 상태 목록 업데이트
            updateTableStatusList(progress.tableList);

            // 완료/실패/취소 시 처리
            if (status === 'COMPLETED' || status === 'FAILED' || status === 'CANCELLED') {
                stopProgressMonitoring();
                $('#scanningIcon').removeClass('fa-spin');
                $('#btnCancelScan').hide();
                $('#btnRefreshProgress').hide();
                // Currently scanning 영역과 Table Scan Status 숨김
                $('.current-table-info').hide();
                $('#tableScanStatusPanel').hide();

                // FAILED/CANCELLED일 때 Resume 버튼 표시
                if (status === 'FAILED' || status === 'CANCELLED') {
                    $('#btnResumeScan').show();
                } else {
                    $('#btnResumeScan').hide();
                }

                // 완료 처리는 한 번만 실행
                if (!completionHandled) {
                    completionHandled = true;

                    if (status === 'COMPLETED') {
                        $('#mainProgressBar').removeClass('progress-bar-animated').css('background', '#10b981');
                        showToast('success', i18nResults.scanCompletedWithPii.replace('{0}', progress.piiCount || 0));
                        // 결과 테이블 새로고침
                        console.log('[Results] Scan completed, refreshing results...');
                        loadResults();
                    } else if (status === 'FAILED') {
                        $('#mainProgressBar').removeClass('progress-bar-animated').css('background', '#ef4444');
                        showToast('error', i18nResults.scanFailed + ': ' + (progress.errorMsg || '알 수 없는 오류'));
                    } else if (status === 'CANCELLED') {
                        showToast('warning', i18nResults.scanCancelled);
                    }
                }
            }
        },
        error: function() {
            console.log('Progress update failed');
        }
    });
}

function updateCurrentScanningTables(tableList, threadCount) {
    $('#scanningThreadCount').text(threadCount || 0);

    if (!tableList || tableList.length === 0) {
        $('#currentScanningTables').html('<code class="scanning-table-tag">-</code>');
        return;
    }

    // SCANNING 상태인 테이블만 필터링
    var scanningTables = tableList.filter(function(t) {
        return t.status === 'SCANNING';
    });

    if (scanningTables.length === 0) {
        $('#currentScanningTables').html('<code class="scanning-table-tag text-muted">대기중...</code>');
        return;
    }

    var html = '';
    scanningTables.forEach(function(table) {
        var fullName = table.schema ? table.schema + '.' + table.tableName : table.tableName;
        html += '<code class="scanning-table-tag"><i class="fas fa-sync-alt fa-spin me-1"></i>' + fullName + '</code>';
    });

    $('#currentScanningTables').html(html);
}

function updateTableStatusList(tableList) {
    if (!tableList || tableList.length === 0) return;

    $('#tableStatusCount').text(tableList.length + ' 테이블');

    var html = '';
    tableList.forEach(function(table, idx) {
        var statusClass = 'table-status-' + (table.status || 'waiting').toLowerCase();
        var statusText = translateStatus(table.status || 'WAITING');
        var statusIcon = '';

        if (table.status === 'SCANNING') {
            statusIcon = '<i class="fas fa-sync-alt fa-spin me-1"></i>';
        } else if (table.status === 'COMPLETED') {
            statusIcon = '<i class="fas fa-check me-1"></i>';
        } else if (table.status === 'SKIPPED') {
            statusIcon = '<i class="fas fa-minus me-1"></i>';
        }

        html += '<tr>';
        html += '<td>' + (idx + 1) + '</td>';
        html += '<td>' + (table.schema || '-') + '</td>';
        html += '<td><strong>' + (table.tableName || '-') + '</strong></td>';
        html += '<td>' + (table.columnCount || '-') + '</td>';
        html += '<td>' + (table.piiCount > 0 ? '<span class="text-danger">' + table.piiCount + '</span>' : '-') + '</td>';
        html += '<td>' + (table.scanTime ? formatDuration(Math.floor(table.scanTime / 1000)) : '-') + '</td>';
        html += '<td class="' + statusClass + '">' + statusIcon + statusText + '</td>';
        html += '</tr>';
    });

    $('#tableStatusBody').html(html);
}

function stopProgressMonitoring() {
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
}

function refreshProgress() {
    updateProgress();
    showToast('info', i18nResults.progressUpdated);
}

function cancelCurrentScan() {
    if (!currentExecutionId) return;

    showConfirmModal({
        type: 'warning',
        title: i18nResults.cancelScan,
        message: i18nResults.cancelInProgressScan,
        confirmText: i18nResults.cancelAction
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/cancel',
            type: 'POST',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', i18nResults.scanCancelledSuccess);
                }
            },
            error: function() {
                showToast('error', i18nResults.cancelScanError);
            }
        });
    });
}

function resumeCurrentScan() {
    if (!currentExecutionId) return;

    showConfirmModal({
        type: 'info',
        title: i18nResults.resumeScan || '이어서 실행',
        message: i18nResults.resumeScanConfirm || '완료된 테이블은 건너뛰고 이어서 실행하시겠습니까?',
        confirmText: i18nResults.resumeAction || '이어서 실행'
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/resume',
            type: 'POST',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', i18nResults.scanResumed || '스캔이 재시작되었습니다 (완료된 테이블 스킵)');
                    $('#btnResumeScan').hide();
                    completionHandled = false;
                    // Progress 모니터링 재시작
                    showProgressPanel('RUNNING');
                    startProgressMonitoring();
                } else {
                    showToast('warning', response.message);
                }
            },
            error: function(xhr) {
                var msg = i18nResults.resumeScanError || '스캔 재시작 중 오류 발생';
                if (xhr.responseJSON && xhr.responseJSON.message) {
                    msg = xhr.responseJSON.message;
                }
                showToast('error', msg);
            }
        });
    });
}

function toggleTableList() {
    isTableListExpanded = !isTableListExpanded;
    $('#tableListBody').slideToggle(200);
    $('#tableListToggleIcon').toggleClass('fa-chevron-down fa-chevron-up');
}

// ========== Filter & Load ==========
function applyFilters() {
    var executionId = $('#filterExecution').val();

    // Execution이 변경되면 진행 모니터링 업데이트
    if (executionId !== currentExecutionId) {
        stopProgressMonitoring();
        currentExecutionId = executionId;

        if (executionId) {
            startProgressMonitoring();
        } else {
            $('#executionProgressPanel').hide();
            $('#tableScanStatusPanel').hide();
        }
    }

    loadResults();
}

function clearFilters() {
    $('#filterExecution').val('');
    $('#filterPiiType').val('');
    $('#filterScore').val('');
    $('#filterStatus').val('');
    $('#filterDb').val('');
    $('#filterSchema').val('');
    $('#filterTable').val('');
    $('#filterColumn').val('');
    currentExecutionId = null;
    stopProgressMonitoring();
    $('#executionProgressPanel').hide();
    $('#tableScanStatusPanel').hide();
    loadResults();
}

function loadResults() {
    var execId = $('#filterExecution').val() || currentExecutionId;
    var params = {
        pageNum: 1,  // 필터 변경 시 항상 1페이지로
        executionId: execId,
        search3: $('#filterPiiType').val(),
        search5: $('#filterScore').val(),
        search4: $('#filterStatus').val(),
        search1: $('#filterDb').val(),
        search2: $('#filterSchema').val(),
        filterTable: $('#filterTable').val(),
        filterColumn: $('#filterColumn').val()
    };

    console.log('[Results] Loading results with params:', params);

    $('#resultsTableWrapper').css('opacity', '0.5');

    $.ajax({
        url: contextPath + '/piidiscovery/results',
        type: 'GET',
        data: params,
        success: function(html) {
            console.log('[Results] Received response, length:', html.length);

            // HTML을 파싱하여 필요한 부분 추출
            var $html = $('<div>').html(html);
            var $table = $html.find('#resultsTable');
            var $empty = $html.find('#emptyState');
            var $pagination = $html.find('#paginationWrapper');
            var $totalCountElem = $html.find('#totalCount');
            var totalCount = $totalCountElem.length > 0 ? $totalCountElem.text() : '0';

            console.log('[Results] Found table:', $table.length > 0, ', empty:', $empty.length > 0, ', total:', totalCount);

            if ($table.length > 0) {
                $('#resultsTableWrapper').html($table);
                $('#totalCount').text(totalCount);
            } else if ($empty.length > 0) {
                $('#resultsTableWrapper').html($empty);
                $('#totalCount').text('0');
            } else {
                // 둘 다 없으면 전체 content 영역 사용
                var $resultsContent = $html.find('#resultsTableWrapper');
                if ($resultsContent.length > 0) {
                    $('#resultsTableWrapper').html($resultsContent.html());
                }
            }

            // 페이징 영역 갱신
            if ($pagination.length > 0) {
                $('#paginationWrapper').html($pagination.html());
            } else {
                $('#paginationWrapper').empty();
            }

            $('#resultsTableWrapper').css('opacity', '1');
            updateSelection();
        },
        error: function(xhr, status, error) {
            console.error('[Results] Error loading results:', error);
            $('#resultsTableWrapper').css('opacity', '1');
            showToast('error', i18nResults.errorLoadingResults);
        }
    });
}

function refreshAll() {
    if (currentExecutionId) {
        updateProgress();
    }
    loadResults();
    showToast('success', i18nResults.refreshComplete);
}

function goToPage(page) {
    var params = {
        pageNum: page,
        executionId: $('#filterExecution').val(),
        search3: $('#filterPiiType').val(),
        search5: $('#filterScore').val(),
        search4: $('#filterStatus').val(),
        search1: $('#filterDb').val(),
        search2: $('#filterSchema').val(),
        filterTable: $('#filterTable').val(),
        filterColumn: $('#filterColumn').val()
    };
    loadPageContent('results', params);
}

// ========== Selection ==========
function toggleSelectAll() {
    var isChecked = $('#selectAll').is(':checked');
    $('.result-checkbox').prop('checked', isChecked);
    updateSelection();
}

function updateSelection() {
    var checkedCount = $('.result-checkbox:checked').length;
    $('#selectedNum').text(checkedCount);
    $('#selectedCount').toggle(checkedCount > 0);
    $('#btnConfirmSelected, #btnExcludeSelected').prop('disabled', checkedCount === 0);
}

// ========== Actions ==========
function confirmSingle(resultId, status) {
    $.ajax({
        url: contextPath + '/piidiscovery/api/results/' + resultId + '/confirm?status=' + status,
        type: 'POST',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: function(response) {
            if (response.success) {
                showToast('success', status === 'CONFIRMED' ? i18nResults.confirmAsPii : i18nResults.excluded);
                var $row = $('tr[data-id="' + resultId + '"]');
                $row.data('status', status);
                $row.find('.status-badge').removeClass('pending confirmed excluded').addClass(status.toLowerCase()).text(translateStatus(status));
                updateSelection();
            } else {
                showToast('error', response.message || '실패');
            }
        }
    });
}

function confirmSelected(status) {
    var selectedIds = [];
    $('.result-checkbox:checked').each(function() { selectedIds.push($(this).val()); });

    if (selectedIds.length === 0) return;

    var isConfirm = status === 'CONFIRMED';
    showConfirmModal({
        type: isConfirm ? 'success' : 'warning',
        title: isConfirm ? i18nResults.confirmPii : i18nResults.markFalsePositive,
        message: selectedIds.length + i18nResults.itemsToConfirm + (isConfirm ? i18nResults.confirmPii : i18nResults.markFalsePositive) + '?',
        confirmText: isConfirm ? i18nResults.confirmPii : i18nResults.markFalsePositive
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/results/confirm-batch',
            type: 'POST',
            contentType: 'application/json',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            data: JSON.stringify({ resultIds: selectedIds, status: status }),
            success: function(response) {
                if (response.success) {
                    showToast('success', response.message);
                    loadResults();
                } else {
                    showToast('error', response.message || '실패');
                }
            }
        });
    });
}

// ========== Utility ==========
function translateStatus(status) {
    var statusMap = {
        'RUNNING': '실행중', 'COMPLETED': '완료', 'FAILED': '실패',
        'CANCELLED': '취소됨', 'PENDING': '검토 대기', 'CONFIRMED': 'PII 확정',
        'EXCLUDED': '오탐 제외', 'NOT_PII': 'PII 아님',
        'SCANNING': '스캔중', 'SKIPPED': '스킵', 'WAITING': '대기중'
    };
    return statusMap[status] || status;
}

function formatDuration(seconds) {
    if (!seconds || seconds === 0) return '0s';
    if (seconds < 60) return seconds + 's';
    if (seconds < 3600) return Math.floor(seconds / 60) + 'm ' + (seconds % 60) + 's';
    var hours = Math.floor(seconds / 3600);
    var mins = Math.floor((seconds % 3600) / 60);
    return hours + 'h ' + mins + 'm';
}

function showToast(type, message) {
    var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : (type === 'warning' ? '#f59e0b' : '#3b82f6'));
    var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
    $('body').append(toast);
    setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
}

// ========== Detail Modal ==========
function showDetailModal(resultId) {
    $('#detailContent').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i><p class="mt-2">로딩중...</p></div>');
    $('#detailModal').modal('show');

    $.ajax({
        url: contextPath + '/piidiscovery/api/results/' + resultId,
        type: 'GET',
        success: function(result) {
            var html = '<div class="detail-grid">';

            // Left Section: Column Info + Detection Result
            html += '<div class="detail-left">';

            // Column Info
            html += '<div class="detail-section">';
            html += '<h6><i class="fas fa-columns"></i> 컬럼 정보</h6>';
            html += '<table class="table table-sm table-bordered">';
            html += '<tr><th>데이터베이스</th><td>' + (result.dbName || '-') + '</td></tr>';
            html += '<tr><th>스키마</th><td>' + (result.schemaName || '-') + '</td></tr>';
            html += '<tr><th>테이블</th><td><strong>' + (result.tableName || '-') + '</strong></td></tr>';
            html += '<tr><th>컬럼</th><td><code>' + (result.columnName || '-') + '</code></td></tr>';
            html += '<tr><th>데이터 타입</th><td>' + (result.dataType || '-') + '</td></tr>';
            html += '<tr><th>코멘트</th><td>' + (result.columnComment || '-') + '</td></tr>';
            html += '</table>';
            html += '</div>';

            // PII Detection Info
            html += '<div class="detail-section">';
            html += '<h6><i class="fas fa-shield-alt"></i> 탐지 결과</h6>';
            html += '<table class="table table-sm table-bordered">';
            html += '<tr><th>개인정보 유형</th><td><span class="badge badge-info">' + (result.piiTypeName || '-') + '</span></td></tr>';
            html += '<tr><th>점수</th><td><span class="score-badge ' + (result.score >= 80 ? 'high' : (result.score >= 50 ? 'medium' : 'low')) + '">' + (result.score || 0) + '%</span></td></tr>';
            html += '<tr><th>메타</th><td>' + (result.metaScore || 0) + '% ' + (result.metaMatch === 'Y' ? '<span class="badge badge-success">일치</span>' : '') + '</td></tr>';
            html += '<tr><th>패턴</th><td>' + (result.patternScore || 0) + '% ' + (result.patternMatch === 'Y' ? '<span class="badge badge-success">일치</span>' : '') + '</td></tr>';
            html += '<tr><th>규칙</th><td>' + (result.matchedRule || '-') + '</td></tr>';
            html += '<tr><th>상태</th><td><span class="status-badge ' + (result.confirmStatus || 'pending').toLowerCase() + '">' + translateStatus(result.confirmStatus || 'PENDING') + '</span></td></tr>';
            html += '</table>';
            html += '</div>';

            html += '</div>'; // end detail-left

            // Right Section: Sample Data
            html += '<div class="detail-right">';
            html += '<div class="detail-section" style="height: 100%;">';
            html += '<h6><i class="fas fa-database"></i> 샘플 데이터</h6>';
            if (result.sampleData) {
                html += '<div class="sample-data-box">';
                var samples = result.sampleData.split('\n');
                samples.forEach(function(sample, idx) {
                    if (sample.trim()) {
                        html += '<div class="sample-item"><span class="sample-num">' + (idx + 1) + '</span> ' + escapeHtml(sample) + '</div>';
                    }
                });
                html += '</div>';
            } else {
                html += '<div class="text-muted" style="padding: 20px; text-align: center;"><i class="fas fa-info-circle"></i><br>샘플 데이터 없음</div>';
            }
            html += '</div>';
            html += '</div>'; // end detail-right

            html += '</div>'; // end detail-grid

            $('#detailContent').html(html);
        },
        error: function() {
            $('#detailContent').html('<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> 상세 정보를 불러오는데 실패했습니다</div>');
        }
    });
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}

// 페이지 떠날 때 인터벌 정리
$(window).on('beforeunload', function() {
    stopProgressMonitoring();
});
</script>
