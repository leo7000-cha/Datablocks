<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-cogs"></i>
            <span><spring:message code="memu.recovery_job_apply" text="Job Recovery"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.recovery_management" text="Recovery"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.recovery_job_apply" text="Job"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                    <div class="policy-filter-item" style="width: 300px;">
                        <label class="policy-filter-label" for="search1"><spring:message code="etc.jobid" text="JOBID"/></label>
                        <select class="form-control form-control-sm" name="search1" id="search1" style="height: 34px;"
                                onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                            <option value=""></option>
                            <c:forEach items="${listjob}" var="piijob">
                                <option value="<c:out value="${piijob.jobid}"/>"
                                        <c:if test="${pageMaker.cri.search1 eq piijob.jobid}">selected</c:if>>
                                    <c:out value="${piijob.jobid}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="policy-filter-actions">
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button data-oper='register' class="btn btn-filter-register">
                        <i class="fas fa-redo-alt"></i> <spring:message code="etc.recovery" text="Recovery"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" style="table-layout: fixed; width: 100%;">
                <colgroup>
                    <col style="width: 40px"/>
                    <col style="width: 200px"/>
                    <col style="width: 60px"/>
                    <col style="width: 80px"/>
                    <col style="width: 80px"/>
                    <col style="width: 80px"/>
                    <col style="width: 70px"/>
                    <col style="width: 70px"/>
                    <col style="width: 70px"/>
                    <col style="width: 60px"/>
                    <col style="width: 100px"/>
                    <col style="width: 60px"/>
                    <col style="width: 90px"/>
                    <col style="width: 90px"/>
                    <col style="width: 130px"/>
                </colgroup>
                <thead>
                <tr>
                    <th>&nbsp;</th>
                    <th><spring:message code="col.jobid" text="JOBID"/></th>
                    <th><spring:message code="col.version" text="Ver"/></th>
                    <th><spring:message code="col.system" text="System"/></th>
                    <th><spring:message code="col.policy_id" text="Policy"/></th>
                    <th><spring:message code="col.keymap_id" text="Keymap"/></th>
                    <th><spring:message code="col.jobtype" text="Jobtype"/></th>
                    <th><spring:message code="col.runtype" text="Runtype"/></th>
                    <th><spring:message code="col.calendar" text="Calendar"/></th>
                    <th><spring:message code="col.time" text="Time"/></th>
                    <th><spring:message code="col.job_owner_name1" text="Owner"/></th>
                    <th><spring:message code="col.runcnt" text="Runcnt"/></th>
                    <th><spring:message code="etc.basedate_min" text="Min Date"/></th>
                    <th><spring:message code="etc.basedate_max" text="Max Date"/></th>
                    <th><spring:message code="etc.lastexedatetime" text="Last Exe.Time"/></th>
                </tr>
                </thead>
                <tbody id="apply">
                <c:forEach items="${list}" var="orderjob">
                    <tr>
                        <td class="text-center"><input type="radio" class="chkRadio" name="chkRadio"
                                                       onClick="checkeRowColorChange(this);"
                                                       style="width:15px;height:15px;"></td>
                        <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${orderjob.jobid}"/>"><c:out value="${orderjob.jobid}"/></td>
                        <td class="text-right"><c:out value="${orderjob.version}"/></td>
                        <td><c:out value="${orderjob.system}"/></td>
                        <td><c:out value="${orderjob.policy_id}"/></td>
                        <td><c:out value="${orderjob.keymap_id}"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${orderjob.jobtype eq 'PII' }"><spring:message code="etc.piipagi" text="PII"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'ILM' }"><spring:message code="etc.ilmshort" text="ILM"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'TDM' }"><spring:message code="etc.tdmshort" text="TDM"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'MIGRATE' }"><spring:message code="etc.mig" text="MIGRATE"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'SYNC' }"><spring:message code="etc.sync" text="Data synchronization"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'BATCH' }"><spring:message code="etc.dlmbatch" text="Batch"/></c:when>
                                <c:when test="${orderjob.jobtype eq 'ETC' }"><spring:message code="etc.etc" text="ETC"/></c:when>
                                <c:otherwise><c:out value="${orderjob.jobtype}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${orderjob.runtype eq 'REGULAR' }"><spring:message code="etc.regular" text="Regular"/></c:when>
                                <c:when test="${orderjob.runtype eq 'IRREGULAR' }"><spring:message code="etc.irregular" text="Irregular"/></c:when>
                                <c:when test="${orderjob.runtype eq 'DLM_BATCH' }"><spring:message code="etc.dlmbatch" text="DLM_Batch"/></c:when>
                                <c:when test="${orderjob.runtype eq 'RESTORE' }"><spring:message code="etc.restore" text="Restore"/></c:when>
                                <c:when test="${orderjob.runtype eq 'RECOVERY' }"><spring:message code="etc.recovery" text="Recovery"/></c:when>
                                <c:when test="${orderjob.runtype eq 'BACKDATED' }"><spring:message code="etc.backdated" text="Backdated"/></c:when>
                                <c:otherwise><c:out value="${orderjob.runtype}"/></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><c:out value="${orderjob.calendar}"/></td>
                        <td class="text-center"><c:out value="${orderjob.time}"/></td>
                        <td><c:out value="${orderjob.job_owner_name1}"/></td>
                        <td class="text-right"><c:out value="${orderjob.runcnt}"/></td>
                        <td class="text-center"><c:out value="${orderjob.basedate_min}"/></td>
                        <td class="text-center"><c:out value="${orderjob.basedate_max}"/></td>
                        <td class="text-center"><c:out value="${orderjob.lastexedatetime}"/></td>
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
    function checkeRowColorChange(obj) {
        jQuery("#apply > tr").css("background-color", "");
        var row = jQuery(".chkRadio").index(obj);
        jQuery("#apply > tr").eq(row).css("background-color", "#e0f2fe");
    };

    $(document).ready(function () {

        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            var param = [];
            var checkedcnt = 0;
            if (jQuery(".chkRadio:checked").val()) {
                var row = jQuery(".chkRadio:checked").parent().parent();
                var td = row.children();

                var data = {
                    recoveryid: null,
                    phase: "APPLY",
                    old_orderid: null,
                    new_orderid: null,
                    keymap_id: td.eq(5).text().trim(),
                    basedate: null,
                    old_jobid: td.eq(1).text().trim(),
                    old_version: td.eq(2).text().trim(),
                    new_jobid: td.eq(1).text().trim() + "_Recovery:All",
                    status: "NEW",
                    regdate: null,
                    upddate: null,
                    reguserid: $('#global_userid').val(),
                    upduserid: $('#global_userid').val()
                };

                param.push(data);
                checkedcnt++;
            }
            if (checkedcnt == 0) {
                dlmAlert("Select a Order for recovery");
                return;
            }

            $.ajax({
                url: "/piirecovery/jobregister",
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                type: "post",
                data: JSON.stringify(param),
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data, textStatus, jqXHR) {ingHide();
                    if (data == "success") {
                        showToast("처리가 완료되었습니다.", false);
                        searchAction(1);
                    } else {
                        $("#errormodalbody").html(data);
                        $("#errormodal").modal("show");
                    }
                },
                error: function (data, request, error) {
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });

        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piirecovery/list");
        });

    });

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();

        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "joblist?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        $.ajax({
            type: "GET",
            url: "/piirecovery/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

</script>
