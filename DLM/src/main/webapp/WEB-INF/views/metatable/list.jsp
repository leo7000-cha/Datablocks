<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- Policy Management CSS -->
<link rel="stylesheet" href="/resources/css/piipolicy-refactor.css">

<!-- Hidden Form for pagination -->
<form style="display:none;" role="form" id="searchForm">
    <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
    <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
</form>

<!-- Main Container -->
<div class="policy-management-container" id="metatablelist">

    <!-- ========== PAGE HEADER ========== -->
    <div class="page-header-bar">
        <div class="page-header-title">
            <i class="fas fa-database"></i>
            <span><spring:message code="memu.tablemata_mgmt" text="Table Meta"/></span>
        </div>
        <!-- Stats Section (가운데) -->
        <div style="display: flex; gap: 10px; align-items: center;">
            <div style="display: flex; align-items: center; gap: 6px; padding: 6px 12px; background: #f1f5f9; border-radius: 6px;">
                <i class="fas fa-table" style="color: #3b82f6; font-size: 12px;"></i>
                <span style="font-size: 11px; color: #64748b;">테이블</span>
                <span style="font-size: 13px; font-weight: 700; color: #1e293b;">${stats.tableCount}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 6px; padding: 6px 12px; background: #f1f5f9; border-radius: 6px;">
                <i class="fas fa-columns" style="color: #8b5cf6; font-size: 12px;"></i>
                <span style="font-size: 11px; color: #64748b;">칼럼</span>
                <span style="font-size: 13px; font-weight: 700; color: #1e293b;">${stats.columnCount}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 6px; padding: 6px 12px; background: #dcfce7; border-radius: 6px;">
                <i class="fas fa-check-circle" style="color: #22c55e; font-size: 12px;"></i>
                <span style="font-size: 11px; color: #64748b;">확인</span>
                <span style="font-size: 13px; font-weight: 700; color: #16a34a;">${stats.verifiedCount}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 6px; padding: 6px 12px; background: #fef3c7; border-radius: 6px;">
                <i class="fas fa-clock" style="color: #f59e0b; font-size: 12px;"></i>
                <span style="font-size: 11px; color: #64748b;">미확인</span>
                <span style="font-size: 13px; font-weight: 700; color: #d97706;">${stats.unverifiedCount}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 6px; padding: 6px 12px; background: #fce7f3; border-radius: 6px;">
                <i class="fas fa-user-shield" style="color: #ec4899; font-size: 12px;"></i>
                <span style="font-size: 11px; color: #64748b;">개인정보</span>
                <span style="font-size: 13px; font-weight: 700; color: #db2777;">${stats.piiCount}</span>
            </div>
        </div>
        <div class="page-header-breadcrumb">
            <span class="breadcrumb-item"><spring:message code="memu.meta_configuration" text="Meta"/></span>
            <i class="fas fa-chevron-right"></i>
            <span class="breadcrumb-item active"><spring:message code="memu.tablemata_mgmt" text="Table Meta 정보 관리"/></span>
        </div>
    </div>

    <!-- ========== FILTER SECTION ========== -->
    <div class="policy-filter-section">
        <div class="policy-filter-row" style="flex-wrap: nowrap;">
            <div style="display: flex; gap: 8px; flex: 1; align-items: flex-end; flex-wrap: wrap;">
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search1">DB</label>
                    <select class="policy-filter-select" name="search1" id="filter_search1" style="width: 80px;" onchange="updateOwnerList(); searchAction(1);">
                        <option value=""></option>
                        <c:set var="prevDb" value="" />
                        <c:forEach items="${dbOwnerList}" var="item">
                            <c:if test="${item.db != prevDb && item.db != 'DLM' && item.db != 'DLMARC'}">
                                <option value="${item.db}" <c:if test="${pageMaker.cri.search1 eq item.db}">selected</c:if>>${item.db}</option>
                                <c:set var="prevDb" value="${item.db}" />
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search2">Owner</label>
                    <select class="policy-filter-select" name="search2" id="filter_search2" style="width: 100px;" onchange="searchAction(1);">
                        <option value=""></option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search3">Table</label>
                    <input type="text" class="policy-filter-input" id="filter_search3" name="search3" style="width: 120px;"
                           placeholder="%, _"
                           title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR"
                           onkeyup="characterCheck(this);$(this).val($(this).val().toUpperCase());"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search3}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search4">Column</label>
                    <input type="text" class="policy-filter-input" id="filter_search4" name="search4" style="width: 120px;"
                           placeholder="%, _"
                           title="와일드카드: % = 여러문자, _ = 한문자. 예: %ACTEUR%, ACTEUR"
                           onkeyup="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search4}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search10"><spring:message code="col.column_comment" text="Column Comment"/></label>
                    <input type="text" class="policy-filter-input" id="filter_search10" name="search10" style="width: 160px;"
                           placeholder="%, _"
                           title="와일드카드: % = 여러문자, _ = 한문자. 예: %이름%, 이름"
                           onkeyup="characterCheck(this)"
                           onkeypress="if (event.keyCode === 13) {event.preventDefault();searchAction(1);}"
                           value='<c:out value="${pageMaker.cri.search10}"/>'>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search5"><spring:message code="col.enc_yn" text="Encrypted"/></label>
                    <select class="policy-filter-select" id="filter_search5" name="search5" style="width: 60px;" onchange="searchAction(1);">
                        <option value="">-</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search5 eq 'Y'}">selected</c:if>>Y</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search7"><spring:message code="col.piitype" text="개인정보타입"/></label>
                    <select class="policy-filter-select" id="filter_search7" name="search7" style="width: 150px;" onchange="searchAction(1);">
                        <option value="">-</option>
                        <option value="PII" <c:if test="${pageMaker.cri.search7 eq 'PII'}">selected</c:if>>Y</option>
                        <option value="NOTPII" <c:if test="${pageMaker.cri.search7 eq 'NOTPII'}">selected</c:if>>N</option>
                        <c:forEach var="item" items="${listlkPiiScrType}">
                            <option value="${item.piicode}" <c:if test="${pageMaker.cri.search7 eq item.piicode}">selected</c:if>>${item.piitypename}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search8"><spring:message code="col.scramble" text="스크램블"/></label>
                    <select class="policy-filter-select" id="filter_search8" name="search8" style="width: 60px;" onchange="searchAction(1);">
                        <option value="">-</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search8 eq 'Y'}">selected</c:if>>Y</option>
                        <option value="N" <c:if test="${pageMaker.cri.search8 eq 'N'}">selected</c:if>>N</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search16" style="color:#8b5cf6;"><spring:message code="etc.metapiiinfo" text="개인정보탐지"/></label>
                    <select class="policy-filter-select" id="filter_search16" name="search16" style="width: 90px;" onchange="searchAction(1);">
                        <option value="">-</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search16 eq 'Y'}">selected</c:if>><spring:message code="etc.detected" text="탐지됨"/></option>
                        <option value="N" <c:if test="${pageMaker.cri.search16 eq 'N'}">selected</c:if>><spring:message code="etc.notdetected" text="미탐지"/></option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search15" style="color:#04862C;"><spring:message code="etc.verify_flag" text="확인완료"/></label>
                    <select class="policy-filter-select" id="filter_search15" name="search15" style="width: 60px;" onchange="searchAction(1);">
                        <option value="">-</option>
                        <option value="Y" <c:if test="${pageMaker.cri.search15 eq 'Y'}">selected</c:if>>Y</option>
                        <option value="N" <c:if test="${pageMaker.cri.search15 eq 'N'}">selected</c:if>>N</option>
                    </select>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search12" style="color:#B28709;"><spring:message code="col.updatedate" text="수정일"/></label>
                    <div style="display: flex; align-items: center; gap: 2px;">
                        <input type="text" class="policy-filter-input" id="filter_search12" name="search12" style="width: 85px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search12}"/>' autocomplete="off">
                        <span style="color: #94a3b8;">~</span>
                        <input type="text" class="policy-filter-input" id="filter_search13" name="search13" style="width: 85px;"
                               maxlength="10" value='<c:out value="${pageMaker.cri.search13}"/>' autocomplete="off">
                    </div>
                </div>
                <div class="policy-filter-item">
                    <label class="policy-filter-label" for="filter_search11" style="color:#800000;"><spring:message code="etc.orderby" text="Order by"/></label>
                    <select class="policy-filter-select" id="filter_search11" name="search11" style="width: 140px;" onchange="searchAction(1);">
                        <option value="R" <c:if test="${pageMaker.cri.search11 eq 'R'}">selected</c:if>><spring:message code="etc.regdate_desc" text="등록일(최신순)"/></option>
                        <option value="U" <c:if test="${pageMaker.cri.search11 eq 'U'}">selected</c:if>><spring:message code="etc.upddate_desc" text="수정일(최신순)"/></option>
                        <option value="V" <c:if test="${pageMaker.cri.search11 eq 'V'}">selected</c:if>><spring:message code="etc.verifydate_desc" text="확인일(최신순)"/></option>
                    </select>
                </div>
            </div>
            <div class="policy-filter-actions">
                <button data-oper='verify' class="btn btn-filter-action-important" id="btnVerify" disabled>
                    <i class="fa-solid fa-circle-check"></i> <span><spring:message code="etc.verify" text="Verify"/></span>
                </button>
                <button data-oper='search' class="btn btn-filter-search">
                    <i class="fas fa-search"></i> <spring:message code="btn.search" text="Search"/>
                </button>
                <button data-oper='exceldownload' class="btn btn-filter-excel">
                    <i class="fas fa-download"></i> <spring:message code="btn.excel" text="EXCEL"/>
                </button>
                <button data-oper='excelupload' class="btn btn-filter-register">
                    <i class="fas fa-upload"></i> UPLOAD
                </button>
            </div>
        </div>
    </div>

    <!-- ========== DATA TABLE ========== -->
    <div class="policy-table-section">
        <div class="policy-table-wrapper">
            <table class="policy-table" id="listTable">
                <thead>
                <tr>
                    <th style="width: 40px;"><input type="checkbox" class="chkBox" id="checkall" style="vertical-align:middle;width:15px;height:15px;"></th>
                    <th><spring:message code="col.db" text="DB"/></th>
                    <th><spring:message code="col.owner" text="Owner"/></th>
                    <th><spring:message code="col.table_name" text="Table_Name"/></th>
                    <th><spring:message code="col.column_name" text="Column_Name"/></th>
                    <th><spring:message code="col.column_comment" text="Column Comment"/></th>
                    <th><spring:message code="col.column_id" text="Col_Id"/></th>
                    <th>PK</th>
                    <th><spring:message code="col.data_type" text="Type"/></th>
                    <th><spring:message code="col.data_length" text="Length"/></th>
                    <th><spring:message code="col.domain" text="Domain"/></th>
                    <th class="th-purple"><spring:message code="etc.metapiiinfo" text="PII Meta"/></th>
                    <th class="th-blue"><spring:message code="col.encript_flag" text="Encript"/></th>
                    <th class="th-blue"><spring:message code="col.piigrade" text="Grade"/></th>
                    <th class="th-blue"><spring:message code="col.piitype" text="PiiType"/></th>
                    <th class="th-blue"><spring:message code="col.scramble_type" text="Scramble"/></th>
                    <th class="th-blue"><spring:message code="col.masterkey" text="Parent Key"/></th>
                    <th class="th-blue"><spring:message code="col.masteryn" text="Parent YN"/></th>
                    <th class="th-green"><spring:message code="etc.verifydate" text="Verified"/></th>
                    <th class="th-brown"><spring:message code="col.updatedate" text="Update"/></th>
                </tr>
                </thead>
                <tbody id="metatable-body">
                <c:forEach items="${list}" var="metatable">
                    <tr>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${empty metatable.val3}">
                                    <input type="checkbox" class="chkBox" name="chkBox" onClick="checkedRowColorChange();"
                                           style="vertical-align:middle;width:15px;height:15px;">
                                </c:when>
                                <c:otherwise>&nbsp;</c:otherwise>
                            </c:choose>
                        </td>
                        <td><c:out value="${metatable.db}"/></td>
                        <td><c:out value="${metatable.owner}"/></td>
                        <td><c:out value="${metatable.table_name}"/></td>
                        <td><c:out value="${metatable.column_name}"/></td>
                        <td><c:out value="${metatable.column_comment}"/></td>
                        <td class="text-right"><c:out value="${metatable.column_id}"/></td>
                        <td class="text-center"><c:out value="${metatable.pk_yn}"/></td>
                        <td><c:out value="${metatable.data_type}"/></td>
                        <td class="text-right"><c:out value="${metatable.data_length}"/></td>
                        <td><c:out value="${metatable.domain}"/></td>
                        <td class="pii-discovery-cell">
                            <c:choose>
                                <c:when test="${not empty metatable.val2 && fn:contains(metatable.val2, '|')}">
                                    <c:set var="piiParts" value="${fn:split(metatable.val2, '|')}"/>
                                    <span class="pii-discovery-badge"
                                          onclick="showPiiDetailsModal('${metatable.db}', '${metatable.owner}', '${metatable.table_name}', '${metatable.column_name}')"
                                          style="cursor: pointer; background: linear-gradient(135deg, #8b5cf6, #6366f1); color: white; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 500; display: inline-flex; align-items: center; gap: 4px;"
                                          title="${metatable.val2} - 클릭하여 상세 보기">
                                        <i class="fas fa-shield-alt" style="font-size: 10px;"></i>
                                        <span class="pii-type">${piiParts[0]}</span>
                                        <span class="pii-score" style="background: rgba(255,255,255,0.2); padding: 1px 5px; border-radius: 8px; font-size: 10px;">${piiParts[1]}</span>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${metatable.val2}"/>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center"><c:out value="${metatable.encript_flag}"/></td>
                        <td class="text-center"><c:out value="${metatable.piigrade}"/></td>
                        <td>
                            <c:forEach var="item" items="${listlkPiiScrType}">
                                <c:if test="${metatable.piitype eq item.piicode}">
                                    <c:out value="${item.piitypename}"/>
                                </c:if>
                            </c:forEach>
                        </td>
                        <td><c:out value="${metatable.scramble_type}"/></td>
                        <td><c:out value="${metatable.masterkey}"/></td>
                        <td class="text-center"><c:out value="${metatable.masteryn}"/></td>
                        <td class="text-center"><c:out value="${metatable.val3}"/></td>
                        <td class="text-center"><c:out value="${metatable.upddate}"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <div class="policy-pagination-section">
        <%@include file="../includes/pager.jsp" %>
    </div>
