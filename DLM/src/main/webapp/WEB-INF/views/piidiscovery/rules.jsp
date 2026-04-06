<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!-- Detection Rules Content -->
<div id="rulesContent">
    <!-- Info Banner -->
    <div class="alert alert-info d-flex align-items-center" style="border-radius: 10px; margin-bottom: 20px;">
        <i class="fas fa-info-circle" style="font-size: 1.25rem; margin-right: 12px;"></i>
        <div>
            <spring:message code="discovery.rules_desc"/>
        </div>
    </div>

    <div class="row">
        <!-- Rule Categories -->
        <div class="col-md-4">
            <div class="content-panel">
                <div class="panel-header">
                    <h3 class="panel-title"><spring:message code="discovery.rule_categories"/></h3>
                    <button class="btn btn-sm btn-outline-primary" onclick="showAddCategoryModal()" title="<spring:message code='discovery.add_category'/>">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>
                <div class="panel-body" style="padding: 0;">
                    <div class="list-group list-group-flush" id="categoryList">
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action active" data-category="ID">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-id-card" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_id"/></div>
                                <span class="badge badge-primary" id="countID">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="SENSITIVE">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-shield-alt" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_sensitive"/></div>
                                <span class="badge badge-secondary" id="countSENSITIVE">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="AUTH">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-key" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_auth"/></div>
                                <span class="badge badge-secondary" id="countAUTH">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="FINANCIAL">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-credit-card" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_financial"/></div>
                                <span class="badge badge-secondary" id="countFINANCIAL">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="MEDICAL">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-hospital" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_medical"/></div>
                                <span class="badge badge-secondary" id="countMEDICAL">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="PERSONAL">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-user" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_personal"/></div>
                                <span class="badge badge-secondary" id="countPERSONAL">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="CONTACT">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-phone" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_contact"/></div>
                                <span class="badge badge-secondary" id="countCONTACT">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="PRIVATE">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-user-lock" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_private"/></div>
                                <span class="badge badge-secondary" id="countPRIVATE">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="AUTO">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-laptop" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_auto"/></div>
                                <span class="badge badge-secondary" id="countAUTO">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="LIMITED_ID">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-building" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_limited_id"/></div>
                                <span class="badge badge-secondary" id="countLIMITED_ID">0</span>
                            </div>
                        </a>
                        <a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="CUSTOM">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-cog" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_custom"/></div>
                                <span class="badge badge-secondary" id="countCUSTOM">0</span>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Rule Details -->
        <div class="col-md-8">
            <div class="content-panel">
                <div class="panel-header">
                    <h3 class="panel-title" id="rulesPanelTitle">
                        <i class="fas fa-id-card" style="margin-right: 8px;"></i> <spring:message code="discovery.cat_id"/>
                    </h3>
                    <button class="btn btn-sm btn-primary" onclick="showAddRuleModal()">
                        <i class="fas fa-plus"></i> <spring:message code="discovery.add_rule"/>
                    </button>
                </div>
                <div class="panel-body" style="padding: 0;">
                    <table class="discovery-table" id="rulesTable">
                        <thead>
                            <tr>
                                <th><spring:message code="discovery.rule_name"/></th>
                                <th><spring:message code="discovery.rule_type"/></th>
                                <th><spring:message code="discovery.pattern_keywords"/></th>
                                <th><spring:message code="discovery.weight"/></th>
                                <th><spring:message code="discovery.status"/></th>
                                <th style="width: 100px;"><spring:message code="discovery.actions"/></th>
                            </tr>
                        </thead>
                        <tbody id="rulesTableBody">
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">
                                    <i class="fas fa-spinner fa-spin"></i> <spring:message code="discovery.loading_rules"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Weight Configuration -->
            <div class="content-panel" style="margin-top: 20px;">
                <div class="panel-header">
                    <h3 class="panel-title"><i class="fas fa-balance-scale" style="margin-right: 8px;"></i> <spring:message code="discovery.score_weights"/></h3>
                </div>
                <div class="panel-body">
                    <div style="display: flex; gap: 20px; flex-wrap: wrap;">
                        <div style="flex: 1; min-width: 180px;">
                            <label class="form-label" style="display: block; font-weight: 600; margin-bottom: 8px;"><spring:message code="discovery.metadata_match_weight"/></label>
                            <div class="input-group" style="max-width: 150px;">
                                <input type="number" class="form-control" id="weightMeta" value="40" min="0" max="100">
                                <span class="input-group-text">%</span>
                            </div>
                            <small class="text-muted" style="display: block; margin-top: 4px;"><spring:message code="discovery.column_name_comments"/></small>
                        </div>
                        <div style="flex: 1; min-width: 180px;">
                            <label class="form-label" style="display: block; font-weight: 600; margin-bottom: 8px;"><spring:message code="discovery.pattern_match_weight"/></label>
                            <div class="input-group" style="max-width: 150px;">
                                <input type="number" class="form-control" id="weightPattern" value="35" min="0" max="100">
                                <span class="input-group-text">%</span>
                            </div>
                            <small class="text-muted" style="display: block; margin-top: 4px;"><spring:message code="discovery.data_regex_pattern"/></small>
                        </div>
                        <div style="flex: 1; min-width: 180px;">
                            <label class="form-label" style="display: block; font-weight: 600; margin-bottom: 8px;"><spring:message code="discovery.ai_match_weight"/></label>
                            <div class="input-group" style="max-width: 150px;">
                                <input type="number" class="form-control" id="weightAI" value="25" min="0" max="100">
                                <span class="input-group-text">%</span>
                            </div>
                            <small class="text-muted" style="display: block; margin-top: 4px;"><spring:message code="discovery.ml_classification"/></small>
                        </div>
                    </div>
                    <div style="margin-top: 16px; display: flex; align-items: center; gap: 16px;">
                        <button class="btn btn-primary" onclick="saveWeights()">
                            <i class="fas fa-save" style="margin-right: 4px;"></i> <spring:message code="discovery.save_weights"/>
                        </button>
                        <span id="weightTotal" style="font-weight: 600;"><spring:message code="discovery.total"/>: 100%</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Rule Modal -->
