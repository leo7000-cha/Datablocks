<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Forms -->
<form style="display:none;" role="form" id="searchForm">
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

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== MODIFY HEADER ========== -->
    <div class="detail-header">
        <div class="detail-header-left">
            <div class="detail-title-group">
                <span class="detail-id"><c:out value="${piipolicy.policy_id}"/></span>
                <span class="policy-badge badge-phase-checkout"><i class="fas fa-edit"></i> EDITING</span>
                <span class="cell-version">v<c:out value="${piipolicy.version}"/></span>
            </div>
            <div class="detail-subtitle"><c:out value="${piipolicy.policy_name}"/></div>
        </div>
        <div class="detail-header-actions">
            <sec:authorize access="hasAnyRole('ROLE_SEC','ROLE_ADMIN')">
                <button data-oper='modify' class="btn btn-detail-save">
                    <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                </button>
                <c:if test="${piipolicy.phase eq 'CHECKOUT'}">
                    <button data-oper='delete' class="btn btn-detail-delete">
                        <i class="fas fa-trash-alt"></i> <spring:message code="btn.delete" text="Delete"/>
                    </button>
                </c:if>
            </sec:authorize>
            <c:if test="${piipolicy.phase eq 'CHECKOUT'}">
                <button data-oper='checkin' class="btn btn-detail-checkin">
                    <i class="fas fa-check-circle"></i> <spring:message code="etc.requestforcheckin" text="Request Check-In"/>
                </button>
            </c:if>
            <button data-oper='list' class="btn btn-detail-list">
                <i class="fas fa-list"></i> List
            </button>
        </div>
    </div>

    <!-- ========== MODIFY CONTENT ========== -->
    <div class="detail-content">
        <form role="form" id="piipolicy_modify_form">
            <input type="hidden" name="policy_id" value='<c:out value="${piipolicy.policy_id}"/>'>
            <input type="hidden" name="version" value='<c:out value="${piipolicy.version}"/>'>
            <input type="hidden" name="phase" value='<c:out value="${piipolicy.phase}"/>'>
            <input type="hidden" name="regdate" value='<c:out value="${piipolicy.regdate}"/>'>
            <input type="hidden" name="upddate" value='<c:out value="${piipolicy.upddate}"/>'>
            <input type="hidden" name="reguserid" value='<c:out value="${piipolicy.reguserid}"/>'>
            <input type="hidden" name="upduserid" value='<sec:authentication property="principal.member.userid"/>'>
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="detail-grid">
                <!-- Left Column - Basic Info -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-info-circle"></i> <spring:message code="etc.basicInfo" text="Basic Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_id" text="Policy ID"/></div>
                        <div class="detail-value detail-value-id"><c:out value="${piipolicy.policy_id}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_name" text="Policy Name"/></div>
                        <div class="detail-value">
                            <input type="text" class="detail-input" name="policy_name" value='<c:out value="${piipolicy.policy_name}"/>'>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.version" text="Version"/></div>
                        <div class="detail-value detail-value-id"><c:out value="${piipolicy.version}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.phase" text="Phase"/></div>
                        <div class="detail-value">
                            <span class="policy-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> <c:out value="${piipolicy.phase}"/></span>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.status" text="Status"/></div>
                        <div class="detail-value">
                            <select class="detail-select" name="status">
                                <option value="ACTIVE" <c:if test="${piipolicy.status eq 'ACTIVE'}">selected</c:if>>ACTIVE</option>
                                <option value="INACTIVE" <c:if test="${piipolicy.status eq 'INACTIVE'}">selected</c:if>>INACTIVE</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Right Column - Retention Info -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-clock"></i> <spring:message code="etc.retentionInfo" text="Retention Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.del_deadline" text="Delete Deadline"/></div>
                        <div class="detail-value">
                            <div class="detail-input-group">
                                <input type="text" class="detail-input detail-input-small" name="del_deadline"
                                       maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                       value='<c:out value="${piipolicy.del_deadline}"/>'>
                                <select class="detail-select" name="del_deadline_unit">
                                    <option value=""></option>
                                    <option value="Y" <c:if test="${piipolicy.del_deadline_unit eq 'Y'}">selected</c:if>><spring:message code="etc.year" text="Year"/></option>
                                    <option value="M" <c:if test="${piipolicy.del_deadline_unit eq 'M'}">selected</c:if>><spring:message code="etc.month" text="Month"/></option>
                                    <option value="D" <c:if test="${piipolicy.del_deadline_unit eq 'D'}">selected</c:if>><spring:message code="etc.day" text="Day"/></option>
                                    <option value="D_BIZ" <c:if test="${piipolicy.del_deadline_unit eq 'D_BIZ'}">selected</c:if>><spring:message code="etc.day_biz" text="Biz Day"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.archive_flag" text="Archive Flag"/></div>
                        <div class="detail-value">
                            <select class="detail-select" id="archive_flag" name="archive_flag">
                                <option value="Y" <c:if test="${piipolicy.archive_flag eq 'Y'}">selected</c:if>>YES</option>
                                <option value="N" <c:if test="${piipolicy.archive_flag eq 'N'}">selected</c:if>>NO</option>
                            </select>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.arc_del_deadline" text="Archive Deadline"/></div>
                        <div class="detail-value">
                            <div class="detail-input-group">
                                <input type="text" class="detail-input detail-input-small" name="arc_del_deadline"
                                       maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                       value='<c:out value="${piipolicy.arc_del_deadline}"/>'>
                                <select class="detail-select" name="arc_del_deadline_unit">
                                    <option value=""></option>
                                    <option value="Y" <c:if test="${piipolicy.arc_del_deadline_unit eq 'Y'}">selected</c:if>><spring:message code="etc.year" text="Year"/></option>
                                    <option value="M" <c:if test="${piipolicy.arc_del_deadline_unit eq 'M'}">selected</c:if>><spring:message code="etc.month" text="Month"/></option>
                                    <option value="D" <c:if test="${piipolicy.arc_del_deadline_unit eq 'D'}">selected</c:if>><spring:message code="etc.day" text="Day"/></option>
                                    <option value="D_BIZ" <c:if test="${piipolicy.arc_del_deadline_unit eq 'D_BIZ'}">selected</c:if>><spring:message code="etc.day_biz" text="Biz Day"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.regdate" text="Reg Date"/></div>
                        <div class="detail-value detail-value-date"><c:out value="${piipolicy.regdate}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.reguserid" text="Reg User"/></div>
                        <div class="detail-value"><c:out value="${piipolicy.reguserid}"/></div>
                    </div>
                </div>
            </div>

            <!-- Side-by-Side Textarea Sections -->
            <div class="detail-textarea-grid">
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-gavel"></i> <spring:message code="col.related_law" text="Related Law"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="related_law" spellcheck="false"><c:out value="${piipolicy.related_law}"/></textarea>
                    </div>
                </div>

                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-comment-alt"></i> <spring:message code="col.comments" text="Comments"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="comments" spellcheck="false"><c:out value="${piipolicy.comments}"/></textarea>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Check-In Request Modal -->
