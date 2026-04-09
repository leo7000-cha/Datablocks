<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div id="sourcesContent">
    <div style="margin-bottom:20px; text-align:right;">
        <button class="btn-monitor" onclick="showSourceForm()"><i class="fas fa-plus"></i> 수집 대상 등록</button>
    </div>

    <div class="content-panel">
        <div class="panel-header"><h3 class="panel-title">수집 대상 시스템 (${total}건)</h3></div>
        <div class="panel-body" style="padding:0;">
            <table class="monitor-table">
                <thead><tr><th>시스템명</th><th>수집방식</th><th>DB유형</th><th>호스트</th><th>제외 계정</th><th>상태</th><th>최근수집</th><th>누적건수</th><th>작업</th></tr></thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty list}">
                            <c:forEach var="src" items="${list}">
                                <tr>
                                    <td><strong>${src.sourceName}</strong></td>
                                    <td>${src.sourceType}</td>
                                    <td>${src.dbType}</td>
                                    <td>${src.hostname}:${src.port}</td>
                                    <td style="max-width:150px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${src.excludeAccounts}">${src.excludeAccounts != null ? src.excludeAccounts : '-'}</td>
                                    <td><span class="status-badge ${src.status == 'RUNNING' ? 'running' : src.status == 'ERROR' ? 'error' : 'stopped'}">${src.status}</span></td>
                                    <td style="white-space:nowrap;">${src.lastCollectTime != null ? src.lastCollectTime : '-'}</td>
                                    <td>${src.totalCollected != null ? src.totalCollected : 0}</td>
                                    <td style="white-space:nowrap;">
                                        <button class="btn-outline" style="padding:4px 8px; font-size:0.75rem;" onclick="startCollect('${src.sourceId}')"><i class="fas fa-play"></i></button>
                                        <button class="btn-outline" style="padding:4px 8px; font-size:0.75rem;" onclick="stopCollect('${src.sourceId}')"><i class="fas fa-stop"></i></button>
                                        <button class="btn-outline" style="padding:4px 8px; font-size:0.75rem;" onclick="editSource('${src.sourceId}')"><i class="fas fa-edit"></i></button>
                                        <button class="btn-outline" style="padding:4px 8px; font-size:0.75rem; color:#ef4444; border-color:#ef4444;" onclick="deleteSource('${src.sourceId}')"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="9" style="text-align:center; padding:40px; color:#94a3b8;">등록된 수집 대상이 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Source Form Modal -->
<div id="sourceFormModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.5); z-index:9999; display:none; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:12px; max-width:500px; width:90%; padding:24px;">
        <h3 style="margin:0 0 20px;">수집 대상 등록</h3>
        <form id="sourceForm">
            <input type="hidden" id="sf_sourceId">
            <div style="margin-bottom:12px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">시스템명 *</label><input type="text" id="sf_sourceName" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px;"></div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px;">
                <div><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">수집방식</label><select id="sf_sourceType" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px;"><option value="DB_AUDIT">DB Audit Log</option><option value="GENERAL_LOG">General Log</option><option value="DLM_SELF">DLM 자체</option></select></div>
                <div><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">DB유형</label><select id="sf_dbType" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px;"><option value="ORACLE">Oracle</option><option value="MARIADB">MariaDB</option><option value="MYSQL">MySQL</option><option value="MSSQL">MSSQL</option><option value="TIBERO">Tibero</option></select></div>
            </div>
            <div style="margin-bottom:12px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">연계 DB *</label><select id="sf_dbName" onchange="onDbSelect()" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px;"><option value="">-- 연계 DB 선택 --</option></select></div>
            <div style="display:grid; grid-template-columns:2fr 1fr; gap:12px; margin-bottom:12px;">
                <div><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">호스트</label><input type="text" id="sf_hostname" readonly style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; background:#f8fafc; color:#64748b;"></div>
                <div><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">포트</label><input type="text" id="sf_port" readonly style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; background:#f8fafc; color:#64748b;"></div>
            </div>
            <div style="margin-bottom:12px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">스키마명</label><input type="text" id="sf_schemaName" placeholder="예: HR, SCOTT (PII 매칭용)" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem;"><span style="font-size:0.75rem; color:#94a3b8;">TBL_METATABLE의 owner와 매칭되는 스키마명. SQL 파싱 시 PII 자동 분류에 사용됩니다.</span></div>
            <div style="margin-bottom:12px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">제외 계정</label><textarea id="sf_excludeAccounts" rows="2" placeholder="SYS, SYSTEM, DLM_BATCH" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem;"></textarea><span style="font-size:0.75rem; color:#94a3b8;">콤마(,)로 구분하여 입력. 해당 계정의 SQL은 수집에서 제외됩니다.</span></div>
            <div style="margin-bottom:12px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">대상 테이블</label><textarea id="sf_tableFilter" rows="2" placeholder="비워두면 전체 테이블" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:0.85rem;"></textarea><span style="font-size:0.75rem; color:#94a3b8;">콤마(,)로 구분하여 입력. 비워두면 모든 테이블을 수집합니다.</span></div>
            <div style="margin-bottom:20px;"><label style="font-size:0.85rem; font-weight:600; display:block; margin-bottom:4px;">설명</label><textarea id="sf_description" rows="2" style="width:100%; padding:8px 12px; border:1px solid #e2e8f0; border-radius:8px;"></textarea></div>
            <div style="text-align:right; display:flex; gap:8px; justify-content:flex-end;">
                <button type="button" class="btn-outline" onclick="$('#sourceFormModal').hide()">취소</button>
                <button type="button" class="btn-monitor" onclick="saveSource()">저장</button>
            </div>
        </form>
    </div>
