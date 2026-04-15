<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">
    <!-- Page Heading -->


    <div class="card shadow mb-4">
        <div class="card-header text-right">
            <sec:authorize access="isAuthenticated()">
                <button data-oper='modify' class="btn btn-primary"><spring:message code="btn.modify"
                                                                                   text="Modify"/></button>
                <button data-oper='remove' class="btn btn-outline-danger"><spring:message code="btn.remove"
                                                                                   text="Remove"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-info">List</button>
        </div>

        <div class="row m-1">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <form style="margin: 0; padding: 0;" role="form" id="piiconfkeymap_modify_form" action="/piiconfkeymap/modify" method="post">
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputinsertstr">Keymap_id</label><input
                                        type="text" class="form-control form-control-sm" id="inputkeymap_id"
                                        name='keymap_id' value='<c:out value="${piiconfkeymap.keymap_id}"/>'></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-2"><label for="inputkey_name">Key_Name</label><input
                                        type="text" class="form-control form-control-sm" id="inputkey_name"
                                        name='key_name' value='<c:out value="${piiconfkeymap.key_name}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputdb">Db</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputdb"
                                                                                                       name='db'
                                                                                                       value='<c:out value="${piiconfkeymap.db}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputseq1">Seq1</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq1"
                                                                                                           name='seq1'
                                                                                                           value='<c:out value="${piiconfkeymap.seq1}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputseq2">Seq2</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq2"
                                                                                                           name='seq2'
                                                                                                           value='<c:out value="${piiconfkeymap.seq2}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputseq3">Seq3</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq3"
                                                                                                           name='seq3'
                                                                                                           value='<c:out value="${piiconfkeymap.seq3}"/>'>
                                </div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-3"><label for="inputkey_cols">Key_Cols</label><input
                                        type="text" class="form-control form-control-sm" id="inputkey_cols"
                                        name='key_cols' value='<c:out value="${piiconfkeymap.key_cols}"/>'></div>
                                <div class="form-group col-sm-3"><label for="inputsrc_owner">Src_Owner</label><input
                                        type="text" class="form-control form-control-sm" id="inputsrc_owner"
                                        name='src_owner' value='<c:out value="${piiconfkeymap.src_owner}"/>'></div>
                                <div class="form-group col-sm-3"><label for="inputsrc_table_name">Src_Table_Name</label><input
                                        type="text" class="form-control form-control-sm" id="inputsrc_table_name"
                                        name='src_table_name' value='<c:out value="${piiconfkeymap.src_table_name}"/>'>
                                </div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-3"><label for="inputwhere_col">Where_Col</label><input
                                        type="text" class="form-control form-control-sm" id="inputwhere_col"
                                        name='where_col' value='<c:out value="${piiconfkeymap.where_col}"/>'></div>
                                <div class="form-group col-sm-3"><label for="inputwhere_key_name">Where_Key_name</label><input
                                        type="text" class="form-control form-control-sm" id="inputwhere_key_name"
                                        name='where_key_name' value='<c:out value="${piiconfkeymap.where_key_name}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputparallelcnt">ParallelCnt</label><input
                                        type="text" class="form-control form-control-sm" id="inputparallelcnt"
                                        name='parallelcnt' value='<c:out value="${piiconfkeymap.parallelcnt}"/>'></div>
                                <div class="form-group col-sm-1"><label for="inputstatus">Status</label><input
                                        type="text" class="form-control form-control-sm" id="inputstatus" name='status'
                                        value='<c:out value="${piiconfkeymap.status}"/>'></div>
                                <div class="form-group col-sm-1"><label for="inputsqltype">Sqltype</label><input
                                        type="text" class="form-control form-control-sm" id="inputsqltype"
                                        name='sqltype' value='<c:out value="${piiconfkeymap.sqltype}"/>'></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputinsertstr">Insertstr</label><input
                                        type="text" class="form-control form-control-sm" id="inputinsertstr"
                                        name='insertstr' value='<c:out value="${piiconfkeymap.insertstr}"/>'></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputwherestr">Wherestr</label><textarea
                                        spellcheck="false" rows="5" class="form-control form-control-sm"
                                        id="inputwherestr" name='wherestr'><c:out
                                        value="${piiconfkeymap.wherestr}"/></textarea></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputrefstr">Refstr</label><textarea
                                        spellcheck="false" rows="2" class="form-control form-control-sm"
                                        id="inputrefstr" name='refstr'><c:out
                                        value="${piiconfkeymap.refstr}"/></textarea></div>
                            </div>

                            <input type="hidden" name='regdate' value='<c:out value="${piiconfkeymap.regdate}"/>'>
                            <input type="hidden" name='upddate' value=''>
                            <input type="hidden" name='reguserid' value='<c:out value="${piiconfkeymap.reguserid}"/>'>
                            <input type="hidden" name='upduserid'
                                   value='<sec:authentication property="principal.member.userid"/>'>
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        </form>

                        <div id="modify_result"></div>

                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                            <input type='hidden' name='pagenum'
                                   value='<c:out value="${cri.pagenum}"/>'> <input
                                type='hidden' name='amount'
                                value='<c:out value="${cri.amount}"/>'> <input
                                type='hidden' name='key_name'
                                value='<c:out value="${cri.search1}"/>'> <input
                                type='hidden' name='key_cols'
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.keymap" text="ConfKeymap management"/>" + ">Modify");
    });
    $(document).ready(function () {

        $("button[data-oper='modify']").on("click", function (e) {

            var elementForm = $("#piiconfkeymap_modify_form");
            var elementResult = $("#content_home"); //alert($('#piiconfkeymap_modify_form [name="key_name"]').val());
            $.ajax({
                type: "POST",
                url: "/piiconfkeymap/modify",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) { ingHide();//alert("Successful!");alert(data);
                    elementResult.html(data); //받아온 data 실행
                    //elementResult.text(Parse_data); //받아온 data 실행
                }
            });

        });

        $("button[data-oper='remove']").on("click", function (e) {
            showConfirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>", function() {
                var elementForm = $("#piiconfkeymap_modify_form");
                var elementResult = $("#content_home");
                $.ajax({
                    type: "POST",
                    url: "/piiconfkeymap/remove",
                    dataType: "html",
                    //data:$('form').serialize(),
                    data: elementForm.serialize(),
                    error: function (request, error) { ingHide();
                        $("#errormodalbody").html(request.responseText);
                        $("#errormodal").modal("show");
                    },
                    success: function (data) { ingHide();
                        dlmAlert("Successful!");
                        elementResult.html(data); //받아온 data 실행
                        //elementResult.text(Parse_data); //받아온 data 실행
                    }
                });
            });

        });

        $("button[data-oper='list']").on("click", function (e) {

            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var keymap_id = $('#searchForm [name="keymap_id"]').val();
            var key_name = $('#searchForm [name="key_name"]').val();
            var key_cols = $('#searchForm [name="key_cols"]').val();
            var url_search = "";
            //alert("pagenum="+pagenum+"&amount="+"&search1="+key_name+"&search2="+key_cols);

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(keymap_id)) {
                url_search += "&search1=" + keymap_id
            }
            ;
            if (!isEmpty(key_name)) {
                url_search += "&search2=" + key_name
            }
            ;
            if (!isEmpty(key_cols)) {
                url_search += "&search3=" + key_cols
            }
            ;

            //alert("/piiconfkeymap/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiconfkeymap/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
