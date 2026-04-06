<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1" style="height:818px">

    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum'
                   value='<c:out value="${pageMaker.cri.pagenum}"/>'> <input
                type='hidden' name='amount'
                value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="search-container">
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-4" style="vertical-align: middle;"
                               for="db">DB</label>
                        <div class="col-sm-7">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="db"
                                   name="db"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search1}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="owner">Owner</label>
                        <div class="col-sm-8">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="owner"
                                   name="owner"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search2}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="table_name">Table</label>
                        <div class="col-sm-8">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="table_name"
                                   name="table_name"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search3}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item">
                    <button data-oper='search' class="btn btn-secondary btn-sm p-0 pb-2 button"><spring:message
                            code="btn.search" text="Search"/></button>
                </div>

                <div class="search-item pr-2" style="text-align: right;">
                    <button data-oper='register' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message
                            code="btn.register" text="Register"/></button>
                </div>
                <div class="search-item"></div>
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
                    <th>DATABASEID</th>
                    <th>OWNER</th>
                    <th>TABLE_NAME</th>
                    <th>PAGITYPE</th>
                    <th>PAGITYPEDETAIL</th>
                    <th>ARCHIVEFLAG</th>
                    <th>STATUS</th>
                    <th>SEQ1</th>
                    <th>SEQ2</th>
                    <th>SEQ3</th>
                    <th>PIPELINE</th>
                    <th>WHERE_COL</th>
                    <th>WHERE_KEY_NAME</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piiconftable">
                    <tr>
                        <td class="td-get"><c:out value="${piiconftable.db}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.owner}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.table_name}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.pagitype}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.pagitypedetail}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.archiveflag}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.status}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.seq1}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.seq2}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.seq3}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.pipeline}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.where_col}"/></td>
                        <td class="td-get"><c:out value="${piiconftable.where_key_name}"/></td>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.table" text="ConfTable management"/>");
    });
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
        //$("#listTable1 tr").click(function() {
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

            var serchkeyno = "db=" + serchkeyno1 + "&" + "owner=" + serchkeyno2 + "&" + "table_name=" + serchkeyno3
            //alert(serchkeyno);
            //$('#content_home').load("/piiconftable/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
            //content_home( "refresh" );
            searchAction(null, serchkeyno);
        })
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piiconftable/register");
        })

    });


    movePage = function (pageNo) {
        searchAction(pageNo);
        /* 	alert("/piiconftable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $('#content_home').load("/piiconftable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search); */
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="db"]').val();
        var search2 = $('#searchForm [name="owner"]').val();
        var search3 = $('#searchForm [name="table_name"]').val();
        var url_search = "";
        var url_view = "";
        //alert("pagenum:" + pagenum + "amount:" + amount + "search1:" + search1 + "search2:" + search2);
        //if (isEmpty(serchkeyno)) {url_view = "list?"; } else {url_view = "get?piikeyno="+serchkeyno+"&";}
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
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        //alert("/piiconftable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piiconftable/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

