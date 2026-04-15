<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
.ep-tabs { display:flex; gap:0; border-bottom:2px solid #e5e7eb; margin-bottom:16px; }
.ep-tab { padding:10px 22px; font-size:0.85rem; font-weight:600; color:#9ca3af; cursor:pointer; border-bottom:2px solid transparent; margin-bottom:-2px; transition:all 0.15s; }
.ep-tab:hover { color:#6b7280; }
.ep-tab.active { color:#7c3aed; border-bottom-color:#7c3aed; }
.ep-tab .cnt { font-size:0.72rem; background:#f3f4f6; color:#6b7280; padding:2px 8px; border-radius:8px; margin-left:6px; }
.ep-tab.active .cnt { background:#ede9fe; color:#7c3aed; }

.ep-toolbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; }
.ep-toolbar .desc { font-size:0.8rem; color:#6b7280; }
.ep-toolbar .btn-add { background:#7c3aed; color:#fff; border:none; padding:7px 14px; border-radius:8px; font-size:0.8rem; font-weight:600; cursor:pointer; display:flex; align-items:center; gap:5px; }

.ep-table { width:100%; border-collapse:separate; border-spacing:0; }
.ep-table thead th { background:#f9fafb; padding:8px 12px; font-size:0.76rem; font-weight:600; color:#6b7280; text-align:left; border-bottom:1px solid #e5e7eb; }
.ep-table tbody td { padding:10px 12px; font-size:0.82rem; color:#1f2937; border-bottom:1px solid #f3f4f6; vertical-align:middle; }
.ep-table tbody tr:hover { background:#f9fafb; }
.ep-table tbody tr { cursor:pointer; }

.ep-pattern { font-family:'Consolas','Monaco',monospace; background:#f3f4f6; padding:3px 8px; border-radius:4px; font-size:0.8rem; color:#1f2937; word-break:break-all; }
.ep-match { font-size:0.7rem; padding:2px 7px; border-radius:4px; font-weight:600; white-space:nowrap; }
.ep-match-prefix { background:#dbeafe; color:#1e40af; }
.ep-match-contains { background:#fef3c7; color:#92400e; }
.ep-match-regex { background:#fce7f3; color:#9d174d; }
.ep-type { font-size:0.72rem; padding:2px 7px; border-radius:4px; font-weight:600; white-space:nowrap; }
.ep-type-all { background:#f3f4f6; color:#374151; }
.ep-type-db { background:#ede9fe; color:#7c3aed; }
.ep-type-was { background:#dcfce7; color:#15803d; }
.ep-active { color:#059669; }
.ep-inactive { color:#dc2626; }
.ep-actions { white-space:nowrap; text-align:center; }
.ep-actions button { background:none; border:none; cursor:pointer; padding:4px 8px; font-size:0.82rem; color:#9ca3af; }
.ep-actions button:hover { color:#1f2937; }
.ep-actions .btn-del:hover { color:#dc2626; }

/* Modal */
.ep-modal-overlay { position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:10000; display:flex; align-items:center; justify-content:center; }
.ep-modal { background:#fff; border-radius:14px; width:680px; max-width:90vw; overflow:hidden; }
.ep-modal-header { padding:18px 22px; border-bottom:1px solid #e5e7eb; display:flex; align-items:center; justify-content:space-between; }
.ep-modal-header h4 { font-size:0.95rem; font-weight:700; color:#1f2937; margin:0; }
.ep-modal-header .close-btn { background:none; border:none; font-size:1.2rem; color:#9ca3af; cursor:pointer; }
.ep-modal-body { padding:20px 22px; }
.ep-modal-body label { font-size:0.8rem; font-weight:600; color:#374151; margin-bottom:5px; display:block; }
.ep-modal-body .field { margin-bottom:14px; }
.ep-modal-body input, .ep-modal-body select { width:100%; padding:8px 12px; border:1px solid #d1d5db; border-radius:8px; font-size:0.85rem; }
.ep-modal-body textarea { width:100%; padding:10px 12px; border:1px solid #d1d5db; border-radius:8px; font-size:0.85rem; font-family:'Consolas','Monaco',monospace; resize:vertical; }
.ep-modal-body textarea:focus, .ep-modal-body input:focus, .ep-modal-body select:focus { outline:none; border-color:#c4b5fd; }
.ep-modal-body .field-row { display:flex; gap:12px; }
.ep-modal-body .field-hint { font-size:0.72rem; color:#9ca3af; margin-top:4px; }
.ep-modal-footer { padding:14px 22px; border-top:1px solid #e5e7eb; display:flex; gap:8px; justify-content:flex-end; }
.ep-modal-footer button { padding:8px 18px; border-radius:8px; font-size:0.82rem; font-weight:600; cursor:pointer; }
.ep-modal-footer .btn-cancel { background:#fff; color:#6b7280; border:1px solid #d1d5db; }
.ep-modal-footer .btn-save { background:#7c3aed; color:#fff; border:none; }
</style>

<!-- 탭 -->
<div class="ep-tabs">
    <div class="ep-tab active" onclick="switchEpTab(this, '')">전체 <span class="cnt" id="cntAll">0</span></div>
    <div class="ep-tab" onclick="switchEpTab(this, 'ALL')">공통 <span class="cnt" id="cntCommon">0</span></div>
    <div class="ep-tab" onclick="switchEpTab(this, 'DB_AUDIT')">DB 접근 감사 <span class="cnt" id="cntDb">0</span></div>
    <div class="ep-tab" onclick="switchEpTab(this, 'WAS_AGENT')">WAS 접근 감사 <span class="cnt" id="cntWas">0</span></div>
</div>

<!-- 툴바 -->
<div class="ep-toolbar">
    <div class="desc">수집 시 제외할 SQL 패턴을 관리합니다. <strong>공통</strong> 패턴은 모든 수집 유형에 적용됩니다.</div>
    <button class="btn-add" onclick="openEpModal()"><i class="fas fa-plus"></i> 등록</button>
</div>

<!-- 테이블 -->
<table class="ep-table">
    <thead>
        <tr>
            <th style="width:40px;">상태</th>
            <th>SQL 패턴</th>
            <th style="width:80px;">매칭</th>
            <th style="width:90px;">적용 대상</th>
            <th>설명</th>
            <th style="width:110px;text-align:center;">작업</th>
        </tr>
    </thead>
    <tbody id="epTableBody">
        <tr><td colspan="6" style="text-align:center;color:#9ca3af;padding:30px;">로딩 중...</td></tr>
    </tbody>
</table>

<script>
var _epCurrentType = '';
var _allPatterns = [];

function loadPatterns() {
    $.get('/accesslog/api/exclude-patterns', function(list) {
        _allPatterns = list || [];
        updateCounts();
        renderPatterns();
    });
}
loadPatterns();

function updateCounts() {
    document.getElementById('cntAll').textContent = _allPatterns.length;
    document.getElementById('cntCommon').textContent = _allPatterns.filter(function(p){return p.sourceType==='ALL';}).length;
    document.getElementById('cntDb').textContent = _allPatterns.filter(function(p){return p.sourceType==='DB_AUDIT';}).length;
    document.getElementById('cntWas').textContent = _allPatterns.filter(function(p){return p.sourceType==='WAS_AGENT';}).length;
}

function switchEpTab(el, type) {
    _epCurrentType = type;
    document.querySelectorAll('.ep-tab').forEach(function(t){t.classList.remove('active');});
    el.classList.add('active');
    renderPatterns();
}

function renderPatterns() {
    var filtered = _epCurrentType ? _allPatterns.filter(function(p){return p.sourceType===_epCurrentType;}) : _allPatterns;
    if (filtered.length === 0) {
        document.getElementById('epTableBody').innerHTML = '<tr><td colspan="6" style="text-align:center;color:#9ca3af;padding:40px;"><i class="fas fa-filter" style="font-size:1.5rem;margin-bottom:8px;display:block;"></i>등록된 제외 SQL이 없습니다.</td></tr>';
        return;
    }
    var html = '';
    filtered.forEach(function(p) {
        var matchClass = p.matchType === 'PREFIX' ? 'ep-match-prefix' : p.matchType === 'CONTAINS' ? 'ep-match-contains' : 'ep-match-regex';
        var matchLabel = p.matchType === 'PREFIX' ? '시작' : p.matchType === 'CONTAINS' ? '포함' : '정규식';
        var typeClass = p.sourceType === 'ALL' ? 'ep-type-all' : p.sourceType === 'DB_AUDIT' ? 'ep-type-db' : 'ep-type-was';
        var typeLabel = p.sourceType === 'ALL' ? '공통' : p.sourceType === 'DB_AUDIT' ? 'DB 접근' : 'WAS 접근';
        var activeIcon = p.isActive === 'Y'
            ? '<i class="fas fa-circle ep-active" style="font-size:0.55rem;" title="활성"></i>'
            : '<i class="fas fa-circle ep-inactive" style="font-size:0.55rem;" title="비활성"></i>';
        html += '<tr ondblclick="openEpModal(' + p.patternId + ')">' +
            '<td style="text-align:center;">' + activeIcon + '</td>' +
            '<td><span class="ep-pattern">' + escHtml(p.pattern) + '</span></td>' +
            '<td><span class="ep-match ' + matchClass + '">' + matchLabel + '</span></td>' +
            '<td><span class="ep-type ' + typeClass + '">' + typeLabel + '</span></td>' +
            '<td style="color:#6b7280;font-size:0.8rem;">' + escHtml(p.description || '') + '</td>' +
            '<td class="ep-actions">' +
                '<button onclick="event.stopPropagation();togglePattern(' + p.patternId + ',\'' + (p.isActive==='Y'?'N':'Y') + '\')" title="' + (p.isActive==='Y'?'비활성화':'활성화') + '"><i class="fas fa-' + (p.isActive==='Y'?'pause':'play') + '"></i></button>' +
                '<button onclick="event.stopPropagation();openEpModal(' + p.patternId + ')" title="편집"><i class="fas fa-pen"></i></button>' +
                '<button class="btn-del" onclick="event.stopPropagation();deletePattern(' + p.patternId + ')" title="삭제"><i class="fas fa-trash"></i></button>' +
            '</td>' +
        '</tr>';
    });
    document.getElementById('epTableBody').innerHTML = html;
}

function escHtml(s) { return s ? s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') : ''; }

// ========== Modal ==========
function openEpModal(patternId) {
    var existing = document.getElementById('epModalOverlay');
    if (existing) existing.remove();

    var isEdit = !!patternId;
    var p = isEdit ? _allPatterns.find(function(x){return x.patternId == patternId;}) : null;

    var overlay = document.createElement('div');
    overlay.id = 'epModalOverlay';
    overlay.className = 'ep-modal-overlay';
    overlay.innerHTML =
        '<div class="ep-modal">' +
            '<div class="ep-modal-header">' +
                '<h4><i class="fas fa-filter" style="color:#7c3aed;margin-right:8px;"></i>' + (isEdit ? '제외 SQL 수정' : '제외 SQL 등록') + '</h4>' +
                '<button class="close-btn" onclick="closeEpModal()">&times;</button>' +
            '</div>' +
            '<div class="ep-modal-body">' +
                '<div class="field">' +
                    '<label>SQL 패턴 <span style="color:#dc2626;">*</span></label>' +
                    '<textarea id="epPattern" rows="8" placeholder="제외할 SQL 패턴을 입력하세요.&#10;&#10;예시:&#10;  SELECT 1 FROM DUAL&#10;  ALL_TAB_COLUMNS&#10;  ^SELECT.*FROM\\s+SYS\\." style="min-height:160px;">' + escHtml(p ? p.pattern : '') + '</textarea>' +
                    '<div class="field-hint">매칭 방식에 따라 SQL의 시작, 포함 여부, 정규식으로 비교합니다.</div>' +
                '</div>' +
                '<div class="field-row">' +
                    '<div class="field" style="flex:1;">' +
                        '<label>매칭 방식</label>' +
                        '<select id="epMatchType">' +
                            '<option value="PREFIX"' + (p && p.matchType==='PREFIX' ? ' selected' : '') + '>시작 문자열 (PREFIX)</option>' +
                            '<option value="CONTAINS"' + (p && p.matchType==='CONTAINS' ? ' selected' : '') + '>포함 문자열 (CONTAINS)</option>' +
                            '<option value="REGEX"' + (p && p.matchType==='REGEX' ? ' selected' : '') + '>정규표현식 (REGEX)</option>' +
                        '</select>' +
                    '</div>' +
                    '<div class="field" style="flex:1;">' +
                        '<label>적용 대상</label>' +
                        '<select id="epSourceType">' +
                            '<option value="ALL"' + (p && p.sourceType==='ALL' ? ' selected' : !p ? ' selected' : '') + '>공통 (모든 수집 유형)</option>' +
                            '<option value="DB_AUDIT"' + (p && p.sourceType==='DB_AUDIT' ? ' selected' : '') + '>DB 접근 감사</option>' +
                            '<option value="WAS_AGENT"' + (p && p.sourceType==='WAS_AGENT' ? ' selected' : '') + '>WAS 접근 감사</option>' +
                        '</select>' +
                    '</div>' +
                '</div>' +
                '<div class="field">' +
                    '<label>설명</label>' +
                    '<input type="text" id="epDescription" placeholder="패턴에 대한 설명 (선택)" value="' + escHtml(p ? p.description || '' : '') + '">' +
                '</div>' +
            '</div>' +
            '<div class="ep-modal-footer">' +
                '<button class="btn-cancel" onclick="closeEpModal()">취소</button>' +
                '<button class="btn-save" onclick="saveEpModal(' + (isEdit ? patternId : 0) + ')"><i class="fas fa-check"></i> ' + (isEdit ? '수정' : '등록') + '</button>' +
            '</div>' +
        '</div>';

    // 현재 탭 기준 적용 대상 기본값
    if (!isEdit && _epCurrentType) {
        setTimeout(function() {
            var sel = document.getElementById('epSourceType');
            if (sel) sel.value = _epCurrentType;
        }, 0);
    }

    overlay.addEventListener('click', function(e) { if (e.target === overlay) closeEpModal(); });
    document.body.appendChild(overlay);
    setTimeout(function() { document.getElementById('epPattern').focus(); }, 100);
}

function closeEpModal() {
    var el = document.getElementById('epModalOverlay');
    if (el) el.remove();
}

function saveEpModal(patternId) {
    var pattern = document.getElementById('epPattern').value.trim();
    if (!pattern) { showToast('SQL 패턴을 입력하세요.', true); return; }

    var data = {
        pattern: pattern,
        matchType: document.getElementById('epMatchType').value,
        sourceType: document.getElementById('epSourceType').value,
        description: document.getElementById('epDescription').value
    };

    if (patternId) {
        $.ajax({ url: '/accesslog/api/exclude-patterns/' + patternId, type: 'PUT', contentType: 'application/json',
            data: JSON.stringify(data),
            success: function() { closeEpModal(); loadPatterns(); showToast('수정되었습니다.'); }
        });
    } else {
        $.ajax({ url: '/accesslog/api/exclude-patterns', type: 'POST', contentType: 'application/json',
            data: JSON.stringify(data),
            success: function(res) {
                if (res.success) { closeEpModal(); loadPatterns(); showToast('등록되었습니다.'); }
                else showToast(res.message || '등록 실패', true);
            }
        });
    }
}

function togglePattern(patternId, newActive) {
    var p = _allPatterns.find(function(x){return x.patternId == patternId;});
    if (!p) return;
    $.ajax({ url: '/accesslog/api/exclude-patterns/' + patternId, type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ pattern: p.pattern, matchType: p.matchType, description: p.description, isActive: newActive }),
        success: function() { loadPatterns(); }
    });
}

function deletePattern(patternId) {
    showConfirm('이 제외 SQL을 삭제하시겠습니까?', function() {
        $.ajax({ url: '/accesslog/api/exclude-patterns/' + patternId, type: 'DELETE',
            success: function() { loadPatterns(); showToast('삭제되었습니다.'); }
        });
    });
}
</script>
