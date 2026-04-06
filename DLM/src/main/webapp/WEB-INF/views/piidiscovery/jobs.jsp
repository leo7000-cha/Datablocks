<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Scan Jobs Content -->
<div id="jobsContent">
    <!-- Filter Bar -->
    <div class="content-panel" style="margin-bottom: 20px;">
        <div class="panel-body" style="padding: 12px 20px;">
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center gap-3">
                    <select class="form-control form-control-sm" style="width: 150px;" id="filterDb">
                        <option value="">전체 데이터베이스</option>
                        <c:forEach var="db" items="${dbList}">
                            <option value="${db.db}">${db.db}</option>
                        </c:forEach>
                    </select>
                    <select class="form-control form-control-sm" style="width: 150px;" id="filterActive">
                        <option value="">전체 상태</option>
                        <option value="Y">활성</option>
                        <option value="N">비활성</option>
                    </select>
                    <input type="text" class="form-control form-control-sm" placeholder="작업명 검색..." style="width: 200px;" id="filterKeyword">
                </div>
                <button class="btn-primary-discovery" onclick="showNewScanModal()">
                    <i class="fas fa-plus"></i> 새 스캔 작업
                </button>
            </div>
        </div>
    </div>

    <!-- Jobs Table -->
    <div class="content-panel">
        <div class="panel-header">
            <h3 class="panel-title">스캔 작업 목록</h3>
            <span style="color: #64748b; font-size: 0.85rem;">합계: ${pageMaker.total} jobs</span>
        </div>
        <div class="panel-body" style="padding: 0;">
            <c:choose>
                <c:when test="${not empty jobList}">
                    <table class="discovery-table">
                        <thead>
                            <tr>
                                <th style="width: 40px;"><input type="checkbox" id="selectAll"></th>
                                <th>작업명</th>
                                <th>대상 데이터베이스</th>
                                <th>대상 스키마</th>
                                <th>스레드</th>
                                <th>최근 실행</th>
                                <th>실행 횟수</th>
                                <th>상태</th>
                                <th style="width: 180px;">작업</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="job" items="${jobList}">
                                <tr data-job-id="${job.jobId}">
                                    <td><input type="checkbox" class="job-checkbox" value="${job.jobId}"></td>
                                    <td>
                                        <strong>${job.jobName}</strong>
                                        <c:if test="${not empty job.description}">
                                            <br><small class="text-muted">${job.description}</small>
                                        </c:if>
                                    </td>
                                    <td>${job.targetDb}</td>
                                    <td>${job.targetSchema}</td>
                                    <td><span class="badge badge-secondary">${job.threadCount}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty job.lastExecutionStatus}">
                                                <span class="status-badge ${job.lastExecutionStatus.toLowerCase()}">
                                                    <i class="fas fa-circle"></i>
                                                    <c:choose>
                                                        <c:when test="${job.lastExecutionStatus == 'RUNNING'}">실행 중</c:when>
                                                        <c:when test="${job.lastExecutionStatus == 'COMPLETED'}">완료</c:when>
                                                        <c:when test="${job.lastExecutionStatus == 'FAILED'}">실패</c:when>
                                                        <c:when test="${job.lastExecutionStatus == 'CANCELLED'}">취소됨</c:when>
                                                        <c:when test="${job.lastExecutionStatus == 'PENDING'}">대기 중</c:when>
                                                        <c:otherwise>${job.lastExecutionStatus}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <br><small class="text-muted">${job.lastExecutionDate}</small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">${job.executionCount}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${job.isActive == 'Y'}">
                                                <span class="badge badge-success">활성</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">비활성</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <c:choose>
                                                <c:when test="${job.lastExecutionStatus == 'RUNNING'}">
                                                    <button class="btn btn-outline-primary btn-sm" title="진행 현황 보기" onclick="showProgressModal('${job.lastExecutionId}', '${job.jobName}')">
                                                        <i class="fas fa-chart-line"></i>
                                                    </button>
                                                    <button class="btn btn-outline-warning btn-sm" title="취소" onclick="cancelExecution('${job.lastExecutionId}')">
                                                        <i class="fas fa-stop"></i>
                                                    </button>
                                                </c:when>
                                                <c:when test="${job.lastExecutionStatus == 'FAILED' or job.lastExecutionStatus == 'CANCELLED'}">
                                                    <button class="btn btn-outline-info btn-sm" title="이어서 실행 (완료 테이블 건너뜀)" onclick="resumeExecution('${job.lastExecutionId}', '${job.jobName}')">
                                                        <i class="fas fa-redo"></i>
                                                    </button>
                                                    <button class="btn btn-outline-success btn-sm" title="새로 스캔 실행" onclick="executeScanJob('${job.jobId}')">
                                                        <i class="fas fa-play"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-outline-success btn-sm" title="스캔 실행" onclick="executeScanJob('${job.jobId}')">
                                                        <i class="fas fa-play"></i>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                            <button class="btn btn-outline-info btn-sm" title="실행 이력" onclick="showExecutionHistory('${job.jobId}', '${job.jobName}')">
                                                <i class="fas fa-history"></i>
                                            </button>
                                            <button class="btn btn-outline-secondary btn-sm" title="수정" onclick="editJob('${job.jobId}')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button class="btn btn-outline-danger btn-sm" title="삭제" onclick="deleteScanJob('${job.jobId}')">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="fas fa-play-circle"></i>
                        </div>
                        <h3>스캔 작업이 없습니다</h3>
                        <p>새 스캔 작업을 생성하여 데이터베이스의 개인정보를 탐지하세요.</p>
                        <button class="btn-primary-discovery" onclick="showNewScanModal()">
                            <i class="fas fa-plus"></i>
                            스캔 작업 생성
                        </button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Execution History Modal -->
