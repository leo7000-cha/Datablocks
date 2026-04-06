<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/jquery-ui-themes-1.12.1/themes/base/jquery-ui.css">
<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>

<div class="m-0" style="height:630px">

    <!-- grid-template-columns: 20% 80%  ; -->
    <div id="steps" class="step-container m-0 p-1" style="overflow:hidden;width:100%">
        <!-- grid-template-columns: 20%  ; -->
        <div id="steptabdiv" class="m-0 card shadow border" style="overflow:hidden;height:625px;width:100%;">

            <div class="panel m-1 " style="overflow-y:auto;overflow-x:hidden; width:97%;height:620px">
                <ul id="steptab" class="list-group  m-0 p-0 " style="width:100%">
                    <c:forEach items="${liststep}" var="piiorderstep" varStatus="status">
                        <li class="list-group-item list-group-item-primary text-center mb-1 p-1"
                            id="${status.count}" name="${piiorderstep.stepseq}" style="width:99%">
                            <div style="font-size: 15px; width:100%; font-family: 'Noto Sans KR', sans-serif; font-weight:bold;  text-align: left;  vertical-align: middle; padding : 0px;">
                                <c:out value="${piiorderstep.stepseq}"/>.<c:out value="${piiorderstep.stepid}"/>
                            </div>
                            <div style="font-size: 15px; width:100%; font-family: 'Noto Sans KR', sans-serif; font-weight:bold;  text-align: center;  vertical-align: middle; padding : 0px;">
                                <c:choose>
                                    <c:when test="${piiorderstep.status eq 'Ended OK' }">
                                        <span style="font-size: 12px;" class="badge badge-success"><c:out
                                                value="${piiorderstep.status}"/></span>
                                    </c:when>
                                    <c:when test="${piiorderstep.status eq 'Ended not OK' }">
                                        <span style="font-size: 12px;" class="badge badge-danger">Error</span>
                                    </c:when>
                                    <c:when test="${piiorderstep.status eq 'Running' }">
                                        <span style="font-size: 12px;" class="badge badge-primary"><i
                                                class="fa fa-spinner fa-spin"></i> <c:out
                                                value="${piiorderstep.status}"/>
                                            </span>
                                    </c:when>
                                    <c:when test="${piiorderstep.status eq 'Wait condition' }">
                                        <span style="font-size: 12px;" class="badge badge-secondary">Wait</span>
                                    </c:when>
                                    <c:when test="${piiorderstep.status eq 'Hold' }">
                                        <span style="font-size: 12px;" class="badge badge-info"><c:out
                                                value="${piiorderstep.status}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="font-size: 12px;" class="badge badge-light"><c:out
                                                value="${piiorderstep.status}"/></span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <c:forEach items="${liststepstatus}" var="piiorderstepstatus">
                                <c:if test="${piiorderstep.stepid eq piiorderstepstatus.stepid }">
                                    <table style="width:100%">
                                        <colgroup>
                                            <col style="width: 20%"/>
                                            <col style="width: 20%"/>
                                            <col style="width: 20%"/>
                                            <col style="width: 20%"/>
                                            <col style="width: 20%"/>
                                        </colgroup>
                                        <tr style="border: 0px solid white; height: 9px; padding : 0em;">
                                            <th class="th-get-sm-orderdetail">Total</th>
                                            <th class="th-get-sm-orderdetail">Wait</th>
                                            <th class="th-get-sm-orderdetail">Run</th>
                                            <th class="th-get-sm-orderdetail">Ok</th>
                                            <th class="th-get-sm-orderdetail">Error</th>


                                        </tr>
                                        <tr style="border: 0px solid white; height: 10px; padding : 0em;">
                                            <td class="td-get-sm-r-orderdetail"><c:out
                                                    value="${piiorderstepstatus.total}"/></td>
                                            <td class="td-get-sm-r-orderdetail"><c:out
                                                    value="${piiorderstepstatus.wait}"/></td>
                                            <td class="td-get-sm-r-orderdetail"><c:out
                                                    value="${piiorderstepstatus.running}"/></td>
                                            <td class="td-get-sm-r-orderdetail"><c:out
                                                    value="${piiorderstepstatus.ok}"/></td>
                                            <td class="td-get-sm-r-orderdetail"><c:out
                                                    value="${piiorderstepstatus.notok}"/></td>
                                        </tr>
                                    </table>
                                </c:if>
                            </c:forEach>

                        </li>
                    </c:forEach>
                </ul>
            </div>
            <form style="margin: 0; padding: 0;" role="form" id=orderdetailForm>
                <input type='hidden' name='orderdetail_orderid' value='<c:out value="${piiorder.orderid}"/>'>
                <input type='hidden' name='orderdetail_jobid' value='<c:out value="${piiorder.jobid}"/>'>
                <input type='hidden' name='orderdetail_version' value='<c:out value="${piiorder.version}"/>'>
                <input type='hidden' name='orderdetail_stepseq' value='1'>

            </form>
        </div>
        <!-- grid-template-columns:  80%  ; -->
        <div class="m-0 p-1 card shadow border" style="display:flex; flex-direction:column; height:100%;">
            <div class="tableWrapper p-0" style="height:473px; flex-shrink:0;">
                <table id="listTable" class="table table-sm table-hover">

                    <thead>
                    <tr>
                        <!-- <th class="th-get">ORDERID</th> -->
                        <th class="th-get">STATUS</th>
                        <!-- <th class="th-get">STEID</th> -->
                        <c:set var="steptype" value="${piiorderstep.steptype}"/>
                        <c:choose>
                            <c:when test="${steptype eq 'GEN_KEYMAP'}">
                                <th class="th-get"><spring:message code="etc.keyname_desc" text="Key Desc"/></th>
                                <th class="th-get">KEYMAP_ID</th>
                                <th class="th-get">KEY_NAME</th>
                            </c:when>
                            <c:when test="${steptype eq 'EXE_EXTRACT'}">
                                <th class="th-get">Type</th>
                                <th class="th-get">Task Name</th>
                            </c:when>
                            <c:otherwise>
                                <th class="th-hidden">KEYMAP_ID</th>
                                <th class="th-hidden">KEY_NAME</th>
                            </c:otherwise>
                        </c:choose>
                        <th class="th-get">DB</th>
                        <c:choose>
                            <c:when test="${steptype eq 'GEN_KEYMAP' || steptype eq 'EXE_EXTRACT'}">
                            </c:when>
                            <c:otherwise>
                                <th class="th-get">OWNER</th>
                                <th class="th-get">TABLE</th>
                            </c:otherwise>
                        </c:choose>

                        <th class="th-get"><spring:message code="col.execnt" text="Exe cnt"/></th>
                        <th class="th-get"><spring:message code="col.exetime" text="Running time"/></th>
                        <th class="th-get"><spring:message code="col.exestart" text="Start date"/></th>
                        <!-- <th class="th-get">EXEEND</th> -->
                        <!-- <th class="th-get">PAGITYPE</th> -->
                        <!-- <th class="th-get">PAGITYPEDETAIL</th> -->
                        <!-- <th class="th-get">EXETYPE</th> -->
                        <!-- <th class="th-get">ARCHIVEFLAG</th>
                        <th class="th-get">PRECEDING</th>
                        <th class="th-get">SUCCEDDING</th> -->
                        <c:choose>
                            <c:when test="${steptype eq 'GEN_KEYMAP'}">
                                <th class="th-get">SEQ1</th>
                                <th class="th-get">SEQ2</th>
                            </c:when>
                            <c:otherwise>
                                <th class="th-get">SEQ</th>
                            </c:otherwise>
                        </c:choose>
                        <!-- <th class="th-get">PIPELINE</th>
                        <th class="th-get">WHERE_COL</th>
                        <th class="th-get">PARALLELCNT</th> -->

                        <!-- <th class="th-get">ARCCNT</th>
                        <th class="th-get">ARCTIME</th>
                        <th class="th-get">ARCSTART</th>
                        <th class="th-get">ARCEND</th> -->

                        <th class="th-hidden">SQLMSG</th>
                        <th class="th-hidden">SQLSTR</th>

                        <c:choose>
                            <c:when test="${steptype eq 'EXE_MIGRATE' || steptype eq 'EXE_SCRAMBLE' || steptype eq 'EXE_ILM' || steptype eq 'EXE_SYNC'}">
                                <th class="th-get">Details</th>
                            </c:when>
                            <c:otherwise>
                            </c:otherwise>
                        </c:choose>

                    </tr>
                    </thead>
                    <tbody id="piiordersteptable-body">
                        <c:forEach items="${liststeptable}" var="piiordersteptable">
                        <tr>
                            <td class="td-hidden"><c:out value="${piiordersteptable.orderid}"/></td>
                            <td class="td-hidden"><c:out value="${piiordersteptable.stepid}"/></td>
                            <td class="td-hidden"><c:out value="${piiordersteptable.seq1}"/></td>
                            <td class="td-hidden"><c:out value="${piiordersteptable.seq2}"/></td>
                            <td class="td-hidden"><c:out value="${piiordersteptable.seq3}"/></td>
                            <td class="td-get-sm">
                                <c:choose>
                                    <c:when test="${piiordersteptable.status eq 'Ended OK' }"><span
                                            style="font-size: 11px;" class="badge badge-success"><%--<c:out
                                            value="${piiordersteptable.status}"/>--%>OK</span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Ended not OK' }"><span
                                            style="font-size: 11px;" class="badge badge-danger">Error</span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Running' }"><span
                                            style="font-size: 11px;" class="badge badge-primary"><i
                                            class="fa fa-spinner fa-spin"></i>Run</span></c:when>
                                    <c:when test="${piiordersteptable.status eq 'Wait condition' }"><span
                                            style="font-size: 11px;" class="badge badge-secondary">Wait</span></c:when>
                                    <%--<c:when test="${piiordersteptable.status eq 'Recovered' }"><span
                                            style="font-size: 11px;" class="badge badge-info"><c:out
                                            value="${piiordersteptable.status}"/></span></c:when>--%>
                                    <c:when test="${piiordersteptable.status eq 'Hold' }"><span style="font-size: 11px;"
                                                                                                class="badge badge-warning"><c:out
                                            value="${piiordersteptable.status}"/></span></c:when>
                                    <c:otherwise><span class="badge badge-light"><c:out
                                            value="${piiordersteptable.status}"/></span></c:otherwise>
                                </c:choose>
                            </td>
                                <%-- <td class="td-get-sm"><c:out value="${piiordersteptable.stepid}"/></td> --%>
                            <c:choose>
                                <c:when test="${steptype eq 'GEN_KEYMAP'}">
                                    <td class="td-get-sm-l"><c:out value="${piiordersteptable.pk_col}"/></td>
                                    <td class="td-get-sm-l"><c:out value="${piiordersteptable.preceding}"/></td>
                                    <td class="td-get-sm-l"><c:out value="${piiordersteptable.succedding}"/></td>
                                </c:when>
                                <c:when test="${steptype eq 'EXE_EXTRACT'}">
                                    <td class="td-get-sm">
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
                                            <c:otherwise> <c:out value="${piisteptable.pagitypedetail}"/> </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="td-get-sm-l"><c:out value="${piiordersteptable.pk_col}"/></td>
                                </c:when>
                                <c:otherwise>
                                    <td class="td-hidden"><c:out value="${piiordersteptable.preceding}"/></td>
                                    <td class="td-hidden"><c:out value="${piiordersteptable.succedding}"/></td>
                                </c:otherwise>
                            </c:choose>
                            <td class="td-get-sm"><c:out value="${piiordersteptable.db}"/></td>
                            <c:choose>
                                <c:when test="${steptype eq 'GEN_KEYMAP' || steptype eq 'EXE_EXTRACT'}">
                                </c:when>
                                <c:otherwise>
                                    <td class="td-get-sm"><c:out value="${piiordersteptable.owner}"/></td>
                                    <td class="td-get-sm-l"><c:out value="${piiordersteptable.table_name}"/></td>
                                </c:otherwise>
                            </c:choose>

                            <td class="td-get-sm-r"><c:out value="${piiordersteptable.execnt}"/></td>
                            <td class="td-get-sm"><c:out value="${piiordersteptable.exetime}"/></td>
                            <td class="td-get-sm"><%--<c:out value="${piiordersteptable.exestart}"/>--%><c:out value="${fn:substring(piiordersteptable.exestart, 5, fn:length(piiordersteptable.exestart))}" />
                            </td>
                                <%-- <td class="td-get-sm"><c:out value="${piiordersteptable.exeend}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piiordersteptable.pagitype}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.pagitypedetail}"/></td> --%>
                                <%-- <td class="td-get-sm"><c:out value="${piiordersteptable.exetype}"/></td> --%><%--
									<td class="td-get-sm"><c:out value="${piiordersteptable.archiveflag}"/></td>
									<td class="td-get-sm"><c:out value="${piiordersteptable.preceding}"/></td>
									<td class="td-get-sm"><c:out value="${piiordersteptable.succedding}"/></td> --%>
                            <c:choose>
                                <c:when test="${steptype eq 'GEN_KEYMAP'}">
                                    <td class="td-get-sm-r"><c:out value="${piiordersteptable.seq2}"/></td>
                                    <td class="td-get-sm-r"><c:out value="${piiordersteptable.seq3}"/></td>
                                </c:when>
                                <c:otherwise>
                                    <td class="td-get-sm-r"><c:out value="${piiordersteptable.seq2}"/></td>
                                </c:otherwise>
                            </c:choose>
                                <%--<td class="td-get-sm"><c:out value="${piiordersteptable.pipeline}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.where_col}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.parallelcnt}"/></td> --%>
                                <%--
                                <td class="td-get-sm"><c:out value="${piiordersteptable.arccnt}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.arctime}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.arcstart}"/></td>
                                <td class="td-get-sm"><c:out value="${piiordersteptable.arcend}"/></td> --%>

                            <td class="td-hidden"><c:out value="${piiordersteptable.sqlmsg}"/></td>
                            <td class="td-hidden"><c:out value="${piiordersteptable.sqlstr}"/></td>
                            <c:choose>
                                <c:when test="${steptype eq 'EXE_MIGRATE' || steptype eq 'EXE_SCRAMBLE' || steptype eq 'EXE_ILM' || steptype eq 'EXE_SYNC'}">
                                    <td class="td-get-sm icon-container" style="cursor: pointer;"
                                        onclick="getinnersteplist(<c:out value="${piiordersteptable.orderid}"/>, '<c:out value="${piiordersteptable.stepid}"/>', <c:out value="${piiordersteptable.seq1}"/>, <c:out value="${piiordersteptable.seq2}"/>, <c:out value="${piiordersteptable.seq3}"/>)"
                                    >
                                        <i class="fa-regular fa-file-lines icon-color"></i>
                                    </td>
                                </c:when>
                                <c:otherwise>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div><!-- <div class="table-responsive"> -->
            <div class="sql-detail-panel">
                <div id="moredetail"></div>
            </div>
        </div>


    </div><!-- <div id="steps" class="step-container1 " style="width:100%"> -->

