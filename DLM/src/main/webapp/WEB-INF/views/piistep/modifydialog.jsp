<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<div class="step-modal-layout" id="stepModalLayout">

    <!-- ===== LEFT: Step List Pane ===== -->
    <div class="step-list-pane">
        <div class="step-context-bar">
            <span class="context-pill"><i class="fas fa-briefcase"></i> <c:out value="${jobid}"/></span>
            <span class="context-sep"><i class="fas fa-chevron-right"></i></span>
            <span class="context-pill">v<c:out value="${version}"/></span>
        </div>

        <div class="step-filter-bar">
            <input type="text" id="stepFilterText"
                   placeholder="<spring:message code='step.filter_placeholder' text='Filter by name / STEPID'/>">
            <select id="stepFilterType">
                <option value=""><spring:message code="step.filter_all_types" text="All types"/></option>
                <c:forEach var="t" items="${['EXE_EXTRACT','GEN_KEYMAP','EXE_ARCHIVE','EXE_DELETE','EXE_UPDATE','EXE_BROADCAST','EXE_HOMECAST','EXE_FINISH','EXE_MIGRATE','EXE_SCRAMBLE','EXE_ILM','EXE_SYNC','ETC','EXE_TD_UPDATE']}">
                    <option value="${t}">${t}</option>
                </c:forEach>
            </select>
            <select id="stepFilterStatus">
                <option value=""><spring:message code="step.filter_all_status" text="All status"/></option>
                <option value="ACTIVE">ACTIVE</option>
                <option value="INACTIVE">INACTIVE</option>
                <option value="HOLD">HOLD</option>
            </select>
        </div>

        <div class="step-list-wrapper">
            <c:choose>
                <c:when test="${empty list}">
                    <div class="step-list-empty">
                        <i class="fas fa-inbox"></i>
                        <div><spring:message code="step.empty_state" text="No steps yet. Click + New Step to add one."/></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="step-list-table" id="stepListTable">
                        <colgroup>
                            <col class="col-w-seq">
                            <col class="col-w-stepid">
                            <col class="col-w-stepname">
                            <col class="col-w-steptype">
                            <col class="col-w-status">
                        </colgroup>
                        <thead>
                        <tr>
                            <th class="col-seq" data-sort="stepseq">#<span class="sort-indicator">▼</span></th>
                            <th data-sort="stepid">STEPID<span class="sort-indicator">↕</span></th>
                            <th data-sort="stepname"><spring:message code="col.stepname" text="Name"/><span class="sort-indicator">↕</span></th>
                            <th data-sort="steptype"><spring:message code="col.steptype" text="Type"/><span class="sort-indicator">↕</span></th>
                            <th class="col-status" data-sort="status"><spring:message code="col.status" text="Status"/><span class="sort-indicator">↕</span></th>
                        </tr>
                        </thead>
                        <tbody id="stepListBody">
                        <c:forEach items="${list}" var="piistep" varStatus="st">
                            <tr data-stepid="<c:out value='${piistep.stepid}'/>"
                                data-jobid="<c:out value='${piistep.jobid}'/>"
                                data-steptype="<c:out value='${piistep.steptype}'/>"
                                data-status="<c:out value='${piistep.status}'/>">
                                <td class="col-seq"><c:out value="${piistep.stepseq}"/></td>
                                <td class="col-stepid"><c:out value="${piistep.stepid}"/></td>
                                <td class="col-stepname"><c:out value="${piistep.stepname}"/></td>
                                <td class="col-steptype"><c:out value="${piistep.steptype}"/></td>
                                <td class="col-status">
                                    <c:set var="statusCls" value="status-inactive"/>
                                    <c:if test="${piistep.status eq 'ACTIVE'}"><c:set var="statusCls" value="status-active"/></c:if>
                                    <c:if test="${piistep.status eq 'HOLD'}"><c:set var="statusCls" value="status-hold"/></c:if>
                                    <span class="step-badge ${statusCls}"><c:out value="${piistep.status}"/></span>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="step-list-footer">
            <div class="reorder-group">
                <button type="button" class="btn-step-reorder" id="btnReorderUp" title="Move up" disabled>▲</button>
                <button type="button" class="btn-step-reorder" id="btnReorderDown" title="Move down" disabled>▼</button>
            </div>
            <button type="button" class="btn-step-save-order" id="btnSaveOrder">
                <spring:message code="step.save_order" text="Save Order"/>
            </button>
            <span class="status-msg" id="stepListStatusMsg"></span>
        </div>
    </div>

    <!-- ===== RIGHT: Detail Pane ===== -->
    <div class="step-detail-pane">
        <div class="step-detail-topbar" style="display:flex;align-items:center;justify-content:flex-end;padding:10px 20px 0 20px;">
            <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_ADMIN')">
                <button type="button" class="step-detail-new-btn" id="btnNewStep">
                    <i class="fas fa-plus"></i> New Step
                </button>
            </sec:authorize>
        </div>

        <div id="stepDetailSlot" style="flex:1; display:flex; flex-direction:column; overflow:hidden;">
            <div class="step-detail-placeholder" id="stepDetailPlaceholder">
                <i class="fas fa-layer-group"></i>
                <p><spring:message code="step.placeholder" text="Select a step or click + New Step to add one."/></p>
            </div>
        </div>
    </div>
