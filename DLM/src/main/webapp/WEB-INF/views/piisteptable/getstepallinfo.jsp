<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/jquery-ui-themes-1.12.1/themes/base/jquery-ui.css">
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>


<c:forEach items="${liststep}" var="piistep">
    <c:set var="exetype" value="${piistep.steptype}"/>

    <!-- STEP 정보 한줄 표시 -->
    <div class="step-info-bar">
        <div class="step-info-item step-info-title">
            <span class="step-info-value"><c:out value="${piistep.stepseq}"/>.<c:out value="${piistep.stepid}"/> [<c:out value="${piistep.stepname}"/>]</span>
        </div>
        <div class="step-info-item">
            <span class="step-info-label">
                <c:choose>
                    <c:when test="${exetype eq 'EXE_SCRAMBLE'}">Source DB</c:when>
                    <c:when test="${exetype eq 'EXE_ILM'}">Archiving DB</c:when>
                    <c:when test="${exetype eq 'EXE_MIGRATE' || exetype eq 'EXE_SYNC'}">Target DB</c:when>
                    <c:otherwise>DB</c:otherwise>
                </c:choose>
            </span>
            <span class="step-info-value step-db-badge"><c:out value="${piistep.db}"/></span>
        </div>
        <div class="step-info-item">
            <span class="step-info-label"><spring:message code="col.threadtablecnt" text="동시작업 테이블수"/></span>
            <span class="step-info-value"><c:out value="${piistep.threadcnt}"/></span>
        </div>
        <div class="step-info-item">
            <span class="step-info-label">
                <c:choose>
                    <c:when test="${exetype eq 'EXE_SCRAMBLE' || exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' || exetype eq 'EXE_SYNC'}">
                        <spring:message code="col.handlecnt" text="처리단위"/>
                    </c:when>
                    <c:otherwise>
                        <spring:message code="col.commitcnt" text="커밋단위"/>
                    </c:otherwise>
                </c:choose>
            </span>
            <span class="step-info-value"><c:out value="${piistep.commitcnt}"/></span>
        </div>
        <c:if test="${exetype eq 'EXE_SCRAMBLE' || exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE'}">
            <div class="step-info-item">
                <span class="step-info-label"><spring:message code="col.data_handling_method" text="데이터 처리 방법"/></span>
                <span class="step-info-value">
                    <c:choose>
                        <c:when test="${piistep.data_handling_method eq 'TRUNCSERT'}"><spring:message code="etc.data_handling_method1" text="Truncate&Insert"/></c:when>
                        <c:when test="${piistep.data_handling_method eq 'REPLACEINSERT'}"><spring:message code="etc.data_handling_method2" text="Upsert"/></c:when>
                        <c:when test="${piistep.data_handling_method eq 'INSERT'}"><spring:message code="etc.data_handling_method4" text="Insert"/></c:when>
                        <c:when test="${piistep.data_handling_method eq 'DELDUPINSERT'}"><spring:message code="etc.data_handling_method5" text="DelDup&Insert"/></c:when>
                        <c:otherwise><c:out value="${piistep.data_handling_method}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="step-info-item">
                <span class="step-info-label"><spring:message code="col.index_unusual_flag" text="INDEX,FK 비활성화"/></span>
                <span class="step-info-value"><c:out value="${piistep.index_unusual_flag}"/></span>
            </div>
            <div class="step-info-item">
                <span class="step-info-label"><spring:message code="col.processing_method" text="병렬 처리 방식"/></span>
                <span class="step-info-value">
                    <c:choose>
                        <c:when test="${piistep.processing_method eq 'TMP_TABLE'}"><spring:message code="etc.processing_method1" text="분산 병렬 처리"/></c:when>
                        <c:when test="${piistep.processing_method eq 'SQLLDR'}"><spring:message code="etc.processing_method2" text="SQL Loader 사용"/></c:when>
                        <c:when test="${piistep.processing_method eq 'PARTITION'}"><spring:message code="etc.processing_method3" text="파티션 기반 병렬 처리"/></c:when>
                        <c:when test="${piistep.processing_method eq 'DIRECT_SQL'}"><spring:message code="etc.processing_method4" text="Direct SQL"/></c:when>
                        <c:otherwise><c:out value="${piistep.processing_method}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="step-info-item">
                <span class="step-info-label"><spring:message code="col.distributedtaskcnt" text="분산 병렬 작업수"/></span>
                <span class="step-info-value"><c:out value="${piistep.val1}"/></span>
            </div>
        </c:if>
    </div>

    <!-- hidden data (데이터 참조용) -->
    <div style="display:none;">
        <span id="step_stepseq"><c:out value="${piistep.stepseq}"/></span>
        <span id="step_stepid"><c:out value="${piistep.stepid}"/></span>
        <span id="step_stepname"><c:out value="${piistep.stepname}"/></span>
        <span id="step_steptype"><c:out value="${piistep.steptype}"/></span>
        <span id="step_db"><c:out value="${piistep.db}"/></span>
        <span id="step_status"><c:out value="${piistep.status}"/></span>
        <span id="step_threadcnt"><c:out value="${piistep.threadcnt}"/></span>
        <span id="step_commitcnt"><c:out value="${piistep.commitcnt}"/></span>
    </div>

    <!-- 기존 테이블 제거 - 아래 c:choose 블록 전부 숨김 -->
    <c:if test="${false}">
            <c:choose>
                <c:when test="${exetype eq 'EXE_ILM'}">
                    <thead>
                    <tr>
                        <th class="th-get"><spring:message code="col.stepseq" text="Stepseq"/></th>
                        <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                        <th class="th-hidden"><spring:message code="col.stepname" text="Stepname"/></th>
                        <th class="th-hidden"><spring:message code="col.steptype" text="Steptype"/></th>
                        <th class="th-get text-primary font-weight-bold">Archiving DB</th>
                        <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                        <th class="th-get"><spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/></th>
                        <th class="th-get"><spring:message code="col.handlecnt" text="Data Processing Unit"/><font
                                style="color:blue">*</font></th>
                        <th class="th-hidden"><spring:message code="col.data_handling_method" text="Data_Handling_Method" /><font
                                style="color:blue">*</font></th>
                        <th class="th-hidden"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.processing_method" text="Processing_Method" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt" /><font
                                style="color:blue">*</font></th>
                            <%--<th class="th-get"><spring:message code="col.val2" text="Val2" /></th>
                            <th class="th-get"><spring:message code="col.val3" text="Val3" /></th>
                            <th class="th-get"><spring:message code="col.val4" text="Val4" /></th>
                            <th class="th-get"><spring:message code="col.val5" text="Val5" /></th>--%>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="td-get"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-hidden"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-hidden"><c:out value="${piistep.steptype}"/></td>
                        <td class="td-get"><c:out value="${piistep.db}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.threadcnt}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.commitcnt}"/></td>
                            <%-- <td class="td-get"><c:out value="${piistep.phase}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piistep.version}"/></td> --%>
                        <td class='td-hidden'>
                            <c:choose>
                                <c:when test="${piistep.data_handling_method eq 'TRUNCSERT'}">
                                    <spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'REPLACEINSERT'}">
                                    <spring:message code="etc.data_handling_method2" text="Upsert" />
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'INSERT'}">
                                    <spring:message code="etc.data_handling_method4" text="Insert"/>
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'DELDUPINSERT'}">
                                    <spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${piistep.data_handling_method}" />
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class='td-hidden'><c:out value="${piistep.fk_disable_flag}" /></td>
                        <td class='td-get'><c:out value="${piistep.index_unusual_flag}" /></td>
                        <td class='td-get'>
                            <c:choose>
                                <c:when test="${piistep.processing_method eq 'TMP_TABLE'}">
                                    <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'SQLLDR'}">
                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'PARTITION'}">
                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'DIRECT_SQL'}">
                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${piistep.processing_method}" />
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class='td-get-r'><c:out value="${piistep.val1}" /></td>
                            <%-- <td class='td-get'><c:out value="${piistep.val2}" /></td>
                           <td class='td-get'><c:out value="${piistep.val3}" /></td>
                           <td class='td-get'><c:out value="${piistep.val4}" /></td>
                           <td class='td-get'><c:out value="${piistep.val5}" /></td>--%>

                    </tr>
                    </tbody>
                </c:when>
                <c:when test="${exetype eq 'EXE_MIGRATE' }">
                    <thead>
                    <tr>
                        <th class="th-get"><spring:message code="col.stepseq" text="Stepseq"/></th>
                        <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                        <th class="th-hidden"><spring:message code="col.stepname" text="Stepname"/></th>
                        <th class="th-hidden"><spring:message code="col.steptype" text="Steptype"/></th>
                        <th class="th-get text-primary font-weight-bold">Target DB</th>
                        <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                        <th class="th-get"><spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/></th>
                        <th class="th-get"><spring:message code="col.handlecnt" text="Data Processing Unit"/><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.data_handling_method" text="Data_Handling_Method" /><font
                                style="color:blue">*</font></th>
                        <th class="th-hidden"><spring:message code="col.fk_disable_flag" text="Fk_Disable_Flag" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.index_unusual_flag" text="Index_Unusual_Flag" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.processing_method" text="Processing_Method" /><font
                                style="color:blue">*</font></th>
                        <th class="th-get"><spring:message code="col.distributedtaskcnt" text="Distributed Task Cnt" /><font
                                style="color:blue">*</font></th>
                            <%--<th class="th-get"><spring:message code="col.val2" text="Val2" /></th>
                            <th class="th-get"><spring:message code="col.val3" text="Val3" /></th>
                            <th class="th-get"><spring:message code="col.val4" text="Val4" /></th>
                            <th class="th-get"><spring:message code="col.val5" text="Val5" /></th>--%>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="td-get"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-hidden"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-hidden"><c:out value="${piistep.steptype}"/></td>
                        <td class="td-get"><c:out value="${piistep.db}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.threadcnt}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.commitcnt}"/></td>
                            <%-- <td class="td-get"><c:out value="${piistep.phase}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piistep.version}"/></td> --%>
                        <td class='td-get'>
                            <c:choose>
                                <c:when test="${piistep.data_handling_method eq 'TRUNCSERT'}">
                                    <spring:message code="etc.data_handling_method1" text="Truncate&Insert" />
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'REPLACEINSERT'}">
                                    <spring:message code="etc.data_handling_method2" text="Upsert" />
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'INSERT'}">
                                    <spring:message code="etc.data_handling_method4" text="Insert"/>
                                </c:when>
                                <c:when test="${piistep.data_handling_method eq 'DELDUPINSERT'}">
                                    <spring:message code="etc.data_handling_method5" text="DelDup&Insert" />
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${piistep.data_handling_method}" />
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class='td-hidden'><c:out value="${piistep.fk_disable_flag}" /></td>
                        <td class='td-get'><c:out value="${piistep.index_unusual_flag}" /></td>
                        <td class='td-get'>
                            <c:choose>
                                <c:when test="${piistep.processing_method eq 'TMP_TABLE'}">
                                    <spring:message code="etc.processing_method1" text="Distributed Parallel Processing" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'SQLLDR'}">
                                    <spring:message code="etc.processing_method2" text="Using SQL Loader" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'PARTITION'}">
                                    <spring:message code="etc.processing_method3" text="Execute parallelly based on Patitions" />
                                </c:when>
                                <c:when test="${piistep.processing_method eq 'DIRECT_SQL'}">
                                    <spring:message code="etc.processing_method4" text="Direct SQL with TMP(Only for the regular conversion task)" />
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${piistep.processing_method}" />
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class='td-get-r'><c:out value="${piistep.val1}" /></td>
                            <%-- <td class='td-get'><c:out value="${piistep.val2}" /></td>
                           <td class='td-get'><c:out value="${piistep.val3}" /></td>
                           <td class='td-get'><c:out value="${piistep.val4}" /></td>
                           <td class='td-get'><c:out value="${piistep.val5}" /></td>--%>

                    </tr>
                    </tbody>
                </c:when>
                <c:when test="${exetype eq 'EXE_SYNC'}">
                    <thead>
                    <tr>
                        <th class="th-get"><spring:message code="col.stepseq" text="Stepseq"/></th>
                        <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                        <th class="th-hidden"><spring:message code="col.stepname" text="Stepname"/></th>
                        <th class="th-get"><spring:message code="col.steptype" text="Steptype"/></th>
                        <th class="th-get text-primary font-weight-bold">Target DB</th>
                        <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                        <th class="th-get"><spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/></th>
                        <th class="th-get"><spring:message code="col.handlecnt" text="Data Processing Unit"/><font
                                style="color:blue">*</font></th>

                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="td-get"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-hidden"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-get"><c:out value="${piistep.steptype}"/></td>
                        <td class="td-get"><c:out value="${piistep.db}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.threadcnt}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.commitcnt}"/></td>

                    </tr>
                    </tbody>
                </c:when>
                <c:otherwise>
                    <thead>
                    <tr>
                        <th class="th-get"><spring:message code="col.stepseq" text="Stepseq"/></th>
                        <th class="th-get"><spring:message code="col.stepid" text="Stepid"/></th>
                        <th class="th-get"><spring:message code="col.stepname" text="Stepname"/></th>
                        <th class="th-get"><spring:message code="col.steptype" text="Steptype"/></th>
                        <th class="th-get">
                            <c:choose>
                                <c:when test="${exetype eq 'EXE_BROADCAST' }">
                                    Source DB
                                </c:when>
                                <c:when test="${exetype eq 'EXE_HOMECAST' }">
                                    Target DB
                                </c:when>
                                <c:otherwise>
                                    <spring:message code="col.db" text="DB"/>
                                </c:otherwise>
                            </c:choose>
                        </th>
                        <th class="th-get"><spring:message code="col.status" text="Status"/></th>
                        <th class="th-get"><spring:message code="col.threadtablecnt" text="Concurrent Operation Tables"/></th>
                        <th class="th-get"><spring:message code="col.commitcnt" text="Commitcnt"/></th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="td-get"><c:out value="${piistep.stepseq}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepid}"/></td>
                        <td class="td-get"><c:out value="${piistep.stepname}"/></td>
                        <td class="td-get"><c:out value="${piistep.steptype}"/></td>
                        <td class="td-get"><c:out value="${piistep.db}"/></td>
                        <td class="td-get"><c:out value="${piistep.status}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.threadcnt}"/></td>
                        <td class="td-get-r"><c:out value="${piistep.commitcnt}"/></td>
                            <%-- <td class="td-get"><c:out value="${piistep.phase}"/></td> --%>
                            <%-- <td class="td-get"><c:out value="${piistep.version}"/></td> --%>
                    </tr>
                    </tbody>
                </c:otherwise>
            </c:choose>
    </c:if>

    <!-- grid-template-columns: 45% 55% ; -->
    <div id="tableinfo" class="tablelist-container m-0 " style="width: 99.8%;">

        <!-- Table List--> <!-- grid-template-columns: 45%   ; -->
        <div>
            <div class="card shadow m-1 border tablelist-card" style="width:99%;height:590px">
                <div class="step-section-header">
                    <div class="step-section-title">
                        <i class="fa-solid fa-table-list"></i>
                        테이블 리스트
                    </div>
                    <div class="step-section-actions">
                        <sec:authorize access="isAuthenticated()">
                            <c:if test="${ exetype eq 'EXE_DELETE' || exetype eq 'EXE_UPDATE' || exetype eq 'EXE_BROADCAST' || exetype eq 'EXE_FINISH' || exetype eq 'EXE_ETC' || exetype eq 'EXE_EXTRACT' || exetype eq 'EXE_SCRAMBLE' || exetype eq 'EXE_MIGRATE' }">
                                <a href="javascript:void(0);" class="btn-excel-download" onclick="doExcelTemplateDownload('<c:out value="${fn:substring(piistep.steptype,4,15)}"/>');" title="Excel Template 다운로드"><i class="fas fa-file-excel"></i><i class="fas fa-arrow-down"></i></a>
                            </c:if>
                        </sec:authorize>
                    </div>
                </div>
                <div class="tableWrapper" style="width:100%;height:calc(100% - 32px);">
                    <table class="listTable table-hover" id="steptables">
                        <thead>
                        <tr>
                            <th class="th-hidden" style="text-align:center;"><input type="checkbox" class="chkBox"
                                                                                 id="checkall"
                                                                                 style="vertical-align:middle;width:15px;height:15px;">
                            </th>
                            <th class="th-hidden">JOBID</th>
                            <th class="th-hidden">VERSION</th>
                            <th class="th-hidden">STEPID</th>
                            <th class="th-hidden">SEQ1</th>
                            <th class="th-hidden">SEQ2</th>
                            <th class="th-hidden">SEQ3</th>

                            <c:choose>
                                <c:when test="${exetype eq 'GEN_KEYMAP'}">
                                    <th class="th-get"><spring:message code="etc.keyname_desc" text="Key Desc"/></th>
                                    <th class="th-get">KEY_NAME</th>
                                    <th class="th-get">DB</th>
                                    <th class="th-get">SEQ1</th>
                                    <th class="th-get">SEQ2</th>
                                </c:when>
                                <c:when test="${exetype eq 'EXE_EXTRACT'}">
                                    <th class="th-get">Type</th>
                                    <th class="th-get">Task Name</th>
                                    <th class="th-get">DB</th>
                                    <th class="th-get">SEQ</th>
                                </c:when>
                                <c:when test="${ exetype eq 'EXE_BROADCAST'}">
                                    <th class="th-get">Target DB</th>
                                    <th class="th-get">OWNER</th>
                                    <th class="th-get">TABLE_NAME</th>
                                    <th class="th-get">SEQ</th>
                                </c:when>
                                <c:when test="${exetype eq 'EXE_HOMECAST'}">
                                    <th class="th-get">Source DB</th>
                                    <th class="th-get">OWNER</th>
                                    <th class="th-get">TABLE_NAME</th>
                                    <th class="th-get">SEQ</th>
                                </c:when>
                                <c:when test="${exetype eq 'EXE_SCRAMBLE'}">
                                    <th class="th-get">Target DB</th>
                                    <th class="th-get">OWNER</th>
                                    <th class="th-get">TABLE_NAME</th>
                                    <th class="th-get">병렬수</th>
                                    <th class="th-get">SEQ</th>
                                    <th class="th-get">등록일</th>
                                </c:when>
                                <c:when test="${exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' || exetype eq 'EXE_SYNC'}">
                                    <th class="th-get">Source DB</th>
                                    <th class="th-get">OWNER</th>
                                    <th class="th-get">TABLE_NAME</th>
                                    <th class="th-get">병렬수</th>
                                    <th class="th-get">SEQ</th>
                                    <th class="th-get">등록일</th>
                                </c:when>
                                <c:otherwise>
                                    <th class="th-get">DB</th>
                                    <th class="th-get">OWNER</th>
                                    <th class="th-get">TABLE_NAME</th>
                                    <th class="th-get">SEQ</th>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                        </thead>
                        <tbody id="steptablesbody">
                        <c:forEach items="${liststeptable}" var="piisteptable">
                            <c:if test="${piisteptable.stepid eq piistep.stepid}">
                                <tr>
                                    <td class="td-hidden"><input type="checkbox" class="chkBox" name="chkBox"
                                                              onClick="checkedRowColorChange();"
                                                              style="vertical-align:middle;width:15px;height:15px;">
                                    </td>
                                    <td class="td-hidden"><c:out value="${piisteptable.jobid}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.version}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.stepid}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.seq1}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.seq2}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.seq3}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.db}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.owner}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.table_name}"/></td>
                                    <td class="td-hidden"><c:out value="${piisteptable.exetype}"/></td>
                                    <c:choose>
                                        <c:when test="${exetype eq 'GEN_KEYMAP'}">
                                            <td class="td-get-l"><c:out value="${piisteptable.pk_col}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.key_name}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq2}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq3}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'EXE_EXTRACT'}">

                                            <td class="td-get">
                                                <c:choose>
                                                    <c:when test="${piisteptable.pagitypedetail eq 'ADD' }"><i
                                                            class="fa fa-plus-circle " style="color:blue"></i>
                                                        <spring:message code="etc.add" text="Add"/></c:when>
                                                    <c:when test="${piisteptable.pagitypedetail eq 'EXCLUDE' }"><i
                                                            class="fa fa-minus-circle" style="color:red"></i>
                                                        <spring:message code="etc.exclude" text="Exclude"/></c:when>
                                                    <c:when test="${piisteptable.pagitypedetail eq 'ETC' }"><i
                                                            class="fa fa-circle" style="color:green"></i>
                                                        <spring:message code="etc.etc" text="Etc"/></c:when>
                                                    <c:otherwise> <c:out value="${piisteptable.pagitypedetail}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="td-get-l"><c:out value="${piisteptable.pk_col}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq2}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'EXE_SCRAMBLE'}">
                                            <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.owner}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.table_name}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.pipeline}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq2}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.regdate}"/></td>
                                        </c:when>
                                        <c:when test="${exetype eq 'EXE_ILM' || exetype eq 'EXE_MIGRATE' || exetype eq 'EXE_SYNC'}">
                                            <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.owner}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.table_name}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.pipeline}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq2}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.regdate}"/></td>
                                        </c:when>
                                        <c:otherwise>
                                            <td class="td-get-l"><c:out value="${piisteptable.db}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.owner}"/></td>
                                            <td class="td-get-l"><c:out value="${piisteptable.table_name}"/></td>
                                            <td class="td-get-r"><c:out value="${piisteptable.seq2}"/></td>
                                        </c:otherwise>
                                    </c:choose>


                                </tr>
                            </c:if>
                        </c:forEach>
                        </tbody>
                    </table>
                </div><!-- Table List-->
            </div>
        </div>
        <!-- Table details --><!-- grid-template-columns:  55%  ; -->
        <div class="card shadow m-1 p-0 border" style="width:99%;height:590px">
            <div class="step-section-header">
                <div class="step-section-title">
                    <i class="fa-solid fa-sliders"></i>
                    테이블 세부 속성
                    <span class="step-section-hint">
                        <i class="fa-solid fa-circle-info"></i>
                        파란색 '*' 항목은 비워두면 STEP의 해당 속성값이 자동 상속 적용됩니다.
                    </span>
                </div>
            </div>
            <div id="get_tabledetail" class="m-1 p-0 "
                 style="overflow-y:auto;overflow-x:hidden;width:98.7%; height:518px;">
            </div><!-- Table details -->
        </div>
    </div>
    <!-- <div id="${piistep.stepid}tableinfo" class="tablelist-container border mr-1" style="height:475px;width: 100%;display:none;" > -->

    <!-- </div> --><%-- <div id="${piistep.stepid}stepinfo" class="tab-body-none" style="width:100%;height:600px;"> --%>
