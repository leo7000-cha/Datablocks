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

    <input type='hidden' name='cur_jobid' value='<c:out value="${piistep.jobid}"/>'>
    <input type='hidden' name='cur_version' value='<c:out value="${piistep.version}"/>'>
    <input type='hidden' name='cur_stepid' value='<c:out value="${piistep.stepid}"/>'>


        <!-- grid-template-columns: 45% 55%  ; -->
        <div id="tableinfo" class="tablelist-container m-0 " style="width: 99.8%;">
            <div class="card shadow-sm m-1 P-0 tablelist-card" style="width:99%;height:590px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
                <div class="step-section-header">
                    <div class="step-section-title">
                        <i class="fa-solid fa-table-list" style="color: #0ea5e9;"></i>
                        테이블 리스트
                        <sec:authorize access="isAuthenticated()">
                            <c:if test="${ exetype eq 'EXE_DELETE' || exetype eq 'EXE_UPDATE' || exetype eq 'EXE_BROADCAST' || exetype eq 'EXE_FINISH' || exetype eq 'EXE_ETC' || exetype eq 'EXE_EXTRACT' || exetype eq 'EXE_SCRAMBLE' || exetype eq 'EXE_MIGRATE' }">
                                <a href="javascript:void(0);" class="btn-excel-download" onclick="doExcelTemplateDownload('<c:out value="${fn:substring(piistep.steptype,4,15)}"/>');" title="Excel Template 다운로드"><i class="fas fa-file-excel"></i><i class="fas fa-arrow-down"></i></a>
                                <a href="javascript:void(0);" class="btn-excel-upload" onclick="uploadModal();" title="Excel 업로드"><i class="fas fa-file-excel"></i><i class="fas fa-arrow-up"></i></a>
                            </c:if>
                        </sec:authorize>
                    </div>
                    <div class="step-section-actions">
                        <sec:authorize access="hasAnyRole('ROLE_ADMIN','ROLE_IT')">
                            <c:if test="${exetype ne 'EXE_ARCHIVE' }">
                                <button data-oper='piisteptable_register' id="piisteptable_register"
                                        class="btn btn-step-new"><i class="fas fa-plus"></i> <spring:message
                                        code="btn.new" text="New"/></button>
                                <button data-oper='piisteptable_remove' id="piisteptable_remove"
                                        class="btn btn-step-remove"><i class="fas fa-trash-alt"></i> <spring:message
                                        code="btn.remove" text="Remove"/></button>
                            </c:if>
                        </sec:authorize>
                    </div>
                </div>

                <div class="tableWrapper" style="width:100%;height:calc(100% - 32px);">
                    <table class="listTable table-hover" id="steptables">
                        <thead>
                        <tr>
                            <th class="th-get" style="text-align:center;"><input type="checkbox" class="chkBox"
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
                                <c:when test="${exetype eq 'EXE_BROADCAST'}">
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
                                    <td class="td-get"><input type="checkbox" class="chkBox" name="chkBox"
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
            <!-- Table details --><!-- grid-template-columns:  55%  ; -->


            <div class="card shadow-sm m-1 P-0" style="width:99%;height:590px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
                <div class="step-section-header">
                    <div class="step-section-title">
                        <i class="fa-solid fa-sliders" style="color: #8b5cf6;"></i>
                        테이블 세부 속성
                        <span class="step-section-hint">
                            <i class="fa-solid fa-circle-info"></i>
                            파란색 '*' 항목은 비워두면 STEP의 해당 속성값이 자동 상속 적용됩니다.
                        </span>
                    </div>
                </div>


                <div id="tabledetail" class="m-1 p-0 "
                     style="overflow-y:auto;overflow-x:hidden; width:98.8%;height:527px;">
                </div><!-- Table details -->
            </div>


        </div>
    </div><%-- <div id="${piistep.stepid}stepinfo" class="tab-body-none" style="width:100%;height:600px;"> --%>
