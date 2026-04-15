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
            <div class="step-item">
                <div id="modifystepresult" class="ml-1"></div>
            </div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item"></div>
            <div class="step-item" style="text-align: right;">

                <sec:authorize access="isAuthenticated()">
                    <button data-oper='modify-step-dialog' class="btn btn-action-save btn-action-sm">
                        <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/></button>
                    <button data-oper='remove-step-dialog' class="btn btn-action-remove btn-action-sm">
                        <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Remove"/></button>
                </sec:authorize>

            </div>
        </div>

    </div>
    <!-- <div class="card-header  m-1 p-0 width:100%;height:75px;"> -->

    <c:set var="exetype" value="${piistep.steptype}"/>
    <div class="row m-0">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <!-- <h1 class="h5 mb-0 m-1">Job</h1> -->
                <div class="panel-body p-1">
                    <form style="margin: 0; padding: 0;" role="form" id="piistep_modify_form">
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
                                <td class="td-get-l" colspan=5><c:out value="${piistep.stepid}"/><input type="hidden"
                                                                                                        class="form-control form-control-sm"
                                                                                                        name='stepid'
                                                                                                        value='<c:out value="${piistep.stepid}"/>'>
                                </td>
                            </tr>
                            <tr>
                                <th class="th-get">STEPNAME</th>
                                <td class="td-get" colspan=3><input type="text" class="form-control form-control-sm"
                                                                    name='stepname'
                                                                    value='<c:out value="${piistep.stepname}"/>'>
                                </td>
                                <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                                <td class="td-get">
                                    <select class="form-control form-control-sm" name="status">
                                        <option value="ACTIVE"
                                                <c:if test="${piistep.status eq 'ACTIVE'}">selected</c:if> >ACTIVE
                                        </option>
                                        <option value="INACTIVE"
                                                <c:if test="${piistep.status eq 'INACTIVE'}">selected</c:if> >INACTIVE
                                        </option>
                                        <option value="HOLD"
                                                <c:if test="${piistep.status eq 'HOLD'}">selected</c:if> >HOLD
                                        </option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th class="th-get">STEPTYPE</th>
                                <td class="td-get">
                                    <select class="form-control form-control-sm" name="steptype" id="modify_steptype" readonly >
                                        <option value="EXE_EXTRACT"
                                                <c:if test="${piistep.steptype eq 'EXE_EXTRACT'}">selected</c:if> >
                                            EXE_EXTRACT
                                        </option>
                                        <option value="GEN_KEYMAP"
                                                <c:if test="${piistep.steptype eq 'GEN_KEYMAP'}">selected</c:if> >
                                            GEN_KEYMAP
                                        </option>
                                        <option value="EXE_ARCHIVE"
                                                <c:if test="${piistep.steptype eq 'EXE_ARCHIVE'}">selected</c:if> >
                                            EXE_ARCHIVE
                                        </option>
                                        <option value="EXE_DELETE"
                                                <c:if test="${piistep.steptype eq 'EXE_DELETE'}">selected</c:if> >
                                            EXE_DELETE
                                        </option>
                                        <option value="EXE_UPDATE"
                                                <c:if test="${piistep.steptype eq 'EXE_UPDATE'}">selected</c:if> >
                                            EXE_UPDATE
                                        </option>
                                        <option value="EXE_BROADCAST"
                                                <c:if test="${piistep.steptype eq 'EXE_BROADCAST'}">selected</c:if> >
                                            EXE_BROADCAST
                                        </option>
                                        <option value="EXE_HOMECAST"
                                                <c:if test="${piistep.steptype eq 'EXE_HOMECAST'}">selected</c:if> >
                                            EXE_HOMECAST
                                        </option>
                                        <option value="EXE_FINISH"
                                                <c:if test="${piistep.steptype eq 'EXE_FINISH'}">selected</c:if> >
                                            EXE_FINISH
                                        </option>
                                        <option value="EXE_MIGRATE"
                                                <c:if test="${piistep.steptype eq 'EXE_MIGRATE'}">selected</c:if> >
                                            EXE_MIGRATE
                                        </option>
                                        <option value="EXE_SCRAMBLE"
                                                <c:if test="${piistep.steptype eq 'EXE_SCRAMBLE'}">selected</c:if> >
                                            EXE_SCRAMBLE
                                        </option>
                                        <option value="EXE_ILM"
                                                <c:if test="${piistep.steptype eq 'EXE_ILM'}">selected</c:if> >
                                            EXE_ILM
                                        </option>
                                        <option value="EXE_SYNC"
                                                <c:if test="${piistep.steptype eq 'EXE_SYNC'}">selected</c:if> >
                                            EXE_SYNC
                                        </option>
                                        <option value="ETC"
                                                <c:if test="${piistep.steptype eq 'ETC'}">selected</c:if> >ETC
                                        </option>
                                        <option value="EXE_TD_UPDATE"
                                                <c:if test="${piistep.steptype eq 'EXE_TD_UPDATE'}">selected</c:if> >EXE_TD_UPDATE
                                        </option>
                                    </select>
                                </td>
                                <th class="th-get" id="dbTh">
                                    <c:choose>
                                        <c:when test="${piistep.steptype eq 'EXE_SCRAMBLE'}">
                                            Source DB
                                        </c:when>
                                        <c:when test="${piistep.steptype eq 'EXE_ILM'}">
                                            Archiving DB
                                        </c:when>
                                        <c:when test="${piistep.steptype eq 'EXE_MIGRATE'}">
                                            Target DB
                                        </c:when>
                                        <c:when test="${piistep.steptype eq 'EXE_SYNC'}">
                                            Target DB
                                        </c:when>
                                        <c:otherwise>
                                            DB
                                        </c:otherwise>
                                    </c:choose>

                                </th>
                                <td class="td-get">
                                    <%-- <input type="text" class="form-control form-control-sm" name='db' value='<c:out value="${piistep.db}"/>'> --%>
                                    <select class="pt-0 pb-0 form-control form-control-sm" name="db"
                                            style="font-size: 11px;">
                                        <option value=""></option>
                                        <c:forEach items="${piidatabaselist}" var="piidatabase">
                                            <option value="<c:out value="${piidatabase.db}"/>"
                                                    <c:if test="${piistep.db eq piidatabase.db}">selected</c:if> >
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
                                           value='<c:out value="${piistep.threadcnt}"/>'>
                                </td>
                                <c:choose>
                                    <c:when test="${exetype eq 'EXE_SCRAMBLE'}">
                                        <th class="th-get" id="thCnt"><spring:message code="col.handlecnt"
                                                                           text="Data Processing Unit"/></th>
                                    </c:when>
                                    <c:when test="${exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' || exetype eq 'EXE_SYNC'}">
                                        <th class="th-get" id="thCnt"><spring:message code="col.handlecnt"
                                                                                      text="Data Processing Unit"/></th>
                                    </c:when>
                                    <c:otherwise>
                                        <th class="th-get" id="thCnt"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                                    </c:otherwise>
                                </c:choose>
                                <td class="td-get">
                                    <input type="text" class="form-control form-control-sm" maxlength='8'
                                           onKeyup="this.value=this.value.replace(/[^0-9]/g,'');" name='commitcnt'
                                           value='<c:out value="${piistep.commitcnt}"/>'>
                                </td>
                            </tr>
                            <c:choose>
                                <c:when test="${exetype eq 'EXE_SCRAMBLE'}">
                                    <tr class="scrambleRows">
                                    <th scope="row" class="th-get" id="dynamicThId"><spring:message code="col.data_handling_method" text="Data_Handling_Method" /></th>
                                        <td class="td-get" id="dynamicTdId">
                                            <select class="form-control form-control-sm" name="data_handling_method">
                                                <option value="TRUNCSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'TRUNCSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                                </option>
                                                <option value="REPLACEINSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'REPLACEINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method2" text="Upsert" />
                                                </option>
                                                <option value="DELDUPINSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'DELDUPINSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                                </option>
                                                <option value="INSERT"
                                                        <c:if test="${piistep.data_handling_method eq 'INSERT'}">selected</c:if> ><spring:message code="etc.data_handling_method3" text="INSERT" />
                                                </option>
                                            </select>
                                        </td>
                                        <%--<th class="th-get"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="fk_disable_flag">
                                                <option value="Y"
                                                        <c:if test="${piistep.fk_disable_flag eq 'Y'}">selected</c:if> >Y
                                                </option>
                                                <option value="N"
                                                        <c:if test="${piistep.fk_disable_flag eq 'N'}">selected</c:if> >N
                                                </option>
                                            </select>
                                        </td>--%>
                                        <input type="hidden" class="form-control form-control-sm" name='fk_disable_flag'
                                               value='<c:out value="${piistep.fk_disable_flag}"/>'>
                                        <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="index_unusual_flag">
                                                <option value="Y"
                                                        <c:if test="${piistep.index_unusual_flag eq 'Y'}">selected</c:if> >Y
                                                </option>
                                                <option value="N"
                                                        <c:if test="${piistep.index_unusual_flag eq 'N'}">selected</c:if> >N
                                                </option>
                                                <%--<option value="YN"
                                                        <c:if test="${piistep.index_unusual_flag eq 'YN'}">selected</c:if> >YN
                                                </option>--%>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr class="scrambleRows">
                                    <th scope="row" class="th-get"><spring:message code="col.processing_method" text="Processing_Method" /></th>
                                    <td class="td-get" COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piistep.processing_method}" />'>--%>
                                        <select class="form-control form-control-sm" name="processing_method">
                                            <option value="TMP_TABLE"
                                                    <c:if test="${piistep.processing_method eq 'TMP_TABLE'}">selected</c:if> >
                                                <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                            </option>
                                            <%--<option value="SQLLDR"
                                                    <c:if test="${piistep.processing_method eq 'SQLLDR'}">selected</c:if> >
                                                <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                            </option>
                                            <option value="PARTITION"
                                                    <c:if test="${piistep.processing_method eq 'PARTITION'}">selected</c:if> >
                                                <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                            </option>
                                            <option value="DIRECT_SQL"
                                                    <c:if test="${piistep.processing_method eq 'DIRECT_SQL'}">selected</c:if> >
                                                <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                            </option>--%>
                                        </select>
                                    </td>
                                    <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="val1">
                                            <option value="1" <c:if test="${piistep.val1 eq '1'}">selected</c:if> >1 </option>
                                            <option value="2" <c:if test="${piistep.val1 eq '2'}">selected</c:if> >2 </option>
                                            <option value="3" <c:if test="${piistep.val1 eq '3'}">selected</c:if> >3 </option>
                                            <option value="4" <c:if test="${piistep.val1 eq '4'}">selected</c:if> >4 </option>
                                            <option value="5" <c:if test="${piistep.val1 eq '5'}">selected</c:if> >5 </option>
                                            <option value="6" <c:if test="${piistep.val1 eq '6'}">selected</c:if> >6 </option>
                                            <option value="7" <c:if test="${piistep.val1 eq '7'}">selected</c:if> >7 </option>
                                            <option value="8" <c:if test="${piistep.val1 eq '8'}">selected</c:if> >8 </option>
                                            <option value="9" <c:if test="${piistep.val1 eq '9'}">selected</c:if> >9 </option>
                                            <option value="10" <c:if test="${piistep.val1 eq '10'}">selected</c:if> >10 </option>
                                            <option value="11" <c:if test="${piistep.val1 eq '11'}">selected</c:if> >11 </option>
                                            <option value="12" <c:if test="${piistep.val1 eq '12'}">selected</c:if> >12 </option>
                                            <option value="13" <c:if test="${piistep.val1 eq '13'}">selected</c:if> >13 </option>
                                            <option value="14" <c:if test="${piistep.val1 eq '14'}">selected</c:if> >14 </option>
                                            <option value="15" <c:if test="${piistep.val1 eq '15'}">selected</c:if> >15 </option>
                                        </select>
                                    </td>
                                    <%--<th class="th-get"><spring:message code="col.createtmpparallelcnt" text="TMP Parallel Max Cnt"/></th>
                                    <td class="td-get">
                                        <select class="form-control form-control-sm" name="val2">
                                            <option value="1" <c:if test="${piistep.val2 eq '1'}">selected</c:if>>1</option>
                                            <option value="2" <c:if test="${piistep.val2 eq '2'}">selected</c:if>>2</option>
                                            <option value="3" <c:if test="${piistep.val2 eq '3'}">selected</c:if>>3</option>
                                            <option value="4" <c:if test="${piistep.val2 eq '4'}">selected</c:if>>4</option>
                                            <option value="5" <c:if test="${piistep.val2 eq '5'}">selected</c:if>>5</option>
                                            <option value="6" <c:if test="${piistep.val2 eq '6'}">selected</c:if>>6</option>
                                            <option value="7" <c:if test="${piistep.val2 eq '7'}">selected</c:if> >7 </option>
                                            <option value="8" <c:if test="${piistep.val2 eq '8'}">selected</c:if> >8 </option>
                                            <option value="9" <c:if test="${piistep.val2 eq '9'}">selected</c:if> >9 </option>
                                            <option value="10" <c:if test="${piistep.val2 eq '10'}">selected</c:if> >10 </option>
                                            <option value="11" <c:if test="${piistep.val2 eq '11'}">selected</c:if> >11 </option>
                                            <option value="12" <c:if test="${piistep.val2 eq '12'}">selected</c:if> >12 </option>
                                        </select>
                                    </td>--%>
                                    </tr>
                                    <%--                                    <th scope="row" class="th-get"><spring:message code="col.val1" text="Val1" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val1' value='<c:out value="${piistep.val1}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val2" text="Val2" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val2' value='<c:out value="${piistep.val2}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val3" text="Val3" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val3' value='<c:out value="${piistep.val3}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val4" text="Val4" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val4' value='<c:out value="${piistep.val4}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val5" text="Val5" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val5' value='<c:out value="${piistep.val5}" />'></td>--%>
                                </c:when>
                                <c:when test="${exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' }">
                                    <tr class="scrambleRows">
                                        <th scope="row" class="th-get" id="dynamicThId"><spring:message code="col.data_handling_method" text="Data_Handling_Method" /></th>
                                        <td class="td-get" id="dynamicTdId">
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
                                                    <option value="Y"
                                                            <c:if test="${piistep.fk_disable_flag eq 'Y'}">selected</c:if> >Y
                                                    </option>
                                                    <option value="N"
                                                            <c:if test="${piistep.fk_disable_flag eq 'N'}">selected</c:if> >N
                                                    </option>
                                                </select>
                                            </td>--%>
                                        <input type="hidden" class="form-control form-control-sm" name='fk_disable_flag'
                                               value='<c:out value="${piistep.fk_disable_flag}"/>'>
                                        <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="index_unusual_flag">
                                                <option value="Y"
                                                        <c:if test="${piistep.index_unusual_flag eq 'Y'}">selected</c:if> >Y
                                                </option>
                                                <option value="N"
                                                        <c:if test="${piistep.index_unusual_flag eq 'N'}">selected</c:if> >N
                                                </option>
                                                <%--<option value="YN"
                                                        <c:if test="${piistep.index_unusual_flag eq 'YN'}">selected</c:if> >YN
                                                </option>--%>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr class="scrambleRows">
                                        <th scope="row" class="th-get"><spring:message code="col.processing_method" text="Processing_Method" /></th>
                                        <td class="td-get" COLSPAN="1"><%--<input type="text" class="form-control form-control-sm" name='processing_method' value='<c:out value="${piistep.processing_method}" />'>--%>
                                            <select class="form-control form-control-sm" name="processing_method">
                                                <option value="TMP_TABLE"
                                                        <c:if test="${piistep.processing_method eq 'TMP_TABLE'}">selected</c:if> >
                                                    <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                                </option>
                                                    <%--<option value="SQLLDR"
                                                            <c:if test="${piistep.processing_method eq 'SQLLDR'}">selected</c:if> >
                                                        <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                                    </option>
                                                    <option value="PARTITION"
                                                            <c:if test="${piistep.processing_method eq 'PARTITION'}">selected</c:if> >
                                                        <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                                    </option>
                                                    <option value="DIRECT_SQL"
                                                            <c:if test="${piistep.processing_method eq 'DIRECT_SQL'}">selected</c:if> >
                                                        <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                                    </option>--%>
                                            </select>
                                        </td>
                                        <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt"/></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="val1">
                                                <option value="1"
                                                        <c:if test="${piistep.val1 eq '1'}">selected</c:if> >1
                                                </option>
                                                <option value="2"
                                                        <c:if test="${piistep.val1 eq '2'}">selected</c:if> >2
                                                </option>
                                                <option value="3"
                                                        <c:if test="${piistep.val1 eq '3'}">selected</c:if> >3
                                                </option>
                                                <option value="4"
                                                        <c:if test="${piistep.val1 eq '4'}">selected</c:if> >4
                                                </option>
                                                <option value="5"
                                                        <c:if test="${piistep.val1 eq '5'}">selected</c:if> >5
                                                </option>
                                                <option value="6"
                                                        <c:if test="${piistep.val1 eq '6'}">selected</c:if> >6
                                                </option>
                                                <option value="7" <c:if test="${piistep.val1 eq '7'}">selected</c:if> >7 </option>
                                                <option value="8" <c:if test="${piistep.val1 eq '8'}">selected</c:if> >8 </option>
                                                <option value="9" <c:if test="${piistep.val1 eq '9'}">selected</c:if> >9 </option>
                                                <option value="10" <c:if test="${piistep.val1 eq '10'}">selected</c:if> >10 </option>
                                                <option value="11" <c:if test="${piistep.val1 eq '11'}">selected</c:if> >11 </option>
                                                <option value="12" <c:if test="${piistep.val1 eq '12'}">selected</c:if> >12 </option>
                                                <option value="13" <c:if test="${piistep.val1 eq '13'}">selected</c:if> >13 </option>
                                                <option value="14" <c:if test="${piistep.val1 eq '14'}">selected</c:if> >14 </option>
                                                <option value="15" <c:if test="${piistep.val1 eq '15'}">selected</c:if> >15 </option>
                                            </select>
                                        </td>
                                        <%--<th class="th-get"><spring:message code="col.createtmpparallelcnt" text="TMP Parallel Max Cnt"/></th>
                                        <td class="td-get">
                                            <select class="form-control form-control-sm" name="val2">
                                                <option value="1" <c:if test="${piistep.val2 eq '1'}">selected</c:if>>1</option>
                                                <option value="2" <c:if test="${piistep.val2 eq '2'}">selected</c:if>>2</option>
                                                <option value="3" <c:if test="${piistep.val2 eq '3'}">selected</c:if>>3</option>
                                                <option value="4" <c:if test="${piistep.val2 eq '4'}">selected</c:if>>4</option>
                                                <option value="5" <c:if test="${piistep.val2 eq '5'}">selected</c:if>>5</option>
                                                <option value="6" <c:if test="${piistep.val2 eq '6'}">selected</c:if>>6</option>
                                                <option value="7" <c:if test="${piistep.val2 eq '7'}">selected</c:if> >7 </option>
                                                <option value="8" <c:if test="${piistep.val2 eq '8'}">selected</c:if> >8 </option>
                                                <option value="9" <c:if test="${piistep.val2 eq '9'}">selected</c:if> >9 </option>
                                                <option value="10" <c:if test="${piistep.val2 eq '10'}">selected</c:if> >10 </option>
                                                <option value="11" <c:if test="${piistep.val2 eq '11'}">selected</c:if> >11 </option>
                                                <option value="12" <c:if test="${piistep.val2 eq '12'}">selected</c:if> >12 </option>
                                            </select>
                                        </td>--%>
                                    </tr>
                                    <%--                                    <th scope="row" class="th-get"><spring:message code="col.val1" text="Val1" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val1' value='<c:out value="${piistep.val1}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val2" text="Val2" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val2' value='<c:out value="${piistep.val2}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val3" text="Val3" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val3' value='<c:out value="${piistep.val3}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val4" text="Val4" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val4' value='<c:out value="${piistep.val4}" />'></td>
                                                                        <th scope="row" class="th-get"><spring:message code="col.val5" text="Val5" /></th><td class="td-get"><input type="text" class="form-control form-control-sm" name='val5' value='<c:out value="${piistep.val5}" />'></td>--%>
                                </c:when>
                                <c:otherwise>
                                    <tr></tr>
                                </c:otherwise>
                            </c:choose>

                            </tbody>
                        </table>
                        <input type="hidden" class="form-control form-control-sm" name='jobid'
                               value='<c:out value="${piistep.jobid}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='version'
                               value='<c:out value="${piistep.version}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='phase'
                               value='<c:out value="${piistep.phase}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='stepseq'
                               value='<c:out value="${piistep.stepseq}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='enddate'
                               value='<c:out value="${piistep.enddate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='regdate'
                               value='<c:out value="${piistep.regdate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upddate'
                               value='<c:out value="${piistep.upddate}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='reguserid'
                               value='<c:out value="${piistep.reguserid}"/>'>
                        <input type="hidden" class="form-control form-control-sm" name='upduserid'
                               value='<sec:authentication property="principal.member.userid"/>'>
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </form>
                </div><!--  end panel-body -->
            </div><!--  panel panel-default-->
        </div><!-- col-sm-12 -->
    </div>
    <div id="modifyresult" class="ml-2">${modifyresult}</div>
