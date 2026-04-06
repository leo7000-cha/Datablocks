<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script src="resources/js/bootstrap-datepicker.min.js"></script>
<script src="resources/js/bootstrap-datepicker.ko.min.js"></script>
<link href="resources/css/bootstrap-datepicker.css" rel="stylesheet">

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search5' value=''>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-table"></i>
            <span><spring:message code="memu.table_del_stat" text="Table Purge Report"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.report" text="Report"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.table_del_stat" text="Table Purge"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <div class="policy-filter-grid">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.system" text="System"/></label>
                    <select class="policy-filter-select" name="search1" id="filter_search1"
                            onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <option value=""></option>
                        <c:forEach items="${listsystem}" var="piisystem">
                            <c:if test="${'ARCHIVE_DB' ne piisystem.system_id && 'DLM' ne piisystem.system_id}">
                                <option value="<c:out value="${piisystem.system_id}"/>"
                                        <c:if test="${pageMaker.cri.search1 eq piisystem.system_id}">selected</c:if>>
                                    <c:out value="${piisystem.system_name}"/>
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="policy-filter-item" style="grid-column: span 2;">
                    <label class="policy-filter-label" for="filter_search2">JOBID</label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2"
                           value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.basedate" text="Date"/></label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <input type="text" class="policy-filter-input" id="filter_search3" name="search3" style="width: 120px;"
                               placeholder="YYYY/MM/DD" maxlength="10"
                               value='<c:out value="${pageMaker.cri.search3}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <span class="policy-filter-separator">~</span>
                        <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 120px;"
                               placeholder="YYYY/MM/DD" maxlength="10"
                               value='<c:out value="${pageMaker.cri.search4}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                    </div>
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <button data-oper='exceldownload' class="btn btn-filter-excel">
                    <i class="fas fa-download"></i> <spring:message code="btn.excel" text="EXCEL"/>
                </button>
            </div>
        </div>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable">
                <thead>
                <tr>
                    <th><spring:message code="col.system" text="System"/></th>
                    <th>JOBID</th>
                    <th><spring:message code="etc.pii_reason" text="PII reason"/></th>
                    <th>DB</th>
                    <th>OWNER</th>
                    <th>TABLE_NAME</th>
                    <th class="text-right"><spring:message code="etc.del_cnt" text="Delcnt"/></th>
                    <th class="text-right"><spring:message code="etc.archive_cnt" text="Arccnt"/></th>
                    <th class="text-right"><spring:message code="etc.arc_del_cnt" text="ArcDelcnt"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piiorderreport">
                    <tr>
                        <td><c:out value="${piiorderreport.system}"/></td>
                        <td><c:out value="${piiorderreport.jobid}"/></td>
                        <td>
                            <c:if test="${'PII_POLICY1' eq fn:substring(piiorderreport.jobid,0,11)}"><spring:message code="etc.policy1_title" text="Only sign up customer"/></c:if>
                            <c:if test="${'PII_POLICY2' eq fn:substring(piiorderreport.jobid,0,11)}"><spring:message code="etc.policy2_title" text="Unconfirmed customer"/></c:if>
                            <c:if test="${'PII_POLICY3' eq fn:substring(piiorderreport.jobid,0,11)}"><spring:message code="etc.policy3_title" text="Termination of transaction customer"/></c:if>
                        </td>
                        <td><c:out value="${piiorderreport.db}"/></td>
                        <td><c:out value="${piiorderreport.owner}"/></td>
                        <td><c:out value="${piiorderreport.table_name}"/></td>
                        <td class="text-right"><fmt:formatNumber value="${piiorderreport.delcnt}" pattern="#,###"/></td>
                        <td class="text-right"><fmt:formatNumber value="${piiorderreport.arccnt}" pattern="#,###"/></td>
                        <td class="text-right"><fmt:formatNumber value="${piiorderreport.delarccnt}" pattern="#,###"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <div class="policy-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<form style="margin: 0; padding: 0;" id="form1" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>

<script type="text/javascript">
    function doExcelDownload() {
        var f = document.form1;
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val().replace(/-/g, "/");
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val();

        var url_search = "";
        var pagenum = 1;
        var amount = 10000;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;

        f.action = "/piiupload/download_table_del_stat?pagenum=" + pagenum + "&amount=" + amount + url_search;
        f.submit();
    }
</script>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        $("button[data-oper='exceldownload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doExcelDownload();
        });
    });

    // Flatpickr for date pickers
    flatpickr("#filter_search3", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search4", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val().replace(/-/g, "/");
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val();
        var search5 = $('#searchForm [name="search5"]').val();

        var url_search = "";
        var url_view = "report?";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 1000;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#content_home').html(data);
            }
        });
    }

    diologAction = function (serchkeyno1) {
        var serchkeyno = "orderid=" + serchkeyno1;
        doubleSubmitFlag = true;
        $("#actionmodal").modal();
        return;
    }
</script>
