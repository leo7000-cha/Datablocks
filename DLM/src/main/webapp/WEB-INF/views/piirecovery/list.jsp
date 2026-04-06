<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Policy Management CSS (shared styles) -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Main Container -->
<div class="policy-management-container">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-history"></i>
            <span><spring:message code="memu.recovery_list" text="Recovery History"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.recovery_management" text="Recovery"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.recovery_list" text="History"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <input type='hidden' name='search2' value='<c:out value="${pageMaker.cri.search2}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                    <div class="policy-filter-item" style="width: 300px;">
                        <label class="policy-filter-label" for="search1"><spring:message code="etc.jobid" text="JOBID"/></label>
                        <select class="form-control form-control-sm" name="search1" id="search1" style="height: 34px;"
                                onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                            <option value=""></option>
                            <c:forEach items="${listjob}" var="piijob">
                                <option value="<c:out value="${piijob.jobid}"/>"
                                        <c:if test="${pageMaker.cri.search1 eq piijob.jobid}">selected</c:if>>
                                    <c:out value="${piijob.jobid}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="policy-filter-actions">
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
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
                    <col style="width: 80px"/>
                    <col style="width: 100px"/>
                    <col style="width: 180px"/>
                    <col style="width: 220px"/>
                    <col style="width: 80px"/>
                    <col style="width: 150px"/>
                    <col style="width: 100px"/>
                </colgroup>
                <thead>
                <tr>
                    <th><spring:message code="col.recoveryid" text="Recovery ID"/></th>
                    <th><spring:message code="etc.recovery_orderid" text="New Order"/></th>
                    <th>Original_<spring:message code="col.jobid" text="JOBID"/></th>
                    <th><spring:message code="etc.recovery_jobid" text="Recovery JOBID"/></th>
                    <th><spring:message code="col.status" text="Status"/></th>
                    <th><spring:message code="etc.recovery_datetime" text="Recovery Time"/></th>
                    <th><spring:message code="etc.recovery_user" text="User"/></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piirecovery">
                    <tr>
                        <td class="text-right"><c:out value="${piirecovery.recoveryid}"/></td>
                        <td class="text-right"><c:out value="${piirecovery.new_orderid}"/></td>
                        <td style="max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${piirecovery.old_jobid}"/>"><c:out value="${piirecovery.old_jobid}"/></td>
                        <td style="max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${piirecovery.new_jobid}"/>">
                            <a href="javascript:diologDetailAction('${piirecovery.new_orderid}','${piirecovery.new_jobid}','','')">
                                <c:out value="${piirecovery.new_jobid}"/>
                            </a>
                        </td>
                        <td><c:out value="${piirecovery.status}"/></td>
                        <td class="text-center"><c:out value="${piirecovery.regdate}"/></td>
                        <td class="text-center"><c:out value="${piirecovery.reguserid}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Page navigation -->
    <div class="policy-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>

</div>

<script type="text/javascript">
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })

    });


    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }

        $.ajax({
            type: "GET",
            url: "/piirecovery/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });

    }

    diologDetailAction = function (orderid, jobid, version, jobname) {

        $.ajax({
            type: "GET",
            url: encodeURI("/piiorder/getorderdetail?" + "orderid=" + orderid + "&jobid=" + jobid + "&version=" + version + "&stepseq=" + "0" + "&action=" + "1"),
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#jobdetailheader').html(jobid);
                $('#jobdetailbody').html(data);
                $("#jobdetailmodal").modal();
                $("#" + "1").addClass("active");
            }
        });
    }

</script>