<div class="modal fade" id="executionHistoryModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-history"></i> 실행 이력: <span id="historyJobName"></span></h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" id="executionHistoryContent">
                <div class="text-center py-4">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <p class="mt-2">실행 이력 로딩 중...</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<!-- Progress Modal -->
<div class="modal fade" id="progressModal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-chart-line"></i> 스캔 진행: <span id="progressJobName"></span></h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" id="progressContent">
                <div class="progress-container">
                    <div class="progress-stats">
                        <div class="stat-item">
                            <span class="stat-label">상태</span>
                            <span class="stat-value" id="progressStatus">-</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">진행률</span>
                            <span class="stat-value" id="progressPercent">0%</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">테이블</span>
                            <span class="stat-value"><span id="progressScannedTables">0</span> / <span id="progressTotalTables">0</span></span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">탐지된 개인정보</span>
                            <span class="stat-value text-danger" id="progressPiiCount">0</span>
                        </div>
                    </div>
                    <div class="progress" style="height: 20px; margin: 20px 0;">
                        <div class="progress-bar bg-primary progress-bar-striped progress-bar-animated" id="progressBar" style="width: 0%"></div>
                    </div>
                    <div class="progress-details">
                        <p><strong>현재 테이블:</strong> <span id="progressCurrentTable">-</span></p>
                        <p><strong>경과 시간:</strong> <span id="progressElapsed">-</span></p>
                        <p id="progressRemainingRow"><strong>예상 잔여:</strong> <span id="progressRemaining">-</span></p>
                        <p><strong>컬럼:</strong> 전체 <span id="progressTotalCols">0</span> / 스캔 <span id="progressScannedCols">0</span> / 제외 <span id="progressExcludedCols">0</span></p>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-info" id="resumeScanBtn" style="display:none;" onclick="resumeCurrentExecution()">
                    <i class="fas fa-redo"></i> 스캔 이어서 실행
                </button>
                <button type="button" class="btn btn-warning" id="cancelScanBtn" onclick="cancelCurrentExecution()">
                    <i class="fas fa-stop"></i> 스캔 취소
                </button>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<style>
.progress-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-bottom: 20px;
}
.stat-item {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    text-align: center;
}
.stat-label {
    display: block;
    font-size: 0.75rem;
    color: #6c757d;
    text-transform: uppercase;
    margin-bottom: 5px;
}
.stat-value {
    font-size: 1.25rem;
    font-weight: 600;
    color: #1e293b;
}
.progress-details {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    font-size: 0.875rem;
}
.progress-details p {
    margin-bottom: 5px;
}
</style>

