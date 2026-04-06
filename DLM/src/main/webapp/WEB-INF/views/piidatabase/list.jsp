<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<style>
/* DB Connection Page Styles */
.db-container {
    padding: 0;
    background: #f1f5f9;
    min-height: 100%;
}

.db-header {
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

.db-title {
    font-size: 1.1rem;
    font-weight: 700;
    color: #1e293b;
    display: flex;
    align-items: center;
    gap: 10px;
}

.db-title i {
    color: #3b82f6;
}

.db-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}

.db-search {
    position: relative;
}

.db-search input {
    padding: 8px 12px 8px 36px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    width: 220px;
    background: #f8fafc;
    transition: all 0.2s;
}

.db-search input:focus {
    outline: none;
    border-color: #3b82f6;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
}

.db-search i {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    font-size: 0.85rem;
}

/* Statistics Bar */
.db-stats-bar {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 12px 20px;
    background: #fff;
    border-bottom: 1px solid #e2e8f0;
    flex-wrap: wrap;
}

.db-stats-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.85rem;
}

.db-stats-item.total {
    font-weight: 600;
    color: #1e293b;
}

.db-stats-item.total i {
    color: #3b82f6;
}

.db-stats-count {
    font-size: 0.8rem;
    font-weight: 600;
    color: #1e293b;
    background: #f1f5f9;
    padding: 2px 8px;
    border-radius: 10px;
}

.db-stats-divider {
    width: 1px;
    height: 20px;
    background: #e2e8f0;
}

/* DB Body - Grouped */
.db-body-grouped {
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.db-system-group {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    overflow: hidden;
}

.db-system-header {
    padding: 14px 20px;
    background: linear-gradient(135deg, #475569 0%, #334155 100%);
    color: #fff;
}

.db-system-title {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 1rem;
    font-weight: 600;
}

.db-system-title i {
    font-size: 0.9rem;
    opacity: 0.8;
}

.db-system-count {
    background: rgba(255,255,255,0.2);
    padding: 2px 10px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 600;
}

.db-system-body {
    padding: 16px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 12px;
    background: #f8fafc;
}

/* Environment badges */
.db-card-env.env-prod {
    background: rgba(239, 68, 68, 0.3);
    color: #fff;
}
.db-card-env.env-prod1 {
    background: rgba(249, 115, 22, 0.3);
    color: #fff;
}
.db-card-env.env-stage {
    background: rgba(234, 179, 8, 0.3);
    color: #fff;
}
.db-card-env.env-dev {
    background: rgba(34, 197, 94, 0.3);
    color: #fff;
}
.db-card-env.env-etc {
    background: rgba(148, 163, 184, 0.3);
    color: #fff;
}

.db-card-comments {
    font-size: 0.7rem;
    color: #94a3b8;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 150px;
}

/* DB Body - flat (keep for compatibility) */
.db-body {
    padding: 20px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
    gap: 16px;
}

/* DB Card */
.db-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    overflow: hidden;
    cursor: pointer;
    transition: all 0.2s;
    border: 2px solid transparent;
}

.db-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.12);
    transform: translateY(-2px);
    border-color: #3b82f6;
}

.db-card-header {
    padding: 14px 16px;
    color: #fff;
    display: flex;
    align-items: center;
    gap: 12px;
}

