<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->

<div class="card shadow m-1 " style="height: 670px;width: 1100px;">
    <div id="ordersteptableupdatelistdialog" class="table-container613 m-1 " style="width: 98.8%;">

        <div class="card-body m-1 p-0" style="height:655px;width:100%;border:1px solid #ECEEEE;">
            <div class="card-header m-0 p-0 " style="width:95%;height:35px;">
                <form style="margin: 0; padding: 0;" role="form" id=ordersteptableupdateForm>
                    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
                    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
                    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
                    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
                    <div class="search-container-1row-523 ml-1">
                        <div class="search-item">
                            <div class="form-group row">
                                <label class="lable-search col-sm-12" style="vertical-align: middle;"
                                ><c:out value="${cri.search5}"/>.<c:out value="${cri.search6}"/></label>
                            </div>
                        </div>
                        <div class="search-item">
                            <div class="form-group row">
                                <label class="lable-search col-sm-12" style="vertical-align: middle;"
                                > </label>

                            </div>
                        </div>
                        <div class="search-item">
                            <div class="form-group row">
                                <label class="lable-search col-sm-12" style="vertical-align: middle;"
                                > </label>

                            </div>
                        </div>
                        <div class="search-item">

                        </div>
                    </div>

                    <!-- <div class="search-container"> -->
                </form>
            </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
            <div class="tableWrapper " style="height:620px;">
                <table id="listTable_cols" class="table table-sm table-hover">
                    <thead>
                    <tr>
                        <th> &nbsp; &nbsp; &nbsp;</th>
                        <th class="th-get"><spring:message code="col.column_id" text="Column_Id"/></th>
                        <th class="th-get"><spring:message code="col.column_name" text="Column_Name"/></th>
                        <th class="th-get"><spring:message code="col.pk_yn" text="Pk_Yn"/></th>
                        <th class="th-get"><spring:message code="col.data_type" text="Data_Type"/></th>
                        <th class="th-get"><spring:message code="col.data_length" text="Data_Length"/></th>
                        <th class="th-get"><spring:message code="col.nullable" text="Nullable"/></th>
                        <th class="th-get"><spring:message code="col.comments" text="Comments"/></th>

                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${piitablelist}" var="piitable">
                        <tr>
                            <td class="td-get"><input type="checkbox" class="chkBox" name="chkBoxStepTable"
                                                      style="vertical-align:middle;width:14px;height:14px;"></td>
                            <td class="td-get"><c:out value="${piitable.column_id}"/></td>
                            <td class="td-get"><c:out value="${piitable.column_name}"/></td>
                            <td class="td-get"><c:out value="${piitable.pk_yn}"/></td>
                            <td class="td-get"><c:out value="${piitable.data_type}"/></td>
                            <td class="td-get"><c:out value="${piitable.data_length}"/></td>
                            <td class="td-get"><c:out value="${piitable.nullable}"/></td>
                            <td class="td-get"><c:out value="${piitable.comments}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

            </div>
            <!-- <div class="table-responsive"> -->
        </div> <!-- <div class="card-body"> -->

        <div class=" flex-container_column m-1" style="height:360px;width: 100%;vertical-align: middle;">
            <button type="button" class="btn btn-outline-primary mb-1" style="font-weight:bold;width:50px;"
                    onClick="addJobUpdate();"><i class="fa fa-angle-double-right"></i></button>
            <button type="button" class="btn btn-outline-primary" style="font-weight:bold;width:50px;"
                    onClick="deleteJobUpdate();"><i class="fa fa-angle-double-left"></i></button>
        </div>

        <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->

        <div class="card-body m-1 p-0" style="height:655px;width:100%; border:1px solid #ECEEEE;">
            <div class="card-header m-0 p-0 " style="width:95%;height:35px;">
                <div class="search-container-1row-73 ml-1">
                    <div class="search-item">
                        <div class="form-group row">
                            <label class="lable-search col-sm-12" style="vertical-align: middle;">Update column and
                                value</label>
                        </div>
                    </div>
                    <div class="search-item_right mr-1">
                        <button data-oper='saveStepTableUpdate' class="btn btn-primary btn-sm p-0 pb-2 button ml-1">
                            <spring:message code="btn.save" text="Save"/></button>
                    </div>
                </div>
                <!-- <div class="search-container"> -->
            </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
            <div class="tableWrapper " style="height:620px;">
                <table id="listTable_update" class="table table-sm table-hover">
                    <colgroup>
                        <col style="width: 10%"/>
                        <col style="width: 50%"/>
                        <col style="width: 40%"/>
                    </colgroup>
                    <thead>
                    <tr>
                        <th class="th-get">&nbsp;
                            <!-- <input type="checkbox" class="chkBox" id="updatecheckall"  style="width:14px;height:14px;"> --></th>
                        <th class="th-get"><spring:message code="col.column_name" text="Column_Name"/></th>
                        <th>UPDATE_VAL</th>

                    </tr>
                    </thead>
                    <tbody id="steptableupdatebody">
                    <c:forEach items="${listordersteptableupdate}" var="piiordersteptableupdate">
                        <tr>
                            <td class="td-get"><input type="checkbox" class="chkBox" name="chkBoxStepTableUpdate"
                                                      style="vertical-align:middle;width:14px;height:14px;"></td>
                            <td class="td-get-l"><c:out value="${piiordersteptableupdate.column_name}"/></td>
                            <td class="td-get-l"><input type="text" class="form-control form-control-sm"
                                                        style="vertical-align:middle;font-size: 11px; "
                                                        name="update_val"
                                                        value='<c:out value="${piiordersteptableupdate.update_val}"/>'>
                            </td>
                            <td class="td-hidden">SAVEDDATA</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

            </div>
            <!-- <div class="table-responsive"> -->
        </div> <!-- <div class="card-body"> -->

    </div><!-- <div id="ordersteptableupdatelistdialog" -->