<script>
var currentExecutionId = null;
var progressInterval = null;
var contextPath = '${pageContext.request.contextPath}';
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

// i18n Messages for JavaScript
var i18nJobs = {
    runScan: '<spring:message code="discovery.run_scan" text="스캔 실행" javaScriptEscape="true"/>',
    runScanConfirm: '<spring:message code="discovery.run_scan_confirm" text="이 작업의 스캔을 실행하시겠습니까?" javaScriptEscape="true"/>',
    execute: '<spring:message code="discovery.execute" text="실행" javaScriptEscape="true"/>',
    scanStarted: '<spring:message code="discovery.scan_started" text="스캔이 시작되었습니다. 결과 화면으로 이동합니다." javaScriptEscape="true"/>',
    scanStartFailed: '<spring:message code="discovery.scan_start_failed" text="스캔 시작 실패" javaScriptEscape="true"/>',
    scanStartError: '<spring:message code="discovery.scan_start_error" text="스캔 시작 중 오류 발생" javaScriptEscape="true"/>',
    jobLoadFailed: '<spring:message code="discovery.job_load_failed" text="작업 정보를 불러올 수 없습니다" javaScriptEscape="true"/>',
    jobLoadError: '<spring:message code="discovery.job_load_error" text="작업 정보를 불러오는 중 오류 발생" javaScriptEscape="true"/>',
    deleteJob: '<spring:message code="discovery.delete_job" text="스캔 작업 삭제" javaScriptEscape="true"/>',
    deleteJobConfirm: '<spring:message code="discovery.delete_job_confirm" text="이 스캔 작업을 삭제하시겠습니까?" javaScriptEscape="true"/>',
    deleteJobWarning: '<spring:message code="discovery.delete_job_warning" text="• 작업 설정이 삭제됩니다\\n• 모든 실행 이력이 삭제됩니다" javaScriptEscape="true"/>',
    delete_: '<spring:message code="discovery.delete" text="삭제" javaScriptEscape="true"/>',
    finalConfirm: '<spring:message code="discovery.final_confirm" text="최종 확인" javaScriptEscape="true"/>',
    deleteConfirmFinal: '<spring:message code="discovery.delete_confirm_final" text="정말 삭제하시겠습니까?\\n이 작업은 되돌릴 수 없습니다." javaScriptEscape="true"/>',
    deleteConfirmBtn: '<spring:message code="discovery.delete_confirm_btn" text="삭제 확인" javaScriptEscape="true"/>',
    jobDeleted: '<spring:message code="discovery.job_deleted" text="작업이 삭제되었습니다" javaScriptEscape="true"/>',
    deleteFailed: '<spring:message code="discovery.delete_failed" text="삭제 실패" javaScriptEscape="true"/>',
    deleteError: '<spring:message code="discovery.delete_error" text="삭제 중 오류 발생" javaScriptEscape="true"/>',
    cancelScan: '<spring:message code="discovery.cancel_scan" text="스캔 취소" javaScriptEscape="true"/>',
    cancelScanConfirm: '<spring:message code="discovery.cancel_scan_confirm" text="스캔을 취소하시겠습니까?" javaScriptEscape="true"/>',
    cancel: '<spring:message code="discovery.cancel" text="취소" javaScriptEscape="true"/>',
    scanCancelled: '<spring:message code="discovery.scan_cancelled" text="스캔이 취소되었습니다" javaScriptEscape="true"/>',
    cancelScanError: '<spring:message code="discovery.cancel_scan_error" text="스캔 취소 중 오류 발생" javaScriptEscape="true"/>',
    scanComplete: '<spring:message code="discovery.scan_complete" text="스캔이 완료되었습니다" javaScriptEscape="true"/>',
    scanFailed: '<spring:message code="discovery.scan_failed" text="스캔이 실패했습니다" javaScriptEscape="true"/>',
    resumeScan: '<spring:message code="discovery.resume_scan" text="스캔 재시작" javaScriptEscape="true"/>',
    resumeScanConfirm: '<spring:message code="discovery.resume_scan_confirm" text="완료된 테이블은 건너뛰고 이어서 실행하시겠습니까?" javaScriptEscape="true"/>',
    resume: '<spring:message code="discovery.resume" text="재시작" javaScriptEscape="true"/>',
    scanResumed: '<spring:message code="discovery.scan_resumed" text="스캔이 재시작되었습니다 (완료된 테이블 스킵)" javaScriptEscape="true"/>',
    resumeScanError: '<spring:message code="discovery.resume_scan_error" text="스캔 재시작 중 오류 발생" javaScriptEscape="true"/>',
    noExecutionHistory: '<spring:message code="discovery.no_execution_history" text="실행 이력이 없습니다" javaScriptEscape="true"/>',
    executionHistoryError: '<spring:message code="discovery.execution_history_error" text="실행 이력을 불러오는 중 오류가 발생했습니다" javaScriptEscape="true"/>'
};

