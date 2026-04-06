<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piimemberlist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-users"></i>
            <span><spring:message code="memu.user_management" text="Users"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.common" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.user_management" text="Users"/></span>
        </div>
    </div>

    <!-- Header Section -->
    <div class="member-list-header">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center" style="gap: 20px;">
                        <div class="d-flex align-items-center" style="gap: 8px;">
                            <label class="member-search-label"><spring:message code="col.userid" text="Userid"/></label>
                            <input type="text" class="member-search-input" id="search1" name="search1"
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search1}"/>' placeholder="Search ID...">
                        </div>
                        <div class="d-flex align-items-center" style="gap: 8px;">
                            <label class="member-search-label"><spring:message code="col.username" text="Username"/></label>
                            <input type="text" class="member-search-input" id="search2" name="search2"
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search2}"/>' placeholder="Search Name...">
                        </div>
                    </div>
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <button type="button" data-oper='search' class="btn-action-search">
                            <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                        </button>
                        <sec:authorize access="hasRole('ROLE_ADMIN')">
                            <button type="button" data-oper='register' class="btn-action-register">
                                <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                            </button>
                        </sec:authorize>
                    </div>
                </div>
            </sec:authorize>
        </form>
    </div>

    <!-- Table Section -->
    <div class="member-table-container">
        <table class="member-table member-table-header">
            <thead>
            <tr>
                <th style="width: 15%;"><spring:message code="col.userid" text="Userid"/></th>
                <th style="width: 15%;"><spring:message code="col.username" text="Username"/></th>
                <th style="width: 12%;"><spring:message code="col.dept_cd" text="Dept_Cd"/></th>
                <th style="width: 18%;"><spring:message code="col.dept_name" text="Dept_Name"/></th>
                <th style="width: 18%;"><spring:message code="col.regdate" text="Regdate"/></th>
                <th style="width: 18%;"><spring:message code="col.updatedate" text="Updatedate"/></th>
                <th class="th-hidden"><spring:message code="col.enabled" text="Enabled"/></th>
            </tr>
            </thead>
        </table>
        <div class="member-table-wrapper">
            <table class="member-table" id="listTable">
                <tbody>
                <c:forEach items="${list}" var="member">
                    <tr data-userid="${member.userid}">
                        <td style="width: 15%;"><c:out value="${member.userid}"/></td>
                        <td style="width: 15%;"><c:out value="${member.username}"/></td>
                        <td style="width: 12%;"><c:out value="${member.dept_cd}"/></td>
                        <td style="width: 18%;"><c:out value="${member.dept_name}"/></td>
                        <td style="width: 18%;"><c:out value="${member.regdate}"/></td>
                        <td style="width: 18%;"><c:out value="${member.updatedate}"/></td>
                        <td class="td-hidden">
                            <c:choose>
                                <c:when test="${member.enabled eq '1'}">Y</c:when>
                                <c:otherwise>N</c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pager -->
    <div class="member-pager">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>

<!-- Register Modal -->
<div class="modal fade" id="registerModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 480px;">
        <div class="modal-content">
            <div class="modal-header member-modal-header">
                <h5 class="modal-title"><i class="fas fa-user-plus mr-2"></i><spring:message code="btn.register" text="Register User"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="registerForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userid" text="Userid"/> <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="userid" required autofocus placeholder="Enter user ID">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.username" text="Username"/> <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="username" required placeholder="Enter username">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_cd" text="Dept_Cd"/></label>
                        <input type="text" class="member-form-input" name="dept_cd" placeholder="Enter department code">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_name" text="Dept_Name"/></label>
                        <input type="text" class="member-form-input" name="dept_name" placeholder="Enter department name">
                    </div>
                    <div class="member-form-info">
                        <i class="fas fa-info-circle"></i> <spring:message code="msg.initialpwd" text="The initial pwd is '#USERID'"/>
                    </div>
                    <input type="hidden" name="userpw" value="">
                    <input type="hidden" name="enabled" value="1">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer">
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> <spring:message code="btn.cancel" text="Cancel"/>
                </button>
                <button type="button" class="btn-modal-save" id="btnRegisterSave">
                    <i class="fas fa-save"></i> <spring:message code="btn.register" text="Register"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modify Modal -->
