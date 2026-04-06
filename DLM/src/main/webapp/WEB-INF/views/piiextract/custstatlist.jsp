<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<script src="resources/js/bootstrap-datepicker.min.js"></script>
<script src="resources/js/bootstrap-datepicker.ko.min.js"></script>
<link href="resources/css/bootstrap-datepicker.css" rel="stylesheet">

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${pageMaker.cri.search6}"/>'>
    <input type='hidden' name='search7' value='<c:out value="${pageMaker.cri.search7}"/>'>
    <input type='hidden' name='search8' value='<c:out value="${pageMaker.cri.search8}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <c:if test="${pageMaker.cri.search9 ne 'DIALOG'}">
        <div class="page-header-bar">
            <div class="page-header-title">
                <i class="fas fa-chart-pie"></i>
                <span><spring:message code="menu.pii_pagi_stat" text="Processing Report"/></span>
            </div>
            <div class="page-header-breadcrumb">
                <span class="breadcrumb-item"><spring:message code="memu.report" text="Report"/></span>
                <i class="fas fa-chevron-right"></i>
                <span class="breadcrumb-item active"><spring:message code="menu.pii_pagi_stat" text="Processing"/></span>
            </div>
        </div>
    </c:if>

    <!-- ========== FILTER SECTION ========== -->
    <c:choose>
        <c:when test="${pageMaker.cri.search9 eq 'DIALOG'}">
            <!-- Dialog Mode - Read Only -->
            <div class="policy-filter-section">
                <div class="policy-filter-row">
                    <div class="policy-filter-grid">
                        <div class="policy-filter-item" >
                            <label class="policy-filter-label"><spring:message code="etc.report_type" text="Report type"/></label>
                            <span class="policy-filter-value">
                                <c:if test="${pageMaker.cri.search6 eq 'MONTHLY'}"><spring:message code="etc.monthly_report" text="Monthly report"/></c:if>
                                <c:if test="${pageMaker.cri.search6 eq 'QUARTERLY'}"><spring:message code="etc.annual_report" text="Annually report"/></c:if>
                                <c:if test="${pageMaker.cri.search6 eq 'MONTHLY_CONSENT'}"><spring:message code="etc.monthly_report_consent" text="Monthly report(Consent form)"/></c:if>
                            </span>
                        </div>
                        <div class="policy-filter-item">
                            <label class="policy-filter-label"><spring:message code="etc.period" text="Period"/></label>
                            <span class="policy-filter-value">
                                <c:if test="${pageMaker.cri.search6 eq 'MONTHLY'}"><c:out value="${pageMaker.cri.search4}"/></c:if>
                                <c:if test="${pageMaker.cri.search6 eq 'QUARTERLY'}"><c:out value="${pageMaker.cri.search4}"/> ~ <c:out value="${pageMaker.cri.search5}"/></c:if>
                                <c:if test="${pageMaker.cri.search6 eq 'MONTHLY_CONSENT'}"><c:out value="${pageMaker.cri.search4}"/></c:if>
                            </span>
                        </div>
                    </div>
                    <div class="policy-filter-actions">
                        <button type="button" class="btn btn-filter-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Close
                        </button>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Normal Mode -->
            <div class="policy-filter-section">
                <div class="policy-filter-row">
                    <div class="policy-filter-grid">
                        <div class="policy-filter-item" style="grid-column: span 2;">
                            <label class="policy-filter-label" for="filter_search6"><spring:message code="etc.report_type" text="Report type"/></label>
                            <select class="policy-filter-select" name="search6" id="filter_search6"
                                    onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                                <option value="MONTHLY" <c:if test="${pageMaker.cri.search6 eq 'MONTHLY'}">selected</c:if>><spring:message code="etc.monthly_report" text="Monthly report"/></option>
                                <option value="QUARTERLY" <c:if test="${pageMaker.cri.search6 eq 'QUARTERLY'}">selected</c:if>><spring:message code="etc.annual_report" text="Annually report"/></option>
                                <option value="MONTHLY_CONSENT" <c:if test="${pageMaker.cri.search6 eq 'MONTHLY_CONSENT'}">selected</c:if>><spring:message code="etc.monthly_report_consent" text="Monthly report(Consent form)"/></option>
                            </select>
                        </div>
                        <div class="policy-filter-item">
                            <label class="policy-filter-label" for="filter_search4"><spring:message code="etc.period" text="Period"/></label>
                            <input type="text" class="policy-filter-input" id="filter_search4" name="search4"
                                   maxlength="10" value='<c:out value="${pageMaker.cri.search4}"/>'
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)">
                        </div>
                        <div class="policy-filter-item" id="periodTo" style="display:none;">
                            <label class="policy-filter-label" for="filter_search5">~</label>
                            <input type="text" class="policy-filter-input" id="filter_search5" name="search5"
                                   maxlength="10" value='<c:out value="${pageMaker.cri.search5}"/>'
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)">
                        </div>
                    </div>
                    <div class="policy-filter-actions">
                        <button data-oper='search' class="btn btn-filter-search">
                            <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                        </button>
                        <button data-oper='report' class="btn btn-filter-register">
                            <i class="fas fa-file-alt"></i> <spring:message code="etc.report_apply" text="Report"/>
                        </button>
                        <button data-oper='exceldownload' class="btn btn-filter-excel">
                            <i class="fas fa-download"></i> <spring:message code="btn.excel" text="EXCEL"/>
                        </button>
                        <sec:authorize access="hasRole('ROLE_ADMIN')">
                        <button type="button" class="btn btn-filter-purge" onclick="executePurge()">
                            <i class="fas fa-broom"></i> Purge
                        </button>
                        </sec:authorize>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <c:choose>
                <c:when test="${pageMaker.cri.search6 eq 'MONTHLY_CONSENT'}">
                    <table class="policy-table multi-row-header" id="scrallTable1">
                        <thead>
                        <tr>
                            <th rowspan="2"><spring:message code="etc.base" text="Base"/></th>
                            <th colspan="2"><spring:message code="etc.creditinfo_consent_form" text="Creditinfo consent form"/></th>
                        </tr>
                        <tr>
                            <th><spring:message code="etc.archive_cnt" text="Archive_Cnt"/></th>
                            <th><spring:message code="etc.arc_del_cnt" text="Arc_del_Cnt"/></th>
                        </tr>
                        </thead>
                        <tbody id="report-body-consent">
                        <c:forEach items="${list}" var="piiextract">
                            <tr>
                                <td class="text-center"><c:out value="${piiextract.mon}"/></td>
                                <td class="text-right"><c:out value="${piiextract.arccnt}"/></td>
                                <td class="text-right"><c:out value="${piiextract.delarccnt}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <table class="policy-table multi-row-header" id="scrallTable2">
                        <colgroup>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                        </colgroup>
                        <thead>
                        <tr>
                            <th rowspan="2" style="vertical-align: middle;"><spring:message code="etc.base" text="Base"/></th>
                            <th colspan="3"><spring:message code="etc.policy1_title" text="Only sign up customer"/> [PII_POLICY1]</th>
                            <th colspan="3"><spring:message code="etc.policy2_title" text="Unconfirmed customer"/> [PII_POLICY2]</th>
                            <th colspan="3"><spring:message code="etc.policy3_title" text="Termination of transaction customer"/> [PII_POLICY3]</th>
                        </tr>
                        <tr>
                            <th><spring:message code="etc.archive_cnt" text="Archive_Cnt"/></th>
                            <th><spring:message code="etc.restore_cnt" text="Restore_Cnt"/></th>
                            <th><spring:message code="etc.arc_del_cnt" text="Arc_del_Cnt"/></th>
                            <th><spring:message code="etc.archive_cnt" text="Archive_Cnt"/></th>
                            <th><spring:message code="etc.restore_cnt" text="Restore_Cnt"/></th>
                            <th><spring:message code="etc.arc_del_cnt" text="Arc_del_Cnt"/></th>
                            <th><spring:message code="etc.archive_cnt" text="Archive_Cnt"/></th>
                            <th><spring:message code="etc.restore_cnt" text="Restore_Cnt"/></th>
                            <th><spring:message code="etc.arc_del_cnt" text="Arc_del_Cnt"/></th>
                        </tr>
                        <c:set var="archive_cnt1" value="0"/>
                        <c:set var="restore_cnt1" value="0"/>
                        <c:set var="arc_del_cnt1" value="0"/>
                        <c:set var="archive_cnt2" value="0"/>
                        <c:set var="restore_cnt2" value="0"/>
                        <c:set var="arc_del_cnt2" value="0"/>
                        <c:set var="archive_cnt3" value="0"/>
                        <c:set var="restore_cnt3" value="0"/>
                        <c:set var="arc_del_cnt3" value="0"/>
                        <c:forEach items="${list}" var="piiextract">
                            <c:set var="archive_cnt1" value="${archive_cnt1 + piiextract.archive_cnt1}"/>
                            <c:set var="restore_cnt1" value="${restore_cnt1 + piiextract.restore_cnt1}"/>
                            <c:set var="arc_del_cnt1" value="${arc_del_cnt1 + piiextract.arc_del_cnt1}"/>
                            <c:set var="archive_cnt2" value="${archive_cnt2 + piiextract.archive_cnt2}"/>
                            <c:set var="restore_cnt2" value="${restore_cnt2 + piiextract.restore_cnt2}"/>
                            <c:set var="arc_del_cnt2" value="${arc_del_cnt2 + piiextract.arc_del_cnt2}"/>
                            <c:set var="archive_cnt3" value="${archive_cnt3 + piiextract.archive_cnt3}"/>
                            <c:set var="restore_cnt3" value="${restore_cnt3 + piiextract.restore_cnt3}"/>
                            <c:set var="arc_del_cnt3" value="${arc_del_cnt3 + piiextract.arc_del_cnt3}"/>
                        </c:forEach>
                        <tr class="sum-row">
                            <th><spring:message code="etc.sum" text="Sum"/></th>
                            <th class="text-right"><fmt:formatNumber value="${archive_cnt1}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${restore_cnt1}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${arc_del_cnt1}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${archive_cnt2}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${restore_cnt2}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${arc_del_cnt2}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${archive_cnt3}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${restore_cnt3}" pattern="#,###"/></th>
                            <th class="text-right"><fmt:formatNumber value="${arc_del_cnt3}" pattern="#,###"/></th>
                        </tr>
                        </thead>
                        <tbody id="report-body">
                        <c:forEach items="${list}" var="piiextract">
                            <tr>
                                <td class="text-center"><c:out value="${piiextract.mon}"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.archive_cnt1}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.restore_cnt1}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.arc_del_cnt1}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.archive_cnt2}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.restore_cnt2}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.arc_del_cnt2}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.archive_cnt3}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.restore_cnt3}" pattern="#,###"/></td>
                                <td class="text-right"><fmt:formatNumber value="${piiextract.arc_del_cnt3}" pattern="#,###"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Pagination -->
    <div class="policy-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>

