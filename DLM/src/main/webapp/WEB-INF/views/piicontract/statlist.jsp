<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<script src="resources/js/bootstrap-datepicker.min.js"></script>
<script src="resources/js/bootstrap-datepicker.ko.min.js"></script>
<link href="resources/css/bootstrap-datepicker.css" rel="stylesheet">
<link rel="stylesheet" href="/resources/css/bootstrap4-toggle.css">
<script src="/resources/js/bootstrap4-toggle.js"></script>

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
    <c:if test="${pageMaker.cri.search9 ne 'DIALOG'}">
        <div class="page-header-bar">
            <div class="page-header-title">
                <i class="fas fa-chart-line"></i>
                <span><spring:message code="menu.month_real_doc_pagi_stat" text="Document Purge Report"/></span>
            </div>
            <div class="page-header-breadcrumb">
                <span class="breadcrumb-item"><spring:message code="menu.real_doc_del" text="Document Purge"/></span>
                <i class="fas fa-chevron-right"></i>
                <span class="breadcrumb-item active"><spring:message code="menu.real_doc_del_stat" text="Report"/></span>
            </div>
        </div>
    </c:if>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row">
            <c:choose>
                <c:when test="${pageMaker.cri.search9 eq 'DIALOG'}">
                    <div class="policy-filter-grid" style="display: flex; align-items: center; gap: 24px; flex-wrap: nowrap;">
                        <div class="policy-filter-item" style="flex: 0 0 auto;">
                            <label class="policy-filter-label"><spring:message code="col.dept_name" text="Department"/></label>
                            <span class="policy-filter-value"><c:out value="${department.deptname}"/></span>
                        </div>
                        <div class="policy-filter-item" style="flex: 0 0 auto;">
                            <label class="policy-filter-label"><spring:message code="etc.period" text="Period"/></label>
                            <span class="policy-filter-value">
                                <c:out value="${pageMaker.cri.search4}"/> ~ <c:out value="${pageMaker.cri.search5}"/>
                            </span>
                        </div>
                    </div>
                    <div class="policy-filter-actions">
                        <button type="button" class="btn btn-filter-search" data-dismiss="modal">
                            <i class="fas fa-times"></i> Close
                        </button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="policy-filter-grid" style="display: flex; align-items: center; gap: 24px; flex-wrap: nowrap;">
                        <div class="policy-filter-item" style="flex: 0 0 auto;">
                            <label class="policy-filter-label" for="filter_search2"><spring:message code="col.dept_name" text="Department"/></label>
                            <select class="policy-filter-select" name="search2" id="filter_search2"
                                    onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                                <option value=""></option>
                                <c:forEach items="${listMgmtDept}" var="mgmtDept">
                                    <option value="<c:out value="${mgmtDept.mgmt_dept_cd}"/>"
                                            <c:if test="${pageMaker.cri.search2 eq mgmtDept.mgmt_dept_cd}">selected</c:if>>
                                        <c:out value="${mgmtDept.mgmt_dept_name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="policy-filter-item" style="flex: 0 0 auto;">
                            <label class="policy-filter-label" for="filter_search4"><spring:message code="etc.period" text="Period"/></label>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 120px;"
                                       placeholder="YYYY/MM/DD" maxlength="10"
                                       value='<c:out value="${pageMaker.cri.search4}"/>'
                                       onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                       onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                                <span class="policy-filter-separator">~</span>
                                <input type="text" class="policy-filter-input" id="filter_search5" name="search5" style="width: 120px;"
                                       placeholder="YYYY/MM/DD" maxlength="10"
                                       value='<c:out value="${pageMaker.cri.search5}"/>'
                                       onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                       onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                            </div>
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
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable">
                <thead>
                <tr>
                    <th><spring:message code="etc.pagi_month" text="Month"/></th>
                    <th><spring:message code="col.dept_cd" text="Dept_Cd"/></th>
                    <th><spring:message code="col.dept_name" text="Dept_Name"/></th>
                    <th class="text-right"><spring:message code="etc.real_doc_del_all_cnt" text="All count"/></th>
                    <th class="text-right"><spring:message code="etc.real_doc_del_not_complete_cnt" text="Not_complete_cnt"/></th>
                    <th class="text-right"><spring:message code="etc.real_doc_del_complete_cnt" text="Complete_cnt"/></th>
                    <th class="text-right"><spring:message code="etc.real_doc_del_ratio" text="Progress ratio"/></th>
                </tr>
                </thead>
                <tbody id="contractlist">
                <c:forEach items="${list}" var="piicontract">
                    <tr>
                        <td><c:out value="${piicontract.mon}"/></td>
                        <td><c:out value="${piicontract.mgmt_dept_cd}"/></td>
                        <td><c:out value="${piicontract.mgmt_dept_name}"/></td>
                        <td class="text-right"><c:out value="${piicontract.acount}"/></td>
                        <td class="text-right"><c:out value="${piicontract.ncount}"/></td>
                        <td class="text-right"><c:out value="${piicontract.ycount}"/></td>
                        <td class="text-right"><c:out value="${piicontract.progress}"/></td>
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

