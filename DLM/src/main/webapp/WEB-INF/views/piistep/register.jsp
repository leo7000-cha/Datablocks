<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<div class="card shadow m-1" style="border-radius: 8px; overflow: hidden;">
    <div class="card-header m-0 p-0 " style="width:100%;">
        <div class="search-container-get-1row">
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item" style="text-align: right;">

                <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_ADMIN')">
                    <button data-oper='register-step-dialog' class="btn btn-action-register btn-action-sm">
                        <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/></button>
                </sec:authorize>

            </div>
        </div>

    </div>
    <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->
    <div class="row m-0">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <!-- <h1 class="h5 mb-0 m-1">Job</h1> -->
                <div class="panel-body p-1">
                    <form style="margin: 0; padding: 0;" role="form" id="piistep_register_form">
                        <table class="job-info-table" style="width: 100%">
                            <colgroup>
                                <col style="width: 13%"/>
                                <col style="width: 20%"/>
                                <col style="width: 13%"/>
                                <col style="width: 20%"/>
                                <col style="width: 13%"/>
                                <col style="width: 20%"/>
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="th-get">STEPID</th>
                                <td class="td-get-l" colspan=5><input type="text" class="form-control form-control-sm"
                                                                                                        name='stepid'>
                                </td>
                            </tr>
                            <tr>
                                <th class="th-get">STEPNAME</th>
                                <td class="td-get" colspan=3><input type="text" class="form-control form-control-sm"
                                                                    name='stepname' >
                                </td>
                                <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                                <td class="td-get">
                                    <select class="form-control form-control-sm" name="status">
                                        <option value="ACTIVE" selected >ACTIVE
                                        </option>
                                        <option value="INACTIVE" >INACTIVE
                                        </option>
                                        <option value="HOLD" >HOLD
                                        </option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th class="th-get">STEPTYPE</th>
                                <td class="td-get">
                                    <select class="form-control form-control-sm" name="steptype" onchange="showHideRows()">
                                        <option value="EXE_EXTRACT">EXE_EXTRACT</option>
                                        <option value="GEN_KEYMAP">GEN_KEYMAP</option>
                                        <option value="EXE_ARCHIVE">EXE_ARCHIVE</option>
                                        <option value="EXE_DELETE">EXE_DELETE</option>
                                        <option value="EXE_UPDATE">EXE_UPDATE</option>
                                        <option value="EXE_BROADCAST">EXE_BROADCAST</option>
                                        <option value="EXE_HOMECAST">EXE_HOMECAST</option>
                                        <option value="EXE_FINISH">EXE_FINISH</option>
                                        <option value="EXE_MIGRATE">EXE_MIGRATE</option>
                                        <option value="EXE_SCRAMBLE">EXE_SCRAMBLE</option>
                                        <option value="EXE_ILM">EXE_ILM</option>
                                        <option value="EXE_SYNC">EXE_SYNC</option>
                                        <option value="ETC">ETC</option>
                                        <option value="ETC">EXE_TD_UPDATE</option>
                                    </select>
                                </td>
                                <th class="th-get" id="dbTh"><spring:message code="col.db" text="DB"/></th>
                                <td class="td-get">
                                    <%-- <input type="text" class="form-control form-control-sm" name='db' value='<c:out value="${piistep.db}"/>'> --%>
                                    <select class="pt-0 pb-0 form-control form-control-sm" name="db"
                                            style="font-size: 11px;">
                                        <option value=""></option>
                                        <c:forEach items="${piidatabaselist}" var="piidatabase">
                                            <option value="<c:out value="${piidatabase.db}"/>">
                                                <c:out value="${piidatabase.db}"/></option>
                                        </c:forEach>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th class="th-get"><spring:message code="col.threadtablecnt"
                                                                   text="Concurrent Operation Tables"/></th>
                                <td class="td-get">
                                    <input type="text" class="form-control form-control-sm" maxlength='2'
                                           onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='threadcnt'
                                           value='1'>
                                </td>
                                <c:choose>
                                    <c:when test="${exetype eq 'EXE_SCRAMBLE'}">
                                        <th class="th-get"  id="thCnt"><spring:message code="col.handlecnt"
                                                                           text="Data Processing Unit"/></th>
                                    </c:when>
                                    <c:when test="${exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' }">
                                        <th class="th-get"  id="thCnt"><spring:message code="col.handlecnt"
                                                                                       text="Data Processing Unit"/></th>
                                    </c:when>
                                    <c:otherwise>
                                        <th class="th-get"  id="thCnt"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                                    </c:otherwise>
                                </c:choose>
                                <td class="td-get">
                                    <input type="text" class="form-control form-control-sm" maxlength='8'
                                           onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                           value='5000'>
                                </td>
                            </tr>

                                    <tr id="dataHandlingMethodRow">
                                        <th scope="row" class="th-get" id="dynamicThId"><spring:message code="col.data_handling_method" text="Data_Handling_Method" /></th>
                                        <td class="td-get" id="dynamicTdId">
                                            <select class="form-control form-control-sm" name="data_handling_method">
                                                <option value="TRUNCSERT" selected ><spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                                </option>
                                                <option value="REPLACEINSERT" ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                                </option>
                                                <option value="DELDUPINSERT" ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                                </option>
                                                <option value="INSERT" ><spring:message code="etc.data_handling_method3" text="INSERT" />
                                                </option>
                                            </select>
                                        </td>
                                        <td class="td-get" id="dynamicTdId_MIG">
                                            <select class="form-control form-control-sm" name="data_handling_method">
                                                <option value="INSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method4" text="Insert" />
                                                </option>
                                                <option value="REPLACEINSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                                </option>
                                                <option value="DELDUPINSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                                </option>
                                                <option value="TRUNCSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'TRUNCSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                                </option>
                                            </select>
                                        </td>
                                        <%--<th class="th-get"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="fk_disable_flag">
                                                <option value="Y" >Y
                                                </option>
                                                <option value="N" selected >N
                                                </option>
                                            </select>
                                        </td>--%>
                                        <input type="hidden" class="form-control form-control-sm" name='fk_disable_flag'
                                               value='<c:out value="${piistep.fk_disable_flag}"/>'>
                                        <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="index_unusual_flag">
                                                <option value="Y"   >Y
                                                </option>
                                                <option value="N" selected >N
                                                </option>
                                                <%--<option value="YN"  >YN
                                                </option>--%>
                                            </select>
                                        </td>
                                    <tr id="processingMethodRow">
                                        <th scope="row" class="th-get"><spring:message code="col.processing_method" text="Processing_Method" /></th>
                                        <td class="td-get" COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piistep.processing_method}" />'>--%>
                                            <select class="form-control form-control-sm" name="processing_method">
                                                <option value="TMP_TABLE" >
                                                    <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                                </option>
                                                <%--<option value="SQLLDR" >
                                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                                </option>
                                                <option value="PARTITION" >
                                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                                </option>
                                                <option value="DIRECT_SQL" >
                                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                                </option>--%>
                                            </select>
                                        </td>
                                        <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="val1">
                                                <option value="1">1</option>
                                                <option value="2">2</option>
                                                <option value="3">3</option>
                                                <option value="4">4</option>
                                                <option value="5">5</option>
                                                <option value="6">6</option>
                                                <option value="7">7</option>
                                                <option value="8">8</option>
                                                <option value="9">9</option>
                                                <option value="10">10</option>
                                                <option value="11">11</option>
                                                <option value="12">12</option>
                                                <option value="13">13</option>
                                                <option value="14">14</option>
                                                <option value="15">15</option>
                                            </select>
                                        </td>
                                        <%--<th class="th-get"><spring:message code="col.createtmpparallelcnt" text="TMP Parallel Max Cnt"/></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="val2">
                                                <option value="1">1</option>
                                                <option value="2">2</option>
                                                <option value="3">3</option>
                                                <option value="4">4</option>
                                                <option value="5">5</option>
                                                <option value="6">6</option>
                                                <option value="7">7</option>
                                                <option value="8">8</option>
                                                <option value="9">9</option>
                                                <option value="10">10</option>
                                                <option value="11">11</option>
                                                <option value="12">12</option>
                                            </select>
                                        </td>--%>
                                    </tr>
                                    <%--                                    <th scope="row" class="th-get"><spring:message code="col.val1" text="Val1" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val1' value='<c:out value="${piistep.val1}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val2" text="Val2" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val2' value='<c:out value="${piistep.val2}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val3" text="Val3" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val3' value='<c:out value="${piistep.val3}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val4" text="Val4" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val4' value='<c:out value="${piistep.val4}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val5" text="Val5" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val5' value='<c:out value="${piistep.val5}" />'></td>--%>


                            </tbody>
                        </table>
                        <input type="hidden" class="form-control form-control-sm" name='jobid'
                               value='<c:out value="${jobid}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='version'
                               value='<c:out value="${version}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='phase'
                               value='<c:out value="${phase}"/>'>
                        <%--<input type="hidden" class="form-control form-control-sm" name='stepseq'
                               value='<c:out value="${piistep.stepseq}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='enddate'
                               value='<c:out value="${piistep.enddate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='regdate'
                               value='<c:out value="${piistep.regdate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upddate'
                               value='<c:out value="${piistep.upddate}"/>'>--%>
                        <input type="hidden" class="form-control form-control-sm" name='reguserid'
                               value='<sec:authentication property="principal.member.userid"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upduserid'
                               value='<sec:authentication property="principal.member.userid"/>'>
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </form>
                </div><!--  end panel-body -->
            </div><!--  panel panel-default-->
        </div><!-- col-sm-12 -->
    </div>
    <div id="registerresult" class="ml-2">${registerresult}</div>
