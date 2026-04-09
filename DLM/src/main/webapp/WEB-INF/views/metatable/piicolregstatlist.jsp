<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
</form>

<!-- Main Container -->
<div class="policy-management-container" id="metatablelist">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-check-circle"></i>
            <span><spring:message code="memu.columnregisteredStatus" text="PII Registration Status"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.task_configuration" text="Task"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.columnregisteredStatus" text="PII Status"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 12px; flex: 1; align-items: flex-end; flex-wrap: wrap;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1"><spring:message code="col.db" text="DB"/></label>
                    <select class="policy-filter-select" name="search1" id="filter_search1" style="width: 100px;" onchange="searchAction(1);">
                        <option value=""></option>
                        <c:forEach items="${piidatabaselist}" var="piidatabase">
                            <c:if test="${fn:contains(piidatabase.db, 'DLM') == false
                                         && fn:contains(piidatabase.db, 'ILM') == false
                                         && fn:contains(piidatabase.db, 'ARC') == false}">
                                <option value="<c:out value="${piidatabase.db}"/>"
                                        <c:if test="${pageMaker.cri.search1 eq piidatabase.db}">selected</c:if>>
                                    <c:out value="${piidatabase.db}"/>
                                </option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2">Owner</label>
                    <input type="text" class="policy-filter-input" id="filter_search2" name="search2" style="width: 100px;"
                           onkeyup="characterCheck(this);$(this).val($(this).val().toUpperCase());"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search2}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3">Table</label>
                    <input type="text" class="policy-filter-input" id="filter_search3" name="search3" style="width: 120px;"
                           placeholder="%...%"
                           onkeyup="characterCheck(this);$(this).val($(this).val().toUpperCase());"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search3}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search4">Column</label>
                    <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 120px;"
                           placeholder="%...%"
                           onkeyup="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search4}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search6"><spring:message code="etc.policy_id" text="Policy"/></label>
                    <select class="policy-filter-select" id="filter_search6" name="search6" style="width: 100px;" onchange="searchAction(1);">
                        <option value=""><spring:message code="etc.all" text="All"/></option>
                        <option value="PII_POLICY1" <c:if test="${pageMaker.cri.search6 eq 'PII_POLICY1'}">selected</c:if>>Policy1</option>
                        <option value="PII_POLICY2" <c:if test="${pageMaker.cri.search6 eq 'PII_POLICY2'}">selected</c:if>>Policy2</option>
                        <option value="PII_POLICY3" <c:if test="${pageMaker.cri.search6 eq 'PII_POLICY3'}">selected</c:if>>Policy3</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search5"><spring:message code="etc.registered_yn" text="Registered"/></label>
                    <select class="policy-filter-select" id="filter_search5" name="search5" style="width: 80px;" onchange="searchAction(1);">
                        <option value="N" <c:if test="${pageMaker.cri.search5 eq 'N'}">selected</c:if>>N</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search5 eq 'Y'}">selected</c:if>>Y</option>
                        <option value="" <c:if test="${pageMaker.cri.search5 eq ''}">selected</c:if>>All</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search12" style="color:#B28709;">Update</label>
                    <div style="display: flex; align-items: center; gap: 4px;">
                        <input type="text" class="policy-filter-input" id="filter_search12" name="search12" style="width: 95px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search12}"/>'>
                        <span class="policy-filter-separator">~</span>
                        <input type="text" class="policy-filter-input" id="filter_search13" name="search13" style="width: 95px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search13}"/>'>
                    </div>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search11" style="color:#800000;">Order</label>
                    <select class="policy-filter-select" id="filter_search11" name="search11" style="width: 100px;" onchange="searchAction(1);">
                        <option value="">Default</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search11 eq 'Y'}">selected</c:if>>Date DESC</option>
                    </select>
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <button data-oper='exceldownload' class="btn btn-filter-excel">
                    <i class="fas fa-file-excel"></i> Excel
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
                    <th><spring:message code="col.db" text="DB"/></th>
                    <th><spring:message code="col.owner" text="Owner"/></th>
                    <th><spring:message code="col.table_name" text="Table_Name"/></th>
                    <th><spring:message code="col.column_name" text="Column_Name"/></th>
                    <th><spring:message code="col.column_name" text="Column_Name"/>(KR)</th>
                    <th><spring:message code="col.column_id" text="Column_Id"/></th>
                    <th><spring:message code="col.pk_yn" text="Pk_Yn"/></th>
                    <th><spring:message code="col.data_type" text="Data_Type"/></th>
                    <th><spring:message code="col.data_length" text="Data_Length"/></th>
                    <th class="th-hidden"><spring:message code="col.domain" text="Domain"/></th>
                    <th style="color: #B28709;">Meta <spring:message code="col.updatedate" text="Update date"/></th>
                    <th style="color:#2C58D9;"><spring:message code="col.encript_flag" text="Encript_Flag"/></th>
                    <th style="color:#2C58D9;"><spring:message code="col.piigrade" text="Piigrade"/></th>
                    <th style="color:#2C58D9;"><spring:message code="col.piitype" text="Piitype"/></th>
                    <th style="color:#2C58D9;"><spring:message code="col.scramble_type" text="Scramble_Type"/></th>
                    <th class="th-hidden" style="color:#2C58D9;"><spring:message code="col.masterkey" text="Parent Key"/></th>
                    <th class="th-hidden" style="color:#2C58D9;"><spring:message code="col.masteryn" text="Parent YN"/></th>
                    <th><spring:message code="col.jobid" text="JOBID"/></th>
                    <th>JOB<spring:message code="col.regdate" text="Regdate"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="metatable">
                    <tr>
                        <td><c:out value="${metatable.db}"/></td>
                        <td><c:out value="${metatable.owner}"/></td>
                        <td><c:out value="${metatable.table_name}"/></td>
                        <td><c:out value="${metatable.column_name}"/></td>
                        <td><c:out value="${metatable.column_comment}"/></td>
                        <td class="text-right"><c:out value="${metatable.column_id}"/></td>
                        <td class="text-center"><c:out value="${metatable.pk_yn}"/></td>
                        <td><c:out value="${metatable.data_type}"/></td>
                        <td class="text-right"><c:out value="${metatable.data_length}"/></td>
                        <td class="td-hidden"><c:out value="${metatable.domain}"/></td>
                        <td class="text-center"><c:out value="${metatable.upddate}"/></td>
                        <td class="text-center"><c:out value="${metatable.encript_flag}"/></td>
                        <td class="text-center"><c:out value="${metatable.piigrade}"/></td>
                        <td>
                            <c:forEach var="item" items="${listlkPiiScrType}">
                                <c:if test="${metatable.piitype eq item.piicode}">
                                    <c:out value="${item.piitypename}"/>
                                </c:if>
                            </c:forEach>
                        </td>
                        <td><c:out value="${metatable.scramble_type}"/></td>
                        <td class="td-hidden"><c:out value="${metatable.masterkey}"/></td>
                        <td class="td-hidden"><c:out value="${metatable.masteryn}"/></td>
                        <td><c:out value="${metatable.jobid}"/></td>
                        <td class="text-center"><c:out value="${metatable.confregdate}"/></td>
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

