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
                <button data-oper='register' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.register" text="Register"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="registerapprovalline_register_form" action="/piiapprovaluser/registerApprovalline"
                              method="post">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 50.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 60%"/>
                                </colgroup>
                                <tbody>

                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.approvalid" text="Approvalid" /></th>
                                    <td class="td-get">
                                        <select class="pt-0 pb-0 form-control form-control-sm" id="approvalid" name="approvalid"
                                                style="height:25px">
                                            <c:forEach items="${Approvallist}" var="approval">
                                                <option value="<c:out value="${approval.approvalid}"/>">
                                                    <c:out value="${approval.approvalname}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.aprvlineid" text="Approval Line" /></th>
                                    <td class="td-get">
                                        <input type="text" class="form-control form-control-sm" name='aprvlineid' onkeyup="characterCheck(this)"
                                               onkeydown="characterCheck(this)" >
                                    </td>
                                </tr>
                                <input type="hidden" class="form-control form-control-sm" name='approvalname' ></td>
                                </tbody>
                            </table>


                        </form>

                        <div id="register_result"></div>

                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                            <input type='hidden' name='pagenum'
                                   value='<c:out value="${cri.pagenum}"/>'> <input
                                type='hidden' name='amount'
                                value='<c:out value="${cri.amount}"/>'> <input
                                type='hidden' name='search1'
                                value='<c:out value="${cri.search1}"/>'> <input
                                type='hidden' name='search2'
                                value='<c:out value="${cri.search2}"/>'>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.piiapprovaluser_management" text="Approvaline mgmt"/>" + ">Register");
    });
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
        $('#registerapprovalline_register_form [name="approvalid"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $("button[data-oper='register']").on("click", function (e) {

            var formsubmitSerialArray = $("#registerapprovalline_register_form").serializeArray();
            var formsubmit = JSON.stringify(serializeObject(formsubmitSerialArray));
            $.ajax({
                url: "/piiapprovaluser/registerapprovalline",
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
        diologSearchMember = function (no) {
            var pagenum = 1;
            var amount = 100;
            var url_view = "";
            var url_search = "";
            var search2 = "";//$('#piijob_modify_form [name="job_owner_name1"]').val();
            var search3 = no;
            var search4 = "approval_register";

            url_view = "diologsearchmember?";
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2;
            }
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3;
            }
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
                success: function (data) { ingHide();//alert('success1');
                    $('#diologsearchmemberlistbody').html(data);
                    $("#diologsearchmemberlist").modal();

                }
            });
        }
        goBackToList = function () {
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";
            //alert("pagenum="+pagenum+"&amount="+"&search1="+db+"&search2="+db);

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) {
                url_search += "&search1=" + search1
            }
            ;
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2
            }
            ;

            //alert("/piiapprovaluser/approvallinelist?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiapprovaluser/approvallinelist?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
    });
</script>
