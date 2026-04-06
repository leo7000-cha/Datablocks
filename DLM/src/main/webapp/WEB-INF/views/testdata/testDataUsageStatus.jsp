<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">
<link href="/resources/vendor/bootstrap-datepicker/css/bootstrap-datepicker.min.css" rel="stylesheet">

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-chart-bar"></i>
            <span><spring:message code="menu.testdata_usage_status" text="Usage Status"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.testdata" text="Test Data"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="menu.testdata_usage_status" text="Usage Status"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                    <div class="policy-filter-item" style="width: 150px;">
                        <label class="policy-filter-label" for="startDate">Start Date</label>
                        <input type="text" class="policy-filter-input" id="startDate" name="startDate"
                               placeholder="YYYY/MM/DD" value='<c:out value="${startDate}"/>'>
                    </div>
                    <div class="policy-filter-item" style="width: 150px;">
                        <label class="policy-filter-label" for="endDate">End Date</label>
                        <input type="text" class="policy-filter-input" id="endDate" name="endDate"
                               placeholder="YYYY/MM/DD" value='<c:out value="${endDate}"/>'>
                    </div>
                </div>
                <div class="policy-filter-actions">
                    <button data-oper="search" class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button data-oper='excel' class="btn btn-filter-excel">
                        <i class="fas fa-download"></i> <spring:message code="btn.excel" text="EXCEL"/>
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" style="table-layout: fixed; width: 100%;">
                <colgroup>
                    <col style="width: 15%"/>
                    <col style="width: 15%"/>
                    <col style="width: 17%"/>
                    <col style="width: 18%"/>
                    <col style="width: 17%"/>
                    <col style="width: 18%"/>
                </colgroup>
                <thead>
                <tr>
                    <th><spring:message code="testdata.department" text="부서"/></th>
                    <th><spring:message code="testdata.requester" text="신청자"/></th>
                    <th class="text-right"><spring:message code="testdata.autogen_request_count" text="자동생성 신청건수"/></th>
                    <th class="text-right"><spring:message code="testdata.autogen_customer_count" text="자동생성 고객건수"/></th>
                    <th class="text-right"><spring:message code="testdata.tableload_request_count" text="테이블단위적재 신청건수"/></th>
                    <th class="text-right"><spring:message code="testdata.tableload_table_count" text="테이블단위적재 테이블수"/></th>
                </tr>
                </thead>
                <tbody>
                <!-- Total Row -->
                <tr style="background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%); font-weight: 700;">
                    <td colspan="2" style="color: #1e293b;">
                        <i class="fas fa-calculator"></i> <spring:message code="testdata.total" text="총계"/>
                    </td>
                    <td class="text-right" style="color: #6366f1; font-size: 1rem;">
                        <fmt:formatNumber value="${totalAutoGenRequestCount}" pattern="#,###"/>
                    </td>
                    <td class="text-right" style="color: #6366f1; font-size: 1rem;">
                        <fmt:formatNumber value="${totalAutoGenCustomerCount}" pattern="#,###"/>
                    </td>
                    <td class="text-right" style="color: #6366f1; font-size: 1rem;">
                        <fmt:formatNumber value="${totalTableLoadRequestCount}" pattern="#,###"/>
                    </td>
                    <td class="text-right" style="color: #6366f1; font-size: 1rem;">
                        <fmt:formatNumber value="${totalTableLoadTableCount}" pattern="#,###"/>
                    </td>
                </tr>
                <!-- Data Rows -->
                <c:forEach items="${statusList}" var="status">
                    <tr>
                        <td><c:out value="${status.deptname}"/></td>
                        <td><span class="cell-user"><c:out value="${status.userName}"/></span></td>
                        <td class="text-right"><fmt:formatNumber value="${status.autoGenRequestCount}" pattern="#,###"/></td>
                        <td class="text-right"><fmt:formatNumber value="${status.autoGenCustomerCount}" pattern="#,###"/></td>
                        <td class="text-right"><fmt:formatNumber value="${status.tableLoadRequestCount}" pattern="#,###"/></td>
                        <td class="text-right"><fmt:formatNumber value="${status.tableLoadTableCount}" pattern="#,###"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script src="/resources/vendor/bootstrap-datepicker/js/bootstrap-datepicker.min.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        $('#startDate, #endDate').datepicker({
            format: "yyyy/mm/dd",
            autoclose: true,
            todayHighlight: true,
            language: 'ko'
        });

        $('#startDate, #endDate').keypress(function (e) {
            if (e.which === 13) {
                e.preventDefault();
                $("button[data-oper='search']").click();
            }
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();

            var startDate = $('#startDate').val();
            var endDate = $('#endDate').val();

            var re = /^\d{4}\/\d{2}\/\d{2}$/;
            if (startDate && !re.test(startDate)) {
                alert("Invalid start date format (yyyy/mm/dd)");
                return;
            }
            if (endDate && !re.test(endDate)) {
                alert("Invalid end date format (yyyy/mm/dd)");
                return;
            }

            var base = "${pageContext.request.contextPath}" || "";
            ingShow();
            $.ajax({
                type: "GET",
                url: base + "/testdata/testDataUsageStatus?startDate=" + encodeURIComponent(startDate) +
                    "&endDate=" + encodeURIComponent(endDate),
                dataType: "html",
                success: function (html) {
                    ingHide();
                    $('#content_home').html(html);
                },
                error: function (req) {
                    ingHide();
                    alert("Error: " + (req.responseText || req.status));
                }
            });
        });

        $("button[data-oper='excel']").on("click", function (e) {
            e.preventDefault();

            var startDate = $('#startDate').val();
            var endDate = $('#endDate').val();

            var re = /^\d{4}\/\d{2}\/\d{2}$/;
            if (startDate && !re.test(startDate)) {
                alert("Invalid start date format (yyyy/mm/dd)");
                return;
            }
            if (endDate && !re.test(endDate)) {
                alert("Invalid end date format (yyyy/mm/dd)");
                return;
            }

            var base = "${pageContext.request.contextPath}" || "";
            var url = base + "/testdata/testDataUsageStatus/excel?startDate=" + encodeURIComponent(startDate) + "&endDate=" + encodeURIComponent(endDate);
            window.location.href = url;
        });
    });
</script>
