<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- 개인정보 컬럼 Content -->
<div id="columnsContent">
    <!-- Tab Navigation -->
    <ul class="nav nav-tabs" style="margin-bottom: 20px; border-bottom: 2px solid #e2e8f0;">
        <li class="nav-item">
            <a class="nav-link ${currentTab != 'excluded' ? 'active' : ''}" href="javascript:void(0)" onclick="switchTab('confirmed')" style="font-weight: 600; padding: 12px 24px;">
                <i class="fas fa-check-circle text-success mr-2"></i><spring:message code="discovery.confirmed_pii"/>
                <span class="badge badge-success" style="margin-left: 8px;" id="tabConfirmedCount">${confirmedCount}</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${currentTab == 'excluded' ? 'active' : ''}" href="javascript:void(0)" onclick="switchTab('excluded')" style="font-weight: 600; padding: 12px 24px;">
                <i class="fas fa-ban text-danger mr-2"></i><spring:message code="discovery.excluded_false_positive"/>
                <span class="badge badge-danger" style="margin-left: 8px;" id="tabExcludedCount">${excludedCount}</span>
            </a>
        </li>
    </ul>

    <!-- Summary Stats (Compact Cards) -->
    <div class="summary-cards-row">
        <div class="summary-card summary-card-success">
            <div class="summary-card-icon">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="summary-card-content">
                <div class="summary-card-value" id="statConfirmed">${confirmedCount}</div>
                <div class="summary-card-label"><spring:message code="discovery.confirmed_pii"/></div>
            </div>
        </div>
        <div class="summary-card summary-card-danger">
            <div class="summary-card-icon">
                <i class="fas fa-ban"></i>
            </div>
            <div class="summary-card-content">
                <div class="summary-card-value" id="statExcluded">${excludedCount}</div>
                <div class="summary-card-label"><spring:message code="discovery.excluded_false_positive"/></div>
            </div>
        </div>
        <div class="summary-card summary-card-primary">
            <div class="summary-card-icon">
                <i class="fas fa-database"></i>
            </div>
            <div class="summary-card-content">
                <div class="summary-card-value" id="statDatabases">-</div>
                <div class="summary-card-label"><spring:message code="discovery.databases"/></div>
            </div>
        </div>
        <div class="summary-card summary-card-purple">
            <div class="summary-card-icon">
                <i class="fas fa-fingerprint"></i>
            </div>
            <div class="summary-card-content">
                <div class="summary-card-value" id="statPiiTypes">-</div>
                <div class="summary-card-label"><spring:message code="discovery.pii_types"/></div>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="content-panel" style="margin-bottom: 20px;">
        <div class="panel-body" style="padding: 16px 20px;">
            <div class="d-flex align-items-center justify-content-between flex-wrap" style="gap: 12px;">
                <!-- Search Fields -->
                <div class="d-flex align-items-center flex-wrap" style="gap: 8px;">
                    <select class="form-control form-control-sm filter-field" id="filterDb">
                        <option value="">데이터베이스</option>
                    </select>
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterSchema" placeholder="스키마 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterTable" placeholder="테이블 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="filterColumn" placeholder="컬럼 (%, _)" style="text-transform: uppercase;" title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR">
                    <select class="form-control form-control-sm filter-field" id="filterPiiType">
                        <option value="">개인정보 유형</option>
                    </select>
                    <button class="btn btn-primary btn-sm filter-btn" onclick="applyFilters()">
                        <i class="fas fa-search"></i> 검색
                    </button>
                    <button class="btn btn-outline-secondary btn-sm filter-btn" onclick="clearFilters()">
                        <i class="fas fa-redo"></i> 초기화
                    </button>
                </div>
                <!-- Action Buttons -->
                <div class="d-flex align-items-center" style="gap: 8px;">
                    <span class="text-muted" id="selectedCount" style="display: none; margin-right: 4px;">
                        <strong id="selectedNum">0</strong> <spring:message code="etc.selected" text="selected"/>
                    </span>
                    <button class="btn btn-outline-danger btn-sm action-btn" onclick="removeSelected()" id="btnRemove" disabled>
                        <i class="fas fa-trash"></i> <spring:message code="discovery.remove"/>
                    </button>
                    <button class="btn btn-outline-success btn-sm action-btn" onclick="showAddManualModal()">
                        <i class="fas fa-plus"></i> <spring:message code="discovery.add"/>
                    </button>
                    <button class="btn btn-outline-secondary btn-sm action-btn" onclick="exportRegistry()">
                        <i class="fas fa-file-excel"></i> <spring:message code="discovery.export"/>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Columns Table -->
    <div class="content-panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div>
                <h3 class="panel-title" id="tableTitle">
                    <c:choose>
                        <c:when test="${currentTab == 'excluded'}">
                            <i class="fas fa-ban text-danger mr-2"></i><spring:message code="discovery.excluded_columns"/>
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-check-circle text-success mr-2"></i><spring:message code="discovery.confirmed_pii_columns"/>
                        </c:otherwise>
                    </c:choose>
                </h3>
                <span style="color: #64748b; font-size: 0.85rem;">
                    <spring:message code="discovery.total_columns"/>: <strong id="totalCount">${pageMaker.total}</strong>
                </span>
            </div>
            <div class="d-flex align-items-center" style="gap: 8px;">
                <span class="text-muted" style="font-size: 0.85rem;">표시</span>
                <select class="form-control form-control-sm" style="width: 70px;" id="pageSize" onchange="changePageSize()">
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                    <option value="100" selected>100</option>
                </select>
            </div>
        </div>
        <div class="panel-body" style="padding: 0;">
            <div id="columnsTableWrapper">
                <c:choose>
                    <c:when test="${not empty columnList}">
                        <table class="discovery-table" id="columnsTable">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">
                                        <input type="checkbox" id="selectAll" onclick="toggleSelectAll()">
                                    </th>
                                    <th>데이터베이스</th>
                                    <th>스키마</th>
                                    <th>테이블</th>
                                    <th>컬럼</th>
                                    <th>데이터 타입</th>
                                    <th>개인정보 유형</th>
                                    <th>점수</th>
                                    <th><c:choose><c:when test="${currentTab == 'excluded'}"><spring:message code="discovery.excluded_by"/></c:when><c:otherwise><spring:message code="discovery.confirmed_by"/></c:otherwise></c:choose></th>
                                    <th><c:choose><c:when test="${currentTab == 'excluded'}"><spring:message code="discovery.excluded_date"/></c:when><c:otherwise><spring:message code="discovery.confirmed_date"/></c:otherwise></c:choose></th>
                                    <th style="width: 100px;">작업</th>
                                </tr>
                            </thead>
                            <tbody id="columnsBody">
                                <c:forEach var="col" items="${columnList}">
                                    <tr data-id="${col.registryId}">
                                        <td><input type="checkbox" class="col-checkbox" value="${col.registryId}" onclick="updateSelection()"></td>
                                        <td>${col.dbName}</td>
                                        <td>${col.schemaName}</td>
                                        <td><strong>${col.tableName}</strong></td>
                                        <td><code>${col.columnName}</code></td>
                                        <td><span class="badge badge-secondary">${col.dataType}</span></td>
                                        <td><span class="badge badge-info">${col.piiTypeName}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${col.confidenceScore != null}">
                                                    <span class="score-badge ${col.confidenceScore >= 80 ? 'high' : (col.confidenceScore >= 50 ? 'medium' : 'low')}">
                                                        ${col.confidenceScore}%
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-light">MANUAL</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><small>${col.registeredBy}</small></td>
                                        <td><small>${col.registeredDate}</small></td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <button class="btn btn-outline-info" title="상세 보기" onclick="showColumnDetail('${col.registryId}')">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <c:choose>
                                                    <c:when test="${currentTab == 'excluded'}">
                                                        <button class="btn btn-outline-danger" title="삭제" onclick="resetColumn('${col.registryId}')">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                        <button class="btn btn-outline-primary" title="PII 확정으로 변경" onclick="changeStatus('${col.registryId}', 'CONFIRMED')">
                                                            <i class="fas fa-check"></i>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn btn-outline-danger" title="삭제" onclick="resetColumn('${col.registryId}')">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                        <button class="btn btn-outline-warning" title="오탐 제외로 변경" onclick="changeStatus('${col.registryId}', 'EXCLUDED')">
                                                            <i class="fas fa-ban"></i>
                                                        </button>
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
                                <i class="fas fa-table-columns"></i>
                            </div>
                            <h3><spring:message code="discovery.no_pii_columns"/></h3>
                            <p><spring:message code="discovery.no_pii_columns_desc"/></p>
                            <div class="d-flex gap-2 justify-content-center">
                                <button class="btn-primary-discovery" onclick="loadPageContent('jobs')">
                                    <i class="fas fa-radar"></i>
                                    <spring:message code="discovery.start_discovery_scan"/>
                                </button>
                                <button class="btn btn-outline-success" onclick="showAddManualModal()">
                                    <i class="fas fa-plus mr-1"></i>
                                    <spring:message code="discovery.add"/>
                                </button>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <!-- Pagination -->
        <c:if test="${not empty columnList}">
            <div class="panel-footer" style="padding: 12px 20px; border-top: 1px solid #e2e8f0;">
                <div class="d-flex justify-content-between align-items-center">
                    <c:set var="showingFrom" value="${(pageMaker.cri.pagenum - 1) * pageMaker.cri.amount + 1}" />
                    <c:set var="showingTo" value="${pageMaker.cri.pagenum * pageMaker.cri.amount}" />
                    <c:if test="${showingTo > pageMaker.total}">
                        <c:set var="showingTo" value="${pageMaker.total}" />
                    </c:if>
                    <span class="text-muted" style="font-size: 0.85rem;">
                        <strong>${showingFrom}</strong> - <strong>${showingTo}</strong> / <strong>${pageMaker.total}</strong>
                    </span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0" id="paginationUl">
                            <c:if test="${pageMaker.prev}">
                                <li class="page-item">
                                    <a class="page-link" href="#" onclick="goToPage(${pageMaker.startPage - 1}); return false;">&laquo;</a>
                                </li>
                            </c:if>
                            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                                <li class="page-item ${pageMaker.cri.pagenum == num ? 'active' : ''}">
                                    <a class="page-link" href="#" onclick="goToPage(${num}); return false;">${num}</a>
                                </li>
                            </c:forEach>
                            <c:if test="${pageMaker.next}">
                                <li class="page-item">
                                    <a class="page-link" href="#" onclick="goToPage(${pageMaker.endPage + 1}); return false;">&raquo;</a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </div>
        </c:if>
    </div>
