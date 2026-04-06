<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>
<form style="margin: 0; padding: 0;" role="form" id="piijob_get_form">
    <input type="hidden" name='jobid' value='<c:out value="${piijob.jobid}"/>'>
    <input type="hidden" name='version' value='<c:out value="${piijob.version}"/>'>
    <input type="hidden" name='jobname' value='<c:out value="${piijob.jobname}"/>'>
    <input type="hidden" name='jobtype' value='<c:out value="${piijob.jobtype}"/>'>
    <input type="hidden" name='policy_id' value='<c:out value="${piijob.policy_id}"/>'>
    <input type="hidden" name='status' value='<c:out value="${piijob.status}"/>'>
    <input type="hidden" name='phase' value='<c:out value="${piijob.phase}"/>'>
    <input type="hidden" name='runtype' value='<c:out value="${piijob.runtype}"/>'>
    <input type="hidden" name='calendar' value='<c:out value="${piijob.calendar}"/>'>
    <input type="hidden" name='time' value='<c:out value="${piijob.time}"/>'>
    <input type="hidden" name='confirmflag' value='<c:out value="${piijob.confirmflag}" default="N"/>'>
    <input type="hidden" name='keymap_id' value='<c:out value="${piijob.keymap_id}"/>'>
    <input type="hidden" name='system' value='<c:out value="${piijob.system}"/>'>
    <input type="hidden" name='job_owner_name1' value='<c:out value="${piijob.job_owner_name1}"/>'>
    <input type="hidden" name='job_owner_id1' value='<c:out value="${piijob.job_owner_id1}"/>'>
    <input type="hidden" name='job_owner_name2' value='<c:out value="${piijob.job_owner_name2}"/>'>
    <input type="hidden" name='job_owner_id2' value='<c:out value="${piijob.job_owner_id2}"/>'>
    <input type="hidden" name='job_owner_name3' value='<c:out value="${piijob.job_owner_name3}"/>'>
    <input type="hidden" name='job_owner_id3' value='<c:out value="${piijob.job_owner_id3}"/>'>
    <input type="hidden" name='cronval' value='<c:out value="${piijob.cronval}"/>'>
    <input type="hidden" name='enddate' value='<c:out value="${piijob.enddate}"/>'>
    <input type="hidden" name='regdate' value='<c:out value="${piijob.regdate}"/>'>
    <input type="hidden" name='upddate' value='<c:out value="${piijob.upddate}"/>'>
    <input type="hidden" name='reguserid' value='<c:out value="${piijob.reguserid}"/>'>
    <input type="hidden" name='upduserid' value='<sec:authentication property="principal.member.userid"/>'>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

    <div class="jm-cards-row">
        <!-- 기본 정보 카드 -->
        <div class="jm-card jm-card-wide jm-card-info">
            <div class="jm-card-title"><i class="fas fa-info-circle"></i> 기본 정보</div>
            <div class="jm-card-body">
                <div class="jm-inline">
                    <div class="jm-field" style="flex:3;">
                        <label class="jm-label">JOBID</label>
                        <div class="jm-readonly"><strong><c:out value="${piijob.jobid}"/></strong></div>
                    </div>
                    <div class="jm-field" style="flex:0.5;">
                        <label class="jm-label">Ver</label>
                        <select name="version_select" id="job_version" class="jm-select" style="height:24px;">
                            <c:forEach items="${listallversion}" var="piijoballversion">
                                <option value="<c:out value="${piijoballversion.version}"/>" <c:if test="${piijob.version eq piijoballversion.version}">selected</c:if>><c:out value="${piijoballversion.version}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="jm-field" style="flex:0.5;">
                        <label class="jm-label">Status</label>
                        <div class="jm-readonly"><c:out value="${piijob.status}"/></div>
                    </div>
                </div>
                <div class="jm-inline">
                    <div class="jm-field" style="flex:3;">
                        <label class="jm-label">Job Name</label>
                        <div class="jm-readonly"><c:out value="${piijob.jobname}"/></div>
                    </div>
                    <div class="jm-field" style="flex:0.5;">
                        <label class="jm-label">Phase</label>
                        <div class="jm-readonly"><c:out value="${piijob.phase}"/></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Job 속성 카드 -->
        <div class="jm-card jm-card-props">
            <div class="jm-card-title"><i class="fas fa-tags"></i> Job 속성</div>
            <div class="jm-card-body">
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">Jobtype</label>
                        <div class="jm-readonly">
                            <c:choose>
                                <c:when test="${piijob.jobtype eq 'PII'}"><spring:message code="etc.piipagi" text="PII"/></c:when>
                                <c:when test="${piijob.jobtype eq 'TDM'}"><spring:message code="etc.tdm" text="TDM"/></c:when>
                                <c:when test="${piijob.jobtype eq 'MIGRATE'}"><spring:message code="etc.mig" text="MIGRATE"/></c:when>
                                <c:when test="${piijob.jobtype eq 'ILM'}"><spring:message code="etc.ilm" text="ILM"/></c:when>
                                <c:when test="${piijob.jobtype eq 'SYNC'}"><spring:message code="etc.sync" text="SYNC"/></c:when>
                                <c:when test="${piijob.jobtype eq 'BATCH'}"><spring:message code="etc.dlmbatch" text="Batch"/></c:when>
                                <c:when test="${piijob.jobtype eq 'ETC'}"><spring:message code="etc.etc" text="ETC"/></c:when>
                                <c:otherwise><c:out value="${piijob.jobtype}"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Policy</label>
                        <div class="jm-readonly"><c:out value="${piijob.policy_id}"/></div>
                    </div>
                </div>
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">System</label>
                        <div class="jm-readonly"><c:out value="${piijob.system}"/></div>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Keymap</label>
                        <div class="jm-readonly"><c:out value="${piijob.keymap_id}"/></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 수행 스케줄 카드 -->
        <div class="jm-card jm-card-narrow jm-card-schedule">
            <div class="jm-card-title"><i class="fas fa-clock"></i> 수행 스케줄</div>
            <div class="jm-card-body">
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">Runtype</label>
                        <div class="jm-readonly">
                            <c:choose>
                                <c:when test="${piijob.runtype eq 'REGULAR'}"><spring:message code="etc.regular" text="정기"/></c:when>
                                <c:when test="${piijob.runtype eq 'IRREGULAR'}"><spring:message code="etc.irregular" text="비정기"/></c:when>
                                <c:when test="${piijob.runtype eq 'DLM_BATCH'}"><spring:message code="etc.dlmbatch" text="Batch"/></c:when>
                                <c:otherwise><c:out value="${piijob.runtype}"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Calendar</label>
                        <div class="jm-readonly"><c:out value="${piijob.calendar}"/></div>
                    </div>
                </div>
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">Time</label>
                        <div class="jm-readonly"><c:out value="${piijob.time}"/></div>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Confirm</label>
                        <div class="toggle-container" style="margin-top:2px;">
                            <label class="switch"><input type="checkbox" class="toggle-switch" disabled <c:if test="${piijob.confirmflag eq 'Y'}">checked</c:if>><span class="slider"></span></label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 담당자 카드 -->
        <div class="jm-card jm-card-narrow jm-card-owner">
            <div class="jm-card-title"><i class="fas fa-users"></i> 담당자</div>
            <div class="jm-card-body">
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner1</label>
                    <div class="jm-readonly" style="max-width:110px;"><c:out value="${piijob.job_owner_name1}"/></div>
                </div>
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner2</label>
                    <div class="jm-readonly" style="max-width:110px;"><c:out value="${piijob.job_owner_name2}"/></div>
                </div>
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner3</label>
                    <div class="jm-readonly" style="max-width:110px;"><c:out value="${piijob.job_owner_name3}"/></div>
                </div>
            </div>
        </div>

        <!-- 선행 Job 카드 -->
        <div class="jm-card jm-card-narrow jm-card-wait">
            <div class="jm-card-title"><i class="fas fa-link"></i> 선행 Job</div>
            <div class="jm-card-body">
                <div class="jm-wait-list"><c:forEach items="${listjobwait}" var="piijobwait"><span class="jm-wait-tag"><c:out value="${piijobwait.jobid_w}"/></span></c:forEach></div>
            </div>
        </div>
    </div>

    <style>
    .jm-cards-row { display:flex; gap:8px; align-items:stretch; }
    .jm-card { background:#fff; border:1px solid #e2e8f0; border-radius:6px; padding:6px 10px; display:flex; flex-direction:column; flex:1; min-width:100px; }
    .jm-card-wide { flex:2; }
    .jm-card-narrow { flex:0.8; }
    .jm-card-info { border-left:3px solid #3b82f6; }
    .jm-card-info .jm-card-title { color:#1e40af; }
    .jm-card-props { border-left:3px solid #8b5cf6; }
    .jm-card-props .jm-card-title { color:#7c3aed; }
    .jm-card-schedule { border-left:3px solid #0ea5e9; }
    .jm-card-schedule .jm-card-title { color:#0369a1; }
    .jm-card-owner { border-left:3px solid #22c55e; }
    .jm-card-owner .jm-card-title { color:#15803d; }
    .jm-card-wait { border-left:3px solid #f59e0b; }
    .jm-card-wait .jm-card-title { color:#b45309; }
    .jm-card-title { font-size:0.7rem; font-weight:600; color:#1e40af; margin-bottom:4px; padding-bottom:3px; border-bottom:1px solid #e2e8f0; white-space:nowrap; }
    .jm-card-title i { margin-right:4px; }
    .jm-card-body { display:flex; flex-direction:column; gap:3px; flex:1; }
    .jm-inline { display:flex; gap:6px; }
    .jm-field { display:flex; flex-direction:column; gap:1px; flex:1; min-width:0; }
    .jm-field-row { display:flex; align-items:center; gap:5px; }
    .jm-field-row .jm-readonly { flex:1; min-width:80px; }
    .jm-label-inline { font-size:0.68rem; font-weight:600; color:#64748b; text-transform:uppercase; white-space:nowrap; min-width:55px; }
    .jm-label { font-size:0.68rem; font-weight:600; color:#64748b; text-transform:uppercase; white-space:nowrap; }
    .jm-select { height:24px; padding:0 5px; font-size:0.75rem; border:1px solid #cbd5e1; border-radius:4px; background:#fff; width:100%; box-sizing:border-box; }
    .jm-readonly { height:24px; padding:2px 5px; font-size:0.75rem; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; color:#334155; display:flex; align-items:center; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .jm-wait-list { display:flex; flex-wrap:wrap; gap:2px; min-height:24px; padding:2px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; align-items:center; }
    .jm-wait-tag { font-size:0.65rem; color:#64748b; background:#e2e8f0; padding:1px 4px; border-radius:3px; }
    </style>
</form>


<form style="margin: 0; padding: 0;" role="form" style="display: none;" id=searchForm_job>
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
</form>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.job" text="Job"/>" + ">Details")
    });


    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='modify_job']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piijob_get_form");
            var elementResult = $("#jobdetail");
            ingShow(); $.ajax({
                type: "POST",
                url: "/piijob/modify",
                dataType: "text",
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data);
                }
            });
        });

        $("button[data-oper='remove_job']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piijob_get_form");
            var elementResult = $("#content_home");
            ingShow(); $.ajax({
                type: "POST",
                url: "/piijob/remove",
                dataType: "html",
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data);
                }
            });

        });

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm_job [name="pagenum"]').val();
            var amount = $('#searchForm_job [name="amount"]').val();
            var search1 = $('#searchForm_job [name="search1"]').val();
            var search2 = $('#searchForm_job [name="search2"]').val();
            var search3 = $('#searchForm_job [name="search3"]').val();
            var search4 = $('#searchForm_job [name="search4"]').val();
            var search5 = $('#searchForm_job [name="search5"]').val();
            var search6 = $('#searchForm_job [name="search6"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) { url_search += "&search1=" + search1 };
            if (!isEmpty(search2)) { url_search += "&search2=" + search2 };
            if (!isEmpty(search3)) { url_search += "&search3=" + search3 };
            if (!isEmpty(search4)) { url_search += "&search4=" + search4 };
            if (!isEmpty(search5)) { url_search += "&search5=" + search5 };
            if (!isEmpty(search6)) { url_search += "&search6=" + search6 };

            ingShow(); $.ajax({
                type: "GET",
                url: "/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    $('#content_home').html(data);
                }
            });

        });

        $("#job_version").change(function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction_jobversion();
        });


    });
    searchAction_jobversion = function () {

        var serchkeyno1 = $('#piijob_get_form [name="jobid"]').val();
        var serchkeyno2 = $('#job_version').val(); // select에서 선택한 버전 값 사용

        var serchkeyno = "jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2;
        var url_view;
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;

        // 검색 조건 유지
        var search1 = $('#searchForm [name="search1"]').val() || '';
        var search2 = $('#searchForm [name="search2"]').val() || '';
        var search3 = $('#searchForm [name="search3"]').val() || '';
        var search4 = $('#searchForm [name="search4"]').val() || '';
        var search5 = $('#searchForm [name="search5"]').val() || '';
        var search6 = $('#searchForm [name="search6"]').val() || '';
        var search7 = $('#searchForm [name="search7"]').val() || '';
        var search8 = $('#searchForm [name="search8"]').val() || '';
        var url_search = "";

        if (!isEmpty(search1)) url_search += "&search1=" + encodeURIComponent(search1);
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + encodeURIComponent(search3);
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;

        ingShow(); $.ajax({
            type: "GET",
            url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

