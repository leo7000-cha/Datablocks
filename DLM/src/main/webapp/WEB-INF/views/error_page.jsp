<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ page session="false" import="java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Error page</title>
</head>
<body>

<%--   <h4><c:out value="${exception.getMessage()}"></c:out></h4>

  <ul>
   <c:forEach items="${exception.getStackTrace() }" var="stack">
     <li><c:out value="${stack}"></c:out></li>
   </c:forEach>
  </ul> --%>
	<c:if test="${requestScope['javax.servlet.error.status_code'] == 400}">
		<p>잘못 된 요청입니다.</p>    
	</c:if>	
	
	<c:if test="${requestScope['javax.servlet.error.status_code'] == 404}">
		<p>요청하신 페이지를 찾을 수 없습니다.</p>    
	</c:if>
	
	<c:if test="${requestScope['javax.servlet.error.status_code'] == 405}">
		<p>요청된 메소드가 허용되지 않습니다.</p>    
	</c:if>
	
	<c:if test="${requestScope['javax.servlet.error.status_code'] == 500}">
		<p>서버에 오류가 발생하여 요청을 수행할 수 없습니다.</p>
	</c:if>
	
	<c:if test="${requestScope['javax.servlet.error.status_code'] == 503}">
		<p>서비스를 사용할 수 없습니다.</p>
	</c:if>
	
	<%--<a href="/">HOME</a>--%>
</body>
</html>
