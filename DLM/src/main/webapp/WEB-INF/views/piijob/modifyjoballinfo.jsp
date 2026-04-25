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
            <!-- 페이지 안내 -->
            <div class="page-indicator editing">
                <i class="fa-solid fa-pen-to-square"></i>
                <span>EDITING</span>
            </div>
        </div>
        <div class="job-detail-toolbar-right">
            <sec:authorize access="hasAnyRole('ROLE_IT')">
                <sec:authentication property="principal.member.userid" var="userid"/>
                <c:if test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                    <c:if test="${piijob.phase eq 'CHECKOUT' }">
                        <button data-oper='checkin' class="btn-checkin-request">
                            <i class="fa-solid fa-paper-plane"></i> <spring:message code="etc.requestforcheckin" text="Request for Check-In"/></button>
                        <button data-oper='remove_job' class="btn-tool btn-remove">
                            <i class="fa-solid fa-trash"></i> JOB 삭제</button>
                    </c:if>
                </c:if>
            </sec:authorize>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <c:if test="${piijob.phase eq 'CHECKOUT' }">
                    <button data-oper='checkin' class="btn-checkin-request">
                        <i class="fa-solid fa-paper-plane"></i> <spring:message code="etc.requestforcheckin" text="Request for Check-In"/></button>
                    <button data-oper='remove_job' class="btn-tool btn-remove">
                        <i class="fa-solid fa-trash"></i> JOB 삭제</button>
                </c:if>
            </sec:authorize>
            <button data-oper='modifyjoballinfolist' class="btn-list"><i class="fa-solid fa-list"></i> List</button>
            <button data-oper='jobcopy' class="btn-tool btn-wizard"><i class="fa-solid fa-copy"></i> Create/Copy</button>
        </div>
    </div>

    <!-- Job Info Section - Compact -->
    <div id="jobdetail" class="job-info-card">
        <%@include file="modify.jsp" %>
    </div>

    <!-- Step Container -->
    <div id="steps" class="step-container1" style="overflow:hidden;width:100%;flex:1;">
        <div id="steptabdiv" class="step-list-sidebar">
            <div class="step-list-header">
                <div class="step-list-title">
                    <i class="fa-solid fa-cubes"></i> STEPS
                </div>
                <button type="button" class="step-edit-btn" data-oper="modify_step" title="STEP 수정">
                    <i class="fa-solid fa-pen-to-square"></i>
                </button>
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

    <!-- Step Management Modal -->
    <div class="modal fade" id="stepmodal" role="dialog">
        <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
            <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                <div class="modal-header" style="background: linear-gradient(135deg, #0f766e 0%, #14b8a6 100%); padding: 16px 24px; border: none;">
                    <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem;">
                        <i class="fa-solid fa-layer-group"></i> Step Management
                    </h5>
                    <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="stepmodalbody" style="padding: 0; background: #f8fafc;">
                    <!-- Content loaded dynamically -->
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 12px 24px; background: #f1f5f9;">
                    <button type="button" class="btn" data-dismiss="modal"
                            style="background: #64748b; color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-weight: 500;">
                        <i class="fas fa-times"></i> 닫기
                    </button>
                </div>
            </div>
        </div>
    </div>
    <!-- The Modal end-->
    <!-- Request for Check In Modal -->
    <div class="modal fade" id="requestmodal" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document" style="max-width: 700px;">
            <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                <div class="modal-header" style="background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); padding: 16px 24px; border: none;">
                    <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem;">
                        <i class="fas fa-paper-plane"></i> <spring:message code="etc.requestforcheckin" text="Request for Check In"/>
                    </h5>
                    <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="requestmodalbody" style="padding: 24px;">
                    <div style="margin-bottom: 20px;">
                        <label style="display: block; font-weight: 600; color: #374151; margin-bottom: 8px; font-size: 0.9rem;">
                            <i class="fas fa-sitemap" style="color: #6b7280;"></i> <spring:message code="etc.aprvline" text="Approval Line"/>
                        </label>
                        <div id="approvallineselect" style="max-height: 200px; overflow-y: auto;"></div>
                    </div>
                    <div style="margin-bottom: 12px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <label style="font-weight: 600; color: #374151; font-size: 0.9rem;">
                                <i class="fas fa-edit" style="color: #6b7280;"></i> <spring:message code="msg.msginputapplyreason" text="Please enter the details of the reason for the change"/>
                            </label>
                            <span style="font-size: 0.8rem; color: #9ca3af;"><span id="reasonlength">0</span>/1000</span>
                        </div>
                        <textarea spellcheck="false" rows="12" class="form-control"
                                  name='checkin_reason' id='checkin_reason'
                                  style="border: 1px solid #d1d5db; border-radius: 8px; padding: 12px; font-size: 0.9rem; resize: none; transition: border-color 0.2s, box-shadow 0.2s;"
                                  onfocus="this.style.borderColor='#3b82f6'; this.style.boxShadow='0 0 0 3px rgba(59,130,246,0.1)';"
                                  onblur="this.style.borderColor='#d1d5db'; this.style.boxShadow='none';"></textarea>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px; background: #f8fafc;">
                    <button type="button" class="btn" data-dismiss="modal"
                            style="background: #64748b; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 500;">
                        <i class="fas fa-times"></i> 취소
                    </button>
                    <button data-oper='request_checkin' class="btn"
                            style="background: linear-gradient(135deg, #7c3aed, #a855f7); color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-weight: 500;">
                        <i class="fas fa-paper-plane"></i> Request
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
                <div class="modal-body" style="padding: 24px; background: #f8fafc;">
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