</div>
<!-- <div class="card shadow"> DataTales begin-->
<style>
    .icon-container {
        transition: background-color 0.3s;
    }
    .icon-container:hover {
        background-color: #f0f0f0;
    }
    .icon-color {
        color: #000000;
        transition: color 0.3s;
    }
    .icon-container:hover .icon-color {
        color: #ff0000;
    }

    /* ===== Order Detail Table Header Fix ===== */
    #jobdetailbody #listTable.table-hover thead th.th-get {
        background: #f8fafc !important;
        color: #475569 !important;
        font-weight: 700;
        font-size: 0.68rem;
        padding: 8px !important;
        border: none !important;
        border-bottom: 2px solid #cbd5e1 !important;
        text-transform: uppercase;
        letter-spacing: 0.03em;
        white-space: nowrap;
        position: sticky;
        top: 0;
        z-index: 10;
        box-shadow: inset 0 -2px 0 #cbd5e1, 0 -10px 0 #f8fafc;
    }

    #jobdetailbody #listTable.table-hover thead {
        position: sticky;
        top: 0;
        z-index: 10;
    }

    #jobdetailbody #listTable.table-hover tbody td {
        font-size: 0.72rem;
        padding: 5px 8px !important;
        color: #334155;
        border: none !important;
        border-bottom: 1px solid #f1f5f9 !important;
    }

    #jobdetailbody #listTable.table-hover tbody tr:nth-child(even) td {
        background: #fafbfc;
    }

    #jobdetailbody #listTable.table-hover tbody tr:hover td {
        background: #eff6ff !important;
    }

    #jobdetailbody #listTable.table-hover tbody tr:hover td:first-child {
        box-shadow: inset 3px 0 0 #3b82f6;
    }

    /* Selected row */
    #jobdetailbody #listTable.table-hover tbody tr.selected-row td {
        background: #dbeafe !important;
    }

    #jobdetailbody #listTable.table-hover tbody tr.selected-row td:first-child {
        box-shadow: inset 3px 0 0 #2563eb;
    }

    /* ===== SQL Detail Panel ===== */
    .sql-detail-panel {
        margin: 6px 4px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        overflow: hidden;
        background: #fff;
        flex: 1;
        min-height: 0;
        display: flex;
        flex-direction: column;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }

    .sql-detail-panel #moredetail {
        flex: 1;
        min-height: 0;
        display: flex;
        flex-direction: column;
    }

    .sql-error-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding: 6px 12px;
        background: linear-gradient(135deg, #fef2f2 0%, #fff1f2 100%);
        border-bottom: 1px solid #fecaca;
        border-left: 3px solid #dc2626;
        flex-shrink: 0;
    }

    .sql-error-msg {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.72rem;
        font-weight: 600;
        color: #dc2626;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        flex: 1;
        min-width: 0;
    }

    .sql-error-msg i {
        font-size: 0.72rem;
        flex-shrink: 0;
        animation: errorPulse 2s ease-in-out infinite;
    }

    @keyframes errorPulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.4; }
    }

    .sql-magnify-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 26px;
        height: 26px;
        border-radius: 6px;
        border: 1px solid #fecaca;
        background: #fff;
        color: #dc2626;
        cursor: pointer;
        transition: all 0.2s;
        flex-shrink: 0;
    }

    .sql-magnify-btn:hover {
        background: #dc2626;
        color: #fff;
        border-color: #dc2626;
        transform: scale(1.05);
        box-shadow: 0 2px 8px rgba(220,38,38,0.3);
    }

    .sql-magnify-btn i {
        font-size: 0.7rem;
    }

    .sql-code-area {
        width: 100%;
        flex: 1;
        min-height: 0;
        border: none;
        outline: none;
        resize: none;
        padding: 8px 12px;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 0.72rem;
        line-height: 1.5;
        color: #1e293b;
        background: #f8fafc;
        tab-size: 4;
    }

    /* ===== Magnify Modal Error Style ===== */
    #magnifymodalmsg {
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 0.82rem;
        line-height: 1.8;
        color: #991b1b;
        background: #fff;
        border: 1px solid #fecaca;
        border-left: 4px solid #dc2626;
        border-radius: 6px;
        padding: 16px 20px;
        word-break: break-all;
        white-space: pre-wrap;
        box-shadow: 0 2px 8px rgba(220,38,38,0.08);
    }
