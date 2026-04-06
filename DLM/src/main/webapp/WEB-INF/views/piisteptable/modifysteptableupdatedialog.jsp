<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<style>
/* Update Column Dialog Styles */
.update-dialog-container {
    display: flex;
    gap: 10px;
    padding: 10px;
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
    border-radius: 8px;
    height: 670px;
    width: 1100px;
}

.update-dialog-panel {
    flex: 1;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    border: 1px solid #e2e8f0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

.update-dialog-header {
    background: linear-gradient(135deg, #475569 0%, #334155 100%);
    color: #fff;
    padding: 12px 16px;
    font-size: 0.85rem;
    font-weight: 600;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-radius: 8px 8px 0 0;
}

.update-dialog-header .header-title {
    display: flex;
    align-items: center;
    gap: 8px;
}

.update-dialog-header .header-title i {
    font-size: 1rem;
}

.update-dialog-header .table-name {
    background: rgba(255,255,255,0.2);
    padding: 4px 10px;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
}

.update-dialog-header .btn-save {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: #fff;
    border: none;
    padding: 6px 14px;
    border-radius: 6px;
    font-size: 0.75rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    gap: 5px;
}

.update-dialog-header .btn-save:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

.update-dialog-body {
    flex: 1;
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.update-dialog-table-wrapper {
    flex: 1;
    overflow-y: auto;
    overflow-x: auto;
}

.update-dialog-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    font-size: 0.78rem;
}

.update-dialog-table thead {
    position: sticky;
    top: 0;
    z-index: 10;
}

.update-dialog-table thead th {
    background: #f1f5f9;
    padding: 10px 12px;
    text-align: left;
    font-weight: 700;
    color: #0f172a;
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    border-bottom: 2px solid #cbd5e1;
    white-space: nowrap;
    vertical-align: middle;
}

.update-dialog-table tbody tr {
    transition: all 0.15s ease;
    border-bottom: 1px solid #f1f5f9;
}

.update-dialog-table tbody tr:nth-child(odd) {
    background: #fff;
}

.update-dialog-table tbody tr:nth-child(even) {
    background: #fafbfc;
}

.update-dialog-table tbody tr:hover {
    background: linear-gradient(90deg, #eff6ff 0%, #f8fafc 100%);
    box-shadow: inset 3px 0 0 #3b82f6;
}

.update-dialog-table tbody td {
    padding: 8px 12px;
    color: #1e293b;
    font-weight: 500;
    vertical-align: middle;
}

.update-dialog-table input[type="checkbox"] {
    width: 13px;
    height: 13px;
    cursor: pointer;
}

.update-dialog-table tbody td input[type="text"] {
    width: 100%;
    padding: 6px 10px;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 0.78rem;
    transition: all 0.2s ease;
}

.update-dialog-table tbody td input[type="text"]:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Transfer buttons in center */
.update-dialog-transfer {
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 8px;
    padding: 0 5px;
}

.update-dialog-transfer .btn-transfer {
    background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
    color: #fff;
    border: none;
    width: 44px;
    height: 44px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
}

.update-dialog-transfer .btn-transfer:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 15px rgba(99, 102, 241, 0.4);
}

.update-dialog-transfer .btn-transfer.btn-remove {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.update-dialog-transfer .btn-transfer.btn-remove:hover {
    box-shadow: 0 4px 15px rgba(239, 68, 68, 0.4);
}

/* Footer hint */
.update-dialog-footer {
    background: linear-gradient(135deg, #dbeafe 0%, #eff6ff 100%);
    padding: 10px 16px;
    font-size: 0.75rem;
    color: #1e40af;
    border-top: 1px solid #bfdbfe;
    display: flex;
    align-items: center;
    gap: 8px;
}

.update-dialog-footer i {
    font-size: 0.9rem;
}

/* Hidden columns */
.th-get-hidden, .td-get-hidden {
    display: none;
}
</style>

<!-- Hidden Form -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
</form>

<!-- Main Container -->
<div class="update-dialog-container">

    <!-- Left Panel: Available Columns -->
    <div class="update-dialog-panel" style="flex: 1.1;">
        <div class="update-dialog-header">
            <div class="header-title">
                <i class="fas fa-columns"></i>
                <span>Available Columns</span>
            </div>
            <span class="table-name"><c:out value="${cri.search5}"/>.<c:out value="${cri.search6}"/></span>
        </div>
        <div class="update-dialog-body">
            <div class="update-dialog-table-wrapper">
                <table class="update-dialog-table" id="listTable_cols">
                    <thead>
                    <tr>
                        <th style="width:40px; text-align:center;"><input type="checkbox" id="checkall_cols"></th>
                        <th><spring:message code="col.column_id" text="ID"/></th>
                        <th><spring:message code="col.column_name" text="Column Name"/></th>
                        <th>PK</th>
                        <th><spring:message code="col.data_type" text="Type"/></th>
                        <th><spring:message code="col.data_length" text="Length"/></th>
                        <th><spring:message code="col.nullable" text="Null"/></th>
                        <th><spring:message code="col.domain" text="Domain"/></th>
                        <th><spring:message code="col.piitype" text="PII Type"/></th>
                        <th class="th-get-hidden">DB</th>
                    </tr>
                    </thead>
                    <tbody id="updatecolpiitabletbody">
                    <c:forEach items="${piitablelist}" var="piitable">
                        <tr>
                            <td style="text-align:center;"><input type="checkbox" class="chkBox" name="chkBoxStepTable"></td>
                            <td style="text-align:right;"><c:out value="${piitable.column_id}"/></td>
                            <td><c:out value="${piitable.column_name}"/></td>
                            <td style="text-align:center;"><c:out value="${piitable.pk_yn}"/></td>
                            <td><c:out value="${piitable.data_type}"/></td>
                            <td style="text-align:right;"><c:out value="${piitable.data_length}"/></td>
                            <td style="text-align:center;"><c:out value="${piitable.nullable}"/></td>
                            <td><c:out value="${piitable.domain}"/></td>
                            <td>
                                <c:forEach var="item" items="${listlkPiiScrType}">
                                    <c:if test="${piitable.piitype eq item.piicode}">
                                        <c:out value="${item.piitypename}"/>
                                    </c:if>
                                </c:forEach>
                            </td>
                            <td class="td-get-hidden"><c:out value="${piitable.db}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Transfer Buttons -->
    <div class="update-dialog-transfer">
        <button type="button" class="btn-transfer" onclick="addJobUpdate();" title="Add selected columns">
            <i class="fas fa-chevron-right"></i>
        </button>
        <button type="button" class="btn-transfer btn-remove" onclick="deleteJobUpdate();" title="Remove selected columns">
            <i class="fas fa-chevron-left"></i>
        </button>
    </div>

    <!-- Right Panel: Update Columns -->
    <div class="update-dialog-panel" style="flex: 0.9;">
        <div class="update-dialog-header">
            <div class="header-title">
                <i class="fas fa-edit"></i>
                <span>Update Columns & Values</span>
            </div>
            <button data-oper='saveStepTableUpdate' class="btn-save">
                <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
            </button>
        </div>
        <div class="update-dialog-body">
            <div class="update-dialog-table-wrapper">
                <table class="update-dialog-table" id="listTable_upcols">
                    <colgroup>
                        <col style="width: 40px"/>
                        <col style="width: 45%"/>
                        <col style="width: auto"/>
                    </colgroup>
                    <thead>
                    <tr>
                        <th style="text-align:center;"><input type="checkbox" id="updatecheckall"></th>
                        <th>Column Name</th>
                        <th>Value</th>
                        <th class="th-get-hidden">DATATYPE</th>
                    </tr>
                    </thead>
                    <tbody id="steptableupdatebody">
                    <c:forEach items="${liststeptableupdate}" var="piisteptableupdate">
                        <tr>
                            <td style="text-align:center;"><input type="checkbox" class="chkBox" name="chkBoxStepTableUpdate"></td>
                            <td><c:out value="${piisteptableupdate.column_name}"/></td>
                            <td>
                                <input type="text" name="update_val" value='<c:out value="${piisteptableupdate.update_val}"/>'>
                            </td>
                            <td class="td-get-hidden">SAVEDDATA</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="update-dialog-footer">
                <i class="fas fa-info-circle"></i>
                <span><spring:message code="msg.noarcenter" text="Enter 'NULL' for null value, 'sysdate' for current date"/></span>
            </div>
        </div>
    </div>

</div>

<!-- Hidden fields -->
<input type='hidden' id='steptableupdate_global_jobid' value='<c:out value="${piisteptable.jobid}"/>'>
<input type='hidden' id='steptableupdate_global_version' value='<c:out value="${piisteptable.version}"/>'>
<input type='hidden' id='steptableupdate_global_stepid' value='<c:out value="${piisteptable.stepid}"/>'>
<input type='hidden' id='steptableupdate_seq1' value='<c:out value="${piisteptable.seq1}"/>'>
<input type='hidden' id='steptableupdate_seq2' value='<c:out value="${piisteptable.seq2}"/>'>
<input type='hidden' id='steptableupdate_seq3' value='<c:out value="${piisteptable.seq3}"/>'>

<script type="text/javascript">
    $(document).ready(function () {
        // Check all for left table
        $("#checkall_cols").click(function () {
            $("input[name=chkBoxStepTable]").prop("checked", $(this).prop("checked"));
        });

        // Check all for right table
        $("#updatecheckall").click(function () {
            $("input[name=chkBoxStepTableUpdate]").prop("checked", $(this).prop("checked"));
        });
    });

    function addJobUpdate() {
        var existflag = true;
        var checkbox = $("input:checkbox[name=chkBoxStepTable]:checked");

        checkbox.each(function (i) {
            existflag = true;
            var tr = checkbox.parent().parent().eq(i);
            var td = tr.children();

            $('#steptableupdatebody tr').each(function () {
                if (jQuery.trim(td.eq(2).text()) == jQuery.trim($(this).children().eq(1).text())) {
                    existflag = false;
                    alert(jQuery.trim(td.eq(2).text()) + " has already been applied");
                    return false;
                }
            });

            if (existflag) {
                var dataType = jQuery.trim(td.eq(4).text());
                var defaultVal = 'null';

                if (dataType.match("CHAR") || dataType.match("TEXT") || dataType.match("LOB")) {
                    defaultVal = '*';
                } else if (dataType.match("DATE") || dataType.match("TIME")) {
                    defaultVal = 'sysdate';
                }

                var htmlstr = "<tr>";
                htmlstr += "<td style='text-align:center;'><input type='checkbox' class='chkBox' name='chkBoxStepTableUpdate'></td>";
                htmlstr += "<td>" + jQuery.trim(td.eq(2).text()) + "</td>";
                htmlstr += "<td><input type='text' name='update_val' value='" + defaultVal + "'></td>";
                htmlstr += "<td class='td-get-hidden'>" + dataType + "</td>";
                htmlstr += "</tr>";

                $("#steptableupdatebody").append(htmlstr);
                updateValues();
            }
        });
    }

    function deleteJobUpdate() {
        $('#steptableupdatebody tr').each(function () {
            if ($(this).children().eq(0).find('input').is(":checked")) {
                $(this).remove();
            }
        });
    }

    function updateValues() {
        $('#steptableupdatebody tr').each(function () {
            var tdd = $(this).children();
            var datatype = jQuery.trim(tdd.eq(3).text());
            var s = tdd.eq(2).find("input[name='update_val']").val().toUpperCase();
            var input_val = s.replace(/^'|'$/g, '');

            $('#updatecolpiitabletbody tr').each(function () {
                if (jQuery.trim(tdd.eq(1).text()) == jQuery.trim($(this).children().eq(2).text())) {
                    datatype = jQuery.trim($(this).children().eq(4).text());
                }
            });

            var updateval;
            if (datatype == "SAVEDDATA") {
                updateval = input_val;
            } else if (input_val.toUpperCase() == "NULL") {
                updateval = input_val;
            } else if (input_val.toUpperCase() == "SCRAMBLE" || input_val.toUpperCase() == "NOARC") {
                updateval = "'" + input_val + "'";
            } else if (/^(NUMBER|DECIMAL|INT|BIGINT|FLOAT|MEDIUMINT|SMALLINT|TINYINT)$/i.test(datatype)) {
                updateval = input_val;
            } else if (/^(DATE|TIMESTAMP|TIME|DATETIME)$/i.test(datatype) || datatype.indexOf("TIMESTAMP") != -1 || datatype.indexOf("YEAR") != -1) {
                updateval = input_val;
            } else {
                updateval = "'" + input_val + "'";
            }
            tdd.eq(2).find("input[name='update_val']").val(updateval);
        });
    }

    $("button[data-oper='saveStepTableUpdate']").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        var global_jobid = $('#steptableupdate_global_jobid').val();
        var global_version = $('#steptableupdate_global_version').val();
        var global_stepid = $('#steptableupdate_global_stepid').val();
        var seq1 = $('#steptableupdate_seq1').val();
        var seq2 = $('#steptableupdate_seq2').val();
        var seq3 = $('#steptableupdate_seq3').val();
        var param = [];

        // Header for empty list case
        param.push({
            jobid: global_jobid,
            version: global_version,
            stepid: global_stepid,
            seq1: seq1,
            seq2: seq2,
            seq3: seq3,
            column_name: "HEADER",
            update_val: "HEADER",
            status: "HEADER"
        });

        $('#steptableupdatebody tr').each(function () {
            var td = $(this).children();
            var datatype = jQuery.trim(td.eq(3).text());
            var s = td.eq(2).find("input[name='update_val']").val().toUpperCase();
            var input_val = s.replace(/^'|'$/g, '');

            $('#updatecolpiitabletbody tr').each(function () {
                if (jQuery.trim(td.eq(1).text()) == jQuery.trim($(this).children().eq(2).text())) {
                    datatype = jQuery.trim($(this).children().eq(4).text());
                }
            });

            var updateval;
            if (datatype == "SAVEDDATA") {
                updateval = input_val;
            } else if (input_val.toUpperCase() == "NULL") {
                updateval = input_val;
            } else if (input_val.toUpperCase() == "SCRAMBLE" || input_val.toUpperCase() == "NOARC") {
                updateval = "'" + input_val + "'";
            } else if (/^(NUMBER|DECIMAL|INT|BIGINT|FLOAT|MEDIUMINT|SMALLINT|TINYINT)$/i.test(datatype)) {
                updateval = input_val;
            } else if (/^(DATE|TIMESTAMP|TIME|DATETIME)$/i.test(datatype) || datatype.indexOf("TIMESTAMP") != -1 || datatype.indexOf("YEAR") != -1) {
                updateval = input_val;
            } else {
                updateval = "'" + input_val + "'";
            }

            param.push({
                jobid: global_jobid,
                version: global_version,
                stepid: global_stepid,
                seq1: seq1,
                seq2: seq2,
                seq3: seq3,
                column_name: jQuery.trim(td.eq(1).text()),
                update_val: updateval,
                status: "ACTIVE"
            });
        });

        ingShow();
        $.ajax({
            url: "/piisteptable/modifysteptableupdate",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                $('#steptableupdatemodify tr').remove();

                $('#steptableupdatebody tr').each(function () {
                    var td = $(this).children();
                    var updateval = td.eq(2).find("input[name='update_val']").val();
                    $("#steptableupdatemodify").append("<tr style='border:none;'><td style='border:none;'>" + td.eq(1).text() + " = </td><td style='border:none;'>" + updateval + "</td></tr>");
                });

                $("#GlobalSuccessMsgModal").modal("show");
                $("#dialogsteptableupdatelist").modal("hide");
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    });

    $("body").on('hidden.bs.modal', '.modal', function (e) {
        e.preventDefault();
        e.stopPropagation();
    });
</script>
