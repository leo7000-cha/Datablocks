<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<c:set var="siteUpperCase" value="${fn:toUpperCase(site)}" />

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${pageMaker.cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${pageMaker.cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${pageMaker.cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${pageMaker.cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${pageMaker.cri.search5}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-list-ul"></i>
            <span><spring:message code="memu.restore_apply_list" text="Restore List"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.restore_browse" text="Restore"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.restore_apply_list" text="List"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                <div class="policy-filter-item" style="width: 120px;">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.custid" text="CustID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1"
                           placeholder="CustID" value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="width: 120px;">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.cust_nm" text="Custname"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2"
                           placeholder="Custname" value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="width: 120px;">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.birth_dt" text="Birthdate"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search3"
                           placeholder="YYYYMMDD" value='<c:out value="${pageMaker.cri.search3}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                    <div class="policy-filter-item" style="width: 120px;">
                        <label class="policy-filter-label" for="filter_search5"><spring:message code="col.cust_pin" text="Cust_pin"/></label>
                        <input type="text" class="policy-filter-input" id="filter_search5"
                               placeholder="Cust Pin" value='<c:out value="${pageMaker.cri.search5}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                    </div>
                </c:if>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
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
                    <th class="text-center" style="width:70px;"><spring:message code="col.restoreid" text="Restoreid"/></th>
                    <th class="text-center" style="width:80px;"><spring:message code="etc.apply_type" text="Apply_type"/></th>
                    <th class="text-center" style="width:80px;"><spring:message code="col.custid" text="Custid"/></th>
                    <th style="width:120px;"><spring:message code="col.cust_nm" text="Cust_Nm"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.birth_dt" text="birth_dt"/></th>
                    <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                        <th class="text-center" style="width:100px;"><spring:message code="col.cust_pin" text="Cust_Pin"/></th>
                    </c:if>
                    <th class="text-center" style="width:80px;"><spring:message code="etc.restore_orderid" text="New_orderid"/></th>
                    <th class="text-center" style="width:100px;"><spring:message code="col.browse_deadline_dt" text="Browse_deadline"/></th>
                    <th class="text-center" style="width:140px;"><spring:message code="col.status" text="Status"/></th>
                    <th class="text-center" style="width:100px;"><spring:message code="col.approvedate" text="Approvedate"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="etc.old_basedate" text="Basedate"/></th>
                    <th class="text-center" style="width:130px;"><spring:message code="col.restore_Datetime" text="Restore_Datetime"/></th>
                    <th style="width:90px;"><spring:message code="col.requesterid" text="Requesterid"/></th>
                    <th style="width:90px;"><spring:message code="col.requestername" text="Requestername"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piirestore">
                    <tr>
                        <td class="text-center"><span class="cell-policy-id"><c:out value="${piirestore.restoreid}"/></span></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piirestore.apply_type eq 'RESTORE'}">
                                    <span class="policy-badge badge-phase-checkin"><i class="fas fa-undo-alt"></i> <spring:message code="etc.cust_apply_restore" text="Restore"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-phase-checkout"><i class="fas fa-eye"></i> <spring:message code="etc.cust_apply_browse" text="Browse"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><c:out value="${piirestore.custid}"/></td>
                        <td><c:out value="${piirestore.cust_nm}"/></td>
                        <td class="text-center"><c:out value="${piirestore.birth_dt}"/></td>
                        <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                            <td class="text-center"><c:out value="${piirestore.cust_pin}"/></td>
                        </c:if>
                        <td class="text-center">
                            <c:if test="${piirestore.new_orderid != 0}">
                                <c:out value="${piirestore.new_orderid}"/>
                            </c:if>
                        </td>
                        <td class="text-center">
                            <c:if test="${piirestore.status eq 'APPROVED_BROWSE'}">
                                <c:out value="${piirestore.browse_deadline_dt}"/>
                            </c:if>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piirestore.status eq 'Ended OK'}">
                                    <span class="policy-badge badge-status-active"><i class="fas fa-check-circle"></i> <spring:message code="etc.restored" text="Restored"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'Ended not OK'}">
                                    <span class="policy-badge" style="background:#fee2e2; color:#dc2626;"><i class="fas fa-times-circle"></i> Error</span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'REJECTED'}">
                                    <span class="policy-badge badge-status-inactive"><i class="fas fa-ban"></i> <spring:message code="etc.rejected" text="Rejected"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'Running'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-spinner fa-spin"></i> <c:out value="${piirestore.status}"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'Wait condition'}">
                                    <span class="policy-badge" style="background:#f1f5f9; color:#64748b;"><i class="fas fa-clock"></i> Wait</span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'ORDERED'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-check"></i> <spring:message code="etc.approved" text="Approved"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'APPROVED_BROWSE'}">
                                    <span class="policy-badge badge-status-active"><i class="fas fa-check"></i> <spring:message code="etc.approved_browse" text="Approved_browse"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'APPLY'}">
                                    <span class="policy-badge badge-phase-default"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.approving" text="Approval in progress"/></span>
                                </c:when>
                                <c:when test="${piirestore.status eq 'NEW'}">
                                    <span class="policy-badge" style="background:#f1f5f9; color:#64748b;"><spring:message code="etc.approving" text="Approval in progress"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge" style="background:#f8fafc; color:#64748b;"><c:out value="${piirestore.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piirestore.approve_date}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piirestore.basedate}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piirestore.regdate}"/></span></td>
                        <td><span class="cell-user"><c:out value="${piirestore.reguserid}"/></span></td>
                        <td><span class="cell-user"><c:out value="${piirestore.upduserid}"/></span></td>
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

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

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

        // Table row click to view details (optional enhancement)
        $("#listTable tbody tr").on("click", function() {
            $(this).addClass("selected").siblings().removeClass("selected");
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#filter_search5').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piirestore/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    diologDetailAction = function (orderid, jobid, version, jobname) {
        $.ajax({
            type: "GET",
            url: encodeURI("/piiorder/getorderdetail?" + "orderid=" + orderid + "&jobid=" + jobid + "&version=" + version + "&stepseq=" + "1"),
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#jobdetailheader').html(jobid);
                $('#jobdetailbody').html(data);
                $("#jobdetailmodal").modal();
                $("#" + "1").addClass("active");
            }
        });
    }
</script>