<div class="modal fade" id="requestmodal" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content modal-content-modern">
            <div class="modal-header modal-header-modern">
                <h5 class="modal-title"><i class="fas fa-check-circle"></i> <spring:message code="etc.requestforcheckin" text="Request for Check-In"/></h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="modal-form-group">
                    <label class="modal-label"><spring:message code="etc.aprvline" text="Approval Line"/></label>
                    <div id="approvallineselect"></div>
                </div>
                <div class="modal-form-group">
                    <label class="modal-label"><spring:message code="msg.msginputapplyreason" text="Please enter the details of the reason for the change"/></label>
                    <textarea class="detail-textarea detail-textarea-large" name="reqreason" id="reqreason" spellcheck="false"></textarea>
                </div>
            </div>
            <div class="modal-footer modal-footer-modern">
                <button type="button" class="btn btn-detail-list" data-dismiss="modal">Cancel</button>
                <button data-oper='request' class="btn btn-detail-save">
                    <i class="fas fa-paper-plane"></i> Request
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteConfirmModal" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-modern">
            <div class="modal-header modal-header-delete">
                <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> <spring:message code="etc.deleteconfirm" text="Delete Confirmation"/></h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="delete-confirm-content">
                    <div class="delete-confirm-icon">
                        <i class="fas fa-trash-alt"></i>
                    </div>
                    <div class="delete-confirm-message">
                        <p class="delete-confirm-title"><spring:message code="msg.deleteversiononly" text="Only this version will be deleted."/></p>
                        <div class="delete-confirm-details">
                            <div class="delete-detail-item">
                                <span class="delete-detail-label">Policy ID:</span>
                                <span class="delete-detail-value" id="deleteTargetPolicyId"></span>
                            </div>
                            <div class="delete-detail-item">
                                <span class="delete-detail-label">Version:</span>
                                <span class="delete-detail-value delete-version-badge" id="deleteTargetVersion"></span>
                            </div>
                        </div>
                        <p class="delete-confirm-notice"><i class="fas fa-info-circle"></i> <spring:message code="msg.checkinversionkept" text="Previously checked-in versions will be kept."/></p>
                    </div>
                </div>
            </div>
            <div class="modal-footer modal-footer-modern">
                <button type="button" class="btn btn-detail-list" data-dismiss="modal">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button data-oper='confirmDelete' class="btn btn-detail-delete">
                    <i class="fas fa-trash-alt"></i> <spring:message code="btn.delete" text="Delete"/>
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.policy" text="Policy Management"/>" + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "Modify");

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
    });

    $(document).ready(function () {
        // Archive flag change handler
        $("#archive_flag").change(function () {
            if ($(this).val() == 'N') {
                $('#piipolicy_modify_form [name="arc_del_deadline"]').val('');
                $('#piipolicy_modify_form [name="arc_del_deadline_unit"]').val('');
            }
        });

        // Save button
        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var archive_flag = $('#piipolicy_modify_form [name="archive_flag"]').val();
            var del_deadline = $('#piipolicy_modify_form [name="del_deadline"]').val();
            var del_deadline_unit = $('#piipolicy_modify_form [name="del_deadline_unit"]').val();
            var arc_del_deadline = $('#piipolicy_modify_form [name="arc_del_deadline"]').val();
            var arc_del_deadline_unit = $('#piipolicy_modify_form [name="arc_del_deadline_unit"]').val();

            if (isEmpty(del_deadline) || isEmpty(del_deadline_unit)) {
                dlmAlert("<spring:message code="msg.policy_del_deadline" text="Del_deadline is mandatory"/>");
                return;
            }

            if (archive_flag == "Y" && (isEmpty(arc_del_deadline) || isEmpty(arc_del_deadline_unit))) {
                dlmAlert("<spring:message code="msg.policy_arc_del_deadline" text="Arc_del_deadline is mandatory"/>");
                return;
            }

            var formData = {};
            $('#piipolicy_modify_form').serializeArray().forEach(function(item) {
                formData[item.name] = item.value;
            });

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piipolicy/modify",
                dataType: "text",
                data: JSON.stringify(formData),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    showToast("처리가 완료되었습니다.", false);
                }
            });
        });

        // List button
        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var searchParams = getSearchParams();

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/list?" + searchParams,
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
        });

        // Delete button - show confirmation modal
        $("button[data-oper='delete']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var policy_id = $('#piipolicy_modify_form [name="policy_id"]').val();
            var version = $('#piipolicy_modify_form [name="version"]').val();

            // Set modal content
            $('#deleteTargetPolicyId').text(policy_id);
            $('#deleteTargetVersion').text('v' + version);

            // Show modal
            $("#deleteConfirmModal").modal("show");
        });

        // Confirm delete button in modal
        $("button[data-oper='confirmDelete']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            // Close modal
            $("#deleteConfirmModal").modal("hide");
            $('body').removeClass('modal-open');
            $('.modal-backdrop').remove();

            var policy_id = $('#piipolicy_modify_form [name="policy_id"]').val();
            var version = $('#piipolicy_modify_form [name="version"]').val();
            var searchParams = getSearchParams();

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piipolicy/remove",
                data: {
                    policy_id: policy_id,
                    version: version,
                    "${_csrf.parameterName}": "${_csrf.token}"
                },
                dataType: "text",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    // Go back to list
                    $.ajax({
                        type: "GET",
                        url: "/piipolicy/list?" + searchParams,
                        dataType: "html",
                        error: function (request, error) {
                            $("#errormodalbody").html(request.responseText);
                            $("#errormodal").modal("show");
                        },
                        success: function (data) {
                            $('#content_home').html(data);
                            showToast("처리가 완료되었습니다.", false);
                        }
                    });
                }
            });
        });

        // Check-in button - open modal
        $("button[data-oper='checkin']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var aprovalid = "POLICY_APPROVAL";
            $.ajax({
                type: "GET",
                url: "/piiapprovaluser/approvallinebyappidlist?approvalid=" + aprovalid,
                dataType: "html",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#approvallineselect').html(data);
                }
            });
            $('#reqreason').val("");
            $("#requestmodal").modal();
        });

        // Request button in modal
        $("button[data-oper='request']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            // 모달 완전히 닫기 및 backdrop 제거
            $("#requestmodal").modal("hide");
            $('body').removeClass('modal-open');
            $('.modal-backdrop').remove();

            requestApproval();
        });
    });

    function requestApproval() {
        if ($('#piipolicy_modify_form [name="phase"]').val() != "CHECKOUT") {
            dlmAlert("The policy is not Checkout status");
            return;
        }

        var aprvlineid = $('input[name="aprvlineid"]:checked').val();
        if (isEmpty(aprvlineid)) {
            dlmAlert("<spring:message code='msg.select_approval_line' text='Please select an approval line'/>");
            return;
        }

        var policy_id = $('#piipolicy_modify_form [name="policy_id"]').val();
        var version = $('#piipolicy_modify_form [name="version"]').val();
        var reqreason = $('#reqreason').val();

        var searchParams = getSearchParams();

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piipolicy/checkin?policy_id=" + policy_id + "&version=" + version + "&reqreason=" + encodeURIComponent(reqreason) + "&aprvlineid=" + aprvlineid + "&" + searchParams,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#content_home').html(data);
                showToast("처리가 완료되었습니다.", false);
            }
        });
    }

    function getSearchParams() {
        var params = [];
        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;

        params.push("pagenum=" + pagenum);
        params.push("amount=" + amount);

        for (var i = 1; i <= 8; i++) {
            var val = $('#searchForm [name="search' + i + '"]').val();
            if (val) {
                params.push("search" + i + "=" + encodeURIComponent(val));
            }
        }
        return params.join("&");
    }
</script>
