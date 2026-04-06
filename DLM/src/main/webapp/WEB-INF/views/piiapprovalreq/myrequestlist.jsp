<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-paper-plane"></i>
            <span><spring:message code="memu.approval_request" text="My Approval Requests"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.approval_management" text="Approval"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.approval_request" text="My Requests"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 16px; flex: 1; align-items: flex-end;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.requesterid" text="Requester"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1" name="search1" style="width: 120px;" readonly
                           value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_arlist();}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.approverid" text="Approver"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2" style="width: 120px;"
                           value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_arlist();}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.phase" text="Phase"/></label>
                    <select class="policy-filter-select" id="filter_search3" name="search3" style="width: 140px;">
                        <option value=""></option>
                        <option value="APPLY" <c:if test="${pageMaker.cri.search3 eq 'APPLY'}">selected</c:if>>
                            <spring:message code="etc.approval_apply" text="Wait approval"/>
                        </option>
                        <option value="FINAL_APPROVAL" <c:if test="${pageMaker.cri.search3 eq 'FINAL_APPROVAL'}">selected</c:if>>
                            <spring:message code="etc.final_approved" text="Final Approved"/>
                        </option>
                        <option value="APPROVED" <c:if test="${pageMaker.cri.search3 eq 'APPROVED'}">selected</c:if>>
                            <spring:message code="etc.phase_approved" text="Phase Approved"/>
                        </option>
                        <option value="REJECTED" <c:if test="${pageMaker.cri.search3 eq 'REJECTED'}">selected</c:if>>
                            <spring:message code="etc.rejected" text="Rejected"/>
                        </option>
                    </select>
                </div>
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
                    <th><spring:message code="col.reqid" text="Reqid"/></th>
                    <th><spring:message code="col.aprvlineid" text="Approval Line"/></th>
                    <th><spring:message code="col.approvallinestep" text="Step"/></th>
                    <th><spring:message code="col.approval_status" text="Status"/></th>
                    <th colspan="2"><spring:message code="etc.apply_detail_info" text="Details"/></th>
                    <th><spring:message code="col.approverid" text="Approverid"/></th>
                    <th><spring:message code="col.approvername" text="Approvername"/></th>
                    <th><spring:message code="col.reqdate" text="Apply date"/></th>
                    <th><spring:message code="col.approvedate" text="Approval Date"/></th>
                    <th><spring:message code="col.reqreason" text="Reqreason"/></th>
                </tr>
                </thead>
                <tbody id="appvallist-body">
                <c:forEach items="${list}" var="piiapprovalreq">
                    <tr>
                        <td class="text-right"><c:out value="${piiapprovalreq.reqid}"/></td>
                        <td><c:out value="${piiapprovalreq.aprvlineid}"/></td>
                        <td class="text-center"><c:out value="${piiapprovalreq.seq}"/></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiapprovalreq.phase eq 'FINAL_APPROVAL'}">
                                    <span class="badge badge-success" style="font-size: 11px;"><spring:message code="etc.final_approved" text="Final Approved"/></span>
                                </c:when>
                                <c:when test="${piiapprovalreq.phase eq 'APPROVED'}">
                                    <span class="badge badge-primary" style="font-size: 11px;"><spring:message code="etc.phase_approved" text="Phase Approved"/></span>
                                </c:when>
                                <c:when test="${piiapprovalreq.phase eq 'REJECTED'}">
                                    <span class="badge badge-dark" style="font-size: 11px;"><spring:message code="etc.rejected" text="Rejected"/></span>
                                </c:when>
                                <c:when test="${piiapprovalreq.phase eq 'APPLY'}">
                                    <span class="badge badge-info" style="font-size: 11px;"><spring:message code="etc.approval_apply" text="Wait approval"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-light" style="font-size: 11px;"><c:out value="${piiapprovalreq.phase}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <c:choose>
                            <c:when test="${piiapprovalreq.approvalid eq 'REPORT_APPROVAL'}">
                                <td colspan="2">
                                    <a href="javascript:searchAction_detailrequest('${piiapprovalreq.report_type}','${piiapprovalreq.date_from}','${piiapprovalreq.date_to}','${piiapprovalreq.val1}','${piiapprovalreq.val2}','${piiapprovalreq.val3}','${piiapprovalreq.apply_date}','${piiapprovalreq.apply_userid}')">
                                        <i class='fas fa-search-plus'></i>
                                        <spring:message code="etc.report_detail" text="Report details"/>
                                    </a>
                                </td>
                            </c:when>
                            <c:otherwise>
                                <td><c:out value="${piiapprovalreq.jobid}"/></td>
                                <td class="text-center"><c:out value="${piiapprovalreq.version}"/></td>
                            </c:otherwise>
                        </c:choose>
                        <td><c:out value="${piiapprovalreq.approverid}"/></td>
                        <td><c:out value="${piiapprovalreq.approvername}"/></td>
                        <td class="text-center"><c:out value="${piiapprovalreq.regdate}"/></td>
                        <td class="text-center">
                            <c:if test="${piiapprovalreq.phase ne 'APPLY'}">
                                <c:out value="${piiapprovalreq.upddate}"/>
                            </c:if>
                        </td>
                        <td>
                            <c:set var="reqreason" value="${piiapprovalreq.reqreason}"/>
                            <a href="javascript:seeDetailreason('${piiapprovalreq.reqid}')">
                                ${fn:substring(reqreason,0,50)}
                            </a>
                            <input type="hidden" class="form-control form-control-sm"
                                   id="myrequest_${piiapprovalreq.reqid}"
                                   value='<c:out value="${piiapprovalreq.reqreason}"/>'>
                        </td>
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