</div>

<!-- Processing Modal -->
<div class="modal fade" id="processing" role="dialog">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-body modal-body-custom" id="ordermodalbody">
                <h6 class="ml-2">Processing.......</h6>
            </div>
        </div>
    </div>
</div>

<!-- Upload Modal -->
<div class="modal fade" id="uploadmodal" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 450px;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden;">
            <div class="modal-header" style="background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%); padding: 16px 24px; border: none;">
                <h5 class="modal-title" style="color: #fff; font-weight: 600; font-size: 1.1rem;">
                    <i class="fas fa-cloud-upload-alt"></i> Meta Data Upload
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 24px;">
                <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; padding: 12px 16px; margin-bottom: 20px;">
                    <p style="margin: 0; font-size: 0.875rem; color: #1e40af;">
                        <i class="fas fa-info-circle"></i> <span style="color: #2563eb; font-weight: 600;">파란색</span> 텍스트 정보가 업데이트됩니다.
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

<form style="margin: 0; padding: 0;" id="form1" name="form1" method="post" enctype="multipart/form-data">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    // DB-Owner 목록 데이터
    var dbOwnerList = [
        <c:forEach items="${dbOwnerList}" var="item" varStatus="status">
        { db: '${item.db}', owner: '${item.owner}' }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    var selectedSearch2 = '<c:out value="${pageMaker.cri.search2}"/>';

    // DB 선택시 Owner 목록 업데이트
    function updateOwnerList() {
        var selectedDb = $('#filter_search1').val();
        var ownerSelect = $('#filter_search2');
        ownerSelect.empty();
        ownerSelect.append('<option value=""></option>');

        if (selectedDb) {
            var owners = dbOwnerList
                .filter(function(item) { return item.db === selectedDb; })
                .map(function(item) { return item.owner; });
            // 중복 제거
            owners = [...new Set(owners)];
            owners.forEach(function(owner) {
                var selected = (owner === selectedSearch2) ? ' selected' : '';
                ownerSelect.append('<option value="' + owner + '"' + selected + '>' + owner + '</option>');
            });
        }
    }

    // 페이지 로드시 Owner 목록 초기화
    $(document).ready(function() {
        updateOwnerList();
    });

    // Flatpickr for date pickers
    flatpickr("#filter_search12", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    flatpickr("#filter_search13", {
        locale: "ko",
        dateFormat: "Y/m/d",
        allowInput: true,
        onChange: function(selectedDates, dateStr, instance) {
            instance._input.blur();
        }
    });

    function checkedRowColorChange() {
        jQuery("#metatable-body > tr").css("background-color", "#FFFFFF");
        var checkbox = $("input:checkbox[name=chkBox]:checked");
        checkbox.each(function (i) {
            checkbox.parent().parent().eq(i).css("background-color", "#E2E8F9");
        });

        // Enable/disable action button based on selection
        if (checkbox.length > 0) {
            $("#btnVerify").prop("disabled", false);
        } else {
            $("#btnVerify").prop("disabled", true);
        }
    }

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        $("#checkall").click(function () {
            if ($("#checkall").prop("checked")) {
                $("input[name=chkBox]").prop("checked", true);
            } else {
                $("input[name=chkBox]").prop("checked", false);
            }
        });

        $("button[data-oper='exceldownload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doExcelTemplateDownload();
        });

        $("button[data-oper='excelupload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $("#uploadmodal").modal();
            $('#uploadFileInput').val("");
            $('#uploadresult').html("");
            $('#selectedFileInfo').hide();
            $('#uploadDropZone').show();
        });

        // File drop zone interactions
        var dropZone = $('#uploadDropZone');

        dropZone.on('click', function() {
            $('#uploadFileInput').click();
        });

        dropZone.on('dragover', function(e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).css({
                'border-color': '#3b82f6',
                'background': '#eff6ff'
            });
        });

        dropZone.on('dragleave', function(e) {
            e.preventDefault();
            e.stopPropagation();
            $(this).css({
                'border-color': '#cbd5e1',
                'background': '#f8fafc'
            });
        });

        dropZone.on('drop', function(e) {
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

        $('#uploadFileInput').on('change', function() {
            if (this.files.length > 0) {
                showSelectedFile(this.files[0]);
            }
        });

        $('#removeFileBtn').on('click', function(e) {
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

        $("button[data-oper='upload']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            doubleSubmitFlag = true;
            var formData = new FormData();
            var inputFile = $("#uploadFileInput");
            var files = inputFile[0].files;

            formData.append("uploadFile", files[0]);
            if (files.length == 0) {
                alert("Choose the upload file");
                return false;
            } else if (files.length > 1) {
                alert("Choose only one file");
                return false;
            }

            for (var i = 0; i < files.length; i++) {
                if (!$('#uploadFileInput').val().toUpperCase().endsWith(".XLS") && !$('#uploadFileInput').val().toUpperCase().endsWith(".XLSX")) {
                    alert("Only EXCEL file type can be uploaded.");
                    return false;
                }
                formData.append("uploadFile", files[i]);
            }

            $.ajax({
                url: "/piiupload/uploadMetadata",
                processData: false,
                contentType: false,
                data: formData,
                type: 'POST',
                dataType: "application/json",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data, textStatus, jqXHR) {
                    ingHide();
                    if (data.indexOf("successfully") != -1) {
                        $("#uploadmodal").modal("hide");
                        $("#messagemodalbody").html("<p class='text-success' style='font-size: 14px;'>" + data + "</p>");
                        $("#messagemodal").modal("show");
                        setTimeout(function () { searchAction(1); }, 1000);
                    } else {
                        $("#errormodalbody").html(data);
                        $("#errormodal").modal("show");
                    }
                },
                error: function (request, error) {
                    ingHide();
                    if (request.responseText.indexOf("successfully") != -1) {
                        $("#uploadmodal").modal("hide");
                        $("#messagemodalbody").html("<p class='text-success' style='font-size: 14px;'>" + request.responseText + "</p>");
                        $("#messagemodal").modal("show");
                        setTimeout(function () { searchAction(1); }, 1000);
                    } else {
                        $("#errormodalbody").html(request.responseText);
                        $("#errormodal").modal("show");
                    }
                }
            });
        });

        $("button[data-oper='verify']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            var param = [];
            var tr, td;
            var checkbox = $("input:checkbox[name=chkBox]:checked");

            checkbox.each(function (i) {
                tr = checkbox.parent().parent().eq(i);
                td = tr.children();
                var data = {
                    db: td.eq(1).text(),
                    owner: td.eq(2).text(),
                    table_name: td.eq(3).text(),
                    column_name: td.eq(4).text(),
                    column_id: null, pk_yn: null, pk_position: null, full_data_type: null,
                    data_type: null, data_length: null, domain: null, piitype: null,
                    piigrade: null, encript_flag: null, scramble_type: null,
                    regdate: null, upddate: null, reguserid: null, upduserid: null,
                    masterkey: null, masteryn: null, table_comment: null, column_comment: null,
                    val1: null, val2: null, val3: null, val4: null
                };
                param.push(data);
            });

            $.ajax({
                url: "/metatable/verify",
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                type: "post",
                data: JSON.stringify(param),
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data, textStatus, jqXHR) {
                    ingHide();
                    $("#GlobalSuccessMsgModal").modal("show");
                    searchAction(1);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        $('#listTable tbody').on('dblclick', 'tr', function (e) {
            e.preventDefault();
            e.stopPropagation();
            var selectedRow = $(this);
            var td = selectedRow.children();

            var pagenum = $('#searchForm [name="pagenum"]').val();
            var amount = 10000;
            var search1 = td.eq(1).text();
            var search2 = td.eq(2).text();
            var search3 = td.eq(3).text();
            var search4 = td.eq(4).text();
            var url_search = "";

            if (isEmpty(pagenum)) pagenum = 1;
            if (!isEmpty(search1)) url_search += "&search1=" + search1;
            if (!isEmpty(search2)) url_search += "&search2=" + search2;
            if (!isEmpty(search3)) url_search += "&search3=" + search3;
            if (!isEmpty(search4)) url_search += "&search4=" + search4;

            ingShow();
            $.ajax({
                type: "GET",
                url: "/metatable/modifydialog?pagenum=" + pagenum + "&amount=" + amount + url_search,
                dataType: "html",
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                },
                success: function (data) {
                    ingHide();
                    $('#dialogmetadataupdatebody').html(data);
                    $("#dialogmetadataupdate").modal();
                }
            });
        });

        $("button[data-oper='search']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            searchAction(1);
        });
    });

    function doExcelTemplateDownload() {
        var f = document.form1;
        var url_search = "";
        var pagenum = 1;
        var amount = 200000;

        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();
        var search9 = $('#filter_search9').val();
        var search10 = $('#filter_search10').val();
        var search11 = $('#filter_search11').val();
        var search12 = $('#filter_search12').val();
        var search13 = $('#filter_search13').val();
        var search14 = $('#filter_search14').val();
        var search15 = $('#filter_search15').val();

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) { url_search += "&search4=" + search4; search5 = "Y"; }
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;
        if (!isEmpty(search10)) url_search += "&search10=" + search10;
        if (!isEmpty(search11)) url_search += "&search11=" + search11;
        if (!isEmpty(search12)) url_search += "&search12=" + search12;
        if (!isEmpty(search13)) url_search += "&search13=" + search13;
        if (!isEmpty(search14)) url_search += "&search14=" + search14;
        if (!isEmpty(search15)) url_search += "&search15=" + search15;

        f.action = "/piiupload/download_metadata?pagenum=" + pagenum + "&amount=" + amount + url_search;
        f.submit();
    }

    movePage = function (pageNo) {
        searchAction(pageNo);
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#filter_search1').val();
        var search2 = $('#filter_search2').val();
        var search3 = $('#filter_search3').val();
        var search4 = $('#filter_search4').val();
        var search5 = $('#filter_search5').val();
        var search6 = $('#filter_search6').val();
        var search7 = $('#filter_search7').val();
        var search8 = $('#filter_search8').val();
        var search9 = $('#filter_search9').val();
        var search10 = $('#filter_search10').val();
        var search11 = $('#filter_search11').val();
        var search12 = $('#filter_search12').val();
        var search13 = $('#filter_search13').val();
        var search14 = $('#filter_search14').val();
        var search15 = $('#filter_search15').val();
        var search16 = $('#filter_search16').val();
        var url_search = "";
        var url_view = "";

        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "modify?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;

        if (!isEmpty(search1)) url_search += "&search1=" + search1;
        if (!isEmpty(search2)) url_search += "&search2=" + search2;
        if (!isEmpty(search3)) url_search += "&search3=" + search3;
        if (!isEmpty(search4)) url_search += "&search4=" + search4;
        if (!isEmpty(search5)) url_search += "&search5=" + search5;
        if (!isEmpty(search6)) url_search += "&search6=" + search6;
        if (!isEmpty(search7)) url_search += "&search7=" + search7;
        if (!isEmpty(search8)) url_search += "&search8=" + search8;
        if (!isEmpty(search9)) url_search += "&search9=" + search9;
        if (!isEmpty(search10)) url_search += "&search10=" + search10;
        if (!isEmpty(search11)) url_search += "&search11=" + search11;
        if (!isEmpty(search12)) url_search += "&search12=" + search12;
        if (!isEmpty(search13)) url_search += "&search13=" + search13;
        if (!isEmpty(search14)) url_search += "&search14=" + search14;
        if (!isEmpty(search15)) url_search += "&search15=" + search15;
        if (!isEmpty(search16)) url_search += "&search16=" + search16;

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
                $('#content_home').html(data);
            }
        });
    }

    /**
     * PII Discovery Details Modal
     * DOMAIN 컬럼에서 PII 탐지 정보 클릭 시 상세 정보 모달 표시
     */
    function showPiiDetailsModal(db, owner, tableName, columnName) {
        // Registry API 호출하여 상세 정보 조회
        $.ajax({
            type: "GET",
            url: "/piidiscovery/api/registry",
            data: {
                search1: db,
                search2: owner,
                filterTable: tableName,
                filterColumn: columnName,
                search4: 'CONFIRMED'
            },
            dataType: "json",
            beforeSend: function(xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(response) {
                if (response.registryList && response.registryList.length > 0) {
                    var registry = response.registryList[0];
                    showPiiDetailContent(registry);
                } else {
                    showPiiDetailContentFromDomain(db, owner, tableName, columnName);
                }
            },
            error: function(request, error) {
                console.error("Failed to load PII registry info", error);
                showPiiDetailContentFromDomain(db, owner, tableName, columnName);
            }
        });
    }

    function showPiiDetailContent(registry) {
        var modalHtml = '<div class="modal fade" id="piiDetailsModal" tabindex="-1" role="dialog">' +
            '<div class="modal-dialog modal-lg" role="document">' +
            '<div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden;">' +
            '<div class="modal-header" style="background: linear-gradient(135deg, #8b5cf6, #6366f1); border: none; padding: 16px 24px;">' +
            '<h5 class="modal-title" style="color: #fff; font-weight: 600;"><i class="fas fa-shield-alt"></i> PII Discovery Details</h5>' +
            '<button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;"><span>&times;</span></button>' +
            '</div>' +
            '<div class="modal-body" style="padding: 24px;">' +
            '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">' +
            // 컬럼 정보
            '<div style="background: #f8fafc; border-radius: 8px; padding: 16px;">' +
            '<h6 style="color: #64748b; font-size: 12px; margin-bottom: 12px; text-transform: uppercase;">Column Information</h6>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Database</span><br><span style="font-weight: 600;">' + (registry.dbName || '-') + '</span></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Schema</span><br><span style="font-weight: 600;">' + (registry.schemaName || '-') + '</span></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Table</span><br><span style="font-weight: 600;">' + (registry.tableName || '-') + '</span></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Column</span><br><span style="font-weight: 600;">' + (registry.columnName || '-') + '</span></div>' +
            '<div><span style="color: #94a3b8; font-size: 12px;">Data Type</span><br><span style="font-weight: 600;">' + (registry.dataType || '-') + '</span></div>' +
            '</div>' +
            // PII 탐지 정보
            '<div style="background: #f8fafc; border-radius: 8px; padding: 16px;">' +
            '<h6 style="color: #64748b; font-size: 12px; margin-bottom: 12px; text-transform: uppercase;">PII Detection Info</h6>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">PII Type</span><br><span style="font-weight: 600; color: #8b5cf6;">' + (registry.piiTypeName || '-') + '</span></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Confidence Score</span><br>' +
            '<div style="display: flex; align-items: center; gap: 8px;">' +
            '<div style="flex: 1; background: #e2e8f0; border-radius: 4px; height: 8px;">' +
            '<div style="width: ' + (registry.confidenceScore || 0) + '%; height: 100%; background: linear-gradient(90deg, #10b981, #22c55e); border-radius: 4px;"></div>' +
            '</div>' +
            '<span style="font-weight: 600; color: #16a34a;">' + (registry.confidenceScore || 0) + '%</span>' +
            '</div></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Detection Method</span><br><span style="font-weight: 600;">' + (registry.detectionMethod || '-') + '</span></div>' +
            '<div style="margin-bottom: 8px;"><span style="color: #94a3b8; font-size: 12px;">Status</span><br><span style="padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; ' +
            (registry.status === 'CONFIRMED' ? 'background: #dcfce7; color: #16a34a;' : 'background: #fee2e2; color: #dc2626;') + '">' + (registry.status || '-') + '</span></div>' +
            '<div><span style="color: #94a3b8; font-size: 12px;">Detected Date</span><br><span style="font-weight: 600;">' + (registry.registeredDate || '-') + '</span></div>' +
            '</div>' +
            '</div>' +
            // 샘플 데이터
            (registry.sampleData ? '<div style="margin-top: 16px; background: #fef3c7; border-radius: 8px; padding: 12px;">' +
            '<h6 style="color: #92400e; font-size: 12px; margin-bottom: 8px;"><i class="fas fa-eye-slash"></i> Sample Data (Masked)</h6>' +
            '<code style="color: #78350f; font-size: 12px;">' + registry.sampleData + '</code>' +
            '</div>' : '') +
            '</div>' +
            '<div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px;">' +
            '<button type="button" class="btn" data-dismiss="modal" style="background: #64748b; color: #fff; border: none; padding: 8px 16px; border-radius: 6px;">닫기</button>' +
            '</div></div></div></div>';

        // 기존 모달 제거 후 새로 추가
        $('#piiDetailsModal').remove();
        $('body').append(modalHtml);
        $('#piiDetailsModal').modal('show');
    }

    function showPiiDetailContentFromDomain(db, owner, tableName, columnName) {
        // DOMAIN 컬럼에서 정보 파싱
        var domainCell = $('tr').filter(function() {
            return $(this).find('td').eq(1).text() === db &&
                   $(this).find('td').eq(2).text() === owner &&
                   $(this).find('td').eq(3).text() === tableName &&
                   $(this).find('td').eq(4).text() === columnName;
        }).find('.pii-discovery-badge');

        var piiType = domainCell.find('.pii-type').text() || '-';
        var piiScore = domainCell.find('.pii-score').text() || '0';

        var simpleRegistry = {
            dbName: db,
            schemaName: owner,
            tableName: tableName,
            columnName: columnName,
            piiTypeName: piiType,
            confidenceScore: parseFloat(piiScore),
            detectionMethod: 'AUTO',
            status: 'CONFIRMED'
        };

        showPiiDetailContent(simpleRegistry);
    }
</script>
