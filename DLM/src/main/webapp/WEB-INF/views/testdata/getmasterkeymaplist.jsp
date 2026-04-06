<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<link rel="stylesheet" href="/resources/jquery-ui-themes-1.12.1/themes/base/jquery-ui.css">
<script type="text/javascript" src="resources/jquery-ui-1.12.1/jquery-ui.js"></script>

<div class="m-0" style="height:630px">

    <!-- grid-template-columns: 20% 80%  ; -->
    <div id="steps" class="m-0" style="overflow:hidden;width:100%">
        <!-- grid-template-columns: 20%  ; -->
        <div class="m-0 card shadow border" style="overflow:hidden;height:625px;">

        <!-- grid-template-columns:  80%  ; -->
        <div class="m-1 p-1 card shadow border">
            <div class="tableWrapper p-0" style="height:610px;">
                <table id="masterkeyListTable" class="table table-sm table-hover">

                    <thead>
                    <tr>
                        <th class="th-get"><spring:message code="etc.appliedcustno" text="Applied Customer Number"/></th>
                        <th class="th-get">Key</th>
                        <th class="th-get">Key Name</th>
                        <th class="th-get"><spring:message code="etc.prodkey" text="Production Key"/></th>
                        <th class="th-get"><spring:message code="etc.testkey" text="Test Key"/></th>
                    </tr>
                    </thead>
                    <tbody id="piiordersteptable-body">
                    <c:forEach items="${masterkeylist}" var="masterkey">
                        <tr>
                            <td class="td-get-sm-l"><c:out value="${masterkey.custid}"/></td>
                            <td class="td-get-sm-l"><c:out value="${masterkey.keyid}"/></td>
                            <td class="td-get-sm-l"><c:out value="${masterkey.keyname}"/></td>
                            <td class="td-get-sm-l"><c:out value="${masterkey.val}"/></td>
                            <td class="td-get-sm-l"><c:out value="${masterkey.newval}"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div><!-- <div class="table-responsive"> -->

        </div>


    </div><!-- <div id="steps" class="step-container1 " style="width:100%"> -->

</div>
<!-- <div class="card shadow"> DataTales begin-->





