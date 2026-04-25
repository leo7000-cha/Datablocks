<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
/* ========== Policy List ========== */
.pol-toolbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:16px; }
.pol-toolbar .btn-add { background:linear-gradient(135deg,#7c3aed,#6d28d9); color:#fff; border:none; padding:7px 16px; border-radius:8px; font-size:0.82rem; font-weight:600; cursor:pointer; display:flex; align-items:center; gap:6px; }
.pol-toolbar .btn-add:hover { opacity:0.9; }
.pol-empty { text-align:center; padding:60px 20px; color:#9ca3af; }
.pol-empty i { font-size:2rem; margin-bottom:10px; display:block; }
.pol-empty p { font-size:0.85rem; }
.pol-table { width:100%; border-collapse:separate; border-spacing:0; }
.pol-table thead th { background:#f9fafb; padding:10px 14px; font-size:0.78rem; font-weight:600; color:#6b7280; text-align:left; border-bottom:1px solid #e5e7eb; }
.pol-table tbody td { padding:12px 14px; font-size:0.82rem; color:#1f2937; border-bottom:1px solid #f3f4f6; }
.pol-table tbody tr { cursor:pointer; transition:background 0.1s; }
.pol-table tbody tr:hover { background:#f9fafb; }
.pol-badge { display:inline-flex; align-items:center; gap:4px; padding:3px 10px; border-radius:10px; font-size:0.72rem; font-weight:600; }
.pol-badge-purple { background:#ede9fe; color:#7c3aed; }
.pol-badge-green { background:#dcfce7; color:#15803d; }
.pol-badge-gray { background:#f3f4f6; color:#9ca3af; }
.pol-db-type { font-size:0.7rem; padding:2px 8px; border-radius:4px; font-weight:600; }
.pol-db-oracle { background:#fef3c7; color:#92400e; }
.pol-db-mariadb { background:#dbeafe; color:#1e40af; }

/* ========== Policy Detail ========== */
.pol-detail { display:none !important; }
.pol-detail.visible { display:block !important; }
.pol-detail-header { display:flex; align-items:center; gap:12px; margin-bottom:16px; }
.pol-detail-header .btn-back { background:none; border:1px solid #d1d5db; border-radius:8px; padding:6px 12px; font-size:0.82rem; cursor:pointer; color:#374151; }
.pol-detail-header .btn-back:hover { background:#f3f4f6; }
.pol-detail-header .db-info { font-size:0.95rem; font-weight:700; color:#1f2937; }
.pol-detail-header .db-sub { font-size:0.78rem; color:#6b7280; margin-left:8px; }
.pol-detail-actions { display:flex; gap:8px; margin-left:auto; }
.pol-detail-actions button { padding:7px 16px; border-radius:8px; font-size:0.8rem; font-weight:600; cursor:pointer; display:flex; align-items:center; gap:5px; }
.btn-save { background:#7c3aed; color:#fff; border:none; }
.btn-save:hover { background:#6d28d9; }
.btn-script { background:#fff; color:#7c3aed; border:1px solid #c4b5fd; }
.btn-script:hover { background:#f5f3ff; }

/* ========== Tabs ========== */
.pol-tabs { display:flex; gap:0; border-bottom:2px solid #e5e7eb; margin-bottom:0; }
.pol-tab { padding:10px 24px; font-size:0.85rem; font-weight:600; color:#9ca3af; cursor:pointer; border-bottom:2px solid transparent; margin-bottom:-2px; transition:all 0.15s; display:flex; align-items:center; gap:8px; }
.pol-tab:hover { color:#6b7280; }
.pol-tab.active { color:#7c3aed; border-bottom-color:#7c3aed; }
.pol-tab .tab-count { font-size:0.72rem; background:#f3f4f6; color:#6b7280; padding:2px 8px; border-radius:8px; }
.pol-tab.active .tab-count { background:#ede9fe; color:#7c3aed; }
.pol-tab-content { background:#fff; border:1px solid #e5e7eb; border-top:none; border-radius:0 0 12px 12px; padding:16px; }

/* ========== Dual Panel ========== */
.dual-panel { display:flex; gap:0; height:calc(100vh - 340px); min-height:380px; border:1px solid #e5e7eb; border-radius:10px; overflow:hidden; }
.dual-panel-col { flex:1; display:flex; flex-direction:column; min-width:0; }
.dual-panel-head { padding:8px 12px; background:#f9fafb; border-bottom:1px solid #e5e7eb; display:flex; align-items:center; gap:6px; flex-shrink:0; }
.dual-panel-head .panel-title { font-size:0.78rem; font-weight:700; color:#374151; white-space:nowrap; }
.dual-panel-head .panel-count { font-size:0.72rem; color:#9ca3af; }
.dual-panel-head .panel-search { flex:1; padding:5px 10px; border:1px solid #e5e7eb; border-radius:6px; font-size:0.78rem; background:#fff; outline:none; min-width:0; }
.dual-panel-head .panel-search:focus { border-color:#c4b5fd; }
.dual-panel-body { flex:1; overflow-y:auto; padding:2px 0; }
.dual-panel-item { display:flex; align-items:center; gap:5px; padding:4px 10px; cursor:pointer; font-size:0.78rem; transition:background 0.1s; user-select:none; }
.dual-panel-item:hover { background:#f3f4f6; }
.dual-panel-item input[type=checkbox] { flex-shrink:0; margin:0; cursor:pointer; }
.dual-panel-item .tbl-name { flex:1; color:#1f2937; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.dual-panel-item .tbl-meta { color:#9ca3af; font-size:0.68rem; white-space:nowrap; }
.dual-panel-item .tag-pii { background:#ede9fe; color:#7c3aed; font-size:0.62rem; padding:1px 5px; border-radius:3px; }
.dual-panel-item .tag-biz { background:#fef3c7; color:#92400e; font-size:0.62rem; padding:1px 5px; border-radius:3px; }
.dual-panel-mid { display:flex; flex-direction:column; justify-content:center; align-items:center; gap:6px; padding:0 8px; flex-shrink:0; }
.dual-panel-mid button { width:34px; height:30px; border:1px solid #d1d5db; border-radius:6px; background:#fff; cursor:pointer; font-size:0.78rem; color:#374151; display:flex; align-items:center; justify-content:center; transition:all 0.15s; }
.dual-panel-mid button:hover { background:#7c3aed; color:#fff; border-color:#7c3aed; }
.schema-hdr { font-size:0.68rem; font-weight:700; padding:5px 10px 2px; opacity:0.7; }
</style>

<!-- ==================== 목록 뷰 ==================== -->
<div id="policyListView">
    <div class="pol-toolbar">
        <div style="font-size:0.82rem;color:#6b7280;">DB별 감사 대상 테이블 설정 현황</div>
        <button class="btn-add" onclick="openNewPolicy()"><i class="fas fa-plus"></i> 감사 대상 등록</button>
    </div>
    <table class="pol-table" id="policyTable">
        <thead>
            <tr>
                <th>DB</th>
                <th>시스템</th>
                <th>유형</th>
                <th>DB Audit 대상</th>
                <th>Java Agent (BCI) 대상</th>
                <th></th>
            </tr>
        </thead>
        <tbody id="policyListBody">
            <tr><td colspan="6" style="text-align:center;color:#9ca3af;padding:40px;">로딩 중...</td></tr>
        </tbody>
    </table>
</div>

<!-- ==================== 상세 편집 뷰 ==================== -->
<div id="policyDetailView" class="pol-detail">
    <div class="pol-detail-header">
        <button class="btn-back" onclick="showPolicyList()"><i class="fas fa-arrow-left"></i> 목록</button>
        <!-- 신규 등록 시 DB 선택 -->
        <div id="detailDbSelect" style="display:none;">
            <select id="newPolicyDbSelect" onchange="onNewDbSelected()" style="padding:7px 12px;border:1px solid #d1d5db;border-radius:8px;font-size:0.85rem;min-width:260px;">
                <option value="">-- 대상 DB를 선택하세요 --</option>
                <c:forEach var="db" items="${dbList}">
                    <option value="${db.db}" data-type="${db.dbtype}" data-host="${db.hostname}" data-port="${db.port}" data-system="${db.system}">${db.db} (${db.dbtype} · ${db.hostname}:${db.port})</option>
                </c:forEach>
            </select>
        </div>
        <!-- 수정 시 DB 정보 표시 -->
        <span class="db-info" id="detailDbName"></span>
        <span class="db-sub" id="detailDbSub"></span>
        <div class="pol-detail-actions">
            <button class="btn-save" onclick="savePolicy()"><i class="fas fa-save"></i> 저장</button>
            <button class="btn-script" onclick="downloadScript()"><i class="fas fa-file-download"></i> 스크립트 다운로드</button>
        </div>
    </div>

    <div class="pol-tabs">
        <div class="pol-tab active" id="tabDbAudit" onclick="switchTab('dbaudit')">
            <i class="fas fa-database"></i> DB Audit <span class="tab-count" id="tabDbAuditCount">0</span>
        </div>
        <div class="pol-tab" id="tabBci" onclick="switchTab('bci')">
            <i class="fas fa-satellite-dish"></i> Java Agent (BCI) <span class="tab-count" id="tabBciCount">0</span>
        </div>
    </div>
    <div class="pol-tab-content" id="tabContent"></div>
</div>

<script>
var _currentDbName = null;
var _configuredDbs = {};
var _currentDbType = null;
var _policyData = {};
var _currentTab = 'dbaudit';

// ========== 목록 ==========
function loadPolicyList() {
    $.get('/accesslog/api/policy/list', function(list) {
        // 정책이 설정된 DB만 필터
        var filtered = (list || []).filter(function(db) { return db.auditCount > 0 || db.bciCount > 0; });
        _configuredDbs = {};
        filtered.forEach(function(db) { _configuredDbs[db.dbName] = true; });
        var html = '';
        if (filtered.length === 0) {
            html = '<tr><td colspan="6"><div class="pol-empty"><i class="fas fa-shield-alt"></i><p>등록된 감사 대상이 없습니다.<br>"감사 대상 등록" 버튼으로 DB별 감사 대상 테이블을 설정하세요.</p></div></td></tr>';
        } else {
            filtered.forEach(function(db) {
                var typeClass = db.dbType === 'ORACLE' ? 'pol-db-oracle' : 'pol-db-mariadb';
                var auditBadge = db.auditCount > 0
                    ? '<span class="pol-badge pol-badge-purple"><i class="fas fa-database"></i> ' + db.auditCount + '개 테이블</span>'
                    : '<span class="pol-badge pol-badge-gray">미설정</span>';
                var bciBadge = db.bciCount > 0
                    ? '<span class="pol-badge pol-badge-green"><i class="fas fa-globe"></i> ' + db.bciCount + '개 테이블</span>'
                    : '<span class="pol-badge pol-badge-gray">미설정</span>';
                html += '<tr onclick="openPolicyDetail(\'' + db.dbName + '\',\'' + db.dbType + '\',\'' + (db.hostname||'') + '\',\'' + (db.port||'') + '\',\'' + (db.system||'') + '\')">' +
                    '<td><strong>' + db.dbName + '</strong><div style="font-size:0.72rem;color:#9ca3af;">' + (db.hostname||'') + ':' + (db.port||'') + '</div></td>' +
                    '<td>' + (db.system||'-') + '</td>' +
                    '<td><span class="pol-db-type ' + typeClass + '">' + db.dbType + '</span></td>' +
                    '<td>' + auditBadge + '</td>' +
                    '<td>' + bciBadge + '</td>' +
                    '<td style="text-align:right;"><i class="fas fa-pen" style="color:#9ca3af;font-size:0.75rem;"></i></td>' +
                '</tr>';
            });
        }
        document.getElementById('policyListBody').innerHTML = html;

        // 이미 정책이 있는 DB는 등록 드롭다운에서 숨김
        var usedDbs = {};
        filtered.forEach(function(db) { usedDbs[db.dbName] = true; });
        var sel = document.getElementById('addPolicyDb');
        for (var i = 0; i < sel.options.length; i++) {
            if (sel.options[i].value && usedDbs[sel.options[i].value]) {
                sel.options[i].disabled = true;
                sel.options[i].text = sel.options[i].text.replace(/ \(설정됨\)$/, '') + ' (설정됨)';
            }
        }
    });
}
loadPolicyList();

function openNewPolicy() {
    _currentDbName = null;
    _currentDbType = null;
    document.getElementById('policyListView').style.display = 'none';
    var detail = document.getElementById('policyDetailView');
    detail.classList.add('visible');

    // 신규 모드: DB 선택 드롭다운 보이기, DB 정보 숨기기
    document.getElementById('detailDbSelect').style.display = '';
    document.getElementById('detailDbName').style.display = 'none';
    document.getElementById('detailDbSub').style.display = 'none';

    // 이미 설정된 DB 제외
    var sel = document.getElementById('newPolicyDbSelect');
    sel.value = '';
    for (var i = 0; i < sel.options.length; i++) {
        var opt = sel.options[i];
        if (opt.value && _configuredDbs[opt.value]) {
            opt.disabled = true;
            if (opt.text.indexOf('(설정됨)') < 0) opt.text += ' (설정됨)';
        } else {
            opt.disabled = false;
            opt.text = opt.text.replace(/ \(설정됨\)$/, '');
        }
    }

    // 탭/내용 초기화
    document.getElementById('tabContent').innerHTML = '<div style="padding:40px;text-align:center;color:#9ca3af;font-size:0.85rem;"><i class="fas fa-hand-pointer" style="font-size:1.5rem;margin-bottom:10px;display:block;"></i>대상 DB를 선택하면 감사 대상 테이블을 설정할 수 있습니다.</div>';
    document.getElementById('tabDbAuditCount').textContent = '0';
    document.getElementById('tabBciCount').textContent = '0';
}

function onNewDbSelected() {
    var sel = document.getElementById('newPolicyDbSelect');
    var opt = sel.options[sel.selectedIndex];
    if (!opt || !opt.value) return;
    _currentDbName = opt.value;
    _currentDbType = opt.getAttribute('data-type') || '';

    // 스크립트 버튼: Oracle만 표시
    document.querySelector('.btn-script').style.display = _currentDbType === 'ORACLE' ? '' : 'none';

    loadPolicyDetail();
}

function showPolicyList() {
    document.getElementById('policyListView').style.display = '';
    document.getElementById('policyDetailView').classList.remove('visible');
    loadPolicyList();
}

// ========== 상세 편집 (수정 모드) ==========
function openPolicyDetail(dbName, dbType, host, port, system) {
    _currentDbName = dbName;
    _currentDbType = dbType;

    document.getElementById('policyListView').style.display = 'none';
    var detail = document.getElementById('policyDetailView');
    detail.classList.add('visible');

    // 수정 모드: DB 선택 숨기고, DB 정보 표시
    document.getElementById('detailDbSelect').style.display = 'none';
    document.getElementById('detailDbName').style.display = '';
    document.getElementById('detailDbSub').style.display = '';
    document.getElementById('detailDbName').textContent = dbName;
    document.getElementById('detailDbSub').textContent = dbType + ' · ' + host + ':' + port + (system ? ' · ' + system : '');

    // 스크립트 버튼: Oracle만 표시
    document.querySelector('.btn-script').style.display = dbType === 'ORACLE' ? '' : 'none';

    loadPolicyDetail();
}

function loadPolicyDetail() {
    $.get('/accesslog/api/setup/status', { dbName: _currentDbName }, function(res) {
        if (!res.success) { showToast(res.message, true); return; }
        _policyData = res;
        document.getElementById('tabDbAuditCount').textContent =
            (res.piiTables || []).filter(function(t) { return t.auditYn === 'Y'; }).length;
        document.getElementById('tabBciCount').textContent = res.bciTargetCount || 0;
        _currentTab = 'dbaudit';
        document.querySelectorAll('.pol-tab').forEach(function(el) { el.classList.remove('active'); });
        document.getElementById('tabDbAudit').classList.add('active');
        switchTab('dbaudit');
    });
}

function switchTab(tab) {
    _currentTab = tab;
    document.querySelectorAll('.pol-tab').forEach(function(el) { el.classList.remove('active'); });
    document.getElementById(tab === 'dbaudit' ? 'tabDbAudit' : 'tabBci').classList.add('active');
    // 스크립트 다운로드: DB Audit 탭 + Oracle일 때만
    document.querySelector('.btn-script').style.display = (tab === 'dbaudit' && _currentDbType === 'ORACLE') ? '' : 'none';
    if (tab === 'dbaudit') renderDbAuditTab(); else renderBciTab();
}

// ========== DB Audit 탭 ==========
function renderDbAuditTab() {
    var tables = _policyData.piiTables || [];
    var left = [], right = [];
    tables.forEach(function(t) {
        var item = { owner:t.owner||'', tableName:t.tableName, piiColumns:t.piiColumns||'', piiColumnCount:t.piiColumnCount };
        if (t.auditYn === 'Y') right.push(item); else left.push(item);
    });
    window._auditLeft = left;
    window._auditRight = right;
    renderDualPanel('audit', 'PII 테이블', 'Audit 대상', '#7c3aed', '#f5f3ff');
}

// ========== BCI 탭 ==========
function renderBciTab() {
    var allTables = _policyData.allTables || [];
    var bciTargets = _policyData.bciTargets || [];
    var bciSet = {};
    bciTargets.forEach(function(t) { bciSet[(t.owner||'') + '.' + t.tableName] = t; });
    var left = [], right = [];
    allTables.forEach(function(t) {
        var key = (t.owner||'') + '.' + t.tableName;
        var item = { owner:t.owner||'', tableName:t.tableName, piiColumnCount:t.piiColumnCount||0, totalColumnCount:t.totalColumnCount||0 };
        if (bciSet[key]) right.push(item); else left.push(item);
    });
    window._bciLeft = left;
    window._bciRight = right;
    renderDualPanel('bci', '전체 테이블', 'BCI 대상', '#059669', '#ecfdf5');
}

// ========== 공통 듀얼 패널 ==========
function renderDualPanel(prefix, leftTitle, rightTitle, color, rightBg) {
    var html = '<div class="dual-panel">' +
      '<div class="dual-panel-col">' +
        '<div class="dual-panel-head">' +
          '<span class="panel-title"><i class="fas fa-database" style="color:#6b7280;margin-right:3px;"></i>' + leftTitle + '</span>' +
          '<span class="panel-count" id="' + prefix + 'LeftCount"></span>' +
          '<label style="margin-left:auto;font-size:0.72rem;color:#64748b;cursor:pointer;display:flex;align-items:center;gap:3px;">' +
            '<input type="checkbox" id="' + prefix + 'LeftCheckAll" onchange="toggleCheckAll(\'' + prefix + 'Left\')" style="accent-color:#0d9488;">' +
            '전체</label>' +
          '<input type="text" class="panel-search" id="' + prefix + 'LeftSearch" placeholder="검색..." oninput="filterPanel(\'' + prefix + 'Left\')">' +
        '</div>' +
        '<div class="dual-panel-body" id="' + prefix + 'LeftPanel"></div>' +
      '</div>' +
      '<div class="dual-panel-mid">' +
        '<button onclick="moveItems(\'' + prefix + '\',\'right\')"><i class="fas fa-chevron-right"></i></button>' +
        '<button onclick="moveAllItems(\'' + prefix + '\',\'right\')"><i class="fas fa-angle-double-right"></i></button>' +
        '<button onclick="moveItems(\'' + prefix + '\',\'left\')"><i class="fas fa-chevron-left"></i></button>' +
        '<button onclick="moveAllItems(\'' + prefix + '\',\'left\')"><i class="fas fa-angle-double-left"></i></button>' +
      '</div>' +
      '<div class="dual-panel-col">' +
        '<div class="dual-panel-head" style="background:' + rightBg + ';">' +
          '<span class="panel-title" style="color:' + color + ';"><i class="fas fa-shield-alt" style="margin-right:3px;"></i>' + rightTitle + '</span>' +
          '<span class="panel-count" id="' + prefix + 'RightCount" style="color:' + color + ';"></span>' +
          '<label style="margin-left:auto;font-size:0.72rem;color:' + color + ';cursor:pointer;display:flex;align-items:center;gap:3px;">' +
            '<input type="checkbox" id="' + prefix + 'RightCheckAll" onchange="toggleCheckAll(\'' + prefix + 'Right\')" style="accent-color:' + color + ';">' +
            '전체</label>' +
          '<input type="text" class="panel-search" id="' + prefix + 'RightSearch" placeholder="검색..." oninput="filterPanel(\'' + prefix + 'Right\')">' +
        '</div>' +
        '<div class="dual-panel-body" id="' + prefix + 'RightPanel"></div>' +
      '</div>' +
    '</div>';
    document.getElementById('tabContent').innerHTML = html;
    renderPanelLists(prefix);
}

function renderPanelLists(prefix) {
    renderPanelList(prefix + 'LeftPanel', window['_' + prefix + 'Left'], prefix + 'LeftCount', prefix);
    renderPanelList(prefix + 'RightPanel', window['_' + prefix + 'Right'], prefix + 'RightCount', prefix);
    if (prefix === 'audit') document.getElementById('tabDbAuditCount').textContent = window._auditRight.length;
    if (prefix === 'bci') document.getElementById('tabBciCount').textContent = window._bciRight.length;
}

function renderPanelList(panelId, items, countId, prefix) {
    var html = '';
    var groups = {};
    items.forEach(function(t, idx) {
        var k = t.owner || '(없음)';
        if (!groups[k]) groups[k] = [];
        groups[k].push({ item:t, idx:idx });
    });
    var schemaColor = prefix === 'bci' ? '#059669' : '#7c3aed';
    for (var schema in groups) {
        html += '<div class="schema-hdr" style="color:' + schemaColor + ';">' + schema + '</div>';
        groups[schema].forEach(function(g) {
            var meta = prefix === 'bci'
                ? (g.item.piiColumnCount > 0 ? '<span class="tag-pii">PII ' + g.item.piiColumnCount + '</span>' : '<span class="tag-biz">업무</span>')
                : '<span class="tbl-meta">' + g.item.piiColumnCount + '</span>';
            html += '<div class="dual-panel-item" data-idx="' + g.idx + '" data-table="' + g.item.tableName.toLowerCase() + '">' +
              '<input type="checkbox" onclick="event.stopPropagation()">' +
              '<span class="tbl-name">' + g.item.tableName + '</span>' + meta + '</div>';
        });
    }
    if (items.length === 0) html = '<div style="padding:30px;text-align:center;color:#9ca3af;font-size:0.8rem;">항목 없음</div>';
    document.getElementById(panelId).innerHTML = html;
    document.getElementById(countId).textContent = items.length + '개';
}

function filterPanel(side) {
    var kw = document.getElementById(side + 'Search').value.toLowerCase();
    document.getElementById(side + 'Panel').querySelectorAll('.dual-panel-item').forEach(function(el) {
        el.style.display = el.getAttribute('data-table').indexOf(kw) >= 0 ? '' : 'none';
    });
    // 전체 선택 체크박스 상태 초기화
    var checkAll = document.getElementById(side + 'CheckAll');
    if (checkAll) checkAll.checked = false;
}

function toggleCheckAll(side) {
    var checked = document.getElementById(side + 'CheckAll').checked;
    document.getElementById(side + 'Panel').querySelectorAll('.dual-panel-item').forEach(function(el) {
        // 현재 보이는(검색 필터에 해당하는) 항목만 선택/해제
        if (el.style.display !== 'none') {
            el.querySelector('input[type="checkbox"]').checked = checked;
        }
    });
}

function moveItems(prefix, dir) {
    var src = dir === 'right' ? 'Left' : 'Right', dst = dir === 'right' ? 'Right' : 'Left';
    var indices = [];
    document.querySelectorAll('#' + prefix + src + 'Panel .dual-panel-item input:checked').forEach(function(cb) {
        indices.push(parseInt(cb.closest('.dual-panel-item').getAttribute('data-idx')));
    });
    indices.sort(function(a,b){return b-a;});
    indices.forEach(function(i) { window['_' + prefix + dst].push(window['_' + prefix + src].splice(i,1)[0]); });
    sortLists(prefix); renderPanelLists(prefix);
}

function moveAllItems(prefix, dir) {
    var src = dir === 'right' ? 'Left' : 'Right', dst = dir === 'right' ? 'Right' : 'Left';
    var kw = (document.getElementById(prefix + src + 'Search') || {}).value || '';
    kw = kw.toLowerCase();
    var keep = [], move = [];
    window['_' + prefix + src].forEach(function(t) {
        if (!kw || t.tableName.toLowerCase().indexOf(kw) >= 0) move.push(t); else keep.push(t);
    });
    window['_' + prefix + src] = keep;
    window['_' + prefix + dst] = window['_' + prefix + dst].concat(move);
    sortLists(prefix); renderPanelLists(prefix);
}

function sortLists(prefix) {
    var cmp = function(a,b) { return (a.owner+a.tableName).localeCompare(b.owner+b.tableName); };
    window['_' + prefix + 'Left'].sort(cmp);
    window['_' + prefix + 'Right'].sort(cmp);
}

// ========== 저장 ==========
function savePolicy() {
    if (!_currentDbName) return;

    // DB Audit 저장
    var allAudit = (window._auditLeft||[]).concat(window._auditRight||[]);
    $.ajax({ url:'/accesslog/api/audit-policy/save-batch', type:'POST', contentType:'application/json',
        data: JSON.stringify({ dbName:_currentDbName, tables:allAudit.map(function(t){return{owner:t.owner,tableName:t.tableName};}), auditYn:null }),
        async:false });
    if ((window._auditRight||[]).length > 0) {
        $.ajax({ url:'/accesslog/api/audit-policy/save-batch', type:'POST', contentType:'application/json',
            data: JSON.stringify({ dbName:_currentDbName, tables:window._auditRight.map(function(t){return{owner:t.owner,tableName:t.tableName};}), auditYn:'Y' }),
            async:false });
    }

    // BCI 저장
    var bciTables = (window._bciRight||[]).map(function(t) {
        return { owner:t.owner, tableName:t.tableName, targetType:t.piiColumnCount > 0 ? 'PII' : 'BUSINESS' };
    });
    $.ajax({ url:'/accesslog/api/bci-target/save', type:'POST', contentType:'application/json',
        data: JSON.stringify({ dbName:_currentDbName, tables:bciTables }),
        async:false });

    showToast('DB Audit ' + (window._auditRight||[]).length + '개, Java Agent (BCI) ' + bciTables.length + '개 감사 대상 저장 완료');
}

// ========== 스크립트 다운로드 (DB Audit 전용) ==========
function downloadScript() {
    if (!_currentDbName) return;
    var right = window._auditRight || [];
    if (right.length === 0) { showToast('DB Audit 대상 테이블이 없습니다.', true); return; }

    var scriptTables = right.map(function(t) { return { owner:t.owner, tableName:t.tableName, piiColumns:t.piiColumns }; });
    $.ajax({
        url:'/accesslog/api/audit-policy/script',
        type:'POST', contentType:'application/json',
        data: JSON.stringify({ dbName:_currentDbName, tables:scriptTables }),
        success: function(res) {
            if (!res.success) { showToast(res.message, true); return; }
            var blob = new Blob([res.script], { type:'text/sql;charset=utf-8' });
            var a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'XAUDIT_POLICY_' + _currentDbName + '_' + new Date().toISOString().slice(0,10).replace(/-/g,'') + '.sql';
            a.click();
            URL.revokeObjectURL(a.href);
            showToast('스크립트가 다운로드됩니다.');
        },
        error: function() { showToast('스크립트 생성 실패', true); }
    });
}
</script>
