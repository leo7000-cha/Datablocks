<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/jquery-ui-themes-1.12.1/themes/base/jquery-ui.css">
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>


<div class="job-detail-container" style="height:100%;display:flex;flex-direction:column;">
    <!-- Compact Toolbar -->
    <div class="job-detail-toolbar">
        <div class="job-detail-toolbar-left">
            <sec:authentication property="principal.member.userid" var="userid"/>
            <!-- 수정 페이지 이동 버튼 (왼쪽 배치) -->
            <sec:authorize access="hasAnyRole('ROLE_IT')">
                <c:if test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                    <c:if test="${piijob.phase eq 'CHECKOUT' }">
                        <button data-oper='modifyjoballinfo' class="btn-tool btn-modify"><i class="fa-solid fa-pen"></i> <spring:message code="btn.modify" text="Modify"/></button>
                    </c:if>
                </c:if>
            </sec:authorize>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <c:if test="${piijob.phase eq 'CHECKOUT' }">
                    <button data-oper='modifyjoballinfo' class="btn-tool btn-modify"><i class="fa-solid fa-pen"></i> <spring:message code="memu.movetomodify" text="Modify"/></button>
                </c:if>
            </sec:authorize>
            <!-- Order 버튼 -->
            <c:choose>
                <c:when test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                    <c:if test="${piijob.phase eq 'CHECKIN' && piijob.status eq 'ACTIVE'}">
                        <button data-oper="order" class="btn-order"><i class="fa-solid fa-play"></i> Order</button>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <sec:authorize access="hasRole('ROLE_ADMIN')">
                        <c:if test="${piijob.phase eq 'CHECKIN' && piijob.status eq 'ACTIVE'}">
                            <button data-oper="order" class="btn-order"><i class="fa-solid fa-play"></i> Order</button>
                        </c:if>
                    </sec:authorize>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="job-detail-toolbar-right">
            <sec:authorize access="hasAnyRole('ROLE_IT')">
                <c:if test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                    <c:if test="${piijob.phase eq 'CHECKIN' && piijob.version eq maxversion }">
                        <button data-oper='checkout' class="btn-tool btn-checkout"><i class="fa-solid fa-lock-open"></i> CheckOut</button>
                    </c:if>
                </c:if>
            </sec:authorize>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <c:if test="${piijob.phase eq 'CHECKIN' && piijob.version eq maxversion }">
                    <button data-oper='checkout' class="btn-tool btn-checkout"><i class="fa-solid fa-lock-open"></i> CheckOut</button>
                </c:if>
            </sec:authorize>
            <button data-oper='jobgetlist' class="btn-tool"><i class="fa-solid fa-list"></i> List</button>
            <button data-oper='jobcopy' class="btn-tool btn-wizard"><i class="fa-solid fa-copy"></i> Create/Copy</button>
        </div>
    </div>

    <!-- Job Info Section - Compact -->
    <div id="jobdetail" class="job-info-card">
        <%@include file="getjob.jsp" %>
    </div>

    <!-- Step Container -->
    <div id="steps" class="step-container1" style="overflow:hidden;width:100%;flex:1;">
        <div id="steptabdiv" class="step-list-sidebar">
            <div class="step-list-header">
                <div class="step-list-title">
                    <i class="fa-solid fa-cubes"></i> STEPS
                </div>
            </div>
            <div class="step-list-body">
                <ul id="steptab">
                    <c:forEach items="${liststep}" var="piistep" varStatus="loop">
                        <c:if test="${piistep.status ne 'INACTIVE' }">
                            <c:choose>
                                <c:when test="${piistep.status eq 'HOLD' }">
                                    <li class="list-group-item list-group-item-action list-group-item-warning" id="${piistep.stepid}">
                                </c:when>
                                <c:when test="${piistep.status eq 'ACTIVE' }">
                                    <li class="list-group-item list-group-item-action list-group-item-primary" id="${piistep.stepid}">
                                </c:when>
                                <c:otherwise>
                                    <li class="list-group-item list-group-item-action list-group-item-secondary" id="${piistep.stepid}">
                                </c:otherwise>
                            </c:choose>
                            <div class="step-item-id">${piistep.stepseq}. ${piistep.stepid}</div>
                            <c:choose>
                                <c:when test="${piistep.status eq 'ACTIVE'}">
                                    <span class="step-item-status status-active">${piistep.status}</span>
                                </c:when>
                                <c:when test="${piistep.status eq 'HOLD'}">
                                    <span class="step-item-status status-hold">${piistep.status}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="step-item-status status-inactive">${piistep.status}</span>
                                </c:otherwise>
                            </c:choose>
                            </li>
                        </c:if>
                    </c:forEach>
                </ul>
            </div>
        </div>
        <div class="step-detail-area">
            <div id="jobstepdetail"></div>
        </div>
    </div>


