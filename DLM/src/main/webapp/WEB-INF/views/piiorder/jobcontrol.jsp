<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-sliders"></i>
            <span><spring:message code="memu.job_execution_control" text="Job Control"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.monitoring" text="Monitoring"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.job_execution_control" text="Control"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="display: flex; flex-wrap: wrap; gap: 12px;">
                    <div class="policy-filter-item" style="width: 160px;">
                        <label class="policy-filter-label" for="search6"><spring:message code="col.jobtype" text="Jobtype"/></label>
                        <select class="form-control form-control-sm" id="search6" name="search6" style="height: 34px; font-weight: 600;" onchange="searchAction(1)">
                            <option value=""></option>
                            <option value="PII" <c:if test="${pageMaker.cri.search6 eq 'PII'}">selected</c:if>><spring:message code="etc.piipagi" text="PII"/></option>
                            <option value="TDM" <c:if test="${pageMaker.cri.search6 eq 'TDM'}">selected</c:if>><spring:message code="etc.tdm" text="TDM"/></option>
                            <option value="MIGRATE" <c:if test="${pageMaker.cri.search6 eq 'MIGRATE'}">selected</c:if>><spring:message code="etc.mig" text="MIGRATE"/></option>
                            <option value="ILM" <c:if test="${pageMaker.cri.search6 eq 'ILM'}">selected</c:if>><spring:message code="etc.ilm" text="ILM"/></option>
                            <option value="SYNC" <c:if test="${pageMaker.cri.search6 eq 'SYNC'}">selected</c:if>><spring:message code="etc.sync" text="Sync"/></option>
                            <option value="BATCH" <c:if test="${pageMaker.cri.search6 eq 'BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                            <option value="ETC" <c:if test="${pageMaker.cri.search6 eq 'ETC'}">selected</c:if>><spring:message code="etc.etc" text="ETC"/></option>
                        </select>
                    </div>
                    <div class="policy-filter-item" style="width: 130px;">
                        <label class="policy-filter-label" for="search5"><spring:message code="col.runtype" text="Runtype"/></label>
                        <select class="form-control form-control-sm" id="search5" name="search5" style="height: 34px; font-weight: 600;" onchange="searchAction(1)">
                            <option value="" <c:if test="${pageMaker.cri.search5 eq ''}">selected</c:if>></option>
                            <option value="REGULAR" <c:if test="${pageMaker.cri.search5 eq 'REGULAR'}">selected</c:if>><spring:message code="etc.regular" text="Regular"/></option>
                            <option value="IRREGULAR" <c:if test="${pageMaker.cri.search5 eq 'IRREGULAR'}">selected</c:if>><spring:message code="etc.irregular" text="Irregular"/></option>
                            <option value="RESTORE" <c:if test="${pageMaker.cri.search5 eq 'RESTORE'}">selected</c:if>><spring:message code="etc.restore" text="Restore"/></option>
                            <option value="RECOVERY" <c:if test="${pageMaker.cri.search5 eq 'RECOVERY'}">selected</c:if>><spring:message code="etc.recovery" text="Recovery"/></option>
                            <option value="BACKDATED" <c:if test="${pageMaker.cri.search5 eq 'BACKDATED'}">selected</c:if>><spring:message code="etc.backdated" text="Backdated"/></option>
                            <option value="DLM_BATCH" <c:if test="${pageMaker.cri.search5 eq 'DLM_BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                        </select>
                    </div>
                    <div class="policy-filter-item" style="width: 130px;">
                        <label class="policy-filter-label" for="search4">Status</label>
                        <select class="form-control form-control-sm" name="search4" id="search4" style="height: 34px; font-weight: 600;" onchange="searchAction(1)">
                            <option value="" <c:if test="${pageMaker.cri.search4 eq ''}">selected</c:if>></option>
                            <option value="Wait condition" <c:if test="${pageMaker.cri.search4 eq 'Wait condition'}">selected</c:if>>Wait</option>
                            <option value="Ended OK" <c:if test="${pageMaker.cri.search4 eq 'Ended OK'}">selected</c:if>>Ended OK</option>
                            <option value="Ended not OK" <c:if test="${pageMaker.cri.search4 eq 'Ended not OK'}">selected</c:if>>Error</option>
                            <option value="Running" <c:if test="${pageMaker.cri.search4 eq 'Running'}">selected</c:if>>Running</option>
                            <option value="Recovered" <c:if test="${pageMaker.cri.search4 eq 'Recovered'}">selected</c:if>>Recovered</option>
                            <option value="Hold" <c:if test="${pageMaker.cri.search4 eq 'Hold'}">selected</c:if>>Hold</option>
                        </select>
                    </div>
                    <div class="policy-filter-item" style="width: 280px;">
                        <label class="policy-filter-label" for="search1">JOBID</label>
                        <input type="text" class="policy-filter-input" id="search1" name="search1" placeholder="%JOBID% 검색"
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search1}"/>'>
                    </div>
                    <div class="policy-filter-item" style="width: 130px;">
                        <label class="policy-filter-label" for="search2">Basedate</label>
                        <input type="text" class="policy-filter-input" placeholder="YYYY/MM/DD" maxlength="10"
                               id="search2" name="search2"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search2}"/>' autocomplete="off">
                    </div>
                    <div class="policy-filter-item" style="width: 150px;">
                        <label class="policy-filter-label" for="search3"><spring:message code="col.job_owner" text="Job owner"/></label>
                        <input type="text" class="policy-filter-input" id="search3" name="search3" placeholder="아이디/이름"
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search3}"/>'>
                    </div>
                </div>
                <div class="policy-filter-actions" style="flex-wrap: wrap; gap: 6px; align-items: center;">
                    <button data-oper='rerun' class="btn btn-execute-emphasis-blue" id="btnExecute" disabled>
                        <i class="fas fa-bolt"></i> Execute
                    </button>
                    <span style="display: inline-block; width: 1px; height: 28px; background: #d1d5db; margin: 0 10px;"></span>
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button data-oper='updateactionflag' class="btn btn-filter-register" id="btnUpdate" disabled>
                        <i class="fas fa-save"></i> <spring:message code="btn.update" text="Update"/>
                    </button>
                    <button data-oper='removeOrder' class="btn btn-filter-reject" id="btnRemove" disabled>
                        <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Remove"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable" style="table-layout: fixed; width: 100%;">
                <colgroup>
                    <col style="width: 20px"/>
                    <col style="width: 85px"/>
                    <col style="width: 85px"/>
                    <col style="width: 50px"/>
                    <col style="width: 95px"/>
                    <col style="width: 230px"/>
                    <col style="width: 45px"/>
                    <col style="width: 70px"/>
                    <col style="width: 150px"/>
                    <col style="width: 80px"/>
                    <col style="width: 120px"/>
                    <col style="width: 80px"/>
                    <col style="width: 120px"/>
                    <col style="width: 120px"/>
                    <col style="width: 120px"/>
                    <col style="width: 80px"/>
                </colgroup>
                <thead>
                <tr>
                    <th>&nbsp;</th>
                    <th style="white-space: nowrap;"><spring:message code="col.orderid" text="ORDERID"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.status" text="상태"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.confirm" text="컨펌"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.basedate" text="기준일"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.jobid" text="JOBID"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.version" text="버전"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.system" text="시스템"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.jobtype" text="JOB타입"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.runtype" text="수행타입"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.eststarttime" text="예정시작시각"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.runningtime" text="수행시간"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.realstarttime" text="실제시작시각"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.realendtime" text="실제종료시각"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.orderdate" text="Order일시"/></th>
                    <th style="white-space: nowrap;"><spring:message code="col.job_owner" text="담당자"/></th>
                </tr>
                </thead>
                <tbody id="orderlist-body">
                <c:forEach items="${list}" var="piiorder">
                    <tr>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiorder.status ne 'Ended OK' && piiorder.status ne 'Recovered'}">
                                    <input type="checkbox" class="chkBox" name="chkBox" onClick="checkedRowColorChange();" style="width:15px;height:15px;">
                                </c:when>
                                <c:otherwise>&nbsp;</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-right"><c:out value="${piiorder.orderid}"/></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiorder.status eq 'Ended OK'}"><span class="status-badge status-badge-sm status-success"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Ended not OK'}"><span class="status-badge status-badge-sm status-error">Error</span></c:when>
                                <c:when test="${piiorder.status eq 'Running'}"><span class="status-badge status-badge-sm status-running"><i class="fa fa-spinner fa-spin"></i> <c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Wait condition'}">
                                    <span class="status-badge status-badge-sm status-wait" data-toggle="tooltip" data-placement="right"
                                          title="<c:choose><c:when test="${!empty piiorder.waitreason_waitjob}"><spring:message code="col.waitreason_waitjob" text="Not completed waiting jobs"/> : <c:out value="${piiorder.waitreason_waitjob}"/></c:when><c:when test="${!empty piiorder.waitreason_samejobnotcompleted}"><spring:message code="col.waitreason_samejobnotcompleted" text="Not completed same jobs"/> : <c:out value="${piiorder.waitreason_samejobnotcompleted}"/></c:when><c:when test="${!empty piiorder.waitreason_executiontime}"><spring:message code="col.waitreason_executiontime" text="Before the execution time"/> : <c:out value="${piiorder.waitreason_executiontime}"/></c:when></c:choose>">Wait</span>
                                </c:when>
                                <c:when test="${piiorder.status eq 'Recovered'}"><span class="status-badge status-badge-sm" style="background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: #fff;"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Hold'}"><span class="status-badge status-badge-sm status-warning"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:otherwise><span class="status-badge status-badge-sm"><c:out value="${piiorder.status}"/></span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiorder.status eq 'Wait condition'}">
                                    <div class="toggle-container text-center">
                                        <label class="switch">
                                            <input type="checkbox" class="toggle-switch" name="confirmflag" <c:if test="${piiorder.confirmflag eq 'Y'}">checked</c:if> value="Y">
                                            <span class="slider"></span>
                                        </label>
                                    </div>
                                </c:when>
                                <c:otherwise>&nbsp;</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="td-hidden"><input type="checkbox" style="width:15px;height:15px;" name="holdflag" value="Y" ${piiorder.holdflag == "Y" ? "CHECKED" : ""}></td>
                        <td class="td-hidden"><input type="checkbox" style="width:15px;height:15px;" name="forceokflag" value="Y" ${piiorder.forceokflag == "Y" ? "CHECKED" : ""}></td>
                        <td class="text-center"><c:out value="${piiorder.basedate}"/></td>
                        <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${piiorder.jobid}"/>">
                            <a href="javascript:diologDetailAction('${piiorder.orderid}','${piiorder.jobid}','${piiorder.version}','${piiorder.jobname}','${piiorder.basedate}')"><c:out value="${piiorder.jobid}"/></a>
                        </td>
                        <td class="td-hidden"><c:out value="${piiorder.jobid}"/></td>
                        <td class="text-right"><c:out value="${piiorder.version}"/></td>
                        <td class="td-hidden"><c:out value="${piiorder.jobname}"/></td>
                        <td class="text-center"><c:out value="${piiorder.system}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${piiorder.jobtype eq 'PII'}"><span style="font-size: 11px;" class="badge badge-primary"><i class="fa-solid fa-shield-halved"></i></span> <spring:message code="etc.piipagi" text="PII"/></c:when>
                                <c:when test="${piiorder.jobtype eq 'TDM'}"><span style="font-size: 11px;" class="badge badge-info"><i class="fa-solid fa-database"></i></span> <spring:message code="etc.tdm" text="TDM"/></c:when>
                                <c:when test="${piiorder.jobtype eq 'ILM'}"><span style="font-size: 11px;" class="badge badge-warning"><i class="fa-solid fa-recycle"></i></span> <spring:message code="etc.ilm" text="ILM"/></c:when>
                                <c:when test="${piiorder.jobtype eq 'MIGRATE'}"><span style="font-size: 11px;" class="badge badge-warning"><i class="fa-solid fa-arrow-right-arrow-left"></i></span> <spring:message code="etc.mig" text="MIGRATE"/></c:when>
                                <c:when test="${piiorder.jobtype eq 'BATCH'}"><span style="font-size: 11px;" class="badge badge-secondary"><i class="fa-solid fa-gears"></i></span> <spring:message code="etc.dlmbatch" text="Batch"/></c:when>
                                <c:when test="${piiorder.jobtype eq 'ETC'}"><span style="font-size: 11px;" class="badge badge-light"><i class="fa-solid fa-bars-progress"></i></span> <spring:message code="etc.etc" text="ETC"/></c:when>
                                <c:otherwise><span style="font-size: 11px;" class="badge badge-secondary"><i class="fa-solid fa-ellipsis"></i></span> <c:out value="${piiorder.jobtype}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${piiorder.runtype eq 'REGULAR'}"><spring:message code="etc.regular" text="Regular"/></c:when>
                                <c:when test="${piiorder.runtype eq 'IRREGULAR'}"><spring:message code="etc.irregular" text="Irregular"/></c:when>
                                <c:when test="${piiorder.runtype eq 'RESTORE'}"><spring:message code="etc.restore" text="Restore"/></c:when>
                                <c:when test="${piiorder.runtype eq 'RECOVERY'}"><spring:message code="etc.recovery" text="Recovery"/></c:when>
                                <c:when test="${piiorder.runtype eq 'BACKDATED'}"><spring:message code="etc.backdated" text="Backdated"/></c:when>
                                <c:when test="${piiorder.runtype eq 'DLM_BATCH'}"><spring:message code="etc.dlmbatch" text="DLM_Batch"/></c:when>
                                <c:otherwise><c:out value="${piiorder.runtype}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${piiorder.status ne 'Ended OK' && piiorder.status ne 'Recovered'}">
                                    <input type="text" placeholder="yyyy/mm/dd HH:mm:ss" class="form-control form-control-sm" maxlength="19"
                                           onblur="validateDateTime(this)" name="eststarttime" style="font-size: 11px; padding: 2px 4px;"
                                           value='<c:out value="${piiorder.eststarttime}"/>'>
                                </c:when>
                                <c:otherwise><c:out value="${piiorder.eststarttime}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><c:out value="${piiorder.runningtime}"/></td>
                        <td><c:out value="${piiorder.realstarttime}"/></td>
                        <td><c:out value="${piiorder.realendtime}"/></td>
                        <td><c:out value="${piiorder.orderdate}"/></td>
                        <td class="td-hidden"><c:out value="${piiorder.orderuserid}"/></td>
                        <td class="td-hidden"><c:out value="${piiorder.status}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${fn:startsWith(piiorder.jobid, 'TESTDATA_AUTO_GEN')}"><c:out value="${piiorder.job_owner_name3}"/></c:when>
                                <c:otherwise><c:out value="${piiorder.job_owner_name1}"/></c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Page navigation -->
    <div class="policy-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>

