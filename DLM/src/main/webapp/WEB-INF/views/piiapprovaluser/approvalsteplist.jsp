<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div class="member-list-container" id="piiapprovalsteplist">
    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-tasks"></i>
            <span><spring:message code="col.approvallinestep" text="Approval Steps"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.admin" text="Admin"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item"><spring:message code="memu.piiapprovalline_mgmt" text="Approval Lines"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="col.approvallinestep" text="Steps"/></span>
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
                        <label class="member-search-label"><spring:message code="col.aprvlineid" text="Approval Line"/></label>
                        <select class="member-search-input" id="search2" name="search2" style="width: 200px;">
                            <option value="">Select</option>
                            <c:forEach items="${approvallinelist}" var="approvalline">
                                <option value="<c:out value="${approvalline.aprvlineid}"/>"
                                        <c:if test="${pageMaker.cri.search2 eq approvalline.aprvlineid}">selected</c:if>>
                                    <c:out value="${approvalline.aprvlineid}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="d-flex align-items-center" style="gap: 8px;">
                    <button type="button" data-oper='search' class="btn-action-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button type="button" data-oper='backtolist' class="btn-action-secondary">
                        <i class="fas fa-list"></i> <spring:message code="btn.list" text="List"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Step Info Card -->
    <div class="step-info-card">
        <div class="step-info-header">
            <div class="step-info-title">
                <i class="fas fa-stream mr-2"></i>
                <spring:message code="col.approvallinestep" text="Approval Line Step"/>
                <c:if test="${not empty approvalline.aprvlineid}">
                    <span class="step-info-badge"><c:out value="${approvalline.aprvlineid}"/></span>
                </c:if>
            </div>
            <div class="step-info-actions">
                <div class="step-move-buttons">
                    <button type="button" class="btn-step-move" onclick="rowMoveEvent('up');" title="Move Up">
                        <i class="fas fa-chevron-up"></i>
                    </button>
                    <button type="button" class="btn-step-move" onclick="rowMoveEvent('down');" title="Move Down">
                        <i class="fas fa-chevron-down"></i>
                    </button>
                </div>
                <sec:authorize access="isAuthenticated()">
                    <button type="button" data-oper='addApprovalStep' class="btn-action-register" style="padding: 4px 10px; font-size: 0.75rem;">
                        <i class="fas fa-plus"></i> Add
                    </button>
                    <button type="button" data-oper='deleteApprovalStep' class="btn-action-delete" style="padding: 4px 10px; font-size: 0.75rem;">
                        <i class="fas fa-minus"></i> Del
                    </button>
                    <button type="button" data-oper='saveallstep' class="btn-action-primary" style="padding: 4px 10px; font-size: 0.75rem;">
                        <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                    </button>
                </sec:authorize>
            </div>
        </div>

        <!-- Step Table -->
        <div class="step-table-container">
            <table class="step-table step-table-header">
                <thead>
                <tr>
                    <th style="width: 5%;"></th>
                    <th style="width: 20%;"><spring:message code="col.aprvlineid" text="Approval Line"/></th>
                    <th style="width: 8%;"><spring:message code="col.seq" text="Seq"/></th>
                    <th style="width: 22%;"><spring:message code="col.stepname" text="Step Name"/></th>
                    <th style="width: 20%;"><spring:message code="col.approverid" text="Approver ID"/></th>
                    <th style="width: 25%;"><spring:message code="col.approvername" text="Approver Name"/></th>
                </tr>
                </thead>
            </table>
            <div class="step-table-wrapper">
                <table class="step-table" id="approvalsteps">
                    <tbody id="approvalstepbody">
                    <c:forEach items="${steplist}" var="piiapprovalstep">
                        <tr>
                            <td style="width: 5%;">
                                <input type="radio" class="chkRadio" name="chkRadio"
                                       onclick="checkeRowColorChange(this);"
                                       style="width: 16px; height: 16px; cursor: pointer;">
                            </td>
                            <td style="width: 20%;" class="td-aprvlineid"><c:out value="${piiapprovalstep.aprvlineid}"/></td>
                            <td style="width: 8%;" class="td-seq"><c:out value="${piiapprovalstep.seq}"/></td>
                            <td style="width: 22%;">
                                <input type="text" class="step-input" name="stepname"
                                       value='<c:out value="${piiapprovalstep.stepname}"/>'
                                       onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                       placeholder="Enter step name">
                            </td>
                            <td style="width: 20%;" class="td-approverid td-clickable"><c:out value="${piiapprovalstep.approverid}"/></td>
                            <td style="width: 25%;" class="td-approvername td-clickable"><c:out value="${piiapprovalstep.approvername}"/></td>
                            <td class="td-hidden"><c:out value="${piiapprovalstep.approvalid}"/></td>
                            <td class="td-hidden"><c:out value="${piiapprovalstep.approvalname}"/></td>
                            <td class="td-hidden"><input type="hidden" name="saveyn" value="Y"></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <c:if test="${empty steplist}">
            <div class="step-empty-message">
                <i class="fas fa-info-circle"></i>
                <spring:message code="msg.nosteps" text="No approval steps defined. Click 'Add' to create a new step."/>
            </div>
        </c:if>
    </div>
