<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- on/off check box styles -->
<link rel="stylesheet" href="/resources/css/bootstrap4-toggle.css">
<script src="/resources/js/bootstrap4-toggle.js"></script>

<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="piicontractlist">
    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum'
                   value='<c:out value="${pageMaker.cri.pagenum}"/>'> <input
                type='hidden' name='amount'
                value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class="search-container-4-same">
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="search1"><spring:message code="col.custid" text="CUSTID"/></label>
                        <div class="col-sm-5">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="search1"
                                   name="search1"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search1}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="search2"><spring:message code="col.dept_name" text="Department"/></label>
                        <div class="col-sm-8">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="search2"
                                   name="search2"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search2}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3" style="vertical-align: middle;"
                               for="search3"><spring:message code="col.status" text="Status"/></label>
                        <div class="col-sm-8">
                            <select class="pt-0 pb-0 form-control form-control-sm" id="search3" name="search3"
                                    style="height:25px"
                                    onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}">
                                <option value=""></option>

                                    <option value="N"/>
                                            <c:if test="${pageMaker.cri.search3 eq 'N'}">selected</c:if>
                                            <spring:message code="etc.real_doc_del_not_complete" text="Document Purge not completed"/>
                                    </option>
                                    <option value="Y"/>
                                            <c:if test="${pageMaker.cri.search3 eq 'Y'}">selected</c:if>
                                            <spring:message code="etc.real_doc_del_complete" text="Document Purge completed"/>
                                    </option>

                            </select>
                        </div>
                    </div>
                </div>
                <div class="search-item pr-2" style="text-align: right;">
                    <button data-oper='search' class="btn btn-secondary btn-sm p-0 pb-2 button"><spring:message
                            code="btn.search" text="Search"/></button>
                    <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                        <button data-oper='register' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message
                                code="btn.register" text="Register"/></button>
                    </sec:authorize>
                </div>

                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-3"
                               style="vertical-align: middle;" for="search4"><spring:message code="col.arc_del_date"
                                                                                             text="Destruct Date"/></label>
                        <div class="col-sm-4">
                            <input type=text class="form-control form-control-sm" placeholder="YYYY/MM/DD" maxlength='10'
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                   style="height: 25px; vertical-align: middle" id="search4" name="search4"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search4}"/>' autocomplete="off">
                        </div>
                        ~
                        <div class="col-sm-4">
                            <input type=text class="form-control form-control-sm" placeholder="YYYY/MM/DD" maxlength='10'
                                   onkeyup="characterCheck(this)" onkeydown="characterCheck(this)"
                                   style="height: 25px; vertical-align: middle" id="search5" name="search5"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search5}"/>' autocomplete="off">
                        </div>
                    </div>
                </div>
                <div class="search-item"></div>
                <div class="search-item"></div>
                <div class="search-item"></div>

            </div>
            <!-- <div class="search-container"> -->
        </form>
    </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->

    <div class="card-body m-1 p-0">

        <div class="tableWrapper" style="height:490px">
            <table id="listTable" class="table table-sm table-hover">
                <colgroup>
                    <col style="width: 15%"/>
                    <col style="width: 35%"/>
                    <col style="width: 50%"/>
                </colgroup>
                <thead>
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.custid" text="Custid" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.contractno" text="Contractno" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.dept_cd" text="Dept_Cd" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.dept_name" text="Dept_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.contract_opn_dt" text="Contract_Opn_Dt" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.contract_close_dt" text="Contract_Close_Dt" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.pd_cd" text="Pd_Cd" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.pd_nm" text="Pd_Nm" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.status" text="Status" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.actid" text="Actid" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.rsdnt_altrntv_id" text="Rsdnt_Altrntv_Id" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.cust_nm" text="Cust_Nm" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.birth_dt" text="Birth_Dt" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.cb_dt" text="Cb_Dt" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.cust_pin" text="Cust_Pin" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.inst_cd" text="Inst_Cd" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.basedate" text="Basedate" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.actrole_end_date" text="Actrole_End_Date" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.archive_date" text="Archive_Date" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.delete_date" text="Delete_Date" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.arc_del_date" text="Arc_Del_Date" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.real_doc_del_date" text="Real_Doc_Del_Date" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.real_doc_del_userid" text="Real_Doc_Del_Userid" /></th>

                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="piicontract">
                        <tr>
                            <td class='td-get'><c:out value="${piicontract.custid}" /></td>
                            <td class='td-get'><c:out value="${piicontract.contractno}" /></td>
                            <td class='td-get'><c:out value="${piicontract.dept_cd}" /></td>
                            <td class='td-get'><c:out value="${piicontract.dept_name}" /></td>
                            <td class='td-get'><c:out value="${piicontract.contract_opn_dt}" /></td>
                            <td class='td-get'><c:out value="${piicontract.contract_close_dt}" /></td>
                            <td class='td-get'><c:out value="${piicontract.pd_cd}" /></td>
                            <td class='td-get'><c:out value="${piicontract.pd_nm}" /></td>
                            <td class='td-get'><c:out value="${piicontract.status}" /></td>
                            <td class='td-get'><c:out value="${piicontract.actid}" /></td>
                            <td class='td-get'><c:out value="${piicontract.rsdnt_altrntv_id}" /></td>
                            <td class='td-get'><c:out value="${piicontract.cust_nm}" /></td>
                            <td class='td-get'><c:out value="${piicontract.birth_dt}" /></td>
                            <td class='td-get'><c:out value="${piicontract.cb_dt}" /></td>
                            <td class='td-get'><c:out value="${piicontract.cust_pin}" /></td>
                            <td class='td-get'><c:out value="${piicontract.inst_cd}" /></td>
                            <td class='td-get'><c:out value="${piicontract.basedate}" /></td>
                            <td class='td-get'><c:out value="${piicontract.actrole_end_date}" /></td>
                            <td class='td-get'><c:out value="${piicontract.archive_date}" /></td>
                            <td class='td-get'><c:out value="${piicontract.delete_date}" /></td>
                            <td class='td-get'><c:out value="${piicontract.arc_del_date}" /></td>
                            <td class='td-get'><c:out value="${piicontract.real_doc_del_date}" /></td>
                            <td class='td-get'><c:out value="${piicontract.real_doc_del_userid}" /></td>
                        </tr>
                </c:forEach>
                </tbody>
            </table>
        </div><!-- <div class="table-responsive"> -->

        <!-- Page navigation -->
        <%@include file="../includes/pager.jsp" %>

    </div> <!-- <div class="card-body"> -->

