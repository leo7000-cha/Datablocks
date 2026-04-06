<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${pageMaker.cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${pageMaker.cri.search2}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-file-contract"></i>
            <span><spring:message code="memu.policy" text="Policy Management"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.task_configuration" text="Task"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.policy" text="Policy"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <div class="policy-filter-grid">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.policy_id" text="Policy ID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1" name="search1"
                           placeholder="Policy ID" value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.policy_name" text="Policy Name"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2"
                           placeholder="Policy Name" value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <sec:authorize access="hasAnyRole('ROLE_SEC','ROLE_BIZ','ROLE_ADMIN')">
                    <button data-oper='register' class="btn btn-filter-register">
                        <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                    </button>
                </sec:authorize>
            </div>
        </div>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable">
                <thead>
                <tr>
                    <th><spring:message code="col.policy_id" text="Policy ID"/></th>
                    <th><spring:message code="col.policy_name" text="Policy Name"/></th>
                    <th class="text-center"><spring:message code="col.version" text="Ver"/></th>
                    <th class="text-center"><spring:message code="col.phase" text="Phase"/></th>
                    <th class="text-center"><spring:message code="col.status" text="Status"/></th>
                    <th class="text-center"><spring:message code="col.del_deadline" text="Del Deadline"/></th>
                    <th class="text-center"><spring:message code="col.archive_flag" text="Archive"/></th>
                    <th class="text-center"><spring:message code="col.arc_del_deadline" text="Arc Deadline"/></th>
                    <th><spring:message code="col.related_law" text="Related Law"/></th>
                    <th><spring:message code="col.comments" text="Comments"/></th>
                    <th class="text-center"><spring:message code="col.regdate" text="Reg Date"/></th>
                    <th class="text-center"><spring:message code="col.reguserid" text="Reg User"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piipolicy">
                    <tr data-phase="${piipolicy.phase}">
                        <td><span class="cell-policy-id"><c:out value="${piipolicy.policy_id}"/></span></td>
                        <td><span class="cell-policy-name"><c:out value="${piipolicy.policy_name}"/></span></td>
                        <td class="text-center"><span class="cell-version"><c:out value="${piipolicy.version}"/></span></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piipolicy.phase eq 'CHECKOUT'}">
                                    <span class="policy-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> CHECKOUT</span>
                                </c:when>
                                <c:when test="${piipolicy.phase eq 'CHECKIN'}">
                                    <span class="policy-badge badge-phase-checkin"><i class="fas fa-lock"></i> CHECKIN</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-phase-default"><i class="fas fa-check-circle"></i> <c:out value="${piipolicy.phase}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piipolicy.status eq 'ACTIVE'}">
                                    <span class="policy-badge badge-status-active">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-status-inactive"><c:out value="${piipolicy.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <span class="cell-deadline">
                                <c:out value="${piipolicy.del_deadline}"/>
                                <c:choose>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'Y'}"><spring:message code="etc.year" text="Year"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'M'}"><spring:message code="etc.month" text="Month"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'D'}"><spring:message code="etc.day" text="Day"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'D_BIZ'}"><spring:message code="etc.day_biz" text="Biz Day"/></c:when>
                                </c:choose>
                            </span>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piipolicy.archive_flag eq 'Y'}">
                                    <span class="policy-badge badge-archive-yes">Y</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-archive-no">N</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <span class="cell-deadline">
                                <c:out value="${piipolicy.arc_del_deadline}"/>
                                <c:choose>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'Y'}"><spring:message code="etc.year" text="Year"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'M'}"><spring:message code="etc.month" text="Month"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'D'}"><spring:message code="etc.day" text="Day"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'D_BIZ'}"><spring:message code="etc.day_biz" text="Biz Day"/></c:when>
                                </c:choose>
                            </span>
                        </td>
                        <td><span class="cell-law"><c:out value="${piipolicy.related_law}"/></span></td>
                        <td><span class="cell-comments"><c:out value="${piipolicy.comments}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piipolicy.regdate}"/></span></td>
                        <td class="text-center"><span class="cell-user"><c:out value="${piipolicy.reguserid}"/></span></td>
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

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Double-click row to view details
        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var td = $(this).children();
            var policy_id = td.eq(0).text().trim();
            var version = td.eq(2).text().trim();
            var phase = $(this).data('phase');
            var serchkeyno = "policy_id=" + policy_id + "&version=" + version;

            // CHECKOUT 상태면 modify로, 아니면 get으로 이동
            if (phase === 'CHECKOUT') {
                goToModify(policy_id, version);
            } else {
                searchAction(null, serchkeyno);
            }
        });

        // Search button
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        // Register button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#content_home').load("/piipolicy/register");
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var search1 = $('#filter_search1').val() || '';
        var search2 = $('#filter_search2').val() || '';
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }

        var pagenum = pageNo || 1;
        var amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + encodeURIComponent(search2);

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piipolicy/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    goToModify = function (policy_id, version) {
        var search1 = $('#filter_search1').val() || '';
        var search2 = $('#filter_search2').val() || '';
        var url_search = "";

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + encodeURIComponent(search2);

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piipolicy/modify?policy_id=" + policy_id + "&version=" + version + "&pagenum=1&amount=100" + url_search,
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
