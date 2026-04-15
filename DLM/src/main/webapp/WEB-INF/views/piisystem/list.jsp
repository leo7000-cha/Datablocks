<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<style>
/* DB Connection Page Styles */
.dbconn-container {
    padding: 0;
    background: #f1f5f9;
    min-height: 100%;
}

.dbconn-header {
    background: #fff;
    padding: 16px 20px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 10;
}

.dbconn-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #1e293b;
    display: flex;
    align-items: center;
    gap: 10px;
}

.dbconn-title i {
    color: #8b5cf6;
}

.dbconn-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}

.dbconn-search {
    position: relative;
}

.dbconn-search input {
    padding: 8px 12px 8px 36px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    width: 200px;
    background: #f8fafc;
    transition: all 0.2s;
}

.dbconn-search input:focus {
    outline: none;
    border-color: #8b5cf6;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(139,92,246,0.1);
}

.dbconn-search i {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    font-size: 0.85rem;
}

/* Statistics Bar */
.dbconn-stats-bar {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 12px 20px;
    background: #fff;
    border-bottom: 1px solid #e2e8f0;
}

.dbconn-stats-item {
    display: flex;
    align-items: center;
    gap: 6px;
}

.dbconn-stats-item.total {
    font-weight: 600;
    color: #1e293b;
}

.dbconn-stats-item.total i {
    color: #8b5cf6;
}

.dbconn-stats-count {
    font-size: 0.8rem;
    font-weight: 600;
    color: #1e293b;
    background: #f1f5f9;
    padding: 2px 8px;
    border-radius: 10px;
}

/* DB Connection Body */
.dbconn-body {
    padding: 20px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 16px;
}

/* DB Connection Card */
.dbconn-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    overflow: hidden;
    cursor: pointer;
    transition: all 0.2s;
    border: 2px solid transparent;
}

.dbconn-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.12);
    transform: translateY(-2px);
    border-color: #8b5cf6;
}

.dbconn-card-header {
    padding: 16px;
    background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
    color: #fff;
    display: flex;
    align-items: center;
    gap: 12px;
}

.dbconn-card-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: rgba(255,255,255,0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
}

.dbconn-card-title {
    flex: 1;
}

.dbconn-card-id {
    font-size: 1rem;
    font-weight: 700;
}

.dbconn-card-name {
    font-size: 0.75rem;
    opacity: 0.9;
    margin-top: 2px;
}

.dbconn-card-status {
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
}

.dbconn-card-status.active {
    background: rgba(16, 185, 129, 0.2);
    color: #10b981;
}

.dbconn-card-status.inactive {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
}

.dbconn-card-body {
    padding: 16px;
}

.dbconn-card-info {
    display: flex;
    align-items: flex-start;
    gap: 8px;
}

.dbconn-card-info i {
    color: #94a3b8;
    font-size: 0.85rem;
    margin-top: 2px;
}

.dbconn-card-info-text {
    flex: 1;
    font-size: 0.85rem;
    color: #64748b;
    line-height: 1.5;
    word-break: break-all;
}

.dbconn-card-info-text.empty {
    color: #cbd5e1;
    font-style: italic;
}

