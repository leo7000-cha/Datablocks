<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->

<div class="card shadow m-1 " style="height: 670px;width: 1100px;">
    <div id="steptablewaitlistdialog" class="table-container613 m-1 " style="width: 98.8%;">

        <div class="card-body m-1 p-0" style="height:655px;width:100%;border:1px solid #ECEEEE;">
            <div class="card-header m-0 p-0 " style="width:95%;height:35px;">
                <form style="margin: 0; padding: 0;" role="form" id=searchForm>
                    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
                    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
                    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
                    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
                    <div class="search-container-1row-91 ml-1">
                        <div class="search-item">
                            <div class="form-group row">
                                <label class="lable-search col-sm-12" style="vertical-align: middle;">JOBID : <c:out
                                        value="${cri.search1}"/></label>
                            </div>
                        </div>
                        <div class="search-item"></div>
                        <div class="search-item"></div>
                        <div></div>

                    </div>

                    <!-- <div class="search-container"> -->
                </form>
            </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
            <div class="tableWrapper " style="height:620px;">
                <table id="listTable_tabs" class="table table-sm table-hover">
                    <thead>
                    <tr>
                        <th class="th-get"> &nbsp; &nbsp;</th>
                        <th class="th-get">STEPID</th>
                        <th class="th-get">DB</th>
                        <th class="th-get">OWNER</th>
                        <th class="th-get">TABLE_NAME</th>
                        <th class="th-hidden">SEQ1</th>
                        <th class="th-get">SEQ</th>
                        <th class="th-hidden">SEQ3</th>
                        <!-- <th>PIPELINE</th>
                        <th>PK_COLUMNS</th> -->
                        <!-- <th>PK_DATA_TYPE</th> -->
                        <!-- <th>IMATABLE_NAME</th> -->
                        <!-- <th>MASTERKEY</th> -->
                        <!-- <th>WHERE_COL</th>
                         -->
                        <!-- <th>PARALLELCNT</th> -->
                        <!-- <th>COMMITCNT</th> -->
                        <!-- <th>TOTALCNT</th> -->
                        <!-- <th>WHERESTR</th>
                        <th>SQLSTR</th> -->
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${liststeptable}" var="piisteptable">
                        <tr>
                            <td class="td-get-sm"><input type="checkbox" class="chkBox" name="chkBoxStepTable"
                                                         style="vertical-align:middle;width:14px;height:14px;"></td>
                            <td class="td-get-sm"><c:out value="${piisteptable.stepid}"/></td>

                            <td class="td-get-sm"><c:out value="${piisteptable.db}"/></td>
                            <td class="td-get-sm"><c:out value="${piisteptable.owner}"/></td>
                            <td class="td-get-sm-l"><c:out value="${piisteptable.table_name}"/></td>

                            <td class="td-hidden"><c:out value="${piisteptable.seq1}"/></td>
                            <td class="td-get-sm-r"><c:out value="${piisteptable.seq2}"/></td>
                            <td class="td-hidden"><c:out value="${piisteptable.seq3}"/></td>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.pipeline}"/></td>
                                <td class="td-get-sm"><c:out value="${piisteptable.pk_columns}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.pk_data_type}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.imatable_name}"/></td>
                                <td class="td-get-sm"><c:out value="${piisteptable.masterkey}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.where_col}"/></td>
                                 --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.parallelcnt}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.commitcnt}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.totalcnt}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piisteptable.wherestr}"/></td>
                                <td class="td-get-sm"><c:out value="${piisteptable.sqlstr}"/></td> --%>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

            </div>
            <!-- <div class="table-responsive"> -->
        </div> <!-- <div class="card-body"> -->

        <%-- 	<div class=" flex-container_column m-1" style="height:360px;width: 100%;vertical-align: middle;">
                <div>
                <input type="button" class="btn-1" onClick="addJobWait();" value=">>" style="font-weight:bold;width:50px;height:30;"/>
                <br>
                <input type="button" class="btn-1" onClick="deleteJobWait();" value="<<" style="font-weight:bold;width:50px;height:30;"/>
                </div>
            </div> --%>

        <div class=" flex-container_column p-2 m-1" style="height:360px;width: 100%;vertical-align: middle;">
            <button type="button" class="btn btn-outline-primary mb-1" style="font-weight:bold;width:50px;"
                    onClick="addStepTableWait();"><i class="fa fa-angle-double-right"></i></button>
            <button type="button" class="btn btn-outline-primary" style="font-weight:bold;width:50px;"
                    onClick="deleteStepTableWait();"><i class="fa fa-angle-double-left"></i></button>
        </div>


        <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->

        <div class="card-body m-1 p-0" style="height:655px;width:100%; border:1px solid #ECEEEE;">
            <div class="card-header m-0 p-0 " style="width:95%;height:35px;">
                <div class="search-container-1row-73 ml-1">
                    <div class="search-item">
                        <div class="form-group row">
                            <label class="lable-search col-sm-12" style="vertical-align: middle;"><c:out
                                    value="${piisteptable.table_name}"/></label>
                        </div>
                    </div>
                    <div class="search-item_right mr-1">
                        <button data-oper='saveStepTableWait' class="btn btn-primary btn-sm p-0 pb-2 button ml-1">
                            <spring:message code="btn.save" text="Save"/></button>
                    </div>
                </div>
                <!-- <div class="search-container"> -->
            </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
            <div class="tableWrapper " style="height:620px;">
                <table id="listTable_waittabs" class="table table-sm table-hover">
                    <thead>
                    <tr>
                        <th class="th-get-sm"><input type="checkbox" class="chkBox" id="waitcheckall"
                                                     style="width:14px;height:14px;"></th>
                        <th class="th-get-sm">DB</th>
                        <th class="th-get-sm">OWNER</th>
                        <th class="th-get-sm">TABLE_NAME</th>

                    </tr>
                    </thead>
                    <tbody id="steptablewaitbody">
                    <c:forEach items="${liststeptablewait}" var="piisteptablewait">
                        <tr>
                            <td class="td-get-sm"><input type="checkbox" class="chkBox" name="chkBoxStepTableWait"
                                                         style="width:14px;height:14px;"></td>
                            <td class="td-get-sm"><c:out value="${piisteptablewait.db_w}"/></td>
                            <td class="td-get-sm"><c:out value="${piisteptablewait.owner_w}"/></td>
                            <td class="td-get-sm-l"><c:out value="${piisteptablewait.table_name_w}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

            </div>
            <!-- <div class="table-responsive"> -->
        </div> <!-- <div class="card-body"> -->

    </div><!-- <div id="steptablewaitlistdialog" -->