</div>

<!-- Add Manual PII Column Modal -->
<div class="modal fade" id="addManualModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                <h5 class="modal-title"><i class="fas fa-plus-circle text-success"></i> <spring:message code="discovery.add_pii_column"/></h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="addManualForm">
                    <div class="form-group">
                        <label>데이터베이스 <span class="text-danger">*</span></label>
                        <select class="form-control" id="manualDbName" name="dbName" required onchange="loadSchemasForManual()">
                            <option value=""><spring:message code="discovery.select_database"/>...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>스키마 <span class="text-danger">*</span></label>
                        <select class="form-control" id="manualSchemaName" name="schemaName" required>
                            <option value=""><spring:message code="discovery.select_schema"/>...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>테이블 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control text-uppercase" id="manualTableName" name="tableName" required placeholder="CUSTOMER" style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>컬럼 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control text-uppercase" id="manualColumnName" name="columnName" required placeholder="CUST_SSN" style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>데이터 타입</label>
                        <input type="text" class="form-control text-uppercase" id="manualDataType" name="dataType" placeholder="VARCHAR2(20)" style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label>개인정보 유형 <span class="text-danger">*</span></label>
                        <select class="form-control" id="manualPiiType" name="piiTypeCode" required>
                            <option value=""><spring:message code="discovery.select_pii_type"/>...</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><spring:message code="discovery.cancel"/></button>
                <button type="button" class="btn btn-primary" onclick="saveManualColumn()">
                    <i class="fas fa-plus"></i> <spring:message code="discovery.add_column"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Column Detail Modal -->
