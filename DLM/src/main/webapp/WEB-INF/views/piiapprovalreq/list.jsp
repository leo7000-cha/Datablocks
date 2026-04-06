<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
    pageContext.setAttribute("br", "<br/>");
    pageContext.setAttribute("cn", "\n");
%>

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
            <i class="fas fa-inbox"></i>
            <span><spring:message code="memu.approval_wait" text="Approval Inbox"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.approval_management" text="Approval"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.approval_wait" text="Inbox"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 16px; flex: 1; align-items: flex-end;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.requesterid" text="Requester"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1" name="search1" style="width: 120px;"
                           value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_arlist();}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.approverid" text="Approver"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2" style="width: 120px;" readonly
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
                <button data-oper='approve' class="btn btn-filter-action-important" id="btnApprove" disabled>
                    <i class="fas fa-check-circle"></i> <span><spring:message code="etc.approve" text="Approve"/></span>
                </button>
                <button data-oper='reject' class="btn btn-filter-reject" id="btnReject" disabled>
                    <i class="fas fa-times-circle"></i> <spring:message code="etc.reject" text="Reject"/>
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
                    <th style="width: 40px;"><input type="checkbox" class="chkBox" id="checkall" style="vertical-align:middle;width:15px;height:15px;"></th>
                    <th><spring:message code="col.reqid" text="Reqid"/></th>
                    <th><spring:message code="col.aprvlineid" text="Approval Line"/></th>
                    <th><spring:message code="col.approvallinestep" text="Step"/></th>
                    <th class="th-hidden"><spring:message code="col.approvalid" text="Approvalid"/></th>
                    <th><spring:message code="col.approval_status" text="Status"/></th>
                    <th colspan="2"><spring:message code="etc.apply_detail_info" text="Details"/></th>
                    <th><spring:message code="col.requesterid" text="Requesterid"/></th>
                    <th><spring:message code="col.requestername" text="Requestername"/></th>
                    <th><spring:message code="col.reqdate" text="Apply date"/></th>
                    <th><spring:message code="col.approvedate" text="Approval Date"/></th>
                    <th><spring:message code="col.reqreason" text="Reqreason"/></th>
                </tr>
                </thead>
                <tbody id="appvallist-body">
                <c:forEach items="${list}" var="piiapprovalreq">
                    <tr>
                        <td class="text-center">
                            <c:if test="${piiapprovalreq.phase eq 'APPLY'}">
                                <input type="checkbox" class="chkBox" name="chkBox" onClick="checkedRowColorChange();"
                                       style="vertical-align:middle;width:15px;height:15px;">
                            </c:if>
                        </td>
                        <td class="text-right"><c:out value="${piiapprovalreq.reqid}"/></td>
                        <td><c:out value="${piiapprovalreq.aprvlineid}"/></td>
                        <td class="text-center"><c:out value="${piiapprovalreq.seq}"/></td>
                        <td class="td-hidden"><c:out value="${piiapprovalreq.approvalid}"/></td>
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
                                    <span class="badge badge-warning" style="font-size: 11px;"><spring:message code="etc.approval_apply" text="Wait approval"/></span>
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
                        <td><c:out value="${piiapprovalreq.requesterid}"/></td>
                        <td><c:out value="${piiapprovalreq.requestername}"/></td>
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
<div class="modal fade" id="detailreason" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">
                    <i class='fas fa-search-plus'></i> <spring:message code="msg.reasonforapplication" text="Details Reason for application"/>
                </h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="detailreasonmodalbody">
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
        let result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
            checkedRowColorChange();
        });

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

    function checkedRowColorChange() {
        jQuery("#appvallist-body > tr").css("background-color", "#FFFFFF");
        let checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#E2E8F9");
        });

        // Enable/disable approve and reject buttons based on selection
        if (checkbox.length > 0) {
            $("#btnApprove").prop("disabled", false);
            $("#btnReject").prop("disabled", false);
        } else {
            $("#btnApprove").prop("disabled", true);
            $("#btnReject").prop("disabled", true);
        }
    }

    seeDetailreason = function (reqid) {
        $("#detailreason").modal();
        $("#detail_reason").val($("#myrequest_" + reqid).val());
    };

    movePage = function (pageNo) {
        searchAction_arlist(pageNo);
    }

    searchAction_arlist = function (pageNo, serchkeyno, e) {
        if (e && typeof e.preventDefault === 'function') {
            e.preventDefault();
            e.stopPropagation();
        }
        ingShow();
        let pagenum = $('#searchForm [name="pagenum"]').val();
        let amount = $('#searchForm [name="amount"]').val();
        let search1 = $('#filter_search1').val();
        let search2 = $('#filter_search2').val();
        let search3 = $('#filter_search3').val();
        let url_search = "";
        let url_view = "";

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

    $("button[data-oper='approve']").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        let param = [];
        let tr, td;
        let checkedcnt = 0;
        let checkbox = $("input:checkbox[name=chkBox]:checked");

        checkbox.each(function (i) {
            checkedcnt = 1;
        });

        if (checkedcnt == 0) {
            alert("<spring:message code="msg.selecttosend" text="Select to process"/>");
            return;
        }

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            let data = {
                reqid: td.eq(1).text(),
                aprvlineid: td.eq(2).text(),
                seq: td.eq(3).text(),
                approvalid: td.eq(4).text(),
                phase: td.eq(5).text(),
                jobid: td.eq(6).text(),
                version: td.eq(7).text(),
                requesterid: td.eq(8).text(),
                requestername: td.eq(9).text(),
                regdate: "1",
                upddate: td.eq(10).text(),
                reqreason: td.eq(11).text()
            };
            param.push(data);
        });

        $.ajax({
            url: "/piiapprovalreq/approve",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {
                ingHide();
                $('#content_home').html(data);
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    });

    $("button[data-oper='reject']").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        let param = [];
        let tr, td;
        let checkbox = $("input:checkbox[name=chkBox]:checked");

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            let data = {
                reqid: td.eq(1).text(),
                aprvlineid: td.eq(2).text(),
                seq: td.eq(3).text(),
                approvalid: td.eq(4).text(),
                phase: td.eq(5).text(),
                jobid: td.eq(6).text(),
                version: td.eq(7).text(),
                requesterid: td.eq(8).text(),
                requestername: td.eq(9).text(),
                regdate: "1",
                upddate: td.eq(10).text(),
                reqreason: td.eq(11).text()
            };
            param.push(data);
        });

        $.ajax({
            url: "/piiapprovalreq/reject",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {
                ingHide();
                $('#content_home').html(data);
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    });

    diologAction_Job = function (serchkeyno1, serchkeyno2) {
        let serchkeyno = "jobid=" + serchkeyno1 + "&version=" + serchkeyno2;
        let pagenum = 1;
        let amount = $('#searchForm [name="amount"]').val();
        let search1 = $('#filter_search1').val();
        let search2 = $('#filter_search2').val();
        let url_search = "";
        let url_view = isEmpty(serchkeyno) ? "list?" : "get?" + serchkeyno + "&";

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
        let serchkeyno = "policy_id=" + serchkeyno1 + "&version=" + serchkeyno2;
        let pagenum = 1;
        let amount = $('#searchForm [name="amount"]').val();
        let search1 = $('#filter_search1').val();
        let search2 = $('#filter_search2').val();
        let url_search = "";
        let url_view = isEmpty(serchkeyno) ? "list?" : "get?" + serchkeyno + "&";

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
        let pagenum = 1;
        let amount = $('#searchForm [name="amount"]').val();
        let search1 = serchkeyno2;
        let url_search = "";
        let url_view = "list?";

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
        let pagenum = 1;
        let amount = 100000;
        let search2 = (report_type == "REAL_DOC_REPORT") ? val1 : null;
        let search4 = date_from;
        let search5 = date_to;
        let search6 = report_type;
        let search9 = "DIALOG";

        let url_search = "";
        let url_view = "";

        if (report_type == "MONTHLY" || report_type == "QUARTERLY" || report_type == "MONTHLY_CONSENT") {
            url_view = "/piiextract/custstatlist?";
        } else if (report_type == "REAL_DOC_REPORT") {
            url_view = "/piicontract/statlist?";
        }

        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        url_search += "&search9=" + search9;

        $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