$(document).ready(function() {
    // Select all checkbox
    $('#selectAll').change(function() {
        $('.job-checkbox').prop('checked', $(this).is(':checked'));
    });

    // Filter handlers
    $('#filterDb, #filterActive').change(function() {
        applyFilters();
    });

    $('#filterKeyword').on('keyup', debounce(function() {
        applyFilters();
    }, 500));
});

function debounce(func, wait) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            func.apply(context, args);
        }, wait);
    };
}

function applyFilters() {
    var params = {
        search1: $('#filterDb').val(),
        search3: $('#filterActive').val(),
        keyword: $('#filterKeyword').val()
    };
    loadPageContent('jobs', params);
}

function showToast(type, message) {
    var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : '#f59e0b');
    var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
    $('body').append(toast);
    setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
}

// ========== Run Scan ==========
function executeScanJob(jobId) {
    showConfirmModal({
        type: 'confirm',
        title: i18nJobs.runScan,
        message: i18nJobs.runScanConfirm,
        confirmText: i18nJobs.execute
    }).then(function(confirmed) {
        if (!confirmed) return;

        var $btn = $('tr[data-job-id="' + jobId + '"] .btn-outline-success');
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>');

        $.ajax({
            url: contextPath + '/piidiscovery/api/jobs/' + jobId + '/execute',
            type: 'POST',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                }
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', i18nJobs.scanStarted);
                    // Navigate to results page with execution ID
                    if (typeof navigateToResults === 'function') {
                        navigateToResults(response.executionId);
                    } else {
                        // Fallback - try parent window
                        if (window.parent && typeof window.parent.navigateToResults === 'function') {
                            window.parent.navigateToResults(response.executionId);
                        } else {
                            // Navigate via nav-link click with execution parameter
                            $('.nav-link[data-page="results"]').data('executionId', response.executionId).click();
                        }
                    }
                } else {
                    showToast('error', i18nJobs.scanStartFailed + ': ' + (response.message || '알 수 없는 오류'));
                    $btn.prop('disabled', false).html('<i class="fas fa-play"></i>');
                }
            },
            error: function(xhr) {
                showToast('error', i18nJobs.scanStartError);
                $btn.prop('disabled', false).html('<i class="fas fa-play"></i>');
            }
        });
    });
}