<div class="modal fade" id="columnDetailModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document" style="max-width: 1300px;">
        <div class="modal-content">
            <div class="modal-header" style="padding: 16px 24px; background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                <h5 class="modal-title" style="font-size: 1.1rem; font-weight: 600;">
                    <i class="fas fa-info-circle text-primary"></i> 개인정보 컬럼 상세
                </h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" id="columnDetailBody" style="padding: 24px;">
            </div>
            <div class="modal-footer" style="padding: 12px 24px; background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

// i18n Messages for JavaScript
var i18nCols = {
    deleteConfirm: '<spring:message code="discovery.delete_confirm" javaScriptEscape="true"/>',
    deleteFromRegistryConfirm: '<spring:message code="discovery.delete_from_registry_confirm" javaScriptEscape="true"/>',
    delete_: '<spring:message code="discovery.delete" javaScriptEscape="true"/>',
    deletedFromRegistry: '<spring:message code="discovery.deleted_from_registry" javaScriptEscape="true"/>',
    confirmPii: '<spring:message code="discovery.confirm_pii" javaScriptEscape="true"/>',
    markFalsePositive: '<spring:message code="discovery.mark_false_positive" javaScriptEscape="true"/>',
    confirmAsPii: '<spring:message code="discovery.confirm_as_pii" javaScriptEscape="true"/>',
    markAsFalsePositive: '<spring:message code="discovery.mark_as_false_positive" javaScriptEscape="true"/>',
    statusChanged: '<spring:message code="discovery.status_changed" javaScriptEscape="true"/>',
    batchDelete: '<spring:message code="discovery.batch_delete" javaScriptEscape="true"/>',
    batchDeleteConfirm: '<spring:message code="discovery.batch_delete_confirm" javaScriptEscape="true"/>',
    itemsDeleted: '<spring:message code="discovery.items_deleted" javaScriptEscape="true"/>',
    itemsDeleteFailed: '<spring:message code="discovery.items_delete_failed" javaScriptEscape="true"/>',
    metaTableSyncConfirm: '<spring:message code="discovery.meta_table_sync_confirm" javaScriptEscape="true"/>',
    syncToMetaTable: '<spring:message code="discovery.sync_to_meta_table" javaScriptEscape="true"/>',
    sync: '<spring:message code="discovery.sync" javaScriptEscape="true"/>'
};

