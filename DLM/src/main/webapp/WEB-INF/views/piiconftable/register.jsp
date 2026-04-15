<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">

    <div class="card shadow mb-4">
        <div class="card-header text-right">
            <sec:authorize access="isAuthenticated()">
                <button data-oper='register' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message
                        code="btn.register" text="Register"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
        </div>

        <div class="row  ml-1">
            <div class="col-lg-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">

                        <form style="margin: 0; padding: 0;" role="form" id="piiconftable_register_form" action="/piiconftable/register" method="post">

                            <div class="form-row ">
                                <div class="form-group col-sm-2"><label for="inputdb">DB</label><input
                                        type="text" class="form-control form-control-sm" id="inputdb" autofocus
                                        name='db' value='<c:out value="${piiconftable.db}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputowner">Owner</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputowner"
                                                                                                             name='owner'
                                                                                                             value='<c:out value="${piiconftable.owner}"/>'>
                                </div>
                                <div class="form-group col-sm-3"><label for="inputtable_name">Table_Name</label><input
                                        type="text" class="form-control form-control-sm" id="inputtable_name"
                                        name='table_name' value='<c:out value="${piiconftable.table_name}"/>'></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-2"><label for="inputpagitype">Pagitype</label><input
                                        type="text" class="form-control form-control-sm" id="inputpagitype"
                                        name='pagitype' value='<c:out value="${piiconftable.pagitype}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputpagitypedetail">Pagitypedetail</label><input
                                        type="text" class="form-control form-control-sm" id="inputpagitypedetail"
                                        name='pagitypedetail' value='<c:out value="${piiconftable.pagitypedetail}"/>'>
                                </div>
                                <div class="form-group col-sm-2"><label for="inputarchiveflag">Archiveflag</label><input
                                        type="text" class="form-control form-control-sm" id="inputarchiveflag"
                                        name='archiveflag' value='<c:out value="${piiconftable.archiveflag}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputstatus">Status</label><input
                                        type="text" class="form-control form-control-sm" id="inputstatus" name='status'
                                        value='<c:out value="${piiconftable.status}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputpreceding">Preceding</label><input
                                        type="text" class="form-control form-control-sm" id="inputpreceding"
                                        name='preceding' value='<c:out value="${piiconftable.preceding}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputsuccedding">Succedding</label><input
                                        type="text" class="form-control form-control-sm" id="inputsuccedding"
                                        name='succedding' value='<c:out value="${piiconftable.succedding}"/>'></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-1"><label for="inputseq1">Seq1</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq1"
                                                                                                           name='seq1'
                                                                                                           value='<c:out value="${piiconftable.seq1}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputseq2">Seq2</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq2"
                                                                                                           name='seq2'
                                                                                                           value='<c:out value="${piiconftable.seq2}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputseq3">Seq3</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputseq3"
                                                                                                           name='seq3'
                                                                                                           value='<c:out value="${piiconftable.seq3}"/>'>
                                </div>
                                <div class="form-group col-sm-1"><label for="inputpipeline">Pipeline</label><input
                                        type="text" class="form-control form-control-sm" id="inputpipeline"
                                        name='pipeline' value='<c:out value="${piiconftable.pipeline}"/>'></div>
                                <div class="form-group col-sm-4"><label for="inputpk_columns">Pk_Columns</label><input
                                        type="text" class="form-control form-control-sm" id="inputpk_columns"
                                        name='pk_columns' value='<c:out value="${piiconftable.pk_columns}"/>'></div>
                                <div class="form-group col-sm-1"><label for="inputpk_data_type">Pk_Type</label><input
                                        type="text" class="form-control form-control-sm" id="inputpk_data_type"
                                        name='pk_data_type' value='<c:out value="${piiconftable.pk_data_type}"/>'></div>
                                <div class="form-group col-sm-2"><label
                                        for="inputimatable_name">Imatable_Name</label><input type="text"
                                                                                             class="form-control form-control-sm"
                                                                                             id="inputimatable_name"
                                                                                             name='imatable_name'
                                                                                             value='<c:out value="${piiconftable.imatable_name}"/>'>
                                </div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-2"><label for="inputmasterkey">Masterkey</label><input
                                        type="text" class="form-control form-control-sm" id="inputmasterkey"
                                        name='masterkey' value='<c:out value="${piiconftable.masterkey}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputwhere_col">Where_Col</label><input
                                        type="text" class="form-control form-control-sm" id="inputwhere_col"
                                        name='where_col' value='<c:out value="${piiconftable.where_col}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputwhere_key_name">Where_key_name</label><input
                                        type="text" class="form-control form-control-sm" id="inputwhere_key_name"
                                        name='where_key_name' value='<c:out value="${piiconftable.where_key_name}"/>'>
                                </div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputwherestr">Wherestr</label><textarea
                                        spellcheck="false" rows="4" class="form-control form-control-sm"
                                        id="inputwherestr" name='wherestr'><c:out
                                        value="${piiconftable.wherestr}"/></textarea></div>
                            </div>
                            <div class="form-row ">
                                <div class="form-group col-sm-2"><label for="inputparallelcnt">Parallelcnt</label><input
                                        type="text" class="form-control form-control-sm" id="inputparallelcnt"
                                        name='parallelcnt' value='<c:out value="${piiconftable.parallelcnt}"/>'></div>
                                <div class="form-group col-sm-2"><label for="inputtotalcnt">Totalcnt</label><input
                                        type="text" class="form-control form-control-sm" id="inputtotalcnt"
                                        name='totalcnt' value='<c:out value="${piiconftable.totalcnt}"/>'></div>
                            </div>

                            <input type="hidden" name='regdate' value=''>
                            <input type="hidden" name='upddate' value=''>
                            <input type="hidden" name="reguserid"
                                   value='<sec:authentication property="principal.member.userid"/>'/>
                            <input type="hidden" name="upduserid"
                                   value='<sec:authentication property="principal.member.userid"/>'/>
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        </form>


                        <div id="register_result"></div>
                    </div><!--  end panel-body -->

                </div><!--  panel panel-default-->
            </div><!-- col-lg-12 -->
        </div><!-- row  ml-1 -->
    </div>    <!-- <div class="card shadow mb-4"> DataTales begin-->
</div>
<!-- <div class="container-fluid"> -->

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.table" text="ConfTable management"/>" + ">Register");
    });
    $(document).ready(function () {

        $("button[data-oper='register']").on("click", function (e) {

            var elementForm = $("#piiconftable_register_form");
            var elementResult = $("#content_home");
            $.ajax({
                type: "POST",
                url: "/piiconftable/register",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    dlmAlert("Successful!");
                    //alert(data);
                    elementResult.html(data); //받아온 data 실행
                    //elementResult.text(Parse_data); //받아온 data 실행
                }
            });

        });

        $("button[data-oper='list']").on("click", function (e) {

            $('#content_home').load("/piiconftable/list");

        });

    });
</script>