<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script src="resources/js/bootstrap-datepicker.min.js"></script>
<script src="resources/js/bootstrap-datepicker.ko.min.js"></script>
<link href="resources/css/bootstrap-datepicker.css" rel="stylesheet">

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
    <input type='hidden' name='search6' value='<c:out value="${pageMaker.cri.search6}"/>'>
    <input type='hidden' name='search7' value='<c:out value="${pageMaker.cri.search7}"/>'>
    <input type='hidden' name='search8' value='<c:out value="${pageMaker.cri.search8}"/>'>
    <input type='hidden' name='applytype'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-plus-circle"></i>
            <span><spring:message code="memu.restore_browse_apply" text="Restore Apply"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.restore_browse" text="Restore"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.restore_browse_apply" text="Apply"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <div class="policy-filter-grid" style="display: flex; gap: 10px; flex: 1;">
                <div class="policy-filter-item" style="min-width: 100px;">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.custid" text="CustID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1"
                           placeholder="CustID" value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="min-width: 100px;">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="col.cust_nm" text="Custname"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search2"
                           placeholder="Custname" value='<c:out value="${pageMaker.cri.search2}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="min-width: 100px;">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.birth_dt" text="Birthdate"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search3"
                           placeholder="YYYYMMDD" value='<c:out value="${pageMaker.cri.search3}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                    <div class="policy-filter-item" style="min-width: 100px;">
                        <label class="policy-filter-label" for="filter_search5"><spring:message code="col.cust_pin" text="Cust_pin"/></label>
                        <input type="text" class="policy-filter-input" id="filter_search5"
                               placeholder="Cust Pin" value='<c:out value="${pageMaker.cri.search5}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                    </div>
                </c:if>
                <div class="policy-filter-item" style="min-width: 110px;">
                    <label class="policy-filter-label" for="filter_search7"><spring:message code="etc.pagi_basedate" text="Basedate"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search7"
                           placeholder="YYYY/MM/DD" value='<c:out value="${pageMaker.cri.search7}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="min-width: 270px;">
                    <label class="policy-filter-label" for="filter_search8"><spring:message code="col.jobid" text="JOBID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search8"
                           placeholder="JOBID" value='<c:out value="${pageMaker.cri.search8}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item" style="min-width: 100px;">
                    <label class="policy-filter-label" for="filter_search6"><spring:message code="col.orderid" text="orderID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search6"
                           placeholder="Order ID" value='<c:out value="${pageMaker.cri.search6}"/>'
                           onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
            </div>
            <div class="policy-filter-actions" style="flex-shrink: 0;">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <button data-oper='restore' class="btn btn-filter-register" id="btnRestore" disabled>
                    <i class="fas fa-undo-alt"></i> <spring:message code="etc.cust_apply_restore" text="Restore"/>
                </button>
                <button data-oper='browse' class="btn btn-filter-browse" id="btnBrowse" disabled>
                    <i class="fas fa-eye"></i> <spring:message code="etc.cust_apply_browse" text="Browse"/>
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
                    <th class="text-center" style="width:40px;"><input type="checkbox" id="checkall" style="width:15px;height:15px;"></th>
                    <th class="text-center" style="width:70px;"><spring:message code="col.orderid" text="ORDERID"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.basedate" text="Basedate"/></th>
                    <th style="width:100px;"><spring:message code="col.jobid" text="JOBID"/></th>
                    <th class="text-center" style="width:45px;"><spring:message code="col.version" text="Ver"/></th>
                    <th style="width:80px;"><spring:message code="col.system" text="System"/></th>
                    <th class="text-center" style="width:70px;"><spring:message code="col.custid" text="CustID"/></th>
                    <th style="width:100px;"><spring:message code="col.cust_nm" text="Cust_Nm"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.birth_dt" text="Birth_Date"/></th>
                    <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                        <th class="text-center" style="width:90px;"><spring:message code="col.cust_pin" text="Cust_Pin"/></th>
                    </c:if>
                    <th class="text-center" style="width:130px;"><spring:message code="col.pii_status" text="Status"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.archive_date" text="Archive_Date"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.expected_arc_del_date" text="Expected_Arc"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.restore_Datetime" text="Restore_Date"/></th>
                    <th class="text-center" style="width:90px;"><spring:message code="col.arc_del_date" text="Arc_del_date"/></th>
                </tr>
                </thead>
                <tbody id="actorderlist">
                <c:forEach items="${list}" var="piiactorder">
                    <tr>
                        <td class="text-center">
                            <c:if test="${piiactorder.exclude_reason ne 'DELARC'
                                       && piiactorder.exclude_reason ne 'RESTORE'
                                       && piiactorder.exclude_reason ne 'APPLY_RESTORE'
                                       && piiactorder.exclude_reason ne 'APPLY_BROWSE'
                                       && piiactorder.exclude_reason ne 'APPROVED_RESTORE'
                                       && piiactorder.exclude_reason ne 'APPROVED_BROWSE'}">
                                <input type="checkbox" class="chkBox" name="chkBox" onClick="checkedRowColorChange();" style="width:15px;height:15px;">
                            </c:if>
                        </td>
                        <td class="text-center"><c:out value="${piiactorder.orderid}"/></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piiactorder.basedate}"/></span></td>
                        <td><c:out value="${piiactorder.jobid}"/></td>
                        <td class="text-center"><span class="cell-version"><c:out value="${piiactorder.version}"/></span></td>
                        <td><c:out value="${piiactorder.system}"/></td>
                        <td class="text-center"><c:out value="${piiactorder.custid}"/></td>
                        <td><c:out value="${piiactorder.cust_nm}"/></td>
                        <td class="text-center"><c:out value="${piiactorder.birth_dt}"/></td>
                        <c:if test="${siteUpperCase eq 'HANACARD_1QNET'}">
                            <td class="text-center"><c:out value="${piiactorder.cust_pin}"/></td>
                        </c:if>
                        <!-- Hidden columns for data extraction -->
                        <td style="display:none;"><c:out value="${piiactorder.jobname}"/></td>
                        <td style="display:none;"><c:out value="${piiactorder.keymap_id}"/></td>
                        <td style="display:none;"><c:out value="${piiactorder.rsdnt_altrntv_id}"/></td>
                        <td style="display:none;"><c:out value="${piiactorder.cust_pin}"/></td>

                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiactorder.exclude_reason eq 'DELARC'}">
                                    <span class="policy-badge badge-status-inactive"><i class="fas fa-ban"></i> <spring:message code="etc.delarccompleted" text="Purged"/></span>
                                </c:when>
                                <c:when test="${piiactorder.exclude_reason eq 'RESTORE'}">
                                    <span class="policy-badge badge-status-active"><i class="fas fa-check-circle"></i> <spring:message code="etc.restored" text="Restored"/></span>
                                </c:when>
                                <c:when test="${piiactorder.exclude_reason eq 'APPLY_RESTORE'}">
                                    <span class="policy-badge" style="background:#fef3c7; color:#d97706;"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.apply_restore" text="Apply_restore"/></span>
                                </c:when>
                                <c:when test="${piiactorder.exclude_reason eq 'APPLY_BROWSE'}">
                                    <span class="policy-badge" style="background:#fef3c7; color:#d97706;"><i class="fas fa-spinner fa-spin"></i> <spring:message code="etc.apply_browse" text="Apply_browse"/></span>
                                </c:when>
                                <c:when test="${piiactorder.exclude_reason eq 'APPROVED_RESTORE'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-check"></i> <spring:message code="etc.approved_restore" text="Approved_restore"/></span>
                                </c:when>
                                <c:when test="${piiactorder.exclude_reason eq 'APPROVED_BROWSE'}">
                                    <span class="policy-badge" style="background:#dbeafe; color:#1d4ed8;"><i class="fas fa-check"></i> <spring:message code="etc.approved_browse" text="Approved_browse"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-phase-checkin"><i class="fas fa-archive"></i> <spring:message code="etc.archived" text="Archived"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piiactorder.archive_date}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piiactorder.expected_arc_del_date}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piiactorder.restore_date}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piiactorder.arc_del_date}"/></span></td>
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

