<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height: 670px;width: 1100px;" id="metatablelist">
    <div class="card-body m-1 p-0" style="height:665px;width:99%;border:1px solid #ECEEEE;">
        <div class="tableWrapper" style="height:625px;width:100%;">
            <table id="listTable" class="table table-sm table-hover">
                <thead>
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.db" text="DB" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.owner" text="Owner" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.table_name" text="Table_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.column_name" text="Column_Name" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.column_id" text="Column_Id" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.pk_yn_br" text="Pk_Yn" /></th>
                    <%--<th scope="row" class="th-get"><spring:message code="col.pk_position" text="Pk_Position" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.full_data_type" text="Full_Data_Type" /></th>--%>
                    <th scope="row" class="th-get"><spring:message code="col.data_type" text="Data_Type" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.data_length" text="Data_Length" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.domain" text="Domain" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.encript_flag_br" text="Encript_Flag" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.piigrade_br" text="Piigrade" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.piitype" text="Piitype" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.scramble_type" text="Scramble_Type" /></th>
                    <th scope="row" class="th-get"><spring:message code="col.upddate" text="Update date" /></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${list}" var="metatable">
                    <tr>
                        <td class='td-get-l'><c:out value="${metatable.db}" /></td>
                        <td class='td-get-l'><c:out value="${metatable.owner}" /></td>
                        <td class='td-get-l'><c:out value="${metatable.table_name}" /></td>
                        <td class='td-get-l'><c:out value="${metatable.column_name}" /></td>
                        <td class='td-get-r'><c:out value="${metatable.column_id}" /></td>
                        <td class='td-get-l'><c:out value="${metatable.pk_yn}" /></td>
                        <%--<td><c:out value="${metatable.pk_position}" /></td>
                        <td><c:out value="${metatable.full_data_type}" /></td>--%>
                        <td class='td-get-l'><c:out value="${metatable.data_type}" /></td>
                        <td class='td-get-r'><c:out value="${metatable.data_length}" /></td>
                        <td class='td-get-l'><c:out value="${metatable.domain}" /></td>
                        <td class='td-get'><c:out value="${metatable.encript_flag}" /></td>
                        <td class='td-get'><c:out value="${metatable.piigrade}" /></td>
                        <td class='td-get-l' <%--onclick="diologMetaUpdateAction(this)"--%>><%--<c:out value="${metatable.piitype}" />--%>
                            <c:forEach var="item" items="${listlkPiiScrType}">
                                <c:if test="${metatable.piitype eq item.piicode}">
                                    <c:out value="${item.piitypename}" />
                                </c:if>
                            </c:forEach>
                        </td>
                        <td class="td-get-l"><c:out value="${metatable.scramble_type}" /></td>
                        <td><c:out value="${metatable.upddate}" /></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div><!-- <div class="table-responsive"> -->

        <!-- Page navigation -->
        <%@include file="../includes/pager.jsp" %>

    </div> <!-- <div class="card-body"> -->
</div>

<!-- 스크립트 추가 -->
<%--<script>
    // Close 버튼 클릭 시
    $("#dialogmetadataupdateclose").click(function() {
        // 현재 열려 있는 모달을 닫기
        $(".modal.show").modal("hide");
    });
</script>--%>
<!-- <div class="card shadow mb-1"> -->


<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    var selectedRow;

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);


        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();e.stopPropagation();

            // 현재 클릭된 Row(<tr>)
            selectedRow = $(this);
            var td = selectedRow.children();

            // this 요소의 값을 업데이트
            // tdElement.innerText = "Updated Value";

            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = 10000;
            var search1 = td.eq(0).text();//db
            var search2 = td.eq(1).text();//owner
            var search3 = td.eq(2).text();//table_name
            var search4 = td.eq(3).text();//column_name
            var url_search = "";
            var url_view = "modifydialog?";

            if (isEmpty(pagenum)) pagenum = 1;

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
            /*if (!isEmpty(search5)) {
                url_search += "&search5=" + search5;
            }
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6;
            }
            if (!isEmpty(search7)) {
                url_search += "&search7=" + search7;
            }
            if (!isEmpty(search8)) {
                url_search += "&search8=" + search8;
            }
            if (!isEmpty(search9)) {
                url_search += "&search9=" + search9;
            }*/
            /*alert("/ssmbanupload/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search);*/
            $.ajax({
                type: "GET",
                url: "/metatable/" + url_view
                    + "pagenum=" + pagenum
                    + "&amount=" + amount
                    + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();//alert('success1');
                    $('#dialogmetadataupdatebody').html(data);
                    $("#dialogmetadataupdate").modal();

                }
            });
        })


    });

    diologMetaUpdateAction = function (tdElement) {
        //e.preventDefault();e.stopPropagation();
        selectedCell = tdElement;
        var row = tdElement.parentNode; // 클릭한 <td> 요소의 부모 노드인 <tr> 요소를 가져옴
        var rowIndex = row.rowIndex; // 해당 <tr> 요소의 인덱스를 가져옴

        var cells = row.getElementsByTagName("td"); // 해당 <tr> 요소의 모든 <td> 요소를 가져옴
        var cellValues = [];

        for (var i = 0; i < cells.length; i++) {
            cellValues.push(cells[i].innerText); // 각 <td> 요소의 내용을 배열에 추가
        }

        // this 요소의 값을 업데이트
        // tdElement.innerText = "Updated Value";

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = 10000;
        var search1 = cellValues[0];//db
        var search2 = cellValues[1];//owner
        var search3 = cellValues[2];//table_name
        var search4 = cellValues[3];//column_name
        var url_search = "";
        var url_view = "modifydialog?";

        if (isEmpty(pagenum)) pagenum = 1;

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
        /*if (!isEmpty(search5)) {
            url_search += "&search5=" + search5;
        }
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6;
        }
        if (!isEmpty(search7)) {
            url_search += "&search7=" + search7;
        }
        if (!isEmpty(search8)) {
            url_search += "&search8=" + search8;
        }
        if (!isEmpty(search9)) {
            url_search += "&search9=" + search9;
        }*/
        /*alert("/ssmbanupload/" + url_view
            + "pagenum=" + pagenum
            + "&amount=" + amount
            + url_search);*/
        $.ajax({
            type: "GET",
            url: "/metatable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#dialogmetadataupdatebody').html(data);
                $("#dialogmetadataupdate").modal();

            }
        });
    }
</script>
