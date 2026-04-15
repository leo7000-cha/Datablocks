<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- 개인정보 컬럼 (데이터 인벤토리) -->
<div id="columnsContent">

    <!-- Stats -->
    <div style="display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap;">
        <div style="display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #f1f5f9; border-radius: 8px;">
            <i class="fas fa-table" style="color: #3b82f6; font-size: 13px;"></i>
            <span style="font-size: 11px; color: #64748b;">테이블</span>
            <span style="font-size: 14px; font-weight: 700; color: #1e293b;">${stats.tableCount}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #f1f5f9; border-radius: 8px;">
            <i class="fas fa-columns" style="color: #8b5cf6; font-size: 13px;"></i>
            <span style="font-size: 11px; color: #64748b;">컬럼</span>
            <span style="font-size: 14px; font-weight: 700; color: #1e293b;">${stats.columnCount}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #dcfce7; border-radius: 8px;">
            <i class="fas fa-check-circle" style="color: #22c55e; font-size: 13px;"></i>
            <span style="font-size: 11px; color: #64748b;">확인</span>
            <span style="font-size: 14px; font-weight: 700; color: #16a34a;">${stats.verifiedCount}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #fef3c7; border-radius: 8px;">
            <i class="fas fa-clock" style="color: #f59e0b; font-size: 13px;"></i>
            <span style="font-size: 11px; color: #64748b;">미확인</span>
            <span style="font-size: 14px; font-weight: 700; color: #d97706;">${stats.unverifiedCount}</span>
        </div>
        <div style="display: flex; align-items: center; gap: 6px; padding: 8px 14px; background: #fce7f3; border-radius: 8px;">
            <i class="fas fa-user-shield" style="color: #ec4899; font-size: 13px;"></i>
            <span style="font-size: 11px; color: #64748b;">개인정보</span>
            <span style="font-size: 14px; font-weight: 700; color: #db2777;">${stats.piiCount}</span>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="content-panel" style="margin-bottom: 20px;">
        <div class="panel-body" style="padding: 14px 20px;">
            <div class="d-flex align-items-center flex-wrap" style="gap: 8px;">
                <select class="form-control form-control-sm filter-field" id="colFilterDb" style="width: 120px;">
                    <option value="">DB</option>
                </select>
                <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="colFilterOwner" placeholder="Owner" style="width: 100px; text-transform:uppercase;"
                       value='<c:out value="${pageMaker.cri.search2}"/>' onkeypress="if(event.keyCode===13){colSearch(1);}">
                <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="colFilterTable" placeholder="Table (%, _)" style="width: 120px; text-transform:uppercase;"
                       value='<c:out value="${pageMaker.cri.search3}"/>' onkeypress="if(event.keyCode===13){colSearch(1);}">
                <input type="text" class="form-control form-control-sm filter-field text-uppercase" id="colFilterColumn" placeholder="Column (%, _)" style="width: 150px;"
                       value='<c:out value="${pageMaker.cri.search4}"/>' onkeypress="if(event.keyCode===13){colSearch(1);}">
                <input type="text" class="form-control form-control-sm filter-field" id="colFilterComment" placeholder="Comment" style="width: 120px;"
                       value='<c:out value="${pageMaker.cri.search10}"/>' onkeypress="if(event.keyCode===13){colSearch(1);}">
                <select class="form-control form-control-sm filter-field" id="colFilterEncrypt" style="width: 90px;" onchange="colSearch(1);">
                    <option value="">암호화</option>
                    <option value="Y" <c:if test="${pageMaker.cri.search5 eq 'Y'}">selected</c:if>>Y</option>
                </select>
                <select class="form-control form-control-sm filter-field" id="colFilterPiiType" style="width: 140px;" onchange="colSearch(1);">
                    <option value="">개인정보타입</option>
                    <option value="PII" <c:if test="${pageMaker.cri.search7 eq 'PII'}">selected</c:if>>Y</option>
                    <option value="NOTPII" <c:if test="${pageMaker.cri.search7 eq 'NOTPII'}">selected</c:if>>N</option>
                    <c:forEach var="item" items="${listlkPiiScrType}">
                        <option value="${item.piicode}" <c:if test="${pageMaker.cri.search7 eq item.piicode}">selected</c:if>>${item.piitypename}</option>
                    </c:forEach>
                </select>
                <select class="form-control form-control-sm filter-field" id="colFilterScramble" style="width: 100px;" onchange="colSearch(1);">
                    <option value="">스크램블</option>
                    <option value="Y" <c:if test="${pageMaker.cri.search8 eq 'Y'}">selected</c:if>>Y</option>
                    <option value="N" <c:if test="${pageMaker.cri.search8 eq 'N'}">selected</c:if>>N</option>
                </select>
                <select class="form-control form-control-sm filter-field" id="colFilterDetection" style="width: 90px;" onchange="colSearch(1);">
                    <option value="">탐지</option>
                    <option value="Y" <c:if test="${pageMaker.cri.search16 eq 'Y'}">selected</c:if>>탐지됨</option>
                    <option value="N" <c:if test="${pageMaker.cri.search16 eq 'N'}">selected</c:if>>미탐지</option>
                    <option value="EXCLUDED" <c:if test="${pageMaker.cri.search16 eq 'EXCLUDED'}">selected</c:if>>오탐제외</option>
                </select>
                <select class="form-control form-control-sm filter-field" id="colFilterVerify" style="width: 70px;" onchange="colSearch(1);">
                    <option value="">확인</option>
                    <option value="Y" <c:if test="${pageMaker.cri.search15 eq 'Y'}">selected</c:if>>Y</option>
                    <option value="N" <c:if test="${pageMaker.cri.search15 eq 'N'}">selected</c:if>>N</option>
                </select>
                <button class="btn btn-sm btn-primary" onclick="colSearch(1)"><i class="fas fa-search"></i> 검색</button>
                <button class="btn btn-sm btn-outline-secondary" onclick="colClearFilters()"><i class="fas fa-redo"></i></button>
            </div>
        </div>
    </div>

    <!-- Action Bar -->
    <span id="colVerifyActions" style="display: none; gap: 6px; align-items: center; margin-bottom: 12px;">
        <span class="text-muted"><strong id="colSelectedNum">0</strong> 건 선택</span>
        <button class="btn btn-sm" onclick="colVerifySelected()" style="background: #22c55e; color: #fff; border: none; font-weight: 600;">
            <i class="fas fa-circle-check"></i> 확인처리
        </button>
    </span>

    <!-- Table -->
    <div class="content-panel">
        <div class="panel-body" style="padding: 0;">
            <c:choose>
                <c:when test="${not empty list}">
                    <table class="discovery-table" id="columnsTable" style="white-space: nowrap;">
                        <thead>
                            <tr>
                                <th style="width: 40px;"><input type="checkbox" id="colCheckAll" onclick="colToggleAll()" style="vertical-align:middle; width:15px; height:15px;"></th>
                                <th>데이터베이스</th>
                                <th>스키마</th>
                                <th>테이블</th>
                                <th>컬럼</th>
                                <th>컬럼명</th>
                                <th>데이터 타입</th>
                                <th>탐지결과</th>
                                <th>암호화</th>
                                <th>개인정보 유형</th>
                                <th>변환타입</th>
                                <th>확인일</th>
                                <th>수정일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="m" items="${list}">
                                <tr style="cursor: pointer;"
                                    data-db="${m.db}" data-schema="${m.owner}" data-table="${m.table_name}" data-column="${m.column_name}"
                                    data-piitype="${m.piitype}" data-encrypt="${m.encript_flag}" data-scramble="${m.scramble_type}"
                                    data-datatype="${m.data_type}" data-val2="${m.val2}" data-piitypename="${piiTypeNames[m.piitype]}"
                                    ondblclick="openPiiSettingModal(this)">
                                    <td class="text-center" onclick="event.stopPropagation();">
                                        <c:choose>
                                            <c:when test="${empty m.val3}">
                                                <input type="checkbox" class="col-chk" name="colChk" onclick="colCheckChanged()" style="vertical-align:middle; width:15px; height:15px;"
                                                       data-db="${m.db}" data-owner="${m.owner}" data-table="${m.table_name}" data-column="${m.column_name}">
                                            </c:when>
                                            <c:otherwise>&nbsp;</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${m.db}</td>
                                    <td>${m.owner}</td>
                                    <td><strong>${m.table_name}</strong></td>
                                    <td><code>${m.column_name}</code></td>
                                    <td><small>${m.column_comment}</small></td>
                                    <td><span class="badge badge-secondary">${m.data_type}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty m.val2 && fn:contains(m.val2, '|')}">
                                                <c:set var="piiParts" value="${fn:split(m.val2, '|')}"/>
                                                <span style="background: linear-gradient(135deg, #8b5cf6, #6366f1); color: white; padding: 2px 7px; border-radius: 10px; font-size: 10px; font-weight: 500;">
                                                    <i class="fas fa-shield-alt" style="font-size: 9px;"></i>
                                                    ${piiParts[0]} <span style="background:rgba(255,255,255,0.2); padding:0 4px; border-radius:6px; font-size:9px;">${piiParts[1]}</span>
                                                </span>
                                            </c:when>
                                            <c:when test="${m.val2 == 'EXCLUDED'}">
                                                <span style="background:#fef2f2; color:#dc2626; padding:2px 7px; border-radius:10px; font-size:10px; font-weight:600; border:1px solid #fecaca;">
                                                    <i class="fas fa-ban" style="font-size:9px;"></i> 오탐제외
                                                </span>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:if test="${m.encript_flag == 'Y'}"><span class="badge badge-danger">Y</span></c:if>
                                        <c:if test="${m.encript_flag != 'Y'}"><span class="text-muted">-</span></c:if>
                                    </td>
                                    <td>
                                        <c:if test="${not empty m.piitype}">
                                            <span class="badge badge-info">
                                                <c:choose>
                                                    <c:when test="${piiTypeNames[m.piitype] != null}">${piiTypeNames[m.piitype]}</c:when>
                                                    <c:otherwise>${m.piitype}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </c:if>
                                        <c:if test="${empty m.piitype}"><span class="text-muted">-</span></c:if>
                                    </td>
                                    <td><small>${m.scramble_type}</small></td>
                                    <td><small>${m.val3}</small></td>
                                    <td><small>${m.upddate}</small></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div style="padding: 40px; text-align: center; color: #94a3b8;">
                        <i class="fas fa-database fa-2x"></i>
                        <p style="margin-top: 12px;">데이터가 없습니다</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        <!-- Pagination -->
        <c:if test="${not empty list}">
            <div style="padding: 12px 20px; border-top: 1px solid #e2e8f0;">
                <div class="d-flex justify-content-between align-items-center">
                    <c:set var="showFrom" value="${(pageMaker.cri.pagenum - 1) * pageMaker.cri.amount + 1}" />
                    <c:set var="showTo" value="${pageMaker.cri.pagenum * pageMaker.cri.amount}" />
                    <c:if test="${showTo > pageMaker.total}"><c:set var="showTo" value="${pageMaker.total}" /></c:if>
                    <span class="text-muted" style="font-size: 0.85rem;"><strong>${showFrom}</strong> - <strong>${showTo}</strong> / <strong>${pageMaker.total}</strong></span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <c:if test="${pageMaker.prev}">
                                <li class="page-item"><a class="page-link" href="#" onclick="colGoToPage(${pageMaker.startPage - 1}); return false;">&laquo;</a></li>
                            </c:if>
                            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                                <li class="page-item ${pageMaker.cri.pagenum == num ? 'active' : ''}">
                                    <a class="page-link" href="#" onclick="colGoToPage(${num}); return false;">${num}</a>
                                </li>
                            </c:forEach>
                            <c:if test="${pageMaker.next}">
                                <li class="page-item"><a class="page-link" href="#" onclick="colGoToPage(${pageMaker.endPage + 1}); return false;">&raquo;</a></li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </div>
        </c:if>
    </div>