</div>
<!-- <div class="card shadow"> DataTales begin-->

<!-- The Modal end-->
<!-- JOB Order Modal - Modern Style -->
<style>
@keyframes order-btn-pulse {
    0%, 100% { box-shadow: 0 4px 15px rgba(99, 102, 241, 0.4); }
    50% { box-shadow: 0 4px 25px rgba(99, 102, 241, 0.6), 0 0 0 4px rgba(99, 102, 241, 0.1); }
}
@keyframes order-btn-shine {
    0% { left: -100%; }
    100% { left: 100%; }
}
.order-btn-animated {
    position: relative;
    overflow: hidden;
    background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%);
    animation: order-btn-pulse 2s ease-in-out infinite;
}
.order-btn-animated:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 25px rgba(99, 102, 241, 0.5);
}
.order-btn-animated:active {
    transform: translateY(0);
}
.order-btn-animated::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
    animation: order-btn-shine 3s ease-in-out infinite;
}
.order-btn-animated i {
    animation: none;
}
/* Order 모달 날짜 입력 스타일 */
.order-date-input {
    border: 2px solid #e0e7ff !important;
    border-radius: 12px !important;
    padding: 16px 20px !important;
    font-size: 1.25rem !important;
    font-weight: 700 !important;
    text-align: center !important;
    background: #fff !important;
    width: 180px !important;
    color: #4f46e5 !important;
    letter-spacing: 2px !important;
    box-shadow: 0 4px 12px rgba(79, 70, 229, 0.1) !important;
    transition: all 0.2s ease !important;
    height: auto !important;
}
.order-date-input:focus {
    border-color: #6366f1 !important;
    box-shadow: 0 4px 16px rgba(99, 102, 241, 0.25) !important;
    outline: none !important;
}
</style>
<div class="modal fade" id="requestmodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 420px;">
        <div class="modal-content" style="border: none; border-radius: 20px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
            <!-- Modal Header -->
            <div class="modal-header" style="background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #6366f1 100%); padding: 20px 24px; border: none;">
                <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.15rem; display: flex; align-items: center;">
                    <div style="width: 40px; height: 40px; background: rgba(255,255,255,0.2); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin-right: 14px; backdrop-filter: blur(10px);">
                        <i class="fa-solid fa-rocket" style="font-size: 18px;"></i>
                    </div>
                    JOB Order
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none; font-size: 1.5rem;">
                    <span>&times;</span>
                </button>
            </div>

            <!-- Modal body -->
            <div class="modal-body" id="ordermodalbody" style="padding: 28px 24px; background: linear-gradient(180deg, #f8fafc 0%, #fff 100%);">
                <div style="margin-bottom: 20px; display: flex; flex-direction: column; align-items: center;">
                    <label style="display: block; font-weight: 600; color: #374151; margin-bottom: 16px; font-size: 0.9rem; text-align: center;">
                        <i class="fa-regular fa-calendar" style="color: #6366f1; margin-right: 8px;"></i>
                        <spring:message code="msg.enterbasedatetoorder" text="Order 기준일을 입력하세요"/>
                    </label>
                    <input type="text" id="datePicker" class="form-control" placeholder="YYYY/MM/DD" maxlength='10'
                           style="border: 2px solid #e0e7ff; border-radius: 12px; padding: 16px 20px; font-size: 1.25rem; font-weight: 700; text-align: center; background: #fff; width: 180px; color: #4f46e5; letter-spacing: 2px; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.1); transition: all 0.2s ease;"
                           onfocus="this.style.borderColor='#6366f1'; this.style.boxShadow='0 4px 16px rgba(99, 102, 241, 0.25)';"
                           onblur="this.style.borderColor='#e0e7ff'; this.style.boxShadow='0 4px 12px rgba(79, 70, 229, 0.1)';" autocomplete="off">
                </div>
                <div id="orderresult" style="min-height: 24px; font-size: 0.85rem; color: #6b7280; text-align: center;"></div>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer" style="border-top: 1px solid #e5e7eb; padding: 16px 24px; background: #fff; display: flex; gap: 12px;">
                <button onclick="javascript:$('#requestmodal').modal('hide');"
                        style="flex: 1; background: #f1f5f9; color: #64748b; border: none; padding: 14px 20px; border-radius: 12px; font-weight: 600; font-size: 0.95rem; transition: all 0.2s ease; cursor: pointer;"
                        onmouseover="this.style.background='#e2e8f0';" onmouseout="this.style.background='#f1f5f9';">
                    <spring:message code="btn.cancel" text="Cancel"/>
                </button>
                <button data-oper='requestorder' class="order-btn-animated"
                        style="flex: 1; color: #fff; border: none; padding: 14px 20px; border-radius: 12px; font-weight: 600; font-size: 0.95rem; transition: all 0.2s ease; cursor: pointer;">
                    <i class="fa-solid fa-paper-plane" style="margin-right: 8px;"></i> Order
                </button>
            </div>
        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- JOB Create/Copy Modal - Modern Style -->
