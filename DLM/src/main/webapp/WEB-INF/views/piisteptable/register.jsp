<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- <div class="card shadow m-1"> -->
<!-- <div class="row m-0 p-0">
<div class="col-sm-12">
<div class="panel panel-default m-0 p-0" style="width: 100%">

<div class="panel-body"> -->
<div class="table-detail-actions">
    <c:set var="exetype" value="${piisteptable.exetype}"/>
    <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_ADMIN')">
        <c:choose>
            <c:when test="${exetype eq 'KEYMAP' || exetype eq 'UPDATE' || exetype eq 'DELETE' || piisteptable.stepid eq 'EXE_TRANSFORM'}">
                <button data-oper="wizard_steptable" class="btn btn-detail-wizard"><i
                        class="fa-solid fa-wand-sparkles"></i> Wizard</button>
            </c:when>

            <c:otherwise>
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${exetype eq 'ARCHIVE'}">
            </c:when>
            <c:otherwise>
                <button data-oper='steptableregister' class="btn btn-detail-register"><i class="fas fa-plus"></i> <spring:message
                        code="btn.register" text="Register"/></button>
            </c:otherwise>
        </c:choose>
    </sec:authorize>
</div>

<form style="margin: 0; padding: 0;" role="form" id="piisteptable_modify_form">
    <input type="hidden" class="form-control  form-control-sm small-text" name='jobid'
           value='<c:out value="${piisteptable.jobid}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='version'
           value='<c:out value="${piisteptable.version}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='stepid'
           value='<c:out value="${piisteptable.stepid}"/>'>
    <table class="job-info-table m-0" style="width: 100%">
        <colgroup>
            <col style="width: 15%"/>
            <col style="width: 20%"/>
            <col style="width: 15%"/>
            <col style="width: 20%"/>
            <col style="width: 15%"/>
            <col style="width: 20%"/>
        </colgroup>
        <tbody>

        <c:choose>
            <c:when test="${exetype eq 'EXTRACT'}">
                <tr>
                    <th class="th-get">Type</th>
                    <td class="td-get-l">
                        <select class="pt-0 pb-0 form-control  form-control-sm small-text" name="pagitypedetail"
                                style="height:27px;">
                            <option value="ADD"
                                    <c:if test="${piisteptable.pagitypedetail eq 'ADD'}">selected</c:if> >추가
                            </option>
                            <option value="EXCLUDE"
                                    <c:if test="${piisteptable.pagitypedetail eq 'EXCLUDE'}">selected</c:if> >제외
                            </option>
                            <option value="ETC"
                                    <c:if test="${piisteptable.pagitypedetail eq 'ETC'}">selected</c:if> >기타
                            </option>
                        </select>
                    </td>
                    <th class="th-get">Task Name</th>
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text" name='pk_col'
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'KEYMAP'}">
                <tr>
                    <th class="th-get"><spring:message code="col.keymap_id" text="Keymap_Id"/></th>
                    <td class="td-get-l"><input type="text" class="form-control form-control-sm small-text" name='keymap_id'
                                                value='<c:out value="${piisteptable.keymap_id}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_name" text="Key_Name"/></th>
                    <td class="td-get-l"><input type="text" class="form-control form-control-sm small-text" name='key_name'
                                                value='<c:out value="${piisteptable.key_name}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_cols" text="Key_Cols"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l"><input type="text" class="form-control form-control-sm small-text" name='key_cols'
                                                value='<c:out value="${piisteptable.key_cols}"/>'
                                                ></td>
                </tr>
            </c:when>
            <c:otherwise>
                <%--<input type="hidden" class="form-control  form-control-sm small-text" name='keymap_id'
                       value='<c:out value="${piisteptable.keymap_id}"/>'>
                <input type="hidden" class="form-control  form-control-sm small-text" name='key_name'
                       value='<c:out value="${piisteptable.key_name}"/>'>
                <input type="hidden" class="form-control  form-control-sm small-text" name='key_cols'
                       value='<c:out value="${piisteptable.key_cols}"/>'>--%>
            </c:otherwise>
        </c:choose>


        <c:if test="${ exetype ne 'EXTRACT'  }">
            <tr>
                <c:choose>
                    <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'BROADCAST'}">
                        <th class="th-get text-primary font-weight-bold">Target DB</th>
                    </c:when>
                    <c:when test="${exetype eq 'ILM' || exetype eq 'HOMECAST'}">
                        <th class="th-get text-primary font-weight-bold">Source DB</th>
                    </c:when>
                    <c:when test="${exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                        <th class="th-get text-primary font-weight-bold">Source DB</th>
                    </c:when>
                    <c:otherwise>
                        <th class="th-get">DB</th>
                    </c:otherwise>
                </c:choose>
                <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='db'
                                            value='<c:out value="${piisteptable.db}"/>'>
                    <div id='steptabledb'><c:out value="${piisteptable.db}"/></div>
                </td>

                <c:choose>
                    <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'>
                            <div id='steptableowner'><c:out value="${piisteptable.owner}"/></div>
                        </td>
                        <th class="th-get">
                            Table
                            <a class="collapse-item" href='javascript:diologSearchTableAction(0);'>
                                <i class="fas fa-search"></i>
                            </a>
                        </th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='table_name'
                                                    value='<c:out value="${piisteptable.table_name}"/>'>
                            <div id='steptable_name'><c:out value="${piisteptable.table_name}"/></div>
                        </td>

                    </c:when>
                    <c:when test="${exetype eq 'ARCHIVE'}">
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'><c:out
                                value="${piisteptable.owner}"/></td>
                        <th class="th-get">TABLE</th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='table_name'
                                                    value='<c:out value="${piisteptable.table_name}"/>'><c:out
                                value="${piisteptable.table_name}"/></td>

                    </c:when>
                    <c:otherwise>
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'>
                            <div id='steptableowner'><c:out value="${piisteptable.owner}"/></div>
                        </td>
                        <th class="th-get">
                            TABLE
                            <a class="collapse-item" href='javascript:diologSearchTableAction(0);'>
                                <i class="fas fa-search"></i>
                            </a>
                        </th>
                        <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='table_name'
                                                    value='<c:out value="${piisteptable.table_name}"/>'>
                            <div id='steptable_name'><c:out value="${piisteptable.table_name}"/></div>
                        </td>

                    </c:otherwise>
                </c:choose>
            </tr>
        </c:if>
        <c:choose>
            <c:when test="${exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                <tr>
                    <th class="th-get text-primary font-weight-bold">Target DB</th>
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='where_col'
                                                value='<c:out value="${piisteptable.where_col}"/>'>
                        <div id='steptableTargetdb'><c:out value="${piisteptable.where_col}"/></div>
                    </td>
                    <th class="th-get">OWNER</th>
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='where_key_name'
                                                value='<c:out value="${piisteptable.where_key_name}"/>'>
                        <div id='steptableTargetowner'><c:out value="${piisteptable.where_key_name}"/></div>
                    </td>
                    <th class="th-get">
                        TABLE
                        <a class="collapse-item" href='javascript:diologSearchTableAction(2);'>
                            <i class="fas fa-search"></i>
                        </a>
                    </th>
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='sqlstr'
                                                value='<c:out value="${piisteptable.sqlstr}"/>'>
                        <div id='steptableTargetname'><c:out value="${piisteptable.sqlstr}"/></div>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>

            </c:otherwise>
        </c:choose>
        <tr>
            <c:choose>
                <c:when test="${exetype eq 'ARCHIVE'}">
                    <th class="th-hidden">SEQ1</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'><c:out
                            value="${piisteptable.seq1}"/></td>
                    <th class="th-get">SEQ</th>
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'><c:out
                            value="${piisteptable.seq2}"/></td>
                    <th class="th-hidden">SEQ3</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                 value='<c:out value="${piisteptable.seq3}"/>'><c:out
                            value="${piisteptable.seq3}"/></td>
                </c:when>
                <c:when test="${exetype eq 'KEYMAP'}">

                    <th class="td-hidden">SEQ1</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'><c:out
                            value="${piisteptable.seq1}"/></td>
                    <th class="th-get">SEQ1</th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'><%--<c:out
                            value="${piisteptable.seq2}"/>--%></td>
                    <th class="th-get">SEQ2</th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                value='<c:out value="${piisteptable.seq3}"/>'><%--<c:out
                            value="${piisteptable.seq3}"/>--%></td>
                    <th class="th-get"><spring:message code="col.sqltype" text="Sql type"/></th>
                    <td class="td-get-l">
                        <select class="form-control  form-control-sm small-text" name="sqltype">
                            <option value="AUTO"
                                    <c:if test="${piisteptable.sqltype eq 'AUTO'}">selected</c:if> >AUTO
                            </option>
                            <option value="AUTOMANUAL"
                                    <c:if test="${piisteptable.sqltype eq 'AUTOMANUAL'}">selected</c:if> >AUTO+MANUAL
                            </option>
                            <option value="MANUAL"
                                    <c:if test="${piisteptable.sqltype eq 'MANUAL'}">selected</c:if> >MANUAL
                            </option>
                        </select>
                    </td>
                </c:when>
                <c:otherwise>
                    <th class="th-hidden">SEQ1</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'></td>
                    <th class="th-get">SEQ</th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'></td>
                    <th class="th-hidden">SEQ3</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                 value='<c:out value="${piisteptable.seq3}"/>'></td>

                    <c:choose>
                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                            <th class="th-get"><spring:message code="col.pk_col" text="Pk_Col"/></th>
                            <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                                  name='pk_col'
                                                                  value='<c:out value="${piisteptable.pk_col}"/>'></td>
                        </c:when>
                        <c:when test="${exetype eq 'EXTRACT'}">
                            <th class="th-get">DB</th>
                            <td class="td-get-l">
                                    <%--<input type="hidden" class="form-control  form-control-sm small-text" name='db' value='<c:out value="${piisteptable.db}"/>'>--%>
                                <input type="hidden" class="form-control  form-control-sm small-text" name='owner'
                                       value='<c:out value="${piisteptable.owner}"/>'>
                                <input type="hidden" class="form-control  form-control-sm small-text" name='table_name'
                                       value='<c:out value="${piisteptable.table_name}"/>'>
                                    <%--<div id='steptabledb'><c:out value="${piisteptable.db}"/></div>--%>
                                <select class="pt-0 pb-0 form-control  form-control-sm small-text" name="db"
                                        style="font-size:12px; height:27px;">
                                    <option value=""></option>
                                    <c:forEach items="${piidatabaselist}" var="piidatabase">
                                        <option value="<c:out value="${piidatabase.db}"/>"
                                                <c:if test="${piisteptable.db eq piidatabase.db}">selected</c:if> >
                                            <c:out value="${piidatabase.db}"/></option>
                                    </c:forEach>
                                </select>
                            </td>
                        </c:when>

                        <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" class="form-control  form-control-sm small-text" name='pk_col'
                                   value='<c:out value="${piisteptable.pk_col}"/>'>
                        </c:otherwise>
                    </c:choose>

                </c:otherwise>
            </c:choose>
        </tr>
        <tr>
            <c:choose>
                <c:when test="${exetype eq 'ARCHIVE'}">
                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" name='exetype'
                                                value='<c:out value="${piisteptable.exetype}"/>'><c:out
                            value="${piisteptable.exetype}"/></td>
                    <th class="th-get"><spring:message code="col.arc_del_m" text="Arc_Del_Deadline"/></th>
                    <td class="td-get-l">
                        <c:choose>
                            <c:when test="${piisteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                    code="etc.backdated" text="Backdated"/></c:when>
                            <c:otherwise> <c:out value="${piisteptable.pagitypedetail}"/> </c:otherwise>
                        </c:choose>
                        <input type="hidden" class="form-control  form-control-sm small-text" name='pagitypedetail'
                               value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                    </td>
                </c:when>
                <c:otherwise>
                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                    <td class="td-get-l"><c:out value="${piisteptable.exetype}"/><input type="hidden"
                                                                                        class="form-control  form-control-sm small-text"
                                                                                        name='exetype'
                                                                                        value='<c:out value="${piisteptable.exetype}"/>'>
                    </td>
                    <c:choose>
                        <c:when test="${exetype eq 'KEYMAP'}">
                            <th class="th-get"><spring:message code="etc.keyname_desc" text="Key Desc"/></th>
                            <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                                  name='pk_col'
                                                                  value='<c:out value="${piisteptable.pk_col}"/>'></td>
                        </c:when>
                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                            <th class="th-get"><spring:message code="col.arc_del_m" text="Arc_Del_Deadline"/></th>
                            <td class="td-get-l">
                                <c:choose>
                                    <c:when test="${piisteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                            code="etc.backdated" text="Backdated"/>
                                        <input type="hidden" class="form-control  form-control-sm small-text" name='pagitypedetail'
                                               value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="d-flex align-items-center">
                                            <input type="text" class="form-control  form-control-sm small-text" style="width:40px;" name='pagitypedetail'
                                                   value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                                            &nbsp;<span> Months </span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                            </td>
                        </c:when>
                        <c:when test="${ exetype eq 'HOMECAST'}">
                            <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                            <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='8'
                                                        onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                        name='commitcnt'
                                                        value='<c:out value="${piisteptable.commitcnt}"/>'></td>
                        </c:when>
                        <c:when test="${exetype eq 'SCRAMBLE' or exetype eq 'MIGRATE'}">
                            <th class="th-get">/*+ Hint */</th>
                            <td class="td-get-l" COLSPAN="3">
                                <input type="text" class="form-control  form-control-sm small-text"
                                       name='hintselect'
                                       value='<c:out value="${piisteptable.hintselect}"/>'>
                            </td>
                            <%--<th class="th-get"><spring:message code="col.sqltype" text="Sql type"/></th>
                            <td class="td-get-l">
                                <select class="form-control  form-control-sm small-text" name="sqltype" id="sqlTypeSelect">
                                    <c:if test="${piisteptable.stepid ne 'EXE_TRANSFORM'}">
                                        <option value="MANUAL"
                                                <c:if test="${piisteptable.sqltype eq 'MANUAL'}">selected</c:if> >Where문 직접 입력
                                        </option>
                                    </c:if>
                                    <option value="AUTO"
                                            <c:if test="${piisteptable.sqltype eq 'AUTO'}">selected</c:if> >Keymap Wizard
                                    </option>
                                </select>
                            </td>

                            <td class="td-get-l" COLSPAN="2">
                                <c:if test="${piisteptable.stepid eq 'EXE_TRANSFORM'}">
                                    <button id="wizardButton" data-oper="wizard_steptable" class="btn btn-info btn-sm p-0 pb-2 button"
                                            style="display: block;">
                                        <i class="fa-solid fa-wand-sparkles"></i> Wizard
                                    </button>
                                </c:if>
                                <c:if test="${piisteptable.stepid ne 'EXE_TRANSFORM'}">
                                    <button id="wizardButton" data-oper="wizard_steptable" class="btn btn-info btn-sm p-0 pb-2 button"
                                            style="<c:if test="${piisteptable.sqltype eq 'AUTO'}">display: block;</c:if><c:if test="${piisteptable.sqltype ne 'AUTO'}">display: none;</c:if>">
                                        <i class="fa-solid fa-wand-sparkles"></i> Wizard
                                    </button>
                                </c:if>
                            </td>--%>
                        </c:when>
                        <c:otherwise>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${exetype eq 'UPDATE'}">
                            <th class="th-get" colspan=2>
                                <spring:message code="etc.updatecols" text="Update cols"/>
                                <%--<a class="collapse-item" href='javascript:diologStepTableUpdateAction();'>
                                    <i class="fas fa-edit"></i>
                                </a>--%>
                            </th>
                            <input type="hidden" class="form-control  form-control-sm small-text" name='pagitype'
                                   value='<c:out value="${piisteptable.pagitype}"/>'>
                        </c:when>
                        <c:otherwise>
                            <%-- <th class="th-hidden"><spring:message code="col.pagitype" text="Pagitype"/></th>
                             <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text"
                                                          name='pagitype'
                                                          value='<c:out value="${piisteptable.pagitype}"/>'></td>--%>
                        </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </tr>

        <c:choose>
            <c:when test="${exetype eq 'KEYMAP' || exetype eq 'ARCHIVE' ||  exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' || exetype eq 'BROADCAST' || exetype eq 'HOMECAST' }">

            </c:when>
            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE'  || exetype eq 'SCRAMBLE' || exetype eq 'SYNC' }">
                <tr>
                    <th class="th-hidden"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                    <td class="td-hidden"><input type="text" class="form-control  form-control-sm small-text" maxlength='3'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                 name='parallelcnt'
                                                 value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <c:choose>
                        <c:when test="${exetype eq 'SCRAMBLE' and fn:startsWith(piisteptable.jobid, 'TESTDATA_AUTO_GEN')}">
                            <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/></th>
                            <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text" id="where_col_scr"
                                                                  name='where_col'
                                                                  value='<c:out value="${piisteptable.where_col}"/>'
                                                                  style="background-color: WHITE;" ></td>

                            <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/></th>
                            <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text" id="where_key_name_scr"
                                                                  name='where_key_name'
                                                                  value='<c:out value="${piisteptable.where_key_name}"/>'
                                                                  style="background-color: WHITE;" ></td>
                        </c:when>
                    </c:choose>
                    <th class="th-get"><spring:message code="col.handlecnt"
                                                       text="Data Processing Unit"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'UPDATE' || (exetype eq 'RECOVERY' && piisteptable.pagitypedetail eq 'RECOVERY_U')}">
                <tr>
                    <th class="th-get"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='3'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                name='parallelcnt' value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>

                    <td class="td-get-l" rowspan=3 COLSPAN="2">
                        <div class="m-0 p-0">
                            <table style="border: none; width: 100%; height:100px ">
                                <tr style="border: none;">
                                    <td class="td-get-l"
                                        style=" border: none;display: flex;  justify-content: top;  flex-direction: column;">
                                        <table style="border: none;">
                                            <tbody id="steptableupdatemodify"
                                                   style="display:block;height:90px;overflow:auto;">
                                            <c:forEach items="${liststeptableupdate}" var="piisteptableupdate">
                                                <tr style="border: none;">
                                                    <td style="border: none;"><c:out
                                                            value="${piisteptableupdate.column_name}"/> =
                                                    </td>
                                                    <td style="border: none;"><c:out
                                                            value="${piisteptableupdate.update_val}"/></td>
                                                </tr>
                                            </c:forEach>

                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='3'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                name='parallelcnt' value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>

                    <th class="th-get" rowspan=3>
                        <spring:message code="etc.table_wait" text="Waiting table"/>
                        <a class="collapse-item" href='javascript:diologStepTableWaitAction();'>
                            <i class="fas fa-edit"></i>
                        </a>
                    </th>
                    <td class="td-get-l" rowspan=3>
                        <div class="m-0 p-0">
                            <table style="border: none; width: 100%; height:100px ">
                                <tr style="border: none;">
                                    <td class="td-get-l"
                                        style=" border: none;display: flex;  justify-content: top;  flex-direction: column;">
                                        <table style="border: none;">
                                            <tbody id="steptablewaitmodify"
                                                   style="display:block;height:90px;overflow:auto;">
                                            <c:forEach items="${liststeptablewait}" var="piisteptablewait">
                                                <tr style="border: none;">
                                                    <td style="border: none;"><c:out
                                                            value="${piisteptablewait.table_name_w}"/></td>
                                                </tr>
                                            </c:forEach>

                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </c:otherwise>
        </c:choose>

        <c:choose>
            <c:when test="${ exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'BROADCAST' || exetype eq 'HOMECAST' || exetype eq 'EXTRACT' }">
                <input type="hidden" class="form-control  form-control-sm small-text" name='where_col'
                       value='<c:out value="${piisteptable.where_col}"/>'>
                <input type="hidden" class="form-control  form-control-sm small-text" name='where_key_name'
                       value='<c:out value="${piisteptable.where_key_name}"/>'>
            </c:when>
            <c:when test="${exetype eq 'SCRAMBLE'  }">
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                   text="Processing_Method"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get"
                        COLSPAN="1"><%--<input type="text" class="form-control  form-control-sm small-text" name='processing_method' value='<c:out value="${piisteptable.processing_method}" />'>--%>
                        <select class="form-control  form-control-sm small-text" name="succedding">
                            <option value=""
                                    <c:if test="${piisteptable.succedding eq ''}">selected</c:if> >
                            </option>
                            <option value="TMP_TABLE"
                                    <c:if test="${piisteptable.succedding eq 'TMP_TABLE'}">selected</c:if> >
                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing"/>
                            </option>
                        </select>
                    </td>
                    <th class="th-get"><spring:message code="etc.hashcol" text="Distribution Key"/><%--<font
                            style="color:blue">*</font>--%></th>
                    <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text"
                                                          name='pk_col' style="font-size:12px;"
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control  form-control-sm small-text" name="pipeline">
                            <option value=""
                                    <c:if test="${piisteptable.pipeline eq ''}">selected</c:if> >
                            </option>
                            <option value="1" <c:if test="${piisteptable.pipeline eq '1'}">selected</c:if>>1</option>
                            <option value="2" <c:if test="${piisteptable.pipeline eq '2'}">selected</c:if>>2</option>
                            <option value="3" <c:if test="${piisteptable.pipeline eq '3'}">selected</c:if>>3</option>
                            <option value="4" <c:if test="${piisteptable.pipeline eq '4'}">selected</c:if>>4</option>
                            <option value="5" <c:if test="${piisteptable.pipeline eq '5'}">selected</c:if>>5</option>
                            <option value="6" <c:if test="${piisteptable.pipeline eq '6'}">selected</c:if>>6</option>
                            <option value="7" <c:if test="${piisteptable.pipeline eq '7'}">selected</c:if>>7</option>
                            <option value="8" <c:if test="${piisteptable.pipeline eq '8'}">selected</c:if>>8</option>
                            <option value="9" <c:if test="${piisteptable.pipeline eq '9'}">selected</c:if>>9</option>
                            <option value="10" <c:if test="${piisteptable.pipeline eq '10'}">selected</c:if>>10</option>
                            <option value="11" <c:if test="${piisteptable.pipeline eq '11'}">selected</c:if>>11</option>
                            <option value="12" <c:if test="${piisteptable.pipeline eq '12'}">selected</c:if>>12</option>
                            <option value="13" <c:if test="${piisteptable.pipeline eq '13'}">selected</c:if>>13</option>
                            <option value="14" <c:if test="${piisteptable.pipeline eq '14'}">selected</c:if>>14</option>
                            <option value="15" <c:if test="${piisteptable.pipeline eq '15'}">selected</c:if>>15</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.data_handling_method"
                                                                   text="Data_Handling_Method"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get" COLSPAN="1">
                        <select class="form-control  form-control-sm small-text" name="preceding">
                            <option value=""
                                    <c:if test="${piisteptable.preceding eq ''}">selected</c:if> >
                            </option>
                            <option value="INSERT"
                                    <c:if test="${piisteptable.preceding eq 'INSERT'}">selected</c:if> >
                                <spring:message code="etc.data_handling_method3" text="INSERT"/>
                            </option>
                            <option value="REPLACEINSERT"
                                    <c:if test="${piisteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> >
                                <spring:message code="etc.data_handling_method2" text="Upsert"/>
                            </option>
                            <option value="DELDUPINSERT"
                                    <c:if test="${piisteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> >
                                <spring:message code="etc.data_handling_method5" text="DelDup&Insert"/>
                            </option>
                            <option value="TRUNCSERT"
                                    <c:if test="${piisteptable.preceding eq 'TRUNCSERT'}">selected</c:if> >
                                <spring:message code="etc.data_handling_method1" text="Truncate&Insert"/>
                            </option>
                        </select>
                    </td>
                    <th class="th-get">Trunc partition</th>
                    <td class="td-get">
                        <input type="text" class="form-control  form-control-sm small-text"
                               name='uval1' style="font-size:12px;"
                               value='<c:out value="${piisteptable.uval1}"/>'>
                    </td>

                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control  form-control-sm small-text" name="pagitypedetail" id="pagitypedetail" onchange="handlePagitypedetailChange(this.value)">
                            <option value=""
                                    <c:if test="${piisteptable.pagitypedetail eq ''}">selected</c:if> >
                            </option>
                            <option value="Y"
                                    <c:if test="${piisteptable.pagitypedetail eq 'Y'}">selected</c:if> >Y
                            </option>
                            <option value="N"
                                    <c:if test="${piisteptable.pagitypedetail eq 'N'}">selected</c:if> >N
                            </option>
                            <%--<option value="YN"
                                    <c:if test="${piisteptable.pagitypedetail eq 'YN'}">selected</c:if> >YN
                            </option>--%>
                        </select>
                    </td>
                    <th class="th-hidden"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag"/><font
                            style="color:blue">*</font></th>
                    <td class="td-hidden">
                        <select class="form-control  form-control-sm small-text" name="pagitype">
                            <option value=""
                                    <c:if test="${piisteptable.pagitype eq ''}">selected</c:if> >
                            </option>
                            <option value="Y"
                                    <c:if test="${piisteptable.pagitype eq 'Y'}">selected</c:if> >Y
                            </option>
                            <option value="N"
                                    <c:if test="${piisteptable.pagitype eq 'N'}">selected</c:if> >N
                            </option>
                        </select>
                    </td>

                </tr>
            </c:when>
            <c:when test="${exetype eq 'SYNC' }">
            </c:when>
            <c:when test="${exetype eq 'ILM'  || exetype eq 'MIGRATE' }">
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                   text="Processing_Method"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get"
                        COLSPAN="1"><%--<input type="text" class="form-control  form-control-sm small-text" name='processing_method' value='<c:out value="${piisteptable.processing_method}" />'>--%>
                        <select class="form-control  form-control-sm small-text" name="succedding">
                            <option value=""
                                    <c:if test="${piisteptable.succedding eq ''}">selected</c:if> >
                            </option>
                            <option value="TMP_TABLE"
                                    <c:if test="${piisteptable.succedding eq 'TMP_TABLE'}">selected</c:if> >
                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing"/>
                            </option>
                        </select>
                    </td>
                    <th class="th-get"><spring:message code="etc.hashcol" text="Distribution Key"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text"
                                                          name='pk_col' style="font-size:12px;"
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control  form-control-sm small-text" name="pipeline">
                            <option value=""
                                    <c:if test="${piisteptable.pipeline eq ''}">selected</c:if> >
                            </option>
                            <option value="1" <c:if test="${piisteptable.pipeline eq '1'}">selected</c:if>>1</option>
                            <option value="2" <c:if test="${piisteptable.pipeline eq '2'}">selected</c:if>>2</option>
                            <option value="3" <c:if test="${piisteptable.pipeline eq '3'}">selected</c:if>>3</option>
                            <option value="4" <c:if test="${piisteptable.pipeline eq '4'}">selected</c:if>>4</option>
                            <option value="5" <c:if test="${piisteptable.pipeline eq '5'}">selected</c:if>>5</option>
                            <option value="6" <c:if test="${piisteptable.pipeline eq '6'}">selected</c:if>>6</option>
                            <option value="7" <c:if test="${piisteptable.pipeline eq '7'}">selected</c:if>>7</option>
                            <option value="8" <c:if test="${piisteptable.pipeline eq '8'}">selected</c:if>>8</option>
                            <option value="9" <c:if test="${piisteptable.pipeline eq '9'}">selected</c:if>>9</option>
                            <option value="10" <c:if test="${piisteptable.pipeline eq '10'}">selected</c:if>>10</option>
                            <option value="11" <c:if test="${piisteptable.pipeline eq '11'}">selected</c:if>>11</option>
                            <option value="12" <c:if test="${piisteptable.pipeline eq '12'}">selected</c:if>>12</option>
                            <option value="13" <c:if test="${piisteptable.pipeline eq '13'}">selected</c:if>>13</option>
                            <option value="14" <c:if test="${piisteptable.pipeline eq '14'}">selected</c:if>>14</option>
                            <option value="15" <c:if test="${piisteptable.pipeline eq '15'}">selected</c:if>>15</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <c:choose>
                        <c:when test="${exetype eq 'ILM'}">
                            <th scope="row" class="th-hidden"><spring:message code="col.data_handling_method"
                                                                              text="Data_Handling_Method"/><font
                                    style="color:blue">*</font></th>
                            <td class="td-hidden" COLSPAN="1">
                                <select class="form-control  form-control-sm small-text" name="preceding">
                                    <option value=""
                                            <c:if test="${piisteptable.preceding eq ''}">selected</c:if> >
                                    </option>
                                    <option value="INSERT"
                                            <c:if test="${piisteptable.preceding eq 'INSERT'}">selected</c:if> >
                                        <spring:message code="etc.data_handling_method3" text="INSERT"/>
                                    </option>
                                    <option value="REPLACEINSERT"
                                            <c:if test="${piisteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> >
                                        <spring:message code="etc.data_handling_method2" text="Upsert"/>
                                    </option>
                                    <option value="DELDUPINSERT"
                                            <c:if test="${piisteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> >
                                        <spring:message code="etc.data_handling_method5" text="DelDup&Insert"/>
                                    </option>
                                    <option value="TRUNCSERT"
                                            <c:if test="${piisteptable.preceding eq 'TRUNCSERT'}">selected</c:if> >
                                        <spring:message code="etc.data_handling_method1" text="Truncate&Insert"/>
                                    </option>
                                </select>
                            </td>
                        </c:when>
                        <c:when test="${exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                            <th scope="row" class="th-get"><spring:message code="col.data_handling_method"
                                                                           text="Data_Handling_Method"/><font
                                    style="color:blue">*</font></th>
                            <td class="td-get" COLSPAN="1">
                                <select class="form-control  form-control-sm small-text" name="preceding">
                                    <option value=""
                                            <c:if test="${piisteptable.preceding eq ''}">selected</c:if> >
                                    </option>
                                    <option value="INSERT"
                                            <c:if test="${piisteptable.preceding eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method4" text="Insert" />
                                    </option>
                                    <option value="REPLACEINSERT"
                                            <c:if test="${piisteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Usert" />
                                    </option>
                                    <option value="DELDUPINSERT"
                                            <c:if test="${piisteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                    </option>
                                    <option value="TRUNCSERT"
                                            <c:if test="${piisteptable.preceding eq 'TRUNCSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                    </option>
                                </select>
                            </td>
                            <th class="th-get">Trunc partition</th>
                            <td class="td-get">
                                <input type="text" class="form-control  form-control-sm small-text"
                                       name='uval1' style="font-size:12px;"
                                       value='<c:out value="${piisteptable.uval1}"/>'>
                            </td>
                        </c:when>
                    </c:choose>

                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control  form-control-sm small-text" name="pagitypedetail">
                            <option value=""
                                    <c:if test="${piisteptable.pagitypedetail eq ''}">selected</c:if> >
                            </option>
                            <option value="Y"
                                    <c:if test="${piisteptable.pagitypedetail eq 'Y'}">selected</c:if> >Y
                            </option>
                            <option value="N"
                                    <c:if test="${piisteptable.pagitypedetail eq 'N'}">selected</c:if> >N
                            </option>
                            <%--<option value="YN"
                                    <c:if test="${piisteptable.pagitypedetail eq 'YN'}">selected</c:if> >YN
                            </option>--%>
                        </select>
                    </td>
                    <th class="th-get-hidden"><spring:message code="etc.target_tab_distribute" text="Target distributed"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get-hidden">
                        <select class="form-control  form-control-sm small-text" name="pagitype">
                            <option value=""
                                    <c:if test="${piisteptable.pagitype eq ''}">selected</c:if> >
                            </option>
                            <option value="Y"
                                    <c:if test="${piisteptable.pagitype eq 'Y'}">selected</c:if> >Y
                            </option>
                            <option value="N"
                                    <c:if test="${piisteptable.pagitype eq 'N'}">selected</c:if> >N
                            </option>
                        </select>
                    </td>

                </tr>
            </c:when>
            <c:when test="${exetype eq 'KEYMAP' }">
                <tr>
                    <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/><font
                            style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                          name='where_col'
                                                          value='<c:out value="${piisteptable.where_col}"/>'
                                                          style="background-color: WHITE;" ></td>
                </tr>
                <tr>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                            style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text"
                                                          name='where_key_name'
                                                          value='<c:out value="${piisteptable.where_key_name}"/>'
                                                          style="background-color: WHITE;" ></td>
                    <th class="th-get">/*+ Hint */</th>
                    <td class="td-get-l" COLSPAN="3">
                        <input type="text" class="form-control  form-control-sm small-text"
                               name='hintselect'
                               value='<c:out value="${piisteptable.hintselect}"/>'>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/><font
                            style="color:RED"><c:if
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
                    </th>
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                          name='where_col'
                                                          value='<c:out value="${piisteptable.where_col}"/>'
                                                          style="background-color: WHITE;" ></td>
                </tr>
                <tr>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                            style="color:RED"><c:if
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
                    </th>
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                          name='where_key_name'
                                                          value='<c:out value="${piisteptable.where_key_name}"/>'
                                                          style="background-color: WHITE;" ></td>
                </tr>
            </c:otherwise>

        </c:choose>

        <c:choose>
            <c:when test="${exetype eq 'KEYMAP' }">
                <tr>
                    <th class="th-get"><spring:message code="etc.selectstr" text="Selectstr"/><font
                            style="color:RED">*</font><%--<br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)--%>
                    </th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="6"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'ARCHIVE' }">
                <tr>
                    <th class="th-get"><spring:message code="etc.selectstr" text="Selectstr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="6"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'BROADCAST' }">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="8"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="12"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'SYNC'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="13"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;">
                        OPERATION_DATE <= TO_DATE('#BASEDATE','yyyy/mm/dd')
                        ORDER BY OPERATION_TIME
                                                    </textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'HOMECAST'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="7"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${ exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' }">
            </c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="6"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:otherwise>
        </c:choose>

        <c:if test="${exetype ne 'MIGRATE' && exetype ne 'ILM' && exetype ne 'SCRAMBLE' && exetype ne 'SYNC'}">
            <tr>
                <c:choose>
                    <c:when test="${exetype eq 'ARCHIVE'}">
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                                code="etc.illustrative" text="Illustrative"/>)
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="8" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:when>
                    <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                                code="etc.illustrative" text="Illustrative"/>)
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="7" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:when>
                    <c:when test="${exetype eq 'KEYMAP' }">
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                style="color:RED">*</font>
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="6" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:when>
                    <c:when test="${exetype eq 'BROADCAST' || exetype eq 'HOMECAST'}">
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                                code="etc.illustrative" text="Illustrative"/>)
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="8" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:when>
                    <c:when test="${exetype eq 'EXTRACT' ||  exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC'}">
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                style="color:RED">*</font>
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="19" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;"><c:out value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:when>

                    <c:otherwise>
                        <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                style="color:RED">*</font>
                        </th>
                        <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="6" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;"><c:out value="${piisteptable.sqlstr}"/></textarea>
                        </td>
                    </c:otherwise>
                </c:choose>
            </tr>
        </c:if>
        <c:choose>
            <c:when test="${exetype eq 'SCRAMBLE' }">
                <tr>
                    <th class="th-get"><spring:message code="etc.scramble_columns" text="Scramble columns"/>
                        <br>
                        <a class="collapse-item" href='javascript:diologMetaTableAction();'>
                            <i class="fas fa-edit"></i>
                        </a>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <div class="tableWrapper_inner" style="height:167px;width:99.8%">
                            <table id="listTable_dialog" class="table table-sm">
                                <thead>
                                <tr>
                                    <th scope="row" style="font-size: 13px;"><spring:message code="col.column_name"
                                                                                             text="Column_Name"/></th>
                                        <%--<th scope="row" style="font-size: 13px;"><spring:message code="col.pk_yn" text="Pk_Yn" /></th>--%>
                                        <%--<th scope="row" style="font-size: 13px;"><spring:message code="col.data_type" text="Data_Type" /></th>
                                        <th scope="row" style="font-size: 13px;"><spring:message code="col.data_length" text="Data_Length" /></th>--%>
                                    <th scope="row" style="font-size: 13px;"><spring:message code="col.encript_flag"
                                                                                             text="Encript_Flag"/></th>
                                        <%--<th scope="row" style="font-size: 13px;"><spring:message code="col.piigrade" text="Piigrade" /></th>--%>
                                    <th scope="row" style="font-size: 13px;"><spring:message code="col.piitype"
                                                                                             text="Piitype"/></th>
                                    <th scope="row" style="font-size: 13px;"><spring:message code="col.scramble_type"
                                                                                             text="Scramble_Type"/></th>
                                    <th scope="row" style="font-size: 13px;"><spring:message code="col.upddate"
                                                                                             text="Upddate"/></th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${listscramblecolumn}" var="metatable">
                                    <c:if test="${not empty metatable.scramble_type}">
                                        <tr>
                                            <td><c:out value="${metatable.column_name}"/></td>
                                                <%--<td ><c:out value="${metatable.pk_yn}" /></td>--%>
                                                <%--<td nowrap><c:out value="${metatable.data_type}" /></td>
                                                <td class='td-get-r'><c:out value="${metatable.data_length}" /></td>--%>
                                            <td><c:out value="${metatable.encript_flag}"/></td>
                                                <%--<td ><c:out value="${metatable.piigrade}" /></td>--%>
                                            <td>Grade <c:out value="${metatable.piigrade}"/>:
                                                <c:forEach var="item" items="${listlkPiiScrType}">
                                                    <c:if test="${metatable.piitype eq item.piicode}">
                                                        <c:out value="${item.piitypename}" />
                                                    </c:if>
                                                </c:forEach>
                                            </td>
                                            <td><c:out value="${metatable.scramble_type}"/></td>
                                            <td><c:out value="${metatable.upddate}"/></td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                            <%--<table style="border: none;width:100%;">
                                &lt;%&ndash;<colgroup>
                                    <col style="width: 20%"/>
                                    <col style="width: 5%"/>
                                    <col style="width: 15%"/>
                                    <col style="width: 20%"/>
                                    <col style="width: 5%"/>
                                    <col style="width: 20%"/>
                                </colgroup>&ndash;%&gt;
                                <tbody id="steptablescramblecolumnmodify"
                                       style="display:block;height:90px;overflow:auto;">
                                <c:forEach items="${listscramblecolumn}" var="scramblecolumn">
                                    <c:if test="${not empty scramblecolumn.scramble_type}">
                                        <tr>
                                            <td><c:out value="${scramblecolumn.column_name}" /></td>
                                            <td><c:out value="${scramblecolumn.pk_yn}" /></td>
                                            <td><c:out value="${scramblecolumn.data_type}" /></td>
                                            <td><c:out value="${scramblecolumn.piitype}" /></td>
                                            <td><c:out value="${scramblecolumn.encript_flag}" /></td>
                                            <td><c:out value="${scramblecolumn.scramble_type}" /></td>
                                        </tr>
                                    </c:if>
                                </c:forEach>


                                </tbody>
                            </table>--%>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>

            </c:otherwise>
        </c:choose>
        </tbody>
    </table>

    <%-- <th class="th-get">ARCHIVEFLAG</th>
    <td class="td-get-l">
        <select class="form-control  form-control-sm small-text" name="archiveflag">
                <option value="N" <c:if test="${piisteptable.archiveflag eq 'N'}" >selected</c:if> >N</option>
                <option value="Y" <c:if test="${piisteptable.archiveflag eq 'Y'}" >selected</c:if> >Y</option>
        </select>
    </td> --%>
    <input type="hidden" class="form-control  form-control-sm small-text" name='key_refstr'
           value='<c:out value="${piisteptable.key_refstr}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='archiveflag'
           value='<c:out value="${piisteptable.archiveflag}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='status'
           value='<c:out value="${piisteptable.status}"/>'>
    <%--<input type="hidden" class="form-control  form-control-sm small-text" name='succedding'
           value='<c:out value="${piisteptable.succedding}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='preceding'
           value='<c:out value="${piisteptable.preceding}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='pipeline'
           value='<c:out value="${piisteptable.pipeline}"/>'>--%>

    <%--    <input type="hidden" class="form-control  form-control-sm small-text" name='regdate'
               value='<c:out value="${piisteptable.regdate}"/>'>
        <input type="hidden" class="form-control  form-control-sm small-text" name='upddate'
               value='<c:out value="${piisteptable.upddate}"/>'>--%>
    <input type="hidden" class="form-control  form-control-sm small-text" name='reguserid'
           value='<c:out value="${piisteptable.reguserid}"/>'>
    <input type="hidden" class="form-control  form-control-sm small-text" name='upduserid'
           value='<sec:authentication property="principal.member.userid"/>'>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>