// ========== Edit Job ==========
function editJob(jobId) {
    $.ajax({
        url: contextPath + '/piidiscovery/api/jobs/' + jobId,
        type: 'GET',
        success: function(job) {
            if (!job || !job.jobId) {
                showToast('error', i18nJobs.jobLoadFailed);
                return;
            }

            // First load database list, then populate form
            $.ajax({
                url: contextPath + '/piidiscovery/api/databases',
                type: 'GET',
                success: function(dbList) {
                    var $targetDb = $('#targetDb');
                    $targetDb.empty().append('<option value="">데이터베이스 선택...</option>');
                    if (dbList && dbList.length > 0) {
                        dbList.forEach(function(db) {
                            $targetDb.append('<option value="' + db.db + '">' + db.db + ' (' + db.dbtype + ')</option>');
                        });
                    }

                    // Populate form with job data
                    $('#jobName').val(job.jobName);
                    $targetDb.val(job.targetDb);
                    $('#targetTables').val(job.targetTables || '*');
                    $('#sampleSize').val(job.sampleSize || 1000);
                    $('#threadCount').val(job.threadCount || 5);

                    // Scan mode
                    if (job.scanMode === 'NEW') {
                        $('#scanModeSelect').val('New');
                        $('#scanModeNew').prop('checked', true);
                    } else {
                        $('#scanModeSelect').val('Full');
                        $('#scanModeFull').prop('checked', true);
                    }
                    if (typeof toggleSkipConfirmedOption === 'function') {
                        toggleSkipConfirmedOption();
                    }

                    // Detection methods
                    $('#enableMeta').prop('checked', job.enableMeta === 'Y');
                    $('#enablePattern').prop('checked', job.enablePattern === 'Y');

                    // Smart filtering
                    $('#excludeDataTypes').val(job.excludeDataTypes || '');
                    $('#minColumnLength').val(job.minColumnLength || 2);
                    $('#maxColumnLength').val(job.maxColumnLength || 4000);
                    $('#excludePatterns').val(job.excludePatterns || '');
                    $('#skipConfirmedPii').prop('checked', job.skipConfirmedPii !== 'N');

                    // Load schemas for the selected DB
                    if (job.targetDb) {
                        $.ajax({
                            url: contextPath + '/piidiscovery/api/schemas/' + job.targetDb,
                            type: 'GET',
                            success: function(schemas) {
                                var html = '';
                                var selectedSchemas = job.targetSchema ? job.targetSchema.split(',') : [];
                                if (schemas && schemas.length > 0) {
                                    schemas.forEach(function(schema, index) {
                                        var isChecked = selectedSchemas.indexOf(schema) >= 0;
                                        html += '<div class="custom-control custom-checkbox" style="margin-bottom: 4px;">';
                                        html += '<input type="checkbox" class="custom-control-input schema-checkbox" id="schema_' + index + '" value="' + schema + '"' + (isChecked ? ' checked' : '') + '>';
                                        html += '<label class="custom-control-label" for="schema_' + index + '">' + schema + '</label>';
                                        html += '</div>';
                                    });
                                } else {
                                    html = '<span class="text-muted"><i class="fas fa-info-circle"></i> 스키마를 찾을 수 없습니다</span>';
                                }
                                $('#schemaListContainer').html(html);
                            }
                        });
                    }

                    // Store job ID for update
                    $('#newScanForm').data('editJobId', job.jobId);

                    // Update modal title and button, then show
                    $('.modal-title').html('<i class="fas fa-edit" style="color: var(--discovery-primary); margin-right: 10px;"></i>스캔 작업 수정');
                    $('#btnSubmitJob').html('<i class="fas fa-save"></i> 작업 수정');
                    $('#newScanModal').modal('show');
                }
            });
        },
        error: function() {
            showToast('error', i18nJobs.jobLoadError);
        }
    });
}

// ========== Delete Job ==========
function deleteScanJob(jobId) {
    // First confirmation with warning
    showConfirmModal({
        type: 'danger',
        title: i18nJobs.deleteJob,
        message: i18nJobs.deleteJobConfirm + '\n\n' + i18nJobs.deleteJobWarning,
        confirmText: i18nJobs.delete_
    }).then(function(confirmed) {
        if (!confirmed) return;

        // Second confirmation for safety
        showConfirmModal({
            type: 'danger',
            title: i18nJobs.finalConfirm,
            message: i18nJobs.deleteConfirmFinal,
            confirmText: i18nJobs.deleteConfirmBtn
        }).then(function(confirmed2) {
            if (!confirmed2) return;

            var $row = $('tr[data-job-id="' + jobId + '"]');
            $row.css('opacity', '0.5');

            $.ajax({
                url: contextPath + '/piidiscovery/api/jobs/' + jobId,
                type: 'DELETE',
                beforeSend: function(xhr) {
                    if (csrfHeader && csrfToken) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    }
                },
                success: function(response) {
                    if (response.success) {
                        showToast('success', i18nJobs.jobDeleted);
                        $row.fadeOut(300, function() {
                            $(this).remove();
                            // Check if table is empty
                            if ($('.discovery-table tbody tr').length === 0) {
                                loadPageContent('jobs');
                            }
                        });
                    } else {
                        showToast('error', i18nJobs.deleteFailed + ': ' + (response.message || '알 수 없는 오류'));
                        $row.css('opacity', '1');
                    }
                },
                error: function(xhr) {
                    showToast('error', i18nJobs.deleteError);
                    $row.css('opacity', '1');
                }
            });
        });
    });
}

