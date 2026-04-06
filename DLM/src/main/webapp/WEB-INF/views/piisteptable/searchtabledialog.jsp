<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->

<div class="search-dialog-container" style="height: 640px; width: 760px;">
    <!-- Search Header -->
    <div class="search-dialog-header">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm_std>
            <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
            <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
            <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
            <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center" style="gap: 16px;">
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <label class="search-dialog-label">DB</label>
                        <select class="search-dialog-select" name="search4" id="search4" onchange="searchAction_std_tabledialog()">
                            <option value=""></option>
                            <c:forEach items="${piidatabaselist}" var="piidatabase">
                                <option value="<c:out value="${piidatabase.db}"/>"
                                        <c:if test="${cri.search4 eq piidatabase.db}">selected</c:if> >
                                    <c:out value="${piidatabase.db}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <label class="search-dialog-label">Owner</label>
                        <input type=text class="search-dialog-input" name="search5" id="search5"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_std_tabledialog(); }"
                               value='<c:out value="${cri.search5}"/>' placeholder="Owner...">
                    </div>
                    <div class="d-flex align-items-center" style="gap: 8px;">
                        <label class="search-dialog-label">Table</label>
                        <input type=text class="search-dialog-input" style="width: 160px;" name="search6" id="search6"
                               onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction_std_tabledialog(); }"
                               value='<c:out value="${cri.search6}"/>' placeholder="Table name...">
                    </div>
                </div>
                <button onclick="event.preventDefault();searchAction_std_tabledialog();" class="btn-dialog-search">
                    <i class="fas fa-search"></i> Search
                </button>
            </div>
        </form>
    </div>

    <!-- Table Container -->
    <div class="search-dialog-table-container">
        <div class="search-dialog-table-wrapper">
            <table class="search-dialog-table" id="listTable">
                <thead>
                    <tr>
                        <th style="width: 25%;">DB</th>
                        <th style="width: 30%;">OWNER</th>
                        <th style="width: 45%;">TABLE_NAME</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach items="${piitablelist}" var="piitable">
                    <tr>
                        <td style="width: 25%;"><c:out value="${piitable.db}"/></td>
                        <td style="width: 30%;"><c:out value="${piitable.owner}"/></td>
                        <td style="width: 45%;"><c:out value="${piitable.table_name}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Page navigation -->
    <div class="search-dialog-pager">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>