</div>
<!-- <div class="card shadow"> DataTales begin-->

<form style="margin: 0; padding: 0;" role="form" id=searchForm>
    <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
    <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
    <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
</form>

<script type="text/javascript">

    $(document).ready(function () {
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


        $("button[data-oper='modify-step-dialog']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();
            var elementForm = $("#piistep_modify_form");
            var elementResult = $("#stepmodalbody");
            $('#step_md_global_jobid').val($('#piistep_modify_form [name="jobid"]').val());
            $('#step_md_global_version').val($('#piistep_modify_form [name="version"]').val());
            $('#step_md_global_stepid').val($('#piistep_modify_form [name="stepid"]').val());

            var jobid = $('#step_md_global_jobid').val();
            var version = $('#step_md_global_version').val();
            var stepid = $('#step_md_global_stepid').val();


            if (isEmpty($('#piistep_modify_form [name="stepid"]').val())) {
                dlmAlert('Stepid is mandatory');
                $('#piistep_modify_form [name="stepid"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="stepname"]').val())) {
                dlmAlert('Stepname is mandatory');
                $('#piistep_modify_form [name="stepname"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="steptype"]').val())) {
                dlmAlert('Steptype is mandatory');
                $('#piistep_modify_form [name="steptype"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="db"]').val())) {
                dlmAlert('DB is mandatory');
                $('#piistep_modify_form [name="db"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="threadcnt"]').val())) {
                dlmAlert('Threadcnt is mandatory');
                $('#piistep_modify_form [name="threadcnt"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="commitcnt"]').val())) {
                dlmAlert('Commitcnt is mandatory');
                $('#piistep_modify_form [name="commitcnt"]').focus();
                return;
            }
            if (isEmpty($('#piistep_modify_form [name="status"]').val())) {
                dlmAlert('Status is mandatory');
                $('#piistep_modify_form [name="status"]').focus();
                return;
            }