<div class="modal fade" id="copymodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 520px;">
        <div class="modal-content" style="border: none; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
            <!-- Modal Header -->
            <div class="modal-header" style="background: linear-gradient(135deg, #3b82f6 0%, #60a5fa 100%); padding: 18px 24px; border: none;">
                <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem; display: flex; align-items: center;">
                    <div style="width: 36px; height: 36px; background: rgba(255,255,255,0.2); border-radius: 10px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                        <i class="fa-solid fa-copy" style="font-size: 14px;"></i>
                    </div>
                    JOB Create/Copy
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none; font-size: 1.5rem;">
                    <span>&times;</span>
                </button>
            </div>

            <!-- Modal body -->
            <div class="modal-body" id="requestmodalbody" style="padding: 24px; background: #f8fafc;">
                <div id="copyInfoBox" style="margin-bottom: 20px; padding: 14px 16px; background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); border-radius: 10px; border-left: 4px solid #3b82f6;">
                    <div style="display: flex; align-items: center; margin-bottom: 8px;">
                        <i class="fa-solid fa-info-circle" style="color: #3b82f6; margin-right: 10px; font-size: 1.1rem;"></i>
                        <span id="copyInfoTitle" style="color: #1e40af; font-weight: 600; font-size: 0.9rem;"></span>
                    </div>
                    <div id="copyInfoDesc" style="color: #475569; font-size: 0.8rem; line-height: 1.5; padding-left: 26px;"></div>
                </div>
                <!-- Hidden message holders -->
                <input type="hidden" id="msg_copy_title" value="<spring:message code='msg.jobcopy.title' text='현재 Job을 복사하여 새로운 Job을 생성합니다.'/>">
                <input type="hidden" id="msg_copy_desc" value="<spring:message code='msg.jobcopy.desc' text='복사된 Job은 CHECKOUT 상태로 생성되며, Step/Table 정보가 함께 복사됩니다.'/>">
                <input type="hidden" id="msg_backdated_title" value="<spring:message code='msg.jobbackdated.title' text='소급 파기 Job을 생성합니다.'/>">
                <input type="hidden" id="msg_backdated_desc" value="<spring:message code='msg.jobbackdated.desc' text='과거 특정 시점의 파기 대상을 소급하여 처리하는 Job입니다. 기준일자를 과거로 지정하여 Order합니다.'/>">
                <input type="hidden" id="msg_recovery_title" value="<spring:message code='msg.jobrecovery.title' text='복구 Job을 생성합니다.'/>">
                <input type="hidden" id="msg_recovery_desc" value="<spring:message code='msg.jobrecovery.desc' text='분리보관된 데이터를 원본 테이블로 복구하는 Job입니다. 복구 대상 고객을 지정하여 실행합니다.'/>">

                <!-- New JOBID -->
                <div style="margin-bottom: 16px;">
                    <label style="display: block; font-weight: 600; color: #374151; margin-bottom: 8px; font-size: 0.85rem;">
                        <i class="fa-solid fa-fingerprint" style="color: #3b82f6; margin-right: 6px;"></i> New JOBID
                    </label>
                    <input type="text" class="form-control" id='jobid_copy' value='<c:out value="${piijob.jobid}"/>_'
                           style="border: 2px solid #e5e7eb; border-radius: 8px; padding: 10px 14px; font-size: 0.9rem; transition: all 0.2s ease;">
                </div>

                <!-- New JOBNAME -->
                <div style="margin-bottom: 16px;">
                    <label style="display: block; font-weight: 600; color: #374151; margin-bottom: 8px; font-size: 0.85rem;">
                        <i class="fa-solid fa-tag" style="color: #3b82f6; margin-right: 6px;"></i> New JOBNAME
                    </label>
                    <input type="text" class="form-control" id='jobname_copy' value='<c:out value="${piijob.jobname}"/>_'
                           style="border: 2px solid #e5e7eb; border-radius: 8px; padding: 10px 14px; font-size: 0.9rem; transition: all 0.2s ease;">
                </div>

                <!-- Creation type -->
                <div>
                    <label style="display: block; font-weight: 600; color: #374151; margin-bottom: 12px; font-size: 0.85rem;">
                        <i class="fa-solid fa-list-check" style="color: #3b82f6; margin-right: 6px;"></i> Creation type
                    </label>
                    <div style="display: flex; flex-wrap: wrap; gap: 10px;">
                        <label class="creation-type-card" style="flex: 1; min-width: 120px; display: flex; align-items: center; padding: 12px 14px; background: #fff; border: 2px solid #e5e7eb; border-radius: 10px; cursor: pointer; transition: all 0.2s ease;">
                            <input type="radio" name="radiocopy" id="radiocopy-1" value="COPY" style="display: none;">
                            <span class="radio-custom" style="width: 18px; height: 18px; border: 2px solid #d1d5db; border-radius: 50%; margin-right: 10px; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease; flex-shrink: 0;"></span>
                            <span style="font-weight: 500; color: #374151; font-size: 0.85rem;"><spring:message code="etc.job_copy" text="Copy JOB"/></span>
                        </label>
                        <c:if test="${fn:startsWith(piijob.jobid, 'PII_POLICY')}">
                            <label class="creation-type-card" style="flex: 1; min-width: 120px; display: flex; align-items: center; padding: 12px 14px; background: #fff; border: 2px solid #e5e7eb; border-radius: 10px; cursor: pointer; transition: all 0.2s ease;">
                                <input type="radio" name="radiocopy" id="radiocopy-2" value="BACKDATED" checked style="display: none;">
                                <span class="radio-custom" style="width: 18px; height: 18px; border: 2px solid #d1d5db; border-radius: 50%; margin-right: 10px; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease; flex-shrink: 0;"></span>
                                <span style="font-weight: 500; color: #374151; font-size: 0.85rem;"><spring:message code="etc.backdated" text="Backdated"/> JOB</span>
                            </label>
                            <label class="creation-type-card" style="flex: 1; min-width: 120px; display: flex; align-items: center; padding: 12px 14px; background: #fff; border: 2px solid #e5e7eb; border-radius: 10px; cursor: pointer; transition: all 0.2s ease;">
                                <input type="radio" name="radiocopy" id="radiocopy-3" value="RECOVERY" style="display: none;">
                                <span class="radio-custom" style="width: 18px; height: 18px; border: 2px solid #d1d5db; border-radius: 50%; margin-right: 10px; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease; flex-shrink: 0;"></span>
                                <span style="font-weight: 500; color: #374151; font-size: 0.85rem;"><spring:message code="etc.recovery" text="Recovery"/> JOB</span>
                            </label>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer" style="border-top: 1px solid #e5e7eb; padding: 16px 24px; background: #fff; display: flex; gap: 10px;">
                <button data-dismiss="modal"
                        style="flex: 1; background: #f1f5f9; color: #64748b; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 600; transition: all 0.2s ease;">
                    <i class="fa-solid fa-times" style="margin-right: 6px;"></i> Cancel
                </button>
                <button data-oper='requestcopy'
                        style="flex: 1; background: linear-gradient(135deg, #3b82f6, #60a5fa); color: #fff; border: none; padding: 12px 20px; border-radius: 10px; font-weight: 600; box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3); transition: all 0.2s ease;">
                    <i class="fa-solid fa-plus" style="margin-right: 6px;"></i> Create
                </button>
            </div>
        </div>
    </div>
