<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- 설정 콘텐츠 -->
<div id="settingsContent">
    <div class="row">
        <!-- 메인 설정 컬럼 -->
        <div class="col-md-8">
            <!-- 기본 스캔 작업 설정 -->
            <div class="content-panel">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-cog" style="margin-right: 8px;"></i> <spring:message code="discovery.default_scan_settings"/></h3>
                </div>
                <div class="panel-body">
                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600;">제외 데이터 타입</label>
                        <textarea class="form-control text-uppercase" id="cfg_default_exclude_types"
                               data-key="default.exclude_data_types" rows="2"
                               style="text-transform: uppercase;">NUMBER,INT,INTEGER,BIGINT,FLOAT,DOUBLE,DECIMAL,DATE,DATETIME,TIMESTAMP,BLOB,CLOB,RAW,LONG</textarea>
                        <small class="text-muted"><spring:message code="discovery.exclude_data_types_desc"/></small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600;">제외 컬럼 패턴</label>
                        <textarea class="form-control text-uppercase" id="cfg_default_exclude_patterns"
                               data-key="default.exclude_patterns" rows="2"
                               style="text-transform: uppercase;">*_CD,*_YN,*_FLAG,*_TYPE,*_SEQ,*_IDX,*_CNT,*_AMT,REG_DATE,UPD_DATE,DEL_YN</textarea>
                        <small class="text-muted"><spring:message code="discovery.exclude_patterns_desc"/></small>
                    </div>

                    <div style="display: flex; gap: 24px; flex-wrap: wrap; margin-top: 20px;">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="cfg_default_enable_meta"
                                   data-key="default.enable_meta" checked>
                            <label class="form-check-label" for="cfg_default_enable_meta">
                                <strong>메타데이터 분석</strong>
                                <div class="text-muted" style="font-size: 0.85rem;"><spring:message code="discovery.column_comment_analysis"/></div>
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="cfg_default_enable_pattern"
                                   data-key="default.enable_pattern" checked>
                            <label class="form-check-label" for="cfg_default_enable_pattern">
                                <strong>패턴 매칭</strong>
                                <div class="text-muted" style="font-size: 0.85rem;"><spring:message code="discovery.regex_pattern_matching"/></div>
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="cfg_default_skip_confirmed"
                                   data-key="default.skip_confirmed" checked>
                            <label class="form-check-label" for="cfg_default_skip_confirmed">
                                <strong>확인된 개인정보 건너뛰기</strong>
                                <div class="text-muted" style="font-size: 0.85rem;"><spring:message code="discovery.skip_confirmed_pii"/></div>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 임계값 설정 -->
            <div class="content-panel" style="margin-top: 20px;">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-sliders" style="margin-right: 8px;"></i> <spring:message code="discovery.detection_threshold"/></h3>
                </div>
                <div class="panel-body">
                    <p class="text-muted mb-4" style="font-size: 0.9rem;">
                        <spring:message code="discovery.threshold_desc"/>
                    </p>

                    <div style="display: flex; gap: 40px; flex-wrap: wrap;">
                        <div style="flex: 1; min-width: 250px;">
                            <label class="form-label" style="font-weight: 600;"><spring:message code="discovery.min_score_threshold"/></label>
                            <div class="input-group" style="max-width: 150px;">
                                <input type="number" class="form-control" id="cfg_threshold_min_score"
                                       data-key="threshold.min_score" value="30" min="0" max="100">
                                <span class="input-group-text">%</span>
                            </div>
                            <small class="text-muted"><spring:message code="discovery.below_score_not_pii"/></small>
                            <div class="mt-2">
                                <div class="progress" style="height: 8px; max-width: 200px;">
                                    <div class="progress-bar bg-secondary" id="minScoreBar" style="width: 30%;"></div>
                                </div>
                            </div>
                        </div>

                        <div style="flex: 1; min-width: 250px;">
                            <label class="form-label" style="font-weight: 600;"><spring:message code="discovery.auto_confirm_threshold"/></label>
                            <div class="input-group" style="max-width: 150px;">
                                <input type="number" class="form-control" id="cfg_threshold_auto_confirm"
                                       data-key="threshold.auto_confirm" value="90" min="50" max="100">
                                <span class="input-group-text">%</span>
                            </div>
                            <small class="text-muted"><spring:message code="discovery.above_score_auto_confirm"/></small>
                            <div class="mt-2">
                                <div class="progress" style="height: 8px; max-width: 200px;">
                                    <div class="progress-bar bg-success" id="autoConfirmBar" style="width: 90%;"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-info mt-4" style="border-radius: 8px;">
                        <i class="fas fa-info-circle" style="margin-right: 8px;"></i>
                        <strong><spring:message code="discovery.score_range"/>:</strong>
                        <span class="badge bg-secondary" style="margin-left: 8px;">0-29%</span> 비개인정보 →
                        <span class="badge bg-warning" style="margin-left: 8px;">30-89%</span> 대기 (<spring:message code="discovery.manual_review"/>) →
                        <span class="badge bg-success" style="margin-left: 8px;">90%+</span> 자동 확인
                    </div>
                </div>
            </div>

            <!-- AI/LLM 설정 -->
            <div class="content-panel" style="margin-top: 20px;">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-robot" style="margin-right: 8px;"></i> AI/LLM 설정</h3>
                </div>
                <div class="panel-body">
                    <p class="text-muted mb-3" style="font-size: 0.9rem;">
                        AI 개인정보 탐지는 LLM(Privacy-AI 서비스)을 사용하여 컬럼 메타데이터와 샘플 데이터를 분석하여 개인정보를 정밀하게 식별합니다.
                    </p>

                    <div class="mb-3">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="cfg_llm_enabled" role="switch">
                            <label class="form-check-label" for="cfg_llm_enabled" style="font-weight: 600;">
                                AI 개인정보 탐지
                            </label>
                        </div>
                        <small class="text-muted" style="margin-left: 2.5rem; display: block;">
                            LLM 분석을 사용한 AI 기반 개인정보 탐지 활성화 (Privacy-AI 서비스 필요)
                        </small>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" style="font-weight: 600;">Privacy-AI URL</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="cfg_llm_api_url"
                                   placeholder="http://dlm-privacy-ai:8000" value="http://dlm-privacy-ai:8000">
                            <button class="btn btn-outline-secondary" type="button" id="btnTestLlm" onclick="testLlmConnection()">
                                <i class="fas fa-plug" style="margin-right: 4px;"></i> 연결 테스트
                            </button>
                        </div>
                        <small class="text-muted">Privacy-AI 서비스 엔드포인트 URL</small>
                    </div>

                    <div id="llmTestResult" style="display: none;" class="mt-2"></div>
                </div>
            </div>

            <!-- 저장 버튼 -->
            <div class="mt-4">
                <button class="btn btn-primary" id="btnSaveSettings" onclick="saveAllSettings()" style="padding: 8px 20px;">
                    <i class="fas fa-save" style="margin-right: 6px;"></i><spring:message code="discovery.save_settings"/>
                </button>
                <button class="btn btn-outline-secondary" onclick="resetToDefaults()" style="padding: 8px 16px; margin-left: 10px;">
                    <i class="fas fa-undo" style="margin-right: 6px;"></i><spring:message code="discovery.reset_to_defaults"/>
                </button>
            </div>
        </div>

        <!-- 사이드 컬럼 -->
        <div class="col-md-4">
            <!-- 통계 -->
            <div class="content-panel">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-chart-pie" style="margin-right: 8px;"></i> <spring:message code="discovery.discovery_statistics"/></h3>
                </div>
                <div class="panel-body" id="statsBody">
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.total_scan_jobs"/></div>
                        <div class="stat-value" id="statTotalJobs">-</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.total_executions"/></div>
                        <div class="stat-value" id="statTotalExecutions">-</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.tables_scanned"/></div>
                        <div class="stat-value" id="statTablesScanned">-</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.pii_columns_detected"/></div>
                        <div class="stat-value text-primary" id="statPiiDetected">-</div>
                    </div>
                    <hr>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.confirmed_pii"/></div>
                        <div class="stat-value text-success" id="statConfirmed">-</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.excluded_false_positive"/></div>
                        <div class="stat-value text-warning" id="statExcluded">-</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-label"><spring:message code="discovery.pending_review"/></div>
                        <div class="stat-value text-info" id="statPending">-</div>
                    </div>
                </div>
            </div>

            <!-- 연동 상태 -->
            <div class="content-panel" style="margin-top: 20px;">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-plug" style="margin-right: 8px;"></i> 메타 테이블 동기화</h3>
                </div>
                <div class="panel-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span><spring:message code="discovery.meta_table_sync"/></span>
                        <span class="badge badge-success"><spring:message code="discovery.active"/></span>
                    </div>
                    <small class="text-muted d-block mb-3">
                        <spring:message code="discovery.meta_table_sync_desc"/>
                    </small>
                    <div class="alert alert-light" style="padding: 10px 14px; margin-bottom: 0; border-radius: 6px; background: #f0fdf4; border: 1px solid #bbf7d0;">
                        <i class="fas fa-check-circle text-success" style="margin-right: 6px;"></i>
                        <span style="color: #166534;"><spring:message code="discovery.meta_sync_always_enabled"/></span>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<style>