</div>

<!-- Hidden form for approval line info -->
<form style="margin: 0; padding: 0;" role="form" id="form_etc">
    <input type='hidden' name='aprvlineid' value='<c:out value="${approvalline.aprvlineid}"/>'>
    <input type='hidden' name='approvalid' value='<c:out value="${approvalline.approvalid}"/>'>
    <input type='hidden' name='approvalname' value='<c:out value="${approvalline.approvalname}"/>'>
</form>

<!-- Member Search Modal -->
<div class="modal fade" id="diologsearchmemberlist" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #475569 0%, #334155 100%); color: #fff; padding: 12px 20px;">
                <h5 class="modal-title"><i class="fas fa-users mr-2"></i><spring:message code="etc.search_member" text="Search Member"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="diologsearchmemberlistbody" style="padding: 0; max-height: 500px; overflow-y: auto;">
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
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Search button
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });

        // Back to list button
        $("button[data-oper='backtolist']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            goBackToList();
        });

        // Double click on approver cells to select/change approver
        $('#approvalsteps tbody').on('dblclick', '.td-approverid, .td-approvername', function (e) {
            e.stopPropagation();
            var tr = $(this).closest('tr');
            var clickedindex = tr.index();
            diologSearchMember(clickedindex);
        });

        // Add step
        $("button[data-oper='addApprovalStep']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            addNewStep();
        });

        // Delete step
        $("button[data-oper='deleteApprovalStep']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            deleteSelectedStep();
        });

        // Save all steps
        $("button[data-oper='saveallstep']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            saveAllSteps();
        });
    });

    // Highlight selected row
    function checkeRowColorChange(obj) {
        $("#approvalstepbody > tr").removeClass('step-row-selected');
        var row = $(".chkRadio").index(obj);
        $("#approvalstepbody > tr").eq(row).addClass('step-row-selected');
    }

    // Move row up or down
    function rowMoveEvent(direction) {
        if (!$(".chkRadio:checked").val()) {
            alert("<spring:message code='msg.selectstep' text='Select a step to move.'/>");
            return;
        }

        var row = $(".chkRadio:checked").parent().parent();
        var num = row.index();
        var max = $(".chkRadio").length - 1;

        if (direction == "up") {
            if (num == 0) return false;
            row.prev().before(row);
        } else if (direction == "down") {
            if (num >= max) return false;
            row.next().after(row);
        }

        // Update sequence numbers
        updateSequenceNumbers();
    }

    // Update sequence numbers after reordering
    function updateSequenceNumbers() {
        $('#approvalstepbody > tr').each(function (index) {
            $(this).find('.td-seq').text(index + 1);
        });
    }

    // Add new step
    function addNewStep() {
        var aprvlineid = $('#form_etc [name="aprvlineid"]').val();
        var approvalid = $('#form_etc [name="approvalid"]').val();
        var approvalname = $('#form_etc [name="approvalname"]').val();

        if (!aprvlineid) {
            alert("<spring:message code='msg.selectapprovalline' text='Please select an approval line first.'/>");
            return;
        }

        var newseq = $('#approvalstepbody > tr').length + 1;

        var htmlstr = '<tr>';
        htmlstr += '<td style="width: 5%;"><input type="radio" class="chkRadio" name="chkRadio" onclick="checkeRowColorChange(this);" style="width: 16px; height: 16px; cursor: pointer;"></td>';
        htmlstr += '<td style="width: 20%;" class="td-aprvlineid">' + aprvlineid + '</td>';
        htmlstr += '<td style="width: 8%;" class="td-seq">' + newseq + '</td>';
        htmlstr += '<td style="width: 22%;"><input type="text" class="step-input" name="stepname" value="" placeholder="Enter step name"></td>';
        htmlstr += '<td style="width: 20%;" class="td-approverid td-clickable"></td>';
        htmlstr += '<td style="width: 25%;" class="td-approvername td-clickable"></td>';
        htmlstr += '<td class="td-hidden">' + approvalid + '</td>';
        htmlstr += '<td class="td-hidden">' + approvalname + '</td>';
        htmlstr += '<td class="td-hidden"><input type="hidden" name="saveyn" value="N"></td>';
        htmlstr += '</tr>';

        $("#approvalstepbody").append(htmlstr);
    }

    // Delete selected step
    function deleteSelectedStep() {
        if (!$(".chkRadio:checked").val()) {
            alert("<spring:message code='msg.selectstep' text='Select a step to delete.'/>");
            return;
        }

        var row = $(".chkRadio:checked").parent().parent();
        row.remove();
        updateSequenceNumbers();
    }

    // Save all steps
    function saveAllSteps() {
        var approvalid = $('#form_etc [name="approvalid"]').val();
        var approvalname = $('#form_etc [name="approvalname"]').val();

        var param = [];
        var hasError = false;
        var isEmpty = true;

        $('#approvalstepbody > tr').each(function (index) {
            isEmpty = false;
            var tr = $(this);
            var stepname = tr.find('input[name="stepname"]').val().trim();
            var approverid = tr.find('.td-approverid').text().trim();
            var seq = tr.find('.td-seq').text().trim();

            if (!stepname) {
                alert("<spring:message code='msg.enterstepname' text='Step'/> " + seq + ": <spring:message code='msg.stepnamerequired' text='Step name is required.'/>");
                hasError = true;
                return false;
            }
            if (!approverid) {
                alert("<spring:message code='msg.enterstepname' text='Step'/> " + seq + ": <spring:message code='msg.approverrequired' text='Approver is required.'/>");
                hasError = true;
                return false;
            }

            var data = {
                aprvlineid: tr.find('.td-aprvlineid').text().trim(),
                seq: seq,
                stepname: stepname,
                approvalid: approvalid,
                approvalname: approvalname,
                approverid: approverid,
                approvername: tr.find('.td-approvername').text().trim()
            };
            param.push(data);
        });

        if (isEmpty) {
            alert("<spring:message code='msg.atleastonestep' text='At least one approval step is required.'/>");
            return;
        }
        if (hasError) return;

        ingShow();
        $.ajax({
            url: "/piiapprovaluser/saveallstep",
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "POST",
            data: JSON.stringify(param),
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                // Update saveyn to Y for all rows
                $('#approvalstepbody > tr').each(function () {
                    $(this).find('input[name="saveyn"]').val("Y");
                });
                $("#GlobalSuccessMsgModal").modal("show");
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }
        });
    }

    // Open member search dialog
    function diologSearchMember(clickedindex) {
        var pagenum = 1;
        var amount = 100;
        var search3 = clickedindex;
        var search4 = "approval_step_user";

        $.ajax({
            type: "GET",
            url: "/piimember/diologsearchmember?pagenum=" + pagenum + "&amount=" + amount + "&search3=" + search3 + "&search4=" + search4,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#diologsearchmemberlistbody').html(data);
                $("#diologsearchmemberlist").modal();
            }
        });
    }

    // Search action
    function searchAction(pageNo) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search2 = $('#searchForm [name="search2"]').val();

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        var url_search = "";
        if (!isEmpty(search2)) {
            url_search = "&aprvlineid=" + search2;
        }

        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/approvalsteplist?pagenum=" + pagenum + "&amount=" + amount + url_search,
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

    // Go back to approval line list
    function goBackToList() {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiapprovaluser/approvallinelist?pagenum=1&amount=100",
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

    movePage = function (pageNo) {
        searchAction(pageNo);
    }
</script>
