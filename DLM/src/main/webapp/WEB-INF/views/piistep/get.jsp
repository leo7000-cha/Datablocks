<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">
<%--사용안함....................--%>
<div class="card shadow m-1" style="border-radius: 8px; overflow: hidden;">
    <div class="card-header m-0 p-0 " style="width:100%;">
        <div class="search-container-get-1row">
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item" style="text-align: right;">
                <button data-oper='list' class="btn btn-action-list btn-action-sm"><i class="fas fa-list"></i> List</button>
                <button data-oper='copy' class="btn btn-action-copy btn-action-sm"><i class="fas fa-copy"></i> Copy</button>
                <button data-oper='modify' class="btn btn-action-modify btn-action-sm"><i class="fas fa-edit"></i> <spring:message
                        code="btn.modify" text="Modify"/></button>
                <sec:authorize access="isAuthenticated()">
                    <c:if test="${piistep.phase eq 'checkout' }">
                        <button data-oper='modify' class="btn btn-action-modify btn-action-sm"><i class="fas fa-edit"></i> <spring:message
                                code="btn.modify" text="Modify"/></button>
                        <button data-oper='remove' class="btn btn-action-remove btn-action-sm"><i class="fas fa-trash-alt"></i> <spring:message
                                code="btn.remove" text="Remove"/></button>
                        <button data-oper='checkin' class="btn btn-action-checkin btn-action-sm"><i class="fas fa-check-circle"></i> Checkin</button>
                    </c:if>
                    <button data-oper='remove' class="btn btn-action-checkout btn-action-sm"><i class="fas fa-sign-out-alt"></i> Checkout</button>
                    <button data-oper='checkin' class="btn btn-action-checkin btn-action-sm"><i class="fas fa-check-circle"></i> Checkin</button>
                </sec:authorize>

            </div>
        </div>

    </div>
    <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->


    <div class="row m-0">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <!-- <h1 class="h5 mb-0 m-1">Job</h1> -->
                <div class="panel-body">
                    <form style="margin: 0; padding: 0;" role="form" id="piistep_get_form">
                    <table class="job-info-table m-1" style="width: 100%">
                        <colgroup>
                            <col style="width: 10%"/>
                            <col style="width: 23%"/>
                            <col style="width: 10%"/>
                            <col style="width: 23%"/>
                            <col style="width: 10%"/>
                            <col style="width: 24%"/>
                        </colgroup>
                        <tbody>

                        <tr>
                            <th class="th-get">STEPSEQ</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='stepseq'
                                                      value='<c:out value="${piistep.stepseq}"/>'></td>
                            <th class="th-get-hidden">JOBID</th>
                            <td class="td-get-hidden" colspan=3><input type="text" class="form-control form-control-sm"
                                                                       name='jobid'
                                                                       value='<c:out value="${piistep.jobid}"/>'></td>
                        </tr>
                        <tr>
                            <th class="th-get">STEPID</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='stepid'
                                                      value='<c:out value="${piistep.stepid}"/>'></td>
                            <th class="th-get">STEPNAME</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='stepname'
                                                      value='<c:out value="${piistep.stepname}"/>'></td>
                            <th class="th-get">PHASE</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='phase'
                                                      value='<c:out value="${piistep.phase}"/>'></td>
                        </tr>
                        <tr>

                            <th class="th-get">VERSION</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='version'
                                                      value='<c:out value="${piistep.version}"/>'></td>
                            <%-- <th class="th-get">ENDDATE</th><td class="td-get"><input type="text" class="form-control form-control-sm" name='enddate' value='<c:out value="${piistep.enddate}"/>'></td> --%>
                            <th class="th-get">THREADCNT</th>
                            <td class="td-get"><c:out value="${piistep.threadcnt}"/><input type="hidden"
                                                                                           class="form-control form-control-sm"
                                                                                           name='threadcnt'
                                                                                           value='<c:out value="${piistep.threadcnt}"/>'>
                            </td>
                            <th class="th-get">COMMITCNT</th>
                            <td class="td-get"><c:out value="${piistep.commitcnt}"/><input type="hidden"
                                                                                           class="form-control form-control-sm"
                                                                                           name='commitcnt'
                                                                                           value='<c:out value="${piistep.commitcnt}"/>'>
                            </td>

                        </tr>
                        <tr>
                            <th class="th-get">STEPTYPE</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='steptype'
                                                      value='<c:out value="${piistep.steptype}"/>'></td>
                            <th class="th-get">DATABASEID</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='db'
                                                      value='<c:out value="${piistep.db}"/>'></td>
                            <th class="th-get">STATUS</th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='status'
                                                      value='<c:out value="${piistep.status}"/>'></td>
                        </tr>

                        <tr>
                            <th class="th-get"><spring:message code="col.regdate" text="Reg_date"/></th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='regdate'
                                                      value='<c:out value="${piistep.regdate}"/>'></td>
                            <th class="th-get-hidden">UPDDATE</th>
                            <td class="td-get-hidden"><input type="text" class="form-control form-control-sm"
                                                             name='upddate' value='<c:out value="${piistep.upddate}"/>'>
                            </td>
                            <th class="th-get"><spring:message code="col.reguserid" text="Register"/></th>
                            <td class="td-get"><input type="text" class="form-control form-control-sm" name='reguserid'
                                                      value='<c:out value="${piistep.reguserid}"/>'></td>
                            <th class="th-get-hidden">UPDUSERID</th>
                            <td class="td-get-hidden"><input type="text" class="form-control form-control-sm"
                                                             name='upduserid'
                                                             value='<c:out value="${piistep.upduserid}"/>'></td>
                        </tr>


                        </tbody>
                    </table>
                    </form>
                </div>
                <!--  end panel-body -->
            </div>
            <!--  panel panel-default-->
        </div>
        <!-- col-sm-12 -->
    </div>