.stat-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
}
.stat-label {
    color: #64748b;
    font-size: 0.9rem;
}
.stat-value {
    font-size: 1.1rem;
    font-weight: 600;
}
.form-check {
    padding-left: 1.75rem;
}
.form-check-input {
    width: 1.1rem;
    height: 1.1rem;
    margin-top: 0.2rem;
}
.form-check-label {
    margin-left: 0.5rem;
}
</style>

<script>
var contextPath = '${pageContext.request.contextPath}';
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');
var configsCache = {};

$(document).ready(function() {
    loadAllSettings();
    loadStatistics();

    // 임계값 바 업데이트
    $('#cfg_threshold_min_score').on('input', function() {
        $('#minScoreBar').css('width', $(this).val() + '%');
    });
    $('#cfg_threshold_auto_confirm').on('input', function() {
        $('#autoConfirmBar').css('width', $(this).val() + '%');
    });
});

function loadAllSettings() {
    $.get(contextPath + '/piidiscovery/api/configs', function(configs) {
        configsCache = {};
        configs.forEach(function(c) {
            configsCache[c.configKey] = c;
        });

        // 폼 요소에 값 적용
        $('[data-key]').each(function() {
            var $el = $(this);
            var key = $el.data('key');
            var config = configsCache[key];

            if (config) {
                if ($el.is(':checkbox')) {
                    $el.prop('checked', config.configValue === 'Y');
                } else {
                    $el.val(config.configValue);
                }
            }
        });

        // 임계값 바 업데이트
        $('#minScoreBar').css('width', ($('#cfg_threshold_min_score').val() || 30) + '%');
        $('#autoConfirmBar').css('width', ($('#cfg_threshold_auto_confirm').val() || 90) + '%');

    }).fail(function() {
        console.log('설정을 찾을 수 없어 기본값을 사용합니다');
    });

    // LLM 설정 별도 로드
    $.ajax({
        url: contextPath + '/piidiscovery/api/llm/settings',
        type: 'GET',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        success: function(data) {
            if (data.success) {
                $('#cfg_llm_enabled').prop('checked', data.enabled === true);
                if (data.apiUrl) {
                    $('#cfg_llm_api_url').val(data.apiUrl);
                }
            }
        }
    });
}

