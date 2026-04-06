<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">
<!-- Begin Page Content -->
<div class="card shadow m-1">

    <div class="card-header m-0 p-0" style="width: 100%;">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="search-container-4">
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="search6"><spring:message code="etc.table_name" text="Table_name"/></label>
                        <div class="col-sm-6">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" name="search6" id="search6"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search6}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item"></div>
                <div class="search-item"></div>
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
        <div class="tableWrapper ">
            <table id="listTable" class="table table-sm table-hover">

                <thead>
                <tr>
                    <th class="th-get"><spring:message code="col.jobid" text="JOBID"/></th>
                    <th class="th-get"><spring:message code="col.version" text="Version"/></th>
                    <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                    <th class="th-get"><spring:message code="col.db" text="DB"/></th>
                    <th class="th-get"><spring:message code="col.owner" text="Owner"/></th>
                    <th class="th-get"><spring:message code="col.table_name" text="Table_Name"/></th>
                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                    <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                    <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/></th>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_Key_Name"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piisteptable">
                    <tr>
                        <td class="td-get-l"><c:out value="${piisteptable.jobid}"/></td>
                        <td class="td-get-r"><c:out value="${piisteptable.version}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.stepid}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.owner}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.table_name}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.exetype}"/></td>
                            <%-- <td class="td-get"><c:out value="${piisteptable.archiveflag}"/></td> --%>
                        <td class="td-get-l"><c:out value="${piisteptable.status}"/></td>
                            <%-- <td class="td-get"><c:out value="${piisteptable.preceding}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.succedding}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piisteptable.seq1}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.seq2}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.seq3}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.pipeline}"/></td> --%>
                        <td class="td-get-l"><c:out value="${piisteptable.where_col}"/></td>
                        <td class="td-get-l"><c:out value="${piisteptable.where_key_name}"/></td>
                            <%-- <td class="td-get"><c:out value="${piisteptable.parallelcnt}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piisteptable.commitcnt}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piisteptable.wherestr}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.sqlstr}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piisteptable.regdate}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.upddate}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.reguserid}"/></td>
                            <td class="td-get"><c:out value="${piisteptable.upduserid}"/></td> --%>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.registerdtable" text="Tablelist"/>");
    });


    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#searchForm [name="search6"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
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
        var search6 = $('#searchForm [name="search6"]').val().toUpperCase();
        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "/piisteptable/" + "list?";
        } else {
            url_view = serchkeyno;
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6
        }
        ;

        //alert(url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
                //$('#content_home').load(data);
            }
        });

    }
    searchJobAction = function (pageNo, serchkeyno) {

        var url_search = "";
        var url_view = "";
        //alert("pagenum:" + pagenum + "amount:" + amount + "search1:" + search1 + "search2:" + search2);
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        var pagenum = 1;
        var amount = 100;

        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

