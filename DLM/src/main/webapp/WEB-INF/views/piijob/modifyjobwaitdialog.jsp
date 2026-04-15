<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">
<!-- Begin Page Content -->

<div class="jobwait-dialog-container">
    <div class="jobwait-dialog-content">
        <!-- Left Panel: Job List -->
        <div class="jobwait-panel">
            <div class="jobwait-panel-header">
                <form style="margin: 0; padding: 0;" role="form" id=searchForm_diologModifyJobWait>
                    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
                    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
                    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
                    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
                    <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
                    <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
                    <input type=hidden name="search2" id="search2" value='<c:out value="${cri.search2}"/>'>
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center" style="gap: 10px;">
                            <span class="jobwait-panel-title"><i class="fas fa-list-ul mr-2"></i>Job List</span>
                            <div class="d-flex align-items-center" style="gap: 6px;">
                                <%--<label class="search-dialog-label mb-0">JOBID</label>--%>
                                <input type=text class="search-dialog-input" style="width: 220px;" name="search1" id="search1"
                                       onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_jobwaitdialog(); }"
                                       value='<c:out value="${cri.search1}"/>' placeholder="Search Job ID...">
                            </div>
                        </div>
                        <button data-oper='searchjoblist' class="btn-dialog-search">
                            <i class="fas fa-search"></i> Search
                        </button>
                    </div>
                </form>
            </div>
            <div class="jobwait-table-container">
                <table class="wizard-compact-table wizard-header-table">
                    <thead>
                        <tr>
                            <th style="width: 40px;"></th>
                            <th>JOBID</th>
                            <th class="th-hidden">VERSION</th>
                            <th class="th-hidden">JOBNAME</th>
                            <th class="th-hidden">STATUS</th>
                            <th class="th-hidden">JOBTYPE</th>
                            <th style="width: 80px;">RUNTYPE</th>
                            <th style="width: 100px;">CALENDAR</th>
                            <th style="width: 70px;">TIME</th>
                        </tr>
                    </thead>
                </table>
                <div class="jobwait-table-wrapper">
                    <table class="wizard-compact-table" id="listTable_job">
                        <tbody>
                        <c:forEach items="${list}" var="piijob">
                            <tr>
                                <td class="text-center" style="width: 40px;"><input type="checkbox" class="wizard-checkbox" name="chkBoxJob"></td>
                                <td><c:out value="${piijob.jobid}"/></td>
                                <td class="td-hidden"><c:out value="${piijob.version}"/></td>
                                <td class="td-hidden"><c:out value="${piijob.jobname}"/></td>
                                <td class="td-hidden"><c:out value="${piijob.status}"/></td>
                                <td class="td-hidden"><c:out value="${piijob.jobtype}"/></td>
                                <td style="width: 80px;"><c:out value="${piijob.runtype}"/></td>
                                <td style="width: 100px;"><c:out value="${piijob.calendar}"/></td>
                                <td style="width: 70px;"><c:out value="${piijob.time}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Center: Action Buttons -->
        <div class="jobwait-actions">
            <button type="button" class="btn-jobwait-add" onClick="addJobWait();" title="Add to Waiting">
                <i class="fas fa-chevron-right"></i>
            </button>
            <button type="button" class="btn-jobwait-remove" onClick="deleteJobWait();" title="Remove from Waiting">
                <i class="fas fa-chevron-left"></i>
            </button>
        </div>

        <!-- Right Panel: Waiting Job List -->
        <div class="jobwait-panel jobwait-panel-right">
            <div class="jobwait-panel-header">
                <div class="d-flex align-items-center justify-content-between">
                    <span class="jobwait-panel-title"><i class="fas fa-clock mr-2"></i><spring:message code="etc.job_wait" text="Waiting Job"/></span>
                    <button data-oper='saveJobWait' class="btn-dialog-save">
                        <i class="fas fa-save"></i> Save
                    </button>
                </div>
            </div>
            <div class="jobwait-table-container">
                <table class="wizard-compact-table wizard-header-table">
                    <thead>
                        <tr>
                            <th style="width: 40px;"></th>
                            <th>JOBID</th>
                            <th class="th-hidden">JOBNAME</th>
                        </tr>
                    </thead>
                </table>
                <div class="jobwait-table-wrapper">
                    <table class="wizard-compact-table" id="listTable_jobwait">
                        <tbody id="jobwaitbody">
                        <c:forEach items="${listjobwait}" var="piijobwait">
                            <tr>
                                <td class="text-center" style="width: 40px;"><input type="checkbox" class="wizard-checkbox" name="chkBoxJobWait"></td>
                                <td><c:out value="${piijobwait.jobid_w}"/></td>
                                <td class="td-hidden"><c:out value="${piijobwait.jobname_w}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- <div class="card shadow mb-1"> -->
