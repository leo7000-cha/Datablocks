<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<div class="reg-page">
    <!-- Header -->
    <div class="reg-header">
        <div class="reg-header-content">
            <div class="reg-header-left">
                <div class="reg-header-icon"><i class="fas fa-rocket"></i></div>
                <div class="reg-header-text">
                    <h2>Create New Job</h2>
                    <p>Configure and register a new data lifecycle job</p>
                </div>
            </div>
            <div class="reg-header-actions">
                <button data-oper='list' class="reg-btn reg-btn-ghost"><i class="fas fa-arrow-left"></i> Back to List</button>
                <button data-oper='register' class="reg-btn reg-btn-save"><i class="fas fa-check-circle"></i> <spring:message code="btn.save" text="Save"/></button>
            </div>
        </div>
    </div>

    <!-- Form Body -->
    <form role="form" id="piijob_register_form" class="reg-body">

        <!-- Section 1: Job Identity -->
        <div class="reg-section reg-section-identity">
            <div class="reg-section-header">
                <i class="fas fa-fingerprint"></i> Job Identity
            </div>
            <div class="reg-grid reg-grid-identity">
                <div class="reg-field reg-field-wide">
                    <label class="reg-label">JOBID <span class="reg-required">*</span></label>
                    <input type="text" class="reg-input" autofocus name="jobid"
                           placeholder="POLICY_DB_SYSTEM_JOBTYPE"
                           value='<c:out value="${piijob.jobid}"/>'>
                </div>
                <div class="reg-field reg-field-wide">
                    <label class="reg-label">Job Name <span class="reg-required">*</span></label>
                    <input type="text" class="reg-input" name="jobname"
                           placeholder="Enter job name"
                           value='<c:out value="${piijob.jobname}"/>'>
                </div>
                <div class="reg-field">
                    <label class="reg-label">Version</label>
                    <div class="reg-static-value">
                        <span class="reg-version-badge">v1</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 2: Configuration -->
        <div class="reg-section reg-section-config">
            <div class="reg-section-header">
                <i class="fas fa-sliders-h"></i> Configuration
            </div>
            <div class="reg-grid reg-grid-config">
                <div class="reg-field">
                    <label class="reg-label">Job Type <span class="reg-required">*</span></label>
                    <select class="reg-select" name="jobtype">
                        <option value="PII" <c:if test="${piijob.jobtype eq 'PII'}">selected</c:if>><spring:message code="etc.piipagi" text="PII"/></option>
                        <option value="TDM" <c:if test="${piijob.jobtype eq 'TDM'}">selected</c:if>><spring:message code="etc.tdm" text="TDM"/></option>
                        <option value="MIGRATE" <c:if test="${piijob.jobtype eq 'MIGRATE'}">selected</c:if>><spring:message code="etc.mig" text="MIGRATE"/></option>
                        <option value="ILM" <c:if test="${piijob.jobtype eq 'ILM'}">selected</c:if>><spring:message code="etc.ilm" text="ILM"/></option>
                        <option value="SYNC" <c:if test="${piijob.jobtype eq 'SYNC'}">selected</c:if>><spring:message code="etc.sync" text="Data synchronization"/></option>
                        <option value="BATCH" <c:if test="${piijob.jobtype eq 'BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                        <option value="ETC" <c:if test="${piijob.jobtype eq 'ETC'}">selected</c:if>><spring:message code="etc.etc" text="ETC"/></option>
                    </select>
                </div>
                <div class="reg-field">
                    <label class="reg-label">Policy</label>
                    <select class="reg-select" name="policy_id">
                        <option value="">-- Select --</option>
                        <c:forEach items="${listpolicy}" var="piipolicy">
                            <c:if test="${piipolicy.policy_id ne 'PII_TESTDATA'}">
                                <option value="<c:out value="${piipolicy.policy_id}"/>"><c:out value="${piipolicy.policy_id}"/></option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="reg-field">
                    <label class="reg-label"><spring:message code="col.db" text="DB"/> <span class="reg-required">*</span></label>
                    <select class="reg-select" name="db">
                        <option value="">-- Select --</option>
                        <c:forEach items="${piidatabaselist}" var="piidatabase">
                            <option value="<c:out value="${piidatabase.db}"/>"><c:out value="${piidatabase.db}"/></option>
                        </c:forEach>
                    </select>
                </div>
                <div class="reg-field">
                    <label class="reg-label">Keymap</label>
                    <input type="text" class="reg-input" name="keymap_id"
                           placeholder="Enter keymap ID"
                           value='<c:out value="${piijob.keymap_id}"/>'>
                </div>
                <div class="reg-field">
                    <label class="reg-label"><spring:message code="col.system" text="System"/> <span class="reg-required">*</span></label>
                    <select class="reg-select" name="system">
                        <option value="">-- Select --</option>
                        <c:forEach items="${listsystem}" var="piisystem">
                            <c:if test="${'ARCHIVE_DB' ne piisystem.system_id && 'DLM' ne piisystem.system_id}">
                                <option value="<c:out value="${piisystem.system_id}"/>"
                                        <c:if test="${piijob.system eq piisystem.system_id}">selected</c:if>>
                                    <c:out value="${piisystem.system_name}"/></option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </div>

        <!-- Section 3: Schedule -->
        <div class="reg-section reg-section-schedule">
            <div class="reg-section-header">
                <i class="fas fa-clock"></i> Schedule
            </div>
            <div class="reg-grid reg-grid-schedule">
                <div class="reg-field">
                    <label class="reg-label">Run Type <span class="reg-required">*</span></label>
                    <select class="reg-select" name="runtype" id="runtypeSelect">
                        <option value="IRREGULAR" <c:if test="${empty piijob.runtype or piijob.runtype eq 'IRREGULAR'}">selected</c:if>><spring:message code="etc.irregular" text="Irregular"/></option>
                        <option value="REGULAR" <c:if test="${piijob.runtype eq 'REGULAR'}">selected</c:if>><spring:message code="etc.regular" text="Regular"/></option>
                        <option value="DLM_BATCH" <c:if test="${piijob.runtype eq 'DLM_BATCH'}">selected</c:if>><spring:message code="etc.dlmbatch" text="Batch"/></option>
                    </select>
                </div>
                <div class="reg-field reg-field-calendar" id="scheduleCalendarField" style="display:none;">
                    <label class="reg-label">Calendar</label>
                    <div class="cal-picker" id="calPicker">
                        <button type="button" class="cal-trigger" id="calTrigger">
                            <i class="far fa-calendar-alt cal-trigger-icon"></i>
                            <span class="cal-trigger-text" id="calTriggerText"><spring:message code="cal.select" text="스케줄 선택"/></span>
                            <i class="fas fa-chevron-down cal-trigger-arrow"></i>
                        </button>
                        <div class="cal-dropdown" id="calDropdown">
                            <div class="cal-group">
                                <div class="cal-group-label"><i class="fas fa-globe"></i> <spring:message code="cal.everyday" text="매일"/></div>
                                <div class="cal-chips">
                                    <button type="button" class="cal-chip cal-chip-all" data-val="ALLDAYS"><i class="fas fa-infinity"></i> <spring:message code="cal.alldays" text="매일"/></button>
                                </div>
                            </div>
                            <div class="cal-group">
                                <div class="cal-group-label"><i class="fas fa-briefcase"></i> <spring:message code="cal.group" text="요일 그룹"/></div>
                                <div class="cal-chips">
                                    <button type="button" class="cal-chip" data-val="WEEKDAYS"><i class="fas fa-building"></i> <spring:message code="cal.weekdays" text="평일 (월~금)"/></button>
                                    <button type="button" class="cal-chip" data-val="WEEKEND"><i class="fas fa-umbrella-beach"></i> <spring:message code="cal.weekend" text="주말 (토~일)"/></button>
                                </div>
                            </div>
                            <div class="cal-group">
                                <div class="cal-group-label"><i class="fas fa-calendar-day"></i> <spring:message code="cal.specificday" text="매주 특정 요일"/></div>
                                <div class="cal-chips cal-chips-days">
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_MON"><spring:message code="cal.mon" text="월"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_TUE"><spring:message code="cal.tue" text="화"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_WED"><spring:message code="cal.wed" text="수"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_THU"><spring:message code="cal.thu" text="목"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_FRI"><spring:message code="cal.fri" text="금"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_SAT"><spring:message code="cal.sat" text="토"/></button>
                                    <button type="button" class="cal-chip cal-chip-day" data-val="WEEK_SUN"><spring:message code="cal.sun" text="일"/></button>
                                </div>
                            </div>
                            <div class="cal-group">
                                <div class="cal-group-label"><i class="fas fa-redo-alt"></i> <spring:message code="cal.biweekly" text="격주"/></div>
                                <div class="cal-chips">
                                    <button type="button" class="cal-chip" data-val="2ND_SAT"><i class="fas fa-calendar-week"></i> <spring:message code="cal.2nd_sat" text="격주 토요일"/></button>
                                    <button type="button" class="cal-chip" data-val="2ND_SUN"><i class="fas fa-calendar-week"></i> <spring:message code="cal.2nd_sun" text="격주 일요일"/></button>
                                </div>
                            </div>
                            <button type="button" class="cal-clear" id="calClear"><i class="fas fa-times"></i> <spring:message code="cal.clear" text="초기화"/></button>
                        </div>
                        <input type="hidden" name="calendar" id="calendarHidden" value='<c:out value="${piijob.calendar}"/>'>
                    </div>
                </div>
                <div class="reg-field reg-field-time" id="scheduleTimeField" style="display:none;">
                    <label class="reg-label"><spring:message code="col.time" text="시각"/></label>
                    <div class="tp-picker" id="tpPicker">
                        <button type="button" class="tp-trigger" id="tpTrigger">
                            <i class="far fa-clock tp-trigger-icon"></i>
                            <span class="tp-trigger-text" id="tpTriggerText"><spring:message code="cal.select" text="시간 선택"/></span>
                            <i class="fas fa-chevron-down tp-trigger-arrow"></i>
                        </button>
                        <div class="tp-dropdown" id="tpDropdown">
                            <div class="tp-columns">
                                <div class="tp-col">
                                    <div class="tp-col-label">HOUR</div>
                                    <div class="tp-scroll" id="tpHourScroll">
                                        <button type="button" class="tp-cell" data-h="00">00</button>
                                        <button type="button" class="tp-cell" data-h="01">01</button>
                                        <button type="button" class="tp-cell" data-h="02">02</button>
                                        <button type="button" class="tp-cell" data-h="03">03</button>
                                        <button type="button" class="tp-cell" data-h="04">04</button>
                                        <button type="button" class="tp-cell" data-h="05">05</button>
                                        <button type="button" class="tp-cell" data-h="06">06</button>
                                        <button type="button" class="tp-cell" data-h="07">07</button>
                                        <button type="button" class="tp-cell" data-h="08">08</button>
                                        <button type="button" class="tp-cell" data-h="09">09</button>
                                        <button type="button" class="tp-cell" data-h="10">10</button>
                                        <button type="button" class="tp-cell" data-h="11">11</button>
                                        <button type="button" class="tp-cell" data-h="12">12</button>
                                        <button type="button" class="tp-cell" data-h="13">13</button>
                                        <button type="button" class="tp-cell" data-h="14">14</button>
                                        <button type="button" class="tp-cell" data-h="15">15</button>
                                        <button type="button" class="tp-cell" data-h="16">16</button>
                                        <button type="button" class="tp-cell" data-h="17">17</button>
                                        <button type="button" class="tp-cell" data-h="18">18</button>
                                        <button type="button" class="tp-cell" data-h="19">19</button>
                                        <button type="button" class="tp-cell" data-h="20">20</button>
                                        <button type="button" class="tp-cell" data-h="21">21</button>
                                        <button type="button" class="tp-cell" data-h="22">22</button>
                                        <button type="button" class="tp-cell" data-h="23">23</button>
                                    </div>
                                </div>
                                <div class="tp-divider"></div>
                                <div class="tp-col">
                                    <div class="tp-col-label">MIN</div>
                                    <div class="tp-scroll" id="tpMinScroll">
                                        <button type="button" class="tp-cell" data-m="00">00</button>
                                        <button type="button" class="tp-cell" data-m="05">05</button>
                                        <button type="button" class="tp-cell" data-m="10">10</button>
                                        <button type="button" class="tp-cell" data-m="15">15</button>
                                        <button type="button" class="tp-cell" data-m="20">20</button>
                                        <button type="button" class="tp-cell" data-m="25">25</button>
                                        <button type="button" class="tp-cell" data-m="30">30</button>
                                        <button type="button" class="tp-cell" data-m="35">35</button>
                                        <button type="button" class="tp-cell" data-m="40">40</button>
                                        <button type="button" class="tp-cell" data-m="45">45</button>
                                        <button type="button" class="tp-cell" data-m="50">50</button>
                                        <button type="button" class="tp-cell" data-m="55">55</button>
                                    </div>
                                </div>
                            </div>
                            <div class="tp-footer">
                                <button type="button" class="tp-now" id="tpNow"><i class="fas fa-bolt"></i> Now</button>
                                <button type="button" class="tp-ok" id="tpOk"><i class="fas fa-check"></i> OK</button>
                            </div>
                        </div>
                        <input type="hidden" name="time" id="timeHidden" value='<c:out value="${piijob.time}"/>'>
                    </div>
                </div>
                <div class="reg-field">
                    <label class="reg-label"><spring:message code="job.manual_approve" text="수동 승인 후 실행"/></label>
                    <div class="reg-toggle-wrap">
                        <label class="reg-toggle">
                            <input type="checkbox" id="confirmflag_checkbox"
                                   <c:if test="${piijob.confirmflag eq 'Y'}">checked</c:if>
                                   onchange="document.getElementById('confirmflag_hidden').value = this.checked ? 'Y' : 'N';">
                            <span class="reg-toggle-track">
                                <span class="reg-toggle-thumb"></span>
                            </span>
                            <span class="reg-toggle-label" id="confirmLabel">OFF</span>
                        </label>
                        <input type="hidden" name="confirmflag" id="confirmflag_hidden" value="<c:out value="${piijob.confirmflag}" default="N"/>">
                        <p class="reg-field-hint"><spring:message code="job.manual_approve_desc" text="활성화 시 자동 실행되지 않고, 담당자가 승인해야 실행됩니다"/></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section 4: Ownership -->
        <div class="reg-section reg-section-owner">
            <div class="reg-section-header">
                <i class="fas fa-users"></i> Ownership
            </div>
            <div class="reg-grid reg-grid-owner">
                <div class="reg-field">
                    <label class="reg-label">Owner 1 <span class="reg-required">*</span></label>
                    <div class="reg-owner-field">
                        <div class="reg-owner-display" id="job_owner_name1"><c:out value="${piijob.job_owner_name1}" default="Not assigned"/></div>
                        <button type="button" class="reg-owner-search" onclick="diologSearchMember(1)"><i class="fas fa-user-plus"></i></button>
                    </div>
                    <input type="hidden" name="job_owner_name1" value='<c:out value="${piijob.job_owner_name1}"/>'>
                    <input type="hidden" name="job_owner_id1" value='<c:out value="${piijob.job_owner_id1}"/>'>
                </div>
                <div class="reg-field">
                    <label class="reg-label">Owner 2</label>
                    <div class="reg-owner-field">
                        <div class="reg-owner-display" id="job_owner_name2"><c:out value="${piijob.job_owner_name2}" default="Not assigned"/></div>
                        <button type="button" class="reg-owner-search" onclick="diologSearchMember(2)"><i class="fas fa-user-plus"></i></button>
                    </div>
                    <input type="hidden" name="job_owner_name2" value='<c:out value="${piijob.job_owner_name2}"/>'>
                    <input type="hidden" name="job_owner_id2" value='<c:out value="${piijob.job_owner_id2}"/>'>
                </div>
                <div class="reg-field">
                    <label class="reg-label">Owner 3</label>
                    <div class="reg-owner-field">
                        <div class="reg-owner-display" id="job_owner_name3"><c:out value="${piijob.job_owner_name3}" default="Not assigned"/></div>
                        <button type="button" class="reg-owner-search" onclick="diologSearchMember(3)"><i class="fas fa-user-plus"></i></button>
                    </div>
                    <input type="hidden" name="job_owner_name3" value='<c:out value="${piijob.job_owner_name3}"/>'>
                    <input type="hidden" name="job_owner_id3" value='<c:out value="${piijob.job_owner_id3}"/>'>
                </div>
            </div>
        </div>

        <!-- Hidden fields -->
        <input type="hidden" name="version" value="1">
        <input type="hidden" name="status" value="ACTIVE">
        <input type="hidden" name="phase" value="CHECKOUT">
        <input type="hidden" name="cronval" value='<c:out value="${piijob.cronval}"/>'>
        <input type="hidden" name="enddate" value='<c:out value="${piijob.enddate}"/>'>
        <input type="hidden" name="regdate" value='<c:out value="${piijob.regdate}"/>'>
        <input type="hidden" name="upddate" value='<c:out value="${piijob.upddate}"/>'>
        <input type="hidden" name="reguserid" value='<sec:authentication property="principal.member.userid"/>'>
        <input type="hidden" name="upduserid" value='<sec:authentication property="principal.member.userid"/>'>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
    </form>

    <div id="register_result"></div>