// ========== Progress Modal ==========
function showProgressModal(executionId, jobName) {
    currentExecutionId = executionId;
    $('#progressJobName').text(jobName);

    // 초기화
    $('#progressStatus').text('로딩 중...').removeClass('text-success text-danger text-warning');
    $('#progressPercent').text('0%');
    $('#progressScannedTables, #progressTotalTables, #progressPiiCount').text('0');
    $('#progressCurrentTable, #progressElapsed, #progressRemaining').text('-');
    $('#progressTotalCols, #progressScannedCols, #progressExcludedCols').text('0');
    $('#progressBar').removeClass('bg-success bg-danger').addClass('bg-primary progress-bar-striped progress-bar-animated').css('width', '0%');
    $('#cancelScanBtn').hide();
    $('#resumeScanBtn').hide();
    $('#progressRemainingRow').show();

    $('#progressModal').modal('show');

    // 먼저 상태 확인 후 폴링 여부 결정
    $.get(contextPath + '/piidiscovery/api/executions/' + executionId + '/progress', function(progress) {
        if (progress.status === 'RUNNING' || progress.status === 'PENDING') {
            // 실행 중: 취소 버튼 표시, 폴링 시작
            $('#progressModal .modal-title').html('<i class="fas fa-chart-line"></i> 스캔 진행: <span id="progressJobName">' + jobName + '</span>');
            $('#cancelScanBtn').show();
            startProgressPolling();
        } else {
            // 완료/실패/취소: 결과만 표시
            $('#progressModal .modal-title').html('<i class="fas fa-info-circle"></i> 스캔 상세: <span id="progressJobName">' + jobName + '</span>');
            updateProgressDisplay(progress);
            $('#cancelScanBtn').hide();
            $('#progressRemainingRow').hide();
            $('#progressCurrentTable').text('(스캔 완료)');
        }
    });
}

function startProgressPolling() {
    if (progressInterval) clearInterval(progressInterval);

    updateProgress();
    progressInterval = setInterval(updateProgress, 2000);
}

function updateProgress() {
    if (!currentExecutionId) return;

    $.ajax({
        url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/progress',
        type: 'GET',
        success: function(progress) {
            updateProgressDisplay(progress);

            if (progress.status === 'COMPLETED' || progress.status === 'FAILED' || progress.status === 'CANCELLED') {
                clearInterval(progressInterval);
                progressInterval = null;
                $('#cancelScanBtn').hide();
                $('#progressRemainingRow').hide();

                if (progress.status === 'COMPLETED') {
                    $('#resumeScanBtn').hide();
                    $('#progressCurrentTable').text('(완료)');
                    showToast('success', i18nJobs.scanComplete);
                } else if (progress.status === 'FAILED') {
                    $('#resumeScanBtn').show();
                    $('#progressCurrentTable').text('(실패 - 이어서 실행을 클릭하세요)');
                    showToast('error', i18nJobs.scanFailed);
                } else if (progress.status === 'CANCELLED') {
                    $('#resumeScanBtn').show();
                    $('#progressCurrentTable').text('(취소됨 - 이어서 실행을 클릭하세요)');
                }

                // Refresh job list after completion
                setTimeout(function() {
                    loadPageContent('jobs');
                }, 1000);
            }
        },
        error: function() {
            console.error('Failed to get progress');
        }
    });
}

// 상태값 한글 매핑
var statusLabelMap = {
    'RUNNING': '실행 중',
    'COMPLETED': '완료',
    'FAILED': '실패',
    'CANCELLED': '취소됨',
    'PENDING': '대기 중'
};