<div class="modal fade" id="modifyModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 480px;">
        <div class="modal-content">
            <div class="modal-header member-modal-header-modify">
                <h5 class="modal-title"><i class="fas fa-user-edit mr-2"></i><spring:message code="btn.modify" text="Modify User"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="modifyForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userid" text="Userid"/></label>
                        <input type="text" class="member-form-input" name="userid" readonly>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.username" text="Username"/> <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="username" required>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_cd" text="Dept_Cd"/></label>
                        <input type="text" class="member-form-input" name="dept_cd">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.dept_name" text="Dept_Name"/></label>
                        <input type="text" class="member-form-input" name="dept_name">
                    </div>
                    <div class="member-form-divider"></div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userpw" text="Password"/></label>
                        <input type="password" class="member-form-input" name="userpw" placeholder="Leave blank to keep current">
                        <small class="member-form-hint"><spring:message code="etc.pwdmustbe" text="Must be composed of letters, numbers, and special symbols with 8 or more characters."/></small>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.userpw2" text="Confirm Password"/></label>
                        <input type="password" class="member-form-input" name="userpw2" placeholder="Confirm password">
                    </div>
                    <input type="hidden" name="enabled" value="">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer">
                <button type="button" class="btn-modal-reset" id="btnInitPwd">
                    <i class="fas fa-key"></i> <spring:message code="etc.initpwd" text="Init PWD"/>
                </button>
                <button type="button" class="btn-modal-delete" id="btnDelete">
                    <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Delete"/>
                </button>
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> <spring:message code="btn.cancel" text="Cancel"/>
                </button>
                <button type="button" class="btn-modal-save" id="btnModifySave">
                    <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Double click to edit - get data from row
        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            if (!is_admin) return;

            var tr = $(this);
            var td = tr.children();
            var userid = td.eq(0).text().trim();
            var username = td.eq(1).text().trim();
            var dept_cd = td.eq(2).text().trim();
            var dept_name = td.eq(3).text().trim();

            if (userid) {
                var form = $('#modifyForm');
                form[0].reset();
                form.find('[name="userid"]').val(userid);
                form.find('[name="username"]').val(username);
                form.find('[name="dept_cd"]').val(dept_cd);
                form.find('[name="dept_name"]').val(dept_name);
                form.find('[name="enabled"]').val('1');
                $('#modifyModal').modal('show');
            }
        });

        // Search button
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        // Register button - open modal
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#registerForm')[0].reset();
            $('#registerModal').modal('show');
        });

        // Register save
        $('#btnRegisterSave').on('click', function () {
            var form = $('#registerForm');
            var userid = form.find('[name="userid"]').val().trim();
            var username = form.find('[name="username"]').val().trim();

            if (!userid) {
                alert('<spring:message code="msg.enteruserid" text="Please enter user ID"/>');
                return;
            }
            if (!username) {
                alert('<spring:message code="msg.enterusername" text="Please enter username"/>');
                return;
            }

            form.find('[name="userpw"]').val('#' + userid);

            var formData = {};
            form.serializeArray().forEach(function(item) {
                formData[item.name] = item.value;
            });

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piimember/register",
                data: form.serialize(),
                dataType: "html",
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data) {
                    ingHide();
                    $('#registerModal').modal('hide');
                    // Remove backdrop and body class before refresh
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() {
                        searchAction(1);
                    }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Modify save
        $('#btnModifySave').on('click', function () {
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
                    $('#modifyModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() {
                        searchAction(1);
                    }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Initialize password
        $('#btnInitPwd').on('click', function () {
            var userid = $('#modifyForm [name="userid"]').val();
            var newPwd = '#' + userid;

            if (!confirm('<spring:message code="msg.initpwdconfirm" text="Reset password to"/> ' + newPwd + '?')) {
                return;
            }

            $('#modifyForm [name="userpw"]').val(newPwd);
            $('#modifyForm [name="userpw2"]').val(newPwd);
            $('#btnModifySave').click();
        });

        // Delete user
        $('#btnDelete').on('click', function () {
            if (!confirm('<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>')) {
                return;
            }

            var form = $('#modifyForm');
            ingShow();
            $.ajax({
                type: "POST",
                url: "/piimember/remove",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#modifyModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() {
                        searchAction(1);
                    }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piimember/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
    }

    // Password validation
    function fn_pw_check() {
        var pw = $('#modifyForm [name="userpw"]').val();
        var pw2 = $('#modifyForm [name="userpw2"]').val();
        var id = $('#modifyForm [name="userid"]').val();

        if (pw.length == 0) return true;

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
