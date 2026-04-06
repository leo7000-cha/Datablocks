<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<c:set var="exetype" value="${piisteptable.exetype}"/>
<form style="margin: 0; padding: 0;" role="form" id="piisteptable_modify_form">
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='jobid'
           value='<c:out value="${piisteptable.jobid}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='version'
           value='<c:out value="${piisteptable.version}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='stepid'
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
                        <select readonly style="background-color: #ffffff; color: #666666;"
                                class="pt-0 pb-0 form-control form-control-sm" name="pagitypedetail"
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
                    <td class="td-get-l" colspan=3><input readonly style="background-color: #ffffff; color: #666666;"
                                                          type="text" class="form-control form-control-sm" name='pk_col'
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'KEYMAP'}">
                <tr>
                    <th class="th-get"><spring:message code="col.keymap_id" text="Keymap_Id"/></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" name='keymap_id'
                                                value='<c:out value="${piisteptable.keymap_id}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_name" text="Key_Name"/></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" name='key_name'
                                                value='<c:out value="${piisteptable.key_name}"/>'></td>
                    <th class="th-get"><spring:message code="col.key_cols" text="Key_Cols"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" name='key_cols'
                                                value='<c:out value="${piisteptable.key_cols}"/>'
                    ></td>
                </tr>
            </c:when>
            <c:otherwise>
                <%--<input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='keymap_id'
                       value='<c:out value="${piisteptable.keymap_id}"/>'>
                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='key_name'
                       value='<c:out value="${piisteptable.key_name}"/>'>
                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='key_cols'
                       value='<c:out value="${piisteptable.key_cols}"/>'>--%>
            </c:otherwise>
        </c:choose>

        <c:if test="${ exetype ne 'EXTRACT'}">
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
                <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                            class="form-control form-control-sm" name='db'
                                            value='<c:out value="${piisteptable.db}"/>'>
                    <div id='steptabledb'><c:out value="${piisteptable.db}"/></div>
                </td>

                <c:choose>
                    <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'>
                            <div id='steptableowner'><c:out value="${piisteptable.owner}"/></div>
                        </td>
                        <th class="th-get">
                            Table
                        </th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='table_name'
                                                    value='<c:out value="${piisteptable.table_name}"/>'>
                            <div id='steptable_name'><c:out value="${piisteptable.table_name}"/></div>
                        </td>

                    </c:when>
                    <c:when test="${exetype eq 'ARCHIVE'}">
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'><c:out
                                value="${piisteptable.owner}"/></td>
                        <th class="th-get">TABLE</th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='table_name'
                                                    value='<c:out value="${piisteptable.table_name}"/>'><c:out
                                value="${piisteptable.table_name}"/></td>

                    </c:when>
                    <c:otherwise>
                        <th class="th-get">OWNER</th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='owner'
                                                    value='<c:out value="${piisteptable.owner}"/>'>
                            <div id='steptableowner'><c:out value="${piisteptable.owner}"/></div>
                        </td>
                        <th class="th-get">
                            Table
                        </th>
                        <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                    type="hidden" class="form-control form-control-sm" name='table_name'
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
                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm" name='where_col'
                                                value='<c:out value="${piisteptable.where_col}"/>'>
                        <div id='steptableTargetdb'><c:out value="${piisteptable.where_col}"/></div>
                    </td>
                    <th class="th-get">OWNER</th>
                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm" name='where_key_name'
                                                value='<c:out value="${piisteptable.where_key_name}"/>'>
                        <div id='steptableTargetowner'><c:out value="${piisteptable.where_key_name}"/></div>
                    </td>
                    <th class="th-get">
                        TABLE<%--
                        <a class="collapse-item" href='javascript:diologSearchTableAction(2);'>
                            <i class="fas fa-search"></i>
                        </a>--%>
                    </th>
                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm" name='sqlstr'
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
                    <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;"
                                                 type="hidden" class="form-control form-control-sm" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'><c:out
                            value="${piisteptable.seq1}"/></td>
                    <th class="th-get">SEQ</th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                type="hidden" class="form-control form-control-sm" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'><c:out
                            value="${piisteptable.seq2}"/></td>
                    <th class="th-hidden">SEQ3</th>
                    <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;"
                                                 type="hidden" class="form-control form-control-sm" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                 value='<c:out value="${piisteptable.seq3}"/>'><c:out
                            value="${piisteptable.seq3}"/></td>
                </c:when>
                <c:when test="${exetype eq 'KEYMAP'}">

                    <th class="td-hidden">SEQ1</th>
                    <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;"
                                                 type="hidden" class="form-control form-control-sm" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'><c:out
                            value="${piisteptable.seq1}"/></td>
                    <th class="th-get">SEQ1</th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                type="hidden" class="form-control form-control-sm" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'><c:out
                            value="${piisteptable.seq2}"/></td>
                    <th class="th-get">SEQ2</th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                type="hidden" class="form-control form-control-sm" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                value='<c:out value="${piisteptable.seq3}"/>'><c:out
                            value="${piisteptable.seq3}"/></td>
                    <th class="th-get"><spring:message code="col.sqltype" text="Sql type"/></th>
                    <td class="td-get-l">
                        <select readonly style="background-color: #ffffff; color: #666666;"
                                class="form-control form-control-sm" name="sqltype">
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
                    <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;"
                                                 type="hidden" class="form-control form-control-sm" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq1'
                                                 value='<c:out value="${piisteptable.seq1}"/>'></td>
                    <th class="th-get">SEQ</th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                type="hidden" class="form-control form-control-sm" maxlength='6'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq2'
                                                value='<c:out value="${piisteptable.seq2}"/>'><c:out
                            value="${piisteptable.seq2}"/></td>
                    <th class="th-hidden">SEQ3</th>
                    <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;"
                                                 type="hidden" class="form-control form-control-sm" maxlength='6'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='seq3'
                                                 value='<c:out value="${piisteptable.seq3}"/>'></td>

                    <c:choose>
                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                            <th class="th-get"><spring:message code="col.pk_col" text="Pk_Col"/></th>
                            <td class="td-get-l" colspan=3><input readonly
                                                                  style="background-color: #ffffff; color: #666666;font-size:12px;"
                                                                  type="text" class="form-control form-control-sm"
                                                                  name='pk_col'
                                                                  value='<c:out value="${piisteptable.pk_col}"/>'></td>
                        </c:when>
                        <c:when test="${exetype eq 'EXTRACT'}">
                            <th class="th-get">DB</th>
                            <td class="td-get-l">
                                    <%--<input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='db' value='<c:out value="${piisteptable.db}"/>'>--%>
                                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                       class="form-control form-control-sm" name='owner'
                                       value='<c:out value="${piisteptable.owner}"/>'>
                                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                       class="form-control form-control-sm" name='table_name'
                                       value='<c:out value="${piisteptable.table_name}"/>'>
                                    <%--<div id='steptabledb'><c:out value="${piisteptable.db}"/></div>--%>
                                <select readonly style="background-color: #ffffff; color: #666666;"
                                        class="pt-0 pb-0 form-control form-control-sm" name="db"
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
                        <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SCRAMBLE' || exetype eq 'SYNC' }">
                            <th class="th-get"><spring:message code="col.regdate" text="Regdate"/></th>
                            <td class="td-get-l"><c:out value="${piisteptable.regdate}"/></td>
                            <th class="th-get"><spring:message code="col.upddate" text="Upddate"/></th>
                            <td class="td-get-l"><c:out value="${piisteptable.upddate}"/></td>
                        </c:when>
                        <c:otherwise>
                            <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                   class="form-control form-control-sm" name='pk_col'
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
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                type="hidden" class="form-control form-control-sm" name='exetype'
                                                value='<c:out value="${piisteptable.exetype}"/>'><c:out
                            value="${piisteptable.exetype}"/></td>
                    <th class="th-get"><spring:message code="col.arc_del_m" text="Arc_Del_Deadline"/></th>
                    <td class="td-get-l">
                        <c:choose>
                            <c:when test="${piisteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                    code="etc.backdated" text="Backdated"/></c:when>
                            <c:otherwise> <c:out value="${piisteptable.pagitypedetail}"/> </c:otherwise>
                        </c:choose>
                        <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                               class="form-control form-control-sm" name='pagitypedetail'
                               value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                    </td>
                </c:when>
                <c:otherwise>
                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                    <td class="td-get-l"><c:out value="${piisteptable.exetype}"/><input readonly
                                                                                        style="background-color: #ffffff; color: #666666;"
                                                                                        type="hidden"
                                                                                        class="form-control form-control-sm"
                                                                                        name='exetype'
                                                                                        value='<c:out value="${piisteptable.exetype}"/>'>
                    </td>
                    <c:choose>
                        <c:when test="${exetype eq 'KEYMAP'}">
                            <th class="th-get"><spring:message code="etc.keyname_desc" text="Key Desc"/></th>
                            <td class="td-get-l" colspan=3><input readonly
                                                                  style="background-color: #ffffff; color: #666666;"
                                                                  type="text" class="form-control form-control-sm"
                                                                  name='pk_col'
                                                                  value='<c:out value="${piisteptable.pk_col}"/>'></td>
                        </c:when>
                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                            <th class="th-get"><spring:message code="col.arc_del_m" text="Arc_Del_Deadline"/></th>
                            <td class="td-get-l">
                                <c:choose>
                                    <c:when test="${piisteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                            code="etc.backdated" text="Backdated"/>
                                        <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                               class="form-control form-control-sm" name='pagitypedetail'
                                               value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="d-flex align-items-center">
                                            <input type="text" "preceding" readonly class="form-control form-control-sm" style="background-color: #ffffff; color: #666666;width:40px;" name='pagitypedetail'
                                                   value='<c:out value="${piisteptable.pagitypedetail}"/>'>
                                            &nbsp;<span> Months </span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                            </td>
                        </c:when>
                        <c:when test="${ exetype eq 'SCRAMBLE' or exetype eq 'MIGRATE'}">
                            <th class="th-get">/*+ Hint */</th>
                            <td class="td-get-l" COLSPAN="3">
                                <input type="text" class="form-control  form-control-sm small-text" readonly style="background-color: WHITE;"
                                       name='hintselect'
                                       value='<c:out value="${piisteptable.hintselect}"/>'>
                            </td>
                        </c:when>
                        <c:when test="${ exetype eq 'HOMECAST'}">
                            <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                            <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;"
                                                        type="text" class="form-control form-control-sm" maxlength='8'
                                                        onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                        name='commitcnt'
                                                        value='<c:out value="${piisteptable.commitcnt}"/>'></td>
                        </c:when>
                        <c:otherwise>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${exetype eq 'UPDATE'}">
                            <th class="th-get" colspan=2>
                                <spring:message code="etc.updatecols" text="Update cols"/>
                            </th>
                            <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                                   class="form-control form-control-sm" name='pagitype'
                                   value='<c:out value="${piisteptable.pagitype}"/>'>
                        </c:when>
                        <c:otherwise>
                            <%-- <th class="th-hidden"><spring:message code="col.pagitype" text="Pagitype"/></th>
                             <td class="td-hidden"><input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm"
                                                          name='pagitype'
                                                          value='<c:out value="${piisteptable.pagitype}"/>'></td>--%>
                        </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </tr>

        <c:choose>
            <c:when test="${exetype eq 'KEYMAP' || exetype eq 'ARCHIVE' ||  exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' || exetype eq 'BROADCAST' || exetype eq 'HOMECAST'  }">

            </c:when>
            <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'MIGRATE' || exetype eq 'ILM' || exetype eq 'SYNC'}">
                <tr>
                    <th class="th-hidden"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                    <td class="th-hidden"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                 class="form-control form-control-sm" maxlength='3'
                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                 name='parallelcnt'
                                                 value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <c:choose>
                        <c:when test="${exetype eq 'SCRAMBLE' and fn:startsWith(piisteptable.jobid, 'TESTDATA_AUTO_GEN')}">
                            <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/>
                            </th>
                            <td class="td-get-l" colspan=1><input readonly style="background-color: #ffffff; color: #666666;" type="text" class="form-control form-control-sm"
                                                                  name='where_col'
                                                                  value='<c:out value="${piisteptable.where_col}"/>'
                                                                  style="background-color: WHITE;" readonly></td>

                            <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/>
                            </th>
                            <td class="td-get-l" colspan=1><input readonly style="background-color: #ffffff; color: #666666;" type="text" class="form-control form-control-sm"
                                                                  name='where_key_name'
                                                                  value='<c:out value="${piisteptable.where_key_name}"/>'
                                                                  style="background-color: WHITE;" readonly></td>
                        </c:when>
                    </c:choose>
                    <th class="th-get"><spring:message code="col.handlecnt"
                                                       text="Data Processing Unit"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'UPDATE' || (exetype eq 'RECOVERY' && piisteptable.pagitypedetail eq 'RECOVERY_U')}">
                <tr>
                    <th class="th-get"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" maxlength='3'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                name='parallelcnt' value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>

                        <%--                    <th class="th-get" rowspan=3>--%>
                        <%--                        <spring:message code="etc.updatecols" text="Update cols"/>--%>
                        <%--                        <a class="collapse-item" href='javascript:diologStepTableUpdateAction();'>--%>
                        <%--                            <i class="fas fa-edit"></i>--%>
                        <%--                        </a>--%>
                        <%--                    </th>--%>
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
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" maxlength='3'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                name='parallelcnt' value='<c:out value="${piisteptable.parallelcnt}"/>'>
                    </td>
                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    <td class="td-get-l"><input readonly style="background-color: #ffffff; color: #666666;" type="text"
                                                class="form-control form-control-sm" maxlength='8'
                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                value='<c:out value="${piisteptable.commitcnt}"/>'></td>

                    <th class="th-get" rowspan=3>
                        <spring:message code="etc.table_wait" text="Waiting table"/>
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
            <c:when test="${ exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'BROADCAST'|| exetype eq 'HOMECAST' || exetype eq 'EXTRACT' }">
                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                       class="form-control form-control-sm" name='where_col'
                       value='<c:out value="${piisteptable.where_col}"/>'>
                <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
                       class="form-control form-control-sm" name='where_key_name'
                       value='<c:out value="${piisteptable.where_key_name}"/>'>
            </c:when>
            <c:when test="${exetype eq 'SCRAMBLE'  }">
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                   text="Processing_Method"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get"
                        COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piisteptable.processing_method}" />'>--%>
                        <select class="form-control form-control-sm" name="succedding" readonly
                                style="background-color: #ffffff; color: #666666;">
                            <option value=""
                                    <c:if test="${piisteptable.succedding eq ''}">selected</c:if> >
                            </option>
                            <option value="TMP_TABLE"
                                    <c:if test="${piisteptable.succedding eq 'TMP_TABLE'}">selected</c:if> >
                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing"/>
                            </option>
                                <%--<option value="SQLLDR"
                                        <c:if test="${piisteptable.succedding eq 'SQLLDR'}">selected</c:if> >
                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                </option>
                                <option value="PARTITION"
                                        <c:if test="${piisteptable.succedding eq 'PARTITION'}">selected</c:if> >
                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                </option>
                                <option value="DIRECT_SQL"
                                        <c:if test="${piisteptable.succedding eq 'DIRECT_SQL'}">selected</c:if> >
                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                </option>--%>
                        </select>
                    </td>
                    <th class="th-get"><spring:message code="etc.hashcol" text="Distribution Key"/><%--<font
                            style="color:blue">*</font>--%></th>
                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                          style="background-color: #ffffff; color: #666666;"
                                                          name='pk_col' style="font-size:12px;"
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control form-control-sm" name="pipeline" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                        <select class="form-control form-control-sm" name="preceding" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                          style="background-color: #ffffff; color: #666666;"
                                                          name='uval1' style="font-size:12px;"
                                                          value='<c:out value="${piisteptable.uval1}"/>'></td>

                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control form-control-sm" name="pagitypedetail" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                        <select class="form-control form-control-sm" name="pagitype" readonly
                                style="background-color: #ffffff; color: #666666;">
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
            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE'}">
                <tr>
                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                   text="Processing_Method"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get"
                        COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piisteptable.processing_method}" />'>--%>
                        <select class="form-control form-control-sm" name="succedding" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                          style="background-color: #ffffff; color: #666666;"
                                                          name='pk_col' style="font-size:12px;"
                                                          value='<c:out value="${piisteptable.pk_col}"/>'></td>
                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control form-control-sm" name="pipeline" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                        <select class="form-control form-control-sm" name="preceding" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                    <c:when test="${exetype eq 'MIGRATE' || exetype eq 'SYNC' }">
                        <th scope="row" class="th-get"><spring:message code="col.data_handling_method"
                                                                       text="Data_Handling_Method"/><font
                                style="color:blue">*</font></th>
                        <td class="td-get" COLSPAN="1">
                            <select class="form-control form-control-sm" name="preceding" readonly
                                    style="background-color: #ffffff; color: #666666;">
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
                        <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                              style="background-color: #ffffff; color: #666666;"
                                                              name='uval1' style="font-size:12px;"
                                                              value='<c:out value="${piisteptable.uval1}"/>'></td>
                    </c:when>
                </c:choose>
                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                            style="color:blue">*</font></th>
                    <td class="td-get">
                        <select class="form-control form-control-sm" name="pagitypedetail" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                        <select class="form-control form-control-sm" name="pagitype" readonly
                                style="background-color: #ffffff; color: #666666;">
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
                    <td class="td-get-l" colspan=3><input type="text" class="form-control  form-control-sm small-text" readonly
                                                          name='where_col'
                                                          value='<c:out value="${piisteptable.where_col}"/>'
                                                          style="background-color: WHITE;" ></td>
                </tr>
                <tr>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                            style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=1><input type="text" class="form-control  form-control-sm small-text" readonly
                                                          name='where_key_name'
                                                          value='<c:out value="${piisteptable.where_key_name}"/>'
                                                          style="background-color: WHITE;" ></td>
                    <th class="th-get">/*+ Hint */</th>
                    <td class="td-get-l" COLSPAN="3">
                        <input type="text" class="form-control  form-control-sm small-text" readonly style="background-color: WHITE;"
                               name='hintselect'
                               value='<c:out value="${piisteptable.hintselect}"/>'>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/><font
                            style="color:RED"><c:if
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'SCRAMBLE' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
                    </th>
                    <td class="td-get-l" colspan=3><input readonly style="background-color: #ffffff; color: #666666;"
                                                          type="text" class="form-control form-control-sm"
                                                          name='where_col'
                                                          value='<c:out value="${piisteptable.where_col}"/>'
                    ></td>
                </tr>
                <tr>
                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                            style="color:RED"><c:if
                            test="${piisteptable.seq3 ne '999' && piijob.jobtype ne 'SCRAMBLE' && piijob.jobtype ne 'ILM' && piijob.jobtype ne 'MIGRATE' && piijob.jobtype ne 'SYNC'}">*</c:if></font>
                    </th>
                    <td class="td-get-l" colspan=3><input readonly style="background-color: #ffffff; color: #666666;"
                                                          type="text" class="form-control form-control-sm"
                                                          name='where_key_name'
                                                          value='<c:out value="${piisteptable.where_key_name}"/>'
                    ></td>
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
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="7"
                                                             class="form-control form-control-sm" name='wherestr'
                    ><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'ARCHIVE' }">
                <tr>
                    <th class="th-get"><spring:message code="etc.selectstr" text="Selectstr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="7"
                                                             class="form-control form-control-sm" name='wherestr'
                    ><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'BROADCAST'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="9"
                                                             class="form-control form-control-sm" name='wherestr'
                    ><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="15"
                                                             class="form-control form-control-sm" name='wherestr'
                                                             style="font-size: 12px;"><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${exetype eq 'HOMECAST'}">
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="8"
                                                             class="form-control form-control-sm" name='wherestr'
                    ><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:when>
            <c:when test="${ exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC' || exetype eq 'EXTRACT' }">
            </c:when>
            <c:otherwise>
                <tr>
                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                            style="color:RED">*</font></th>
                    <td class="td-get-l" colspan=5><textarea readonly
                                                             style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                                             spellcheck="false" rows="6"
                                                             class="form-control form-control-sm" name='wherestr'
                    ><c:out
                            value="${piisteptable.wherestr}"/></textarea></td>
                </tr>
            </c:otherwise>
        </c:choose>

        <c:if test="${exetype ne 'MIGRATE' && exetype ne 'SCRAMBLE' && exetype ne 'ILM' && exetype ne 'SYNC'}">
        <tr>
            </c:if>
            <c:choose>
                <c:when test="${exetype eq 'ARCHIVE'}">
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="10" class="form-control form-control-sm" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" readonly><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:when>
                <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="8" class="form-control form-control-sm" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" readonly><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:when>
                <c:when test="${exetype eq 'KEYMAP' }">
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                            style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="7" class="form-control form-control-sm" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" readonly><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:when>
                <c:when test="${exetype eq 'BROADCAST' || exetype eq 'HOMECAST'}">
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><br>(<spring:message
                            code="etc.illustrative" text="Illustrative"/>)
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="10" class="form-control form-control-sm" name='sqlstr'
                                  style="font-size: 12px;background-color: white;" readonly><c:out
                                value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:when>

                <c:when test="${exetype eq 'EXTRACT' ||  exetype eq 'FINISH' ||  exetype eq 'TD_UPDATE' || exetype eq 'ETC'}">
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="21" class="form-control form-control-sm" name='sqlstr'
                        ><c:out value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:when>
                <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">

                </c:when>
                <c:otherwise>
                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font style="color:RED">*</font>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;"
                                  spellcheck="false" rows="7" class="form-control form-control-sm" name='sqlstr'
                        ><c:out value="${piisteptable.sqlstr}"/></textarea>
                    </td>
                </c:otherwise>
            </c:choose>
            <c:if test="${exetype ne 'MIGRATE' && exetype ne 'SCRAMBLE'&& exetype ne 'ILM' && exetype ne 'SYNC'}">
        </tr>
        </c:if>

        <c:choose>
            <c:when test="${exetype eq 'SCRAMBLE' }">
                <tr>
                    <th class="th-get"><spring:message code="etc.scramble_columns" text="Scramble columns"/>
                    </th>
                    <td class="td-get-l" colspan=5>
                        <div class="tableWrapper_inner" style="height:195px;width:99.8%">
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
        <select readonly style="background-color: #ffffff; color: #666666;" class="form-control form-control-sm" name="archiveflag">
                <option value="N" <c:if test="${piisteptable.archiveflag eq 'N'}" >selected</c:if> >N</option>
                <option value="Y" <c:if test="${piisteptable.archiveflag eq 'Y'}" >selected</c:if> >Y</option>
        </select>
    </td> --%>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='key_refstr'
           value='<c:out value="${piisteptable.key_refstr}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='archiveflag'
           value='<c:out value="${piisteptable.archiveflag}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='status'
           value='<c:out value="${piisteptable.status}"/>'>
    <%--<input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='succedding'
           value='<c:out value="${piisteptable.succedding}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='preceding'
           value='<c:out value="${piisteptable.preceding}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='pipeline'
           value='<c:out value="${piisteptable.pipeline}"/>'>--%>

    <%--    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='regdate'
               value='<c:out value="${piisteptable.regdate}"/>'>
        <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" class="form-control form-control-sm" name='upddate'
               value='<c:out value="${piisteptable.upddate}"/>'>--%>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='reguserid'
           value='<c:out value="${piisteptable.reguserid}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden"
           class="form-control form-control-sm" name='upduserid'
           value='<sec:authentication property="principal.member.userid"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type="hidden" name="${_csrf.parameterName}"
           value="${_csrf.token}"/>
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
                <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;" spellcheck="false"
                          rows="3" class="form-control form-control-sm" name='reqreason'
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
                <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;" spellcheck="false"
                          rows="3" class="form-control form-control-sm" name='reqreason'
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
                <textarea readonly style="background-color: #ffffff; color: #666666;font-size: 12px;" spellcheck="false"
                          rows="3" class="form-control form-control-sm" name='reqreason'
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
<!--
</div> -->

