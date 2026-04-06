<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

	<title>X-One · Login</title>

	<!-- Icons / Fonts -->
	<link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">

	<!-- Core / Theme CSS -->
	<link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

	<!-- Custom styles (overwrite freely) -->
	<link href="/resources/css/login-refactored.css" rel="stylesheet">

	<!-- Optional: preload logo for faster paint -->
	<link rel="preload" as="image" href="/resources/img/login_logo.png">
</head>

<body class="login-bg">
<main class="auth-wrapper">
	<section class="brand-side">
		<div class="brand-main tight">
			<p class="brand-overline">Quality in everything we do</p>
			<h1 class="brand-product">X‑One</h1>
			<p class="brand-tagline">One Hub, All Data</p>
		</div>
	</section>


	<section class="auth-card">
		<header class="auth-header">
			<h2 class="auth-title">Sign in</h2>
			<%--<p class="auth-subtitle">Welcome back. Please enter your credentials.</p>--%>
		</header>

		<!-- Error message (server-side) -->
		<c:if test="${not empty error}">
			<div class="alert alert-danger d-flex align-items-center mb-3" role="alert">
				<i class="fa-solid fa-triangle-exclamation mr-2"></i>
				<span><c:out value="${error}"/></span>
			</div>
		</c:if>

		<form id="loginForm" role="form" method="post" action="/login" novalidate>
			<div class="form-group">
				<label for="usernameLogin" class="sr-only">User ID</label>
				<div class="field-wrap">
					<i class="fa-regular fa-user field-icon" aria-hidden="true"></i>
					<input
							id="usernameLogin"
							name="username"
							type="text"
							class="form-control field-input"
							placeholder="User ID"
							autocomplete="username"
							autofocus
							required
					/>
				</div>
			</div>

			<div class="form-group">
				<label for="passwordLogin" class="sr-only">Password</label>
				<div class="field-wrap">
					<i class="fa-solid fa-lock field-icon" aria-hidden="true"></i>
					<input
							id="passwordLogin"
							name="password"
							type="password"
							class="form-control field-input"
							placeholder="Password"
							autocomplete="current-password"
							required
					/>
					<button type="button" class="toggle-password" aria-label="Show password" title="Show password">
						<i class="fa-regular fa-eye"></i>
					</button>
				</div>
			</div>

			<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

			<div class="auth-actions">
				<button type="submit" class="btn btn-primary btn-login">
					<span>Login</span>
					<i class="fa-solid fa-arrow-right ml-2" aria-hidden="true"></i>
				</button>

				<%--<div class="auth-links">
					<button type="button" class="btn btn-link p-0 link-join" id="joinBtn">Request access</button>
					<a href="/customLogin" class="btn btn-link p-0 d-none">Alt login</a>
				</div>--%>
			</div>
		</form>

		<footer class="auth-footer">
			<small>&copy; <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy"/> X‑One. All rights reserved.</small>
		</footer>
	</section>
</main>

<!-- Toast: Join -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100">
	<div id="joinToast" class="toast align-items-center text-white bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
		<div class="d-flex">
			<div class="toast-body">Please contact the administrator!</div>
			<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
		</div>
	</div>
</div>

<!-- JS -->
<script src="/resources/vendor/jquery/jquery.min.js"></script>
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>
<script src="/resources/js/sb-admin-2.min.js"></script>

<script>
	// Submit on Enter in inputs
	document.addEventListener('keydown', (e) => {
		if (e.key === 'Enter') {
			const form = document.getElementById('loginForm');
			if (form) form.submit();
		}
	});

	// Show/Hide password
	(function () {
		const btn = document.querySelector('.toggle-password');
		const input = document.getElementById('passwordLogin');
		if (!btn || !input) return;

		btn.addEventListener('click', () => {
			const isPassword = input.getAttribute('type') === 'password';
			input.setAttribute('type', isPassword ? 'text' : 'password');
			btn.setAttribute('aria-label', isPassword ? 'Hide password' : 'Show password');
			btn.title = isPassword ? 'Hide password' : 'Show password';
			btn.innerHTML = isPassword
					? '<i class="fa-regular fa-eye-slash"></i>'
					: '<i class="fa-regular fa-eye"></i>';
		});
	})();

	// Toast for Join
	(function () {
		const joinBtn = document.getElementById('joinBtn');
		const toastEl = document.getElementById('joinToast');
		if (!joinBtn || !toastEl) return;

		joinBtn.addEventListener('click', () => {
			const toast = new bootstrap.Toast(toastEl);
			toast.show();
		});
	})();
</script>

<c:if test="${param.logout != null}">
	<script>
		// Optionally show a toast or message on logout
		// const toast = new bootstrap.Toast(document.getElementById('joinToast')); toast.show();
	</script>
</c:if>
</body>
</html>