.db-card-header.oracle { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); }
.db-card-header.mariadb { background: linear-gradient(135deg, #14b8a6 0%, #0d9488 100%); }
.db-card-header.mysql { background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); }
.db-card-header.postgresql { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
.db-card-header.mssql { background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); }
.db-card-header.tibero { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); }
.db-card-header.db2 { background: linear-gradient(135deg, #64748b 0%, #475569 100%); }
.db-card-header.sap_iq { background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%); }

.db-card-icon {
    width: 36px;
    height: 36px;
    border-radius: 8px;
    background: rgba(255,255,255,0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
}

.db-card-title {
    flex: 1;
    min-width: 0;
}

.db-card-name {
    font-size: 0.95rem;
    font-weight: 700;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.db-card-type {
    font-size: 0.7rem;
    opacity: 0.9;
    margin-top: 2px;
}

.db-card-env {
    padding: 3px 8px;
    border-radius: 12px;
    font-size: 0.65rem;
    font-weight: 600;
    text-transform: uppercase;
    background: rgba(255,255,255,0.2);
}

.db-card-body {
    padding: 14px 16px;
}

.db-card-info-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}

.db-card-info-item {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.db-card-info-item.full {
    grid-column: 1 / -1;
}

.db-card-info-label {
    font-size: 0.65rem;
    color: #94a3b8;
    text-transform: uppercase;
    font-weight: 600;
}

.db-card-info-value {
    font-size: 0.8rem;
    color: #334155;
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.db-card-info-value.empty {
    color: #cbd5e1;
    font-style: italic;
}

.db-card-footer {
    padding: 10px 16px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.db-card-system {
    font-size: 0.75rem;
    color: #64748b;
    display: flex;
    align-items: center;
    gap: 4px;
}

.db-card-actions {
    display: flex;
    gap: 6px;
}

.db-card-btn {
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 0.7rem;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 4px;
}

.db-card-btn.edit {
    background: #e0e7ff;
    color: #4f46e5;
}

.db-card-btn.edit:hover {
    background: #c7d2fe;
}

.db-card-btn.test {
    background: #dcfce7;
    color: #16a34a;
}

.db-card-btn.test:hover {
    background: #bbf7d0;
}

.db-card-btn.sql {
    background: #fef3c7;
    color: #d97706;
}

.db-card-btn.sql:hover {
    background: #fde68a;
}

/* Modal Styles */
.db-modal .modal-dialog {
    max-width: 600px;
}

.db-modal .modal-header {
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    color: #fff;
    border: none;
    padding: 16px 20px;
}

.db-modal .modal-header.modify {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.db-modal .modal-title {
    font-size: 1rem;
    font-weight: 600;
}

.db-modal .close {
    color: #fff;
    opacity: 0.8;
}

.db-modal .modal-body {
    padding: 20px;
}

.db-form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 16px;
}

.db-form-row.single {
    grid-template-columns: 1fr;
}

.db-form-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.db-form-label {
    font-size: 0.8rem;
    font-weight: 600;
    color: #374151;
}

.db-form-label .required {
    color: #ef4444;
}

.db-form-input, .db-form-select {
    padding: 10px 12px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    font-size: 0.85rem;
    transition: all 0.2s;
}

.db-form-input:focus, .db-form-select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
}

.db-form-input:read-only {
    background: #f1f5f9;
}

.db-modal .modal-footer {
    padding: 12px 20px;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
}

.btn-modal-cancel {
    padding: 8px 16px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #fff;
    color: #64748b;
    font-size: 0.85rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-modal-cancel:hover {
    background: #f1f5f9;
}

.btn-modal-save {
    padding: 8px 16px;
    border: none;
    border-radius: 8px;
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    color: #fff;
    font-size: 0.85rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-modal-save:hover {
    box-shadow: 0 2px 8px rgba(59,130,246,0.4);
}

.btn-modal-test {
    padding: 8px 16px;
    border: none;
    border-radius: 8px;
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: #fff;
    font-size: 0.85rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-modal-test:hover {
    box-shadow: 0 2px 8px rgba(16,185,129,0.4);
}

.btn-modal-delete {
    padding: 8px 16px;
    border: none;
    border-radius: 8px;
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    color: #fff;
    font-size: 0.85rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-modal-delete:hover {
    box-shadow: 0 2px 8px rgba(239,68,68,0.4);
}

/* Empty State */
.db-empty {
    grid-column: 1 / -1;
    padding: 60px 20px;
    text-align: center;
    color: #94a3b8;
}

.db-empty i {
    font-size: 3rem;
    margin-bottom: 16px;
    color: #cbd5e1;
}
</style>

<!-- Get userid for admin check -->
<sec:authentication property="principal.member.userid" var="currentUserId"/>

<!-- Begin Page Content -->
<div class="db-container" id="piidatabaselist">
    <!-- Header -->
    <div class="db-header">
        <div class="db-title">
            <i class="fas fa-database"></i>
            <spring:message code="memu.db_connection" text="DB Connection"/>
        </div>
        <div class="db-actions">
            <div class="db-search">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" placeholder="Search DB name, host..."
                       onkeyup="filterDatabases(this.value)">
            </div>
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <button type="button" data-oper='register' class="btn-action-register">
                    <i class="fas fa-plus"></i> <spring:message code="btn.register" text="Register"/>
                </button>
            </sec:authorize>
        </div>
    </div>

    <!-- Hidden Form -->
    <form style="display:none;" id="searchForm">
        <input type='hidden' name='pagenum' value='<c:out value="${pageMaker.cri.pagenum}"/>'>
        <input type='hidden' name='amount' value='<c:out value="${pageMaker.cri.amount}"/>'>
    </form>

    <!-- Statistics Bar -->
    <c:set var="oracleCount" value="0"/>
    <c:set var="mariadbCount" value="0"/>
    <c:set var="mysqlCount" value="0"/>
    <c:set var="postgresCount" value="0"/>
    <c:set var="otherCount" value="0"/>
    <c:forEach items="${list}" var="db">
        <c:choose>
            <c:when test="${db.dbtype eq 'ORACLE'}"><c:set var="oracleCount" value="${oracleCount + 1}"/></c:when>
            <c:when test="${db.dbtype eq 'MARIADB'}"><c:set var="mariadbCount" value="${mariadbCount + 1}"/></c:when>
            <c:when test="${db.dbtype eq 'MYSQL'}"><c:set var="mysqlCount" value="${mysqlCount + 1}"/></c:when>
            <c:when test="${db.dbtype eq 'POSTGRESQL'}"><c:set var="postgresCount" value="${postgresCount + 1}"/></c:when>
            <c:otherwise><c:set var="otherCount" value="${otherCount + 1}"/></c:otherwise>
        </c:choose>
    </c:forEach>

    <div class="db-stats-bar">
        <div class="db-stats-item total">
            <i class="fas fa-server"></i>
            <span>Total</span>
            <span class="db-stats-count">${fn:length(list)}</span>
        </div>
        <div class="db-stats-divider"></div>
        <c:if test="${oracleCount > 0}">
            <div class="db-stats-item">
                <span style="width:8px;height:8px;border-radius:50%;background:#ef4444;"></span>
                <span>Oracle</span>
                <span class="db-stats-count">${oracleCount}</span>
            </div>
        </c:if>
        <c:if test="${mariadbCount > 0}">
            <div class="db-stats-item">
                <span style="width:8px;height:8px;border-radius:50%;background:#14b8a6;"></span>
                <span>MariaDB</span>
                <span class="db-stats-count">${mariadbCount}</span>
            </div>
        </c:if>
        <c:if test="${mysqlCount > 0}">
            <div class="db-stats-item">
                <span style="width:8px;height:8px;border-radius:50%;background:#f97316;"></span>
                <span>MySQL</span>
                <span class="db-stats-count">${mysqlCount}</span>
            </div>
        </c:if>
        <c:if test="${postgresCount > 0}">
            <div class="db-stats-item">
                <span style="width:8px;height:8px;border-radius:50%;background:#3b82f6;"></span>
                <span>PostgreSQL</span>
                <span class="db-stats-count">${postgresCount}</span>
            </div>
        </c:if>
        <c:if test="${otherCount > 0}">
            <div class="db-stats-item">
                <span style="width:8px;height:8px;border-radius:50%;background:#64748b;"></span>
                <span>Other</span>
                <span class="db-stats-count">${otherCount}</span>
            </div>
        </c:if>
    </div>

    <!-- DB Body - Grouped by System -->
    <div class="db-body-grouped">
        <c:forEach items="${listsystem}" var="sys">
            <%-- Count DBs for this system --%>
            <c:set var="sysDbCount" value="0"/>
            <c:forEach items="${list}" var="db">
                <c:if test="${db.system eq sys.system_id}"><c:set var="sysDbCount" value="${sysDbCount + 1}"/></c:if>
            </c:forEach>

            <c:if test="${sysDbCount > 0}">
                <div class="db-system-group">
                    <div class="db-system-header">
                        <div class="db-system-title">
                            <i class="fas fa-sitemap"></i>
                            <span>${sys.system_name}</span>
                            <span class="db-system-count">${sysDbCount}</span>
                        </div>
                    </div>
                    <div class="db-system-body">
                        <%-- PRODUCTION --%>
                        <c:forEach items="${list}" var="piidatabase">
                            <c:if test="${piidatabase.system eq sys.system_id && piidatabase.env eq 'PRODUCTION'}">
                                <div class="db-card"
                                     data-db="<c:out value='${piidatabase.db}'/>"
                                     data-system="<c:out value='${piidatabase.system}'/>"
                                     data-env="<c:out value='${piidatabase.env}'/>"
                                     data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                     data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                     data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                     data-port="<c:out value='${piidatabase.port}'/>"
                                     data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                     data-id="<c:out value='${piidatabase.id}'/>"
                                     data-comments="<c:out value='${piidatabase.comments}'/>">
                                    <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                        <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                        <div class="db-card-title">
                                            <div class="db-card-name">${piidatabase.db}</div>
                                            <div class="db-card-type">${piidatabase.dbtype}</div>
                                        </div>
                                        <span class="db-card-env env-prod">PROD</span>
                                    </div>
                                    <div class="db-card-body">
                                        <div class="db-card-info-grid">
                                            <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                        </div>
                                    </div>
                                    <div class="db-card-footer">
                                        <span class="db-card-comments">${piidatabase.comments}</span>
                                        <div class="db-card-actions">
                                            <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                            <c:if test="${currentUserId eq 'admin'}">
                                                <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                            </c:if>
                                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                                <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                            </sec:authorize>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                        <%-- PRODUCTION-1 --%>
                        <c:forEach items="${list}" var="piidatabase">
                            <c:if test="${piidatabase.system eq sys.system_id && piidatabase.env eq 'PRODUCTION-1'}">
                                <div class="db-card"
                                     data-db="<c:out value='${piidatabase.db}'/>"
                                     data-system="<c:out value='${piidatabase.system}'/>"
                                     data-env="<c:out value='${piidatabase.env}'/>"
                                     data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                     data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                     data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                     data-port="<c:out value='${piidatabase.port}'/>"
                                     data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                     data-id="<c:out value='${piidatabase.id}'/>"
                                     data-comments="<c:out value='${piidatabase.comments}'/>">
                                    <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                        <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                        <div class="db-card-title">
                                            <div class="db-card-name">${piidatabase.db}</div>
                                            <div class="db-card-type">${piidatabase.dbtype}</div>
                                        </div>
                                        <span class="db-card-env env-prod1">PROD-1</span>
                                    </div>
                                    <div class="db-card-body">
                                        <div class="db-card-info-grid">
                                            <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                        </div>
                                    </div>
                                    <div class="db-card-footer">
                                        <span class="db-card-comments">${piidatabase.comments}</span>
                                        <div class="db-card-actions">
                                            <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                            <c:if test="${currentUserId eq 'admin'}">
                                                <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                            </c:if>
                                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                                <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                            </sec:authorize>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                        <%-- PRE-PRODUCTION (Staging) --%>
                        <c:forEach items="${list}" var="piidatabase">
                            <c:if test="${piidatabase.system eq sys.system_id && piidatabase.env eq 'PRE-PRODUCTION'}">
                                <div class="db-card"
                                     data-db="<c:out value='${piidatabase.db}'/>"
                                     data-system="<c:out value='${piidatabase.system}'/>"
                                     data-env="<c:out value='${piidatabase.env}'/>"
                                     data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                     data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                     data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                     data-port="<c:out value='${piidatabase.port}'/>"
                                     data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                     data-id="<c:out value='${piidatabase.id}'/>"
                                     data-comments="<c:out value='${piidatabase.comments}'/>">
                                    <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                        <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                        <div class="db-card-title">
                                            <div class="db-card-name">${piidatabase.db}</div>
                                            <div class="db-card-type">${piidatabase.dbtype}</div>
                                        </div>
                                        <span class="db-card-env env-stage">STAGE</span>
                                    </div>
                                    <div class="db-card-body">
                                        <div class="db-card-info-grid">
                                            <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                        </div>
                                    </div>
                                    <div class="db-card-footer">
                                        <span class="db-card-comments">${piidatabase.comments}</span>
                                        <div class="db-card-actions">
                                            <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                            <c:if test="${currentUserId eq 'admin'}">
                                                <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                            </c:if>
                                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                                <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                            </sec:authorize>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                        <%-- DEVELOPMENT --%>
                        <c:forEach items="${list}" var="piidatabase">
                            <c:if test="${piidatabase.system eq sys.system_id && piidatabase.env eq 'DEVELOPMENT'}">
                                <div class="db-card"
                                     data-db="<c:out value='${piidatabase.db}'/>"
                                     data-system="<c:out value='${piidatabase.system}'/>"
                                     data-env="<c:out value='${piidatabase.env}'/>"
                                     data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                     data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                     data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                     data-port="<c:out value='${piidatabase.port}'/>"
                                     data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                     data-id="<c:out value='${piidatabase.id}'/>"
                                     data-comments="<c:out value='${piidatabase.comments}'/>">
                                    <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                        <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                        <div class="db-card-title">
                                            <div class="db-card-name">${piidatabase.db}</div>
                                            <div class="db-card-type">${piidatabase.dbtype}</div>
                                        </div>
                                        <span class="db-card-env env-dev">DEV</span>
                                    </div>
                                    <div class="db-card-body">
                                        <div class="db-card-info-grid">
                                            <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                        </div>
                                    </div>
                                    <div class="db-card-footer">
                                        <span class="db-card-comments">${piidatabase.comments}</span>
                                        <div class="db-card-actions">
                                            <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                            <c:if test="${currentUserId eq 'admin'}">
                                                <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                            </c:if>
                                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                                <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                            </sec:authorize>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                        <%-- ETC (Others) --%>
                        <c:forEach items="${list}" var="piidatabase">
                            <c:if test="${piidatabase.system eq sys.system_id && piidatabase.env ne 'PRODUCTION' && piidatabase.env ne 'PRODUCTION-1' && piidatabase.env ne 'PRE-PRODUCTION' && piidatabase.env ne 'DEVELOPMENT'}">
                                <div class="db-card"
                                     data-db="<c:out value='${piidatabase.db}'/>"
                                     data-system="<c:out value='${piidatabase.system}'/>"
                                     data-env="<c:out value='${piidatabase.env}'/>"
                                     data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                     data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                     data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                     data-port="<c:out value='${piidatabase.port}'/>"
                                     data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                     data-id="<c:out value='${piidatabase.id}'/>"
                                     data-comments="<c:out value='${piidatabase.comments}'/>">
                                    <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                        <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                        <div class="db-card-title">
                                            <div class="db-card-name">${piidatabase.db}</div>
                                            <div class="db-card-type">${piidatabase.dbtype}</div>
                                        </div>
                                        <span class="db-card-env env-etc">${piidatabase.env}</span>
                                    </div>
                                    <div class="db-card-body">
                                        <div class="db-card-info-grid">
                                            <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                            <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                        </div>
                                    </div>
                                    <div class="db-card-footer">
                                        <span class="db-card-comments">${piidatabase.comments}</span>
                                        <div class="db-card-actions">
                                            <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                            <c:if test="${currentUserId eq 'admin'}">
                                                <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                            </c:if>
                                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                                <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                            </sec:authorize>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </c:forEach>

        <%-- DBs without system assignment --%>
        <c:set var="noSysCount" value="0"/>
        <c:forEach items="${list}" var="db">
            <c:set var="hasSystem" value="false"/>
            <c:forEach items="${listsystem}" var="sys">
                <c:if test="${db.system eq sys.system_id}"><c:set var="hasSystem" value="true"/></c:if>
            </c:forEach>
            <c:if test="${!hasSystem}"><c:set var="noSysCount" value="${noSysCount + 1}"/></c:if>
        </c:forEach>

        <c:if test="${noSysCount > 0}">
            <div class="db-system-group">
                <div class="db-system-header">
                    <div class="db-system-title">
                        <i class="fas fa-question-circle"></i>
                        <span>Unassigned</span>
                        <span class="db-system-count">${noSysCount}</span>
                    </div>
                </div>
                <div class="db-system-body">
                    <c:forEach items="${list}" var="piidatabase">
                        <c:set var="hasSystem" value="false"/>
                        <c:forEach items="${listsystem}" var="sys">
                            <c:if test="${piidatabase.system eq sys.system_id}"><c:set var="hasSystem" value="true"/></c:if>
                        </c:forEach>
                        <c:if test="${!hasSystem}">
                            <div class="db-card"
                                 data-db="<c:out value='${piidatabase.db}'/>"
                                 data-system="<c:out value='${piidatabase.system}'/>"
                                 data-env="<c:out value='${piidatabase.env}'/>"
                                 data-dbtype="<c:out value='${piidatabase.dbtype}'/>"
                                 data-dbuser="<c:out value='${piidatabase.dbuser}'/>"
                                 data-hostname="<c:out value='${piidatabase.hostname}'/>"
                                 data-port="<c:out value='${piidatabase.port}'/>"
                                 data-id-type="<c:out value='${piidatabase.id_type}'/>"
                                 data-id="<c:out value='${piidatabase.id}'/>"
                                 data-comments="<c:out value='${piidatabase.comments}'/>">
                                <div class="db-card-header ${fn:toLowerCase(piidatabase.dbtype)}">
                                    <div class="db-card-icon"><i class="fas fa-database"></i></div>
                                    <div class="db-card-title">
                                        <div class="db-card-name">${piidatabase.db}</div>
                                        <div class="db-card-type">${piidatabase.dbtype}</div>
                                    </div>
                                    <span class="db-card-env">
                                        <c:choose>
                                            <c:when test="${piidatabase.env eq 'PRODUCTION'}">PROD</c:when>
                                            <c:when test="${piidatabase.env eq 'PRODUCTION-1'}">PROD-1</c:when>
                                            <c:when test="${piidatabase.env eq 'PRE-PRODUCTION'}">STAGE</c:when>
                                            <c:when test="${piidatabase.env eq 'DEVELOPMENT'}">DEV</c:when>
                                            <c:otherwise>${piidatabase.env}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="db-card-body">
                                    <div class="db-card-info-grid">
                                        <div class="db-card-info-item"><span class="db-card-info-label">Host</span><span class="db-card-info-value">${piidatabase.hostname}</span></div>
                                        <div class="db-card-info-item"><span class="db-card-info-label">Port</span><span class="db-card-info-value">${piidatabase.port}</span></div>
                                        <div class="db-card-info-item"><span class="db-card-info-label">User</span><span class="db-card-info-value">${piidatabase.dbuser}</span></div>
                                        <div class="db-card-info-item"><span class="db-card-info-label">${piidatabase.id_type}</span><span class="db-card-info-value">${empty piidatabase.id ? '-' : piidatabase.id}</span></div>
                                    </div>
                                </div>
                                <div class="db-card-footer">
                                    <span class="db-card-comments">${piidatabase.comments}</span>
                                    <div class="db-card-actions">
                                        <button type="button" class="db-card-btn test" onclick="event.stopPropagation(); testConnection($(this).closest('.db-card'));"><i class="fas fa-plug"></i></button>
                                        <c:if test="${currentUserId eq 'admin'}">
                                            <button type="button" class="db-card-btn sql" onclick="event.stopPropagation(); openSqlManager('${piidatabase.db}');"><i class="fas fa-terminal"></i></button>
                                        </c:if>
                                        <sec:authorize access="hasRole('ROLE_ADMIN')">
                                            <button type="button" class="db-card-btn edit" onclick="event.stopPropagation(); openModifyModal($(this).closest('.db-card'));"><i class="fas fa-edit"></i></button>
                                        </sec:authorize>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <c:if test="${empty list}">
            <div class="db-empty">
                <i class="fas fa-database"></i>
                <div>No DB connections found</div>
                <div style="font-size: 0.85rem; margin-top: 8px;">Click "Register" to add a new connection</div>
            </div>
        </c:if>
    </div>
</div>

<!-- Register Modal -->
<div class="modal fade db-modal" id="registerModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-2"></i>Register DB Connection</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="registerForm">
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB Name <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="db" required
                                   onkeyup="this.value=this.value.toUpperCase()" placeholder="e.g. PROD_DB">
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">System</label>
                            <select class="db-form-select" name="system">
                                <option value="">Select System</option>
                                <c:forEach items="${listsystem}" var="sys">
                                    <option value="${sys.system_id}">${sys.system_name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB Type <span class="required">*</span></label>
                            <select class="db-form-select" name="dbtype">
                                <option value="ORACLE">Oracle</option>
                                <option value="MARIADB">MariaDB</option>
                                <option value="MYSQL">MySQL</option>
                                <option value="POSTGRESQL">PostgreSQL</option>
                                <option value="MSSQL">MSSQL</option>
                                <option value="TIBERO">Tibero</option>
                                <option value="DB2">DB2</option>
                                <option value="SAP_IQ">SAP IQ</option>
                            </select>
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Environment</label>
                            <select class="db-form-select" name="env">
                                <option value="PRODUCTION"><spring:message code="etc.productionenv" text="Production"/></option>
                                <option value="PRODUCTION-1"><spring:message code="etc.productionenv-1day" text="Production -1Day"/></option>
                                <option value="PRE-PRODUCTION"><spring:message code="etc.stagingenv" text="Staging"/></option>
                                <option value="DEVELOPMENT"><spring:message code="etc.devenv" text="Development"/></option>
                                <option value="ETC"><spring:message code="etc.etc" text="Others"/></option>
                            </select>
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">Hostname <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="hostname" required placeholder="e.g. 192.168.1.100">
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Port <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="port" required placeholder="e.g. 1521"
                                   onkeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB User <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="dbuser" required placeholder="Username">
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Password <span class="required">*</span></label>
                            <input type="password" class="db-form-input" name="pwd" required placeholder="Password">
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">ID Type</label>
                            <select class="db-form-select" name="id_type">
                                <option value="SID">SID</option>
                                <option value="SERVICENAME">Service Name</option>
                                <option value="DBNAME">DB Name</option>
                                <option value="SERVER">Server (SAP IQ)</option>
                            </select>
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">ID Value</label>
                            <input type="text" class="db-form-input" name="id" placeholder="SID or Service Name">
                        </div>
                    </div>
                    <div class="db-form-row single">
                        <div class="db-form-group">
                            <label class="db-form-label">Comments</label>
                            <input type="text" class="db-form-input" name="comments" placeholder="Description">
                        </div>
                    </div>
                    <input type="hidden" name="reguserid" value="<sec:authentication property='principal.member.userid'/>">
                    <input type="hidden" name="upduserid" value="<sec:authentication property='principal.member.userid'/>">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-test" id="btnRegisterTest">
                    <i class="fas fa-plug"></i> Test Connection
                </button>
                <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button type="button" class="btn-modal-save" id="btnRegisterSave">
                    <i class="fas fa-save"></i> Register
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modify Modal -->
<div class="modal fade db-modal" id="modifyModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header modify">
                <h5 class="modal-title"><i class="fas fa-edit mr-2"></i>Modify DB Connection</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <form id="modifyForm">
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB Name</label>
                            <input type="text" class="db-form-input" name="db" readonly>
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">System</label>
                            <select class="db-form-select" name="system">
                                <option value="">Select System</option>
                                <c:forEach items="${listsystem}" var="sys">
                                    <option value="${sys.system_id}">${sys.system_name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB Type <span class="required">*</span></label>
                            <select class="db-form-select" name="dbtype">
                                <option value="ORACLE">Oracle</option>
                                <option value="MARIADB">MariaDB</option>
                                <option value="MYSQL">MySQL</option>
                                <option value="POSTGRESQL">PostgreSQL</option>
                                <option value="MSSQL">MSSQL</option>
                                <option value="TIBERO">Tibero</option>
                                <option value="DB2">DB2</option>
                                <option value="SAP_IQ">SAP IQ</option>
                            </select>
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Environment</label>
                            <select class="db-form-select" name="env">
                                <option value="PRODUCTION"><spring:message code="etc.productionenv" text="Production"/></option>
                                <option value="PRODUCTION-1"><spring:message code="etc.productionenv-1day" text="Production -1Day"/></option>
                                <option value="PRE-PRODUCTION"><spring:message code="etc.stagingenv" text="Staging"/></option>
                                <option value="DEVELOPMENT"><spring:message code="etc.devenv" text="Development"/></option>
                                <option value="ETC"><spring:message code="etc.etc" text="Others"/></option>
                            </select>
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">Hostname <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="hostname" required placeholder="e.g. 192.168.1.100">
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Port <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="port" required placeholder="e.g. 1521"
                                   onkeyup="this.value=this.value.replace(/[^0-9]/g,'');">
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">DB User <span class="required">*</span></label>
                            <input type="text" class="db-form-input" name="dbuser" required placeholder="Username">
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">Password <small>(leave empty to keep)</small></label>
                            <input type="password" class="db-form-input" name="pwd" placeholder="New password">
                        </div>
                    </div>
                    <div class="db-form-row">
                        <div class="db-form-group">
                            <label class="db-form-label">ID Type</label>
                            <select class="db-form-select" name="id_type">
                                <option value="SID">SID</option>
                                <option value="SERVICENAME">Service Name</option>
                                <option value="DBNAME">DB Name</option>
                                <option value="SERVER">Server (SAP IQ)</option>
                            </select>
                        </div>
                        <div class="db-form-group">
                            <label class="db-form-label">ID Value</label>
                            <input type="text" class="db-form-input" name="id" placeholder="SID or Service Name">
                        </div>
                    </div>
                    <div class="db-form-row single">
                        <div class="db-form-group">
                            <label class="db-form-label">Comments</label>
                            <input type="text" class="db-form-input" name="comments" placeholder="Description">
                        </div>
                    </div>
                    <input type="hidden" name="upduserid" value="<sec:authentication property='principal.member.userid'/>">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </form>
            </div>
            <div class="modal-footer" style="justify-content: space-between;">
                <button type="button" class="btn-modal-delete" id="btnModifyDelete">
                    <i class="fas fa-trash-alt"></i> Delete
                </button>
                <div style="display: flex; gap: 8px;">
                    <button type="button" class="btn-modal-test" id="btnModifyTest">
                        <i class="fas fa-plug"></i> Test
                    </button>
                    <button type="button" class="btn-modal-cancel" data-dismiss="modal">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                    <button type="button" class="btn-modal-save" id="btnModifySave">
                        <i class="fas fa-save"></i> Save
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">
    $(function () {
        $("#menupath").html(Menupath + '<i class="fas fa-chevron-right" style="font-size: 18px; margin: 0 6px; color: #888;"></i>' + "<spring:message code='memu.db_connection' text='DB Connection'/>");
    });

    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        // Click on card (for admin: open modify modal)
        $('.db-card').on('click', function () {
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

        // Register save
        $('#btnRegisterSave').on('click', function () {
            var form = $('#registerForm');
            if (!validateForm(form, true)) return;

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piidatabase/register",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    closeModal('#registerModal');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Register test
        $('#btnRegisterTest').on('click', function () {
            testConnectionFromForm($('#registerForm'));
        });

        // Modify save
        $('#btnModifySave').on('click', function () {
            var form = $('#modifyForm');
            if (!validateForm(form, false)) return;

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piidatabase/modify",
                data: form.serialize(),
                dataType: "html",
                success: function (data) {
                    ingHide();
                    closeModal('#modifyModal');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });

        // Modify test
        $('#btnModifyTest').on('click', function () {
            testConnectionFromForm($('#modifyForm'));
        });

        // Modify delete
        $('#btnModifyDelete').on('click', function () {
            var form = $('#modifyForm');
            var db = form.find('[name="db"]').val();

            if (!confirm('<spring:message code="msg.removeconfirm" text="Are you sure you want to delete"/> ' + db + '?')) {
                return;
            }

            ingShow();
            $.ajax({
                type: "POST",
                url: "/piidatabase/remove",
                data: { db: db, "${_csrf.parameterName}": "${_csrf.token}" },
                dataType: "html",
                success: function (data) {
                    ingHide();
                    closeModal('#modifyModal');
                    $("#GlobalSuccessMsgModal").modal("show");
                    setTimeout(function() { searchAction(); }, 500);
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });
    });

    function openModifyModal(card) {
        var form = $('#modifyForm');
        form[0].reset();
        form.find('[name="db"]').val(card.data('db') || '');
        form.find('[name="system"]').val(card.data('system') || '');
        form.find('[name="env"]').val(card.data('env') || 'PRODUCTION');
        form.find('[name="dbtype"]').val(card.data('dbtype') || 'ORACLE');
        form.find('[name="hostname"]').val(card.data('hostname') || '');
        form.find('[name="port"]').val(card.data('port') || '');
        form.find('[name="dbuser"]').val(card.data('dbuser') || '');
        form.find('[name="id_type"]').val(card.data('id-type') || 'SID');
        form.find('[name="id"]').val(card.data('id') || '');
        form.find('[name="comments"]').val(card.data('comments') || '');
        $('#modifyModal').modal('show');
    }

    function validateForm(form, isRegister) {
        var dbtype = form.find('[name="dbtype"]').val();
        var id = form.find('[name="id"]').val();
        var id_type = form.find('[name="id_type"]').val();
        var db = form.find('[name="db"]').val();
        var hostname = form.find('[name="hostname"]').val();
        var port = form.find('[name="port"]').val();
        var dbuser = form.find('[name="dbuser"]').val();
        var pwd = form.find('[name="pwd"]').val();

        if (!db) { alert('DB Name is required'); form.find('[name="db"]').focus(); return false; }
        if (!hostname) { alert('Hostname is required'); form.find('[name="hostname"]').focus(); return false; }
        if (!port) { alert('Port is required'); form.find('[name="port"]').focus(); return false; }
        if (!dbuser) { alert('DB User is required'); form.find('[name="dbuser"]').focus(); return false; }
        if (isRegister && !pwd) { alert('Password is required'); form.find('[name="pwd"]').focus(); return false; }

        if (dbtype === 'ORACLE') {
            if (id_type !== 'SID' && id_type !== 'SERVICENAME') {
                alert('SID or Service Name is required for Oracle');
                form.find('[name="id_type"]').val('SERVICENAME').focus();
                return false;
            }
            if (!id) { alert('SID or Service Name value is required for Oracle'); form.find('[name="id"]').focus(); return false; }
        }

        if ((dbtype === 'MYSQL' || dbtype === 'MARIADB' || dbtype === 'DB2')) {
            if (id_type !== 'DBNAME') {
                form.find('[name="id_type"]').val('DBNAME');
            }
            if (!id) { alert('DBNAME value is required for ' + dbtype); form.find('[name="id"]').focus(); return false; }
        }

        return true;
    }

    function testConnection(card) {
        var data = {
            db: card.data('db'),
            dbtype: card.data('dbtype'),
            hostname: card.data('hostname'),
            port: card.data('port'),
            dbuser: card.data('dbuser'),
            pwd: '',
            id_type: card.data('id-type'),
            id: card.data('id')
        };
        doConnectionTest(data);
    }

    function testConnectionFromForm(form) {
        var data = {
            db: form.find('[name="db"]').val(),
            dbtype: form.find('[name="dbtype"]').val(),
            hostname: form.find('[name="hostname"]').val(),
            port: form.find('[name="port"]').val(),
            dbuser: form.find('[name="dbuser"]').val(),
            pwd: form.find('[name="pwd"]').val(),
            id_type: form.find('[name="id_type"]').val(),
            id: form.find('[name="id"]').val()
        };

        if (!data.hostname || !data.port || !data.dbuser) {
            alert('Please fill in Hostname, Port, and DB User');
            return;
        }

        doConnectionTest(data);
    }

    function doConnectionTest(data) {
        ingShow();
        $.ajax({
            type: "POST",
            url: "/piidatabase/connectiontest",
            dataType: "text",
            data: JSON.stringify(data),
            contentType: "application/json; charset=UTF-8",
            beforeSend: function (xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function (result) {
                ingHide();
                $("#messagemodalbody").html('<div class="text-success"><i class="fas fa-check-circle mr-2"></i>' + result + '</div>');
                $("#messagemodal").modal("show");
            },
            error: function (request, error) {
                ingHide();
                $("#errormodalbody").html("<spring:message code='msg.connectiontesterror' text='Connection failed! Check the connection information.'/>");
                $("#errormodal").modal("show");
            }
        });
    }

    function filterDatabases(query) {
        query = query.toLowerCase();
        $('.db-card').each(function() {
            var db = ($(this).data('db') || '').toString().toLowerCase();
            var hostname = ($(this).data('hostname') || '').toString().toLowerCase();
            var system = ($(this).data('system') || '').toString().toLowerCase();
            var dbtype = ($(this).data('dbtype') || '').toString().toLowerCase();
            var comments = ($(this).data('comments') || '').toString().toLowerCase();

            if (db.includes(query) || hostname.includes(query) || system.includes(query) ||
                dbtype.includes(query) || comments.includes(query)) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }

    function closeModal(selector) {
        $(selector).modal('hide');
        $('.modal-backdrop').remove();
        $('body').removeClass('modal-open').css('padding-right', '');
    }

    function openSqlManager(db) {
        window.open('/index?page=exeupdate&db=' + encodeURIComponent(db), '_blank');
    }

    function searchAction() {
        ingShow();
        $.ajax({
            type: "GET",
            url: "/piidatabase/list?pagenum=1&amount=100",
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

    movePage = function (pageNo) {
        searchAction();
    }
</script>