var currentTab = '${currentTab}' || 'confirmed';
var currentFilters = {
    db: '${param.search1}' || '',
    schema: '${param.search2}' || '',
    table: '${param.filterTable}' || '',
    column: '${param.filterColumn}' || '',
    piiType: '${param.search3}' || '',
    page: parseInt('${param.pageNum}') || 1,
    amount: parseInt('${param.amount}') || 100
};

// 탭 전환
function switchTab(tab) {
    currentTab = tab;
    currentFilters.page = 1;
    var status = (tab === 'excluded') ? 'EXCLUDED' : 'CONFIRMED';
    loadPageContent('columns?search4=' + status + '&tab=' + tab);
}

$(document).ready(function() {
    loadDatabaseList();
    loadPiiTypeList();
    computeStats();

    // Input 필드에 값 복원
    $('#filterSchema').val(currentFilters.schema);
    $('#filterTable').val(currentFilters.table);
    $('#filterColumn').val(currentFilters.column);

    // Page size 복원
    $('#pageSize').val(currentFilters.amount);

    // Select 변경 시 자동 조회
    $('#filterDb, #filterPiiType').change(function() {
        applyFilters();
    });

    // Input Enter 키로 검색
    $('#filterSchema, #filterTable, #filterColumn').keypress(function(e) {
        if (e.which === 13) applyFilters();
    });
});

