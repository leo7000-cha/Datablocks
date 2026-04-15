<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<style>
/* Settings Page Styles */
.settings-container {
    padding: 0;
    background: #f1f5f9;
    min-height: 100%;
}

.settings-header {
    background: #fff;
    padding: 16px 20px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 10;
}

.settings-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #1e293b;
    display: flex;
    align-items: center;
    gap: 10px;
}

.settings-title i {
    color: #3b82f6;
}

.settings-actions {
    display: flex;
    gap: 8px;
}

.settings-body {
    padding: 20px;
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
}

.settings-body.single-column {
    grid-template-columns: 1fr;
}

/* Settings Category Card */
.settings-category {
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    overflow: hidden;
}

.settings-category.full-width {
    grid-column: span 2;
}

.category-header {
    padding: 14px 18px;
    background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 10px;
}

.category-icon {
    width: 32px;
    height: 32px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.9rem;
}

.category-icon.module { background: linear-gradient(135deg, #0ea5e9, #0284c7); color: #fff; }
.category-icon.system { background: linear-gradient(135deg, #3b82f6, #2563eb); color: #fff; }
.category-icon.job { background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: #fff; }
.category-icon.restore { background: linear-gradient(135deg, #10b981, #059669); color: #fff; }
.category-icon.commit { background: linear-gradient(135deg, #f59e0b, #d97706); color: #fff; }
.category-icon.sql { background: linear-gradient(135deg, #ec4899, #db2777); color: #fff; }
.category-icon.flag { background: linear-gradient(135deg, #14b8a6, #0d9488); color: #fff; }
.category-icon.notice { background: linear-gradient(135deg, #64748b, #475569); color: #fff; }

.category-title {
    font-size: 0.9rem;
    font-weight: 600;
    color: #1e293b;
}

.category-body {
    padding: 0;
}

/* Settings Item */
.settings-item {
    display: flex;
    align-items: center;
    padding: 14px 18px;
    border-bottom: 1px solid #f1f5f9;
    cursor: pointer;
    transition: background 0.15s;
}

.settings-item:last-child {
    border-bottom: none;
}

.settings-item:hover {
    background: #f8fafc;
}

.settings-item-info {
    flex: 1;
    min-width: 0;
}

.settings-item-key {
    font-size: 0.8rem;
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 2px;
}

.settings-item-desc {
    font-size: 0.72rem;
    color: #64748b;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.settings-item-value {
    font-size: 0.8rem;
    color: #3b82f6;
    font-weight: 500;
    max-width: 200px;
    text-align: right;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin-left: 12px;
}

.settings-item-value.empty {
    color: #94a3b8;
    font-style: italic;
}

.settings-item-arrow {
    color: #cbd5e1;
    margin-left: 8px;
    font-size: 0.75rem;
}

/* Flag Toggle in Settings */
.settings-flag {
    display: flex;
    align-items: center;
    padding: 12px 18px;
    border-bottom: 1px solid #f1f5f9;
}

.settings-flag:last-child {
    border-bottom: none;
}

.settings-flag-info {
    flex: 1;
}

.settings-flag-key {
    font-size: 0.8rem;
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 2px;
}

.settings-flag-desc {
    font-size: 0.72rem;
    color: #64748b;
}

.settings-toggle {
    position: relative;
    width: 44px;
    height: 24px;
    cursor: pointer;
}

.settings-toggle input {
    opacity: 0;
    width: 0;
    height: 0;
}

.settings-toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #cbd5e1;
    transition: 0.3s;
    border-radius: 24px;
}

.settings-toggle-slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}

.settings-toggle input:checked + .settings-toggle-slider {
    background: linear-gradient(135deg, #10b981, #059669);
}

.settings-toggle input:checked + .settings-toggle-slider:before {
    transform: translateX(20px);
}

/* Search Filter */
.settings-search {
    position: relative;
}

.settings-search input {
    padding: 8px 12px 8px 36px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    width: 220px;
    background: #f8fafc;
    transition: all 0.2s;
}

.settings-search input:focus {
    outline: none;
    border-color: #3b82f6;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
}

.settings-search i {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    font-size: 0.85rem;
}

/* Modal Toggle for FLAG */
.modal-toggle-container {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 0;
}

.modal-toggle {
    position: relative;
    width: 50px;
    height: 26px;
    cursor: pointer;
}

.modal-toggle input {
    opacity: 0;
    width: 0;
    height: 0;
}

.modal-toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #cbd5e1;
    transition: 0.3s;
    border-radius: 26px;
}

.modal-toggle-slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}

.modal-toggle input:checked + .modal-toggle-slider {
    background: linear-gradient(135deg, #10b981, #059669);
}

.modal-toggle input:checked + .modal-toggle-slider:before {
    transform: translateX(24px);
}

.modal-toggle-label {
    font-size: 0.9rem;
    font-weight: 600;
    color: #1e293b;
}

.modal-toggle-label.on {
    color: #059669;
}

.modal-toggle-label.off {
    color: #94a3b8;
}

/* Badge styles for FLAG values */
.badge-on {
    background: linear-gradient(135deg, #10b981, #059669);
    color: #fff;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 0.7rem;
    font-weight: 600;
}

.badge-off {
    background: #e2e8f0;
    color: #64748b;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 0.7rem;
    font-weight: 600;
}

/* Other Settings section styling */
#otherSettingsBody {
    max-height: 500px;
    overflow-y: auto;
}

#otherSettingsBody .settings-item {
    display: flex;
    align-items: center;
}

/* Statistics Bar */
.settings-stats-bar {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 12px 20px;
    background: #fff;
    border-bottom: 1px solid #e2e8f0;
    flex-wrap: wrap;
}

.stats-item {
    display: flex;
    align-items: center;
    gap: 6px;
}

.stats-item.stats-total {
    font-weight: 600;
    color: #1e293b;
}

.stats-item.stats-total i {
    color: #3b82f6;
}

.stats-divider {
    width: 1px;
    height: 20px;
    background: #e2e8f0;
}

.stats-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
}

.stats-dot.module { background: linear-gradient(135deg, #0ea5e9, #0284c7); }
.stats-dot.flag { background: linear-gradient(135deg, #14b8a6, #0d9488); }
.stats-dot.system { background: linear-gradient(135deg, #3b82f6, #2563eb); }
.stats-dot.job { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
.stats-dot.restore { background: linear-gradient(135deg, #10b981, #059669); }
.stats-dot.commit { background: linear-gradient(135deg, #f59e0b, #d97706); }
.stats-dot.sql { background: linear-gradient(135deg, #ec4899, #db2777); }
.stats-dot.notice { background: linear-gradient(135deg, #64748b, #475569); }
.stats-dot.other { background: linear-gradient(135deg, #6366f1, #4f46e5); }

.stats-label {
    font-size: 0.75rem;
    color: #64748b;
}

.stats-count {
    font-size: 0.8rem;
    font-weight: 600;
    color: #1e293b;
    background: #f1f5f9;
    padding: 2px 8px;
    border-radius: 10px;
}
</style>

<!-- Begin Page Content -->
<div class="settings-container" id="piiconfiglist">
    <!-- Header (DB Connection Style) -->
    <div class="settings-header">
        <div class="settings-title">
            <i class="fas fa-cogs"></i>
            <spring:message code="memu.control_management" text="Solution Configuration"/>
        </div>
        <div class="settings-actions">
            <div class="settings-search">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" placeholder="Search settings..."
                       onkeyup="filterSettings(this.value)">
            </div>
            <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
                <button type="button" data-oper='register' class="btn-action-register">
                    <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                </button>
                <button type="button" data-oper='refresh' class="btn-action-reset">
                    <i class="fas fa-sync-alt"></i> Refresh
                </button>
            </sec:authorize>
        </div>
    </div>

    <!-- Hidden Form -->
    <form style="display:none;" id="searchForm">
        <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
        <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    </form>

    <%-- Calculate counts for each category --%>
    <c:set var="moduleCount" value="0"/>
    <c:set var="flagCount" value="0"/>
    <c:set var="systemCount" value="0"/>
    <c:set var="jobCount" value="0"/>
    <c:set var="restoreCount" value="0"/>
    <c:set var="commitCount" value="0"/>
    <c:set var="sqlCount" value="0"/>
    <c:set var="noticeCount" value="0"/>
    <c:set var="otherCnt" value="0"/>
    <c:forEach items="${list}" var="cfg">
        <c:choose>
            <c:when test="${fn:startsWith(cfg.cfgkey, 'MODULE_')}"><c:set var="moduleCount" value="${moduleCount + 1}"/></c:when>
            <c:when test="${fn:contains(cfg.cfgkey, '_FLAG')}"><c:set var="flagCount" value="${flagCount + 1}"/></c:when>
            <c:when test="${cfg.cfgkey eq 'SITE' || cfg.cfgkey eq 'DLM_ENV' || cfg.cfgkey eq 'DLM_LOG_PATH' || cfg.cfgkey eq 'DEFAULT_LOCALE' || cfg.cfgkey eq 'LOG_LEVEL' || cfg.cfgkey eq 'DASHBOARD_SHOW'}"><c:set var="systemCount" value="${systemCount + 1}"/></c:when>
            <c:when test="${cfg.cfgkey eq 'DLM_CURRENT_ORDERID' || cfg.cfgkey eq 'DLM_TABLELIST_ORDERBY' || cfg.cfgkey eq 'DLM_ARCDELJOB_TIME' || cfg.cfgkey eq 'DLM_ARCDELJOB_THREADCNT' || cfg.cfgkey eq 'TESTDATA_AUTO_GEN_JOB_MAX_CNT' || cfg.cfgkey eq 'RESTORE_JOB_MAX_CNT'}"><c:set var="jobCount" value="${jobCount + 1}"/></c:when>
            <c:when test="${cfg.cfgkey eq 'DLM_RESTORE_THREADCNT' || cfg.cfgkey eq 'DLM_RESTORE_COMMITCNT' || cfg.cfgkey eq 'RESTOREGAP_UPDROW_EXCEPTION'}"><c:set var="restoreCount" value="${restoreCount + 1}"/></c:when>
            <c:when test="${fn:contains(cfg.cfgkey, 'COMMIT_LOOP_CNT') || fn:contains(cfg.cfgkey, 'STOPHOUR')}"><c:set var="commitCount" value="${commitCount + 1}"/></c:when>
            <c:when test="${fn:contains(cfg.cfgkey, 'SQL') || fn:contains(cfg.cfgkey, 'HINT') || cfg.cfgkey eq 'DLM_EXTRACT_MAX_CNT' || cfg.cfgkey eq 'SQLLDR_PATH'}"><c:set var="sqlCount" value="${sqlCount + 1}"/></c:when>
            <c:when test="${fn:contains(cfg.cfgkey, 'NOTICE')}"><c:set var="noticeCount" value="${noticeCount + 1}"/></c:when>
            <c:otherwise><c:set var="otherCnt" value="${otherCnt + 1}"/></c:otherwise>
        </c:choose>
    </c:forEach>

    <!-- Statistics Bar -->
    <div class="settings-stats-bar">
        <div class="stats-item stats-total">
            <i class="fas fa-list-ul"></i>
            <span class="stats-label">Total</span>
            <span class="stats-count">${fn:length(list)}</span>
        </div>
        <div class="stats-divider"></div>
        <div class="stats-item">
            <span class="stats-dot module"></span>
            <span class="stats-label">Module</span>
            <span class="stats-count">${moduleCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot flag"></span>
            <span class="stats-label">Flags</span>
            <span class="stats-count">${flagCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot system"></span>
            <span class="stats-label">System</span>
            <span class="stats-count">${systemCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot job"></span>
            <span class="stats-label">JOB</span>
            <span class="stats-count">${jobCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot restore"></span>
            <span class="stats-label">Restore</span>
            <span class="stats-count">${restoreCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot commit"></span>
            <span class="stats-label">Commit</span>
            <span class="stats-count">${commitCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot sql"></span>
            <span class="stats-label">SQL</span>
            <span class="stats-count">${sqlCount}</span>
        </div>
        <div class="stats-item">
            <span class="stats-dot notice"></span>
            <span class="stats-label">Notice</span>
            <span class="stats-count">${noticeCount}</span>
        </div>
        <c:if test="${otherCnt > 0}">
            <div class="stats-item">
                <span class="stats-dot other"></span>
                <span class="stats-label">Other</span>
                <span class="stats-count">${otherCnt}</span>
            </div>
        </c:if>
    </div>

    <!-- Settings Body -->
    <div class="settings-body">

        <!-- Module Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon module"><i class="fas fa-th-large"></i></div>
                <div class="category-title">HUB Modules</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${fn:startsWith(piiconfig.cfgkey, 'MODULE_')}">
                        <div class="settings-flag" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="FLAG">
                            <div class="settings-flag-info">
                                <div class="settings-flag-key">${piiconfig.cfgkey}</div>
                                <div class="settings-flag-desc">${piiconfig.comments}</div>
                            </div>
                            <label class="settings-toggle">
                                <input type="checkbox" ${piiconfig.value eq 'Y' ? 'checked' : ''} disabled>
                                <span class="settings-toggle-slider"></span>
                            </label>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- FLAG Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon flag"><i class="fas fa-toggle-on"></i></div>
                <div class="category-title">System Flags</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${fn:contains(piiconfig.cfgkey, '_FLAG')}">
                        <div class="settings-flag" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="FLAG">
                            <div class="settings-flag-info">
                                <div class="settings-flag-key">${piiconfig.cfgkey}</div>
                                <div class="settings-flag-desc">${piiconfig.comments}</div>
                            </div>
                            <label class="settings-toggle">
                                <input type="checkbox" ${piiconfig.value eq 'Y' ? 'checked' : ''} disabled>
                                <span class="settings-toggle-slider"></span>
                            </label>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- System Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon system"><i class="fas fa-server"></i></div>
                <div class="category-title">System Settings</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${piiconfig.cfgkey eq 'SITE' || piiconfig.cfgkey eq 'DLM_ENV' ||
                                  piiconfig.cfgkey eq 'DLM_LOG_PATH' || piiconfig.cfgkey eq 'DEFAULT_LOCALE' ||
                                  piiconfig.cfgkey eq 'LOG_LEVEL' || piiconfig.cfgkey eq 'DASHBOARD_SHOW'}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>"
                             data-type="${fn:contains(piiconfig.cfgkey, 'LOG_LEVEL') ? 'LOG_LEVEL' : 'TEXT'}">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : (fn:length(piiconfig.value) > 30 ? fn:substring(piiconfig.value, 0, 30).concat('...') : piiconfig.value)}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- JOB Execution Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon job"><i class="fas fa-play-circle"></i></div>
                <div class="category-title">JOB Execution</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${piiconfig.cfgkey eq 'DLM_CURRENT_ORDERID' || piiconfig.cfgkey eq 'DLM_TABLELIST_ORDERBY' ||
                                  piiconfig.cfgkey eq 'DLM_ARCDELJOB_TIME' || piiconfig.cfgkey eq 'DLM_ARCDELJOB_THREADCNT' ||
                                  piiconfig.cfgkey eq 'TESTDATA_AUTO_GEN_JOB_MAX_CNT' || piiconfig.cfgkey eq 'RESTORE_JOB_MAX_CNT'}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="TEXT">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : piiconfig.value}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- Restore Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon restore"><i class="fas fa-undo-alt"></i></div>
                <div class="category-title">Restore Settings</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${piiconfig.cfgkey eq 'DLM_RESTORE_THREADCNT' || piiconfig.cfgkey eq 'DLM_RESTORE_COMMITCNT' ||
                                  piiconfig.cfgkey eq 'RESTOREGAP_UPDROW_EXCEPTION'}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="TEXT">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : piiconfig.value}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- Commit & Loop Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon commit"><i class="fas fa-layer-group"></i></div>
                <div class="category-title">Commit & Loop Settings</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'COMMIT_LOOP_CNT') || fn:contains(piiconfig.cfgkey, 'STOPHOUR')}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="TEXT">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : piiconfig.value}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- SQL & Hint Settings -->
        <div class="settings-category">
            <div class="category-header">
                <div class="category-icon sql"><i class="fas fa-database"></i></div>
                <div class="category-title">SQL & Hint Settings</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'SQL') || fn:contains(piiconfig.cfgkey, 'HINT') ||
                                  piiconfig.cfgkey eq 'DLM_EXTRACT_MAX_CNT' || piiconfig.cfgkey eq 'SQLLDR_PATH'}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>"
                             data-type="${fn:contains(piiconfig.cfgkey, 'SQL') || fn:contains(piiconfig.cfgkey, 'HINT') ? 'SQL' : 'TEXT'}">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : (fn:length(piiconfig.value) > 50 ? fn:substring(piiconfig.value, 0, 50).concat('...') : piiconfig.value)}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>

        <!-- Other Settings (Uncategorized) -->
        <div class="settings-category full-width" id="otherSettings">
            <div class="category-header">
                <div class="category-icon" style="background: linear-gradient(135deg, #6366f1, #4f46e5); color: #fff;">
                    <i class="fas fa-ellipsis-h"></i>
                </div>
                <div class="category-title">Other Settings</div>
            </div>
            <div class="category-body" id="otherSettingsBody">
                <c:set var="otherCount" value="0"/>
                <c:forEach items="${list}" var="piiconfig">
                    <c:set var="isOther" value="true"/>
                    <%-- Exclude MODULE Settings --%>
                    <c:if test="${fn:startsWith(piiconfig.cfgkey, 'MODULE_')}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude FLAGS --%>
                    <c:if test="${fn:contains(piiconfig.cfgkey, '_FLAG')}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude System Settings --%>
                    <c:if test="${piiconfig.cfgkey eq 'SITE' || piiconfig.cfgkey eq 'DLM_ENV' || piiconfig.cfgkey eq 'DLM_LOG_PATH' || piiconfig.cfgkey eq 'DEFAULT_LOCALE' || piiconfig.cfgkey eq 'LOG_LEVEL' || piiconfig.cfgkey eq 'DASHBOARD_SHOW'}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude JOB Execution --%>
                    <c:if test="${piiconfig.cfgkey eq 'DLM_CURRENT_ORDERID' || piiconfig.cfgkey eq 'DLM_TABLELIST_ORDERBY' || piiconfig.cfgkey eq 'DLM_ARCDELJOB_TIME' || piiconfig.cfgkey eq 'DLM_ARCDELJOB_THREADCNT' || piiconfig.cfgkey eq 'TESTDATA_AUTO_GEN_JOB_MAX_CNT' || piiconfig.cfgkey eq 'RESTORE_JOB_MAX_CNT'}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude Restore Settings --%>
                    <c:if test="${piiconfig.cfgkey eq 'DLM_RESTORE_THREADCNT' || piiconfig.cfgkey eq 'DLM_RESTORE_COMMITCNT' || piiconfig.cfgkey eq 'RESTOREGAP_UPDROW_EXCEPTION'}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude Commit & Loop Settings --%>
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'COMMIT_LOOP_CNT') || fn:contains(piiconfig.cfgkey, 'STOPHOUR')}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude SQL & Hint Settings --%>
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'SQL') || fn:contains(piiconfig.cfgkey, 'HINT') || piiconfig.cfgkey eq 'DLM_EXTRACT_MAX_CNT' || piiconfig.cfgkey eq 'SQLLDR_PATH'}"><c:set var="isOther" value="false"/></c:if>
                    <%-- Exclude Notice Settings --%>
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'NOTICE')}"><c:set var="isOther" value="false"/></c:if>

                    <c:if test="${isOther}">
                        <c:set var="otherCount" value="${otherCount + 1}"/>
                        <div class="settings-item other-settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="TEXT">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                <c:choose>
                                    <c:when test="${empty piiconfig.value}">Not set</c:when>
                                    <c:when test="${fn:length(piiconfig.value) > 40}">${fn:substring(piiconfig.value, 0, 40)}...</c:when>
                                    <c:otherwise>${piiconfig.value}</c:otherwise>
                                </c:choose>
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
                <c:if test="${otherCount == 0}">
                    <div style="padding: 20px; text-align: center; color: #94a3b8;">
                        <i class="fas fa-check-circle"></i> All settings are categorized
                    </div>
                </c:if>
            </div>
        </div>

        <!-- Notice Settings (Full Width) -->
        <div class="settings-category full-width">
            <div class="category-header">
                <div class="category-icon notice"><i class="fas fa-bullhorn"></i></div>
                <div class="category-title">Notice Settings</div>
            </div>
            <div class="category-body">
                <c:forEach items="${list}" var="piiconfig">
                    <c:if test="${fn:contains(piiconfig.cfgkey, 'NOTICE')}">
                        <div class="settings-item" data-cfgkey="<c:out value='${piiconfig.cfgkey}'/>"
                             data-value="<c:out value='${piiconfig.value}'/>" data-comments="<c:out value='${piiconfig.comments}'/>" data-type="TEXT">
                            <div class="settings-item-info">
                                <div class="settings-item-key">${piiconfig.cfgkey}</div>
                                <div class="settings-item-desc">${piiconfig.comments}</div>
                            </div>
                            <div class="settings-item-value ${empty piiconfig.value ? 'empty' : ''}">
                                ${empty piiconfig.value ? 'Not set' : (fn:length(piiconfig.value) > 50 ? fn:substring(piiconfig.value, 0, 50).concat('...') : piiconfig.value)}
                            </div>
                            <i class="fas fa-chevron-right settings-item-arrow"></i>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<!-- Register Modal -->
<div class="modal fade" id="registerModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header member-modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i><spring:message code="btn.register" text="Register Config"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="registerForm">
                    <div class="member-form-group">
                        <label class="member-form-label">KEY <span class="text-danger">*</span></label>
                        <input type="text" class="member-form-input" name="cfgkey" required
                               onkeyup="this.value=this.value.toUpperCase()" placeholder="Enter config key">
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">VALUE</label>
                        <textarea class="member-form-input" name="value" rows="5" placeholder="Enter value" style="height: auto;"></textarea>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">COMMENTS</label>
                        <input type="text" class="member-form-input" name="comments" placeholder="Enter comments">
                    </div>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer">
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> <spring:message code="btn.cancel" text="Cancel"/>
                </button>
                <button type="button" class="btn-modal-save" id="btnRegisterSave">
                    <i class="fas fa-save"></i> <spring:message code="btn.register" text="Register"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modify Modal -->
<div class="modal fade" id="modifyModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header member-modal-header-modify">
                <h5 class="modal-title"><i class="fas fa-edit mr-2"></i><spring:message code="btn.modify" text="Modify Config"/></h5>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body member-modal-body">
                <form id="modifyForm">
                    <div class="member-form-group">
                        <label class="member-form-label">KEY</label>
                        <input type="text" class="member-form-input" name="cfgkey" readonly>
                    </div>
                    <div class="member-form-group" id="valueContainer">
                        <label class="member-form-label">VALUE</label>
                    </div>
                    <div class="member-form-group">
                        <label class="member-form-label">COMMENTS</label>
                        <input type="text" class="member-form-input" name="comments" placeholder="Enter comments">
                    </div>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer member-modal-footer">
                <button type="button" class="btn-modal-delete" id="btnDelete" style="margin-right: auto;">
                    <i class="fas fa-trash-alt"></i> <spring:message code="btn.remove" text="Delete"/>
                </button>
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> <spring:message code="btn.cancel" text="Cancel"/>
                </button>
                <button type="button" class="btn-modal-save" id="btnModifySave">
                    <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    // List of known/categorized keys
    var categorizedKeys = [
        // MODULE
        'MODULE_XPURGE', 'MODULE_XGEN', 'MODULE_XSCAN', 'MODULE_XAUDIT',
        // FLAGS
        'DLM_RUN_FLAG', 'DLM_ORDER_FLAG', 'DLM_ORDER_ARCDELJOB_FLAG', 'DLM_ARC_TAB_AUTO_MGMT_FLAG',
        // System
        'SITE', 'DLM_ENV', 'DLM_LOG_PATH', 'DEFAULT_LOCALE', 'LOG_LEVEL', 'DASHBOARD_SHOW',
        // JOB
        'DLM_CURRENT_ORDERID', 'DLM_TABLELIST_ORDERBY', 'DLM_ARCDELJOB_TIME', 'DLM_ARCDELJOB_THREADCNT',
        'TESTDATA_AUTO_GEN_JOB_MAX_CNT', 'RESTORE_JOB_MAX_CNT',
        // Restore
        'DLM_RESTORE_THREADCNT', 'DLM_RESTORE_COMMITCNT', 'RESTOREGAP_UPDROW_EXCEPTION',
        // Commit/Loop/Stop
        'ILM_COMMIT_LOOP_CNT', 'MIGRATE_COMMIT_LOOP_CNT', 'SCRAMBLE_COMMIT_LOOP_CNT',
        'ILM_STOPHOUR_FROM_TO', 'MIGRATE_STOPHOUR_FROM_TO',
        // SQL/Hint
        'DLM_ENC_PWD_SQL', 'DLM_KEYMAP_JOIN_HINT', 'DLM_KEYMAP_HIST_JOIN_HINT', 'DLM_EXTRACT_MAX_CNT', 'SQLLDR_PATH',
        // Notice
        'NOTICE1', 'NOTICE2', 'NOTICE3', 'NOTICE4', 'NOTICE5'
    ];

    $(function () {
        // Debug: log all config items from server
        console.log('=== All Config Items from Server ===');
        <c:forEach items="${list}" var="piiconfig">
        console.log('${piiconfig.cfgkey}');
        </c:forEach>
        console.log('=== End of Config Items ===');

        // Check for uncategorized settings
        checkUncategorizedSettings();
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Click on settings item
        $('.settings-item').on('click', function () {
            if (!is_admin) return;
            openModifyModal($(this));
        });

        // Click on FLAG item
        $('.settings-flag').on('click', function () {
            if (!is_admin) return;
            openModifyModal($(this));
        });

        // Click on Other Settings item
        $('.other-settings-item').on('click', function () {
            if (!is_admin) return;
            openModifyModal($(this));
        });

        // Register button
        $("button[data-oper='register']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            $('#registerForm')[0].reset();
            $('#registerModal').modal('show');
        });

        // Refresh button
        $("button[data-oper='refresh']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            refreshConfig();
        });

        // Register save
        $('#btnRegisterSave').on('click', function () {
            var form = $('#registerForm');
            var cfgkey = form.find('[name="cfgkey"]').val().trim();

            if (!cfgkey) {
                dlmAlert('<spring:message code="msg.enterkey" text="Please enter config key"/>');
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiconfig/register",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#registerModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Modify save
        $('#btnModifySave').on('click', function () {
            var form = $('#modifyForm');
            var configType = form.data('configType');

            if (configType === 'FLAG') {
                var isChecked = form.find('.modal-toggle-switch').is(':checked');
                form.find('[name="value"]').val(isChecked ? 'Y' : 'N');
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piiconfig/modify",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    $('#modifyModal').modal('hide');
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                    showToast("처리가 완료되었습니다.", false);
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Delete
        $('#btnDelete').on('click', function () {
            showConfirm('<spring:message code="msg.removeconfirm" text="Are you sure to remove?"/>', function() {
                var cfgkey = $('#modifyForm [name="cfgkey"]').val();
                if (!cfgkey) {
                    dlmAlert('Config key not found!');
                    return;
                }

                console.log('Deleting config key:', cfgkey);

                // Create a form and submit
                var deleteForm = $('<form>', {
                    'method': 'POST',
                    'action': '/piiconfig/remove'
                });
                deleteForm.append($('<input>', {type: 'hidden', name: 'cfgkey', value: cfgkey}));
                deleteForm.append($('<input>', {type: 'hidden', name: '${_csrf.parameterName}', value: '${_csrf.token}'}));

                ingShow();
                $.ajax({
                    type: "POST",
                    url: "/piiconfig/remove",
                    data: deleteForm.serialize(),
                    dataType: "html",
                    success: function (data) {
                        console.log('Delete success');
                        ingHide();
                        $('#modifyModal').modal('hide');
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        showToast("처리가 완료되었습니다.", false);
                        setTimeout(function() { searchAction(); }, 500);
                    },
                    error: function (request, error) {
                        console.log('Delete error:', request.status, request.responseText);
                        ingHide();
                        $("#errormodalbody").html(request.responseText);
                        $("#errormodal").modal("show");
                    }
                });
            });
        });
    });

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function checkUncategorizedSettings() {
        var otherContainer = $('#otherSettingsBody');
        otherContainer.empty();
        var hasItems = false;

        <c:forEach items="${list}" var="piiconfig">
        (function() {
            var cfgkey = '<c:out value="${piiconfig.cfgkey}"/>';
            var cfgvalue = '<c:out value="${piiconfig.value}"/>';
            var comments = '<c:out value="${piiconfig.comments}"/>';

            if (categorizedKeys.indexOf(cfgkey) === -1 &&
                !cfgkey.includes('_FLAG') &&
                !cfgkey.includes('NOTICE') &&
                !cfgkey.includes('SQL') &&
                !cfgkey.includes('HINT') &&
                !cfgkey.includes('COMMIT_LOOP_CNT') &&
                !cfgkey.includes('STOPHOUR')) {

                hasItems = true;
                var item = $('<div class="settings-item"></div>');
                item.attr('data-cfgkey', cfgkey);
                item.attr('data-value', cfgvalue);
                item.attr('data-comments', comments);
                item.attr('data-type', 'TEXT');

                item.html(
                    '<div class="settings-item-info">' +
                    '<div class="settings-item-key">' + escapeHtml(cfgkey) + '</div>' +
                    '<div class="settings-item-desc">' + escapeHtml(comments) + '</div>' +
                    '</div>' +
                    '<div class="settings-item-value">' + (cfgvalue ? escapeHtml(cfgvalue) : 'Not set') + '</div>' +
                    '<i class="fas fa-chevron-right settings-item-arrow"></i>'
                );

                item.on('click', function() {
                    if (!is_admin) return;
                    openModifyModal($(this));
                });

                otherContainer.append(item);
            }
        })();
        </c:forEach>

        if (hasItems) {
            $('#otherSettings').show();
        }
    }

    function openModifyModal(el) {
        var cfgkey = el.data('cfgkey') || '';
        var value = el.data('value') || '';
        var comments = el.data('comments') || '';
        var configType = el.data('type') || 'TEXT';

        // Convert to string to handle any type
        cfgkey = String(cfgkey);
        value = String(value);
        comments = String(comments);

        var form = $('#modifyForm');
        form[0].reset();
        form.data('configType', configType);
        form.find('[name="cfgkey"]').val(cfgkey);
        form.find('[name="comments"]').val(comments);

        var valueContainer = $('#valueContainer');
        valueContainer.empty();
        valueContainer.append('<label class="member-form-label">VALUE</label>');

        if (configType === 'FLAG') {
            var isChecked = value === 'Y';
            var toggleHtml = '<div class="modal-toggle-container">';
            toggleHtml += '<label class="modal-toggle">';
            toggleHtml += '<input type="checkbox" class="modal-toggle-switch" ' + (isChecked ? 'checked' : '') + '>';
            toggleHtml += '<span class="modal-toggle-slider"></span>';
            toggleHtml += '</label>';
            toggleHtml += '<span class="modal-toggle-label ' + (isChecked ? 'on' : 'off') + '">' + (isChecked ? 'ON' : 'OFF') + '</span>';
            toggleHtml += '</div>';
            valueContainer.append(toggleHtml);
            valueContainer.append($('<input type="hidden" name="value">').val(value));

            valueContainer.find('.modal-toggle-switch').on('change', function() {
                var checked = $(this).is(':checked');
                valueContainer.find('.modal-toggle-label')
                    .text(checked ? 'ON' : 'OFF')
                    .removeClass('on off')
                    .addClass(checked ? 'on' : 'off');
                form.find('[name="value"]').val(checked ? 'Y' : 'N');
            });
        } else if (configType === 'SQL') {
            var textarea = $('<textarea class="member-form-input" name="value" rows="12" style="height: auto; font-family: monospace; font-size: 0.8rem;"></textarea>');
            textarea.val(value);
            valueContainer.append(textarea);
        } else if (configType === 'LOG_LEVEL') {
            var selectHtml = '<select class="member-form-input" name="value">';
            selectHtml += '<option value="">Select</option>';
            selectHtml += '<option value="WARN"' + (value === 'WARN' ? ' selected' : '') + '>WARN</option>';
            selectHtml += '<option value="INFO"' + (value === 'INFO' ? ' selected' : '') + '>INFO</option>';
            selectHtml += '<option value="DEBUG"' + (value === 'DEBUG' ? ' selected' : '') + '>DEBUG</option>';
            selectHtml += '</select>';
            valueContainer.append(selectHtml);
        } else {
            var input = $('<input type="text" class="member-form-input" name="value">');
            input.val(value);
            valueContainer.append(input);
        }

        $('#modifyModal').modal('show');
    }

    function filterSettings(query) {
        query = query.toLowerCase();
        $('.settings-item, .settings-flag').each(function() {
            var key = $(this).data('cfgkey').toLowerCase();
            var comments = ($(this).data('comments') || '').toLowerCase();
            if (key.includes(query) || comments.includes(query)) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });

        // Show/hide categories based on visible items
        $('.settings-category').each(function() {
            var visibleItems = $(this).find('.settings-item:visible, .settings-flag:visible').length;
            if (visibleItems === 0 && query) {
                $(this).hide();
            } else {
                $(this).show();
            }
        });
    }

    function refreshConfig() {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiconfig/refreshConfig",
            dataType: "text",
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) {
                ingHide();
                showToast("처리가 완료되었습니다.", false);
            }
        });
    }

    function searchAction() {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piiconfig/list?pagenum=1&amount=100",
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
</script>