// Progress 표시 업데이트 (실행 중/완료 공용)
function updateProgressDisplay(progress) {
    // Status
    $('#progressStatus').text(statusLabelMap[progress.status] || progress.status)
        .removeClass('text-success text-danger text-warning text-info')
        .addClass(progress.status === 'COMPLETED' ? 'text-success' :
                 progress.status === 'FAILED' ? 'text-danger' :
                 progress.status === 'CANCELLED' ? 'text-info' :
                 progress.status === 'RUNNING' ? 'text-warning' : '');

    // Progress bar
    $('#progressPercent').text(progress.progress + '%');
    $('#progressBar').css('width', progress.progress + '%');

    if (progress.status === 'COMPLETED') {
        $('#progressBar').removeClass('bg-primary progress-bar-animated progress-bar-striped').addClass('bg-success');
    } else if (progress.status === 'FAILED') {
        $('#progressBar').removeClass('bg-primary progress-bar-animated progress-bar-striped').addClass('bg-danger');
    } else if (progress.status === 'CANCELLED') {
        $('#progressBar').removeClass('bg-primary progress-bar-animated progress-bar-striped').addClass('bg-secondary');
    }

    // Tables
    $('#progressTotalTables').text(progress.totalTables || 0);
    $('#progressScannedTables').text(progress.scannedTables || 0);
    $('#progressPiiCount').text(progress.piiCount || 0);

    // Current table (실행 중일 때만 표시)
    if (progress.currentTable) {
        $('#progressCurrentTable').text(progress.currentSchema ? progress.currentSchema + '.' + progress.currentTable : progress.currentTable);
    }

    // Time
    $('#progressElapsed').text(formatDuration(progress.elapsedSeconds));
    $('#progressRemaining').text(progress.estimatedRemaining || '-');

    // Columns
    $('#progressTotalCols').text(progress.totalColumns || 0);
    $('#progressScannedCols').text(progress.scannedColumns || 0);
    $('#progressExcludedCols').text(progress.excludedColumns || 0);
}

function formatDuration(seconds) {
    if (!seconds || seconds === 0) return '0s';
    if (seconds < 60) return seconds + 's';
    if (seconds < 3600) return Math.floor(seconds / 60) + 'm ' + (seconds % 60) + 's';
    var hours = Math.floor(seconds / 3600);
    var mins = Math.floor((seconds % 3600) / 60);
    return hours + 'h ' + mins + 'm';
}

function cancelCurrentExecution() {
    if (!currentExecutionId) return;
    cancelExecution(currentExecutionId);
}

function resumeCurrentExecution() {
    if (!currentExecutionId) return;
    $('#progressModal').modal('hide');
    resumeExecution(currentExecutionId, $('#progressJobName').text());
}

function cancelExecution(executionId) {
    showConfirmModal({
        type: 'warning',
        title: i18nJobs.cancelScan,
        message: i18nJobs.cancelScanConfirm,
        confirmText: i18nJobs.cancel
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/executions/' + executionId + '/cancel',
            type: 'POST',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                }
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', i18nJobs.scanCancelled);
                    loadPageContent('jobs');
                }
            },
            error: function() {
                showToast('error', i18nJobs.cancelScanError);
            }
        });
    });
}

// ========== Resume Execution ==========
function resumeExecution(executionId, jobName) {
    showConfirmModal({
        type: 'info',
        title: i18nJobs.resumeScan,
        message: i18nJobs.resumeScanConfirm,
        confirmText: i18nJobs.resume
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/executions/' + executionId + '/resume',
            type: 'POST',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                }
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', i18nJobs.scanResumed);
                    // History 모달 닫기 (열려있으면)
                    $('#executionHistoryModal').modal('hide');
                    // Progress 모달 열기
                    showProgressModal(response.executionId, jobName);
                } else {
                    showToast('warning', response.message);
                }
            },
            error: function(xhr) {
                var msg = i18nJobs.resumeScanError;
                if (xhr.responseJSON && xhr.responseJSON.message) {
                    msg = xhr.responseJSON.message;
                }
                showToast('error', msg);
            }
        });
    });
}

