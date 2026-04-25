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
    <title>X-Audit 접속기록·소명</title>
    <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">
    <link href="/resources/css/flatpickr.min.css" rel="stylesheet">
    <link href="/resources/css/material_blue.css" rel="stylesheet">
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">
    <style>
        :root {
            --monitor-primary: #0d9488;
            --monitor-primary-dark: #0f766e;
            --monitor-secondary: #0ea5e9;
            --monitor-success: #10b981;
            --monitor-warning: #f59e0b;
            --monitor-danger: #ef4444;
            --monitor-bg: #f8fafc;
            --monitor-sidebar: #1e293b;
            --monitor-sidebar-hover: #334155;
        }
        * { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        body { background: var(--monitor-bg); overflow: hidden; }

        .monitor-wrapper { display: flex; height: 100vh; }

        /* Sidebar */
        .monitor-sidebar { width: 260px; background: var(--monitor-sidebar); display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar-header { padding: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }
        .sidebar-brand-icon { width: 40px; height: 40px; background: linear-gradient(135deg, var(--monitor-primary), var(--monitor-secondary)); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
        .sidebar-brand-icon i { color: #fff; font-size: 1.2rem; }
        .sidebar-brand-text { color: #fff; font-size: 1rem; font-weight: 600; line-height: 1.3; }
        .sidebar-nav { flex: 1; padding: 16px 0; overflow-y: auto; scrollbar-width: none; -ms-overflow-style: none; }
        .sidebar-nav::-webkit-scrollbar { display: none; }
        .nav-section { padding: 0 16px; margin-bottom: 8px; }
        .nav-section-title { color: rgba(255,255,255,0.4); font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; padding: 8px 12px; }
        .nav-item { margin: 2px 0; }
        .nav-link { display: flex; align-items: center; gap: 12px; padding: 12px 16px; color: rgba(255,255,255,0.7); text-decoration: none; border-radius: 8px; margin: 0 8px; transition: all 0.2s; font-size: 0.875rem; font-weight: 500; }
        .nav-link:hover { background: var(--monitor-sidebar-hover); color: #fff; text-decoration: none; }
        .nav-link.active { background: var(--monitor-primary); color: #fff; }
        .nav-link i { width: 20px; text-align: center; font-size: 1rem; }
        .nav-badge { margin-left: auto; background: var(--monitor-danger); color: #fff; font-size: 0.7rem; padding: 2px 8px; border-radius: 10px; font-weight: 600; }

        /* Sidebar Footer */
        .sidebar-footer { padding: 16px; border-top: 1px solid rgba(255,255,255,0.1); }
        .user-info { display: flex; align-items: center; gap: 12px; padding: 8px; border-radius: 8px; background: rgba(255,255,255,0.05); }
        .user-avatar { width: 36px; height: 36px; background: linear-gradient(135deg, var(--monitor-primary), var(--monitor-secondary)); border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .user-avatar i { color: #fff; font-size: 0.9rem; }
        .user-details { flex: 1; }
        .user-name { color: #fff; font-size: 0.85rem; font-weight: 600; }
        .user-role { color: rgba(255,255,255,0.5); font-size: 0.75rem; }
        .btn-back-main { display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; padding: 10px; margin-top: 12px; background: rgba(255,255,255,0.1); border: none; border-radius: 8px; color: rgba(255,255,255,0.7); font-size: 0.8rem; cursor: pointer; transition: all 0.2s; text-decoration: none; }
        .btn-back-main:hover { background: rgba(255,255,255,0.15); color: #fff; text-decoration: none; }

        /* Main Content */
        .monitor-main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .monitor-header { background: #fff; padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; }
        .header-title { display: flex; align-items: center; gap: 12px; }
        .header-title h1 { font-size: 1.25rem; font-weight: 700; color: #1e293b; margin: 0; }
        .header-title .page-badge { font-size: 0.7rem; background: #ccfbf1; color: var(--monitor-primary); padding: 4px 10px; border-radius: 20px; font-weight: 600; }
        .monitor-content { flex: 1; padding: 24px; overflow-y: auto; }

        /* Stats Cards */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .stat-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
        .stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
        .stat-icon.primary { background: #ccfbf1; color: var(--monitor-primary); }
        .stat-icon.success { background: #d1fae5; color: var(--monitor-success); }
        .stat-icon.warning { background: #fef3c7; color: var(--monitor-warning); }
        .stat-icon.danger { background: #fee2e2; color: var(--monitor-danger); }
        .stat-icon i { font-size: 1.25rem; }
        .stat-value { font-size: 1.75rem; font-weight: 700; color: #1e293b; margin-bottom: 4px; }
        .stat-label { font-size: 0.85rem; color: #64748b; }

        /* Panels */
        .content-panel { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 24px; }
        .panel-header { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; }
        .panel-title { font-size: 1rem; font-weight: 600; color: #1e293b; margin: 0; }
        .panel-body { padding: 20px; }

        /* Table */
        .monitor-table { width: 100%; border-collapse: collapse; }
        .monitor-table th { background: #f8fafc; padding: 12px 16px; text-align: left; font-size: 0.75rem; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #e2e8f0; }
        .monitor-table td { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; font-size: 0.875rem; color: #334155; }
        .monitor-table tr:hover { background: #f8fafc; }

        /* Status Badge */
        .status-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 500; }
        .status-badge.running { background: #dbeafe; color: #1d4ed8; }
        .status-badge.completed { background: #d1fae5; color: #059669; }
        .status-badge.new-alert { background: #fee2e2; color: #dc2626; }
        .status-badge.stopped { background: #f1f5f9; color: #64748b; }
        .status-badge.error { background: #fee2e2; color: #dc2626; }
        .status-badge.high { background: #fee2e2; color: #dc2626; }
        .status-badge.medium { background: #fef3c7; color: #d97706; }
        .status-badge.low { background: #d1fae5; color: #059669; }
        .status-badge.info { background: #dbeafe; color: #1d4ed8; }

        /* Buttons */
        .btn-monitor { background: linear-gradient(135deg, var(--monitor-primary), var(--monitor-primary-dark)); color: #fff; border: none; padding: 10px 20px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; transition: all 0.2s; }
        .btn-monitor:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(13, 148, 136, 0.4); }
        .btn-outline { background: transparent; color: var(--monitor-primary); border: 1px solid var(--monitor-primary); padding: 8px 16px; border-radius: 8px; font-size: 0.85rem; font-weight: 500; cursor: pointer; transition: all 0.2s; }
        .btn-outline:hover { background: var(--monitor-primary); color: #fff; }

        /* Filter Bar */
        .filter-bar { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; align-items: center; }
        .filter-bar select, .filter-bar input { padding: 8px 12px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 0.85rem; color: #334155; }
        .filter-bar select:focus, .filter-bar input:focus { outline: none; border-color: var(--monitor-primary); box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.1); }

        /* Flatpickr date inputs */
        .fp-date { cursor: pointer; background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2394a3b8' stroke-width='2'%3E%3Crect x='3' y='4' width='18' height='18' rx='2' ry='2'%3E%3C/rect%3E%3Cline x1='16' y1='2' x2='16' y2='6'%3E%3C/line%3E%3Cline x1='8' y1='2' x2='8' y2='6'%3E%3C/line%3E%3Cline x1='3' y1='10' x2='21' y2='10'%3E%3C/line%3E%3C/svg%3E") no-repeat right 10px center; padding-right: 32px !important; }
        .flatpickr-calendar { border-radius: 10px; box-shadow: 0 8px 24px rgba(0,0,0,0.12); border: 1px solid #e2e8f0; }
        .flatpickr-day.selected { background: var(--monitor-primary) !important; border-color: var(--monitor-primary) !important; }
        .flatpickr-day:hover { background: #ccfbf1; border-color: #ccfbf1; }

        /* Empty State */
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state-icon { width: 80px; height: 80px; background: #f1f5f9; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; }
        .empty-state-icon i { font-size: 2rem; color: #94a3b8; }
        .empty-state h3 { font-size: 1.1rem; font-weight: 600; color: #475569; margin-bottom: 8px; }
        .empty-state p { color: #94a3b8; font-size: 0.9rem; margin-bottom: 20px; }

        /* Pagination */
        .pagination-wrap { display: flex; justify-content: center; padding: 16px; }
        .pagination-wrap a, .pagination-wrap span { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; margin: 0 4px; font-size: 0.85rem; color: #64748b; text-decoration: none; transition: all 0.2s; }
        .pagination-wrap a:hover { background: #f1f5f9; }
        .pagination-wrap .active-page { background: var(--monitor-primary); color: #fff; }

        /* Toggle Switch */
        .toggle-switch { position: relative; display: inline-block; width: 44px; height: 24px; cursor: pointer; }
        .toggle-switch input { opacity: 0; width: 0; height: 0; }
        .toggle-slider { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: #cbd5e1; border-radius: 24px; transition: all 0.3s; }
        .toggle-slider:before { content: ''; position: absolute; width: 18px; height: 18px; left: 3px; bottom: 3px; background: #fff; border-radius: 50%; transition: all 0.3s; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }
        .toggle-switch input:checked + .toggle-slider { background: var(--monitor-primary); }
        .toggle-switch input:checked + .toggle-slider:before { transform: translateX(20px); }
    </style>
</head>
<body>
    <div class="monitor-wrapper">
        <!-- Sidebar -->
        <aside class="monitor-sidebar">
            <div class="sidebar-header">
                <a href="/accesslog/index" class="sidebar-brand">
                    <div class="sidebar-brand-icon"><i class="fas fa-shield-halved"></i></div>
                    <span class="sidebar-brand-text">접속기록관리</span>
                </a>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">모니터링</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link active" data-page="dashboard">
                            <i class="fas fa-chart-line"></i> 대시보드
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">접속기록</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="logs">
                            <i class="fas fa-list-ul"></i> 접속기록 조회
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">이상행위</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="alerts">
                            <i class="fas fa-triangle-exclamation"></i> 이상행위 알림
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="suppressions">
                            <i class="fas fa-filter-circle-xmark"></i> 알림 예외 관리
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="alert-rules">
                            <i class="fas fa-list-check"></i> 탐지 규칙
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">보고서</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="reports">
                            <i class="fas fa-file-lines"></i> 보고서 관리
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">검증</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="hash-verify">
                            <i class="fas fa-fingerprint"></i> 저장기록 위·변조 검증
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">관리</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="policy">
                            <i class="fas fa-shield-alt"></i> 감사 대상 테이블
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="sources">
                            <i class="fas fa-server"></i> 수집 관리
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="exclude-patterns">
                            <i class="fas fa-filter"></i> 수집 제외 SQL
                        </a>
                    </div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="settings">
                            <i class="fas fa-gear"></i> 환경설정
                        </a>
                    </div>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-info">
                    <div class="user-avatar"><i class="fas fa-user"></i></div>
                    <div class="user-details">
                        <div class="user-name"><sec:authentication property="principal.username"/></div>
                    </div>
                </div>
                <a href="/hub" class="btn-back-main"><i class="fas fa-arrow-left"></i> 메인으로 돌아가기</a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="monitor-main">
            <div class="monitor-header">
                <div class="header-title">
                    <h1 id="pageTitle">대시보드</h1>
                    <span class="page-badge" id="pageBadge">Privacy Monitor</span>
                </div>
                <div class="header-actions" id="headerActions"></div>
            </div>
            <div class="monitor-content" id="mainContent">
                <jsp:include page="dashboard.jsp"/>
            </div>
        </main>
    </div>

    <script src="/resources/vendor/jquery/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="/resources/js/flatpickr.min.js"></script>
    <script>
    $(function() {
        var csrfToken = $('meta[name="_csrf"]').attr('content');
        var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
        $.ajaxSetup({ beforeSend: function(xhr) { xhr.setRequestHeader(csrfHeader, csrfToken); } });

        var pageTitles = {
            'dashboard': '대시보드',
            'logs': '접속기록 조회',
            'alerts': '이상행위 알림',
            'reports': '보고서 관리',
            'hash-verify': '저장기록 위·변조 검증',
            'alert-rules': '이상행위 탐지 규칙',
            'suppressions': '알림 예외 관리',
            'policy': '감사 대상 테이블 관리',
            'sources': '수집 관리',
            'exclude-patterns': '수집 제외 SQL 관리',
            'settings': '환경설정'
        };

        var currentPage = 'dashboard';

        $('.nav-link[data-page]').on('click', function(e) {
            e.preventDefault();
            var page = $(this).data('page');
            currentPage = page;
            $('.nav-link').removeClass('active');
            $(this).addClass('active');
            $('#pageTitle').text(pageTitles[page] || page);

            $.get('/accesslog/' + page, function(html) {
                $('#mainContent').html(html);
            }).fail(function() {
                $('#mainContent').html('<div class="empty-state"><div class="empty-state-icon"><i class="fas fa-exclamation-triangle"></i></div><h3>페이지를 불러올 수 없습니다</h3></div>');
            });
        });

        // URL 해시로 페이지 직접 로드 (새 탭 열기 지원)
        var initHash = location.hash.replace('#', '');
        if (initHash && pageTitles[initHash]) {
            $('.nav-link[data-page="' + initHash + '"]').click();
        }

    });

    // ========== 공통 알림 (dlmAlert) ==========
    function dlmAlert(msg, callback) {
        var $m = $('#dlmAlertModal');
        if ($m.length === 0) {
            $('body').append(
                '<div id="dlmAlertModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.4);z-index:100000;align-items:center;justify-content:center;">' +
                '  <div style="background:#fff;border-radius:14px;max-width:380px;width:90%;padding:28px 24px 20px;box-shadow:0 12px 40px rgba(0,0,0,0.18);text-align:center;">' +
                '    <div style="width:48px;height:48px;background:#fef3c7;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 14px;">' +
                '      <i class="fas fa-exclamation-triangle" style="color:#f59e0b;font-size:1.3rem;"></i>' +
                '    </div>' +
                '    <div id="dlmAlertMsg" style="font-size:0.9rem;color:#334155;line-height:1.6;white-space:pre-line;margin-bottom:20px;"></div>' +
                '    <button id="dlmAlertOk" style="background:linear-gradient(135deg,var(--monitor-primary),var(--monitor-primary-dark));color:#fff;border:none;padding:10px 36px;border-radius:8px;font-size:0.85rem;font-weight:600;cursor:pointer;">확인</button>' +
                '  </div>' +
                '</div>'
            );
            $m = $('#dlmAlertModal');
            $m.on('click', '#dlmAlertOk', function() {
                $m.hide();
                var cb = $m.data('callback');
                if (typeof cb === 'function') cb();
            });
            // ESC 닫기
            $(document).on('keydown', function(e) {
                if (e.key === 'Escape' && $m.is(':visible')) { $m.hide(); }
            });
        }
        $('#dlmAlertMsg').text(msg);
        $m.data('callback', callback || null);
        $m.css('display','flex');
        setTimeout(function() { $('#dlmAlertOk').focus(); }, 50);
    }

    // HTML 이스케이프 유틸
    function escHtml(str) {
        if (!str) return '';
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ========== 공통 확인 모달 (showConfirm) ==========
    function showConfirm(message, callback, cancelCallback) {
        var $m = $('#dlmConfirmModal');
        if ($m.length === 0) {
            $('body').append(
                '<div id="dlmConfirmModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.4);z-index:100000;align-items:center;justify-content:center;">' +
                '  <div style="background:#fff;border-radius:14px;max-width:380px;width:90%;padding:28px 24px 20px;box-shadow:0 12px 40px rgba(0,0,0,0.18);text-align:center;">' +
                '    <div style="width:48px;height:48px;background:#fef2f2;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 14px;">' +
                '      <i class="fas fa-exclamation-circle" style="color:#ef4444;font-size:1.3rem;"></i>' +
                '    </div>' +
                '    <div id="dlmConfirmMsg" style="font-size:0.9rem;color:#334155;line-height:1.6;white-space:pre-line;margin-bottom:20px;"></div>' +
                '    <div style="display:flex;gap:10px;justify-content:center;">' +
                '      <button id="dlmConfirmCancel" style="background:#f1f5f9;color:#64748b;border:none;padding:10px 28px;border-radius:8px;font-size:0.85rem;font-weight:600;cursor:pointer;">취소</button>' +
                '      <button id="dlmConfirmOk" style="background:#ef4444;color:#fff;border:none;padding:10px 28px;border-radius:8px;font-size:0.85rem;font-weight:600;cursor:pointer;">확인</button>' +
                '    </div>' +
                '  </div>' +
                '</div>'
            );
            $m = $('#dlmConfirmModal');
            $m.on('click', '#dlmConfirmOk', function() {
                $m.hide();
                var cb = $m.data('callback');
                if (typeof cb === 'function') cb();
            });
            $m.on('click', '#dlmConfirmCancel', function() {
                $m.hide();
                var cb = $m.data('cancelCallback');
                if (typeof cb === 'function') cb();
            });
            $(document).on('keydown', function(e) {
                if (e.key === 'Escape' && $m.is(':visible')) {
                    $m.hide();
                    var cb = $m.data('cancelCallback');
                    if (typeof cb === 'function') cb();
                }
            });
        }
        $('#dlmConfirmMsg').text(message);
        $m.data('callback', callback || null);
        $m.data('cancelCallback', cancelCallback || null);
        $m.css('display','flex');
        setTimeout(function() { $('#dlmConfirmOk').focus(); }, 50);
    }

    // ========== 공통 토스트 ==========
    function showToast(msg, isError) {
        var $t = $('#globalToast');
        if ($t.length === 0) {
            $('body').append(
                '<div id="globalToast" style="position:fixed;bottom:24px;right:24px;z-index:99999;' +
                'padding:12px 24px;border-radius:10px;font-size:0.85rem;font-weight:500;color:#fff;' +
                'box-shadow:0 4px 16px rgba(0,0,0,0.15);transform:translateY(100px);opacity:0;' +
                'transition:all 0.3s;pointer-events:none;"></div>'
            );
            $t = $('#globalToast');
        }
        var icon = isError ? 'times-circle' : 'check-circle';
        $t.html('<i class="fas fa-' + icon + '" style="margin-right:6px;"></i>' + msg);
        $t.css({ background: isError ? '#dc2626' : '#059669', transform: 'translateY(0)', opacity: 1 });
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
            $t.css({ transform: 'translateY(100px)', opacity: 0 });
        }, 2500));
    }
    </script>
</body>
</html>