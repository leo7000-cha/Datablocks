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
</form>

<!-- Main Container -->
<div class="policy-management-container" id="lkpiiscrtypelist">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-tags"></i>
            <span><spring:message code="memu.lkpiiscr_mgmt" text="PII & Scramble"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.meta_configuration" text="Meta"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.lkpiiscr_mgmt" text="개인정보 변환타입 관리"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 16px; flex: 1; align-items: flex-end;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_piigradeid"><spring:message code="col.piigrade" text="PII Grade"/></label>
                    <select class="policy-filter-select" id="filter_piigradeid" name="piigradeid" style="width: 100px;" onchange="searchAction(1);">
                        <option value="" <c:if test="${pageMaker.cri.search1 eq ''}">selected</c:if>></option>
                        <option value="1" <c:if test="${pageMaker.cri.search1 eq '1'}">selected</c:if>>1</option>
                        <option value="2" <c:if test="${pageMaker.cri.search1 eq '2'}">selected</c:if>>2</option>
                        <option value="3" <c:if test="${pageMaker.cri.search1 eq '3'}">selected</c:if>>3</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_piitypename"><spring:message code="col.piitypename" text="PII Type Name"/></label>
                    <input type="text" class="policy-filter-input" id="filter_piitypename" name="piitypename" style="width: 180px;"
                           placeholder="%...%"
                           onkeyup="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search2}"/>'>
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
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
                    <th><spring:message code="col.piicode" text="Piicode"/></th>
                    <th><spring:message code="col.piigrade" text="PII Grade"/></th>
                    <th class="th-hidden"><spring:message code="col.piigradename" text="Piigradename"/></th>
                    <th class="th-hidden"><spring:message code="col.piigroupid" text="Piigroupid"/></th>
                    <th><spring:message code="col.piigroupname" text="Piigroupname"/></th>
                    <th class="th-hidden"><spring:message code="col.piitypeid" text="Piitypeid"/></th>
                    <th><spring:message code="col.piitypename" text="Piitypename"/></th>
                    <th class="text-center" style="width: 90px;">사용여부</th>
                    <th><spring:message code="col.scrtype" text="Scrtype"/></th>
                    <th><spring:message code="col.scrmethod" text="Scrmethod"/></th>
                    <th><spring:message code="col.scrcategory" text="Scrcategory"/></th>
                    <th><spring:message code="col.scrdigits" text="Scrdigits"/></th>
                    <th><spring:message code="col.scrvalidity" text="Scrvalidity"/></th>
                    <th><spring:message code="col.remarks" text="Remarks"/></th>
                    <th><spring:message code="col.encdecfunctype" text="Encdecfunctype"/></th>
                    <th><spring:message code="col.encfunc" text="Encfunc"/></th>
                    <th><spring:message code="col.decfunc" text="Decfunc"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="lkpiiscrtype">
                    <tr>
                        <td><c:out value="${lkpiiscrtype.piicode}"/></td>
                        <td class="text-center"><c:out value="${lkpiiscrtype.piigradeid}"/></td>
                        <td class="td-hidden"><c:out value="${lkpiiscrtype.piigradename}"/></td>
                        <td class="td-hidden"><c:out value="${lkpiiscrtype.piigroupid}"/></td>
                        <td><c:out value="${lkpiiscrtype.piigroupname}"/></td>
                        <td class="td-hidden"><c:out value="${lkpiiscrtype.piitypeid}"/></td>
                        <td><c:out value="${lkpiiscrtype.piitypename}"/></td>
                        <td class="text-center">
                            <span class="visible-toggle" data-piicode="${lkpiiscrtype.piicode}" data-visible="${lkpiiscrtype.visible}"
                                  style="cursor: pointer; font-size: 1.6em; line-height: 1;" title="클릭하여 사용여부 전환"
                                  onclick="toggleVisible(this)">
                                <c:choose>
                                    <c:when test="${lkpiiscrtype.visible == 'Y'}"><i class="fas fa-toggle-on" style="color: #22c55e;"></i></c:when>
                                    <c:otherwise><i class="fas fa-toggle-off" style="color: #d1d5db;"></i></c:otherwise>
                                </c:choose>
                            </span>
                        </td>
                        <td><c:out value="${lkpiiscrtype.scrtype}"/></td>
                        <td><c:out value="${lkpiiscrtype.scrmethod}"/></td>
                        <td><c:out value="${lkpiiscrtype.scrcategory}"/></td>
                        <td><c:out value="${lkpiiscrtype.scrdigits}"/></td>
                        <td><c:out value="${lkpiiscrtype.scrvalidity}"/></td>
                        <td><c:out value="${lkpiiscrtype.remarks}"/></td>
                        <td class="text-center"><c:out value="${lkpiiscrtype.encdecfunctype}"/></td>
                        <td><c:out value="${lkpiiscrtype.encfunc}"/></td>
                        <td><c:out value="${lkpiiscrtype.decfunc}"/></td>
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

<!-- Detail/Modify Modal -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 750px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden;">
            <div class="modal-body" id="detailModalBody" style="padding: 0;">
                <!-- Content loaded via AJAX -->
            </div>
        </div>
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

        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var tr = $(this);
            var td = tr.children();
            var piicode = td.eq(0).text().trim();
            openDetailModal(piicode);
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#content_home').load("/lkpiiscrtype/register");
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_piigradeid').val();
        var search2 = $('#filter_piitypename').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/lkpiiscrtype/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    // Open detail modal
    openDetailModal = function (piicode) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_piigradeid').val();
        var search2 = $('#filter_piitypename').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/lkpiiscrtype/get?piicode=" + piicode + "&pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#detailModalBody').html(data);
                $('#detailModal').modal('show');
            }
        });
    }

    // Open modify modal
    openModifyModal = function (piicode) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_piigradeid').val();
        var search2 = $('#filter_piitypename').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/lkpiiscrtype/modify?piicode=" + piicode + "&pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#detailModalBody').html(data);
            }
        });
    }

    // Refresh list (called after save/delete)
    refreshList = function () {
        searchAction();
    }

    // Toggle visible (인벤토리 표시 여부)
    function toggleVisible(el) {
        var $el = $(el);
        var piicode = $el.data('piicode');
        var currentVisible = $el.data('visible');
        var newVisible = (currentVisible === 'Y') ? 'N' : 'Y';
        var csrfToken = $('meta[name="_csrf"]').attr('content') || $('input[name="_csrf"]').val();
        var csrfHeader = $('meta[name="_csrf_header"]').attr('content') || 'X-CSRF-TOKEN';

        $.ajax({
            type: 'POST',
            url: '/lkpiiscrtype/api/toggle-visible',
            data: { piicode: piicode, visible: newVisible },
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    $el.data('visible', newVisible);
                    if (newVisible === 'Y') {
                        $el.html('<i class="fas fa-toggle-on" style="color: #22c55e;"></i>');
                    } else {
                        $el.html('<i class="fas fa-toggle-off" style="color: #d1d5db;"></i>');
                    }
                }
            },
            error: function() {
                dlmAlert('변경 실패');
            }
        });
    }
</script>
