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
    <input type='hidden' name='search6' value=''>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-user-clock"></i>
            <span><spring:message code="memu.report_cust_list" text="Customer History"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.report" text="Report"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.report_cust_list" text="Customer"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 12px; flex: 1; align-items: flex-end;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.custid" text="CustID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1" name="search1" style="width: 100px;"
                           value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.cust_nm" text="Custname"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2" style="width: 100px;"
                           value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.birth_dt" text="Birthdate"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search3" name="search3" style="width: 90px;"
                           value='<c:out value="${pageMaker.cri.search3}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search7"><spring:message code="etc.pii_reason" text="PII reason"/></label>
                    <select class="policy-filter-select" id="filter_search7" name="search7" style="width: 140px;"
                            onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <option value=""></option>
                        <c:forEach items="${listpolicy}" var="piipolicy">
                            <option value="<c:out value="${piipolicy.policy_id}"/>"
                                    <c:if test="${pageMaker.cri.search7 eq piipolicy.policy_id}">selected</c:if>>
                                <c:if test="${'PII_POLICY1' eq piipolicy.policy_id}"><spring:message code="etc.policy1_title" text="Only sign up customer"/></c:if>
                                <c:if test="${'PII_POLICY2' eq piipolicy.policy_id}"><spring:message code="etc.policy2_title" text="Unconfirmed customer"/></c:if>
                                <c:if test="${'PII_POLICY3' eq piipolicy.policy_id}"><spring:message code="etc.policy3_title" text="Termination of transaction customer"/></c:if>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search8"><spring:message code="col.pii_status" text="Status"/></label>
                    <select class="policy-filter-select" id="filter_search8" name="search8" style="width: 130px;"
                            onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <option value=""></option>
                        <option value="DELARC" <c:if test="${pageMaker.cri.search8 eq 'DELARC'}">selected</c:if>><spring:message code="etc.delarccompleted" text="Purging Archived Data Completed"/></option>
                        <option value="RESTORE" <c:if test="${pageMaker.cri.search8 eq 'RESTORE'}">selected</c:if>><spring:message code="etc.restored" text="Restored"/></option>
                        <option value="ARCHIVE" <c:if test="${pageMaker.cri.search8 eq 'ARCHIVE'}">selected</c:if>><spring:message code="etc.archived" text="Archived"/></option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search9"><spring:message code="etc.period" text="Period"/></label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <select class="policy-filter-select" id="filter_search9" name="search9" style="width: 160px;">
                            <option value="ARC" <c:if test="${pageMaker.cri.search9 eq 'ARC'}">selected</c:if>><spring:message code="etc.piipurgeperiod" text="PII Purging Period"/></option>
                            <option value="ARCDEL" <c:if test="${pageMaker.cri.search9 eq 'ARCDEL'}">selected</c:if>><spring:message code="etc.delarcperiod" text="Purging Archived Data Period"/></option>
                        </select>
                        <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 90px;"
                               value='<c:out value="${pageMaker.cri.search4}"/>'>
                        <span class="policy-filter-separator">~</span>
                        <input type="text" class="policy-filter-input" id="filter_search5" name="search5" style="width: 90px;"
                               value='<c:out value="${pageMaker.cri.search5}"/>'>
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
        <div class="policy-table-wrapper" style="max-height: 680px; overflow-y: auto;">
            <table class="policy-table multi-row-header" id="listTable">
                <thead>
                <tr>
                    <th rowspan="2"><spring:message code="col.custid" text="Custid"/></th>
                    <th rowspan="2"><spring:message code="col.cust_nm" text="Cust_Nm"/></th>
                    <th rowspan="2"><spring:message code="col.birth_dt" text="Birth_dt"/></th>
                    <th rowspan="2"><spring:message code="col.last_base_date" text="Close date"/></th>
                    <th rowspan="2"><spring:message code="etc.pii_reason" text="PII reason"/></th>
                    <th colspan="6"><spring:message code="etc.del_contents" text="Deleted contents"/></th>
                    <th rowspan="2"><spring:message code="etc.progress_classification" text="Progress classification"/></th>
                    <th rowspan="2"><spring:message code="etc.datatype_br" text="Data type"/></th>
                    <th rowspan="2"><spring:message code="col.archive_date" text="Archive_Date"/></th>
                    <th rowspan="2"><spring:message code="col.delete_date" text="Delete_Date"/></th>
                    <th rowspan="2"><spring:message code="col.restore_date" text="Restore_Date"/></th>
                    <th rowspan="2"><spring:message code="col.expected_arc_del_date_br" text="Expected_Archive_Date"/></th>
                    <th rowspan="2"><spring:message code="col.arc_del_date" text="Arc_del_date"/></th>
                    <th rowspan="2"><spring:message code="etc.person_in_charge_br" text="Person in charge"/></th>
                    <th rowspan="2"><spring:message code="etc.head_in_charge_br" text="Head in charge"/></th>
                </tr>
                <tr>
                    <th><spring:message code="etc.pii_kind1_br" text="Unique identification"/></th>
                    <th><spring:message code="etc.pii_kind2_br" text="General personal"/></th>
                    <th><spring:message code="etc.pii_kind3_br" text="Credit transaction"/></th>
                    <th><spring:message code="etc.pii_kind4_br" text="Credit capability"/></th>
                    <th><spring:message code="etc.pii_kind5_br" text="Credit judgment"/></th>
                    <th><spring:message code="etc.pii_kind6_br" text="Public information, etc."/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piiextract">
                    <tr>
                        <td>
                            <span data-toggle="tooltip" data-placement="right"
                                  title="JOBID : <c:out value="${piiextract.jobid}"/>    ORDERID : <c:out value="${piiextract.orderid}"/>">
                                <c:out value="${piiextract.custid}"/>
                            </span>
                        </td>
                        <td>
                            <span data-toggle="tooltip" data-placement="right"
                                  title="JOBID : <c:out value="${piiextract.jobid}"/>    ORDERID : <c:out value="${piiextract.orderid}"/>">
                                <c:out value="${piiextract.cust_nm}"/>
                            </span>
                        </td>
                        <td class="text-center"><c:out value="${piiextract.birth_dt}"/></td>
                        <td class="text-center"><c:out value="${piiextract.last_base_date}"/></td>
                        <td>
                            <c:if test="${'PII_POLICY1' eq fn:substring(piiextract.jobid,0,11)}"><spring:message code="etc.policy1_title" text="Only sign up customer"/></c:if>
                            <c:if test="${'PII_POLICY2' eq fn:substring(piiextract.jobid,0,11)}"><spring:message code="etc.policy2_title" text="Unconfirmed customer"/></c:if>
                            <c:if test="${'PII_POLICY3' eq fn:substring(piiextract.jobid,0,11)}"><spring:message code="etc.policy3_title" text="Termination of transaction customer"/></c:if>
                        </td>
                        <c:if test="${'PII_POLICY1' eq fn:substring(piiextract.jobid,0,11)}">
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center"></td>
                            <td class="text-center"></td>
                            <td class="text-center"></td>
                            <td class="text-center"></td>
                            <td class="text-center"><spring:message code="etc.customer_registration" text="Customer registration"/></td>
                            <td><spring:message code="etc.customer_registration_file" text="Customer registration files"/></td>
                        </c:if>
                        <c:if test="${'PII_POLICY2' eq fn:substring(piiextract.jobid,0,11)}">
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center"></td>
                            <td class="text-center"><spring:message code="etc.counseling" text="Counseling"/></td>
                            <td><spring:message code="etc.counseling_file" text="Counseling files"/></td>
                        </c:if>
                        <c:if test="${'PII_POLICY3' eq fn:substring(piiextract.jobid,0,11)}">
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center">O</td>
                            <td class="text-center"><spring:message code="etc.contract" text="Contract"/></td>
                            <td><spring:message code="etc.contract_file" text="Contract files"/></td>
                        </c:if>
                        <td class="text-center"><c:out value="${piiextract.archive_date}"/></td>
                        <td class="text-center"><c:out value="${piiextract.delete_date}"/></td>
                        <td class="text-center"><c:out value="${piiextract.restore_date}"/></td>
                        <td class="text-center"><c:out value="${piiextract.expected_arc_del_date}"/></td>
                        <td class="text-center"><c:out value="${piiextract.arc_del_date}"/></td>
                        <td></td>
                        <td></td>
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
    // Sticky header positioning
    $(document).ready(function() {
        var tableHeaderTop = document.querySelector('.policy-table thead');
        if (tableHeaderTop) {
            var ths = document.querySelectorAll('.policy-table thead th');
            for (var i = 0; i < ths.length; i++) {
                var th = ths[i];
                th.style.position = 'sticky';
                th.style.zIndex = '1';
            }
        }
    });

    function doExcelDownload() {
        var f = document.form1;
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();
        var search9 = $('#filter_search9').val();

        if (isEmpty(search1) && isEmpty(search2) && isEmpty(search3) && isEmpty(search4) && isEmpty(search5) && isEmpty(search7)) {
            $("#messagemodalbody").html("<spring:message code="msg.inputsearch" text="Please enter one or more search criteria"/>");
            $("#messagemodal").modal("show");
            return;
        }

        var url_search = "";
        var pagenum = 1;
        var amount = 10000;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;

        f.action = "/piiupload/download_cust_history?pagenum=" + pagenum + "&amount=" + amount + url_search;
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
    flatpickr("#filter_search4", {
        locale: "ko",
        dateFormat: "Y/m/d",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        altInputClass: "policy-filter-input policy-filter-input-sm",
        defaultDate: null,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search5", {
        locale: "ko",
        dateFormat: "Y/m/d",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        altInputClass: "policy-filter-input policy-filter-input-sm",
        defaultDate: null,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = 100;
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();
        var search9 = $('#filter_search9').val();

        var url_search = "";
        var url_view = "list?";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiextract/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
</script>
