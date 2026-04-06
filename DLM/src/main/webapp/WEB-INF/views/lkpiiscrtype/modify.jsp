<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
    .edit-card {
        background: #fff;
        border-radius: 12px;
        overflow: hidden;
    }
    .edit-card-header {
        background: linear-gradient(135deg, #065f46 0%, #047857 100%);
        color: #fff;
        padding: 16px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .edit-card-header h5 {
        margin: 0;
        font-weight: 600;
        font-size: 1.1rem;
    }
    .edit-card-body {
        padding: 24px;
        max-height: 70vh;
        overflow-y: auto;
    }
    .edit-table {
        width: 100%;
        border-collapse: collapse;
    }
    .edit-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        padding: 8px 16px;
        text-align: left;
        width: 35%;
        border-bottom: 1px solid #e2e8f0;
        font-size: 0.875rem;
        vertical-align: middle;
    }
    .edit-table td {
        padding: 6px 16px;
        border-bottom: 1px solid #e2e8f0;
        color: #1e293b;
        font-size: 0.875rem;
    }
    .edit-table tr:last-child th,
    .edit-table tr:last-child td {
        border-bottom: none;
    }
    .edit-table input[type="text"],
    .edit-table select {
        width: 100%;
        padding: 6px 10px;
        border: 1px solid #d1d5db;
        border-radius: 6px;
        font-size: 0.875rem;
        transition: all 0.2s;
    }
    .edit-table input[type="text"]:focus,
    .edit-table select:focus {
        outline: none;
        border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }
    .edit-table input[readonly] {
        background: #f1f5f9;
        color: #64748b;
    }
    .edit-actions {
        display: flex;
        gap: 8px;
    }
    .edit-actions .btn {
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 0.85rem;
        font-weight: 500;
    }
    .btn-edit-save {
        background: linear-gradient(135deg, #10b981, #059669);
        color: #fff;
        border: none;
    }
    .btn-edit-save:hover {
        background: linear-gradient(135deg, #059669, #047857);
        color: #fff;
    }
    .btn-edit-saveas {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: #fff;
        border: none;
    }
    .btn-edit-saveas:hover {
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        color: #fff;
    }
    .btn-edit-delete {
        background: #dc2626;
        color: #fff;
        border: none;
    }
    .btn-edit-delete:hover {
        background: #b91c1c;
        color: #fff;
    }
    .btn-edit-close {
        background: #64748b;
        color: #fff;
        border: none;
    }
    .btn-edit-close:hover {
        background: #475569;
        color: #fff;
    }
</style>

<div class="edit-card">
    <div class="edit-card-header">
        <h5><i class="fas fa-edit"></i> <spring:message code="memu.lkpiiscr_mgmt" text="PII Conversion Type Edit"/></h5>
        <div class="edit-actions">
            <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                <button data-oper='modify' class="btn btn-edit-save">
                    <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                </button>
                <button data-oper='register' class="btn btn-edit-saveas">
                    <i class="fas fa-copy"></i> Save as
                </button>
                <button data-oper='remove' class="btn btn-edit-delete">
                    <i class="fas fa-trash"></i> <spring:message code="btn.remove" text="Remove"/>
                </button>
            </sec:authorize>
            <button data-oper='close' class="btn btn-edit-close">
                <i class="fas fa-times"></i> <spring:message code="btn.close" text="Close"/>
            </button>
        </div>
    </div>
    <div class="edit-card-body">
        <form style="margin: 0; padding: 0;" role="form" id="lkpiiscrtype_modify_form" method="post">
            <table class="edit-table">
                <tbody>
                <tr>
                    <th><spring:message code="col.piicode" text="Piicode"/></th>
                    <td><input readonly type="text" name='piicode' value='<c:out value="${lkpiiscrtype.piicode}" escapeXml="false"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.piigradename" text="PII Grade"/></th>
                    <td>
                        <input type="hidden" name='piigradeid' value='<c:out value="${lkpiiscrtype.piigradeid}"/>'>
                        <input type="hidden" name='piigradename' value='<c:out value="${lkpiiscrtype.piigradename}"/>'>
                        <select id="piigradeid">
                            <option value="1" <c:if test="${lkpiiscrtype.piigradeid eq '1'}">selected</c:if>>1</option>
                            <option value="2" <c:if test="${lkpiiscrtype.piigradeid eq '2'}">selected</c:if>>2</option>
                            <option value="3" <c:if test="${lkpiiscrtype.piigradeid eq '3'}">selected</c:if>>3</option>
                        </select>
                    </td>
                </tr>
                <input type="hidden" name='piigroupid' value='<c:out value="${lkpiiscrtype.piigroupid}"/>'>
                <input type="hidden" name='piigroupname' value='<c:out value="${lkpiiscrtype.piigroupname}"/>'>
                <%-- Grade 1 Group Select --%>
                <tr data-grade="1">
                    <th><spring:message code="col.piigroupname" text="PII Group"/></th>
                    <td>
                        <select id="piigroupid1">
                            <option value="1" <c:if test="${lkpiiscrtype.piigroupid eq '1'}">selected</c:if>>생명·신체에 중대한 위해를 초래할 우려가 있는 정보</option>
                            <option value="2" <c:if test="${lkpiiscrtype.piigroupid eq '2'}">selected</c:if>>민감정보</option>
                            <option value="3" <c:if test="${lkpiiscrtype.piigroupid eq '3'}">selected</c:if>>인증정보</option>
                            <option value="4" <c:if test="${lkpiiscrtype.piigroupid eq '4'}">selected</c:if>>신용정보/금융정보</option>
                            <option value="5" <c:if test="${lkpiiscrtype.piigroupid eq '5'}">selected</c:if>>의료정보</option>
                            <option value="6" <c:if test="${lkpiiscrtype.piigroupid eq '6'}">selected</c:if>>위치정보</option>
                        </select>
                    </td>
                </tr>
                <%-- Grade 2 Group Select --%>
                <tr data-grade="2">
                    <th><spring:message code="col.piigroupname" text="PII Group"/></th>
                    <td>
                        <select id="piigroupid2">
                            <option value="1" <c:if test="${lkpiiscrtype.piigroupid eq '1'}">selected</c:if>>개인식별정보</option>
                            <option value="2" <c:if test="${lkpiiscrtype.piigroupid eq '2'}">selected</c:if>>연락정보</option>
                            <option value="3" <c:if test="${lkpiiscrtype.piigroupid eq '3'}">selected</c:if>>개인관련정보</option>
                        </select>
                    </td>
                </tr>
                <%-- Grade 3 Group Select --%>
                <tr data-grade="3">
                    <th><spring:message code="col.piigroupname" text="PII Group"/></th>
                    <td>
                        <select id="piigroupid3">
                            <option value="1" <c:if test="${lkpiiscrtype.piigroupid eq '1'}">selected</c:if>>자동 생성 정보</option>
                            <option value="2" <c:if test="${lkpiiscrtype.piigroupid eq '2'}">selected</c:if>>가공정보</option>
                            <option value="3" <c:if test="${lkpiiscrtype.piigroupid eq '3'}">selected</c:if>>제한적 본인 식별정보</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th><spring:message code="col.piitypeid" text="PII Type ID"/></th>
                    <td><input type="text" name='piitypeid' value='<c:out value="${lkpiiscrtype.piitypeid}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.piitypename" text="PII Type Name"/></th>
                    <td><input type="text" name='piitypename' value='<c:out value="${lkpiiscrtype.piitypename}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrtype" text="Scramble Type"/></th>
                    <td><input type="text" name='scrtype' value='<c:out value="${lkpiiscrtype.scrtype}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrmethod" text="Scramble Method"/></th>
                    <td><input type="text" name='scrmethod' value='<c:out value="${lkpiiscrtype.scrmethod}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrcategory" text="Scramble Category"/></th>
                    <td><input type="text" name='scrcategory' value='<c:out value="${lkpiiscrtype.scrcategory}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrdigits" text="Scramble Digits"/></th>
                    <td><input type="text" name='scrdigits' value='<c:out value="${lkpiiscrtype.scrdigits}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrvalidity" text="Scramble Validity"/></th>
                    <td><input type="text" name='scrvalidity' value='<c:out value="${lkpiiscrtype.scrvalidity}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.remarks" text="Remarks"/></th>
                    <td><input type="text" name='remarks' value='<c:out value="${lkpiiscrtype.remarks}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.encdecfunctype" text="Enc/Dec Func Type"/></th>
                    <td>
                        <select id="encdecfunctype" name="encdecfunctype">
                            <option value=""></option>
                            <option value="JAVA API" <c:if test="${lkpiiscrtype.encdecfunctype eq 'JAVA API'}">selected</c:if>>JAVA API</option>
                            <option value="DB" <c:if test="${lkpiiscrtype.encdecfunctype eq 'DB'}">selected</c:if>>DB</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th><spring:message code="col.encfunc" text="Encrypt Function"/></th>
                    <td><input type="text" name='encfunc' value='<c:out value="${lkpiiscrtype.encfunc}"/>'></td>
                </tr>
                <tr>
                    <th><spring:message code="col.decfunc" text="Decrypt Function"/></th>
                    <td><input type="text" name='decfunc' value='<c:out value="${lkpiiscrtype.decfunc}"/>'></td>
                </tr>
                </tbody>
            </table>
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </form>

        <form style="display:none;" role="form" id="originalForm">
            <input type='hidden' name='piicode_original' value='<c:out value="${lkpiiscrtype.piicode}"/>'>
        </form>
    </div>
</div>

<script type="text/javascript">
    // Update piicode when piitypeid changes
    $('input[name="piitypeid"]').on('input', function() {
        var piigradeid = $('#lkpiiscrtype_modify_form [name="piigradeid"]').val();
        var piigroupid = $('#lkpiiscrtype_modify_form [name="piigroupid"]').val();
        var piitypeid = $('#lkpiiscrtype_modify_form [name="piitypeid"]').val();
        $('#lkpiiscrtype_modify_form [name="piicode"]').val(piigradeid + "_" + piigroupid + "_" + piitypeid);
    });

    // Update hidden fields and piicode when group selects change
    $('#piigroupid1, #piigroupid2, #piigroupid3').on('change', function() {
        var newValue = $(this).val();
        var newOption = $(this).find('option:selected').text();
        $('#lkpiiscrtype_modify_form [name="piigroupid"]').val(newValue);
        $('#lkpiiscrtype_modify_form [name="piigroupname"]').val(newOption);
        var piigradeid = $('#lkpiiscrtype_modify_form [name="piigradeid"]').val();
        var piitypeid = $('#lkpiiscrtype_modify_form [name="piitypeid"]').val();
        $('#lkpiiscrtype_modify_form [name="piicode"]').val(piigradeid + "_" + newValue + "_" + piitypeid);
    });

    // Update hidden fields and piicode when grade select changes
    $('#piigradeid').on('change', function() {
        var newValue = $(this).val();
        var newOption = $(this).find('option:selected').text();
        $('#lkpiiscrtype_modify_form [name="piigradeid"]').val(newValue);
        $('#lkpiiscrtype_modify_form [name="piigradename"]').val(newOption);
        var piigroupid = $('#lkpiiscrtype_modify_form [name="piigroupid"]').val();
        var piitypeid = $('#lkpiiscrtype_modify_form [name="piitypeid"]').val();
        $('#lkpiiscrtype_modify_form [name="piicode"]').val(newValue + "_" + piigroupid + "_" + piitypeid);

        // Show/hide group rows based on grade
        $('tr[data-grade]').hide();
        $('tr[data-grade="' + newValue + '"]').show();
    });

    // Auto-update scrtype based on scrmethod, scrcategory, scrdigits
    $('#lkpiiscrtype_modify_form [name="scrmethod"], #lkpiiscrtype_modify_form [name="scrcategory"], #lkpiiscrtype_modify_form [name="scrdigits"]').on('input', function() {
        var scrmethod = $('#lkpiiscrtype_modify_form [name="scrmethod"]').val();
        var scrcategory = $('#lkpiiscrtype_modify_form [name="scrcategory"]').val();
        var scrdigits = $('#lkpiiscrtype_modify_form [name="scrdigits"]').val();
        if (scrdigits.trim() !== '') {
            $('#lkpiiscrtype_modify_form [name="scrtype"]').val(scrmethod + "_" + scrcategory + "_" + scrdigits);
        } else {
            $('#lkpiiscrtype_modify_form [name="scrtype"]').val(scrmethod + "_" + scrcategory);
        }
    });

    $(document).ready(function () {
        // Initialize grade selection
        $('#piigradeid').trigger('change');

        // Save button
        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var piicode_original = $('#originalForm [name="piicode_original"]').val();
            var piicode = $('#lkpiiscrtype_modify_form [name="piicode"]').val();

            if (piicode != piicode_original) {
                alert("<spring:message code="col.piicode" text="Piicode"/> should be same from '" + piicode_original + "'");
                return;
            }

            var requiredFields = ['piicode', 'piigradeid', 'piigradename', 'piigroupid', 'piigroupname', 'piitypeid', 'piitypename', 'scrtype', 'scrmethod', 'scrcategory'];
            for (var i = 0; i < requiredFields.length; i++) {
                var val = $('#lkpiiscrtype_modify_form [name="' + requiredFields[i] + '"]').val();
                if (!val || val.trim() === '') {
                    alert(requiredFields[i] + " is mandatory");
                    $('#lkpiiscrtype_modify_form [name="' + requiredFields[i] + '"]').focus();
                    return;
                }
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/lkpiiscrtype/modify",
                dataType: "html",
                data: $("#lkpiiscrtype_modify_form").serialize(),
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#detailModal').modal('hide');
                    $('body').removeClass('modal-open');
                    $('.modal-backdrop').remove();
                    refreshList();
                    setTimeout(function() {
                        $("#GlobalSuccessMsgModal").modal("show");
                    }, 300);
                }
            });
        });

        // Save as button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var piicode_original = $('#originalForm [name="piicode_original"]').val();
            var piicode = $('#lkpiiscrtype_modify_form [name="piicode"]').val();

            if (piicode == piicode_original) {
                alert("<spring:message code="col.piicode" text="Piicode"/> should be different from '" + piicode_original + "'");
                return;
            }

            var requiredFields = ['piicode', 'piigradeid', 'piigradename', 'piigroupid', 'piigroupname', 'piitypeid', 'piitypename', 'scrtype', 'scrmethod', 'scrcategory'];
            for (var i = 0; i < requiredFields.length; i++) {
                var val = $('#lkpiiscrtype_modify_form [name="' + requiredFields[i] + '"]').val();
                if (!val || val.trim() === '') {
                    alert(requiredFields[i] + " is mandatory");
                    $('#lkpiiscrtype_modify_form [name="' + requiredFields[i] + '"]').focus();
                    return;
                }
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/lkpiiscrtype/register",
                dataType: "html",
                data: $("#lkpiiscrtype_modify_form").serialize(),
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#detailModal').modal('hide');
                    $('body').removeClass('modal-open');
                    $('.modal-backdrop').remove();
                    refreshList();
                    setTimeout(function() {
                        $("#GlobalSuccessMsgModal").modal("show");
                    }, 300);
                }
            });
        });

        // Remove button
        $("button[data-oper='remove']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (!confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>")) {
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/lkpiiscrtype/remove",
                dataType: "html",
                data: $("#lkpiiscrtype_modify_form").serialize(),
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#detailModal').modal('hide');
                    $('body').removeClass('modal-open');
                    $('.modal-backdrop').remove();
                    refreshList();
                    setTimeout(function() {
                        $("#GlobalSuccessMsgModal").modal("show");
                    }, 300);
                }
            });
        });

        // Close button
        $("button[data-oper='close']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#detailModal').modal('hide');
        });
    });
</script>
