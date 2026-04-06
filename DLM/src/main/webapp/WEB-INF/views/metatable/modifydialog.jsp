<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<style>
    /* Compact Layout */
    .meta-content {
        padding: 16px;
    }

    /* Column Info - Compact Table */
    .info-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 12px;
        font-size: 12px;
    }

    .info-table th {
        background: #f1f5f9;
        padding: 6px 10px;
        font-weight: 600;
        color: #475569;
        border: 1px solid #e2e8f0;
        text-align: center;
        white-space: nowrap;
    }

    .info-table td {
        padding: 6px 10px;
        border: 1px solid #e2e8f0;
        text-align: center;
        background: #fff;
    }

    .info-table td.editable {
        background: #fefce8;
        padding: 4px 6px;
    }

    .info-table .input-sm {
        width: 100%;
        height: 26px;
        padding: 2px 6px;
        font-size: 12px;
        border: 1px solid #d1d5db;
        border-radius: 3px;
    }

    .info-table .input-sm:focus {
        outline: none;
        border-color: #3b82f6;
    }

    /* PII Section */
    .pii-box {
        border: 1px solid #d1d5db;
        border-radius: 4px;
        background: #fff;
    }

    .pii-header {
        background: #1e40af;
        padding: 10px 14px;
        font-size: 13px;
        font-weight: 600;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .pii-header i {
        margin-right: 8px;
    }

    .btn-pii-reset {
        padding: 3px 10px;
        font-size: 11px;
        font-weight: 600;
        color: #1e40af;
        background: #fff;
        border: 1px solid #93c5fd;
        border-radius: 4px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .btn-pii-reset:hover {
        background: #fee2e2;
        border-color: #fca5a5;
        color: #dc2626;
    }

    .pii-body {
        max-height: 520px;
        overflow-y: auto;
        padding: 0;
        background: #fff;
    }

    /* PII Row - 가로 배치 */
    .pii-row {
        display: flex;
        align-items: center;
        border-bottom: 1px solid #e5e7eb;
        min-height: 36px;
        background: #fff;
    }

    .pii-row:last-child {
        border-bottom: none;
    }

    .pii-grade {
        width: 36px;
        align-self: stretch;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 700;
        color: #fff;
        flex-shrink: 0;
    }

    .pii-grade.g1 { background: linear-gradient(135deg, #ef4444, #dc2626); }
    .pii-grade.g2 { background: linear-gradient(135deg, #f97316, #ea580c); }
    .pii-grade.g3 { background: linear-gradient(135deg, #eab308, #ca8a04); }
    .pii-grade.g4 { background: linear-gradient(135deg, #22c55e, #16a34a); }
    .pii-grade.g0 { background: linear-gradient(135deg, #9ca3af, #6b7280); }

    .pii-category {
        width: 180px;
        padding: 8px 12px;
        font-size: 12px;
        font-weight: 600;
        color: #1e3a5f;
        background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
        border-right: 1px solid #cbd5e1;
        display: flex;
        align-items: center;
        align-self: stretch;
        flex-shrink: 0;
        line-height: 1.4;
    }

    .pii-items {
        flex: 1;
        padding: 6px 12px;
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        align-items: center;
        align-content: center;
    }

    /* Chip Style */
    .chip {
        position: relative;
    }

    .chip input {
        position: absolute;
        opacity: 0;
        width: 0;
        height: 0;
    }

    .chip label {
        display: inline-block;
        padding: 5px 12px;
        font-size: 12px;
        font-weight: 500;
        color: #334155;
        background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }

    .chip label:hover {
        background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
        border-color: #38bdf8;
        color: #0369a1;
        box-shadow: 0 2px 6px rgba(56, 189, 248, 0.2);
    }

    .chip input:checked + label {
        background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        border-color: #1e40af;
        color: #fff;
        font-weight: 600;
        box-shadow: 0 3px 8px rgba(29, 78, 216, 0.35);
    }

    /* Action */
    .action-bar {
        padding: 12px 0 0 0;
        text-align: right;
    }

    .btn-save {
        padding: 6px 16px;
        font-size: 12px;
        font-weight: 600;
        color: #fff;
        background: #3b82f6;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    .btn-save:hover {
        background: #2563eb;
    }

    /* Scrollbar */
    .pii-body::-webkit-scrollbar {
        width: 5px;
    }
    .pii-body::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 3px;
    }
</style>

<div class="meta-content">
    <!-- Column Info Table -->
    <table class="info-table">
        <tr>
            <th>DB</th>
            <th>Owner</th>
            <th>Table</th>
            <th>Column</th>
            <th>PK</th>
            <th><spring:message code="col.encript_flag" text="Encrypt"/></th>
            <th><spring:message code="col.scramble_type" text="Scramble"/></th>
            <th><spring:message code="col.masterkey" text="Parent Key"/></th>
            <th><spring:message code="col.masteryn" text="Parent YN"/></th>
        </tr>
        <tr>
            <td><c:out value="${metatable.db}"/></td>
            <td><c:out value="${metatable.owner}"/></td>
            <td><c:out value="${metatable.table_name}"/></td>
            <td><c:out value="${metatable.column_name}"/></td>
            <td><c:out value="${metatable.pk_yn}"/></td>
            <td class="editable">
                <select class="input-sm" id="encript_flag">
                    <option value=""></option>
                    <option value="Y" <c:if test="${metatable.encript_flag eq 'Y'}">selected</c:if>>Y</option>
                </select>
            </td>
            <td class="editable">
                <input type="text" class="input-sm" id="scramble_type" value='<c:out value="${metatable.scramble_type}"/>'>
            </td>
            <td class="editable">
                <input type="text" class="input-sm" id="masterkey" value='<c:out value="${metatable.masterkey}"/>'>
            </td>
            <td class="editable">
                <select class="input-sm" id="masteryn">
                    <option value=""></option>
                    <option value="Y" <c:if test="${metatable.masteryn eq 'Y'}">selected</c:if>>Y</option>
                </select>
            </td>
        </tr>
    </table>

    <!-- PII Classification -->
    <div class="pii-box">
        <div class="pii-header">
            <span><i class="fas fa-shield-alt"></i>
            <spring:message code="etc.piiclassification" text="PII Classification"/></span>
            <button type="button" class="btn-pii-reset" id="btnPiiReset">
                <i class="fas fa-undo"></i> Reset
            </button>
        </div>
        <div class="pii-body">
            <form id="pii_classification">
                <c:set var="prevGroupId" value="0"/>
                <c:forEach var="item" items="${listlkPiiScrType}" varStatus="loop">
                    <c:if test="${item.piigroupid ne prevGroupId}">
                        <c:if test="${not loop.first}">
                                </div>
                            </div>
                        </c:if>
                        <div class="pii-row">
                            <div class="pii-grade g${item.piigradeid}">${item.piigradeid}</div>
                            <div class="pii-category">${item.piigroupname}</div>
                            <div class="pii-items">
                    </c:if>

                    <div class="chip">
                        <input type="radio" name="personalInfoType" id="${item.piicode}" value="${item.piicode}"
                               <c:if test="${metatable.piitype == item.piicode}">checked</c:if>>
                        <label for="${item.piicode}">${item.piitypename}</label>
                    </div>

                    <c:set var="prevGroupId" value="${item.piigroupid}"/>

                    <c:if test="${loop.last}">
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </form>
        </div>
    </div>

    <!-- Action -->
    <div class="action-bar">
        <button data-oper='saveMetaUpdate' class="btn-save">
            <i class="fas fa-save"></i> <spring:message code="btn.save" text="Save"/>
        </button>
    </div>

    <!-- Hidden Forms -->
    <form style="display:none;" id="searchForm">
        <input type='hidden' name='pagenum' value='<c:out value="${cri.pagenum}"/>'>
        <input type='hidden' name='amount' value='<c:out value="${cri.amount}"/>'>
        <input type='hidden' name='search1' value='<c:out value="${cri.search1}"/>'>
        <input type='hidden' name='search2' value='<c:out value="${cri.search2}"/>'>
        <input type='hidden' name='search3' value='<c:out value="${cri.search3}"/>'>
        <input type='hidden' name='search4' value='<c:out value="${cri.search4}"/>'>
        <input type='hidden' name='search5' value='<c:out value="${cri.search5}"/>'>
        <input type='hidden' name='search6' value='<c:out value="${cri.search6}"/>'>
        <input type='hidden' name='search7' value='<c:out value="${cri.search7}"/>'>
        <input type='hidden' name='search8' value='<c:out value="${cri.search8}"/>'>
    </form>

    <form style="display:none;" id="metatable_modify_form">
        <input type="hidden" name='db' value='<c:out value="${metatable.db}"/>'>
        <input type="hidden" name='owner' value='<c:out value="${metatable.owner}"/>'>
        <input type="hidden" name='table_name' value='<c:out value="${metatable.table_name}"/>'>
        <input type="hidden" name='column_name' value='<c:out value="${metatable.column_name}"/>'>
        <input type="hidden" name='column_id' value='<c:out value="${metatable.column_id}"/>'>
        <input type="hidden" name='pk_yn' value='<c:out value="${metatable.pk_yn}"/>'>
        <input type="hidden" name='pk_position' value='<c:out value="${metatable.pk_position}"/>'>
        <input type="hidden" name='full_data_type' value='<c:out value="${metatable.full_data_type}"/>'>
        <input type="hidden" name='data_type' value='<c:out value="${metatable.data_type}"/>'>
        <input type="hidden" name='data_length' value='<c:out value="${metatable.data_length}"/>'>
        <input type="hidden" name='domain' value='<c:out value="${metatable.domain}"/>'>
        <input type="hidden" name='piitype' value='<c:out value="${metatable.piitype}"/>'>
        <input type="hidden" name='piigrade' value='<c:out value="${metatable.piigrade}"/>'>
        <input type="hidden" name='encript_flag' value='<c:out value="${metatable.encript_flag}"/>'>
        <input type="hidden" name='scramble_type' value='<c:out value="${metatable.scramble_type}"/>'>
        <input type="hidden" name='regdate' value='<c:out value="${metatable.regdate}"/>'>
        <input type="hidden" name='upddate' value='<c:out value="${metatable.upddate}"/>'>
        <input type="hidden" name='reguserid' value='<c:out value="${metatable.reguserid}"/>'>
        <input type="hidden" name='upduserid' value='<c:out value="${metatable.upduserid}"/>'>
        <input type="hidden" name='masterkey' value='<c:out value="${metatable.masterkey}"/>'>
        <input type="hidden" name='masteryn' value='<c:out value="${metatable.masteryn}"/>'>
        <input type="hidden" name='table_comment' value='<c:out value="${metatable.table_comment}"/>'>
        <input type="hidden" name='column_comment' value='<c:out value="${metatable.column_comment}"/>'>
        <input type="hidden" name='val1' value='<c:out value="${metatable.val1}"/>'>
        <input type="hidden" name='val2' value='<c:out value="${metatable.val2}"/>'>
        <input type="hidden" name='val3' value='<c:out value="${metatable.val3}"/>'>
        <input type="hidden" name='val4' value='<c:out value="${metatable.val4}"/>'>
    </form>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

        const radios = document.querySelectorAll('input[name="personalInfoType"]');
        const textInput = document.getElementById('scramble_type');
        const encript_flag = document.getElementById('encript_flag');

        radios.forEach(radio => {
            radio.addEventListener('change', function () {
                <c:forEach var="item" items="${listlkPiiScrType}">
                if (radio.value === "${item.piicode}") {
                    textInput.value = "${item.scrtype}";
                    encript_flag.value = "${empty item.encdecfunctype ? '' : 'Y'}";
                }
                </c:forEach>
            });
        });

        $("#btnPiiReset").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();
            // 라디오 버튼 선택 해제
            document.querySelectorAll('input[name="personalInfoType"]').forEach(function(radio) {
                radio.checked = false;
            });
            // 관련 필드 초기화
            document.getElementById('scramble_type').value = '';
            document.getElementById('encript_flag').value = '';
        });

        $("button[data-oper='saveMetaUpdate']").on("click", function (e) {
            e.preventDefault();
            e.stopPropagation();

            var search1 = "<c:out value='${cri.search1}'/>";
            var search2 = "<c:out value='${cri.search2}'/>";
            var search3 = "<c:out value='${cri.search3}'/>";
            var search4 = "<c:out value='${cri.search4}'/>";
            var url_search = "";
            if (!isEmpty(search1)) url_search += "search1=" + search1;
            if (!isEmpty(search2)) url_search += "&search2=" + search2;
            if (!isEmpty(search3)) url_search += "&search3=" + search3;
            if (!isEmpty(search4)) url_search += "&search4=" + search4;

            const radioButtons = document.querySelectorAll('input[name="personalInfoType"]');
            const textInput = document.getElementById('scramble_type');
            let selectedValue = null;
            let selectedLabel = null;

            radioButtons.forEach(radioButton => {
                if (radioButton.checked) {
                    selectedValue = radioButton.value;
                    const labelElement = document.querySelector('label[for="' + selectedValue + '"]');
                    selectedLabel = labelElement.textContent;
                }
            });

            var grade = null;
            var midclass = null;
            if (selectedValue) {
                const parts = selectedValue.split("_");
                grade = parts[0];
                midclass = parts[1];
                if (selectedValue == "notpii") {
                    $("#metatable_modify_form input[name='piitype']").val("");
                    $("#metatable_modify_form input[name='piigrade']").val("");
                } else {
                    $("#metatable_modify_form input[name='piitype']").val(selectedValue);
                    $("#metatable_modify_form input[name='piigrade']").val(grade);
                }
            } else {
                $("#metatable_modify_form input[name='piitype']").val("");
                $("#metatable_modify_form input[name='piigrade']").val("");
            }

            const encriptFlagSelect = document.getElementById('encript_flag');
            const encriptFlagValue = encriptFlagSelect.value;
            const scrambleTypeSelect = document.getElementById('scramble_type');
            const scrambleTypeValue = scrambleTypeSelect.value;

            $("#metatable_modify_form input[name='encript_flag']").val(encriptFlagValue);
            $("#metatable_modify_form input[name='scramble_type']").val(scrambleTypeValue);

            const masterkeyValue = document.getElementById('masterkey').value;
            $("#metatable_modify_form input[name='masterkey']").val(masterkeyValue);
            const masterynValue = document.getElementById('masteryn').value;
            $("#metatable_modify_form input[name='masteryn']").val(masterynValue);

            var formData = {
                db: $("#metatable_modify_form input[name='db']").val(),
                owner: $("#metatable_modify_form input[name='owner']").val(),
                table_name: $("#metatable_modify_form input[name='table_name']").val(),
                column_name: $("#metatable_modify_form input[name='column_name']").val(),
                column_id: $("#metatable_modify_form input[name='column_id']").val(),
                pk_yn: $("#metatable_modify_form input[name='pk_yn']").val(),
                pk_position: $("#metatable_modify_form input[name='pk_position']").val(),
                full_data_type: $("#metatable_modify_form input[name='full_data_type']").val(),
                data_type: $("#metatable_modify_form input[name='data_type']").val(),
                data_length: $("#metatable_modify_form input[name='data_length']").val(),
                domain: $("#metatable_modify_form input[name='domain']").val(),
                piitype: $("#metatable_modify_form input[name='piitype']").val(),
                piigrade: $("#metatable_modify_form input[name='piigrade']").val(),
                encript_flag: $("#metatable_modify_form input[name='encript_flag']").val(),
                scramble_type: $("#metatable_modify_form input[name='scramble_type']").val(),
                regdate: $("#metatable_modify_form input[name='regdate']").val(),
                upddate: $("#metatable_modify_form input[name='upddate']").val(),
                reguserid: $("#metatable_modify_form input[name='reguserid']").val(),
                upduserid: $("#metatable_modify_form input[name='upduserid']").val(),
                masterkey: $("#metatable_modify_form input[name='masterkey']").val(),
                masteryn: $("#metatable_modify_form input[name='masteryn']").val(),
                table_comment: $("#metatable_modify_form input[name='table_comment']").val(),
                column_comment: $("#metatable_modify_form input[name='column_comment']").val(),
                val1: $("#metatable_modify_form input[name='val1']").val(),
                val2: $("#metatable_modify_form input[name='val2']").val(),
                val3: $("#metatable_modify_form input[name='val3']").val(),
                val4: $("#metatable_modify_form input[name='val4']").val()
            };

            var urlstr = "/metatable/piimodify?" + url_search;

            $.ajax({
                url: urlstr,
                dataType: "text",
                contentType: "application/json; charset=UTF-8",
                type: "post",
                data: JSON.stringify(formData),
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
                },
                success: function (data, textStatus, jqXHR) {
                    ingHide();
                    $("#dialogmetadataupdate").modal("hide");
                    // 리스트 갱신 (stats, 수정일 등 반영)
                    if (typeof searchAction === 'function') {
                        var currentPage = $('#searchForm [name="pagenum"]').val() || 1;
                        searchAction(currentPage);
                    }
                },
                error: function (request, error) {
                    ingHide();
                    $("#errormodalbody").html(request.responseText);
                    $("#errormodal").modal("show");
                }
            });
        });
    });
</script>
