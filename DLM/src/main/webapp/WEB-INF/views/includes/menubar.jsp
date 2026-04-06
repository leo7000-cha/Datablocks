<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<script src="/resources/vendor/jquery/jquery.min.js"></script>
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>
<!-- Custom styles for this template -->
<link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

<script>

    $(document).ready(function () {

        // Check for page parameter from server (passed via model)
        var loadPage = '<c:out value="${loadPage}" />';
        var loadDb = '<c:out value="${loadDb}" />';

        if (loadPage === 'exeupdate') {
            // Load SQL Manager page
            Menupath = "SQL Manager";
            var url = "/piidatabase/exeupdate";
            if (loadDb && loadDb !== '') {
                url += "?db=" + encodeURIComponent(loadDb);
            }
            $('#content_home').load(url);
        } else {
            // No page parameter - load default dashboard
            Menupath = "<spring:message code="memu.dashboard" text="Dashboard"/>";
            $('#content_home').load("/piidashboard/dashboard?pagenum=1&amount=100");
        }

        // Dropdown is handled by CSS :hover only - disable all click events
        $('#menulist .dropdown-toggle').removeAttr('data-toggle').on('click', function(e) {
            e.preventDefault();
        });

        $('.dropdown-item').click(function (e) {
            e.preventDefault();
            e.stopPropagation();
            ingShow();

            var menuId = $(this).attr('id');
            var url = "";
            // 1. header.jsp의 hidden input에서 사용자 이름 가져오기
            var userName = $('#global_userName').val();

            // 2. URL에 포함될 수 있도록 사용자 이름 인코딩 (한글, 공백 등 처리)
            var encodedUserName = encodeURIComponent(userName);

            if (menuId == "1000") {
                url = "/piidashboard/dashboard?pagenum=1&amount=100";
                Menupath = "<i class='far fa-chart-bar'></i> <spring:message code="memu.dashboard" text="대시보드"/>";
            } else if (menuId == "1010") {
                url = "/piidatabase/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="memu.config_management" text="시스템 설정"/>";
            } else if (menuId == "1020") {
                url = "/piisystem/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="memu.config_management" text="시스템 설정"/>";
            } else if (menuId == "1011") {
                url = "/piiconfig/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="memu.config_management" text="시스템 설정"/>";
            } else if (menuId == "1030") {
                url = "/piiconftable/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="memu.env_configuration" text="환경 설정"/>";
            } else if (menuId == "2000") {
                url = "/piipolicy/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-layer-group'></i> <spring:message code="memu.task_configuration" text="작업 관리"/>";
            } else if (menuId == "2001") {
                url = "/piijob/list?pagenum=1&amount=100&search2=PII&search7=ACTIVE";
                Menupath = "<i class='fas fa-layer-group'></i> <spring:message code="memu.task_configuration" text="작업 관리"/>";
            } else if (menuId == "2002") {
                url = "/piistep/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-layer-group'></i> <spring:message code="memu.task_configuration" text="작업 관리"/>";
            } else if (menuId == "2010") {
                url = "/piisteptable/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-layer-group'></i> <spring:message code="memu.task_configuration" text="작업 관리"/>";
            } else if (menuId == "2012") {
                url = "/metatable/piicolregstatlist?pagenum=1&amount=100&search6=PII_POLICY3&search5=N";
                Menupath = "<i class='fas fa-layer-group'></i> <spring:message code="memu.task_configuration" text="작업 관리"/>";
            } else if (menuId == "2020") {
                url = "/metatable/list?pagenum=1&amount=100&search11=Y&search15=N";
                Menupath = "<i class='fas fa-database'></i> <spring:message code="memu.tablemata_mgmt" text="데이터 인벤토리"/>";
            } else if (menuId == "2030") {
                url = "/lkpiiscrtype/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-shield-alt'></i> <spring:message code="memu.lkpiiscr_mgmt" text="민감정보 분류·보호 정책"/>";
            } else if (menuId == "2040") {
                // 민감정보 자동 탐지 - 새 탭으로 열기
                window.open("/piidiscovery/index", "_blank");
                ingHide();
                return;
            } else if (menuId == "2013") {
                url = "/piisteptable/register";
                Menupath = "<i class='fas fa-layer-group'></i> 스텝테이블 관리";
            } else if (menuId == "3001") {
                url = "/piischedule/list?pagenum=1&amount=100";
            } else if (menuId == "3002") {
                url = "/piischedule/register";
            } else if (menuId == "5001") {
                url = "/piirestore/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-box-archive'></i> <spring:message code="memu.restore_browse" text="복원·열람"/>";
            } else if (menuId == "5002") {
                url = "/piirestore/actorderlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-box-archive'></i> <spring:message code="memu.restore_browse" text="복원·열람"/>";
            } else if (menuId == "5003") {
                url = "/piirestore/arccustlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-box-archive'></i> <spring:message code="memu.restore_browse" text="복원·열람"/>";
            } else if (menuId == "30001") {
                url = "/testdata/apply?pagenum=1&amount=100&search2=CORE";
                Menupath = "<i class='fas fa-vial'></i> <spring:message code="memu.testdata" text="테스트 데이터"/>";
            } else if (menuId == "30002") {
                url = "/testdata/list?pagenum=1&amount=100&search3=" + encodedUserName;
                Menupath = "<i class='fas fa-vial'></i> <spring:message code="memu.testdata" text="테스트 데이터"/>";
            } else if (menuId === "30003") {
                url = "/testdata/testDataUsageStatus";
                Menupath = "<i class='fas fa-vial'></i> <spring:message code="memu.testdata" text="테스트 데이터"/>";
            } else if (menuId == "5111") {
                url = "/piirecovery/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-rotate-left'></i> <spring:message code="memu.recovery_management" text="복구 관리"/>";
            } else if (menuId == "5112") {
                url = "/piirecovery/orderlist";
                Menupath = "<i class='fas fa-rotate-left'></i> <spring:message code="memu.recovery_management" text="복구 관리"/>";
            } else if (menuId == "5113") {
                url = "/piirecovery/joblist";
                Menupath = "<i class='fas fa-rotate-left'></i> <spring:message code="memu.recovery_management" text="복구 관리"/>";
            } else if (menuId == "8001") {
                url = "/piiapprovalreq/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-stamp'></i> <spring:message code="memu.approval_management" text="결재 관리"/>";
            } else if (menuId == "8002") {
                url = "/piiapprovalreq/myrequestlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-stamp'></i> <spring:message code="memu.approval_management" text="결재 관리"/>";
            } else if (menuId == "6001") {
                url = "/piiorder/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gauge-high'></i> <spring:message code="memu.monitoring" text="모니터링"/>";
            } else if (menuId == "6002") {
                url = "/piiorder/jobcontrol?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gauge-high'></i> <spring:message code="memu.monitoring" text="모니터링"/>";
            } else if (menuId == "7001") {
                url = "/piiextract/custstatlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-chart-pie'></i> <spring:message code="memu.report" text="리포트"/>";
            } else if (menuId == "7002") {
                url = "/piiorder/report?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-chart-pie'></i> <spring:message code="memu.report" text="리포트"/>";
            } else if (menuId == "7003") {
                url = "/piiextract/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-chart-pie'></i> <spring:message code="memu.report" text="리포트"/>";
            } else if (menuId == "7501") {
                url = "/piicontract/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-broom'></i> <spring:message code="menu.real_doc_del" text="실물 파기"/>";
            } else if (menuId == "7511") {
                url = "/piicontract/statlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-broom'></i> <spring:message code="menu.real_doc_del" text="실물 파기"/>";
            } else if (menuId == "9001") {
                url = "/piidetect/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-search'></i> <spring:message code="memu.detect_management" text="탐지 관리"/>";
            } else if (menuId == "9003") {
                url = "/piidetect/resultlist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-search'></i> <spring:message code="memu.detect_management" text="탐지 관리"/>";
            } else if (menuId == "10001") {
                url = "/piimember/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-users-gear'></i> <spring:message code="memu.common" text="관리자 설정"/>";
            } else if (menuId == "10002") {
                url = "/piiauth/list?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-users-gear'></i> <spring:message code="memu.common" text="관리자 설정"/>";
            } else if (menuId == "10003") {
                url = "/piiapprovaluser/approvallinelist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-users-gear'></i> <spring:message code="memu.common" text="관리자 설정"/>";
            } else if (menuId == "11002") {
                url = "/piitable/layoutgaplist?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="menu.env_admin" text="시스템 설정"/>";
            } else if (menuId == "11003") {
                url = "/command/console?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-gear'></i> <spring:message code="menu.env_admin" text="시스템 설정"/>";
            } else if (menuId == "11004") {
                url = "/command/terminal?pagenum=1&amount=100";
                Menupath = "<i class='fas fa-terminal'></i> 터미널";
            } else if (menuId == "21001") {
                url = "/piiupload/uploadAjax";
                Menupath = "테스트";
            } else if (menuId == "31001") {
                url = "/board/list?pagenum=1&amount=100";
                Menupath = "게시판";
            }

            $('#content_home').load(url, function() {
                ingHide();
            });
            // $('#content_home').load(url);

        })

    });
