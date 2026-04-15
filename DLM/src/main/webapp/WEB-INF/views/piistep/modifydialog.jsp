<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">
<!-- Begin Page Content -->
<div class="card shadow m-1" style="height: 670px;width: 1100px; border-radius: 8px; overflow: hidden;">

    <div class="m-1 p-0" style="height:310px;width: 1090px;">
        <div class="tableWrapper" style="height:300px; border-radius: 6px; overflow-y: auto; border: 1px solid #e2e8f0;">
            <table id="listTable" class="table table-sm table-hover policy-table">
                <thead>
                <tr>
                    <th class="th-get">&nbsp;&nbsp;&nbsp;</th>
                    <th class="th-get">SEQ</th>
                    <th class="th-get">JOBID</th>
                    <th class="th-get">STEPID</th>
                    <th class="th-get">STEPNAME</th>
                    <th class="th-get">STATUS</th>
                </tr>
                </thead>
                <tbody id=modifydial-step>
                <c:forEach items="${list}" var="piistep">
                    <tr>
                        <td class="td-get"><input type="radio" class="chkRadio" name="chkRadio"
                                                  onClick="checkeRowColorChange(this);"
                                                  style="vertical-align:middle;width:15px;height:15px;"></td>
                        <td class="td-get-r"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.jobid}"/></td>
                        <td class="td-get-l"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-get-l"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>

                    </tr>
                </c:forEach>
                </tbody>
            </table>

        </div>
        <!-- <div class="table-responsive"> -->
    </div> <!-- <div class="card-body"> -->
    <div class="card-header m-0 p-0 " style="width:100%;">
        <div class="search-container-get-1row">
            <div class="step-item">
                <div class="d-flex align-items-center ml-1" style="gap: 4px;">
                    <input type="button" class="btn-action-up" onClick="rowMoveEvent('up');" value="▲"/>
                    <input type="button" class="btn-action-down" onClick="rowMoveEvent('down');" value="▼"/>
                    <input type="button" class="btn-action-save-seq" onClick="updateStepSeq();" value="Save"/>
                </div>
            </div>
            <div class="step-item"></div>
            <div class="step-item"><span id=modify_step_dlg_result style="color: #059669; font-weight: 500; font-size: 0.72rem;"><c:out value="${step_modifydiolog_result}"/></span>
            </div>
            <div class="step-item"></div>
            <div class="mr-1" style="text-align: right;">
                <sec:authorize access="isAuthenticated()">
                    <input type="button" class="btn-action-new" id="step_md_register" onClick="register();" value="+ New Step"/>
                </sec:authorize>

            </div>
        </div>

    </div>
    <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->


    <div class="card-body m-1 p-0">
        <div id="stepdetaildilaog">
        </div>
    </div>


