<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<c:set var="isNew" value="${mode eq 'new'}"/>
<c:set var="exetype" value="${piistep.steptype}"/>

<div class="step-detail-container" data-mode="${mode}">

    <div class="step-detail-header">
        <div class="step-detail-title" id="stepDetailTitle">
            <i class="fas fa-edit"></i>
            <span id="stepDetailTitleText">
                <c:choose>
                    <c:when test="${isNew}"><spring:message code="btn.register" text="New Step"/></c:when>
                    <c:otherwise><c:out value="${piistep.stepid}"/> — <c:out value="${piistep.stepname}"/></c:otherwise>
                </c:choose>
            </span>
            <span class="mode-pill ${isNew ? 'mode-new' : ''}">
                <c:choose>
                    <c:when test="${isNew}"><spring:message code="step.mode_new" text="NEW"/></c:when>
                    <c:otherwise><spring:message code="step.mode_edit" text="EDIT"/></c:otherwise>
                </c:choose>
            </span>
            <span class="dirty-dot" title="Unsaved changes"></span>
        </div>
    </div>

    <div class="step-detail-body">
        <form role="form" id="piistepForm" autocomplete="off">

            <!-- ===== Section: Basic ===== -->
            <div class="step-section">
                <div class="step-section-title">
                    <i class="fas fa-info-circle"></i>
                    <spring:message code="section.step.basic" text="Basic Info"/>
                </div>
                <div class="step-section-body">
                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.stepid" text="STEPID"/> <span class="required">*</span>
                        </label>
                        <input type="text" name="stepid"
                               class="step-field-input" maxlength="30"
                               value="<c:out value='${piistep.stepid}'/>"
                               <c:if test="${not isNew}">readonly</c:if>>
                        <small class="field-error"><spring:message code="msg.field_required" text="This field is required"/></small>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.stepname" text="Step Name"/> <span class="required">*</span>
                        </label>
                        <input type="text" name="stepname" class="step-field-input" maxlength="100"
                               value="<c:out value='${piistep.stepname}'/>">
                        <small class="field-error"><spring:message code="msg.field_required" text="This field is required"/></small>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.steptype" text="Step Type"/> <span class="required">*</span>
                        </label>
                        <select name="steptype" class="step-field-select" id="stepTypeSelect"
                                <c:if test="${not isNew}">disabled</c:if>>
                            <c:forEach var="t" items="${['EXE_EXTRACT','GEN_KEYMAP','EXE_ARCHIVE','EXE_DELETE','EXE_UPDATE','EXE_BROADCAST','EXE_HOMECAST','EXE_FINISH','EXE_MIGRATE','EXE_SCRAMBLE','EXE_ILM','EXE_SYNC','ETC','EXE_TD_UPDATE']}">
                                <option value="${t}" <c:if test="${exetype eq t}">selected</c:if>>${t}</option>
                            </c:forEach>
                        </select>
                        <c:if test="${not isNew}">
                            <input type="hidden" name="steptype" value="<c:out value='${exetype}'/>">
                        </c:if>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.status" text="Status"/> <span class="required">*</span>
                        </label>
                        <select name="status" class="step-field-select">
                            <option value="ACTIVE" <c:if test="${isNew or piistep.status eq 'ACTIVE'}">selected</c:if>>ACTIVE</option>
                            <option value="INACTIVE" <c:if test="${piistep.status eq 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                            <option value="HOLD" <c:if test="${piistep.status eq 'HOLD'}">selected</c:if>>HOLD</option>
                        </select>
                    </div>

                    <div class="step-field span-2">
                        <label class="step-field-label" id="dbFieldLabel">
                            <spring:message code="col.db" text="DB"/> <span class="required">*</span>
                        </label>
                        <select name="db" class="step-field-select">
                            <option value=""></option>
                            <c:forEach items="${piidatabaselist}" var="piidatabase">
                                <option value="<c:out value='${piidatabase.db}'/>"
                                        <c:if test="${piistep.db eq piidatabase.db}">selected</c:if>>
                                    <c:out value="${piidatabase.db}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <small class="field-error"><spring:message code="msg.field_required" text="This field is required"/></small>
                    </div>
                </div>
            </div>

            <!-- ===== Section: Execution ===== -->
            <div class="step-section">
                <div class="step-section-title">
                    <i class="fas fa-cogs"></i>
                    <spring:message code="section.step.execution" text="Execution"/>
                </div>
                <div class="step-section-body">
                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/>
                            <i class="fas fa-question-circle tooltip-icon"
                               title="<spring:message code='tip.threadcnt'/>"></i>
                            <span class="required">*</span>
                        </label>
                        <input type="text" name="threadcnt" class="step-field-input" maxlength="2"
                               onkeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                               value="<c:out value='${empty piistep.threadcnt ? 1 : piistep.threadcnt}'/>">
                        <small class="field-error"><spring:message code="msg.field_required" text="This field is required"/></small>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label" id="commitCntLabel">
                            <spring:message code="col.commitcnt" text="Commit Count"/>
                            <i class="fas fa-question-circle tooltip-icon" id="commitCntTip"
                               title="<spring:message code='tip.commitcnt'/>"></i>
                            <span class="required">*</span>
                        </label>
                        <input type="text" name="commitcnt" class="step-field-input" maxlength="8"
                               onkeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                               value="<c:out value='${empty piistep.commitcnt ? 5000 : piistep.commitcnt}'/>">
                        <small class="field-error"><spring:message code="msg.field_required" text="This field is required"/></small>
                    </div>
                </div>
            </div>

            <!-- ===== Section: Advanced (conditional) ===== -->
            <div class="step-section step-section-advanced" id="advancedSection">
                <div class="step-section-title">
                    <i class="fas fa-sliders-h"></i>
                    <spring:message code="section.step.advanced" text="Advanced"/>
                    <span class="reveal-hint">
                        <i class="fas fa-arrow-up"></i>
                        <spring:message code="step.additional_fields" text="Extra fields revealed"/>
                    </span>
                </div>
                <div class="step-section-body">
                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.data_handling_method" text="Data Handling Method"/>
                        </label>
                        <select name="data_handling_method" class="step-field-select">
                            <option value="TRUNCSERT" <c:if test="${piistep.data_handling_method eq 'TRUNCSERT' or (isNew and empty piistep.data_handling_method)}">selected</c:if>>
                                <spring:message code="etc.data_handling_method1" text="Truncate & Insert"/>
                            </option>
                            <option value="REPLACEINSERT" <c:if test="${piistep.data_handling_method eq 'REPLACEINSERT'}">selected</c:if>>
                                <spring:message code="etc.data_handling_method2" text="Upsert"/>
                            </option>
                            <option value="DELDUPINSERT" <c:if test="${piistep.data_handling_method eq 'DELDUPINSERT'}">selected</c:if>>
                                <spring:message code="etc.data_handling_method5" text="DelDup & Insert"/>
                            </option>
                            <option value="INSERT" <c:if test="${piistep.data_handling_method eq 'INSERT'}">selected</c:if>>
                                <spring:message code="etc.data_handling_method3" text="Insert"/>
                            </option>
                        </select>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.processing_method" text="Processing Method"/>
                            <i class="fas fa-question-circle tooltip-icon"
                               title="<spring:message code='tip.processing_method'/>"></i>
                        </label>
                        <select name="processing_method" class="step-field-select">
                            <option value="TMP_TABLE" <c:if test="${piistep.processing_method eq 'TMP_TABLE' or (isNew and empty piistep.processing_method)}">selected</c:if>>
                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing"/>
                            </option>
                        </select>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.index_unusual_flag" text="Disable Index/FK"/>
                        </label>
                        <select name="index_unusual_flag" class="step-field-select">
                            <option value="N" <c:if test="${piistep.index_unusual_flag eq 'N' or (isNew and empty piistep.index_unusual_flag)}">selected</c:if>>N</option>
                            <option value="Y" <c:if test="${piistep.index_unusual_flag eq 'Y'}">selected</c:if>>Y</option>
                        </select>
                    </div>

                    <div class="step-field">
                        <label class="step-field-label">
                            <spring:message code="col.distributedtaskcnt" text="Distributed Task Count"/>
                            <i class="fas fa-question-circle tooltip-icon"
                               title="<spring:message code='tip.val1_distributed'/>"></i>
                        </label>
                        <select name="val1" class="step-field-select">
                            <c:forEach var="i" begin="1" end="15">
                                <option value="${i}" <c:if test="${piistep.val1 eq i or (isNew and empty piistep.val1 and i == 1)}">selected</c:if>>${i}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Hidden state -->
            <input type="hidden" name="jobid" value="<c:out value='${isNew ? jobid : piistep.jobid}'/>">
            <input type="hidden" name="version" value="<c:out value='${isNew ? version : piistep.version}'/>">
            <input type="hidden" name="phase" value="<c:out value='${isNew ? phase : piistep.phase}'/>">
            <input type="hidden" name="fk_disable_flag" value="<c:out value='${piistep.fk_disable_flag}'/>">
            <c:if test="${not isNew}">
                <input type="hidden" name="stepseq" value="<c:out value='${piistep.stepseq}'/>">
                <input type="hidden" name="enddate" value="<c:out value='${piistep.enddate}'/>">
                <input type="hidden" name="regdate" value="<c:out value='${piistep.regdate}'/>">
                <input type="hidden" name="upddate" value="<c:out value='${piistep.upddate}'/>">
            </c:if>
            <input type="hidden" name="reguserid" value="<c:choose><c:when test='${isNew}'><sec:authentication property='principal.member.userid'/></c:when><c:otherwise><c:out value='${piistep.reguserid}'/></c:otherwise></c:choose>">
            <input type="hidden" name="upduserid" value="<sec:authentication property='principal.member.userid'/>">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        </form>
    </div>

    <div class="step-detail-footer">
        <sec:authorize access="isAuthenticated()">
            <c:if test="${not isNew}">
                <button type="button" class="btn-step-delete" id="stepDeleteBtn">
                    <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Remove"/>
                </button>
            </c:if>
            <button type="button" class="btn-step-cancel" id="stepCancelBtn">
                <spring:message code="btn.cancel" text="Cancel"/>
            </button>
            <button type="button" class="btn-step-save" id="stepSaveBtn">
                <i class="fas fa-save"></i>
                <c:choose>
                    <c:when test="${isNew}"><spring:message code="btn.register" text="Register"/></c:when>
                    <c:otherwise><spring:message code="btn.save" text="Save"/></c:otherwise>
                </c:choose>
            </button>
        </sec:authorize>
    </div>
