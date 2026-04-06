<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-search"></i>
            <span><spring:message code="memu.arccust_browse" text="Customer Browse"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.restore_browse" text="Restore"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.arccust_browse" text="Browse"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="grid-template-columns: 200px 1fr; gap: 12px;">
                    <div class="policy-filter-item">
                        <label class="policy-filter-label" for="custid"><spring:message code="col.custid" text="CustID"/></label>
                        <select class="policy-filter-input" name="custid" id="custid" style="padding: 6px 10px;">
                            <option value=""></option>
                            <c:forEach items="${arccustlist}" var="arccust">
                                <option value="<c:out value="${arccust.custid}"/>" selected><c:out value="${arccust.custid}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>
            <input type='hidden' name="db"/>
            <input type='hidden' name="owner"/>
            <input type='hidden' name="table_name"/>
            <input type="hidden" name="runtype" value="SELECT"/>
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </form>
    </div>

    <!-- ========== TABLES SECTION ========== -->
    <div style="display: flex; gap: 16px; height: calc(100vh - 180px);">
        <!-- Left Panel: Arc Tables -->
        <div class="policy-table-section" style="flex: 0 0 400px; height: 100%;">
            <div style="background: linear-gradient(135deg, #475569 0%, #334155 100%); color: #fff; padding: 10px 16px; border-radius: 8px 8px 0 0; font-weight: 600; font-size: 0.85rem;">
                <i class="fas fa-database"></i> Archived Tables
            </div>
            <div class="policy-table-wrapper" style="border-radius: 0 0 8px 8px;">
                <table class="policy-table" id="ArcTables">
                    <thead>
                    <tr>
                        <th>DB</th>
                        <th>OWNER</th>
                        <th>TABLE_NAME</th>
                    </tr>
                    </thead>
                    <tbody id="steptablesbody">
                    <c:forEach items="${arctablelist}" var="arctable">
                        <tr style="cursor: pointer;">
                            <td><c:out value="${arctable.db}"/></td>
                            <td><c:out value="${arctable.owner}"/></td>
                            <td><c:out value="${arctable.table_name}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Right Panel: Browse Result -->
        <div class="policy-table-section" style="flex: 1; height: 100%;">
            <div style="background: linear-gradient(135deg, #475569 0%, #334155 100%); color: #fff; padding: 10px 16px; border-radius: 8px 8px 0 0; font-weight: 600; font-size: 0.85rem;">
                <i class="fas fa-search"></i> Browse Result
            </div>
            <div class="policy-table-wrapper" style="border-radius: 0 0 8px 8px; padding: 12px;">
                <div id="modify_result" style="font-size: 0.85rem; color: #64748b;">
                    <div style="text-align: center; padding: 40px; color: #94a3b8;">
                        <i class="fas fa-info-circle" style="font-size: 2rem; margin-bottom: 12px; display: block;"></i>
                        <spring:message code="msg.dbclicktobrowse" text="Double-click a table to browse data"/>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        history.replaceState({}, null, null);

        $('#ArcTables tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();

            var tr = $(this);
            var td = tr.children();
            var elementForm = $("#searchForm");

            if (isEmpty($('#searchForm [name="custid"]').val())) {
                alert("<spring:message code="msg.selectcustno" text="Select custno to browse!"/>");
                return;
            }

            $("#modify_result").html('<div style="text-align: center; padding: 40px;"><i class="fas fa-spinner fa-spin" style="font-size: 2rem; color: #6366f1;"></i><div style="margin-top: 12px; color: #64748b;">Processing...</div></div>');

            $('#searchForm [name="db"]').val(td.eq(0).text().trim());
            $('#searchForm [name="owner"]').val(td.eq(1).text().trim());
            $('#searchForm [name="table_name"]').val(td.eq(2).text().trim());
            $('#searchForm [name="runtype"]').val("SELECT");

            var formSerializeArray = elementForm.serializeArray();
            var object = {};
            for (var i = 0; i < formSerializeArray.length; i++) {
                object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
            }

            $.ajax({
                type: "POST",
                url: "/piirestore/arccustbrowse",
                dataType: "text",
                data: JSON.stringify(object),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (result) {
                    $("#modify_result").html(result);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html("<spring:message code="msg.connectiontesterror" text="Check the connection information!"/>");
                    $("#errormodal").modal("show");
                }
            });
        });
    });
</script>