console.log(elementForm.serialize());
            ingShow();
            $.ajax({
                type: "POST",
                url: "/piistep/modify",
                dataType: "html",
                //data:$('form').serialize(),
                data: elementForm.serialize(),
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                    //alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
                },
                success: function (data) { ingHide();//alert(111);
                    $('#stepmodalbody').html(data);
                    $("#stepmodal").modal();

                    var url_view = "/piistep/modify?jobid=" + jobid + "&" + "version=" + version + "&" + "stepid=" + stepid + "&";
                    searchAction_stepdialog(null, url_view, "#stepdetaildilaog");
                    $('#modify_step_dlg_result').html("Successfully saved");
                    //elementResult.html(data); //받아온 data 실행
                    //elementResult.text(Parse_data); //받아온 data 실행
                }
            });
        });

        $("button[data-oper='remove-step-dialog']").on("click", function (e) {
            e.preventDefault();e.stopPropagation();

            var elementForm = $("#piistep_modify_form");
            var elementResult = $("#stepmodalbody");
            $('#step_md_global_jobid').val($('#piistep_modify_form [name="jobid"]').val());
            $('#step_md_global_version').val($('#piistep_modify_form [name="version"]').val());
            $('#step_md_global_stepid').val($('#piistep_modify_form [name="stepid"]').val());

            // Use modal confirmation
            showConfirm('Are you sure you want to delete this step?', function() {
                ingShow();
                $.ajax({
                    type: "POST",
                    url: "/piistep/remove",
                    dataType: "html",
                    data: elementForm.serialize(),
                    error: function (request, error) {
                        ingHide();
                        $("#errormodalbody").html(request.responseText);
                        $("#errormodal").modal("show");
                    },
                    success: function (data) {
                        ingHide();
                        $('#modify_step_dlg_result').html("Successfully removed");

                        // Refresh the step list to reflect the deletion
                        if (typeof refreshStepList === 'function') {
                            refreshStepList();
                        }

                        // Clear the step detail area after deletion
                        $('#stepdetaildilaog').empty();
                    }
                });
            });
        });

    });

    /*function handleSSelectChange() {
        // select 요소의 현재 선택된 값을 가져옴
        var selectedValue = document.getElementById("modify_steptype").value;

        // 변경할 th 요소를 가져옴
        var thElement = document.getElementById("dbTh");
        var thElementthCnt = document.getElementById("thCnt");
        // 선택된 값이 "EXE_SCRAMBLE"이면 "Source DB"로 변경, 그 외에는 "DB"로 변경

        if (selectedValue == 'EXE_SCRAMBLE') {
            thElement.innerText = "Source DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_modify_form [name="commitcnt"]').val(20000);
            var rowsToToggle = document.querySelectorAll(".scrambleRows");
            for (var i = 0; i < rowsToToggle.length; i++) {
                var row = rowsToToggle[i];
                row.style.display = "table-row";
            }
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            thElement.classList.remove('th-hidden');
            tdElement.classList.remove('td-hidden');
            thElement.classList.add('th-get');
            tdElement.classList.add('td-get');
        } else if (selectedValue == 'EXE_ILM' ) {
            thElement.innerText = "Archiving DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_modify_form [name="commitcnt"]').val(20000);
            var rowsToToggle = document.querySelectorAll(".scrambleRows");
            for (var i = 0; i < rowsToToggle.length; i++) {
                var row = rowsToToggle[i];
                row.style.display = "table-row";
            }
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            thElement.classList.add('th-hidden');
            tdElement.classList.add('td-hidden');
        } else if (selectedValue == 'EXE_MIGRATE' || selectedValue == 'EXE_SYNC') {
            thElement.innerText = "Target DB" ;
            thElementthCnt.innerText = '<spring:message code="col.handlecnt" text="Data Processing Unit"/>' ;
            $('#piistep_modify_form [name="commitcnt"]').val(20000);
            var rowsToToggle = document.querySelectorAll(".scrambleRows");
            for (var i = 0; i < rowsToToggle.length; i++) {
                var row = rowsToToggle[i];
                row.style.display = "table-row";
            }
            var thElement = document.getElementById('dynamicThId');
            var tdElement = document.getElementById('dynamicTdId');
            thElement.classList.add('th-hidden');
            tdElement.classList.add('td-hidden');
        } else {
            thElement.innerText = "DB" ;
            thElementthCnt.innerText = '<spring:message code="col.commitcnt" text="Commitcnt"/>' ;
            $('#piistep_modify_form [name="commitcnt"]').val(5000);
            var rowsToToggle = document.querySelectorAll(".scrambleRows");
            for (var i = 0; i < rowsToToggle.length; i++) {
                var row = rowsToToggle[i];
                row.style.display = "none";
            }
        }

    }*/
</script>




 

 