</div>
<!-- <div class="card shadow mb-1"> -->
<input type='hidden' id='steptablewait_global_jobid' value='<c:out value="${piisteptable.jobid}"/>'>
<input type='hidden' id='steptablewait_global_version' value='<c:out value="${piisteptable.version}"/>'>
<input type='hidden' id='steptablewait_global_stepid' value='<c:out value="${piisteptable.stepid}"/>'>
<input type='hidden' id='steptablewait_global_db' value='<c:out value="${piisteptable.db}"/>'>
<input type='hidden' id='steptablewait_global_owner' value='<c:out value="${piisteptable.owner}"/>'>
<input type='hidden' id='steptablewait_global_table_name' value='<c:out value="${piisteptable.table_name}"/>'>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>


<script type="text/javascript">
    $(document).ready(function () {
        $("#waitcheckall").click(function () {
            if ($("#waitcheckall").prop("checked")) {
                $("input[name=chkBoxStepTableWait]").prop("checked", true);
            } else {
                $("input[name=chkBoxStepTableWait]").prop("checked", false);
            }
        })
    })

    function addStepTableWait() {
        var param = [];
        var tr;
        var td;
        var existflag = true;
        var global_table_name = $('#steptablewait_global_table_name').val();
        var checkbox = $("input:checkbox[name=chkBoxStepTable]:checked");//.parent().parent()

        checkbox.each(function (i) {
            existflag = true;
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            $('#steptablewaitbody tr').each(function () { //alert($(this).children().eq(3).text()  +"   "+td.eq(4).text());
                if (td.eq(4).text() == $(this).children().eq(3).text()) {
                    existflag = false;
                    return false;
                }
            });
            if (td.eq(4).text() == global_table_name) {// prevent to avoid itself
                existflag = false;
            }
            if (existflag)
                $("#steptablewaitbody").append("<tr><td style='text-align:center;'><input type='checkbox' class='chkBox' name='chkBoxStepTableWait'  style='vertical-align:middle;width:14px;height:14px;'></td><td class='td-get-sm'>" + td.eq(2).text() + "</td><td class='td-get-sm'>" + td.eq(3).text() + "</td><td class='td-get-sm'>" + td.eq(4).text() + "</td></tr>");
        });

    }

    function deleteStepTableWait() {
        $('#steptablewaitbody tr').each(function () {
            if ($(this).children().eq(0).children().is(":checked")) {
                $(this).remove();
            }
        });
    }