</div>
<style>
.creation-type-card:hover { border-color: #93c5fd; background: #f0f9ff; }
.creation-type-card:has(input:checked) { border-color: #3b82f6; background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); }
.creation-type-card:has(input:checked) .radio-custom { border-color: #3b82f6; background: #3b82f6; }
.creation-type-card:has(input:checked) .radio-custom::after { content: ''; width: 8px; height: 8px; background: #fff; border-radius: 50%; }
.creation-type-card .radio-custom { display: flex; align-items: center; justify-content: center; }
</style>
<!-- The Modal end-->

<!-- STEP Modify Modal -->
<div class="modal fade" id="stepmodal" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">
                    <i class="fa-solid fa-pen-to-square mr-2"></i> STEP 수정
                </h4>
                <button type="button" class="close text-white ml-auto" data-dismiss="modal" aria-label="Close" style="font-size: 1.5rem;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body modal-body-custom bg-light" id="stepmodalbody">
            </div>
            <div class="modal-footer">
                <button onclick="javascript:$('#stepmodal').modal('hide');" class="btn-footer-secondary">Close</button>
            </div>
        </div>
    </div>
</div>
<!-- STEP Modal end-->

<form style="margin: 0; padding: 0;" role="form" id=searchForm>
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
<input type='hidden' id='jobget_global_jobid' name='jobget_global_jobid' value='<c:out value="${piijob.jobid}"/>'>
<input type='hidden' id='jobget_global_version' name='jobget_global_version' value='<c:out value="${piijob.version}"/>'>
<input type='hidden' id='jobget_global_stepid' name='jobget_global_stepid' value='0'>
<input type='hidden' id='jobget_global_phase' name='jobget_global_phase' value='<c:out value="${piijob.phase}"/>'>

<script type="text/javascript">
    var doubleSubmitFlag = false;
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.job" text="Job"/>" + ">Details")
        var selectedStepid = "";

        // ADMIN 전용: Phase 더블클릭 토글
        $(document).off('dblclick.phaseToggle').on('dblclick.phaseToggle', '#phaseToggle', function() {
            var $el = $(this);
            if ($el.data('processing')) return;
            $el.data('processing', true);
            var jobid = $('#jobget_global_jobid').val();
            var version = $('#jobget_global_version').val();
            var current = $el.text().trim();
            var next = (current === 'CHECKIN') ? 'CHECKOUT' : 'CHECKIN';
            showConfirm('Phase를 ' + current + ' → ' + next + ' 로 변경하시겠습니까?', function() {
                $.ajax({
                    url: '/piijob/api/force-toggle-phase',
                    type: 'POST', contentType: 'application/json',
                    beforeSend: function(xhr) { xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}"); },
                    data: JSON.stringify({ jobid: jobid, version: version }),
                    success: function(res) {
                        if (res.success) {
                            searchJobAction(null, 'get?jobid=' + jobid + '&version=' + version + '&');
                        } else {
                            dlmAlert('변경 실패: ' + (res.message || ''));
                        }
                    },
                    complete: function() { $el.data('processing', false); }
                });
            }, function() {
                $el.data('processing', false);
            });
        });
    });

    $(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        var stepid = '<c:out value="${firststepid}"/>';
        $("#" + stepid).trigger("click");

    });

    flatpickr("#datePicker", {
        locale: "ko",
        dateFormat: "Y/m/d",
        defaultDate: "today",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        altInputClass: "order-date-input",  // 커스텀 스타일 클래스
        onChange: function(selectedDates, dateStr, instance) {
            var resultBox = document.getElementById("orderresult");
            if (resultBox) {
                resultBox.innerHTML = "";
            }
        }
    });

    // STEP 수정 버튼 클릭 핸들러
    $(".step-edit-btn").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();

        var jobid = $('#jobget_global_jobid').val();
        var version = $('#jobget_global_version').val();
        var stepid = '';

        var url_view = "modifydialog?jobid=" + jobid + "&version=" + version + "&stepid=" + stepid + "&";

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piistep/" + url_view + "pagenum=1&amount=100",
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#stepmodalbody').html(data);
                $("#stepmodal").modal();
            }
        });
    });

    // Step 관리 모달에서 순서 변경 / 저장 / 삭제가 발생했을 때 호출됨 → MOTHER의 STEP LIST 갱신
    window.onStepMgmtClosed = function (jobid, version) {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piijob/get?jobid=" + encodeURIComponent(jobid) + "&version=" + encodeURIComponent(version),
            dataType: "html",
            error: function (request) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#content_home').html(data);
            }
        });
    };
