<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
/* ========== Zone A: Status Summary ========== */
.src-stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px; margin-bottom: 20px; }
.src-stat-card { background: #fff; border-radius: 12px; padding: 16px 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.2s; border: 2px solid transparent; }
.src-stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.src-stat-card.active { border-color: var(--monitor-primary); }
.src-stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.src-stat-icon.total { background: #ccfbf1; color: var(--monitor-primary); }
.src-stat-icon.running { background: #d1fae5; color: #059669; }
.src-stat-icon.stopped { background: #f1f5f9; color: #64748b; }
.src-stat-icon.error { background: #fee2e2; color: #ef4444; }
.src-stat-icon.agent { background: #ede9fe; color: #7c3aed; }
.src-stat-icon i { font-size: 1.1rem; }
.src-stat-value { font-size: 1.5rem; font-weight: 700; color: #1e293b; }
.src-stat-label { font-size: 0.78rem; color: #64748b; margin-top: 2px; }

/* ========== Zone B: Toolbar ========== */
.src-toolbar { background: #fff; border-radius: 12px; padding: 14px 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 20px; display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.src-toolbar .batch-section { display: flex; align-items: center; gap: 8px; padding-right: 16px; border-right: 1px solid #e2e8f0; }
.src-toolbar .batch-section.hidden { display: none; }
.batch-count { font-size: 0.8rem; color: var(--monitor-primary); font-weight: 600; white-space: nowrap; }
.btn-batch { padding: 6px 12px; border-radius: 6px; font-size: 0.78rem; font-weight: 500; cursor: pointer; border: 1px solid #e2e8f0; background: #fff; color: #475569; transition: all 0.15s; display: inline-flex; align-items: center; gap: 4px; }
.btn-batch:hover { background: #f8fafc; border-color: #cbd5e1; }
.btn-batch.danger:hover { background: #fef2f2; border-color: #fca5a5; color: #dc2626; }
.src-toolbar .filter-section { display: flex; align-items: center; gap: 8px; flex: 1; }
.src-toolbar .filter-section input,
.src-toolbar .filter-section select { padding: 7px 12px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.82rem; color: #334155; }
.src-toolbar .filter-section input { width: 200px; }
.src-toolbar .action-section { display: flex; align-items: center; gap: 8px; margin-left: auto; }
.btn-view-toggle { padding: 7px 10px; border: 1px solid #e2e8f0; border-radius: 8px; background: #fff; color: #94a3b8; cursor: pointer; font-size: 0.9rem; transition: all 0.15s; }
.btn-view-toggle.active { background: var(--monitor-primary); color: #fff; border-color: var(--monitor-primary); }

/* ========== Zone C: Card View ========== */
.src-card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(380px, 1fr)); gap: 20px; }
.src-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; transition: all 0.2s; border: 2px solid transparent; }
.src-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
.src-card.selected { border-color: var(--monitor-primary); background: #f0fdfa; }
.src-card-header { padding: 16px 20px 12px; display: flex; align-items: flex-start; gap: 12px; }
.src-card-check { margin-top: 3px; }
.src-card-check input[type="checkbox"] { width: 16px; height: 16px; accent-color: var(--monitor-primary); cursor: pointer; }
.src-card-info { flex: 1; min-width: 0; }
.src-card-top { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
.src-type-badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 0.7rem; font-weight: 600; }
.src-type-badge.db-audit { background: #dbeafe; color: #1d4ed8; }
.src-type-badge.bci-agent { background: #ede9fe; color: #7c3aed; }
.src-type-badge.dac { background: #fef3c7; color: #92400e; }
.src-type-badge.dlm-self { background: #f1f5f9; color: #64748b; }
.src-status-dot { width: 10px; height: 10px; border-radius: 50%; margin-left: auto; flex-shrink: 0; }
.src-status-dot.running { background: #10b981; animation: pulse-green 2s infinite; }
.src-status-dot.stopped { background: #94a3b8; }
.src-status-dot.error { background: #ef4444; animation: pulse-red 2s infinite; }
@keyframes pulse-green { 0%, 100% { box-shadow: 0 0 0 0 rgba(16,185,129,0.4); } 50% { box-shadow: 0 0 0 6px rgba(16,185,129,0); } }
@keyframes pulse-red { 0%, 100% { box-shadow: 0 0 0 0 rgba(239,68,68,0.4); } 50% { box-shadow: 0 0 0 6px rgba(239,68,68,0); } }
.src-status-text { font-size: 0.7rem; font-weight: 600; margin-left: 4px; }
.src-status-text.running { color: #059669; }
.src-status-text.stopped { color: #64748b; }
.src-status-text.error { color: #ef4444; }
.src-card-name { font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.src-card-sub { font-size: 0.8rem; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.src-card-sub .db-type-tag { font-weight: 600; color: #475569; }
.src-card-metrics { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0; padding: 12px 20px; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9; }
.src-metric { text-align: center; }
.src-metric:not(:last-child) { border-right: 1px solid #f1f5f9; }
.src-metric-value { font-size: 0.85rem; font-weight: 700; color: #1e293b; }
.src-metric-label { font-size: 0.7rem; color: #94a3b8; margin-top: 2px; }
.src-card-agent { padding: 8px 20px; background: #faf5ff; display: flex; align-items: center; gap: 12px; font-size: 0.78rem; }
.src-card-agent i { color: #7c3aed; }
.src-card-agent .agent-hb { color: #475569; }
.src-card-agent .agent-active { color: #059669; font-weight: 600; }
.src-card-agent .agent-inactive { color: #ef4444; font-weight: 600; }
.src-card-error { padding: 8px 20px; background: #fef2f2; display: flex; align-items: center; gap: 8px; font-size: 0.78rem; color: #dc2626; }
.src-card-error i { flex-shrink: 0; }
.src-card-error span { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.src-card-actions { padding: 12px 20px; display: flex; align-items: center; gap: 8px; }
.src-card-actions .btn-action { padding: 5px 12px; border: 1px solid #e2e8f0; border-radius: 6px; background: #fff; font-size: 0.75rem; font-weight: 500; cursor: pointer; color: #475569; transition: all 0.15s; display: inline-flex; align-items: center; gap: 4px; }
.src-card-actions .btn-action:hover { background: #f8fafc; border-color: #cbd5e1; }
.src-card-actions .btn-action.start { color: #059669; border-color: #a7f3d0; }
.src-card-actions .btn-action.start:hover { background: #ecfdf5; }
.src-card-actions .btn-action.stop { color: #d97706; border-color: #fde68a; }
.src-card-actions .btn-action.stop:hover { background: #fffbeb; }
.src-card-actions .btn-action.delete { color: #ef4444; border-color: #fca5a5; }
.src-card-actions .btn-action.delete:hover { background: #fef2f2; }

/* ========== Zone C: Table View ========== */
.src-table-wrap { display: none; }
.src-table-wrap.active { display: block; }
.src-card-grid.hidden { display: none; }

/* ========== Wizard Modal ========== */
.wizard-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 9999; align-items: center; justify-content: center; }
.wizard-modal { background: #fff; border-radius: 16px; max-width: 680px; width: 94%; max-height: 90vh; overflow-y: auto; }
.wizard-header { padding: 20px 28px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; }
.wizard-header h3 { margin: 0; font-size: 1.1rem; font-weight: 700; color: #1e293b; }
.wizard-close { background: none; border: none; font-size: 1.3rem; color: #94a3b8; cursor: pointer; padding: 4px; }
.wizard-close:hover { color: #475569; }

/* Step Indicator */
.wizard-steps { display: flex; align-items: center; justify-content: center; padding: 20px 28px 8px; gap: 0; }
.wizard-step { display: flex; align-items: center; gap: 8px; }
.wizard-step-num { width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.78rem; font-weight: 700; border: 2px solid #e2e8f0; color: #94a3b8; background: #fff; transition: all 0.2s; }
.wizard-step.active .wizard-step-num { border-color: var(--monitor-primary); background: var(--monitor-primary); color: #fff; }
.wizard-step.done .wizard-step-num { border-color: var(--monitor-primary); background: #ccfbf1; color: var(--monitor-primary); }
.wizard-step-label { font-size: 0.82rem; font-weight: 500; color: #94a3b8; }
.wizard-step.active .wizard-step-label { color: var(--monitor-primary); font-weight: 600; }
.wizard-step.done .wizard-step-label { color: var(--monitor-primary); }
.wizard-step-line { width: 60px; height: 2px; background: #e2e8f0; margin: 0 8px; }
.wizard-step-line.done { background: var(--monitor-primary); }

/* Step Content */
.wizard-body { padding: 20px 28px; }
.wizard-panel { display: none; }
.wizard-panel.active { display: block; }

/* Method Selector Cards */
.method-selector { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 20px; }
.method-card { padding: 16px; border: 2px solid #e2e8f0; border-radius: 12px; text-align: center; cursor: pointer; transition: all 0.2s; }
.method-card:hover { border-color: #cbd5e1; background: #f8fafc; }
.method-card.selected { border-color: var(--monitor-primary); background: #f0fdfa; }
.method-card i { font-size: 1.5rem; color: #94a3b8; margin-bottom: 8px; display: block; }
.method-card.selected i { color: var(--monitor-primary); }
.method-card .method-name { font-size: 0.85rem; font-weight: 600; color: #334155; margin-bottom: 4px; }
.method-card .method-desc { font-size: 0.72rem; color: #94a3b8; line-height: 1.4; }

/* Form Fields */
.wiz-field { margin-bottom: 14px; }
.wiz-field label { font-size: 0.82rem; font-weight: 600; display: block; margin-bottom: 5px; color: #334155; }
.wiz-field label .required { color: #ef4444; margin-left: 2px; }
.wiz-field input, .wiz-field select, .wiz-field textarea { width: 100%; padding: 9px 14px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.85rem; color: #334155; box-sizing: border-box; }
.wiz-field input:focus, .wiz-field select:focus, .wiz-field textarea:focus { outline: none; border-color: var(--monitor-primary); box-shadow: 0 0 0 3px rgba(13,148,136,0.1); }
.wiz-field input[readonly] { background: #f8fafc; color: #64748b; }
.wiz-field .field-hint { font-size: 0.72rem; color: #94a3b8; margin-top: 4px; }
.wiz-field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

/* Agent Guide Box */
.agent-guide { background: #f0fdfa; border: 1px solid #99f6e4; border-radius: 10px; padding: 14px 16px; margin-top: 12px; }
.agent-guide-toggle { display: flex; align-items: center; gap: 8px; cursor: pointer; font-size: 0.82rem; font-weight: 600; color: var(--monitor-primary); background: none; border: none; padding: 0; }
.agent-guide-toggle i { transition: transform 0.2s; }
.agent-guide-content { display: none; margin-top: 12px; }
.agent-guide-content.show { display: block; }
.agent-guide-content pre { background: #1e293b; color: #e2e8f0; padding: 14px; border-radius: 8px; font-size: 0.78rem; overflow-x: auto; margin: 8px 0; white-space: pre-wrap; word-break: break-all; }
.agent-guide-content .btn-copy { padding: 4px 10px; border: 1px solid #99f6e4; background: #fff; border-radius: 6px; font-size: 0.72rem; cursor: pointer; color: var(--monitor-primary); }
.agent-guide-content .btn-copy:hover { background: #ccfbf1; }

/* Step 3: Review */
.review-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
.review-table th { text-align: left; padding: 8px 12px; font-size: 0.78rem; color: #64748b; background: #f8fafc; font-weight: 500; border-bottom: 1px solid #e2e8f0; width: 30%; }
.review-table td { padding: 8px 12px; font-size: 0.85rem; color: #1e293b; border-bottom: 1px solid #f1f5f9; }
.btn-test-conn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border: 1px solid var(--monitor-primary); background: #fff; color: var(--monitor-primary); border-radius: 8px; font-size: 0.82rem; font-weight: 500; cursor: pointer; transition: all 0.15s; }
.btn-test-conn:hover { background: #f0fdfa; }
.test-result { margin-top: 8px; padding: 8px 12px; border-radius: 8px; font-size: 0.8rem; display: none; }
.test-result.success { display: block; background: #ecfdf5; color: #059669; }
.test-result.fail { display: block; background: #fef2f2; color: #dc2626; }

/* Wizard Footer */
.wizard-footer { padding: 16px 28px; border-top: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: flex-end; gap: 8px; }

/* Agent ID copy field */
.copy-field { display: flex; gap: 6px; }
.copy-field input { flex: 1; }
.copy-field .btn-copy-inline { padding: 9px 14px; border: 1px solid #e2e8f0; border-radius: 8px; background: #f8fafc; cursor: pointer; color: #64748b; font-size: 0.82rem; transition: all 0.15s; white-space: nowrap; }
.copy-field .btn-copy-inline:hover { background: #e2e8f0; }

/* Responsive */
@media (max-width: 768px) {
    .src-stats-grid { grid-template-columns: repeat(3, 1fr); }
    .src-card-grid { grid-template-columns: 1fr; }
    .method-selector { grid-template-columns: 1fr; }
    .wiz-field-row { grid-template-columns: 1fr; }
}
</style>

<div id="sourcesContent">

    <!-- Zone A: Status Summary -->
    <div class="src-stats-grid" id="statsGrid">
        <div class="src-stat-card active" data-filter="all" onclick="filterByStatus('all', this)">
            <div class="src-stat-icon total"><i class="fas fa-server"></i></div>
            <div><div class="src-stat-value" id="statTotal">0</div><div class="src-stat-label">전체 등록</div></div>
        </div>
        <div class="src-stat-card" data-filter="RUNNING" onclick="filterByStatus('RUNNING', this)">
            <div class="src-stat-icon running"><i class="fas fa-play-circle"></i></div>
            <div><div class="src-stat-value" id="statRunning">0</div><div class="src-stat-label">수집 중</div></div>
        </div>
        <div class="src-stat-card" data-filter="STOPPED" onclick="filterByStatus('STOPPED', this)">
            <div class="src-stat-icon stopped"><i class="fas fa-pause-circle"></i></div>
            <div><div class="src-stat-value" id="statStopped">0</div><div class="src-stat-label">중지</div></div>
        </div>
        <div class="src-stat-card" data-filter="ERROR" onclick="filterByStatus('ERROR', this)">
            <div class="src-stat-icon error"><i class="fas fa-exclamation-circle"></i></div>
            <div><div class="src-stat-value" id="statError">0</div><div class="src-stat-label">오류</div></div>
        </div>
        <div class="src-stat-card" data-filter="agent" onclick="filterByStatus('agent', this)">
            <div class="src-stat-icon agent"><i class="fas fa-satellite-dish"></i></div>
            <div><div class="src-stat-value" id="statAgent">0</div><div class="src-stat-label">Agent 연결</div></div>
        </div>
    </div>

    <!-- Zone B: Toolbar -->
    <div class="src-toolbar">
        <div class="batch-section hidden" id="batchSection">
            <span class="batch-count" id="batchCount">0건 선택됨</span>
            <button class="btn-batch" onclick="batchStart()"><i class="fas fa-play"></i> 일괄 시작</button>
            <button class="btn-batch" onclick="batchStop()"><i class="fas fa-stop"></i> 일괄 중지</button>
            <button class="btn-batch danger" onclick="batchDelete()"><i class="fas fa-trash"></i> 일괄 삭제</button>
        </div>
        <div class="filter-section">
            <input type="text" id="srcSearch" placeholder="시스템명 또는 DB명 검색..." oninput="applyFilters()">
            <select id="srcStatusFilter" onchange="applyFilters()">
                <option value="">상태 전체</option>
                <option value="RUNNING">수집 중</option>
                <option value="STOPPED">중지</option>
                <option value="ERROR">오류</option>
            </select>
            <select id="srcTypeFilter" onchange="applyFilters()">
                <option value="">방식 전체</option>
                <option value="DB_AUDIT">DB 접근 감사 (Audit)</option>
                <option value="DB_DAC">DB 접근제어</option>
                <option value="WAS_AGENT">WAS 접근 감사</option>
            </select>
        </div>
        <div class="action-section">
            <button class="btn-view-toggle active" id="btnCardView" onclick="setView('card')"><i class="fas fa-th-large"></i></button>
            <button class="btn-view-toggle" id="btnTableView" onclick="setView('table')"><i class="fas fa-list"></i></button>
            <button class="btn-monitor" onclick="openWizard()"><i class="fas fa-plus"></i> 수집 소스 등록</button>
        </div>
    </div>

    <!-- Zone C: Card View -->
    <div class="src-card-grid" id="cardGrid">
        <c:choose>
            <c:when test="${not empty list}">
                <c:forEach var="src" items="${list}">
                    <div class="src-card" data-id="${src.sourceId}" data-status="${src.status}" data-type="${src.sourceType}" data-name="${src.sourceName}" data-db="${src.dbName}" data-agent-status="${src.agentStatus}">
                        <div class="src-card-header">
                            <div class="src-card-check"><input type="checkbox" class="src-check" data-id="${src.sourceId}" onchange="updateBatchUI()"></div>
                            <div class="src-card-info">
                                <div class="src-card-top">
                                    <c:choose>
                                        <c:when test="${src.sourceType == 'DB_AUDIT'}"><span class="src-type-badge db-audit"><i class="fas fa-database"></i> DB 접근 감사 (Audit)</span></c:when>
                                        <c:when test="${src.sourceType == 'DB_DAC'}"><span class="src-type-badge dac"><i class="fas fa-shield-alt"></i> DB 접근제어</span></c:when>
                                        <c:when test="${src.sourceType == 'WAS_AGENT'}"><span class="src-type-badge bci-agent"><i class="fas fa-globe"></i> WAS 접근 감사</span></c:when>
                                        <c:otherwise><span class="src-type-badge dlm-self"><i class="fas fa-cog"></i> ${src.sourceType}</span></c:otherwise>
                                    </c:choose>
                                    <div class="src-status-dot ${src.status == 'RUNNING' ? 'running' : src.status == 'ERROR' ? 'error' : 'stopped'}"></div>
                                    <span class="src-status-text ${src.status == 'RUNNING' ? 'running' : src.status == 'ERROR' ? 'error' : 'stopped'}">${src.status == 'RUNNING' ? '수집 중' : src.status == 'ERROR' ? '오류' : '중지'}</span>
                                </div>
                                <div class="src-card-name" title="${src.sourceName}">${src.sourceName}</div>
                                <div class="src-card-sub"><span class="db-type-tag">${src.dbType}</span> &middot; ${src.hostname}:${src.port} &middot; ${src.dbName}</div>
                            </div>
                        </div>
                        <div class="src-card-metrics">
                            <div class="src-metric">
                                <div class="src-metric-value">${src.collectInterval != null ? src.collectInterval : 5}분</div>
                                <div class="src-metric-label">수집 주기</div>
                            </div>
                            <div class="src-metric">
                                <div class="src-metric-value">${src.totalCollected != null ? src.totalCollected : 0}</div>
                                <div class="src-metric-label">누적 건수</div>
                            </div>
                            <div class="src-metric">
                                <div class="src-metric-value" title="${src.lastCollectTime}">${src.lastCollectTime != null ? src.lastCollectTime : '-'}</div>
                                <div class="src-metric-label">최근 수집</div>
                            </div>
                        </div>
                        <c:if test="${src.sourceType == 'WAS_AGENT' && src.agentId != null}">
                            <div class="src-card-agent">
                                <i class="fas fa-satellite-dish"></i>
                                <span class="agent-hb">Heartbeat: ${src.agentLastHeartbeat != null ? src.agentLastHeartbeat : '없음'}</span>
                                <span class="${src.agentStatus == 'ACTIVE' ? 'agent-active' : 'agent-inactive'}">${src.agentStatus == 'ACTIVE' ? '정상' : '미연결'}</span>
                            </div>
                        </c:if>
                        <c:if test="${src.status == 'ERROR' && src.errorMsg != null}">
                            <div class="src-card-error"><i class="fas fa-exclamation-triangle"></i><span title="${src.errorMsg}">${src.errorMsg}</span></div>
                        </c:if>
                        <div class="src-card-actions">
                            <button class="btn-action start" onclick="startCollect('${src.sourceId}')"><i class="fas fa-play"></i> 시작</button>
                            <button class="btn-action stop" onclick="stopCollect('${src.sourceId}')"><i class="fas fa-stop"></i> 중지</button>
                            <button class="btn-action" onclick="editSource('${src.sourceId}')"><i class="fas fa-edit"></i> 편집</button>
                            <button class="btn-action delete" onclick="deleteSource('${src.sourceId}')"><i class="fas fa-trash"></i> 삭제</button>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div style="grid-column: 1 / -1;">
                    <div class="empty-state">
                        <div class="empty-state-icon"><i class="fas fa-server"></i></div>
                        <h3>등록된 수집 대상이 없습니다</h3>
                        <p>수집 대상을 등록하여 접속기록 수집을 시작하세요.</p>
                        <button class="btn-monitor" onclick="openWizard()"><i class="fas fa-plus"></i> 수집 대상 등록</button>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Zone C: Table View -->
    <div class="src-table-wrap" id="tableView">
        <div class="content-panel">
            <div class="panel-body" style="padding:0;">
                <table class="monitor-table">
                    <thead><tr>
                        <th style="width:30px;"><input type="checkbox" id="tableCheckAll" onchange="toggleAllTable(this)"></th>
                        <th>시스템명</th><th>수집방식</th><th>DB유형</th><th>호스트</th><th>제외 계정</th><th>상태</th><th>최근수집</th><th>누적건수</th><th>작업</th>
                    </tr></thead>
                    <tbody id="tableBody">
                        <c:forEach var="src" items="${list}">
                            <tr data-id="${src.sourceId}" data-status="${src.status}" data-type="${src.sourceType}" data-name="${src.sourceName}" data-db="${src.dbName}">
                                <td><input type="checkbox" class="src-check-tbl" data-id="${src.sourceId}" onchange="updateBatchUI()"></td>
                                <td><strong>${src.sourceName}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${src.sourceType == 'DB_AUDIT'}"><span class="src-type-badge db-audit" style="font-size:0.68rem;">DB 접근 감사 (Audit)</span></c:when>
                                        <c:when test="${src.sourceType == 'DB_DAC'}"><span class="src-type-badge dac" style="font-size:0.68rem;">DB 접근제어</span></c:when>
                                        <c:when test="${src.sourceType == 'WAS_AGENT'}"><span class="src-type-badge bci-agent" style="font-size:0.68rem;">WAS 접근 감사</span></c:when>
                                        <c:otherwise>${src.sourceType}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${src.dbType}</td>
                                <td>${src.hostname}:${src.port}</td>
                                <td style="max-width:120px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="${src.excludeAccounts}">${src.excludeAccounts != null ? src.excludeAccounts : '-'}</td>
                                <td><span class="status-badge ${src.status == 'RUNNING' ? 'running' : src.status == 'ERROR' ? 'error' : 'stopped'}">${src.status == 'RUNNING' ? '수집 중' : src.status == 'ERROR' ? '오류' : '중지'}</span></td>
                                <td style="white-space:nowrap;">${src.lastCollectTime != null ? src.lastCollectTime : '-'}</td>
                                <td>${src.totalCollected != null ? src.totalCollected : 0}</td>
                                <td style="white-space:nowrap;">
                                    <button class="btn-outline" style="padding:4px 8px; font-size:0.72rem;" onclick="startCollect('${src.sourceId}')"><i class="fas fa-play"></i></button>
                                    <button class="btn-outline" style="padding:4px 8px; font-size:0.72rem;" onclick="stopCollect('${src.sourceId}')"><i class="fas fa-stop"></i></button>
                                    <button class="btn-outline" style="padding:4px 8px; font-size:0.72rem;" onclick="editSource('${src.sourceId}')"><i class="fas fa-edit"></i></button>
                                    <button class="btn-outline" style="padding:4px 8px; font-size:0.72rem; color:#ef4444; border-color:#ef4444;" onclick="deleteSource('${src.sourceId}')"><i class="fas fa-trash"></i></button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- ========== Source Modal ========== -->
<div class="wizard-overlay" id="wizardModal">
    <div class="wizard-modal" style="max-width:680px;max-height:90vh;overflow:hidden;display:flex;flex-direction:column;">
        <div class="wizard-header">
            <h3 id="wizardTitle">수집 소스 등록</h3>
            <button class="wizard-close" onclick="closeWizard()">&times;</button>
        </div>

        <div class="wizard-body" style="flex:1;overflow-y:auto;padding:20px 24px;">
            <input type="hidden" id="wz_sourceId">
            <input type="hidden" id="wz_dbType">
            <input type="hidden" id="wz_tableFilter_db">
            <input type="hidden" id="wz_tableFilter_agent">

            <!-- 수집 방식 -->
            <div class="wiz-field">
                <label>수집 방식<span class="required">*</span></label>
                <div class="method-selector">
                    <div class="method-card selected" data-type="DB_AUDIT" onclick="selectMethod(this)">
                        <i class="fas fa-database"></i>
                        <div class="method-name">DB 접근 감사 (Audit)</div>
                        <div class="method-desc">DB 자체 감사<br>로그 수집</div>
                    </div>
                    <div class="method-card" data-type="DB_DAC" onclick="selectMethod(this)">
                        <i class="fas fa-shield-alt"></i>
                        <div class="method-name">DB 접근제어</div>
                        <div class="method-desc">DB 접근제어 솔루션<br>로그 연동</div>
                    </div>
                    <div class="method-card" data-type="WAS_AGENT" onclick="selectMethod(this)">
                        <i class="fas fa-globe"></i>
                        <div class="method-name">WAS 접근 감사</div>
                        <div class="method-desc">WAS Agent 기반<br>실시간 수집</div>
                    </div>
                </div>
            </div>

            <!-- 대상 DB -->
            <div class="wiz-field">
                <label>대상 DB<span class="required">*</span></label>
                <select id="wz_dbName" onchange="onWzDbSelect()" style="width:100%;">
                    <option value="">-- DB를 선택하세요 --</option>
                </select>
            </div>

            <!-- DB 정보 (선택 후 자동 표시) -->
            <div id="wz_dbInfo" style="display:none;background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;padding:14px 18px;margin-bottom:14px;">
                <div style="display:flex;gap:24px;font-size:0.82rem;">
                    <div><span style="color:#9ca3af;">시스템</span> <strong id="wz_infoSystem">-</strong></div>
                    <div><span style="color:#9ca3af;">유형</span> <strong id="wz_infoDbType">-</strong></div>
                    <div><span style="color:#9ca3af;">호스트</span> <strong id="wz_infoHost">-</strong></div>
                </div>
            </div>

            <!-- 설명 -->
            <div class="wiz-field">
                <label>설명</label>
                <input type="text" id="wz_description" placeholder="수집 소스에 대한 간단한 설명">
            </div>

            <hr style="border:none;border-top:1px solid #e5e7eb;margin:16px 0;">

            <!-- ===== DB Audit 설정 ===== -->
            <div id="section_db">
                <input type="hidden" id="wz_schemaName_db">
                <div class="wiz-field">
                    <label>수집 주기 (분)</label>
                    <input type="number" id="wz_collectInterval" value="5" min="1" max="60" style="width:120px;">
                    <div class="field-hint">1~60분 사이로 설정하세요.</div>
                </div>

                <div class="wiz-field">
                    <label>감사 대상</label>
                    <div id="wz_auditTables_db" onclick="showAuditTableDetail('db')" style="min-height:36px;padding:8px 12px;border:1px solid #e5e7eb;border-radius:8px;background:#f9fafb;font-size:0.82rem;color:#6b7280;cursor:pointer;display:flex;align-items:center;gap:8px;">
                        <span style="color:#9ca3af;">DB를 선택하세요</span>
                    </div>
                    <div class="field-hint"><a href="javascript:void(0)" onclick="window.open('/accesslog/index#policy','_blank');" style="color:#7c3aed;">감사 대상 테이블 관리</a>에서 설정합니다. 클릭하면 상세 목록을 확인할 수 있습니다.</div>
                </div>

                <div class="wiz-field">
                    <label>제외 계정</label>
                    <textarea id="wz_excludeAccounts_db" rows="2" placeholder="SYS, SYSTEM, COTDL" style="width:100%;"></textarea>
                    <div class="field-hint">해당 계정의 SQL은 수집에서 제외됩니다.</div>
                </div>

                <div class="wiz-field">
                    <label>제외 SQL 패턴</label>
                    <div class="field-hint"><a href="javascript:void(0)" onclick="window.open('/accesslog/index#exclude-patterns','_blank');" style="color:#7c3aed;">수집 제외 SQL 관리</a> 메뉴에서 수집 유형별로 설정합니다.</div>
                </div>

                <!-- DBA 사전 설정 가이드 -->
                <div id="dbaGuideBox" style="display:none;margin-top:8px;">
                    <div style="background:#f0f9ff;border:1px solid #bae6fd;border-radius:10px;padding:14px 16px;">
                        <button type="button" onclick="$(this).next().toggle();$(this).find('i').toggleClass('fa-chevron-down fa-chevron-up');" style="display:flex;align-items:center;gap:6px;background:none;border:none;cursor:pointer;padding:0;font-size:0.82rem;font-weight:600;color:#0369a1;">
                            <i class="fas fa-info-circle"></i> DBA 사전 설정 가이드 <i class="fas fa-chevron-down" style="font-size:0.7rem;margin-left:4px;"></i>
                        </button>
                        <div style="display:none;margin-top:10px;font-size:0.78rem;color:#475569;line-height:1.7;" id="dbaGuideContent"></div>
                    </div>
                </div>
            </div>

            <!-- ===== DB 접근제어 설정 ===== -->
            <div id="section_dac" style="display:none;">
                <!-- 안내 카드 -->
                <div style="background:linear-gradient(135deg,#fef3c7,#fffbeb);border:1px solid #fbbf24;border-radius:10px;padding:14px 16px;margin-bottom:14px;">
                    <div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">
                        <i class="fas fa-shield-alt" style="color:#92400e;"></i>
                        <span style="font-size:0.85rem;font-weight:700;color:#92400e;">DB 접근제어</span>
                    </div>
                    <div style="font-size:0.78rem;color:#78716c;line-height:1.6;">
                        DB 접근제어 솔루션(차크라맥스, 페트라, DBSafer 등)이 기록하는 접속 로그를 SELECT문으로 직접 조회하여 수집합니다.<br>
                        위에서 DB 접근제어 솔루션의 DB를 선택한 뒤, 아래에 조회 SQL을 작성하세요.
                    </div>
                </div>

                <div class="wiz-field">
                    <label>수집 주기 (분)</label>
                    <input type="number" id="wz_collectInterval_dac" value="5" min="1" max="60">
                </div>

                <div class="wiz-field">
                    <label>감사 대상 유형</label>
                    <select id="wz_dacAuditType" onchange="onDacAuditTypeChange()" style="width:100%;margin-bottom:8px;">
                        <option value="DB_AUDIT" selected>DB 접근 감사 (Audit)</option>
                        <option value="BCI">WAS 접근 감사</option>
                    </select>
                    <div id="wz_auditTables_dac" onclick="showAuditTableDetail(document.getElementById('wz_dacAuditType').value === 'BCI' ? 'bci' : 'db')" style="min-height:36px;padding:8px 12px;border:1px solid #e5e7eb;border-radius:8px;background:#f9fafb;font-size:0.82rem;color:#6b7280;cursor:pointer;display:flex;align-items:center;gap:8px;">
                        <span style="color:#9ca3af;">위에서 대상 DB를 선택하면 자동 표시됩니다</span>
                    </div>
                    <div class="field-hint"><a href="javascript:void(0)" onclick="window.open('/accesslog/index#policy','_blank');" style="color:#7c3aed;">감사 대상 테이블 관리</a>에서 설정합니다. 클릭하면 상세 목록을 확인할 수 있습니다.</div>
                </div>

                <div class="wiz-field">
                    <label>제외 계정</label>
                    <textarea id="wz_excludeAccounts_dac" rows="2" placeholder="SYS, SYSTEM, COTDL" style="width:100%;"></textarea>
                    <div class="field-hint">해당 계정의 SQL은 수집에서 제외됩니다.</div>
                </div>

                <div class="wiz-field">
                    <label>제외 SQL 패턴</label>
                    <div class="field-hint"><a href="javascript:void(0)" onclick="window.open('/accesslog/index#exclude-patterns','_blank');" style="color:#7c3aed;">수집 제외 SQL 관리</a> 메뉴에서 수집 유형별로 설정합니다.</div>
                </div>

                <div class="wiz-field">
                    <label>조회 SQL<span class="required">*</span></label>
                    <textarea id="wz_dacSelectSql" rows="14" style="width:100%;font-family:'Consolas','Monaco','Courier New',monospace;font-size:0.8rem;line-height:1.5;background:#f9fafb;"></textarea>
                    <div class="field-hint">
                        <code style="background:#e2e8f0;padding:1px 4px;border-radius:3px;font-size:0.72rem;">&#35;{LAST_OFFSET}</code>은 마지막 수집 시점(DATETIME, 예: <code style="background:#e2e8f0;padding:1px 4px;border-radius:3px;font-size:0.72rem;">'2026-04-14 09:00:00'</code>)으로 자동 치환됩니다.
                        SELECT 결과의 컬럼 alias를 표준명(access_time, user_account 등)에 맞추면 자동 매핑됩니다.
                    </div>
                    <div style="background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;padding:8px 10px;margin-top:6px;font-size:0.72rem;color:#991b1b;">
                        <i class="fas fa-exclamation-triangle" style="margin-right:4px;"></i>
                        <strong>인덱스 필수:</strong> WHERE 조건의 시각 컬럼에 인덱스가 없으면 매 수집마다 전체 테이블 스캔이 발생합니다.
                        DBA에게 인덱스 생성을 요청하세요.
                    </div>
                </div>

                <!-- 프리셋 버튼 -->
                <div style="margin-top:4px;padding-top:12px;border-top:1px solid #e5e7eb;">
                    <div style="font-size:0.78rem;font-weight:600;color:#64748b;margin-bottom:8px;"><i class="fas fa-magic"></i> SQL 템플릿</div>
                    <div style="display:flex;gap:6px;flex-wrap:wrap;">
                        <button type="button" class="btn-outline" style="padding:5px 12px;font-size:0.72rem;" onclick="applyDacPreset('chakra')">차크라맥스</button>
                        <button type="button" class="btn-outline" style="padding:5px 12px;font-size:0.72rem;" onclick="applyDacPreset('petra')">페트라</button>
                        <button type="button" class="btn-outline" style="padding:5px 12px;font-size:0.72rem;" onclick="applyDacPreset('dbsafer')">DBSafer</button>
                        <button type="button" class="btn-outline" style="padding:5px 12px;font-size:0.72rem;" onclick="applyDacPreset('queryone')">QueryOne</button>
                    </div>
                    <div class="field-hint" style="margin-top:6px;">템플릿 선택 시 해당 솔루션의 기본 SQL이 입력됩니다. 환경에 맞게 수정하세요.</div>
                </div>
            </div>

            <!-- ===== WAS Agent 설정 ===== -->
            <div id="section_agent" style="display:none;">
                <input type="hidden" id="wz_schemaName_agent">
                <input type="hidden" id="wz_agentId">
                <input type="hidden" id="wz_serverUrl">

                <!-- ===== 안내 배너 ===== -->
                <div style="background:linear-gradient(135deg,#ede9fe,#f5f3ff);border:1px solid #c4b5fd;border-radius:10px;padding:14px 16px;margin-bottom:16px;">
                    <div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">
                        <i class="fas fa-globe" style="color:#7c3aed;"></i>
                        <span style="font-size:0.85rem;font-weight:700;color:#5b21b6;">WAS 접근 감사</span>
                    </div>
                    <div style="font-size:0.78rem;color:#6b7280;line-height:1.6;">
                        WAS(Tomcat, WebLogic, JEUS 등)에 설치되는 경량 Java Agent가 모든 SQL 실행을 실시간으로 감지하여 XAudit 서버로 전송합니다.<br>
                        아래 설정을 완료한 후 <strong>등록</strong>하면, Agent 배포 가이드가 자동으로 생성됩니다.
                    </div>
                </div>

                <!-- ===== STEP A: 사용자 식별 설정 ===== -->
                <div style="margin-bottom:16px;">
                    <div style="display:flex;align-items:center;gap:6px;margin-bottom:10px;">
                        <span style="background:#7c3aed;color:#fff;width:20px;height:20px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;">A</span>
                        <span style="font-size:0.85rem;font-weight:700;color:#334155;">사용자 식별 설정</span>
                    </div>

                    <div style="background:#fefce8;border:1px solid #fde68a;border-radius:8px;padding:10px 14px;margin-bottom:12px;font-size:0.75rem;color:#854d0e;line-height:1.6;">
                        <i class="fas fa-info-circle" style="color:#ca8a04;margin-right:3px;"></i>
                        Agent 설치 대상 WAS의 로그인 방식에 따라 설정합니다.<br>
                        <strong>지금 모르면 비워두고 등록하세요.</strong> Agent 설치 후 접속기록에서 사용자가 UNKNOWN으로 나오면 그때 설정 파일에서 수정할 수 있습니다.
                    </div>

                    <div class="wiz-field" style="margin-bottom:10px;">
                        <label>인증 방식</label>
                        <select id="wz_userIdMethod" onchange="onUserIdMethodChange()" style="width:100%;">
                            <option value="SESSION">세션(Session) 기반</option>
                            <option value="HEADER">SSO/통합인증 (HTTP 헤더)</option>
                        </select>
                    </div>

                    <!-- 세션 방식 -->
                    <div id="wz_sessionAttrWrap" style="margin-bottom:10px;">
                        <div class="wiz-field" style="margin-bottom:0;">
                            <label>세션 속성명 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">(나중에 설정 가능)</span></label>
                            <input type="text" id="wz_sessionAttrName" placeholder="비워두면 자동 탐지 시도" autocomplete="off">
                            <div class="field-hint" style="margin-top:6px;line-height:1.6;">
                                WAS 담당자에게 확인: <em>"로그인 후 세션에 사용자 ID를 어떤 이름으로 저장하나요?"</em><br>
                                <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">loginVO.id</code> <span style="color:#94a3b8;">(eGov/DevOn — 객체.필드)</span> &nbsp;
                                <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">userId</code> <span style="color:#94a3b8;">(문자열 직접 저장)</span> &nbsp;
                                <span style="color:#94a3b8;">Spring Security → 비워두세요</span>
                            </div>
                        </div>
                    </div>

                    <!-- SSO 헤더 방식 -->
                    <div id="wz_headerNameWrap" style="display:none;margin-bottom:10px;">
                        <div class="wiz-field" style="margin-bottom:0;">
                            <label>SSO 헤더명 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">(나중에 설정 가능)</span></label>
                            <input type="text" id="wz_ssoHeaderName" placeholder="비워두면 자동 탐지 시도" autocomplete="off">
                            <div class="field-hint" style="margin-top:6px;line-height:1.6;">
                                SSO 담당자에게 확인: <em>"인증 후 WAS에 전달되는 사용자 ID 헤더 이름이 뭔가요?"</em><br>
                                <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">SM_USER</code> <span style="color:#94a3b8;">(SiteMinder)</span> &nbsp;
                                <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">iv-user</code> <span style="color:#94a3b8;">(WebSEAL)</span> &nbsp;
                                <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">X-Remote-User</code> <span style="color:#94a3b8;">(SAML)</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== STEP B: 감사 범위 설정 ===== -->
                <div style="margin-bottom:16px;">
                    <div style="display:flex;align-items:center;gap:6px;margin-bottom:10px;">
                        <span style="background:#7c3aed;color:#fff;width:20px;height:20px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;">B</span>
                        <span style="font-size:0.85rem;font-weight:700;color:#334155;">감사 범위 설정</span>
                        <span style="font-size:0.72rem;color:#94a3b8;margin-left:4px;">어떤 테이블의 접근을 감시할지 범위를 설정합니다</span>
                    </div>

                    <div class="wiz-field" style="margin-bottom:10px;">
                        <label>감사 대상 테이블 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">— Agent가 감시할 테이블 목록 (클릭하면 상세 목록 확인)</span></label>
                        <div id="wz_bciTables_agent" onclick="showAuditTableDetail('bci')" style="min-height:36px;padding:8px 12px;border:1px solid #e5e7eb;border-radius:8px;background:#f9fafb;font-size:0.82rem;color:#6b7280;cursor:pointer;display:flex;align-items:center;gap:8px;">
                            <span style="color:#9ca3af;">위에서 대상 DB를 먼저 선택하세요</span>
                        </div>
                        <div style="background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;padding:8px 10px;margin-top:6px;font-size:0.72rem;color:#991b1b;line-height:1.5;">
                            <i class="fas fa-exclamation-triangle" style="color:#dc2626;margin-right:4px;"></i>
                            <strong>필수:</strong> 감사 대상 테이블을 <a href="javascript:void(0)" onclick="window.open('/accesslog/index#policy','_blank');" style="color:#7c3aed;font-weight:600;">감사 대상 테이블 관리</a> 메뉴에서 먼저 등록하세요.
                            <strong>등록된 테이블의 SQL만 수집</strong>되며, 미등록 시 Agent가 작동하지 않습니다.
                        </div>
                    </div>

                    <div class="wiz-field" style="margin-bottom:10px;">
                        <label>제외 계정 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">— 이 계정의 SQL은 수집하지 않습니다 (쉼표 구분)</span></label>
                        <textarea id="wz_excludeAccounts_agent" rows="2" placeholder="SYS, SYSTEM, COTDL" style="width:100%;" autocomplete="off"></textarea>
                        <div class="field-hint">DB 관리자 계정 등을 입력합니다. WAS가 사용하는 연결 풀 계정(예: app_user)은 제외하지 마세요.</div>
                    </div>

                    <div class="wiz-field" style="margin-bottom:10px;">
                        <label>제외 SQL 패턴 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">— 헬스체크, 모니터링 등 불필요한 SQL을 제외합니다</span></label>
                        <div class="field-hint"><a href="javascript:void(0)" onclick="window.open('/accesslog/index#exclude-patterns','_blank');" style="color:#7c3aed;font-weight:500;">수집 제외 SQL 관리</a> 메뉴에서 패턴을 등록할 수 있습니다. (선택사항)</div>
                    </div>
                </div>

                <!-- ===== STEP C: 고급 설정 (접힘) ===== -->
                <div style="margin-bottom:16px;">
                    <button type="button" onclick="$(this).next().toggle();$(this).find('.fa-chevron-down,.fa-chevron-up').toggleClass('fa-chevron-down fa-chevron-up');" style="display:flex;align-items:center;gap:6px;background:none;border:none;cursor:pointer;padding:0;font-size:0.82rem;font-weight:600;color:#64748b;margin-bottom:8px;">
                        <span style="background:#94a3b8;color:#fff;width:20px;height:20px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;">C</span>
                        고급 설정 <i class="fas fa-chevron-down" style="font-size:0.65rem;margin-left:2px;"></i>
                    </button>
                    <div style="display:none;padding-left:28px;">
                        <div class="wiz-field" style="margin-bottom:10px;">
                            <label>정책 동기화 주기 <span style="font-weight:400;color:#94a3b8;font-size:0.72rem;">— Agent가 XAudit 서버에서 PII 정책을 갱신하는 간격</span></label>
                            <div style="display:flex;align-items:center;gap:6px;">
                                <input type="number" id="wz_policySyncSec" value="300" min="60" max="3600" style="width:100px;">
                                <span style="font-size:0.8rem;color:#64748b;">초</span>
                                <span style="font-size:0.72rem;color:#94a3b8;">(기본 300초 = 5분)</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== STEP D: Agent 배포 가이드 (등록 후 표시 / 편집 시 항상 표시) ===== -->
                <div id="agentDeployGuide" style="display:none;border-top:2px solid #c4b5fd;padding-top:16px;margin-top:8px;">
                    <button type="button" id="agentGuideToggle" onclick="$(this).next().slideToggle(200);$(this).find('.fa-chevron-down,.fa-chevron-up').toggleClass('fa-chevron-down fa-chevron-up');" style="display:flex;align-items:center;gap:6px;background:none;border:none;cursor:pointer;padding:0;margin-bottom:8px;width:100%;">
                        <span style="background:#059669;color:#fff;width:20px;height:20px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700;"><i class="fas fa-rocket" style="font-size:0.6rem;"></i></span>
                        <span style="font-size:0.85rem;font-weight:700;color:#334155;">Agent 배포 가이드</span>
                        <span style="font-size:0.72rem;color:#94a3b8;margin-left:4px;">아래 3단계를 따라 WAS에 Agent를 설치하세요</span>
                        <i class="fas fa-chevron-down" style="font-size:0.65rem;color:#94a3b8;margin-left:auto;"></i>
                    </button>
                    <div id="agentGuideContent" style="display:none;">

                    <!-- D-1: JAR 배포 -->
                    <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:12px 14px;margin-bottom:10px;">
                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:8px;">
                            <span style="background:#e2e8f0;color:#475569;width:18px;height:18px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.65rem;font-weight:700;">1</span>
                            <span style="font-size:0.82rem;font-weight:600;color:#334155;">Agent JAR 파일 배포</span>
                        </div>
                        <div style="font-size:0.75rem;color:#64748b;line-height:1.6;margin-bottom:6px;">
                            <code style="background:#e2e8f0;padding:1px 5px;border-radius:3px;">dlm-agent-1.0.0.jar</code> 파일을 WAS 서버의 적절한 경로에 복사합니다.
                        </div>
                        <div style="display:flex;align-items:center;gap:6px;">
                            <pre id="agentJarPath" style="flex:1;background:#1e293b;color:#e2e8f0;padding:8px 12px;border-radius:6px;font-size:0.75rem;margin:0;overflow-x:auto;white-space:nowrap;">/opt/dlm/dlm-agent-1.0.0.jar</pre>
                            <button class="btn-copy-inline" onclick="copyTextToClipboard(document.getElementById('agentJarPath').textContent)" style="flex-shrink:0;"><i class="fas fa-copy"></i></button>
                        </div>
                    </div>

                    <!-- D-2: 설정 파일 생성 -->
                    <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:12px 14px;margin-bottom:10px;">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                            <div style="display:flex;align-items:center;gap:6px;">
                                <span style="background:#e2e8f0;color:#475569;width:18px;height:18px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.65rem;font-weight:700;">2</span>
                                <span style="font-size:0.82rem;font-weight:600;color:#334155;">설정 파일 생성</span>
                            </div>
                            <button class="btn-copy-inline" onclick="copyAgentProps()" style="font-size:0.72rem;"><i class="fas fa-copy"></i> 복사</button>
                        </div>
                        <div style="font-size:0.75rem;color:#64748b;line-height:1.6;margin-bottom:6px;">
                            아래 내용을 <code style="background:#e2e8f0;padding:1px 5px;border-radius:3px;">/opt/dlm/dlm-agent.properties</code> 파일로 저장합니다.
                        </div>
                        <pre id="agentPropsSnippet" style="background:#1e293b;color:#e2e8f0;padding:10px 12px;border-radius:6px;font-size:0.72rem;margin:0;overflow-x:auto;max-height:180px;overflow-y:auto;white-space:pre-wrap;word-break:break-all;line-height:1.5;"></pre>
                    </div>

                    <!-- D-3: WAS 기동 옵션 추가 -->
                    <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:12px 14px;margin-bottom:10px;">
                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:8px;">
                            <span style="background:#e2e8f0;color:#475569;width:18px;height:18px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.65rem;font-weight:700;">3</span>
                            <span style="font-size:0.82rem;font-weight:600;color:#334155;">WAS 기동 옵션에 Agent 추가 후 재시작</span>
                        </div>
                        <div style="font-size:0.75rem;color:#64748b;line-height:1.6;margin-bottom:6px;">
                            WAS의 JVM 옵션에 아래 인자를 추가한 뒤 WAS를 재시작합니다.
                        </div>
                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:8px;">
                            <pre id="agentJvmSnippet" style="flex:1;background:#1e293b;color:#e2e8f0;padding:8px 12px;border-radius:6px;font-size:0.75rem;margin:0;overflow-x:auto;white-space:nowrap;"></pre>
                            <button class="btn-copy-inline" onclick="copyTextToClipboard(document.getElementById('agentJvmSnippet').textContent)" style="flex-shrink:0;"><i class="fas fa-copy"></i></button>
                        </div>
                        <!-- WAS별 설정 위치 가이드 -->
                        <div style="font-size:0.72rem;color:#64748b;line-height:1.8;">
                            <strong style="color:#475569;">WAS별 설정 위치:</strong><br>
                            <span style="color:#7c3aed;font-weight:600;">Tomcat</span> &rarr; <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">CATALINA_OPTS</code> 또는 <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">setenv.sh</code><br>
                            <span style="color:#7c3aed;font-weight:600;">WebLogic</span> &rarr; 관리콘솔 > 서버 > 서버시작 > 인수<br>
                            <span style="color:#7c3aed;font-weight:600;">JEUS</span> &rarr; <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">jeus-jvm-option</code> 또는 WebAdmin > JVM 옵션<br>
                            <span style="color:#7c3aed;font-weight:600;">Spring Boot</span> &rarr; <code style="background:#f1f5f9;padding:1px 4px;border-radius:2px;">java -javaagent:... -jar app.jar</code>
                        </div>
                    </div>

                    <!-- D-4: 연결 확인 -->
                    <div style="background:#ecfdf5;border:1px solid #a7f3d0;border-radius:10px;padding:12px 14px;">
                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">
                            <span style="background:#059669;color:#fff;width:18px;height:18px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.65rem;font-weight:700;"><i class="fas fa-check" style="font-size:0.55rem;"></i></span>
                            <span style="font-size:0.82rem;font-weight:600;color:#059669;">연결 확인 방법</span>
                        </div>
                        <div style="font-size:0.75rem;color:#475569;line-height:1.7;">
                            WAS 재시작 후 아래를 확인하세요:<br>
                            <strong>1.</strong> WAS 로그에 <code style="background:#d1fae5;padding:1px 5px;border-radius:3px;">[XAudit-Agent] Agent successfully installed.</code> 메시지 출력<br>
                            <strong>2.</strong> 이 화면의 수집 소스 카드에 <span style="color:#059669;font-weight:600;">Heartbeat: 정상</span> 표시 (약 1분 소요)<br>
                            <strong>3.</strong> 접속기록 > 대시보드에서 수집 건수 증가 확인
                        </div>
                    </div>
                    </div><!-- /agentGuideContent -->
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="wizard-footer">
            <button class="btn-outline" onclick="closeWizard()">취소</button>
            <button class="btn-monitor" id="btnSubmit" onclick="saveSource()"><i class="fas fa-check"></i> 등록</button>
        </div>
    </div>
</div>

<!-- 감사 대상 상세 목록 팝업 -->
<div id="auditTablePopup" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.3);z-index:10001;display:none;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:12px;width:400px;max-height:60vh;overflow:hidden;display:flex;flex-direction:column;">
        <div style="padding:14px 18px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;justify-content:space-between;">
            <strong id="auditPopupTitle" style="font-size:0.88rem;"></strong>
            <button onclick="document.getElementById('auditTablePopup').style.display='none';" style="background:none;border:none;font-size:1.1rem;cursor:pointer;color:#9ca3af;">&times;</button>
        </div>
        <div id="auditPopupBody" style="flex:1;overflow-y:auto;padding:10px 18px;"></div>
    </div>
</div>

<script>
// ========== Data & State ==========
var _dbList = [];
var _currentStep = 1;
var _selectedMethod = 'DB_AUDIT';
var _currentView = 'card';
var _editMode = false;

// ========== Init ==========
$(function() {
    computeStats();
});

function onUserIdMethodChange() {
    var method = $('#wz_userIdMethod').val();
    $('#wz_sessionAttrWrap').toggle(method === 'SESSION');
    $('#wz_headerNameWrap').toggle(method === 'HEADER');
}

function computeStats() {
    var cards = $('.src-card');
    var total = cards.length;
    var running = cards.filter('[data-status="RUNNING"]').length;
    var stopped = cards.filter('[data-status="STOPPED"]').length;
    var error = cards.filter('[data-status="ERROR"]').length;
    var agent = cards.filter('[data-agent-status="ACTIVE"]').length;
    $('#statTotal').text(total);
    $('#statRunning').text(running);
    $('#statStopped').text(stopped);
    $('#statError').text(error);
    $('#statAgent').text(agent);
}

// ========== View Toggle ==========
function setView(view) {
    _currentView = view;
    if (view === 'card') {
        $('#cardGrid').removeClass('hidden');
        $('#tableView').removeClass('active');
        $('#btnCardView').addClass('active');
        $('#btnTableView').removeClass('active');
    } else {
        $('#cardGrid').addClass('hidden');
        $('#tableView').addClass('active');
        $('#btnCardView').removeClass('active');
        $('#btnTableView').addClass('active');
    }
}

// ========== Filters ==========
function filterByStatus(status, el) {
    $('.src-stat-card').removeClass('active');
    $(el).addClass('active');
    if (status === 'all') {
        $('#srcStatusFilter').val('');
        $('#srcTypeFilter').val('');
    } else if (status === 'agent') {
        $('#srcStatusFilter').val('');
        $('#srcTypeFilter').val('WAS_AGENT');
    } else {
        $('#srcStatusFilter').val(status);
    }
    applyFilters();
}

function applyFilters() {
    var keyword = ($('#srcSearch').val() || '').toLowerCase();
    var statusF = $('#srcStatusFilter').val();
    var typeF = $('#srcTypeFilter').val();

    // Card view filter
    $('.src-card').each(function() {
        var $c = $(this);
        var match = true;
        if (keyword && $c.data('name').toString().toLowerCase().indexOf(keyword) === -1 && ($c.data('db') || '').toString().toLowerCase().indexOf(keyword) === -1) match = false;
        if (statusF && $c.data('status') !== statusF) match = false;
        if (typeF && $c.data('type') !== typeF) match = false;
        $c.toggle(match);
    });

    // Table view filter
    $('#tableBody tr').each(function() {
        var $r = $(this);
        var match = true;
        if (keyword && $r.data('name').toString().toLowerCase().indexOf(keyword) === -1 && ($r.data('db') || '').toString().toLowerCase().indexOf(keyword) === -1) match = false;
        if (statusF && $r.data('status') !== statusF) match = false;
        if (typeF && $r.data('type') !== typeF) match = false;
        $r.toggle(match);
    });
}

// ========== Batch Operations ==========
function getSelectedIds() {
    var ids = [];
    if (_currentView === 'card') {
        $('.src-check:checked').each(function() { ids.push($(this).data('id')); });
    } else {
        $('.src-check-tbl:checked').each(function() { ids.push($(this).data('id')); });
    }
    return ids;
}

function updateBatchUI() {
    var ids = getSelectedIds();
    if (ids.length > 0) {
        $('#batchSection').removeClass('hidden');
        $('#batchCount').text(ids.length + '건 선택됨');
    } else {
        $('#batchSection').addClass('hidden');
    }
}

function toggleAllTable(el) {
    $('.src-check-tbl').prop('checked', el.checked);
    updateBatchUI();
}

function batchStart() {
    var ids = getSelectedIds();
    if (!ids.length) return;
    showConfirm(ids.length + '건의 수집을 시작하시겠습니까?', function() {
        $.ajax({ url: '/accesslog/api/source/batch-start', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ sourceIds: ids }),
            success: function(res) { showToast(res.message); reloadPage(); },
            error: function(xhr) { showToast('일괄 시작 실패: ' + (xhr.responseJSON && xhr.responseJSON.message || xhr.statusText), true); }
        });
    });
}

function batchStop() {
    var ids = getSelectedIds();
    if (!ids.length) return;
    showConfirm(ids.length + '건의 수집을 중지하시겠습니까?', function() {
        $.ajax({ url: '/accesslog/api/source/batch-stop', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ sourceIds: ids }),
            success: function(res) { showToast(res.message); reloadPage(); },
            error: function(xhr) { showToast('일괄 중지 실패: ' + (xhr.responseJSON && xhr.responseJSON.message || xhr.statusText), true); }
        });
    });
}

function batchDelete() {
    var ids = getSelectedIds();
    if (!ids.length) return;
    showConfirm(ids.length + '건의 수집 대상을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.', function() {
        $.ajax({ url: '/accesslog/api/source/batch-delete', type: 'POST', contentType: 'application/json',
            data: JSON.stringify({ sourceIds: ids }),
            success: function(res) { showToast(res.message); reloadPage(); },
            error: function(xhr) { showToast('일괄 삭제 실패: ' + (xhr.responseJSON && xhr.responseJSON.message || xhr.statusText), true); }
        });
    });
}

// ========== CRUD Operations ==========
function startCollect(sourceId) {
    $.post('/accesslog/api/collection/' + sourceId + '/start')
        .done(function(res) {
            if (res.success === false) {
                showToast(res.message || '수집 시작에 실패했습니다.', true);
            } else {
                showToast(res.message || '수집이 완료되었습니다.');
                reloadPage();
            }
        })
        .fail(function(xhr) {
            showToast('수집 시작 실패: ' + (xhr.responseJSON && xhr.responseJSON.message || xhr.statusText), true);
        });
}

function stopCollect(sourceId) {
    $.post('/accesslog/api/collection/' + sourceId + '/stop')
        .done(function(res) {
            if (res.success === false) {
                showToast(res.message || '수집 중지에 실패했습니다.', true);
            } else {
                showToast('수집이 중지되었습니다.');
                reloadPage();
            }
        })
        .fail(function(xhr) {
            showToast('수집 중지 실패: ' + (xhr.responseJSON && xhr.responseJSON.message || xhr.statusText), true);
        });
}

function deleteSource(sourceId) {
    showConfirm('수집 대상을 삭제하시겠습니까?', function() {
        $.ajax({ url: '/accesslog/api/source/' + sourceId, type: 'DELETE',
            success: function(res) { if (res.success) reloadPage(); }
        });
    });
}

function editSource(sourceId) {
    $.get('/accesslog/api/collection/' + sourceId + '/status', function(res) {
        var src = res.source;
        if (!src) return;
        _editMode = true;

        // 필드 초기화 (openWizard 내부 로직 인라인)
        $('#wz_sourceId').val('');
        $('#wz_dbName').val('');
        $('#wz_dbType').val('');
        $('#wz_description').val('');
        $('#wz_dbInfo').hide();
        $('#wz_schemaName_db').val('');
        $('#wz_collectInterval').val(5);
        $('#wz_tableFilter_db').val('');
        $('#wz_excludeAccounts_db').val('');
        $('#wz_auditTables_db').html('');
        $('#wz_collectInterval_dac').val(5);
        $('#wz_excludeAccounts_dac').val('');
        $('#wz_dacSelectSql').val(getDacDefaultSql());
        $('#wz_dacAuditType').val('DB_AUDIT');
        $('#wz_auditTables_dac').html('');
        $('#wz_agentId').val(generateUUID());
        $('#wz_serverUrl').val(location.protocol + '//' + location.host);
        $('#wz_schemaName_agent').val('');
        $('#wz_excludeAccounts_agent').val('');
        $('#wz_tableFilter_agent').val('');
        $('#wz_bciTables_agent').html('');
        $('#wz_userIdMethod').val('SESSION');
        $('#wz_ssoHeaderName').val('');
        $('#wz_sessionAttrName').val('');
        $('#wz_policySyncSec').val(300);
        $('#wz_headerNameWrap').hide();
        $('#wz_sessionAttrWrap').hide();
        $('#wz_sessionAttrWrap').show();

        $('#wizardTitle').text('수집 소스 편집');
        $('#btnSubmit').html('<i class="fas fa-check"></i> 수정');

        // DB 목록 로드 후 값 설정
        loadDatabaseList(function() {
            $('#wz_sourceId').val(src.sourceId);
            $('#wz_dbType').val(src.dbType);
            $('#wz_description').val(src.description || '');

            // DB 선택
            $('#wz_dbName').val(src.dbName);
            onWzDbSelect();

            // 수집 방식
            _selectedMethod = src.sourceType || 'DB_AUDIT';
            $('.method-card').removeClass('selected');
            $('.method-card[data-type="' + _selectedMethod + '"]').addClass('selected');
            updateMethodSections();

            // 설정 값
            if (_selectedMethod === 'WAS_AGENT') {
                $('#wz_agentId').val(src.agentId || '');
                $('#wz_schemaName_agent').val(src.schemaName || '');
                $('#wz_excludeAccounts_agent').val(src.excludeAccounts || '');
                // 편집 시 배포 가이드 즉시 표시
                setTimeout(function() {
                    updateAgentSnippet();
                    $('#agentDeployGuide').show();
                }, 200);
            } else if (_selectedMethod === 'DB_DAC') {
                $('#wz_collectInterval_dac').val(src.collectInterval || 5);
                $('#wz_excludeAccounts_dac').val(src.excludeAccounts || '');
                $('#wz_dacSelectSql').val(src.dacSelectSql || getDacDefaultSql());
            } else {
                $('#wz_schemaName_db').val(src.schemaName || '');
                $('#wz_collectInterval').val(src.collectInterval || 5);
                $('#wz_excludeAccounts_db').val(src.excludeAccounts || '');
            }

            $('#wizardModal').css('display', 'flex');
        });
    });
}

function saveSource() {
    var sourceId = $('#wz_sourceId').val();
    var dbName = $('#wz_dbName').val();
    if (!dbName) { showToast('대상 DB를 선택하세요.', true); return; }

    var isAgent = _selectedMethod === 'WAS_AGENT';
    var isDac = _selectedMethod === 'DB_DAC';
    var db = _dbList.find(function(d) { return d.db === dbName; });

    if (isDac) {
        if (!$('#wz_dacSelectSql').val() || !$('#wz_dacSelectSql').val().trim()) {
            showToast('조회 SQL을 작성하세요.', true); return;
        }
    }

    var data = {
        sourceName: db ? (db.system || db.db) : dbName,
        sourceType: _selectedMethod,
        dbType: $('#wz_dbType').val(),
        dbName: dbName,
        hostname: db ? db.hostname : '',
        port: db ? db.port : '',
        description: $('#wz_description').val(),
        schemaName: isAgent ? $('#wz_schemaName_agent').val() : $('#wz_schemaName_db').val(),
        excludeAccounts: isDac ? $('#wz_excludeAccounts_dac').val() : (isAgent ? $('#wz_excludeAccounts_agent').val() : $('#wz_excludeAccounts_db').val()),
        tableFilter: isDac ? $('#wz_tableFilter_db').val() : (isAgent ? $('#wz_tableFilter_agent').val() : $('#wz_tableFilter_db').val()),
        collectInterval: isAgent ? 0 : (isDac ? parseInt($('#wz_collectInterval_dac').val()) || 5 : parseInt($('#wz_collectInterval').val()) || 5),
        agentId: isAgent ? $('#wz_agentId').val() : null,
        // DAC 전용
        dacSelectSql: isDac ? $('#wz_dacSelectSql').val() : null
    };

    var url = sourceId ? '/accesslog/api/source/' + sourceId : '/accesslog/api/source';
    var method = sourceId ? 'PUT' : 'POST';
    $.ajax({ url: url, type: method, contentType: 'application/json', data: JSON.stringify(data),
        success: function(res) {
            if (res.success) {
                if (isAgent && !sourceId) {
                    // WAS Agent 신규 등록 → 닫지 않고 배포 가이드 표시
                    showToast('등록 완료! Agent 배포 가이드를 확인하세요.');
                    updateAgentSnippet();
                    $('#agentDeployGuide').show();
                    // 위저드 body를 배포 가이드까지 스크롤
                    var guideEl = document.getElementById('agentDeployGuide');
                    if (guideEl) guideEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    // 버튼을 "닫기"로 변경
                    $('#btnSubmit').html('<i class="fas fa-check"></i> 완료').off('click').on('click', function() {
                        closeWizard();
                        reloadPage();
                    });
                } else {
                    closeWizard();
                    showToast(sourceId ? '수정되었습니다.' : '등록되었습니다.');
                    reloadPage();
                }
            } else { showToast(res.message || '저장 실패', true); }
        }
    });
}

// ========== Wizard ==========
function openWizard() {
    _editMode = false;
    _selectedMethod = 'DB_AUDIT';
    $('#wz_sourceId').val('');
    $('#wz_dbName').val('');
    $('#wz_dbType').val('');
    $('#wz_description').val('');
    $('#wz_dbInfo').hide();
    $('#wz_schemaName_db').val('');
    $('#wz_collectInterval').val(5);
    $('#wz_tableFilter_db').val('');
    $('#wz_excludeAccounts_db').val('');
    $('#wz_auditTables_db').html('<span style="color:#9ca3af;">DB를 선택하세요</span>');
    // DAC 필드 초기화
    $('#wz_collectInterval_dac').val(5);
    $('#wz_excludeAccounts_dac').val('');
    $('#wz_dacSelectSql').val(getDacDefaultSql());
    $('#wz_dacAuditType').val('DB_AUDIT');
    $('#wz_auditTables_dac').html('<span style="color:#9ca3af;">DB를 선택하세요</span>');
    $('#wz_agentId').val(generateUUID());
    $('#wz_serverUrl').val(location.protocol + '//' + location.host);
    $('#wz_schemaName_agent').val('');
    $('#wz_excludeAccounts_agent').val('');
    $('#wz_tableFilter_agent').val('');
    $('#wz_bciTables_agent').html('<span style="color:#9ca3af;">DB를 선택하세요</span>');
    $('#wz_userIdMethod').val('SESSION');
    $('#wz_ssoHeaderName').val('');
    $('#wz_sessionAttrName').val('');
    $('#wz_policySyncSec').val(300);
    $('#wz_headerNameWrap').hide();
    $('#wz_sessionAttrWrap').hide();
    $('#agentDeployGuide').hide();
    $('#wizardTitle').text('수집 소스 등록');
    $('#btnSubmit').html('<i class="fas fa-check"></i> 등록');
    $('.method-card').removeClass('selected');
    $('.method-card[data-type="DB_AUDIT"]').addClass('selected');
    updateMethodSections();
    loadDatabaseList(function() {
        $('#wizardModal').css('display', 'flex');
    });
}

function closeWizard() {
    $('#wizardModal').hide();
}

function selectMethod(el) {
    $('.method-card').removeClass('selected');
    $(el).addClass('selected');
    _selectedMethod = $(el).data('type');
    if (_selectedMethod === 'WAS_AGENT' && !$('#wz_agentId').val()) {
        $('#wz_agentId').val(generateUUID());
    }
    updateMethodSections();
    updateDbaGuide();
}

function updateMethodSections() {
    $('#section_db').hide();
    $('#section_dac').hide();
    $('#section_agent').hide();
    if (_selectedMethod === 'WAS_AGENT') {
        $('#section_agent').show();
    } else if (_selectedMethod === 'DB_DAC') {
        $('#section_dac').show();
    } else {
        $('#section_db').show();
    }
}

function showAuditTableDetail(type) {
    var popup = document.getElementById('auditTablePopup');
    var title = document.getElementById('auditPopupTitle');
    var body = document.getElementById('auditPopupBody');

    if (type === 'db') {
        title.textContent = 'DB 접근 감사 대상 테이블 (Audit)';
        var tables = (_auditPolicyCache || {}).auditTables || [];
        if (tables.length === 0) {
            body.innerHTML = '<p style="color:#9ca3af;padding:20px;text-align:center;">등록된 감사 대상이 없습니다.</p>';
        } else {
            var html = '<div style="font-size:0.8rem;">';
            tables.forEach(function(t) {
                html += '<div style="padding:5px 0;border-bottom:1px solid #f3f4f6;display:flex;align-items:center;gap:8px;">' +
                    '<span style="color:#7c3aed;font-weight:600;font-size:0.75rem;background:#f5f3ff;padding:1px 6px;border-radius:3px;">' + (t.owner||'') + '</span>' +
                    '<span>' + t.tableName + '</span>' +
                    '<span style="color:#9ca3af;font-size:0.72rem;margin-left:auto;">' + t.piiColumnCount + ' PII</span></div>';
            });
            html += '</div>';
            body.innerHTML = html;
        }
    } else {
        title.textContent = 'WAS 접근 감사 대상 테이블';
        var targets = (_auditPolicyCache || {}).bciTargets || [];
        if (targets.length === 0) {
            body.innerHTML = '<p style="color:#9ca3af;padding:20px;text-align:center;">등록된 감사 대상이 없습니다.</p>';
        } else {
            var html = '<div style="font-size:0.8rem;">';
            targets.forEach(function(t) {
                var tag = t.targetType === 'BUSINESS'
                    ? '<span style="background:#fef3c7;color:#92400e;font-size:0.65rem;padding:1px 5px;border-radius:3px;">업무</span>'
                    : '<span style="background:#dcfce7;color:#15803d;font-size:0.65rem;padding:1px 5px;border-radius:3px;">PII</span>';
                html += '<div style="padding:5px 0;border-bottom:1px solid #f3f4f6;display:flex;align-items:center;gap:8px;">' +
                    '<span style="color:#059669;font-weight:600;font-size:0.75rem;background:#ecfdf5;padding:1px 6px;border-radius:3px;">' + (t.owner||'') + '</span>' +
                    '<span>' + t.tableName + '</span>' + tag + '</div>';
            });
            html += '</div>';
            body.innerHTML = html;
        }
    }
    popup.style.display = 'flex';
}

function updateAgentSnippet() {
    var agentId = $('#wz_agentId').val();
    var serverUrl = $('#wz_serverUrl').val() || (location.protocol + '//' + location.host);
    var userMethod = $('#wz_userIdMethod').val() || 'SESSION';
    var ssoHeader = $('#wz_ssoHeaderName').val() || '';
    var excludeUsers = $('#wz_excludeAccounts_agent').val() || '';
    var excludeSql = $('#wz_excludeSqlPatterns').val() || '';
    var policySyncMs = (parseInt($('#wz_policySyncSec').val()) || 300) * 1000;
    var sessionAttr = $('#wz_sessionAttrName').val() || '';

    // JVM 인자
    $('#agentJvmSnippet').text('-javaagent:/opt/dlm/dlm-agent-1.0.0.jar=/opt/dlm/dlm-agent.properties');

    // Agent 설정 파일
    var props = 'dlm.server.url=' + serverUrl + '\n' +
        'dlm.agent.id=' + agentId + '\n' +
        'dlm.agent.secret=\n';
    // 사용자 식별
    if (userMethod === 'HEADER' && ssoHeader) {
        props += '\n# 사용자 식별: SSO 헤더\n' +
            'dlm.user.header=' + ssoHeader + '\n';
    } else if (userMethod === 'SESSION' && sessionAttr) {
        props += '\n# 사용자 식별: 세션 속성\n' +
            'dlm.user.session-attr=' + sessionAttr + '\n';
    } else {
        props += '\n# 사용자 식별: 자동 탐지 (Spring Security > Remote User)\n' +
            '# 자동 탐지가 안 되면 아래 중 하나를 설정하세요\n' +
            '# dlm.user.session-attr=loginVO\n' +
            '# dlm.user.header=X-SSO-USER\n';
    }
    props += '\n# 버퍼 & 전송\n' +
        'dlm.buffer.capacity=10000\n' +
        'dlm.shipper.batch-size=500\n' +
        'dlm.shipper.flush-interval-ms=3000\n\n' +
        '# PII 정책 동기화\n' +
        'dlm.policy.sync-interval-ms=' + policySyncMs + '\n\n' +
        '# 제외 설정\n';
    if (excludeUsers) props += 'dlm.exclude.users=' + excludeUsers.replace(/\s+/g, '') + '\n';
    if (excludeSql) props += 'dlm.exclude.sql-patterns=' + excludeSql.replace(/\s+/g, '') + '\n';
    props += '\n# 장애 복구\n' +
        'dlm.failover.dir=/tmp/dlm-agent-failover';

    $('#agentPropsSnippet').text(props);
}

function copyAgentProps() {
    copyTextToClipboard($('#agentPropsSnippet').text());
    showToast('설정 파일이 복사되었습니다.');
}

// ========== DBA 사전 설정 가이드 ==========
var _dbaGuides = {
    ORACLE: '<strong>Oracle Unified Audit 설정 (DBA 작업 필요)</strong>' +
        '<div style="margin-top:10px;">' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin-bottom:4px;">1단계. Unified Audit 활성화 확인</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0 8px;font-size:0.75rem;overflow-x:auto;">' +
        'SELECT VALUE FROM V$OPTION WHERE PARAMETER = \'Unified Auditing\';</pre>' +
        '<div style="font-size:0.72rem;color:#475569;margin-bottom:12px;">' +
        '결과가 <strong style="color:#059669;">TRUE</strong> → 활성 상태 (다음 단계로)<br>' +
        '결과가 <strong style="color:#dc2626;">FALSE</strong> → 비활성 상태 (DBA가 DB 재시작 필요: <code>shutdown immediate → startup</code>)</div>' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin-bottom:4px;">2단계. Audit 정책 생성 + 활성화</div>' +
        '<div style="font-size:0.72rem;color:#475569;margin-bottom:6px;">' +
        '감사 대상 테이블 기반으로 자동 생성된 스크립트를 사용하세요.<br>' +
        '<a href="javascript:void(0)" onclick="window.open(\'/accesslog/index#policy\',\'_blank\');" style="color:#7c3aed;font-weight:600;">' +
        '감사 대상 테이블 관리</a> 페이지에서 <strong>스크립트 다운로드</strong> 버튼을 클릭하면 대상 테이블에 맞는 Audit 정책 SQL이 생성됩니다.</div>' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin:12px 0 4px;">3단계. XAudit 수집 계정 권한 부여</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0;font-size:0.75rem;overflow-x:auto;">' +
        '-- XAudit이 접속하는 DB 계정에 아래 권한 부여\nGRANT SELECT ON SYS.UNIFIED_AUDIT_TRAIL TO {XAudit계정};\nGRANT AUDIT_VIEWER TO {XAudit계정};</pre>' +
        '</div>',

    MARIADB: '<strong>MariaDB/MySQL General Log 설정 (DBA 작업 필요)</strong>' +
        '<div style="margin-top:10px;">' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin-bottom:4px;">1단계. General Log 활성화</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0 8px;font-size:0.75rem;overflow-x:auto;">' +
        '-- 활성화 확인\nSHOW VARIABLES LIKE \'general_log\';\n-- 결과: ON = 활성, OFF = 비활성\n\n' +
        '-- 활성화 (TABLE 모드로 설정)\nSET GLOBAL general_log = \'ON\';\nSET GLOBAL log_output = \'TABLE\';</pre>' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin:12px 0 4px;">2단계. XAudit 수집 계정 권한 부여</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0;font-size:0.75rem;overflow-x:auto;">' +
        'GRANT SELECT ON mysql.general_log TO \'{XAudit계정}\'@\'%\';\nFLUSH PRIVILEGES;</pre>' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin:12px 0 4px;">3단계. event_time 인덱스 확인</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0 8px;font-size:0.75rem;overflow-x:auto;">' +
        '-- general_log는 기본 인덱스 없음 → 증분 수집 시 Full Scan 발생\n' +
        '-- CSV 엔진이라 인덱스 추가 불가 → TABLE 엔진으로 변환 필요\n' +
        'ALTER TABLE mysql.general_log ENGINE = MyISAM;\n' +
        'CREATE INDEX idx_event_time ON mysql.general_log(event_time);</pre>' +
        '<div style="background:#fef3c7;border:1px solid #fbbf24;border-radius:6px;padding:8px 10px;margin-top:8px;font-size:0.72rem;color:#92400e;">' +
        '<i class="fas fa-exclamation-triangle" style="margin-right:4px;"></i>' +
        '<strong>성능 주의:</strong> General Log는 모든 쿼리를 기록합니다. 운영 환경에서는 DB 접근제어 방식을 권장합니다.</div>' +
        '</div>',

    MSSQL: '<strong>MSSQL Server Audit 설정 (DBA 작업 필요)</strong>' +
        '<div style="margin-top:10px;">' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin-bottom:4px;">1단계. Server Audit 생성</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0 8px;font-size:0.75rem;overflow-x:auto;">' +
        'CREATE SERVER AUDIT DlmAudit\n  TO FILE (FILEPATH = \'C:\\AuditLogs\\\');\nALTER SERVER AUDIT DlmAudit WITH (STATE = ON);</pre>' +
        '<div style="font-size:0.78rem;font-weight:600;color:#334155;margin:12px 0 4px;">2단계. Database Audit 스펙 생성</div>' +
        '<pre style="background:#1e293b;color:#e2e8f0;padding:10px;border-radius:6px;margin:4px 0;font-size:0.75rem;overflow-x:auto;">' +
        'CREATE DATABASE AUDIT SPECIFICATION DlmDbAudit\n  FOR SERVER AUDIT DlmAudit\n  ADD (SELECT, INSERT, UPDATE, DELETE\n    ON DATABASE::{DB명} BY public);\nALTER DATABASE AUDIT SPECIFICATION DlmDbAudit WITH (STATE = ON);</pre>' +
        '</div>'
};

function updateDbaGuide() {
    var dbType = ($('#wz_dbType').val() || '').toUpperCase();
    var guide = _dbaGuides[dbType] || _dbaGuides[dbType === 'MYSQL' ? 'MARIADB' : dbType] || null;
    if (guide && _selectedMethod === 'DB_AUDIT') {
        $('#dbaGuideContent').html(guide);
        $('#dbaGuideBox').show();
    } else {
        $('#dbaGuideBox').hide();
    }
}

// ========== DB_DAC 기본 샘플 SQL ==========
var _dacDefaultSql =
    "-- DB 접근제어 솔루션 로그 조회 SQL\n" +
    "-- 테이블명, 컬럼명을 솔루션 환경에 맞게 수정하세요\n" +
    "-- 아래 SQL 템플릿 버튼으로 솔루션별 샘플을 불러올 수 있습니다\n" +
    "-- #" + "{LAST_OFFSET} → DATETIME (예: '2026-04-14 09:00:00')\n" +
    "--\n" +
    "-- [필수] WHERE 조건의 시각 컬럼(LOG_DATE)에 인덱스가 있어야 합니다\n" +
    "-- 인덱스 없으면 매 수집마다 전체 테이블 스캔이 발생합니다\n" +
    "-- 예) CREATE INDEX IDX_LOG_DATE ON ACCESS_LOG_TABLE(LOG_DATE);\n" +
    "\n" +
    "SELECT LOG_DATE      AS access_time,   -- 접속 시각 (필수)\n" +
    "       DB_USER       AS user_account,   -- DB 접속 계정 (ID/사번)\n" +
    "       EMP_NAME      AS user_name,      -- 사용자 실명\n" +
    "       DEPT_NAME     AS department,      -- 부서\n" +
    "       CLIENT_IP     AS client_ip,       -- 접속 IP\n" +
    "       CMD_TYPE      AS action_type,     -- 수행 유형\n" +
    "       OBJ_NAME      AS target_table,    -- 대상 테이블\n" +
    "       SQL_TEXT       AS sql_text,        -- SQL 텍스트\n" +
    "       RESULT        AS result_code      -- 실행 결과\n" +
    "  FROM ACCESS_LOG_TABLE   -- 솔루션 로그 테이블명으로 변경\n" +
    " WHERE LOG_DATE > #" + "{LAST_OFFSET}\n" +
    " ORDER BY LOG_DATE\n" +
    " LIMIT 1000";

function getDacDefaultSql() { return _dacDefaultSql; }

// ========== DB_DAC 감사 대상 유형 변경 ==========
function onDacAuditTypeChange() {
    updateDacAuditDisplay();
}

function updateDacAuditDisplay() {
    var type = ($('#wz_dacAuditType').val() || 'DB_AUDIT');
    var cache = _auditPolicyCache || {};
    if (type === 'BCI') {
        var targets = cache.bciTargets || [];
        if (targets.length > 0) {
            $('#wz_auditTables_dac').html(
                '<span style="background:#dcfce7;color:#15803d;padding:3px 10px;border-radius:6px;font-size:0.8rem;font-weight:600;">' +
                '<i class="fas fa-globe" style="margin-right:4px;"></i>' + targets.length + '개 테이블</span>' +
                '<span style="color:#9ca3af;font-size:0.75rem;">클릭하여 상세 확인</span>'
            );
        } else {
            $('#wz_auditTables_dac').html('<span style="color:#9ca3af;font-size:0.8rem;">미설정 — 감사 대상 테이블 관리에서 등록하세요</span>');
        }
    } else {
        var tables = cache.auditTables || [];
        if (tables.length > 0) {
            $('#wz_auditTables_dac').html(
                '<span style="background:#ede9fe;color:#7c3aed;padding:3px 10px;border-radius:6px;font-size:0.8rem;font-weight:600;">' +
                '<i class="fas fa-database" style="margin-right:4px;"></i>' + tables.length + '개 테이블</span>' +
                '<span style="color:#9ca3af;font-size:0.75rem;">클릭하여 상세 확인</span>'
            );
        } else {
            $('#wz_auditTables_dac').html('<span style="color:#dc2626;font-size:0.8rem;"><i class="fas fa-exclamation-circle"></i> 미설정 — 감사 대상 테이블 관리에서 등록하세요</span>');
        }
    }
}

// ========== DB_DAC SQL Templates ==========
var _dacTemplates = {
    chakra: {
        name: '차크라맥스',
        sql: "SELECT ACCESS_DATE   AS access_time,\n" +
             "       DB_USER       AS user_account,\n" +
             "       USER_NAME     AS user_name,\n" +
             "       DEPT_NAME     AS department,\n" +
             "       CLIENT_IP     AS client_ip,\n" +
             "       SQL_TYPE      AS action_type,\n" +
             "       OBJECT_NAME   AS target_table,\n" +
             "       LEFT(SQL_TEXT, 2000) AS sql_text,\n" +
             "       RESULT_CODE   AS result_code\n" +
             "  FROM CHAKRA_ACCESS_LOG\n" +
             " WHERE ACCESS_DATE > #" + "{LAST_OFFSET}\n" +
             " ORDER BY ACCESS_DATE\n" +
             " LIMIT 1000"
    },
    petra: {
        name: '페트라',
        sql: "SELECT LOG_TIME      AS access_time,\n" +
             "       DB_ACCOUNT    AS user_account,\n" +
             "       USER_NM       AS user_name,\n" +
             "       ORG_NM        AS department,\n" +
             "       SRC_IP        AS client_ip,\n" +
             "       CMD_TYPE      AS action_type,\n" +
             "       TBL_NAME      AS target_table,\n" +
             "       LEFT(QUERY_TEXT, 2000) AS sql_text,\n" +
             "       STATUS        AS result_code\n" +
             "  FROM PETRA_SQL_LOG\n" +
             " WHERE LOG_TIME > #" + "{LAST_OFFSET}\n" +
             " ORDER BY LOG_TIME\n" +
             " LIMIT 1000"
    },
    dbsafer: {
        name: 'DBSafer',
        sql: "SELECT EVENT_TIME    AS access_time,\n" +
             "       USER_ID       AS user_account,\n" +
             "       USER_NAME     AS user_name,\n" +
             "       DEPT          AS department,\n" +
             "       SOURCE_IP     AS client_ip,\n" +
             "       ACTION        AS action_type,\n" +
             "       TARGET_OBJ    AS target_table,\n" +
             "       LEFT(SQL_STMT, 2000) AS sql_text,\n" +
             "       RESULT        AS result_code\n" +
             "  FROM DBS_AUDIT_LOG\n" +
             " WHERE EVENT_TIME > #" + "{LAST_OFFSET}\n" +
             " ORDER BY EVENT_TIME\n" +
             " LIMIT 1000"
    },
    queryone: {
        name: 'QueryOne',
        sql: "SELECT ACCESS_DT     AS access_time,\n" +
             "       CONN_USER     AS user_account,\n" +
             "       EMP_NAME      AS user_name,\n" +
             "       DEPT_NAME     AS department,\n" +
             "       CONN_IP       AS client_ip,\n" +
             "       EXEC_TYPE     AS action_type,\n" +
             "       OBJ_NAME      AS target_table,\n" +
             "       LEFT(EXEC_SQL, 2000) AS sql_text,\n" +
             "       EXEC_RESULT   AS result_code\n" +
             "  FROM QO_ACCESS_HIST\n" +
             " WHERE ACCESS_DT > #" + "{LAST_OFFSET}\n" +
             " ORDER BY ACCESS_DT\n" +
             " LIMIT 1000"
    }
};

function applyDacPreset(key) {
    var t = _dacTemplates[key];
    if (!t) return;
    $('#wz_dacSelectSql').val(t.sql);
    showToast(t.name + ' SQL 템플릿이 적용되었습니다. 환경에 맞게 수정하세요.');
}

// ========== Helpers ==========
function loadDatabaseList(callback) {
    $.get('/accesslog/api/databases', function(list) {
        _dbList = list || [];
        var $sel = $('#wz_dbName');
        $sel.find('option:not(:first)').remove();
        $.each(_dbList, function(i, db) {
            $sel.append('<option value="' + db.db + '">' + db.db + ' (' + db.dbtype + ' - ' + db.hostname + ':' + db.port + ')</option>');
        });
        if (callback) callback();
    });
}

function onWzDbSelect() {
    var dbName = $('#wz_dbName').val();
    var db = _dbList.find(function(d) { return d.db === dbName; });
    if (db) {
        $('#wz_dbType').val(db.dbtype.toUpperCase());
        $('#wz_infoSystem').text(db.system || db.db);
        $('#wz_infoDbType').text(db.dbtype);
        $('#wz_infoHost').text(db.hostname + ':' + db.port);
        $('#wz_dbInfo').show();
        loadAuditPolicyTables(dbName);
        updateDbaGuide();
        // DAC: DB 타입에 맞는 샘플 SQL 업데이트 (기본값 상태일 때만)
        if (_selectedMethod === 'DB_DAC') {
            var cur = $('#wz_dacSelectSql').val() || '';
            var isDefault = !cur || cur.indexOf('ACCESS_LOG_TABLE') >= 0;
            if (isDefault) $('#wz_dacSelectSql').val(getDacDefaultSql());
        }
    } else {
        $('#wz_dbInfo').hide();
        $('#wz_auditTables_db').html('<span style="color:#9ca3af;">DB를 선택하세요</span>');
        $('#wz_bciTables_agent').html('<span style="color:#9ca3af;">DB를 선택하세요</span>');
        $('#wz_tableFilter_db').val('');
        $('#wz_tableFilter_agent').val('');
    }
}

var _auditPolicyCache = {};

function loadAuditPolicyTables(dbName) {
    $.get('/accesslog/api/setup/status', { dbName: dbName }, function(res) {
        // DB Audit 대상
        var auditTables = (res.piiTables || []).filter(function(t) { return t.auditYn === 'Y'; });
        var auditFilter = auditTables.map(function(t) { return t.tableName; });
        _auditPolicyCache.auditTables = auditTables;
        _auditPolicyCache.bciTargets = res.bciTargets || [];

        var auditHtml;
        if (auditTables.length > 0) {
            auditHtml = '<span style="background:#ede9fe;color:#7c3aed;padding:3px 10px;border-radius:6px;font-size:0.8rem;font-weight:600;">' +
                '<i class="fas fa-database" style="margin-right:4px;"></i>' + auditTables.length + '개 테이블</span>' +
                '<span style="color:#9ca3af;font-size:0.75rem;">클릭하여 상세 확인</span>';
        } else {
            auditHtml = '<span style="color:#dc2626;font-size:0.8rem;"><i class="fas fa-exclamation-circle"></i> 미설정 — 감사 대상 테이블 관리에서 등록하세요</span>';
        }
        $('#wz_auditTables_db').html(auditHtml);
        $('#wz_tableFilter_db').val(auditFilter.join(','));
        // DAC 감사 대상도 자동 표시 (기본: DB 접근 감사)
        updateDacAuditDisplay();

        // 스키마 자동 설정 (감사 대상 테이블의 owner 목록)
        var owners = {};
        auditTables.forEach(function(t) { if (t.owner) owners[t.owner] = true; });
        $('#wz_schemaName_db').val(Object.keys(owners).join(','));

        // BCI 대상
        var bciTargets = res.bciTargets || [];
        var bciFilter = bciTargets.map(function(t) { return t.tableName; });

        if (bciTargets.length > 0) {
            $('#wz_bciTables_agent').html(
                '<span style="background:#dcfce7;color:#15803d;padding:3px 10px;border-radius:6px;font-size:0.8rem;font-weight:600;">' +
                '<i class="fas fa-globe" style="margin-right:4px;"></i>' + bciTargets.length + '개 테이블</span>' +
                '<span style="color:#9ca3af;font-size:0.75rem;">클릭하여 상세 확인</span>'
            );
        } else {
            $('#wz_bciTables_agent').html('<span style="color:#9ca3af;font-size:0.8rem;">미설정 — 감사 대상 테이블 관리에서 등록하세요</span>');
        }
        $('#wz_tableFilter_agent').val(bciFilter.join(','));

        // 스키마 자동 설정
        var bciOwners = {};
        bciTargets.forEach(function(t) { if (t.owner) bciOwners[t.owner] = true; });
        $('#wz_schemaName_agent').val(Object.keys(bciOwners).join(','));
    });
}

function testConnection() {
    var $btn = $('.btn-test-conn');
    $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 테스트 중...');
    $.ajax({
        url: '/accesslog/api/source/test-connection', type: 'POST', contentType: 'application/json',
        data: JSON.stringify({
            dbName: $('#wz_dbName').val(),
            hostname: $('#wz_hostname').val(),
            port: $('#wz_port').val(),
            dbType: $('#wz_dbType').val()
        }),
        success: function(res) {
            var $r = $('#testResult');
            $r.removeClass('success fail');
            if (res.success) {
                $r.addClass('success').html('<i class="fas fa-check-circle"></i> ' + res.message).show();
            } else {
                $r.addClass('fail').html('<i class="fas fa-times-circle"></i> ' + res.message).show();
            }
        },
        complete: function() {
            $btn.prop('disabled', false).html('<i class="fas fa-plug"></i> 연결 테스트');
        }
    });
}

function toggleGuide() {
    var $c = $('#guideContent');
    var $a = $('#guideArrow');
    if ($c.hasClass('show')) {
        $c.removeClass('show');
        $a.removeClass('fa-chevron-down').addClass('fa-chevron-right');
    } else {
        $c.addClass('show');
        $a.removeClass('fa-chevron-right').addClass('fa-chevron-down');
    }
}

function copyField(id) {
    var el = document.getElementById(id);
    el.select();
    document.execCommand('copy');
    showToast('복사되었습니다.');
}

function copySnippet() {
    copyTextToClipboard($('#agentSnippet').text());
    showToast('복사되었습니다.');
}

function copyFinalSnippet() {
    copyTextToClipboard($('#finalSnippet').text());
    showToast('복사되었습니다.');
}

function copyTextToClipboard(text) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text);
    } else {
        var ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
    }
}

function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0;
        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
}

function reloadPage() {
    $.get('/accesslog/sources', function(html) { $('#mainContent').html(html); });
}

</script>
