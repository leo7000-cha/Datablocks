<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1" style="height:818px">
    <!-- Page Heading -->
    <!-- <h1 class="h3 mb-2">Configuration</h1> -->

    <div class="card shadow mb-4">
        <div class="card-header text-right">
            <sec:authorize access="isAuthenticated()">
                <button data-oper='modify' class="btn btn-primary"><spring:message code="btn.modify"
                                                                                   text="Modify"/></button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-info">List</button>
        </div>

        <div class="row m-1">
            <div class="col-sm-12">
                <div class="panel panel-default">

                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <div class="form-row ">
                            <div class="form-group col-sm-2"><label for="inputdb">DB</label><input
                                    type="text" class="form-control form-control-sm" id="inputdb"
                                    name='db' value='<c:out value="${piiconftable.db}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputowner">Owner</label><input type="text"
                                                                                                         class="form-control form-control-sm"
                                                                                                         id="inputowner"
                                                                                                         name='owner'
                                                                                                         value='<c:out value="${piiconftable.owner}"/>'
                                                                                                         readonly="readonly">
                            </div>
                            <div class="form-group col-sm-3"><label for="inputtable_name">Table_Name</label><input
                                    type="text" class="form-control form-control-sm" id="inputtable_name"
                                    name='table_name' value='<c:out value="${piiconftable.table_name}"/>'
                                    readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-2"><label for="inputpagitype">Pagitype</label><input
                                    type="text" class="form-control form-control-sm" id="inputpagitype" name='pagitype'
                                    value='<c:out value="${piiconftable.pagitype}"/>' readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label
                                    for="inputpagitypedetail">Pagitypedetail</label><input type="text"
                                                                                           class="form-control form-control-sm"
                                                                                           id="inputpagitypedetail"
                                                                                           name='pagitypedetail'
                                                                                           value='<c:out value="${piiconftable.pagitypedetail}"/>'
                                                                                           readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputarchiveflag">Archiveflag</label><input
                                    type="text" class="form-control form-control-sm" id="inputarchiveflag"
                                    name='archiveflag' value='<c:out value="${piiconftable.archiveflag}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputstatus">Status</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputstatus"
                                                                                                           name='status'
                                                                                                           value='<c:out value="${piiconftable.status}"/>'
                                                                                                           readonly="readonly">
                            </div>
                            <div class="form-group col-sm-2"><label for="inputpreceding">Preceding</label><input
                                    type="text" class="form-control form-control-sm" id="inputpreceding"
                                    name='preceding' value='<c:out value="${piiconftable.preceding}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputsuccedding">Succedding</label><input
                                    type="text" class="form-control form-control-sm" id="inputsuccedding"
                                    name='succedding' value='<c:out value="${piiconftable.succedding}"/>'
                                    readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-1"><label for="inputseq1">Seq1</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq1"
                                                                                                       name='seq1'
                                                                                                       value='<c:out value="${piiconftable.seq1}"/>'
                                                                                                       readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputseq2">Seq2</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq2"
                                                                                                       name='seq2'
                                                                                                       value='<c:out value="${piiconftable.seq2}"/>'
                                                                                                       readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputseq3">Seq3</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq3"
                                                                                                       name='seq3'
                                                                                                       value='<c:out value="${piiconftable.seq3}"/>'
                                                                                                       readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputpipeline">Pipeline</label><input
                                    type="text" class="form-control form-control-sm" id="inputpipeline" name='pipeline'
                                    value='<c:out value="${piiconftable.pipeline}"/>' readonly="readonly"></div>
                            <div class="form-group col-sm-4"><label for="inputpk_columns">Pk_Columns</label><input
                                    type="text" class="form-control form-control-sm" id="inputpk_columns"
                                    name='pk_columns' value='<c:out value="${piiconftable.pk_columns}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-1"><label for="inputpk_data_type">Pk_Type</label><input
                                    type="text" class="form-control form-control-sm" id="inputpk_data_type"
                                    name='pk_data_type' value='<c:out value="${piiconftable.pk_data_type}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputimatable_name">Imatable_Name</label><input
                                    type="text" class="form-control form-control-sm" id="inputimatable_name"
                                    name='imatable_name' value='<c:out value="${piiconftable.imatable_name}"/>'
                                    readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-2"><label for="inputmasterkey">Masterkey</label><input
                                    type="text" class="form-control form-control-sm" id="inputmasterkey"
                                    name='masterkey' value='<c:out value="${piiconftable.masterkey}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputwhere_col">Where_Col</label><input
                                    type="text" class="form-control form-control-sm" id="inputwhere_col"
                                    name='where_col' value='<c:out value="${piiconftable.where_col}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label
                                    for="inputwhere_key_name">Where_key_name</label><input type="text"
                                                                                           class="form-control form-control-sm"
                                                                                           id="inputwhere_key_name"
                                                                                           name='where_key_name'
                                                                                           value='<c:out value="${piiconftable.where_key_name}"/>'
                                                                                           readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-12"><label for="inputwherestr">Wherestr</label><textarea
                                    spellcheck="false" rows="4" class="form-control form-control-sm" id="inputwherestr"
                                    name='wherestr' readonly="readonly"><c:out
                                    value="${piiconftable.wherestr}"/></textarea></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-2"><label for="inputparallelcnt">Parallelcnt</label><input
                                    type="text" class="form-control form-control-sm" id="inputparallelcnt"
                                    name='parallelcnt' value='<c:out value="${piiconftable.parallelcnt}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputtotalcnt">Totalcnt</label><input
                                    type="text" class="form-control form-control-sm" id="inputtotalcnt" name='totalcnt'
                                    value='<c:out value="${piiconftable.totalcnt}"/>' readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-2"><label for="inputregdate">Regdate</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputregdate"
                                                                                                             name='regdate'
                                                                                                             value='<c:out value="${piiconftable.regdate}"/>'
                                                                                                             readonly="readonly">
                            </div>
                            <div class="form-group col-sm-2"><label for="inputupddate">Upddate</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputupddate"
                                                                                                             name='upddate'
                                                                                                             value='<c:out value="${piiconftable.upddate}"/>'
                                                                                                             readonly="readonly">
                            </div>
                            <div class="form-group col-sm-2"><label for="inputreguserid">Reguserid</label><input
                                    type="text" class="form-control form-control-sm" id="inputreguserid"
                                    name='reguserid' value='<c:out value="${piiconftable.reguserid}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputupduserid">Upduserid</label><input
                                    type="text" class="form-control form-control-sm" id="inputupduserid"
                                    name='upduserid' value='<c:out value="${piiconftable.upduserid}"/>'
                                    readonly="readonly"></div>
                        </div>


                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                            <input type='hidden' name='pagenum'
                                   value='<c:out value="${cri.pagenum}"/>'> <input
                                type='hidden' name='amount'
                                value='<c:out value="${cri.amount}"/>'> <input
                                type='hidden' name='search1'
                                value='<c:out value="${cri.search1}"/>'> <input
                                type='hidden' name='search2'
                                value='<c:out value="${cri.search2}"/>'><input
                                type='hidden' name='search3'
                                value='<c:out value="${cri.search3}"/>'>
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
</div>

<!-- <div class="container-fluid"> -->

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.table" text="ConfTable management"/>" + ">Details");
    });
    $(document).ready(function () {

        $("button[data-oper='modify']").on("click", function (e) {

            e.preventDefault();e.stopPropagation();
            var serchkeyno1 = $('#inputdb').val()
            var serchkeyno2 = $('#inputowner').val()
            var serchkeyno3 = $('#inputtable_name').val()
            var serchkeyno = "db=" + serchkeyno1 + "&" + "owner=" + serchkeyno2 + "&" + "table_name=" + serchkeyno3
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var search3 = $('#searchForm [name="search3"]').val();
            var url_search = "";
            var url_view = "";

            url_view = "modify?" + serchkeyno + "&";//alert("/piiconftable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
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
            //alert("/piiconftable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiconftable/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
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

            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var search3 = $('#searchForm [name="search3"]').val();
            var url_search = "";
            //alert("pagenum="+pagenum+"&amount="+"&search1="+search1+"&search2="+search2);

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
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3;
            }

            //alert("/piiconftable/list?pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiconftable/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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