<!-- Detail Reason Modal -->
<div class="modal fade" id="detailreasondlg_myrequest" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">
                    <i class='fas fa-search-plus'></i> <spring:message code="msg.reasonforapplication" text="Details Reason for application"/>
                </h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="detailreasondlg_myrequest_modalbody">
                <textarea spellcheck="false" rows="15" class="form-control form-control-sm" name='detail_reason' id='detail_reason'></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Detail Request Modal -->
<div class="modal fade" id="detailrequest" role="dialog" style="width:65%;">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" id="detailrequestmodalbody"></div>
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

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction_arlist();
        });

        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#content_home').load("/piiapprovalreq/register");
        });
    });

    seeDetailreason = function (reqid) {
        $("#detailreasondlg_myrequest").modal();
        $("#detail_reason").val($("#myrequest_" + reqid).val());
    };

    movePage = function (pageNo) {
        searchAction_arlist(pageNo);
    }

    searchAction_arlist = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "myrequestlist?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiapprovalreq/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    moveToApprover = function (serchkeyno1) {
        var serchkeyno = "reqid=" + serchkeyno1;
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var url_search = "";
        var url_view = isEmpty(serchkeyno) ? "list?" : "modify?" + serchkeyno + "&";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;

        $.ajax({
            type: "GET",
            url: "/piiapprovalreq/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    diologAction_Job = function (serchkeyno1, serchkeyno2) {
        var serchkeyno = "jobid=" + serchkeyno1 + "&version=" + serchkeyno2;
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var url_search = "";
        var url_view = isEmpty(serchkeyno) ? "list?" : "get?" + serchkeyno + "&";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

        $.ajax({
            type: "GET",
            url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    diologAction_Policy = function (serchkeyno1, serchkeyno2) {
        var serchkeyno = "policy_id=" + serchkeyno1 + "&version=" + serchkeyno2;
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var url_search = "";
        var url_view = isEmpty(serchkeyno) ? "list?" : "get?" + serchkeyno + "&";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

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

    diologAction_Restore = function (serchkeyno1, serchkeyno2) {
        var pagenum = 1;
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = serchkeyno2;
        var url_search = "";
        var url_view = "list?";

        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;

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

    searchAction_detailrequest = function (report_type, date_from, date_to, val1, val2, val3, apply_date, apply_userid) {
        var pagenum = 1;
        var amount = 100;
        var search4 = date_from;
        var search5 = date_to;
        var search6 = report_type;
        var search9 = "DIALOG";

        var url_search = "";
        var url_view = "custstatlist?";

        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        url_search += "&search9=" + search9;

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
                $('#detailrequest').html(data);
                $("#detailrequest").modal();
            }
        });
    }
</script>