</div>

<!-- The Modal -->
<div class="modal fade" id="diologsearchmemberlist" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.search_member" text="Search member"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body modal-body-custom" id="diologsearchmemberlistbody">
                <h6>Select job to wait!</h6>
                <textarea spellcheck="false" rows="3" class="form-control form-control-sm" name='reqreason'
                          id='reqreason'><c:out value="${piisteptable.wherestr}"/></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="diologsearchmemberlistclose"
                        data-dismiss="modal">Close
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Duplicate JOBID Notice Modal -->
<div class="modal fade" id="dupJobIdModal" role="dialog" aria-labelledby="dupJobIdTitle">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.18);">
            <div class="modal-header" style="background: linear-gradient(135deg, #ef4444, #dc2626); border: none; padding: 18px 24px;">
                <h5 class="modal-title" id="dupJobIdTitle" style="color: #fff; font-weight: 700; font-size: 1rem;">
                    <i class="fas fa-exclamation-circle" style="margin-right: 8px;"></i>JOBID 중복 안내
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.9; text-shadow: none;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 28px 24px; text-align: center;">
                <div style="width: 56px; height: 56px; margin: 0 auto 18px; background: #fef2f2; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-copy" style="font-size: 1.5rem; color: #ef4444;"></i>
                </div>
                <p style="margin: 0 0 8px; font-weight: 600; font-size: 0.95rem; color: #1e293b;">
                    이미 존재하는 JOBID 입니다.
                </p>
                <p style="margin: 0; color: #64748b; font-size: 0.85rem;">
                    <span style="display: inline-block; background: #f1f5f9; padding: 4px 14px; border-radius: 6px; font-family: monospace; font-weight: 600; color: #ef4444; font-size: 0.9rem;" id="dupJobIdValue"></span>
                </p>
                <p style="margin: 14px 0 0; color: #64748b; font-size: 0.82rem;">
                    다른 JOBID를 입력해 주세요.
                </p>
            </div>
            <div class="modal-footer" style="border: none; padding: 12px 24px 20px; justify-content: center;">
                <button type="button" class="btn" data-dismiss="modal" id="dupJobIdCloseBtn"
                        style="background: linear-gradient(135deg, #ef4444, #dc2626); color: #fff; border: none; border-radius: 8px; padding: 8px 32px; font-weight: 600; font-size: 0.82rem;">
                    확인
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Migration Notice Modal -->
<div class="modal fade" id="migrateNoticeModal" role="dialog" aria-labelledby="migrateNoticeTitle">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.18);">
            <div class="modal-header" style="background: linear-gradient(135deg, #f59e0b, #d97706); border: none; padding: 18px 24px;">
                <h5 class="modal-title" id="migrateNoticeTitle" style="color: #fff; font-weight: 700; font-size: 1rem;">
                    <i class="fas fa-exclamation-triangle" style="margin-right: 8px;"></i>데이터 이관 안내
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.9; text-shadow: none;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 28px 24px; font-size: 0.88rem; color: #334155; line-height: 1.8;">
                <p style="margin: 0 0 14px; font-weight: 600; color: #b45309;">
                    <i class="fas fa-info-circle" style="margin-right: 6px;"></i>이관 대상 테이블에 개인정보가 포함되어 있지 않아야 합니다.
                </p>
                <p style="margin: 0; color: #64748b;">
                    개인정보가 포함된 테이블은 <strong style="color: #0369a1;">테스트 데이터</strong> Job Type을 선택하여 처리해 주세요.
                </p>
            </div>
            <div class="modal-footer" style="border: none; padding: 12px 24px 20px; justify-content: center;">
                <button type="button" class="btn" data-dismiss="modal"
                        style="background: linear-gradient(135deg, #f59e0b, #d97706); color: #fff; border: none; border-radius: 8px; padding: 8px 32px; font-weight: 600; font-size: 0.82rem;">
                    확인
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.job" text="DB Connection"/>" + ">Register");

        // Toggle label sync
        var cb = document.getElementById('confirmflag_checkbox');
        var lbl = document.getElementById('confirmLabel');
        function syncLabel() { lbl.textContent = cb.checked ? 'ON' : 'OFF'; }
        syncLabel();
        cb.addEventListener('change', syncLabel);

        // Calendar Picker
        var calPicker = document.getElementById('calPicker');
        var calTrigger = document.getElementById('calTrigger');
        var calDropdown = document.getElementById('calDropdown');
        var calHidden = document.getElementById('calendarHidden');
        var calText = document.getElementById('calTriggerText');
        var calChips = calDropdown.querySelectorAll('.cal-chip');
        var calClear = document.getElementById('calClear');

        var calLabels = {
            'ALLDAYS':'<spring:message code="cal.alldays" text="매일"/>',
            'WEEKDAYS':'<spring:message code="cal.weekdays" text="평일 (월~금)"/>',
            'WEEKEND':'<spring:message code="cal.weekend" text="주말 (토~일)"/>',
            'WEEK_MON':'<spring:message code="cal.mon" text="월"/>','WEEK_TUE':'<spring:message code="cal.tue" text="화"/>',
            'WEEK_WED':'<spring:message code="cal.wed" text="수"/>','WEEK_THU':'<spring:message code="cal.thu" text="목"/>',
            'WEEK_FRI':'<spring:message code="cal.fri" text="금"/>','WEEK_SAT':'<spring:message code="cal.sat" text="토"/>',
            'WEEK_SUN':'<spring:message code="cal.sun" text="일"/>',
            '2ND_SAT':'<spring:message code="cal.2nd_sat" text="격주 토요일"/>',
            '2ND_SUN':'<spring:message code="cal.2nd_sun" text="격주 일요일"/>'
        };

        function calSelect(val) {
            calHidden.value = val;
            calChips.forEach(function(c) { c.classList.remove('active'); });
            if (val) {
                calText.textContent = calLabels[val] || val;
                calText.classList.add('has-value');
                calDropdown.querySelector('[data-val="'+val+'"]').classList.add('active');
            } else {
                calText.textContent = '<spring:message code="cal.select" text="스케줄 선택"/>';
                calText.classList.remove('has-value');
            }
        }

        // Init from server value
        if (calHidden.value) calSelect(calHidden.value);

        calTrigger.addEventListener('click', function(e) {
            e.stopPropagation();
            calPicker.classList.toggle('open');
        });

        calChips.forEach(function(chip) {
            chip.addEventListener('click', function(e) {
                e.stopPropagation();
                calSelect(this.getAttribute('data-val'));
                calPicker.classList.remove('open');
            });
        });

        calClear.addEventListener('click', function(e) {
            e.stopPropagation();
            calSelect('');
            calPicker.classList.remove('open');
        });

        // Time Picker
        var tpPicker = document.getElementById('tpPicker');
        var tpTrigger = document.getElementById('tpTrigger');
        var tpDropdown = document.getElementById('tpDropdown');
        var tpHidden = document.getElementById('timeHidden');
        var tpText = document.getElementById('tpTriggerText');
        var tpHourScroll = document.getElementById('tpHourScroll');
        var tpMinScroll = document.getElementById('tpMinScroll');
        var tpSelH = '00', tpSelM = '00';

        function tpUpdate() {
            var val = tpSelH + ':' + tpSelM;
            tpHidden.value = val;
            tpText.textContent = tpSelH + ' : ' + tpSelM;
            tpText.classList.add('has-value');
            tpHourScroll.querySelectorAll('.tp-cell').forEach(function(c) {
                c.classList.toggle('active', c.getAttribute('data-h') === tpSelH);
            });
            tpMinScroll.querySelectorAll('.tp-cell').forEach(function(c) {
                c.classList.toggle('active', c.getAttribute('data-m') === tpSelM);
            });
        }

        function tpScrollTo(container, btn) {
            if (btn) container.scrollTop = btn.offsetTop - container.offsetTop - 40;
        }

        // Init from server value
        if (tpHidden.value) {
            var parts = tpHidden.value.split(':');
            if (parts.length >= 2) { tpSelH = parts[0]; tpSelM = parts[1]; tpUpdate(); }
        }

        tpTrigger.addEventListener('click', function(e) {
            e.stopPropagation();
            tpPicker.classList.toggle('open');
            if (tpPicker.classList.contains('open')) {
                // Position the fixed dropdown below the trigger
                var rect = tpTrigger.getBoundingClientRect();
                tpDropdown.style.top = (rect.bottom + 8) + 'px';
                tpDropdown.style.left = rect.left + 'px';
                setTimeout(function() {
                    tpScrollTo(tpHourScroll, tpHourScroll.querySelector('.active'));
                    tpScrollTo(tpMinScroll, tpMinScroll.querySelector('.active'));
                }, 50);
            }
        });

        tpHourScroll.querySelectorAll('.tp-cell').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                tpSelH = this.getAttribute('data-h');
                tpUpdate();
            });
        });

        tpMinScroll.querySelectorAll('.tp-cell').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                tpSelM = this.getAttribute('data-m');
                tpUpdate();
            });
        });

        document.getElementById('tpNow').addEventListener('click', function(e) {
            e.stopPropagation();
            var now = new Date();
            tpSelH = String(now.getHours()).padStart(2,'0');
            tpSelM = String(Math.round(now.getMinutes()/5)*5 % 60).padStart(2,'0');
            tpUpdate();
            tpScrollTo(tpHourScroll, tpHourScroll.querySelector('.active'));
            tpScrollTo(tpMinScroll, tpMinScroll.querySelector('.active'));
        });

        document.getElementById('tpOk').addEventListener('click', function(e) {
            e.stopPropagation();
            tpPicker.classList.remove('open');
        });

        // Close all pickers on outside click
        document.addEventListener('click', function(e) {
            if (!calPicker.contains(e.target)) calPicker.classList.remove('open');
            if (!tpPicker.contains(e.target)) tpPicker.classList.remove('open');
        });

        // Close time picker on scroll
        document.querySelector('.reg-page').addEventListener('scroll', function() {
            if (tpPicker.classList.contains('open')) {
                tpPicker.classList.remove('open');
            }
        });
    });

    $(document).ready(function () {

        // MIGRATE 선택 시 안내 모달
        $('#piijob_register_form [name="jobtype"]').on('change', function () {
            if ($(this).val() === 'MIGRATE') {
                $('#migrateNoticeModal').modal('show');
            }
        });

        // Run Type 변경 시 Calendar/시각 필드 표시 토글
        function toggleScheduleFields() {
            var runtype = $('#runtypeSelect').val();
            if (runtype === 'REGULAR') {
                $('#scheduleCalendarField').show();
                $('#scheduleTimeField').show();
            } else {
                $('#scheduleCalendarField').hide();
                $('#scheduleTimeField').hide();
                // 비정기 선택 시 값 초기화
                $('#calendarHidden').val('');
                $('#calTriggerText').text('<spring:message code="cal.select" text="스케줄 선택"/>');
                $('.cal-chip').removeClass('cal-chip-active');
                $('#timeHidden').val('');
                $('#tpTriggerText').text('<spring:message code="cal.select" text="시간 선택"/>');
            }
        }
        $('#runtypeSelect').on('change', toggleScheduleFields);
        toggleScheduleFields();

        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var jobtype = $('#piijob_register_form [name="jobtype"]').val();
            var runtype = $('#piijob_register_form [name="runtype"]').val();
            var jobid = $('#piijob_register_form [name="jobid"]').val();
            if (isEmpty(jobid)) {
                alert('<spring:message code="col.jobid" text="JOBID"/> is mandatory');
                $('#piijob_register_form [name="jobid"]').focus();
                return;
            }
            // JOBID 중복 체크
            var isDup = false;
            $.ajax({
                type: "GET",
                url: "/piijob/checkJobId",
                data: { jobid: jobid.toUpperCase() },
                async: false,
                success: function (data) { isDup = data; }
            });
            if (isDup) {
                $('#dupJobIdValue').text(jobid.toUpperCase());
                $('#dupJobIdModal').modal('show');
                $('#dupJobIdModal').on('hidden.bs.modal', function () {
                    $('#piijob_register_form [name="jobid"]').focus().select();
                    $(this).off('hidden.bs.modal');
                });
                return;
            }
            if (isEmpty($('#piijob_register_form [name="jobname"]').val())) {
                alert('<spring:message code="col.jobname" text="Jobname"/> is mandatory');
                $('#piijob_register_form [name="jobname"]').focus();
                return;
            }

            var system = $('#piijob_register_form [name="system"]').val();

            if (jobtype == "PII" && isEmpty(system)) {
                alert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_register_form [name="system"]').focus();
                return;
            }
            if (jobtype == "TDM" && isEmpty($('#piijob_register_form [name="system"]').val())) {
                alert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_register_form [name="system"]').focus();
                return;
            }
            if (jobtype == "ILM" && isEmpty($('#piijob_register_form [name="system"]').val())) {
                alert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_register_form [name="system"]').focus();
                return;
            }
            if (jobtype == "MIGRATE" && isEmpty(system)) {
                alert('<spring:message code="col.system" text="System"/> is mandatory');
                $('#piijob_register_form [name="system"]').focus();
                return;
            }
            if (jobtype == "PII" && isEmpty($('#piijob_register_form [name="policy_id"]').val())) {
                alert('<spring:message code="col.policy_id" text="Policy_Id"/> is mandatory');
                $('#piijob_register_form [name="policy_id"]').focus();
                return;
            }
            if (jobtype == "PII" && isEmpty($('#piijob_register_form [name="keymap_id"]').val())) {
                alert('<spring:message code="col.keymap_id" text="Keymap_Id"/> is mandatory');
                $('#piijob_register_form [name="keymap_id"]').focus();
                return;
            }
            if (isEmpty($('#piijob_register_form [name="jobtype"]').val())) {
                alert('<spring:message code="col.jobtype" text="Jobtype"/> is mandatory');
                $('#piijob_register_form [name="jobtype"]').focus();
                return;
            }
            if (jobtype != "SCRAMBLE" && jobtype != "ILM" && jobtype != "MIG" ) {
                if (isEmpty($('#piijob_register_form [name="runtype"]').val())) {
                    alert('<spring:message code="col.runtype" text="Runtype"/> is mandatory');
                    $('#piijob_register_form [name="runtype"]').focus();
                    return;
                }

                if (runtype != "IRREGULAR" && isEmpty($('#piijob_register_form [name="calendar"]').val())) {
                    alert('<spring:message code="col.calendar" text="Calendar"/> is mandatory');
                    $('#piijob_register_form [name="calendar"]').focus();
                    return;
                }
                if (runtype != "IRREGULAR" && isEmpty($('#piijob_register_form [name="calendar"]').val())) {
                    alert('<spring:message code="col.calendar" text="Calendar"/> is mandatory');
                    $('#piijob_register_form [name="calendar"]').focus();
                    return;
                }
                if (!isEmpty($('#piijob_register_form [name="calendar"]').val()) && isEmpty($('#piijob_register_form [name="time"]').val())) {
                    alert('<spring:message code="col.time" text="Time"/> is mandatory');
                    $('#piijob_register_form [name="time"]').focus();
                    return;
                }
            }
            if (isEmpty($('#piijob_register_form [name="job_owner_id1"]').val())) {
                alert('<spring:message code="col.job_owner_id1" text="Job_Owner_Id1"/> is mandatory');
                $('#piijob_register_form [name="job_owner_id1"]').focus();
                return;
            }
            if (isEmpty($('#piijob_register_form [name="job_owner_name1"]').val())) {
                alert('<spring:message code="col.job_owner_name1" text="Job_Owner_Name1"/> is mandatory');
                $('#piijob_register_form [name="job_owner_name1"]').focus();
                return;
            }

            var elementForm = $("#piijob_register_form");
            var elementResult = $("#content_home");
            $('#piijob_register_form [name="jobid"]').val($('#piijob_register_form [name="jobid"]').val().toUpperCase())
            $('#piijob_register_form [name="jobname"]').val($('#piijob_register_form [name="jobname"]').val().toUpperCase())
            $('#piijob_register_form [name="keymap_id"]').val($('#piijob_register_form [name="keymap_id"]').val().toUpperCase())
            ingShow(); $.ajax({
                type: "POST",
                url: "/piijob/register",
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
            $('#content_home').load("/piijob/list");
        });

        diologSearchMember = function (no) {
            var pagenum = 1;
            var amount = 100;
            var url_view = "";
            var url_search = "";
            var search2 = "";
            var search3 = no;
            var search4 = "register";

            url_view = "diologsearchmember?";
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2;
            }
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3;
            }
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4;
            }

            ingShow(); $.ajax({
                type: "GET",
                url: "/piimember/" + url_view
                    + "pagenum=" + pagenum
                    + "&amount=" + amount
                    + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    $('#diologsearchmemberlistbody').html(data);
                    $("#diologsearchmemberlist").modal();
                }
            });
        }

    });
</script>
