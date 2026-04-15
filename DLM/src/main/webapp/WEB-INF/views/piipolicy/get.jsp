<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Forms -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
    <input type='hidden' name='search7' value='<c:out value="${cri.search7}"/>'>
    <input type='hidden' name='search8' value='<c:out value="${cri.search8}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== DETAIL HEADER ========== -->
    <div class="detail-header">
        <div class="detail-header-left">
            <div class="detail-title-group">
                <span class="detail-id"><c:out value="${piipolicy.policy_id}"/></span>
                <c:choose>
                    <c:when test="${piipolicy.phase eq 'CHECKOUT'}">
                        <span class="policy-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> CHECKOUT</span>
                    </c:when>
                    <c:when test="${piipolicy.phase eq 'CHECKIN'}">
                        <span class="policy-badge badge-phase-checkin"><i class="fas fa-lock"></i> CHECKIN</span>
                    </c:when>
                    <c:otherwise>
                        <span class="policy-badge badge-phase-default"><c:out value="${piipolicy.phase}"/></span>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${piipolicy.status eq 'ACTIVE'}">
                        <span class="policy-badge badge-status-active">ACTIVE</span>
                    </c:when>
                    <c:otherwise>
                        <span class="policy-badge badge-status-inactive"><c:out value="${piipolicy.status}"/></span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="detail-subtitle"><c:out value="${piipolicy.policy_name}"/></div>
        </div>
        <div class="detail-header-actions">
            <sec:authorize access="hasAnyRole('ROLE_SEC','ROLE_ADMIN')">
                <c:choose>
                    <c:when test="${piipolicy.phase eq 'CHECKIN' && piipolicy.status eq 'ACTIVE' && piipolicy.version eq maxversion}">
                        <button data-oper='checkout' class="btn btn-detail-checkout">
                            <i class="fas fa-lock-open"></i> CheckOut
                        </button>
                    </c:when>
                    <c:when test="${piipolicy.phase eq 'CHECKOUT' && piipolicy.status eq 'ACTIVE'}">
                        <button data-oper='modify' class="btn btn-detail-modify">
                            <i class="fas fa-edit"></i> <spring:message code="memu.movetomodify" text="수정 페이지 이동"/>
                        </button>
                    </c:when>
                </c:choose>
            </sec:authorize>
            <button data-oper='list' class="btn btn-detail-list">
                <i class="fas fa-list"></i> List
            </button>
        </div>
    </div>

    <!-- ========== DETAIL CONTENT ========== -->
    <div class="detail-content">
        <form role="form" id="piipolicy_get_form">
            <input type="hidden" name="policy_id" value='<c:out value="${piipolicy.policy_id}"/>'>
            <input type="hidden" name="policy_name" value='<c:out value="${piipolicy.policy_name}"/>'>
            <input type="hidden" name="phase" value='<c:out value="${piipolicy.phase}"/>'>
            <input type="hidden" name="status" value='<c:out value="${piipolicy.status}"/>'>
            <input type="hidden" name="del_deadline" value='<c:out value="${piipolicy.del_deadline}"/>'>
            <input type="hidden" name="del_deadline_unit" value='<c:out value="${piipolicy.del_deadline_unit}"/>'>
            <input type="hidden" name="archive_flag" value='<c:out value="${piipolicy.archive_flag}"/>'>
            <input type="hidden" name="arc_del_deadline_unit" value='<c:out value="${piipolicy.arc_del_deadline_unit}"/>'>
            <input type="hidden" name="regdate" value='<c:out value="${piipolicy.regdate}"/>'>
            <input type="hidden" name="upddate" value='<c:out value="${piipolicy.upddate}"/>'>
            <input type="hidden" name="reguserid" value='<c:out value="${piipolicy.reguserid}"/>'>
            <input type="hidden" name="upduserid" value='<c:out value="${piipolicy.upduserid}"/>'>
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="detail-grid">
                <!-- Left Column -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-info-circle"></i> <spring:message code="etc.basicInfo" text="Basic Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_id" text="Policy ID"/></div>
                        <div class="detail-value detail-value-id"><c:out value="${piipolicy.policy_id}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.policy_name" text="Policy Name"/></div>
                        <div class="detail-value"><c:out value="${piipolicy.policy_name}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.version" text="Version"/></div>
                        <div class="detail-value">
                            <select class="detail-select" name="version" id="policy_version">
                                <c:forEach items="${listallversion}" var="piipolicyallversion">
                                    <option value="<c:out value="${piipolicyallversion.version}"/>"
                                            <c:if test="${piipolicy.version eq piipolicyallversion.version}">selected</c:if>>
                                        <c:out value="${piipolicyallversion.version}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.phase" text="Phase"/></div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${piipolicy.phase eq 'CHECKOUT'}">
                                    <span class="policy-badge badge-phase-checkout"><i class="fas fa-lock-open"></i> CHECKOUT</span>
                                </c:when>
                                <c:when test="${piipolicy.phase eq 'CHECKIN'}">
                                    <span class="policy-badge badge-phase-checkin"><i class="fas fa-lock"></i> CHECKIN</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-phase-default"><c:out value="${piipolicy.phase}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.status" text="Status"/></div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${piipolicy.status eq 'ACTIVE'}">
                                    <span class="policy-badge badge-status-active">ACTIVE</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-status-inactive"><c:out value="${piipolicy.status}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-clock"></i> <spring:message code="etc.retentionInfo" text="Retention Information"/></div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.del_deadline" text="Delete Deadline"/></div>
                        <div class="detail-value">
                            <span class="detail-value-highlight">
                                <c:out value="${piipolicy.del_deadline}"/>
                                <c:choose>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'Y'}"><spring:message code="etc.year" text="Year"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'M'}"><spring:message code="etc.month" text="Month"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'D'}"><spring:message code="etc.day" text="Day"/></c:when>
                                    <c:when test="${piipolicy.del_deadline_unit eq 'D_BIZ'}"><spring:message code="etc.day_biz" text="Biz Day"/></c:when>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.archive_flag" text="Archive Flag"/></div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${piipolicy.archive_flag eq 'Y'}">
                                    <span class="policy-badge badge-archive-yes">YES</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="policy-badge badge-archive-no">NO</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.arc_del_deadline" text="Archive Deadline"/></div>
                        <div class="detail-value">
                            <span class="detail-value-highlight">
                                <c:out value="${piipolicy.arc_del_deadline}"/>
                                <c:choose>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'Y'}"><spring:message code="etc.year" text="Year"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'M'}"><spring:message code="etc.month" text="Month"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'D'}"><spring:message code="etc.day" text="Day"/></c:when>
                                    <c:when test="${piipolicy.arc_del_deadline_unit eq 'D_BIZ'}"><spring:message code="etc.day_biz" text="Biz Day"/></c:when>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.regdate" text="Reg Date"/></div>
                        <div class="detail-value detail-value-date"><c:out value="${piipolicy.regdate}"/></div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label"><spring:message code="col.reguserid" text="Reg User"/></div>
                        <div class="detail-value"><c:out value="${piipolicy.reguserid}"/></div>
                    </div>
                </div>
            </div>

            <!-- Side-by-Side Textarea Sections -->
            <div class="detail-textarea-grid">
                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-gavel"></i> <spring:message code="col.related_law" text="Related Law"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="related_law" readonly spellcheck="false"><c:out value="${piipolicy.related_law}"/></textarea>
                    </div>
                </div>

                <div class="detail-section">
                    <div class="detail-section-title"><i class="fas fa-comment-alt"></i> <spring:message code="col.comments" text="Comments"/></div>
                    <div class="detail-textarea-wrapper">
                        <textarea class="detail-textarea" name="comments" readonly spellcheck="false"><c:out value="${piipolicy.comments}"/></textarea>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="memu.policy" text="Policy Management"/>" + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "Details");

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);
    });

    $(document).ready(function () {
        // Modify button
        $("button[data-oper='modify']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            if ($('#piipolicy_get_form [name="phase"]').val() != "CHECKOUT") {
                dlmAlert("The Policy is not checkout status");
                return;
            }

            var policy_id = $('#piipolicy_get_form [name="policy_id"]').val();
            var version = $('#piipolicy_get_form [name="version"]').val();
            var searchParams = getSearchParams();

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/modify?policy_id=" + policy_id + "&version=" + version + "&" + searchParams,
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
        });

        // List button
        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var searchParams = getSearchParams();

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/list?" + searchParams,
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
        });

        // Checkout button
        $("button[data-oper='checkout']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            if ($('#piipolicy_get_form [name="phase"]').val() != "CHECKIN") {
                dlmAlert("The policy is not 'CHECKIN' status");
                return;
            }

            var policy_id = $('#piipolicy_get_form [name="policy_id"]').val();
            var version = $('#piipolicy_get_form [name="version"]').val();

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/checkout?policy_id=" + policy_id + "&version=" + version + "&pagenum=1&amount=100&search1=" + policy_id,
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
        });

        // Version change
        $("#policy_version").change(function (e) {
            e.preventDefault();
            e.stopPropagation();

            var policy_id = $('#piipolicy_get_form [name="policy_id"]').val();
            var version = $(this).val();

            ingShow();
            $.ajax({
                type: "GET",
                url: "/piipolicy/get?policy_id=" + policy_id + "&version=" + version + "&pagenum=1&amount=100",
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
        });
    });

    function getSearchParams() {
        var params = [];
        var pagenum = $('#searchForm [name="pagenum"]').val() || 1;
        var amount = $('#searchForm [name="amount"]').val() || 100;

        params.push("pagenum=" + pagenum);
        params.push("amount=" + amount);

        for (var i = 1; i <= 8; i++) {
            var val = $('#searchForm [name="search' + i + '"]').val();
            if (val) {
                params.push("search" + i + "=" + encodeURIComponent(val));
            }
        }
        return params.join("&");
    }
</script>
