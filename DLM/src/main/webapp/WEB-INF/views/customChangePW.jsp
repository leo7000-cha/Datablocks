<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!DOCTYPE html>
<html lang="en">


<head>

<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1, shrink-to-fit=no">
<meta name="description" content="">
<meta name="author" content="">

<title>Change Password</title>

<!-- Custom fonts for this template-->
<link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css"
	rel="stylesheet" type="text/css">

<!-- Custom styles for this template-->
<link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

</head>

<body class="bg-gradient-primary" >

	<div class="container">

		<!-- Outer Row -->
		<div class="row justify-content-center">

			<div class="col-xl-6">

				<div class="card o-hidden border-0 shadow-lg my-5">
					<div class="card-body p-0">
						<!-- Nested Row within Card Body -->
						<div class="row">
							<!-- <div class="col-lg-6 d-none d-lg-block bg-login-image"></div> -->
							<div class="col-xl-12">
								<div class="p-5">
									<div class="text-center">
										<h1 class="h4 text-gray-900 mb-4">Change Password</h1>
										<%-- <h2><c:out value="${error}"/></h2>
										<h2><c:out value="${logout}"/></h2> --%>								
									</div>
									<form style="margin: 0; padding: 0;" class="user" role="form" id="changePwdForm" method='post' action="/changePassword">
									
										<div class="form-group">
											<input class="form-control" placeholder="userid"
												name="username" type="text" autofocus onkeypress="if (event.keyCode === 13) {login(); }">
										</div>
										<div class="form-group">
											<input class="form-control" placeholder="Password" autocomplete=”off”
												name="password1" type="password" onkeypress="if (event.keyCode === 13) {login(); }">
										</div>
										<div class="form-group">
											<input class="form-control" placeholder="Password" autocomplete=”off”
												name="password2" type="password" onkeypress="if (event.keyCode === 13) {login(); }">
										</div>
									
										<!-- <a href="index.html" class="btn btn-primary btn-user btn-block">Login </a> -->
										<a href="/changePassword"	class="btn btn-primary btn-user btn-block"> Change </a>

										<input type="hidden" name="${_csrf.parameterName}"	value="${_csrf.token}"/>

									</form>
									
									<div class="text-center mt-2">
										<c:out value="${error}"/>
									</div>

								</div>
							</div>
						</div>
					</div>
				</div>

			</div>

		</div>

	</div>

	<!-- Bootstrap core JavaScript-->
	<script src="/resources/vendor/jquery/jquery.min.js"></script>
	<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

	<!-- Core plugin JavaScript-->
	<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

	<!-- Custom scripts for all pages-->
	<script src="/resources/js/sb-admin-2.min.js"></script>
	<script>
		/* $("button[data-oper='login']").on("click", function(e){ */
		$(".btn-primary").on("click", function(e){
			e.preventDefault();e.stopPropagation();
			$("#changePwdForm").submit();
	
		});
		login = function(){ 
			$("#changePwdForm").submit();
		}

	</script>

	<c:if test="${param.logout != null}">
		<script>
			$(document).ready(function() {
				//alert("로그아웃하였습니다.");
			});
		</script>
	</c:if>

</body>

</html>
