<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piiapprovaluserlist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-user-check"></i>
            <span><spring:message code="memu.piiapprovaluser_management" text="Approval Users"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.admin" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.piiapprovaluser_management" text="Approval Users"/></span>
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
                        <label class="member-search-label"><spring:message code="col.approvalid" text="Approval ID"/></label>
                        <select class="member-search-input" id="search1" name="search1" style="width: 200px;">
                            <option value="">All</option>
                            <c:forEach items="${Approvallist}" var="approval">
                                <option value="<c:out value="${approval.approvalid}"/>"
                                        <c:if test="${pageMaker.cri.search1 eq approval.approvalid}">selected</c:if>>
                                    <c:out value="${approval.approvalid}"/>
                                </option>
                            </c:forEach>
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
                <th style="width: 25%;"><spring:message code="col.approvalid" text="Approval ID"/></th>
                <th style="width: 30%;"><spring:message code="col.approvalname" text="Approval Name"/></th>
                <th style="width: 20%;"><spring:message code="col.approverid" text="Approver ID"/></th>
                <th style="width: 25%;"><spring:message code="col.approvername" text="Approver Name"/></th>
            </tr>
            </thead>
        </table>
        <div class="member-table-wrapper">
            <table class="member-table" id="listTable">
                <tbody>
                <c:forEach items="${list}" var="piiapprovaluser">
                    <tr data-seq="<c:out value="${piiapprovaluser.seq}"/>"
                        data-aprvlineid="<c:out value="${piiapprovaluser.aprvlineid}"/>">
                        <td style="width: 25%;"><c:out value="${piiapprovaluser.approvalid}"/></td>
                        <td style="width: 30%;"><c:out value="${piiapprovaluser.approvalname}"/></td>
                        <td style="width: 20%;"><c:out value="${piiapprovaluser.approverid}"/></td>
                        <td style="width: 25%;"><c:out value="${piiapprovaluser.approvername}"/></td>
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
                <h5 class="modal-title"><i class="fas fa-user-plus mr-2"></i><spring:message code="btn.register" text="Register Approval User"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="registerForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.approvalid" text="Approval ID"/> <span class="text-danger">*</span></label>
                        <select class="member-form-input" name="approvalid" required>
                            <c:forEach items="${Approvallist}" var="approval">
                                <option value="<c:out value="${approval.approvalid}"/>" data-name="<c:out value="${approval.approvalname}"/>">
                                    <c:out value="${approval.approvalid}"/> [<c:out value="${approval.approvalname}"/>]
                                </option>
                            </c:forEach>
                        </select>
                        <input type="hidden" name="approvalname" value="">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">
                            <spring:message code="col.approvername" text="Approver Name"/> <span class="text-danger">*</span>
                            <a href="javascript:openMemberSearchModal('register');" class="ml-2" style="color: #3b82f6;">
                                <i class="fas fa-search"></i> <spring:message code="etc.search" text="Search"/>
                            </a>
                        </label>
                        <input type="text" class="member-form-input" name="approvername_display" readonly placeholder="Click search to select approver">
                        <input type="hidden" name="approverid" value="">
                        <input type="hidden" name="approvername" value="">
                    </div>
                    <input type="hidden" name="seq" value="1">
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
                <h5 class="modal-title"><i class="fas fa-user-edit mr-2"></i><spring:message code="btn.modify" text="Modify Approval User"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="modifyForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.approvalid" text="Approval ID"/></label>
                        <input type="text" class="member-form-input" name="approvalid_display" readonly>
                        <input type="hidden" name="approvalid" value="">
                        <input type="hidden" name="approvalname" value="">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">
                            <spring:message code="col.approvername" text="Approver Name"/> <span class="text-danger">*</span>
                            <a href="javascript:openMemberSearchModal('modify');" class="ml-2" style="color: #3b82f6;">
                                <i class="fas fa-search"></i> <spring:message code="etc.search" text="Search"/>
                            </a>
                        </label>
                        <input type="text" class="member-form-input" name="approvername_display" readonly placeholder="Click search to select approver">
                        <input type="hidden" name="approverid" value="">
                        <input type="hidden" name="approvername" value="">
                        <input type="hidden" name="approverid_old" value="">
                        <input type="hidden" name="approvername_old" value="">
                    </div>
                    <input type="hidden" name="seq" value="">
                    <input type="hidden" name="aprvlineid" value="">
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

