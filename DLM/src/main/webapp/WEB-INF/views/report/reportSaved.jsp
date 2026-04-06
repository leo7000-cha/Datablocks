<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>보고서 저장 결과</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 40px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        td, th { border: 1px solid #ccc; padding: 10px; }
        th { background-color: #f0f0f0; }
        .result { margin-bottom: 30px; font-size: 18px; color: green; }
        .btn-box { margin-top: 30px; }
    </style>
</head>
<body>
<h2>${form.form_name} 저장 결과</h2>

<div class="result">
    저장 결과: <strong>${result}</strong>
</div>

<table>
    <c:forEach var="entry" items="${data}">
        <tr>
            <th style="width: 30%">${entry.key}</th>
            <td>${entry.value}</td>
        </tr>
    </c:forEach>
</table>

<div class="btn-box">
    <a href="/report/view?srvyId=${data.srvyId}&formName=${data.formName}">📄 PDF로 보기</a>
</div>
</body>
</html>
