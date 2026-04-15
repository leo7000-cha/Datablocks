<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
/* SQL Manager Page Styles */
.sql-container {
    padding: 0;
    background: #0f172a;
    min-height: 100%;
    display: flex;
    flex-direction: column;
}

.sql-header {
    background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
    padding: 12px 20px;
    border-bottom: 1px solid #334155;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
}

.sql-title {
    font-size: 1rem;
    font-weight: 600;
    color: #f1f5f9;
    display: flex;
    align-items: center;
    gap: 10px;
}

.sql-title i {
    color: #22d3ee;
    font-size: 1.1rem;
}

.sql-controls {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
}

.sql-control-group {
    display: flex;
    align-items: center;
    gap: 8px;
}

.sql-control-label {
    font-size: 0.75rem;
    font-weight: 500;
    color: #94a3b8;
    text-transform: uppercase;
}

.sql-select {
    padding: 6px 12px;
    border: 1px solid #475569;
    border-radius: 6px;
    background: #1e293b;
    color: #f1f5f9;
    font-size: 0.85rem;
    min-width: 140px;
    cursor: pointer;
    transition: all 0.2s;
}

.sql-select:focus {
    outline: none;
    border-color: #22d3ee;
    box-shadow: 0 0 0 2px rgba(34,211,238,0.2);
}

.sql-select option {
    background: #1e293b;
    color: #f1f5f9;
}

.sql-input {
    padding: 6px 12px;
    border: 1px solid #475569;
    border-radius: 6px;
    background: #1e293b;
    color: #f1f5f9;
    font-size: 0.85rem;
    width: 80px;
    text-align: center;
    transition: all 0.2s;
}

.sql-input:focus {
    outline: none;
    border-color: #22d3ee;
    box-shadow: 0 0 0 2px rgba(34,211,238,0.2);
}

.sql-actions {
    display: flex;
    gap: 8px;
}

.sql-btn {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
}

.sql-btn.run {
    background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
    color: #fff;
}

.sql-btn.run:hover {
    box-shadow: 0 2px 8px rgba(34,197,94,0.4);
    transform: translateY(-1px);
}

.sql-btn.save {
    background: transparent;
    border: 1px solid #475569;
    color: #94a3b8;
}

.sql-btn.save:hover {
    border-color: #64748b;
    color: #f1f5f9;
    background: #1e293b;
}

.sql-btn.excel {
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    color: #fff;
}

.sql-btn.excel:hover {
    box-shadow: 0 2px 8px rgba(59,130,246,0.4);
    transform: translateY(-1px);
}

/* Editor Area */
.sql-editor-wrapper {
    flex: 0 0 auto;
    padding: 12px;
    background: #0f172a;
}

.sql-editor-container {
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #334155;
    background: #1e293b;
}

.sql-editor-toolbar {
    padding: 8px 12px;
    background: #1e293b;
    border-bottom: 1px solid #334155;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.sql-editor-info {
    font-size: 0.75rem;
    color: #64748b;
    display: flex;
    align-items: center;
    gap: 16px;
}

.sql-editor-info span {
    display: flex;
    align-items: center;
    gap: 4px;
}

.sql-editor-info i {
    color: #475569;
}

.sql-editor-hint {
    font-size: 0.7rem;
    color: #64748b;
    display: flex;
    align-items: center;
    gap: 6px;
}

.sql-editor-hint kbd {
    background: #334155;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.65rem;
    color: #94a3b8;
}

.sql-textarea {
    width: 100%;
    min-height: 280px;
    max-height: 350px;
    padding: 16px;
    border: none;
    background: #0f172a;
    color: #e2e8f0;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 0.9rem;
    line-height: 1.6;
    resize: vertical;
    outline: none;
}

.sql-textarea::placeholder {
    color: #475569;
}

.sql-textarea::-webkit-scrollbar {
    width: 8px;
}

.sql-textarea::-webkit-scrollbar-track {
    background: #1e293b;
}

.sql-textarea::-webkit-scrollbar-thumb {
    background: #475569;
    border-radius: 4px;
}

.sql-textarea::-webkit-scrollbar-thumb:hover {
    background: #64748b;
}