<!-- Member Search Modal -->
<div class="modal fade" id="memberSearchModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #475569 0%, #334155 100%); color: #fff; padding: 12px 20px;">
                <h5 class="modal-title"><i class="fas fa-users mr-2"></i><spring:message code="etc.search_member" text="Search Member"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="memberSearchModalBody" style="padding: 0; max-height: 500px; overflow-y: auto;">
                <!-- Member search content will be loaded here -->
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0; padding: 10px 20px;">
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> Close
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
    var currentModalTarget = 'register'; // 'register' or 'modify'

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Update approvalname when approvalid changes
        $('#registerForm [name="approvalid"]').on('change', function() {
            var selectedOption = $(this).find('option:selected');
            var approvalname = selectedOption.data('name');
            $('#registerForm [name="approvalname"]').val(approvalname);
        });
        // Initialize approvalname
        $('#registerForm [name="approvalid"]').trigger('change');

        // Double click to edit - get data from row
        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            if (!is_admin) return;

            var tr = $(this);
            var td = tr.children();
            var approvalid = td.eq(0).text().trim();
            var approvalname = td.eq(1).text().trim();
            var approverid = td.eq(2).text().trim();
            var approvername = td.eq(3).text().trim();
            var seq = tr.data('seq');
            var aprvlineid = tr.data('aprvlineid');

            if (approvalid) {
                var form = $('#modifyForm');
                form[0].reset();
                form.find('[name="approvalid"]').val(approvalid);
                form.find('[name="approvalid_display"]').val(approvalid);
                form.find('[name="approvalname"]').val(approvalname);
                form.find('[name="approverid"]').val(approverid);
                form.find('[name="approvername"]').val(approvername);
                form.find('[name="approvername_display"]').val(approvername ? approvername + ' (' + approverid + ')' : '');
                form.find('[name="approverid_old"]').val(approverid);
                form.find('[name="approvername_old"]').val(approvername);
                form.find('[name="seq"]').val(seq || '1');
                form.find('[name="aprvlineid"]').val(aprvlineid);
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
            $('#registerForm [name="approvalid"]').trigger('change');
            $('#registerModal').modal('show');
        });

        // Register save
        $('#btnRegisterSave').on('click', function () {
            var form = $('#registerForm');
            var approverid = form.find('[name="approverid"]').val().trim();

            if (!approverid) {
                alert('<spring:message code="msg.selectapprover" text="Please select an approver"/>');
                return;
            }

            var formData = {
                approvalid: form.find('[name="approvalid"]').val(),
                approvalname: form.find('[name="approvalname"]').val(),
                approverid: form.find('[name="approverid"]').val(),
                approvername: form.find('[name="approvername"]').val(),
                seq: form.find('[name="seq"]').val()
            };

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiapprovaluser/register",
                data: JSON.stringify(formData),
                contentType: "application/json; charset=UTF-8",
                dataType: "text",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data) {
                    ingHide();
                    if (data == "success") {
                        $('#registerModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        $("#GlobalSuccessMsgModal").modal("show");
                        setTimeout(function() {
                            searchAction(1);
                        }, 500);
                    } else {
                        $("#errormodalbody").html(data);
                        $("#errormodal").modal("show");
                    }
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
            var approverid = form.find('[name="approverid"]').val().trim();

            if (!approverid) {
                alert('<spring:message code="msg.selectapprover" text="Please select an approver"/>');
                return;
            }

            var formData = {
                aprvlineid: form.find('[name="aprvlineid"]').val(),
                approvalid: form.find('[name="approvalid"]').val(),
                approvalname: form.find('[name="approvalname"]').val(),
                approverid: form.find('[name="approverid"]').val(),
                approvername: form.find('[name="approvername"]').val(),
                seq: form.find('[name="seq"]').val()
            };

            var approverid_old = form.find('[name="approverid_old"]').val();
            var approvername_old = form.find('[name="approvername_old"]').val();

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiapprovaluser/modify?approverid_old=" + encodeURIComponent(approverid_old) + "&approvername_old=" + encodeURIComponent(approvername_old),
                data: JSON.stringify(formData),
                contentType: "application/json; charset=UTF-8",
                dataType: "text",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data) {
                    ingHide();
                    if (data == "success") {
                        $('#modifyModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        $("#GlobalSuccessMsgModal").modal("show");
                        setTimeout(function() {
                            searchAction(1);
                        }, 500);
                    } else {
                        $("#errormodalbody").html(data);
                        $("#errormodal").modal("show");
                    }
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
            if (!confirm('<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>')) {
                return;
            }

            var form = $('#modifyForm');
            var formData = {
                aprvlineid: form.find('[name="aprvlineid"]').val(),
                approvalid: form.find('[name="approvalid"]').val(),
                approvalname: form.find('[name="approvalname"]').val(),
                approverid: form.find('[name="approverid_old"]').val(),
                approvername: form.find('[name="approvername_old"]').val(),
                seq: form.find('[name="seq"]').val()
            };

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiapprovaluser/remove",
                data: JSON.stringify(formData),
                contentType: "application/json; charset=UTF-8",
                dataType: "text",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data) {
                    ingHide();
                    if (data == "success") {
                        $('#modifyModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        $("#GlobalSuccessMsgModal").modal("show");
                        setTimeout(function() {
                            searchAction(1);
                        }, 500);
                    } else {
                        $("#errormodalbody").html(data);
                        $("#errormodal").modal("show");
                    }
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });
    });

    // Open member search modal
    function openMemberSearchModal(target) {
        currentModalTarget = target;
        var pagenum = 1;
        var amount = 100;
        var search4 = "approval_" + target;

        $.ajax({
            type: "GET",
            url: "/piimember/diologsearchmember?pagenum=" + pagenum + "&amount=" + amount + "&search4=" + search4,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#memberSearchModalBody').html(data);
                $('#memberSearchModal').modal('show');
            }
        });
    }

    // Called from member search dialog when a member is selected
    function selectMemberForApproval(userid, username) {
        var targetForm = currentModalTarget === 'register' ? '#registerForm' : '#modifyForm';
        $(targetForm).find('[name="approverid"]').val(userid);
        $(targetForm).find('[name="approvername"]').val(username);
        $(targetForm).find('[name="approvername_display"]').val(username + ' (' + userid + ')');
        $('#memberSearchModal').modal('hide');
    }

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) url_search += "&search1=" + search1;

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/list?pagenum=" + pagenum + "&amount=" + amount + url_search,
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