<!-- Report Modal -->
<div class="modal fade" id="requestrestoremodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 600px;">
        <div class="modal-content" style="border: none; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 80px rgba(0, 0, 0, 0.25);">
            <!-- Modal Header -->
            <div class="modal-header" style="background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%); border: none; padding: 20px 24px;">
                <h5 class="modal-title" style="color: #fff; font-weight: 700; font-size: 1.1rem; display: flex; align-items: center; gap: 10px;">
                    <i class="fas fa-file-signature" style="font-size: 18px; opacity: 0.9;"></i>
                    <spring:message code="menu.month_real_doc_pagi_stat" text="Monthly document Purge status"/>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">
                    <span>&times;</span>
                </button>
            </div>
            <!-- Modal Body -->
            <div class="modal-body" id="requestestoremodalbody" style="padding: 24px; background: #f8fafc;">
                <!-- Approval Line Section -->
                <div style="margin-bottom: 20px;">
                    <label style="display: block; font-size: 0.8rem; font-weight: 600; color: #475569; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px;">
                        <i class="fas fa-sitemap" style="margin-right: 6px; color: #6366f1;"></i>
                        <spring:message code="col.aprvlineid" text="Approval Line"/>
                    </label>
                    <div id="approvallineselect" style="background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px;"></div>
                </div>
                <!-- Reason Section -->
                <div>
                    <label style="display: block; font-size: 0.8rem; font-weight: 600; color: #475569; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px;">
                        <i class="fas fa-pen" style="margin-right: 6px; color: #6366f1;"></i>
                        <spring:message code="msg.msginputreportreason" text="Please enter the details of the reason for the report"/>
                    </label>
                    <textarea spellcheck="false" rows="10" class="form-control"
                              name='checkin_reason' id='checkin_reason'
                              style="border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.88rem; padding: 12px; resize: vertical; background: #fff; transition: border-color 0.2s, box-shadow 0.2s;"
                              onfocus="this.style.borderColor='#6366f1'; this.style.boxShadow='0 0 0 3px rgba(99,102,241,0.1)';"
                              onblur="this.style.borderColor='#e2e8f0'; this.style.boxShadow='none';"></textarea>
                </div>
            </div>
            <!-- Modal Footer -->
            <div class="modal-footer" style="border: none; padding: 16px 24px; background: #fff; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn" data-dismiss="modal"
                        style="background: #f1f5f9; color: #64748b; border: none; border-radius: 8px; padding: 10px 20px; font-weight: 600; font-size: 0.85rem;">
                    <i class="fas fa-times" style="margin-right: 6px;"></i>Cancel
                </button>
                <button data-oper='request_checkin' class="btn"
                        style="background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%); color: #fff; border: none; border-radius: 8px; padding: 10px 24px; font-weight: 600; font-size: 0.85rem; box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);">
                    <i class="fas fa-paper-plane" style="margin-right: 6px;"></i>Request
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
    function doExcelDownload() {
        var f = document.form1;
        var search2 = $('#filter_search2').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        var pagenum = 1;
        var amount = 10000;

        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        f.action = "/piiupload/download_real_doc_stat?pagenum=" + pagenum + "&amount=" + amount + url_search;
        f.submit();
    }
</script>

<script type="text/javascript">
    function checkedRowColorChange() {
        jQuery("#contractlist > tr").css("background-color", "#FFFFFF");
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#E2E8F9");
        });
    }

    // Flatpickr for date pickers
    flatpickr("#filter_search4", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search5", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function (selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    $(document).ready(function () {
        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
            checkedRowColorChange();
        });

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#filter_search2').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });

        $("button[data-oper='exceldownload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doExcelDownload();
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        $("button[data-oper='update']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            requestUpdate();
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

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search2 = $('#filter_search2').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "statlist?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piicontract/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    requestUpdate = function () {
        var url_search = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search2 = $('#filter_search2').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;

        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var param = [];
        var checkedcnt = 0;
        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();

            var data = {
                custid: td.eq(1).text(),
                contractno: td.eq(2).text(),
                dept_cd: null,
                dept_name: null,
                contract_opn_dt: null,
                contract_close_dt: null,
                pd_cd: null,
                pd_nm: null,
                status: "Y",
                actid: null,
                rsdnt_altrntv_id: null,
                cust_nm: null,
                birth_dt: null,
                cb_dt: null,
                cust_pin: null,
                inst_cd: null,
                basedate: null,
                actrole_end_date: null,
                archive_date: null,
                delete_date: null,
                arc_del_date: null,
                real_doc_del_date: null,
                real_doc_del_userid: null
            };

            param.push(data);
            checkedcnt++;
        });
        if (checkedcnt == 0) {
            return;
        }

        var url_view = "updatestatusasy?";
        $.ajax({
            url: "/piicontract/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
    }

    checkin = function (applytype) {
        var search2 = $('#filter_search2').val();
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(search5)) {
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

        var msg = "(" + search4 + " ~ " + search5 + ") <spring:message code="menu.month_real_doc_pagi_stat" text="Monthly document Purge status"/>";
        $('#checkin_reason').val(msg + " <spring:message code='msg.requtestapproval' text=''/>");
        $("#requestrestoremodal").modal();
    }

    requestApproval = function () {
        var serchkeyno3 = $('#checkin_reason').val();
        var url_search = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search2 = $('#filter_search2').val();
        var search6 = "REAL_DOC_REPORT";
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }
        if (isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;

        var applytype = "REPORT";
        var data = {
            reportid: null,
            phase: "APPLY"
        };

        var url_view = "reportregister?reqreason=" + serchkeyno3 + "&" + "aprvlineid=" + $('input[name="aprvlineid"]:checked').val() + "&" + "applytype=" + applytype + "&";
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
</script>