</script>

<style>
    /* ============================================
       Premium Navigation Bar - 2024 Design
       ============================================ */

    :root {
        --nav-bg-start: #0f172a;
        --nav-bg-end: #1e293b;
        --nav-accent: #6366f1;
        --nav-accent-light: #818cf8;
        --nav-text: rgba(255, 255, 255, 0.9);
        --nav-text-muted: rgba(255, 255, 255, 0.6);
        --dropdown-bg: #ffffff;
        --dropdown-hover: #f8fafc;
        --dropdown-accent: #6366f1;
    }

    #menubar {
        background: linear-gradient(135deg, var(--nav-bg-start) 0%, var(--nav-bg-end) 100%);
        height: 48px;
        position: relative;
        z-index: 1000;
    }

    #menubar::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: linear-gradient(90deg, transparent, rgba(99, 102, 241, 0.5), transparent);
    }

    #menubar::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: rgba(0, 0, 0, 0.2);
    }

    #menulist {
        height: 48px;
        padding: 0 12px;
        display: flex;
        align-items: center;
        margin: 0;
    }

    /* ===== Brand Logo ===== */
    .nav-brand {
        display: flex;
        align-items: center;
        padding: 0 20px 0 8px;
        text-decoration: none !important;
        position: relative;
    }

    .nav-brand::after {
        content: '';
        position: absolute;
        right: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 1px;
        height: 24px;
        background: rgba(255, 255, 255, 0.1);
    }

    .brand-logo {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        margin-right: 8px;
        object-fit: cover;
        box-shadow: 0 2px 10px rgba(99, 102, 241, 0.4);
        transition: transform 0.3s ease;
    }

    .nav-brand:hover .brand-logo {
        transform: scale(1.1);
    }

    .brand-name {
        font-size: 1.15rem;
        font-weight: 700;
        color: #fff;
        letter-spacing: -0.5px;
        font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
    }

    .brand-badge {
        font-size: 0.55rem;
        font-weight: 600;
        color: var(--nav-accent-light);
        background: rgba(99, 102, 241, 0.15);
        padding: 2px 6px;
        border-radius: 4px;
        margin-left: 6px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* ===== Navigation Items ===== */
    #menulist .nav-item {
        position: static;
    }

    #menulist .nav-item.dropdown {
        position: relative !important;
    }

    #menulist .nav-link {
        color: var(--nav-text);
        font-size: 0.8rem;
        font-weight: 500;
        padding: 8px 14px;
        margin: 0 2px;
        display: flex;
        align-items: center;
        gap: 7px;
        border-radius: 8px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        text-decoration: none !important;
    }

    #menulist .nav-link::before {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 0;
        height: 2px;
        background: var(--nav-accent);
        border-radius: 2px;
        transition: width 0.2s ease;
    }

    #menulist .nav-link:hover,
    #menulist .nav-item.dropdown:hover > .nav-link {
        color: #fff;
        background: rgba(255, 255, 255, 0.08);
    }

    #menulist .nav-link:hover::before,
    #menulist .nav-item.dropdown:hover > .nav-link::before {
        width: calc(100% - 16px);
    }

    #menulist .nav-link i {
        font-size: 0.85rem;
        width: 18px;
        text-align: center;
        opacity: 0.8;
        transition: all 0.2s;
    }

    #menulist .nav-link:hover i {
        opacity: 1;
        color: var(--nav-accent-light);
    }

    /* Dropdown Arrow */
    #menulist .dropdown-toggle::after {
        content: '\f107';
        font-family: 'Font Awesome 6 Free';
        font-weight: 900;
        font-size: 0.6rem;
        border: none;
        margin-left: 5px;
        opacity: 0.5;
        transition: transform 0.25s ease;
        vertical-align: middle;
    }

    #menulist .nav-item.dropdown:hover .dropdown-toggle::after {
        transform: rotate(180deg);
    }

    /* ===== Dropdown Menu ===== */
    #menulist .dropdown-menu {
        display: none;
        position: absolute !important;
        background: var(--dropdown-bg);
        border: none !important;
        border-radius: 12px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15),
                    0 8px 25px rgba(0, 0, 0, 0.1),
                    0 0 0 1px rgba(0, 0, 0, 0.05);
        padding: 8px;
        margin: 0 !important;
        top: 100% !important;
        left: 0 !important;
        min-width: 220px;
        transform-origin: top left;
        z-index: 1050;
    }

    /* Show dropdown on hover only */
    #menulist .nav-item.dropdown:hover > .dropdown-menu {
        display: block;
    }

    /* ===== Dropdown Items ===== */
    .dropdown-item {
        color: #334155;
        font-size: 0.82rem;
        font-weight: 500;
        padding: 10px 14px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        gap: 10px;
        transition: all 0.15s ease;
        position: relative;
        margin: 2px 0;
    }

    .dropdown-item::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 3px;
        height: 0;
        background: var(--dropdown-accent);
        border-radius: 0 3px 3px 0;
        transition: height 0.2s ease;
    }

    .dropdown-item:hover {
        background: linear-gradient(90deg, #f1f5f9 0%, transparent 100%);
        color: var(--dropdown-accent);
        padding-left: 18px;
    }

    .dropdown-item:hover::before {
        height: 60%;
    }

    .dropdown-item:active {
        background: #e0e7ff;
        transform: scale(0.98);
    }

    .dropdown-item .menu-icon {
        width: 28px;
        height: 28px;
        background: #f1f5f9;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        color: #64748b;
        transition: all 0.2s;
    }

    .dropdown-item:hover .menu-icon {
        background: linear-gradient(135deg, var(--dropdown-accent) 0%, var(--nav-accent-light) 100%);
        color: #fff;
        transform: scale(1.05);
    }

    /* ===== Divider ===== */
    .dropdown-divider {
        margin: 8px 10px;
        border-top: 1px solid #e2e8f0;
    }

    /* ===== Active State ===== */
    #menulist .nav-item.active .nav-link {
        background: rgba(99, 102, 241, 0.15);
        color: #fff;
    }

    #menulist .nav-item.active .nav-link::before {
        width: calc(100% - 16px);
    }

    #menulist .nav-item.active .nav-link i {
        color: var(--nav-accent-light);
    }

    /* ===== User Section (Right Side) ===== */
    .nav-user-section {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 8px;
        padding-left: 16px;
        border-left: 1px solid rgba(255, 255, 255, 0.1);
    }

    /* Language Selector */
    .nav-lang-selector {
        position: relative;
    }

    .nav-lang-btn {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 10px;
        background: rgba(255, 255, 255, 0.08);
        border: none;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .nav-lang-btn:hover {
        background: rgba(255, 255, 255, 0.15);
    }

    .nav-lang-btn img {
        width: 18px;
        height: 14px;
        border-radius: 2px;
        object-fit: cover;
    }

    .nav-lang-btn i {
        color: rgba(255, 255, 255, 0.6);
        font-size: 0.6rem;
        transition: transform 0.2s;
    }

    .nav-lang-selector.open .nav-lang-btn i {
        transform: rotate(180deg);
    }

    .nav-lang-dropdown {
        display: none;
        position: absolute;
        top: calc(100% + 8px);
        right: 0;
        background: #fff;
        border-radius: 10px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
        min-width: 150px;
        padding: 6px;
        z-index: 9999;
        animation: dropdownSlide 0.2s ease;
    }

    .nav-lang-selector.open .nav-lang-dropdown {
        display: block;
    }

    .nav-lang-option {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 6px;
        color: #334155;
        text-decoration: none;
        font-size: 0.82rem;
        font-weight: 500;
        transition: all 0.15s;
    }

    .nav-lang-option:hover {
        background: #f1f5f9;
        color: var(--nav-accent);
        text-decoration: none;
    }

    .nav-lang-option img {
        width: 20px;
        height: 15px;
        border-radius: 2px;
        object-fit: cover;
    }

    .nav-lang-option .lang-check {
        margin-left: auto;
        color: #22c55e;
        font-size: 0.75rem;
    }

    /* User Info */
    .nav-user-info {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 4px 12px 4px 8px;
        background: rgba(255, 255, 255, 0.08);
        border-radius: 24px;
        transition: all 0.2s;
    }

    .nav-user-info:hover {
        background: rgba(255, 255, 255, 0.12);
    }

    .nav-user-avatar {
        width: 28px;
        height: 28px;
        background: linear-gradient(135deg, var(--nav-accent) 0%, var(--nav-accent-light) 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .nav-user-avatar i {
        color: #fff;
        font-size: 0.75rem;
    }

    .nav-user-name {
        color: #fff;
        font-size: 0.8rem;
        font-weight: 500;
        max-width: 100px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    /* Logout Button */
    .nav-logout-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
        background: rgba(100, 116, 139, 0.12);
        border: none;
        border-radius: 8px;
        color: #64748b;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none !important;
    }

    .nav-logout-btn:hover {
        background: rgba(100, 116, 139, 0.2);
        color: #475569;
        transform: scale(1.05);
    }

    .nav-logout-btn i {
        font-size: 0.85rem;
    }

</style>



<div id="menubar">
    <ul id="menulist" class="nav nav-pills">
        <!-- Brand Logo -->
        <a class="nav-brand" href="/index">
            <img src="/resources/img/XOne.png" alt="X-ONE" class="brand-logo">
            <span class="brand-name">X-One</span>
            <span class="brand-badge">v2.0</span>
        </a>

        <!-- Task Configuration (작업 관리) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-layer-group"></i>
                <span><spring:message code="memu.task_configuration" text="작업 관리"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='2001'>
                    <span class="menu-icon"><i class="fas fa-briefcase"></i></span>
                    <spring:message code="memu.job" text="Job 관리"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='2000'>
                    <span class="menu-icon"><i class="fas fa-file-contract"></i></span>
                    <spring:message code="memu.policy" text="파기 정책"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='2012'>
                    <span class="menu-icon"><i class="fas fa-check-circle"></i></span>
                    <spring:message code="memu.columnregisteredStatus" text="컬럼 등록 현황"/>
                </a>
            </div>
        </li>

        <!-- Restore Management (복원·열람) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-box-archive"></i>
                <span><spring:message code="memu.restore_browse" text="복원·열람"/></span>
            </a>
            <div class="dropdown-menu">
                <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_BIZ','ROLE_SEC','ROLE_ADMIN')">
                    <a class="dropdown-item" href='javascript:void(0)' id='5002'>
                        <span class="menu-icon"><i class="fas fa-plus-circle"></i></span>
                        <spring:message code="memu.restore_browse_apply" text="복원·열람 신청"/>
                    </a>
                </sec:authorize>
                <a class="dropdown-item" href='javascript:void(0)' id='5001'>
                    <span class="menu-icon"><i class="fas fa-list-ul"></i></span>
                    <spring:message code="memu.restore_apply_list" text="신청 목록"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='5003'>
                    <span class="menu-icon"><i class="fas fa-search"></i></span>
                    <spring:message code="memu.arccust_browse" text="고객 조회"/>
                </a>
            </div>
        </li>

        <!-- Test Data (테스트 데이터) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-vial"></i>
                <span><spring:message code="memu.testdata" text="테스트 데이터"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='30001'>
                    <span class="menu-icon"><i class="fas fa-paper-plane"></i></span>
                    <spring:message code="memu.testdata_apply" text="신청"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='30002'>
                    <span class="menu-icon"><i class="fas fa-clipboard-list"></i></span>
                    <spring:message code="memu.testdata_apply_list" text="내 신청 목록"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='30003'>
                    <span class="menu-icon"><i class="fas fa-chart-bar"></i></span>
                    <spring:message code="menu.testdata_usage_status" text="사용 현황"/>
                </a>
            </div>
        </li>

        <!-- Recovery Management (복구 관리 - IT/ADMIN only) -->
        <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_ADMIN')">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="fas fa-rotate-left"></i>
                    <span><spring:message code="memu.recovery_management" text="복구 관리"/></span>
                </a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href='javascript:void(0)' id='5112'>
                        <span class="menu-icon"><i class="fas fa-box"></i></span>
                        <spring:message code="memu.recovery_order_apply" text="Order 복구"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='5113'>
                        <span class="menu-icon"><i class="fas fa-cogs"></i></span>
                        <spring:message code="memu.recovery_job_apply" text="Job 복구"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='5111'>
                        <span class="menu-icon"><i class="fas fa-history"></i></span>
                        <spring:message code="memu.recovery_list" text="복구 이력"/>
                    </a>
                </div>
            </li>
        </sec:authorize>

        <!-- Monitoring (모니터링) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-gauge-high"></i>
                <span><spring:message code="memu.monitoring" text="모니터링"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='6001'>
                    <span class="menu-icon"><i class="fas fa-satellite-dish"></i></span>
                    <spring:message code="memu.realtime_monitoring" text="실시간 모니터링"/>
                </a>
                <sec:authorize access="hasAnyRole('ROLE_IT','ROLE_ADMIN')">
                    <a class="dropdown-item" href='javascript:void(0)' id='6002'>
                        <span class="menu-icon"><i class="fas fa-sliders"></i></span>
                        <spring:message code="memu.job_execution_control" text="실행 제어"/>
                    </a>
                </sec:authorize>
            </div>
        </li>

        <!-- Report (리포트) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-chart-pie"></i>
                <span><spring:message code="memu.report" text="리포트"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='7001'>
                    <span class="menu-icon"><i class="fas fa-file-lines"></i></span>
                    <spring:message code="menu.pii_pagi_stat" text="처리 현황"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='7003'>
                    <span class="menu-icon"><i class="fas fa-user-clock"></i></span>
                    <spring:message code="memu.report_cust_list" text="고객별 처리 이력"/>
                </a>
                <a class="dropdown-item" href="javascript:void(0)" id='7002'>
                    <span class="menu-icon"><i class="fas fa-table-cells"></i></span>
                    <spring:message code="memu.table_del_stat" text="테이블별 파기 현황"/>
                </a>
            </div>
        </li>

        <!-- Document Purge (실물 파기) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-broom"></i>
                <span><spring:message code="menu.real_doc_del" text="실물 파기"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="javascript:void(0)" id='7501'>
                    <span class="menu-icon"><i class="fas fa-file-circle-plus"></i></span>
                    <spring:message code="menu.real_doc_del_mgmt" text="파기 등록"/>
                </a>
                <a class="dropdown-item" href="javascript:void(0)" id='7511'>
                    <span class="menu-icon"><i class="fas fa-file-circle-check"></i></span>
                    <spring:message code="menu.real_doc_del_stat" text="파기 현황"/>
                </a>
            </div>
        </li>

        <!-- Approval Management (결재 관리) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-stamp"></i>
                <span><spring:message code="memu.approval_management" text="결재 관리"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='8001'>
                    <span class="menu-icon"><i class="fas fa-inbox"></i></span>
                    <spring:message code="memu.approval_wait" text="결재 대기함"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='8002'>
                    <span class="menu-icon"><i class="fas fa-paper-plane"></i></span>
                    <spring:message code="memu.approval_request" text="내 결재 요청"/>
                </a>
            </div>
        </li>

        <!-- Data Governance (데이터 거버넌스) -->
        <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                <i class="fas fa-shield-halved"></i>
                <span><spring:message code="memu.meta_configuration" text="데이터 거버넌스"/></span>
            </a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href='javascript:void(0)' id='2020'>
                    <span class="menu-icon"><i class="fas fa-database"></i></span>
                    <spring:message code="memu.tablemata_mgmt" text="데이터 인벤토리"/>
                </a>
                <a class="dropdown-item" href='javascript:void(0)' id='2030'>
                    <span class="menu-icon"><i class="fas fa-shield-alt"></i></span>
                    <spring:message code="memu.lkpiiscr_mgmt" text="민감정보 분류·보호 정책"/>
                </a>
                <div class="dropdown-divider"></div>
                <a class="dropdown-item" href='javascript:void(0)' id='2040'>
                    <span class="menu-icon"><i class="fas fa-magnifying-glass-chart"></i></span>
                    <spring:message code="menu.discovery" text="민감정보 자동 탐지"/> <i class="fas fa-external-link-alt" style="font-size:0.55rem; opacity:0.4; margin-left:4px;"></i>
                </a>
            </div>
        </li>

        <!-- Common (관리자 설정 - ADMIN only) -->
        <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="fas fa-users-gear"></i>
                    <span><spring:message code="memu.common" text="관리자 설정"/></span>
                </a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href='javascript:void(0)' id='10001'>
                        <span class="menu-icon"><i class="fas fa-user-plus"></i></span>
                        <spring:message code="memu.user_management" text="사용자 관리"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='10002'>
                        <span class="menu-icon"><i class="fas fa-user-lock"></i></span>
                        <spring:message code="memu.auth_management" text="권한 관리"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='10003'>
                        <span class="menu-icon"><i class="fas fa-sitemap"></i></span>
                        <spring:message code="memu.piiapprovalline_mgmt" text="결재선 관리"/>
                    </a>
                </div>
            </li>
        </sec:authorize>

        <!-- Environment Management (시스템 설정 - ADMIN only) -->
        <sec:authorize access="hasRole('ROLE_ADMIN')">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="fas fa-gear"></i>
                    <span><spring:message code="menu.env_admin" text="시스템 설정"/></span>
                </a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href='javascript:void(0)' id='1011'>
                        <span class="menu-icon"><i class="fas fa-toggle-on"></i></span>
                        <spring:message code="memu.control_management" text="제어 설정"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='1010'>
                        <span class="menu-icon"><i class="fas fa-database"></i></span>
                        <spring:message code="memu.db_connection" text="DB 연결 관리"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='1020'>
                        <span class="menu-icon"><i class="fas fa-server"></i></span>
                        <spring:message code="memu.systemmgmt" text="시스템 관리"/>
                    </a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" href='javascript:void(0)' id='11002'>
                        <span class="menu-icon"><i class="fas fa-arrows-left-right-to-line"></i></span>
                        <spring:message code="memu.arc_table_gap" text="아카이브 Gap"/>
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='11003'>
                        <span class="menu-icon"><i class="fas fa-terminal"></i></span>
                        콘솔
                    </a>
                    <a class="dropdown-item" href='javascript:void(0)' id='11004'>
                        <span class="menu-icon"><i class="fas fa-rectangle-terminal"></i></span>
                        터미널
                    </a>
                </div>
            </li>
        </sec:authorize>

        <!-- ===== User Section (Right Side) ===== -->
        <div class="nav-user-section">
            <!-- Language Selector -->
            <div class="nav-lang-selector" id="langSelector">
                <button type="button" class="nav-lang-btn" onclick="toggleLangDropdown()">
                    <c:choose>
                        <c:when test="${currentLocale == 'ko-KR'}">
                            <img src="/resources/img/ko.svg" alt="KO">
                        </c:when>
                        <c:otherwise>
                            <img src="/resources/img/us.svg" alt="EN">
                        </c:otherwise>
                    </c:choose>
                    <i class="fas fa-chevron-down"></i>
                </button>
                <div class="nav-lang-dropdown">
                    <a href="/changeLocale?lang=ko_KR" class="nav-lang-option">
                        <img src="/resources/img/ko.svg" alt="한국어">
                        <span>한국어</span>
                        <c:if test="${currentLocale == 'ko-KR'}">
                            <i class="fas fa-check lang-check"></i>
                        </c:if>
                    </a>
                    <a href="/changeLocale?lang=en_US" class="nav-lang-option">
                        <img src="/resources/img/us.svg" alt="English">
                        <span>English</span>
                        <c:if test="${currentLocale == 'en-US'}">
                            <i class="fas fa-check lang-check"></i>
                        </c:if>
                    </a>
                </div>
            </div>

            <!-- User Info -->
            <div class="nav-user-info">
                <%--<div class="nav-user-avatar">
                    <i class="fas fa-user"></i>
                </div>--%>
                <span class="nav-user-name">
                    <sec:authentication property="principal.member.userName"/>
                </span>
            </div>

            <!-- Hidden Fields for Global User Info -->
            <input type="hidden" id="global_userid" value="<sec:authentication property='principal.member.userid'/>">
            <input type="hidden" id="global_userName" value="<sec:authentication property='principal.member.userName'/>">

            <!-- Logout Button -->
            <a href="#" data-toggle="modal" data-target="#logoutModal" class="nav-logout-btn" title="Logout">
                <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>
    </ul>
</div>

<script>
    // Language Dropdown Toggle
    function toggleLangDropdown() {
        document.getElementById('langSelector').classList.toggle('open');
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        var langSelector = document.getElementById('langSelector');
        if (langSelector && !langSelector.contains(e.target)) {
            langSelector.classList.remove('open');
        }
    });
</script>