</div>

<style>
.pii-confirm-box { border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
.pii-confirm-header { display: flex; justify-content: space-between; align-items: center; padding: 10px 16px; background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%); border-bottom: 1px solid #bbf7d0; font-weight: 600; font-size: 0.95rem; color: #166534; }
.pii-confirm-header .btn-pii-reset { padding: 3px 10px; font-size: 11px; background: #fff; border: 1px solid #d1d5db; border-radius: 4px; cursor: pointer; color: #6b7280; }
.pii-confirm-body { overflow-y: auto; }
.pii-confirm-body .pc-row { display: flex; border-bottom: 1px solid #e5e7eb; min-height: 30px; background: #fff; }
.pc-grade { width: 36px; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 700; color: #fff; flex-shrink: 0; }
.pc-grade.g1 { background: linear-gradient(135deg, #ef4444, #dc2626); }
.pc-grade.g2 { background: linear-gradient(135deg, #f97316, #ea580c); }
.pc-grade.g3 { background: linear-gradient(135deg, #eab308, #ca8a04); }
.pc-grade.g4 { background: linear-gradient(135deg, #22c55e, #16a34a); }
.pc-grade.g0 { background: linear-gradient(135deg, #9ca3af, #6b7280); }
.pc-category { width: 180px; padding: 4px 10px; font-size: 11px; font-weight: 600; color: #1e3a5f; background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%); border-right: 1px solid #cbd5e1; display: flex; align-items: center; flex-shrink: 0; }
.pc-items { flex: 1; padding: 4px 10px; display: flex; flex-wrap: wrap; gap: 4px; align-items: center; }
.pc-chip { position: relative; }
.pc-chip input { position: absolute; opacity: 0; width: 0; height: 0; }
.pc-chip label { display: inline-block; padding: 3px 10px; font-size: 11px; font-weight: 500; color: #334155; background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border: 1px solid #cbd5e1; border-radius: 6px; cursor: pointer; transition: all 0.2s; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
.pc-chip label:hover { background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%); border-color: #38bdf8; color: #0369a1; }
.pc-chip input:checked + label { background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); border-color: #1e40af; color: #fff; font-weight: 600; box-shadow: 0 3px 8px rgba(29, 78, 216, 0.35); }
.th-purple { color: #7c3aed !important; }
.th-blue { color: #2563eb !important; }
.th-green { color: #059669 !important; }
.th-brown { color: #b45309 !important; }
</style>

<!-- PII 설정 모달 -->
<div class="modal fade" id="colPiiSettingModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-xl" role="document" style="max-width: 1100px;">
        <div class="modal-content" style="border-radius: 12px; overflow: hidden;">
            <div class="modal-header" style="padding: 16px 24px; background: #f0fdf4; border-bottom: 1px solid #bbf7d0;">
                <h5 class="modal-title" style="font-size: 1.1rem; font-weight: 600;"><i class="fas fa-check-circle" style="color: #22c55e;"></i> PII 확정 및 인벤토리 세팅</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" style="padding: 24px;">
                <input type="hidden" id="colPiiHiddenDb">
                <input type="hidden" id="colPiiHiddenSchema">
                <input type="hidden" id="colPiiHiddenTable">
                <input type="hidden" id="colPiiHiddenColumn">
                <div style="margin-bottom: 20px;">
                    <table class="table table-sm table-bordered" style="margin: 0; font-size: 0.85rem;">
                        <tr style="background: #f8fafc;">
                            <td style="background:#e2e8f0; font-weight:700; color:#334155; text-align:center; width:40px; writing-mode:vertical-lr; letter-spacing:2px; font-size:0.75rem;">컬럼</td>
                            <th style="background:#eef2f7;">데이터베이스</th><td id="colPiiDb">-</td>
                            <th style="background:#eef2f7;">스키마</th><td id="colPiiSchema">-</td>
                            <th style="background:#eef2f7;">테이블</th><td id="colPiiTable">-</td>
                            <th style="background:#eef2f7;">컬럼</th><td id="colPiiColumn">-</td>
                            <th style="background:#eef2f7;">데이터타입</th><td id="colPiiDataType">-</td>
                        </tr>
                        <tr style="background: #eff6ff;">
                            <td style="background:#bfdbfe; font-weight:700; color:#1e40af; text-align:center; writing-mode:vertical-lr; letter-spacing:2px; font-size:0.75rem;">현재</td>
                            <th style="background:#dbeafe; color:#1e40af;">개인정보</th><td id="colPiiCurrentType">-</td>
                            <th style="background:#dbeafe; color:#1e40af;">암호화</th><td id="colPiiCurrentEnc">-</td>
                            <th style="background:#dbeafe; color:#1e40af;">변환타입</th><td id="colPiiCurrentScramble">-</td>
                            <th style="background:#dbeafe; color:#1e40af;">탐지결과</th><td id="colPiiVal2" colspan="3">-</td>
                        </tr>
                        <tr style="background: #f0fdf4;">
                            <td style="background:#bbf7d0; font-weight:700; color:#166534; text-align:center; writing-mode:vertical-lr; letter-spacing:2px; font-size:0.75rem;">설정</td>
                            <th style="background:#dcfce7; color:#166534;">개인정보</th><td id="colPiiSelectedType" style="color:#166534; font-weight:600;">-</td>
                            <th style="background:#dcfce7; color:#166534;">변환타입</th>
                            <td><input type="text" class="form-control form-control-sm" id="colPiiScramble" readonly style="background:#f1f5f9; padding:2px 6px; height:26px;"></td>
                            <th style="background:#dcfce7; color:#166534;">암호화</th>
                            <td><select class="form-control form-control-sm" id="colPiiEncrypt" style="width:70px; padding:2px 6px; height:26px; border-color:#86efac;">
                                <option value="">-</option><option value="Y">Y</option>
                            </select></td>
                            <td colspan="4"></td>
                        </tr>
                    </table>
                </div>
                <div class="pii-confirm-box">
                    <div class="pii-confirm-header">
                        <span><i class="fas fa-shield-alt"></i> 해당하는 개인정보 항목을 선택하세요</span>
                        <button type="button" class="btn-pii-reset" onclick="$('input[name=colPiiTypeRadio]:checked').prop('checked',false); $('#colPiiScramble').val(''); $('#colPiiSelectedType').text('-');">
                            <i class="fas fa-undo"></i> Reset
                        </button>
                    </div>
                    <div class="pii-confirm-body" id="colPiiTypeSelector"></div>
                </div>
            </div>
            <div class="modal-footer" style="padding: 12px 24px; background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
                <button type="button" class="btn" onclick="submitColPiiSetting()" style="background: #22c55e; color: #fff; font-weight: 600;">
                    <i class="fas fa-check-circle"></i> 저장
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

// DB 목록 로드
$(document).ready(function() {
    $.get(contextPath + '/piidiscovery/api/databases', function(databases) {
        var html = '<option value="">DB</option>';
        if (databases && databases.length > 0) {
            databases.forEach(function(db) { html += '<option value="' + db.db + '">' + db.db + '</option>'; });
        }
        $('#colFilterDb').html(html);
        <c:if test="${not empty pageMaker.cri.search1}">$('#colFilterDb').val('${pageMaker.cri.search1}');</c:if>
    });
});

function colSearch(page) {
    var params = {
        pageNum: page || 1,
        amount: 100,
        search1: $('#colFilterDb').val(),
        search2: $('#colFilterOwner').val() || null,
        search3: $('#colFilterTable').val() || null,
        search4: $('#colFilterColumn').val() || null,
        search10: $('#colFilterComment').val() || null,
        search5: $('#colFilterEncrypt').val(),
        search7: $('#colFilterPiiType').val(),
        search8: $('#colFilterScramble').val(),
        search16: $('#colFilterDetection').val(),
        search15: $('#colFilterVerify').val()
    };
    // null 제거
    Object.keys(params).forEach(function(k) { if (!params[k]) delete params[k]; });
    loadPageContent('columns', params);
}

// ========== 체크박스 + 확인처리 ==========
function colToggleAll() {
    var checked = $('#colCheckAll').prop('checked');
    $('input[name="colChk"]').prop('checked', checked);
    colCheckChanged();
}

function colCheckChanged() {
    var cnt = $('input[name="colChk"]:checked').length;
    $('#colSelectedNum').text(cnt);
    if (cnt > 0) { $('#colVerifyActions').css('display', 'flex'); } else { $('#colVerifyActions').hide(); }
    // 행 색상
    $('input[name="colChk"]').each(function() {
        $(this).closest('tr').css('background-color', $(this).prop('checked') ? '#E2E8F9' : '');
    });
}

function colVerifySelected() {
    var param = [];
    $('input[name="colChk"]:checked').each(function() {
        param.push({
            db: $(this).data('db'),
            owner: $(this).data('owner'),
            table_name: $(this).data('table'),
            column_name: $(this).data('column')
        });
    });
    if (param.length === 0) return;

    $.ajax({
        url: '/metatable/verify',
        type: 'POST',
        contentType: 'application/json; charset=UTF-8',
        data: JSON.stringify(param),
        beforeSend: function(xhr) { if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken); },
        success: function() {
            showToast('success', param.length + '건 확인처리 완료');
            colSearch();
        },
        error: function() { showToast('error', '확인처리 실패'); }
    });
}

function colClearFilters() {
    $('#colFilterDb, #colFilterOwner, #colFilterTable, #colFilterColumn, #colFilterComment').val('');
    $('#colFilterEncrypt, #colFilterPiiType, #colFilterScramble, #colFilterDetection, #colFilterVerify').val('');
    colSearch(1);
}

function colGoToPage(page) { colSearch(page); }

// ========== PII 설정 모달 ==========
var colLkPiiTypes = null;
function loadColLkPiiTypes(cb) {
    if (colLkPiiTypes) { cb(colLkPiiTypes); return; }
    $.get(contextPath + '/piidiscovery/api/lk-pii-types', function(t) { colLkPiiTypes = t || []; cb(colLkPiiTypes); });
}

function openPiiSettingModal(tr) {
    var $tr = $(tr);
    var db = $tr.data('db'), schema = $tr.data('schema'), table = $tr.data('table'), column = $tr.data('column');
    var piitype = $tr.data('piitype'), encrypt = $tr.data('encrypt'), scramble = $tr.data('scramble');
    var datatype = $tr.data('datatype'), val2 = $tr.data('val2'), piitypename = $tr.data('piitypename');

    $('#colPiiDb').text(db || '-'); $('#colPiiSchema').text(schema || '-');
    $('#colPiiTable').html('<strong>' + (table || '-') + '</strong>'); $('#colPiiColumn').html('<code>' + (column || '-') + '</code>');
    $('#colPiiDataType').html('<span class="badge badge-secondary">' + (datatype || '-') + '</span>');
    $('#colPiiCurrentType').html(piitypename ? '<span class="badge badge-info">' + piitypename + '</span>' : '-');
    $('#colPiiCurrentEnc').text(encrypt || '-'); $('#colPiiCurrentScramble').text(scramble || '-'); $('#colPiiVal2').text(val2 || '-');
    $('#colPiiHiddenDb').val(db); $('#colPiiHiddenSchema').val(schema); $('#colPiiHiddenTable').val(table); $('#colPiiHiddenColumn').val(column);
    $('#colPiiEncrypt').val(encrypt === 'Y' ? 'Y' : ''); $('#colPiiScramble').val(scramble || '');

    loadColLkPiiTypes(function(types) {
        var html = '', gid = '';
        types.forEach(function(t) {
            if (t.piigroupid !== gid) {
                if (gid) html += '</div></div>';
                gid = t.piigroupid;
                html += '<div class="pc-row"><div class="pc-grade g' + t.piigradeid + '">' + t.piigradeid + '</div><div class="pc-category">' + t.piigroupname + '</div><div class="pc-items">';
            }
            var ck = (piitype && piitype === t.piicode) ? ' checked' : '';
            html += '<div class="pc-chip"><input type="radio" name="colPiiTypeRadio" id="cp_' + t.piicode + '" value="' + t.piicode + '" data-scrtype="' + (t.scrtype||'') + '" data-grade="' + (t.piigradeid||'') + '"' + ck + '><label for="cp_' + t.piicode + '">' + t.piitypename + '</label></div>';
        });
        if (gid) html += '</div></div>';
        $('#colPiiTypeSelector').html(html);
        $('input[name="colPiiTypeRadio"]').change(function() { $('#colPiiScramble').val($(this).data('scrtype')||''); $('#colPiiSelectedType').text($(this).next('label').text()); });
        var $ck = $('input[name="colPiiTypeRadio"]:checked');
        $('#colPiiSelectedType').text($ck.length > 0 ? $ck.next('label').text() : '-');
        $('#colPiiSettingModal').modal('show');
    });
}

function submitColPiiSetting() {
    var $sel = $('input[name="colPiiTypeRadio"]:checked');
    if ($sel.length === 0) { showToast('warning', '개인정보 유형을 선택해주세요'); return; }
    $.ajax({
        url: contextPath + '/piidiscovery/api/meta-pii-update',
        type: 'POST', contentType: 'application/json',
        data: JSON.stringify({ db: $('#colPiiHiddenDb').val(), schema: $('#colPiiHiddenSchema').val(), table: $('#colPiiHiddenTable').val(), column: $('#colPiiHiddenColumn').val(),
            piiTypeCode: $sel.val(), piiGrade: $sel.data('grade')+'', encryptFlag: $('#colPiiEncrypt').val(), scrambleType: $('#colPiiScramble').val() }),
        beforeSend: function(xhr) { if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken); },
        success: function(r) { if (r.success) { $('#colPiiSettingModal').modal('hide'); showToast('success', 'PII 설정 완료'); colSearch(); } else { showToast('error', r.message||'실패'); } },
        error: function() { showToast('error', '업데이트 실패'); }
    });
}

function showToast(type, msg) {
    var bg = type==='success'?'#22c55e':type==='error'?'#ef4444':'#f59e0b';
    var t = $('<div class="position-fixed" style="top:20px;right:20px;z-index:9999;padding:12px 20px;background:'+bg+';color:white;border-radius:8px;box-shadow:0 4px 12px rgba(0,0,0,0.15);">'+msg+'</div>');
    $('body').append(t); setTimeout(function(){t.fadeOut(function(){t.remove();});},3000);
}
</script>
