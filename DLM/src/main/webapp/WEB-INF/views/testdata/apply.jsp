<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<c:set var="siteUpperCase" value="${fn:toUpperCase(site)}"/>

<style>
/* ============================================
   Test Data Apply Page - Modern Design
   ============================================ */

/* Header Section - Uses page-header-bar from piipolicy-refactor.css */

/* Main Content */
.testdata-content {
    padding: 16px;
}

/* Configuration Card */
.config-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.06);
    margin-bottom: 16px;
    overflow: hidden;
}

.config-card-header {
    padding: 10px 16px;
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    color: #334155;
    font-size: 0.85rem;
}

.config-card-header i {
    color: #6366f1;
}

.config-card-body {
    padding: 14px 16px;
}

.config-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
}

@media (max-width: 1200px) {
    .config-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 768px) {
    .config-grid {
        grid-template-columns: 1fr;
    }
}

.config-item {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.config-label {
    font-size: 0.7rem;
    font-weight: 600;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.config-select {
    padding: 8px 12px;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    color: #1e293b;
    background: #fff;
    transition: all 0.2s;
    cursor: pointer;
}

.config-select:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.config-select:disabled {
    background: #f8fafc;
    color: #64748b;
    cursor: not-allowed;
}

/* Workspace Area */
.workspace-area {
    display: grid;
    grid-template-columns: 380px 1fr;
    gap: 16px;
}

@media (max-width: 1024px) {
    .workspace-area {
        grid-template-columns: 1fr;
    }
}

/* Input Panel */
.input-panel {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.06);
    overflow: hidden;
}

.panel-header {
    padding: 10px 14px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    font-size: 0.85rem;
}

.panel-header.input-header {
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: #fff;
}

.panel-header.input-header i {
    color: #c7d2fe;
}

.panel-header.preview-header {
    background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);
    color: #fff;
}

.panel-header.preview-header i {
    color: #a5f3fc;
}

.panel-body {
    padding: 14px;
}

/* ID Type Selector */
.id-type-selector {
    margin-bottom: 10px;
}

.id-type-label {
    font-size: 0.7rem;
    font-weight: 600;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
    display: block;
}

.id-type-select {
    width: 100%;
    padding: 8px 12px;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    color: #1e293b;
    background: #fff;
    transition: all 0.2s;
}

.id-type-select:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

/* Textarea */
.input-textarea {
    width: 100%;
    min-height: 330px;
    padding: 12px;
    border: 2px solid #e2e8f0;
    border-radius: 10px;
    font-size: 0.85rem;
    font-family: 'Consolas', 'Monaco', monospace;
    line-height: 1.5;
    resize: none;
    transition: all 0.2s;
    color: #1e293b;
}

.input-textarea:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.input-textarea::placeholder {
    color: #94a3b8;
    font-family: inherit;
}

/* Input Help */
.input-help {
    margin-top: 10px;
    padding: 8px 12px;
    background: #f8fafc;
    border-radius: 8px;
    border-left: 3px solid #6366f1;
}

.input-help-title {
    font-size: 0.7rem;
    font-weight: 600;
    color: #6366f1;
    margin-bottom: 4px;
}

.input-help-text {
    font-size: 0.75rem;
    color: #64748b;
    line-height: 1.4;
}

/* Submit Button */
.submit-section {
    margin-top: 12px;
}

.btn-submit {
    width: 100%;
    padding: 10px 20px;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: #fff;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
}

.btn-submit:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(99, 102, 241, 0.45);
}

.btn-submit:active {
    transform: translateY(0);
}

.btn-submit i {
    font-size: 1rem;
}

/* Preview Panel */
.preview-panel {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.06);
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.preview-info {
    padding: 6px 14px;
    background: #f8fafc;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.preview-count {
    font-size: 0.75rem;
    color: #64748b;
}

.preview-count strong {
    color: #6366f1;
    font-weight: 700;
}

.preview-badge {
    padding: 3px 10px;
    background: #dbeafe;
    color: #2563eb;
    border-radius: 20px;
    font-size: 0.65rem;
    font-weight: 600;
}

