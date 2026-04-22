<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko"><head>
<meta charset="UTF-8"/>
<title>X-Audit 요청 상세</title>
<style>
body { margin:0; font-family:-apple-system,"Segoe UI","Malgun Gothic",sans-serif; background:#f8fafc; color:#0f172a; }
.xp-wrap { padding:24px; }
.xp-title { font-size:20px; font-weight:700; margin:0 0 12px; }
.xp-title small { font-size:12px; color:#64748b; font-weight:400; margin-left:10px; font-family:"SF Mono",Consolas,monospace; }
.xp-back { display:inline-block; margin-bottom:14px; color:#2563eb; text-decoration:none; font-size:13px; }
.xp-card { background:#fff; border:1px solid #e2e8f0; border-radius:10px; padding:16px; margin-bottom:12px; }
.xp-head { display:grid; grid-template-columns:repeat(6,1fr); gap:10px; }
.xp-head .f { display:flex; flex-direction:column; }
.xp-head .f label { font-size:11px; color:#64748b; text-transform:uppercase; letter-spacing:.5px; }
.xp-head .f span { font-size:14px; font-weight:600; }
.xp-row-sql { border-left:4px solid #3b82f6; padding:10px 14px; background:#fff; border:1px solid #e2e8f0; border-radius:6px; margin:8px 0; }
.xp-row-sql.pii { border-left-color:#dc2626; }
.xp-meta { display:flex; gap:14px; font-size:12px; color:#64748b; margin-bottom:6px; }
.xp-meta b { color:#0f172a; }
.xp-sql { font-family:"SF Mono",Consolas,monospace; font-size:12px; background:#0f172a; color:#f1f5f9; padding:10px; border-radius:6px; white-space:pre-wrap; overflow-x:auto; }
.xp-bind { font-family:"SF Mono",Consolas,monospace; font-size:11px; background:#f1f5f9; color:#475569; padding:6px 10px; border-radius:4px; margin-top:6px; }
.xp-pill { display:inline-block; padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; }
.xp-pii-pill { background:#fef2f2; color:#dc2626; }
</style></head><body>
<div class="xp-wrap">
    <a class="xp-back" href="/xaudit/access">&larr; 접속기록으로</a>
    <h1 class="xp-title">요청 상세<small>reqId=${reqId}</small></h1>

    <c:choose>
        <c:when test="${empty sqls}">
            <div class="xp-card" style="color:#94a3b8;text-align:center;padding:40px;">이 요청에 실행된 SQL이 없습니다.</div>
        </c:when>
        <c:otherwise>
            <c:set var="first" value="${sqls[0]}"/>
            <div class="xp-card">
                <div class="xp-head">
                    <div class="f"><label>처리계</label><span>${first.serviceName}</span></div>
                    <div class="f"><label>사용자</label><span>${first.userId} / ${first.userName}</span></div>
                    <div class="f"><label>IP</label><span>${first.clientIp}</span></div>
                    <div class="f"><label>메뉴</label><span>${first.menuId}</span></div>
                    <div class="f"><label>URI</label><span style="word-break:break-all;">${first.uri}</span></div>
                    <div class="f"><label>SQL 개수</label><span>${fn:length(sqls)}</span></div>
                </div>
            </div>

            <c:forEach var="s" items="${sqls}" varStatus="st">
                <div class="xp-row-sql ${not empty s.piiDetected ? 'pii' : ''}">
                    <div class="xp-meta">
                        <span>#${st.count}</span>
                        <span><b>${s.sqlType}</b></span>
                        <span>${fn:substring(s.accessTime,0,23)}</span>
                        <span>소요 <b>${s.durationMs}</b> ms</span>
                        <span>영향행 <b>${s.affectedRows}</b></span>
                        <c:if test="${not empty s.piiDetected}"><span class="xp-pill xp-pii-pill">PII: ${s.piiDetected}</span></c:if>
                        <span style="margin-left:auto;opacity:.6;">sqlId: ${s.sqlId}</span>
                    </div>
                    <div class="xp-sql">${fn:escapeXml(s.sqlText)}</div>
                    <c:if test="${not empty s.bindParams}">
                        <div class="xp-bind">bind: ${fn:escapeXml(s.bindParams)}</div>
                    </c:if>
                    <c:if test="${not empty s.errorMessage}">
                        <div class="xp-bind" style="background:#fee2e2;color:#991b1b;">error: ${fn:escapeXml(s.errorMessage)}</div>
                    </c:if>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>
</body></html>