</div>
<!-- <div class="card shadow mb-1"> -->
<input type='hidden' id='steptableupdate_global_orderid' value='<c:out value="${piiordersteptable.orderid}"/>'>
<input type='hidden' id='steptableupdate_global_jobid' value='<c:out value="${piiordersteptable.jobid}"/>'>
<input type='hidden' id='steptableupdate_global_version' value='<c:out value="${piiordersteptable.version}"/>'>
<input type='hidden' id='steptableupdate_global_stepid' value='<c:out value="${piiordersteptable.stepid}"/>'>
<input type='hidden' id='steptableupdate_seq1' value='<c:out value="${piiordersteptable.seq1}"/>'>
<input type='hidden' id='steptableupdate_seq2' value='<c:out value="${piiordersteptable.seq2}"/>'>
<input type='hidden' id='steptableupdate_seq3' value='<c:out value="${piiordersteptable.seq3}"/>'>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        $("#updatecheckall").click(function () {
            if ($("#updatecheckall").prop("checked")) {
                $("input[name=chkBoxStepTableUpdate]").prop("checked", true);
            } else {
                $("input[name=chkBoxStepTableUpdate]").prop("checked", false);
            }
        })
    })

    function addJobUpdate() {
        var param = [];
        var tr;
        var td;
        var existflag = true;
        var seq3 = $('#steptableupdate_seq3').val();
        var checkbox = $("input:checkbox[name=chkBoxStepTable]:checked");


        checkbox.each(function (i) {
            existflag = true;
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            $('#steptableupdatebody tr').each(function () {
                if (jQuery.trim(td.eq(2).text()) == jQuery.trim($(this).children().eq(1).text())) {
                    existflag = false;
                    alert(jQuery.trim(td.eq(2).text()) + " has already been applied ");
                    return false;

                }
            });

            if (existflag) {
                var htmlstr = "<tr>";
                htmlstr += "    <td class='td-get'>";
                htmlstr += "    		<input type='checkbox' class='chkBox' name='chkBoxStepTableUpdate'  style='vertical-align:middle;width:14px;height:14px;'>";
                htmlstr += "    </td>";
                htmlstr += "    <td class='td-get-l'>" + jQuery.trim(td.eq(2).text());
                htmlstr += "    </td>";
                htmlstr += "    <td class='td-get-l'><input type='text' class='form-control form-control-sm' name='update_val' value='null'></td>";
                htmlstr += "    <td class='td-hidden'>" + jQuery.trim(td.eq(4).text());
                htmlstr += "    </td>";
                htmlstr += "</tr>";
                $("#steptableupdatebody").append(htmlstr);
            }

        });

    }

    function deleteJobUpdate() {
        $('#steptableupdatebody tr').each(function () {
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
            searchAction_steptableupdatedialog(null,url_view,"#content_home");
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


    $("button[data-oper='saveStepTableUpdate']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_orderid = $('#steptableupdate_global_orderid').val();
        var global_jobid = $('#steptableupdate_global_jobid').val();
        var global_version = $('#steptableupdate_global_version').val();
        var global_stepid = $('#steptableupdate_global_stepid').val();
        var seq1 = $('#steptableupdate_seq1').val();
        var seq2 = $('#steptableupdate_seq2').val();
        var seq3 = $('#steptableupdate_seq3').val();
        var param = [];
        var td;

        //For the case empty list
        var dataheader = {
            orderid: global_orderid,
            jobid: global_jobid,
            version: global_version,
            stepid: global_stepid,
            seq1: seq1,
            seq2: seq2,
            seq3: seq3,
            column_name: "HEADER",
            update_val: "HEADER",
            status: "HEADER"
        };

        param.push(dataheader);

        $('#steptableupdatebody tr').each(function () {

            td = $(this).children();//alert(td.eq(1).text()+"-"+td.eq(2).find("input[name='update_val']").val());
            var datatype = jQuery.trim(td.eq(3).text());
            var updateval;
            if (td.eq(2).find("input[name='update_val']").val().toUpperCase() == "NULL") {
                updateval = td.eq(2).find("input[name='update_val']").val();
            } else if (datatype.toUpperCase() == "SAVEDDATA") {
                updateval = td.eq(2).find("input[name='update_val']").val();
            } else if (datatype.toUpperCase() == "NUMBER" || datatype.toUpperCase() == "DECIMAL" || datatype.toUpperCase() == "INT" || datatype.toUpperCase() == "BIGINT"
                || datatype.toUpperCase() == "FLOAT" || datatype.toUpperCase() == "MEDIUMINT" || datatype.toUpperCase() == "SMALLINT" || datatype.toUpperCase() == "TINYINT") {
                updateval = td.eq(2).find("input[name='update_val']").val();
            } else if (datatype.toUpperCase() == "DATE" || datatype.toUpperCase() == "TIMESTAMP" || datatype.toUpperCase() == "TIME" || datatype.toUpperCase() == "DATETIME"
                || datatype.toUpperCase().indexOf("TIMESTAMP") != -1 || datatype.toUpperCase().indexOf("YEAR") != -1) {
                updateval = td.eq(2).find("input[name='update_val']").val();
            } else {
                updateval = "'" + td.eq(2).find("input[name='update_val']").val() + "'";
            }

            var data = {
                orderid: global_orderid,
                jobid: global_jobid,
                version: global_version,
                stepid: global_stepid,
                seq1: seq1,
                seq2: seq2,
                seq3: seq3,
                column_name: jQuery.trim(td.eq(1).text()),
                update_val: updateval,
                status: "ACTIVE"
            };

            param.push(data);
        });

        //console.log("param "+param.length);

        ingShow(); $.ajax({
            url: "/piiorder/modifyordersteptableupdate",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                //$('#content_home').html(data);
                $('#steptableupdatemodify tr').each(function () {
                    $(this).remove();
                });
                $('#steptableupdatebody tr').each(function () {

                    td = $(this).children();//alert(td.eq(1).text()+"-"+td.eq(2).find("input[name='update_val']").val());
                    var datatype = jQuery.trim(td.eq(3).text());
                    var updateval;
                    if (td.eq(2).find("input[name='update_val']").val().toUpperCase() == "NULL") {
                        updateval = td.eq(2).find("input[name='update_val']").val();
                    } else if (datatype.toUpperCase() == "SAVEDDATA") {
                        updateval = td.eq(2).find("input[name='update_val']").val();
                    } else if (datatype.toUpperCase() == "NUMBER" || datatype.toUpperCase() == "DECIMAL" || datatype.toUpperCase() == "INT" || datatype.toUpperCase() == "BIGINT"
                        || datatype.toUpperCase() == "FLOAT" || datatype.toUpperCase() == "MEDIUMINT" || datatype.toUpperCase() == "SMALLINT" || datatype.toUpperCase() == "TINYINT") {
                        updateval = td.eq(2).find("input[name='update_val']").val();
                    } else if (datatype.toUpperCase() == "DATE" || datatype.toUpperCase() == "TIMESTAMP" || datatype.toUpperCase() == "TIME" || datatype.toUpperCase() == "DATETIME"
                        || datatype.toUpperCase().indexOf("TIMESTAMP") != -1 || datatype.toUpperCase().indexOf("YEAR") != -1) {
                        updateval = td.eq(2).find("input[name='update_val']").val();
                    } else {
                        updateval = "'" + td.eq(2).find("input[name='update_val']").val() + "'";
                    }

                    $("#steptableupdatemodify").append("<tr style='border: none;'><td style='border: none;'>" + td.eq(1).text() + " = </td><td style='border: none;'>" + updateval + "</td></tr>");
                });
                $("#GlobalSuccessMsgModal").modal("show");
                $("#dialogordertableupdatelist").modal("hide");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

    $("button[data-oper='searchsteptablelist']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        searchAction_steptableupdatedialog();
    });

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });


    searchAction_ordersteptableupdatedialog = function () {//alert("dialog searchAction_steptableupdatedialog");
        var global_jobid = $('#steptableupdate_global_jobid').val();
        var global_version = $('#steptableupdate_global_version').val();
        var global_stepid = $('#steptableupdate_global_stepid').val();
        var seq1 = $('#steptableupdate_seq1').val();
        var seq2 = $('#steptableupdate_seq2').val();
        var seq3 = $('#steptableupdate_seq3').val();

        var pagenum = $('#ordersteptableupdateForm [name="pagenum"]').val();
        var amount = $('#ordersteptableupdateForm [name="amount"]').val();
        var search1 = $('#ordersteptableupdateForm [name="search1"]').val();
        var search2 = $('#ordersteptableupdateForm [name="search2"]').val();
        var search3 = $('#ordersteptableupdateForm [name="search3"]').val();
        var search4 = $('#ordersteptableupdateForm [name="search4"]').val();
        var search5 = $('#ordersteptableupdateForm [name="search5"]').val();
        var search6 = $('#ordersteptableupdateForm [name="search6"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "modifyordersteptableupdatedialog?jobid=" + global_jobid + "&" + "version=" + global_version + "&" + "stepid=" + global_stepid
            + "&" + "seq1=" + seq1 + "&" + "seq2=" + seq2 + "&" + "seq3=" + seq3
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


        ingShow(); $.ajax({
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
                $('#dialogsteptableupdatelistbody').html(data);
                //$("#dialogordertableupdatelist").modal();

            }
        });
    }

</script>


