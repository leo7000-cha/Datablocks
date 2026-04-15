<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!-- 개인정보 분류 -->
<div id="piipolicyContent">

    <!-- Filter Bar -->
    <div class="content-panel" style="margin-bottom: 20px;">
        <div class="panel-body" style="padding: 14px 20px;">
            <div class="d-flex align-items-center flex-wrap" style="gap: 8px;">
                <select class="form-control form-control-sm filter-field" id="ppFilterGrade" style="width: 100px;" onchange="ppSearch(1);">
                    <option value="">Grade</option>
                    <option value="1" <c:if test="${pageMaker.cri.search1 eq '1'}">selected</c:if>>1</option>
                    <option value="2" <c:if test="${pageMaker.cri.search1 eq '2'}">selected</c:if>>2</option>
                    <option value="3" <c:if test="${pageMaker.cri.search1 eq '3'}">selected</c:if>>3</option>
                </select>
                <input type="text" class="form-control form-control-sm filter-field" id="ppFilterName" placeholder="PII Type Name" style="width: 180px;"
                       value='<c:out value="${pageMaker.cri.search2}"/>' onkeypress="if(event.keyCode===13){ppSearch(1);}">
                <button class="btn btn-sm btn-primary" onclick="ppSearch(1)"><i class="fas fa-search"></i> 검색</button>
                <button class="btn btn-sm btn-outline-secondary" onclick="ppClear()"><i class="fas fa-redo"></i></button>
                <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                    <button class="btn btn-sm btn-outline-success" onclick="ppOpenRegister()" style="margin-left: auto;">
                        <i class="fas fa-plus"></i> 등록
                    </button>
                </sec:authorize>
            </div>
        </div>
    </div>

    <!-- Table -->
    <div class="content-panel">
        <div class="panel-body" style="padding: 0;">
            <table class="discovery-table" style="white-space: nowrap;">
                <thead>
                    <tr>
                        <th>Code</th>
                        <th style="width:50px;">Grade</th>
                        <th>Group</th>
                        <th>PII Type</th>
                        <th>Scramble Type</th>
                        <th>Scramble Method</th>
                        <th>Category</th>
                        <th>Enc/Dec Type</th>
                        <th>Remarks</th>
                        <th style="width: 80px;">사용여부</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${list}">
                        <tr style="cursor: pointer;" ondblclick="ppOpenDetail('${item.piicode}')">
                            <td><code>${item.piicode}</code></td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${item.piigradeid == '1'}"><span class="badge" style="background:#ef4444; color:#fff;">${item.piigradeid}</span></c:when>
                                    <c:when test="${item.piigradeid == '2'}"><span class="badge" style="background:#f97316; color:#fff;">${item.piigradeid}</span></c:when>
                                    <c:when test="${item.piigradeid == '3'}"><span class="badge" style="background:#eab308; color:#fff;">${item.piigradeid}</span></c:when>
                                    <c:otherwise><span class="badge badge-secondary">${item.piigradeid}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td title="${item.piigroupname}">
                                <c:choose>
                                    <c:when test="${fn:length(item.piigroupname) > 12}">${fn:substring(item.piigroupname, 0, 12)}...</c:when>
                                    <c:otherwise>${item.piigroupname}</c:otherwise>
                                </c:choose>
                            </td>
                            <td><strong>${item.piitypename}</strong></td>
                            <td><small>${item.scrtype}</small></td>
                            <td><small>${item.scrmethod}</small></td>
                            <td><small>${item.scrcategory}</small></td>
                            <td class="text-center"><span class="badge badge-secondary">${item.encdecfunctype}</span></td>
                            <td><small>${item.remarks}</small></td>
                            <td class="text-center" onclick="event.stopPropagation();">
                                <span class="pp-toggle" data-piicode="${item.piicode}" data-visible="${item.visible}"
                                      style="cursor: pointer; font-size: 1.5em; line-height: 1;" title="사용여부 전환"
                                      onclick="ppToggleVisible(this)">
                                    <c:choose>
                                        <c:when test="${item.visible == 'Y'}"><i class="fas fa-toggle-on" style="color: #22c55e;"></i></c:when>
                                        <c:otherwise><i class="fas fa-toggle-off" style="color: #d1d5db;"></i></c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <!-- Pagination -->
        <c:if test="${not empty list}">
            <div style="padding: 12px 20px; border-top: 1px solid #e2e8f0;">
                <div class="d-flex justify-content-between align-items-center">
                    <c:set var="sf" value="${(pageMaker.cri.pagenum - 1) * pageMaker.cri.amount + 1}" />
                    <c:set var="st" value="${pageMaker.cri.pagenum * pageMaker.cri.amount}" />
                    <c:if test="${st > pageMaker.total}"><c:set var="st" value="${pageMaker.total}" /></c:if>
                    <span class="text-muted" style="font-size: 0.85rem;"><strong>${sf}</strong> - <strong>${st}</strong> / <strong>${pageMaker.total}</strong></span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <c:if test="${pageMaker.prev}"><li class="page-item"><a class="page-link" href="#" onclick="ppGoTo(${pageMaker.startPage - 1}); return false;">&laquo;</a></li></c:if>
                            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                                <li class="page-item ${pageMaker.cri.pagenum == num ? 'active' : ''}"><a class="page-link" href="#" onclick="ppGoTo(${num}); return false;">${num}</a></li>
                            </c:forEach>
                            <c:if test="${pageMaker.next}"><li class="page-item"><a class="page-link" href="#" onclick="ppGoTo(${pageMaker.endPage + 1}); return false;">&raquo;</a></li></c:if>
                        </ul>
                    </nav>
                </div>
            </div>
        </c:if>
    </div>
