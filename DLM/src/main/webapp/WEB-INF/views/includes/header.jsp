<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>


  <!-- Custom fonts for this template -->
  <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">

  <!-- Custom styles for this template -->
  <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">

<div id="header" class="card shadow" style="width: 100%;  height: 40px;">
    <div class="search-container-1row-523">
        <div class="search-item">
            <label class="lable-search" style="vertical-align: middle;">
                <div class="mb-0 " style="font-weight: bold;" id=menupath></div>
            </label>
        </div>
        <div class="search-item"></div>
        <div class="search-item" style="display: flex; justify-content: flex-end;">
            <div style="display: flex; align-items: center; margin-left: auto;">
            <div class="language-select">
                <div class="dropdown-label">
                    <c:choose>
                        <c:when test="${currentLocale == 'ko-KR'}">
                            <img src="resources/img/ko.svg" alt="한국어" class="current-flag">
                        </c:when>
                        <c:when test="${currentLocale == 'ja-JP'}">
                            <img src="resources/img/ja.svg" alt="일본어" class="current-flag">
                        </c:when>
                        <c:when test="${currentLocale == 'zh-CN'}">
                            <img src="resources/img/zh.svg" alt="중국어" class="current-flag">
                        </c:when>
                        <c:when test="${currentLocale == 'fr-FR'}">
                            <img src="resources/img/fr.svg" alt="프랑스어" class="current-flag">
                        </c:when>
                        <c:otherwise>
                            <img src="resources/img/us.svg" alt="영어" class="current-flag">
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="dropdown-content">
                    <a href="/changeLocale?lang=ko_KR" class="language-option selected">
                        <img src="resources/img/ko.svg" alt="한국어" class="option-flag">
                        <span>한국어</span>
                        <c:if test="${currentLocale == 'ko-KR'}">
                            <span class="checkmark">&#10004;</span>
                        </c:if>
                    </a>
                    <a href="/changeLocale?lang=en_US" class="language-option">
                        <img src="resources/img/us.svg" alt="영어" class="option-flag">
                        <span>English</span>
                        <c:if test="${currentLocale == 'en-US'}">
                            <span class="checkmark">&#10004;</span>
                        </c:if>
                    </a>
                    <%--<a href="/changeLocale?lang=zh" class="language-option">
                        <img src="resources/img/zh.svg" alt="중국어" class="option-flag">
                        <span>简体中文</span>
                    </a>
                    <a href="/changeLocale?lang=ja" class="language-option">
                        <img src="resources/img/ja.svg" alt="일본어" class="option-flag">
                        <span>日本語</span>
                    </a>
                    <a href="/changeLocale?lang=fr" class="language-option">
                        <img src="resources/img/fr.svg" alt="프랑스어" class="option-flag">
                        <span>Français</span>
                    </a>--%>

                </div>
            </div>

            <style>
                .language-select {
                    position: relative;
                    display: inline-block;
                }

                .dropdown-label {
                    cursor: pointer;
                    padding: 10px;
                    display: flex; /* flexbox 사용 */
                    align-items: center; /* 수직 가운데 정렬 */
                }

                .dropdown-content {
                    display: none;
                    position: absolute;
                    background-color: #f9f9f9;
                    min-width: 160px;
                    box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
                    z-index: 9999;
                }

                /*.language-select:hover .dropdown-content {
                    display: block;
                }*/

                .language-option {
                    display: flex;
                    align-items: center;
                    padding: 10px;
                    text-decoration: none;
                    color: black;
                }

                .language-option:hover {
                    background-color: #f1f1f1;
                }

                .option-flag, .current-flag {
                    width: 20px;
                    margin-right: 10px;
                }

                .checkmark {
                    margin-left: auto;
                    color: green;
                }

                .language-option.selected {
                    background-color: #e0e0e0;
                }

                .dropdown-content a.language-option {
                    width: 100%;
                    box-sizing: border-box;
                }

                .user-info {
                    padding: 6px 12px;
                    background-color: #f8f9fc;
                    border-radius: 8px;
                    box-shadow: 0 1px 4px rgba(0,0,0,0.05);
                    font-size: 14px;
                }

                .username-info {
                    font-weight: 500;
                    font-size: 14px;
                    line-height: 1.4;
                }

                .logout-btn {
                    background-color: #6c757d; /* Bootstrap secondary */
                    color: white !important;
                    padding: 1px 5px;
                    border-radius: 20px;
                    font-size: 12px;
                    font-weight: 500;
                    transition: background-color 0.2s ease;
                    text-decoration: none;
                }

                .logout-btn:hover {
                    background-color: #495057;
                    color: #fff;
                }

            </style>

                <div class="user-info-box">
                    <i class="fas fa-user-circle"></i>
                    <div class="username-info">
                        <sec:authentication property="principal.member.userName"/>
                    </div>
                    <input type="hidden" id="global_userid" value="<sec:authentication property='principal.member.userid'/>">
                    <input type="hidden" id="global_userName" value="<sec:authentication property='principal.member.userName'/>">
                    <a href="#" data-toggle="modal" data-target="#logoutModal" class="logout-btn-modern">
                        <%--<i class="fas fa-sign-out-alt"></i> --%>Logout
                    </a>
                </div>

            </div>
        </div>
	</div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const label = document.querySelector('.dropdown-label');
        const content = document.querySelector('.dropdown-content');

        label.addEventListener('click', function() {
            content.style.display = content.style.display === 'block' ? 'none' : 'block';
        });

        // 드롭다운 외부 클릭 시 닫기
        document.addEventListener('click', function(event) {
            if (!label.contains(event.target) && !content.contains(event.target)) {
                content.style.display = 'none';
            }
        });
    });
</script>