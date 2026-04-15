<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>
<!-- <div class="card shadow m-1"> -->
<div class="row mt-3 mb-3 ml-1 mr-1 ">
    <div class="col-sm-12">
        <div class="panel panel-default" style="height: 535px;width: 100%">
            <!-- <h1 class="h5 mb-0 m-1">Job</h1> -->
            <div class="panel-body">
                <div class="mt-0 mb-1" style="text-align: right;">
                    <%-- 				<sec:authorize access="hasAnyRole('ROLE_IT')">
                                        <sec:authentication property="principal.member.userid" var="userid"/>
                                        <c:if test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                                                <button data-oper='steptablemodify' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message code="btn.save" text="Save"/></button>
                                        </c:if>
                                    </sec:authorize>
                                    <sec:authorize access="hasRole('ROLE_ADMIN')">
                                            <button data-oper='steptablemodify' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message code="btn.save" text="Save"/></button>
                                    </sec:authorize>	 --%>
                </div>
                <c:set var="exetype" value="${piiordersteptable.exetype}"/>
                <form style="margin: 0; padding: 0;" role="form" id="piisteptable_modify_form">
                    <input type="hidden" class="form-control form-control-sm" name='jobid'
                           value='<c:out value="${piiordersteptable.jobid}"/>'>
                    <input type="hidden" class="form-control form-control-sm" name='version'
                           value='<c:out value="${piiordersteptable.version}"/>'>
                    <input type="hidden" class="form-control form-control-sm" name='stepid'
                           value='<c:out value="${piiordersteptable.stepid}"/>'>
                    <table class="m-0" style="width: 100%">
                        <colgroup>
                            <col style="width: 12%"/>
                            <col style="width: 20%"/>
                            <col style="width: 15%"/>
                            <col style="width: 20%"/>
                            <col style="width: 12%"/>
                            <col style="width: 20%"/>
                        </colgroup>
                        <tbody>

                        <c:choose>
                            <c:when test="${piiordersteptable.exetype eq 'EXTRACT'}">
                                <tr>
                                    <th class="th-get">Type</th>
                                    <td class="td-get-l">
                                        <c:choose>
                                            <c:when test="${piiordersteptable.pagitypedetail eq 'ADD' }"><i
                                                    class="fa fa-plus-circle " style="color:blue"></i> <spring:message
                                                    code="etc.add" text="Add"/></c:when>
                                            <c:when test="${piiordersteptable.pagitypedetail eq 'EXCLUDE' }"><i
                                                    class="fa fa-minus-circle" style="color:red"></i> <spring:message
                                                    code="etc.exclude" text="Exclude"/></c:when>
                                            <c:when test="${piiordersteptable.pagitypedetail eq 'ETC' }"><i
                                                    class="fa fa-circle" style="color:green"></i> <spring:message
                                                    code="etc.etc" text="Etc"/></c:when>
                                            <c:otherwise> <c:out value="${piiordersteptable.pagitypedetail}"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <th class="th-get">Task Name</th>
                                    <td class="td-get-l" colspan=3><input type="hidden"
                                                                          class="form-control form-control-sm"
                                                                          name='pk_col'
                                                                          value='<c:out value="${piiordersteptable.pk_col}"/>'><c:out
                                            value="${piiordersteptable.pk_col}"/></td>
                                </tr>
                            </c:when>
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
                                <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                            name='db'
                                                            value='<c:out value="${piiordersteptable.db}"/>'>
                                    <div id='steptabledb'><c:out value="${piiordersteptable.db}"/></div>
                                </td>

                                <c:choose>
                                    <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE'}">
                                        <th class="th-get">OWNER</th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='owner'
                                                                    value='<c:out value="${piiordersteptable.owner}"/>'>
                                            <div id='steptableowner'><c:out value="${piiordersteptable.owner}"/></div>
                                        </td>
                                        <th class="th-get">
                                            Table
                                        </th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='table_name'
                                                                    value='<c:out value="${piiordersteptable.table_name}"/>'>
                                            <div id='steptable_name'><c:out
                                                    value="${piiordersteptable.table_name}"/></div>
                                        </td>

                                    </c:when>
                                    <c:when test="${exetype eq 'ARCHIVE'}">
                                        <th class="th-get">OWNER</th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='owner'
                                                                    value='<c:out value="${piiordersteptable.owner}"/>'><c:out
                                                value="${piiordersteptable.owner}"/></td>
                                        <th class="th-get">TABLE</th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='table_name'
                                                                    value='<c:out value="${piiordersteptable.table_name}"/>'><c:out
                                                value="${piiordersteptable.table_name}"/></td>

                                    </c:when>
                                    <c:otherwise>
                                        <th class="th-get">OWNER</th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='owner'
                                                                    value='<c:out value="${piiordersteptable.owner}"/>'>
                                            <div id='steptableowner'><c:out value="${piiordersteptable.owner}"/></div>
                                        </td>
                                        <th class="th-get">
                                            Table
                                        </th>
                                        <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                    name='table_name'
                                                                    value='<c:out value="${piiordersteptable.table_name}"/>'>
                                            <div id='steptable_name'><c:out
                                                    value="${piiordersteptable.table_name}"/></div>
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
                                                                value='<c:out value="${piiordersteptable.where_col}"/>'>
                                        <div id='steptableTargetdb'><c:out value="${piiordersteptable.where_col}"/></div>
                                    </td>
                                    <th class="th-get">OWNER</th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm" name='where_key_name'
                                                                value='<c:out value="${piiordersteptable.where_key_name}"/>'>
                                        <div id='steptableTargetowner'><c:out value="${piiordersteptable.where_key_name}"/></div>
                                    </td>
                                    <th class="th-get">
                                        TABLE<%--
                                        <a class="collapse-item" href='javascript:diologSearchTableAction(2);'>
                                            <i class="fas fa-search"></i>
                                        </a>--%>
                                    </th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm" name='sqlstr'
                                                                value='<c:out value="${piiordersteptable.sqlstr}"/>'>
                                        <div id='steptableTargetname'><c:out value="${piiordersteptable.sqlstr}"/></div>
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
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 maxlength='6'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='seq1'
                                                                 value='<c:out value="${piiordersteptable.seq1}"/>'><c:out
                                            value="${piiordersteptable.seq1}"/></td>
                                    <th class="th-get">SEQ</th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='6'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='seq2'
                                                                value='<c:out value="${piiordersteptable.seq2}"/>'><c:out
                                            value="${piiordersteptable.seq2}"/></td>
                                    <th class="th-hidden">SEQ3</th>
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 maxlength='6'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='seq3'
                                                                 value='<c:out value="${piiordersteptable.seq3}"/>'><c:out
                                            value="${piiordersteptable.seq3}"/></td>
                                </c:when>
                                <c:when test="${exetype eq 'KEYMAP'}">

                                    <th class="td-hidden">SEQ1</th>
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 maxlength='6'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='seq1'
                                                                 value='<c:out value="${piiordersteptable.seq1}"/>'><c:out
                                            value="${piiordersteptable.seq1}"/></td>
                                    <th class="th-get">SEQ1</th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='6'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='seq2'
                                                                value='<c:out value="${piiordersteptable.seq2}"/>'><c:out
                                            value="${piiordersteptable.seq2}"/></td>
                                    <th class="th-get">SEQ2</th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='6'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='seq3'
                                                                value='<c:out value="${piiordersteptable.seq3}"/>'><c:out
                                            value="${piiordersteptable.seq3}"/></td>
                                </c:when>
                                <c:otherwise>
                                    <th class="th-hidden">SEQ1</th>
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 maxlength='6'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='seq1'
                                                                 value='<c:out value="${piiordersteptable.seq1}"/>'><c:out
                                            value="${piiordersteptable.seq1}"/></td>
                                    <th class="th-get">SEQ</th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='6'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='seq2'
                                                                value='<c:out value="${piiordersteptable.seq2}"/>'><c:out
                                            value="${piiordersteptable.seq2}"/></td>
                                    <th class="th-hidden">SEQ3</th>
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 maxlength='6'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='seq3'
                                                                 value='<c:out value="${piiordersteptable.seq3}"/>'><c:out
                                            value="${piiordersteptable.seq3}"/></td>

                                    <c:choose>
                                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                                            <th class="th-get"><spring:message code="col.pk_col" text="Pk_Col"/></th>
                                            <td class="" colspan=3><input type="hidden"
                                                                          class="form-control form-control-sm"
                                                                          name='pk_col'
                                                                          value='<c:out value="${piiordersteptable.pk_col}"/>'><c:out
                                                    value="${piiordersteptable.pk_col}"/><c:out
                                                    value="${piiordersteptable.pk_col}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'EXTRACT'}">
                                            <th class="th-get">DB</th>
                                            <td class="td-get-l">
                                                <input type="hidden" class="form-control form-control-sm"
                                                       name='db'
                                                       value='<c:out value="${piiordersteptable.db}"/>'>
                                                <input type="hidden" class="form-control form-control-sm" name='owner'
                                                       value='<c:out value="${piiordersteptable.owner}"/>'>
                                                <input type="hidden" class="form-control form-control-sm"
                                                       name='table_name'
                                                       value='<c:out value="${piiordersteptable.table_name}"/>'>
                                                <div id='steptabledb'><c:out
                                                        value="${piiordersteptable.db}"/></div>
                                            </td>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="hidden" class="form-control form-control-sm" name='pk_col'
                                                   value='<c:out value="${piiordersteptable.pk_col}"/>'>
                                        </c:otherwise>
                                    </c:choose>

                                </c:otherwise>
                            </c:choose>
                        </tr>
                        <tr>
                            <th class="th-get">Status</th>
                            <td class="td-get-l">
                                <%-- <select style="height:27px;"  class="form-control form-control-sm" name="status" >

                                    <option value="Wait condition" <c:if test="${piiordersteptable.status eq 'Wait condition'}" >selected</c:if> >Wait</option>
                                    <option value="Ended OK" <c:if test="${piiordersteptable.status eq 'Ended OK'}" >selected</c:if> >Ended OK</option>
                                    <option value="Ended not OK" <c:if test="${piiordersteptable.status eq 'Ended not OK'}" >selected</c:if> >Error</option>
                                    <option value="Running" <c:if test="${piiordersteptable.status eq 'Running'}" >selected</c:if> >Running</option>
                                    <option value="Recovered" <c:if test="${piiordersteptable.status eq 'Recovered'}" >selected</c:if> >Recovered</option>
                                    <option value="Hold" <c:if test="${pageMaker.cri.search4 eq 'Hold'}" >selected</c:if> >Hold</option>
                                </select> --%>
                                <c:choose>
                                    <c:when test="${piiordersteptable.status eq 'Ended OK' }"><span
                                            style="font-size: 12px;" class="badge badge-success"><c:out
                                            value="${piiordersteptable.status}"/></span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Ended not OK' }"><span
                                            style="font-size: 12px;" class="badge badge-danger">Error</span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Running' }"><span
                                            style="font-size: 12px;" class="badge badge-primary"><i
                                            class="fa fa-spinner fa-spin"></i> <c:out
                                            value="${piiordersteptable.status}"/></span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Wait condition' }"><span
                                            style="font-size: 12px;" class="badge badge-secondary">Wait</span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Recovered' }"><span
                                            style="font-size: 12px;" class="badge badge-warning"><c:out
                                            value="${piiordersteptable.status}"/></span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Hold' }"><span style="font-size: 11px;"
                                                                                                class="badge badge-warning"><c:out
                                            value="${piiordersteptable.status}"/></span></c:when>
                                    <c:otherwise><span class="badge badge-light"><c:out
                                            value="${piiorder.status}"/></span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <c:choose>
                                <c:when test="${exetype eq 'ARCHIVE'}">
                                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                name='exetype'
                                                                value='<c:out value="${piiordersteptable.exetype}"/>'><c:out
                                            value="${piiordersteptable.exetype}"/></td>
                                    <th class="th-get"><spring:message code="col.arc_del_m"
                                                                       text="Arc_Del_Deadline"/></th>
                                    <td class="td-get-l">
                                        <c:choose>
                                            <c:when test="${piiordersteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                                    code="etc.backdated" text="Backdated"/></c:when>
                                            <c:otherwise> <c:out value="${piiordersteptable.pagitypedetail}"/>
                                            </c:otherwise>
                                        </c:choose>
                                        <input type="hidden" class="form-control form-control-sm" name='pagitypedetail'
                                               value='<c:out value="${piiordersteptable.pagitypedetail}"/>'>
                                    </td>
                                </c:when>
                                <c:otherwise>
                                    <th class="th-get"><spring:message code="col.exetype" text="Exetype"/></th>
                                    <td class="td-get-l"><c:out value="${piiordersteptable.exetype}"/><input
                                            type="hidden" class="form-control form-control-sm" name='exetype'
                                            value='<c:out value="${piiordersteptable.exetype}"/>'>
                                    </td>
                                    <c:choose>

                                        <c:when test="${exetype eq 'KEYMAP'}">
                                            <th class="th-get"><spring:message code="etc.keyname_desc"
                                                                               text="Key Desc"/></th>
                                            <td class="td-get-l" colspan=3><input type="hidden"
                                                                                  class="form-control form-control-sm"
                                                                                  name='pk_col'
                                                                                  value='<c:out value="${piiordersteptable.pk_col}"/>'><c:out
                                                    value="${piiordersteptable.pk_col}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}">
                                            <th class="th-get"><spring:message code="col.arc_del_m"
                                                                               text="Arc_Del_Deadline"/></th>
                                            <td class="td-get-l">
                                                <c:choose>
                                                    <c:when test="${piiordersteptable.pagitypedetail eq 'BACKDATED' }"><spring:message
                                                            code="etc.backdated" text="Backdated"/></c:when>
                                                    <c:otherwise> <c:out value="${piiordersteptable.pagitypedetail}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                                <input type="hidden" class="form-control form-control-sm"
                                                       name='pagitypedetail'
                                                       value='<c:out value="${piiordersteptable.pagitypedetail}"/>'>
                                            </td>
                                        </c:when>
                                        <c:when test="${exetype eq 'HOMECAST'}">
                                            <th class="th-get"><spring:message code="col.commitcnt"
                                                                               text="Commitcnt"/></th>
                                            <td class="td-get-l"><input type="hidden"
                                                                        class="form-control form-control-sm"
                                                                        maxlength='8'
                                                                        onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                        name='commitcnt'
                                                                        value='<c:out value="${piiordersteptable.commitcnt}"/>'><c:out
                                                    value="${piiordersteptable.commitcnt}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'SCRAMBLE' or exetype eq 'MIGRATE'}">
                                        <th class="th-get">/*+ Hint */</th>
                                        <td class="td-get-l" COLSPAN="3">
                                            <input type="text" class="form-control  form-control-sm small-text" style="background-color: WHITE;" readonly
                                                   name='hintselect'
                                                   value='<c:out value="${piiordersteptable.hintselect}"/>'>
                                        </td>
                                        </c:when>
                                        <c:otherwise>
                                        </c:otherwise>
                                    </c:choose>

                                    <c:if test="${exetype ne 'SCRAMBLE'}">
                                    <th class="th-hidden"><spring:message code="col.pagitype" text="Pagitype"/></th>
                                    <td class="td-hidden"><input type="hidden" class="form-control form-control-sm"
                                                                 name='pagitype'
                                                                 value='<c:out value="${piiordersteptable.pagitype}"/>'>
                                    </td>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>

                        </tr>

                        <c:choose>
                            <c:when test="${piiordersteptable.exetype eq 'KEYMAP' || piiordersteptable.exetype eq 'ARCHIVE' || piiordersteptable.exetype eq 'FINISH' || piiordersteptable.exetype eq 'TD_UPDATE' || piiordersteptable.exetype eq 'EXTRACT'|| piiordersteptable.exetype eq 'BROADCAST' || exetype eq 'HOMECAST' }">
                                <!-- <th class="th-get" rowspan=3 ></th>
                                <th class="th-get" rowspan=3 ></th> -->
                            </c:when>
                            <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'MIGRATE' || exetype eq 'ILM' || exetype eq 'SYNC'}">
                                <tr>
                                    <th class="th-hidden"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                                    <td class="td-hidden"><input type="text" class="form-control form-control-sm" maxlength='3'
                                                                 onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                 name='parallelcnt' value='<c:out value="${piiordersteptable.parallelcnt}"/>'>
                                    </td>
                                    <c:choose>
                                        <c:when test="${exetype eq 'SCRAMBLE' and fn:startsWith(piiordersteptable.jobid, 'TESTDATA_AUTO_GEN')}">
                                            <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/></th>
                                            <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" id="where_col_scr"
                                                                                  name='where_col'
                                                                                  value='<c:out value="${piiordersteptable.where_col}"/>'
                                                                                  style="background-color: WHITE;" readonly></td>

                                            <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/></th>
                                            <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" id="where_key_name_scr"
                                                                                  name='where_key_name'
                                                                                  value='<c:out value="${piiordersteptable.where_key_name}"/>'
                                                                                  style="background-color: WHITE;" readonly></td>
                                        </c:when>
                                    </c:choose>
                                    <th class="th-get"><spring:message code="col.handlecnt"
                                                                       text="Data Processing Unit"/></th>
                                    <td class="td-get-l"><input type="text" class="form-control form-control-sm" maxlength='8'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                                                value='<c:out value="${piiordersteptable.commitcnt}"/>'></td>
                                </tr>
                            </c:when>
                            <c:when test="${piiordersteptable.exetype eq 'UPDATE' || (piiordersteptable.exetype eq 'RECOVERY' && piiordersteptable.pagitypedetail eq 'RECOVERY_U')}">
                                <tr>
                                    <th class="th-get"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='3'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='parallelcnt'
                                                                value='<c:out value="${piiordersteptable.parallelcnt}"/>'><c:out
                                            value="${piiordersteptable.parallelcnt}"/></td>
                                    <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='8'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='commitcnt'
                                                                value='<c:out value="${piiordersteptable.commitcnt}"/>'><c:out
                                            value="${piiordersteptable.commitcnt}"/></td>

                                    <th class="th-get" rowspan=3>
                                        <spring:message code="etc.updatecols" text="Update cols"/>
                                        <%--<a class="collapse-item" href='javascript:diologStepTableUpdateAction();'>
                                            <i class="fas fa-edit"></i>
                                        </a>--%>
                                    </th>
                                    <td class="" rowspan=3>
                                        <div class="m-0 p-0">
                                            <table style="border: none; width:100%">
                                                <tbody id="steptableupdatemodify"
                                                       style="display:block;height:90px; width:100%;overflow:auto;">
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
                                        </div>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <th class="th-get"><spring:message code="col.parallelcnt" text="Parallelcnt"/></th>
                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='3'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='parallelcnt'
                                                                value='<c:out value="${piiordersteptable.parallelcnt}"/>'><c:out
                                            value="${piiordersteptable.parallelcnt}"/></td>


                                    <td class="td-get-l"><input type="hidden" class="form-control form-control-sm"
                                                                maxlength='8'
                                                                onKeyup="this.value=this.value.replace(/[^0-9]/g,'');"
                                                                name='commitcnt'
                                                                value='<c:out value="${piiordersteptable.commitcnt}"/>'><c:out
                                            value="${piiordersteptable.commitcnt}"/></td>
                                    <c:if test="${exetype ne 'SCRAMBLE'}">
                                    <th class="th-get" rowspan=3>
                                        <spring:message code="etc.table_wait" text="Waiting table"/>
                                    </th>
                                    <td class="" rowspan=3>

                                        <div class="m-0 p-0">
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
                                        </div>

                                    </td>
                                    </c:if>
                                </tr>
                            </c:otherwise>
                        </c:choose>

                        <c:choose>
                            <c:when test="${exetype eq 'FINISH' || exetype eq 'TD_UPDATE' || exetype eq 'BROADCAST' || exetype eq 'HOMECAST' || exetype eq 'EXTRACT' }">
                                <input type="hidden" class="form-control form-control-sm" name='where_col'
                                       value='<c:out value="${piiordersteptable.where_col}"/>'>
                                <input type="hidden" class="form-control form-control-sm" name='where_key_name'
                                       value='<c:out value="${piiordersteptable.where_key_name}"/>'>
                            </c:when>

                            <c:when test="${exetype eq 'SCRAMBLE'  }">
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                                   text="Processing_Method"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get"
                                        COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piiordersteptable.processing_method}" />'>--%>
                                        <select class="form-control form-control-sm" name="succedding" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.succedding eq ''}">selected</c:if> >
                                            </option>
                                            <option value="TMP_TABLE"
                                                    <c:if test="${piiordersteptable.succedding eq 'TMP_TABLE'}">selected</c:if> >
                                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                            </option>
                                                <%--<option value="SQLLDR"
                                                        <c:if test="${piiordersteptable.succedding eq 'SQLLDR'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                                </option>
                                                <option value="PARTITION"
                                                        <c:if test="${piiordersteptable.succedding eq 'PARTITION'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                                </option>
                                                <option value="DIRECT_SQL"
                                                        <c:if test="${piiordersteptable.succedding eq 'DIRECT_SQL'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                                </option>--%>
                                        </select>
                                    </td>
                                    <th class="th-get"><spring:message code="etc.hashcol" text="Distribution Key"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly style="background-color: #ffffff; color: #666666;"
                                                                          name='pk_col' style="font-size:12px;"
                                                                          value='<c:out value="${piiordersteptable.pk_col}"/>'></td>
                                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="pipeline" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pipeline eq ''}">selected</c:if> >
                                            </option>
                                            <option value="1" <c:if test="${piiordersteptable.pipeline eq '1'}">selected</c:if>>1</option>
                                            <option value="2" <c:if test="${piiordersteptable.pipeline eq '2'}">selected</c:if>>2</option>
                                            <option value="3" <c:if test="${piiordersteptable.pipeline eq '3'}">selected</c:if>>3</option>
                                            <option value="4" <c:if test="${piiordersteptable.pipeline eq '4'}">selected</c:if>>4</option>
                                            <option value="5" <c:if test="${piiordersteptable.pipeline eq '5'}">selected</c:if>>5</option>
                                            <option value="6" <c:if test="${piiordersteptable.pipeline eq '6'}">selected</c:if>>6</option>
                                            <option value="7" <c:if test="${piiordersteptable.pipeline eq '7'}">selected</c:if>>7</option>
                                            <option value="8" <c:if test="${piiordersteptable.pipeline eq '8'}">selected</c:if>>8</option>
                                            <option value="9" <c:if test="${piiordersteptable.pipeline eq '9'}">selected</c:if>>9</option>
                                            <option value="10" <c:if test="${piiordersteptable.pipeline eq '10'}">selected</c:if>>10</option>
                                            <option value="11" <c:if test="${piiordersteptable.pipeline eq '11'}">selected</c:if>>11</option>
                                            <option value="12" <c:if test="${piiordersteptable.pipeline eq '12'}">selected</c:if>>12</option>
                                            <option value="13" <c:if test="${piiordersteptable.pipeline eq '13'}">selected</c:if>>13</option>
                                            <option value="14" <c:if test="${piiordersteptable.pipeline eq '14'}">selected</c:if>>14</option>
                                            <option value="15" <c:if test="${piiordersteptable.pipeline eq '15'}">selected</c:if>>15</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.data_handling_method"
                                                                                   text="Data_Handling_Method"/><font
                                        style="color:blue">*</font></th>
                                    <td class="td-get" COLSPAN="1">
                                        <select class="form-control form-control-sm" name="preceding" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.preceding eq ''}">selected</c:if> >
                                            </option>
                                            <option value="INSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method3" text="INSERT" />
                                            </option>
                                            <option value="REPLACEINSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                            </option>
                                            <option value="DELDUPINSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                            </option>
                                            <option value="TRUNCSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'TRUNCSERT'}">selected</c:if> >
                                                <spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                            </option>
                                        </select>
                                    </td>
                                    <th class="th-get">Trunc partition</th>
                                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                                          style="background-color: #ffffff; color: #666666;"
                                                                          name='uval1' style="font-size:12px;"
                                                                          value='<c:out value="${piiordersteptable.uval1}"/>'></td>

                                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="pagitypedetail" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pagitypedetail eq ''}">selected</c:if> >
                                            </option>
                                            <option value="Y"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'Y'}">selected</c:if> >Y
                                            </option>
                                            <option value="N"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'N'}">selected</c:if> >N
                                            </option>
                                            <%--<option value="YN"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'YN'}">selected</c:if> >YN
                                            </option>--%>
                                        </select>
                                    </td>
                                    <th class="th-hidden"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-hidden">
                                        <select class="form-control form-control-sm" name="pagitype" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pagitype eq ''}">selected</c:if> >
                                            </option>
                                            <option value="Y"
                                                    <c:if test="${piiordersteptable.pagitype eq 'Y'}">selected</c:if> >Y
                                            </option>
                                            <option value="N"
                                                    <c:if test="${piiordersteptable.pagitype eq 'N'}">selected</c:if> >N
                                            </option>
                                        </select>
                                    </td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'SYNC' }">
                            </c:when>
                            <c:when test="${exetype eq 'ILM' ||  exetype eq 'MIGRATE' }">
                                <tr>
                                    <th scope="row" class="th-get"><spring:message code="col.processing_method"
                                                                                   text="Processing_Method"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get"
                                        COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piiordersteptable.processing_method}" />'>--%>
                                        <select class="form-control form-control-sm" name="succedding" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.succedding eq ''}">selected</c:if> >
                                            </option>
                                            <option value="TMP_TABLE"
                                                    <c:if test="${piiordersteptable.succedding eq 'TMP_TABLE'}">selected</c:if> >
                                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                            </option>
                                                <%--<option value="SQLLDR"
                                                        <c:if test="${piiordersteptable.succedding eq 'SQLLDR'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                                </option>
                                                <option value="PARTITION"
                                                        <c:if test="${piiordersteptable.succedding eq 'PARTITION'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                                </option>
                                                <option value="DIRECT_SQL"
                                                        <c:if test="${piiordersteptable.succedding eq 'DIRECT_SQL'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                                </option>--%>
                                        </select>
                                    </td>
                                    <th class="th-get"><spring:message code="etc.hashcol" text="Distribution Key"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly style="background-color: #ffffff; color: #666666;"
                                                                          name='pk_col' style="font-size:12px;"
                                                                          value='<c:out value="${piiordersteptable.pk_col}"/>'></td>
                                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="pipeline" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pipeline eq ''}">selected</c:if> >
                                            </option>
                                            <option value="1" <c:if test="${piiordersteptable.pipeline eq '1'}">selected</c:if>>1</option>
                                            <option value="2" <c:if test="${piiordersteptable.pipeline eq '2'}">selected</c:if>>2</option>
                                            <option value="3" <c:if test="${piiordersteptable.pipeline eq '3'}">selected</c:if>>3</option>
                                            <option value="4" <c:if test="${piiordersteptable.pipeline eq '4'}">selected</c:if>>4</option>
                                            <option value="5" <c:if test="${piiordersteptable.pipeline eq '5'}">selected</c:if>>5</option>
                                            <option value="6" <c:if test="${piiordersteptable.pipeline eq '6'}">selected</c:if>>6</option>
                                            <option value="7" <c:if test="${piiordersteptable.pipeline eq '7'}">selected</c:if>>7</option>
                                            <option value="8" <c:if test="${piiordersteptable.pipeline eq '8'}">selected</c:if>>8</option>
                                            <option value="9" <c:if test="${piiordersteptable.pipeline eq '9'}">selected</c:if>>9</option>
                                            <option value="10" <c:if test="${piiordersteptable.pipeline eq '10'}">selected</c:if>>10</option>
                                            <option value="11" <c:if test="${piiordersteptable.pipeline eq '11'}">selected</c:if>>11</option>
                                            <option value="12" <c:if test="${piiordersteptable.pipeline eq '12'}">selected</c:if>>12</option>
                                            <option value="13" <c:if test="${piiordersteptable.pipeline eq '13'}">selected</c:if>>13</option>
                                            <option value="14" <c:if test="${piiordersteptable.pipeline eq '14'}">selected</c:if>>14</option>
                                            <option value="15" <c:if test="${piiordersteptable.pipeline eq '15'}">selected</c:if>>15</option>
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
                                        <select class="form-control form-control-sm" name="preceding" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.preceding eq ''}">selected</c:if> >
                                            </option>
                                            <option value="INSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method3" text="INSERT" />
                                            </option>
                                            <option value="REPLACEINSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                            </option>
                                            <option value="DELDUPINSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                            </option>
                                            <option value="TRUNCSERT"
                                                    <c:if test="${piiordersteptable.preceding eq 'TRUNCSERT'}">selected</c:if> >
                                                     <spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                            </option>
                                        </select>
                                    </td>
                                    </c:when>
                                    <c:when test="${exetype eq 'MIGRATE' || exetype eq 'SYNC' }">
                                        <th scope="row" class="th-get"><spring:message code="col.data_handling_method"
                                                                                       text="Data_Handling_Method"/><font
                                                style="color:blue">*</font></th>
                                        <td class="td-get" COLSPAN="1">
                                            <select class="form-control form-control-sm" name="preceding">
                                                <option value=""
                                                        <c:if test="${piiordersteptable.preceding eq ''}">selected</c:if> >
                                                </option>
                                                <option value="INSERT"
                                                        <c:if test="${piiordersteptable.preceding eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method4" text="Insert" />
                                                </option>
                                                <option value="REPLACEINSERT"
                                                        <c:if test="${piiordersteptable.preceding eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                                </option>
                                                <option value="DELDUPINSERT"
                                                        <c:if test="${piiordersteptable.preceding eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                                </option>
                                                <option value="TRUNCSERT"
                                                        <c:if test="${piiordersteptable.preceding eq 'TRUNCSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                                </option>
                                            </select>
                                        </td>
                                        <th class="th-get">Trunc partition</th>
                                        <td class="td-get-l" colspan=1><input type="text" class="form-control form-control-sm" readonly
                                                                              style="background-color: #ffffff; color: #666666;"
                                                                              name='uval1' style="font-size:12px;"
                                                                              value='<c:out value="${piiordersteptable.uval1}"/>'></td>
                                    </c:when>
                                </c:choose>
                                    <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="pagitypedetail" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pagitypedetail eq ''}">selected</c:if> >
                                            </option>
                                            <option value="Y"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'Y'}">selected</c:if> >Y
                                            </option>
                                            <option value="N"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'N'}">selected</c:if> >N
                                            </option>
                                            <%--<option value="YN"
                                                    <c:if test="${piiordersteptable.pagitypedetail eq 'YN'}">selected</c:if> >YN
                                            </option>--%>
                                        </select>
                                    </td>
                                    <th class="th-get-hidden"><spring:message code="etc.target_tab_distribute" text="Target distributed"/><font
                                            style="color:blue">*</font></th>
                                    <td class="td-get-hidden">
                                        <select class="form-control form-control-sm" name="pagitype" readonly style="background-color: #ffffff; color: #666666;">
                                            <option value=""
                                                    <c:if test="${piiordersteptable.pagitype eq ''}">selected</c:if> >
                                            </option>
                                            <option value="Y"
                                                    <c:if test="${piiordersteptable.pagitype eq 'Y'}">selected</c:if> >Y
                                            </option>
                                            <option value="N"
                                                    <c:if test="${piiordersteptable.pagitype eq 'N'}">selected</c:if> >N
                                            </option>
                                        </select>
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <th class="th-get"><spring:message code="col.where_col" text="Where_Col"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=3><c:out value="${piiordersteptable.where_col}"/></td>
                                </tr>
                                <tr>
                                    <th class="th-get"><spring:message code="col.where_key_name" text="Where_key_name"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=3><c:out
                                            value="${piiordersteptable.where_key_name}"/></td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        <c:choose>
                            <c:when test="${exetype eq 'KEYMAP' }">
                                <tr>
                                    <th class="th-get"><spring:message code="etc.selectstr" text="Selectstr"/><br>(<spring:message
                                            code="etc.illustrative" text="Illustrative"/>)</th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="8" class="form-control form-control-sm"
                                                  name='wherestr'
                                                  style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.wherestr}"/></textarea>
                                    </td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'ARCHIVE' }">
                                <tr>
                                    <th class="th-get"><spring:message code="etc.selectstr" text="Selectstr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="7" class="form-control form-control-sm"
                                                  name='wherestr'
                                                  style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.wherestr}"/></textarea>
                                    </td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'BROADCAST' }">
                                <tr>
                                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="8" class="form-control form-control-sm"
                                                  name='wherestr'
                                                  style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.wherestr}"/></textarea>
                                    </td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                                <tr>
                                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                                    <td class="td-get-l" colspan=5><textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="13"
                                                                             class="form-control form-control-sm"
                                                                             name='wherestr'
                                                                             style="font-size: 12px;background-color: white;"><c:out
                                            value="${piiordersteptable.wherestr}"/></textarea></td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'HOMECAST'}">
                                <tr>
                                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                                    <td class="td-get-l" colspan=5><textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="8"
                                                                             class="form-control form-control-sm"
                                                                             name='wherestr'
                                                                             style="font-size: 12px;background-color: white;"><c:out
                                            value="${piiordersteptable.wherestr}"/></textarea></td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'SCRAMBLE'}">
                                <tr>
                                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/></th>
                                    <td class="td-get-l" colspan=5><textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="7"
                                                                             class="form-control form-control-sm"
                                                                             name='wherestr'
                                                                             style="font-size: 12px;background-color: white;"><c:out
                                            value="${piiordersteptable.wherestr}"/></textarea></td>
                                </tr>
                            </c:when>
                            <c:when test="${exetype eq 'FINISH' || exetype eq 'TD_UPDATE' || exetype eq 'EXTRACT' }">
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <th class="th-get"><spring:message code="col.wherestr" text="Wherestr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="6" class="form-control form-control-sm"
                                                  name='wherestr'
                                                  style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.wherestr}"/></textarea>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>

                            <c:choose>
                                <c:when test="${exetype eq 'DELETE' || exetype eq 'UPDATE' || exetype eq 'ARCHIVE'}"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr"
                                                                       text="Sqlstr"/><br>(<spring:message
                                            code="etc.illustrative" text="Illustrative"/>)
                                    </th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="9" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'KEYMAP' }"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr"
                                                                       text="Sqlstr"/><font
                                            style="color:RED">*</font></th>
                                    </th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="8" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'ARCHIVE'}"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr"
                                                                       text="Sqlstr"/><br>(<spring:message
                                            code="etc.illustrative" text="Illustrative"/>)
                                    </th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="11" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'BROADCAST' || exetype eq 'HOMECAST'}"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr"
                                                                       text="Sqlstr"/><br>(<spring:message
                                            code="etc.illustrative" text="Illustrative"/>)
                                    </th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea  style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="11" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'EXTRACT'}"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea  style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="19" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'FINISH'}"><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea  style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="19" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:when>
                                <c:when test="${exetype eq 'SCRAMBLE' || exetype eq 'ILM' || exetype eq 'MIGRATE' || exetype eq 'SYNC'}">
                                </c:when>
                                <c:otherwise><tr>
                                    <th class="th-get"><spring:message code="col.sqlstr" text="Sqlstr"/><font
                                            style="color:RED">*</font></th>
                                    <td class="td-get-l" colspan=5>
                                        <textarea  style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="8" class="form-control form-control-sm"
                                                  name='sqlstr' style="font-size: 12px;background-color: white;"><c:out
                                                value="${piiordersteptable.sqlstr}"/></textarea>
                                    </td></tr>
                                </c:otherwise>

                            </c:choose>
                        <c:choose>
                            <c:when test="${exetype eq 'SCRAMBLE' }">
                                <tr>
                                    <th class="th-get"><spring:message code="etc.scramble_columns" text="Scramble columns"/>
                                    </th>
                                    <td class="td-get-l" colspan=5>
                                        <div class="tableWrapper_inner" style="height:160px;width:99.8%">
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
                        <select class="form-control form-control-sm" name="archiveflag">
                                <option value="N" <c:if test="${piiordersteptable.archiveflag eq 'N'}" >selected</c:if> >N</option>
                                <option value="Y" <c:if test="${piiordersteptable.archiveflag eq 'Y'}" >selected</c:if> >Y</option>
                        </select>
                    </td> --%>
                    <input type="hidden" class="form-control form-control-sm" name='orderid'
                           value='<c:out value="${piiordersteptable.orderid}"/>'>
                    <input type="hidden" class="form-control form-control-sm" name='succedding'
                           value='<c:out value="${piiordersteptable.succedding}"/>'>
                    <input type="hidden" class="form-control form-control-sm" name='preceding'
                           value='<c:out value="${piiordersteptable.preceding}"/>'>
                    <%--<input type="hidden" class="form-control form-control-sm" name='pipeline'
                           value='<c:out value="${piiordersteptable.pipeline}"/>'>--%>


                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>

            </div>
            <!--  end panel-body -->
        </div>
        <!--  panel panel-default-->
    </div>

    <!-- col-lg-12 -->
    <!-- The Modal -->
    <div class="modal fade" id="modalxl" role="dialog" style="z-index:1051;">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">

                <!-- Modal Header -->
                <div class="modal-header modal-wizard">
                    <h4 class="modal-title modal-title-unified">
                        <i class="fa-solid fa-wand-sparkles fa-lg mr-3" style="animation: sparkle 1.5s infinite alternate;"></i>
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
                    <textarea readonly style="background-color: #ffffff; color: #666666;" spellcheck="false" rows="3" class="form-control form-control-sm" name='reqreason'
                              id='reqreason'></textarea>
                </div>
                <!-- Modal footer -->
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button"
                            id="dialogsteptablewaitlistclose" data-dismiss="modal">Close
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
                </div>
                <!-- Modal footer -->
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button"
                            id="dialogsearchtablelistclose" data-dismiss="modal">Close
                    </button>
                </div>

            </div>
        </div>
    </div>
    <!-- The Modal end-->