</div>

<script type="text/javascript">
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
    });

    $(document).ready(function () {
        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
        })
    })

    flatpickr("#search2", {
        locale: "ko",
        dateFormat: "Y/m/d",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        defaultDate: null,
        altInputClass: "policy-filter-input",
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piiorder/register");
        })
    });

    function checkedRowColorChange() {
        jQuery("#orderlist-body > tr").css("background-color", "");
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#e0f2fe");
        });

        // Enable/disable action buttons based on selection
        if (checkbox.length > 0) {
            $("#btnExecute").prop("disabled", false);
            $("#btnUpdate").prop("disabled", false);
            $("#btnRemove").prop("disabled", false);
        } else {
            $("#btnExecute").prop("disabled", true);
            $("#btnUpdate").prop("disabled", true);
            $("#btnRemove").prop("disabled", true);
        }
    };

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
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
        if (isEmpty(serchkeyno)) {
            url_view = "jobcontrol?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {url_search += "&search1="+search1;}
        if (!isEmpty(search2)) {url_search += "&search2="+search2;}
        if (!isEmpty(search3)) {url_search += "&search3="+search3;}
        if (!isEmpty(search4)) {url_search += "&search4="+search4;}
        if (!isEmpty(search5) && search6 != "BATCH") {url_search += "&search5="+search5;}
        if (!isEmpty(search6)) {url_search += "&search6="+search6;}
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });
    }

    $("button[data-oper='updateactionflag']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var precheck = false;
        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var realstarttime = td.eq(16).text();
            var status = td.eq(20).text();
            if (status == "Ended OK" || status == "Recovered") {
                precheck = false;
                return false;
            } else {
                precheck = true;
            }
        });
        if (!precheck) {
            $("#messagemodalbody").html("Order must not be in Ended OK, Recovered");
            $("#messagemodal").modal("show");
            return;
        }

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var confirmflag;
            if (td.eq(3).children().children().children().is(":checked")) confirmflag = "Y"; else confirmflag = "N";
            var holdflag;
            if (td.eq(4).children().is(":checked")) holdflag = td.eq(4).children().val(); else holdflag = "N";
            var forceokflag;
            if (td.eq(5).children().is(":checked")) forceokflag = td.eq(5).children().val(); else forceokflag = "N";
            var status = td.eq(20).text();
            if (status == "Ended OK" || status == "Recovered") {
                return true;
            }
            var data = {
                orderid: td.eq(1).text(),
                basedate: null,
                runcnt: null,
                jobid: null,
                version: null,
                jobname: null,
                system: null,
                jobtype: null,
                runtype: null,
                calendar: null,
                time: null,
                status: null,
                confirmflag: confirmflag,
                holdflag: holdflag,
                forceokflag: forceokflag,
                killflag: null,
                eststarttime: td.eq(14).children().val(),
                runningtime: null,
                realstarttime: null,
                realendtime: null,
                orderdate: null,
                orderuserid: td.eq(19).text()
            };
            param.push(data);
        });

        ingShow();
        $.ajax({
            url: "/piiorder/updateactionflag",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                $("#GlobalSuccessMsgModal").modal("show");
                searchAction(1);
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    });

    $("button[data-oper='rerun']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var precheck = false;
        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var realstarttime = td.eq(16).text();
            var status = td.eq(20).text();
            if (status == "Ended OK" || status == "Recovered") {
                precheck = false;
                return false;
            } else {
                precheck = true;
            }
        });
        if (checkbox.length === 0) {
            $("#messagemodalbody").html("Please check at least one item.");
            $("#messagemodal").modal("show");
            return;
        }
        if (!precheck) {
            $("#messagemodalbody").html("Order must not be in Ended OK, Recovered");
            $("#messagemodal").modal("show");
            return;
        }
        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var confirmflag = "N";
            var holdflag = "N";
            var forceokflag = "N";
            var data = {
                orderid: td.eq(1).text(),
                basedate: null,
                runcnt: null,
                jobid: td.eq(7).text(),
                version: td.eq(8).text(),
                jobname: null,
                system: null,
                jobtype: null,
                runtype: null,
                calendar: null,
                time: null,
                status: null,
                confirmflag: confirmflag,
                holdflag: holdflag,
                forceokflag: forceokflag,
                killflag: null,
                eststarttime: null,
                runningtime: null,
                realstarttime: null,
                realendtime: null,
                orderdate: null,
                orderuserid: td.eq(20).text()
            };
            param.push(data);
        });

        $.ajax({
            url: "/piiorder/rerun",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                $("#GlobalSuccessMsgModal").modal("show");
                searchAction(1);
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    });

    $("button[data-oper='removeOrder']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var global_version = $('#step_md_global_version').val();
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");

        var precheck = false;
        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var realstarttime = td.eq(16).text();
            var status = td.eq(20).text();
            if (status == "Ended OK" || status == "Recovered") {
                precheck = false;
                return false;
            } else {
                precheck = true;
            }
        });
        if (!precheck) {
            $("#messagemodalbody").html("Cann't remove Order in 'Ended OK', 'Recovered' status");
            $("#messagemodal").modal("show");
            return;
        }

        var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
        if (confirmflag == false) {
            return;
        }

        checkbox.each(function (i) {
            tr = checkbox.parent().parent().eq(i);
            td = tr.children();
            var realstarttime = td.eq(16).text();
            var status = td.eq(20).text();
            var data = {
                orderid: td.eq(1).text(),
                basedate: null,
                runcnt: null,
                jobid: td.eq(7).text(),
                version: td.eq(8).text(),
                jobname: null,
                system: null,
                jobtype: null,
                runtype: null,
                calendar: null,
                time: null,
                status: status,
                confirmflag: null,
                holdflag: null,
                forceokflag: null,
                killflag: null,
                eststarttime: null,
                runningtime: null,
                realstarttime: realstarttime,
                realendtime: null,
                orderdate: null,
                orderuserid: td.eq(19).text()
            };
            param.push(data);
        });

        $.ajax({
            url: "/piiorder/removeOrder",
            dataType: "html",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $("#GlobalSuccessMsgModal").modal("show");
                searchAction(1);
            }
        });
    });

    diologDetailAction = function (orderid, jobid, version, jobname, basedate) {
        $.ajax({
            type: "GET",
            url: encodeURI("/piiorder/getorderdetail?" + "orderid=" + orderid + "&jobid=" + jobid + "&version=" + version + "&stepseq=" + "0" + "&action=" + "2"),
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#jobdetailheader').html(jobid + " [ORDERID:" + orderid + ", <spring:message code='col.basedate' text='basedate'/>:" + basedate + "]");
                $('#jobdetailbody').html(data);
                $("#jobdetailmodal").modal();
                $("#" + "1").addClass("active");
            }
        });
    }

    function validateDateTime(input) {
        const value = input.value.trim();
        if (value === "") {
            return true;
        }
        const regex = /^(\d{4})\/(\d{2})\/(\d{2}) (\d{2}):(\d{2}):(\d{2})$/;
        const match = value.match(regex);
        if (!match) {
            alert("올바른 형식이 아닙니다. yyyy/mm/dd HH:mm:ss 형식으로 입력해주세요.");
            return false;
        }
        const year = parseInt(match[1], 10);
        const month = parseInt(match[2], 10) - 1;
        const day = parseInt(match[3], 10);
        const hour = parseInt(match[4], 10);
        const minute = parseInt(match[5], 10);
        const second = parseInt(match[6], 10);
        const date = new Date(year, month, day, hour, minute, second);
        if (
            date.getFullYear() !== year ||
            date.getMonth() !== month ||
            date.getDate() !== day ||
            date.getHours() !== hour ||
            date.getMinutes() !== minute ||
            date.getSeconds() !== second
        ) {
            alert("유효하지 않은 날짜 또는 시간입니다.");
            return false;
        }
        return true;
    }
</script>