// ========== Execution History ==========
function showExecutionHistory(jobId, jobName) {
    $('#historyJobName').text(jobName);
    $('#executionHistoryContent').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i><p class="mt-2">로딩 중...</p></div>');
    $('#executionHistoryModal').modal('show');

    $.ajax({
        url: contextPath + '/piidiscovery/api/jobs/' + jobId + '/executions',
        type: 'GET',
        success: function(executions) {
            var html = '';
            if (executions && executions.length > 0) {
                html = '<table class="table table-sm">';
                html += '<thead><tr><th>일시</th><th>상태</th><th>진행률</th><th>테이블</th><th>PII</th><th>소요시간</th><th>작업</th></tr></thead>';
                html += '<tbody>';
                executions.forEach(function(exec) {
                    html += '<tr>';
                    html += '<td>' + (exec.startTime || '-') + '</td>';
                    html += '<td><span class="status-badge ' + (exec.status || 'pending').toLowerCase() + '">' + (statusLabelMap[exec.status] || exec.status || '대기 중') + '</span></td>';
                    html += '<td>' + (exec.progress || 0) + '%</td>';
                    html += '<td>' + (exec.scannedTables || 0) + ' / ' + (exec.totalTables || 0) + '</td>';
                    html += '<td><span class="badge badge-danger">' + (exec.piiCount || 0) + '</span></td>';
                    html += '<td>' + formatDuration(Math.floor((exec.durationMs || 0) / 1000)) + '</td>';
                    html += '<td>';
                    if (exec.status === 'RUNNING') {
                        html += '<button class="btn btn-sm btn-outline-primary me-1" title="진행 현황 보기" onclick="showProgressModal(\'' + exec.executionId + '\', \'' + jobName + '\')"><i class="fas fa-chart-line"></i></button>';
                    }
                    if (exec.status === 'FAILED' || exec.status === 'CANCELLED') {
                        html += '<button class="btn btn-sm btn-outline-info me-1" title="이어서 실행 (완료 테이블 건너뜀)" onclick="resumeExecution(\'' + exec.executionId + '\', \'' + jobName + '\')"><i class="fas fa-redo"></i></button>';
                    }
                    if (exec.status === 'COMPLETED' && exec.piiCount > 0) {
                        html += '<button class="btn btn-sm btn-outline-success" title="결과 보기" onclick="viewExecutionResults(\'' + exec.executionId + '\')"><i class="fas fa-list-alt"></i></button>';
                    }
                    html += '</td>';
                    html += '</tr>';
                });
                html += '</tbody></table>';
            } else {
                html = '<div class="text-center py-4 text-muted"><i class="fas fa-inbox fa-2x"></i><p class="mt-2">' + i18nJobs.noExecutionHistory + '</p></div>';
            }
            $('#executionHistoryContent').html(html);
        },
        error: function() {
            $('#executionHistoryContent').html('<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> ' + i18nJobs.executionHistoryError + '</div>');
        }
    });
}

$('#progressModal').on('hidden.bs.modal', function() {
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    currentExecutionId = null;

    // 블랙아웃 방지: 모달 backdrop 완전히 제거
    setTimeout(function() {
        if ($('.modal.show').length === 0) {
            $('.modal-backdrop').remove();
            $('body').removeClass('modal-open').css('padding-right', '');
        }
    }, 100);
});

// View Results - Results 탭으로 이동하면서 해당 execution 필터링
function viewExecutionResults(executionId) {
    $('#executionHistoryModal').modal('hide');
    // Results 탭으로 이동
    if (typeof loadPageContent === 'function') {
        loadPageContent('results', { executionId: executionId });
    } else if (window.parent && typeof window.parent.loadPageContent === 'function') {
        window.parent.loadPageContent('results', { executionId: executionId });
    } else {
        // fallback: 직접 URL 이동
        window.location.href = contextPath + '/piidiscovery?page=results&executionId=' + executionId;
    }
}

// executionHistoryModal 닫힐 때도 처리
$('#executionHistoryModal').on('hidden.bs.modal', function() {
    setTimeout(function() {
        if ($('.modal.show').length === 0) {
            $('.modal-backdrop').remove();
            $('body').removeClass('modal-open').css('padding-right', '');
        }
    }, 100);
});
</script>
