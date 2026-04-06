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
                        <form style="margin: 0; padding: 0;" role="form" id="piiauth_modify_form">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 40.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 70%"/>
                                </colgroup>
                                <tbody>

                                <tr>
                                    <th class="th-get"><spring:message code="col.userid" text="Userid"/></th>
                                    <td class="td-get-l">
                                        <c:out value="${piiauth.userid}"/><input type="hidden"
                                                                                 class="form-control form-control-sm"
                                                                                 name='userid'
                                                                                 value='<c:out value="${piiauth.userid}"/>'>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get"><spring:message code="col.auth" text="Auth"/></th>
                                    <td class="td-get-l">
                                        <input type="hidden" class="form-control form-control-sm" name='auth'
                                               value='<c:out value="${piiauth.auth}"/>'>
                                        <select class="pt-0 pb-0 form-control form-control-sm" name="authtochange"
                                                style="height:27px;">
                                            <option value="ROLE_IT"
                                                    <c:if test="${piiauth.auth eq 'ROLE_IT'}">selected</c:if> >ROLE_IT
                                            </option>
                                            <option value="ROLE_BIZ"
                                                    <c:if test="${piiauth.auth eq 'ROLE_BIZ'}">selected</c:if> >ROLE_BIZ
                                            </option>
                                            <option value="ROLE_SEC"
                                                    <c:if test="${piiauth.auth eq 'ROLE_SEC'}">selected</c:if> >ROLE_SEC
                                            </option>
                                            <option value="ROLE_ADMIN"
                                                    <c:if test="${piiauth.auth eq 'ROLE_ADMIN'}">selected</c:if> >
                                                ROLE_ADMIN
                                            </option>
                                            <option value="ROLE_USER"
                                                    <c:if test="${piiauth.auth eq 'ROLE_USER'}">selected</c:if> >
                                                ROLE_USER
                                            </option>
                                        </select>
                                    </td>
                                </tr>

                                </tbody>
                            </table>

                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        </form>

                        <div id="modify_result"></div>

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

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.auth_management" text="Auth management"/>" + ">Modify");
    });
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='modify']").on("click", function (e) {

            var elementForm = $("#piiauth_modify_form");
            var elementResult = $("#content_home");
            ingShow(); $.ajax({
                type: "POST",
                url: "/piiauth/modify",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data); //받아온 data 실행
                    $("#GlobalSuccessMsgModal").modal("show");

                }
            });

        });

        $("button[data-oper='remove']").on("click", function (e) {
            var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
            if (confirmflag == false) {
                return;
            }

            var elementForm = $("#piiauth_modify_form");
            var elementResult = $("#content_home");
            ingShow(); $.ajax({
                type: "POST",
                url: "/piiauth/remove",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data); //받아온 data 실행
                    $("#GlobalSuccessMsgModal").modal("show");
                }
            });

        });

        $("button[data-oper='list']").on("click", function (e) {

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

            //alert("/piiauth/list?pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/piiauth/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();//alert("통신성공!!!!");
                    $('#content_home').html(data);
                }
            });

        });

    });
</script>
