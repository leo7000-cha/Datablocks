<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="piitablelist">
    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum'
                   value='<c:out value="${pageMaker.cri.pagenum}"/>'> <input
                type='hidden' name='amount'
                value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="search-container-4">
                <div class="search-item">

                </div>
                <div class="search-item">

                </div>

                <div class="search-item">

                </div>

                <div class="search-item pr-2" style="text-align: right;">
                    <button data-oper='search' class="btn btn-secondary btn-sm p-0 pb-2 button"><spring:message
                            code="btn.search" text="Search"/></button>
                </div>


                <div class="search-item"></div>
                <div class="search-item"></div>
                <div class="search-item"></div>
                <div class="search-item"></div>

            </div>
            <!-- <div class="search-container"> -->
        </form>
    </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->

    <div class="card-body m-1 p-0">
        <div class="tableWrapper">
            <table id="listTable" class="table table-sm table-hover">
                <thead>
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.db" text="DB" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.owner" text="Owner" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.table_name" text="Table_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.column_name" text="Column_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.column_id" text="Column_Id" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.pk_yn" text="Pk_Yn" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.pk_position" text="Pk_Position" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.full_data_type" text="Full_Data_Type" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.data_type" text="Data_Type" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.data_length" text="Data_Length" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.domain" text="Domain" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.piitype" text="Piitype" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.piigrade" text="Piigrade" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.encript_flag" text="Encript_Flag" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.scramble_type" text="Scramble_Type" /></th>
                </tr>
                </thead>
                <tbody>
                 <c:forEach items="${list}" var="metatable">
                <tr>
                    <td><c:out value="${metatable.db}" /></td>
                    <td><c:out value="${metatable.owner}" /></td>
                    <td><c:out value="${metatable.table_name}" /></td>
                    <td><c:out value="${metatable.column_name}" /></td>
                    <td><c:out value="${metatable.column_id}" /></td>
                    <td><c:out value="${metatable.pk_yn}" /></td>
                    <td><c:out value="${metatable.pk_position}" /></td>
                    <td><c:out value="${metatable.full_data_type}" /></td>
                    <td><c:out value="${metatable.data_type}" /></td>
                    <td><c:out value="${metatable.data_length}" /></td>
                    <td><c:out value="${metatable.domain}" /></td>
                    <td><c:out value="${metatable.piitype}" /></td>
                    <td><c:out value="${metatable.piigrade}" /></td>
                    <td><c:out value="${metatable.encript_flag}" /></td>
                    <td><c:out value="${metatable.scramble_type}" /></td>
                </tr>
                </c:forEach>
                </tbody>
            </table>

        </div>
        <!-- <div class="table-responsive"> -->
        <!-- Page navigation -->
        <%@include file="../includes/pager.jsp" %>

    </div> <!-- <div class="card-body"> -->
    <!-- table click infomation -->
    <div id="table_click_Result1"></div>
    <div id="table_click_Result2"></div>
</div>
<!-- <div class="card shadow mb-1"> -->

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">

    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.gap_dlm_meta" text="DLM & Meta Gap"/>");
    });
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