</div>
<!-- <div class="card shadow"> DataTales begin-->
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
<input type='hidden' id='jobget_reqreason' name='jobget_reqreason' value=''>
<input type='hidden' id='jobget_global_phase' name='jobget_global_phase' value='<c:out value="${piijob.phase}"/>'>
<script type="text/javascript">
    var doubleSubmitFlag = false;
    $(function () {
        //$("#menupath").html(Menupath +">Details>Modify");
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.job" text="Job"/>" + ">Modify")

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
                            $el.text(res.phase);
                            $('#jobget_global_phase').val(res.phase);
                            $('input[name="phase"]').val(res.phase);
                            $('input[name="ori_phase"]').val(res.phase);
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
    var textCountLimit = 1000;

    $(document).ready(function () {
        $('textarea[name=checkin_reason]').keyup(function () {
            var textLength = $(this).val().length;
            $('#reasonlength').text(textLength);
            if (textLength >= textCountLimit) {
                $(this).val($(this).val().substr(0, textCountLimit));
            }
            var textLength = $(this).val().length;
            $('#reasonlength').text(textLength);
        });
    });
    var getTextLength = function (str) {
        var len = 0;
        for (var i = 0; i < str.length; i++) {
            //if (escape(str.charAt(i)).length == 6) {
            //    len += 3;
            //}
            len++;
        }
        return len;
    }
    getMaxText = function (str) {
        var len = 0;
        var i = 0;
        for (i = 0; i < str.length; i++) {
            if (escape(str.charAt(i)).length == 6) {
                len += 4;
            } else
                len++;


            if (len > textCountLimit) {
                break;
            }
        }
        //alert(len);
        $(this).val($(this).val().substring(0, i));
        $('#reasonlength').text(len);
    }
    $(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        var stepid = '<c:out value="${firststepid}"/>';
        $("#" + stepid).trigger("click");
    });
    //$ (document).on('hidden.bs.modal', '#requestmodal', function(e) {
    //	e.preventDefault();e.stopPropagation();
    //	if( doubleSubmitFlag ){
    //		doubleSubmitFlag = false;
    //		requestApproval();
    //	}
    //});
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
        var search1 = $('input[name=jobid]').val();
        var search2 = $('input[name=version]').val();
        var search3 = $('#jobget_global_stepid').val();
        var search4 = $('#searchForm [name="search4"]').val();
        var search5 = $('#searchForm [name="search5"]').val();
        var search6 = $('#searchForm [name="search6"]').val();

        var url_search = "";
        var url_view = "modifystepallinfo?"
            + "jobid=" + search1 + "&"
            + "version=" + search2 + "&"
            + "stepid=" + search3 + "&"
        ;
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
    $("button[data-oper='modify_step']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = '';//$('#jobget_global_stepid').val();//$('input[name=stepid]').val();
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
        var url_view = "";

        url_view = "modifydialog?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        amount = 100;
        //alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piistep/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
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
            url: "/piijob/modifyjoballinfo?jobid=" + encodeURIComponent(jobid) + "&version=" + encodeURIComponent(version),
            dataType: "html",
            error: function (request) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });
    };

    $("button[data-oper='modify_job_dialog']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        //var serchkeyno3 = $('#jobget_global_stepid').val();//$('input[name=stepid]').val();
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
        var url_view = "";

        url_view = "modify?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        amount = 100;
        //alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piistep/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#stepmodalbody').html(data);
                $("#stepmodal").modal();

            }
        });

    });

    $("button[data-oper='checkout']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        //alert($('#jobget_global_phase').val());
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job is not Checkin status !!!");
            return;
        }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = '';//$('#jobget_global_stepid').val();//$('input[name=stepid]').val();
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
        var url_view = "";

        url_view = "checkout?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&";//+ "stepid=" + serchkeyno3

        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
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
                $('#content_home').html(data);

            }
        });

    });
    $("button[data-oper='checkin']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;

        /* 		if ($('#piijob_modify_form [name="jobid"]').val() != $('#piijob_modify_form_ori [name="ori_jobid"]').val() ){alert('JOBID is changed. Press the savejob button if you want to save');return;}
                if ($('#piijob_modify_form [name="version"]').val() != $('#piijob_modify_form_ori [name="ori_version"]').val() ){alert('Version is changed. Press the savejob button if you want to save');return;}
         */
        if ($('#piijob_modify_form [name="jobname"]').val() != $('#piijob_modify_form_ori [name="ori_jobname"]').val()) {
            dlmAlert('Jobname is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="system"]').val() != $('#piijob_modify_form_ori [name="ori_system"]').val()) {
            dlmAlert('System is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="policy_id"]').val() != $('#piijob_modify_form_ori [name="ori_policy_id"]').val()) {
            dlmAlert('Policy_Id is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="keymap_id"]').val() != $('#piijob_modify_form_ori [name="ori_keymap_id"]').val()) {
            dlmAlert('Keymap_Id is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="jobtype"]').val() != $('#piijob_modify_form_ori [name="ori_jobtype"]').val()) {
            dlmAlert('Jobtype is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="runtype"]').val() != $('#piijob_modify_form_ori [name="ori_runtype"]').val()) {
            dlmAlert('Runtype is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="calendar"]').val() != $('#piijob_modify_form_ori [name="ori_calendar"]').val()) {
            dlmAlert('Calendar is changed. Press the savejob button if you want to save');
            dlmAlert($('#piijob_modify_form [name="calendar"]').val());
            dlmAlert($('#piijob_modify_form_ori [name="ori_calendar"]').val());
            return;
        }
        if ($('#piijob_modify_form [name="time"]').val() != $('#piijob_modify_form_ori [name="ori_time"]').val()) {
            dlmAlert('Time is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="cronval"]').val() != $('#piijob_modify_form_ori [name="ori_cronval"]').val()) {
            dlmAlert('Cronval is changed. Press the savejob button if you want to save');
            return;
        }
        //if ($('#piijob_modify_form [name="confirmflag"]').val() != $('#piijob_modify_form_ori [name="ori_confirmflag"]').val() ){alert('Confirmflag is changed. Press the savejob button if you want to save');return;}
        if ($('#piijob_modify_form [name="status"]').val() != $('#piijob_modify_form_ori [name="ori_status"]').val()) {
            dlmAlert('Status is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="phase"]').val() != $('#piijob_modify_form_ori [name="ori_phase"]').val()) {
            dlmAlert('Phase is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_id1"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_id1"]').val()) {
            dlmAlert('Job_Owner_Id1 is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_name1"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_name1"]').val()) {
            dlmAlert('Job_Owner_Name1 is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_id2"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_id2"]').val()) {
            dlmAlert('Job_Owner_Id2 is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_name2"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_name2"]').val()) {
            dlmAlert('Job_Owner_Name2 is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_id3"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_id3"]').val()) {
            dlmAlert('Job_Owner_Id3 is changed. Press the savejob button if you want to save');
            return;
        }
        if ($('#piijob_modify_form [name="job_owner_name3"]').val() != $('#piijob_modify_form_ori [name="ori_job_owner_name3"]').val()) {
            dlmAlert('Job_Owner_Name3 is changed. Press the savejob button if you want to save');
            return;
        }
        var aprovalid = "JOB_APPROVAL";
        ingShow(); $.ajax({
            type: "GET",
            url: "/piiapprovaluser/approvallinebyappidlist?approvalid=" + aprovalid ,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#approvallineselect').html(data);
            }
        });

        $('#checkin_reason').val("");
        $("#requestmodal").modal();

    });
    $("button[data-oper='request_checkin']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if (isEmpty($('input[name="aprvlineid"]:checked').val())) {
            dlmAlert("<spring:message code='msg.select_approval_line' text='Please select an approval line'/>");
            return;
        }

        if (isEmpty($('#checkin_reason').val())) {
            dlmAlert("Enter request reason for CHECK-IN ");
            return;
        }

        doubleSubmitFlag = true;
        $("#GlobalSuccessMsgModal").removeClass("in");
        $(".modal-backdrop").remove();
        $('body').removeClass('modal-open');
        $('body').css('padding-right', '');
        $("#GlobalSuccessMsgModal").modal("hide");
        ;
        requestApproval();
    });

    $("button[data-oper='modify']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
        var serchkeyno = $('input[name=jobid]').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "/piijob/" + "modify?jobid=" + serchkeyno
            + "&";//alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount))
            amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                dlmAlert("성공");
                $('#content_home').html(data);
                //$('#content_home').load(data);
            }
        });

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

        if (!isEmpty(search1)) { url_search += "&search1=" + search1; }
        if (!isEmpty(search2)) { url_search += "&search2=" + search2; }
        if (!isEmpty(search3)) { url_search += "&search3=" + search3; }
        if (!isEmpty(search4)) { url_search += "&search4=" + search4; }
        if (!isEmpty(search5)) { url_search += "&search5=" + search5; }
        if (!isEmpty(search6)) { url_search += "&search6=" + search6; }
        if (!isEmpty(search7)) { url_search += "&search7=" + search7; }
        if (!isEmpty(search8)) { url_search += "&search8=" + search8; }

        url_view = "/piijob/" + "copy?jobid=" + serchkeyno1 + "&version=" + serchkeyno2
            + "&jobid_copy=" + serchkeyno3 + "&jobname_copy=" + serchkeyno4
            + "&copytype=" + serchkeyno5
            + "&";

        ingShow(); $.ajax({
            type: "GET",
            url: url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html("The JOBID is already existed");
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $("#GlobalSuccessMsgModal").removeClass("in");
                $(".modal-backdrop").remove();
                $('body').removeClass('modal-open');
                $('body').css('padding-right', '');
                $("#GlobalSuccessMsgModal").modal("hide");
                $("#copymodal").modal("hide");

                $('#content_home').html(data);
            }
        });
    });

    $("button[data-oper='modifyjoballinfolist']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val().toUpperCase();
        var search2 = $('#searchForm [name="search2"]').val().toUpperCase();
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

//		alert("/piijob/list?pagenum="+pagenum+"&amount="+amount+url_search);
//		$('#content_home').load("/piijob/list?pagenum=" + pagenum + "&amount=" + amount + url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piijob/list?pagenum="
                + pagenum + "&amount="
                + amount + url_search,
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

    requestApproval = function () {

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
        var serchkeyno1 = $('#jobget_global_jobid').val();
        var serchkeyno2 = $('#jobget_global_version').val();
        var serchkeyno3 = $('#checkin_reason').val();
        var url_search = "";
        var url_view = "";
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val().toUpperCase();
        var search2 = $('#searchForm [name="search2"]').val().toUpperCase();
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
        var aprvlineid = $('input[name="aprvlineid"]:checked').val();
        url_view = "checkin?";

        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);

        var json = {
              reqid: ""
            , aprvlineid:aprvlineid
            , seq: "1"
            , approvalid: "JOB_APPROVAL"
            , phase: "APPLY"
            , jobid: serchkeyno1
            , version: serchkeyno2
            , requesterid: ""
            , requestername: ""
            , regdate: ""
            , upddate: ""
            , reqreason: serchkeyno3
        };

        ingShow(); $.ajax({
            url: "/piijob/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json",
            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                showToast("처리가 완료되었습니다.", false);
                //$('#orderresult').text("Successfully ordered on "+serchkeyno3);

                //$('#orderresult').text("The order failed on "+serchkeyno3);

                $('#content_home').html(data);
            }
        });

    }
</script>