<div class="modal fade" id="ruleModal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); color: white;">
                <h5 class="modal-title" id="ruleModalTitle">
                    <i class="fas fa-plus-circle"></i> <spring:message code="discovery.add_detection_rule"/>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: white; opacity: 0.9;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 24px;">
                <form id="ruleForm">
                    <input type="hidden" id="ruleId" name="ruleId">

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.rule_name"/> <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="ruleName" name="ruleName" required
                                       placeholder="예: 한국어 이름 컬럼">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.category"/> <span class="text-danger">*</span></label>
                                <select class="form-control" id="ruleCategory" name="category" required>
                                    <option value=""><spring:message code="discovery.select_category"/>...</option>
                                    <option value="ID"><spring:message code="discovery.cat_id"/></option>
                                    <option value="SENSITIVE"><spring:message code="discovery.cat_sensitive"/></option>
                                    <option value="AUTH"><spring:message code="discovery.cat_auth"/></option>
                                    <option value="FINANCIAL"><spring:message code="discovery.cat_financial"/></option>
                                    <option value="MEDICAL"><spring:message code="discovery.cat_medical"/></option>
                                    <option value="PERSONAL"><spring:message code="discovery.cat_personal"/></option>
                                    <option value="CONTACT"><spring:message code="discovery.cat_contact"/></option>
                                    <option value="PRIVATE"><spring:message code="discovery.cat_private"/></option>
                                    <option value="AUTO"><spring:message code="discovery.cat_auto"/></option>
                                    <option value="LIMITED_ID"><spring:message code="discovery.cat_limited_id"/></option>
                                    <option value="CUSTOM"><spring:message code="discovery.cat_custom"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.rule_type"/> <span class="text-danger">*</span></label>
                                <select class="form-control" id="ruleType" name="ruleType" required onchange="onRuleTypeChange()">
                                    <option value=""><spring:message code="discovery.select_type"/>...</option>
                                    <option value="META"><spring:message code="discovery.metadata_type"/></option>
                                    <option value="PATTERN"><spring:message code="discovery.pattern_type"/></option>
                                    <option value="AI"><spring:message code="discovery.ai_type"/></option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">개인정보 유형 <span class="text-danger">*</span></label>
                                <select class="form-control" id="rulePiiType" name="piiTypeCode" required>
                                    <option value=""><spring:message code="discovery.select_pii_type"/>...</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" id="patternLabel">패턴 / 키워드 <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="rulePattern" name="pattern" rows="3" required
                                  placeholder="쉼표로 구분된 키워드: NAME, NM, 성명, 이름"></textarea>
                        <small class="text-muted" id="patternHelp">
                            메타데이터: 쉼표로 구분된 키워드 (예: NAME, NM, 성명, 이름)<br>
                            정규식: 정규 표현식 (예: ^[가-힣]{2,4}$)
                        </small>
                    </div>

                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.weight"/> <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="ruleWeight" name="weight"
                                           required min="0" max="1" step="0.01" value="0.3">
                                </div>
                                <small class="text-muted"><spring:message code="discovery.weight_help"/></small>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.priority"/></label>
                                <input type="number" class="form-control" id="rulePriority" name="priority"
                                       min="1" max="100" value="10">
                                <small class="text-muted"><spring:message code="discovery.priority_help"/></small>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label class="form-label"><spring:message code="discovery.status"/></label>
                                <select class="form-control" id="ruleStatus" name="status">
                                    <option value="ACTIVE"><spring:message code="discovery.active"/></option>
                                    <option value="INACTIVE"><spring:message code="discovery.inactive"/></option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"><spring:message code="discovery.description"/></label>
                        <textarea class="form-control" id="ruleDescription" name="description" rows="2"
                                  placeholder=""></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><spring:message code="discovery.cancel"/></button>
                <button type="button" class="btn btn-primary" onclick="saveRule()">
                    <i class="fas fa-save" style="margin-right: 4px;"></i> <spring:message code="discovery.save_rule"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Add Category Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white;">
                <h5 class="modal-title">
                    <i class="fas fa-folder-plus"></i> <spring:message code="discovery.add_custom_category"/>
                </h5>
                <button type="button" class="close" data-dismiss="modal" style="color: white; opacity: 0.9;">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" style="padding: 24px;">
                <div class="alert alert-info">
                    <i class="fas fa-info-circle" style="margin-right: 8px;"></i>
                    <spring:message code="discovery.category_info"/>
                </div>
                <form id="categoryForm">
                    <div class="form-group">
                        <label class="form-label"><spring:message code="discovery.category_code"/> <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="newCategoryCode" required
                               placeholder="예: MEDICAL" style="text-transform: uppercase;">
                    </div>
                    <div class="form-group">
                        <label class="form-label"><spring:message code="discovery.display_name"/> <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="newCategoryName" required
                               placeholder="">
                    </div>
                    <div class="form-group">
                        <label class="form-label"><spring:message code="discovery.icon"/></label>
                        <select class="form-control" id="newCategoryIcon">
                            <option value="fa-cog">기본</option>
                            <option value="fa-hospital">의료</option>
                            <option value="fa-car">차량</option>
                            <option value="fa-graduation-cap">교육</option>
                            <option value="fa-briefcase">사업</option>
                            <option value="fa-globe">글로벌</option>
                            <option value="fa-key">보안</option>
                            <option value="fa-tag">태그</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer" style="background: #f8fafc; border-top: 1px solid #e2e8f0;">
                <button type="button" class="btn btn-secondary" data-dismiss="modal"><spring:message code="discovery.cancel"/></button>
                <button type="button" class="btn btn-success" onclick="addCategory()">
                    <i class="fas fa-plus" style="margin-right: 4px;"></i> <spring:message code="discovery.add_category"/>
                </button>
            </div>
        </div>
    </div>