</div>

<input type='hidden' id='step_md_global_jobid' value='<c:out value="${jobid}"/>'>
<input type='hidden' id='step_md_global_version' value='<c:out value="${version}"/>'>
<input type='hidden' id='step_md_global_stepid' value='<c:out value="${stepid}"/>'>

<script>
(function(){
    var jobid = $('#step_md_global_jobid').val();
    var version = $('#step_md_global_version').val();
    var initialStepid = $('#step_md_global_stepid').val();

    var $listPane = $('.step-list-pane');
    var $tbody = $('#stepListBody');
    var $msg = $('#stepListStatusMsg');
    var $btnUp = $('#btnReorderUp');
    var $btnDown = $('#btnReorderDown');
    var $btnSaveOrder = $('#btnSaveOrder');
    var orderDirty = false;

    // Enable Bootstrap tooltips
    if (typeof $().tooltip === 'function') {
        $('[data-toggle="tooltip"]').tooltip({container: '#stepmodal'});
    }

    // ---------- filter ----------
    function applyFilter() {
        var txt = ($('#stepFilterText').val() || '').trim().toUpperCase();
        var fType = $('#stepFilterType').val() || '';
        var fStatus = $('#stepFilterStatus').val() || '';
        $tbody.find('tr').each(function(){
            var $r = $(this);
            var sid = ($r.data('stepid') || '').toString().toUpperCase();
            var sname = ($r.find('.col-stepname').text() || '').toUpperCase();
            var stype = ($r.data('steptype') || '').toString();
            var sst = ($r.data('status') || '').toString();
            var match = true;
            if (txt && sid.indexOf(txt) === -1 && sname.indexOf(txt) === -1) match = false;
            if (fType && stype !== fType) match = false;
            if (fStatus && sst !== fStatus) match = false;
            $r.toggle(match);
        });
    }
    $('#stepFilterText').on('input', applyFilter);
    $('#stepFilterType, #stepFilterStatus').on('change', applyFilter);

    // ---------- sorting ----------
    var sortState = { key: 'stepseq', dir: 'asc' };
    function compareRows(a, b, key, dir) {
        function keyVal($r) {
            if (key === 'stepseq') return parseInt($r.find('.col-seq').text(), 10) || 0;
            if (key === 'stepid') return $r.data('stepid') || '';
            if (key === 'stepname') return $r.find('.col-stepname').text() || '';
            if (key === 'steptype') return $r.data('steptype') || '';
            if (key === 'status') return $r.data('status') || '';
            return '';
        }
        var av = keyVal($(a)), bv = keyVal($(b));
        if (av < bv) return dir === 'asc' ? -1 : 1;
        if (av > bv) return dir === 'asc' ? 1 : -1;
        return 0;
    }
    $listPane.on('click', '#stepListTable thead th', function(){
        var key = $(this).data('sort');
        if (!key) return;
        if (sortState.key === key) sortState.dir = (sortState.dir === 'asc' ? 'desc' : 'asc');
        else { sortState.key = key; sortState.dir = 'asc'; }

        $('#stepListTable thead th').removeClass('sorted-asc sorted-desc');
        $(this).addClass(sortState.dir === 'asc' ? 'sorted-asc' : 'sorted-desc');
        $(this).find('.sort-indicator').text(sortState.dir === 'asc' ? '▲' : '▼');

        var rows = $tbody.find('tr').toArray();
        rows.sort(function(a,b){ return compareRows(a,b,sortState.key,sortState.dir); });
        $tbody.append(rows);
        if (sortState.key !== 'stepseq') markOrderDirty(false);
        updateReorderButtons();
    });

    // ---------- selection / load detail ----------
    function clearSelection() {
        $tbody.find('tr').removeClass('is-selected');
    }
    function selectRow(stepid) {
        clearSelection();
        var $r = $tbody.find('tr[data-stepid="' + cssEscape(stepid) + '"]');
        if ($r.length) $r.addClass('is-selected');
        updateReorderButtons();
    }
    function cssEscape(v) { return (v || '').replace(/(["\\])/g, '\\$1'); }

    function loadStepDetail(stepid) {
        $('#step_md_global_stepid').val(stepid);
        $('#stepDetailPlaceholder').hide();
        ingShow();
        $.ajax({
            type: 'GET',
            url: '/piistep/modify?jobid=' + encodeURIComponent(jobid)
               + '&version=' + encodeURIComponent(version)
               + '&stepid=' + encodeURIComponent(stepid),
            dataType: 'html',
            error: function(req){
                ingHide();
                $('#errormodalbody').html(req.responseText);
                $('#errormodal').modal('show');
            },
            success: function(data){
                ingHide();
                $('#stepDetailSlot').html(data);
                selectRow(stepid);
                wireDetailCallbacks();
            }
        });
    }

    function loadNewForm() {
        $('#stepDetailPlaceholder').hide();
        ingShow();
        $.ajax({
            type: 'GET',
            url: '/piistep/register?jobid=' + encodeURIComponent(jobid)
               + '&version=' + encodeURIComponent(version),
            dataType: 'html',
            error: function(req){
                ingHide();
                $('#errormodalbody').html(req.responseText);
                $('#errormodal').modal('show');
            },
            success: function(data){
                ingHide();
                clearSelection();
                $('#stepDetailSlot').html(data);
                wireDetailCallbacks();
            }
        });
    }

    // Callbacks from detailform.jsp
    function wireDetailCallbacks() {
        window.onStepSaved = function(savedStepid, wasNew, message) {
            flashMsg(message || 'Saved', false);
            refreshList(savedStepid, function(){
                loadStepDetail(savedStepid);
            });
        };
        window.onStepRemoved = function(message) {
            flashMsg(message || 'Removed', false);
            $('#step_md_global_stepid').val('');
            refreshList(null, function(){
                $('#stepDetailSlot').html(
                    '<div class="step-detail-placeholder" id="stepDetailPlaceholder">' +
                    '<i class="fas fa-layer-group"></i><p>' +
                    '<spring:message code="step.placeholder" text="Select a step or click + New Step to add one."/>' +
                    '</p></div>'
                );
            });
        };
        window.onStepCancel = function() {
            var sid = $('#step_md_global_stepid').val();
            if (sid) loadStepDetail(sid);
            else {
                $('#stepDetailSlot').html(
                    '<div class="step-detail-placeholder" id="stepDetailPlaceholder">' +
                    '<i class="fas fa-layer-group"></i><p>' +
                    '<spring:message code="step.placeholder" text="Select a step or click + New Step to add one."/>' +
                    '</p></div>'
                );
            }
        };
    }

    // Row click (delegated on stable parent so new rows after refresh still work)
    $listPane.on('click', '#stepListBody tr', function(){
        var sid = $(this).attr('data-stepid') || $(this).data('stepid');
        if (!sid) return;
        if (window.stepDetailState && window.stepDetailState.dirty) {
            showConfirm('<spring:message code="step.discard_confirm" text="Discard changes?"/>', function(){
                loadStepDetail(sid);
            });
        } else {
            loadStepDetail(sid);
        }
    });

    // New Step button
    $('#btnNewStep').on('click', function(){
        if (window.stepDetailState && window.stepDetailState.dirty) {
            showConfirm('<spring:message code="step.discard_confirm" text="Discard changes?"/>', function(){
                loadNewForm();
            });
        } else {
            loadNewForm();
        }
    });

    // ---------- reorder ----------
    function updateReorderButtons() {
        var $sel = $tbody.find('tr.is-selected:visible');
        if (!$sel.length) {
            $btnUp.prop('disabled', true);
            $btnDown.prop('disabled', true);
            return;
        }
        var $visible = $tbody.find('tr:visible');
        var idx = $visible.index($sel);
        $btnUp.prop('disabled', idx <= 0);
        $btnDown.prop('disabled', idx >= $visible.length - 1);
    }

    function markOrderDirty(v) {
        orderDirty = !!v;
        $btnSaveOrder.toggleClass('is-dirty', orderDirty);
        if (orderDirty) {
            $btnSaveOrder.html('<spring:message code="step.save_order_dirty" text="Save Order"/>');
        } else {
            $btnSaveOrder.html('<spring:message code="step.save_order" text="Save Order"/>');
        }
    }

    function renumberSeq() {
        $tbody.find('tr').each(function(i){
            $(this).find('.col-seq').text(i + 1);
        });
    }

    $btnUp.on('click', function(){
        if ($(this).prop('disabled')) return;
        var $sel = $tbody.find('tr.is-selected');
        if (!$sel.length) return;
        var $prev = $sel.prevAll('tr:visible').first();
        if ($prev.length) {
            $sel.insertBefore($prev);
            renumberSeq();
            markOrderDirty(true);
            updateReorderButtons();
        }
    });

    $btnDown.on('click', function(){
        if ($(this).prop('disabled')) return;
        var $sel = $tbody.find('tr.is-selected');
        if (!$sel.length) return;
        var $next = $sel.nextAll('tr:visible').first();
        if ($next.length) {
            $sel.insertAfter($next);
            renumberSeq();
            markOrderDirty(true);
            updateReorderButtons();
        }
    });

    $btnSaveOrder.on('click', function(){
        if (!orderDirty) return;
        var payload = [];
        $tbody.find('tr').each(function(i){
            var sid = $(this).attr('data-stepid') || $(this).data('stepid');
            if (!sid) return;
            payload.push({
                stepseq: String(i + 1),
                jobid: jobid,
                version: version,
                stepid: sid
            });
        });
        if (!payload.length) { flashMsg('No steps to save', true); return; }
        ingShow();
        $.ajax({
            url: '/piistep/modify_seq',
            type: 'POST',
            contentType: 'application/json; charset=UTF-8',
            dataType: 'text',
            data: JSON.stringify(payload),
            beforeSend: function(xhr){
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(data){
                ingHide();
                markOrderDirty(false);
                flashMsg('<spring:message code="msg.order_saved" text="Order saved"/>', false);
            },
            error: function(req){
                ingHide();
                flashMsg(req.responseText || 'Failed', true);
            }
        });
    });

    // ---------- status message flash ----------
    function flashMsg(text, isError) {
        $msg.text(text).toggleClass('error', !!isError).addClass('visible');
        clearTimeout($msg.data('t'));
        $msg.data('t', setTimeout(function(){ $msg.removeClass('visible'); }, 2500));
    }

    // ---------- list refresh (re-fetch modifydialog HTML, swap list wrapper) ----------
    function refreshList(focusStepid, cb) {
        ingShow();
        $.ajax({
            type: 'GET',
            url: '/piistep/modifydialog?jobid=' + encodeURIComponent(jobid)
               + '&version=' + encodeURIComponent(version)
               + '&stepid=' + encodeURIComponent(focusStepid || ''),
            dataType: 'html',
            success: function(data){
                ingHide();
                var $wrap = $('<div>').append(data);
                var $newWrapper = $wrap.find('.step-list-wrapper').first();
                if ($newWrapper.length) {
                    $('.step-list-wrapper').html($newWrapper.html());
                }
                // Re-query tbody after swap (may have just been added for first time)
                $tbody = $('#stepListBody');
                markOrderDirty(false);
                applyFilter();
                if (focusStepid) selectRow(focusStepid);
                updateReorderButtons();
                if (typeof cb === 'function') cb();
            },
            error: function(req){
                ingHide();
                $('#errormodalbody').html(req.responseText);
                $('#errormodal').modal('show');
            }
        });
    }

    // ---------- close modal cleanup + refresh job view ----------
    $('body').off('hidden.bs.modal.stepmgmt').on('hidden.bs.modal.stepmgmt', '#stepmodal', function(){
        var gStepid = $('#step_md_global_stepid').val();
        if (typeof searchAction_stepdialog === 'function' && gStepid) {
            var url_view = "/piijob/modifyjoballinfo?jobid=" + encodeURIComponent(jobid) + "&version=" + encodeURIComponent(version) + "&";
            searchAction_stepdialog(null, url_view, "#content_home");
        }
    });

    // ---------- initial state ----------
    if (initialStepid) {
        selectRow(initialStepid);
        loadStepDetail(initialStepid);
    }
    updateReorderButtons();

    // ---------- global helper (kept for detailform callbacks that need legacy refresh) ----------
    window.refreshStepList = function(sid, cb){ refreshList(sid || null, cb); };
})();
</script>
