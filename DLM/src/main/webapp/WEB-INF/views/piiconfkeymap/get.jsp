<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">
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
                            <div class="form-row ">
                                <div class="form-group col-sm-12"><label for="inputinsertstr">Keymap_id</label><input
                                        type="text" class="form-control form-control-sm" id="inputkeymap_id"
                                        name='keymap_id' value='<c:out value="${piiconfkeymap.keymap_id}"/>'
                                        readonly="readonly"></div>
                            </div>
                            <div class="form-group col-sm-2"><label for="inputkey_name">Key_Name</label><input
                                    type="text" class="form-control form-control-sm" id="inputkey_name" name='key_name'
                                    value='<c:out value="${piiconfkeymap.key_name}"/>' readonly="readonly"></div>
                            <div class="form-group col-sm-2"><label for="inputdb">Db</label><input type="text"
                                                                                                   class="form-control form-control-sm"
                                                                                                   id="inputdb"
                                                                                                   name='db'
                                                                                                   value='<c:out value="${piiconfkeymap.db}"/>'
                                                                                                   readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputseq1">Seq1</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq1"
                                                                                                       name='seq1'
                                                                                                       value='<c:out value="${piiconfkeymap.seq1}"/>'
                                                                                                       readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputseq2">Seq2</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq2"
                                                                                                       name='seq2'
                                                                                                       value='<c:out value="${piiconfkeymap.seq2}"/>'
                                                                                                       readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputseq3">Seq3</label><input type="text"
                                                                                                       class="form-control form-control-sm"
                                                                                                       id="inputseq3"
                                                                                                       name='seq3'
                                                                                                       value='<c:out value="${piiconfkeymap.seq3}"/>'
                                                                                                       readonly="readonly">
                            </div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-3"><label for="inputkey_cols">Key_Cols</label><input
                                    type="text" class="form-control form-control-sm" id="inputkey_cols" name='key_cols'
                                    value='<c:out value="${piiconfkeymap.key_cols}"/>' readonly="readonly"></div>
                            <div class="form-group col-sm-3"><label for="inputsrc_owner">Src_Owner</label><input
                                    type="text" class="form-control form-control-sm" id="inputsrc_owner"
                                    name='src_owner' value='<c:out value="${piiconfkeymap.src_owner}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-3"><label
                                    for="inputsrc_table_name">Src_Table_Name</label><input type="text"
                                                                                           class="form-control form-control-sm"
                                                                                           id="inputsrc_table_name"
                                                                                           name='src_table_name'
                                                                                           value='<c:out value="${piiconfkeymap.src_table_name}"/>'
                                                                                           readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-3"><label for="inputwhere_col">Where_Col</label><input
                                    type="text" class="form-control form-control-sm" id="inputwhere_col"
                                    name='where_col' value='<c:out value="${piiconfkeymap.where_col}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-3"><label
                                    for="inputwhere_key_name">Where_Key_name</label><input type="text"
                                                                                           class="form-control form-control-sm"
                                                                                           id="inputwhere_key_name"
                                                                                           name='where_key_name'
                                                                                           value='<c:out value="${piiconfkeymap.where_key_name}"/>'
                                                                                           readonly="readonly"></div>
                            <div class="form-group col-sm-1"><label for="inputparallelcnt">Parallel_Cnt</label><input
                                    type="text" class="form-control form-control-sm" id="inputparallelcnt"
                                    name='parallelcnt' value='<c:out value="${piiconfkeymap.parallelcnt}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-1"><label for="inputstatus">Status</label><input type="text"
                                                                                                           class="form-control form-control-sm"
                                                                                                           id="inputstatus"
                                                                                                           name='status'
                                                                                                           value='<c:out value="${piiconfkeymap.status}"/>'
                                                                                                           readonly="readonly">
                            </div>
                            <div class="form-group col-sm-1"><label for="inputsqltype">Sqltype</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputsqltype"
                                                                                                             name='sqltype'
                                                                                                             value='<c:out value="${piiconfkeymap.sqltype}"/>'
                                                                                                             readonly="readonly">
                            </div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-12"><label for="inputinsertstr">Insertstr</label><input
                                    type="text" class="form-control form-control-sm" id="inputinsertstr"
                                    name='insertstr' value='<c:out value="${piiconfkeymap.insertstr}"/>'
                                    readonly="readonly"></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-12"><label for="inputwherestr">Wherestr</label><textarea
                                    spellcheck="false" rows="5" class="form-control form-control-sm" id="inputwherestr"
                                    name='wherestr' readonly="readonly"><c:out
                                    value="${piiconfkeymap.wherestr}"/></textarea></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-12"><label for="inputrefstr">Refstr</label><textarea
                                    spellcheck="false" rows="2" class="form-control form-control-sm" id="inputrefstr"
                                    name='refstr' readonly="readonly"><c:out
                                    value="${piiconfkeymap.refstr}"/></textarea></div>
                        </div>
                        <div class="form-row ">
                            <div class="form-group col-sm-3"><label for="inputregdate">Regdate</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputregdate"
                                                                                                             name='regdate'
                                                                                                             value='<c:out value="${piiconfkeymap.regdate}"/>'
                                                                                                             readonly="readonly">
                            </div>
                            <div class="form-group col-sm-3"><label for="inputupddate">Upddate</label><input type="text"
                                                                                                             class="form-control form-control-sm"
                                                                                                             id="inputupddate"
                                                                                                             name='upddate'
                                                                                                             value='<c:out value="${piiconfkeymap.upddate}"/>'
                                                                                                             readonly="readonly">
                            </div>
                            <div class="form-group col-sm-3"><label for="inputreguserid">Reguserid</label><input
                                    type="text" class="form-control form-control-sm" id="inputreguserid"
                                    name='reguserid' value='<c:out value="${piiconfkeymap.reguserid}"/>'
                                    readonly="readonly"></div>
                            <div class="form-group col-sm-3"><label for="inputupduserid">Upduserid</label><input
                                    type="text" class="form-control form-control-sm" id="inputupduserid"
                                    name='upduserid' value='<c:out value="${piiconfkeymap.upduserid}"/>'
                                    readonly="readonly"></div>
                        </div>


                        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                            <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                            <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                            <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
                            <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
                            <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
                            <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
                            <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
                            <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
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
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.keymap" text="ConfKeymap management"/>" + ">Details");
    });
    $(document).ready(function () {

        $("button[data-oper='modify']").on("click", function (e) {

            e.preventDefault();e.stopPropagation();
            var serchkeyno1 = $('input[name=keymap_id]').val();
            var serchkeyno2 = $('input[name=key_name]').val();
            var serchkeyno3 = $('input[name=db]').val();
            var serchkeyno4 = $('input[name=seq1]').val();
            var serchkeyno5 = $('input[name=seq2]').val();
            var serchkeyno6 = $('input[name=seq3]').val();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var search3 = $('#searchForm [name="search3"]').val();
            var search4 = $('#searchForm [name="search4"]').val();
            var search5 = $('#searchForm [name="search5"]').val();
            var search6 = $('#searchForm [name="search6"]').val();
            var url_search = "";
            var url_view = "modify?"
                + "keymap_id=" + serchkeyno1 + "&"
                + "key_name=" + serchkeyno2 + "&"
                + "db=" + serchkeyno3 + "&"
                + "seq1=" + serchkeyno4 + "&"
                + "seq2=" + serchkeyno5 + "&"
                + "seq3=" + serchkeyno6 + "&";
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
                url_search += "&search3=" + search3
            }
            ;
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4
            }
            ;
            if (!isEmpty(search5)) {
                url_search += "&search5=" + search5
            }
            ;
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6
            }
            ;
            //alert("/piiconfkeymap/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $.ajax({
                type: "GET",
                url: "/piiconfkeymap/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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