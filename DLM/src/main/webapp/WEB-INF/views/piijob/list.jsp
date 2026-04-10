<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- JOB Management CSS -->
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${pageMaker.cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${pageMaker.cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${pageMaker.cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${pageMaker.cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${pageMaker.cri.search5}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${pageMaker.cri.search6}"/>'>
    <input type='hidden' name='search7' value='<c:out value="${pageMaker.cri.search7}"/>'>
    <input type='hidden' name='search8' value='<c:out value="${pageMaker.cri.search8}"/>'>
</form>

<!-- Calculate Statistics -->
<c:set var="totalJobs" value="${pageMaker.total}"/>
<c:set var="activeCount" value="0"/>
<c:set var="inactiveCount" value="0"/>
<c:set var="piiCount" value="0"/>
<c:set var="regularCount" value="0"/>
<c:set var="checkoutCount" value="0"/>
<c:forEach items="${list}" var="job">
    <c:if test="${job.status eq 'ACTIVE'}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    <c:if test="${job.status eq 'INACTIVE'}"><c:set var="inactiveCount" value="${inactiveCount + 1}"/></c:if>
    <c:if test="${job.jobtype eq 'PII'}"><c:set var="piiCount" value="${piiCount + 1}"/></c:if>
    <c:if test="${job.runtype eq 'REGULAR'}"><c:set var="regularCount" value="${regularCount + 1}"/></c:if>
    <c:if test="${job.phase eq 'CHECKOUT'}"><c:set var="checkoutCount" value="${checkoutCount + 1}"/></c:if>
</c:forEach>

<!-- Main Container -->
<div class="job-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-briefcase"></i>
            <span><spring:message code="memu.job" text="Job Management"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.task_configuration" text="Task"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.job" text="Job"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="job-filter-section">
        <div class="job-filter-row">
            <div class="job-filter-grid">
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search2"><spring:message code="col.jobtype" text="Job Type"/></label>
                <select class="job-filter-select" id="filter_search2" name="search2" onchange="searchAction(1)">
                    <option value=""><spring:message code="etc.all" text="All"/></option>
                    <option value="PII" <c:if test="${pageMaker.cri.search2 eq 'PII'}">selected</c:if>><spring:message code="etc.piipagi" text="PII"/></option>
                    <option value="TDM" <c:if test="${pageMaker.cri.search2 eq 'TDM'}">selected</c:if>><spring:message code="etc.tdm" text="TDM"/></option>
                    <option value="MIGRATE" <c:if test="${pageMaker.cri.search2 eq 'MIGRATE'}">selected</c:if>><spring:message code="etc.mig" text="MIGRATE"/></option>
                    <option value="ILM" <c:if test="${pageMaker.cri.search2 eq 'ILM'}">selected</c:if>><spring:message code="etc.ilm" text="ILM"/></option>
                    <option value="SYNC" <c:if test="${pageMaker.cri.search2 eq 'SYNC'}">selected</c:if>><spring:message code="etc.sync" text="SYNC"/></option>
                    <option value="BATCH" <c:if test="${pageMaker.cri.search2 eq 'BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                    <option value="ETC" <c:if test="${pageMaker.cri.search2 eq 'ETC'}">selected</c:if>><spring:message code="etc.etc" text="ETC"/></option>
                </select>
            </div>
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search8"><spring:message code="col.runtype" text="Run Type"/></label>
                <select class="job-filter-select" id="filter_search8" name="search8" onchange="searchAction(1)">
                    <option value=""><spring:message code="etc.all" text="All"/></option>
                    <option value="REGULAR" <c:if test="${pageMaker.cri.search8 eq 'REGULAR'}">selected</c:if>><spring:message code="etc.regular" text="Regular"/></option>
                    <option value="IRREGULAR" <c:if test="${pageMaker.cri.search8 eq 'IRREGULAR'}">selected</c:if>><spring:message code="etc.irregular" text="Irregular"/></option>
                    <option value="RESTORE" <c:if test="${pageMaker.cri.search8 eq 'RESTORE'}">selected</c:if>><spring:message code="etc.restore" text="Restore"/></option>
                    <option value="RECOVERY" <c:if test="${pageMaker.cri.search8 eq 'RECOVERY'}">selected</c:if>><spring:message code="etc.recovery" text="Recovery"/></option>
                    <option value="BACKDATED" <c:if test="${pageMaker.cri.search8 eq 'BACKDATED'}">selected</c:if>><spring:message code="etc.backdated" text="Backdated"/></option>
                </select>
            </div>
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search7"><spring:message code="col.status" text="Status"/></label>
                <select class="job-filter-select" id="filter_search7" name="search7" onchange="searchAction(1)">
                    <option value=""><spring:message code="etc.all" text="All"/></option>
                    <option value="ACTIVE" <c:if test="${pageMaker.cri.search7 eq 'ACTIVE'}">selected</c:if>>ACTIVE</option>
                    <option value="INACTIVE" <c:if test="${pageMaker.cri.search7 eq 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                </select>
            </div>
            <div class="job-filter-item" style="grid-column: span 2;">
                <label class="job-filter-label" for="filter_search1">JOBID</label>
                <input type="text" class="job-filter-input" id="filter_search1" name="search1" style="width: 100%;"
                       placeholder="JOBID" value='<c:out value="${pageMaker.cri.search1}"/>'
                       onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
            </div>
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search5"><spring:message code="col.policy_id" text="Policy"/></label>
                <select class="job-filter-select" id="filter_search5" name="search5" onchange="searchAction(1)">
                    <option value=""><spring:message code="etc.all" text="All"/></option>
                    <c:forEach items="${listpolicy}" var="piipolicy">
                        <option value="<c:out value="${piipolicy.policy_id}"/>" <c:if test="${pageMaker.cri.search5 eq piipolicy.policy_id}">selected</c:if>>
                            <c:out value="${piipolicy.policy_id}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search4"><spring:message code="col.system" text="System"/></label>
                <select class="job-filter-select" id="filter_search4" name="search4" onchange="searchAction(1)">
                    <option value=""><spring:message code="etc.all" text="All"/></option>
                    <c:forEach items="${listsystem}" var="piisystem">
                        <c:if test="${'ARCHIVE_DB' ne piisystem.system_id && 'DLM' ne piisystem.system_id}">
                            <option value="<c:out value="${piisystem.system_id}"/>" <c:if test="${pageMaker.cri.search4 eq piisystem.system_id}">selected</c:if>>
                                <c:out value="${piisystem.system_name}"/>
                            </option>
                        </c:if>
                    </c:forEach>
                </select>
            </div>
            <div class="job-filter-item">
                <label class="job-filter-label" for="filter_search3"><spring:message code="col.job_owner_name1" text="Owner"/></label>
                <input type="text" class="job-filter-input" id="filter_search3" name="search3"
                       placeholder=""
                       onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                       value='<c:out value="${pageMaker.cri.search3}"/>'
                       onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
            </div>
            </div>
            <div class="job-filter-actions">
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_SEC','ROLE_ADMIN')">
                    <button data-oper='register' class="btn btn-filter-register">
                        <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                    </button>
                </sec:authorize>
            </div>
        </div>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="job-table-section">
        <div class="job-table-wrapper">
            <table class="job-table" id="listTable555">
                <thead>
                <tr>
                    <th><spring:message code="col.jobid" text="JOBID"/></th>
                    <th class="text-center"><spring:message code="col.version" text="Ver"/></th>
                    <th><spring:message code="col.jobname" text="Job Name"/></th>
                    <th class="text-center"><spring:message code="col.system" text="System"/></th>
                    <th class="text-center"><spring:message code="col.policy_id" text="Policy"/></th>
                    <%--<th><spring:message code="col.keymap_id" text="Keymap"/></th>--%>
                    <th class="text-center"><spring:message code="col.jobtype" text="Type"/></th>
                    <th class="text-center"><spring:message code="col.runtype" text="Run"/></th>
                    <th class="text-center"><spring:message code="col.calendar" text="Calendar"/></th>
                    <th class="text-center"><spring:message code="col.time" text="Time"/></th>
                    <th class="text-center"><spring:message code="col.status" text="Status"/></th>
                    <th class="text-center"><spring:message code="col.phase" text="Phase"/></th>
                    <th class="text-center"><spring:message code="col.job_owner_name1" text="Owner"/></th>
                    <th class="text-center"><spring:message code="col.regdate" text="Reg Date"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piijob">
                    <tr>
                        <td><span class="cell-jobid"><c:out value="${piijob.jobid}"/></span></td>
                        <td class="text-center"><span class="cell-version"><c:out value="${piijob.version}"/></span></td>
                        <td><span class="cell-jobname" title="<c:out value="${piijob.jobname}"/>"><c:out value="${piijob.jobname}"/></span></td>
                        <td class="text-center"><span class="cell-system"><c:out value="${piijob.system}"/></span></td>
                        <td class="text-center"><span class="cell-policy"><c:out value="${piijob.policy_id}"/></span></td>
                        <%--<td><span class="cell-keymap"><c:out value="${piijob.keymap_id}"/></span></td>--%>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piijob.jobtype eq 'PII'}">
                                    <span class="job-badge badge-jobtype-pii"><i class="fas fa-shield-alt"></i> PII</span>
                                </c:when>
                                <c:when test="${piijob.jobtype eq 'TDM'}">
                                    <span class="job-badge badge-jobtype-tdm"><i class="fas fa-database"></i> TDM</span>
                                </c:when>
                                <c:when test="${piijob.jobtype eq 'ILM'}">
                                    <span class="job-badge badge-jobtype-ilm"><i class="fas fa-recycle"></i> ILM</span>
                                </c:when>
                                <c:when test="${piijob.jobtype eq 'MIGRATE'}">
                                    <span class="job-badge badge-jobtype-migrate"><i class="fas fa-exchange-alt"></i> MIG</span>
                                </c:when>
                                <c:when test="${piijob.jobtype eq 'BATCH'}">
                                    <span class="job-badge badge-jobtype-batch"><i class="fas fa-cogs"></i> BATCH</span>
                                </c:when>
                                <c:when test="${piijob.jobtype eq 'SYNC'}">
                                    <span class="job-badge badge-jobtype-sync"><i class="fas fa-sync"></i> SYNC</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="job-badge badge-jobtype-etc"><i class="fas fa-ellipsis-h"></i> <c:out value="${piijob.jobtype}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piijob.runtype eq 'REGULAR'}">
                                    <span class="job-badge badge-runtype-regular"><spring:message code="etc.regular" text="Regular"/></span>
                                </c:when>
                                <c:when test="${piijob.runtype eq 'IRREGULAR'}">
                                    <span class="job-badge badge-runtype-irregular"><spring:message code="etc.irregular" text="Irregular"/></span>
                                </c:when>
                                <c:when test="${piijob.runtype eq 'RESTORE'}">
                                    <span class="job-badge badge-runtype-restore"><spring:message code="etc.restore" text="Restore"/></span>
                                </c:when>
                                <c:when test="${piijob.runtype eq 'RECOVERY'}">
                                    <span class="job-badge badge-runtype-recovery"><spring:message code="etc.recovery" text="Recovery"/></span>
                                </c:when>
                                <c:when test="${piijob.runtype eq 'BACKDATED'}">
                                    <span class="job-badge badge-runtype-backdated"><spring:message code="etc.backdated" text="Backdated"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="job-badge badge-runtype-irregular"><c:out value="${piijob.runtype}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:if test="${piijob.runtype eq 'REGULAR' || piijob.runtype eq 'DLM_BATCH'}">
                                <span class="cell-calendar"><c:choose><c:when test="${piijob.calendar eq 'ALLDAYS'}"><spring:message code="etc.cal_alldays" text="매일"/></c:when><c:when test="${piijob.calendar eq 'WEEKDAYS'}"><spring:message code="etc.cal_weekdays" text="평일(월~금)"/></c:when><c:when test="${piijob.calendar eq 'WEEKEND'}"><spring:message code="etc.cal_weekend" text="주말(토,일)"/></c:when><c:when test="${piijob.calendar eq 'WEEK_MON'}"><spring:message code="etc.cal_mon" text="매주 월요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_TUE'}"><spring:message code="etc.cal_tue" text="매주 화요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_WED'}"><spring:message code="etc.cal_wed" text="매주 수요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_THU'}"><spring:message code="etc.cal_thu" text="매주 목요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_FRI'}"><spring:message code="etc.cal_fri" text="매주 금요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_SAT'}"><spring:message code="etc.cal_sat" text="매주 토요일"/></c:when><c:when test="${piijob.calendar eq 'WEEK_SUN'}"><spring:message code="etc.cal_sun" text="매주 일요일"/></c:when><c:when test="${piijob.calendar eq '2ND_SAT'}"><spring:message code="etc.cal_2nd_sat" text="격주 토요일"/></c:when><c:when test="${piijob.calendar eq '2ND_SUN'}"><spring:message code="etc.cal_2nd_sun" text="격주 일요일"/></c:when><c:otherwise><c:out value="${piijob.calendar}"/></c:otherwise></c:choose></span>
                            </c:if>
                        </td>
                        <td class="text-center">
                            <c:if test="${piijob.runtype eq 'REGULAR'}">
                                <span class="cell-time"><c:out value="${piijob.time}"/></span>
                            </c:if>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piijob.status eq 'ACTIVE'}">
                                    <span class="job-badge badge-status-active"><i class="fas fa-check"></i> ACTIVE</span>
                                </c:when>
                                <c:when test="${piijob.status eq 'INACTIVE'}">
                                    <span class="job-badge badge-status-inactive"><i class="fas fa-pause"></i> INACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="job-badge badge-status-inactive"><c:out value="${piijob.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piijob.phase eq 'CHECKOUT'}">
                                    <span class="job-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> CHECKOUT</span>
                                </c:when>
                                <c:when test="${piijob.phase eq 'CHECKIN'}">
                                    <span class="job-badge badge-phase-checkin"><i class="fas fa-lock"></i> CHECKIN</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="job-badge badge-phase-default"><i class="fas fa-check-circle"></i> <c:out value="${piijob.phase}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><span class="cell-owner"><c:out value="${piijob.job_owner_name1}"/></span></td>
                        <td class="text-center"><span class="cell-date"><c:out value="${piijob.regdate}"/></span></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <div class="job-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Job Type change handler
        $("#filter_search2").change(function () {
            if ($(this).val() !== "PII") {
                $("#filter_search8").val("");
            }
        });

        // Double-click row to view details
        $('#listTable555 tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var td = $(this).children();
            var jobid = td.eq(0).text().trim();
            var version = td.eq(1).text().trim();
            var isCheckout = $(this).find('.badge-phase-checkout').length > 0;
            var serchkeyno = "jobid=" + jobid + "&version=" + version;
            searchAction(null, serchkeyno, null, null, isCheckout);
        });

        // Search button
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        // Register button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#content_home').load("/piijob/register");
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno, filterKey, filterValue, isCheckout) {
        var search1 = $('#filter_search1').val() || '';
        var search2 = $('#filter_search2').val() || '';
        var search3 = $('#filter_search3').val() || '';
        var search4 = $('#filter_search4').val() || '';
        var search5 = $('#filter_search5').val() || '';
        var search6 = $('#searchForm [name="search6"]').val() || '';
        var search7 = $('#filter_search7').val() || '';
        var search8 = $('#filter_search8').val() || '';

        // Override filter if provided (for stat card clicks)
        if (filterKey && filterValue !== undefined) {
            if (filterKey === 'search2') search2 = filterValue;
            if (filterKey === 'search7') search7 = filterValue;
            if (filterKey === 'search8') search8 = filterValue;
            // Reset other filters when clicking stat cards
            if (filterKey !== '' && filterValue === '') {
                search1 = ''; search2 = ''; search3 = ''; search4 = '';
                search5 = ''; search7 = ''; search8 = '';
            }
        }

        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else if (isCheckout) {
            url_view = "modifyjoballinfo?" + serchkeyno + "&";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }

        var pagenum = pageNo || 1;
        var amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + encodeURIComponent(search3);
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#content_home').html(data);
            }
        });
    }
</script>