</div>

<style>
/* Category List Styles */
.list-group-item {
    border: none;
    border-bottom: 1px solid #e2e8f0;
    padding: 14px 20px;
    cursor: pointer;
    transition: all 0.2s;
}
.list-group-item:hover {
    background: #f1f5f9;
}
.list-group-item.active {
    background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
    color: white;
    border-color: transparent;
}
.list-group-item.active .badge {
    background: rgba(255,255,255,0.2) !important;
    color: white !important;
}
.list-group-item i {
    width: 20px;
    text-align: center;
}

/* Rules Table Styles */
#rulesTable tbody tr:hover {
    background: #f8fafc;
}
#rulesTable code {
    background: #f1f5f9;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.8rem;
    max-width: 250px;
    display: inline-block;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    vertical-align: middle;
}

/* Weight Input Validation */
.weight-error {
    color: #ef4444;
    font-weight: 600;
}
.weight-ok {
    color: #10b981;
    font-weight: 600;
}

/* Modal Form Styles */
#ruleModal .form-group {
    margin-bottom: 16px;
}
#ruleModal .form-label {
    font-weight: 600;
    color: #374151;
    margin-bottom: 6px;
}
</style>

<script>
var contextPath = '${pageContext.request.contextPath}';
var csrfToken = $('meta[name="_csrf"]').attr('content');
var csrfHeader = $('meta[name="_csrf_header"]').attr('content');