.dbconn-card-footer {
    padding: 12px 16px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

.dbconn-card-btn {
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 0.75rem;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 4px;
}

.dbconn-card-btn.edit {
    background: #e0e7ff;
    color: #4f46e5;
}

.dbconn-card-btn.edit:hover {
    background: #c7d2fe;
}

.dbconn-card-btn.delete {
    background: #fee2e2;
    color: #dc2626;
}

.dbconn-card-btn.delete:hover {
    background: #fecaca;
}

/* Modal Delete Button */
.btn-modal-delete {
    padding: 8px 16px;
    border: none;
    border-radius: 8px;
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    color: #fff;
    font-size: 0.85rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
}

.btn-modal-delete:hover {
    box-shadow: 0 2px 8px rgba(239,68,68,0.4);
    transform: translateY(-1px);
}

.member-modal-footer-with-delete {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-top: 1px solid #e5e7eb;
    background: #f9fafb;
}

.member-modal-footer-right {
    display: flex;
    gap: 8px;
}

/* Empty State */
.dbconn-empty {
    grid-column: 1 / -1;
    padding: 60px 20px;
    text-align: center;
    color: #94a3b8;
}

.dbconn-empty i {
    font-size: 3rem;
    margin-bottom: 16px;
    color: #cbd5e1;
}

.dbconn-empty-text {
    font-size: 1rem;
    margin-bottom: 8px;
}

.dbconn-empty-subtext {
    font-size: 0.85rem;
    color: #cbd5e1;
}
</style>

<!-- Begin Page Content -->
<div class="dbconn-container" id="piisystemlist">
    <!-- Header -->
    <div class="dbconn-header">
        <div class="dbconn-title">
            <i class="fas fa-database"></i>
            <spring:message code="memu.systemmgmt" text="DB Connection Management"/>
        </div>
        <div class="dbconn-actions">
            <div class="dbconn-search">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" placeholder="Search systems..."
                       onkeyup="filterConnections(this.value)">
            </div>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <button type="button" data-oper='register' class="btn-action-register">
                    <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                </button>
            </sec:authorize>
        </div>
    </div>

    <!-- Hidden Form -->
    <form style="display:none;" id="searchForm">
        <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
        <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
        <input type='hidden' name='system_id' value='<c:out value="${pageMaker.cri.search1}"/>'>
        <input type='hidden' name='system_name' value='<c:out value="${pageMaker.cri.search2}"/>'>
    </form>

    <!-- Statistics Bar -->
    <div class="dbconn-stats-bar">
        <div class="dbconn-stats-item total">
            <i class="fas fa-server"></i>
            <span>Total Connections</span>
            <span class="dbconn-stats-count">${fn:length(list)}</span>
        </div>
    </div>

    <!-- DB Connection Body -->
    <div class="dbconn-body">
        <c:forEach items="${list}" var="piisystem">
            <div class="dbconn-card" data-system-id="<c:out value='${piisystem.system_id}'/>"
                 data-system-name="<c:out value='${piisystem.system_name}'/>"
                 data-system-info="<c:out value='${piisystem.system_info}'/>"
                 data-use-flag="<c:out value='${piisystem.use_flag}'/>">
                <div class="dbconn-card-header">
                    <div class="dbconn-card-icon">
                        <i class="fas fa-database"></i>
                    </div>
                    <div class="dbconn-card-title">
                        <div class="dbconn-card-id">${piisystem.system_id}</div>
                        <div class="dbconn-card-name">${piisystem.system_name}</div>
                    </div>
                    <span class="dbconn-card-status ${piisystem.use_flag eq 'Y' ? 'active' : 'inactive'}">
                        ${piisystem.use_flag eq 'Y' ? 'Active' : 'Inactive'}
                    </span>
                </div>
                <div class="dbconn-card-body">
                    <div class="dbconn-card-info">
                        <i class="fas fa-info-circle"></i>
                        <div class="dbconn-card-info-text ${empty piisystem.system_info ? 'empty' : ''}">
                            ${empty piisystem.system_info ? 'No description' : piisystem.system_info}
                        </div>
                    </div>
                </div>
                <sec:authorize access="hasRole('ROLE_ADMIN')">
                    <div class="dbconn-card-footer">
                        <button type="button" class="dbconn-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.dbconn-card'));">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                    </div>
                </sec:authorize>
            </div>
        </c:forEach>

        <c:if test="${empty list}">
            <div class="dbconn-empty">
                <i class="fas fa-database"></i>
                <div class="dbconn-empty-text">No DB connections found</div>
                <div class="dbconn-empty-subtext">Click "Register" to add a new connection</div>
            </div>
        </c:if>
    </div>
</div>

<!-- Register Modal -->
<div class="modal fade" id="registerModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header member-modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i><spring:message code="btn.register" text="Register Connection"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="registerForm">
                    <div class="member-form-group">
                        <label class="member-form-label">System ID <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="system_id" required
                               onkeyup="this.value=this.value.toUpperCase()" placeholder="Enter system ID">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">System Name <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="system_name" required placeholder="Enter system name">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">System Info</label>
                        <textarea class="member-form-input" name="system_info" rows="3" placeholder="Enter connection info or description" style="height: auto;"></textarea>
                    </div>
                    <input type="hidden" name="use_flag" value="Y"/>
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
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header member-modal-header-modify">
                <h5 class="modal-title"><i class="fas fa-edit mr-2"></i><spring:message code="btn.modify" text="Modify Connection"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="modifyForm">
                    <div class="member-form-group">
                        <label class="member-form-label">System ID</label>
                        <input type="text" class="member-form-input" name="system_id" readonly style="background: #f1f5f9;">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">System Name <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="system_name" required placeholder="Enter system name">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">System Info</label>
                        <textarea class="member-form-input" name="system_info" rows="3" placeholder="Enter connection info or description" style="height: auto;"></textarea>
                    </div>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer-with-delete">
                <button type="button" class="btn-modal-delete" id="btnModifyDelete">
                    <i class="fas fa-trash-alt"></i> <spring:message code="btn.delete" text="Delete"/>
                </button>
                <div class="member-modal-footer-right">
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
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code='memu.systemmgmt' text='DB Connection Management'/>");
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Click on card (for admin: open modify modal)
        $('.dbconn-card').on('click', function () {
            if (!is_admin) return;
            openModifyModal($(this));
        });

        // Register button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#registerForm')[0].reset();
            $('#registerModal').modal('show');
        });

        // Register save
        $('#btnRegisterSave').on('click', function () {
            var form = $('#registerForm');
            var systemId = form.find('[name="system_id"]').val().trim();
            var systemName = form.find('[name="system_name"]').val().trim();

            if (!systemId) {
                dlmAlert('<spring:message code="msg.enter_system_id" text="Please enter System ID"/>');
                form.find('[name="system_id"]').focus();
                return;
            }
            if (!systemName) {
                dlmAlert('<spring:message code="msg.enter_system_name" text="Please enter System Name"/>');
                form.find('[name="system_name"]').focus();
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piisystem/register",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#registerModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
                    setTimeout(function() { searchAction(); }, 500);
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
            var systemName = form.find('[name="system_name"]').val().trim();

            if (!systemName) {
                dlmAlert('<spring:message code="msg.enter_system_name" text="Please enter System Name"/>');
                form.find('[name="system_name"]').focus();
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piisystem/modify",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#modifyModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Modify delete
        $('#btnModifyDelete').on('click', function () {
            var form = $('#modifyForm');
            var systemId = form.find('[name="system_id"]').val();
            var systemName = form.find('[name="system_name"]').val();

            showConfirm('Are you sure you want to delete "' + systemId + ' (' + systemName + ')"?', function() {
                ingShow();
                $.ajax({
                    type: "POST",
                    url: "/piisystem/remove",
                    data: {
                        system_id: systemId,
                        "${_csrf.parameterName}": "${_csrf.token}"
                    },
                    dataType: "html",
                    success: function (data) {
                        ingHide();
                        $('#modifyModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        showToast("처리가 완료되었습니다.", false);
                        setTimeout(function() { searchAction(); }, 500);
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

    function openModifyModal(card) {
        var systemId = card.data('system-id') || '';
        var systemName = card.data('system-name') || '';
        var systemInfo = card.data('system-info') || '';

        var form = $('#modifyForm');
        form[0].reset();
        form.find('[name="system_id"]').val(systemId);
        form.find('[name="system_name"]').val(systemName);
        form.find('[name="system_info"]').val(systemInfo);

        $('#modifyModal').modal('show');
    }

    function filterConnections(query) {
        query = query.toLowerCase();
        $('.dbconn-card').each(function() {
            var systemId = ($(this).data('system-id') || '').toString().toLowerCase();
            var systemName = ($(this).data('system-name') || '').toString().toLowerCase();
            var systemInfo = ($(this).data('system-info') || '').toString().toLowerCase();

            if (systemId.includes(query) || systemName.includes(query) || systemInfo.includes(query)) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }

    function searchAction() {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piisystem/list?pagenum=1&amount=100",
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
        searchAction();
    }
</script>
