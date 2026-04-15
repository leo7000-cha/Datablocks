<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piiauthlist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-user-shield"></i>
            <span><spring:message code="memu.auth_management" text="Permissions"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.common" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.auth_management" text="Permissions"/></span>
        </div>
    </div>

    <!-- Header Section -->
    <div class="member-list-header">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
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
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search2}"/>' placeholder="Search Name...">
                    </div>
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <label class="member-search-label"><spring:message code="col.auth" text="Auth"/></label>
                        <select class="member-search-input" id="search3" name="search3" style="width: 130px;">
                            <option value="">All</option>
                            <option value="ROLE_IT" <c:if test="${pageMaker.cri.search3 eq 'ROLE_IT'}">selected</c:if>>ROLE_IT</option>
                            <option value="ROLE_BIZ" <c:if test="${pageMaker.cri.search3 eq 'ROLE_BIZ'}">selected</c:if>>ROLE_BIZ</option>
                            <option value="ROLE_SEC" <c:if test="${pageMaker.cri.search3 eq 'ROLE_SEC'}">selected</c:if>>ROLE_SEC</option>
                            <option value="ROLE_ADMIN" <c:if test="${pageMaker.cri.search3 eq 'ROLE_ADMIN'}">selected</c:if>>ROLE_ADMIN</option>
                            <option value="ROLE_USER" <c:if test="${pageMaker.cri.search3 eq 'ROLE_USER'}">selected</c:if>>ROLE_USER</option>
                        </select>
                    </div>
                </div>
                <div class="d-flex align-items-center" style="gap: 8px;">
                    <button type="button" data-oper='search' class="btn-action-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                        <button type="button" data-oper='register' class="btn-action-register">
                            <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                        </button>
                    </sec:authorize>
                </div>
            </div>
        </form>
    </div>

    <!-- Table Section -->
    <div class="member-table-container">
        <table class="member-table member-table-header">
            <thead>
            <tr>
                <th style="width: 35%;"><spring:message code="col.userid" text="Userid"/></th>
                <th style="width: 35%;"><spring:message code="col.username" text="Username"/></th>
                <th style="width: 30%;"><spring:message code="col.auth" text="Auth"/></th>
            </tr>
            </thead>
        </table>
        <div class="member-table-wrapper">
            <table class="member-table" id="listTable">
                <tbody>
                <c:forEach items="${list}" var="member">
                    <tr>
                        <td style="width: 35%;"><c:out value="${member.userid}"/></td>
                        <td style="width: 35%;"><c:out value="${member.username}"/></td>
                        <td style="width: 30%;"><c:out value="${member.auth}"/></td>
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
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 420px;">
        <div class="modal-content">
            <div class="modal-header member-modal-header">
                <h5 class="modal-title"><i class="fas fa-user-shield mr-2"></i><spring:message code="btn.register" text="Register Auth"/></h5>
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
                        <label class="member-form-label"><spring:message code="col.auth" text="Auth"/> <span class="text-danger">*</span></label>
                        <select class="member-form-input" name="auth" required>
                            <option value="ROLE_IT">ROLE_IT</option>
                            <option value="ROLE_BIZ">ROLE_BIZ</option>
                            <option value="ROLE_SEC">ROLE_SEC</option>
                            <option value="ROLE_ADMIN">ROLE_ADMIN</option>
                            <option value="ROLE_USER">ROLE_USER</option>
                        </select>
                    </div>
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
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 420px;">
        <div class="modal-content">
            <div class="modal-header member-modal-header-modify">
                <h5 class="modal-title"><i class="fas fa-user-edit mr-2"></i><spring:message code="btn.modify" text="Modify Auth"/></h5>
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
                        <label class="member-form-label"><spring:message code="col.auth" text="Auth"/> <span class="text-danger">*</span></label>
                        <select class="member-form-input" name="authtochange" required>
                            <option value="ROLE_IT">ROLE_IT</option>
                            <option value="ROLE_BIZ">ROLE_BIZ</option>
                            <option value="ROLE_SEC">ROLE_SEC</option>
                            <option value="ROLE_ADMIN">ROLE_ADMIN</option>
                            <option value="ROLE_USER">ROLE_USER</option>
                        </select>
                    </div>
                    <input type="hidden" name="auth" value="">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer">
                <button type="button" class="btn-modal-delete" id="btnDelete" style="margin-right: auto;">
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
            var auth = td.eq(2).text().trim();

            if (userid) {
                var form = $('#modifyForm');
                form[0].reset();
                form.find('[name="userid"]').val(userid);
                form.find('[name="auth"]').val(auth);
                form.find('[name="authtochange"]').val(auth);
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

            if (!userid) {
                dlmAlert('<spring:message code="msg.enteruserid" text="Please enter user ID"/>');
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiauth/register",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#registerModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
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
            var form = $('#modifyForm');

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiauth/modify",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#modifyModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
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

        // Delete
        $('#btnDelete').on('click', function () {
            showConfirm('<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>', function() {
                var form = $('#modifyForm');
                ingShow();
                $.ajax({
                    type: "POST",
                    url: "/piiauth/remove",
                    data: form.serialize(),
                    dataType: "html",
                    success: function (data) {
                        ingHide();
                        $('#modifyModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        showToast("처리가 완료되었습니다.", false);
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
    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var search3 = $('#searchForm [name="search3"]').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiauth/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
</script>