var currentCategory = 'ID';
var piiTypeList = [];

$(document).ready(function() {
    // Load initial data
    loadCategoryCounts();
    loadPiiTypes();
    loadRulesByCategory('ID');
    loadWeights();

    // Category click - single click to select
    $('#categoryList .list-group-item').click(function() {
        var category = $(this).data('category');
        selectCategory(category);
    });

    // Weight input change
    $('#weightMeta, #weightPattern, #weightAI').on('input', function() {
        updateWeightTotal();
    });
});

// ========== Category Functions ==========
function selectCategory(category) {
    currentCategory = category;

    // Update active state
    $('#categoryList .list-group-item').removeClass('active');
    $('#categoryList .list-group-item').find('.badge').removeClass('badge-primary').addClass('badge-secondary');

    var $selected = $('#categoryList .list-group-item[data-category="' + category + '"]');
    $selected.addClass('active');
    $selected.find('.badge').removeClass('badge-secondary').addClass('badge-primary');

    // Update panel title
    var title = $selected.find('div > div').first().html();
    $('#rulesPanelTitle').html(title);

    // Load rules for this category
    loadRulesByCategory(category);
}

function loadCategoryCounts() {
    $.get(contextPath + '/piidiscovery/api/rules/categories/counts', function(counts) {
        for (var cat in counts) {
            $('#count' + cat).text(counts[cat] || 0);
        }
    });
}

function showAddCategoryModal() {
    $('#categoryForm')[0].reset();
    $('#categoryModal').modal('show');
}

function addCategory() {
    var code = $('#newCategoryCode').val().toUpperCase().trim();
    var name = $('#newCategoryName').val().trim();
    var icon = $('#newCategoryIcon').val();

    if (!code || !name) {
        showToast('warning', '필수 항목을 입력하세요');
        return;
    }

    // Check if category already exists
    if ($('#categoryList .list-group-item[data-category="' + code + '"]').length > 0) {
        showToast('error', '이미 존재하는 분류입니다');
        return;
    }

    // Add to category list
    var html = '<a href="javascript:void(0)" class="list-group-item list-group-item-action" data-category="' + code + '" ondblclick="selectCategory(\'' + code + '\')">';
    html += '<div class="d-flex justify-content-between align-items-center">';
    html += '<div><i class="fas ' + icon + ' me-2"></i> ' + name + '</div>';
    html += '<span class="badge badge-secondary" id="count' + code + '">0</span>';
    html += '</div></a>';

    $('#categoryList').append(html);

    // Bind click event
    $('#categoryList .list-group-item[data-category="' + code + '"]').click(function() {
        selectCategory(code);
    });

    // Add to category dropdown in rule modal
    $('#ruleCategory').append('<option value="' + code + '">' + name + '</option>');

    $('#categoryModal').modal('hide');
    showToast('success', '분류 추가됨: ' + name);
}

