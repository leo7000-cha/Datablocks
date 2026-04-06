<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
    .detail-card {
        background: #fff;
        border-radius: 12px;
        overflow: hidden;
    }
    .detail-card-header {
        background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%);
        color: #fff;
        padding: 16px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .detail-card-header h5 {
        margin: 0;
        font-weight: 600;
        font-size: 1.1rem;
    }
    .detail-card-body {
        padding: 24px;
        max-height: 70vh;
        overflow-y: auto;
    }
    .detail-table {
        width: 100%;
        border-collapse: collapse;
    }
    .detail-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        padding: 10px 16px;
        text-align: left;
        width: 35%;
        border-bottom: 1px solid #e2e8f0;
        font-size: 0.875rem;
    }
    .detail-table td {
        padding: 10px 16px;
        border-bottom: 1px solid #e2e8f0;
        color: #1e293b;
        font-size: 0.875rem;
    }
    .detail-table tr:last-child th,
    .detail-table tr:last-child td {
        border-bottom: none;
    }
    .detail-actions {
        display: flex;
        gap: 8px;
    }
    .detail-actions .btn {
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 0.85rem;
        font-weight: 500;
    }
    .btn-detail-primary {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: #fff;
        border: none;
    }
    .btn-detail-primary:hover {
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        color: #fff;
    }
    .btn-detail-close {
        background: #64748b;
        color: #fff;
        border: none;
    }
    .btn-detail-close:hover {
        background: #475569;
        color: #fff;
    }
</style>

<div class="detail-card">
    <div class="detail-card-header">
        <h5><i class="fas fa-info-circle"></i> <spring:message code="memu.lkpiiscr_mgmt" text="PII Conversion Type Details"/></h5>
        <div class="detail-actions">
            <sec:authorize access="isAuthenticated()">
                <button data-oper='modify' class="btn btn-detail-primary">
                    <i class="fas fa-edit"></i> <spring:message code="btn.modify" text="Modify"/>
                </button>
            </sec:authorize>
            <button data-oper='close' class="btn btn-detail-close">
                <i class="fas fa-times"></i> <spring:message code="btn.close" text="Close"/>
            </button>
        </div>
    </div>
    <div class="detail-card-body">
        <form style="margin: 0; padding: 0;" role="form" id="lkpiiscrtype_get_form" method="post">
            <table class="detail-table">
                <tbody>
                <tr>
                    <th><spring:message code="col.piicode" text="Piicode"/></th>
                    <td>
                        <c:out value="${lkpiiscrtype.piicode}"/>
                        <input type="hidden" name='piicode' value='<c:out value="${lkpiiscrtype.piicode}"/>'>
                    </td>
                </tr>
                <tr>
                    <th><spring:message code="col.piigradename" text="PII Grade"/></th>
                    <td>
                        <c:out value="${lkpiiscrtype.piigradeid}"/>. <c:out value="${lkpiiscrtype.piigradename}"/>
                    </td>
                </tr>
                <tr>
                    <th><spring:message code="col.piigroupname" text="PII Group"/></th>
                    <td>
                        <c:out value="${lkpiiscrtype.piigroupid}"/>. <c:out value="${lkpiiscrtype.piigroupname}"/>
                    </td>
                </tr>
                <tr>
                    <th><spring:message code="col.piitypeid" text="PII Type ID"/></th>
                    <td><c:out value="${lkpiiscrtype.piitypeid}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.piitypename" text="PII Type Name"/></th>
                    <td><c:out value="${lkpiiscrtype.piitypename}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrtype" text="Scramble Type"/></th>
                    <td><c:out value="${lkpiiscrtype.scrtype}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrmethod" text="Scramble Method"/></th>
                    <td><c:out value="${lkpiiscrtype.scrmethod}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrcategory" text="Scramble Category"/></th>
                    <td><c:out value="${lkpiiscrtype.scrcategory}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrdigits" text="Scramble Digits"/></th>
                    <td><c:out value="${lkpiiscrtype.scrdigits}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.scrvalidity" text="Scramble Validity"/></th>
                    <td><c:out value="${lkpiiscrtype.scrvalidity}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.remarks" text="Remarks"/></th>
                    <td><c:out value="${lkpiiscrtype.remarks}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.encdecfunctype" text="Enc/Dec Func Type"/></th>
                    <td><c:out value="${lkpiiscrtype.encdecfunctype}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.encfunc" text="Encrypt Function"/></th>
                    <td><c:out value="${lkpiiscrtype.encfunc}"/></td>
                </tr>
                <tr>
                    <th><spring:message code="col.decfunc" text="Decrypt Function"/></th>
                    <td><c:out value="${lkpiiscrtype.decfunc}"/></td>
                </tr>
                </tbody>
            </table>
        </form>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        // Modify button - load modify form into modal
        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            var piicode = $('#lkpiiscrtype_get_form [name="piicode"]').val();
            openModifyModal(piicode);
        });

        // Close button - close modal
        $("button[data-oper='close']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#detailModal').modal('hide');
        });
    });
</script>