</div>

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
    <input type='hidden' name='db' value='<c:out value="${piistep.db}"/>'>

</form>

<script type="text/javascript">

    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $(function () {
            //$("#menupath").html(Menupath +">Details>Modify");
        });
        $("button[data-oper='steptablemodify']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            /* if ($('#piisteptable_modify_form [name="exetype"]').val()=="KEYMAP" && isEmpty($('#piisteptable_modify_form [name="keymap_id"]').val())){alert('
            <spring:message code="col.keymap_id" text="Keymap_Id"/> is mandatory');$('#piisteptable_modify_form [name="keymap_id"]').focus();return;}
			if ($('#piisteptable_modify_form [name="exetype"]').val()=="KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_name"]').val())){alert('
            <spring:message code="col.key_name" text="Key_Name"/> is mandatory');$('#piisteptable_modify_form [name="key_name"]').focus();return;}
			if ($('#piisteptable_modify_form [name="exetype"]').val()=="KEYMAP" && isEmpty($('#piisteptable_modify_form [name="key_cols"]').val())){alert('
            <spring:message code="col.key_cols" text="Key_Cols"/> is mandatory');$('#piisteptable_modify_form [name="key_cols"]').focus();return;}
			 */
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
            if (isEmpty($('#piisteptable_modify_form [name="sqlstr"]').val())) {
                dlmAlert('<spring:message code="col.sqlstr" text="Sqlstr"/> is mandatory');
                $('#piisteptable_modify_form [name="sqlstr"]').focus();
                return;
            }
            if ($('#piisteptable_modify_form [name="exetype"]').val() == "DELETE" && isEmpty($('#piisteptable_modify_form [name="where_key_name"]').val())) {
                dlmAlert('<spring:message code="col.where_key_name" text="Where_Key_Name"/> is mandatory');
                $('#piisteptable_modify_form [name="where_key_name"]').focus();
                return;
            }

            var formSerializeArray = $('#piisteptable_modify_form').serializeArray();
            var object = {};
            for (var i = 0; i < formSerializeArray.length; i++) {
                object[formSerializeArray[i]['name']] = formSerializeArray[i]['value'];
            }

            ingShow(); $.ajax({
                type: "POST",
                url: "/piiorder/getordertable",
                dataType: "text",
                data: JSON.stringify(object),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) { ingHide();

                    showToast("처리가 완료되었습니다.", false);
                }
            });
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

            ingShow(); $.ajax({
                type: "POST",
                url: "/piiordersteptable/remove",
                dataType: "text",
                data: JSON.stringify(object),
                contentType: "application/json; charset=UTF-8",
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) { ingHide();
                    $("#" + stepid).trigger("click");
                    showToast("처리가 완료되었습니다.", false);
                    //loadAction();
                }
            });

        });

        $("button[data-oper='getordertable']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var jobid = $('#piisteptable_modify_form [name=orderid]').val();
            var stepid = $('#piisteptable_modify_form [name=stepid]').val();
            var seq1 = $('#piisteptable_modify_form [name=seq1]').val();
            var seq2 = $('#piisteptable_modify_form [name=seq2]').val();
            var seq3 = $('#piisteptable_modify_form [name=seq3]').val();

            var url_search = "";
            var url_view = "getordertable?"
                + "orderid		=" + orderid + "&"
                + "stepid=" + stepid + "&"
                + "seq1	=" + seq1 + "&"
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
            // alert("/piiordersteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            ingShow(); $.ajax({
                type: "GET",
                url: "/piiorder/" + url_view
                    + "pagenum=" + pagenum
                    + "&amount=" + amount
                    + url_search,
                dataType: "html",
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) { ingHide();
                    $('#modalxlbdoy').html(data);
                    $("#modalxl").modal();
                }
            });

        });

    });

    diologStepTableWaitAction = function () {

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

        //alert("/piiordersteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piiordersteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#dialogsteptablewaitlistbody').html(data);
                $("#dialogsteptablewaitlist").modal();

            }
        });
    }

    diologSearchTableAction = function () {
        //e.preventDefault();e.stopPropagation();

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
        var search4 = $('#piisteptable_modify_form [name=db]').val();
        var search5 = $('#piisteptable_modify_form [name=owner]').val();
        var search6 = $('#piisteptable_modify_form [name=table_name]').val();
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
        ingShow(); $.ajax({
            type: "GET",
            url: "/piiordersteptable/" + url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert('success1');
                $('#dialogsearchtablelistbody').html(data);
                $("#dialogsearchtablelist").modal();

            }
        });
    }

    $("button[data-oper='wizard_steptable']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var seq3 = $('#piisteptable_modify_form [name="seq3"]').val();
        if (seq3 == "999") {
            var db = $('#piisteptable_modify_form [name="db"]').val();
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
        //alert($('#piisteptable_modify_form [name=db]').val());
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
                $('#modalxlbdoy').html(data);
                $("#modalxl").modal();
            }
        });

    });


</script>