</div>

<script>
(function(){
    var $form = $("#piistepForm");
    var isNew = ${isNew};
    var $title = $("#stepDetailTitle");
    var $saveBtn = $("#stepSaveBtn");
    var $cancelBtn = $("#stepCancelBtn");
    var $deleteBtn = $("#stepDeleteBtn");
    var $dbLabel = $("#dbFieldLabel");
    var $commitLabel = $("#commitCntLabel");
    var $advanced = $("#advancedSection");
    var $stepType = $("select[name='steptype'][id='stepTypeSelect']");

    // Mark detail as loaded so modifydialog JS can hook state
    window.stepDetailState = { isNew: isNew, dirty: false };

    function setDirty(v) {
        window.stepDetailState.dirty = v;
        $title.toggleClass("is-dirty", !!v);
    }

    // Steptype-driven section & label updates
    function updateSectionVisibility() {
        var t = $stepType.val() || $form.find("input[name='steptype']").val();
        var showAdvanced = (t === 'EXE_SCRAMBLE' || t === 'EXE_ILM' || t === 'EXE_MIGRATE' || t === 'EXE_SYNC');

        // Toggle Advanced section
        var wasVisible = $advanced.hasClass("is-visible");
        $advanced.toggleClass("is-visible", showAdvanced);
        if (showAdvanced && !wasVisible) {
            $advanced.addClass("is-revealed");
            setTimeout(function(){ $advanced.removeClass("is-revealed"); }, 2500);
        }

        // DB label
        var dbLabelTxt;
        if (t === 'EXE_SCRAMBLE') dbLabelTxt = 'Source DB';
        else if (t === 'EXE_ILM') dbLabelTxt = 'Archiving DB';
        else if (t === 'EXE_MIGRATE' || t === 'EXE_SYNC') dbLabelTxt = 'Target DB';
        else dbLabelTxt = 'DB';
        $dbLabel.contents().filter(function(){return this.nodeType === 3;}).first().replaceWith(dbLabelTxt + ' ');

        // commitcnt label + default for handle-style steps
        if (showAdvanced) {
            $commitLabel.contents().filter(function(){return this.nodeType === 3;}).first()
                .replaceWith('<spring:message code="col.handlecnt" text="Data Processing Unit"/> ');
            if (isNew) $form.find("input[name='commitcnt']").val(20000);
        } else {
            $commitLabel.contents().filter(function(){return this.nodeType === 3;}).first()
                .replaceWith('<spring:message code="col.commitcnt" text="Commit Count"/> ');
            if (isNew) $form.find("input[name='commitcnt']").val(5000);
        }
    }

    $stepType.on("change", function(){ updateSectionVisibility(); setDirty(true); });
    updateSectionVisibility();

    // Dirty tracking
    $form.on("input change", "input, select", function(e){
        if (e.target.name === 'steptype') return;
        setDirty(true);
    });

    // Inline validation helper
    function validate() {
        var ok = true;
        $form.find(".step-field.has-error").removeClass("has-error");
        $form.find(".is-invalid").removeClass("is-invalid");

        function fail($field) {
            $field.addClass("is-invalid");
            $field.closest(".step-field").addClass("has-error");
            if (ok) $field.focus();
            ok = false;
        }

        var required = ['stepid','stepname','db','threadcnt','commitcnt','status'];
        required.forEach(function(name){
            var $el = $form.find("[name='"+name+"']").filter(":not(:disabled):not([type=hidden])").first();
            if ($el.length && !String($el.val() || "").trim()) fail($el);
        });

        var t = $stepType.val() || $form.find("input[name='steptype']").val();
        if (t === 'EXE_SCRAMBLE' || t === 'EXE_ILM' || t === 'EXE_MIGRATE' || t === 'EXE_SYNC') {
            ['processing_method','index_unusual_flag','val1'].forEach(function(name){
                var $el = $form.find("[name='"+name+"']").first();
                if ($el.length && !String($el.val() || "").trim()) fail($el);
            });
            if (t === 'EXE_SCRAMBLE') {
                var $dh = $form.find("[name='data_handling_method']").first();
                if ($dh.length && !String($dh.val() || "").trim()) fail($dh);
            }
        }
        return ok;
    }

    // Save
    $saveBtn.on("click", function(){
        if (!validate()) return;
        // STEPID uppercase on submit (new mode)
        if (isNew) {
            $form.find("[name='stepid']").val(($form.find("[name='stepid']").val() || '').toUpperCase());
        }
        var url = isNew ? "/piistep/register" : "/piistep/modify";
        ingShow();
        $.ajax({
            type: "POST",
            url: url,
            dataType: "text",
            data: $form.serialize(),
            error: function(req){
                ingHide();
                dlmAlert(req.responseText || "Save failed");
            },
            success: function(data){
                ingHide();
                setDirty(false);
                var sid = $form.find("[name='stepid']").val();
                if (typeof window.onStepSaved === 'function') {
                    window.onStepSaved(sid, isNew, data);
                }
            }
        });
    });

    // Cancel — reload current step or clear
    $cancelBtn.on("click", function(){
        if (window.stepDetailState.dirty) {
            showConfirm('<spring:message code="step.discard_confirm" text="Discard changes?"/>', function(){
                setDirty(false);
                if (typeof window.onStepCancel === 'function') window.onStepCancel();
            });
        } else {
            if (typeof window.onStepCancel === 'function') window.onStepCancel();
        }
    });

    // Delete
    $deleteBtn.on("click", function(){
        showConfirm('<spring:message code="step.remove_confirm" text="Delete this step?"/>', function(){
            ingShow();
            $.ajax({
                type: "POST",
                url: "/piistep/remove",
                dataType: "text",
                data: $form.serialize(),
                error: function(req){
                    ingHide();
                    dlmAlert(req.responseText || "Remove failed");
                },
                success: function(data){
                    ingHide();
                    setDirty(false);
                    if (typeof window.onStepRemoved === 'function') window.onStepRemoved(data);
                }
            });
        });
    });
})();
</script>
