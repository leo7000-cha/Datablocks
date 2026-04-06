<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- on/off check box styles -->
<link rel="stylesheet" href="/resources/css/bootstrap4-toggle.css">
<script src="/resources/js/bootstrap4-toggle.js"></script>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<script src="resources/js/bootstrap-datepicker.min.js"></script>
<script src="resources/js/bootstrap-datepicker.ko.min.js"></script>
<link href="resources/css/bootstrap-datepicker.css" rel="stylesheet">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container" id="piicontractlist">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-file-medical-alt"></i>
            <span><spring:message code="menu.real_doc_del_mgmt" text="Document Purge Register"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="menu.real_doc_del" text="Document Purge"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="menu.real_doc_del_mgmt" text="Register"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 12px; flex: 1; align-items: flex-end;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.custid" text="CUSTID"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search1" name="search1" style="width: 100px;"
                           value='<c:out value="${pageMaker.cri.search1}"/>'
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2"><spring:message code="etc.mgmt_dept" text="Mgmt_dept"/></label>
                    <select class="policy-filter-select" id="filter_search2" name="search2" style="width: 120px;"
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
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3"><spring:message code="col.status" text="Status"/></label>
                    <select class="policy-filter-select" id="filter_search3" name="search3" style="width: 130px;"
                            onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <option value=""></option>
                        <option value="N" <c:if test="${pageMaker.cri.search3 eq 'N'}">selected</c:if>><spring:message code="etc.real_doc_del_not_complete" text="Not completed"/></option>
                        <option value="Y" <c:if test="${pageMaker.cri.search3 eq 'Y'}">selected</c:if>><spring:message code="etc.real_doc_del_complete" text="Completed"/></option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search9"><spring:message code="etc.period" text="Period"/></label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <select class="policy-filter-select" id="filter_search9" name="search9" style="width: 150px;">
                            <option value="ARC" <c:if test="${pageMaker.cri.search9 eq 'ARC'}">selected</c:if>><spring:message code="etc.piipurgeperiod" text="PII Purging Period"/></option>
                            <option value="ARCDEL" <c:if test="${pageMaker.cri.search9 eq 'ARCDEL'}">selected</c:if>><spring:message code="etc.delarcperiod" text="Purging Archived Data Period"/></option>
                        </select>
                        <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 100px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search4}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                        <span class="policy-filter-separator">~</span>
                        <input type="text" class="policy-filter-input" id="filter_search5" name="search5" style="width: 100px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search5}"/>'
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                    </div>
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <button data-oper='update' class="btn btn-filter-action-important" id="btnUpdate" disabled>
                    <i class="fas fa-fire-alt"></i> <span><spring:message code="etc.real_doc_del_complete" text="Update Status"/></span>
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
                    <th style="width: 40px;"><input type="checkbox" class="chkBox" id="checkall" style="vertical-align:middle;width:15px;height:15px;"></th>
                    <th><spring:message code="col.custid" text="Custid"/></th>
                    <th><spring:message code="col.contractno" text="Contractno"/></th>
                    <th><spring:message code="etc.regi_dept" text="Reg_dept"/></th>
                    <th><spring:message code="etc.mgmt_dept" text="Mgmt_dept"/></th>
                    <th><spring:message code="col.contract_opn_dt" text="Contract_Opn_Dt"/></th>
                    <th><spring:message code="col.contract_close_dt" text="Contract_Close_Dt"/></th>
                    <th><spring:message code="col.pd_cd" text="Pd_Cd"/></th>
                    <th><spring:message code="col.pd_nm" text="Pd_Nm"/></th>
                    <th><spring:message code="col.status" text="Status"/></th>
                    <th class="th-get-hidden"><spring:message code="col.actid" text="Actid"/></th>
                    <th><spring:message code="col.rsdnt_altrntv_id" text="Rsdnt_Altrntv_Id"/></th>
                    <th><spring:message code="col.cust_nm" text="Cust_Nm"/></th>
                    <th><spring:message code="col.birth_dt" text="Birth_Dt"/></th>
                    <th class="th-get-hidden"><spring:message code="col.cb_dt" text="Cb_Dt"/></th>
                    <th class="th-get-hidden"><spring:message code="col.cust_pin" text="Cust_Pin"/></th>
                    <th class="th-get-hidden"><spring:message code="col.inst_cd" text="Inst_Cd"/></th>
                    <th class="th-get-hidden"><spring:message code="col.basedate" text="Basedate"/></th>
                    <th class="th-get-hidden"><spring:message code="col.actrole_end_date" text="Actrole_End_Date"/></th>
                    <th><spring:message code="col.archive_date" text="Archive_Date"/></th>
                    <th class="th-get-hidden"><spring:message code="col.delete_date" text="Delete_Date"/></th>
                    <th><spring:message code="col.arc_del_date" text="Arc_Del_Date"/></th>
                    <th><spring:message code="col.real_doc_del_date" text="Real_Doc_Del_Date"/></th>
                    <th><spring:message code="col.real_doc_del_userid" text="Real_Doc_Del_Userid"/></th>
                </tr>
                </thead>
                <tbody id="contractlist">
                <c:forEach items="${list}" var="piicontract">
                    <tr>
                        <td class="text-center">
                            <c:if test="${piicontract.status ne 'Y'}">
                                <input type="checkbox" class="chkBox" name="chkBox" onClick="checkedRowColorChange();" style="vertical-align:middle;width:15px;height:15px;">
                            </c:if>
                        </td>
                        <td><c:out value="${piicontract.custid}"/></td>
                        <td><c:out value="${piicontract.contractno}"/></td>
                        <td><c:out value="${piicontract.dept_name}"/></td>
                        <td><c:out value="${piicontract.mgmt_dept_name}"/></td>
                        <td class="text-center"><c:out value="${piicontract.contract_opn_dt}"/></td>
                        <td class="text-center"><c:out value="${piicontract.contract_close_dt}"/></td>
                        <td><c:out value="${piicontract.pd_cd}"/></td>
                        <td><c:out value="${piicontract.pd_nm}"/></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piicontract.status eq 'N'}"><span style="font-size: 11px;" class="badge badge-danger"><spring:message code="etc.real_doc_del_not_complete" text="Not completed"/></span></c:when>
                                <c:when test="${piicontract.status eq 'Y'}"><span style="font-size: 11px;" class="badge badge-success"><spring:message code="etc.real_doc_del_complete" text="Completed"/></span></c:when>
                                <c:otherwise><spring:message code="etc.real_doc_del_not_complete" text="Not completed"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td class='td-get-hidden'><c:out value="${piicontract.actid}"/></td>
                        <td><c:out value="${piicontract.rsdnt_altrntv_id}"/></td>
                        <td><c:out value="${piicontract.cust_nm}"/></td>
                        <td class="text-center"><c:out value="${piicontract.birth_dt}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.cb_dt}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.cust_pin}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.inst_cd}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.basedate}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.actrole_end_date}"/></td>
                        <td class="text-center"><c:out value="${piicontract.archive_date}"/></td>
                        <td class='td-get-hidden'><c:out value="${piicontract.delete_date}"/></td>
                        <td class="text-center"><c:out value="${piicontract.arc_del_date}"/></td>
                        <td class="text-center"><c:out value="${piicontract.real_doc_del_date}"/></td>
                        <td><c:out value="${piicontract.real_doc_del_userid}"/></td>
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

