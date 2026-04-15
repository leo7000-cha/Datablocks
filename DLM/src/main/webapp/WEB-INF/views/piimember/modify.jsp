<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piimembermodify">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-user-edit"></i>
            <span><spring:message code="btn.modify" text="Modify User"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.common" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item"><spring:message code="memu.user_management" text="Users"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="btn.modify" text="Modify"/></span>
        </div>
    </div>

    <!-- Modify Form Card -->
    <div style="max-width: 520px; margin: 30px auto;">
        <div class="card shadow-sm">
            <div class="card-header member-modal-header-modify" style="padding: 12px 20px;">
                <h6 class="m-0 font-weight-bold text-white">
                    <i class="fas fa-key mr-2"></i><spring:message code="etc.pwdchange" text="Change Password"/>
                </h6>
            </div>
            <div class="card-body" style="padding: 24px;">
                <form id="modifyForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userid" text="Userid"/></label>
                        <input type="text" class="member-form-input" name="userid" value="<c:out value='${piimember.userid}'/>" readonly style="background-color: #f0f0f0;">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.username" text="Username"/></label>
                        <input type="text" class="member-form-input" name="username" value="<c:out value='${piimember.username}'/>" readonly style="background-color: #f0f0f0;">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_cd" text="Dept_Cd"/></label>
                        <input type="text" class="member-form-input" name="dept_cd" value="<c:out value='${piimember.dept_cd}'/>" readonly style="background-color: #f0f0f0;">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_name" text="Dept_Name"/></label>
                        <input type="text" class="member-form-input" name="dept_name" value="<c:out value='${piimember.dept_name}'/>" readonly style="background-color: #f0f0f0;">
                    </div>

                    <div class="member-form-divider"></div>

                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userpw" text="New Password"/> <span class="text-danger">*</span></label>
                        <input type="password" class="member-form-input" name="userpw" required autofocus placeholder="Enter new password">
                        <small class="member-form-hint"><spring:message code="etc.pwdmustbe" text="Must be composed of letters, numbers, and special symbols with 8 or more characters."/></small>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userpw2" text="Confirm Password"/> <span class="text-danger">*</span></label>
                        <input type="password" class="member-form-input" name="userpw2" required placeholder="Confirm password">
                    </div>

                    <input type="hidden" name="enabled" value="<c:out value='${piimember.enabled}'/>">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>

                <!-- Buttons -->
                <div style="display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px;">
                    <button type="button" class="btn-modal-cancel" id="btnCancel">
                        <i class="fas fa-times"></i> <spring:message code="btn.cancel" text="Cancel"/>
                    </button>
                    <button type="button" class="btn-modal-save" id="btnModifySave">
                        <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {

        // Save
        $('#btnModifySave').on('click', function () {
            var pw = $('#modifyForm [name="userpw"]').val();
            var pw2 = $('#modifyForm [name="userpw2"]').val();

            if (!pw || pw.length == 0) {
                $("#errormodalbody").html("<spring:message code='etc.pwdmustbe' text='Please enter a new password.'/>");
                $("#errormodal").modal("show");
                return;
            }

            if (!fn_pw_check()) return;

            var form = $('#modifyForm');
            var formData = {};
            form.serializeArray().forEach(function(item) {
                if (item.name !== 'userpw2') {
                    formData[item.name] = item.value;
                }
            });

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piimember/modify",
                data: JSON.stringify(formData),
                contentType: "application/json; charset=UTF-8",
                dataType: "text",
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (result) {
                    ingHide();
                    showToast("처리가 완료되었습니다.", false);
                    setTimeout(function() {
                        // Go to dashboard
                        $.ajax({
                            type: "GET",
                            url: "/piidashboard/dashboard",
                            dataType: "html",
                            success: function(data) {
                                $('#content_home').html(data);
                            }
                        });
                    }, 1000);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Cancel - back to dashboard
        $('#btnCancel').on('click', function () {
            $.ajax({
                type: "GET",
                url: "/piidashboard/dashboard",
                dataType: "html",
                success: function(data) {
                    $('#content_home').html(data);
                }
            });
        });

        // Enter key on password fields
        $('#modifyForm [name="userpw"], #modifyForm [name="userpw2"]').on('keypress', function(e) {
            if (e.keyCode === 13) {
                e.preventDefault();
                $('#btnModifySave').click();
            }
        });
    });

    // Password validation
    function fn_pw_check() {
        var pw = $('#modifyForm [name="userpw"]').val();
        var pw2 = $('#modifyForm [name="userpw2"]').val();
        var id = $('#modifyForm [name="userid"]').val();

        if (pw != pw2) {
            $("#errormodalbody").html("<spring:message code='etc.pwdnotmatch' text='Passwords do not match.'/>");
            $("#errormodal").modal("show");
            return false;
        }

        var pattern1 = /[0-9]/;
        var pattern2 = /[a-zA-Z]/;
        var pattern3 = /[~!@\#$%<>^&*]/;

        if (!pattern1.test(pw) || !pattern2.test(pw) || !pattern3.test(pw) || pw.length < 8 || pw.length > 50) {
            $("#errormodalbody").html("<spring:message code='etc.pwdmustbe' text='Must be composed of letters, numbers, and special symbols with 8 or more characters.'/>");
            $("#errormodal").modal("show");
            return false;
        }

        if (pw.indexOf(id) > -1) {
            $("#errormodalbody").html("<spring:message code='etc.pwdcannotincludeID' text='Password cannot include your ID.'/>");
            $("#errormodal").modal("show");
            return false;
        }

        return true;
    }
</script>
