<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>X-One · Hub</title>

    <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

    <style>
        /* ===== Theme (login-refactored.css 통일) ===== */
        :root {
            --bg1: #0f172a;
            --bg2: #111827;
            --accent: #2563eb;
            --accent-2: #60a5fa;
            --accent-glow: rgba(37, 99, 235, .18);
            --muted: #9ca3af;
            --text: #e5e7eb;
            --text-strong: #e8ecf4;
            --card-bg: rgba(255, 255, 255, .05);
            --card-brd: rgba(255, 255, 255, .10);
            --ring: rgba(37, 99, 235, .45);
        }

        *, *::before, *::after { box-sizing: border-box; }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
            -webkit-font-smoothing: antialiased;
        }

        body {
            background:
                radial-gradient(60% 80% at 10% 10%, #1f2937 0%, transparent 60%),
                radial-gradient(70% 90% at 90% 20%, rgba(14, 165, 233, .35) 0%, transparent 60%),
                linear-gradient(135deg, var(--bg1), var(--bg2));
            color: var(--text);
            overflow-x: hidden;
        }

        /* ===== Animated Background Orbs ===== */
        .bg-orbs {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            overflow: hidden;
        }
        .bg-orbs .orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            opacity: .12;
            animation: orbFloat 20s ease-in-out infinite;
        }
        .bg-orbs .orb--1 {
            width: 600px; height: 600px;
            background: var(--accent);
            top: -10%; left: -5%;
            animation-duration: 25s;
        }
        .bg-orbs .orb--2 {
            width: 500px; height: 500px;
            background: #0ea5e9;
            bottom: -15%; right: -8%;
            animation-duration: 30s;
            animation-delay: -5s;
        }
        .bg-orbs .orb--3 {
            width: 300px; height: 300px;
            background: #8b5cf6;
            top: 40%; left: 60%;
            animation-duration: 22s;
            animation-delay: -10s;
        }
        @keyframes orbFloat {
            0%, 100% { transform: translate(0, 0) scale(1); }
            33% { transform: translate(30px, -40px) scale(1.05); }
            66% { transform: translate(-20px, 20px) scale(.95); }
        }

        /* ===== Grid Lines (tech feel) ===== */
        .grid-lines {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            background-image:
                linear-gradient(rgba(255,255,255,.02) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,.02) 1px, transparent 1px);
            background-size: 60px 60px;
        }

        /* ===== Layout ===== */
        .hub-page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px 24px;
            position: relative;
            z-index: 1;
        }

        /* ===== Header / Brand ===== */
        .hub-header {
            text-align: center;
            margin-bottom: 56px;
            animation: fadeInUp .6s ease-out;
        }

        .hub-logo {
            width: 56px; height: 56px;
            border-radius: 16px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(37, 99, 235, .25);
        }

        .hub-brand-name {
            font-size: clamp(2rem, 4vw, 2.8rem);
            font-weight: 800;
            color: var(--text-strong);
            letter-spacing: -1.5px;
            margin: 0 0 8px;
        }
        .hub-brand-name span { color: var(--accent-2); }

        .hub-tagline {
            font-size: .95rem;
            font-weight: 600;
            color: var(--accent-2);
            letter-spacing: 3px;
            text-transform: uppercase;
            margin: 0 0 6px;
        }

        .hub-subtitle {
            font-size: .9rem;
            color: var(--muted);
            margin: 0;
        }

        /* ===== Cards Grid ===== */
        .hub-cards {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 24px;
            max-width: 1200px;
            width: 100%;
            animation: fadeInUp .6s ease-out .15s both;
        }

        .hub-card {
            width: 260px;
            flex-shrink: 0;
            position: relative;
            background: var(--card-bg);
            border: 1px solid var(--card-brd);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-radius: 20px;
            padding: 40px 32px 32px;
            text-align: center;
            cursor: pointer;
            transition: all .35s cubic-bezier(.4, 0, .2, 1);
            overflow: hidden;
            text-decoration: none;
            display: block;
            color: inherit;
        }

        /* Top accent bar */
        .hub-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            opacity: 0;
            transition: opacity .3s ease;
        }

        /* Glow effect on hover */
        .hub-card::after {
            content: '';
            position: absolute;
            inset: 0;
            border-radius: 20px;
            opacity: 0;
            transition: opacity .4s ease;
            pointer-events: none;
        }

        .hub-card:hover {
            transform: translateY(-8px);
            border-color: rgba(255, 255, 255, .18);
            box-shadow:
                0 20px 60px rgba(0, 0, 0, .3),
                0 0 40px var(--card-glow, rgba(37, 99, 235, .08));
            color: inherit;
            text-decoration: none;
        }
        .hub-card:hover::before { opacity: 1; }
        .hub-card:active { transform: translateY(-4px); }

        /* Card variants */
        .hub-card--purge { --card-glow: rgba(99, 102, 241, .12); }
        .hub-card--purge::before { background: linear-gradient(90deg, #6366f1, #818cf8); }

        .hub-card--gen { --card-glow: rgba(20, 184, 166, .12); }
        .hub-card--gen::before { background: linear-gradient(90deg, #14b8a6, #2dd4bf); }

        .hub-card--discover { --card-glow: rgba(16, 185, 129, .12); }
        .hub-card--discover::before { background: linear-gradient(90deg, #10b981, #34d399); }

        .hub-card--accesslog { --card-glow: rgba(245, 158, 11, .12); }
        .hub-card--accesslog::before { background: linear-gradient(90deg, #f59e0b, #fbbf24); }

        /* Card Icon */
        .hub-card-icon {
            width: 72px; height: 72px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 22px;
            font-size: 1.6rem;
            transition: transform .3s ease, box-shadow .3s ease;
        }
        .hub-card:hover .hub-card-icon {
            transform: scale(1.1);
        }

        .hub-card--purge .hub-card-icon {
            background: rgba(99, 102, 241, .12);
            color: #818cf8;
            box-shadow: 0 0 0 1px rgba(99, 102, 241, .15);
        }
        .hub-card--purge:hover .hub-card-icon {
            box-shadow: 0 0 24px rgba(99, 102, 241, .2);
        }

        .hub-card--gen .hub-card-icon {
            background: rgba(20, 184, 166, .12);
            color: #2dd4bf;
            box-shadow: 0 0 0 1px rgba(20, 184, 166, .15);
        }
        .hub-card--gen:hover .hub-card-icon {
            box-shadow: 0 0 24px rgba(20, 184, 166, .2);
        }

        .hub-card--discover .hub-card-icon {
            background: rgba(16, 185, 129, .12);
            color: #34d399;
            box-shadow: 0 0 0 1px rgba(16, 185, 129, .15);
        }
        .hub-card--discover:hover .hub-card-icon {
            box-shadow: 0 0 24px rgba(16, 185, 129, .2);
        }

        .hub-card--accesslog .hub-card-icon {
            background: rgba(245, 158, 11, .12);
            color: #fbbf24;
            box-shadow: 0 0 0 1px rgba(245, 158, 11, .15);
        }
        .hub-card--accesslog:hover .hub-card-icon {
            box-shadow: 0 0 24px rgba(245, 158, 11, .2);
        }

        /* Card Text */
        .hub-card-title {
            font-size: 1.2rem;
            font-weight: 800;
            color: var(--text-strong);
            margin-bottom: 4px;
            letter-spacing: -.5px;
        }

        .hub-card-subtitle {
            font-size: .82rem;
            font-weight: 600;
            color: var(--accent-2);
            margin-bottom: 10px;
            letter-spacing: .5px;
        }

        .hub-card-desc {
            font-size: .82rem;
            color: var(--muted);
            line-height: 1.65;
            margin-bottom: 28px;
        }

        /* Card Button */
        .hub-card-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: .8rem;
            font-weight: 600;
            padding: 10px 24px;
            border-radius: 10px;
            transition: all .25s ease;
        }

        .hub-card--purge .hub-card-btn {
            background: rgba(99, 102, 241, .1);
            color: #a5b4fc;
            border: 1px solid rgba(99, 102, 241, .15);
        }
        .hub-card--purge:hover .hub-card-btn {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 16px rgba(99, 102, 241, .35);
        }

        .hub-card--gen .hub-card-btn {
            background: rgba(20, 184, 166, .1);
            color: #5eead4;
            border: 1px solid rgba(20, 184, 166, .15);
        }
        .hub-card--gen:hover .hub-card-btn {
            background: linear-gradient(135deg, #14b8a6, #0d9488);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 16px rgba(20, 184, 166, .35);
        }

        .hub-card--discover .hub-card-btn {
            background: rgba(16, 185, 129, .1);
            color: #6ee7b7;
            border: 1px solid rgba(16, 185, 129, .15);
        }
        .hub-card--discover:hover .hub-card-btn {
            background: linear-gradient(135deg, #10b981, #059669);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 16px rgba(16, 185, 129, .35);
        }

        .hub-card--accesslog .hub-card-btn {
            background: rgba(245, 158, 11, .1);
            color: #fcd34d;
            border: 1px solid rgba(245, 158, 11, .15);
        }
        .hub-card--accesslog:hover .hub-card-btn {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 16px rgba(245, 158, 11, .35);
        }

        .hub-card-btn i.fa-arrow-right {
            font-size: .7rem;
            transition: transform .25s ease;
        }
        .hub-card:hover .hub-card-btn i.fa-arrow-right {
            transform: translateX(4px);
        }

        /* ===== Animations ===== */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(24px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ===== Responsive ===== */
        @media (max-width: 768px) {
            .hub-card { width: 100%; max-width: 360px; }
        }
        @media (min-width: 769px) and (max-width: 1100px) {
            .hub-card { width: 280px; }
        }
        @media (min-width: 1101px) and (max-width: 1400px) {
            .hub-cards { gap: 20px; }
            .hub-card { width: 250px; padding: 32px 24px 28px; }
        }
    </style>
</head>

<body>
    <!-- Background Effects -->
    <div class="bg-orbs">
        <div class="orb orb--1"></div>
        <div class="orb orb--2"></div>
        <div class="orb orb--3"></div>
    </div>
    <div class="grid-lines"></div>

    <div class="hub-page">
        <!-- Header -->
        <header class="hub-header">
            <!-- <img src="/resources/img/XOne.png" alt="X-One" class="hub-logo"> -->
            <h1 class="hub-brand-name">X<span>-</span>One</h1>
            <p class="hub-tagline">All Data. One Platform.</p>
            <p class="hub-subtitle"><spring:message code="hub.subtitle" text="X-One 통합 데이터 관리 플랫폼"/></p>
        </header>

        <!-- Module Cards -->
        <div class="hub-cards">
            <c:if test="${moduleXpurge}">
            <a class="hub-card hub-card--purge" href="/index?page=dashboard&mode=purge">
                <div class="hub-card-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <div class="hub-card-title">X-Purge</div>
                <div class="hub-card-subtitle">개인정보 파기</div>
                <div class="hub-card-desc">파기 정책 관리, Job 실행, 복원·열람 및 리포트</div>
                <span class="hub-card-btn"><spring:message code="hub.card.btn" text="바로가기"/> <i class="fas fa-arrow-right"></i></span>
            </a>
            </c:if>

            <c:if test="${moduleXgen}">
            <a class="hub-card hub-card--gen" href="/index?page=dashboard&mode=gen">
                <div class="hub-card-icon">
                    <i class="fas fa-vial"></i>
                </div>
                <div class="hub-card-title">X-Gen</div>
                <div class="hub-card-subtitle">테스트데이터 생성</div>
                <div class="hub-card-desc">테스트데이터 신청 및 사용 현황 관리</div>
                <span class="hub-card-btn"><spring:message code="hub.card.btn" text="바로가기"/> <i class="fas fa-arrow-right"></i></span>
            </a>
            </c:if>

            <c:if test="${moduleXscan}">
            <a class="hub-card hub-card--discover" href="/piidiscovery/index">
                <div class="hub-card-icon">
                    <i class="fas fa-search-location"></i>
                </div>
                <div class="hub-card-title">X-Scan</div>
                <div class="hub-card-subtitle">개인정보 탐지</div>
                <div class="hub-card-desc">AI 기반 개인정보 컬럼 자동 탐지 및 분류 관리</div>
                <span class="hub-card-btn"><spring:message code="hub.card.btn" text="바로가기"/> <i class="fas fa-arrow-right"></i></span>
            </a>
            </c:if>

            <c:if test="${moduleXaudit}">
            <a class="hub-card hub-card--accesslog" href="/accesslog/index">
                <div class="hub-card-icon">
                    <i class="fas fa-clipboard-list"></i>
                </div>
                <div class="hub-card-title">X-Audit</div>
                <div class="hub-card-subtitle">접속기록 · 소명</div>
                <div class="hub-card-desc">DB 접속기록 수집, 이상행위 탐지 및 감사 로그 관리</div>
                <span class="hub-card-btn"><spring:message code="hub.card.btn" text="바로가기"/> <i class="fas fa-arrow-right"></i></span>
            </a>
            </c:if>
        </div>

    </div>
</body>
</html>