</c:forEach>

<!-- The Modal -->
<div class="modal fade" id="toaddsracmbletablistmodal" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">Unregistered Tables (<c:out value="${toAddScrambleListSize}"/> tables)</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="toaddsracmbletablistmodalbody">

                <div class="tableWrapper m-1 " style="width:98.8%;height:517px">
                    <table class="table-hover"style="width:100%;" >
                        <colgroup>
                            <col style="width: 10%"/>
                            <col style="width: 25%"/>
                            <col style="width: 25%"/>
                            <col style="width: 40%"/>
                        </colgroup>
                        <thead>
                        <tr>
                            <th class="th-get">No</th>
                            <th class="th-get">DB</th>
                            <th class="th-get">OWNER</th>
                            <th class="th-get">TABLE_NAME</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${toAddScrambleList}" var="piitablevo" varStatus="loopStatus">
                            <tr>
                                <td class="td-get-r"><c:out value="${loopStatus.index + 1}"/></td>
                                <td class="td-get"><c:out value="${piitablevo.db}"/></td>
                                <td class="td-get-l"><c:out value="${piitablevo.owner}"/></td>
                                <td class="td-get-l"><c:out value="${piitablevo.table_name}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div><!-- tableWrapper-->

            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" id="toaddsracmbletablistmodalclose"
                        data-dismiss="modal">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<form style="margin: 0; padding: 0;" id="form1" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>
