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

<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="piidetectlist">
    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum'
                   value='<c:out value="${pageMaker.cri.pagenum}"/>'> <input
                type='hidden' name='amount'
                value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="search-container-4-same">
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-4" style="vertical-align: middle;"
                               for="search1"><spring:message code="col.conf_id" text="DETECT_ID"/></label>
                        <div class="col-sm-6">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="search1"
                                   name="search1"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search1}"/>'>
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
        <div class="tableWrapper" >
            <table id="listTable" class="table table-sm table-hover">
                <thead>
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.conf_id" text="Conf_Id" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.conf_name" text="Conf_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_type" text="Detect_Type" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern1" text="Detect_Pattern1" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern2" text="Detect_Pattern2" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern3" text="Detect_Pattern3" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern4" text="Detect_Pattern4" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern5" text="Detect_Pattern5" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern6" text="Detect_Pattern6" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern7" text="Detect_Pattern7" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.detect_pattern8" text="Detect_Pattern8" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.lenth_min" text="Lenth_Min" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.regdate" text="Regdate" /></th>
              <%--      <th scope="row" class="th-get"><spring:message code="col.upddate" text="Upddate" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.reguserid" text="Reguserid" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.upduserid" text="Upduserid" /></th>--%>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piidetect_config">
                        <tr>
                            <td><c:out value="${piidetect_config.conf_id}" /></td>
                            <td><c:out value="${piidetect_config.conf_name}" /></td>
                            <td><c:out value="${piidetect_config.detect_type}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern1}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern2}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern3}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern4}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern5}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern6}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern7}" /></td>
                            <td><c:out value="${piidetect_config.detect_pattern8}" /></td>
                            <td><c:out value="${piidetect_config.lenth_min}" /></td>
                            <td><c:out value="${piidetect_config.regdate}" /></td>
                            <%--<td><c:out value="${piidetect_config.upddate}" /></td>
                            <td><c:out value="${piidetect_config.reguserid}" /></td>
                            <td><c:out value="${piidetect_config.upduserid}" /></td>--%>

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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.detect_config" text="Detect configuration"/>" + "");
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
            var serchkeyno2 = td.eq(1).text().trim();
            var serchkeyno3 = td.eq(2).text().trim();

            var serchkeyno = "cfgkey=" + serchkeyno1;
            //alert(serchkeyno);
            //$('#content_home').load("/piidetect/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
            //content_home( "refresh" );
            searchAction(null, serchkeyno);
        })
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piidetect/register");
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

        //alert("/piidetect/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piidetect/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
