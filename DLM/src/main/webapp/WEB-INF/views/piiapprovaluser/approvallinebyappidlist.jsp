<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- Begin Page Content -->

<style>
.approval-line-cards {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.approval-line-card {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    background: #fff;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.approval-line-card:hover {
    border-color: #a78bfa;
    background: #faf5ff;
}

.approval-line-card.selected {
    border-color: #7c3aed;
    background: linear-gradient(135deg, #f5f3ff 0%, #ede9fe 100%);
    box-shadow: 0 2px 8px rgba(124, 58, 237, 0.15);
}

.approval-line-card input[type="radio"] {
    display: none;
}

.approval-radio-custom {
    width: 16px;
    height: 16px;
    border: 2px solid #d1d5db;
    border-radius: 50%;
    margin-right: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s ease;
    flex-shrink: 0;
}

.approval-line-card.selected .approval-radio-custom {
    border-color: #7c3aed;
    background: #7c3aed;
}

.approval-radio-custom::after {
    content: '';
    width: 6px;
    height: 6px;
    background: #fff;
    border-radius: 50%;
    opacity: 0;
    transition: opacity 0.2s ease;
}

.approval-line-card.selected .approval-radio-custom::after {
    opacity: 1;
}

.approval-line-info {
    display: flex;
    align-items: center;
    flex: 1;
}

.approval-line-icon {
    width: 28px;
    height: 28px;
    background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%);
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 10px;
    flex-shrink: 0;
}

.approval-line-icon i {
    color: #fff;
    font-size: 12px;
}

.approval-line-name {
    font-weight: 600;
    color: #374151;
    font-size: 0.85rem;
}

.approval-line-card.selected .approval-line-name {
    color: #5b21b6;
}

.approval-check-icon {
    width: 20px;
    height: 20px;
    background: #7c3aed;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transform: scale(0.5);
    transition: all 0.2s ease;
}

.approval-line-card.selected .approval-check-icon {
    opacity: 1;
    transform: scale(1);
}

.approval-check-icon i {
    color: #fff;
    font-size: 10px;
}
</style>

<sec:authorize access="hasRole('ROLE_ADMIN')" var="isAdmin" />
<c:set var="listSize" value="${fn:length(approvalUserAlllist)}" />
<div class="approval-line-cards">
    <c:forEach items="${approvalUserAlllist}" var="approvalline" varStatus="loop">
        <%--<c:if test="${isAdmin || approvalline.str1 ne '자동복원결재라인'}">--%>
        <c:if test="${approvalline.str1 ne '자동복원결재라인'}">
        <c:set var="isSelected" value="${listSize == 1 || approvalline.str1 eq lastappline}" />
        <label class="approval-line-card <c:if test="${isSelected}">selected</c:if>">
            <input type="radio" name="aprvlineid" id="aprvlineid"
                   value="<c:out value="${approvalline.str1}"/>"
                   <c:if test="${isSelected}">checked</c:if> />
            <span class="approval-radio-custom"></span>
            <div class="approval-line-info">
                <div class="approval-line-icon">
                    <i class="fas fa-sitemap"></i>
                </div>
                <span class="approval-line-name"><c:out value="${approvalline.str2}"/></span>
            </div>
            <div class="approval-check-icon">
                <i class="fas fa-check"></i>
            </div>
        </label>
        </c:if>
    </c:forEach>
</div>

<script>
$(document).ready(function() {
    $('.approval-line-card').on('click', function() {
        $('.approval-line-card').removeClass('selected');
        $(this).addClass('selected');
    });
});
</script>