</script>

<script type="text/javascript">

    $("#steptab li").click(function (e) {
        e.preventDefault();e.stopPropagation();
        $("#steptab li").each(function () {
            //$(this).attr('class','list-group-item');
            //$( this ).toggleClass( "active" );
            $(this).removeClass("active");
        });
        $(this).addClass("active");
        //$(this).attr('class','list-group-item');
        //alert($( this ).text()+"tabcontent");
        $(".tab-body").each(function () {
            //$(this).css("display", "none");
            //alert($( this ).text())
            $(this).attr('class', 'tab-body-none');
        });

        $('#jobget_global_stepid').val($(this).attr("id"));

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = 100000;//$('#searchForm [name="amount"]').val();
        var search1 = $('#jobget_global_jobid').val();
        var search2 = $('#jobget_global_version').val();
        var search3 = $('#jobget_global_stepid').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#searchForm [name="search5"]').val();
        var search6 = $('#searchForm [name="search6"]').val();
        var search7 = $('#searchForm [name="search7"]').val();
        var search8 = $('#searchForm [name="search8"]').val();

        var url_search = "";
        var url_view = "getstepallinfo?"
            + "jobid=" + search1 + "&"
            + "version=" + search2 + "&"
            + "stepid=" + search3 + "&"
        ;
        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }
        //alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
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
            success: function (data) { ingHide();
                $('#jobstepdetail').html(data);
                //$("#step_md_register").trigger("click");

            }
        });

    });
    $("button[data-oper='modifyjoballinfo']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }

        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;
        var search1 = ($('#searchForm [name="search1"]').val() || '').toUpperCase();
        var search2 = ($('#searchForm [name="search2"]').val() || '').toUpperCase();
        var search3 = $('#searchForm [name="search3"]').val() || '';
        var search4 = $('#searchForm [name="search4"]').val() || '';
        var search5 = $('#searchForm [name="search5"]').val() || '';
        var search6 = $('#searchForm [name="search6"]').val() || '';
        var search7 = $('#searchForm [name="search7"]').val() || '';
        var search8 = $('#searchForm [name="search8"]').val() || '';
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }

        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        url_view = "modifyjoballinfo?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&";//+ "stepid=" + serchkeyno3

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
                $('#content_home').html(data);

            }
        });

    });


    $("button[data-oper='order']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;
        $("#requestmodal").modal();


    });
    // 복사 타입에 따른 안내 메시지 업데이트
    function updateCopyInfo(copytype) {
        var title = "", desc = "";
        if (copytype == "COPY") {
            title = $("#msg_copy_title").val();
            desc = $("#msg_copy_desc").val();
        } else if (copytype == "BACKDATED") {
            title = $("#msg_backdated_title").val();
            desc = $("#msg_backdated_desc").val();
        } else if (copytype == "RECOVERY") {
            title = $("#msg_recovery_title").val();
            desc = $("#msg_recovery_desc").val();
        }
        $("#copyInfoTitle").text(title);
        $("#copyInfoDesc").text(desc);
    }

    $("button[data-oper='jobcopy']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;
        $("input:radio[id='radiocopy-1']").prop('checked', true);
        $("#jobid_copy").val('<c:out value="${piijob.jobid}"/>_' + getToday());
        $("#jobname_copy").val('<c:out value="${piijob.jobname}"/>_' + getToday());
        updateCopyInfo("COPY");
        $("#copymodal").modal();
        $('#jobid_copy').focus();
    });

    $("input[name='radiocopy']:radio").change(function () {
        var copytype = this.value;
        var id = "";
        var name = "";

        if(copytype == "BACKDATED"){
            id = "RETRO"+"_";
            name = "<spring:message code="etc.backdated" text="Retroactive Purging"/>"+"_";
        }
        else if(copytype == "RECOVERY"){
            id = "RECOVER"+"_";
            name = "<spring:message code="etc.recovery" text="Recovery"/>"+"_";
        }

        $("#jobid_copy").val('<c:out value="${piijob.jobid}"/>_' +id+ getToday());
        $("#jobname_copy").val('<c:out value="${piijob.jobname}"/>_' +name+ getToday());
        updateCopyInfo(copytype);
    });

    $("button[data-oper='requestorder']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;
        //$("#GlobalSuccessMsgModal").removeClass("in");
        //$(".modal-backdrop").remove();
        //$('body').removeClass('modal-open');
        //$('body').css('padding-right', '');
        //$("#GlobalSuccessMsgModal").modal("hide");;
        //$("#requestmodal").modal("hide");;
        requestOrder();
    });


    $("button[data-oper='modify']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
//        alert($('#jobget_global_jobid').val());

        var url_view = "";
        var serchkeyno = $('#jobget_global_jobid').val();
        url_view = "/piijob/" + "modify?jobid=" + serchkeyno;

        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;
        var search1 = ($('#searchForm [name="search1"]').val() || '').toUpperCase();
        var search2 = ($('#searchForm [name="search2"]').val() || '').toUpperCase();
        var search3 = $('#searchForm [name="search3"]').val() || '';
        var search4 = $('#searchForm [name="search4"]').val() || '';
        var search5 = $('#searchForm [name="search5"]').val() || '';
        var search6 = $('#searchForm [name="search6"]').val() || '';
        var search7 = $('#searchForm [name="search7"]').val() || '';
        var search8 = $('#searchForm [name="search8"]').val() || '';
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }

        ingShow(); $.ajax({
            type: "GET",
            url: url_view
                + "&pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert("성공");
                $('#content_home').html(data);
                //$('#content_home').load(data);
            }
        });

    });

    $("button[data-oper='requestcopy']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var copytype = $('input[name="radiocopy"]:checked').val();

        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = $('#jobid_copy').val();
        var serchkeyno4 = $('#jobname_copy').val();
        var serchkeyno5 = copytype;

        var url_search = "";
        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var search3 = $('#searchForm [name="search3"]').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#searchForm [name="search5"]').val();
        var search6 = $('#searchForm [name="search6"]').val();
        var search7 = $('#searchForm [name="search7"]').val();
        var search8 = $('#searchForm [name="search8"]').val();

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }
        url_view = "/piijob/" + "copy?jobid=" + serchkeyno1 + "&version=" + serchkeyno2
            + "&jobid_copy=" + serchkeyno3 + "&jobname_copy=" + serchkeyno4
            + "&copytype=" + serchkeyno5
            + "&";

        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html("The JOBID is already existed");
                //$("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $("#GlobalSuccessMsgModal").removeClass("in");
                $(".modal-backdrop").remove();
                $('body').removeClass('modal-open');
                $('body').css('padding-right', '');
                $("#GlobalSuccessMsgModal").modal("hide");
                ;
                $("#copymodal").modal("hide");
                ;

                $('#content_home').html(data);
                //$('#content_home').load(data);
            }
        });

    });

    $("button[data-oper='jobgetlist']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        // $("#searchForm").attr("action","/piijob/list")
        // $("#searchForm").submit();

        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;
        var search1 = ($('#searchForm [name="search1"]').val() || '').toUpperCase();
        var search2 = ($('#searchForm [name="search2"]').val() || '').toUpperCase();
        var search3 = $('#searchForm [name="search3"]').val() || '';
        var search4 = $('#searchForm [name="search4"]').val() || '';
        var search5 = $('#searchForm [name="search5"]').val() || '';
        var search6 = $('#searchForm [name="search6"]').val() || '';
        var search7 = $('#searchForm [name="search7"]').val() || '';
        var search8 = $('#searchForm [name="search8"]').val() || '';
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }

        //$('#content_home').load("/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search);