<!-- <div class="card shadow mb-1"> -->

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">

    $(document).ready(function () {

        $('#searchForm_std [name="search4"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $('#searchForm_std [name="search5"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
        $('#searchForm_std [name="search6"]').bind("keyup", function () {
            $(this).val($(this).val().toUpperCase());
        });
    });
    searchAction_std_tabledialog = function () {

        var pagenum = $('#searchForm_std [name="pagenum"]').val();
        var amount = $('#searchForm_std [name="amount"]').val();
        var search1 = $('#searchForm_std [name=search1]').val();
        var search2 = $('#searchForm_std [name=search2]').val();
        var search3 = $('#searchForm_std [name=search3]').val();
        var search4 = $('#searchForm_std [name=search4]').val().toUpperCase();
        var search5 = $('#searchForm_std [name=search5]').val().toUpperCase();
        var search6 = $('#searchForm_std [name=search6]').val().toUpperCase();
        var url_search = "";
        var url_view = "";

        url_view = "searchtabledialog?jobid=" + search1 + "&" + "version=" + search2 + "&" + "stepid=" + search3
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        //if (isEmpty(pagenum))
        pagenum = 1;
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

        //alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#dialogsearchtablelistbody').html(data);
                //$("#dialogsearchtablelist").modal();

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
        var wherestr = "";
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "ILM"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "MIGRATE") {
            if( $('#piisteptable_modify_form [name="exetype"]').val() == "MIGRATE" && $('#searchtablemode').val() == "2" ){
                /** Migrate Target 테이블 정의*/
                $('#piisteptable_modify_form [name="where_col"]').val(td.eq(0).text().trim());
                $('#piisteptable_modify_form [name="where_key_name"]').val(td.eq(1).text().trim());
                $('#piisteptable_modify_form [name="sqlstr"]').val(td.eq(2).text().trim());
                $('#steptableTargetdb').text(td.eq(0).text().trim());
                $('#steptableTargetowner').text(td.eq(1).text().trim());
                $('#steptableTargetname').text(td.eq(2).text().trim());
                $("#dialogsearchtablelist").modal("hide");
                return;
            }else {
                $('#piisteptable_modify_form [name="db"]').val(td.eq(0).text().trim());
                $('#piisteptable_modify_form [name="owner"]').val(td.eq(1).text().trim());
                $('#piisteptable_modify_form [name="table_name"]').val(td.eq(2).text().trim());
                $('#steptabledb').text(td.eq(0).text().trim());
                $('#steptableowner').text(td.eq(1).text().trim());
                $('#steptable_name').text(td.eq(2).text().trim());

                wherestr = "1=1 \n"
                $('#piisteptable_modify_form [name="wherestr"]').val(wherestr);
            }
        } else {
            $('#piisteptable_modify_form [name="db"]').val(td.eq(0).text().trim());
            $('#piisteptable_modify_form [name="owner"]').val(td.eq(1).text().trim());
            $('#piisteptable_modify_form [name="table_name"]').val(td.eq(2).text().trim());
            $('#steptabledb').text(td.eq(0).text().trim());
            $('#steptableowner').text(td.eq(1).text().trim());
            $('#steptable_name').text(td.eq(2).text().trim());
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "TD_UPDATE") {
                getTDUpdateWhereClauseData();
            }
        }

        var data = {
            db: td.eq(0).text().trim(),
            owner: td.eq(1).text().trim(),
            table_name: td.eq(2).text().trim(),
            db: "",
            owner: "",
            table_name: "",
            column_name: "",
            column_id: "",
            pk_yn: "",
            pk_position: "",
            full_data_type: "",
            data_type: "",
            data_length: "",
            nullable: "",
            comments: "",
            regdate: "",
            upddate: "",
            reguserid: "",
            upduserid: ""
        };

        var pagenum = $('#searchForm_std [name="pagenum"]').val();
        var amount = $('#searchForm_std [name="amount"]').val();
        var search1 = $('#searchForm_std [name=search1]').val();
        var search2 = $('#searchForm_std [name=search2]').val();
        var search3 = $('#searchForm_std [name=search3]').val();
        var search4 = td.eq(0).text().trim().toUpperCase();
        var search5 = td.eq(1).text().trim().toUpperCase();
        var search6 = td.eq(2).text().trim().toUpperCase();
        var url_search = "";
        var url_view = "";

        url_view = "getPkcols?jobid=" + search1 + "&" + "version=" + search2 + "&" + "stepid=" + search3
            + "&";
        //if (isEmpty(pagenum))
        pagenum = 1;
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
        //alert("/piisteptable/" + url_view+ "pagenum=" + pagenum	+ "&amount=" + amount	+ url_search);
        $.ajax({
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            type: "post",
            data: JSON.stringify(data),//{"str" : JSON.stringify(param)},
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                var exetype = $('#piisteptable_modify_form [name="exetype"]').val();
                if (exetype == "DELETE" || exetype == "UPDATE") {
                    $('#piisteptable_modify_form [name="pk_col"]').val(data);
                } else if (exetype == "SCRAMBLE" || exetype == "ILM" || exetype == "MIGRATE") {
                    var parts = data.split(',');
                    var firstPart = parts[0].trim();
                    $('#piisteptable_modify_form [name="pk_col"]').val(firstPart);
                }
                // 테이블 선택 완료 플래그 (wizard 자동 오픈용)
                window._tableSelectedFromSearch = true;
                $("#dialogsearchtablelist").modal("hide");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            }

        });

    })

    movePage = function (pageNo) {
        searchAction_std(pageNo);
    }

    searchAction_std = function (pageNo, serchkeyno) {

        var pagenum = $('#searchForm_std [name="pagenum"]').val();
        var amount = $('#searchForm_std [name="amount"]').val();
        var search1 = $('#searchForm_std [name=search1]').val();
        var search2 = $('#searchForm_std [name=search2]').val();
        var search3 = $('#searchForm_std [name=search3]').val();
        var search4 = $('#searchForm_std [name=search4]').val().toUpperCase();
        var search5 = $('#searchForm_std [name=search5]').val().toUpperCase();
        var search6 = $('#searchForm_std [name=search6]').val().toUpperCase();
        var url_search = "";
        var url_view = "";

        url_view = "searchtabledialog?jobid=" + search1 + "&" + "version=" + search2 + "&" + "stepid=" + search3
            + "&";
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

        //alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#dialogsearchtablelistbody').html(data);
                //$("#dialogsearchtablelist").modal();

            }
        });
    }

    // piisteptable_modify_form 내에서 WHERE절 정보를 가져오는 AJAX 요청 (getPkcols와 별개)
    function getTDUpdateWhereClauseData() {
        var jobid = $('#searchForm_std [name=search1]').val();
        var version = $('#searchForm_std [name=search2]').val();
        var stepid = 'EXE_TRANSFORM';
        var owner = $('#piisteptable_modify_form [name="owner"]').val().trim();
        var table_name = $('#piisteptable_modify_form [name="table_name"]').val().trim();

        $.ajax({
            type: "GET", // 또는 POST
            url: "/piisteptable/getTDUpdateWhereClauseData", // 새로운 컨트롤러 URL
            data: {
                jobid: jobid,
                version: version,
                stepid: stepid,
                owner: owner,
                table_name: table_name
            },
            dataType: "json", // 서버가 JSON을 반환한다고 가정
            success: function(response) {
                var whereCol = response.whereCol;
                var whereKeyName = response.whereKeyName;
                var whereStr = response.whereStr;

                // 받아온 데이터로 SQL 문자열 구성
                var sqlstr =
                    "UPDATE " + owner + "." + table_name + " A\n" +
                    "SET A.COLUMN_TO_UPDATE = '새로운 값'\n" +
                    "WHERE EXISTS (\n" +
                    "  SELECT 1\n" +
                    "  FROM COTDL.TBL_PIIMASTERKEYMAPN B\n" +
                    "  WHERE " + whereStr + "\n" +
                    ")";

                $('#piisteptable_modify_form [name="sqlstr"]').val(sqlstr);
            },
            error: function(request, status, error) {
                alert("자동적재 대상에 테이블이 아닙니다. \n'4.EXE_TRANSFORM' 스탭내에 등록된 테이블만 업데이트 가능합니다.");
            }
        });
    }
</script>