<input readonly style="background-color: #ffffff; color: #666666;" type='hidden' id='searchtablemode'>
<form style="margin: 0; padding: 0;" role="form" id=searchForm>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='pagenum'
           value='<c:out value="${cri.pagenum}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='amount'
           value='<c:out value="${cri.amount}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search1'
           value='<c:out value="${cri.search1}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search2'
           value='<c:out value="${cri.search2}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search3'
           value='<c:out value="${cri.search3}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search4'
           value='<c:out value="${cri.search4}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search5'
           value='<c:out value="${cri.search5}"/>'>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='search6'
           value='<c:out value="${cri.search6}"/>'>
</form>
<form style="margin: 0; padding: 0;" role="form" id=stepinfoForm>
    <input readonly style="background-color: #ffffff; color: #666666;" type='hidden' name='db'
           value='<c:out value="${piisteptable.db}"/>'>

</form>

<script type="text/javascript">

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $(function () {
            //$("#menupath").html(Menupath +">Details>Modify");
        });

        $('#piisteptable_modify_form [name="sqlstr"]').dblclick(function () {
            //var tx = $(this);
            $("#magnifysqlstr").val($('#piisteptable_modify_form [name="sqlstr"]').val());
            $("#magnifyxlsqlstrmodal").modal("show");

        });
        $('#piisteptable_modify_form [name="wherestr"]').dblclick(function () {
            //var tx = $(this);
            $("#magnifywherestr").val($('#piisteptable_modify_form [name="wherestr"]').val());
            $("#magnifyxlwherestrmodal").modal("show");
        });
    });
</script>