</div>
<!-- <div class="card shadow mb-1"> -->
<input type='hidden' id='step_md_global_jobid' value='<c:out value="${jobid}"/>'>
<input type='hidden' id='step_md_global_version' value='<c:out value="${version}"/>'>
<input type='hidden' id='step_md_global_stepid' value='<c:out value="${stepid}"/>'>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">

    $("body").on('hidden.bs.modal', '.modal', function (e) {
        e.preventDefault();e.stopPropagation();

        // Ignore system modals (GlobalConfirmModal, errormodal, etc.)
        var modalId = $(this).attr('id');
        if (modalId === 'GlobalConfirmModal' || modalId === 'errormodal' || modalId === 'stepmodal') {
            return;
        }

        var global_jobid = $('#step_md_global_jobid').val();
        var global_version = $('#step_md_global_version').val();
        var global_stepid = $('#step_md_global_stepid').val();//alert(global_stepid);
        if (!isEmpty_dialog(global_stepid)) {
            var url_view = "/piijob/modifyjoballinfo?jobid=" + global_jobid + "&version=" + global_version + "&";//alert(url_view);
            searchAction_stepdialog(null, url_view, "#content_home");
        }

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
</script>

<script type="text/javascript">
    function checkeRowColorChange(obj) {
        jQuery("#modifydial-step > tr").css("background-color", "#FFFFFF");
        var row = jQuery(".chkRadio").index(obj);
        jQuery("#modifydial-step > tr").eq(row).css("background-color", "#F4F9FB");

        $('#modify_step_dlg_result').text("");
    }

    function rowMoveEvent(direction) {
        if (jQuery(".chkRadio:checked").val()) {
            var row = jQuery(".chkRadio:checked").parent().parent();

            var td = row.children();
            $('#step_md_global_stepid').val(td.eq(3).text());

            var num = row.index();
            var max = (jQuery(".chkRadio").length - 1);	   // index는 0부터 시작하기에 -1을 해준다.
            if (direction == "up") {
                if (num == 0) {
                    //alert("첫번째로 지정되어 있습니다.\n더이상 순서를 변경할 수 없습니다.");
                    return false;
                } else {
                    // 체크된 행(row)을 한칸 위로 올린다.
                    row.prev().before(row);
                }
            } else if (direction == "down") {
                if (num >= max) {
                    //alert("마지막으로 지정되어 있습니다.\n더이상 순서를 변경할 수 없습니다.");
                    return false;
                } else {
                    // 체크된 행(row)을 한칸 아래로 내린다.
                    row.next().after(row);
                }
            }
        } else {
            dlmAlert("Select a step to move.");
        }

        $('#modifydial-step > tr').each(function (index, tr) {
            //console.log(index);
            //console.log(tr);
            var tr = $(this);
            var td = tr.children();
            td.eq(1).html(index + 1);
        });
        $('#modify_step_dlg_result').text("");

    }

    function getStep(jobid, version, stepid) {
        $('#modify_step_dlg_result').text("");
        jQuery(".chkRadio:checked").removeAttr('checked');
        jQuery("#modifydial-step > tr").css("background-color", "#FFFFFF");

        var url_view = "/piistep/modify?jobid=" + jobid + "&" + "version=" + version + "&" + "stepid=" + stepid + "&";
        searchAction_stepdialog(null, url_view, "#stepdetaildilaog");
    }

    function updateStepSeq() {//alert(11);
        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;
        $('#modifydial-step > tr').each(function (index, tr) {
            //console.log(index);console.log(tr);
            tr = $(this);
            td = tr.children();

            var data = {
                stepseq: td.eq(1).text(),
                jobid: td.eq(2).text(),
                version: global_version,
                stepid: td.eq(3).text()
            };

            param.push(data);
        });

        //console.log("param "+param.length);
        ingShow(); $.ajax({
            url: "/piistep/modify_seq",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                $('#modify_step_dlg_result').html(data);
                //alert("success");//alert("success");//data - response from server
                //alert(td.eq(4).text());
                //$('#step_md_global_stepid').val(td.eq(4).text());

            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    }

</script>
<script type="text/javascript">

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });
    register = function () {
        $('#modify_step_dlg_result').text("");
        jQuery(".chkRadio:checked").removeAttr('checked');
        jQuery("#modifydial-step > tr").css("background-color", "#FFFFFF");
        $('#stepdetaildilaog').load("/piistep/register?jobid=" + $('#step_md_global_jobid').val() + "&version=" + $('#step_md_global_version').val());
    }

    searchAction_stepdialog = function (pageNo, url_view, div_success) {
        var global_stepid = $('#step_md_global_stepid').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        if (isEmpty_dialog(url_view)) url_view = "/piistep/list?";
        if (isEmpty_dialog(pagenum)) pagenum = 1;
        if (!isEmpty_dialog(pageNo)) pagenum = pageNo;
        if (isEmpty_dialog(amount)) amount = 100;
        if (!isEmpty_dialog(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty_dialog(search2)) {
            url_search += "&search2=" + search2;
        }
        //alert(url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $(div_success).html(data);
                if (div_success == "#content_home") {
                    $("#" + global_stepid).trigger("click");
                }

            }
        });
    }

    isEmpty_dialog = function (value) {
        if (value == "" || value == null || value == undefined || (value != null && typeof value == "object" && !Object.keys(value).length)) {
            return true;
        } else {
            return false;
        }
    }

    $('#listTable tbody').on('dblclick', 'tr', function (e) {
        e.preventDefault();e.stopPropagation();
        var str = ""
        var tdArr = new Array();	// 배열 선언

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();

        td.each(function (i) {
            tdArr.push(td.eq(i).text());
        });

        var jobid = td.eq(2).text().trim();
        var global_version = $('#step_md_global_version').val();
        var stepid = td.eq(3).text().trim();

        getStep(jobid, global_version, stepid);
    })

    // Function to refresh the step list after registration
    // callback: optional function to call after refresh completes
    refreshStepList = function (newStepid, callback) {
        var global_jobid = $('#step_md_global_jobid').val();
        var global_version = $('#step_md_global_version').val();
        var global_stepid = newStepid || $('#step_md_global_stepid').val() || '';

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piistep/modifydialog?jobid=" + global_jobid + "&version=" + global_version + "&stepid=" + global_stepid,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                // Find and update only the step list table body
                var newContent = $(data);
                var newTableBody = newContent.find('#modifydial-step').html();
                $('#modifydial-step').html(newTableBody);

                // Set the new stepid for subsequent operations
                if (newStepid) {
                    $('#step_md_global_stepid').val(newStepid);
                }

                // Execute callback after refresh completes
                if (typeof callback === 'function') {
                    callback();
                }
            }
        });
    }
</script>