function loadDatabaseList() {
    $.get('${pageContext.request.contextPath}/piidiscovery/api/databases', function(dbList) {
        var html = '<option value="">데이터베이스</option>';
        var manualHtml = '<option value="">데이터베이스 선택...</option>';
        dbList.forEach(function(db) {
            var dbName = db.db || db.dbName;
            html += '<option value="' + dbName + '">' + dbName + '</option>';
            manualHtml += '<option value="' + dbName + '">' + dbName + '</option>';
        });
        $('#filterDb').html(html);
        $('#manualDbName').html(manualHtml);

        // DB 선택값 복원
        if (currentFilters.db) {
            $('#filterDb').val(currentFilters.db);
        }
    });
}

function loadPiiTypeList() {
    $.get('${pageContext.request.contextPath}/piidiscovery/api/pii-types', function(types) {
        var html = '<option value="">개인정보 유형</option>';
        var manualHtml = '<option value="">개인정보 유형 선택...</option>';
        types.forEach(function(t) {
            html += '<option value="' + t.piiTypeCode + '">' + t.piiTypeName + '</option>';
            manualHtml += '<option value="' + t.piiTypeCode + '">' + t.piiTypeName + '</option>';
        });
        $('#filterPiiType').html(html);
        $('#manualPiiType').html(manualHtml);

        // PII Type 선택값 복원
        if (currentFilters.piiType) {
            $('#filterPiiType').val(currentFilters.piiType);
        }
    });
}

function loadSchemasForManual() {
    var dbName = $('#manualDbName').val();
    if (!dbName) {
        $('#manualSchemaName').html('<option value="">스키마 선택...</option>');
        return;
    }
    $.get('${pageContext.request.contextPath}/piidiscovery/api/schemas/' + dbName, function(schemas) {
        var html = '<option value="">스키마 선택...</option>';
        schemas.forEach(function(s) {
            html += '<option value="' + s + '">' + s + '</option>';
        });
        $('#manualSchemaName').html(html);
    });
}

function computeStats() {
    // Compute unique counts from table
    var dbs = new Set();
    var tables = new Set();
    var piiTypes = new Set();

    $('#columnsTable tbody tr').each(function() {
        dbs.add($(this).find('td:eq(1)').text());
        tables.add($(this).find('td:eq(1)').text() + '.' + $(this).find('td:eq(3)').text());
        piiTypes.add($(this).find('td:eq(6) .badge').text());
    });

    $('#statDatabases').text(dbs.size || '-');
    $('#statTables').text(tables.size || '-');
    $('#statPiiTypes').text(piiTypes.size || '-');
}

function applyFilters() {
    currentFilters.db = $('#filterDb').val();
    currentFilters.schema = $('#filterSchema').val();
    currentFilters.table = $('#filterTable').val();
    currentFilters.column = $('#filterColumn').val();
    currentFilters.piiType = $('#filterPiiType').val();
    currentFilters.page = 1;
    goToPage(1);
}

function clearFilters() {
    $('#filterDb, #filterPiiType').val('');
    $('#filterSchema, #filterTable, #filterColumn').val('');
    currentFilters = { db: '', schema: '', table: '', column: '', piiType: '', page: 1, amount: currentFilters.amount };
    goToPage(1);
}

