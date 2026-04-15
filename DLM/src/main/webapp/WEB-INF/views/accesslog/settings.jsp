<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    .settings-categories { display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
    .category-tab {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 18px; border-radius: 10px;
        background: #fff; border: 1px solid #e2e8f0;
        cursor: pointer; transition: all 0.2s;
        font-size: 0.85rem; font-weight: 500; color: #64748b;
    }
    .category-tab:hover { border-color: var(--monitor-primary); color: var(--monitor-primary); }
    .category-tab.active {
        background: var(--monitor-primary); color: #fff;
        border-color: var(--monitor-primary); box-shadow: 0 2px 8px rgba(13,148,136,0.3);
    }
    .category-tab .tab-icon { font-size: 1rem; }
    .category-tab .tab-count {
        background: rgba(255,255,255,0.2); padding: 2px 8px;
        border-radius: 10px; font-size: 0.7rem; font-weight: 600;
    }
    .category-tab:not(.active) .tab-count { background: #f1f5f9; }

    .config-category-panel { display: none; }
    .config-category-panel.active { display: block; }

    .config-card {
        background: #fff; border: 1px solid #e2e8f0; border-radius: 12px;
        padding: 20px 24px; margin-bottom: 12px;
        transition: all 0.2s;
    }
    .config-card-row {
        display: flex; align-items: center; justify-content: space-between; gap: 20px;
    }
    .config-card:hover { border-color: var(--monitor-primary); box-shadow: 0 2px 8px rgba(0,0,0,0.05); }

    .config-info { flex: 1; min-width: 0; }
    .config-label {
        font-size: 0.95rem; font-weight: 600; color: #1e293b;
        margin-bottom: 4px; display: flex; align-items: center; gap: 8px;
    }
    .config-hint {
        display: flex; align-items: flex-start; gap: 6px;
        margin-top: 8px; padding: 8px 12px;
        background: #f0f9ff; border-left: 3px solid #38bdf8;
        border-radius: 0 6px 6px 0; font-size: 0.78rem; color: #475569; line-height: 1.5;
    }
    .config-hint i { color: #38bdf8; margin-top: 2px; flex-shrink: 0; }
    .config-hint-text { flex: 1; }
    .config-hint-text strong { color: #1e293b; font-weight: 600; }
    .config-hint-warn {
        background: #fffbeb; border-left-color: #f59e0b;
    }
    .config-hint-warn i { color: #f59e0b; }

    .config-control { display: flex; align-items: center; gap: 12px; flex-shrink: 0; }
    .config-control input[type="text"] {
        padding: 8px 14px; border: 1px solid #e2e8f0; border-radius: 8px;
        font-size: 0.875rem; width: 200px; transition: border-color 0.2s;
    }
    .config-control input[type="text"]:focus {
        outline: none; border-color: var(--monitor-primary);
        box-shadow: 0 0 0 3px rgba(13,148,136,0.1);
    }

    .config-key-badge {
        font-size: 0.65rem; color: #94a3b8; background: #f8fafc;
        padding: 2px 6px; border-radius: 4px; font-family: 'Courier New', monospace;
        display: none;
    }
    .show-keys .config-key-badge { display: inline-block; }

    .settings-toolbar {
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 16px;
    }
    .settings-toolbar .category-desc {
        font-size: 0.85rem; color: #64748b;
    }
    .toggle-key-btn {
        padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0;
        background: #fff; cursor: pointer; font-size: 0.75rem; color: #94a3b8;
        transition: all 0.2s;
    }
    .toggle-key-btn:hover { border-color: #94a3b8; color: #64748b; }
    .toggle-key-btn.active { background: #f1f5f9; border-color: #94a3b8; color: #64748b; }

    /* Cron Display */
    .cron-display {
        font-size: 0.85rem; font-weight: 600; color: var(--monitor-primary);
        background: #ccfbf1; padding: 6px 14px; border-radius: 8px;
        font-family: 'Inter', sans-serif; letter-spacing: 0.3px;
    }

    /* Cron Modal */
    .cron-modal-overlay {
        display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.4); z-index: 10000;
        justify-content: center; align-items: center;
    }
    .cron-modal-overlay.show { display: flex; }
    .cron-modal {
        background: #fff; border-radius: 16px; width: 480px; max-width: 95vw;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2); overflow: hidden;
        animation: modalSlideIn 0.25s ease;
    }
    @keyframes modalSlideIn { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .cron-modal-header {
        padding: 20px 24px; border-bottom: 1px solid #e2e8f0;
        display: flex; align-items: center; justify-content: space-between;
    }
    .cron-modal-header h3 { font-size: 1.05rem; font-weight: 700; color: #1e293b; margin: 0; }
    .cron-modal-close {
        background: none; border: none; font-size: 1.2rem; color: #94a3b8;
        cursor: pointer; padding: 4px 8px; border-radius: 6px;
    }
    .cron-modal-close:hover { background: #f1f5f9; color: #64748b; }
    .cron-modal-body { padding: 24px; }
    .cron-field-group { margin-bottom: 20px; }
    .cron-field-label { font-size: 0.8rem; font-weight: 600; color: #475569; margin-bottom: 8px; display: block; }
    .cron-field-row { display: flex; align-items: center; gap: 10px; }
    .cron-field-row select, .cron-field-row input[type="number"] {
        padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 8px;
        font-size: 0.9rem; color: #1e293b; background: #fff;
    }
    .cron-field-row select:focus, .cron-field-row input[type="number"]:focus {
        outline: none; border-color: var(--monitor-primary);
        box-shadow: 0 0 0 3px rgba(13,148,136,0.1);
    }
    .cron-field-row .field-unit { font-size: 0.85rem; color: #64748b; white-space: nowrap; }
    .cron-preview {
        background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px;
        padding: 14px 18px; margin-top: 16px;
    }
    .cron-preview-label { font-size: 0.7rem; color: #94a3b8; text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px; margin-bottom: 6px; }
    .cron-preview-text { font-size: 0.9rem; color: #1e293b; font-weight: 500; }
    .cron-preview-expr { font-size: 0.75rem; color: #94a3b8; margin-top: 4px; font-family: 'Courier New', monospace; }
    .cron-modal-footer {
        padding: 16px 24px; border-top: 1px solid #e2e8f0;
        display: flex; justify-content: flex-end; gap: 10px;
    }
    .cron-modal-footer .btn-cancel {
        padding: 10px 20px; border-radius: 8px; border: 1px solid #e2e8f0;
        background: #fff; color: #64748b; font-size: 0.85rem; font-weight: 500; cursor: pointer;
    }
    .cron-modal-footer .btn-save {
        padding: 10px 24px; border-radius: 8px; border: none;
        background: var(--monitor-primary); color: #fff; font-size: 0.85rem; font-weight: 600; cursor: pointer;
    }
    .cron-modal-footer .btn-save:hover { background: var(--monitor-primary-dark); }

</style>

<div id="settingsContent">
    <!-- Category Tabs -->
    <div class="settings-categories" id="categoryTabs">
        <c:forEach var="entry" items="${configGroups}" varStatus="loop">
            <div class="category-tab ${loop.first ? 'active' : ''}" data-category="${entry.key}" onclick="switchCategory('${entry.key}')">
                <span class="tab-icon">
                    <c:choose>
                        <c:when test="${entry.key == 'GENERAL'}"><i class="fas fa-sliders"></i></c:when>
                        <c:when test="${entry.key == 'COLLECT'}"><i class="fas fa-database"></i></c:when>
                        <c:when test="${entry.key == 'ALERT'}"><i class="fas fa-bell"></i></c:when>
                        <c:when test="${entry.key == 'RETENTION'}"><i class="fas fa-clock-rotate-left"></i></c:when>
                        <c:when test="${entry.key == 'ARCHIVE'}"><i class="fas fa-box-archive"></i></c:when>
                        <c:otherwise><i class="fas fa-gear"></i></c:otherwise>
                    </c:choose>
                </span>
                <c:choose>
                    <c:when test="${entry.key == 'GENERAL'}">일반</c:when>
                    <c:when test="${entry.key == 'COLLECT'}">수집</c:when>
                    <c:when test="${entry.key == 'ALERT'}">알림</c:when>
                    <c:when test="${entry.key == 'RETENTION'}">보관</c:when>
                    <c:when test="${entry.key == 'ARCHIVE'}">아카이브</c:when>
                    <c:otherwise>${entry.key}</c:otherwise>
                </c:choose>
                <span class="tab-count">${entry.value.size()}</span>
            </div>
        </c:forEach>
    </div>

    <!-- Config Panels per Category -->
    <c:forEach var="entry" items="${configGroups}" varStatus="loop">
        <div class="config-category-panel ${loop.first ? 'active' : ''}" data-category="${entry.key}">
            <div class="settings-toolbar">
                <span class="category-desc">
                    <c:choose>
                        <c:when test="${entry.key == 'GENERAL'}">시스템 전반 동작에 관련된 기본 설정입니다.</c:when>
                        <c:when test="${entry.key == 'COLLECT'}">접속기록 수집 스케줄과 성능 관련 설정입니다.</c:when>
                        <c:when test="${entry.key == 'ALERT'}">이상행위 탐지 및 알림 전송 관련 설정입니다.</c:when>
                        <c:when test="${entry.key == 'RETENTION'}">접속기록 보관 기간 관련 설정입니다.</c:when>
                        <c:when test="${entry.key == 'ARCHIVE'}">장기 보관 및 자동 아카이빙 관련 설정입니다.</c:when>
                        <c:otherwise>${entry.key} 카테고리 설정</c:otherwise>
                    </c:choose>
                </span>
                <button class="toggle-key-btn" onclick="toggleKeys(this)" title="설정 키 표시/숨기기">
                    <i class="fas fa-code"></i> 키 보기
                </button>
            </div>

            <div class="config-list">
                <c:forEach var="config" items="${entry.value}">
                    <div class="config-card" data-config-key="${config.configKey}">
                        <div class="config-card-row">
                            <div class="config-info">
                                <div class="config-label">
                                    ${config.description}
                                    <span class="config-key-badge">${config.configKey}</span>
                                </div>
                            </div>
                            <div class="config-control">
                                <c:choose>
                                    <c:when test="${config.configValue == 'Y' || config.configValue == 'N'}">
                                        <label class="toggle-switch">
                                            <input type="checkbox" id="cfg_${config.configId}"
                                                   ${config.configValue == 'Y' ? 'checked' : ''}
                                                   onchange="saveToggleConfig('${config.configId}', this.checked)">
                                            <span class="toggle-slider"></span>
                                        </label>
                                    </c:when>
                                    <c:when test="${config.configKey == 'HASH_VERIFY_SCHEDULE'}">
                                        <span class="cron-display" id="cronDisplay_${config.configId}"
                                              data-cron="${config.configValue}">${config.configValue}</span>
                                        <button class="btn-outline" style="padding:6px 14px; font-size:0.8rem;"
                                                onclick="openCronModal('${config.configId}')">
                                            <i class="fas fa-calendar-pen"></i> 변경
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <input type="text" id="cfg_${config.configId}" value="${config.configValue}"
                                               onkeypress="if(event.key==='Enter') saveConfig('${config.configId}')">
                                        <button class="btn-outline" style="padding:6px 14px; font-size:0.8rem;"
                                                onclick="saveConfig('${config.configId}')">저장</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="config-hint-area"></div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:forEach>
</div>

<!-- Cron Schedule Modal -->
<div class="cron-modal-overlay" id="cronModalOverlay" onclick="if(event.target===this) closeCronModal()">
    <div class="cron-modal">
        <div class="cron-modal-header">
            <h3><i class="fas fa-calendar-check" style="color:var(--monitor-primary); margin-right:8px;"></i>해시 검증 스케줄 설정</h3>
            <button class="cron-modal-close" onclick="closeCronModal()">&times;</button>
        </div>
        <div class="cron-modal-body">
            <input type="hidden" id="cronConfigId">

            <div class="cron-field-group">
                <label class="cron-field-label">반복 주기</label>
                <div class="cron-field-row">
                    <select id="cronFrequency" onchange="updateCronPreview()" style="flex:1;">
                        <option value="monthly">매월</option>
                        <option value="weekly">매주</option>
                    </select>
                </div>
            </div>

            <div class="cron-field-group" id="cronDayOfMonthGroup">
                <label class="cron-field-label">실행 일자</label>
                <div class="cron-field-row">
                    <span class="field-unit">매월</span>
                    <select id="cronDayOfMonth" onchange="updateCronPreview()" style="width:80px;">
                        <option value="1">1일</option>
                        <option value="15">15일</option>
                        <option value="L">말일</option>
                    </select>
                </div>
            </div>

            <div class="cron-field-group" id="cronDayOfWeekGroup" style="display:none;">
                <label class="cron-field-label">실행 요일</label>
                <div class="cron-field-row">
                    <select id="cronDayOfWeek" onchange="updateCronPreview()" style="flex:1;">
                        <option value="1">월요일</option>
                        <option value="2">화요일</option>
                        <option value="3">수요일</option>
                        <option value="4">목요일</option>
                        <option value="5">금요일</option>
                        <option value="6">토요일</option>
                        <option value="0">일요일</option>
                    </select>
                </div>
            </div>

            <div class="cron-field-group">
                <label class="cron-field-label">실행 시각</label>
                <div class="cron-field-row">
                    <select id="cronHour" onchange="updateCronPreview()" style="width:90px;">
                        <option value="1">01시</option>
                        <option value="2">02시</option>
                        <option value="3" selected>03시</option>
                        <option value="4">04시</option>
                        <option value="5">05시</option>
                        <option value="6">06시</option>
                        <option value="12">12시</option>
                        <option value="18">18시</option>
                        <option value="22">22시</option>
                        <option value="23">23시</option>
                    </select>
                    <select id="cronMinute" onchange="updateCronPreview()" style="width:90px;">
                        <option value="0" selected>00분</option>
                        <option value="15">15분</option>
                        <option value="30">30분</option>
                        <option value="45">45분</option>
                    </select>
                </div>
            </div>

            <div class="cron-preview">
                <div class="cron-preview-label">실행 예정</div>
                <div class="cron-preview-text" id="cronPreviewText">매월 1일 03:00에 실행</div>
                <div class="cron-preview-expr" id="cronPreviewExpr">0 0 3 1 * *</div>
            </div>
        </div>
        <div class="cron-modal-footer">
            <button class="btn-cancel" onclick="closeCronModal()">취소</button>
            <button class="btn-save" onclick="saveCronSchedule()">저장</button>
        </div>
    </div>
</div>


<script>
// 각 설정 항목별 사용자 친화적 힌트
var CONFIG_HINTS = {
    'HASH_VERIFY_ENABLED': {
        icon: 'fa-shield-halved',
        text: '접속기록이 <strong>위변조되지 않았는지</strong> 해시 체인으로 검증합니다. 비활성화하면 무결성 검증이 중지되며, 감사 시 문제가 될 수 있습니다.',
        warn: true
    },
    'HASH_VERIFY_SCHEDULE': {
        icon: 'fa-calendar-check',
        text: '해시 무결성 자동 검증이 실행되는 일정입니다. 검증은 <strong>서버 부하가 적은 새벽 시간대</strong>를 권장하며, 변경 즉시 다음 실행부터 반영됩니다. (법적 근거: 안전성확보조치 기준 제8조 2항 — 월 1회 이상 점검)'
    },
    'SQL_TEXT_LOGGING': {
        icon: 'fa-file-code',
        text: '실행된 SQL 전문을 접속기록에 함께 저장합니다. <strong>비활성화 상태에서도</strong> 사용된 테이블명, 컬럼명, SQL 유형(SELECT/INSERT/UPDATE/DELETE) 정보는 자동으로 추출·관리되므로 기본적인 감사 추적에는 문제가 없습니다. 전문 저장은 <strong>저장 용량이 크게 증가</strong>하므로, 상세 분석이 필요한 기간에만 활성화를 권장합니다.',
        warn: true
    },
    'SCHEDULER_ENABLED': {
        icon: 'fa-play-circle',
        text: '접속기록 자동 수집 스케줄러를 활성화합니다. 비활성화하면 <strong>새로운 접속기록이 수집되지 않습니다.</strong>',
        warn: true
    },
    'COLLECT_INTERVAL_MIN': {
        icon: 'fa-stopwatch',
        text: '수집 대상 DB에서 접속기록을 가져오는 주기입니다. 값이 작을수록 실시간에 가깝지만 <strong>DB 부하가 증가</strong>합니다. 권장: <strong>5~15분</strong>'
    },
    'COLLECT_BATCH_SIZE': {
        icon: 'fa-layer-group',
        text: '한 번의 수집 사이클에서 가져올 최대 레코드 수입니다. 너무 크면 메모리 부담, 너무 작으면 수집 지연이 발생합니다. 권장: <strong>500~2000</strong>'
    },
    'COLLECT_RETRY_COUNT': {
        icon: 'fa-rotate',
        text: '수집 중 네트워크 오류 등으로 실패 시 자동 재시도 횟수입니다. <strong>0</strong>으로 설정하면 재시도 없이 즉시 실패 처리됩니다.'
    },
    'DETECTION_ENABLED': {
        icon: 'fa-radar',
        text: '비정상 접속 패턴(야간 접속, 대량 조회, 권한 외 접근 등)을 <strong>자동으로 탐지</strong>합니다. 탐지 규칙은 [이상행위 탐지 규칙] 메뉴에서 관리됩니다.'
    },
    'EMAIL_ENABLED': {
        icon: 'fa-envelope',
        text: '이상행위가 탐지되면 담당자에게 <strong>이메일 알림</strong>을 발송합니다. 메일 서버(SMTP) 설정이 올바르게 구성되어 있어야 동작합니다.<br><span style="color:#64748b;font-size:12px;">※ <strong>HIGH(높음)</strong> 심각도 알림만 이메일이 발송되며, MEDIUM/LOW는 발송되지 않습니다.</span>'
    },
    'EMAIL_RECIPIENTS': {
        icon: 'fa-users',
        text: '알림을 받을 이메일 주소를 <strong>쉼표(,)로 구분</strong>하여 입력합니다. 예: admin@company.com, security@company.com<br><span style="color:#64748b;font-size:12px;">※ 이 주소로 발송되는 알림: ① HIGH 심각도 이상행위 감지 ② 소명 제출 완료 ③ 소명 기한 초과 ④ 장기 미처리 알림</span>'
    },
    'RETENTION_PERIOD_YEARS': {
        icon: 'fa-hourglass-half',
        text: '접속기록을 보관하는 기간입니다. 개인정보보호법에 따라 <strong>최소 2년</strong> 보관이 의무이며, 기간 경과 후 자동 삭제됩니다.',
        warn: true
    },
    'RETENTION_FINANCIAL_YEARS': {
        icon: 'fa-landmark',
        text: '금융사 중요원장에 대한 접속기록은 <strong>전자금융감독규정</strong>에 의거하여 일반 기록보다 긴 보관기간이 적용됩니다.',
        warn: true
    },
    'ARCHIVE_ENABLED': {
        icon: 'fa-box-archive',
        text: '보관기간이 지난 접속기록을 자동으로 아카이브 테이블로 이동합니다. 비활성화 시 수동으로 관리해야 하며, <strong>디스크 용량 증가</strong>에 주의하세요.'
    }
};

// cron 표현식 → 사람이 읽는 텍스트
function cronToHuman(cron) {
    var p = (cron || '').split(/\s+/);
    if (p.length < 6) return cron;
    var min = p[1], hr = p[2], dom = p[3], dow = p[5];
    var dowNames = {'0':'일','1':'월','2':'화','3':'수','4':'목','5':'금','6':'토'};
    var time = pad(hr) + ':' + pad(min);
    if (dow !== '*' && dow !== '?') {
        return '매주 ' + (dowNames[dow]||dow) + '요일 ' + time;
    }
    var domLabel = dom === 'L' ? '말일' : dom + '일';
    return '매월 ' + domLabel + ' ' + time;
}

// 힌트 렌더링 + cron display 변환
$(function() {
    $('.config-card').each(function() {
        var key = $(this).data('config-key');
        var hint = CONFIG_HINTS[key];
        if (hint) {
            var warnClass = hint.warn ? ' config-hint-warn' : '';
            var icon = hint.icon || 'fa-circle-info';
            $(this).find('.config-hint-area').html(
                '<div class="config-hint' + warnClass + '">' +
                '  <i class="fas ' + icon + '"></i>' +
                '  <span class="config-hint-text">' + hint.text + '</span>' +
                '</div>'
            );
        }
    });
    // cron display를 사람이 읽는 형태로 변환
    $('.cron-display').each(function() {
        var raw = $(this).text().trim();
        $(this).text(cronToHuman(raw));
    });
});

// === Cron 모달 ===
function openCronModal(configId) {
    var currentCron = $('#cronDisplay_' + configId).data('cron') || '0 0 3 1 * *';
    $('#cronConfigId').val(configId);
    parseCronToModal(currentCron);
    updateCronPreview();
    $('#cronModalOverlay').addClass('show');
}

function closeCronModal() {
    $('#cronModalOverlay').removeClass('show');
}

function parseCronToModal(cron) {
    // cron: "0 M H D * *" (monthly) or "0 M H * * DOW" (weekly)
    var parts = (cron || '0 0 3 1 * *').split(/\s+/);
    var minute = parts[1] || '0';
    var hour = parts[2] || '3';
    var dayOfMonth = parts[3] || '1';
    var dayOfWeek = parts[5] || '*';

    if (dayOfWeek !== '*' && dayOfWeek !== '?') {
        $('#cronFrequency').val('weekly');
        $('#cronDayOfMonthGroup').hide();
        $('#cronDayOfWeekGroup').show();
        $('#cronDayOfWeek').val(dayOfWeek);
    } else {
        $('#cronFrequency').val('monthly');
        $('#cronDayOfMonthGroup').show();
        $('#cronDayOfWeekGroup').hide();
        $('#cronDayOfMonth').val(dayOfMonth === 'L' ? 'L' : dayOfMonth);
    }
    $('#cronHour').val(hour);
    $('#cronMinute').val(minute);
}

function updateCronPreview() {
    var freq = $('#cronFrequency').val();
    var hour = $('#cronHour').val();
    var minute = $('#cronMinute').val();
    var cronExpr, previewText;

    if (freq === 'monthly') {
        $('#cronDayOfMonthGroup').show();
        $('#cronDayOfWeekGroup').hide();
        var dom = $('#cronDayOfMonth').val();
        var domLabel = dom === 'L' ? '말일' : dom + '일';
        cronExpr = '0 ' + minute + ' ' + hour + ' ' + dom + ' * *';
        previewText = '매월 ' + domLabel + ' ' + pad(hour) + ':' + pad(minute) + '에 실행';
    } else {
        $('#cronDayOfMonthGroup').hide();
        $('#cronDayOfWeekGroup').show();
        var dow = $('#cronDayOfWeek').val();
        var dowNames = {'0':'일','1':'월','2':'화','3':'수','4':'목','5':'금','6':'토'};
        cronExpr = '0 ' + minute + ' ' + hour + ' * * ' + dow;
        previewText = '매주 ' + dowNames[dow] + '요일 ' + pad(hour) + ':' + pad(minute) + '에 실행';
    }

    $('#cronPreviewText').text(previewText);
    $('#cronPreviewExpr').text(cronExpr);
}

function pad(n) { return ('0' + n).slice(-2); }

function saveCronSchedule() {
    var configId = $('#cronConfigId').val();
    var cronExpr = $('#cronPreviewExpr').text();
    var previewText = $('#cronPreviewText').text();
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: cronExpr }),
        success: function(res) {
            if (res.success) {
                $('#cronDisplay_' + configId).text(previewText).data('cron', cronExpr);
                closeCronModal();
                showToast('스케줄이 저장되었습니다', false);
            } else {
                showToast('저장 실패', true);
            }
        },
        error: function() { showToast('저장 실패', true); }
    });
}

function switchCategory(category) {
    $('.category-tab').removeClass('active');
    $('.category-tab[data-category="' + category + '"]').addClass('active');
    $('.config-category-panel').removeClass('active');
    $('.config-category-panel[data-category="' + category + '"]').addClass('active');
}

function toggleKeys(btn) {
    var panel = $(btn).closest('.config-category-panel');
    panel.find('.config-list').toggleClass('show-keys');
    $(btn).toggleClass('active');
}

function saveConfig(configId) {
    var value = $('#cfg_' + configId).val();
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: value }),
        success: function(res) { showToast(res.success ? '저장되었습니다' : '저장 실패', !res.success); },
        error: function() { showToast('저장 실패', true); }
    });
}

function saveToggleConfig(configId, checked) {
    var value = checked ? 'Y' : 'N';
    $.ajax({
        url: '/accesslog/api/config/' + configId,
        type: 'PUT', contentType: 'application/json',
        data: JSON.stringify({ configValue: value }),
        success: function(res) { if (!res.success) showToast('저장 실패', true); else showToast('저장되었습니다', false); },
        error: function() { showToast('저장 실패', true); }
    });
}
</script>
