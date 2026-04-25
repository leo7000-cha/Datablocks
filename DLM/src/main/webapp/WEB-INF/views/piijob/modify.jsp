<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>

<form style="margin: 0; padding: 0;" role="form" id="piijob_modify_form">
    <input type="hidden" name='jobid' value='<c:out value="${piijob.jobid}"/>'>
    <input type="hidden" name='version' value='<c:out value="${piijob.version}"/>'>
    <input type="hidden" name='phase' value='<c:out value="${piijob.phase}"/>'>

    <div class="jm-cards-row">
        <!-- 기본 정보 카드 (넓게) -->
        <div class="jm-card jm-card-wide jm-card-info">
            <div class="jm-card-title"><i class="fas fa-info-circle"></i> 기본 정보</div>
            <div class="jm-card-body">
                <div class="jm-inline">
                    <div class="jm-field" style="flex:3;">
                        <label class="jm-label">JOBID</label>
                        <div class="jm-readonly"><strong><c:out value="${piijob.jobid}"/></strong></div>
                    </div>
                    <div class="jm-field" style="flex:0.3;">
                        <label class="jm-label">Ver</label>
                        <div class="jm-readonly"><c:out value="${piijob.version}"/></div>
                    </div>
                    <div class="jm-field" style="flex:0.5;">
                        <label class="jm-label">Status</label>
                        <select class="jm-select" name="status">
                            <option value="ACTIVE" <c:if test="${piijob.status eq 'ACTIVE'}">selected</c:if>>ACTIVE</option>
                            <option value="INACTIVE" <c:if test="${piijob.status eq 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                        </select>
                    </div>
                </div>
                <div class="jm-inline">
                    <div class="jm-field" style="flex:3;">
                        <label class="jm-label">Job Name</label>
                        <input type="text" class="jm-input" name='jobname' value='<c:out value="${piijob.jobname}"/>'>
                    </div>
                    <div class="jm-field" style="flex:0.5;">
                        <label class="jm-label">Phase</label>
                        <sec:authorize access="hasRole('ROLE_ADMIN')">
                            <div class="jm-readonly" id="phaseToggle" style="cursor:pointer;" title="더블클릭으로 Phase 변경"><c:out value="${piijob.phase}"/></div>
                        </sec:authorize>
                        <sec:authorize access="!hasRole('ROLE_ADMIN')">
                            <div class="jm-readonly"><c:out value="${piijob.phase}"/></div>
                        </sec:authorize>
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
                        <select class="jm-select" name="jobtype">
                            <option value="PII" <c:if test="${piijob.jobtype eq 'PII'}">selected</c:if>><spring:message code="etc.piipagi" text="PII"/></option>
                            <option value="TDM" <c:if test="${piijob.jobtype eq 'TDM'}">selected</c:if>><spring:message code="etc.tdm" text="TDM"/></option>
                            <option value="MIGRATE" <c:if test="${piijob.jobtype eq 'MIGRATE'}">selected</c:if>><spring:message code="etc.mig" text="MIGRATE"/></option>
                            <option value="ILM" <c:if test="${piijob.jobtype eq 'ILM'}">selected</c:if>><spring:message code="etc.ilm" text="ILM"/></option>
                            <option value="SYNC" <c:if test="${piijob.jobtype eq 'SYNC'}">selected</c:if>><spring:message code="etc.sync" text="SYNC"/></option>
                            <option value="BATCH" <c:if test="${piijob.jobtype eq 'BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                            <option value="ETC" <c:if test="${piijob.jobtype eq 'ETC'}">selected</c:if>><spring:message code="etc.etc" text="ETC"/></option>
                        </select>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Policy</label>
                        <select class="jm-select" name="policy_id">
                            <option value=""></option>
                            <c:forEach items="${listpolicy}" var="piipolicy">
                                <option value="<c:out value='${piipolicy.policy_id}'/>" <c:if test="${piijob.policy_id eq piipolicy.policy_id}">selected</c:if>><c:out value="${piipolicy.policy_id}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">System</label>
                        <select class="jm-select" name="system">
                            <option value=""></option>
                            <c:forEach items="${listsystem}" var="piisystem">
                                <c:if test="${'ARCHIVE_DB' ne piisystem.system_id && 'XOne' ne piisystem.system_id}">
                                    <option value="<c:out value='${piisystem.system_id}'/>" <c:if test="${piijob.system eq piisystem.system_id}">selected</c:if>><c:out value="${piisystem.system_name}"/></option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Keymap</label>
                        <input type="text" class="jm-input" name='keymap_id' value='<c:out value="${piijob.keymap_id}"/>'>
                    </div>
                </div>
            </div>
        </div>

        <!-- 스케줄 카드 (좁게) -->
        <div class="jm-card jm-card-schedule jm-card-narrow">
            <div class="jm-card-title"><i class="fas fa-clock"></i> 수행 스케줄</div>
            <div class="jm-card-body">
                <div class="jm-inline">
                    <div class="jm-field">
                        <label class="jm-label">Runtype</label>
                        <select class="jm-select" name="runtype" id="runtypeSelect" onchange="toggleScheduleRow()">
                            <option value="REGULAR" <c:if test="${piijob.runtype eq 'REGULAR'}">selected</c:if>><spring:message code="etc.regular" text="정기"/></option>
                            <option value="IRREGULAR" <c:if test="${piijob.runtype eq 'IRREGULAR'}">selected</c:if>><spring:message code="etc.irregular" text="비정기"/></option>
                            <option value="DLM_BATCH" <c:if test="${piijob.runtype eq 'DLM_BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                        </select>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Confirm</label>
                        <div class="toggle-container" style="margin-top:2px;">
                            <label class="switch"><input type="checkbox" class="toggle-switch" id="confirmflag_checkbox" <c:if test="${piijob.confirmflag eq 'Y'}">checked</c:if> onchange="document.getElementById('confirmflag_hidden').value = this.checked ? 'Y' : 'N';"><span class="slider"></span></label>
                            <input type="hidden" name="confirmflag" id="confirmflag_hidden" value="<c:out value="${piijob.confirmflag}" default="N"/>">
                        </div>
                    </div>
                </div>
                <div class="jm-inline" id="scheduleRow" style="${piijob.runtype eq 'IRREGULAR' ? 'display:none;' : ''}">
                    <div class="jm-field">
                        <label class="jm-label">Calendar</label>
                        <select class="jm-select" name="calendar">
                            <option value="" <c:if test="${piijob.calendar eq ''}">selected</c:if>></option>
                            <option value="ALLDAYS" <c:if test="${piijob.calendar eq 'ALLDAYS'}">selected</c:if>><spring:message code="etc.cal_alldays" text="매일"/></option>
                            <option value="WEEKDAYS" <c:if test="${piijob.calendar eq 'WEEKDAYS'}">selected</c:if>><spring:message code="etc.cal_weekdays" text="평일(월~금)"/></option>
                            <option value="WEEKEND" <c:if test="${piijob.calendar eq 'WEEKEND'}">selected</c:if>><spring:message code="etc.cal_weekend" text="주말(토,일)"/></option>
                            <option value="WEEK_MON" <c:if test="${piijob.calendar eq 'WEEK_MON'}">selected</c:if>><spring:message code="etc.cal_mon" text="매주 월요일"/></option>
                            <option value="WEEK_TUE" <c:if test="${piijob.calendar eq 'WEEK_TUE'}">selected</c:if>><spring:message code="etc.cal_tue" text="매주 화요일"/></option>
                            <option value="WEEK_WED" <c:if test="${piijob.calendar eq 'WEEK_WED'}">selected</c:if>><spring:message code="etc.cal_wed" text="매주 수요일"/></option>
                            <option value="WEEK_THU" <c:if test="${piijob.calendar eq 'WEEK_THU'}">selected</c:if>><spring:message code="etc.cal_thu" text="매주 목요일"/></option>
                            <option value="WEEK_FRI" <c:if test="${piijob.calendar eq 'WEEK_FRI'}">selected</c:if>><spring:message code="etc.cal_fri" text="매주 금요일"/></option>
                            <option value="WEEK_SAT" <c:if test="${piijob.calendar eq 'WEEK_SAT'}">selected</c:if>><spring:message code="etc.cal_sat" text="매주 토요일"/></option>
                            <option value="WEEK_SUN" <c:if test="${piijob.calendar eq 'WEEK_SUN'}">selected</c:if>><spring:message code="etc.cal_sun" text="매주 일요일"/></option>
                            <option value="2ND_SAT" <c:if test="${piijob.calendar eq '2ND_SAT'}">selected</c:if>><spring:message code="etc.cal_2nd_sat" text="격주 토요일"/></option>
                            <option value="2ND_SUN" <c:if test="${piijob.calendar eq '2ND_SUN'}">selected</c:if>><spring:message code="etc.cal_2nd_sun" text="격주 일요일"/></option>
                        </select>
                    </div>
                    <div class="jm-field">
                        <label class="jm-label">Time</label>
                        <input type="text" class="jm-input" id='time' name='time' value='<c:out value="${piijob.time}"/>' placeholder="HH:MM" readonly>
                    </div>
                </div>
            </div>
        </div>
        <script>function toggleScheduleRow() { $('#scheduleRow').toggle($('#runtypeSelect').val() !== 'IRREGULAR'); }</script>

        <!-- 담당자 카드 (좁게) -->
        <div class="jm-card jm-card-narrow jm-card-owner">
            <div class="jm-card-title"><i class="fas fa-users"></i> 담당자</div>
            <div class="jm-card-body">
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner1 <a href='javascript:diologSearchMember(1);'><i class="fas fa-search jm-icon"></i></a></label>
                    <div class="jm-readonly" id="job_owner_name1" style="max-width:110px;"><c:out value="${piijob.job_owner_name1}"/></div>
                    <input type="hidden" name='job_owner_name1' value='<c:out value="${piijob.job_owner_name1}"/>'><input type="hidden" name='job_owner_id1' value='<c:out value="${piijob.job_owner_id1}"/>'>
                    <a href='javascript:clearOwner(1);'><i class="fas fa-times jm-icon" style="color:#ef4444;"></i></a>
                </div>
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner2 <a href='javascript:diologSearchMember(2);'><i class="fas fa-search jm-icon"></i></a></label>
                    <div class="jm-readonly" id="job_owner_name2" style="max-width:110px;"><c:out value="${piijob.job_owner_name2}"/></div>
                    <input type="hidden" name='job_owner_name2' value='<c:out value="${piijob.job_owner_name2}"/>'><input type="hidden" name='job_owner_id2' value='<c:out value="${piijob.job_owner_id2}"/>'>
                    <a href='javascript:clearOwner(2);'><i class="fas fa-times jm-icon" style="color:#ef4444;"></i></a>
                </div>
                <div class="jm-field-row">
                    <label class="jm-label-inline">Owner3 <a href='javascript:diologSearchMember(3);'><i class="fas fa-search jm-icon"></i></a></label>
                    <div class="jm-readonly" id="job_owner_name3" style="max-width:110px;"><c:out value="${piijob.job_owner_name3}"/></div>
                    <input type="hidden" name='job_owner_name3' value='<c:out value="${piijob.job_owner_name3}"/>'><input type="hidden" name='job_owner_id3' value='<c:out value="${piijob.job_owner_id3}"/>'>
                    <a href='javascript:clearOwner(3);'><i class="fas fa-times jm-icon" style="color:#ef4444;"></i></a>
                </div>
            </div>
        </div>

        <!-- 선행 Job 카드 -->
        <div class="jm-card jm-card-narrow jm-card-wait">
            <div class="jm-card-title"><i class="fas fa-link"></i> 선행 Job <a href='javascript:diologJobWaitAction();'><i class="fas fa-edit jm-icon"></i></a></div>
            <div class="jm-card-body">
                <div id="jobwaitmodify" class="jm-wait-list"><c:forEach items="${listjobwait}" var="piijobwait"><span class="jm-wait-tag"><c:out value="${piijobwait.jobid_w}"/></span></c:forEach></div>
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
    .jm-field-sm { flex:0.6; }
    .jm-field-xs { flex:0.35; }
    .jm-label { font-size:0.68rem; font-weight:600; color:#64748b; text-transform:uppercase; white-space:nowrap; }
    .jm-req::after { content:'*'; color:#ef4444; margin-left:2px; }
    .jm-input, .jm-select { height:24px; padding:0 5px; font-size:0.75rem; border:1px solid #cbd5e1; border-radius:4px; background:#fff !important; width:100%; box-sizing:border-box; }
    .jm-input:focus, .jm-select:focus { outline:none; border-color:#3b82f6; box-shadow:0 0 0 2px rgba(59,130,246,0.15); background:#fff !important; }
    .jm-readonly { height:24px; padding:2px 5px; font-size:0.75rem; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; color:#334155; display:flex; align-items:center; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .jm-wait-list { display:flex; flex-wrap:wrap; gap:2px; min-height:24px; padding:2px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; align-items:center; }
    .jm-wait-tag { font-size:0.65rem; color:#64748b; background:#e2e8f0; padding:1px 4px; border-radius:3px; }
    .jm-icon { font-size:0.6rem; color:#3b82f6; margin-left:2px; }
    /* Flatpickr Time Picker Style */
    .flatpickr-calendar.hasTime.noCalendar {
        width: 120px !important;
        border-radius: 8px !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
    }
    /* Time Input Box Style */
    #time.jm-input {
        background: #fff !important;
        cursor: pointer !important;
    }
    </style>

                        <!-- Job Property Actions (표시: 변경 시) -->
                        <div id="jobPropActions" style="display:none; justify-content:flex-end; gap:8px; margin-top:10px; padding:8px 0;">
                            <button type="button" id="btnJobReset" class="btn btn-sm" style="background:#64748b; color:#fff; padding:5px 14px; border-radius:5px; font-size:0.78rem; font-weight:600;">
                                <i class="fas fa-undo"></i> Reset
                            </button>
                            <button type="button" id="btnJobSave" data-oper="modify_job" class="btn btn-sm" style="background:linear-gradient(135deg, #10b981 0%, #059669 100%); color:#fff; padding:5px 14px; border-radius:5px; font-size:0.78rem; font-weight:600; box-shadow:0 2px 8px rgba(16,185,129,0.3);">
                                <i class="fas fa-save"></i> Save Job Info
                            </button>
                        </div>

                        <input type="hidden" class="form-control form-control-sm" name='cronval' value='<c:out value="${piijob.cronval}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='enddate' value='<c:out value="${piijob.enddate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upddate' value='<c:out value="${piijob.upddate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='reguserid' value='<c:out value="${piijob.reguserid}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upduserid' value='<sec:authentication property="principal.member.userid"/>'>
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>

<form style="margin: 0; padding: 0;" role="form" id="piijob_modify_form_ori">
    <input type='hidden' name='ori_jobid' value='<c:out value="${piijob.jobid}"/>'>
    <input type='hidden' name='ori_version' value='<c:out value="${piijob.version}"/>'>
    <input type='hidden' name='ori_jobname' value='<c:out value="${piijob.jobname}"/>'>
    <input type='hidden' name='ori_system' value='<c:out value="${piijob.system}"/>'>
    <input type='hidden' name='ori_policy_id' value='<c:out value="${piijob.policy_id}"/>'>
    <input type='hidden' name='ori_keymap_id' value='<c:out value="${piijob.keymap_id}"/>'>
    <input type='hidden' name='ori_jobtype' value='<c:out value="${piijob.jobtype}"/>'>
    <input type='hidden' name='ori_runtype' value='<c:out value="${piijob.runtype}"/>'>
    <input type='hidden' name='ori_calendar' value='<c:out value="${piijob.calendar}"/>'>
    <input type='hidden' name='ori_time' value='<c:out value="${piijob.time}"/>'>
    <input type='hidden' name='ori_cronval' value='<c:out value="${piijob.cronval}"/>'>
    <input type='hidden' name='ori_confirmflag' value='<c:out value="${piijob.confirmflag}"/>'>
    <input type='hidden' name='ori_status' value='<c:out value="${piijob.status}"/>'>
    <input type='hidden' name='ori_phase' value='<c:out value="${piijob.phase}"/>'>
    <input type='hidden' name='ori_job_owner_id1' value='<c:out value="${piijob.job_owner_id1}"/>'>
    <input type='hidden' name='ori_job_owner_name1' value='<c:out value="${piijob.job_owner_name1}"/>'>
    <input type='hidden' name='ori_job_owner_id2' value='<c:out value="${piijob.job_owner_id2}"/>'>
    <input type='hidden' name='ori_job_owner_name2' value='<c:out value="${piijob.job_owner_name2}"/>'>
    <input type='hidden' name='ori_job_owner_id3' value='<c:out value="${piijob.job_owner_id3}"/>'>
    <input type='hidden' name='ori_job_owner_name3' value='<c:out value="${piijob.job_owner_name3}"/>'>
    <input type='hidden' name='ori_enddate' value='<c:out value="${piijob.enddate}"/>'>
    <input type='hidden' name='ori_regdate' value='<c:out value="${piijob.regdate}"/>'>
    <input type='hidden' name='ori_upddate' value='<c:out value="${piijob.upddate}"/>'>
    <input type='hidden' name='ori_reguserid' value='<c:out value="${piijob.reguserid}"/>'>
    <input type='hidden' name='ori_upduserid' value='<c:out value="${piijob.upduserid}"/>'>
</form>

<form style="margin: 0; padding: 0;" role="form" style="display: none;" id="searchForm_job">
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
    <input type='hidden' name='search7' value='<c:out value="${cri.search7}"/>'>
    <input type='hidden' name='search8' value='<c:out value="${cri.search8}"/>'>
</form>

<!-- 모달들 (원본 그대로) -->
<div class="modal fade" id="dialogjobwaitlist" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.job_wait_mgmt" text="Waiting Job management"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="dialogjobwaitlistbody">
                <h6>modifyjobwaitdialog.jsp</h6>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="dialogjobwaitlistclose" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="diologsearchmemberlist" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.search_member" text="Search member"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="diologsearchmemberlistbody">
                <h6>diologsearchmember.jsp</h6>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="diologsearchmemberlistclose" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $(function () {
            $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.job" text="Job"/>" + ">Modify")
        });

        // Time Picker 초기화
        flatpickr("#time", {
            enableTime: true,
            noCalendar: true,
            dateFormat: "H:i",
            time_24hr: true,
            defaultHour: 9,
            defaultMinute: 0,
            minuteIncrement: 10,
            allowInput: false
        });

        // ====== [추가] 더티 트래킹 & 섹션 액션 표시/숨김 ======
        (function(){
            const $form = $("#piijob_modify_form");
            const $actions = $("#jobPropActions");
            const $save = $("#btnJobSave");
            const $reset = $("#btnJobReset");

            let jobDirty = false;

            function setActionsVisible(v){
                if(v){ $actions.css("display","flex"); $save.prop("disabled", false); }
                else { $actions.css("display","none");  $save.prop("disabled", true); }
            }
            function markDirty(v){ jobDirty = !!v; setActionsVisible(jobDirty); }

            // 입력 변경 시 더티 처리 (ori_*, csrf 등 제외)
            $form.on("input change", "input, select, textarea", function(){
                const name = this.name || "";
                if(name.startsWith("ori_") || name === "${_csrf.parameterName}") return;
                markDirty(true);
            });

            // 저장 버튼 기존 로직 실행 전 중복 클릭 방지
            $save.on("click", function(){ $save.prop("disabled", true); });

            // Reset: ori_* 값 복원
            $reset.on("click", function(e){
                e.preventDefault(); e.stopPropagation();
                const $ori = $("#piijob_modify_form_ori");
                $ori.find("input[name^='ori_']").each(function(){
                    const field = this.name.replace(/^ori_/,"");
                    const val = $(this).val();
                    const $target = $form.find(`[name='${field}']`);
                    if(!$target.length) return;

                    if($target.is(":checkbox")){
                        $target.prop("checked", String(val).toUpperCase()==="Y");
                    }else{
                        $target.val(val);
                    }
                    $target.trigger("change"); // 종속 UI 갱신

                    if(field==="job_owner_name1") $("#job_owner_name1").text(val);
                    if(field==="job_owner_name2") $("#job_owner_name2").text(val);
                    if(field==="job_owner_name3") $("#job_owner_name3").text(val);
                });
                // time 별도 처리 보강
                const oriTime = $ori.find("[name='ori_time']").val();
                if (oriTime !== undefined) {
                    $form.find("[name='time']").val(oriTime).trigger("change");
                }
                // confirmflag 토글 스위치 복원
                const oriConfirm = $ori.find("[name='ori_confirmflag']").val();
                const isChecked = String(oriConfirm).toUpperCase() === "Y";
                $("#confirmflag_checkbox").prop("checked", isChecked);
                $("#confirmflag_hidden").val(isChecked ? "Y" : "N");

                // 담당자 복원 (표시 + hidden 모두)
                for (let i = 1; i <= 3; i++) {
                    const oriName = $ori.find("[name='ori_job_owner_name" + i + "']").val() || '';
                    const oriId = $ori.find("[name='ori_job_owner_id" + i + "']").val() || '';
                    $("#job_owner_name" + i).text(oriName);
                    $form.find("[name='job_owner_name" + i + "']").val(oriName);
                    $form.find("[name='job_owner_id" + i + "']").val(oriId);
                }

                markDirty(false);
            });

            // 최초에는 변경 없음
            markDirty(false);
        })();

        // ====== 기존: 저장(잡 속성만) ======
        $("button[data-oper='modify_job']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var jobtype = $('#piijob_modify_form [name="jobtype"]').val();
            if (isEmpty($('#piijob_modify_form [name="jobid"]').val())) {
                dlmAlert('<spring:message code="col.jobid" text="JOBID"/> is mandatory');
                $('#piijob_modify_form [name="jobid"]').focus(); return;
            }
            if (isEmpty($('#piijob_modify_form [name="jobname"]').val())) {
                dlmAlert('<spring:message code="col.jobname" text="Jobname"/> is mandatory');
                $('#piijob_modify_form [name="jobname"]').focus(); return;
            }
            if (jobtype == "PII" && isEmpty($('#piijob_modify_form [name="system"]').val())) {
                dlmAlert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_modify_form [name="system"]').focus(); return;
            }
            if (jobtype == "TDM" && isEmpty($('#piijob_modify_form [name="system"]').val())) {
                dlmAlert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_modify_form [name="system"]').focus(); return;
            }
            if (jobtype == "ILM" && isEmpty($('#piijob_modify_form [name="system"]').val())) {
                dlmAlert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_modify_form [name="system"]').focus(); return;
            }
            if (jobtype == "MIGRATE" && isEmpty($('#piijob_modify_form [name="system"]').val())) {
                dlmAlert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_modify_form [name="system"]').focus(); return;
            }
            if (jobtype == "PII" && isEmpty($('#piijob_modify_form [name="policy_id"]').val())) {
                dlmAlert('<spring:message code="col.policy_id" text="Policy_Id"/> is mandatory');
                $('#piijob_modify_form [name="policy_id"]').focus(); return;
            }
            if (jobtype == "PII" && isEmpty($('#piijob_modify_form [name="keymap_id"]').val())) {
                dlmAlert('<spring:message code="col.keymap_id" text="Keymap_Id"/> is mandatory');
                $('#piijob_modify_form [name="keymap_id"]').focus(); return;
            }
            if (isEmpty($('#piijob_modify_form [name="jobtype"]').val())) {
                dlmAlert('<spring:message code="col.jobtype" text="Jobtype"/> is mandatory');
                $('#piijob_modify_form [name="jobtype"]').focus(); return;
            }
            if (isEmpty($('#piijob_modify_form [name="runtype"]').val())) {
                dlmAlert('<spring:message code="col.runtype" text="Runtype"/> is mandatory');
                $('#piijob_modify_form [name="runtype"]').focus(); return;
            }
            if ($('#piijob_modify_form [name="runtype"]').val() == "REGULAR" && isEmpty($('#piijob_modify_form [name="calendar"]').val())) {
                dlmAlert('<spring:message code="col.calendar" text="Calendar"/> is mandatory');
                $('#piijob_modify_form [name="calendar"]').focus(); return;
            }
            if ($('#piijob_modify_form [name="runtype"]').val() == "REGULAR" && isEmpty($('#piijob_modify_form [name="time"]').val())) {
                dlmAlert('<spring:message code="col.time" text="Time"/> is mandatory');
                $('#piijob_modify_form [name="calendar"]').focus(); return;
            }
            if (jobtype == "PII" && !isEmpty($('#piijob_modify_form [name="calendar"]').val()) && isEmpty($('#piijob_modify_form [name="time"]').val())) {
                dlmAlert('<spring:message code="col.time" text="Time"/> is mandatory');
                $('#piijob_modify_form [name="time"]').focus(); return;
            }
            if (isEmpty($('#piijob_modify_form [name="job_owner_id1"]').val())) {
                dlmAlert('<spring:message code="col.job_owner_id1" text="Job_Owner_Id1"/> is mandatory');
                $('#piijob_modify_form [name="job_owner_id1"]').focus(); return;
            }
            if (isEmpty($('#piijob_modify_form [name="job_owner_name1"]').val())) {
                dlmAlert('<spring:message code="col.job_owner_name1" text="Job_Owner_Name1"/> is mandatory');
                $('#piijob_modify_form [name="job_owner_name1"]').focus(); return;
            }

            var url_view = "";
            var pagenum = $('#searchForm_job [name="pagenum"]').val();
            var amount = $('#searchForm_job [name="amount"]').val();
            var search1 = $('#searchForm_job [name="search1"]').val();
            var search2 = $('#searchForm_job [name="search2"]').val();
            var search3 = $('#searchForm_job [name="search3"]').val();
            var search4 = $('#searchForm_job [name="search4"]').val();
            var search5 = $('#searchForm_job [name="search5"]').val();
            var search6 = $('#searchForm_job [name="search6"]').val();
            var search7 = $('#searchForm_job [name="search7"]').val();
            var search8 = $('#searchForm_job [name="search8"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) { url_search += "&search1=" + search1; }
            if (!isEmpty(search2)) { url_search += "&search2=" + search2; }
            if (!isEmpty(search3)) { url_search += "&search3=" + search3; }
            if (!isEmpty(search4)) { url_search += "&search4=" + search4; }
            if (!isEmpty(search5)) { url_search += "&search5=" + search5; }
            if (!isEmpty(search6)) { url_search += "&search6=" + search6; }
            if (!isEmpty(search7)) { url_search += "&search7=" + search7; }
            if (!isEmpty(search8)) { url_search += "&search8=" + search8; }

            url_view = "modify?";

            var elementForm = $("#piijob_modify_form");
            var elementResult = $("#content_home");

            // 체크박스/hidden confirmflag 처리 (원본 유지)
            var checkbox = elementForm.find('input[type="checkbox"][name="confirmflag"]');
            var hiddenInput = elementForm.find('input[type="hidden"][name="confirmflag"]');
            if (!checkbox.is(':checked')) {
                checkbox.prop('disabled', true);
                hiddenInput.val('N');
            } else {
                hiddenInput.prop('disabled', true);
            }

            ingShow(); $.ajax({
                type: "POST",
                url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

        // ====== 기존: 삭제/리스트/대기잡/멤버검색 로직 유지 ======
        $("button[data-oper='remove_job']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var version = $("input[name='version']").val();
            showConfirm('현재 버전(Version ' + version + ')의 Job만 삭제됩니다.\n이전 버전은 유지되며, Checkin된 최신 버전으로 복구됩니다.\n\n정말 삭제하시겠습니까?', function() {
                var elementForm = $("#piijob_modify_form");
                var elementResult = $("#content_home");
                ingShow(); $.ajax({
                    type: "POST", url: "/piijob/remove", dataType: "html", data: elementForm.serialize(),
                    error: function (request, error) { ingHide(); $("#errormodalbody").html(request.responseText); $("#errormodal").modal("show"); },
                    success: function (data) { ingHide(); elementResult.html(data); }
                });
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
            var search7 = $('#searchForm_job [name="search7"]').val();
            var search8 = $('#searchForm_job [name="search8"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) { url_search += "&search1=" + search1; }
            if (!isEmpty(search2)) { url_search += "&search2=" + search2; }
            if (!isEmpty(search3)) { url_search += "&search3=" + search3; }
            if (!isEmpty(search4)) { url_search += "&search4=" + search4; }
            if (!isEmpty(search5)) { url_search += "&search5=" + search5; }
            if (!isEmpty(search6)) { url_search += "&search6=" + search6; }
            if (!isEmpty(search7)) { url_search += "&search7=" + search7; }
            if (!isEmpty(search8)) { url_search += "&search8=" + search8; }

            ingShow(); $.ajax({
                type: "GET",
                url: "/piijob/list?pagenum="+pagenum+"&amount="+amount+url_search,
                dataType: "html",
                error: function (request, error) { ingHide(); $("#errormodalbody").html(request.responseText); $("#errormodal").modal("show"); },
                success: function (data) { ingHide(); $('#content_home').html(data); }
            });
        });

        diologJobWaitAction = function () {
            if ($('#jobget_global_phase').val() != "CHECKOUT") { return; }
            var serchkeyno1 = $('#jobget_global_jobid').val();
            var serchkeyno2 = $('#jobget_global_version').val();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var url_search = ""; var url_view = "modifyjobwaitdialog?jobid=" + serchkeyno1 + "&version=" + serchkeyno2 + "&";
            if (isEmpty(pagenum)) pagenum = 1; if (isEmpty(amount)) amount = 100;
            amount = 100;
            ingShow(); $.ajax({
                type: "GET",
                url: "/piijob/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide(); $("#errormodalbody").html(request.responseText); $("#errormodal").modal("show"); },
                success: function (data) { ingHide(); $('#dialogjobwaitlistbody').html(data); $("#dialogjobwaitlist").modal(); }
            });
        }

        diologSearchMember = function (no) {
            var pagenum = 1; var amount = 100; var url_view = "diologsearchmember?"; var url_search = "";
            var search3 = no; var search4 = "modify";
            if (!isEmpty(search3)) url_search += "&search3=" + search3;
            if (!isEmpty(search4)) url_search += "&search4=" + search4;
            ingShow(); $.ajax({
                type: "GET",
                url: "/piimember/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide(); $("#errormodalbody").html(request.responseText); $("#errormodal").modal("show"); },
                success: function (data) { ingHide(); $('#diologsearchmemberlistbody').html(data); $("#diologsearchmemberlist").modal(); }
            });
        }

        clearOwner = function (no) {
            showConfirm('Owner' + no + ' 를 삭제하시겠습니까?', function() {
                $('#job_owner_name' + no).text('');
                $('#piijob_modify_form [name="job_owner_name' + no + '"]').val('').trigger("change");
                $('#piijob_modify_form [name="job_owner_id' + no + '"]').val('');
            });
        }
    });
</script>