/* Preview Table */
.preview-table-wrapper {
    flex: 1;
    overflow: auto;
    max-height: 500px;
}

.preview-table {
    width: 100%;
    border-collapse: collapse;
}

.preview-table thead {
    position: sticky;
    top: 0;
    z-index: 10;
}

.preview-table th {
    padding: 10px 12px;
    background: #1e293b;
    color: #fff;
    font-size: 0.75rem;
    font-weight: 600;
    text-align: left;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.preview-table th:first-child {
    text-align: center;
    width: 50px;
}

.preview-table td {
    padding: 8px 12px;
    border-bottom: 1px solid #f1f5f9;
    font-size: 0.8rem;
    color: #334155;
}

.preview-table td:first-child {
    text-align: center;
}

.preview-table tbody tr:hover {
    background: #f8fafc;
}

.row-number {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: #fff;
    border-radius: 50%;
    font-size: 0.7rem;
    font-weight: 700;
}

.custid-value {
    font-weight: 600;
    color: #1e293b;
    font-family: 'Consolas', monospace;
}

.auto-generate-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    background: linear-gradient(135deg, #dbeafe 0%, #e0e7ff 100%);
    color: #4f46e5;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 500;
}

.auto-generate-badge i {
    font-size: 0.7rem;
}

.preview-input {
    width: 100%;
    padding: 6px 10px;
    border: 2px solid #e2e8f0;
    border-radius: 6px;
    font-size: 0.8rem;
    transition: all 0.2s;
}

.preview-input:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

/* Empty State */
.preview-empty {
    padding: 120px 16px;
    text-align: center;
    color: #94a3b8;
}

.preview-empty i {
    font-size: 2.5rem;
    color: #cbd5e1;
    margin-bottom: 12px;
}

.preview-empty-title {
    font-size: 0.9rem;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 6px;
}

.preview-empty-text {
    font-size: 0.8rem;
}

/* ============================================
   Request Modal - Modern Design
   ============================================ */

.modal-request .modal-content {
    border: none;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 25px 50px rgba(0,0,0,0.15);
}

.modal-request .modal-header {
    background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
    color: #fff;
    padding: 20px 24px;
    border: none;
}

.modal-request .modal-title {
    font-size: 1.1rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 10px;
}

.modal-request .modal-title i {
    color: #38bdf8;
}

.modal-request .close {
    color: #fff;
    opacity: 0.7;
    text-shadow: none;
    font-size: 1.5rem;
}

.modal-request .close:hover {
    opacity: 1;
}

.modal-request .modal-body {
    padding: 24px;
    background: #fff;
}

.modal-form-group {
    margin-bottom: 20px;
}

.modal-form-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    color: #334155;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.modal-textarea {
    width: 100%;
    min-height: 200px;
    padding: 16px;
    border: 2px solid #e2e8f0;
    border-radius: 12px;
    font-size: 0.9rem;
    line-height: 1.6;
    resize: none;
    transition: all 0.2s;
}

.modal-textarea:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.char-counter {
    text-align: right;
    font-size: 0.8rem;
    color: #94a3b8;
    margin-top: 8px;
}

.char-counter span {
    color: #6366f1;
    font-weight: 600;
}