function goToPage(page) {
    currentFilters.page = page;
    var status = (currentTab === 'excluded') ? 'EXCLUDED' : 'CONFIRMED';
    loadPageContent('columns?pageNum=' + page + '&amount=' + currentFilters.amount +
        '&search1=' + encodeURIComponent(currentFilters.db) +
        '&search2=' + encodeURIComponent(currentFilters.schema) +
        '&search3=' + encodeURIComponent(currentFilters.piiType) +
        '&filterTable=' + encodeURIComponent(currentFilters.table) +
        '&filterColumn=' + encodeURIComponent(currentFilters.column) +
        '&tab=' + currentTab +
        '&search4=' + status);
}

function changePageSize() {
    currentFilters.amount = parseInt($('#pageSize').val());
    goToPage(1);
}

// ========== Selection ==========
function toggleSelectAll() {
    var isChecked = $('#selectAll').is(':checked');
    $('.col-checkbox').prop('checked', isChecked);
    updateSelection();
}

function updateSelection() {
    var count = $('.col-checkbox:checked').length;
    $('#selectedNum').text(count);
    $('#selectedCount').toggle(count > 0);
    $('#btnSyncMeta, #btnRemove').prop('disabled', count === 0);
}

// ========== Actions (Registry API) ==========

// Registry에서 삭제 (Remove) - 다음 스캔에서 다시 탐지됨
function resetColumn(registryId) {
    showConfirmModal({
        type: 'danger',
        title: i18nCols.deleteConfirm,
        message: i18nCols.deleteFromRegistryConfirm,
        confirmText: i18nCols.delete_
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: '${pageContext.request.contextPath}/piidiscovery/api/registry/' + registryId,
            type: 'DELETE',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', response.message || i18nCols.deletedFromRegistry);
                    $('tr[data-id="' + registryId + '"]').fadeOut(function() { $(this).remove(); computeStats(); });
                } else {
                    showToast('error', response.message || '삭제에 실패했습니다');
                }
            },
            error: function() {
                showToast('error', '레지스트리에서 삭제에 실패했습니다');
            }
        });
    });
}

// 상태 변경 (CONFIRMED <-> EXCLUDED)
function changeStatus(registryId, newStatus) {
    var isConfirm = newStatus === 'CONFIRMED';
    showConfirmModal({
        type: isConfirm ? 'success' : 'warning',
        title: isConfirm ? i18nCols.confirmPii : i18nCols.markFalsePositive,
        message: isConfirm ? i18nCols.confirmAsPii : i18nCols.markAsFalsePositive,
        confirmText: isConfirm ? i18nCols.confirmPii : i18nCols.markFalsePositive
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: '${pageContext.request.contextPath}/piidiscovery/api/registry/' + registryId + '/status?status=' + newStatus,
            type: 'PUT',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', response.message || i18nCols.statusChanged);
                    $('tr[data-id="' + registryId + '"]').fadeOut(function() { $(this).remove(); computeStats(); });
                } else {
                    showToast('error', response.message || '변경에 실패했습니다');
                }
            },
            error: function() {
                showToast('error', '상태 변경에 실패했습니다');
            }
        });
    });
}

