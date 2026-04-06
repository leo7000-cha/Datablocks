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
                        <form style="margin: 0; padding: 0;" role="form" id="piiconfig_register_form" method="post">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 70.7%">
                                <colgroup>
                                    <col style="width: 20%"/>
                                    <col style="width: 40%"/>
                                    <col style="width: 40%"/>
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="th-get">KEY</th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" autofocus
                                                              name='cfgkey'
                                                              value='<c:out value="${piiconfig.cfgkey}"/>'></td>
                                </tr>
                                <tr>
                                    <th class="th-get">VALUE</th>
                                    <td class="td-get" colspan=2><input type="text" class="form-control form-control-sm"
                                                                        name='value'
                                                                        value='<c:out value="${piiconfig.value}"/>'>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get">COMMENTS</th>
                                    <td class="td-get" colspan=2><input type="text" class="form-control form-control-sm"
                                                                        name='comments'
                                                                        value='<c:out value="${piiconfig.comments}"/>'>
                                    </td>
                                </tr>


                                </tbody>
                            </table>

                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        </form>
                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                            <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                            <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                            <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
                            <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.control_management" text="Env configration"/>" + ">Register");
    });
    $(document).ready(function () {

        $('#piiconfig_register_form [name="cfgkey"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piiconfig_register_form");
            var elementResult = $("#content_home");
            $.ajax({
                type: "POST",
                url: "/piiconfig/register",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data); //받아온 data 실행
                }
            });

        });


        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            /* var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val(); */
            var url_search = "";
            //alert("pagenum="+pagenum+"&amount="+"&search1="+userid+"&search2="+db);

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            /* if (!isEmpty(search1)) {url_search += "&search1="+search1};
            if (!isEmpty(search2))  {url_search += "&search2="+search2}; */

            //alert("/piiconfig/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiconfig/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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