</c:forEach>
<!-- Unregistered Tables Modal -->
<div class="modal fade" id="toaddsracmbletablistmodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document" style="max-width: 700px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
            <div class="modal-header" style="background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); padding: 16px 24px; border: none;">
                <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem;">
                    <i class="fas fa-table"></i> Unregistered Tables
                    <span style="background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 20px; font-size: 0.85rem; margin-left: 10px;">
                        <c:out value="${toAddScrambleListSize}"/> tables
                    </span>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 0;">
                <div style="background: #faf5ff; border-bottom: 1px solid #e9d5ff; padding: 12px 24px;">
                    <p style="margin: 0; font-size: 0.85rem; color: #7c3aed;">
                        <i class="fas fa-info-circle"></i> 아직 등록되지 않은 테이블 목록입니다. 필요 시 Step에 추가하세요.
                    </p>
                </div>
                <div style="max-height: 450px; overflow-y: auto; padding: 16px 24px;">
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                        <tr style="background: #f8fafc;">
                            <th style="padding: 10px 12px; text-align: center; font-weight: 600; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; width: 60px;">No</th>
                            <th style="padding: 10px 12px; text-align: left; font-weight: 600; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; width: 100px;">DB</th>
                            <th style="padding: 10px 12px; text-align: left; font-weight: 600; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; width: 150px;">Owner</th>
                            <th style="padding: 10px 12px; text-align: left; font-weight: 600; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0;">Table Name</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${toAddScrambleList}" var="piitablevo" varStatus="loopStatus">
                            <tr style="border-bottom: 1px solid #f1f5f9; transition: background 0.2s;"
                                onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                <td style="padding: 10px 12px; text-align: center; color: #94a3b8; font-size: 0.85rem;"><c:out value="${loopStatus.index + 1}"/></td>
                                <td style="padding: 10px 12px; color: #1e293b; font-size: 0.85rem;"><span style="background: #dbeafe; color: #1d4ed8; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: 500;"><c:out value="${piitablevo.db}"/></span></td>
                                <td style="padding: 10px 12px; color: #475569; font-size: 0.85rem;"><c:out value="${piitablevo.owner}"/></td>
                                <td style="padding: 10px 12px; color: #1e293b; font-size: 0.85rem; font-weight: 500;"><c:out value="${piitablevo.table_name}"/></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px; background: #f8fafc;">
                <button type="button" class="btn" id="toaddsracmbletablistmodalclose" data-dismiss="modal"
                        style="background: #64748b; color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-weight: 500;">
                    <i class="fas fa-times"></i> 닫기
                </button>
            </div>
        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- Upload Modal -->
<div class="modal fade" id="uploadmodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 450px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden;">
            <div class="modal-header" style="background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%); padding: 16px 24px; border: none;">
                <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem;">
                    <i class="fas fa-cloud-upload-alt"></i> Table List Upload
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 24px;">
                <div style="background: #fef3c7; border: 1px solid #fcd34d; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px;">
                    <p style="margin: 0 0 6px 0; font-size: 0.875rem; color: #92400e; font-weight: 600;">
                        <i class="fas fa-exclamation-triangle"></i> 업로드 시 주의사항
                    </p>
                    <p style="margin: 0; font-size: 0.8rem; color: #a16207; line-height: 1.5;">
                        기존 데이터를 <strong>전체 삭제</strong> 후 업로드 파일로 <strong>재등록</strong>됩니다.<br>
                        반드시 현재 목록을 다운로드 후, 수정/추가하여 <strong>전체 리스트</strong>를 업로드하세요.
                    </p>
                </div>
                <div id="uploadDropZone" style="border: 2px dashed #cbd5e1; border-radius: 10px; padding: 30px 20px; text-align: center; background: #f8fafc; transition: all 0.3s; cursor: pointer;">
                    <i class="fas fa-file-excel" style="font-size: 40px; color: #10b981; margin-bottom: 12px;"></i>
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem; color: #475569; font-weight: 500;">Excel 파일을 선택하세요</p>
                    <p style="margin: 0; font-size: 0.8rem; color: #94a3b8;">.xls, .xlsx 파일만 가능</p>
                    <input type='file' name='uploadFile' id="uploadFileInput" accept=".xls,.xlsx" style="display: none;">
                </div>
                <div id="selectedFileInfo" style="display: none; margin-top: 16px; padding: 12px 16px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-file-excel" style="color: #16a34a; font-size: 20px;"></i>
                        <div style="flex: 1; min-width: 0;">
                            <p id="selectedFileName" style="margin: 0; font-size: 0.875rem; color: #166534; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"></p>
                            <p id="selectedFileSize" style="margin: 0; font-size: 0.75rem; color: #4ade80;"></p>
                        </div>
                        <button type="button" id="removeFileBtn" style="background: none; border: none; color: #dc2626; cursor: pointer; padding: 4px;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
                <div id="uploadresult" style="margin-top: 12px; font-size: 0.875rem;"></div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px; background: #f8fafc;">
                <button type="button" class="btn" id="uploadmodalclose" data-dismiss="modal" style="background: #64748b; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; font-weight: 500;">
                    <i class="fas fa-times"></i> 취소
                </button>
                <button data-oper='upload' class="btn" style="background: linear-gradient(135deg, #10b981, #059669); color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-weight: 500;">
                    <i class="fas fa-upload"></i> 업로드
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
    $("button[data-oper='showModaltoAddScrambleList']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        $("#toaddsracmbletablistmodal").modal("show");

    })
    function doExcelTemplateDownload(exeType) {
        var f = document.form1;
        var jobid = $('input[name=cur_jobid]').val();
        var version = $('input[name=cur_version]').val();
        var stepid = $('input[name=cur_stepid]').val();

        f.action = "/piiupload/download_steptable?jobid=" + jobid + "&version=" + version + "&stepid=" + stepid + "&exeType=" + exeType;
        f.submit();
    }