<!-- </div>-->
<!-- end panel-body -->
<!-- </div>-->
<!-- panel panel-default-->
<!-- </div>-->

<!-- col-lg-12 -->
<!-- The Modal -->
<div class="modal fade" id="modalxl" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">
                    <i class="fa-solid fa-wand-sparkles mr-3 fa-xl" style="animation: sparkle 1.5s infinite alternate;"></i>
                    Wizard - Table Configuration
                </h4>
                <button type="button" class="close text-white ml-auto" data-dismiss="modal" aria-label="Close" style="font-size: 1.5rem;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="modalxlbdoy">
                Modal body..
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- The Modal -->
<div class="modal fade" id="dialogsteptablewaitlist" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.table_wait_mgmt"
                                                        text="Waiting table management"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="dialogsteptablewaitlistbody">
                <h6>Please select Table wait!</h6>
                <textarea spellcheck="false" rows="3" class="form-control  form-control-sm small-text" name='reqreason'
                          id='reqreason'></textarea>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="dialogsteptablewaitlistclose"
                        data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- The Modal -->
<div class="modal fade" id="dialogsteptableupdatelist" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h1 class="h5 mb-0 vertical-align:middle;" style="font-weight: bold;"><spring:message
                        code="etc.updatecols_mgmt" text="Update columns management"/></h1>
                <!-- <h1 class="h5 mb-0 vertical-align:middle;" style="font-weight: bold;" id=menupath></h1> -->
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="dialogsteptableupdatelistbody">
                <h6>Update column config</h6>
                <textarea spellcheck="false" rows="3" class="form-control  form-control-sm small-text" name='reqreason'
                          id='reqreason'></textarea>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button"
                        id="dialogsteptableupdatelistclose" data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- The Modal -->