</div>

<style>
#detailModal .detail-card-body { max-height: none !important; overflow-y: visible !important; }
#detailModal .edit-card-body { max-height: none !important; overflow-y: visible !important; }
#detailModal .card { max-height: none !important; height: auto !important; }
</style>

<!-- 상세/수정 모달 -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document" style="max-width: 800px; max-height: 90vh;">
        <div class="modal-content" style="border: none; border-radius: 12px; overflow: hidden;">
            <div class="modal-body" id="detailModalBody" style="padding: 0;">
            </div>
        </div>
    </div>
</div>

<script>
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

function ppSearch(page) {
    var params = { pageNum: page || 1, amount: 100, search1: $('#ppFilterGrade').val(), search2: $('#ppFilterName').val() };
    Object.keys(params).forEach(function(k) { if (!params[k]) delete params[k]; });
    loadPageContent('piipolicy', params);
}
function ppClear() { $('#ppFilterGrade').val(''); $('#ppFilterName').val(''); ppSearch(1); }
function ppGoTo(p) { ppSearch(p); }

function ppToggleVisible(el) {
    var $el = $(el);
    var piicode = $el.data('piicode');
    var newVisible = ($el.data('visible') === 'Y') ? 'N' : 'Y';
    $.ajax({
        type: 'POST', url: '/lkpiiscrtype/api/toggle-visible',
        data: { piicode: piicode, visible: newVisible },
        beforeSend: function(xhr) { if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken); },
        success: function(r) {
            if (r.success) {
                $el.data('visible', newVisible);
                $el.html(newVisible === 'Y' ? '<i class="fas fa-toggle-on" style="color: #22c55e;"></i>' : '<i class="fas fa-toggle-off" style="color: #d1d5db;"></i>');
            }
        }
    });
}

// 상세 보기 (더블클릭) → 기존 get.jsp 모달 로드
function ppOpenDetail(piicode) {
    $.ajax({
        type: 'GET', url: '/lkpiiscrtype/get?piicode=' + piicode, dataType: 'html',
        success: function(data) { $('#detailModalBody').html(data); $('#detailModal').modal('show'); }
    });
}

// 수정 화면 로드 (get.jsp의 modify 버튼에서 호출)
function openModifyModal(piicode) {
    $.ajax({
        type: 'GET', url: '/lkpiiscrtype/modify?piicode=' + piicode, dataType: 'html',
        success: function(data) { $('#detailModalBody').html(data); }
    });
}

// 등록 → 기존 register.jsp 로드
function ppOpenRegister() {
    $.ajax({
        type: 'GET', url: '/lkpiiscrtype/register', dataType: 'html',
        success: function(data) { $('#detailModalBody').html(data); $('#detailModal').modal('show'); }
    });
}

// 기존 JSP에서 사용하는 함수 폴백 (X-Scan에 없는 것)
if (typeof ingShow !== 'function') { window.ingShow = function() {}; }
if (typeof ingHide !== 'function') { window.ingHide = function() {}; }
if (typeof checkResultModal !== 'function') { window.checkResultModal = function() {}; }
if (typeof characterCheck !== 'function') { window.characterCheck = function() {}; }

// 모달 내에서 저장/수정 후 리스트 새로고침
function refreshList() {
    $('#detailModal').modal('hide');
    $('body').removeClass('modal-open');
    $('.modal-backdrop').remove();
    ppSearch();
}
</script>