// 		alert("/piijob/list?pagenum="+pagenum+"&amount="+amount+url_search);
//		$('#content_home').load("/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert("통신성공!!!!");
                $('#content_home').html(data);
                //$('#content_home').load("/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search);
            }
        });

    });

    searchAction = function (pageNo, serchkeyno, stepid) {

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();

        var div_tabledetail = document.getElementById(stepid + 'tabledetail');//.children("content");
        //alert($(div_tabledetail).text());

        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "/piijob/" + "list?";
        } else {
            url_view = serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
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
                $(div_tabledetail).html(data);

                //$('#content_home').load(data);
            }
        });
    }

    ////-------------------------------------------------------------
    getmdytoymd = function (mdy) {
        return mdy.substring(6,10) + mdy.substring(0,2) + mdy.substring(3,5)
    }
    requestOrder = function () {

        if ($('#jobget_global_phase').val() != "CHECKIN") {
            dlmAlert("Job is not Checkin status !");
            return;
        }
        // if ($('input[name=status]').val() != "ACTIVE") {
        //     alert("Job is not ACTIVE status");
        //     return;
        // }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = $('#datePicker').val();

        $('#orderresult').html("");

        var json = {
            "jobid": serchkeyno1
            , "version": serchkeyno2
            , "basedate": serchkeyno3
        };

        ingShow(); $.ajax({
            url: "/piijob/order",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json",
            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(response) { ingHide();
                // 성공적으로 서버가 응답한 경우
                //console.log("서버 응답: ", response); // 응답 데이터를 콘솔에 출력하거나 다른 처리를 수행할 수 있습니다.
                // 여기서 response는 서버에서 반환한 문자열이 됩니다.

                // 성공 여부에 따라 작업 수행
                if (response === "success") {
                    $('#orderresult').html("<p class='text-success'>Successfully ordered</p>");
                }
            },
            error: function(xhr, status, error) { ingHide();
                if (xhr.responseText === "It's already been ordered by that date") {
                    $('#orderresult').html("<p class='text-danger'>" + xhr.responseText + "</p>");
                }else {
                    $("#errormodalbody").html(xhr.responseText);
                    $("#errormodal").modal("show");
                }
            }
            // error: function (request, error) { ingHide();
            //     $("#errormodalbody").html(request.responseText);
            //     $("#errormodal").modal("show");
            // },
            // success: function (data) { ingHide();
            //     if (data == 'success') {
            //         $('#orderresult').html("<p class='text-success '>Successfully ordered</p>");
            //     } else {
            //         //$('#orderresult').html("<p class='text-danger ' style='font-size: 9px;'>"+data+"</p>");
            //         $("#errormodalbody").html(data);
            //         $("#errormodal").modal("show");
            //     }
            // }
        });

    }

    $("button[data-oper='checkout']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKIN") {
            dlmAlert("Job is not Checkin status !");
            return;
        }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = '';//$('#jobget_global_stepid').val();//$('input[name=stepid]').val();

        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var search3 = $('#searchForm [name="search3"]').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#searchForm [name="search5"]').val();
        var search6 = $('#searchForm [name="search6"]').val();
        var search7 = $('#searchForm [name="search7"]').val();
        var search8 = $('#searchForm [name="search8"]').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }

        url_view = "checkout?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&";//+ "stepid=" + serchkeyno3

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
                $('#content_home').html(data);

            }
        });

    });

    $("button[data-oper='removejoballinfo']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }

        var jobid = $('#jobget_global_jobid').val();
        var version = $('#jobget_global_version').val();
        showConfirm('현재 버전(Version ' + version + ')의 Job만 삭제됩니다.\n이전 버전은 유지되며, Checkin된 최신 버전으로 복구됩니다.\n\n정말 삭제하시겠습니까?', function() {
            var elementForm = $("#piijob_get_form");
            var elementResult = $("#content_home");

            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var search3 = $('#searchForm [name="search3"]').val();
            var search4 = $('#searchForm [name="search4"]').val();
            var search5 = $('#searchForm [name="search5"]').val();
            var search6 = $('#searchForm [name="search6"]').val();
            var search7 = $('#searchForm [name="search7"]').val();
            var search8 = $('#searchForm [name="search8"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) {
                url_search += "&search1=" + search1;
            }
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2;
            }
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3;
            }
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4;
            }
            if (!isEmpty(search5)) {
                url_search += "&search5=" + search5;
            }
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6;
            }
            if (!isEmpty(search7)) {
                url_search += "&search7=" + search7;
            }
            if (!isEmpty(search8)) {
                url_search += "&search8=" + search8;
            }

            ingShow(); $.ajax({
                type: "POST",
                url: "/piijob/remove?pagenum="
                    + pagenum + "&amount="
                    + amount + url_search,
                dataType: "html",
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    elementResult.html(data);
                    showToast("처리가 완료되었습니다.", false);
                }
            });
        });

    });

</script>