// ========== Rules Functions ==========
function loadRulesByCategory(category) {
    $('#rulesTableBody').html('<tr><td colspan="6" class="text-center text-muted py-4"><i class="fas fa-spinner fa-spin"></i> 로딩 중...</td></tr>');

    $.get(contextPath + '/piidiscovery/api/rules/category/' + category, function(rules) {
        renderRulesTable(rules);
    }).fail(function() {
        $('#rulesTableBody').html('<tr><td colspan="6" class="text-center text-danger py-4"><i class="fas fa-exclamation-triangle"></i> 규칙을 불러오지 못했습니다</td></tr>');
    });
}

function renderRulesTable(rules) {
    if (!rules || rules.length === 0) {
        $('#rulesTableBody').html('<tr><td colspan="6" class="text-center text-muted py-4"><i class="fas fa-inbox fa-2x mb-2"></i><br>규칙이 없습니다<br><small>"규칙 추가" 버튼을 눌러 생성하세요</small></td></tr>');
        return;
    }

    var html = '';
    rules.forEach(function(rule) {
        var typeBadge = rule.ruleType === 'META' ? '<span class="badge badge-info">메타데이터</span>' :
                       rule.ruleType === 'PATTERN' ? '<span class="badge badge-warning">정규식</span>' :
                       '<span class="badge badge-success">AI</span>';

        var statusBadge = rule.status === 'ACTIVE' ?
                         '<span class="status-badge completed">활성</span>' :
                         '<span class="status-badge pending">비활성</span>';

        html += '<tr data-rule-id="' + rule.ruleId + '">';
        html += '<td><strong>' + escapeHtml(rule.ruleName) + '</strong></td>';
        html += '<td>' + typeBadge + '</td>';
        html += '<td><code title="' + escapeHtml(rule.pattern) + '">' + escapeHtml(rule.pattern) + '</code></td>';
        html += '<td>' + (rule.weight || 0) + '</td>';
        html += '<td>' + statusBadge + '</td>';
        html += '<td>';
        html += '<button class="btn btn-sm btn-outline-primary me-1" title="수정" onclick="editRule(\'' + rule.ruleId + '\')"><i class="fas fa-edit"></i></button>';
        html += '<button class="btn btn-sm btn-outline-danger" title="삭제" onclick="deleteRule(\'' + rule.ruleId + '\', \'' + escapeHtml(rule.ruleName) + '\')"><i class="fas fa-trash"></i></button>';
        html += '</td>';
        html += '</tr>';
    });

    $('#rulesTableBody').html(html);
}

function showAddRuleModal() {
    $('#ruleModalTitle').html('<i class="fas fa-plus-circle"></i> 탐지 규칙 추가');
    $('#ruleForm')[0].reset();
    $('#ruleId').val('');
    $('#ruleCategory').val(currentCategory);
    $('#ruleWeight').val('0.3');
    $('#rulePriority').val('10');
    $('#ruleStatus').val('ACTIVE');

    loadPiiTypesDropdown();
    $('#ruleModal').modal('show');
}

function editRule(ruleId) {
    $.get(contextPath + '/piidiscovery/api/rules/' + ruleId, function(rule) {
        $('#ruleModalTitle').html('<i class="fas fa-edit"></i> 탐지 규칙 수정');
        $('#ruleId').val(rule.ruleId);
        $('#ruleName').val(rule.ruleName);
        $('#ruleCategory').val(rule.category);
        $('#ruleType').val(rule.ruleType);
        $('#rulePattern').val(rule.pattern);
        $('#ruleWeight').val(rule.weight);
        $('#rulePriority').val(rule.priority || 10);
        $('#ruleStatus').val(rule.status);
        $('#ruleDescription').val(rule.description);

        loadPiiTypesDropdown(rule.piiTypeCode);
        onRuleTypeChange();
        $('#ruleModal').modal('show');
    }).fail(function() {
        showToast('error', '규칙 상세를 불러오지 못했습니다');
    });
}