// 선택한 컬럼들 삭제 (Registry에서 제거)
function removeSelected() {
    var selectedIds = [];
    $('.col-checkbox:checked').each(function() {
        selectedIds.push($(this).val());
    });

    if (selectedIds.length === 0) return;

    showConfirmModal({
        type: 'danger',
        title: i18nCols.batchDelete,
        message: selectedIds.length + i18nCols.batchDeleteConfirm,
        confirmText: i18nCols.delete_
    }).then(function(confirmed) {
        if (!confirmed) return;

        var deleteCount = 0;
        var failCount = 0;

        selectedIds.forEach(function(registryId, index) {
            $.ajax({
                url: '${pageContext.request.contextPath}/piidiscovery/api/registry/' + registryId,
                type: 'DELETE',
                async: false,
                beforeSend: function(xhr) {
                    if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function(response) {
                    if (response.success) {
                        deleteCount++;
                        $('tr[data-id="' + registryId + '"]').remove();
                    } else {
                        failCount++;
                    }
                },
                error: function() {
                    failCount++;
                }
            });
        });

        if (deleteCount > 0) {
            showToast('success', deleteCount + i18nCols.itemsDeleted);
            computeStats();
        }
        if (failCount > 0) {
            showToast('error', failCount + i18nCols.itemsDeleteFailed);
        }
    });
}

// 레거시 함수들 (호환성 유지용 - deprecated)
function unconfirmColumn(registryId) { resetColumn(registryId); }
function excludeColumn(registryId) { changeStatus(registryId, 'EXCLUDED'); }
function restoreColumn(registryId) { resetColumn(registryId); }
function confirmColumn(registryId) { changeStatus(registryId, 'CONFIRMED'); }

function exportRegistry() {
    var status = (currentTab === 'excluded') ? 'EXCLUDED' : 'CONFIRMED';
    var dbName = $('#filterDb').val() || '';
    var url = '${pageContext.request.contextPath}/piidiscovery/api/registry/export?status=' + status;
    if (dbName) {
        url += '&dbName=' + encodeURIComponent(dbName);
    }
    window.location.href = url;
}

// ========== Manual Add ==========
function showAddManualModal() {
    $('#addManualForm')[0].reset();
    $('#manualSchemaName').html('<option value="">스키마 선택...</option>');
    $('#addManualModal').modal('show');
}

function saveManualColumn() {
    var formData = {
        dbName: $('#manualDbName').val(),
        schemaName: $('#manualSchemaName').val(),
        tableName: $('#manualTableName').val().toUpperCase(),
        columnName: $('#manualColumnName').val().toUpperCase(),
        dataType: $('#manualDataType').val().toUpperCase() || 'VARCHAR2',
        piiTypeCode: $('#manualPiiType').val(),
        status: 'CONFIRMED'
    };

    if (!formData.dbName || !formData.schemaName || !formData.tableName || !formData.columnName || !formData.piiTypeCode) {
        showToast('warning', '필수 항목을 모두 입력해주세요');
        return;
    }

    $.ajax({
        url: '${pageContext.request.contextPath}/piidiscovery/api/registry',
        type: 'POST',
        contentType: 'application/json',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        data: JSON.stringify(formData),
        success: function(response) {
            if (response.success) {
                $('#addManualModal').modal('hide');
                showToast('success', '개인정보 컬럼이 레지스트리에 추가되었습니다');
                loadPageContent('columns');
            } else {
                showToast('error', response.message || '추가에 실패했습니다');
            }
        },
        error: function() {
            showToast('error', '컬럼 추가에 실패했습니다');
        }
    });
}

// ========== Detail View (Registry API) ==========
function showColumnDetail(registryId) {
    $('#columnDetailBody').html('<div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i><p class="mt-2">로딩 중...</p></div>');
    $('#columnDetailModal').modal('show');

    $.ajax({
        url: '${pageContext.request.contextPath}/piidiscovery/api/registry/' + registryId,
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

            // PII Registry Info
            html += '<div class="detail-section">';
            html += '<h6><i class="fas fa-shield-alt"></i> 레지스트리 정보</h6>';
            html += '<table class="table table-sm table-bordered">';
            html += '<tr><th>개인정보 유형</th><td><span class="badge badge-info">' + (result.piiTypeName || '-') + '</span></td></tr>';
            var score = result.confidenceScore || 0;
            var scoreClass = score >= 80 ? 'high' : (score >= 50 ? 'medium' : 'low');
            html += '<tr><th>신뢰도</th><td>' + (result.detectionMethod === 'MANUAL' ? '<span class="badge badge-light">MANUAL</span>' : '<span class="score-badge ' + scoreClass + '">' + score + '%</span>') + '</td></tr>';
            html += '<tr><th>탐지 방법</th><td><span class="badge badge-secondary">' + (result.detectionMethod || '-') + '</span></td></tr>';
            html += '<tr><th>상태</th><td><span class="status-badge ' + (result.status || 'confirmed').toLowerCase() + '">' + (result.status || 'CONFIRMED') + '</span></td></tr>';
            html += '<tr><th>등록</th><td>' + (result.registeredBy || '-') + ' / ' + (result.registeredDate || '-') + '</td></tr>';
            html += '<tr><th>최초 탐지일</th><td>' + (result.firstDetectedDate || '-') + '</td></tr>';
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
                html += '<div class="text-muted" style="padding: 20px; text-align: center;"><i class="fas fa-info-circle"></i><br>샘플 데이터가 없습니다</div>';
            }
            html += '</div>';
            html += '</div>'; // end detail-right

            html += '</div>'; // end detail-grid

            $('#columnDetailBody').html(html);
        },
        error: function() {
            $('#columnDetailBody').html('<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> 상세 정보를 불러오는데 실패했습니다</div>');
        }
    });
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}

