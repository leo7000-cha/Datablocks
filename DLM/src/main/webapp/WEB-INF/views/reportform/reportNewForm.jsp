<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
<html>
<head>
    <title>보고서 양식 생성/수정</title>
    <script>
        function submitForm() {
            const formData = new FormData(document.getElementById("reportForm"));

            fetch("/reportform/save", {
                method: "POST",
                body: formData
            })
                .then(response => {
                    if (!response.ok) throw new Error("서버 응답 오류");
                    return response.text();
                })
                .then(message => {
                    dlmAlert(message); // 성공 알림
                    //document.getElementById("reportForm").reset(); // 폼 초기화 (선택사항)
                })
                .catch(error => {
                    dlmAlert("저장 실패: " + error.message);
                });
            return false; // 폼 기본 제출 방지
        }
        // 불러오기 (GET)
        function loadForm() {
            const name = document.getElementById("formName").value;
            if (!name) {
                dlmAlert("양식 이름을 입력하세요.");
                return false;
            }
            // location.href로 이동
            window.location.href = "${pageContext.request.contextPath}/reportform/editor?name=" + encodeURIComponent(name);
            return false;
        }

        function previewForm() {
            const name = document.querySelector("#reportForm input[name='formName']").value;
            if (!name) {
                dlmAlert("양식 이름을 입력하세요.");
                return;
            }
            fetch("${pageContext.request.contextPath}/reportform/view?name=" + encodeURIComponent(name), {
                method: "GET",
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            })
                .then(response => {
                    if (!response.ok) throw new Error("미리보기 불러오기 실패");
                    return response.text();
                })
                .then(html => {
                    document.getElementById("previewContent").innerHTML = html;
                    document.getElementById("previewModal").style.display = "flex"; // 모달 열기
                })
                .catch(e => {
                    dlmAlert("미리보기 오류: " + e.message);
                });
        }

        function closePreviewModal() {
            document.getElementById("previewModal").style.display = "none";
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === "Escape") closePreviewModal();
        });
        document.getElementById('previewModal').addEventListener('click', function(e){
            if(e.target === this) closePreviewModal();
        });



    </script>
</head>
<body>
<h2>보고서 양식 관리 화면입니다.</h2>
<div id="formContainer"></div>
<!-- 버튼만 별도 배치 -->
<div style="margin-top:15px;">
    <button type="button" class="btn-primary" onclick="submitForm()">저장</button>
    <button type="button" class="btn-primary" onclick="loadForm()">불러오기</button>
    <button type="button" class="btn-primary" onclick="previewForm()">미리보기</button>
</div>
<form style="margin: 0; padding: 0;" id="reportForm" >
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <label>보고서 양식: <input type="text" name="formName" id="formName" value="${name}" style="width:400px"/></label>
    <textarea name="jsonData" rows="20" cols="80" style="width:100%; height:700px; background:#f4f4f4; padding:1rem; border:1px solid #ccc; white-space:pre-wrap;"><c:out value="${json}" escapeXml="false" /></textarea><br/>
</form>
<%--
<textarea id="jsonRaw" style="width:100%; height:600px; background:#f4f4f4; padding:1rem; border:1px solid #ccc; white-space:pre-wrap;"><c:out value="${json}" escapeXml="false" /></textarea>
--%>
<br/>

<!-- 미리보기 모달 (맨 아래에 위치) -->
<div id="previewModal" style="
    display:none;
    position:fixed;
    top:0; left:0;
    width:100vw; height:100vh;
    background:rgba(0,0,0,0.5);
    z-index:1000;
    align-items:center;
    justify-content:center;
">
    <div id="modalInner" style="
        background:#fff;
        width:850px;
        max-width:95vw;
        max-height:90vh;
        box-shadow:0 0 20px rgba(0,0,0,0.2);
        border-radius:8px;
        position:relative;
        overflow:auto;
        margin:40px auto;
        display:flex;
        flex-direction:column;
    ">
        <button onclick="closePreviewModal()" style="
            position:absolute;
            top:10px; right:10px;
            font-size:1.5rem;
            background:none;
            border:none;
            cursor:pointer;
            z-index:10;
        ">✖</button>
        <div id="previewContent" style="
            width:794px;
            min-height:200px;
            max-height:calc(90vh - 80px);
            margin:40px auto 20px auto;
            box-sizing:border-box;
            padding:20px;
            background:#fff;
            border:1px solid #ccc;
            box-shadow: inset 0 0 5px rgba(0,0,0,0.1);
            overflow:auto;
        ">
            <!-- 미리보기 내용이 여기에 들어감 -->
        </div>
    </div>
</div>


</body>
</html>