function saveRule() {
    // Validation
    var ruleName = $('#ruleName').val().trim();
    var category = $('#ruleCategory').val();
    var ruleType = $('#ruleType').val();
    var piiTypeCode = $('#rulePiiType').val();
    var pattern = $('#rulePattern').val().trim();
    var weight = parseFloat($('#ruleWeight').val());

    if (!ruleName || !category || !ruleType || !piiTypeCode || !pattern) {
        showToast('warning', '모든 필수 항목을 입력하세요');
        return;
    }

    if (isNaN(weight) || weight < 0 || weight > 1) {
        showToast('warning', '가중치는 0과 1 사이여야 합니다');
        return;
    }

    var rule = {
        ruleId: $('#ruleId').val() || null,
        ruleName: ruleName,
        category: category,
        ruleType: ruleType,
        piiTypeCode: piiTypeCode,
        pattern: pattern,
        weight: weight,
        priority: parseInt($('#rulePriority').val()) || 10,
        status: $('#ruleStatus').val(),
        description: $('#ruleDescription').val().trim()
    };

    var isEdit = !!rule.ruleId;
    var url = contextPath + '/piidiscovery/api/rules' + (isEdit ? '/' + rule.ruleId : '');
    var method = isEdit ? 'PUT' : 'POST';

    $.ajax({
        url: url,
        type: method,
        contentType: 'application/json',
        beforeSend: function(xhr) {
            if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
        },
        data: JSON.stringify(rule),
        success: function(response) {
            if (response.success) {
                $('#ruleModal').modal('hide');
                showToast('success', isEdit ? '규칙이 수정되었습니다' : '규칙이 생성되었습니다');
                loadRulesByCategory(currentCategory);
                loadCategoryCounts();
            } else {
                showToast('error', response.message || '규칙 저장에 실패했습니다');
            }
        },
        error: function() {
            showToast('error', '규칙 저장에 실패했습니다');
        }
    });
}

function deleteRule(ruleId, ruleName) {
    showConfirmModal({
        type: 'danger',
        title: '규칙 삭제',
        message: '정말 삭제하시겠습니까 "' + ruleName + '"?\n이 작업은 되돌릴 수 없습니다.',
        confirmText: '삭제'
    }).then(function(confirmed) {
        if (!confirmed) return;

        $.ajax({
            url: contextPath + '/piidiscovery/api/rules/' + ruleId,
            type: 'DELETE',
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            success: function(response) {
                if (response.success) {
                    showToast('success', '규칙이 삭제되었습니다');
                    $('tr[data-rule-id="' + ruleId + '"]').fadeOut(function() {
                        $(this).remove();
                        loadCategoryCounts();
                    });
                } else {
                    showToast('error', response.message || '삭제에 실패했습니다');
                }
            },
            error: function() {
                showToast('error', '규칙 삭제에 실패했습니다');
            }
        });
    });
}

function onRuleTypeChange() {
    var type = $('#ruleType').val();
    if (type === 'META') {
        $('#patternLabel').html('키워드 <span class="text-danger">*</span>');
        $('#rulePattern').attr('placeholder', '쉼표로 구분된 키워드: NAME, NM, 성명, 이름');
        $('#patternHelp').html('컬럼명 또는 코멘트와 매칭할 키워드를 쉼표로 구분하여 입력하세요');
    } else if (type === 'PATTERN') {
        $('#patternLabel').html('정규식 패턴 <span class="text-danger">*</span>');
        $('#rulePattern').attr('placeholder', '예: ^[가-힣]{2,4}$ 또는 \\d{6}-\\d{7}');
        $('#patternHelp').html('데이터 값과 매칭할 정규 표현식을 입력하세요');
    } else if (type === 'AI') {
        $('#patternLabel').html('AI 모델 설정 <span class="text-danger">*</span>');
        $('#rulePattern').attr('placeholder', 'AI 모델 설정 또는 식별자');
        $('#patternHelp').html('AI/ML 모델 파라미터를 설정하세요');
    }
}

// ========== PII Types ==========
function loadPiiTypes() {
    $.get(contextPath + '/piidiscovery/api/pii-types', function(types) {
        piiTypeList = types || [];
    });
}