/* Result Area */
.sql-result-wrapper {
    flex: 1;
    padding: 0 12px 12px 12px;
    display: flex;
    flex-direction: column;
    min-height: 400px;
}

.sql-result-container {
    flex: 1;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #334155;
    background: #1e293b;
    display: flex;
    flex-direction: column;
}

.sql-result-header {
    padding: 10px 16px;
    background: #1e293b;
    border-bottom: 1px solid #334155;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.sql-result-title {
    font-size: 0.8rem;
    font-weight: 600;
    color: #94a3b8;
    display: flex;
    align-items: center;
    gap: 8px;
}

.sql-result-title i {
    color: #22d3ee;
}

.sql-result-status {
    font-size: 0.75rem;
    color: #64748b;
}

.sql-result-body {
    flex: 1;
    overflow: auto;
    background: #0f172a;
    padding: 0;
}

/* Override table styles in result */
.sql-result-body table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.8rem;
}

.sql-result-body th {
    background: #1e293b !important;
    color: #94a3b8 !important;
    padding: 10px 12px !important;
    text-align: left;
    font-weight: 600;
    border-bottom: 1px solid #334155 !important;
    position: sticky;
    top: 0;
    z-index: 1;
}

.sql-result-body td {
    padding: 8px 12px !important;
    color: #e2e8f0 !important;
    border-bottom: 1px solid #1e293b !important;
    background: transparent !important;
}

.sql-result-body tr:hover td {
    background: #1e293b !important;
}

.sql-result-body .alert {
    margin: 16px;
    border-radius: 8px;
}

/* Empty/Ready State */
.sql-result-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    min-height: 200px;
    color: #475569;
    text-align: center;
    padding: 40px;
}

.sql-result-empty i {
    font-size: 3rem;
    margin-bottom: 16px;
    color: #334155;
}

.sql-result-empty p {
    font-size: 0.9rem;
    margin: 0;
}

.sql-result-empty small {
    font-size: 0.75rem;
    color: #334155;
    margin-top: 8px;
}

/* Running state */
.sql-running {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    min-height: 200px;
    color: #22d3ee;
}

.sql-running i {
    font-size: 2rem;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 1200px) {
    .sql-header {
        flex-direction: column;
        align-items: flex-start;
    }

    .sql-controls {
        width: 100%;
        justify-content: space-between;
    }
}
</style>

