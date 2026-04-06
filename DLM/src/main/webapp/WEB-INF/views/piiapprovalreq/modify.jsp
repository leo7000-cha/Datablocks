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

                <button data-oper='modify' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.save" text="Save"/></button>

            <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="piiapprovalreq_modify_form">
                            <table class="m-1" style="border-collapse: collapse; border: 1px; width: 40.7%">
                                <colgroup>
                                    <col style="width: 30%"/>
                                    <col style="width: 70%"/>
                                </colgroup>
                                <tbody>


                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.reqid" text="Reqid" /></th>
                                    <td class="td-get-l"><c:out value="${piiapprovalreq.reqid}" /><input type="hidden" class="form-control form-control-sm" name='reqid' value='<c:out value="${piiapprovalreq.reqid}" />'></td>
                                </tr>
                               <%-- <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.approvalid" text="Approvalid" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='approvalid' value='<c:out value="${piiapprovalreq.approvalid}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.approvalname" text="Approvalname" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='approvalname' value='<c:out value="${piiapprovalreq.approvalname}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.seq" text="Seq" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='seq' value='<c:out value="${piiapprovalreq.seq}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.phase" text="Phase" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='phase' value='<c:out value="${piiapprovalreq.phase}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.jobid" text="Jobid" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='jobid' value='<c:out value="${piiapprovalreq.jobid}" />'></td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.version" text="Version" /></th>
                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='version' value='<c:out value="${piiapprovalreq.version}" />'></td>
                                </tr>--%>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.approverid" text="Approverid" /></th>
                                    <td class="td-get-l">
                                        <select class="pt-0 pb-0 form-control form-control-sm" id="approverid" name="approverid"
                                                style="height:25px">
                                            <c:forEach items="${approvaluserlist}" var="approvaluser">
                                                <c:if test="${approvaluser.approvalid eq 'RESTORE_APPROVAL'}">
                                                    <option value="<c:out value="${approvaluser.approverid}"/>"
                                                            <c:if test="${approvaluser.approverid eq piiapprovalreq.approverid}">selected</c:if> >
                                                        <c:out value="${approvaluser.approvername}"/> [ <c:out
                                                            value="${approvaluser.approverid}"/> ]
                                                    </option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
<%--                                <tr>--%>
<%--                                    <th scope="row" class="th-get"><spring:message code="col.approvername" text="Approvername" /></th>--%>
<%--                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='approvername' value='<c:out value="${piiapprovalreq.approvername}" />'></td>--%>
<%--                                </tr>--%>
<%--                                <tr>--%>
<%--                                    <th scope="row" class="th-get"><spring:message code="col.requesterid" text="Requesterid" /></th>--%>
<%--                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='requesterid' value='<c:out value="${piiapprovalreq.requesterid}" />'></td>--%>
<%--                                </tr>--%>
<%--                                <tr>--%>
<%--                                    <th scope="row" class="th-get"><spring:message code="col.requestername" text="Requestername" /></th>--%>
<%--                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='requestername' value='<c:out value="${piiapprovalreq.requestername}" />'></td>--%>
<%--                                </tr>--%>
<%--                                <tr>--%>
<%--                                    <th scope="row" class="th-get"><spring:message code="col.reqdate" text="Reqdate" /></th>--%>
<%--                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='reqdate' value='<c:out value="${piiapprovalreq.reqdate}" />'></td>--%>
<%--                                </tr>--%>
<%--                                <tr>--%>
<%--                                    <th scope="row" class="th-get"><spring:message code="col.approvedate" text="Approvedate" /></th>--%>
<%--                                    <td class="td-get"><input type="text" class="form-control form-control-sm" name='approvedate' value='<c:out value="${piiapprovalreq.approvedate}" />'></td>--%>
<%--                                </tr>--%>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.reqreason" text="Reqreason" /></th>
                                    <td class="td-get">

                                        <textarea spellcheck="false" rows="15" cols="90" class="form-control form-control-sm"
                                                  name='reqreason' id='reqreason'><c:out value="${piiapprovalreq.reqreason}"/></textarea>
                                    </td>

                                </tr>

                                </tbody>
                            </table>

                        </form>

                        <div id="modify_result"></div>

                        <form style="margin: 0; padding: 0;" role="form" id=searchForm_req>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.approval_request" text="My Request list"/>" + ">Modify");
    });
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var formsubmitSerialArray = $("#piiapprovalreq_modify_form").serializeArray();
            var formsubmit = JSON.stringify(serializeObject(formsubmitSerialArray));
            $.ajax({
                url: "/piiapprovalreq/modifyApprover",
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
        goBackToList = function () {
            var pagenum = $('#searchForm_req [name="pagenum"]').val();
            var amount = $('#searchForm_req [name="amount"]').val();
            var search1 = $('#searchForm_req [name="search1"]').val();
            var search2 = $('#searchForm_req [name="search2"]').val();
            var search3 = $('#searchForm_req [name="search3"]').val();
            var search4 = $('#searchForm_req [name="search4"]').val();
            var search5 = $('#searchForm_req [name="search5"]').val();
            var search6 = $('#searchForm_req [name="search6"]').val();
            var search7 = $('#searchForm_req [name="search7"]').val();
            var search8 = $('#searchForm_req [name="search8"]').val();
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
            //alert("/piiapprovalreq/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiapprovalreq/myrequestlist?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
        $("button[data-oper='remove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
            if (confirmflag == false) {
                return;
            }

            var elementForm = $("#piiapprovalreq_modify_form");
            var elementResult = $("#content_home");
            $.ajax({
                type: "POST",
                url: "/piiapprovalreq/remove",
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
            goBackToList();
        });

    });
</script>
