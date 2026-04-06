<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">
    <!-- Page Heading -->
    <div class="card shadow">
        <div class="card-header text-right">
            <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                <button data-oper='modify' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.modify" text="Modify"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="piiauth_get_form" method="post">
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
                                        <c:out value="${piiauth.auth}"/><input type="hidden"
                                                                               class="form-control form-control-sm"
                                                                               name='auth'
                                                                               value='<c:out value="${piiauth.auth}"/>'>
                                    </td>
                                </tr>


                                </tbody>
                            </table>

                            <%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> --%>
                        </form>
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

                    </div>
                    <!--  end panel-body -->
                </div>
                <!--  panel panel-default-->
            </div>
            <!-- col-lg-12 -->
        </div>
        <!-- row  ml-1 -->
    </div>
    <!-- <div class="card shadow"> DataTales begin-->
    <div id="get_Result"></div>
</div>
<!-- <div class="container-fluid"> -->

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.auth_management" text="Auth management"/>" + ">Details");
    });
    $(document).ready(function () {

        $("button[data-oper='modify']").on("click", function (e) {

            e.preventDefault();e.stopPropagation();
            var serchkeyno1 = $('#piiauth_get_form [name="userid"]').val();
            var serchkeyno2 = $('#piiauth_get_form [name="auth"]').val();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";
            var url_view = "";

            url_view = "modify?userid=" + serchkeyno1 + "&" + "auth=" + serchkeyno2 + "&";//alert("/piiauth/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) {
                url_search += "&search1=" + search1;
            }
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search1;
            }
            //alert("/piiauth/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/piiauth/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "text",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    $('#content_home').html(data);
                    //$('#content_home').load(data);
                }
            });

        });

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";
            //alert("pagenum="+pagenum+"&amount="+"&search1="+userid+"&search2="+db);

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