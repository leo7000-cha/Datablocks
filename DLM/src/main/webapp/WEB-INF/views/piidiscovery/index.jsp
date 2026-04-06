<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge; chrome=1"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>X-One 개인정보 탐지</title>

    <!-- Fonts -->
    <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Styles -->
    <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">

    <style>
        :root {
            --discovery-primary: #6366f1;
            --discovery-primary-dark: #4f46e5;
            --discovery-secondary: #0ea5e9;
            --discovery-success: #10b981;
            --discovery-warning: #f59e0b;
            --discovery-danger: #ef4444;
            --discovery-bg: #f8fafc;
            --discovery-sidebar: #1e293b;
            --discovery-sidebar-hover: #334155;
        }

        * {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }

        body {
            background: var(--discovery-bg);
            overflow: hidden;
        }

        /* ===== Layout ===== */
        .discovery-wrapper {
            display: flex;
            height: 100vh;
        }

        /* ===== Sidebar ===== */
        .discovery-sidebar {
            width: 260px;
            background: var(--discovery-sidebar);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }

        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .sidebar-brand-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--discovery-primary), var(--discovery-secondary));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .sidebar-brand-icon i {
            color: #fff;
            font-size: 1.2rem;
        }

        .sidebar-brand-text {
            color: #fff;
            font-size: 1rem;
            font-weight: 600;
            line-height: 1.3;
        }

        /* Sidebar Navigation */
        .sidebar-nav {
            flex: 1;
            padding: 16px 0;
            overflow-y: auto;
        }

        .nav-section {
            padding: 0 16px;
            margin-bottom: 8px;
        }

        .nav-section-title {
            color: rgba(255,255,255,0.4);
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 8px 12px;
        }

        .nav-item {
            margin: 2px 0;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            border-radius: 8px;
            margin: 0 8px;
            transition: all 0.2s;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .nav-link:hover {
            background: var(--discovery-sidebar-hover);
            color: #fff;
            text-decoration: none;
        }

        .nav-link.active {
            background: var(--discovery-primary);
            color: #fff;
        }

        .nav-link i {
            width: 20px;
            text-align: center;
            font-size: 1rem;
        }

        .nav-badge {
            margin-left: auto;
            background: var(--discovery-danger);
            color: #fff;
            font-size: 0.7rem;
            padding: 2px 8px;
            border-radius: 10px;
            font-weight: 600;
        }

        /* Sidebar Footer */
        .sidebar-footer {
            padding: 16px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px;
            border-radius: 8px;
            background: rgba(255,255,255,0.05);
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, var(--discovery-primary), var(--discovery-secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .user-avatar i {
            color: #fff;
            font-size: 0.9rem;
        }

        .user-details {
            flex: 1;
        }

        .user-name {
            color: #fff;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .user-role {
            color: rgba(255,255,255,0.5);
            font-size: 0.75rem;
        }

        .btn-back-main {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            width: 100%;
            padding: 10px;
            margin-top: 12px;
            background: rgba(255,255,255,0.1);
            border: none;
            border-radius: 8px;
            color: rgba(255,255,255,0.7);
            font-size: 0.8rem;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .btn-back-main:hover {
            background: rgba(255,255,255,0.15);
            color: #fff;
            text-decoration: none;
        }

        /* ===== Main Content ===== */
        .discovery-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* Top Header */
        .discovery-header {
            background: #fff;
            padding: 16px 24px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .header-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-title h1 {
            font-size: 1.25rem;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
        }

        .header-title .page-badge {
            font-size: 0.7rem;
            background: #e0e7ff;
            color: var(--discovery-primary);
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 600;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-primary-discovery {
            background: linear-gradient(135deg, var(--discovery-primary), var(--discovery-primary-dark));
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .btn-primary-discovery:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
        }

        /* Content Area */
        .discovery-content {
            flex: 1;
            padding: 24px;
            overflow-y: auto;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .stat-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }

        .stat-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .stat-icon.primary { background: #e0e7ff; color: var(--discovery-primary); }
        .stat-icon.success { background: #d1fae5; color: var(--discovery-success); }
        .stat-icon.warning { background: #fef3c7; color: var(--discovery-warning); }
        .stat-icon.danger { background: #fee2e2; color: var(--discovery-danger); }

        .stat-icon i { font-size: 1.25rem; }

        .stat-trend {
            font-size: 0.75rem;
            padding: 4px 8px;
            border-radius: 20px;
        }

        .stat-trend.up { background: #d1fae5; color: #059669; }
        .stat-trend.down { background: #fee2e2; color: #dc2626; }

        .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 0.85rem;
            color: #64748b;
        }

        /* Content Panels */
        .content-panel {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 24px;
        }

        .panel-header {
            padding: 16px 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .panel-title {
            font-size: 1rem;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }

        .panel-body {
            padding: 20px;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }

        .empty-state-icon {
            width: 80px;
            height: 80px;
            background: #f1f5f9;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }

        .empty-state-icon i {
            font-size: 2rem;
            color: #94a3b8;
        }

        .empty-state h3 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #475569;
            margin-bottom: 8px;
        }

        .empty-state p {
            color: #94a3b8;
            font-size: 0.9rem;
            margin-bottom: 20px;
        }

        /* Table Styles */
        .discovery-table {
            width: 100%;
            border-collapse: collapse;
        }

        .discovery-table th {
            background: #f8fafc;
            padding: 12px 16px;
            text-align: left;
            font-size: 0.75rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid #e2e8f0;
        }

        .discovery-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.875rem;
            color: #334155;
        }

        .discovery-table tr:hover {
            background: #f8fafc;
        }

        /* Status Badge */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .status-badge.running { background: #dbeafe; color: #1d4ed8; }
        .status-badge.completed { background: #d1fae5; color: #059669; }
        .status-badge.pending { background: #fef3c7; color: #d97706; }
        .status-badge.failed { background: #fee2e2; color: #dc2626; }

        .status-badge i { font-size: 0.6rem; }

        /* Score Badge */
        .score-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .score-badge.high { background: #fee2e2; color: #dc2626; }
        .score-badge.medium { background: #fef3c7; color: #d97706; }
        .score-badge.low { background: #d1fae5; color: #059669; }
    </style>
</head>
<body>
    <div class="discovery-wrapper">
        <!-- Sidebar -->
        <aside class="discovery-sidebar">
            <div class="sidebar-header">
                <a href="/piidiscovery/index" class="sidebar-brand">
                    <div class="sidebar-brand-icon">
                        <i class="fas fa-magnifying-glass-chart"></i>
                    </div>
                    <span class="sidebar-brand-text">개인정보 탐지</span>
                </a>
            </div>

            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">메인</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link active" data-page="dashboard">
                            <i class="fas fa-chart-pie"></i>
                            <span>대시보드</span>
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="jobs">
                            <i class="fas fa-play-circle"></i>
                            <span>스캔 작업</span>
                            <span class="nav-badge">3</span>
                        </a>
                    </div>
                </div>

                <div class="nav-section">
                    <div class="nav-section-title">분석</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="results">
                            <i class="fas fa-magnifying-glass-chart"></i>
                            <span>탐지 결과</span>
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="columns">
                            <i class="fas fa-table-columns"></i>
                            <span>개인정보 컬럼</span>
                        </a>
                    </div>
                </div>

                <div class="nav-section">
                    <div class="nav-section-title">설정</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="rules">
                            <i class="fas fa-sliders"></i>
                            <span>탐지 규칙</span>
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="settings">
                            <i class="fas fa-gear"></i>
                            <span>환경설정</span>
                        </a>
                    </div>
                </div>
            </nav>

            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="user-details">
                        <div class="user-name"><sec:authentication property="principal.member.userName"/></div>
                        <div class="user-role">관리자</div>
                    </div>
                </div>
                <a href="/index" class="btn-back-main">
                    <i class="fas fa-arrow-left"></i>
                    X-One으로 돌아가기
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="discovery-main">
            <header class="discovery-header">
                <div class="header-title">
                    <h1 id="pageTitle">대시보드</h1>
                    <span class="page-badge">개인정보 탐지</span>
                </div>
                <div class="header-actions">
                </div>
            </header>

            <div class="discovery-content" id="contentArea">
                <!-- Dashboard content will be loaded via AJAX -->
                <div class="text-center" style="padding: 60px 0;">
                    <i class="fas fa-spinner fa-spin fa-2x" style="color: #667eea;"></i>
                </div>
            </div>
        </main>
    </div>

    <!-- New Scan Modal (Compact Layout) -->
    <div class="modal fade" id="newScanModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header" style="border-bottom: 1px solid #e2e8f0; padding: 16px 24px;">
                    <h5 class="modal-title" style="font-weight: 600; color: #1e293b;">
                        <i class="fas fa-radar" style="color: var(--discovery-primary); margin-right: 10px;"></i>
                        새 스캔 작업
                    </h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="padding: 20px 24px;">
                    <form id="newScanForm">
                        <div class="row">
                            <!-- Left Column: Basic Settings -->
                            <div class="col-md-6" style="border-right: 1px solid #e2e8f0; padding-right: 24px;">
                                <h6 style="font-weight: 600; color: #1e293b; margin-bottom: 16px;">
                                    <i class="fas fa-cog text-primary"></i> 기본 설정
                                </h6>

                                <div class="row mb-3">
                                    <div class="col-8">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">작업명 *</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control" id="jobName" name="jobName" required placeholder="<spring:message code='discovery.auto_generated' text='자동 생성됨'/>">
                                            <div class="input-group-append">
                                                <button type="button" class="btn btn-outline-secondary" onclick="generateJobName()" title="<spring:message code='discovery.auto_generate' text='자동 생성'/>">
                                                    <i class="fas fa-magic"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">스레드</label>
                                        <input type="number" class="form-control" id="threadCount" name="threadCount" value="5" min="1" max="20">
                                    </div>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-8">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">대상 데이터베이스 *</label>
                                        <select class="form-control" id="targetDb" name="targetDb" required onchange="loadSchemaList()">
                                            <option value="">데이터베이스 선택...</option>
                                        </select>
                                    </div>
                                    <div class="col-4">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">샘플 크기</label>
                                        <input type="number" class="form-control" id="sampleSize" name="sampleSize" value="1000" min="100" max="10000">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">대상 스키마</label>
                                    <div id="schemaListContainer" style="max-height: 100px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px; background: #f8fafc;">
                                        <span class="text-muted"><i class="fas fa-info-circle"></i> <spring:message code="discovery.select_db_first" text="Select DB first"/></span>
                                    </div>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-7">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">대상 테이블</label>
                                        <input type="text" class="form-control text-uppercase" id="targetTables" name="targetTables" placeholder="* or TB_%" style="text-transform: uppercase;">
                                    </div>
                                    <div class="col-5">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">스캔 모드</label>
                                        <select class="form-control" id="scanModeSelect" onchange="$('#scanMode' + this.value).prop('checked', true); toggleSkipConfirmedOption();">
                                            <option value="Full">Full (전체 스캔)</option>
                                            <option value="New">New (신규만 스캔)</option>
                                        </select>
                                        <input type="radio" class="d-none" id="scanModeFull" name="scanMode" value="FULL" checked>
                                        <input type="radio" class="d-none" id="scanModeNew" name="scanMode" value="NEW">
                                    </div>
                                </div>

                                <!-- Detection Methods -->
                                <div style="background: #f0f9ff; border-radius: 8px; padding: 14px; border: 1px solid #bae6fd;">
                                    <label style="font-weight: 600; color: #0369a1; margin-bottom: 10px; display: block;">
                                        <i class="fas fa-search"></i> 탐지 방법
                                    </label>
                                    <div class="d-flex flex-wrap" style="gap: 20px;">
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="enableMeta" name="enableMeta" checked>
                                            <label class="custom-control-label" for="enableMeta">
                                                <i class="fas fa-tags text-primary"></i> 메타데이터 분석
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="enablePattern" name="enablePattern" checked onchange="toggleSampleSize()">
                                            <label class="custom-control-label" for="enablePattern">
                                                <i class="fas fa-fingerprint text-success"></i> 패턴 매칭
                                            </label>
                                        </div>
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="enableAi" name="enableAi" disabled>
                                            <label class="custom-control-label" for="enableAi" style="color: #94a3b8;">
                                                <i class="fas fa-brain"></i> AI <span class="badge badge-secondary" style="font-size: 0.65rem;">Soon</span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column: Smart Filtering -->
                            <div class="col-md-6" style="padding-left: 24px;">
                                <h6 style="font-weight: 600; color: #1e293b; margin-bottom: 16px;">
                                    <i class="fas fa-filter text-warning"></i> 스마트 필터링 (제외 조건)
                                </h6>

                                <div class="mb-3">
                                    <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">제외 데이터 타입</label>
                                    <input type="text" class="form-control text-uppercase" id="excludeDataTypes" placeholder="NUMBER,DATE,TIMESTAMP,BLOB,CLOB" style="text-transform: uppercase;">
                                    <small class="text-muted">쉼표로 구분 (미입력 시 기본값 적용)</small>
                                </div>

                                <div class="row mb-3">
                                    <div class="col-6">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">최소 컬럼 길이</label>
                                        <input type="number" class="form-control" id="minColumnLength" value="2" min="1" max="10">
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">최대 컬럼 길이</label>
                                        <input type="number" class="form-control" id="maxColumnLength" value="4000" min="100">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label" style="font-weight: 500; margin-bottom: 6px;">제외 컬럼 패턴</label>
                                    <input type="text" class="form-control text-uppercase" id="excludePatterns" placeholder="*_CD,*_YN,*_FLAG,*_SEQ,REG_DATE,UPD_DATE" style="text-transform: uppercase;">
                                    <small class="text-muted">* = 와일드카드 (예: *_YN → _YN으로 끝나는 컬럼 제외)</small>
                                </div>

                                <div style="background: #fef3c7; border-radius: 8px; padding: 14px; border: 1px solid #fcd34d;">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="skipConfirmedPii" checked>
                                        <label class="custom-control-label" for="skipConfirmedPii" style="font-weight: 500;">
                                            <i class="fas fa-forward text-warning"></i> 확인된 개인정보 컬럼 건너뛰기
                                        </label>
                                    </div>
                                    <small class="text-muted d-block" style="margin-left: 24px; margin-top: 4px;">이미 확인된 컬럼은 재스캔하지 않습니다</small>
                                </div>

                                <!-- Quick Presets -->
                                <div class="mt-4">
                                    <label class="form-label" style="font-weight: 500; margin-bottom: 8px;">빠른 설정</label>
                                    <div class="d-flex" style="gap: 10px;">
                                        <button type="button" class="btn btn-outline-secondary" onclick="applyPreset('default')"
                                                data-toggle="tooltip" data-placement="bottom" data-html="true"
                                                title="<b>기본 설정</b><br>Sample: 1,000건<br>Threads: 5개<br>컬럼길이: 2~4,000<br>제외 패턴 없음">
                                            <i class="fas fa-cog"></i> 기본
                                        </button>
                                        <button type="button" class="btn btn-outline-primary" onclick="applyPreset('thorough')"
                                                data-toggle="tooltip" data-placement="bottom" data-html="true"
                                                title="<b>정밀 검사</b><br>Sample: 5,000건<br>Threads: 3개<br>컬럼길이: 1~10,000<br>확정 PII도 재스캔">
                                            <i class="fas fa-search-plus"></i> 정밀검사
                                        </button>
                                        <button type="button" class="btn btn-outline-success" onclick="applyPreset('fast')"
                                                data-toggle="tooltip" data-placement="bottom" data-html="true"
                                                title="<b>빠른 검사</b><br>Sample: 500건<br>Threads: 10개<br>컬럼길이: 3~2,000<br>숫자/날짜/코드성 컬럼 제외">
                                            <i class="fas fa-bolt"></i> 빠른검사
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 14px 24px;">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" id="btnSubmitJob" onclick="createScanJob()" style="background: var(--discovery-primary); border-color: var(--discovery-primary);">
                        <i class="fas fa-plus"></i> 작업 생성
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scan Progress Modal -->
    <div class="modal fade" id="progressModal" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content" style="border-radius: 12px; border: none;">
                <div class="modal-header" style="border-bottom: 1px solid #e2e8f0; padding: 20px 24px;">
                    <h5 class="modal-title" style="font-weight: 600; color: #1e293b;">
                        <i class="fas fa-radar fa-spin" id="progressSpinner" style="color: var(--discovery-primary); margin-right: 10px;"></i>
                        <span id="progressTitle">스캔 진행</span>
                    </h5>
                    <button type="button" class="close" id="closeProgressBtn" style="display: none;" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <!-- Status Header -->
                    <div class="d-flex align-items-center justify-content-between mb-4">
                        <div>
                            <span class="status-badge" id="progressStatusBadge">
                                <i class="fas fa-circle"></i> <span id="progressStatusText">실행중</span>
                            </span>
                        </div>
                        <div class="text-right">
                            <small class="text-muted">
                                <i class="fas fa-clock"></i> <spring:message code="discovery.elapsed" text="경과"/>: <span id="progressElapsed">0s</span>
                                &nbsp;|&nbsp;
                                <i class="fas fa-hourglass-half"></i> <spring:message code="discovery.remaining_time" text="남은 시간"/>: <span id="progressRemaining"><spring:message code="discovery.calculating" text="계산중..."/></span>
                            </small>
                        </div>
                    </div>

                    <!-- Progress Bar -->
                    <div class="mb-4">
                        <div class="d-flex justify-content-between mb-2">
                            <span style="font-weight: 500; color: #475569;"><spring:message code="discovery.overall_progress" text="전체 진행률"/></span>
                            <span id="progressPercent" style="font-weight: 600; color: var(--discovery-primary);">0%</span>
                        </div>
                        <div class="progress" style="height: 24px; border-radius: 12px; background: #e2e8f0;">
                            <div class="progress-bar" id="progressBar" role="progressbar" style="width: 0%; background: linear-gradient(135deg, var(--discovery-primary), var(--discovery-secondary)); border-radius: 12px; transition: width 0.3s ease;"></div>
                        </div>
                    </div>

                    <!-- Current Table -->
                    <div class="mb-4 p-3" style="background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0;">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-table" style="color: var(--discovery-primary); margin-right: 12px; font-size: 1.2rem;"></i>
                            <div>
                                <small class="text-muted d-block"><spring:message code="discovery.current_scanning_table" text="현재 스캔 중인 테이블"/></small>
                                <strong id="progressCurrentTable" style="color: #1e293b;">-</strong>
                            </div>
                        </div>
                    </div>

                    <!-- Stats Grid -->
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="text-center p-3" style="background: #eff6ff; border-radius: 8px;">
                                <div style="font-size: 1.5rem; font-weight: 700; color: #1d4ed8;" id="progressScannedTables">0</div>
                                <small class="text-muted"><spring:message code="discovery.scan_completed" text="스캔 완료"/></small>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="text-center p-3" style="background: #fef3c7; border-radius: 8px;">
                                <div style="font-size: 1.5rem; font-weight: 700; color: #d97706;" id="progressRemainingTables">0</div>
                                <small class="text-muted"><spring:message code="discovery.scan_remaining" text="남은 테이블"/></small>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="text-center p-3" style="background: #f1f5f9; border-radius: 8px;">
                                <div style="font-size: 1.5rem; font-weight: 700; color: #475569;" id="progressTotalColumns">0</div>
                                <small class="text-muted"><spring:message code="discovery.column_scanned" text="컬럼 스캔"/></small>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="text-center p-3" style="background: #fee2e2; border-radius: 8px;">
                                <div style="font-size: 1.5rem; font-weight: 700; color: #dc2626;" id="progressPiiCount">0</div>
                                <small class="text-muted"><spring:message code="discovery.pii_detected" text="PII 탐지"/></small>
                            </div>
                        </div>
                    </div>

                    <!-- Table List -->
                    <div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span style="font-weight: 500; color: #475569;">
                                <i class="fas fa-list"></i> <spring:message code="discovery.table_list" text="테이블 목록"/>
                            </span>
                            <small class="text-muted">
                                <span id="progressTableCount">0</span> <spring:message code="discovery.table_count" text="테이블"/>
                            </small>
                        </div>
                        <div id="tableListContainer" style="max-height: 250px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
                            <table class="table table-sm mb-0" style="font-size: 0.85rem;">
                                <thead style="background: #f8fafc; position: sticky; top: 0;">
                                    <tr>
                                        <th style="width: 40px;"></th>
                                        <th><spring:message code="discovery.schema" text="스키마"/></th>
                                        <th><spring:message code="discovery.table" text="테이블"/></th>
                                        <th style="text-align: center;"><spring:message code="discovery.column" text="컬럼"/></th>
                                        <th style="text-align: center;"><spring:message code="discovery.pii" text="PII"/></th>
                                        <th style="text-align: right;"><spring:message code="discovery.time" text="시간"/></th>
                                    </tr>
                                </thead>
                                <tbody id="tableListBody">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">
                                            <i class="fas fa-spinner fa-spin"></i> <spring:message code="discovery.table_list_loading" text="테이블 목록 로딩중..."/>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Error Message -->
                    <div id="progressErrorContainer" class="mt-3" style="display: none;">
                        <div class="alert alert-danger mb-0">
                            <i class="fas fa-exclamation-triangle"></i>
                            <span id="progressErrorMsg"></span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #e2e8f0; padding: 16px 24px;">
                    <button type="button" class="btn btn-danger" id="cancelScanBtn" onclick="cancelCurrentScanByExecution()">
                        <i class="fas fa-stop"></i> <spring:message code="discovery.cancel_scan" text="스캔 취소"/>
                    </button>
                    <button type="button" class="btn btn-secondary" id="closeProgressModalBtn" style="display: none;" data-dismiss="modal">
                        <spring:message code="discovery.close" text="닫기"/>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="/resources/vendor/jquery/jquery.min.js"></script>
    <script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="/resources/vendor/chart.js/chart.umd.min.js"></script>

    <script>
        // Context Path & CSRF Token
        var contextPath = '${pageContext.request.contextPath}';
        var csrfToken = $('meta[name="_csrf"]').attr('content');
        var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

        // i18n Messages for JavaScript
        var i18n = {
            selectDbFirst: '<spring:message code="discovery.select_db_first" text="DB를 먼저 선택하세요" javaScriptEscape="true"/>',
            calculating: '<spring:message code="discovery.calculating" text="계산중..." javaScriptEscape="true"/>',
            scanCompleted: '<spring:message code="discovery.scan_completed" text="스캔 완료" javaScriptEscape="true"/>',
            scanFailed: '<spring:message code="discovery.scan_failed" text="스캔 실패" javaScriptEscape="true"/>',
            scanCancelled: '<spring:message code="discovery.scan_cancelled" text="스캔 취소됨" javaScriptEscape="true"/>',
            scanning: '스캔중',
            completed: '완료',
            failed: '실패',
            cancelled: '취소됨',
            tableListLoading: '<spring:message code="discovery.table_list_loading" text="테이블 목록 로딩중..." javaScriptEscape="true"/>',
            cancelScan: '<spring:message code="discovery.cancel_scan" text="스캔 취소" javaScriptEscape="true"/>',
            cancelScanConfirm: '<spring:message code="discovery.cancel_scan_confirm" text="스캔을 취소하시겠습니까?" javaScriptEscape="true"/>',
            cancel: '<spring:message code="discovery.cancel" text="취소" javaScriptEscape="true"/>',
            confirm: '<spring:message code="discovery.confirm" text="확인" javaScriptEscape="true"/>',
            proceed: '<spring:message code="discovery.proceed" text="진행하시겠습니까?" javaScriptEscape="true"/>',
            jobCreated: '<spring:message code="discovery.job_created" text="Job이 생성되었습니다. Scan Jobs에서 실행할 수 있습니다." javaScriptEscape="true"/>',
            jobUpdated: '<spring:message code="discovery.job_updated" text="Job이 수정되었습니다" javaScriptEscape="true"/>',
            deleteJob: '<spring:message code="discovery.delete_job" text="Scan Job 삭제" javaScriptEscape="true"/>',
            deleteJobConfirm: '<spring:message code="discovery.delete_job_confirm" text="이 Scan Job을 삭제하시겠습니까?" javaScriptEscape="true"/>',
            delete_: '<spring:message code="discovery.delete" text="삭제" javaScriptEscape="true"/>',
            warning: '<spring:message code="discovery.warning" text="주의" javaScriptEscape="true"/>',
            continue_: '<spring:message code="discovery.continue" text="계속" javaScriptEscape="true"/>',
            deleteConfirm: '<spring:message code="discovery.delete_confirm" text="삭제 확인" javaScriptEscape="true"/>'
        };

        $(document).ready(function() {
            // Initialize tooltips
            $('[data-toggle="tooltip"]').tooltip();

            // Load dashboard content via AJAX on initial page load
            loadPageContent('dashboard');

            // Navigation handling
            $('.nav-link').click(function(e) {
                e.preventDefault();
                var page = $(this).data('page');

                // Update active state
                $('.nav-link').removeClass('active');
                $(this).addClass('active');

                // Update page title
                var titles = {
                    'dashboard': '대시보드',
                    'jobs': '스캔 작업',
                    'results': '탐지 결과',
                    'columns': '개인정보 컬럼',
                    'rules': '탐지 규칙',
                    'settings': '환경설정'
                };
                $('#pageTitle').text(titles[page] || page);

                // Load content
                loadPageContent(page);
            });

        });

        // Pattern Matching 체크에 따라 Sample Size 활성화/비활성화
        function toggleSampleSize() {
            var isPatternEnabled = $('#enablePattern').is(':checked');
            $('#sampleSize').prop('disabled', !isPatternEnabled);
            if (isPatternEnabled) {
                $('#sampleSize').css('opacity', '1');
            } else {
                $('#sampleSize').css('opacity', '0.5');
            }
        }

        // Settings에서 기본값 로드
        function loadDefaultJobSettings() {
            // 기본값 설정 (API 실패 시 사용)
            var defaults = {
                'default.sample_size': '1000',
                'default.thread_count': '4',
                'default.min_column_length': '2',
                'default.exclude_data_types': 'NUMBER,INT,INTEGER,BIGINT,FLOAT,DOUBLE,DECIMAL,DATE,DATETIME,TIMESTAMP,BLOB,CLOB,RAW,LONG',
                'default.exclude_patterns': '*_CD,*_YN,*_FLAG,*_TYPE,*_SEQ,*_IDX,*_CNT,*_AMT,REG_DATE,UPD_DATE,DEL_YN',
                'default.enable_meta': 'Y',
                'default.enable_pattern': 'Y',
                'default.skip_confirmed': 'Y'
            };

            // 기본값 적용
            function applyDefaults(configs) {
                var configMap = {};
                if (configs) {
                    configs.forEach(function(c) { configMap[c.configKey] = c.configValue; });
                }

                $('#sampleSize').val(configMap['default.sample_size'] || defaults['default.sample_size']);
                $('#threadCount').val(configMap['default.thread_count'] || defaults['default.thread_count']);
                $('#minColumnLength').val(configMap['default.min_column_length'] || defaults['default.min_column_length']);
                $('#maxColumnLength').val(4000);
                $('#excludeDataTypes').val(configMap['default.exclude_data_types'] || defaults['default.exclude_data_types']);
                $('#excludePatterns').val(configMap['default.exclude_patterns'] || defaults['default.exclude_patterns']);
                $('#enableMeta').prop('checked', (configMap['default.enable_meta'] || defaults['default.enable_meta']) === 'Y');
                $('#enablePattern').prop('checked', (configMap['default.enable_pattern'] || defaults['default.enable_pattern']) === 'Y');
                $('#enableAi').prop('checked', false);
                $('#skipConfirmedPii').prop('checked', (configMap['default.skip_confirmed'] || defaults['default.skip_confirmed']) === 'Y');
            }

            // API에서 설정 로드
            $.get(contextPath + '/piidiscovery/api/configs', function(configs) {
                applyDefaults(configs);
            }).fail(function() {
                applyDefaults(null);
            });
        }

        // Quick Preset 적용
        function applyPreset(preset) {
            switch (preset) {
                case 'default':
                    $('#sampleSize').val(1000);
                    $('#threadCount').val(5);
                    $('#excludeDataTypes').val('');
                    $('#minColumnLength').val(2);
                    $('#maxColumnLength').val(4000);
                    $('#excludePatterns').val('');
                    $('#enableMeta').prop('checked', true);
                    $('#enablePattern').prop('checked', true);
                    $('#skipConfirmedPii').prop('checked', true);
                    break;
                case 'thorough':
                    $('#sampleSize').val(5000);
                    $('#threadCount').val(3);
                    $('#excludeDataTypes').val('');
                    $('#minColumnLength').val(1);
                    $('#maxColumnLength').val(10000);
                    $('#excludePatterns').val('');
                    $('#enableMeta').prop('checked', true);
                    $('#enablePattern').prop('checked', true);
                    $('#skipConfirmedPii').prop('checked', false);
                    break;
                case 'fast':
                    $('#sampleSize').val(500);
                    $('#threadCount').val(10);
                    $('#excludeDataTypes').val('NUMBER,DATE,TIMESTAMP,BLOB,CLOB,LONG,RAW');
                    $('#minColumnLength').val(3);
                    $('#maxColumnLength').val(2000);
                    $('#excludePatterns').val('*_CD,*_YN,*_FLAG,*_SEQ,*_ID,REG_DATE,UPD_DATE,CREATE_,UPDATE_');
                    $('#enableMeta').prop('checked', true);
                    $('#enablePattern').prop('checked', true);
                    $('#skipConfirmedPii').prop('checked', true);
                    break;
            }
            toggleSampleSize();
            toggleSkipConfirmedOption();
        }

        // Scan Mode 변경 시 Skip Confirmed 옵션 토글
        function toggleSkipConfirmedOption() {
            var scanMode = $('#scanModeSelect').val();
            var $skipOption = $('#skipConfirmedPii');
            var $skipContainer = $skipOption.closest('.custom-control');

            if (scanMode === 'New') {
                // NEW 모드: Skip Confirmed 자동 체크 및 비활성화 (신규만 스캔하므로 의미 없음)
                $skipOption.prop('checked', true).prop('disabled', true);
                $skipContainer.css('opacity', '0.5');
                $skipContainer.attr('title', 'NEW 모드에서는 신규 컬럼만 스캔하므로 이 옵션이 자동 적용됩니다.');
            } else {
                // FULL 모드: 옵션 활성화
                $skipOption.prop('disabled', false);
                $skipContainer.css('opacity', '1');
                $skipContainer.removeAttr('title');
            }
        }

        // Job Name 자동 생성
        function generateJobName(showAlert) {
            var dbName = $('#targetDb').val();
            if (!dbName) {
                if (showAlert !== false) {
                    alert(i18n.selectDbFirst);
                }
                return;
            }

            // 현재 날짜/시간
            var now = new Date();
            var dateStr = now.getFullYear().toString() +
                          ('0' + (now.getMonth() + 1)).slice(-2) +
                          ('0' + now.getDate()).slice(-2);
            var timeStr = ('0' + now.getHours()).slice(-2) +
                          ('0' + now.getMinutes()).slice(-2);

            // 스캔 모드
            var scanMode = $('input[name="scanMode"]:checked').val() || 'FULL';
            var modeStr = scanMode === 'NEW' ? 'NEW' : 'FULL';

            // Job Name 생성: DB명_PII_모드_YYYYMMDD_HHMM
            var jobName = dbName.toUpperCase() + '_PII_' + modeStr + '_' + dateStr + '_' + timeStr;
            $('#jobName').val(jobName);
        }

        // 현재 Execution ID 저장 (Results 페이지용)
        var currentExecutionId = null;

        function loadPageContent(page, params) {
            // 모든 모달과 backdrop 정리 (블랙아웃 방지)
            $('.modal').modal('hide');
            $('.modal-backdrop').remove();
            $('body').removeClass('modal-open').css('padding-right', '');

            // 모든 페이지를 AJAX로 로드
            var url = contextPath + '/piidiscovery/' + page;

            // 파라미터가 있으면 쿼리스트링 추가
            if (params) {
                var queryString = $.param(params);
                if (queryString) {
                    url += '?' + queryString;
                }
            }

            $('#contentArea').load(url, function(response, status, xhr) {
                if (status == "error") {
                    console.log("Error loading page: " + page);
                }
                // 대시보드 로드 완료 후 통계 AJAX 업데이트
                if (page === 'dashboard') {
                    loadDashboardStats();
                }
            });
        }

        // Results 페이지로 이동 (특정 Execution 표시)
        function navigateToResults(executionId) {
            currentExecutionId = executionId;

            // Update nav state
            $('.nav-link').removeClass('active');
            $('.nav-link[data-page="results"]').addClass('active');
            $('#pageTitle').text('탐지 결과');

            // Load results page with execution ID
            loadPageContent('results', { executionId: executionId });
        }

        function loadDashboardStats() {
            $.ajax({
                url: contextPath + '/piidiscovery/api/stats',
                type: 'GET',
                success: function(data) {
                    if (data) {
                        updateDashboardStats(data);
                    }
                },
                error: function(xhr, status, error) {
                    console.log('Error loading stats:', error);
                }
            });
        }

        function updateDashboardStats(stats) {
            var $statValues = $('.stat-value');
            if ($statValues.length >= 4) {
                $statValues.eq(0).text(stats.totalTablesScanned || 0);
                $statValues.eq(1).text(stats.piiColumnsDetected || 0);
                $statValues.eq(2).text(stats.confirmedPii || 0);
                $statValues.eq(3).text(stats.pendingReview || 0);
            }
        }

        function showNewScanModal() {
            // Load database list
            $.ajax({
                url: contextPath + '/piidiscovery/api/databases',
                type: 'GET',
                success: function(data) {
                    var $select = $('#targetDb');
                    $select.empty();
                    $select.append('<option value="">Select database...</option>');
                    if (data && data.length > 0) {
                        data.forEach(function(db) {
                            $select.append('<option value="' + db.db + '">' + db.db + ' (' + db.dbtype + ')</option>');
                        });
                    }
                },
                error: function(xhr, status, error) {
                    console.log('Error loading databases:', error);
                }
            });

            // Reset form
            $('#newScanForm')[0].reset();
            $('#newScanForm').removeData('editJobId'); // Clear edit mode
            $('#scanModeFull').prop('checked', true);
            $('#scanModeSelect').val('Full');
            toggleSkipConfirmedOption();
            $('#schemaListContainer').html('<span class="text-muted"><i class="fas fa-info-circle"></i> Select DB first</span>');
            $('.modal-title').html('<i class="fas fa-radar" style="color: var(--discovery-primary); margin-right: 10px;"></i>새 스캔 작업');
            $('#btnSubmitJob').html('<i class="fas fa-plus"></i> Create Job');

            // Load default values from Settings
            loadDefaultJobSettings();
            toggleSampleSize();

            // Show modal and reinitialize tooltips
            $('#newScanModal').modal('show');
            setTimeout(function() {
                $('[data-toggle="tooltip"]').tooltip();
            }, 300);
        }

        function loadSchemaList() {
            var dbName = $('#targetDb').val();
            if (!dbName) {
                $('#schemaListContainer').html('<div class="text-muted" style="font-size: 0.85rem;"><i class="fas fa-info-circle"></i> Select a database first to load schemas</div>');
                return;
            }

            // DB 선택 시 Job Name 자동 생성
            if (!$('#jobName').val()) {
                generateJobName();
            }

            $('#schemaListContainer').html('<div class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading schemas...</div>');

            $.ajax({
                url: contextPath + '/piidiscovery/api/schemas/' + dbName,
                type: 'GET',
                success: function(data) {
                    var html = '';
                    if (data && data.length > 0) {
                        data.forEach(function(schema, index) {
                            html += '<div class="custom-control custom-checkbox" style="margin-bottom: 4px;">';
                            html += '<input type="checkbox" class="custom-control-input schema-checkbox" id="schema_' + index + '" value="' + schema + '">';
                            html += '<label class="custom-control-label" for="schema_' + index + '" style="font-size: 0.9rem;">' + schema + '</label>';
                            html += '</div>';
                        });
                    } else {
                        html = '<div class="text-muted" style="font-size: 0.85rem;"><i class="fas fa-info-circle"></i> No schemas found or using default schema</div>';
                    }
                    $('#schemaListContainer').html(html);
                },
                error: function(xhr, status, error) {
                    $('#schemaListContainer').html('<div class="text-warning" style="font-size: 0.85rem;"><i class="fas fa-exclamation-triangle"></i> Could not load schemas. You can enter manually or leave empty.</div>');
                }
            });
        }

        function createScanJob() {
            // Collect selected schemas
            var selectedSchemas = [];
            $('.schema-checkbox:checked').each(function() {
                selectedSchemas.push($(this).val());
            });

            var formData = {
                jobName: $('#jobName').val(),
                targetDb: $('#targetDb').val(),
                targetSchema: selectedSchemas.join(','),  // Comma-separated list
                targetTables: $('#targetTables').val() || '*',
                scanMode: $('input[name="scanMode"]:checked').val(),
                sampleSize: parseInt($('#sampleSize').val()) || 1000,
                threadCount: parseInt($('#threadCount').val()) || 5,
                enableMeta: $('#enableMeta').is(':checked') ? 'Y' : 'N',
                enablePattern: $('#enablePattern').is(':checked') ? 'Y' : 'N',
                enableAi: $('#enableAi').is(':checked') ? 'Y' : 'N',
                // Smart Filtering
                excludeDataTypes: $('#excludeDataTypes').val(),
                minColumnLength: parseInt($('#minColumnLength').val()) || 2,
                maxColumnLength: parseInt($('#maxColumnLength').val()) || 4000,
                excludePatterns: $('#excludePatterns').val(),
                skipConfirmedPii: $('#skipConfirmedPii').is(':checked') ? 'Y' : 'N'
            };

            // Validation
            if (!formData.jobName) {
                alert('Job name is required');
                return;
            }
            if (!formData.targetDb) {
                alert('Target database is required');
                return;
            }

            // Check if this is an edit operation
            var editJobId = $('#newScanForm').data('editJobId');
            var isEdit = !!editJobId;
            var url = contextPath + '/piidiscovery/api/jobs';
            var method = 'POST';

            if (isEdit) {
                url = contextPath + '/piidiscovery/api/jobs/' + editJobId;
                method = 'PUT';
            }

            $.ajax({
                url: url,
                type: method,
                contentType: 'application/json',
                data: JSON.stringify(formData),
                beforeSend: function(xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function(result) {
                    if (result.success) {
                        $('#newScanModal').modal('hide');
                        // Clear edit mode
                        $('#newScanForm').removeData('editJobId');

                        if (isEdit) {
                            showToast('success', i18n.jobUpdated);
                        } else {
                            showToast('success', i18n.jobCreated);
                        }
                        // Navigate to jobs page
                        $('.nav-link[data-page="jobs"]').click();
                    } else {
                        alert('Error: ' + result.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Error ' + (isEdit ? 'updating' : 'creating') + ' scan job: ' + error);
                }
            });
        }

        function showToast(type, message) {
            var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : '#f59e0b');
            var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
            $('body').append(toast);
            setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
        }

        function deleteScanJob(jobId) {
            showConfirmModal({
                type: 'danger',
                title: i18n.deleteJob,
                message: i18n.deleteJobConfirm,
                confirmText: i18n.delete_
            }).then(function(confirmed) {
                if (!confirmed) return;

                $.ajax({
                    url: contextPath + '/piidiscovery/api/jobs/' + jobId,
                    type: 'DELETE',
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    },
                    success: function(result) {
                        if (result.success) {
                            loadPageContent('jobs');
                        } else {
                            alert('Error: ' + result.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Error deleting scan job: ' + error);
                    }
                });
            });
        }

        function confirmResult(resultId, status) {
            $.ajax({
                url: contextPath + '/piidiscovery/api/results/' + resultId + '/confirm?status=' + status,
                type: 'POST',
                beforeSend: function(xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function(result) {
                    if (result.success) {
                        loadPageContent('results');
                    } else {
                        alert('Error: ' + result.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Error confirming result: ' + error);
                }
            });
        }

        // ========== Progress Tracking ==========
        var currentJobId = null;
        var progressPollingInterval = null;

        function showProgressModal(jobId) {
            currentJobId = jobId;

            // Reset modal state
            $('#progressSpinner').show();
            $('#closeProgressBtn').hide();
            $('#cancelScanBtn').show();
            $('#closeProgressModalBtn').hide();
            $('#progressErrorContainer').hide();
            $('#progressBar').css('width', '0%');
            $('#progressPercent').text('0%');
            $('#progressStatusBadge').removeClass('completed failed cancelled').addClass('running');
            $('#progressStatusText').text('Running');
            $('#progressCurrentTable').text('...');
            $('#progressScannedTables').text('0');
            $('#progressRemainingTables').text('0');
            $('#progressTotalColumns').text('0');
            $('#progressPiiCount').text('0');
            $('#progressElapsed').text('0s');
            $('#progressRemaining').text(i18n.calculating);
            $('#tableListBody').html('<tr><td colspan="6" class="text-center text-muted py-4"><i class="fas fa-spinner fa-spin"></i> ' + i18n.tableListLoading + '</td></tr>');

            $('#progressModal').modal('show');

            // Start polling
            startProgressPolling();
        }

        function startProgressPolling() {
            // Clear any existing interval
            if (progressPollingInterval) {
                clearInterval(progressPollingInterval);
            }

            // Initial fetch
            fetchProgress();

            // Poll every 1 second
            progressPollingInterval = setInterval(fetchProgress, 1000);
        }

        function stopProgressPolling() {
            if (progressPollingInterval) {
                clearInterval(progressPollingInterval);
                progressPollingInterval = null;
            }
        }

        function fetchProgress() {
            if (!currentExecutionId) return;

            $.ajax({
                url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/progress',
                type: 'GET',
                success: function(data) {
                    updateProgressUI(data);
                },
                error: function(xhr, status, error) {
                    console.log('Error fetching progress:', error);
                }
            });
        }

        function updateProgressUI(progress) {
            if (!progress) return;

            // Update progress bar
            var percent = progress.progress || 0;
            $('#progressBar').css('width', percent + '%');
            $('#progressPercent').text(percent + '%');

            // Update status badge
            var status = progress.status || 'RUNNING';
            $('#progressStatusBadge').removeClass('running completed failed cancelled');
            if (status === 'RUNNING') {
                $('#progressStatusBadge').addClass('running');
                $('#progressStatusText').text(i18n.scanning);
            } else if (status === 'COMPLETED') {
                $('#progressStatusBadge').addClass('completed');
                $('#progressStatusText').text(i18n.completed);
                onScanComplete();
            } else if (status === 'FAILED') {
                $('#progressStatusBadge').addClass('failed');
                $('#progressStatusText').text(i18n.failed);
                onScanFailed(progress.errorMsg);
            } else if (status === 'CANCELLED') {
                $('#progressStatusBadge').addClass('cancelled');
                $('#progressStatusText').text(i18n.cancelled);
                onScanCancelled();
            }

            // Update current table
            if (progress.currentTable) {
                var currentTableText = progress.currentTable;
                if (progress.currentSchema) {
                    currentTableText = progress.currentSchema + '.' + currentTableText;
                }
                $('#progressCurrentTable').text(currentTableText);
            } else if (status === 'COMPLETED') {
                $('#progressCurrentTable').text(i18n.scanCompleted);
            }

            // Update stats
            $('#progressScannedTables').text(progress.scannedTables || 0);
            $('#progressRemainingTables').text(progress.remainingTables || 0);
            $('#progressTotalColumns').text(progress.totalColumns || 0);
            $('#progressPiiCount').text(progress.piiCount || 0);
            $('#progressTableCount').text(progress.totalTables || 0);

            // Update time
            if (progress.elapsedSeconds !== undefined) {
                $('#progressElapsed').text(formatSeconds(progress.elapsedSeconds));
            }
            if (progress.estimatedRemaining) {
                $('#progressRemaining').text(progress.estimatedRemaining);
            }

            // Update table list
            if (progress.tableList && progress.tableList.length > 0) {
                updateTableList(progress.tableList);
            }
        }

        function updateTableList(tableList) {
            var html = '';
            tableList.forEach(function(table, index) {
                var statusIcon = '';
                var rowClass = '';

                switch (table.status) {
                    case 'COMPLETED':
                        statusIcon = '<i class="fas fa-check-circle text-success"></i>';
                        break;
                    case 'SCANNING':
                        statusIcon = '<i class="fas fa-spinner fa-spin text-primary"></i>';
                        rowClass = 'table-active';
                        break;
                    case 'SKIPPED':
                        statusIcon = '<i class="fas fa-minus-circle text-warning"></i>';
                        break;
                    default: // PENDING
                        statusIcon = '<i class="fas fa-circle text-muted" style="font-size: 0.6rem;"></i>';
                }

                var schemaName = table.schemaName || '-';
                var scanTime = table.scanTime ? (table.scanTime / 1000).toFixed(1) + 's' : '-';

                html += '<tr class="' + rowClass + '">';
                html += '<td style="text-align: center;">' + statusIcon + '</td>';
                html += '<td>' + schemaName + '</td>';
                html += '<td>' + table.tableName + '</td>';
                html += '<td style="text-align: center;">' + (table.columnCount || 0) + '</td>';
                html += '<td style="text-align: center;">' + (table.piiCount > 0 ? '<span class="badge badge-danger">' + table.piiCount + '</span>' : '0') + '</td>';
                html += '<td style="text-align: right;">' + scanTime + '</td>';
                html += '</tr>';
            });

            $('#tableListBody').html(html);

            // Scroll to current scanning row
            var $scanningRow = $('#tableListBody tr.table-active');
            if ($scanningRow.length > 0) {
                var container = $('#tableListContainer');
                var scrollTo = $scanningRow.offset().top - container.offset().top + container.scrollTop() - 100;
                container.animate({ scrollTop: scrollTo }, 200);
            }
        }

        function formatSeconds(seconds) {
            if (seconds < 60) {
                return seconds + 's';
            } else if (seconds < 3600) {
                var mins = Math.floor(seconds / 60);
                var secs = seconds % 60;
                return mins + 'm ' + secs + 's';
            } else {
                var hours = Math.floor(seconds / 3600);
                var mins = Math.floor((seconds % 3600) / 60);
                return hours + 'h ' + mins + 'm';
            }
        }

        function onScanComplete() {
            stopProgressPolling();
            $('#progressSpinner').removeClass('fa-spin');
            $('#closeProgressBtn').show();
            $('#cancelScanBtn').hide();
            $('#closeProgressModalBtn').show();
            $('#progressCurrentTable').text(i18n.scanCompleted);

            // Refresh dashboard stats
            loadDashboardStats();
        }

        function onScanFailed(errorMsg) {
            stopProgressPolling();
            $('#progressSpinner').removeClass('fa-spin').removeClass('fa-radar').addClass('fa-exclamation-triangle').css('color', '#dc2626');
            $('#closeProgressBtn').show();
            $('#cancelScanBtn').hide();
            $('#closeProgressModalBtn').show();
            $('#progressCurrentTable').text(i18n.scanFailed);

            if (errorMsg) {
                $('#progressErrorMsg').text(errorMsg);
                $('#progressErrorContainer').show();
            }
        }

        function onScanCancelled() {
            stopProgressPolling();
            $('#progressSpinner').removeClass('fa-spin');
            $('#closeProgressBtn').show();
            $('#cancelScanBtn').hide();
            $('#closeProgressModalBtn').show();
            $('#progressCurrentTable').text(i18n.scanCancelled);
        }

        function cancelCurrentScan() {
            if (!currentExecutionId) return;

            showConfirmModal({
                type: 'warning',
                title: i18n.cancelScan,
                message: i18n.cancelScanConfirm,
                confirmText: i18n.cancel
            }).then(function(confirmed) {
                if (!confirmed) return;

                $.ajax({
                    url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/cancel',
                    type: 'POST',
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    },
                    success: function(result) {
                        if (result.success) {
                            // Status will be updated via polling
                        } else {
                            alert('Error: ' + result.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Error cancelling scan: ' + error);
                    }
                });
            });
        }

        // Update executeScanJob to show progress modal with executionId
        function executeScanJob(jobId) {
            $.ajax({
                url: contextPath + '/piidiscovery/api/jobs/' + jobId + '/execute',
                type: 'POST',
                beforeSend: function(xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function(result) {
                    if (result.success && result.executionId) {
                        console.log('Scan started - Job: ' + jobId + ', Execution: ' + result.executionId);
                        // Show progress modal with executionId
                        showProgressModalByExecution(result.executionId);
                    } else {
                        alert('Error: ' + (result.message || 'Failed to start scan'));
                    }
                },
                error: function(xhr, status, error) {
                    alert('Error executing scan: ' + error);
                }
            });
        }

        // Show progress modal by executionId
        function showProgressModalByExecution(executionId) {
            currentExecutionId = executionId;

            // Reset modal state
            $('#progressSpinner').show().addClass('fa-spin');
            $('#closeProgressBtn').hide();
            $('#cancelScanBtn').show();
            $('#closeProgressModalBtn').hide();
            $('#progressErrorContainer').hide();
            $('#progressBar').css('width', '0%').removeClass('bg-success bg-danger');
            $('#progressPercent').text('0%');
            $('#progressStatusBadge').removeClass('completed failed cancelled').addClass('running');
            $('#progressStatusText').text('Running');
            $('#progressCurrentTable').text('...');
            $('#progressScannedTables').text('0');
            $('#progressRemainingTables').text('0');
            $('#progressTotalColumns').text('0');
            $('#progressPiiCount').text('0');
            $('#progressElapsed').text('0s');
            $('#progressRemaining').text(i18n.calculating);
            $('#tableListBody').html('<tr><td colspan="6" class="text-center text-muted py-4"><i class="fas fa-spinner fa-spin"></i> ' + i18n.tableListLoading + '</td></tr>');

            $('#progressModal').modal('show');

            // Start polling with executionId
            startExecutionProgressPolling();
        }

        function startExecutionProgressPolling() {
            if (progressPollingInterval) {
                clearInterval(progressPollingInterval);
            }

            fetchExecutionProgress();
            progressPollingInterval = setInterval(fetchExecutionProgress, 1000);
        }

        function fetchExecutionProgress() {
            if (!currentExecutionId) return;

            $.ajax({
                url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/progress',
                type: 'GET',
                success: function(data) {
                    updateProgressUI(data);
                },
                error: function(xhr, status, error) {
                    console.log('Error fetching progress:', error);
                }
            });
        }

        function cancelCurrentScanByExecution() {
            if (!currentExecutionId) return;

            showConfirmModal({
                type: 'warning',
                title: i18n.cancelScan,
                message: i18n.cancelScanConfirm,
                confirmText: i18n.cancel
            }).then(function(confirmed) {
                if (!confirmed) return;

                $.ajax({
                    url: contextPath + '/piidiscovery/api/executions/' + currentExecutionId + '/cancel',
                    type: 'POST',
                    beforeSend: function(xhr) {
                        xhr.setRequestHeader(csrfHeader, csrfToken);
                    },
                    success: function(result) {
                        if (result.success) {
                            // Status will be updated via polling
                        } else {
                            alert('Error: ' + result.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Error cancelling scan: ' + error);
                    }
                });
            });
        }

        // Cleanup when modal is closed
        $('#progressModal').on('hidden.bs.modal', function() {
            stopProgressPolling();

            // 블랙아웃 방지: 모달 backdrop 완전히 제거
            setTimeout(function() {
                $('.modal-backdrop').remove();
                $('body').removeClass('modal-open').css('padding-right', '');
            }, 100);

            // Results 페이지로 이동 (스캔 완료 시)
            var wasExecutionId = currentExecutionId;
            currentJobId = null;
            currentExecutionId = null;

            // Reset spinner icon
            $('#progressSpinner').removeClass('fa-exclamation-triangle').addClass('fa-radar').css('color', 'var(--discovery-primary)');

            // 스캔 완료 후 Results 페이지로 이동
            if (wasExecutionId && $('#progressStatusText').text() === i18n.completed) {
                setTimeout(function() {
                    navigateToResults(wasExecutionId);
                }, 300);
            }
        });

        // newScanModal 닫힐 때도 backdrop 정리
        $('#newScanModal').on('hidden.bs.modal', function() {
            setTimeout(function() {
                if ($('.modal.show').length === 0) {
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open').css('padding-right', '');
                }
            }, 100);
        });
    </script>

    <!-- ========== Common Confirm Modal ========== -->
    <div class="modal fade" id="discoveryConfirmModal" tabindex="-1" role="dialog" data-backdrop="static">
        <div class="modal-dialog modal-dialog-centered" role="document" style="max-width: 420px;">
            <div class="modal-content" style="border: none; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                <div class="modal-body" style="padding: 0;">
                    <!-- Icon Section -->
                    <div id="confirmIconSection" style="padding: 32px 24px 16px; text-align: center;">
                        <div id="confirmIconWrapper" style="width: 72px; height: 72px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 16px;">
                            <i id="confirmIcon" class="fas fa-question" style="font-size: 32px;"></i>
                        </div>
                    </div>
                    <!-- Content Section -->
                    <div style="padding: 0 28px 28px; text-align: center;">
                        <h5 id="confirmTitle" style="font-size: 1.25rem; font-weight: 700; color: #1e293b; margin-bottom: 12px;"><spring:message code="discovery.confirm" text="확인"/></h5>
                        <p id="confirmMessage" style="color: #64748b; font-size: 0.95rem; line-height: 1.6; margin-bottom: 0; white-space: pre-line;"></p>
                    </div>
                    <!-- Button Section -->
                    <div style="padding: 0 24px 24px; display: flex; gap: 12px;">
                        <button type="button" class="btn" id="confirmCancelBtn" style="flex: 1; height: 46px; border-radius: 10px; font-weight: 600; font-size: 0.95rem; background: #f1f5f9; color: #475569; border: none;">
                            <spring:message code="discovery.cancel" text="취소"/>
                        </button>
                        <button type="button" class="btn" id="confirmOkBtn" style="flex: 1; height: 46px; border-radius: 10px; font-weight: 600; font-size: 0.95rem; border: none;">
                            <spring:message code="discovery.confirm" text="확인"/>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
    /* Confirm Modal Styles */
    #discoveryConfirmModal .modal-content {
        animation: confirmModalSlideIn 0.3s ease-out;
    }
    @keyframes confirmModalSlideIn {
        from {
            opacity: 0;
            transform: scale(0.9) translateY(-20px);
        }
        to {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
    }
    #confirmCancelBtn:hover {
        background: #e2e8f0 !important;
    }
    #confirmOkBtn:hover {
        filter: brightness(1.1);
    }
    </style>

    <script>
    /**
     * Discovery 공통 Confirm Modal
     * 사용법: showConfirmModal(options).then(result => { if(result) { ... } });
     */
    var confirmModalCallback = null;

    function showConfirmModal(options) {
        return new Promise(function(resolve) {
            var opts = $.extend({
                type: 'confirm',      // confirm, warning, danger, success, info
                title: i18n.confirm,
                message: i18n.proceed,
                confirmText: i18n.confirm,
                cancelText: i18n.cancel,
                confirmClass: ''      // 버튼 색상 클래스 (자동 설정됨)
            }, options);

            // 타입별 스타일 설정
            var iconConfig = {
                'confirm': { icon: 'fa-question-circle', bg: '#eff6ff', color: '#3b82f6', btnBg: '#3b82f6' },
                'warning': { icon: 'fa-exclamation-triangle', bg: '#fffbeb', color: '#f59e0b', btnBg: '#f59e0b' },
                'danger':  { icon: 'fa-exclamation-circle', bg: '#fef2f2', color: '#ef4444', btnBg: '#ef4444' },
                'success': { icon: 'fa-check-circle', bg: '#ecfdf5', color: '#10b981', btnBg: '#10b981' },
                'info':    { icon: 'fa-info-circle', bg: '#f0f9ff', color: '#0ea5e9', btnBg: '#0ea5e9' }
            };

            var config = iconConfig[opts.type] || iconConfig['confirm'];

            // 아이콘 설정
            $('#confirmIconWrapper').css('background', config.bg);
            $('#confirmIcon').removeClass().addClass('fas ' + config.icon).css('color', config.color);

            // 텍스트 설정
            $('#confirmTitle').text(opts.title);
            $('#confirmMessage').text(opts.message);
            $('#confirmOkBtn').text(opts.confirmText).css('background', config.btnBg).css('color', 'white');
            $('#confirmCancelBtn').text(opts.cancelText);

            // 콜백 설정
            confirmModalCallback = resolve;

            // 모달 표시
            $('#discoveryConfirmModal').modal('show');
        });
    }

    // 버튼 이벤트 핸들러
    $(document).ready(function() {
        $('#confirmOkBtn').on('click', function() {
            $('#discoveryConfirmModal').modal('hide');
            if (confirmModalCallback) {
                confirmModalCallback(true);
                confirmModalCallback = null;
            }
        });

        $('#confirmCancelBtn').on('click', function() {
            $('#discoveryConfirmModal').modal('hide');
            if (confirmModalCallback) {
                confirmModalCallback(false);
                confirmModalCallback = null;
            }
        });

        $('#discoveryConfirmModal').on('hidden.bs.modal', function() {
            if (confirmModalCallback) {
                confirmModalCallback(false);
                confirmModalCallback = null;
            }
        });
    });

    /**
     * 간편 사용 헬퍼 함수들
     */
    function confirmAction(message, title) {
        return showConfirmModal({ type: 'confirm', title: title || i18n.confirm, message: message });
    }

    function confirmWarning(message, title) {
        return showConfirmModal({ type: 'warning', title: title || i18n.warning, message: message, confirmText: i18n.continue_ });
    }

    function confirmDanger(message, title) {
        return showConfirmModal({ type: 'danger', title: title || i18n.deleteConfirm, message: message, confirmText: i18n.delete_ });
    }
    </script>
</body>
</html>
