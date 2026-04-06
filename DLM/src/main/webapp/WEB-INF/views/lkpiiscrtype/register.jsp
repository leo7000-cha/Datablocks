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
                        <form style="margin: 0; padding: 0;" role="form" id="lkpiiscrtype_modify_form" method="post">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 50.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 70%"/>
                                </colgroup>
                                <tbody>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piicode" text="Piicode" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piicode' value='<c:out value="${lkpiiscrtype.piicode}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piigradeid" text="Piigradeid" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piigradeid' value='<c:out value="${lkpiiscrtype.piigradeid}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piigradename" text="Piigradename" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piigradename' value='<c:out value="${lkpiiscrtype.piigradename}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piigroupid" text="Piigroupid" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piigroupid' value='<c:out value="${lkpiiscrtype.piigroupid}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piigroupname" text="Piigroupname" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piigroupname' value='<c:out value="${lkpiiscrtype.piigroupname}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piitypeid" text="Piitypeid" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piitypeid' value='<c:out value="${lkpiiscrtype.piitypeid}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.piitypename" text="Piitypename" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='piitypename' value='<c:out value="${lkpiiscrtype.piitypename}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.scrtype" text="Scrtype" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='scrtype' value='<c:out value="${lkpiiscrtype.scrtype}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.scrmethod" text="Scrmethod" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='scrmethod' value='<c:out value="${lkpiiscrtype.scrmethod}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.scrcategory" text="Scrcategory" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='scrcategory' value='<c:out value="${lkpiiscrtype.scrcategory}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.scrdigits" text="Scrdigits" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='scrdigits' value='<c:out value="${lkpiiscrtype.scrdigits}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.scrvalidity" text="Scrvalidity" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='scrvalidity' value='<c:out value="${lkpiiscrtype.scrvalidity}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.remarks" text="Remarks" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='remarks' value='<c:out value="${lkpiiscrtype.remarks}" />'></td>

                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.encdecfunctype" text="Encdecfunctype" /></th>
                                    <td class="td-get">
                                        <%--<input type="text" class="form-control form-control-sm" name='encdecfunctype' value='<c:out value="${lkpiiscrtype.encdecfunctype}" />'>--%>
                                        <select style="height:25px;" class="pt-0 pb-0 form-control form-control-sm" id="encdecfunctype" name="encdecfunctype">
                                            <option value="" >
                                            </option>
                                            <option value="JAVA API"
                                                    <c:if test="${lkpiiscrtype.encdecfunctype eq 'JAVA API'}">selected</c:if>>JAVA API
                                            </option>
                                            <option value="DB"
                                                    <c:if test="${lkpiiscrtype.encdecfunctype eq 'DB'}">selected</c:if>>DB
                                            </option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.encfunc" text="Encfunc" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='encfunc' value='<c:out value="${lkpiiscrtype.encfunc}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.decfunc" text="Decfunc" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='decfunc' value='<c:out value="${lkpiiscrtype.decfunc}" />'></td>
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
        $("#menupath").html(Menupath + ">Modify");
    });
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var piicode = $('#lkpiiscrtype_modify_form [name="piicode"]').val();
            var piigradeid = $('#lkpiiscrtype_modify_form [name="piigradeid"]').val();
            var piigradename = $('#lkpiiscrtype_modify_form [name="piigradename"]').val();
            var piigroupid = $('#lkpiiscrtype_modify_form [name="piigroupid"]').val();
            var piigroupname = $('#lkpiiscrtype_modify_form [name="piigroupname"]').val();

            var piitypeid = $('#lkpiiscrtype_modify_form [name="piitypeid"]').val();
            var piitypename = $('#lkpiiscrtype_modify_form [name="piitypename"]').val();
            var scrtype = $('#lkpiiscrtype_modify_form [name="scrtype"]').val();
            var scrmethod = $('#lkpiiscrtype_modify_form [name="scrmethod"]').val();
            var scrcategory = $('#lkpiiscrtype_modify_form [name="scrcategory"]').val();
            //var system_info = $('#lkpiiscrtype_modify_form [name="system_info"]').val();

            if (piicode === null || piicode === undefined || piicode.trim() === '') {
                alert("piicode is madatory value for " + piicode);
                $('#lkpiiscrtype_modify_form [name="piicode"]').focus();
                return;
            }
            if (piigradeid === null || piigradeid === undefined || piigradeid.trim() === '') {
                alert("piigradeid is madatory value for " + piigradeid);
                $('#lkpiiscrtype_modify_form [name="piigradeid"]').focus();
                return;
            }
            if (piigradename === null || piigradename === undefined || piigradename.trim() === '') {
                alert("piigradename is madatory value for " + piigradename);
                $('#lkpiiscrtype_modify_form [name="piigradename"]').focus();
                return;
            }
            if (piigroupid === null || piigroupid === undefined || piigroupid.trim() === '') {
                alert("piigroupid is madatory value for " + piigroupid);
                $('#lkpiiscrtype_modify_form [name="piigroupid"]').focus();
                return;
            }
            if (piigroupname === null || piigroupname === undefined || piigroupname.trim() === '') {
                alert("piigroupname is madatory value for " + piigroupname);
                $('#lkpiiscrtype_modify_form [name="piigroupname"]').focus();
                return;
            }

            if (piitypeid === null || piitypeid === undefined || piitypeid.trim() === '') {
                alert("piitypeid is madatory value for " + piitypeid);
                $('#lkpiiscrtype_modify_form [name="piitypeid"]').focus();
                return;
            }
            if (piitypename === null || piitypename === undefined || piitypename.trim() === '') {
                alert("piitypename is madatory value for " + piitypename);
                $('#lkpiiscrtype_modify_form [name="piitypename"]').focus();
                return;
            }
            if (scrtype === null || scrtype === undefined || scrtype.trim() === '') {
                alert("scrtype is madatory value for " + scrtype);
                $('#lkpiiscrtype_modify_form [name="scrtype"]').focus();
                return;
            }
            if (scrmethod === null || scrmethod === undefined || scrmethod.trim() === '') {
                alert("scrmethod is madatory value for " + scrmethod);
                $('#lkpiiscrtype_modify_form [name="scrmethod"]').focus();
                return;
            }
            if (scrcategory === null || scrcategory === undefined || scrcategory.trim() === '') {
                alert("scrcategory is madatory value for " + scrcategory);
                $('#lkpiiscrtype_modify_form [name="scrcategory"]').focus();
                return;
            }
            var elementForm = $("#lkpiiscrtype_modify_form");
            var elementResult = $("#content_home");

            ingShow(); $.ajax({
                type: "POST",
                url: "/lkpiiscrtype/register",
                dataType: "html",
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) { ingHide();
                    elementResult.html(data); //받아온 data 실행
                    $("#GlobalSuccessMsgModal").modal("show");
                }
            });

        });

        $("button[data-oper='remove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
            if (confirmflag == false) {
                return;
            }
            var elementForm = $("#lkpiiscrtype_modify_form");
            var elementResult = $("#content_home");
            ingShow(); $.ajax({
                type: "POST",
                url: "/lkpiiscrtype/remove",
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
            //alert("/lkpiiscrtype/list?pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/lkpiiscrtype/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