function loadStatistics() {
    // API에서 통계 로드
    $.get(contextPath + '/piidiscovery/api/stats', function(stats) {
        $('#statTotalJobs').text(stats.totalScans || 0);
        $('#statTotalExecutions').text('-');  // 현재 API에 없음
        $('#statTablesScanned').text(stats.totalTablesScanned || 0);
        $('#statPiiDetected').text(stats.piiColumnsDetected || 0);
        $('#statConfirmed').text(stats.confirmedPii || 0);
        $('#statExcluded').text(stats.excludedCount || 0);
        $('#statPending').text(stats.pendingReview || 0);
    }).fail(function() {
        // API 실패 시 기본값 설정
        $('#statTotalJobs, #statTotalExecutions, #statTablesScanned, #statPiiDetected').text('0');
        $('#statConfirmed, #statExcluded, #statPending').text('0');
    });
}

function saveAllSettings() {
    var settingsToSave = [];

    // 폼 요소에서 모든 설정 수집
    $('[data-key]').each(function() {
        var $el = $(this);
        var key = $el.data('key');
        var value;

        if ($el.is(':checkbox')) {
            value = $el.is(':checked') ? 'Y' : 'N';
        } else {
            value = $el.val();
        }

        var configType = 'GENERAL';
        if (key.startsWith('default.')) configType = 'DEFAULT';
        else if (key.startsWith('threshold.')) configType = 'THRESHOLD';
        else if (key.startsWith('sync.')) configType = 'SYNC';

        settingsToSave.push({
            configKey: key,
            configValue: value,
            configType: configType
        });
    });

    $('#btnSaveSettings').prop('disabled', true).html('<i class="fas fa-spinner fa-spin" style="margin-right: 8px;"></i> 저장 중...');

    var savePromises = settingsToSave.map(function(setting) {
        var existingConfig = configsCache[setting.configKey];
        var url = contextPath + '/piidiscovery/api/configs';
        var method = 'POST';

        if (existingConfig) {
            url += '/' + existingConfig.configId;
            method = 'PUT';
        }

        return $.ajax({
            url: url,
            type: method,
            contentType: 'application/json',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            data: JSON.stringify(setting)
        });
    });

    // LLM 설정 저장
    var llmSavePromise = $.ajax({
        url: contextPath + '/piidiscovery/api/llm/settings',
        type: 'POST',
        contentType: 'application/json',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        data: JSON.stringify({
            enabled: $('#cfg_llm_enabled').is(':checked'),
            apiUrl: $('#cfg_llm_api_url').val()
        })
    });
    savePromises.push(llmSavePromise);

    Promise.all(savePromises).then(function() {
        $('#btnSaveSettings').prop('disabled', false).html('<i class="fas fa-save" style="margin-right: 8px;"></i> <spring:message code="discovery.save_settings" javaScriptEscape="true"/>');
        showToast('success', '설정이 성공적으로 저장되었습니다');
        loadAllSettings();
    }).catch(function() {
        $('#btnSaveSettings').prop('disabled', false).html('<i class="fas fa-save" style="margin-right: 8px;"></i> <spring:message code="discovery.save_settings" javaScriptEscape="true"/>');
        showToast('error', '일부 설정 저장에 실패했습니다');
    });
}

