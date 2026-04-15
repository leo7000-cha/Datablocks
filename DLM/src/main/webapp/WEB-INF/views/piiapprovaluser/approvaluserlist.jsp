<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- Begin Page Content -->


        <div class="search-container-1row-55 m-1 " style="width:100%;height:25px;">
            <div style="font-size: 15px;font-weight: bolder; padding: 2px 2px 2px 2px;  vertical-align: middle;">
                <c:out value="${approvalstep.aprvlineid}"/>   Step : <c:out value="${approvalstep.seq}"/>
            </div>
            <div class="step-item" style="text-align: right;">
                <sec:authorize access="isAuthenticated()">
                    <button data-oper='addApprovalStep' id="stepadd"
                            class="btn btn-outline-primary mb-2 mr-2 btn-sm p-0 pb-2 button"><spring:message
                            code="etc.add" text="Add"/></button>
                    <button data-oper='deleteApprovalStep' id="stepdelete"
                            class="btn btn-outline-danger mb-2 mr-2 btn-sm p-0 pb-2 button"><spring:message
                            code="btn.remove" text="Remove"/></button>
                    <button data-oper='savealluser' id="savealluser"
                            class="btn btn-primary mb-2 mr-2 btn-sm p-0 pb-2 button"><spring:message
                            code="btn.save" text="Save"/></button>

                </sec:authorize>
            </div>

        </div>
        <div class="tableWrapper ml-1 mr-1 mb-1 p-0" style="width:98.8%;height:489px">
            <table id="userlist" class="table table-sm table-hover">
                <colgroup>
                    <col style="width: 10%"/>
                    <col style="width: 40%"/>
                    <col style="width: 40%"/>
                </colgroup>
                <thead>
                <tr><th class="th-get" style="text-align:center;">
                </th>
                    <th class="th-get"><spring:message code="col.approverid" text="Approverid"/></th>
                    <th class="th-get"><spring:message code="col.approvername" text="Approvername"/></th>
                    <th scope="row" class="th-get-hidden"><spring:message code="col.aprvlineid" text="Aprvlineid" /></th>
                    <th scope="row" class="th-get-hidden"><spring:message code="col.seq" text="Seq" /></th>
                    <th scope="row" class="th-get-hidden"><spring:message code="col.stepname" text="Stepname" /></th>
                </tr>
                </thead>
                <tbody id="approvaluserbody">
                <c:forEach items="${piiapprovaluserlist}" var="piiapprovaluser">
                    <tr><td class="td-get"><input type="radio" class="chkRadio" name="chkRadio"
                                                  onClick="checkeRowColorChange(this);"
                                                  style="vertical-align:middle;width:15px;height:15px;"></td>
                        <td class="td-get-l"><c:out value="${piiapprovaluser.approverid}"/></td>
                        <td class="td-get-l"><c:out value="${piiapprovaluser.approvername}"/></td>
                        <td class="td-get-hidden"><c:out value="${piiapprovaluser.aprvlineid}" /></td>
                        <td class="td-get-hidden"><c:out value="${piiapprovaluser.seq}" /></td>
                        <td class="td-get-hidden"><c:out value="${piiapprovaluser.stepname}" /></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div><!-- Table List-->

<!-- The Modal -->
<div class="modal fade" id="diologsearchmemberlist" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.search_member" text="Search member"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="diologsearchmemberlistbody">
                <h6>diologsearchmember.jsp</h6>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="diologsearchmemberlistclose"
                        data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<form style="margin: 0; padding: 0;" role="form" id=form_etc>
    <input type='hidden' name='aprvlineid' value='<c:out value="${approvalstep.aprvlineid}"/>'>
    <input type='hidden' name='seq' value='<c:out value="${approvalstep.seq}"/>'>
    <input type='hidden' name='stepname' value='<c:out value="${approvalstep.stepname}"/>'>
</form>
<!-- The Modal end-->
<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>


