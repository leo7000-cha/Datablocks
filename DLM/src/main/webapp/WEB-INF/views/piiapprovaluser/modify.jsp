<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">

    <div class="card shadow">
        <div class="card-header text-right">
            <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                <button data-oper='modify' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.save" text="Save"/></button>
                <button data-oper='remove' class="btn btn-outline-danger btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.remove" text="Remove"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="piiapprovaluser_modify_form">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 40.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 70%"/>
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="th-get">
                                        <spring:message code="col.approvalid" text="Approvalid"/></th>
                                    <td class="td-get-l"><c:out value="${piiapprovaluser.approvalid}"/>
                                        <input type="hidden" class="form-control form-control-sm" name='approvalid'
                                               value='<c:out value="${piiapprovaluser.approvalid}"/>'>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get"><spring:message code="col.approvalname"
                                                                       text="Approvalname"/></th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                name='approvalname'
                                                                value='<c:out value="${piiapprovaluser.approvalname}"/>'>
                                        <c:out value="${piiapprovaluser.approvalname}"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get">
                                        <spring:message code="col.approvername" text="Approvername"/>
                                        <a class="collapse-item" href='javascript:diologSearchMember();'>
                                            <i class="fas fa-search"></i>
                                        </a>
                                    </th>
                                    <td class="td-get-l">
                                        <div id=approvalsuer_approvername><c:out
                                                value="${piiapprovaluser.approvername}"/></div>
                                        <input type="hidden" class="form-control form-control-sm" name='approverid'
                                               value='<c:out value="${piiapprovaluser.approverid}"/>'>
                                        <input type="hidden" class="form-control form-control-sm" name='approvername'
                                               value='<c:out value="${piiapprovaluser.approvername}"/>'>

                                    </td>
                                </tr>

                                </tbody>
                            </table>
                            <input type="hidden" class="form-control form-control-sm" name='seq'
                                   value='<c:out value="${piiapprovaluser.seq}"/>'>
                            <%--<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>--%>

                        </form>

                        <div id="modify_result"></div>

                        <form style="margin: 0; padding: 0;" role="form" id=searchForm_aum>
                            <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                            <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                            <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
                            <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
                            <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
                            <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
                            <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
                            <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
                            <input type='hidden' name='search7' value='<c:out value="${cri.search7}"/>'>
                            <input type='hidden' name='search8' value='<c:out value="${cri.search8}"/>'>
                        </form>

                    </div><!--  end panel-body -->
                </div><!--  panel panel-default-->
            </div><!-- col-lg-12 -->
        </div><!-- row  ml-1 -->
    </div>    <!-- <div class="card shadow mb-4"> DataTales begin-->
</div>
<!-- <div class="container-fluid"> -->

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
<!-- The Modal end-->

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.piiapprovaluser_management" text="Approvaline mgmt"/>" + ">Modify");
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='modify']").on("click", function (e) {

            var formsubmitSerialArray = $("#piiapprovaluser_modify_form").serializeArray();
            var formsubmit = JSON.stringify(serializeObject(formsubmitSerialArray));
            $.ajax({
                url: "/piiapprovaluser/modify?approverid_old=<c:out value='${piiapprovaluser.approverid}'/>" + "&approvername_old=<c:out value='${piiapprovaluser.approvername}'/>",
                //url : "/piiapprovaluser/modify",
                type: "post",
                data: formsubmit,
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr)  // json 형태로 보낼때는 xhr 를 실제 input에 넣지 말고 보내기 전에 추가해야 security에 인식 됨....(문자로 감싸지기 때문에...인식안됨)
                {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, status, error) {
                    $("#errormodalbody").html(status + "-" + request + "-" + error);
                    $("#errormodal").modal("show");
                },
                success: function (result, data) {
                    //elementResult.html(data); //받아온 data 실행
                    //alert(result + ":"+data);
                    if (result == "success") {
                        $("#GlobalSuccessMsgModal").modal("show");
                        goBackToList();
                    } else {
                        $("#errormodalbody").html(result);
                        $("#errormodal").modal("show");
                    }

                }
            });

        });

        $("button[data-oper='remove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
            if (confirmflag == false) {
                return;
            }

            var formsubmitSerialArray = $("#piiapprovaluser_modify_form").serializeArray();
            var formsubmit = JSON.stringify(serializeObject(formsubmitSerialArray));
            $.ajax({
                url: "/piiapprovaluser/remove",
                type: "post",
                data: formsubmit,
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (result, data) {
                    if (result == "success") {
                        $("#GlobalSuccessMsgModal").modal("show");
                        goBackToList();
                    } else {
                        $("#errormodalbody").html(result);
                        $("#errormodal").modal("show");
                    }
                }
            });

        });

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            goBackToList();

        });
        goBackToList = function () {
            var pagenum = $('#searchForm_aum [name="pagenum"]').val();
            var amount = $('#searchForm_aum [name="amount"]').val();
            var search1 = $('#searchForm_aum [name="search1"]').val();
            var search2 = $('#searchForm_aum [name="search2"]').val();
            var search3 = $('#searchForm_aum [name="search3"]').val();
            var search4 = $('#searchForm_aum [name="search4"]').val();
            var search5 = $('#searchForm_aum [name="search5"]').val();
            var search6 = $('#searchForm_aum [name="search6"]').val();
            var search7 = $('#searchForm_aum [name="search7"]').val();
            var search8 = $('#searchForm_aum [name="search8"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
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
            if (!isEmpty(search5)) {
                url_search += "&search5=" + search5;
            }
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6;
            }
            if (!isEmpty(search7)) {
                url_search += "&search7=" + search7;
            }
            if (!isEmpty(search8)) {
                url_search += "&search8=" + search8;
            }
            //alert("/piiapprovaluser/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiapprovaluser/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();//alert("통신성공!!!!");
                    $('#content_home').html(data);
                }
            });
        }
        diologSearchMember = function (no) {
            var pagenum = 1;
            var amount = 100;
            var url_view = "";
            var url_search = "";
            var search1 = $('#piiapprovaluser_modify_form [name="approverid"]').val();
            //var search3 = no;
            var search4 = "approval_modify";
            url_view = "diologsearchmember?";
            // if (!isEmpty(search1)) {
            // 	url_search += "&search1=" + search1;
            // }
            // if (!isEmpty(search3)) {
            //   url_search += "&search3=" + search3;
            // }
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4;
            }
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
                success: function (data) { ingHide();
                    $('#diologsearchmemberlistbody').html(data);
                    $("#diologsearchmemberlist").modal();

                }
            });
        }

    });
</script>