</div>
<!-- <div class="card shadow mb-1"> -->

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>


<script type="text/javascript">

    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code="menu.real_doc_del" text="Document Purge"/>" + ">List");
    });
    flatpickr("#search4", {
        locale: "ko",               // 한국어 설정
        dateFormat: "Y/m/d",        // 저장될 포맷
        altInput: true,             // 보기용 포맷 사용
        altFormat: "Y/m/d",   // 보기용 포맷
        allowInput: true,           // 직접 입력 허용
        defaultDate: null,
        altInputClass: "form-control form-control-sm fixed-height",  // ✅ Bootstrap 스타일로 높이 맞춤
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();  // 👉 포커스 제거
        }
    });

    flatpickr("#search5", {
        locale: "ko",               // 한국어 설정
        dateFormat: "Y/m/d",        // 저장될 포맷
        altInput: true,             // 보기용 포맷 사용
        altFormat: "Y/m/d",   // 보기용 포맷
        allowInput: true,           // 직접 입력 허용
        defaultDate: null,
        altInputClass: "form-control form-control-sm fixed-height",  // ✅ Bootstrap 스타일로 높이 맞춤
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();  // 👉 포커스 제거
        }
    });

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $('#searchForm [name="search1"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $('#searchForm [name="search2"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        //$("#listTable1 tr").click(function() {
        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();e.stopPropagation();
            var str = ""
            var tdArr = new Array();	// 배열 선언

            // 현재 클릭된 Row(<tr>)
            var tr = $(this);
            var td = tr.children();

            // tr.text()는 클릭된 Row 즉 tr에 있는 모든 값을 가져온다.
            //console.log("클릭한 Row의 모든 데이터 : "+tr.text());
            // 반복문을 이용해서 배열에 값을 담아 사용할 수 도 있다.
            td.each(function (i) {
                tdArr.push(td.eq(i).text());
            });
            //console.log("배열에 담긴 값 : "+tdArr);
            // td.eq(index)를 통해 값을 가져올 수도 있다.
            var serchkeyno1 = td.eq(0).text().trim();
            var serchkeyno2 = td.eq(1).text().trim();
            var serchkeyno3 = td.eq(2).text().trim();

            var serchkeyno = "cfgkey=" + serchkeyno1;
            //alert(serchkeyno);
            //$('#content_home').load("/piicontract/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
            //content_home( "refresh" );
            searchAction(null, serchkeyno);
        })
        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            $('#content_home').load("/piicontract/register");
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

        //alert("/piicontract/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piicontract/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
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

</script>