<input type='hidden' id='jobwait_global_jobid' value='<c:out value="${piijob.jobid}"/>'>
<input type='hidden' id='jobwait_global_version' value='<c:out value="${piijob.version}"/>'>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>


<script type="text/javascript">

    function addJobWait() {
        var param = [];
        var tr;
        var td;
        var existflag = true;

        var checkbox = $("input:checkbox[name=chkBoxJob]:checked");//.parent().parent()

        checkbox.each(function (i) {
            existflag = true;
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var global_jobid = $('#jobwait_global_jobid').val();
            $('#jobwaitbody tr').each(function () { //alert($(this).children().eq(1).text()  +"   "+td.eq(1).text());
                if (td.eq(1).text() == $(this).children().eq(1).text()) {
                    existflag = false;
                    return false;
                }

            });
            if (td.eq(1).text() == global_jobid) {// prevent to avoid itself
                existflag = false;
            }
            if (existflag)
                $("#jobwaitbody").append("<tr><td class='text-center' style='width: 40px;'><input type='checkbox' class='wizard-checkbox' name='chkBoxJobWait'></td><td>" + td.eq(1).text() + "</td><td class='td-hidden'>" + td.eq(3).text() + "</td></tr>");
        });

    }

    function deleteJobWait() {
        $('#jobwaitbody tr').each(function () {
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
            searchAction_jobwaitdialog(null,url_view,"#content_home");
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


    $("button[data-oper='saveJobWait']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_jobid = $('#jobwait_global_jobid').val();
        var global_version = $('#jobwait_global_version').val();
        var param = [];
        var td;
        //For the case empty list
        var data_header = {
            jobid: global_jobid,
            version: global_version,
            type: "HEADER",
            jobid_w: "HEADER",
            jobname_w: "HEADER"
        };

        param.push(data_header);

        $('#jobwaitbody tr').each(function () {

            td = $(this).children();
            var data = {
                jobid: global_jobid,
                version: global_version,
                type: "PRE",
                jobid_w: td.eq(1).text(),
                jobname_w: td.eq(2).text()
            };

            param.push(data);
        });

        //console.log("param "+param.length);


        ingShow(); $.ajax({
            url: "/piijob/modifyjobwait",
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
                $('#jobwaitmodify').empty();
                $('#jobwaitbody tr').each(function () {
                    $("#jobwaitmodify").append("<span class='jm-wait-tag'>" + $(this).children().eq(1).text() + "</span>");
                });

                showToast("처리가 완료되었습니다.", false);
                $("#dialogjobwaitlist").modal("hide");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    });

    $("button[data-oper='searchjoblist']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        searchAction_jobwaitdialog();
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });


    searchAction_jobwaitdialog = function () {//alert("dialog searchAction_jobwaitdialog");
        var serchkeyno1 = $('#jobwait_global_jobid').val();
        var serchkeyno2 = $('#jobwait_global_version').val();
        var serchkeyno3 = '';//$('#jobget_global_stepid').val();//$('input[name=stepid]').val();
        var pagenum = $('#searchForm_diologModifyJobWait [name="pagenum"]').val();
        var amount = $('#searchForm_diologModifyJobWait [name="amount"]').val();
        var search1 = $('#searchForm_diologModifyJobWait [name="search1"]').val();
        var search2 = $('#searchForm_diologModifyJobWait [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "modifyjobwaitdialog?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        amount = 100;
        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piijob/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#dialogjobwaitlistbody').html(data);
                //$("#dialogjobwaitlist").modal();

            }
        });
    }

</script>


