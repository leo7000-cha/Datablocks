<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piiapprovallinelist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-sitemap"></i>
            <span><spring:message code="memu.piiapprovalline_mgmt" text="Approval Lines"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.common" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.piiapprovalline_mgmt" text="Approval Lines"/></span>
        </div>
    </div>

    <!-- Header Section -->
    <div class="member-list-header">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <input type='hidden' name='search1' value='<c:out value="${pageMaker.cri.search1}"/>'>
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center" style="gap: 20px;">
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <label class="member-search-label"><spring:message code="etc.report_apply" text="Approval Request"/></label>
                        <select class="member-search-input" id="search2" name="search2" style="width: 200px;">
                            <option value="">All</option>
                            <c:forEach items="${Approvallist}" var="approval">
                                <option value="<c:out value="${approval.approvalid}"/>"
                                        <c:if test="${pageMaker.cri.search2 eq approval.approvalid}">selected</c:if>>
                                    <c:out value="${approval.approvalname}"/>
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
                        <button type="button" data-oper='removeline' class="btn-action-delete" disabled>
                            <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Remove"/>
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
                <th style="width: 5%;">
                    <input type="checkbox" id="checkall" style="width: 16px; height: 16px; cursor: pointer;">
                </th>
                <th style="width: 40%;"><spring:message code="col.approvalname" text="Approval Name"/></th>
                <th style="width: 55%;"><spring:message code="col.aprvlineid" text="Approval Line ID"/></th>
            </tr>
            </thead>
        </table>
        <div class="member-table-wrapper">
            <table class="member-table" id="listTable">
                <tbody>
                <c:forEach items="${list}" var="piiapprovalline">
                    <tr data-approvalid="<c:out value="${piiapprovalline.approvalid}"/>">
                        <td style="width: 5%;">
                            <input type="checkbox" class="chkBox" name="chkBox"
                                   style="width: 16px; height: 16px; cursor: pointer;">
                        </td>
                        <td style="width: 40%;"><c:out value="${piiapprovalline.approvalname}"/></td>
                        <td style="width: 55%;"><c:out value="${piiapprovalline.aprvlineid}"/></td>
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
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i><spring:message code="btn.register" text="Register Approval Line"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="registerForm">
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.approvalid" text="Approval Type"/> <span class="text-danger">*</span></label>
                        <select class="member-form-input" name="approvalid" required>
                            <c:forEach items="${Approvallist}" var="approval">
                                <option value="<c:out value="${approval.approvalid}"/>">
                                    <c:out value="${approval.approvalname}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <input type="hidden" name="approvalname" value="">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label"><spring:message code="col.aprvlineid" text="Approval Line ID"/> <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="aprvlineid" required
                               onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                               placeholder="Enter approval line ID">
                    </div>
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

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Check all checkbox
        $('#checkall').on('change', function () {
            var isChecked = $(this).prop('checked');
            $('input[name="chkBox"]').prop('checked', isChecked);
            checkedRowColorChange();
            updateDeleteButtonState();
        });

        // Individual checkbox change
        $('input[name="chkBox"]').on('change', function () {
            checkedRowColorChange();
            var allChecked = $('input[name="chkBox"]').length === $('input[name="chkBox"]:checked').length;
            $('#checkall').prop('checked', allChecked);
            updateDeleteButtonState();
        });

        // Double click to view step list
        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();

            var tr = $(this);
            var td = tr.children();
            var aprvlineid = td.eq(2).text().trim();

            if (aprvlineid) {
                searchAction(null, "aprvlineid=" + aprvlineid);
            }
        });

        // Search button
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        // Search dropdown change
        $("#search2").on("change", function (e) {
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
            var aprvlineid = form.find('[name="aprvlineid"]').val().trim();

            if (!aprvlineid) {
                dlmAlert('<spring:message code="msg.enteraprvlineid" text="Please enter approval line ID"/>');
                return;
            }

            var formData = {
                approvalid: form.find('[name="approvalid"]').val(),
                aprvlineid: form.find('[name="aprvlineid"]').val()
            };

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiapprovaluser/registerapprovalline",
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
                        showToast("처리가 완료되었습니다.", false);
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

        // Remove selected lines
        $("button[data-oper='removeline']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var checkbox = $("input:checkbox[name=chkBox]:checked");

            if (checkbox.length === 0) {
                dlmAlert("<spring:message code='msg.selecttosend' text='Select Approval line to remove'/>");
                return;
            }

            showConfirm('<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>', function() {
                var param = [];
                checkbox.each(function (i) {
                    var tr = $(this).closest('tr');
                    var td = tr.children();
                    var data = {
                        aprvlineid: td.eq(2).text().trim()
                    };
                    param.push(data);
                });

                ingShow();
                $.ajax({
                    url: "/piiapprovaluser/removeline",
                    dataType: "text",
                    contentType: "application/json; charset=UTF-8",
                    type: "POST",
                    data: JSON.stringify(param),
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                    },
                    success: function (data, textStatus, jqXHR) {
                        ingHide();
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

    // Highlight checked rows
    function checkedRowColorChange() {
        $('#listTable tbody tr').each(function () {
            var isChecked = $(this).find('input[name="chkBox"]').prop('checked');
            if (isChecked) {
                $(this).addClass('table-row-selected');
            } else {
                $(this).removeClass('table-row-selected');
            }
        });
    }

    // Update delete button state
    function updateDeleteButtonState() {
        var checkedCount = $('input[name="chkBox"]:checked').length;
        $("button[data-oper='removeline']").prop('disabled', checkedCount === 0);
    }

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "approvallinelist?";
        } else {
            url_view = "approvalsteplist?" + serchkeyno + "&";
        }

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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