</script>
<script type="text/javascript">
    /* $(document).ready(function(){
        $('#stepmodal').on('hidden.bs.modal', function () {//alert("#stepmodal");
             var url_view = "/piijob/get?jobid="+$('#global_jobid').val()+"&";
            searchAction_steptablewaitdialog(null,url_view,"#content_home");
        })
    }); */
    /* $("body").on('shown.bs.modal', '.modal', function(e) {
        //e.preventDefault();e.stopPropagation();
        //alert('shown');

    }); */


    $("body").on('hidden.bs.modal', '.modal', function (e) {
        e.preventDefault();e.stopPropagation();

    });


    /* $("body").on('show.bs.modal', '.modal', function(e) {
        //e.preventDefault();e.stopPropagation();
        //alert('show');

    });
     */

    /* $("body").on('hide.bs.modal', '.modal', function(e) {
        //e.preventDefault();e.stopPropagation();
        //alert('hide');

    }); */


    $("button[data-oper='saveStepTableWait']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_jobid = $('#steptablewait_global_jobid').val();
        var global_version = $('#steptablewait_global_version').val();
        var global_stepid = $('#steptablewait_global_stepid').val();
        var global_db = $('#steptablewait_global_db').val();
        var global_owner = $('#steptablewait_global_owner').val();
        var global_table_name = $('#steptablewait_global_table_name').val();
        var param = [];
        var td;

        //For the case empty list
        var dataheader = {
            jobid: global_jobid,
            version: global_version,
            stepid: global_stepid,
            db: global_db,
            owner: global_owner,
            table_name: global_table_name,
            type: "HEADER",
            db_w: "HEADER",
            owner_w: "HEADER",
            table_name_w: "HEADER",
        };

        param.push(dataheader);

        $('#steptablewaitbody tr').each(function () {

            td = $(this).children();
            var data = {
                jobid: global_jobid,
                version: global_version,
                stepid: global_stepid,
                db: global_db,
                owner: global_owner,
                table_name: global_table_name,
                type: "PRE",
                db_w: td.eq(1).text(),
                owner_w: td.eq(2).text(),
                table_name_w: td.eq(3).text()
            };

            param.push(data);
        });

        //console.log("param "+param.length);

        $.ajax({
            url: "/piisteptable/modifysteptablewait",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                //$('#content_home').html(data);
                //searchAction(1);
                $('#steptablewaitmodify tr').each(function () {
                    $(this).remove();
                });
                $('#steptablewaitbody tr').each(function () { //alert("<tr style='border: none;'><td style='border: none;'>"+$(this).children().eq(3).text()+"</td></tr>");
                    $("#steptablewaitmodify").append("<tr style='border: none;'><td style='border: none;'>" + $(this).children().eq(3).text() + "</td></tr>");
                });
                showToast("처리가 완료되었습니다.", false);
                $("#dialogsteptablewaitlist").modal("hide");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

    $("button[data-oper='searchsteptablelist']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        searchAction_steptablewaitdialog();
    });

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });


    searchAction_steptablewaitdialog = function () {//alert("dialog searchAction_steptablewaitdialog");
        var global_jobid = $('#steptablewait_global_jobid').val();
        var global_version = $('#steptablewait_global_version').val();
        var global_stepid = $('#steptablewait_global_stepid').val();
        var global_db = $('#steptablewait_global_db').val();
        var global_owner = $('#steptablewait_global_owner').val();
        var global_table_name = $('#steptablewait_global_table_name').val();

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var search3 = $('#searchForm [name="search3"]').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#searchForm [name="search5"]').val();
        var search6 = $('#searchForm [name="search6"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "modifysteptablewaitdialog?jobid=" + global_jobid + "&" + "version=" + global_version + "&" + "stepid=" + global_stepid
            + "&" + "db=" + global_db + "&" + "owner=" + global_owner + "&" + "table_name=" + global_table_name
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
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


        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#dialogsteptablewaitlistbody').html(data);
                //$("#dialogsteptablewaitlist").modal();

            }
        });
    }

</script>


