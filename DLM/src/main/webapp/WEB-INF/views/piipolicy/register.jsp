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
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== REGISTER HEADER ========== -->
    <div class="detail-header">
        <div class="detail-header-left">
            <div class="detail-title-group">
                <span class="detail-id"><i class="fas fa-plus-circle"></i> New Policy</span>
                <span class="policy-badge badge-phase-checkout"><i class="fas fa-edit"></i> REGISTER</span>
            </div>
            <div class="detail-subtitle"><spring:message code="etc.registerNewPolicy" text="Register a new policy"/></div>
        </div>
        <div class="detail-header-actions">
            <sec:authorize access="hasAnyRole('ROLE_SEC','ROLE_ADMIN')">
                <button data-oper='register' class="btn btn-detail-save">
                    <i class="fas fa-save"></i> <spring:message code="btn.register" text="Register"/>
                </button>
            </sec:authorize>
            <button data-oper='list' class="btn btn-detail-list">
                <i class="fas fa-list"></i> List
            </button>
        </div>
    </div>

    <!-- ========== REGISTER CONTENT ========== -->
    <div class="detail-content">
        <form role="form" id="piipolicy_register_form" action="/piipolicy/register" method="post">
            <input type="hidden" name="version" value="1">
            <input type="hidden" name="status" value="ACTIVE">
            <input type="hidden" name="phase" value="CHECKOUT">
            <input type="hidden" name="reguserid" value='<sec:authentication property="principal.member.userid"/>'>
            <input type="hidden" name="upduserid" value='<sec:authentication property="principal.member.userid"/>'>
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="detail-grid">
                <!-- Left Column - Basic Info -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-info-circle"></i> <spring:message code="etc.basicInfo" text="Basic Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_id" text="Policy ID"/> <span class="required">*</span></div>
                        <div class="detail-value">
                            <input type="text" class="detail-input" name="policy_id" autofocus
                                   onkeyup="this.value=this.value.toUpperCase();"
                                   placeholder="Enter Policy ID">
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_name" text="Policy Name"/> <span class="required">*</span></div>
                        <div class="detail-value">
                            <input type="text" class="detail-input" name="policy_name"
                                   placeholder="Enter Policy Name">
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.version" text="Version"/></div>
                        <div class="detail-value detail-value-id">1</div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.phase" text="Phase"/></div>
                        <div class="detail-value">
                            <span class="policy-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> CHECKOUT</span>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.status" text="Status"/></div>
                        <div class="detail-value">
                            <span class="policy-badge badge-status-active">ACTIVE</span>
                        </div>
                    </div>
                </div>

                <!-- Right Column - Retention Info -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-clock"></i> <spring:message code="etc.retentionInfo" text="Retention Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.del_deadline" text="Delete Deadline"/> <span class="required">*</span></div>
                        <div class="detail-value">
                            <div class="detail-input-group">
                                <input type="text" class="detail-input detail-input-small" name="del_deadline"
                                       maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                       placeholder="0">
                                <select class="detail-select" name="del_deadline_unit">
                                    <option value="">Select</option>
                                    <option value="Y"><spring:message code="etc.year" text="Year"/></option>
                                    <option value="M"><spring:message code="etc.month" text="Month"/></option>
                                    <option value="D"><spring:message code="etc.day" text="Day"/></option>
                                    <option value="D_BIZ"><spring:message code="etc.day_biz" text="Biz Day"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.archive_flag" text="Archive Flag"/></div>
                        <div class="detail-value">
                            <select class="detail-select" id="archive_flag" name="archive_flag">
                                <option value="Y">YES</option>
                                <option value="N">NO</option>
                            </select>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.arc_del_deadline" text="Archive Deadline"/></div>
                        <div class="detail-value">
                            <div class="detail-input-group">
                                <input type="text" class="detail-input detail-input-small" name="arc_del_deadline"
                                       maxlength="3" onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                       placeholder="0">
                                <select class="detail-select" name="arc_del_deadline_unit">
                                    <option value="">Select</option>
                                    <option value="Y"><spring:message code="etc.year" text="Year"/></option>
                                    <option value="M"><spring:message code="etc.month" text="Month"/></option>
                                    <option value="D"><spring:message code="etc.day" text="Day"/></option>
                                    <option value="D_BIZ"><spring:message code="etc.day_biz" text="Biz Day"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.reguserid" text="Reg User"/></div>
                        <div class="detail-value"><sec:authentication property="principal.member.userid"/></div>
                    </div>
                </div>
            </div>

            <!-- Side-by-Side Textarea Sections -->
            <div class="detail-textarea-grid">
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-gavel"></i> <spring:message code="col.related_law" text="Related Law"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="related_law" spellcheck="false" placeholder="Enter related laws..."></textarea>
                    </div>
                </div>

                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-comment-alt"></i> <spring:message code="col.comments" text="Comments"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="comments" spellcheck="false" placeholder="Enter comments..."></textarea>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.policy" text="Policy Management"/>" + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "Register");

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
    });

    $(document).ready(function () {
        // Archive flag change handler
        $("#archive_flag").change(function () {
            if ($(this).val() == 'N') {
                $('#piipolicy_register_form [name="arc_del_deadline"]').val('');
                $('#piipolicy_register_form [name="arc_del_deadline_unit"]').val('');
            }
        });

        // Register button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var archive_flag = $('#piipolicy_register_form [name="archive_flag"]').val();

            // Validation
            if (isEmpty($('#piipolicy_register_form [name="policy_id"]').val())) {
                dlmAlert('<spring:message code="col.policy_id" text="Policy_Id"/> is mandatory');
                $('#piipolicy_register_form [name="policy_id"]').focus();
                return;
            }
            if (isEmpty($('#piipolicy_register_form [name="policy_name"]').val())) {
                dlmAlert('<spring:message code="col.policy_name" text="Policy_Name"/> is mandatory');
                $('#piipolicy_register_form [name="policy_name"]').focus();
                return;
            }
            if (isEmpty($('#piipolicy_register_form [name="del_deadline"]').val())) {
                dlmAlert('<spring:message code="col.del_deadline" text="Del_Deadline"/> is mandatory');
                $('#piipolicy_register_form [name="del_deadline"]').focus();
                return;
            }
            if (isEmpty($('#piipolicy_register_form [name="del_deadline_unit"]').val())) {
                dlmAlert('<spring:message code="col.del_deadline_unit" text="Del_Deadline_Unit"/> is mandatory');
                $('#piipolicy_register_form [name="del_deadline_unit"]').focus();
                return;
            }
            if (archive_flag == "Y" && isEmpty($('#piipolicy_register_form [name="arc_del_deadline"]').val())) {
                dlmAlert('<spring:message code="col.arc_del_deadline" text="Arc_Del_Deadline"/> is mandatory');
                $('#piipolicy_register_form [name="arc_del_deadline"]').focus();
                return;
            }
            if (archive_flag == "Y" && isEmpty($('#piipolicy_register_form [name="arc_del_deadline_unit"]').val())) {
                dlmAlert('<spring:message code="col.arc_del_deadline_unit" text="Arc_Del_Deadline_Unit"/> is mandatory');
                $('#piipolicy_register_form [name="arc_del_deadline_unit"]').focus();
                return;
            }

            // Convert policy_id to uppercase
            $('#piipolicy_register_form [name="policy_id"]').val($('#piipolicy_register_form [name="policy_id"]').val().toUpperCase());

            // Build form data, excluding empty arc_del_deadline fields
            var formData = {};
            $('#piipolicy_register_form').serializeArray().forEach(function(item) {
                // Skip empty arc_del_deadline fields (database expects integer or null, not empty string)
                if ((item.name === 'arc_del_deadline' || item.name === 'arc_del_deadline_unit') && item.value === '') {
                    return; // Skip this field
                }
                formData[item.name] = item.value;
            });

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piipolicy/register",
                dataType: "html",
                data: formData,
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

        // List button
        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
            var amount = $('#searchForm [name="amount"]').val() || 100;
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";

            if (!isEmpty(search1)) url_search += "&search1=" + search1;
            if (!isEmpty(search2)) url_search += "&search2=" + search2;

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
    });
</script>
