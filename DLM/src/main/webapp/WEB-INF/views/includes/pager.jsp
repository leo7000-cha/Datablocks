<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<style>
	.pagination-sm .page-link {
		padding: 2px 8px;
		font-size: 0.75rem;
		line-height: 1.2;
	}

	.pagination-sm .page-item.active .page-link {
		background-color: #007bff;
		color: white;
		border-color: #007bff;
	}

	.search-item_left {
		font-size: 0.75rem;         /* ✅ 페이지 번호와 같은 크기 */
		line-height: 1.2;           /* ✅ 높이도 일치시킴 */
		padding-top: 4px;           /* ✅ 수직 가운데 정렬 */
	}
</style>
 <div class="page-container-1row-55 m-1">
	<div class="search-item_left">
		Showing <c:out value="${pageMaker.total == 0 ? 0 : pageMaker.cri.amount * (pageMaker.cri.pagenum-1) +1}"/>
	     to <c:out value="${pageMaker.cri.amount * pageMaker.cri.pagenum < pageMaker.total ? pageMaker.cri.amount * pageMaker.cri.pagenum : pageMaker.total}"/>
	     of <c:out value="${pageMaker.total}"/> entries
	</div>
	<div class="search-item_right">
		<nav aria-label="...">
			<ul class="pagination pagination-sm justify-content-end">
				<c:if test="${pageMaker.prev}">
					<li class="page-item"><a class="page-link"
						href="javascript:void(0)"
						onclick="movePage(${pageMaker.startPage -1 })">Previous</a></li>
				</c:if>
				<c:if test="${pageMaker.endPage ne '1'}">
					<c:forEach var="num" begin="${pageMaker.startPage}"	end="${pageMaker.endPage}">
						<li class='page-item ${pageMaker.cri.pagenum == num ? "active":""} '>
							<a class="page-link" href="javascript:void(0)"	onclick="movePage(${num})">${num}</a>
						</li>
					</c:forEach>
				</c:if>
				<c:if test="${pageMaker.next}">
					<li class="page-item"><a class="page-link"
						href="javascript:void(0)"
						onclick="movePage(${pageMaker.endPage +1 })">Next</a></li>
				</c:if>
			</ul>
		</nav>
	</div>
</div>

<!-- Page navigation -->
			<!-- <div class="page-container-1row-55 m-1">
				<div class="search-item_left">
					Showing <c:out value="${pageMaker.cri.amount * (pageMaker.cri.pagenum-1) +1}"/>
				     to <c:out value="${pageMaker.cri.amount * pageMaker.cri.pagenum < pageMaker.total ? pageMaker.cri.amount * pageMaker.cri.pagenum : pageMaker.total}"/>
				     of <c:out value="${pageMaker.total}"/> entries
				</div>
				<div class="search-item_right">
					<nav aria-label="...">
						<ul class="pagination pagination-sm justify-content-end">
							<c:if test="${pageMaker.prev}">
								<li class="page-item"><a class="page-link"
									href="javascript:void(0)"
									onclick="movePage(${pageMaker.startPage -1 })">Previous</a></li>
							</c:if>
							<c:if test="${pageMaker.endPage ne '1'}">
								<c:forEach var="num" begin="${pageMaker.startPage}"	end="${pageMaker.endPage}">
									<li class='page-item ${pageMaker.cri.pagenum == num ? "active":""} '>
										<a	class="page-link" href="javascript:void(0)"	onclick="movePage(${num})">${num}</a>
									</li>
								</c:forEach>
							</c:if>
							<c:if test="${pageMaker.next}">
								<li class="page-item"><a class="page-link"
									href="javascript:void(0)"
									onclick="movePage(${pageMaker.endPage +1 })">Next</a></li>
							</c:if>
						</ul>
					</nav>
				</div>
			</div>-->
			<!-- Page navigation -->