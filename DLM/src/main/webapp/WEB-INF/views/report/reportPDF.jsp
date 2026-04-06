<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<html>
<head>
    <meta charset="UTF-8" />
    <title>${form.form_name}</title>
    <style>
        body { font-family: NanumGothic; font-size: 10pt;  /* 인쇄 최적화용 */ padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        td, th { border: 1px solid #ccc; padding: 8px; vertical-align: top; }
        th { background-color: #f0f0f0; }

        @media print {
            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>
<div class="no-print" style="text-align: center; margin-top: 40px;">
    <h2>📄 ${form.form_name} [${data.srvyId}] 출력 미리보기</h2>
    <form style="margin: 0; padding: 0;" method="get" action="/report/print" style="display: inline-block; padding: 9px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">
        <input type="hidden" name="srvyId" value="${data.srvyId}" />
        <input type="hidden" name="formName" value="${form.form_name}" />
        <button type="submit" style="background: none; border: none; color: white; cursor: pointer;">📄 PDF 출력</button>
    </form>
</div>

<c:set var="inputValues" value="${data}" />
<c:forEach var="section" items="${form.sections}">
    <br/>
    <h3>${section.title}</h3>
    <table>
        <c:if test="${not empty section.colwidths}">
            <colgroup>
                <c:forEach var="w" items="${section.colwidths}">
                    <col style="width: ${w};" />
                </c:forEach>
            </colgroup>
        </c:if>
        <c:forEach var="row" items="${section.rows}">
            <tr>
                <c:forEach var="field" items="${row.fields}">
                    <c:choose>
                        <c:when test="${field.tag eq 'th'}">
                            <th colspan="${field.colspan}" style="text-align: ${field.align != null ? field.align : 'left'};">
                                <c:choose>
                                    <c:when test="${field.type eq 'label'}">
                                        <span>${field.label != null ? field.label : field.value}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>${inputValues[field.name] != null ? inputValues[field.name] : field.value}</span>
                                    </c:otherwise>
                                </c:choose>
                            </th>
                        </c:when>
                        <c:otherwise>
                            <td colspan="${field.colspan}" style="text-align: ${field.align != null ? field.align : 'left'};">
                                <c:choose>
                                    <c:when test="${field.type eq 'label'}">
                                        <span>${field.label != null ? field.label : field.value}</span>
                                    </c:when>
                                    <c:when test="${field.type eq 'textarea'}">
                                        <div style="white-space: pre-line; min-height: ${field.rows * 20}px;">
                                                ${inputValues[field.name] != null ? inputValues[field.name] : field.value}
                                        </div>
                                    </c:when>
                                    <c:when test="${field.type eq 'amt'}">
                    <span style="text-align: right; display: inline-block; width: 100%;">
                            ${inputValues[field.name]}
                    </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>${inputValues[field.name] != null ? inputValues[field.name] : field.value}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </tr>
        </c:forEach>
    </table>
</c:forEach>
</body>
</html>
