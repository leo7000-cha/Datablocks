<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
            <i class="fas fa-box"></i>
            <span><spring:message code="memu.recovery_order_apply" text="Order Recovery"/></span>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.recovery_management" text="Recovery"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.recovery_order_apply" text="Order"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <form style="margin: 0; padding: 0;" role="form" id="searchForm">
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="policy-filter-row">
                <div class="policy-filter-grid" style="display: flex; gap: 12px;">
                    <div class="policy-filter-item" style="width: 300px;">
                        <label class="policy-filter-label" for="search1"><spring:message code="etc.jobid" text="JOBID"/></label>
                        <select class="form-control form-control-sm" name="search1" id="search1" style="height: 34px;"
                                onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                            <option value=""></option>
                            <c:forEach items="${listjob}" var="piijob">
                                <c:if test="${'ARCHIVE_DB' ne piijob.jobid }">
                                    <option value="<c:out value="${piijob.jobid}"/>" <c:if test="${pageMaker.cri.search1 eq piijob.jobid}">selected</c:if>><c:out value="${piijob.jobid}"/></option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="policy-filter-item" style="width: 150px;">
                        <label class="policy-filter-label" for="search2"><spring:message code="col.basedate" text="Basedate"/></label>
                        <input type="text" class="policy-filter-input" placeholder="YYYY/MM/DD" maxlength="10"
                               id="search2" name="search2"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                               value='<c:out value="${pageMaker.cri.search2}"/>' autocomplete="off">
                    </div>
                </div>
                <div class="policy-filter-actions">
                    <button data-oper='search' class="btn btn-filter-search">
                        <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                    </button>
                    <button data-oper='register' class="btn btn-filter-register">
                        <i class="fas fa-redo-alt"></i> <spring:message code="etc.recovery" text="Recovery"/>
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
                    <col style="width: 40px"/>
                    <col style="width: 80px"/>
                    <col style="width: 100px"/>
                    <col style="width: 180px"/>
                    <col style="width: 60px"/>
                    <col style="width: 80px"/>
                    <col style="width: 80px"/>
                    <col style="width: 70px"/>
                    <col style="width: 70px"/>
                    <col style="width: 70px"/>
                    <col style="width: 130px"/>
                    <col style="width: 80px"/>
                </colgroup>
                <thead>
                <tr>
                    <th>&nbsp;</th>
                    <th><spring:message code="col.orderid" text="ORDERID"/></th>
                    <th><spring:message code="col.basedate" text="Basedate"/></th>
                    <th><spring:message code="col.jobid" text="JOBID"/></th>
                    <th><spring:message code="col.version" text="Ver"/></th>
                    <th><spring:message code="col.system" text="System"/></th>
                    <th><spring:message code="col.keymap_id" text="Keymap"/></th>
                    <th><spring:message code="col.jobtype" text="Jobtype"/></th>
                    <th><spring:message code="col.runtype" text="Runtype"/></th>
                    <th><spring:message code="col.calendar" text="Calendar"/></th>
                    <th><spring:message code="col.realendtime" text="Realendtime"/></th>
                    <th><spring:message code="col.status" text="Status"/></th>
                </tr>
                </thead>
                <tbody id="apply">
                <c:forEach items="${list}" var="piiorder">
                    <tr>
                        <td class="text-center"><input type="radio" class="chkRadio" name="chkRadio" onClick="checkeRowColorChange(this);" style="width:15px;height:15px;"></td>
                        <td class="text-right"><c:out value="${piiorder.orderid}"/></td>
                        <td class="text-center"><c:out value="${piiorder.basedate}"/></td>
                        <td style="max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<c:out value="${piiorder.jobid}"/>"><c:out value="${piiorder.jobid}"/></td>
                        <td class="text-right"><c:out value="${piiorder.version}"/></td>
                        <td><c:out value="${piiorder.system}"/></td>
                        <td><c:out value="${piiorder.keymap_id}"/></td>
                        <td><c:out value="${piiorder.jobtype}"/></td>
                        <td><c:out value="${piiorder.runtype}"/></td>
                        <td class="text-center"><c:out value="${piiorder.calendar}"/></td>
                        <td class="text-center"><c:out value="${piiorder.realendtime}"/></td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${piiorder.status eq 'Ended OK' }"><span class="status-badge status-success"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Ended not OK' }"><span class="status-badge status-error">Error</span></c:when>
                                <c:when test="${piiorder.status eq 'Running' }"><span class="status-badge status-running"><i class="fa fa-spinner fa-spin"></i> <c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Wait condition' }"><span class="status-badge status-wait">Wait</span></c:when>
                                <c:when test="${piiorder.status eq 'Recovered' }"><span class="status-badge status-warning"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:when test="${piiorder.status eq 'Hold' }"><span class="status-badge status-warning"><c:out value="${piiorder.status}"/></span></c:when>
                                <c:otherwise><span class="status-badge"><c:out value="${piiorder.status}"/></span></c:otherwise>
                            </c:choose>
                        </td>
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
    function checkeRowColorChange(obj) {
        jQuery("#apply > tr").css("background-color", "");
        var row = jQuery(".chkRadio").index(obj);
        jQuery("#apply > tr").eq(row).css("background-color", "#e0f2fe");
    };

    flatpickr("#search2", {
        locale: "ko",
        dateFormat: "Y/m/d",
        altInput: true,
        altFormat: "Y/m/d",
        allowInput: true,
        defaultDate: null,
        altInputClass: "policy-filter-input",
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    $(document).ready(function() {

        $("button[data-oper='register']").on("click", function(e){
            e.preventDefault();e.stopPropagation();

            var param = [];
            var checkedcnt = 0;
            if(jQuery(".chkRadio:checked").val()) {
                var row = jQuery(".chkRadio:checked").parent().parent();
                var td = row.children();

                if(td.eq(11).text().trim() == "Wait")
                {alert("Wait condition can not be recovered");return;}

                var data = {
                    recoveryid     	:null,
                    phase      		:"APPLY",
                    old_orderid    	:td.eq(1).text().trim(),
                    new_orderid    	:null,
                    keymap_id 		:td.eq(6).text().trim(),
                    basedate      	:td.eq(2).text().trim(),
                    old_jobid      	:td.eq(3).text().trim(),
                    old_version     :td.eq(4).text().trim(),
                    new_jobid      	:td.eq(3).text().trim()+"_Recovery:"+td.eq(1).text().trim(),
                    status      	:"NEW",
                    regdate      	:null,
                    upddate      	:null,
                    reguserid      	:$('#global_userid').val(),
                    upduserid      	:$('#global_userid').val()
                };

                param.push(data);
                checkedcnt++;
            }
            if(checkedcnt == 0) {alert("Select a Order for recovery");return;}

            $.ajax({
                url         :   "/piirecovery/orderregister",
                dataType    :   "text",
                contentType :   "application/json; charset=UTF-8",
                type        :   "post",
                data        :   JSON.stringify(param),
                beforeSend  : function(xhr)
                {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function(data, textStatus, jqXHR)
                {
                    $("#GlobalSuccessMsgModal").modal("show");
                    searchAction(1);
                },
                error: function(request, error){ ingHide();
                    $("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
                }

            });

        });

        $("button[data-oper='search']").on("click", function(e){
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })

        $("button[data-oper='list']").on("click", function(e){
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piirecovery/list");
        });

    });

    searchAction = function(pageNo, serchkeyno) {
        var pagenum  = $('#searchForm [name="pagenum"]').val();
        var amount   = $('#searchForm [name="amount"]').val();
        var search1  = $('#searchForm [name="search1"]').val();
        var search2  = $('#searchForm [name="search2"]').val();

        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {url_view = "orderlist?"; } else {url_view = "get?"+serchkeyno+"&";}
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {url_search += "&search1="+search1;}
        if (!isEmpty(search2)) {url_search += "&search2="+search2;}
        $.ajax({
            type: "GET",
            url : "/piirecovery/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search,
            dataType : "html",
            error: function(request, error){ ingHide();
                $("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
            },
            success: function(data){ ingHide();
                $('#content_home').html(data);
            }
        });
    }

</script>