<form style="margin: 0; padding: 0;" id="form1" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>

<!-- The Modal -->
<div class="modal fade" id="requerealdocapprovalmodal" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.realdoc_apply_title" text="Application for approval of real document Purge"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="requestestoremodalbody">
                <div class="search-container-1row-91">
                    <div class="form-group row">
                        <label class="lable-search col-sm-2" style="vertical-align: middle;"><spring:message code="col.aprvlineid" text="Approval Line"/></label>
                        <div class="col-sm-10">
                            <div id="approvallineselect"></div>
                        </div>
                    </div>
                </div>
                <div class="search-container-1row-73">
                    <div class="search-item">
                        <h6><spring:message code="msg.msginputapplyreason" text="Please enter the details of the reason for the change"/></h6>
                    </div>
                    <div class="search-item" style="text-align: right;">
                        <h6><span id="reasonlength">54</span>/1000</h6>
                    </div>
                </div>
                <textarea spellcheck="false" rows="15" cols="90" class="form-control form-control-sm" name='checkin_reason' id='checkin_reason'></textarea>
            </div>
            <div class="modal-footer">
                <button data-oper='request_checkin' class="btn btn-primary">Request</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    function checkedRowColorChange() {
        jQuery("#contractlist > tr").css("background-color", "#FFFFFF");
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#E2E8F9");
        });

        // Enable/disable action button based on selection
        if (checkbox.length > 0) {
            $("#btnUpdate").prop("disabled", false);
        } else {
            $("#btnUpdate").prop("disabled", true);
        }
    }

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

        $('#filter_search1').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
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

        $("button[data-oper='exceldownload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doExcelDownload();
        });
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
        var search9 = $('#filter_search9').val();

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

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;

        f.action = "/piiupload/download_real_doc_list?pagenum=" + pagenum + "&amount=" + amount + url_search;
        f.submit();
    }

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);
        var search9 = $('#filter_search9').val();

        var url_search = "";
        var url_view = isEmpty(serchkeyno) ? "list?" : "get?" + serchkeyno + "&";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;

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
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
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
                status: "Y"
            };
            param.push(data);
            checkedcnt++;
        });

        if (checkedcnt == 0) return;

        ingShow();
        $.ajax({
            url: "/piicontract/updatestatusasy?pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    $(document).ready(function () {
        $('textarea[name=checkin_reason]').keyup(function () {
            var textLength = $(this).val().length;
            $('#reasonlength').text(textLength);
            if (textLength >= textCountLimit) {
                $(this).val($(this).val().substr(0, textCountLimit));
            }
            $('#reasonlength').text($(this).val().length);
        });
    });

    $("button[data-oper='apply']").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        checkin("REALDOC");
    });

    checkin = function (applytype) {
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var checkedcnt = 0;
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4) || isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var custids = "<spring:message code="etc.delarcperiod" text="Purging Archived Data Period"/>: " + search4 + " ~ " + search5 + "\n";

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            if (checkedcnt == 0) {
                custids += td.eq(12).text() + " <spring:message code="etc.custandothers" text="customer and others"/>";
            }
            checkedcnt++;
        });

        if (checkedcnt == 0) {
            alert("<spring:message code='msg.selecttoapplyrealdoc' text='Please select a approval target'/>");
            return;
        }

        var aprovalid = applytype + "_APPROVAL";
        ingShow();
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

        custids += (checkedcnt - 1) + " <spring:message code="etc.reqphigicaldocpurge" text="customers' physical document destruction results approval request."/>";
        $('#checkin_reason').val(custids);
        $("#requerealdocapprovalmodal").modal();
    }

    $("button[data-oper='request_checkin']").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        if (isEmpty($('input[name="aprvlineid"]:checked').val())) {
            alert("<spring:message code='msg.select_approval_line' text='Please select an approval line'/>");
            return;
        }

        if (isEmpty($('#checkin_reason').val())) {
            alert("Enter request reason for approval");
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

    requestApproval = function () {
        var serchkeyno3 = $('#checkin_reason').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val().replace("월", "");
        if (search4.length == 6) search4 = search4.substring(0, 5) + "0" + search4.substring(5, 6);
        var search5 = $('#filter_search5').val().replace("월", "");
        if (search5.length == 6) search5 = search5.substring(0, 5) + "0" + search5.substring(5, 6);

        if (isEmpty(search4) || isEmpty(search5)) {
            alert("<spring:message code='msg.period' text='Please enter the period to report'/>");
            return;
        }

        var url_search = "";
        var url_view = "checkin?reqreason=" + serchkeyno3 + "&aprvlineid=" + $('input[name="aprvlineid"]:checked').val() + "&";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
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
                $("#GlobalSuccessMsgModal").modal("show");
            }
        });
    }
</script>
