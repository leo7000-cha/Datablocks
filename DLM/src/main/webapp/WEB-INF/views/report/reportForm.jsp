<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>${form.form_name}</title>
    <style>
        table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
        th, td { border: 1px solid #ccc; padding: 8px; }
        th { background: #f5f5f5; }
        input, select, textarea { width: 100%; box-sizing: border-box; padding: 5px; }
    </style>
</head>
<body>
<h2>${form.form_name}</h2>

<c:set var="inputValues" value="${data}" />

<form style="margin: 0; padding: 0;" action="/report/save" method="post">

    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    <div style="display: flex; gap: 20px; align-items: center;">
        <label for="srvyId">설문 ID</label>
        <input type="text" id="srvyId" name="srvyId" STYLE="width: 300PX;"
               value="${fn:trim(param.srvyId != null ? param.srvyId : '')}" />

        <label for="formName">보고서 양식</label>
        <input type="text" id="formName" name="formName" STYLE="width: 300PX;"
               value="${fn:trim(form.form_name)}" />

        <button type="submit">저장</button>
    </div>

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
                            </c:when>
                            <c:otherwise>
                                <td colspan="${field.colspan}" style="text-align: ${field.align != null ? field.align : 'left'};">
                            </c:otherwise>
                        </c:choose>

                        <c:choose>

                            <c:when test="${field.type eq 'label'}">
                                <span>${fn:trim(field.label != null ? field.label : field.value)}</span>
                            </c:when>

                            <c:when test="${field.type eq 'text' || field.type eq 'amt'}">
                                <input type="text" name="${field.name}"
                                       value="${fn:trim(inputValues[field.name] != null ? inputValues[field.name] : field.value)}"
                                       style="${field.type eq 'amt' ? 'text-align:right;' : ''}"
                                       oninput="${field.type eq 'amt' ? 'formatCurrency(this)' : ''}" />
                            </c:when>

                            <c:when test="${field.type eq 'textarea'}">
                                <textarea name="${field.name}" rows="${field.rows != null ? field.rows : 4}">
<c:out value="${fn:trim(inputValues[field.name] != null ? inputValues[field.name] : field.value)}" />
                                </textarea>
                            </c:when>

                            <c:when test="${field.type eq 'select'}">
                                <select name="${field.name}">
                                    <c:forEach var="opt" items="${field.options}">
                                        <option value="${fn:trim(opt)}"
                                            ${fn:trim(opt) eq fn:trim(inputValues[field.name]) ? 'selected' : ''}>
                                                ${fn:trim(opt)}
                                        </option>
                                    </c:forEach>
                                </select>
                            </c:when>
                        </c:choose>

                        <c:choose>
                            <c:when test="${field.tag eq 'th'}"></th>
                            </c:when>
                            <c:otherwise></td>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </tr>
            </c:forEach>
        </table>
    </c:forEach>


</form>

<script>
    function formatCurrency(input) {
        const value = input.value.replace(/[^\d]/g, '');
        if (value) {
            input.value = parseInt(value, 10).toLocaleString();
        } else {
            input.value = '';
        }
    }
</script>
</body>
</html>
