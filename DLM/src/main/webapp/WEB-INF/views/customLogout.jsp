<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
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

<title>Custom Login</title>

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

			<div class="col-xl-10 col-lg-12 col-md-9">

				<div class="card o-hidden border-0 shadow-lg my-5">
					<div class="card-body p-0">
						<!-- Nested Row within Card Body -->
						<div class="row">
							<div class="col-lg-6 d-none d-lg-block bg-login-image"></div>
							<div class="col-lg-6">
								<div class="p-5">
									<div class="text-center">
										<h1 class="h4 text-gray-900 mb-4">Log out Page</h1>						
									</div>
									<form style="margin: 0; padding: 0;"  role="form" id="logoutForm" method='post' action="/customLogout">
									
										<!-- <a href="index.html" class="btn btn-primary btn-user btn-block">Login </a> -->
										<a href="/customLogout"	class="btn btn-primary btn-user btn-block"> Log out </a>
										<!-- <a href="i/customLogin" class="btn btn-lg btn-success btn-block">Login</a> -->
										<!-- <button data-oper='login' class="btn btn-primary btn-lg">Login</button> -->
	
										<input type="hidden" name="${_csrf.parameterName}"	value="${_csrf.token}"/>

									</form>
									
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
			$("#logoutForm").submit();
	
		});

	</script>

</body>

</html>