<!-- Begin Page Content -->
<div class="sql-container" id="sqlmanager">
    <!-- Header -->
    <div class="sql-header">
        <div class="sql-title">
            <i class="fas fa-terminal"></i>
            SQL Manager
        </div>

        <div class="sql-controls">
            <div class="sql-control-group">
                <span class="sql-control-label">Database</span>
                <select class="sql-select" name="db" id="db">
                    <option value="">-- Select DB --</option>
                    <c:forEach items="${piidatabaselist}" var="piidatabase">
                        <option value="<c:out value="${piidatabase.db}" />"
                                <c:if test="${piiexeupdate.db eq piidatabase.db}">selected</c:if>><c:out value="${piidatabase.db}"/></option>
                    </c:forEach>
                </select>
            </div>

            <div class="sql-control-group">
                <span class="sql-control-label">Max Rows</span>
                <input type="text" class="sql-input" name="maxrowcnt" id="maxrowcnt" value="1000"
                       onkeyup="this.value=this.value.replace(/[^0-9]/g,'');">
            </div>

            <sec:authentication property="principal.member.userid" var="userid"/>
            <c:if test="${userid eq 'admin'}">
                <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                    <div class="sql-actions">
                        <button type="button" class="sql-btn run" id="btnRun">
                            <i class="fas fa-play"></i> Run
                        </button>
                        <button type="button" class="sql-btn save" id="btnSave">
                            <i class="fas fa-save"></i> Save
                        </button>
                        <button type="button" class="sql-btn excel" id="btnExcel">
                            <i class="fas fa-file-excel"></i> Excel
                        </button>
                    </div>
                </sec:authorize>
            </c:if>
        </div>
    </div>

    <!-- Hidden form fields -->
    <form style="display:none;" id="searchForm">
        <input type="hidden" name="pagenum" value="<c:out value='${cri.pagenum}'/>">
        <input type="hidden" name="amount" value="<c:out value='${cri.amount}'/>">
        <input type="hidden" name="splitter" value=";">
        <input type="hidden" name="amho" value="DATABLOCKS">
        <input type="hidden" name="runtype" value="ALL">
    </form>

    <!-- SQL Editor -->
    <div class="sql-editor-wrapper">
        <div class="sql-editor-container">
            <div class="sql-editor-toolbar">
                <div class="sql-editor-info">
                    <span><i class="fas fa-code"></i> SQL Editor</span>
                </div>
                <div class="sql-editor-hint">
                    <kbd>Ctrl</kbd> + <kbd>Enter</kbd> to execute
                </div>
            </div>
            <form id="piidatabase_modify_form">
                <textarea class="sql-textarea" name="sqlstr" id="sqlstr"
                          placeholder="-- Enter your SQL query here...&#10;-- Example: SELECT * FROM table_name WHERE condition;"><c:out value="${piiexeupdate.sqlstr}"/></textarea>
                <input type="hidden" name="amho"/>
                <input type="hidden" name="splitter"/>
                <input type="hidden" name="runtype"/>
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <input type="hidden" name="db"/>
                <input type="hidden" name="maxrowcnt"/>
            </form>
        </div>
    </div>

    <!-- Result Area -->
    <div class="sql-result-wrapper">
        <div class="sql-result-container">
            <div class="sql-result-header">
                <div class="sql-result-title">
                    <i class="fas fa-table"></i>
                    Results
                </div>
                <div class="sql-result-status" id="resultStatus"></div>
            </div>
            <div class="sql-result-body" id="modify_result">
                <div class="sql-result-empty">
                    <i class="fas fa-database"></i>
                    <p>Ready to execute query</p>
                    <small>Select a database and run your SQL</small>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Hidden form for Excel download -->
<form style="display:none;" id="excelForm" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
    <input type="hidden" name="db"/>
    <input type="hidden" name="amho"/>
    <input type="hidden" name="splitter"/>
    <input type="hidden" name="runtype"/>
    <input type="hidden" name="maxrowcnt"/>
</form>