<div class="modal fade" id="dialogsearchtablelist" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><spring:message code="etc.sel_table_mgmt" text="Table search"/></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="dialogsearchtablelistbody">
                <h6>Please select Table!</h6>
                <textarea spellcheck="false" rows="3" class="form-control  form-control-sm small-text" name='reqreason'
                          id='reqreason'></textarea>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="dialogsearchtablelistclose"
                        data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal -->
<div class="modal fade" id="dialogmetadatalist" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h1 class="h5 mb-0 vertical-align:middle;" style="font-weight: bold;"><spring:message
                        code="etc.metadatamodify" text="Meta data modify"/></h1>
                <!-- <h1 class="h5 mb-0 vertical-align:middle;" style="font-weight: bold;" id=menupath></h1> -->
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="dialogmetadatalistbody">
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button"
                        id="dialogmetadatalistclose" data-dismiss="modal">Close
                </button>
            </div>
        </div>
    </div>
</div>
<!-- The Modal end-->
<!--
</div> -->

<input type='hidden' id='searchtablemode'>
<form style="margin: 0; padding: 0;" role="form" id=searchForm>
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
    <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
    <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
    <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
    <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
</form>
<form style="margin: 0; padding: 0;" role="form" id=stepinfoForm>
    <input type='hidden' name='db' value='<c:out value="${piisteptable.db}"/>'>