function loadPiiTypesDropdown(selectedValue) {
    var html = '<option value="">개인정보 유형 선택...</option>';
    piiTypeList.forEach(function(t) {
        var selected = (selectedValue && selectedValue === t.piiTypeCode) ? ' selected' : '';
        html += '<option value="' + t.piiTypeCode + '"' + selected + '>' + t.piiTypeName + '</option>';
    });
    $('#rulePiiType').html(html);
}

// ========== Weights ==========
function loadWeights() {
    // Load from config API
    $.get(contextPath + '/piidiscovery/api/configs', function(configs) {
        configs.forEach(function(c) {
            if (c.configKey === 'weight.metadata') {
                $('#weightMeta').val(parseInt(c.configValue) || 40);
            } else if (c.configKey === 'weight.pattern') {
                $('#weightPattern').val(parseInt(c.configValue) || 35);
            } else if (c.configKey === 'weight.ai') {
                $('#weightAI').val(parseInt(c.configValue) || 25);
            }
        });
        updateWeightTotal();
    });
}

function updateWeightTotal() {
    var meta = parseInt($('#weightMeta').val()) || 0;
    var pattern = parseInt($('#weightPattern').val()) || 0;
    var ai = parseInt($('#weightAI').val()) || 0;
    var total = meta + pattern + ai;

    var $total = $('#weightTotal');
    $total.text('합계: ' + total + '%');

    if (total === 100) {
        $total.removeClass('weight-error').addClass('weight-ok');
    } else {
        $total.removeClass('weight-ok').addClass('weight-error');
    }
}

function saveWeights() {
    var meta = parseInt($('#weightMeta').val()) || 0;
    var pattern = parseInt($('#weightPattern').val()) || 0;
    var ai = parseInt($('#weightAI').val()) || 0;
    var total = meta + pattern + ai;

    if (total !== 100) {
        showConfirmModal({
            type: 'warning',
            title: '가중치 합계 경고',
            message: '가중치 합계가 ' + total + '%이며, 100%가 아닙니다.\n계속 저장하시겠습니까?',
            confirmText: '그래도 저장'
        }).then(function(confirmed) {
            if (confirmed) doSaveWeights(meta, pattern, ai);
        });
    } else {
        doSaveWeights(meta, pattern, ai);
    }
}

function doSaveWeights(meta, pattern, ai) {
    var configs = [
        { configKey: 'weight.metadata', configValue: String(meta), configType: 'SCAN' },
        { configKey: 'weight.pattern', configValue: String(pattern), configType: 'SCAN' },
        { configKey: 'weight.ai', configValue: String(ai), configType: 'SCAN' }
    ];

    var saveCount = 0;
    var errorCount = 0;

    configs.forEach(function(config) {
        $.ajax({
            url: contextPath + '/piidiscovery/api/configs',
            type: 'POST',
            contentType: 'application/json',
            async: false,
            beforeSend: function(xhr) {
                if (csrfHeader && csrfToken) xhr.setRequestHeader(csrfHeader, csrfToken);
            },
            data: JSON.stringify(config),
            success: function() { saveCount++; },
            error: function() { errorCount++; }
        });
    });

    if (errorCount === 0) {
        showToast('success', '가중치가 저장되었습니다');
    } else {
        showToast('error', '일부 가중치 저장에 실패했습니다');
    }
}

// ========== Utilities ==========
function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}

function showToast(type, message) {
    var bgColor = type === 'success' ? '#10b981' : (type === 'error' ? '#ef4444' : '#f59e0b');
    var toast = $('<div class="position-fixed" style="top: 20px; right: 20px; z-index: 9999; padding: 12px 20px; background: ' + bgColor + '; color: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + message + '</div>');
    $('body').append(toast);
    setTimeout(function() { toast.fadeOut(function() { toast.remove(); }); }, 3000);
}

// Modal cleanup
$('#ruleModal, #categoryModal').on('hidden.bs.modal', function() {
    setTimeout(function() {
        if ($('.modal.show').length === 0) {
            $('.modal-backdrop').remove();
            $('body').removeClass('modal-open').css('padding-right', '');
        }
    }, 100);
});
</script>