</style>

<!-- The Modal -->

<div class="modal" id="ordertabledetailmodal" <%--aria-hidden="true"--%> style="display: none; z-index: 1060;">
    <!--  <div class="modal fade" id="ordertabledetailmodal" role="dialog" style="z-index:1050;">-->
    <div class="modal-dialog modal-xl ">
        <div class="modal-content m-0 p-0">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">
                    <i class="fas fa-table mr-2"></i><spring:message code="modal.table.details" text="테이블 상세 정보"/>
                </h4>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom m-0 p-0" id="ordertabledetailbody">
                ordertabledetail Modal body..
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button onclick="javascript:$('#ordertabledetailmodal').modal('hide');"
                        class="btn btn-secondary btn-sm p-0 pb-2 button">Close
                </button>
            </div>

        </div>
    </div>
</div>
<div class="modal" id="innersteplistmodal" style="display: none; z-index: 1060;">
    <div class="modal-dialog modal-xl ">
        <div class="modal-content m-0 p-0">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified" id="innersteplistheader" >
                    Inner step details [Orderid : <c:out value="${piiorder.orderid}"/>]
                </h4>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom m-0 p-0" id="innersteplistbody">
                Inner step details Modal body..
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <!--<button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>-->
                <!--<a href="javascript:$('#innersteplistmodal').modal('hide');" class="btn">Close</a>-->
                <button onclick="javascript:$('#innersteplistmodal').modal('hide');"
                        class="btn btn-secondary btn-sm p-0 pb-2 button">Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<script>
    function scrollToLastErrorRow() {
        var rows = document.querySelectorAll('#piiordersteptable-body tr');
        var lastEndedNotOKRow = null;

        for (var i = rows.length - 1; i >= 0; i--) {
            var statusCell = rows[i].querySelector('td:nth-child(6)');
            //console.log(statusCell.textContent.trim());
            if (statusCell && (statusCell.textContent.trim() === 'Error' || statusCell.textContent.trim() === 'Run')) {
                lastEndedNotOKRow = rows[i];
                break;
            }
        }

        if (lastEndedNotOKRow) {
            lastEndedNotOKRow.scrollIntoView({ behavior: 'auto', block: 'end' });
        }
    };