</script>
<script type="text/javascript">
    var selectedstepallRow;
    var global_seq2_new;
    var result = '<c:out value="${result}"/>';
    checkResultModal(result);
    history.replaceState({}, null, null);

    $(document).ready(function () {
        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
        })
    })

    function checkedRowColorChange() {
        /* 		jQuery("#steptablesbody > tr").css("background-color", "#FFFFFF");

                var checkbox = $("input:checkbox[name=chkBox]:checked");

                checkbox.each(function(i) {
                  checkbox.parent().parent().eq(i).css("background-color", "#E2E8F9");
                }); */

    };
    uploadModal = function () {
        $("#uploadmodal").modal();
        $('#uploadFileInput').val("");
        $('#uploadresult').html("");
        $('#selectedFileInfo').hide();
        $('#uploadDropZone').show();
    };
    uploadModalClose = function () {
        $("#uploadmodal").modal("hide");
    };

    // File drop zone interactions
    $(document).on('click', '#uploadDropZone', function() {
        $('#uploadFileInput').click();
    });

    $(document).on('dragover', '#uploadDropZone', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).css({
            'border-color': '#3b82f6',
            'background': '#eff6ff'
        });
    });

    $(document).on('dragleave', '#uploadDropZone', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).css({
            'border-color': '#cbd5e1',
            'background': '#f8fafc'
        });
    });

    $(document).on('drop', '#uploadDropZone', function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).css({
            'border-color': '#cbd5e1',
            'background': '#f8fafc'
        });
        var files = e.originalEvent.dataTransfer.files;
        if (files.length > 0) {
            $('#uploadFileInput')[0].files = files;
            showSelectedFile(files[0]);
        }
    });

    $(document).on('change', '#uploadFileInput', function() {
        if (this.files.length > 0) {
            showSelectedFile(this.files[0]);
        }
    });

    $(document).on('click', '#removeFileBtn', function(e) {
        e.stopPropagation();
        $('#uploadFileInput').val("");
        $('#selectedFileInfo').hide();
        $('#uploadDropZone').show();
    });

    function showSelectedFile(file) {
        var fileName = file.name;
        var fileSize = (file.size / 1024).toFixed(1) + ' KB';
        if (file.size > 1024 * 1024) {
            fileSize = (file.size / (1024 * 1024)).toFixed(2) + ' MB';
        }
        $('#selectedFileName').text(fileName);
        $('#selectedFileSize').text(fileSize);
        $('#uploadDropZone').hide();
        $('#selectedFileInfo').show();
    }
    refreshTablelist = function () {
        var global_stepid = $('#jobget_global_stepid').val();
        $("#" + global_stepid).trigger("click");
    };

    $("button[data-oper='upload']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        doubleSubmitFlag = true;
        var stepid = '<c:out value="${stepid}"/>';
        var formData = new FormData();
        var inputFile = $("#uploadFileInput");

        var files = inputFile[0].files;

        if (files.length == 0) {
            dlmAlert("Choose the upload file");
            return false;
        } else if (files.length > 1) {
            dlmAlert("Choose only one file");
            return false;
        }

        for (var i = 0; i < files.length; i++) {
            if (!$('#uploadFileInput').val().toUpperCase().endsWith(".XLS") && !$('#uploadFileInput').val().toUpperCase().endsWith(".XLSX")) {
                dlmAlert("Only EXCEL file type can be uploaded. You can download the template file.");
                return false;
            }
            formData.append("uploadFile", files[i]);

        }

        var global_stepid = $('#jobget_global_stepid').val();
        var global_jobid = $('#jobget_global_jobid').val();
        var global_version = $('#jobget_global_version').val();

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "/piiupload/uploadAjaxAction?jobid=" + global_jobid + "&version=" + global_version + "&stepid=" + global_stepid + "&userid=" + $('#global_userid').val();

        ingShow();
        $.ajax({
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
                    setTimeout(function() {
                        $("#" + stepid).trigger("click");
                    }, 1000);

                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            },
            error: function (request, error) { ingHide();
                //$("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
                if (request.responseText.indexOf("successfully") != -1) {
                    $("#uploadmodal").modal("hide");
                    $("#messagemodalbody").html("<p class='text-success' style='font-size: 14px;'>" + request.responseText + "</p>");
                    $("#messagemodal").modal("show");
                    setTimeout(function() {
                        $("#" + stepid).trigger("click");
                    }, 1000);

                } else {
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            }


        }); //$.ajax

    });
    //$("button[data-oper='uploadfromDB']").on("click", function (e) {
     uploadfromDB = function () {
        showConfirm("Are you sure to delete all current steptable data and upload data from 'tbl_piiupload_template' table to config steptables?", function() {
        doubleSubmitFlag = true;
        var formData = new FormData();
        //formData.append("uploadFile", files[i]);

        var global_stepid = $('#jobget_global_stepid').val();
        var global_jobid = $('#jobget_global_jobid').val();
        var global_version = $('#jobget_global_version').val();

        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";
        var url_view = "";

        url_view = "/piiupload/" + "uploadfromDBAjaxAction?jobid=" + global_jobid + "&version=" + global_version + "&stepid=" + global_stepid + "&userid=" + $('#global_userid').val();
         ingShow();
        $.ajax({
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
                    $("#messagemodalbody").html("<p class='text-success ' style='font-size: 13px;'>" + request.responseText + "</p>");
                    $("#messagemodal").modal("show");

                    //$("#"+global_stepid).trigger("click");

                } else {
                    $("#errormodalbody").html(data);
                    $("#errormodal").modal("show");
                }
            },
            error: function (request, error) { ingHide();
                //$("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
                if (request.responseText.indexOf("successfully") != -1) {
                    //$('#uploadresult').html("<p class='text-success ' style='font-size: 13px;'>"+request.responseText+"</p>");
                    $("#uploadmodal").modal("hide");
                    $("#messagemodalbody").html("<p class='text-success ' style='font-size: 13px;'>" + request.responseText + "</p>");
                    $("#messagemodal").modal("show");

                    //$("#"+global_stepid).trigger("click");
                } else {
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            }

        }); //$.ajax

        }); // showConfirm
    };
    $("button[data-oper='piisteptable_remove']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();

        var stepid = '<c:out value="${stepid}"/>';
        var param = [];
        var tr;
        var td;

        var checkbox = $("input:checkbox[name=chkBox]:checked");
        var precheck = false;
        checkbox.each(function (i) {
            precheck = true;
        });
        if (!precheck) {
            $("#messagemodalbody").html("Select tables to remove");
            $("#messagemodal").modal("show");
            return;
        }
        showConfirm("<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>", function() {
            checkbox.each(function (i) {
                //console.log(index);console.log(tr);
                tr = checkbox.parent().parent().eq(i);
                td = tr.children();
                var data = {
                    jobid: td.eq(1).text(),
                    version: td.eq(2).text(),
                    stepid: td.eq(3).text(),
                    db: td.eq(7).text(),
                    owner: td.eq(8).text(),
                    table_name: td.eq(9).text(),
                    pagitype: null,
                    pagitypedetail: null,
                    exetype: td.eq(10).text(),
                    archiveflag: null,
                    status: null,
                    preceding: null,
                    succedding: null,
                    seq1: td.eq(4).text(),
                    seq2: td.eq(5).text(),
                    seq3: td.eq(6).text(),
                    pipeline: null,
                    pk_col: null,
                    where_col: null,
                    where_key_name: null,
                    parallelcnt: null,
                    commitcnt: null,
                    wherestr: null,
                    sqlstr: null,
                    keymap_id: null,
                    key_name: null,
                    key_cols: null,
                    key_refstr: null,
                    sqltype: null,
                    regdate: null,
                    upddate: null,
                    reguserid: null,
                    upduserid: null
                };

                param.push(data);
            });

            //console.log("param "+param.length);
            ingShow();
            $.ajax({
                url: "/piisteptable/removeList",
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                type: "post",
                data: JSON.stringify(param),//{"str" : JSON.stringify(param)},
                beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data, textStatus, jqXHR) {ingHide();
                    $("#" + stepid).trigger("click");
                    showToast("처리가 완료되었습니다.", false);
                },
                error: function (request, error) { ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }

            });
        });

    });

    $("button[data-oper='piisteptable_register']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var global_stepid = $('#jobget_global_stepid').val();
        var global_jobid = $('#jobget_global_jobid').val();
        var global_version = $('#jobget_global_version').val();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
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
            success: function (data) { ingHide();
                $("#tabledetail").html(data);
            }
        });
    });

    $("button[data-oper='piisteptable_register_entire']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var global_stepid = $('#jobget_global_stepid').val();
        var global_jobid = $('#jobget_global_jobid').val();
        var global_version = $('#jobget_global_version').val();

        if ($('#jobget_global_phase').val() != "CHECKOUT") {
            dlmAlert("Job's status is not CHECKOUT");
            return;
        }
        ingShow();
        $.ajax({
            url: '/piisteptable/registerEntireToScramble', // 요청을 보낼 엔드포인트 URL
            type: 'GET', // HTTP 요청 방식
            data: {
                jobid: global_jobid, // jobid 파라미터 값
                version: global_version, // version 파라미터 값
                stepid: global_stepid // stepid 파라미터 값
                // 필요에 따라 추가 파라미터를 여기에 포함시킬 수 있습니다.
            },
            dataType: "text",
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {   /*데이터를 전송하기 전에 헤더에 csrf값을 설정한다*/
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(data) {ingHide();
                // 요청이 성공했을 때 실행할 동작
                $("#" + global_stepid).trigger("click");
                $("#messagemodalbody").html("<p class='text-success ' style='font-size: 14px;'>" + data + "</p>");
                $("#messagemodal").modal("show");
            },
            error: function(xhr, status, error) { ingHide();
                // 요청이 실패했을 때 실행할 동작
                dlmAlert('Error: ' + error);
                // 에러 처리 로직을 추가할 수 있습니다.
            }
        });

    });

    $('#steptables tbody').on('click', 'tr', function () {
        var str = ""
        var tdArr = new Array();	// 배열 선언

        // 현재 클릭된 Row(<tr>)
        var tr = $(this);
        var td = tr.children();

        selectedstepallRow = $(this);
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

        var serchkeyno = "/piisteptable/" + "modify?" + "jobid=" + serchkeyno1 + "&" + "version=" + serchkeyno2 + "&" + "stepid=" + serchkeyno3 + "&" + "seq1=" + serchkeyno4 + "&" + "seq2=" + serchkeyno5 + "&" + "seq3=" + serchkeyno6;
        //alert(serchkeyno);
        searchAction(null, serchkeyno, serchkeyno3);
    });

    searchAction = function (pageNo, serchkeyno, stepid) {

        var pagenum = 1;//$('#searchForm [name="pagenum"]').val();
        var amount = 100;//$('#searchForm [name="amount"]').val();
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
        ingShow();
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
                $("#tabledetail").html(data);

                //$('#content_home').load(data);
            }
        });
    }


</script>	