</form>

<script type="text/javascript">
    function handlePagitypedetailChange(val) {
        if (val === "Y") {
            showConfirm(
                "⚠️ 'Y'를 선택하면 해당 테이블의 인덱스,FK가 자동으로 DROP 후 CREATE 됩니다.\n" +
                "이 작업은 다른 사용자의 업무와 처리 성능에 영향을 줄 수 있으므로, 빈번히 사용되는 테이블의 경우 반드시 사전 공지가 필요합니다.\n\n" +
                "계속 진행하시겠습니까?",
                null,
                function() {
                    document.getElementById("pagitypedetail").value = "";
                }
            );
        }
    }
    function modifyColumnString(input) {
        // SELECT 문에서 FROM 앞부분만 추출
        const selectPart = input.split('FROM')[0].replace('SELECT', '').trim();
        const columns = selectPart.split(',').map(col => col.trim());

        // CUSTID와 EXPECTED_ARC_DEL_DATE 칼럼의 인덱스 찾기
        const custidIndex = columns.findIndex(col => col.endsWith('.CUSTID'));
        const expectedDateIndex = columns.findIndex(col => col.includes('EXPECTED_ARC_DEL_DATE'));

        if (custidIndex === -1 || expectedDateIndex === -1 || custidIndex >= expectedDateIndex) {
            return ''; // 원하는 칼럼이 없거나 순서가 잘못된 경우 빈 문자열 반환
        }

        const middleColumnCount = expectedDateIndex - custidIndex - 1;

        let result = [];
        for (let i = 0; i < Math.min(middleColumnCount, 4); i++) {
            result.push('VAL' + (i + 1));
        }

        // 결과가 비어있지 않을 때만 join 수행
        return result.length > 0 ? result.join(', ') : '';
    }

    // 원본 textarea의 값이 변경될 때마다 호출되는 함수
    $('textarea[name="wherestr"]').on('input', function() {
        if ($('#piisteptable_modify_form [name="exetype"]').val() != "KEYMAP"){
            return false;
        }
        var selectstr = $(this).val();
        var valcols = modifyColumnString(selectstr)
        var seq3 = $('#piisteptable_modify_form [name=seq3]').val();
        if(seq3 == "1" || seq3 == "999")
            $('#piisteptable_modify_form [name="sqlstr"]').val("INSERT INTO COTDL.TBL_PIIKEYMAP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, " + valcols + ", EXPECTED_ARC_DEL_DATE) " + "\n" + selectstr);
        else
            $('#piisteptable_modify_form [name="sqlstr"]').val("INSERT INTO COTDL.TBL_PIIKEYMAP_TMP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, " + valcols + ", EXPECTED_ARC_DEL_DATE) " + "\n" + selectstr);
    });
    $(document).ready(function () {
        var doubleSubmitFlag = true;
        $(document).on('hidden.bs.modal', '#dialogmetadatalist', function (e) {
            e.preventDefault();e.stopPropagation();
            if (doubleSubmitFlag) {
                doubleSubmitFlag = false;
                if (selectedstepallRow) {
                    setTimeout(function () {
                        selectedstepallRow.trigger('click');
                    }, 0);

                }
            }
        });

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $(function () {
            //$("#menupath").html(Menupath +">Details>Modify");
        });

        // 신규 등록 시 테이블이 비어있으면 자동으로 테이블 검색 모달 오픈
        var _autoTableName = $('#piisteptable_modify_form [name="table_name"]').val();
        var _autoExetype = $('#piisteptable_modify_form [name="exetype"]').val();
        var _autoStepid = $('#piisteptable_modify_form [name="stepid"]').val();
        if (isEmpty(_autoTableName) && _autoExetype !== 'EXTRACT' && _autoExetype !== 'ARCHIVE') {
            setTimeout(function () {
                diologSearchTableAction(0);
            }, 300);
        }

        // 테이블 선택 후 wizard가 필요한 steptype이면 자동으로 wizard 오픈
        $(document).on('hidden.bs.modal', '#dialogsearchtablelist', function () {
            if (window._tableSelectedFromSearch) {
                window._tableSelectedFromSearch = false;
                var exetype = $('#piisteptable_modify_form [name="exetype"]').val();
                var stepid = $('#piisteptable_modify_form [name="stepid"]').val();
                if (exetype === 'KEYMAP' || exetype === 'UPDATE' || exetype === 'DELETE' || stepid === 'EXE_TRANSFORM') {
                    setTimeout(function () {
                        $("button[data-oper='wizard_steptable']").first().trigger("click");
                    }, 300);
                }
            }
        });

        $("select[name='preceding']").on('change', function () {
            // 선택한 데이터 처리 방법을 확인
            var dataHandlingMethod = $(this).val();
            // REPLACEINSERT가 선택되면 TMP_TABLE 항목을 숨김
            if (dataHandlingMethod === 'REPLACEINSERT') {
                $("select[name='succedding'] option[value='TMP_TABLE']").hide();
            } else {
                // 다른 경우에는 TMP_TABLE 항목을 다시 보이게 함
                $("select[name='succedding'] option[value='TMP_TABLE']").show();
            }
        });

        $("button[data-oper='steptableremove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piisteptable_modify_form");
            var elementResult = $("#jobstepdetail");
            var stepid = $('#piisteptable_modify_form [name="stepid"]').val();

            var formSerializeArray = $('#piisteptable_modify_form').serializeArray();
            var object = {};
            for (var i = 0; i < formSerializeArray.length; i++) {
                object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piisteptable/remove",
                dataType: "text",
                data: JSON.stringify(object),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) {
                    ingHide();
                    $("#" + stepid).trigger("click");
                    showToast("처리가 완료되었습니다.", false);
                    //loadAction();

                }
            });

        });


        $("button[data-oper='list']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();
            var search1 = $('#searchForm [name="search1"]').val();
            var search2 = $('#searchForm [name="search2"]').val();
            var search3 = $('#searchForm [name="search3"]').val();
            var search4 = $('#searchForm [name="search4"]').val();
            var search5 = $('#searchForm [name="search5"]').val();
            var search6 = $('#searchForm [name="search6"]').val();
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
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3
            }
            ;
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4
            }
            ;
            if (!isEmpty(search5)) {
                url_search += "&search5=" + search5
            }
            ;
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6
            }
            ;

            //alert("/piisteptable/list?pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow();
            $.ajax({
                type: "GET",
                url: "/piisteptable/list?pagenum="
                    + pagenum + "&amount="
                    + amount + url_search,
                dataType: "html",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();//alert("통신성공!!!!");
                    $('#content_home').html(data);
                }
            });

        });

        $("button[data-oper='wizard_steptable']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            if ($('#jobget_global_phase').val() != "CHECKOUT") {
                dlmAlert("Job's status is not CHECKOUT");
                return;
            }
            var seq3 = $('#piisteptable_modify_form [name="seq3"]').val();
            if (seq3 == "999") {
                var db = $('#stepinfoForm [name="db"]').val();
                var keymap_id = $('#piisteptable_modify_form [name="keymap_id"]').val();
                var key_name = $('#piisteptable_modify_form [name="key_name"]').val();
                var arr_cols = $('#piisteptable_modify_form [name="key_cols"]').val().split();
                var colcnt = 0;
                var selectcols = "";
                var valcols = "";
                for (var i = 0; i < arr_cols.length; i++) {
                    colcnt = i + 1;
                    var colname = arr_cols[i];
                    if (colcnt != 1) {
                        selectcols += ", ";
                        valcols += ", ";
                    }
                    selectcols += "A." + "VAL" + colcnt;
                    valcols += "VAL" + colcnt;
                    colcnt++;
                }
                var selectstr = "SELECT DISTINCT '" + keymap_id + "','" + db + "','"
                    + key_name +
                    "', TO_DATE('#BASEDATE','yyyy/mm/dd'), A.CUSTID, " +
                    selectcols
                    + ", EXPECTED_ARC_DEL_DATE FROM COTDL.TBL_PIIKEYMAP_TMP A WHERE "
                    + "DB = '" + db + "' AND KEY_NAME = '" + key_name + "' AND KEYMAP_ID = '#KEYMAP_ID' AND BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')";

                $('#piisteptable_modify_form [name="wherestr"]').val(selectstr);
                $('#piisteptable_modify_form [name="sqlstr"]').val("INSERT INTO COTDL.TBL_PIIKEYMAP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, " + valcols + ", EXPECTED_ARC_DEL_DATE) " + "\n" +selectstr);

                $('#piisteptable_modify_form [name="db"]').val(db);
                $('#piisteptable_modify_form [name="owner"]').val("COTDL");
                $('#piisteptable_modify_form [name="table_name"]').val("TBL_PIIKEYMAP_TMP");
                $('#steptabledb').text(db);
                $('#steptableowner').text("COTDL");
                $('#steptable_name').text("TBL_PIIKEYMAP_TMP");

                return;
            }

            var jobid = $('#piisteptable_modify_form [name=jobid]').val();
            var version = $('#piisteptable_modify_form [name=version]').val();
            var stepid = $('#piisteptable_modify_form [name=stepid]').val();

            var search1 = $('#piisteptable_modify_form [name=seq1]').val();
            var search2 = $('#piisteptable_modify_form [name=seq2]').val();
            var search3 = $('#piisteptable_modify_form [name=seq3]').val();
            var search4 = $('#piisteptable_modify_form [name=db]').val();
            var search5 = $('#piisteptable_modify_form [name=owner]').val();
            var search6 = $('#piisteptable_modify_form [name=table_name]').val();
            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = $('#searchForm [name="amount"]').val();

            if (isEmpty(search4)) {
                dlmAlert("Check Table information (DB)");
                return;
            }
            ;
            if (isEmpty(search5)) {
                dlmAlert("Check Table information (OWNER)");
                return;
            }
            ;
            if (isEmpty(search6)) {
                dlmAlert("Check Table information (TABLE_NAME)");
                return;
            }
            ;

            var url_search = "";
            var url_view = "wizarddialog?"
                + "jobid=" + jobid + "&"
                + "version=" + version + "&"
                + "stepid=" + stepid + "&"
            ;
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
            if (!isEmpty(search3)) {
                url_search += "&search3=" + search3
            }
            ;
            if (!isEmpty(search4)) {
                url_search += "&search4=" + search4
            }
            ;
            if (!isEmpty(search5)) {
                url_search += "&search5=" + search5
            }
            ;
            if (!isEmpty(search6)) {
                url_search += "&search6=" + search6
            }
            ;
            // alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow();
            $.ajax({
                type: "GET",
                url: "/piisteptable/" + url_view
                    + "pagenum=" + pagenum
                    + "&amount=" + amount
                    + url_search,
                dataType: "html",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#modalxlbdoy').html(data);
                    $("#modalxl").modal();
                }
            });

        });

    });

    loadAction = function (jobid, version, stepid, seq1, seq2, seq3) {
        var serchkeyno1 = jobid;
        var serchkeyno2 = version;
        var serchkeyno3 = stepid;
        var serchkeyno4 = db;
        var serchkeyno5 = owner;
        var serchkeyno6 = table_name;
        var search1 = serchkeyno1;
        var search2 = serchkeyno2;
        var search3 = serchkeyno3;
        var search4 = serchkeyno4;
        var search5 = serchkeyno5;
        var search6 = serchkeyno6;

        var serchkeyno = "/piisteptable/" + "modify?" + "jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3 + "&" + "seq1=" + serchkeyno4 + "&" + "seq2=" + serchkeyno5 + "&" + "seq3=" + serchkeyno6;

        searchAction(null, serchkeyno, serchkeyno3);

        var pageNo = 1;
        var pagenum = 1;
        var amount = 100000;
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();

        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "/piisteptable/" + "list?";
        } else {
            url_view = serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = 1;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        //alert(url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow();
        $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $("#tabledetail").html(data);

                //$('#content_home').load(data);
            }
        });
    }


    diologStepTableWaitAction = function () {

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
            return;
        }
        var serchkeyno1 = $('#piisteptable_modify_form [name=jobid]').val();
        var serchkeyno2 = $('#piisteptable_modify_form [name=version]').val();
        var serchkeyno3 = $('#piisteptable_modify_form [name=stepid]').val();
        var serchkeyno4 = $('#piisteptable_modify_form [name=db]').val();
        var serchkeyno5 = $('#piisteptable_modify_form [name=owner]').val();
        var serchkeyno6 = $('#piisteptable_modify_form [name=table_name]').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#piisteptable_modify_form [name=jobid]').val();
        var search2 = $('#piisteptable_modify_form [name=version]').val();
        var search3 = $('#piisteptable_modify_form [name=stepid]').val();
        var search4 = "";
        var search5 = "";
        var search6 = "";
        var url_search = "";
        var url_view = "";

        url_view = "modifysteptablewaitdialog?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3
            + "&" + "db=" + serchkeyno4 + "&" + "owner=" + serchkeyno5 + "&" + "table_name=" + serchkeyno6
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        if (isEmpty(pagenum))
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

        //alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();//alert('success1');
                $('#dialogsteptablewaitlistbody').html(data);
                $("#dialogsteptablewaitlist").modal();

            }
        });
    }
    diologMetaTableAction = function () {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
            return;
        }

        var pagenum = 1;
        var amount = 1000;
        var search1 = $('#piisteptable_modify_form [name=db]').val();
        var search2 = $('#piisteptable_modify_form [name=owner]').val();
        var search3 = $('#piisteptable_modify_form [name=table_name]').val();
        var url_search = "";
        var url_view = "listdialog?";
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3;
        }

        ingShow();
        $.ajax({
            type: "GET",
            url: "/metatable/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                $('#dialogmetadatalistbody').html(data);
                $("#dialogmetadatalist").modal();
            }
        });
        //$("#processing").hide();
    }
    diologStepTableUpdateAction = function () {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
            return;
        }
        var jobid = $('#piisteptable_modify_form [name=jobid]').val();
        var version = $('#piisteptable_modify_form [name=version]').val();
        var stepid = $('#piisteptable_modify_form [name=stepid]').val();

        var search1 = $('#piisteptable_modify_form [name=seq1]').val();
        var search2 = $('#piisteptable_modify_form [name=seq2]').val();
        var search3 = $('#piisteptable_modify_form [name=seq3]').val();
        var search4 = db_steptable_index;//$('#piisteptable_modify_form [name=db]').val();
        var search5 = owner_steptable_index;//$('#piisteptable_modify_form [name=owner]').val();
        var search6 = table_name_steptable_index;//$('#piisteptable_modify_form [name=table_name]').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();

        if (isEmpty(search4)) {
            dlmAlert("Check Table information (DB)");
            return;
        }
        ;
        if (isEmpty(search5)) {
            dlmAlert("Check Table information (OWNER)");
            return;
        }
        ;
        if (isEmpty(search6)) {
            dlmAlert("Check Table information (TABLE_NAME)");
            return;
        }
        ;

        var url_search = "";
        var url_view = "modifysteptableupdatedialog?"
            + "jobid=" + jobid + "&"
            + "version=" + version + "&"
            + "stepid=" + stepid + "&"
        ;
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
        if (!isEmpty(search3)) {
            url_search += "&search3=" + search3
        }
        ;
        if (!isEmpty(search4)) {
            url_search += "&search4=" + search4
        }
        ;
        if (!isEmpty(search5)) {
            url_search += "&search5=" + search5
        }
        ;
        if (!isEmpty(search6)) {
            url_search += "&search6=" + search6
        }
        ;


        //alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();//alert('success1');
                $('#dialogsteptableupdatelistbody').html(data);
                $("#dialogsteptableupdatelist").modal();

            }
        });
    }

    diologSearchTableAction = function (searchmode) {

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
            return;
        }

        $('#searchtablemode').val(searchmode);
        var serchkeyno1 = $('#piisteptable_modify_form [name=jobid]').val();
        var serchkeyno2 = $('#piisteptable_modify_form [name=version]').val();
        var serchkeyno3 = $('#piisteptable_modify_form [name=stepid]').val();
        var serchkeyno4;
        var serchkeyno5;
        var serchkeyno6;


        serchkeyno4 = $('#piisteptable_modify_form [name=db]').val();
        serchkeyno5 = $('#piisteptable_modify_form [name=owner]').val();
        serchkeyno6 = $('#piisteptable_modify_form [name=table_name]').val();


        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = serchkeyno1;
        var search2 = serchkeyno2;
        var search3 = serchkeyno3;
        var search4 = serchkeyno4;
        var search5 = serchkeyno5;
        var search6 = serchkeyno6;
        var url_search = "";
        var url_view = "";

        url_view = "searchtabledialog?jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3
            + "&";//alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        //if (isEmpty(pagenum))
        pagenum = 1;
        //if (isEmpty(amount))
        amount = 100;

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

        //alert("/piijob/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piisteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();//alert('success1');
                $('#dialogsearchtablelistbody').html(data);
                $("#dialogsearchtablelist").modal();

            }
        });
    }
    $("button[data-oper='steptableregister']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        //기존 등록된 테이블은 등록불가
        var db = $('#piisteptable_modify_form [name="db"]').val();
        var owner = $('#piisteptable_modify_form [name="owner"]').val();
        var table_name = $('#piisteptable_modify_form [name="table_name"]').val();
        var newtable = db + " " + owner + " " + table_name;

        /** update column setting이 500ms 걸리기 때문에 이값을 못읽어서 글로벌 변수로 세팅함.  */
        /*db_steptable_index = db ;
        owner_steptable_index = owner;
        table_name_steptable_index = table_name ;*/

        var existTableflag = false;
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && $('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE") {
            $('#steptablesbody tr').each(function () {
                var tr = $(this);
                var td = tr.children();
                var steptables = td.eq(7).text() + " " + td.eq(8).text() + " " + td.eq(9).text();

                if (newtable == steptables) {
                    existTableflag = true;
                    return false;
                }
            });
        }
        if (existTableflag) {
            dlmAlert("This table is already registered");
            return;
        }
        var jobtype = $('#piijob_modify_form [name="jobtype"]').val();


        if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="keymap_id"]').val())) {
            dlmAlert('<spring:message code="col.keymap_id" text="Keymap_Id"/> is mandatory');
            $('#piisteptable_modify_form [name="keymap_id"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_name"]').val())) {
            dlmAlert('<spring:message code="col.key_name" text="Key_Name"/> is mandatory');
            $('#piisteptable_modify_form [name="key_name"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_cols"]').val())) {
            dlmAlert('<spring:message code="col.key_cols" text="Key_Cols"/> is mandatory');
            $('#piisteptable_modify_form [name="key_cols"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="jobid"]').val())) {
            dlmAlert('<spring:message code="col.jobid" text="JOBID"/> is mandatory');
            $('#piisteptable_modify_form [name="jobid"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="version"]').val())) {
            dlmAlert('<spring:message code="col.version" text="Version"/> is mandatory');
            $('#piisteptable_modify_form [name="version"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="stepid"]').val())) {
            dlmAlert('<spring:message code="col.stepid" text="Stepid"/> is mandatory');
            $('#piisteptable_modify_form [name="stepid"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="db"]').val())) {
            dlmAlert('<spring:message code="col.db" text="DB"/> is mandatory');
            $('#piisteptable_modify_form [name="db"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="owner"]').val())) {
            dlmAlert('<spring:message code="col.owner" text="Owner"/> is mandatory');
            $('#piisteptable_modify_form [name="owner"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="table_name"]').val())) {
            dlmAlert('<spring:message code="col.table_name" text="Table_Name"/> is mandatory');
            $('#piisteptable_modify_form [name="table_name"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="exetype"]').val())) {
            dlmAlert('<spring:message code="col.exetype" text="Exetype"/> is mandatory');
            $('#piisteptable_modify_form [name="exetype"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="seq1"]').val())) {
            dlmAlert('<spring:message code="col.seq1" text="Seq1"/> is mandatory');
            $('#piisteptable_modify_form [name="seq1"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="seq2"]').val())) {
            dlmAlert('<spring:message code="col.seq2" text="Seq2"/> is mandatory');
            $('#piisteptable_modify_form [name="seq2"]').focus();
            return;
        }
        if (isEmpty($('#piisteptable_modify_form [name="seq3"]').val())) {
            dlmAlert('<spring:message code="col.seq3" text="Seq3"/> is mandatory');
            $('#piisteptable_modify_form [name="seq3"]').focus();
            return;
        }
        if (jobtype != "ILM" && jobtype != "MIGRATE")
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="where_col"]').val())) {
                dlmAlert('<spring:message code="col.where_col" text="Where_Col"/> is mandatory');
                $('#piisteptable_modify_form [name="where_col"]').focus();
                return;
            }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
            dlmAlert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
            $('#piisteptable_modify_form [name="wherestr"]').focus();
            return;
        }

        if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
            dlmAlert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
            $('#piisteptable_modify_form [name="wherestr"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "EXTRACT" && isEmpty($('#piisteptable_modify_form [name="sqlstr"]').val())) {
            dlmAlert('<spring:message code="col.sqlstr" text="Sqlstr"/> is mandatory');
            $('#piisteptable_modify_form [name="sqlstr"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "FINISH" && isEmpty($('#piisteptable_modify_form [name="sqlstr"]').val())) {
            dlmAlert('<spring:message code="col.sqlstr" text="Sqlstr"/> is mandatory');
            $('#piisteptable_modify_form [name="sqlstr"]').focus();
            return;
        }
        if (jobtype != "ILM" && jobtype != "MIGRATE" && jobtype != "SCRAMBLE")
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="where_key_name"]').val())) {
                dlmAlert('<spring:message code="col.where_key_name" text="Where_Key_Name"/> is mandatory');
                $('#piisteptable_modify_form [name="where_key_name"]').focus();
                return;
            }

        if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
            dlmAlert('<spring:message code="col.pk_col" text="Pk_Col"/> is mandatory');
            $('#piisteptable_modify_form [name="pk_col"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
            dlmAlert('<spring:message code="col.pk_col" text="Pk_Col"/> is mandatory');
            $('#piisteptable_modify_form [name="pk_col"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
            dlmAlert('<spring:message code="etc.keyname_desc" text="Key Desc"/> is mandatory');
            $('#piisteptable_modify_form [name="pk_col"]').focus();
            return;
        }

        if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
            dlmAlert('<spring:message code="etc.hashcol" text="Distribution Key"/> is mandatory');
            $('#piisteptable_modify_form [name="pk_col"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="where_col"]').val())) {
            dlmAlert('<spring:message code="col.where_col" text="Where_Col"/> is mandatory');
            $('#piisteptable_modify_form [name="where_col"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
            dlmAlert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
            $('#piisteptable_modify_form [name="wherestr"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="where_key_name"]').val())) {
            dlmAlert('<spring:message code="col.where_key_name" text="Where_Key_Name"/> is mandatory');
            $('#piisteptable_modify_form [name="where_key_name"]').focus();
            return;
        }

        if ($('#piisteptable_modify_form [name="exetype"]').val() == "BROADCAST" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
            dlmAlert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
            $('#piisteptable_modify_form [name="wherestr"]').focus();
            return;
        }
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "MIGRATE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
            dlmAlert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
            $('#piisteptable_modify_form [name="wherestr"]').focus();
            return;
        }

        // 추가 유효성 검사
        var preceding = $('#piisteptable_modify_form [name="preceding"]').val(); // preceding 값 가져오기
        var pagitypedetail = $('#piisteptable_modify_form [name="pagitypedetail"]').val(); // pagitypedetail 값 가져오기

        // preceding 값이 REPLACEINSERT 또는 DELDUPINSERT인 경우
        if (preceding === "REPLACEINSERT" || preceding === "DELDUPINSERT") {
            // pagitypedetail 값이 N이 아닌 경우
            if (pagitypedetail == "Y") {
                dlmAlert('<spring:message code="msg.validatepk" text="When Data Handling Method is REPLACEINSERT or DELDUPINSERT, Index, FK Disable Flag must be N."/>');
                $('#piisteptable_modify_form [name="pagitypedetail"]').focus();
                return;
            }
        }

        //if ($('#piisteptable_modify_form [name="exetype"]').val()=="HOMECAST" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())){alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');$('#piisteptable_modify_form [name="wherestr"]').focus();return;}

        var elementForm = $("#piisteptable_modify_form");

        var jobid = $('#piisteptable_modify_form [name=jobid]').val();
        var version = $('#piisteptable_modify_form [name=version]').val();
        var stepid = $('#piisteptable_modify_form [name=stepid]').val();
        var db = $('#piisteptable_modify_form [name=db]').val();
        var owner = $('#piisteptable_modify_form [name=owner]').val();
        var table_name = $('input[name=table_name]').val();
        var seq1 = $('#piisteptable_modify_form [name=seq1]').val();
        var seq2 = $('#piisteptable_modify_form [name=seq2]').val();
        var seq3 = $('#piisteptable_modify_form [name=seq3]').val();

        var formSerializeArray = $('#piisteptable_modify_form').serializeArray();
        var object = {};
        for (var i = 0; i < formSerializeArray.length; i++) {
            object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
        }

        ingShow();
        $.ajax({
            type: "POST",
            url: "/piisteptable/register",
            dataType: "text",
            data: JSON.stringify(object),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
                //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            },
            success: function (data) {
                ingHide();
                if (data == 'success') {
                    $("#" + stepid).trigger("click");

                    var serchkeyno = "/piisteptable/" + "modify?" + "jobid=" + jobid + "&" + "version=" + version + "&" + "stepid=" + stepid + "&" + "seq1=" + seq1 + "&" + "seq2=" + seq2 + "&" + "seq3=" + seq3;
                    setTimeout(function () {
                        searchAction(null, serchkeyno, stepid);
                        $('#steptables tr').each(function () { //console.log($(this).children().eq(5).text() +" "+global_seq2_new+" "+$(this).children().eq(6).text()+" "+seq3);

                            if ($(this).children().eq(5).text() == seq2 && $(this).children().eq(6).text() == seq3) {
                                 // 해당 행으로 스크롤
                                $(this)[0].scrollIntoView({ behavior: 'smooth', block: 'end' });
                            }

                        });
                    }, 500);
                    //searchAction(null, serchkeyno, stepid);

                    if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE") {

                    } else if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE") {
                        $('#steptablesbody tr').each(function () {
                            var tr = $(this);
                            var td = tr.children();
                            var steptables = td.eq(7).text() + " " + td.eq(8).text() + " " + td.eq(9).text();

                            if (newtable == steptables) {
                                selectedstepallRow = $(this);
                                return false;
                            }
                        });
                    } else {
                        showToast("처리가 완료되었습니다.", false);
                    }
                } else if (data == 'dup') {
                    $("#errormodalbody").html('<spring:message code="msg.tableisalreadyregisterd" text="The table is already registered!"/>');
                    $("#errormodal").modal();
                } else if (data.indexOf('arc_ddl_warn:') === 0) {
                    // 테이블 등록은 성공했지만 아카이브 DDL에 문제 발생
                    $("#" + stepid).trigger("click");
                    var serchkeyno = "/piisteptable/" + "modify?" + "jobid=" + jobid + "&" + "version=" + version + "&" + "stepid=" + stepid + "&" + "seq1=" + seq1 + "&" + "seq2=" + seq2 + "&" + "seq3=" + seq3;
                    setTimeout(function () { searchAction(null, serchkeyno, stepid); }, 500);
                    // 경고 모달에 DDL 확인 버튼 포함
                    var warnMsg = data.substring('arc_ddl_warn:'.length);
                    var ddlPart = '';
                    var errPart = warnMsg;
                    if (warnMsg.indexOf('|DDL:') > 0) {
                        errPart = warnMsg.substring(0, warnMsg.indexOf('|DDL:'));
                        ddlPart = warnMsg.substring(warnMsg.indexOf('|DDL:') + 5);
                    }
                    var modalHtml = '<div class="alert alert-warning mb-2"><strong>테이블 등록은 완료</strong>되었으나, 분리보관(아카이브) 테이블 DDL 실행 중 오류가 발생했습니다.</div>';
                    modalHtml += '<div class="mb-2"><strong>오류:</strong><br><small class="text-danger">' + errPart.replace(/ARC_DDL_ERROR:/g, '') + '</small></div>';
                    if (ddlPart) {
                        modalHtml += '<div class="mb-2"><strong>실행 DDL:</strong></div>';
                        modalHtml += '<textarea class="form-control" rows="6" style="font-size:11px; font-family:monospace;" readonly>' + ddlPart + '</textarea>';
                        modalHtml += '<div class="mt-2"><button class="btn btn-sm btn-outline-primary" onclick="copyArcDdl(this)"><i class="fas fa-copy"></i> DDL 복사</button>';
                        modalHtml += ' <button class="btn btn-sm btn-outline-success" onclick="retryArcDdl()"><i class="fas fa-redo"></i> 재실행</button></div>';
                    }
                    $("#errormodalbody").html(modalHtml);
                    $("#errormodal").modal("show");
                } else {
                    //$('#orderresult').html("<p class='text-danger ' style='font-size: 9px;'>"+data+"</p>");
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }

            }
        });
    });

    $('#piisteptable_modify_form [name="sqlstr"]').dblclick(function () {
        //var tx = $(this);
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "EXTRACT"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "FINISH"
        ) {
            $("#magnify2sqlstr").val($('#piisteptable_modify_form [name="sqlstr"]').val());
            $("#magnifyxl2sqlstrmodal").modal("show");
            $("#magnify2sqlstr").focus();
            $('textarea').numberedtextarea();
        } else {
            $("#magnifysqlstr").val($('#piisteptable_modify_form [name="sqlstr"]').val());
            $("#magnifyxlsqlstrmodal").modal("show");
            $("#magnifysqlstr").focus();
            $('textarea').numberedtextarea();
        }
        $('textarea').numberedtextarea();
    });

    $('#piisteptable_modify_form [name="wherestr"]').dblclick(function () {
        //var tx = $(this);
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "DELETE"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "BROADCAST"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "HOMECAST"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "ILM"
            || $('#piisteptable_modify_form [name="exetype"]').val() == "MIGRATE"
        ) {
            $("#magnify2wherestr").val($('#piisteptable_modify_form [name="wherestr"]').val());
            $("#magnifyxl2wherestrmodal").modal("show");
            $("#magnify2wherestr").focus();
            $('textarea').numberedtextarea();
        } else {
            $("#magnifywherestr").val($('#piisteptable_modify_form [name="wherestr"]').val());
            $("#magnifyxlwherestrmodal").modal("show");
            $("#magnifywherestr").focus();
            $('textarea').numberedtextarea();
        }

    });

    $("button[data-oper='applysqlstr']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        $('#piisteptable_modify_form [name="sqlstr"]').val($("#magnify2sqlstr").val());
        $("#magnifyxl2sqlstrmodal").modal("hide");

    });

    $("button[data-oper='applywherestr']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        $('#piisteptable_modify_form [name="wherestr"]').val($("#magnify2wherestr").val());
        $("#magnifyxl2wherestrmodal").modal("hide");
    });

    /*document.getElementById("sqlTypeSelect").addEventListener("change", function() {
        var wizardButton = document.getElementById("wizardButton");
        if (this.value === "AUTO") {
            wizardButton.style.display = "block";
            $('#piisteptable_modify_form [name="wherestr"]').val("");

            wizardButton.click();
        } else {
            wizardButton.style.display = "none";
            // where_col 필드 값을 null로 설정
            document.getElementById('where_col_scr').value = '';

            // where_key_name 필드 값을 null로 설정
            document.getElementById('where_key_name_scr').value = '';

            $('#piisteptable_modify_form [name="wherestr"]').val("1=1");
        }
    });*/

    /* ── 아카이브 DDL 관련 함수 ── */

    /** DDL 텍스트 클립보드 복사 */
    function copyArcDdl(btn) {
        var textarea = $(btn).closest('div').siblings('textarea');
        if (textarea.length) {
            textarea[0].select();
            document.execCommand('copy');
            $(btn).text(' 복사됨!').addClass('btn-success').removeClass('btn-outline-primary');
            setTimeout(function(){ $(btn).html('<i class="fas fa-copy"></i> DDL 복사').addClass('btn-outline-primary').removeClass('btn-success'); }, 2000);
        }
    }

    /** 아카이브 DDL 재실행 */
    function retryArcDdl() {
        var object = {};
        var formSerializeArray = $('#piisteptable_modify_form').serializeArray();
        for (var i = 0; i < formSerializeArray.length; i++) {
            object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
        }
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piisteptable/retryArcDdl",
            dataType: "json",
            data: JSON.stringify(object),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                if (data.status === 'OK') {
                    $("#errormodal").modal("hide");
                    showToast("처리가 완료되었습니다.", false);
                } else {
                    var html = '<div class="alert alert-danger">재실행 실패</div>';
                    html += '<div><small>' + (data.message || '') + '</small></div>';
                    $("#errormodalbody").html(html);
                }
            },
            error: function (req, err) {
                ingHide();
                $("#errormodalbody").html('<div class="alert alert-danger">재실행 요청 오류: ' + req.status + '</div>');
            }
        });
    }

    /** 아카이브 DDL 상태 확인 (modify 화면에서 호출 가능) */
    function checkArcDdl(db, owner, table_name) {
        var object = { db: db, owner: owner, table_name: table_name };
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piisteptable/checkArcDdl",
            dataType: "json",
            data: JSON.stringify(object),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                var html = '';
                if (data.status === 'EXISTS') {
                    html += '<div class="alert alert-success"><i class="fas fa-check-circle"></i> ' + data.message + '</div>';
                } else if (data.status === 'NOT_EXISTS') {
                    html += '<div class="alert alert-warning"><i class="fas fa-exclamation-triangle"></i> ' + data.message + '</div>';
                } else {
                    html += '<div class="alert alert-danger"><i class="fas fa-times-circle"></i> ' + (data.message || 'Error') + '</div>';
                }
                if (data.ddl) {
                    html += '<div class="mb-2"><strong>CREATE TABLE DDL:</strong></div>';
                    html += '<textarea class="form-control" rows="8" style="font-size:11px; font-family:monospace;">' + data.ddl + '</textarea>';
                }
                if (data.indexDdls) {
                    html += '<div class="mt-2 mb-1"><strong>INDEX DDL:</strong></div>';
                    html += '<textarea class="form-control" rows="3" style="font-size:11px; font-family:monospace;">' + data.indexDdls.join(';\n') + ';</textarea>';
                }
                html += '<div class="mt-2">';
                html += '<button class="btn btn-sm btn-outline-primary" onclick="copyArcDdl(this)"><i class="fas fa-copy"></i> DDL 복사</button>';
                if (data.status === 'NOT_EXISTS') {
                    html += ' <button class="btn btn-sm btn-outline-success" onclick="retryArcDdlWithParams(\'' + db + '\',\'' + owner + '\',\'' + table_name + '\')"><i class="fas fa-redo"></i> DDL 실행</button>';
                }
                html += '</div>';
                $("#errormodalbody").html(html);
                $("#errormodal").modal("show");
            },
            error: function (req, err) {
                ingHide();
                $("#errormodalbody").html('<div class="alert alert-danger">확인 요청 오류: ' + req.status + '</div>');
                $("#errormodal").modal("show");
            }
        });
    }

    /** 파라미터 기반 아카이브 DDL 재실행 */
    function retryArcDdlWithParams(db, owner, table_name) {
        var object = { db: db, owner: owner, table_name: table_name, exetype: 'DELETE' };
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piisteptable/retryArcDdl",
            dataType: "json",
            data: JSON.stringify(object),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                if (data.status === 'OK') {
                    $("#errormodal").modal("hide");
                    showToast("처리가 완료되었습니다.", false);
                } else {
                    var html = '<div class="alert alert-danger">DDL 실행 실패</div>';
                    html += '<div><small>' + (data.message || '') + '</small></div>';
                    $("#errormodalbody").html(html);
                }
            },
            error: function (req, err) {
                ingHide();
                $("#errormodalbody").html('<div class="alert alert-danger">요청 오류: ' + req.status + '</div>');
            }
        });
    }
</script>