</div>
<!-- <div class="card shadow"> DataTales begin-->

<form style="margin: 0; padding: 0;" role="form" id=searchForm>
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
</form>


<script type="text/javascript">
    function showHideRows() {
        var steptypeSelect = document.querySelector('select[name="steptype"]');
        var dataHandlingMethodRow = document.querySelector('#dataHandlingMethodRow');
        var processingMethodRow = document.querySelector('#processingMethodRow');

        var selectedValue = steptypeSelect.value;
        var thElement = document.getElementById("dbTh");
        var thElementthCnt = document.getElementById("thCnt");
        if (selectedValue === 'EXE_SCRAMBLE') {
            dataHandlingMethodRow.style.display = 'table-row';
            processingMethodRow.style.display = 'table-row';
            thElement.innerText = "Source DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_register_form [name="commitcnt"]').val(20000);
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            var tdElement_MIG = document.getElementById('dynamicTdId_MIG');
            thElement.classList.remove('th-hidden');
            tdElement.classList.remove('td-hidden');
            tdElement_MIG.classList.add('td-hidden');
        } else if (selectedValue === 'EXE_ILM' ) {
            dataHandlingMethodRow.style.display = 'table-row';
            processingMethodRow.style.display = 'table-row';
            thElement.innerText = "Archiving DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_register_form [name="commitcnt"]').val(20000);
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            var tdElement_MIG = document.getElementById('dynamicTdId_MIG');
            thElement.classList.remove('th-hidden');
            tdElement.classList.add('td-hidden');
            tdElement_MIG.classList.remove('td-hidden');
        } else if (selectedValue === 'EXE_MIGRATE' ) {
            dataHandlingMethodRow.style.display = 'table-row';
            processingMethodRow.style.display = 'table-row';
            thElement.innerText = "Target DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_register_form [name="commitcnt"]').val(20000);
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            var tdElement_MIG = document.getElementById('dynamicTdId_MIG');
            thElement.classList.remove('th-hidden');
            tdElement.classList.add('td-hidden');
            tdElement_MIG.classList.remove('td-hidden');
        } else {
            dataHandlingMethodRow.style.display = 'none';
            processingMethodRow.style.display = 'none';
            thElement.innerText = "DB" ;
            thElementthCnt.innerText = '<spring:message code="col.commitcnt" text="Commitcnt"/>' ;
            $('#piistep_register_form [name="commitcnt"]').val(5000)
        }
    }
    $(document).ready(function () {
        dataHandlingMethodRow.style.display = 'none';
        processingMethodRow.style.display = 'none';

        /*$("select[name='data_handling_method']").on('change', function() {
            // 선택한 데이터 처리 방법을 확인
            var dataHandlingMethod = $(this).val();
            // REPLACEINSERT가 선택되면 TMP_TABLE 항목을 숨김
            if (dataHandlingMethod === 'REPLACEINSERT') {
                $("select[name='processing_method'] option[value='TMP_TABLE']").hide();
            } else {
                // 다른 경우에는 TMP_TABLE 항목을 다시 보이게 함
                $("select[name='processing_method'] option[value='TMP_TABLE']").show();
            }
        });*/


        $("button[data-oper='register-step-dialog']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            if (isEmpty($('#piistep_register_form [name="stepid"]').val())) {
                alert('Stepid is mandatory');
                $('#piistep_register_form [name="stepid"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="stepname"]').val())) {
                alert('Stepname is mandatory');
                $('#piistep_register_form [name="stepname"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="steptype"]').val())) {
                alert('Steptype is mandatory');
                $('#piistep_register_form [name="steptype"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="db"]').val())) {
                alert('DB is mandatory');
                $('#piistep_register_form [name="db"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="threadcnt"]').val())) {
                alert('Threadcnt is mandatory');
                $('#piistep_register_form [name="threadcnt"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="commitcnt"]').val())) {
                alert('Commitcnt is mandatory');
                $('#piistep_register_form [name="commitcnt"]').focus();
                return;
            }
            if (isEmpty($('#piistep_register_form [name="status"]').val())) {
                alert('Status is mandatory');
                $('#piistep_register_form [name="status"]').focus();
                return;
            }
            var steptype = $('#piistep_register_form [name="steptype"]').val();
            if(steptype == "EXE_SCRAMBLE"){
                if (isEmpty($('#piistep_register_form [name="data_handling_method"]').val())) {
                    alert('<spring:message code="col.data_handling_method" text="Data_Handling_Method" /> is mandatory');
                    $('#piistep_register_form [name="data_handling_method"]').focus();
                    return;
                }
                if (isEmpty($('#piistep_register_form [name="processing_method"]').val())) {
                    alert('<spring:message code="col.processing_method" text="Processing_Method" /> is mandatory');
                    $('#piistep_register_form [name="processing_method"]').focus();
                    return;
                }
                /*if (isEmpty($('#piistep_register_form [name="fk_disable_flag"]').val())) {
                    alert('<spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /> is mandatory');
                    $('#piistep_register_form [name="fk_disable_flag"]').focus();
                    return;
                }*/
                if (isEmpty($('#piistep_register_form [name="index_unusual_flag"]').val())) {
                    alert('<spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /> is mandatory');
                    $('#piistep_register_form [name="index_unusual_flag"]').focus();
                    return;
                }
                if (isEmpty($('#piistep_register_form [name="val1"]').val())) {
                    alert('<spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt" /> is mandatory');
                    $('#piistep_register_form [name="val1"]').focus();
                    return;
                }
            } else if(steptype == "EXE_ILM" || steptype == "EXE_MIGRATE" || steptype == "EXE_SYNC"){
                if (isEmpty($('#piistep_register_form [name="processing_method"]').val())) {
                    alert('<spring:message code="col.processing_method" text="Processing_Method" /> is mandatory');
                    $('#piistep_register_form [name="processing_method"]').focus();
                    return;
                }
                /*if (isEmpty($('#piistep_register_form [name="fk_disable_flag"]').val())) {
                    alert('<spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /> is mandatory');
                    $('#piistep_register_form [name="fk_disable_flag"]').focus();
                    return;
                }*/
                if (isEmpty($('#piistep_register_form [name="index_unusual_flag"]').val())) {
                    alert('<spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /> is mandatory');
                    $('#piistep_register_form [name="index_unusual_flag"]').focus();
                    return;
                }
                if (isEmpty($('#piistep_register_form [name="val1"]').val())) {
                    alert('<spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt" /> is mandatory');
                    $('#piistep_register_form [name="val1"]').focus();
                    return;
                }
            } else {
                $('#piistep_register_form [name="data_handling_method"]').val("");
                $('#piistep_register_form [name="processing_method"]').val("");
                $('#piistep_register_form [name="fk_disable_flag"]').val("");
                $('#piistep_register_form [name="index_unusual_flag"]').val("");
                $('#piistep_register_form [name="val1"]').val("");
            }

            $('#step_md_global_jobid').val($('#piistep_register_form [name="jobid"]').val());
            $('#step_md_global_version').val($('#piistep_register_form [name="version"]').val());
            $('#step_md_global_stepid').val($('#piistep_register_form [name="stepid"]').val().toUpperCase());

            var jobid = $('#step_md_global_jobid').val();
            var version = $('#step_md_global_version').val();
            var stepid = $('#step_md_global_stepid').val();

            $('#piistep_register_form [name="stepid"]').val($('#piistep_register_form [name="stepid"]').val().toUpperCase())
            $('#piistep_register_form [name="stepname"]').val($('#piistep_register_form [name="stepname"]').val().toUpperCase())
            var elementForm = $("#piistep_register_form");
            var elementResult = $("#stepmodalbody");
            ingShow();
            $.ajax({
                type: "POST",
                url: "/piistep/register",
                dataType: "text", // 서버에서 문자열(String)을 반환하므로 text로 변경
                data: elementForm.serialize(),
                error: function (request) {
                    ingHide();
                    alert(request.responseText);;
                },
                success: function (data) {
                    ingHide();
                    // 성공 시 별도의 처리
                    $('#modify_step_dlg_result').html(data);

                    // Refresh the step list first, then load modify view as callback
                    var url_view = "/piistep/modify?jobid=" + jobid + "&" + "version=" + version + "&" + "stepid=" + stepid + "&";
                    if (typeof refreshStepList === 'function') {
                        refreshStepList(stepid, function() {
                            searchAction_stepdialog(null, url_view, "#stepdetaildilaog");
                        });
                    } else {
                        searchAction_stepdialog(null, url_view, "#stepdetaildilaog");
                    }
                }
            });
        });

        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (isEmpty(amount)) amount = 100;
            if (!isEmpty(search1)) {
                url_search += "&search1=" + search1
            }
            ;
            if (!isEmpty(search2)) {
                url_search += "&search2=" + search2
            }
            ;

            //alert("/piistep/list?pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/piistep/list?pagenum="
                    + pagenum + "&amount="
                    + amount + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    $('#content_home').html(data);
                }
            });

        });

    });
</script>




 

 