<script type="text/javascript">

    var result = '<c:out value="${result}"/>';
    checkResultModal(result);
    history.replaceState({}, null, null);

    function doExcelTemplateDownload(exeType) {
        var f = document.form1;

        var stepid = $('#jobget_global_stepid').val();
        var jobid = $('#jobget_global_jobid').val();
        var version = $('#jobget_global_version').val();
        ingShow();
        f.action = "/piiupload/download_steptable?jobid=" + jobid + "&version=" + version + "&stepid=" + stepid + "&exeType=" + exeType;
        f.submit();
        ingHide();
    }

    $("button[data-oper='showModaltoAddScrambleList']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        $("#toaddsracmbletablistmodal").modal("show");

    })
    $("button[data-oper='piisteptable_register']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var global_stepid = $('#jobget_global_stepid').val();
        var global_jobid = $('#jobget_global_jobid').val();
        var global_version = $('#jobget_global_version').val();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            //alert('<spring:message code="msg.jobisnotcheckout" text="Job is not checkout status"/>');
            return;
        }
        //var serchkeyno = $('input[name=jobid]').val();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "/piisteptable/" + "register?jobid=" + global_jobid + "&version=" + global_version + "&stepid=" + global_stepid + "&";
        if (isEmpty(pagenum))
            pagenum = 1;
        if (isEmpty(amount))
            amount = 100;
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
            url: url_view
                + "pagenum=" + pagenum
                + "&amount=" + amount
                + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert("성공");
                $("#get_tabledetail").html(data);
            }
        });

    })
    $('#steptables tbody').on('click', 'tr', function () {
        var str = ""
        var tdArr = new Array();	// 배열 선언

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();

        // change bg color on selected row 20210718
        $('#steptables tbody > tr').each(function (index, tr) {
            $(this).removeClass("selected-row");
        });
        tr.addClass("selected-row");

        // tr.text()는 클릭된 Row 즉 tr에 있는 모든 값을 가져온다.
        //console.log("클릭한 Row의 모든 데이터 : "+tr.text());
        // 반복문을 이용해서 배열에 값을 담아 사용할 수 도 있다.
        //td.each(function(i){
        //	tdArr.push(td.eq(i).text());
        //});

        // td.eq(index)를 통해 값을 가져올 수도 있다.
        var serchkeyno1 = td.eq(1).text().trim();
        var serchkeyno2 = td.eq(2).text().trim();
        var serchkeyno3 = td.eq(3).text().trim();
        var serchkeyno4 = td.eq(4).text().trim();
        var serchkeyno5 = td.eq(5).text().trim();
        var serchkeyno6 = td.eq(6).text().trim();
//			var serchkeyno = "/piisteptable/"+"get?"+"jobid="+serchkeyno1+"&"+"version="+serchkeyno2+"&"+"stepid="+serchkeyno3+"&"+"db="+serchkeyno4+"&"+"owner="+serchkeyno5+"&"+"table_name="+serchkeyno6;
        var serchkeyno = "/piisteptable/" + "get?" + "jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3 + "&" + "seq1=" + serchkeyno4 + "&" + "seq2=" + serchkeyno5 + "&" + "seq3=" + serchkeyno6;
        //alert(serchkeyno);
        //$('#content_home').load("/piijob/get?piikeyno="+no+"&pagenum=${pageMaker.cri.pagenum}&amount=${pageMaker.cri.amount}");
        //content_home( "refresh" );
        searchAction(null, serchkeyno, serchkeyno3);
    });
    searchAction = function (pageNo, serchkeyno, stepid) {

        var pagenum = 1;//$('#searchForm [name="pagenum"]').val();
        var amount = 50;//$('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();

        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "/piijob/" + "list?";
        } else {
            url_view = serchkeyno + "&";
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
        //alert(url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $("#get_tabledetail").html(data);

                //$('#content_home').load(data);
            }
        });


    }

</script>

