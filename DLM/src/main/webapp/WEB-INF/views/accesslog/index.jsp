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
    <title>X-One 접속기록관리</title>
    <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">
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
        .sidebar-nav { flex: 1; padding: 16px 0; overflow-y: auto; }
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
                            <c:if test="${stats.unresolvedAlertCount != null && stats.unresolvedAlertCount > 0}">
                                <span class="nav-badge">${stats.unresolvedAlertCount}</span>
                            </c:if>
                        </a>
                    </div>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">관리</div>
                    <div class="nav-item">
                        <a href="javascript:void(0)" class="nav-link" data-page="sources">
                            <i class="fas fa-server"></i> 수집 대상
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
                        <div class="user-role"><sec:authentication property="principal.authorities"/></div>
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
    <script>
    $(function() {
        var csrfToken = $('meta[name="_csrf"]').attr('content');
        var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
        $.ajaxSetup({ beforeSend: function(xhr) { xhr.setRequestHeader(csrfHeader, csrfToken); } });

        var pageTitles = {
            'dashboard': '대시보드',
            'logs': '접속기록 조회',
            'alerts': '이상행위 알림',
            'sources': '수집 대상 관리',
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

        // 알림 배지 자동 갱신 (30초)
        function updateAlertBadge() {
            $.get('/accesslog/api/alert-count', function(data) {
                var cnt = data.count || 0;
                var $badge = $('.nav-link[data-page="alerts"] .nav-badge');
                if (cnt > 0) {
                    if ($badge.length) {
                        $badge.text(cnt);
                    } else {
                        $('.nav-link[data-page="alerts"]').append('<span class="nav-badge">' + cnt + '</span>');
                    }
                } else {
                    $badge.remove();
                }
            });
        }
        setInterval(updateAlertBadge, 30000);

        // 대시보드 자동 새로고침 (60초)
        setInterval(function() {
            if (currentPage === 'dashboard') {
                $.get('/accesslog/dashboard', function(html) {
                    $('#mainContent').html(html);
                });
            }
        }, 60000);
    });
    </script>
</body>
</html>