// ========== Utility ==========
function showToast(type, message) {
    var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : (type === 'warning' ? '#f59e0b' : '#3b82f6'));
    var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
    $('body').append(toast);
    setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
}
</script>

<style>
/* Summary Cards Row */
.summary-cards-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 16px;
}
.summary-card {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    border-radius: 10px;
    background: #fff;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    border-left: 4px solid;
}
.summary-card-icon {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
}
.summary-card-content {
    display: flex;
    flex-direction: column;
}
.summary-card-value {
    font-size: 1.4rem;
    font-weight: 700;
    line-height: 1.2;
}
.summary-card-label {
    font-size: 0.75rem;
    color: #64748b;
    font-weight: 500;
}
/* Card Variants */
.summary-card-success {
    border-left-color: #22c55e;
}
.summary-card-success .summary-card-icon {
    background: #dcfce7;
    color: #16a34a;
}
.summary-card-success .summary-card-value {
    color: #16a34a;
}
.summary-card-danger {
    border-left-color: #ef4444;
}
.summary-card-danger .summary-card-icon {
    background: #fee2e2;
    color: #dc2626;
}
.summary-card-danger .summary-card-value {
    color: #dc2626;
}
.summary-card-primary {
    border-left-color: #3b82f6;
}
.summary-card-primary .summary-card-icon {
    background: #dbeafe;
    color: #2563eb;
}
.summary-card-primary .summary-card-value {
    color: #2563eb;
}
.summary-card-purple {
    border-left-color: #a855f7;
}
.summary-card-purple .summary-card-icon {
    background: #f3e8ff;
    color: #9333ea;
}
.summary-card-purple .summary-card-value {
    color: #9333ea;
}

/* Tab Styles */
.nav-tabs {
    border-bottom: 2px solid #e2e8f0;
    background: #f8fafc;
    padding: 0 10px;
    border-radius: 8px 8px 0 0;
}
.nav-tabs .nav-item {
    margin-bottom: -2px;
}
.nav-tabs .nav-link {
    color: #64748b;
    background: #f1f5f9;
    border: 1px solid #e2e8f0;
    border-bottom: none;
    border-radius: 8px 8px 0 0;
    margin-right: 4px;
    padding: 12px 24px;
    font-weight: 600;
    transition: all 0.2s;
}
.nav-tabs .nav-link:hover {
    color: #1e293b;
    background: #e2e8f0;
}
.nav-tabs .nav-link.active {
    color: #6366f1;
    background: #ffffff;
    border-color: #e2e8f0;
    border-bottom: 2px solid #ffffff;
    position: relative;
}
.nav-tabs .nav-link.active::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    right: 0;
    height: 3px;
    background: #6366f1;
    border-radius: 3px 3px 0 0;
}

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
    margin-right: 12px;
}
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

/* Filter Bar Styles */
.filter-field {
    width: 130px !important;
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
