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
            <sec:authorize access="isAuthenticated()">
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
                        <form style="margin: 0; padding: 0;" role="form" id="piisystem_get_form" method="post">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 50.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 70%"/>
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="th-get"><spring:message code="col.system_id" text="SystemID"/></th>
                                    <td class="td-get-l"><c:out value="${piisystem.system_id}"/><input type="hidden"
                                                                                                          class="form-control form-control-sm"
                                                                                                          name='system_id'
                                                                                                          value='<c:out value="${piisystem.system_id}"/>'>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get"><spring:message code="col.system_name" text="System Name"/></th>
                                    <td class="td-get-l"><c:out value="${piisystem.system_name}"/><input type="hidden"
                                                                                                      class="form-control form-control-sm"
                                                                                                      name='system_name'
                                                                                                      value='<c:out value="${piisystem.system_name}"/>'>
                                    </td>
                                </tr>
                                <tr>
                                    <th class="th-get"><spring:message code="col.system_info" text="System Info"/></th>
                                    <td class="td-get-l"><c:out value="${piisystem.system_info}"/><input type="hidden"
                                                                                                         class="form-control form-control-sm"
                                                                                                         name='system_info'
                                                                                                         value='<c:out value="${piisystem.system_info}"/>'>
                                    </td>
                                </tr>
                                </tbody>
                            </table>

                            <%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> --%>
                        </form>
                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.systemmgmt" text="System Management"/>" + ">Details");

    });
    $(document).ready(function () {

        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val().toUpperCase();
            var search2 = $('#searchForm [name="search2"]').val().toUpperCase();
            var search3 = $('#searchForm [name="search3"]').val();
            var search4 = $('#searchForm [name="search4"]').val();
            var search5 = $('#searchForm [name="search5"]').val();
            var search6 = $('#searchForm [name="search6"]').val();
            var search7 = $('#searchForm [name="search7"]').val();
            var search8 = $('#searchForm [name="search8"]').val();
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

            var serchkeyno = $('#piisystem_get_form [name="system_id"]').val();
            url_view = "modify?system_id=" + serchkeyno + "&";

            //alert("/piisystem/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piisystem/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
            var search1 = $('#searchForm [name="search1"]').val().toUpperCase();
            var search2 = $('#searchForm [name="search2"]').val().toUpperCase();
            var search3 = $('#searchForm [name="search3"]').val();
            var search4 = $('#searchForm [name="search4"]').val();
            var search5 = $('#searchForm [name="search5"]').val();
            var search6 = $('#searchForm [name="search6"]').val();
            var search7 = $('#searchForm [name="search7"]').val();
            var search8 = $('#searchForm [name="search8"]').val();
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
            //alert("/piisystem/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piisystem/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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