</div>
<!-- <div class="card shadow"> DataTales begin-->
<form style="margin: 0; padding: 0;" role="form" id=searchForm>
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
</form>


<script type="text/javascript">

    $(document).ready(function () {

        $("#steptab li").click(function () {
            $("#steptab li").each(function () {
                //$(this).attr('class','list-group-item');
                //$( this ).toggleClass( "active" );
                $(this).removeClass("active");
            });
            $(this).addClass("active");
            //$(this).attr('class','list-group-item');
            //alert($( this ).text()+"tabcontent");
            $(".tab-body").each(function () {
                //$(this).css("display", "none");
                //alert($( this ).text())
                $(this).attr('class', 'tab-body-none');
            });

            var div_tabcontent = document.getElementById($(this).text() + "stepinfo");
            $(div_tabcontent).attr('class', 'tab-body');

        });

        $(function () {
            $("#menupath").html(Menupath + ">Details");

        });


        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#tablelist tbody').on('dblclick', 'tr', function () {
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
            var serchkeyno4 = td.eq(3).text().trim();
            var serchkeyno5 = td.eq(4).text().trim();

            var serchkeyno = "get?" + "jobid=" + serchkeyno1 + "&" + "stepid=" + serchkeyno2;
            searchAction(null, serchkeyno, serchkeyno2);
        })


        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            if ($('#piistep_get_form [name="phase"]').val() != "CHECKOUT") {
                //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
                return;
            }
            var serchkeyno1 = $('#piistep_get_form [name="=jobid"]').val();
            var serchkeyno2 = $('#piistep_get_form [name="=stepid"]').val();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";
            var url_view = "";

            url_view = "modify?jobid=" + serchkeyno1 + "&" + "stepid=" + serchkeyno2
                + "&";
            alert("/piistep/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search);
            if (isEmpty(pagenum))
                pagenum = 1;
            if (isEmpty(amount))
                amount = 100;
            if (!isEmpty(search1)) {
                url_search += "&search1=" + search1;
            }
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2;
            }
            //alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/piistep/" + url_view
                    + "pagenum=" + pagenum
                    + "&amount=" + amount
                    + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();//alert("성공");
                    $('#content_home').html(data);
                    //$('#content_home').load(data);
                }
            });

        });


        $("button[data-oper='modify_step']").on("click", function (e) {
            //alert($("#modify_step").text())
            $("#modify_step").modal();

        });

    });

    searchAction = function (pageNo, serchkeyno, param3) {

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        /* var search3  = $('#searchForm [name="search3"]').val();
        var search4  = $('#searchForm [name="search4"]').val();
        var search5  = $('#searchForm [name="search5"]').val(); */

        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = serchkeyno + "&";
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
            success: function (data) { ingHide();//alert(data);
                $(div_tabledetail).html(data);
            }
        });
    }


</script>

