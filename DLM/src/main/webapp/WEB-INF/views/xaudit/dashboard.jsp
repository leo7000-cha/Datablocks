<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko"><head>
<meta charset="UTF-8"/>
<title>X-Audit 대시보드</title>
<style>
body { margin:0; font-family:-apple-system,"Segoe UI","Malgun Gothic",sans-serif; background:#f8fafc; color:#0f172a; }
.xp-wrap { padding:24px; }
.xp-title { font-size:22px; font-weight:700; margin:0 0 16px; }
.xp-title small { font-size:13px; color:#64748b; font-weight:400; margin-left:10px; }
.xp-cards { display:grid; grid-template-columns:repeat(6,1fr); gap:14px; margin-bottom:20px; }
.xp-card { background:#fff; border:1px solid #e2e8f0; border-radius:10px; padding:16px; box-shadow:0 1px 2px rgba(0,0,0,.04); }
.xp-card h4 { font-size:11px; color:#64748b; font-weight:500; margin:0 0 6px; letter-spacing:.5px; text-transform:uppercase; }
.xp-card .v { font-size:26px; font-weight:700; }
.xp-card.pii .v { color:#dc2626; }
.xp-card.fail .v { color:#f97316; }
.xp-row { display:grid; grid-template-columns:2fr 1fr 1fr; gap:16px; }
.xp-panel { background:#fff; border:1px solid #e2e8f0; border-radius:10px; padding:16px; }
.xp-panel h3 { font-size:14px; font-weight:600; margin:0 0 12px; }
.xp-panel table { width:100%; border-collapse:collapse; font-size:13px; }
.xp-panel th { text-align:left; padding:6px 8px; color:#64748b; font-weight:500; border-bottom:1px solid #e2e8f0; }
.xp-panel td { padding:6px 8px; border-bottom:1px solid #f1f5f9; }
.xp-hourly { display:flex; align-items:flex-end; gap:3px; height:120px; margin-top:8px; }
.xp-bar { flex:1; background:linear-gradient(180deg,#3b82f6,#60a5fa); border-radius:3px 3px 0 0; min-height:2px; position:relative; }
.xp-bar span { position:absolute; top:-16px; left:0; right:0; text-align:center; font-size:10px; color:#475569; }
.xp-hours { display:flex; gap:3px; margin-top:4px; font-size:10px; color:#94a3b8; }
.xp-hours div { flex:1; text-align:center; }
.xp-ctl { display:flex; gap:10px; align-items:center; margin-bottom:14px; }
.xp-ctl input { padding:7px 10px; border:1px solid #cbd5e1; border-radius:6px; font-size:13px; }
.xp-ctl button { padding:7px 14px; background:#0f172a; color:#fff; border:0; border-radius:6px; font-size:13px; cursor:pointer; }
.xp-ctl a { text-decoration:none; color:#2563eb; font-size:13px; }
.xp-ctl .sp { flex:1; }
</style></head><body>
<div class="xp-wrap">
    <h1 class="xp-title">X-Audit 대시보드<small>처리계(WAS) → SDK 수집 · ${date}</small></h1>

    <div class="xp-ctl">
        <form method="get" action="/xaudit/dashboard" style="display:flex;gap:8px;">
            <input type="text" name="date" value="${date}" placeholder="YYYYMMDD" maxlength="8"/>
            <button type="submit">조회</button>
        </form>
        <div class="sp"></div>
        <a href="/xaudit/access">접속기록 &rarr;</a>
        <a href="/xaudit/sql">SQL 기록 &rarr;</a>
    </div>

    <div class="xp-cards">
        <div class="xp-card"><h4>접속 요청</h4><div class="v">${counts.access_cnt != null ? counts.access_cnt : 0}</div></div>
        <div class="xp-card"><h4>SQL 실행</h4><div class="v">${counts.sql_cnt != null ? counts.sql_cnt : 0}</div></div>
        <div class="xp-card pii"><h4>PII 탐지 SQL</h4><div class="v">${counts.pii_cnt != null ? counts.pii_cnt : 0}</div></div>
        <div class="xp-card"><h4>고유 사용자</h4><div class="v">${counts.user_cnt != null ? counts.user_cnt : 0}</div></div>
        <div class="xp-card"><h4>연동 처리계</h4><div class="v">${counts.service_cnt != null ? counts.service_cnt : 0}</div></div>
        <div class="xp-card fail"><h4>실패 요청</h4><div class="v">${counts.fail_cnt != null ? counts.fail_cnt : 0}</div></div>
    </div>

    <div class="xp-row">
        <div class="xp-panel">
            <h3>시간대별 접속 추이</h3>
            <c:set var="maxCnt" value="1"/>
            <c:forEach var="h" items="${hourly}">
                <c:if test="${h.cnt > maxCnt}"><c:set var="maxCnt" value="${h.cnt}"/></c:if>
            </c:forEach>
            <div class="xp-hourly">
                <c:forEach var="i" begin="0" end="23">
                    <c:set var="cnt" value="0"/>
                    <c:forEach var="h" items="${hourly}">
                        <c:if test="${h.hour == i}"><c:set var="cnt" value="${h.cnt}"/></c:if>
                    </c:forEach>
                    <div class="xp-bar" style="height:${(cnt*100)/maxCnt}%"><span>${cnt}</span></div>
                </c:forEach>
            </div>
            <div class="xp-hours">
                <c:forEach var="i" begin="0" end="23"><div>${i}</div></c:forEach>
            </div>
        </div>

        <div class="xp-panel">
            <h3>처리계별 요청</h3>
            <table>
                <thead><tr><th>처리계</th><th style="text-align:right">건수</th></tr></thead>
                <tbody>
                <c:forEach var="s" items="${services}">
                    <tr><td>${s.name}</td><td style="text-align:right">${s.cnt}</td></tr>
                </c:forEach>
                <c:if test="${empty services}"><tr><td colspan="2" style="color:#94a3b8;">데이터 없음</td></tr></c:if>
                </tbody>
            </table>
        </div>

        <div class="xp-panel">
            <h3>PII 탐지 상위</h3>
            <table>
                <thead><tr><th>유형</th><th style="text-align:right">건수</th></tr></thead>
                <tbody>
                <c:forEach var="p" items="${piiDist}">
                    <tr><td>${p.pii}</td><td style="text-align:right">${p.cnt}</td></tr>
                </c:forEach>
                <c:if test="${empty piiDist}"><tr><td colspan="2" style="color:#94a3b8;">탐지 없음</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body></html>