</script>
<script type="text/javascript">
    $('#jobdetailmodal').on('shown.bs.modal', function () {
        /*setTimeout(function() {
            $('#steptab li:first').click();
        }, 300); // 0.1초 후에 실행*/
    });

    $(document).on('ready', function () {

    });

    var doubleSubmitFlag = false;
    $(function () {
        //$("#menupath").html(Menupath +">Details");
        //var selectedStepid = "";
        /* 	var refreshtime = $('#orderdetailForm [name="orderdetail_refresh"]').val();
            refresh = setTimeout(function(){  //alert("setTimeout(function(){ inside  "+$('#orderdetailForm [name="orderdetail_stepseq"]').val());
                searchStatusAction();

                //alert($('#orderdetailForm [name="orderdetail_stepseq"]').val());
                }, refreshtime); */

    });

    $(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });
    $(document).on('hidden.bs.modal', '#requestmodal', function (e) {
        e.preventDefault();e.stopPropagation();
        if (doubleSubmitFlag) {
            doubleSubmitFlag = false;
            requestApproval();
        }
    });
</script>

<script type="text/javascript">

    $("#steptab li").click(function (e) {
        e.preventDefault();e.stopPropagation();

        //clearTimeout(refresh);

        $("#steptab li").each(function () {
            $(this).removeClass("active");
        });
        $(this).addClass("active");


        var orderid = $('#orderdetailForm [name="orderdetail_orderid"]').val();
        var jobid = $('#orderdetailForm [name="orderdetail_jobid"]').val();
        var version = $('#orderdetailForm [name="orderdetail_version"]').val();
        //var refreshtime = $('#orderdetailForm [name="orderdetail_refresh"]').val();
        var stepseq = $(this).attr("name");//$(this).attr("id");
        var stepcount = $(this).attr("id");
        $('#orderdetailForm [name="orderdetail_stepseq"]').val(stepseq);
        //alert('#orderdetailForm [name="orderdetail_stepseq"]====  '+  $('#orderdetailForm [name="orderdetail_stepseq"]').val());

        var url_search = "";
        var url_view = "getorderdetail?"
            + "orderid=" + orderid + "&"
            + "jobid=" + jobid + "&"
            + "version=" + version + "&"
            + "stepseq=" + stepseq
            + "&action=" + "<c:out value='${action}'/>"
        ;
        //alert(url_view);
        $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                //$('#jobdetailheader').html(jobid+"(V "+version+")");
                //$('#jobdetailheader').html(jobid+"(V "+version+") > "+stepseq+"."+stepid);
                $('#jobdetailbody').html(data);
                $("#" + stepcount).addClass("active");
                $('#orderdetailForm [name="orderdetail_stepseq"]').val(stepseq);
                //$('#orderdetailForm [name="orderdetail_refresh"]').val(refreshtime);

                scrollToLastErrorRow();
            }
        });

    });

    $('#piiordersteptable-body').on('dblclick', 'tr', function (e) {
        e.preventDefault();e.stopPropagation();
        var str = ""
        var tdArr = new Array();

        var tr = $(this);
        var td = tr.children();

        $('#piiordersteptable-body > tr').removeClass('selected-row').css("background-color", "");
        tr.addClass('selected-row');

        var orderid = td.eq(0).text();
        var stepid = td.eq(1).text();
        var seq1 = td.eq(2).text();
        var seq2 = td.eq(3).text();
        var seq3 = td.eq(4).text();

        getordertable(orderid, stepid, seq1, seq2, seq3);

    });

    $('#piiordersteptable-body').on('click', 'tr', function (e) {
        e.preventDefault();e.stopPropagation();
        var str = ""
        var tdArr = new Array();

        var tr = $(this);
        var td = tr.children();

        $('#piiordersteptable-body > tr').removeClass('selected-row').css("background-color", "");
        tr.addClass('selected-row');

        var json = {
            orderid: td.eq(0).text(),
            stepid: td.eq(1).text(),
            seq1: td.eq(2).text(),
            seq2: td.eq(3).text(),
            seq3: td.eq(4).text()
        };

        $.ajax({
            url: "/piiorder/getStepTableStr",
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
                //$("#GlobalSuccessMsgModal").modal("show");
                //$('#sqlmsg').html(data);
                //$('#sqlstr').html(data);
                $('#moredetail').html(data);
            }
        });

    });

    $("button[data-oper='list']").on("click", function (e) {
        e.preventDefault();e.stopPropagation();
        var pagenum = $('#searchForm [name="pagenum"]').val();
        //var amount  = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="search1"]').val();
        var search2 = $('#searchForm [name="search2"]').val();
        var url_search = "";

        if (isEmpty(pagenum)) pagenum = 1;
        if (isEmpty(amount)) amount = 10000;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1
        }
        ;
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2
        }
        ;

        //alert("/piiorder/list?pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
            type: "GET",
            url: "/piiorder/list?pagenum="
                + pagenum + "&amount="
                + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();//alert("통신성공!!!!");
                $('#content_home').html(data);
            }
        });

    });

    searchStatusAction = function () {
        var orderid = $('#orderdetailForm [name="orderdetail_orderid"]').val();
        var jobid = $('#orderdetailForm [name="orderdetail_jobid"]').val();
        var version = $('#orderdetailForm [name="orderdetail_version"]').val();
        var stepseq = $('#orderdetailForm [name="orderdetail_stepseq"]').val();
        //var refreshtime = $('#orderdetailForm [name="orderdetail_refresh"]').val();

        $("#steptab li").each(function () {
            $("#" + stepseq).removeClass("active");
        });
        $("#" + stepseq).addClass("active");

        //var stepseq = $("#" + stepid).attr("id");
        var stepid = $("#" + stepid).attr("name");
        var url_search = "";
        var url_view = "getorderdetail?"
            + "orderid=" + orderid + "&"
            + "jobid=" + jobid + "&"
            + "version=" + version + "&"
            + "stepseq=" + stepseq
            + "&action=" + "<c:out value='${action}'/>"
        ;
        //alert(url_view);
        $.ajax({
            type: "GET",
            url: "/piiorder/" + url_view,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#jobdetailheader').html(jobid + "(V " + version + ")");
                //$('#jobdetailheader').html(jobid+"(V "+version+") > "+stepseq+"."+stepid);
                $('#jobdetailbody').html(data);
                $("#" + stepseq).addClass("active");
                $('#orderdetailForm [name="orderdetail_stepseq"]').val(stepseq);
                //$('#orderdetailForm [name="orderdetail_refresh"]').val(refreshtime);
            }
        });
    }

    getordertable = function (orderid, stepid, seq1, seq2, seq3) {

        var action = "<c:out value='${action}'/>";
        var url_search = "";
        var url_view = "";
        if (action == 1) {
            url_view = "getordertable?";
        } else {
            url_view = "modifyordertable?";
        }
        url_view = url_view
            + "orderid=" + orderid + "&"
            + "stepid=" + stepid + "&"
            + "seq1=" + seq1 + "&"
            + "seq2=" + seq2 + "&"
            + "seq3=" + seq3 + "&"
        ;
        var pagenum = 1;
        var amount = 10000;

        //alert("/piiorder/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
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
                $('#ordertabledetailbody').html(data);
                $("#ordertabledetailmodal").modal();
            }
        });

    }

    getinnersteplist = function (orderid, stepid, seq1, seq2, seq3) {

        var url_search = "";
        var url_view = "getinnersteplist?";
        url_view = url_view
            + "orderid=" + orderid + "&"
            + "stepid=" + stepid + "&"
            + "seq1=" + seq1 + "&"
            + "seq2=" + seq2 + "&"
            + "seq3=" + seq3 + "&"
        ;
        var pagenum = 1;
        var amount = 10000;

        //alert("/piiorder/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        $.ajax({
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
                $('#innersteplistbody').html(data);
                $("#innersteplistmodal").modal();
            }
        });

    }

    magnify = function () {
        $("#magnifymodalmsg").html("" + $('#orderdetailsqlmsg').text() + "");
        $("#magnifymodal").modal("show");
        // backdrop을 magnifymodal 바로 아래 z-index로 설정
        setTimeout(function() {
            $('.modal-backdrop').last().css('z-index', 1065);
        }, 10);
    }
</script>