function resetToDefaults() {
    showConfirmModal({
        type: 'danger',
        title: '<spring:message code="discovery.reset_settings" javaScriptEscape="true"/>',
        message: '<spring:message code="discovery.reset_settings_confirm" javaScriptEscape="true"/>',
        confirmText: '<spring:message code="discovery.reset" javaScriptEscape="true"/>'
    }).then(function(confirmed) {
        if (!confirmed) return;

        // 폼을 기본값으로 초기화
        $('#cfg_default_exclude_types').val('NUMBER,INT,INTEGER,BIGINT,FLOAT,DOUBLE,DECIMAL,DATE,DATETIME,TIMESTAMP,BLOB,CLOB,RAW,LONG');
        $('#cfg_default_exclude_patterns').val('*_CD,*_YN,*_FLAG,*_TYPE,*_SEQ,*_IDX,*_CNT,*_AMT,REG_DATE,UPD_DATE,DEL_YN');
        $('#cfg_default_enable_meta').prop('checked', true);
        $('#cfg_default_enable_pattern').prop('checked', true);
        $('#cfg_default_skip_confirmed').prop('checked', true);
        $('#cfg_threshold_min_score').val('30').trigger('input');
        $('#cfg_threshold_auto_confirm').val('90').trigger('input');
        $('#cfg_llm_enabled').prop('checked', false);
        $('#cfg_llm_api_url').val('http://dlm-privacy-ai:8000');
        $('#llmTestResult').hide();

        showToast('info', '기본값으로 초기화되었습니다. 저장 버튼을 눌러 적용하세요.');
    });
}

