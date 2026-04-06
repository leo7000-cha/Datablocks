<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Begin Page Content -->
<div class="policy-management-container" id="piitablelist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-columns"></i>
            <span><spring:message code="memu.arc_table_gap" text="Archive Gap"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="menu.env_admin" text="Settings"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.arc_table_gap" text="Archive Gap"/></span>
        </div>
    </div>
    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid"></div>
                <div class="policy-filter-actions">
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table id="listTable" class="policy-table">
                <thead>
                <tr>
                    <th class="th-get"><spring:message code="etc.rn" text="Rn"/></th>
                    <th class="th-get"><spring:message code="etc.owner_src" text="Owner_Src"/></th>
                    <th class="th-get"><spring:message code="etc.table_name_src" text="Table_Name_Src"/></th>
                    <th class="th-get"><spring:message code="etc.column_id_src" text="Column_Id_Src"/></th>
                    <th class="th-get"><spring:message code="etc.column_name_src" text="Column_Name_Src"/></th>
                    <th class="th-get"><spring:message code="etc.data_length_src" text="Data_Length_Src"/></th>
                    <th class="th-get"><spring:message code="etc.owner_arc" text="Owner_Arc"/></th>
                    <th class="th-get"><spring:message code="etc.table_name_arc" text="Table_Name_Arc"/></th>
                    <th class="th-get"><spring:message code="etc.column_id_arc" text="Column_Id_Arc"/></th>
                    <th class="th-get"><spring:message code="etc.column_name_arc" text="Column_Name_Arc"/></th>
                    <th class="th-get"><spring:message code="etc.gapdate" text="Gapdate"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piitable">
                    <tr>
                        <td class="td-get"><c:out value="${piitable.rn}"/></td>
                        <td class="td-get"><c:out value="${piitable.owner_src}"/></td>
                        <td class="td-get"><c:out value="${piitable.table_name_src}"/></td>
                        <td class="td-get"><c:out value="${piitable.column_id_src}"/></td>
                        <td class="td-get"><c:out value="${piitable.column_name_src}"/></td>
                        <td class="td-get"><c:out value="${piitable.data_length_src}"/></td>
                        <td class="td-get"><c:out value="${piitable.owner_arc}"/></td>
                        <td class="td-get"><c:out value="${piitable.table_name_arc}"/></td>
                        <td class="td-get"><c:out value="${piitable.column_id_arc}"/></td>
                        <td class="td-get"><c:out value="${piitable.column_name_arc}"/></td>
                        <td class="td-get"><c:out value="${piitable.gapdate}"/></td>

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

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })

    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "layoutgaplist?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 50;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }

        //alert("/piitable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piitable/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });

    }
</script>
