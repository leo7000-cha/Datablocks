<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">
<link href="/resources/vendor/bootstrap-datepicker/css/bootstrap-datepicker.min.css" rel="stylesheet">

<style>
/* Master Key Detail Modal Header */
#masterkeydetailmodal .modal-header.modal-wizard {
    background: linear-gradient(135deg, #4f46e5 0%, #6366f1 50%, #818cf8 100%);
    padding: 14px 20px;
    border-bottom: none;
}

#masterkeydetailmodal .modal-header.modal-wizard .modal-title {
    color: #fff;
    font-weight: 600;
    font-size: 1rem;
}

#masterkeydetailmodal .modal-header.modal-wizard .close {
    color: #fff;
    opacity: 0.8;
    text-shadow: none;
}

#masterkeydetailmodal .modal-header.modal-wizard .close:hover {
    opacity: 1;
}

/* 파기 예정일 셀 - 충돌 방지용 고유 스타일 */
#listTable td.td-disposal-sche {
    vertical-align: middle !important;
    text-align: center !important;
}
#listTable td.td-disposal-sche .cell-date,
#listTable td.td-disposal-sche input {
    vertical-align: middle !important;
}
</style>

<c:set var="siteUpperCase" value="${fn:toUpperCase(site)}"/>

<!-- Hidden Form -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${pageMaker.cri.search4}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-clipboard-list"></i>
            <span><spring:message code="memu.testdata_apply_list" text="My Requests"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.testdata" text="Test Data"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.testdata_apply_list" text="My Requests"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                <div class="policy-filter-item" style="width: 140px;">
                    <label class="policy-filter-label" for="search1"><spring:message code="etc.apply_custid" text="CustID"/></label>
                    <input type="text" class="policy-filter-input" id="search1" name="search1"
                           placeholder="CustID" value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="width: 140px;">
                    <label class="policy-filter-label" for="search2"><spring:message code="col.requesterid" text="Requesterid"/></label>
                    <input type="text" class="policy-filter-input" id="search2" name="search2"
                           placeholder="Requester ID" value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="width: 140px;">
                    <label class="policy-filter-label" for="search3"><spring:message code="col.requestername" text="Requestername"/></label>
                    <input type="text" class="policy-filter-input" id="search3" name="search3"
                           placeholder="Requester Name" value='<c:out value="${pageMaker.cri.search3}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
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
            <table class="policy-table" id="listTable" style="table-layout: fixed; width: 100%;">
                <colgroup>
                    <col style="width: 45px"/>
                    <col style="width: 75px"/>
                    <col style="width: 75px"/>
                    <col style="width: 65px"/>
                    <col style="width: 140px"/>
                    <col style="width: 140px"/>
                    <col style="width: 120px"/>
                    <col style="width: 85px"/>
                    <col style="width: 85px"/>
                    <col style="width: 65px"/>
                    <col style="width: 80px"/>
                    <col style="width: 85px"/>
                    <col style="width: 75px"/>
                </colgroup>
                <thead>
                <tr>
                    <th class="text-center">No</th>
                    <th class="text-center"><spring:message code="col.sourcedb" text="Source DB"/></th>
                    <th class="text-center"><spring:message code="col.targetdb" text="Target DB"/></th>
                    <th><spring:message code="etc.apply_idtype" text="IDtype"/></th>
                    <th><spring:message code="etc.apply_id" text="Apply ID"/> [Prod]</th>
                    <th><spring:message code="etc.new_generated_id" text="New ID"/></th>
                    <th class="text-center"><spring:message code="col.status" text="Status"/></th>
                    <th class="text-center"><spring:message code="etc.disposal_sche_date" text="Sche Date"/></th>
                    <th class="text-center"><spring:message code="etc.disposal_exec_date" text="Exec Date"/></th>
                    <th class="text-center"><spring:message code="col.orderid" text="OrderID"/></th>
                    <th><spring:message code="etc.testdatajobtype" text="Type"/></th>
                    <th class="text-center"><spring:message code="etc.apply_date" text="Apply Date"/></th>
                    <th><spring:message code="col.requester" text="Requester"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="testdata">
                    <tr>
                        <td class="text-center"><c:out value="${testdata.testdataid}"/></td>
                        <td class="text-center">
                            <c:set var="dbenvname" value="${testdata.sourcedb}"/>
                            <c:choose>
                                <c:when test="${fn:contains(dbenvname, 'PRODUCTION-1')}"><span class="cell-date"><spring:message code="etc.productionenv-1day" text="Prod -1Day"/></span></c:when>
                                <c:when test="${fn:contains(dbenvname, 'PRE-PRODUCTION')}"><span class="cell-date"><spring:message code="etc.stagingenv" text="Staging"/></span></c:when>
                                <c:when test="${fn:contains(dbenvname, 'PRODUCTION')}"><span class="cell-date"><spring:message code="etc.productionenv" text="Production"/></span></c:when>
                                <c:when test="${fn:contains(dbenvname, 'DEVELOPMENT')}"><span class="cell-date"><spring:message code="etc.devenv" text="Development"/></span></c:when>
                                <c:otherwise><c:out value="${dbenvname}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:set var="dbenvname" value="${testdata.targetdb}"/>
                            <c:choose>
                                <c:when test="${fn:contains(dbenvname, 'PRE-PRODUCTION')}"><span class="cell-date"><spring:message code="etc.stagingenv" text="Staging"/></span></c:when>
                                <c:when test="${fn:contains(dbenvname, 'DEVELOPMENT')}"><span class="cell-date"><spring:message code="etc.devenv" text="Development"/></span></c:when>
                                <c:otherwise><c:out value="${dbenvname}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td><c:out value="${testdata.idtype}"/></td>
                        <td style="max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${testdata.custid}"/>">
                            <c:out value="${testdata.custid}"/>
                        </td>
                        <td style="max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                            <c:if test="${!empty testdata.custid_new}">
                                <a href="javascript:diologDetailAction('${testdata.testdataid}','${testdata.new_orderid}','${testdata.regdate}','${testdata.targetdb}','${testdata.jobid}')" style="color:#6366f1;" title="<c:out value="${testdata.custid_new}"/>">
                                    <i class="fa-solid fa-magnifying-glass-plus"></i>
                                    <c:out value="${testdata.custid_new}"/>
                                </a>
                            </c:if>
                        </td>
                        <td class="text-center status-cell">
                            <c:choose>
                                <c:when test="${testdata.status eq 'Ended OK'}">
                                    <span class="policy-badge badge-status-active"><i class="fas fa-check-circle"></i> <spring:message code="etc.insertion_complete" text="Completed"/></span>
                                </c:when>
                                <c:when test="${testdata.status eq 'Ended not OK'}">
                                    <span class="policy-badge" style="background:#fee2e2; color:#dc2626;"><i class="fas fa-times-circle"></i> Error</span>
                                </c:when>
                                <c:when test="${testdata.status eq 'REJECTED'}">
                                    <span class="policy-badge badge-status-inactive"><i class="fas fa-ban"></i> <spring:message code="etc.rejected" text="Rejected"/></span>
                                </c:when>
                                <c:when test="${testdata.status eq 'Running'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-spinner fa-spin"></i> Running</span>
                                </c:when>
                                <c:when test="${testdata.status eq 'Wait condition'}">
                                    <span class="policy-badge" style="background:#f1f5f9; color:#64748b;"><i class="fas fa-clock"></i> Wait</span>
                                </c:when>
                                <c:when test="${testdata.status eq 'ORDERED'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-check"></i> <spring:message code="etc.approved" text="Approved"/></span>
                                </c:when>
                                <c:when test="${testdata.status eq 'APPLY' || testdata.status eq 'NEW'}">
                                    <span class="policy-badge badge-phase-default"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.approving" text="Approving"/></span>
                                </c:when>
                                <c:when test="${testdata.status eq 'DISPOSING'}">
                                    <span class="policy-badge" style="background:#fef3c7; color:#d97706;"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.disposing" text="Disposing"/></span>
                                </c:when>
                                <c:when test="${testdata.status eq 'DISPOSED'}">
                                    <span class="policy-badge" style="background:#374151; color:#fff;"><i class="fas fa-trash-alt"></i> <spring:message code="etc.disposed" text="Disposed"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge" style="background:#f8fafc; color:#64748b;"><c:out value="${testdata.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <c:choose>
                            <c:when test="${testdata.status eq 'Ended OK'}">
                                <td class="text-center" data-testid="${testdata.testdataid}">
                                    <span class="editable-date"><c:out value="${testdata.disposal_sche_date}"/></span>
                                </td>
                            </c:when>
                            <c:otherwise>
                                <td class="text-center"><span class="cell-date"><c:out value="${testdata.disposal_sche_date}"/></span></td>
                            </c:otherwise>
                        </c:choose>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${empty testdata.disposal_exec_date and testdata.status eq 'Ended OK'}">
                                    <button type="button" class="btn btn-dispose" data-testid="${testdata.testdataid}"
                                            style="background:transparent; color:#e11d48; padding:3px 8px; border-radius:4px; font-size:0.7rem; font-weight:600; border:1.5px solid #e11d48; cursor:pointer;">
                                        <i class="fas fa-bolt"></i> <spring:message code="testdata.dispose"/>
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <span class="cell-date"><c:out value="${testdata.disposal_exec_date}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:if test="${testdata.new_orderid ne 0}">
                                <a href="javascript:diologDetailOrder('${testdata.new_orderid}', '${testdata.jobid}')" style="color:#6366f1;">
                                    <i class="fa-solid fa-magnifying-glass-plus"></i> <c:out value="${testdata.new_orderid}"/>
                                </a>
                            </c:if>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${fn:contains(testdata.jobid, 'FIXED')}"><spring:message code="testdata.type.fixedid"/></c:when>
                                <c:otherwise><spring:message code="testdata.type.autogen"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><span class="cell-date"><c:out value="${testdata.regdate}"/></span></td>
                        <td><span class="cell-user"><c:out value="${testdata.upduserid}"/></span></td>
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