<script type="text/javascript">
    $(function () {
        // $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "SQL Manager");
        $("#menupath").html("SQL Manager");
    });

    $(document).ready(function () {
        history.replaceState({}, null, null);

        var actionExecuted = false;

        // Run button click
        $('#btnRun').on('click', function(e) {
            e.preventDefault();
            executeAction();
        });

        // Save button click
        $('#btnSave').on('click', function(e) {
            e.preventDefault();
            saveTextAsFile();
        });

        // Excel button click
        $('#btnExcel').on('click', function(e) {
            e.preventDefault();
            doExcelDownload();
        });

        // Ctrl+Enter to execute
        document.addEventListener("keydown", function(event) {
            if (event.ctrlKey && event.keyCode === 13) {
                executeAction();
            }
        });

        // Execute SQL
        window.executeAction = function() {
            if (actionExecuted) return;
            actionExecuted = true;

            var db = $('#db').val();
            if (!db) {
                dlmAlert("Please select a database!");
                actionExecuted = false;
                return;
            }

            // Show running state
            $("#modify_result").html('<div class="sql-running"><i class="fas fa-spinner"></i></div>');
            $("#resultStatus").text("Executing...");

            var amho = $('#searchForm [name="amho"]').val();
            var splitter = $('#searchForm [name="splitter"]').val();
            var maxrowcnt = $('#maxrowcnt').val();
            var sqlstr = $('#sqlstr').val();

            // Get selected text or query at cursor position
            sqlstr = getQueryToExecute();

            // Determine runtype
            var runtype = validateSelectedText(sqlstr) ? 'SELECT' : 'EXECUTE';

            $.ajax({
                type: "POST",
                url: "/piidatabase/exeupdate",
                dataType: "text",
                data: JSON.stringify({
                    db: db,
                    sqlstr: sqlstr,
                    amho: amho,
                    splitter: splitter,
                    runtype: runtype,
                    maxrowcnt: maxrowcnt
                }),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function(result) {
                    $("#modify_result").html(result);
                    $("#resultStatus").text("Completed");
                },
                error: function(request, error) {
                    $("#modify_result").html('<div class="sql-result-empty"><i class="fas fa-exclamation-triangle" style="color:#ef4444;"></i><p style="color:#ef4444;">Connection error</p><small>Check database connection settings</small></div>');
                    $("#resultStatus").text("Error");
                }
            });

            setTimeout(function() { actionExecuted = false; }, 1000);
        };

        // Excel download
        function doExcelDownload() {
            if (actionExecuted) return;
            actionExecuted = true;

            var db = $('#db').val();
            if (!db) {
                dlmAlert("Please select a database!");
                actionExecuted = false;
                return;
            }

            var amho = $('#searchForm [name="amho"]').val();
            var splitter = $('#searchForm [name="splitter"]').val();
            var maxrowcnt = $('#maxrowcnt').val();
            var sqlstr = getQueryToExecute();

            var url = "/piidatabase/exeupdate_download_excel?pagenum=1&amount=100000";
            url += "&search1=" + encodeURIComponent(db);
            url += "&search2=" + encodeURIComponent(amho);
            url += "&search3=" + encodeURIComponent(splitter);
            url += "&search4=SELECT";
            url += "&search5=" + encodeURIComponent(maxrowcnt);
            url += "&search6=" + encodeURIComponent(sqlstr);

            var f = document.form1;
            f.action = url;
            f.submit();

            setTimeout(function() { actionExecuted = false; }, 1000);
        }
    });

    /**
     * Get query to execute - like DBeaver/DataGrip behavior
     * 1. If text is selected, return selected text
     * 2. Otherwise, find the query containing cursor position (between semicolons)
     */
    function getQueryToExecute() {
        var textarea = document.getElementById("sqlstr");
        var text = textarea.value;
        var selStart = textarea.selectionStart;
        var selEnd = textarea.selectionEnd;

        // 1. If text is selected, use selected text
        if (selStart !== selEnd) {
            return text.substring(selStart, selEnd).trim();
        }

        // 2. Find query at cursor position (between semicolons)
        var cursorPos = selStart;

        // Find start: search backward for semicolon
        var startPos = 0;
        for (var i = cursorPos - 1; i >= 0; i--) {
            if (text.charAt(i) === ';') {
                startPos = i + 1;
                break;
            }
        }

        // Find end: search forward for semicolon
        var endPos = text.length;
        for (var j = cursorPos; j < text.length; j++) {
            if (text.charAt(j) === ';') {
                endPos = j;
                break;
            }
        }

        var query = text.substring(startPos, endPos).trim();

        // If empty at current position, try to get the previous query (cursor might be after semicolon)
        if (!query && cursorPos > 0) {
            // Find the previous semicolon
            var prevSemicolon = text.lastIndexOf(';', cursorPos - 1);
            if (prevSemicolon >= 0) {
                // Find the semicolon before that
                var prevPrevSemicolon = text.lastIndexOf(';', prevSemicolon - 1);
                startPos = prevPrevSemicolon >= 0 ? prevPrevSemicolon + 1 : 0;
                query = text.substring(startPos, prevSemicolon).trim();
            }
        }

        return query;
    }

    function validateSelectedText(selectedText) {
        if (!selectedText) return false;
        var t = selectedText.trim().toLowerCase();
        return /^(select|with|show|desc|describe|explain)\b/.test(t);
    }

    function saveTextAsFile() {
        var textToSave = document.getElementById("sqlstr").value;
        var fileNameToSaveAs = "query_" + new Date().toISOString().slice(0,10) + ".sql";

        var blob = new Blob([textToSave], {type: "text/plain;charset=utf-8"});

        if (window.navigator.msSaveOrOpenBlob) {
            window.navigator.msSaveOrOpenBlob(blob, fileNameToSaveAs);
        } else {
            var link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            link.download = fileNameToSaveAs;
            link.style.display = "none";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
</script>
