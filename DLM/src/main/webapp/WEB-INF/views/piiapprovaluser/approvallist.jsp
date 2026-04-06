<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="piiapprovaluserlist">
    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum'
                   value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount'
                value='<c:out value="${pageMaker.cri.amount}"/>'>
            <input type='hidden' name='search1'
                   value='<c:out value="${pageMaker.cri.search1}"/>'>
            <div class="search-container-4-same">
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="search2"><spring:message code="col.approvalname" text="Approvalname"/></label>
                        <div class="col-sm-9">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="search2"
                                   name="search2"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search2}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item"></div>
                <div class="search-item"></div>

                <div class="search-item pr-2" style="text-align: right;">
                    <button data-oper='search' class="btn btn-secondary btn-sm p-0 pb-2 button"><spring:message
                            code="btn.search" text="Search"/></button>
                    <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                        <button data-oper='register' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message
                                code="btn.register" text="Register"/></button>
                    </sec:authorize>
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
                    <th class="th-hidden"><spring:message code="col.approvalid" text="Approvalid"/></th>
                    <th class="th-get"><spring:message code="col.approvalname" text="Approvalname"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piiapproval">
                    <tr>
                        <td class="td-hidden"><c:out value="${piiapproval.approvalid}"/></td>
                        <td class="td-get"><c:out value="${piiapproval.approvalname}"/></td>

                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div><!-- <div class="table-responsive"> -->

        <!-- Page navigation -->
        <%@include file="../includes/pager.jsp" %>
    </div> <!-- <div class="card-body"> -->

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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.piiapprovalline_mgmt" text="Approvaline mgmt"/>");
    });
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#searchForm [name="search1"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });

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
            //console.log("배열에 담긴 값 : "+tdArr);
            // td.eq(index)를 통해 값을 가져올 수도 있다.
            var serchkeyno1 = td.eq(0).text().trim();
            var serchkeyno2 = td.eq(2).text().trim();

            var serchkeyno = "approvalid=" + serchkeyno1 ;
            //alert(serchkeyno);
            //$('#content_home').load("/piiapprovaluser/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
            //content_home( "refresh" );
            searchAction(null, serchkeyno);
        })
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piiapprovaluser/register");
        })

    });


    movePage = function (pageNo) {
        searchAction(pageNo);
        /* 	alert("/piiapprovaluser/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $('#content_home').load("/piiapprovaluser/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search); */
    }

    searchAction = function (pageNo, serchkeyno) {

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2  = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "approvallist?";
        } else {
            url_view = "approvalsteplist?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        // if (!isEmpty(search1)) {
        //     url_search += "&search1=" + search1;
        // }
        if (!isEmpty(search2)) {
            url_search += "&search2="+search2;
        }

        //alert("/piiapprovaluser/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
