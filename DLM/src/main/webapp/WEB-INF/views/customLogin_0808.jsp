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

	<title>X-One  Login</title>

	<!-- Custom fonts for this template-->
	<link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css"
		  rel="stylesheet" type="text/css">
	<!-- Custom styles for this template-->
	<link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">
	<!-- DLM styles -->
	<link href="/resources/css/datablocks-1.css" rel="stylesheet">
	<link href="/resources/css/login-refactored.css" rel="stylesheet">
</head>

<body class="page-container-55 bgimg" >
<div class="wrapper_center">
	<div style="text-align: center;">
		<img src="/resources/img/login_logo.png"  alt="">
		<h1 class="h6 text-gray-1500 mb-10">  Quality in Everything we do</h1>
		<h1 class="h6 text-gray-1500 mt-16">  </h1>
		<h1 class="h3 m-8" style="color: #1a1a1a; font-weight: 500; line-height: 1.4;">
			&nbsp;
		</h1>
		<h1 class="h3 m-8" style="color: #1a1a1a; font-weight: 500; line-height: 1.4;">
			&nbsp;
		</h1>
		<h1 class="h3 m-8" style="color: #1a1a1a; font-weight: 500; line-height: 1.4;">
			&nbsp;
		</h1>
		<div class="title-minimal">
			<%--<h1 class="product-name">X-One</h1>--%>
			<p class="product-tagline">One Hub, All Data</p>
		</div>



		<form style="margin: 0; padding: 0;" role="form" id="loginForm" method='post' action="/login">
			<div class="login_form">


				<div class="row" style="height:20%;">
					<div class="col" ></div>
				</div>
				<div class="row" style="height:16%;">
					<div class="col-sm-2" ></div>
					<div class="col-sm-6" >
						<input class="login_input white-text" placeholder="USERID" id="usernameLogin"
							   name="username" type="text" autofocus onkeypress="if (event.keyCode === 13) {login(); }"
							   style="color: white; background-color: transparent;">
					</div>

					<div class="col-sm-4" ></div>
				</div>
				<div class="row" style="height:8%;">
					<div class="col" ></div>
				</div>
				<div class="row" style="height:2%;">
					<div class="col-sm-1" ></div>
					<div class="col-sm-10" ><hr class="login_line" ></div>
					<div class="col-sm-1" ></div>
				</div>
				<div class="row" style="height:20%;">
					<div class="col" ></div>
				</div>
				<div class="row" style="height:16%;">
					<div class="col-sm-2" ></div>
					<div class="col-sm-6" >
						<input class="login_input_pwd white-text" placeholder="PASSWORD" autocomplete=”off” id="passwordLogin"
							   name="password" type="password" onkeypress="if (event.keyCode === 13) {login(); }">
					</div>
					<div class="col-sm-4" ></div>
				</div>
				<div class="row" style="height:8%;">
					<div class="col" ></div>
				</div>

			</div>
			<div >
				<!-- <div class="custom-control custom-checkbox small">
                    <input type="checkbox" class="custom-control-input"
                        id="customCheck" name="remember-me"> <label
                        class="custom-control-label" for="customCheck">Remember	Me</label>
                </div> -->
			</div>
			<input type="hidden" name="${_csrf.parameterName}"	value="${_csrf.token}"/>

		</form>

		<div class="row" style="height:80px;">
			<div class="col" ><c:out value="${error}"/></div>
		</div>
		<div class="div_center">
			<div class="row" style="height:80px;">
				<div class="col" ><a href="/customLogin" class="btn login_btn"> Login </a></div>
				<div class="col">
					<a href="#" class="btn login_btn_join" onclick="alert('Please contact the administrator!'); return false;">Join</a>
				</div>
			</div>
		</div>

	</div>
</div>
<div>

</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100">
	<div id="joinToast" class="toast align-items-center text-white bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
		<div class="d-flex">
			<div class="toast-body">
				Please contact the administrator!
			</div>
			<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
		</div>
	</div>
</div>
<script>
	function showJoinToast() {
		const toastEl = document.getElementById('joinToast');
		const toast = new bootstrap.Toast(toastEl);
		toast.show();
	}
</script>

<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/jquery/jquery.min.js"></script>
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>
<script>
	/* $("button[data-oper='login']").on("click", function(e){ */
	$(".login_btn").on("click", function(e){
		e.preventDefault();e.stopPropagation();
		$("#loginForm").submit();

	});
	login = function(){
		$("#loginForm").submit();
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