.modal-request .modal-footer {
    padding: 16px 24px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

.btn-modal-cancel {
    padding: 10px 20px;
    border: 2px solid #e2e8f0;
    border-radius: 10px;
    background: #fff;
    color: #64748b;
    font-size: 0.9rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-modal-cancel:hover {
    border-color: #cbd5e1;
    background: #f8fafc;
}

.btn-modal-submit {
    padding: 10px 24px;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: #fff;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 8px;
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.btn-modal-submit:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}
</style>

<!-- Main Container -->
<div class="policy-management-container" style="overflow-y: auto;">
    <!-- Hidden Form -->
    <form style="display:none;" id="searchForm">
        <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
        <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
        <input type='hidden' name='applytype'>
    </form>

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-paper-plane"></i>
            <span><spring:message code="memu.testdata_apply" text="Test Data Request"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.testdata" text="Test Data"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.testdata_apply" text="Request"/></span>
        </div>
    </div>

    <!-- Content -->
    <div class="testdata-content">
        <!-- Configuration Card -->
        <div class="config-card">
            <div class="config-card-header">
                <i class="fas fa-cog"></i>
                <spring:message code="etc.configuration" text="Configuration"/>
            </div>
            <div class="config-card-body">
                <div class="config-grid">
                    <div class="config-item">
                        <label class="config-label" for="search2">
                            <spring:message code="col.system" text="System"/>
                        </label>
                        <select disabled class="config-select" name="search2" id="search2">
                            <c:forEach items="${listsystem}" var="piisystem">
                                <option value="<c:out value="${piisystem.system_id}"/>"
                                        <c:if test="${cri.search2 eq piisystem.system_id}">selected</c:if>>
                                    <c:out value="${piisystem.system_name}"/> [<c:out value="${piisystem.system_id}"/>]
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="config-item">
                        <label class="config-label" for="search1">
                            Source DB (<spring:message code="etc.productionenv" text="Production"/>)
                        </label>
                        <select class="config-select" name="search1" id="search1">
                            <c:forEach items="${piidatabaselist}" var="piidatabase">
                                <c:if test="${fn:startsWith(piidatabase.env, 'PRODUCTION')}">
                                    <c:choose>
                                        <c:when test="${piidatabase.env eq 'PRODUCTION'}">
                                            <option value="<c:out value="${piidatabase.db}"/>" selected>
                                                <c:out value="${piidatabase.db}"/>
                                            </option>
                                        </c:when>
                                        <c:when test="${piidatabase.env eq 'PRODUCTION-1'}">
                                            <option value="<c:out value="${piidatabase.db}"/>">
                                                <c:out value="${piidatabase.db}"/> (-1 Day)
                                            </option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="<c:out value="${piidatabase.db}"/>">
                                                <c:out value="${piidatabase.db}"/>
                                            </option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="config-item">
                        <label class="config-label" for="search3">
                            Target DB (<spring:message code="etc.devtextenv" text="Dev/Test"/>)
                        </label>
                        <select class="config-select" name="search3" id="search3">
                            <c:forEach items="${piidatabaselist}" var="piidatabase">
                                <c:if test="${not fn:startsWith(piidatabase.env, 'PRODUCTION')}">
                                    <option value="<c:out value="${piidatabase.db}"/>" selected>
                                        <c:out value="${piidatabase.db}"/>
                                        <c:choose>
                                            <c:when test="${piidatabase.env eq 'PRE-PRODUCTION'}"> (Staging)</c:when>
                                            <c:when test="${piidatabase.env eq 'DEVELOPMENT'}"> (Dev)</c:when>
                                            <c:when test="${piidatabase.env eq 'ETC'}"> (Etc)</c:when>
                                        </c:choose>
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="config-item">
                        <label class="config-label" for="search4">
                            <spring:message code="etc.testdatajobtype" text="Test Data Type"/>
                        </label>
                        <select class="config-select" name="search4" id="search4" onchange="addRows()">
                            <c:forEach items="${testdatajoblist}" var="testdatajob" varStatus="loop">
                                <option value="<c:out value="${testdatajob.jobid}"/>" <c:if test="${loop.index == n - 1}">selected</c:if>>
                                    <c:out value="${testdatajob.jobname}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- Workspace Area -->
        <div class="workspace-area">
            <!-- Input Panel -->
            <div class="input-panel">
                <div class="panel-header input-header">
                    <i class="fas fa-keyboard"></i>
                    <spring:message code="etc.inputcustids" text="Enter Customer IDs"/>
                </div>
                <div class="panel-body">
                    <div class="id-type-selector">
                        <label class="id-type-label" for="search5">ID Type</label>
                        <select class="id-type-select" name="search5" id="search5">
                            <option value="CUSTID" selected><spring:message code="col.custid" text="Customer ID"/></option>
                            <c:forEach items="${testdataidtypelist}" var="idtype">
                                <option value="<c:out value="${idtype.id}"/>"><c:out value="${idtype.idname}"/></option>
                            </c:forEach>
                        </select>
                    </div>

                    <textarea class="input-textarea" id="customerNumbers" oninput="addRows()"
                              placeholder="Enter customer IDs (Max 10 items)&#10;Separated by comma, space, or newline&#10;&#10;Example:&#10;12345, 67890, 11111&#10;or&#10;12345&#10;67890&#10;11111"></textarea>

                    <div class="submit-section">
                        <button type="button" data-oper='testdata' class="btn-submit">
                            <i class="fas fa-paper-plane"></i>
                            <spring:message code="memu.testdata_apply" text="Submit Request"/>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Preview Panel -->
            <div class="preview-panel">
                <div class="panel-header preview-header">
                    <i class="fas fa-eye"></i>
                    Preview
                </div>
                <div class="preview-info">
                    <span class="preview-count">
                        <strong id="previewCount">0</strong> items entered
                    </span>
                    <span class="preview-badge">Max 10 items</span>
                </div>
                <div class="preview-table-wrapper">
                    <table class="preview-table" id="listTable">
                        <thead>
                        <tr>
                            <th>NO</th>
                            <th>Source ID (<spring:message code="etc.productionenv" text="Production"/>)</th>
                            <th>Target ID (<spring:message code="etc.devtextenv" text="Dev/Test"/>)</th>
                        </tr>
                        </thead>
                        <tbody id="previewTableBody">
                        </tbody>
                    </table>
                    <div class="preview-empty" id="previewEmpty">
                        <i class="fas fa-inbox"></i>
                        <div class="preview-empty-title">No data entered</div>
                        <div class="preview-empty-text">Enter customer IDs in the left panel to see preview</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Request Modal -->
<div class="modal fade modal-request" id="requesttestdatamodal" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fas fa-paper-plane"></i>
                    <spring:message code="memu.testdata_apply" text="Request Test Data"/>
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="modal-form-group">
                    <label class="modal-form-label">
                        <i class="fas fa-sitemap"></i> <spring:message code="col.aprvlineid" text="Approval Line"/>
                    </label>
                    <div id="approvallineselect"></div>
                </div>
                <div class="modal-form-group">
                    <label class="modal-form-label">
                        <i class="fas fa-comment-alt"></i> <spring:message code="col.reason" text="Request Reason"/>
                    </label>
                    <textarea class="modal-textarea" spellcheck="false"
                              oninput="updateCharacterCount()" name='checkin_reason' id='checkin_reason'
                              placeholder="Please enter the reason for this test data request..."></textarea>
                    <div class="char-counter">
                        <span id="reasonlength">0</span> / 1000 characters
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button type="button" data-oper='request_checkin' class="btn-modal-submit">
                    <i class="fas fa-paper-plane"></i> Submit Request
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function updateCharacterCount() {
        var textarea = document.getElementById('checkin_reason');
        var countSpan = document.getElementById('reasonlength');
        var maxLength = 1000;
        var sanitizedValue = textarea.value.replace(/['"]/g, '');
        var currentLength = sanitizedValue.length;
        countSpan.textContent = currentLength;
        if (currentLength > maxLength) {
            sanitizedValue = sanitizedValue.substring(0, maxLength);
            textarea.value = sanitizedValue;
            countSpan.textContent = maxLength;
        }
    }

    function addRows() {
        var customerNumbersInput = document.getElementById("customerNumbers");
        var customerTableBody = document.getElementById("previewTableBody");
        var previewEmpty = document.getElementById("previewEmpty");
        var previewCount = document.getElementById("previewCount");

        var processedInput = customerNumbersInput.value
            .trim()
            .replace(/[\s,]+/g, ',')
            .replace(/^,|,$/g, '');

        var customerNumbers = [...new Set(processedInput.split(',').filter(num => num !== ''))];

        customerTableBody.innerHTML = "";

        if (customerNumbers.length === 0) {
            previewEmpty.style.display = 'block';
            previewCount.textContent = '0';
            return;
        }

        previewEmpty.style.display = 'none';
        previewCount.textContent = customerNumbers.length;

        var maxDisplay = Math.min(customerNumbers.length, 100);

        for (var i = 0; i < maxDisplay; i++) {
            var customerNumber = customerNumbers[i].trim();

            if (customerNumber !== "") {
                var newRow = customerTableBody.insertRow();

                var sequenceCell = newRow.insertCell(0);
                sequenceCell.innerHTML = '<span class="row-number">' + (i + 1) + '</span>';

                var cell = newRow.insertCell(1);
                cell.innerHTML = '<span class="custid-value">' + customerNumber + '</span>';

                var newCell = newRow.insertCell(2);
                const searchValue = document.getElementById('search4').value;

                if (searchValue.includes('TESTDATA_AUTO_GEN_FIXED') || searchValue.startsWith('TESTDATA_AUTO_GEN_FIXED')) {
                    var input = document.createElement("input");
                    input.type = "text";
                    input.className = "preview-input";
                    input.placeholder = "Enter target ID";
                    newCell.appendChild(input);
                } else {
                    newCell.innerHTML = '<span class="auto-generate-badge"><i class="fas fa-magic"></i> Auto Generate</span>';
                }
            }
        }
    }

    var doubleSubmitFlag = false;

    $(function () {
        const SEL = "button[data-oper='testdata']";
        const $requestModal = $("#requesttestdatamodal");
        const $errorModal = $("#errormodal");

        $(SEL).off("click").removeAttr("onclick");

        $(document).off("click.testdata", SEL).on("click.testdata", SEL, function (e) {
            e.preventDefault();
            e.stopPropagation();

            const $btn = $(this);

            if ($btn.data("cooldown") === true || $btn.prop("disabled")) return;

            $btn.data("cooldown", true).prop("disabled", true);

            let unlocked = false;
            const unlock = () => {
                if (unlocked) return;
                unlocked = true;
                $btn.data("cooldown", false).prop("disabled", false);
            };

            $requestModal.one("shown.bs.modal", unlock);
            $errorModal.one("shown.bs.modal", unlock);

            const fs = setTimeout(unlock, 1200);

            if (typeof checkin === "function") {
                checkin("TESTDATA", () => {});
            } else {
                clearTimeout(fs);
                unlock();
                console.error("checkin function is not defined.");
            }
        });

        $("#searchForm").off("submit.testdata").on("submit.testdata", function (e) {
            e.preventDefault();
        });
    });

    checkin = function (applytype, callback) {
        var search1 = $('#search1').val();
        var param = [];
        var checkedcnt = 0;
        var custids = "";
        var textareaElement = document.getElementById("customerNumbers");
        var textareaValue = textareaElement.value;
        var customerTableBody = document.getElementById("previewTableBody");

        var search4 = document.getElementById("search4");
        if (!search4.value) {
            dlmAlert("Please select Testdata type from the dropdown!");
            if (callback) callback();
            return false;
        }

        if (customerTableBody.rows.length === 0) {
            dlmAlert("<spring:message code="etc.notdatatoadd" text="No data to add!"/>");
            if (callback) callback();
            return false;
        }

        const searchValue = document.getElementById('search4').value;
        if (searchValue.includes('TESTDATA_AUTO_GEN_FIXED') || searchValue.startsWith('TESTDATA_AUTO_GEN_FIXED')) {
            var table = document.getElementById("listTable");
            var inputs = table.getElementsByTagName("input");

            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].value.trim() === "") {
                    dlmAlert("Row [" + (i + 1) + "], " + "<spring:message code="etc.alertinputtestfixedcustno" text="please enter the fixed customer number to generate test data!"/>");
                    inputs[i].focus();
                    if (callback) callback();
                    return false;
                }
            }
        }

        ingShow();

        var aprovalid = applytype + "_APPROVAL";
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/approvallinebyappidlist?approvalid=" + aprovalid,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                if (callback) callback();
            },
            success: function (data) {
                ingHide();
                $('#approvallineselect').html(data);

                if (applytype == "TESTDATA") {
                    custids += "<spring:message code="etc.applytestdatatxt" text="Below is a request for automatic generation of test data for the following production customer numbers."/>\n";
                }
                custids += textareaValue;

                $('#searchForm [name="applytype"]').val(applytype);
                $('#checkin_reason').val(custids);
                $("#requesttestdatamodal").modal();
                updateCharacterCount();

                if (callback) callback();
            }
        });
    };

    if (typeof window.__REQUEST_CHECKIN_INFLIGHT__ === "undefined") {
        window.__REQUEST_CHECKIN_INFLIGHT__ = false;
    }

    $(document)
        .off("click.request_checkin", "button[data-oper='request_checkin']")
        .on("click.request_checkin", "button[data-oper='request_checkin']", function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (isEmpty($('input[name="aprvlineid"]:checked').val())) {
                dlmAlert("<spring:message code='msg.select_approval_line' text='Please select an approval line'/>");
                return;
            }

            if (isEmpty($('#checkin_reason').val())) {
                dlmAlert("Enter request reason for CHECK-IN ");
                return;
            }

            if (window.__REQUEST_CHECKIN_INFLIGHT__) return;

            window.__REQUEST_CHECKIN_INFLIGHT__ = true;
            const $btn = $(this).prop("disabled", true);

            const jq = requestApproval();

            if (jq && jq.always) {
                jq.always(function () {
                    window.__REQUEST_CHECKIN_INFLIGHT__ = false;
                    $btn.prop("disabled", false);
                });
            } else {
                setTimeout(function () {
                    window.__REQUEST_CHECKIN_INFLIGHT__ = false;
                    $btn.prop("disabled", false);
                }, 1500);
            }
        });

    requestApproval = function () {
        var serchkeyno3 = $('#checkin_reason').val();
        var url_search = "";
        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#search1').val().toUpperCase();
        var search2 = $('#search2').val().toUpperCase();
        var search3 = $('#search3').val().toUpperCase();
        var search4 = $('#search4').val().toUpperCase();
        var search5 = $('#search5').val().toUpperCase();

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        var applytype = $('#searchForm [name="applytype"]').val();

        var customerTableBody = document.getElementById("previewTableBody");
        var param = [];
        var checkedcnt = 0;

        for (var i = 0; i < customerTableBody.rows.length; i++) {
            var row = customerTableBody.rows[i];
            var td = $(row).find('td');
            var thirdTd = $(td[2]);
            var input = thirdTd.find('input');
            var inputVal = "";
            if (input.length > 0) {
                inputVal = input.val();
            }
            var data = {
                testdataid: null,
                system: search2,
                sourcedb: search1,
                targetdb: search3,
                phase: "APPLY",
                apply_type: null,
                new_orderid: null,
                jobid: search4,
                idtype: search5,
                custid: td.eq(1).text(),
                custid_new: inputVal,
                cust_nm: null,
                ssn: null,
                new_jobid: null,
                status: null,
                approve_date: null,
                regdate: null,
                upddate: null,
                reguserid: $('#global_userid').val(),
                upduserid: $('#global_userid').val()
            };
            param.push(data);
            checkedcnt++;
        }

        if (checkedcnt == 0) {
            return;
        }

        url_view = "register?reqreason=" + serchkeyno3 + "&" + "aprvlineid=" + $('input[name="aprvlineid"]:checked').val() + "&" + "applytype=" + applytype + "&";

        return $.ajax({
            url: "/testdata/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {
                ingHide();
                if (data === "success") {
                    $("#requesttestdatamodal").modal("hide");
                    $("#requesttestdatamodal").one("hidden.bs.modal", function () {
                        showToast("처리가 완료되었습니다.", false);
                    });
                    $("#GlobalSuccessMsgModal").one("shown.bs.modal", function () {
                        $(this).find("[data-dismiss='modal'], .btn, [role='button']").first().trigger("focus");
                        setTimeout(function () { $("#GlobalSuccessMsgModal").modal("hide"); }, 800);
                    });
                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    };
</script>