<!-- Master Key Detail Modal -->
<div class="modal fade" id="masterkeydetailmodal" style="z-index: 1050;">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title" id="masterkeydetailheader">Masterkey mapping details</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body" id="masterkeydetailbody" style="padding: 16px;">
                Loading...
            </div>
        </div>
    </div>
</div>

<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>
<script src="/resources/vendor/bootstrap-datepicker/js/bootstrap-datepicker.min.js"></script>

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

        // Dispose button handler
        $(document).off("click", ".btn-dispose").on("click", ".btn-dispose", function () {
            var clickedButton = $(this);
            var testdataid = $(this).data("testid");

            if (confirm("Are you sure you want to dispose this test data?\nThis action cannot be undone.")) {
                $.ajax({
                    type: "POST",
                    url: "/testdata/disposal/" + testdataid,
                    context: this,
                    beforeSend: function (xhr) {
                        var csrfToken = $("meta[name='_csrf']").attr("content");
                        var csrfHeader = $("meta[name='_csrf_header']").attr("content");
                        if (csrfToken && csrfHeader) {
                            xhr.setRequestHeader(csrfHeader, csrfToken);
                        }
                    },
                    error: function (request, error) {
                        alert("Error: " + request.responseText);
                    },
                    success: function (response) {
                        var disposingStatusHtml = '<span class="policy-badge" style="background:#fef3c7; color:#d97706;"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.disposing" text="Disposing"/></span>';
                        var statusCell = clickedButton.closest('tr').find('.status-cell');
                        statusCell.html(disposingStatusHtml);
                        clickedButton.remove();
                        $("#GlobalSuccessMsgModal").modal("show");
                    }
                });
            }
        });

        // Editable date handler
        $(document).on("click", ".editable-date", function (e) {
            var span = $(this);
            var td = span.closest('td');
            var testdataid = td.data("testid");
            var originalDate = span.text().trim();

            if (td.find('input').length > 0) return;

            var input = $('<input type="text" class="policy-filter-input" style="width: 100%; text-align: center;" />');
            td.html(input);
            input.val(originalDate).focus();

            input.datepicker({
                format: "yyyy/mm/dd",
                autoclose: true,
                todayHighlight: true,
                language: 'ko'
            });

            input.on('changeDate', function (e) {
                var newDate = $(this).val();
                $(this).datepicker('hide');

                if (newDate && newDate !== originalDate) {
                    updateDisposalDate(td, testdataid, newDate, originalDate);
                } else {
                    td.html('<span class="editable-date">' + (originalDate || "") + '</span>');
                }
            });

            input.on('blur', function () {
                setTimeout(function () {
                    if (td.find('input').length > 0) {
                        td.html('<span class="editable-date">' + (originalDate || "") + '</span>');
                    }
                }, 200);
            });

            input.datepicker('show');
        });

        function updateDisposalDate(td, testdataid, newDate, originalDate) {
            $.ajax({
                type: "POST",
                url: "/testdata/updateDisposalScheDate",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({
                    "testdataid": testdataid,
                    "disposalScheDate": newDate
                }),
                beforeSend: function (xhr) {
                    var csrfToken = $("meta[name='_csrf']").attr("content");
                    var csrfHeader = $("meta[name='_csrf_header']").attr("content");
                    if (csrfToken && csrfHeader) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    }
                },
                success: function (response) {
                    td.html('<span class="editable-date">' + newDate + '</span>');
                },
                error: function (request, status, error) {
                    td.html('<span class="editable-date">' + (originalDate || "") + '</span>');
                    alert("Error updating date: " + request.responseText);
                }
            });
        }
    });

    diologDetailOrder = function (orderid, jobid) {
        $.ajax({
            type: "GET",
            url: encodeURI("/piiorder/getorderdetail?orderid=" + orderid + "&jobid=" + jobid + "&version=1&stepseq=4&action=1"),
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#jobdetailheader').html(jobid + " [ORDERID:" + orderid + "]");
                $('#jobdetailbody').html(data);
                $("#jobdetailmodal").modal();
                $("#4").addClass("active");
            }
        });
    };

    movePage = function (pageNo) {
        searchAction(pageNo);
    };

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#search1').val();
        var search2 = $('#search2').val();
        var search3 = $('#search3').val();
        var search4 = $('#searchForm [name="search4"]').val();
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

        ingShow();
        $.ajax({
            type: "GET",
            url: "/testdata/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
    };

    diologDetailAction = function (testdataid, new_orderid, regdate, targetdb, jobid) {
        $.ajax({
            type: "GET",
            url: encodeURI("/testdata/getmasterkeymaplist?testdataid=" + testdataid + "&new_orderid=" + new_orderid),
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#masterkeydetailheader').html("<spring:message code='etc.masterkeydetails' text='Master Key Mapping info'/>");
                $('#masterkeydetailbody').html(data);
                $("#masterkeydetailmodal").modal();
            }
        });
    };
</script>
