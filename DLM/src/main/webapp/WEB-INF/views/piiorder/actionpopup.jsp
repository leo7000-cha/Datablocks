<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:100px; width:100px">
    <div class="card-body m-1 p-0">
        <div class="bg-white py-2 collapse-inner rounded">
            <a class="collapse-item" href="javascript:void(0)">Report1(to-be)</a>
            <a class="collapse-item" href="javascript:void(0)">Report2(to-be)</a>
        </div>
    </div>
</div>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">

    $(function () {
        $("#menupath").html(Menupath + ">Real time job List");
    });
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piiorder/register");
        })

    });


    movePage = function (pageNo) {
        searchAction(pageNo);
        /* 	alert("/piiorder/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $('#content_home').load("/piiorder/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search); */
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val().replace(/-/g, "/");
        var search3 = $('#searchForm [name="search3"]').val();
        var search4 = $('#searchForm [name="search4"]').val();
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
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        //alert("/piiorder/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    diologAction = function (serchkeyno1) {

        var serchkeyno = "orderid=" + serchkeyno1;//+"&"+"version="+serchkeyno2;//+"&"+"table_name="+serchkeyno3


        window.open("08_2_popup.html", "a", "width=400, height=300, left=100, top=50");
        return;

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        //var search3  = $('#searchForm [name="table_name"]').val();
        var url_search = "";
        var url_view = "";

        //if (isEmpty(serchkeyno)) {url_view = "list?"; } else {url_view = "get?piikeyno="+serchkeyno+"&";}
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;

        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        //if (!isEmpty(search3)) {url_search += "&search3="+search3;}
        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    $("button[data-oper='approve']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");//.parent().parent()

        checkbox.each(function (i) {
            //console.log(index);console.log(tr);
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var data = {
                jobid: td.eq(5).text(),
                version: td.eq(6).text()

            };

            param.push(data);
        });

        console.log("param " + param.length);

        ingShow(); $.ajax({
            url: "/piiorder/approve",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                $('#content_home').html(data);
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

    $("button[data-oper='reject']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");//.parent().parent()

        checkbox.each(function (i) {
            //console.log(index);console.log(tr);
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var data = {
                jobid: td.eq(5).text(),
                version: td.eq(6).text()/* ,
                jobname       :"1",
                system        :"1",
                jobtype       :"1",
                runtype       :"1",
                calendar      :"1",
                time          :"1",
                cronval       :"1",
                confirmflag   :"1",
                status        :"1",
                phase         :"1",
                enddate       :"1",
                regdate       :"1",
                upddate       :"1",
                reguserid     :"1",
                upduserid     :"1" */

            };

            param.push(data);
        });

        console.log("param " + param.length);

        ingShow(); $.ajax({
            url: "/piiorder/reject",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                $('#content_home').html(data);
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

</script>