<!-- The Modal -->
<div class="modal fade" id="requestrestoremodal" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title"><spring:message code="etc.cust_restore_apply_title" text="Request restoration for Approval"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="requestestoremodalbody">
                <div style="margin-bottom: 16px;">
                    <label style="font-weight: 600; color: #334155; margin-bottom: 6px; display: block;"><spring:message code="col.aprvlineid" text="Approval Line"/></label>
                    <div id="approvallineselect"></div>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                    <span style="font-weight: 500; color: #475569;"><spring:message code="msg.msginputapplyreason" text="Please enter the details of the reason for the change"/></span>
                    <span style="color: #94a3b8; font-size: 0.85rem;"><span id="reasonlength">0</span>/1000</span>
                </div>
                <textarea spellcheck="false" rows="12" class="form-control" style="resize: none;" name='checkin_reason' id='checkin_reason'></textarea>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button data-oper='request_checkin' class="btn" style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: #fff; padding: 8px 20px; border-radius: 6px; font-weight: 600;">
                    <i class="fas fa-paper-plane"></i> Request
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function checkedRowColorChange() {
        jQuery("#actorderlist > tr").css("background-color", "");
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#eff6ff");
        });

        // Enable/disable action buttons based on selection
        if (checkbox.length > 0) {
            $("#btnRestore").prop("disabled", false);
            $("#btnBrowse").prop("disabled", false);
        } else {
            $("#btnRestore").prop("disabled", true);
            $("#btnBrowse").prop("disabled", true);
        }
    }

    flatpickr("#filter_search7", {
        locale: "ko",
        dateFormat: "Y/m/d",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        defaultDate: null,
        altInputClass: "policy-filter-input",
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    $(document).ready(function () {
        var varapplytype = "";

        $("#checkall").click(function () {
            $("input[name=chkBox]").prop("checked", $(this).prop("checked"));
            checkedRowColorChange();
        });

        $("button[data-oper='restore']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            checkin("RESTORE");
        });

        $("button[data-oper='browse']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            checkin("BROWSE");
        });

        checkin = function (applytype) {
            var checkbox = $("input:checkbox[name=chkBox]:checked");
            var search1 = $('#filter_search1').val();
            var checkedcnt = 0;
            var custids = "";

            checkbox.each(function (i) {
                tr = checkbox.parent().parent().eq(i);
                td = tr.children();
                if (checkedcnt == 0) {
                    custids += td.eq(7).text() + ":" + td.eq(6).text() + "";
                } else {
                    custids += ", " + td.eq(7).text() + ":" + td.eq(6).text() + "";
                }
                checkedcnt++;
            });

            if (checkedcnt == 0) {
                alert("<spring:message code='msg.selecttorestore' text='Please select a processing target'/>");
                return;
            }

            var aprovalid = applytype + "_APPROVAL";
            $.ajax({
                type: "GET",
                url: "/piiapprovaluser/approvallinebyappidlist?approvalid=" + aprovalid,
                dataType: "html",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#approvallineselect').html(data);
                }
            });

            if (applytype == "RESTORE")
                custids += " <spring:message code="etc.applyrestoreforcust" text="customers' restoration request."/>";
            else
                custids += " <spring:message code="etc.applyviewforcust" text="customers' viewing request."/>";

            $('#searchForm [name="applytype"]').val(applytype);
            $('#checkin_reason').val(custids);
            $("#requestrestoremodal").modal();
        };

        $("button[data-oper='request_checkin']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (isEmpty($('input[name="aprvlineid"]:checked').val())) {
                alert("<spring:message code='msg.select_approval_line' text='Please select an approval line'/>");
                return;
            }

            if (isEmpty($('#checkin_reason').val())) {
                alert("Enter request reason for CHECK-IN ");
                return;
            }

            doubleSubmitFlag = true;
            $("#GlobalSuccessMsgModal").removeClass("in");
            $(".modal-backdrop").remove();
            $('body').removeClass('modal-open');
            $('body').css('padding-right', '');
            $("#GlobalSuccessMsgModal").modal("hide");
            requestApproval();
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    };

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "actorderlist?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + encodeURIComponent(search2);
        if (!isEmpty(search3)) url_search += "&search3=" + encodeURIComponent(search3);
        if (!isEmpty(search4)) url_search += "&search4=" + encodeURIComponent(search4);
        if (!isEmpty(search5)) url_search += "&search5=" + encodeURIComponent(search5);
        if (!isEmpty(search6)) url_search += "&search6=" + encodeURIComponent(search6);
        if (!isEmpty(search7)) url_search += "&search7=" + encodeURIComponent(search7);
        if (!isEmpty(search8)) url_search += "&search8=" + encodeURIComponent(search8);

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
    };

    requestApproval = function () {
        var serchkeyno3 = $('#checkin_reason').val();
        var url_search = "";
        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val().toUpperCase();
        var search2 = $('#filter_search2').val().toUpperCase();
        var search3 = $('#filter_search3').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + encodeURIComponent(search2);
        if (!isEmpty(search3)) url_search += "&search3=" + encodeURIComponent(search3);
        if (!isEmpty(search4)) url_search += "&search4=" + encodeURIComponent(search4);
        if (!isEmpty(search5)) url_search += "&search5=" + encodeURIComponent(search5);
        if (!isEmpty(search6)) url_search += "&search6=" + encodeURIComponent(search6);
        if (!isEmpty(search7)) url_search += "&search7=" + encodeURIComponent(search7);
        if (!isEmpty(search8)) url_search += "&search8=" + encodeURIComponent(search8);

        var applytype = $('#searchForm [name="applytype"]').val();
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var param = [];
        var checkedcnt = 0;

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();

            var data = {
                restoreid: null,
                phase: "APPLY",
                old_orderid: td.eq(1).text(),
                new_orderid: null,
                keymap_id: td.eq(10).text(),
                basedate: td.eq(2).text(),
                custid: td.eq(6).text(),
                cust_nm: td.eq(7).text(),
                birth_dt: td.eq(8).text(),
                rsdnt_altrntv_id: td.eq(11).text(),
                cust_pin: td.eq(12).text(),
                old_jobid: td.eq(3).text(),
                old_version: td.eq(4).text(),
                new_jobid: td.eq(3).text() + "_" + applytype + ":" + td.eq(6).text(),
                status: "NEW",
                regdate: null,
                upddate: null,
                reguserid: $('#global_userid').val(),
                upduserid: $('#global_userid').val()
            };

            param.push(data);
            checkedcnt++;
        });

        if (checkedcnt == 0) {
            return;
        }

        var elementResult = $("#content_home");
        url_view = "register?reqreason=" + serchkeyno3 + "&" + "aprvlineid=" + $('input[name="aprvlineid"]:checked').val() + "&" + "applytype=" + applytype + "&";

        $.ajax({
            url: "/piirestore/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {
                ingHide();
                if (data == "success") {
                    $("#GlobalSuccessMsgModal").modal("show");
                    searchAction(pagenum);
                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    };
</script>