<!-- Processing Modal -->
<div class="modal fade" id="processing" role="dialog">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-body modal-body-custom" id="ordermodalbody">
                <h6 class="ml-2">Processing.......</h6>
            </div>
        </div>
    </div>
</div>

<form style="margin: 0; padding: 0;" id="form1" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    // Flatpickr for date pickers
    flatpickr("#filter_search12", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search13", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    function doExcelTemplateDownload() {
        var f = document.form1;
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search11 = $('#filter_search11').val();
        var search12 = $('#filter_search12').val();
        var search13 = $('#filter_search13').val();
        var url_search = "";
        var pagenum = 1;
        var amount = 100000;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) { url_search += "&search4=" + search4; search5 = "Y"; }
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search11)) url_search += "&search11=" + search11;
        if (!isEmpty(search12)) url_search += "&search12=" + search12;
        if (!isEmpty(search13)) url_search += "&search13=" + search13;

        f.action = "/piiupload/download_metadata_gap?pagenum=" + pagenum + "&amount=" + amount + url_search;
        f.submit();
    }

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='exceldownload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doExcelTemplateDownload();
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
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
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search11 = $('#filter_search11').val();
        var search12 = $('#filter_search12').val();
        var search13 = $('#filter_search13').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "piicolregstatlist?";
        } else {
            url_view = "modify?" + serchkeyno + "&";
        }

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search11)) url_search += "&search11=" + search11;
        if (!isEmpty(search12)) url_search += "&search12=" + search12;
        if (!isEmpty(search13)) url_search += "&search13=" + search13;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/metatable/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
