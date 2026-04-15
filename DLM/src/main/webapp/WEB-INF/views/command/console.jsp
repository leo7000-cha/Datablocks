<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="console">
    <div class="card-header m-0 p-0" style="width:100%">

            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class=search-container91>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-2" style="vertical-align: middle;"
                               for="command">Commnad</label>
                        <div class="col-sm-10">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="command"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();executeAction();}"
                                   >
                            <%--<textarea spellcheck="false" rows="1" class="form-control form-control-sm" id='command'
                                      style="font-size: 12px;"></textarea>--%>
                        </div>

                    </div>
                </div>
                <div class="search-item pr-2" style="text-align: right;">
                    <button id="commandexecute" class="btn btn-primary btn-sm p-0 pb-2 button" >Execute</button>
                </div>
            </div>
            <!-- <div class="search-container"> -->

    </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
    <div class="card-header m-0 p-0" style="width:100%">
        <form style="margin: 0; padding: 0;" role="form" id=searchForm>
            <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
            <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
            <div class=search-container91>
                <div class="search-item">
                    <div class="form-group row">
                        <label class="lable-search col-sm-2" style="vertical-align: middle;"
                               for="logfilepath"> File path</label>
                        <div class="col-sm-8">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="logfilepath"
                                   name="search1"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search1}"/>'>
                        </div>
                        <div class="col-sm-2">
                            <input type=text class="form-control form-control-sm"
                                   style="height: 25px; vertical-align: middle" id="logfile"
                                   name="search2"
                                   onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                                   value='<c:out value="${pageMaker.cri.search2}"/>'>
                        </div>
                    </div>
                </div>
                <div class="search-item pr-2" style="text-align: right;">
                    <%--<button data-oper='search' class="btn btn-secondary btn-sm p-0 pb-2 button">Move</button>--%>
                    <button data-oper='save' class="btn btn-outline-primary btn-sm p-0 pb-2 button">Save</button>
                </div>
            </div>

        </form>
    </div> <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
    <div class="card-body m-1 p-0">
        <div class="tableWrapper" style="height:750px">
            <!-- grid-template-columns: 25% 75%  ; -->
            <div id="steps" class="logfile-container" style="overflow:hidden;width:100%">
                <!-- grid-template-columns: 15%  ; -->

                <div id="steptabdiv" class="ml-1 mr-1 card shadow border" style="overflow:hidden;height:725px;">
                    <div class="card-header py-1" style="font-size: 18px; padding: 2px 2px 2px 2px;  vertical-align: middle;">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <a href="javascript:void(0);" onclick="uploadModal();"><i
                                    class="fas fa-file-upload"></i></a> &nbsp;&nbsp;&nbsp;
                            <a href="javascript:void(0);" onclick="doDownload();"><i
                                    class="fas fa-download"></i> </a>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <a href="javascript:void(0);" onclick="rmWar();">rm-War</a>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <a href="javascript:void(0);" onclick="deploy();">Deploy</a>
                        </h6>

                    </div>

                    <div class="panel panel-defaultr ml-1 mr-1 p-1"
                         style="overflow-y:auto;overflow-x:hidden; width:97%;">
                        <table id="listTable" class=" table-hover" style="width:100%;">
                            <%-- 				<thead>
                                                <tr>
                                                    <th class="th-get"><spring:message code="etc.logfilepath" text="Log file path"/></th>
                                                </tr>
                                            </thead> --%>
                            <tbody id="lstable-body">
                            <c:forEach items="${list}" var="logfiles">
                                <c:if test="${logfiles.type eq 'D' }">
                                    <tr>
                                        <td class="th-hidden"><c:out value="${logfiles.type}"/></td>
                                        <td class="th-hidden"><c:out value="${logfiles.path}"/></td>
                                        <td class="th-hidden"><c:out value="${logfiles.filename}"/></td>
                                        <td nowrap>
                                            <c:choose>
                                                <c:when test="${logfiles.type eq 'F' }"><i class="fas fa-file"></i>
                                                    <c:out value="${logfiles.filename}"/></c:when>
                                                <c:when test="${logfiles.type eq 'D' }"><i class="far fa-folder"></i>
                                                    <c:out value="${logfiles.filename}"/></c:when>
                                                <c:otherwise><c:out value="${logfiles.filename}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                            <c:forEach items="${list}" var="logfiles">
                                <c:if test="${logfiles.type ne 'D' }">
                                    <tr>
                                        <td class="th-hidden"><c:out value="${logfiles.type}"/></td>
                                        <td class="th-hidden"><c:out value="${logfiles.path}"/></td>
                                        <td class="th-hidden"><c:out value="${logfiles.filename}"/></td>
                                        <td nowrap>
                                            <c:choose>
                                                <c:when test="${logfiles.type eq 'F' }"><i class="fas fa-file"></i>
                                                    <c:out value="${logfiles.filename}"/></c:when>
                                                <c:when test="${logfiles.type eq 'D' }"><i class="far fa-folder"></i>
                                                    <c:out value="${logfiles.filename}"/></c:when>
                                                <c:otherwise><c:out value="${logfiles.filename}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- grid-template-columns:  75%  ; -->
                <div class="m-0 p-1 card shadow border">
                    <textarea spellcheck="false" rows="39" class="form-control form-control-sm" id='filecontents'
                              style="font-size: 12px;"><c:out value="${logfile.filecontents}"/></textarea>
                </div>
            </div>
        </div>
        <!-- <div class="table-responsive"> -->
        <!-- Page navigation -->
        <%-- <%@include file="../includes/pager.jsp" %> --%>
        <form style="margin: 0; padding: 0;" role="form" id="currentinfo">
            <input type='hidden' name='type' >
            <input type='hidden' name='path' >
            <input type='hidden' name='filename' >
        </form>

    </div> <!-- <div class="card-body"> -->
    <!-- table click infomation -->
    <div id="table_click_Result1"></div>
    <div id="table_click_Result2"></div>
