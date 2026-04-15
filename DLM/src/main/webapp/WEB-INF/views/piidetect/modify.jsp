<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- on/off check box styles -->
<link rel="stylesheet" href="/resources/css/bootstrap4-toggle.css">
<script src="/resources/js/bootstrap4-toggle.js"></script>
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
            <button data-oper='list' id="goToList" class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="piiconfig_modify_form">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 70%">
                                <colgroup>
                                    <col style="width: 10%"/>
                                    <col style="width: 20%"/>
                                    <col style="width: 60%"/>
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th class="th-get">KEY</th>
                                    <td class="td-get-l" colspan=2><input type="hidden"
                                                                          class="form-control form-control-sm"
                                                                          name='cfgkey'
                                                                          value='<c:out value="${piiconfig.cfgkey}"/>'><c:out
                                            value="${piiconfig.cfgkey}"/></td>
                                </tr>
                                <tr>
                                    <th class="th-get">VALUE</th>
                                    <td class="td-get-l" colspan=2>

                                        <c:set var="cfgkey" value="${piiconfig.cfgkey}"/>
                                        <c:choose>
                                            <c:when test="${fn : contains(cfgkey, '_FLAG')}">
                                                <%-- <c:choose>
                                                    <c:when test="${piiconfig.value eq 'Y'}"> <input type="checkbox" name='checkboxvalue' value='<c:out value="${piiconfig.value}"/>' data-toggle="toggle" data-size="xs" checked ><input type="hidden" name='value' value='<c:out value="${piiconfig.value}"/>'> </c:when>
                                                    <c:otherwise> <input type="checkbox"  name='checkboxvalue' value='<c:out value="${piiconfig.value}"/>' data-toggle="toggle" data-size="xs" ><input type="hidden" name='value' value='<c:out value="${piiconfig.value}"/>'> </c:otherwise>
                                                </c:choose> --%>
                                                <select class="pt-0 pb-0 form-control form-control-sm" name="value"
                                                        style="width:100px;">
                                                    <option value="Y"
                                                            <c:if test="${piiconfig.value eq 'Y'}">selected</c:if> >On
                                                    </option>
                                                    <option value="N"
                                                            <c:if test="${piiconfig.value eq 'N'}">selected</c:if> >Off
                                                    </option>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <input type="text" class="form-control form-control-sm" name='value'
                                                       value='<c:out value="${piiconfig.value}"/>'>
                                            </c:otherwise>
                                        </c:choose>

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

                        <div id="modify_result"></div>

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

                    </div><!--  end panel-body -->
                </div><!--  panel panel-default-->
            </div><!-- col-lg-12 -->
        </div><!-- row  ml-1 -->
    </div>    <!-- <div class="card shadow mb-4"> DataTales begin-->
</div>
<!-- <div class="container-fluid"> -->

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.control_management" text="Env configration"/>" + ">Modify");
    });
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#piiconfig_modify_form [name="cfgkey"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piiconfig_modify_form");
            var elementResult = $("#content_home");

            /* if($('input:checkbox[name="checkboxvalue"]').is(":checked"))
                $('input[name="value"]').val("Y");
            else
                $('input[name="value"]').val("N");

            alert($('input[name="value"]').val()); */

            $.ajax({
                type: "POST",
                url: "/piiconfig/modify",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data); //받아온 data 실행

                    showToast("처리가 완료되었습니다.", false);
                    //$("#goToList").trigger("click");

                }
            });

        });

        $("button[data-oper='remove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            showConfirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>", function() {
                var elementForm = $("#piiconfig_modify_form");
                var elementResult = $("#content_home");
                $.ajax({
                    type: "POST",
                    url: "/piiconfig/remove",
                    dataType: "html",
                    //data:$('form').serialize(),
                    data: elementForm.serialize(),
                    error: function (request, error) { ingHide();
                        $("#errormodalbody").html(request.responseText);
                        $("#errormodal").modal("show");
                    },
                    success: function (data) { ingHide();
                        elementResult.html(data); //받아온 data 실행
                        showToast("처리가 완료되었습니다.", false);
                    }
                });
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
