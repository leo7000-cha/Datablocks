<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">
<!-- Begin Page Content -->

<div class="search-dialog-container" style="height: 500px; width: 100%;">
    <div class="search-dialog-header">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm_diologSearchMember>
            <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
            <input type='hidden' name='search3' value='<c:out value="${pageMaker.cri.search3}"/>'>
            <input type='hidden' name='search4' value='<c:out value="${pageMaker.cri.search4}"/>'>
            <input type='hidden' name='search5' value='<c:out value="${pageMaker.cri.search5}"/>'>
            <input type='hidden' name='search6' value='<c:out value="${pageMaker.cri.search6}"/>'>
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center" style="gap: 16px;">
                    <div class="d-flex align-items-center" style="gap: 6px;">
                        <label class="search-dialog-label mb-0"><spring:message code="col.userid" text="Userid"/></label>
                        <input type=text class="search-dialog-input" style="width: 140px;"
                               name="search1" id="search1"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_dsm(); }"
                               value='<c:out value="${pageMaker.cri.search1}"/>' placeholder="Search Userid...">
                    </div>
                    <div class="d-flex align-items-center" style="gap: 6px;">
                        <label class="search-dialog-label mb-0"><spring:message code="col.username" text="Username"/></label>
                        <input type=text class="search-dialog-input" style="width: 140px;"
                               name="search2" id="search2"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_dsm(); }"
                               value='<c:out value="${pageMaker.cri.search2}"/>' placeholder="Search Username...">
                    </div>
                </div>
                <button onclick="event.preventDefault();searchAction_dsm();" class="btn-dialog-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/></button>
            </div>
        </form>
    </div>
    <div class="search-dialog-table-container">
        <table class="wizard-compact-table wizard-header-table">
            <thead>
            <tr>
                <th><spring:message code="col.userid" text="Userid"/></th>
                <th><spring:message code="col.username" text="Username"/></th>
            </tr>
            </thead>
        </table>
        <div class="search-dialog-table-wrapper" style="height: 380px;">
            <table class="wizard-compact-table" id="listTable">
                <tbody>
                <c:forEach items="${list}" var="member">
                    <tr>
                        <td><c:out value="${member.userid}"/></td>
                        <td><c:out value="${member.username}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    <!-- Page navigation -->
    <%@include file="../includes/pager.jsp" %>
</div>
<!-- <div class="card shadow mb-1"> -->

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>


<script type="text/javascript">

    searchAction_dsm = function (pageNo) {

        var pagenum = $('#searchForm_diologSearchMember [name="pagenum"]').val();
        var amount = $('#searchForm_diologSearchMember [name="amount"]').val();
        var search1 = $('#searchForm_diologSearchMember [name=search1]').val();
        var search2 = $('#searchForm_diologSearchMember [name=search2]').val();
        var search3 = $('#searchForm_diologSearchMember [name=search3]').val();
        var search4 = $('#searchForm_diologSearchMember [name=search4]').val();
        var search5 = $('#searchForm_diologSearchMember [name=search5]').val();
        var search6 = $('#searchForm_diologSearchMember [name=search6]').val();
        var url_search = "";
        var url_view = "";

        url_view = "diologsearchmember?";
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;

        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4;
        }
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }

        //alert("/piimember/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piimember/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                // Support both old and new modal body IDs
                if ($('#memberSearchModalBody').length) {
                    $('#memberSearchModalBody').html(data);
                } else {
                    $('#diologsearchmemberlistbody').html(data);
                }
                //$("#diologsearchmemberlist").modal();

            }
        });
    }

    $('#listTable tbody').on('dblclick', 'tr', function (e) {
        e.preventDefault();e.stopPropagation();
        var str = ""
        var tdArr = new Array();	// 배열 선언

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();

        var search3 = $('#searchForm_diologSearchMember [name="search3"]').val();
        var search4 = $('#searchForm_diologSearchMember [name="search4"]').val();

        if (search4 == "modify") {
            if (search3 == 1) {
                $('#job_owner_name1').text(td.eq(1).text().trim());
                $('#piijob_modify_form [name="job_owner_name1"]').val(td.eq(1).text().trim()).trigger("change");
                $('#piijob_modify_form [name="job_owner_id1"]').val(td.eq(0).text().trim());
            } else if (search3 == 2) {
                $('#job_owner_name2').text(td.eq(1).text().trim());
                $('#piijob_modify_form [name="job_owner_name2"]').val(td.eq(1).text().trim()).trigger("change");
                $('#piijob_modify_form [name="job_owner_id2"]').val(td.eq(0).text().trim());
            } else if (search3 == 3) {
                $('#job_owner_name3').text(td.eq(1).text().trim());
                $('#piijob_modify_form [name="job_owner_name3"]').val(td.eq(1).text().trim()).trigger("change");
                $('#piijob_modify_form [name="job_owner_id3"]').val(td.eq(0).text().trim());
            }
        } else if (search4 == "register") {
            if (search3 == 1) {
                $('#job_owner_name1').text(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_name1"]').val(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_id1"]').val(td.eq(0).text().trim());
            } else if (search3 == 2) {
                $('#job_owner_name2').text(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_name2"]').val(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_id2"]').val(td.eq(0).text().trim());
            } else if (search3 == 3) {
                $('#job_owner_name3').text(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_name3"]').val(td.eq(1).text().trim());
                $('#piijob_register_form [name="job_owner_id3"]').val(td.eq(0).text().trim());
            }
        } else if (search4 == "approval_modify") {
            // Support both old and new form IDs
            $('#approvalsuer_approvername').text(td.eq(1).text().trim());
            $('#piiapprovaluser_modify_form [name="approvername"]').val(td.eq(1).text().trim());
            $('#piiapprovaluser_modify_form [name="approverid"]').val(td.eq(0).text().trim());
            // New modal form support
            if ($('#modifyForm').length) {
                $('#modifyForm [name="approvername"]').val(td.eq(1).text().trim());
                $('#modifyForm [name="approverid"]').val(td.eq(0).text().trim());
                $('#modifyForm [name="approvername_display"]').val(td.eq(1).text().trim() + ' (' + td.eq(0).text().trim() + ')');
                $('#memberSearchModal').modal('hide');
                return;
            }
        } else if (search4 == "approval_register") {
            // Support both old and new form IDs
            $('#approvalsuer_approvername').text(td.eq(1).text().trim());
            $('#piiapprovaluser_register_form [name="approvername"]').val(td.eq(1).text().trim());
            $('#piiapprovaluser_register_form [name="approverid"]').val(td.eq(0).text().trim());
            // New modal form support
            if ($('#registerForm').length) {
                $('#registerForm [name="approvername"]').val(td.eq(1).text().trim());
                $('#registerForm [name="approverid"]').val(td.eq(0).text().trim());
                $('#registerForm [name="approvername_display"]').val(td.eq(1).text().trim() + ' (' + td.eq(0).text().trim() + ')');
                $('#memberSearchModal').modal('hide');
                return;
            }
        } else if (search4 == "approval_step_user") {
            $('#approvalstepbody > tr').each(function (index, tr) {
                var trr = $(this);
                if(search3 == index) {
                    // Update approver ID and name cells
                    trr.find('.td-approverid').text(td.eq(0).text().trim());
                    trr.find('.td-approvername').text(td.eq(1).text().trim());
                }
            });
        }

        $("#diologsearchmemberlist").modal("hide");
    })

    movePage = function (pageNo) {
        searchAction_dsm(pageNo);
    }


</script>


