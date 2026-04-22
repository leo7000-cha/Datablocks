<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko"><head>
<meta charset="UTF-8"/>
<title>X-Audit SQL 기록</title>
<style>
body { margin:0; font-family:-apple-system,"Segoe UI","Malgun Gothic",sans-serif; background:#f8fafc; color:#0f172a; }
.xp-wrap { padding:24px; }
.xp-title { font-size:20px; font-weight:700; margin:0 0 16px; }
.xp-title small { font-size:13px; color:#64748b; font-weight:400; margin-left:10px; }
.xp-bar { display:flex; gap:8px; margin-bottom:14px; flex-wrap:wrap; }
.xp-bar input { padding:7px 10px; border:1px solid #cbd5e1; border-radius:6px; font-size:13px; min-width:140px; }
.xp-bar button { padding:7px 14px; background:#0f172a; color:#fff; border:0; border-radius:6px; font-size:13px; cursor:pointer; }
.xp-bar a { padding:7px 12px; text-decoration:none; color:#2563eb; font-size:13px; border:1px solid #cbd5e1; border-radius:6px; background:#fff; }
table.xp-tab { width:100%; background:#fff; border-collapse:collapse; border:1px solid #e2e8f0; border-radius:10px; overflow:hidden; font-size:13px; table-layout:fixed; }
.xp-tab th { background:#f1f5f9; padding:10px; text-align:left; font-weight:600; border-bottom:1px solid #e2e8f0; color:#475569; }
.xp-tab td { padding:9px 10px; border-bottom:1px solid #f1f5f9; vertical-align:top; word-wrap:break-word; }
.xp-tab tr:hover { background:#f8fafc; }
.xp-sql { font-family:"SF Mono","Consolas",monospace; font-size:12px; color:#0f172a; white-space:pre-wrap; max-height:80px; overflow:auto; }
.xp-pill { display:inline-block; padding:2px 8px; border-radius:12px; font-size:11px; font-weight:600; }
.xp-sel { background:#dbeafe; color:#1e40af; }
.xp-ins { background:#dcfce7; color:#166534; }
.xp-upd { background:#fef3c7; color:#92400e; }
.xp-del { background:#fee2e2; color:#991b1b; }
.xp-pii { background:#fef2f2; color:#dc2626; font-weight:700; }
.xp-foot { display:flex; justify-content:space-between; align-items:center; margin-top:12px; font-size:13px; color:#64748b; }
.xp-pg a, .xp-pg span { display:inline-block; padding:5px 10px; border:1px solid #cbd5e1; border-radius:6px; margin:0 2px; text-decoration:none; color:#1e293b; background:#fff; }
.xp-pg span.active { background:#0f172a; color:#fff; border-color:#0f172a; }
</style></head><body>
<div class="xp-wrap">
    <h1 class="xp-title">X-Audit SQL 실행기록<small>총 ${total} 건</small></h1>

    <form method="get" action="/xaudit/sql" class="xp-bar">
        <input type="text" name="search1" value="${pageMaker.cri.search1}" placeholder="사용자 ID"/>
        <input type="text" name="search2" value="${pageMaker.cri.search2}" placeholder="SQL 타입 (SELECT/UPDATE...)"/>
        <input type="text" name="search3" value="${pageMaker.cri.search3}" placeholder="PII 유형 (JUMIN/CARD...)"/>
        <input type="text" name="search7" value="${pageMaker.cri.search7}" placeholder="시작 YYYY-MM-DD HH:mm"/>
        <input type="text" name="search8" value="${pageMaker.cri.search8}" placeholder="종료"/>
        <input type="hidden" name="pagenum" value="1"/>
        <button type="submit">검색</button>
        <a href="/xaudit/dashboard">대시보드</a>
        <a href="/xaudit/access">접속기록</a>
    </form>

    <table class="xp-tab">
        <colgroup>
            <col style="width:130px"/><col style="width:75px"/><col style="width:90px"/>
            <col/><col style="width:70px"/><col style="width:60px"/><col style="width:90px"/>
        </colgroup>
        <thead><tr>
            <th>실행 시각</th><th>타입</th><th>사용자</th>
            <th>SQL (요약)</th><th>영향행</th><th>ms</th><th>PII</th>
        </tr></thead>
        <tbody>
        <c:forEach var="r" items="${list}">
            <tr>
                <td>${fn:substring(r.accessTime,0,19)}</td>
                <td>
                    <c:choose>
                        <c:when test="${r.sqlType=='SELECT'}"><span class="xp-pill xp-sel">SEL</span></c:when>
                        <c:when test="${r.sqlType=='INSERT'}"><span class="xp-pill xp-ins">INS</span></c:when>
                        <c:when test="${r.sqlType=='UPDATE'}"><span class="xp-pill xp-upd">UPD</span></c:when>
                        <c:when test="${r.sqlType=='DELETE'}"><span class="xp-pill xp-del">DEL</span></c:when>
                        <c:otherwise>${r.sqlType}</c:otherwise>
                    </c:choose>
                </td>
                <td>${r.userId}</td>
                <td>
                    <div class="xp-sql">${fn:escapeXml(r.sqlText)}</div>
                    <c:if test="${not empty r.reqId}">
                        <a href="/xaudit/detail/${r.reqId}" style="font-size:11px;color:#2563eb;text-decoration:none;">요청 전체 &rarr;</a>
                    </c:if>
                </td>
                <td style="text-align:right;">${r.affectedRows}</td>
                <td style="text-align:right;">${r.durationMs}</td>
                <td>
                    <c:if test="${not empty r.piiDetected}">
                        <span class="xp-pill xp-pii">${r.piiDetected}</span>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty list}">
            <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:40px;">데이터 없음</td></tr>
        </c:if>
        </tbody>
    </table>

    <div class="xp-foot">
        <span>페이지 ${pageMaker.cri.pagenum} / ${pageMaker.endPage == 0 ? 1 : pageMaker.endPage}</span>
        <div class="xp-pg">
            <c:if test="${pageMaker.prev}"><a href="?pagenum=${pageMaker.startPage-1}">&laquo;</a></c:if>
            <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                <c:choose>
                    <c:when test="${pageMaker.cri.pagenum == num}"><span class="active">${num}</span></c:when>
                    <c:otherwise><a href="?pagenum=${num}&search1=${pageMaker.cri.search1}&search2=${pageMaker.cri.search2}&search3=${pageMaker.cri.search3}">${num}</a></c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${pageMaker.next}"><a href="?pagenum=${pageMaker.endPage+1}">&raquo;</a></c:if>
        </div>
    </div>
</div>
</body></html>
