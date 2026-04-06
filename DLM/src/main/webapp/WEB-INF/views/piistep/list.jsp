<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Begin Page Content -->
<div class="policy-management-container">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-shoe-prints"></i>
            <span><spring:message code="memu.step" text="Step Management"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.task_configuration" text="Task"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.step" text="Step"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid">
                    <div class="policy-filter-item">
                        <label class="policy-filter-label" for="search1">Step ID</label>
                        <input type="text" class="policy-filter-input" id="search1" name="search1"
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search1}"/>'>
                    </div>
                    <div class="policy-filter-item">
                        <label class="policy-filter-label" for="search2">Step Name</label>
                        <input type="text" class="policy-filter-input" id="search2" name="search2"
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search2}"/>'>
                    </div>
                </div>
                <div class="policy-filter-actions">
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button data-oper='register' class="btn btn-filter-register">
                        <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable">
                <thead>
                <tr>
                    <th class="th-get"><spring:message code="col.jobid" text="JOBID"/></th>
                    <th class="th-get"><spring:message code="col.version" text="Version"/></th>
                    <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                    <th class="th-get"><spring:message code="col.stepname" text="Stepname"/></th>
                    <th class="th-get"><spring:message code="col.steptype" text="Steptype"/></th>
                    <th class="th-get"><spring:message code="col.stepseq" text="Stepseq"/></th>
                    <th class="th-get"><spring:message code="col.db" text="DB"/></th>
                    <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                    <th class="th-get"><spring:message code="col.phase" text="Phase"/></th>
                    <th class="th-get"><spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/></th>
                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    <th class="th-get"><spring:message code="col.enddate" text="Enddate"/></th>
                    <th class="th-get"><spring:message code="col.regdate" text="Regdate"/></th>
                    <th class="th-get"><spring:message code="col.reguserid" text="Reguserid"/></th>

                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piistep">
                    <tr>
                        <td class="td-get-l"><c:out value="${piistep.jobid}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.version}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-get"><c:out value="${piistep.steptype}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.db}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>
                        <td class="td-get"><c:out value="${piistep.phase}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.threadcnt}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.commitcnt}"/></td>
                        <td class="td-get"><c:out value="${piistep.enddate}"/></td>
                        <td class="td-get"><c:out value="${piistep.regdate}"/></td>
                            <%-- <td class="td-get"><c:out value="${piistep.upddate}"/></td> --%>
                        <td class="td-get"><c:out value="${piistep.reguserid}"/></td>
                            <%-- <td class="td-get"><c:out value="${piistep.upduserid}"/></td> --%>

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

        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();e.stopPropagation();
            var str = ""
            var tdArr = new Array();	// 배열 선언

            // 현재 클릭된 Row(<tr>)
            var tr = $(this);
            var td = tr.children();

            // tr.text()는 클릭된 Row 즉 tr에 있는 모든 값을 가져온다.
            //console.log("클릭한 Row의 모든 데이터 : "+tr.text());
            // 반복문을 이용해서 배열에 값을 담아 사용할 수 도 있다.
            td.each(function (i) {
                tdArr.push(td.eq(i).text());
            });

            // td.eq(index)를 통해 값을 가져올 수도 있다.
            var serchkeyno1 = td.eq(0).text().trim();
            var serchkeyno2 = td.eq(1).text().trim();
            var serchkeyno3 = td.eq(2).text().trim();

            var serchkeyno = "jobid=" + serchkeyno1 + "&" + "stepid=" + serchkeyno2;//+"&"+"owner="+serchkeyno2+"&"+"table_name="+serchkeyno3
            //alert(serchkeyno);
            //$('#content_home').load("/piistep/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
            //content_home( "refresh" );
            searchAction(null, serchkeyno);
        })
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piistep/register");
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
        //var search3  = $('#searchForm [name="table_name"]').val();
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
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        //if (!isEmpty(search3)) {url_search += "&search3="+search3;}
        //alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piistep/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

</script>