<!-- Report Request Modal -->
<div class="modal fade" id="requestrestoremodal" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content modal-content-modern">
            <!-- Modal Header -->
            <div class="modal-header modal-header-modern" style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);">
                <h5 class="modal-title" style="display: flex; align-items: center; gap: 10px;">
                    <i class="fas fa-file-signature"></i>
                    <spring:message code="etc.pii_process_report_title" text="PII Processing Report"/>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">
                    <span>&times;</span>
                </button>
            </div>
            <!-- Modal body -->
            <div class="modal-body" style="padding: 24px;">
                <div class="modal-form-group" style="margin-bottom: 20px;">
                    <label class="modal-label" style="display: block; font-weight: 600; color: #334155; margin-bottom: 8px; font-size: 0.9rem;">
                        <i class="fas fa-sitemap" style="color: #6366f1; margin-right: 6px;"></i>
                        <spring:message code="col.aprvlineid" text="Approval Line"/>
                    </label>
                    <div id="approvallineselect" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; max-height: 150px; overflow-y: auto;"></div>
                </div>
                <div class="modal-form-group">
                    <label class="modal-label" style="display: block; font-weight: 600; color: #334155; margin-bottom: 8px; font-size: 0.9rem;">
                        <i class="fas fa-edit" style="color: #6366f1; margin-right: 6px;"></i>
                        <spring:message code="msg.msginputreportreason" text="Please enter the details of the reason for the report"/>
                    </label>
                    <textarea spellcheck="false" rows="8" class="detail-textarea" style="width: 100%; resize: none; border-radius: 8px; border: 1px solid #e2e8f0; padding: 12px; font-size: 0.9rem;"
                              name='checkin_reason' id='checkin_reason'></textarea>
                </div>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer modal-footer-modern" style="background: #f8fafc; border-top: 1px solid #e2e8f0; padding: 16px 24px;">
                <button type="button" class="btn btn-detail-list" data-dismiss="modal" style="margin-right: 8px;">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button data-oper='request_checkin' class="btn" style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: #fff; border: none; padding: 10px 24px; border-radius: 8px; font-weight: 600; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);">
                    <i class="fas fa-paper-plane"></i> Request
                </button>
            </div>
        </div>
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
    $(document).ready(function () {
        // Period field toggle based on report type
        if ("<c:out value="${pageMaker.cri.search6}"/>" == "QUARTERLY") {
            $('#periodTo').show();
        } else {
            $('#periodTo').hide();
        }

        $("#filter_search6").change(function () {
            if ($(this).val() == "QUARTERLY") {
                $('#periodTo').show();
            } else {
                $('#periodTo').hide();
            }
        });
    });

    function doExcelDownload() {
        var f = document.form1;
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search6 = $('#filter_search6').val();

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (search6 == "QUARTERLY" && isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        var pagenum = 1;
        var amount = 10000;

        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;

        f.action = "/piiupload/download_cust_stat?pagenum=" + pagenum + "&amount=" + amount + url_search;
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

        $("button[data-oper='report']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            checkin("REPORT");
        });

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
    });

    checkin = function (applytype) {
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (search6 == "QUARTERLY" && isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
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

        var msg;
        if (search6 == "MONTHLY") {
            msg = "(" + search4 + ") <spring:message code='etc.monthly_report' text='Monthly report'/>";
        } else if (search6 == "QUARTERLY") {
            msg = "(" + search4 + " ~ " + search5 + ") <spring:message code='etc.annual_report' text='Annually report'/>";
        } else if (search6 == "MONTHLY_CONSENT") {
            msg = "(" + search4 + ") <spring:message code='etc.monthly_report_consent' text='Monthly report(Consent form)'/>";
        }

        $('#checkin_reason').val(msg + " <spring:message code='msg.requtestapproval' text=''/>");
        $("#requestrestoremodal").modal();
    }

    requestApproval = function () {
        var serchkeyno3 = $('#checkin_reason').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();

        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search6 = $('#filter_search6').val();

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (search6 == "QUARTERLY" && isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;

        var data = {
            reportid: null,
            phase: "APPLY"
        };

        var url_view = "reportregister?reqreason=" + serchkeyno3 + "&aprvlineid=" + $('input[name="aprvlineid"]:checked').val() + "&applytype=REPORT&";
        $.ajax({
            url: "/piiextract/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(data),
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
    }

    // Flatpickr for date pickers
    flatpickr("#filter_search4", {
        locale: "ko",
        dateFormat: "Y/m",
        altInput: true,
        altFormat: "Y년 m월",
        allowInput: true,
        altInputClass: "policy-filter-input",
        plugins: [
            new monthSelectPlugin({
                shorthand: false,
                dateFormat: "Y/m",
                altFormat: "Y년 m월",
                theme: "light"
            })
        ],
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search5", {
        locale: "ko",
        dateFormat: "Y/m",
        altInput: true,
        altFormat: "Y년 m월",
        allowInput: true,
        altInputClass: "policy-filter-input",
        plugins: [
            new monthSelectPlugin({
                shorthand: false,
                dateFormat: "Y/m",
                altFormat: "Y년 m월",
                theme: "light"
            })
        ],
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    function executePurge() {
        if (!confirm('영구파기/복원 완료 레코드를 정리합니다.\n보존 기간이 경과한 레코드만 삭제됩니다.\n\n실행하시겠습니까?')) return;
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piiextract/purge",
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                var result = (typeof data === 'string') ? JSON.parse(data) : data;
                if (result.status === 'OK') {
                    alert('퍼지 완료: ' + result.message);
                    searchAction(1);
                } else {
                    $("#errormodalbody").html('<div class="alert alert-danger">' + result.message + '</div>');
                    $("#errormodal").modal("show");
                }
            },
            error: function (req, err) {
                ingHide();
                $("#errormodalbody").html('<div class="alert alert-danger">퍼지 요청 실패: ' + req.status + '</div>');
                $("#errormodal").modal("show");
            }
        });
    }

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = 100;

        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search6 = $('#filter_search6').val();

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (search6 == "QUARTERLY" && isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        var url_view = "custstatlist?";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;

        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;

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