function testLlmConnection() {
    var apiUrl = $('#cfg_llm_api_url').val();
    if (!apiUrl) {
        $('#llmTestResult').show().html(
            '<div class="alert alert-warning" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
            '<i class="fas fa-exclamation-triangle" style="margin-right: 6px;"></i> Privacy-AI URL을 입력하세요.</div>'
        );
        return;
    }

    $('#btnTestLlm').prop('disabled', true).html('<i class="fas fa-spinner fa-spin" style="margin-right: 4px;"></i> 테스트 중...');
    $('#llmTestResult').show().html(
        '<div class="alert alert-info" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
        '<i class="fas fa-spinner fa-spin" style="margin-right: 6px;"></i> Privacy-AI 연결 중...</div>'
    );

    $.ajax({
        url: contextPath + '/piidiscovery/api/llm/test-connection',
        type: 'POST',
        contentType: 'application/json',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        data: JSON.stringify({ apiUrl: apiUrl }),
        success: function(data) {
            $('#btnTestLlm').prop('disabled', false).html('<i class="fas fa-plug" style="margin-right: 4px;"></i> 연결 테스트');

            if (data.success && data.connected) {
                var model = data.model || '알 수 없음';
                $('#llmTestResult').html(
                    '<div class="alert alert-success" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
                    '<i class="fas fa-check-circle" style="margin-right: 6px;"></i> <strong>연결 성공</strong>' +
                    (data.enabled ? ' <span class="badge bg-success" style="margin-left: 6px;">LLM 활성</span>' : ' <span class="badge bg-secondary" style="margin-left: 6px;">LLM 비활성</span>') +
                    '<br><small style="margin-top: 4px; display: inline-block;">모델: ' + model + '</small></div>'
                );
            } else if (data.success && !data.connected) {
                var error = data.error || 'LLM 미연결';
                $('#llmTestResult').html(
                    '<div class="alert alert-warning" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
                    '<i class="fas fa-exclamation-triangle" style="margin-right: 6px;"></i> <strong>Privacy-AI 정상, LLM 미연결</strong>' +
                    '<br><small style="margin-top: 4px; display: inline-block;">' + error + '</small></div>'
                );
            } else {
                $('#llmTestResult').html(
                    '<div class="alert alert-danger" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
                    '<i class="fas fa-times-circle" style="margin-right: 6px;"></i> <strong>연결 실패</strong>' +
                    '<br><small style="margin-top: 4px; display: inline-block;">' + (data.message || '알 수 없는 오류') + '</small></div>'
                );
            }
        },
        error: function() {
            $('#btnTestLlm').prop('disabled', false).html('<i class="fas fa-plug" style="margin-right: 4px;"></i> 연결 테스트');
            $('#llmTestResult').html(
                '<div class="alert alert-danger" style="padding: 10px 14px; border-radius: 6px; margin-bottom: 0;">' +
                '<i class="fas fa-times-circle" style="margin-right: 6px;"></i> <strong>요청 실패</strong></div>'
            );
        }
    });
}

function showToast(type, message) {
    var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : (type === 'info' ? '#3b82f6' : '#f59e0b'));
    var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
    $('body').append(toast);
    setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
}
</script>
