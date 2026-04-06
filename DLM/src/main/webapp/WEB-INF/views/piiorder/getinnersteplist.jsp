<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<script src="resources/vendor/bootstrap/js/bootstrap.min.js"></script>
<!-- <div class="card shadow m-1"> -->
<div class="row mt-3 mb-3 ml-1 mr-1 ">
    <div class="col-sm-12">
        <div class="panel panel-default" style="height: 535px;width: 100%">
            <!-- <h1 class="h5 mb-0 m-1">Job</h1> -->
            <div class="panel-body">
                <div class="mt-0 mb-1" style="text-align: right;">
                    <%-- 				<sec:authorize access="hasAnyRole('ROLE_IT')">
                                        <sec:authentication property="principal.member.userid" var="userid"/>
                                        <c:if test="${userid eq piijob.job_owner_id1 || userid eq piijob.job_owner_id2 || userid eq piijob.job_owner_id3 }">
                                                <button data-oper='steptablemodify' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message code="btn.save" text="Save"/></button>
                                        </c:if>
                                    </sec:authorize>
                                    <sec:authorize access="hasRole('ROLE_ADMIN')">
                                            <button data-oper='steptablemodify' class="btn btn-primary btn-sm p-0 pb-2 button"><spring:message code="btn.save" text="Save"/></button>
                                    </sec:authorize>	 --%>
                </div>

                <div class="tableWrapper" style="height: 545px;width: 100%">
                    <table id="listTable"  class=" table-hover">
                        <colgroup>
                            <col style="width: 5%"/>
                            <col style="width: 15%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 10%"/>
                            <col style="width: 15%"/>
                            <col style="width: 15%"/>
                            <col style="width: 20%"/>

                        </colgroup>
                        <thead>
                        <tr>
                            <th scope="row" class="th-hidden"><spring:message code="col.orderid" text="Orderid" /></th>
                            <th scope="row" class="th-hidden"><spring:message code="col.stepid" text="Stepid" /></th>
                            <th scope="row" class="th-hidden"><spring:message code="col.seq1" text="Seq1" /></th>
                            <th scope="row" class="th-hidden"><spring:message code="col.seq2" text="Seq2" /></th>
                            <th scope="row" class="th-hidden">Seq</th>
                            <th scope="row" class="th-get">step_seq</th>
                            <th scope="row" class="th-get">step_name</th>
                            <th scope="row" class="th-get"><spring:message code="col.status" text="Status" /></th>
                            <th scope="row" class="th-get"><spring:message code="col.execnt" text="Execnt" /></th>
                            <th scope="row" class="th-get"><spring:message code="col.exetime" text="Exetime" /></th>
                            <th scope="row" class="th-get"><spring:message code="col.exestart" text="Exestart" /></th>
                            <th scope="row" class="th-get"><spring:message code="col.exeend" text="Exeend" /></th>
                            <th scope="row" class="th-get">message</th>
                            <th scope="row" class="th-hidden">result</th>

                        </tr>
                        </thead>
                        <tbody id=orderlist-body >
                        <c:forEach items="${innerstepvolist}" var="innerstep">
                            <tr>
                                <td class='td-hidden'><c:out value="${innerstep.orderid}" /></td>
                                <td class='td-hidden'><c:out value="${innerstep.stepid}" /></td>
                                <td class='td-hidden'><c:out value="${innerstep.seq1}" /></td>
                                <td class='td-hidden'><c:out value="${innerstep.seq2}" /></td>
                                <td class='td-hidden'>seq</td>
                                <td class='td-get-r'><c:out value="${innerstep.inner_step_seq}" /></td>
                                <td class='td-get-l'><c:out value="${innerstep.inner_step_name}" /></td>
                                <td class='td-get'>
                                    <c:choose>
                                        <c:when test="${innerstep.status eq 'Ended OK' }"><span style="font-size: 12px;" class="badge badge-success"><c:out value="${innerstep.status}"/></span></c:when>
                                        <c:when test="${innerstep.status eq 'Ended not OK' }"><span style="font-size: 12px;" class="badge badge-danger">Error</span></c:when>
                                        <c:when test="${innerstep.status eq 'Running' }"><span style="font-size: 12px;" class="badge badge-primary"><i class="fa fa-spinner fa-spin"></i> <c:out value="${innerstep.status}"/></span></c:when>
                                        <c:when test="${innerstep.status eq 'Wait condition' }">
									<span style="font-size: 12px;" class="badge badge-secondary">Wait</span>
                                        </c:when>
                                        <c:otherwise><span class="badge badge-light"><c:out value="${innerstep.status}"/></span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class='td-get-r'><fmt:formatNumber value="${innerstep.execnt}" pattern="#,###" /></td>
                                <td class='td-get'><c:out value="${innerstep.exetime}" /></td>
                                <td class='td-get'><c:out value="${innerstep.exestart}" /></td>
                                <td class='td-get'><c:out value="${innerstep.exeend}" /></td>
                                <td class='td-get-l'><c:out value="${innerstep.message}" /></td>
                                <td class='td-hidden'><c:out value="${innerstep.result}" /></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>

            </div>
            <!--  end panel-body -->
        </div>
        <!--  panel panel-default-->
    </div>



</div>

