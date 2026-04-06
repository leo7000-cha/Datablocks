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
            <c:when test="${exetype eq 'KEYMAP' || exetype eq 'UPDATE' || exetype eq 'DELETE' || piisteptable.stepid eq 'EXE_TRANSFORM' }">
                <button data-oper='wizard_steptable' class="btn btn-detail-wizard"><i
                        class="fa-solid fa-wand-sparkles"></i> Wizard
                </button>
            </c:when>
            <c:otherwise>

            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${exetype eq 'ARCHIVE'}">
            </c:when>
            <c:otherwise>
                <button data-oper='steptablemodify' class="btn btn-detail-save"><i class="fas fa-save"></i> <spring:message
                        code="btn.save" text="Save"/></button>
                <button data-oper='steptableremove' class="btn btn-detail-remove"><i class="fas fa-trash-alt"></i> <spring:message
                        code="btn.remove" text="Remove"/></button>
            </c:otherwise>
        </c:choose>
        <c:if test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
            <button type="button" class="btn" style="background:linear-gradient(135deg,#94a3b8,#78909c); color:#fff; border:none; padding:5px 12px; border-radius:5px; font-size:0.75rem;"
                    onclick="checkArcDdl('${piisteptable.db}','${piisteptable.owner}','${piisteptable.table_name}')">
                <i class="fas fa-database"></i> Archive DDL
            </button>
        </c:if>
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
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" name='keymap_id'
                                                value='<c:out value="${piisteptable.keymap_id}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_name" text="Key_Name"/></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" name='key_name'
                                                value='<c:out value="${piisteptable.key_name}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_cols" text="Key_Cols"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" name='key_cols'
                                                value='<c:out value="${piisteptable.key_cols}"/>'
                                                ></td>
                </tr>
            </c:when>
            <c:otherwise>

            </c:otherwise>
        </c:choose>


        <c:if test="${ exetype ne 'EXTRACT' }">
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
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'>
                        <input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                               onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2_new'
                               value='<c:out value="${piisteptable.seq2}"/>'></td>
                    <th class="th-get">SEQ2</th>
                    <td class="td-get-l"><input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                value='<c:out value="${piisteptable.seq3}"/>'></td>
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
                    <td class="td-get-l"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'>
                        <input type="text" class="form-control  form-control-sm small-text" maxlength='6'
                               onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2_new'
                               value='<c:out value="${piisteptable.seq2}"/>'><%--<c:out
                            value="${piisteptable.seq2}"/>--%></td>
                    <th class="th-hidden">SEQ3</th>
                    <td class="td-hidden"><input type="hidden" class="form-control  form-control-sm small-text" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                 value='<c:out value="${piisteptable.seq3}"/>'></td>

                    <c:choose>
                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                            <th class="th-get"><spring:message code="col.pk_col" text="Pk_Col"/></th>
                            <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                                  name='pk_col' style="font-size:12px;"
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
                        <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE'  || exetype eq 'SYNC'}">
                            <th class="th-get"><spring:message code="col.regdate" text="Regdate"/></th>
                            <td class="td-get-l"><c:out value="${piisteptable.regdate}"/></td>
                            <th class="th-get"><spring:message code="col.upddate" text="Upddate"/></th>
                            <td class="td-get-l"><c:out value="${piisteptable.upddate}"/></td>
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
                            </td>
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
                        <c:when test="${exetype eq 'HOMECAST'}">
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
                        </c:when>

                        <c:otherwise>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${exetype eq 'UPDATE'}">
                            <th class="th-get" colspan=2>
                                <spring:message code="etc.updatecols" text="Update cols"/>
                                <a class="collapse-item" href='javascript:diologStepTableUpdateAction();'>
                                    <i class="fas fa-edit"></i>
                                </a>
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
            <c:when test="${exetype eq 'KEYMAP' || exetype eq 'ARCHIVE' || exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' || exetype eq 'BROADCAST' || exetype eq 'HOMECAST' }">

            </c:when>
            <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC' }">
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
                                                       text="Data Processing Unit"/><font
                            style="color:blue">*</font></th>
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
            <c:when test="${exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'BROADCAST'  || exetype eq 'HOMECAST' || exetype eq 'EXTRACT' }">
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
                            style="color:RED">*</font>--%></th>
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
                        <select class="form-control  form-control-sm small-text" name="preceding" id="precedingSelect">
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
            <c:when test="${exetype eq 'ILM'  || exetype eq 'MIGRATE'  }">
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
                            style="color:RED">*</font></th>
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
                    <c:when test="${exetype eq 'MIGRATE'  || exetype eq 'SYNC' }">
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
                                        <c:if test="${piisteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
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
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SCRAMBLE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
                    </th>
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text"
                                                          name='where_col'
                                                          value='<c:out value="${piisteptable.where_col}"/>'
                                                          style="background-color: WHITE;" ></td>
                </tr>
                <tr>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                            style="color:RED"><c:if
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SCRAMBLE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
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
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="7"
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

            <c:when test="${exetype eq 'HOMECAST'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="8"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                    <td class="td-get-l" colspan=5><textarea spellcheck="false" rows="12"
                                                             class="form-control  form-control-sm small-text" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' }">
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


        <c:choose>
            <c:when test="${exetype eq 'ARCHIVE'}">
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="10" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="7" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'KEYMAP' }">
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                            style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="6" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'BROADCAST' || exetype eq 'HOMECAST'}">
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="9" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" ><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'EXTRACT' || exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' }">
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="19" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;"><c:out value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}"></c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea spellcheck="false" rows="6" class="form-control  form-control-sm small-text" name='sqlstr'
                                  style="font-size: 12px;"><c:out value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </tr>
            </c:otherwise>
        </c:choose>

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
<div class="modal fade" id="modalxl" tabindex="-1" role="dialog" aria-labelledby="modalxlLabel" aria-hidden="true">
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
            <div class="modal-body modal-body-custom" id="modalxlbdoy" >
                Modal body..
            </div>

            <!-- Modal footer -->
            <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 10px 15px; background: #f8fafc;">
                <button type="button" class="btn-wizard-close" data-dismiss="modal">
                    <i class="fas fa-times"></i> Close
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
                <h1 class="h5 mb-0"><spring:message
                        code="etc.updatecols_mgmt" text="Update columns management"/></h1>
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
            const confirmed = confirm(
                "⚠️ 'Y'를 선택하면 해당 테이블의 인덱스,FK가 자동으로 DROP 후 CREATE 됩니다.\n" +
                "이 작업은 다른 사용자의 업무와 처리 성능에 영향을 줄 수 있으므로, 빈번히 사용되는 테이블의 경우 반드시 사전 공지가 필요합니다.\n\n" +
                "계속 진행하시겠습니까?"
            );

            if (!confirmed) {
                // 사용자가 취소했을 경우 기본값으로 돌리기
                document.getElementById("pagitypedetail").value = "";
                return;
            }
        }
    }
    document.addEventListener('DOMContentLoaded', function() {
        const precedingSelect = document.getElementById('precedingSelect');
        const truncField = document.getElementById('truncPartitionNameField');

        function toggleTruncField() {
            if (precedingSelect.value === 'TRUNCSERT') {
                truncField.style.display = 'table-cell';
            } else {
                truncField.style.display = 'none';
            }
        }

        // 페이지 로드 시 초기 상태 설정
        toggleTruncField();

        // select 박스 변경 시 상태 업데이트
        precedingSelect.addEventListener('change', toggleTruncField);
    });

    function modifyColumnString(input) {
        // 입력 문자열을 쉼표로 나누어 칼럼 배열 생성
        const columns = input.split(',').map(col => col.trim());

        function countMiddleColumns(startPattern, endPattern) {
            const startIndex = columns.findIndex(col => col.includes(startPattern));
            const endIndex = columns.findIndex(col => col.includes(endPattern));

            if (startIndex === -1 || endIndex === -1 || startIndex >= endIndex) {
                return 0; // 원하는 칼럼이 없거나 순서가 잘못된 경우 0 반환
            }

            // 시작과 끝 사이의 쉼표 개수 계산
            const middleColumns = columns.slice(startIndex + 1, endIndex);
            const commaCount = middleColumns.filter(col => col !== '').length; // 빈 값 제외하고 쉼표 개수 세기

            return commaCount; // 중간 칼럼 수 반환
        }

        // CUSTID와 EXPECTED_ARC_DEL_DATE 사이의 VAL 찾기
        const middleCount1 = countMiddleColumns('.CUSTID', 'EXPECTED_ARC_DEL_DATE');
        //console.log(middleCount1);
        // 중간 칼럼 수에 따라 VAL 추가
        if (middleCount1 > 0) {
            return Array.from({ length: Math.min(middleCount1, 4) }, (_, i) => 'VAL' + (i + 1)).join(', ');
        }

        // TO_DATE('#BASEDATE','yyyy/mm/dd'), ACTID와 null 사이의 VAL 찾기
        const middleCount2 = countMiddleColumns("TO_DATE('#BASEDATE','yyyy/mm/dd'), ACTID", 'null');
//console.log(middleCount2);
        // 두 번째 결과가 비어있지 않을 때만 VAL 추가
        return middleCount2 > 0 ? Array.from({ length: Math.min(middleCount2, 4) }, (_, i) => 'VAL' + (i + 1)).join(', ') : 'VAL1';
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
        var updatecolsemptyflag2 = false;
        if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE") {
            /* $('#steptableupdatebody tr').each(function(){ */
            $('#steptableupdatemodify > tr').each(function () {
                updatecolsemptyflag2 = true;
            });

            if (!updatecolsemptyflag2) {
                diologStepTableUpdateAction();
            }
        }
        // data_handling_method select 요소의 변경 이벤트 처리
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
        $("button[data-oper='steptablemodify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var jobtype = $('#piijob_modify_form [name="jobtype"]').val();
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="keymap_id"]').val())) {
                alert('<spring:message code="col.keymap_id" text="Keymap_Id"/> is mandatory');
                $('#piisteptable_modify_form [name="keymap_id"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_name"]').val())) {
                alert('<spring:message code="col.key_name" text="Key_Name"/> is mandatory');
                $('#piisteptable_modify_form [name="key_name"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_cols"]').val())) {
                alert('<spring:message code="col.key_cols" text="Key_Cols"/> is mandatory');
                $('#piisteptable_modify_form [name="key_cols"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="jobid"]').val())) {
                alert('<spring:message code="col.jobid" text="JOBID"/> is mandatory');
                $('#piisteptable_modify_form [name="jobid"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="version"]').val())) {
                alert('<spring:message code="col.version" text="Version"/> is mandatory');
                $('#piisteptable_modify_form [name="version"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="stepid"]').val())) {
                alert('<spring:message code="col.stepid" text="Stepid"/> is mandatory');
                $('#piisteptable_modify_form [name="stepid"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="db"]').val())) {
                alert('<spring:message code="col.db" text="DB"/> is mandatory');
                $('#piisteptable_modify_form [name="db"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="owner"]').val())) {
                alert('<spring:message code="col.owner" text="Owner"/> is mandatory');
                $('#piisteptable_modify_form [name="owner"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="table_name"]').val())) {
                alert('<spring:message code="col.table_name" text="Table_Name"/> is mandatory');
                $('#piisteptable_modify_form [name="table_name"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="exetype"]').val())) {
                alert('<spring:message code="col.exetype" text="Exetype"/> is mandatory');
                $('#piisteptable_modify_form [name="exetype"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="seq1"]').val())) {
                alert('<spring:message code="col.seq1" text="Seq1"/> is mandatory');
                $('#piisteptable_modify_form [name="seq1"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="seq2"]').val())) {
                alert('<spring:message code="col.seq2" text="Seq2"/> is mandatory');
                $('#piisteptable_modify_form [name="seq2"]').focus();
                return;
            }
            if (isEmpty($('#piisteptable_modify_form [name="seq3"]').val())) {
                alert('<spring:message code="col.seq3" text="Seq3"/> is mandatory');
                $('#piisteptable_modify_form [name="seq3"]').focus();
                return;
            }
            if (jobtype != "ILM" && jobtype != "MIGRATE")
                if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="where_col"]').val())) {
                    alert('<spring:message code="col.where_col" text="Where_Col"/> is mandatory');
                    $('#piisteptable_modify_form [name="where_col"]').focus();
                    return;
                }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
                $('#piisteptable_modify_form [name="wherestr"]').focus();
                return;
            }

            if ($('#piisteptable_modify_form [name="exetype"]').val() == "EXTRACT" && isEmpty($('#piisteptable_modify_form [name="sqlstr"]').val())) {
                alert('<spring:message code="col.sqlstr" text="Sqlstr"/> is mandatory');
                $('#piisteptable_modify_form [name="sqlstr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "FINISH" && isEmpty($('#piisteptable_modify_form [name="sqlstr"]').val())) {
                alert('<spring:message code="col.sqlstr" text="Sqlstr"/> is mandatory');
                $('#piisteptable_modify_form [name="sqlstr"]').focus();
                return;
            }
            if (jobtype != "ILM" && jobtype != "MIGRATE")
                if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="where_key_name"]').val())) {
                    alert('<spring:message code="col.where_key_name" text="Where_Key_Name"/> is mandatory');
                    $('#piisteptable_modify_form [name="where_key_name"]').focus();
                    return;
                }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
                alert('<spring:message code="col.pk_col" text="Pk_Col"/> is mandatory');
                $('#piisteptable_modify_form [name="pk_col"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
                alert('<spring:message code="col.pk_col" text="Pk_Col"/> is mandatory');
                $('#piisteptable_modify_form [name="pk_col"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
                alert('<spring:message code="etc.keyname_desc" text="Key Desc"/> is mandatory');
                $('#piisteptable_modify_form [name="pk_col"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE" && isEmpty($('#piisteptable_modify_form [name="pk_col"]').val())) {
                alert('<spring:message code="etc.hashcol" text="Distribution Key"/> is mandatory');
                $('#piisteptable_modify_form [name="pk_col"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="where_col"]').val())) {
                alert('<spring:message code="col.where_col" text="Where_Col"/> is mandatory');
                $('#piisteptable_modify_form [name="where_col"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
                $('#piisteptable_modify_form [name="wherestr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE" && isEmpty($('#piisteptable_modify_form [name="where_key_name"]').val())) {
                alert('<spring:message code="col.where_key_name" text="Where_Key_Name"/> is mandatory');
                $('#piisteptable_modify_form [name="where_key_name"]').focus();
                return;
            }

            if ($('#piisteptable_modify_form [name="exetype"]').val() == "BROADCAST" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
                $('#piisteptable_modify_form [name="wherestr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "SCRAMBLE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
                $('#piisteptable_modify_form [name="wherestr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "ILM" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
                $('#piisteptable_modify_form [name="wherestr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "MIGRATE" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())) {
                alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');
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
                    alert('<spring:message code="msg.validatepk" text="When Data Handling Method is REPLACEINSERT or DELDUPINSERT, Index, FK Disable Flag must be N."/>');
                    $('#piisteptable_modify_form [name="pagitypedetail"]').focus();
                    return;
                }
            }
            //if ($('#piisteptable_modify_form [name="exetype"]').val()=="HOMECAST" && isEmpty($('#piisteptable_modify_form [name="wherestr"]').val())){alert('<spring:message code="col.wherestr" text="Wherestr"/> is mandatory');$('#piisteptable_modify_form [name="wherestr"]').focus();return;}

            var updatecolsemptyflag = false;
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE") {
                /* $('#steptableupdatebody tr').each(function(){ */
                $('#steptableupdatemodify > tr').each(function () {
                    updatecolsemptyflag = true;
                });

                if (!updatecolsemptyflag) {
                    alert('<spring:message code="msg.updatecolismandatory" text="Setting the update column is mandatory"/>');
                    diologStepTableUpdateAction();
                    return;
                }
            }

            if ($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP") {
                var key_name = $('#piisteptable_modify_form [name=key_name]').val();
                var key_cols = $('#piisteptable_modify_form [name=key_cols]').val();
                var key_refstr = "B.KEY_NAME = '" + key_name + "' AND B.KEYMAP_ID = '#KEYMAP_ID' AND B.BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')";//AND A.#WHERECOL1 = B.VAL1";
                var arr_cols = key_cols.split(",");
                var conindex = 0;
                for (var i = 0; i < arr_cols.length; i++) {
                    conindex = i + 1;
                    key_refstr += " AND A.#WHERECOL" + conindex + " = B.VAL" + conindex;
                }
                $('#piisteptable_modify_form [name="key_refstr"]').val(key_refstr);
            }

            var elementForm = $("#piisteptable_modify_form");
            var elementResult = $("#jobstepdetail");
            var jobid = $('#piisteptable_modify_form [name=jobid]').val();
            var version = $('#piisteptable_modify_form [name=version]').val();
            var stepid = $('#piisteptable_modify_form [name=stepid]').val();
            var seq1 = $('#piisteptable_modify_form [name=seq1]').val();
            var seq2 = $('#piisteptable_modify_form [name=seq2]').val();
            global_seq2_new = $('#piisteptable_modify_form [name=seq2_new]').val();
            var exetype = $('#piisteptable_modify_form [name="exetype"]').val();
            var seq3 = $('#piisteptable_modify_form [name=seq3]').val();
            var serchkeyno1 = $('input[name=jobid]').val();
            var serchkeyno2 = $('input[name=version]').val();
            var serchkeyno3 = $('input[name=stepid]').val();
            var serchkeyno4 = $('input[name=db]').val();
            var serchkeyno5 = $('input[name=owner]').val();
            var serchkeyno6 = $('input[name=table_name]').val();
            var formSerializeArray = $('#piisteptable_modify_form').serializeArray();
            var object = {};
            for (var i = 0; i < formSerializeArray.length; i++) {
                object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piisteptable/modify",
                //dataType: "text",
                data: JSON.stringify(object),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (response) {
                    // 성공적으로 서버가 응답한 경우
                    console.log("서버 응답: ", response); // 응답 데이터를 콘솔에 출력하거나 다른 처리를 수행할 수 있습니다.
                    // 여기서 response는 서버에서 반환한 문자열이 됩니다.

                    // 성공 여부에 따라 작업 수행
                    if (response === "success") {
                        ingHide();
                        $("#" + stepid).trigger("click");
                        // 이벤트 핸들러 완료 후 실행될 코드
                        setTimeout(function () {
                            //alert("seq2_new="+global_seq2_new);
                            $('#steptables tr').each(function () { //console.log($(this).children().eq(5).text() +" "+global_seq2_new+" "+$(this).children().eq(6).text()+" "+seq3);

                                    if ($(this).children().eq(5).text() == global_seq2_new && $(this).children().eq(6).text() == seq3) {
                                        $("#GlobalSuccessMsgModal").modal("show");
                                        $(this).trigger("click");

                                        // 해당 행으로 스크롤
                                        $(this)[0].scrollIntoView({ behavior: 'smooth', block: 'end' });
                                    }

                            });
                        }, 500); // 1초 후에 실행 (1000ms = 1초)


                    } else {
                        $("#errormodalbody").html(response);
                        $("#errormodal").modal("show");
                    }
                },
                error: function (xhr, status, error) {
                    ingHide();
                    // 요청 실패 시 처리
                    $("#errormodalbody").html(xhr.responseText);
                    $("#errormodal").modal("show");
                }


            });
        });

        $("button[data-oper='steptableremove']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var confirmflag = confirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>");
            if (confirmflag == false) {
                return;
            }
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
                    $("#GlobalSuccessMsgModal").modal("show");
                    //loadAction();
                }
            });

        });

        $("button[data-oper='wizard_steptable']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            if ($('#jobget_global_phase').val() != "CHECKOUT") {
                alert("Job's status is not CHECKOUT");
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
                alert("Check Table information (DB)");
                return;
            }
            ;
            if (isEmpty(search5)) {
                alert("Check Table information (OWNER)");
                return;
            }
            ;
            if (isEmpty(search6)) {
                alert("Check Table information (TABLE_NAME)");
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

    diologMetaTableAction = function () {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            alert("Job's status is not CHECKOUT");
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

    diologStepTableWaitAction = function () {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            alert("Job's status is not CHECKOUT");
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
            + "&";
        //alert("/piistep/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
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

    diologSearchTableAction = function (searchmode) {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            alert("Job's status is not CHECKOUT");
            return;
        }
        $('#searchtablemode').val(searchmode);
        var serchkeyno1 = $('#piisteptable_modify_form [name=jobid]').val();
        var serchkeyno2 = $('#piisteptable_modify_form [name=version]').val();
        var serchkeyno3 = $('#piisteptable_modify_form [name=stepid]').val();
        var serchkeyno4;
        var serchkeyno5;
        var serchkeyno6;

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

    diologStepTableUpdateAction = function () {
        //e.preventDefault();e.stopPropagation();
        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            alert("Job's status is not CHECKOUT");
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
            alert("Check Table information (DB)");
            return;
        }
        ;
        if (isEmpty(search5)) {
            alert("Check Table information (OWNER)");
            return;
        }
        ;
        if (isEmpty(search6)) {
            alert("Check Table information (TABLE_NAME)");
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
    <c:if test="${exetype eq 'SCRAMBLE'}">
    /*const sqlTypeSelect = document.getElementById("sqlTypeSelect");
    if (sqlTypeSelect) {
        sqlTypeSelect.addEventListener("change", function() {
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
        });
    }*/
    /*const  sqlTypeSelect = document.getElementById("sqlTypeSelect");
    if (sqlTypeSelect) {
        sqlTypeSelect.addEventListener("change", function() {
            const wizardButton = document.getElementById("wizardButton");
            if (this.value === "AUTO") {
                wizardButton.style.display = "block";
                $('#piisteptable_modify_form [name="wherestr"]').val("");
                wizardButton.click();
            } else {
                wizardButton.style.display = "none";
                document.getElementById('where_col_scr').value = '';
                document.getElementById('where_key_name_scr').value = '';
                $('#piisteptable_modify_form [name="wherestr"]').val("1=1");
            }
        });
    }*/
    </c:if>

    /* ── 아카이브 DDL 확인/재실행 ── */
    $('#errormodal').on('hidden.bs.modal', function () {
        $(this).find('.modal-dialog').removeClass('modal-lg').addClass('modal-sm');
        $(this).find('.modal-title').text('Error Message');
        $("#errormodalbody").addClass('modal-sm').css({'max-height':'', 'overflow-y':''});
    });

    function copyArcDdl(btn) {
        var allTextareas = $(btn).closest('.modal-body').find('textarea');
        var allDdl = '';
        allTextareas.each(function() {
            if (allDdl) allDdl += '\n\n';
            allDdl += $(this).val();
        });
        if (allDdl) {
            var tmp = $('<textarea>').appendTo('body').val(allDdl);
            tmp[0].select();
            document.execCommand('copy');
            tmp.remove();
            $(btn).text(' Copied!').addClass('btn-success').removeClass('btn-outline-primary');
            setTimeout(function(){ $(btn).html('<i class="fas fa-copy"></i> DDL 복사').addClass('btn-outline-primary').removeClass('btn-success'); }, 2000);
        }
    }

    function checkArcDdl(db, owner, table_name) {
        console.log('[checkArcDdl] called: db=' + db + ', owner=' + owner + ', table_name=' + table_name);
        var object = { db: db, owner: owner, table_name: table_name };
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piisteptable/checkArcDdl",
            dataType: "json",
            data: JSON.stringify(object),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                console.log('[checkArcDdl] sending AJAX request...');
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (data) {
                ingHide();
                console.log('[checkArcDdl] response:', JSON.stringify(data));
                var html = '';
                if (data.status === 'EXISTS') {
                    html += '<div class="alert alert-success mb-2"><i class="fas fa-check-circle"></i> ' + data.message + '</div>';
                } else if (data.status === 'NOT_EXISTS') {
                    html += '<div class="alert alert-warning mb-2"><i class="fas fa-exclamation-triangle"></i> ' + data.message + '</div>';
                } else {
                    html += '<div class="alert alert-danger mb-2"><i class="fas fa-times-circle"></i> ' + (data.message || 'Error') + '</div>';
                }
                if (data.ddl) {
                    var ddlText = data.ddl.replace(/\s+$/, '');
                    if (!ddlText.endsWith(';')) ddlText += ';';
                    html += '<div class="mb-1"><strong>CREATE TABLE DDL:</strong></div>';
                    html += '<textarea class="form-control" rows="14" style="font-size:12px; font-family:monospace; width:100%;">' + ddlText + '</textarea>';
                }
                if (data.indexDdls) {
                    html += '<div class="mt-2 mb-1"><strong>INDEX DDL:</strong></div>';
                    html += '<textarea class="form-control" rows="6" style="font-size:12px; font-family:monospace; width:100%;">' + data.indexDdls.join(';\n') + ';</textarea>';
                }
                html += '<div class="mt-2">';
                html += '<button class="btn btn-sm btn-outline-primary" onclick="copyArcDdl(this)"><i class="fas fa-copy"></i> DDL 복사</button>';
                if (data.status === 'NOT_EXISTS') {
                    html += ' <button class="btn btn-sm btn-outline-success" onclick="retryArcDdlWithParams(\'' + db + '\',\'' + owner + '\',\'' + table_name + '\')"><i class="fas fa-redo"></i> DDL 실행</button>';
                }
                html += '</div>';
                $("#errormodal .modal-dialog").removeClass("modal-sm").addClass("modal-lg");
                $("#errormodal .modal-title").text("Archive DDL");
                $("#errormodalbody").removeClass('modal-sm').css({'max-height':'70vh', 'overflow-y':'auto'});
                $("#errormodalbody").html(html);
                $("#errormodal").modal("show");
            },
            error: function (req, err) {
                ingHide();
                console.log('[checkArcDdl] AJAX error: status=' + req.status + ', error=' + err);
                console.log('[checkArcDdl] responseText:', req.responseText);
                $("#errormodalbody").html('<div class="alert alert-danger">확인 요청 오류: ' + req.status + '<br><small>' + (req.responseText || err) + '</small></div>');
                $("#errormodal").modal("show");
            }
        });
    }

    function retryArcDdlWithParams(db, owner, table_name) {
        console.log('[retryArcDdlWithParams] called: db=' + db + ', owner=' + owner + ', table_name=' + table_name);
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
                console.log('[retryArcDdlWithParams] response:', JSON.stringify(data));
                if (data.status === 'OK') {
                    $("#errormodal").modal("hide");
                    $("#GlobalSuccessMsgModal").modal("show");
                } else {
                    var html = '<div class="alert alert-danger">DDL 실행 실패</div>';
                    html += '<div><small>' + (data.message || '') + '</small></div>';
                    $("#errormodalbody").html(html);
                }
            },
            error: function (req, err) {
                ingHide();
                console.log('[retryArcDdlWithParams] AJAX error:', req.status, err);
                $("#errormodalbody").html('<div class="alert alert-danger">요청 오류: ' + req.status + '</div>');
            }
        });
    }
</script>