</div>

<script>
var _dbList = []; // 연계 DB 목록 캐시

function loadDatabaseList(callback) {
    $.get('/accesslog/api/databases', function(list) {
        _dbList = list || [];
        var $sel = $('#sf_dbName');
        $sel.find('option:not(:first)').remove();
        $.each(_dbList, function(i, db) {
            $sel.append('<option value="' + db.db + '">' + db.db + ' (' + db.dbtype + ' - ' + db.hostname + ':' + db.port + ')</option>');
        });
        if (callback) callback();
    });
}

function onDbSelect() {
    var dbName = $('#sf_dbName').val();
    var db = _dbList.find(function(d) { return d.db === dbName; });
    if (db) {
        $('#sf_dbType').val(db.dbtype.toUpperCase());
        $('#sf_hostname').val(db.hostname);
        $('#sf_port').val(db.port);
        if (!$('#sf_sourceName').val()) {
            $('#sf_sourceName').val(db.system || db.db);
        }
    } else {
        $('#sf_hostname').val('');
        $('#sf_port').val('');
    }
}

function showSourceForm() {
    $('#sourceForm')[0].reset();
    $('#sf_sourceId').val('');
    loadDatabaseList(function() {
        $('#sourceFormModal').css('display','flex');
    });
}

function saveSource() {
    var sourceId = $('#sf_sourceId').val();
    var data = {
        sourceName: $('#sf_sourceName').val(),
        sourceType: $('#sf_sourceType').val(),
        dbType: $('#sf_dbType').val(),
        dbName: $('#sf_dbName').val(),
        hostname: $('#sf_hostname').val(),
        port: $('#sf_port').val(),
        schemaName: $('#sf_schemaName').val(),
        excludeAccounts: $('#sf_excludeAccounts').val(),
        tableFilter: $('#sf_tableFilter').val(),
        description: $('#sf_description').val()
    };
    var url = sourceId ? '/accesslog/api/source/' + sourceId : '/accesslog/api/source';
    var method = sourceId ? 'PUT' : 'POST';
    $.ajax({ url: url, type: method, contentType: 'application/json', data: JSON.stringify(data),
        success: function(res) {
            if (res.success) {
                $('#sourceFormModal').hide();
                $.get('/accesslog/sources', function(html) { $('#mainContent').html(html); });
            } else { alert(res.message || '저장 실패'); }
        }
    });
}

function editSource(sourceId) {
    $.get('/accesslog/api/collection/' + sourceId + '/status', function(res) {
        var src = res.source;
        if (src) {
            loadDatabaseList(function() {
                $('#sf_sourceId').val(src.sourceId);
                $('#sf_sourceName').val(src.sourceName);
                $('#sf_sourceType').val(src.sourceType);
                $('#sf_dbType').val(src.dbType);
                $('#sf_dbName').val(src.dbName);
                $('#sf_hostname').val(src.hostname);
                $('#sf_port').val(src.port);
                $('#sf_schemaName').val(src.schemaName || '');
                $('#sf_excludeAccounts').val(src.excludeAccounts || '');
                $('#sf_tableFilter').val(src.tableFilter || '');
                $('#sf_description').val(src.description);
                $('#sourceFormModal').css('display','flex');
            });
        }
    });
}

function deleteSource(sourceId) {
    if (!confirm('수집 대상을 삭제하시겠습니까?')) return;
    $.ajax({ url: '/accesslog/api/source/' + sourceId, type: 'DELETE',
        success: function(res) { if (res.success) $.get('/accesslog/sources', function(html) { $('#mainContent').html(html); }); }
    });
}

function startCollect(sourceId) {
    $.post('/accesslog/api/collection/' + sourceId + '/start', function(res) {
        alert(res.message || '수집 완료');
        $.get('/accesslog/sources', function(html) { $('#mainContent').html(html); });
    });
}

function stopCollect(sourceId) {
    $.post('/accesslog/api/collection/' + sourceId + '/stop', function(res) {
        $.get('/accesslog/sources', function(html) { $('#mainContent').html(html); });
    });
}
</script>