<script type="text/javascript">
    $(document).ready(function () {
        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
        })
    })
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
            url_view = "getapprovalsteplist?" + serchkeyno + "&";
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
    $('#userlist tbody').on('dblclick', 'tr', function () {

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();

        clickedindex = 0;
        $('#approvaluserbody > tr').each(function (index, tr) {
            var trr = $(this);
            var tdd = trr.children();
            if(td.eq(1).text() == tdd.eq(1).text()) {
                clickedindex = index;//alert("index : "+index);
            }

        });
        //alert("clickedindex : "+clickedindex);return;
        diologSearchMember(clickedindex);


    });

    searchApprovalUser = function (serchkeyno) {
        var url_view = serchkeyno + "&";
        var pagenum = 1;
        var amount = 100;


        $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount ,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $("#userlist").html(data);

                //$('#content_home').load(data);
            }
        });
    };
    $("button[data-oper='addApprovalStep']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var curcnt = 0;
        $('#approvaluserbody > tr').each(function (index, tr) {
            curcnt = index+1;
        });
        if(curcnt > 0) return;

        var htmlstr = "<tr>";
        htmlstr += "    <td class='td-get'><input type='radio' class='chkRadio' name='chkRadio'";
        htmlstr += "                                  onClick='checkeRowColorChange(this);'";
        htmlstr += "                                  style='vertical-align:middle;width:15px;height:15px;'></td>";
        htmlstr += "    <td class='td-get'>"+""+"</td>";
        htmlstr += "    <td class='td-get'>"+""+"</td>";
        htmlstr += "</tr>";

        $("#approvaluserbody").append(htmlstr);
    });

    $("button[data-oper='deleteApprovalStep']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if (jQuery(".chkRadio:checked").val()) {
            var row = jQuery(".chkRadio:checked").parent().parent();
            row.remove();
        };

    });

    $("button[data-oper='savealluser']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var aprvlineid = $('#form_etc [name="aprvlineid"]').val();
        var seq = $('#form_etc [name="seq"]').val();
        var stepname = $('#form_etc [name="stepname"]').val();

        var param = [];
        var tr;
        var td;
        var emptyflag  = true;
        $('#approvaluserbody > tr').each(function (index, tr) {
            //console.log(index);console.log(tr);
            tr = $(this);
            td = tr.children();

            if(typeof td.eq(1).text() == "undefined" || td.eq(1).text() == "" || td.eq(1).text() == null){
                dlmAlert("결재자가 정의 되지 않았습니다.");
                emptyflag = false;
                return false;
                // return;
            }
            if(typeof td.eq(2).text() == "undefined" || td.eq(2).text() == "" || td.eq(2).text() == null){
                dlmAlert("결재자가 정의 되지 않았습니다.");
                emptyflag = true;
                return false;
                // return;
            }

            var data = {
                aprvlineid: aprvlineid,
                seq: seq,
                stepname: stepname,
                approverid: td.eq(1).text(),
                approvername: td.eq(2).text(),
            };

            emptyflag = false;
            param.push(data);
        });

        if(emptyflag){
            dlmAlert("You must set up an approver");
            return;
        }

        //console.log("param "+param.length);
        $.ajax({
            url: "/piiapprovaluser/savealluser",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                showToast("처리가 완료되었습니다.", false);
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

    function checkeRowColorChange(obj) {
        jQuery("#userlist > tr").css("background-color", "#FFFFFF");
        var row = jQuery(".chkRadio").index(obj);
        jQuery("#userlist > tr").eq(row).css("background-color", "#F4F9FB");

    }

    diologSearchMember = function (clickedindex) {

        var pagenum = 1;
        var amount = 100;
        var url_view = "";
        var url_search = "";
        var search2 = "";//$('#piijob_modify_form [name="job_owner_name1"]').val();
        var search3 = clickedindex;
        var search4 = "approval_step_user";

        url_view = "diologsearchmember?";
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
/*        if (!isEmpty(search3) || search3 == 0) {
            url_search += "&search3=" + search3;
        }*/
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        //alert("url_search : "+url_search);
        $.ajax({
            type: "GET",
            url: "/piimember/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#diologsearchmemberlistbody').html(data);
                $("#diologsearchmemberlist").modal();
            }
        });
    }
</script>