</div>
<!-- <div class="card shadow mb-1"> -->
<!-- The Modal -->
<div class="modal fade" id="uploadmodal" role="dialog">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">File upload</h4>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="uploadmodalbody">
                <div style="vertical-align: middle;padding: 2px 2px 2px 2px;">
                    <input type='file' name='uploadFile'
                           style="height: 30px;background-color:#F7F7F9;font-size: 13px; ">
                </div>
                <div class="ml-2 mt-2" style="width:200px;height:25px;font-size:13px;">
                    <div id=uploadresult></div>
                </div>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button data-oper='uploadFile' class="btn btn-primary btn-sm p-0 pb-2 button">Upload</button>
                <!--  <button onclick="javascript:uploadModalClose();" class="btn btn-secondary btn-sm p-0 pb-2 button">Close</button> -->
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="uploadmodalclose"
                        data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<form style="margin: 0; padding: 0;" id="form1" name="form1" method="get" enctype="multipart/form-data">
    <%--<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>--%>
</form>
<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">

    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "Console");
    });
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            searchAction(1);
        })
        $("button[data-oper='save']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            saveAction();
        })

        document.getElementById("commandexecute").addEventListener("click", executeAction);

    });

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    var searchActionExecuted = false; // 중복 호출 방지를 위한 플래그 변수

    searchAction = function (pageNo, serchkeyno) {
        if (!searchActionExecuted) {
            searchActionExecuted = true;
        }else{
            return;
        }
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = encodeURIComponent($('#searchForm [name="search1"]').val());
        $('#searchForm [name="search2"]').val("");
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "console?";

        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 50;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        // if (!isEmpty(search2)) {
        //     url_search += "&search2=" + search2;
        // }

        //alert("/command/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/command/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });

        setTimeout(function () {
            searchActionExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)
    }

    var searchActionfromDirectoryExecuted = false; // 중복 호출 방지를 위한 플래그 변수
    searchActionfromDirectory = function (path) {
        if (!searchActionfromDirectoryExecuted) {
            searchActionfromDirectoryExecuted = true;
        }else{
            return;
        }
        var pagenum = 1;
        var amount = 1000;
        var search1 = encodeURIComponent(path);
        $('#searchForm [name="search2"]').val("");
        var url_search = "";
        var url_view = "console?";

        if (isEmpty(pagenum)) pagenum = 1;
        //if (!isEmpty(pageNo)) pagenum = pageNo;
        //if (isEmpty(amount)) amount = 50;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }

        //alert("/command/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/command/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });
        setTimeout(function () {
            searchActionfromDirectoryExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)
    }

    $('#lstable-body').on('dblclick', 'tr', function (e) {
        e.preventDefault();e.stopPropagation();
        var str = ""
        var tdArr = new Array();	// 배열 선언

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();


        if (td.eq(0).text() == "D") {
            searchActionfromDirectory(td.eq(1).text());
            return;
        }

        // change bg color on selected row 20210718
        $('#lstable-body > tr').each(function (index, tr) {
            $(this).css("background-color", "#FFFFFF");
            $(this).css("font-weight", "normal");
        });
        tr.css("background-color", "#E2E8F9");
        tr.css("font-weight", "bold");

        if (td.eq(0).text() == "F") {
            $('#currentinfo [name="type"]').val(td.eq(0).text());
            $('#currentinfo [name="path"]').val(td.eq(1).text());
            $('#currentinfo [name="filename"]').val(td.eq(2).text());

            $('#searchForm [name="search2"]').val(td.eq(2).text());
        }
// alert(td.eq(1).text());
        var json = {
            type: td.eq(0).text(),
            path: td.eq(1).text(),
            filename: td.eq(2).text()
        };
//alert(td.eq(0).text()+""+td.eq(1).text()+""+td.eq(2).text());
        ingShow(); $.ajax({
            url: "/command/readLogfile",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json; charset=UTF-8",

            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            },
            success: function (data) { ingHide();
                //$('#sqlmsg').html(data);
                //$('#sqlstr').html(data);
                // $('#filecontents').html(data);
                var textarea = document.getElementById('filecontents');
                textarea.value = data;
            }
        });

    })

    var saveActionExecuted = false; // 중복 호출 방지를 위한 플래그 변수
    saveAction = function () {
        if (!saveActionExecuted) {
            saveActionExecuted = true;
        }else{
            return;
        }

        var type = $('#currentinfo [name="type"]').val();
        // var path = $('#currentinfo [name="path"]').val();
        var path = $('#searchForm [name="search1"]').val(); // 새 파일명으로도 생성 가능하도록
        // var filename = $('#currentinfo [name="filename"]').val();
        var filename = $('#searchForm [name="search2"]').val(); // 새 파일명으로도 생성 가능하도록
        var textarea = document.getElementById("filecontents");
        var contents = textarea.value;

        if (isEmpty(filename)) {
            dlmAlert("Please input the file name!");
            return;
        }

        if (type == "D") {
            dlmAlert("This is not a file!");
            return;
        }

        var json = {
            type: "F",
            path: path,
            filename: filename,
            contents: contents
        };

        ingShow(); $.ajax({
            url: "/command/writefile",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json; charset=UTF-8",

            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                if (data == 'success') {
                    showToast("처리가 완료되었습니다.", false);
                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            }
        });
        setTimeout(function () {
            saveActionExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)
    }

    var executeActionExecuted = false; // 중복 호출 방지를 위한 플래그 변수
    executeAction = function () {
        if (!executeActionExecuted) {
            executeActionExecuted = true;
        }else{
            return;
        }

        var command = document.getElementById("command").value;
        var json = {
            command: command
        };

        ingShow();
        $.ajax({
            url: "/command/executecommand",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json; charset=UTF-8",

            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            },
            success: function (data) { ingHide();
                //$('#sqlmsg').html(data);
                //$('#sqlstr').html(data);
                // $('#filecontents').html(data);
                var textarea = document.getElementById('filecontents');
                textarea.value = data;
            }
        });

        setTimeout(function () {
            executeActionExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)

    }

    executeActionExecuted = false; // 중복 호출 방지를 위한 플래그 변수
    rmWar = function () {
        if (!executeActionExecuted) {
            executeActionExecuted = true;
        }else{
            return;
        }

        var command = document.getElementById("command").value;
        var json = {
            command: command
        };

        ingShow();
        $.ajax({
            url: "/command/rmWar",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json; charset=UTF-8",

            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            },
            success: function (data) { ingHide();
                var textarea = document.getElementById('filecontents');
                textarea.value = data;
            }
        });

        setTimeout(function () {
            executeActionExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)

    }
    executeActionExecuted = false; // 중복 호출 방지를 위한 플래그 변수
    deploy = function () {
        if (!executeActionExecuted) {
            executeActionExecuted = true;
        }else{
            return;
        }

        var command = document.getElementById("command").value;
        var json = {
            command: command
        };

        ingShow();
        $.ajax({
            url: "/command/deploy",
            type: "post",
            data: JSON.stringify(json),
            contentType: "application/json; charset=UTF-8",

            beforeSend: function (xhr) {   //데이터를 전송하기 전에 헤더에 csrf값을 설정한다/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            },
            success: function (data) { ingHide();
                var textarea = document.getElementById('filecontents');
                textarea.value = data;
            }
        });

        setTimeout(function () {
            executeActionExecuted = false;
        }, 1000); // 플래그 변수를 원래 상태로 되돌리기 위한 시간 지연 설정 (1초)

    }
    $("button[data-oper='uploadFile']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;
        var formData = new FormData();
        var inputFile = $("input[name='uploadFile']");
        var files = inputFile[0].files;
        formData.append("uploadFile", files[i]);
        if (files.length == 0) {
            dlmAlert("Choose the upload file");
            return false;
        } else if (files.length > 1) {
            dlmAlert("Choose only one file");
            return false;
        }

        for (var i = 0; i < files.length; i++) {
            formData.append("uploadFile", files[i]);
        }

        var search1 = $('#searchForm [name="search1"]').val();
        var url_search = "";
        var url_view = "";
        url_view = "/piiupload/" + "uploadFile?path=" + search1;

        ingShow(); $.ajax({
            url: url_view,
            processData: false,
            contentType: false,
            data: formData,
            type: 'POST',
            dataType: "application/json",
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data, textStatus, jqXHR) {ingHide();
                if (data.indexOf("successfully") != -1) {
                    //$('#uploadresult').html("<p class='text-success' style='font-size: 13px;'>"+data+"</p>");
                    $("#uploadmodal").modal("hide");
                    $("#messagemodalbody").html("<p class='text-success ' style='font-size: 14px;'>" + request.responseText + "</p>");
                    $("#messagemodal").modal("show");
                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            },
            error: function (request, error) { ingHide();
                if (request.responseText.indexOf("successfully") != -1) {
                    $("#uploadmodal").modal("hide");
                    $("#messagemodalbody").html("<p class='text-success ' style='font-size: 13px;'>" + request.responseText + "</p>");
                    $("#messagemodal").modal("show");
                } else {
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            }
        });
    });

    uploadModal = function () {
        /* 	$("button[data-oper='uploadModal']").on("click",function(e) {
                e.preventDefault();e.stopPropagation();
                doubleSubmitFlag = true; */
        $("#uploadmodal").modal();
        $('input[name=uploadFile]').val("");
        $('#uploadresult').html("");
    };
    uploadModalClose = function () {

        $("#uploadmodal").modal("hide");
        //var global_stepid = $('#jobget_global_stepid').val();
        //$("#"+global_stepid).trigger("click");
    };
    doDownload = function () {
            var path = encodeURIComponent($('#searchForm [name="search1"]').val());
            var filename = encodeURIComponent($('#searchForm [name="search2"]').val());

            var downloadUrl = "piiupload/downloadFile";
            var url = downloadUrl + "?path=" + path + "&filename=" + filename;

            window.location.href = url;
        }
</script>
