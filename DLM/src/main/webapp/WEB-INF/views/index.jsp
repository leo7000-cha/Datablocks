<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%-- <%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %> --%>
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge; chrome=1"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <base href="/">
    <title><c:choose><c:when test="${appMode == 'purge'}">X-Purge 개인정보 파기</c:when><c:when test="${appMode == 'gen'}">X-Gen 테스트데이터 생성</c:when><c:otherwise>X-One</c:otherwise></c:choose></title>

    <!-- Custom fonts for this template -->
    <link href="/resources/vendor/fontawesome-free-6.1.1-web/css/all.min.css" rel="stylesheet" type="text/css">

    <!-- Custom styles for this template -->
    <link href="/resources/css/sb-admin-2.min.css" rel="stylesheet">
    <!-- DLM styles -->
    <link href="/resources/css/datablocks-1.css" rel="stylesheet">
    <!-- Numbered textarea styles -->
    <link href="/resources/css/jquery.numberedtextarea.css" rel="stylesheet" type="text/css">
    <!-- Flatpickr 스타일 -->
    <link rel="stylesheet" href="/resources/css/flatpickr.min.css">
    <link rel="stylesheet" href="/resources/css/material_blue.css">
    <link rel="stylesheet" href="/resources/css/flatpickr/plugins/monthSelect/style.css">

    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">

</head>

<body id="page-top">

<!-- Page Wrapper -->
<div id="wrapper">

    <!-- Sidebar -->
    <%--<%@include file="includes/sidebar_not uesed.jsp" %>--%>
    <!-- End of Sidebar -->

    <!-- Content Wrapper -->
    <div id="content-wrapper" class="d-flex flex-column">
        <!-- Navigation Bar -->
        <div id="menu" style="width: 100%; height: 48px;">
            <%@include file="includes/menubar.jsp" %>
        </div>
        <!-- End of Navigation Bar -->

        <!-- Main Content -->
        <div id="content_home" class="m-0 bordered-nopadding border" style="width: 100%; height: calc(100vh - 68px);">
        </div>
        <!-- End of Main Content -->

        <!-- Footer -->
        <div id="footer" class="m-0" style="  width: 100%;  height: 20px; ">
            <%@include file="includes/footer.jsp" %>
        </div>
        <!-- End of Footer -->

    </div>
    <!-- End of Content Wrapper -->

</div>
<!-- End of Page Wrapper -->

<!-- Scroll to Top Button-->
<a class="scroll-to-top rounded" href="#page-top">
    <i class="fas fa-angle-up"></i>
</a>

<!-- Success Modal Style -->
<style>
    #GlobalSuccessMsgModal .modal-content {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    #GlobalSuccessMsgModal .success-modal-header {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    #GlobalSuccessMsgModal .success-modal-header h4 {
        margin: 0;
        color: #fff;
        font-size: 1.1rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    #GlobalSuccessMsgModal .success-modal-header h4 i {
        font-size: 1.2rem;
    }
    #GlobalSuccessMsgModal .success-modal-header .close {
        background: rgba(255,255,255,0.15);
        border: none;
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        font-size: 1.3rem;
        line-height: 1;
        opacity: 1;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
    }
    #GlobalSuccessMsgModal .success-modal-header .close:hover {
        background: rgba(255,255,255,0.25);
    }
    #GlobalSuccessMsgModal .success-modal-body {
        padding: 28px 24px;
        text-align: center;
    }
    #GlobalSuccessMsgModal .success-icon-wrapper {
        width: 70px;
        height: 70px;
        background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
        animation: successPulse 0.5s ease-out;
    }
    @keyframes successPulse {
        0% { transform: scale(0); opacity: 0; }
        50% { transform: scale(1.1); }
        100% { transform: scale(1); opacity: 1; }
    }
    #GlobalSuccessMsgModal .success-icon-wrapper i {
        font-size: 2rem;
        color: #059669;
    }
    #GlobalSuccessMsgModal .success-message {
        font-size: 1rem;
        color: #1e293b;
        font-weight: 600;
        margin-bottom: 4px;
    }
    #GlobalSuccessMsgModal .success-submessage {
        font-size: 0.85rem;
        color: #64748b;
    }
    #GlobalSuccessMsgModal .success-modal-footer {
        padding: 16px 24px 24px;
        display: flex;
        justify-content: center;
        border-top: none;
    }
    #GlobalSuccessMsgModal .btn-success-close {
        padding: 10px 32px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        color: #fff;
        border: none;
        transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
    }
    #GlobalSuccessMsgModal .btn-success-close:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
    }

    /* Error Modal Style */
    #ErrorMsgModal .modal-content {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    #ErrorMsgModal .error-modal-header {
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    #ErrorMsgModal .error-modal-header h4 {
        margin: 0;
        color: #fff;
        font-size: 1.1rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    #ErrorMsgModal .error-modal-header h4 i {
        font-size: 1.2rem;
    }
    #ErrorMsgModal .error-modal-header .close {
        background: rgba(255,255,255,0.15);
        border: none;
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        font-size: 1.3rem;
        line-height: 1;
        opacity: 1;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
    }
    #ErrorMsgModal .error-modal-header .close:hover {
        background: rgba(255,255,255,0.25);
    }
    #ErrorMsgModal .error-modal-body {
        padding: 28px 24px;
        text-align: center;
    }
    #ErrorMsgModal .error-icon-wrapper {
        width: 70px;
        height: 70px;
        background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
        animation: errorShake 0.5s ease-out;
    }
    @keyframes errorShake {
        0%, 100% { transform: translateX(0); }
        20%, 60% { transform: translateX(-5px); }
        40%, 80% { transform: translateX(5px); }
    }
    #ErrorMsgModal .error-icon-wrapper i {
        font-size: 2rem;
        color: #dc2626;
    }
    #ErrorMsgModal .error-message {
        font-size: 1rem;
        color: #1e293b;
        font-weight: 600;
        margin-bottom: 4px;
    }
    #ErrorMsgModal .error-submessage {
        font-size: 0.85rem;
        color: #64748b;
    }
    #ErrorMsgModal .error-modal-footer {
        padding: 16px 24px 24px;
        display: flex;
        justify-content: center;
        border-top: none;
    }
    #ErrorMsgModal .btn-error-close {
        padding: 10px 32px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        color: #fff;
        border: none;
        transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
    }
    #ErrorMsgModal .btn-error-close:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
    }

    /* Confirm Modal Style */
    #GlobalConfirmModal .modal-content {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    #GlobalConfirmModal .confirm-modal-header {
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    #GlobalConfirmModal .confirm-modal-header h4 {
        margin: 0;
        color: #fff;
        font-size: 1.1rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    #GlobalConfirmModal .confirm-modal-header h4 i {
        font-size: 1.2rem;
    }
    #GlobalConfirmModal .confirm-modal-header .close {
        background: rgba(255,255,255,0.15);
        border: none;
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        font-size: 1.3rem;
        line-height: 1;
        opacity: 1;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
    }
    #GlobalConfirmModal .confirm-modal-header .close:hover {
        background: rgba(255,255,255,0.25);
    }
    #GlobalConfirmModal .confirm-modal-body {
        padding: 32px 24px;
        text-align: center;
    }
    #GlobalConfirmModal .confirm-icon-wrapper {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);
    }
    #GlobalConfirmModal .confirm-icon-wrapper i {
        font-size: 1.8rem;
        color: #d97706;
    }
    #GlobalConfirmModal .confirm-message {
        font-size: 1rem;
        font-weight: 500;
        color: #1e293b;
        margin: 0 0 8px 0;
    }
    #GlobalConfirmModal .confirm-modal-footer {
        padding: 16px 24px 24px;
        display: flex;
        justify-content: center;
        gap: 12px;
        border-top: none;
    }
    #GlobalConfirmModal .btn-confirm-cancel {
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: #e2e8f0;
        color: #475569;
        border: none;
        transition: all 0.2s;
    }
    #GlobalConfirmModal .btn-confirm-cancel:hover {
        background: #cbd5e1;
    }
    #GlobalConfirmModal .btn-confirm-ok {
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        color: #fff;
        border: none;
        transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
    }
    #GlobalConfirmModal .btn-confirm-ok:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(245, 158, 11, 0.4);
    }
</style>

<!-- Success Modal -->
<div class="modal fade" id="GlobalSuccessMsgModal" tabindex="-1" role="dialog" style="z-index:1050;"
     aria-labelledby="GlobalSuccessMsgModalLabel">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="success-modal-header">
                <h4><i class="fas fa-check-circle"></i> <spring:message code="msg.processresult" text="Process Results"/></h4>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="success-modal-body">
                <div class="success-icon-wrapper">
                    <i class="fas fa-check"></i>
                </div>
                <p class="success-message" id="GlobalSuccessMsgModalBody"><spring:message code="msg.processcompleted" text="Process completed"/></p>
                <p class="success-submessage"><spring:message code="msg.successdesc" text="Your request has been processed successfully."/></p>
            </div>
            <div class="success-modal-footer">
                <button type="button" class="btn btn-success-close" data-dismiss="modal">
                    <i class="fas fa-check"></i> OK
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Error Modal -->
<div class="modal fade" id="ErrorMsgModal" tabindex="-1" role="dialog" style="z-index:1050;"
     aria-labelledby="ErrorMsgModalLabel">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="error-modal-header">
                <h4><i class="fas fa-exclamation-circle"></i> <spring:message code="msg.processresult" text="Process Results"/></h4>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="error-modal-body">
                <div class="error-icon-wrapper">
                    <i class="fas fa-times"></i>
                </div>
                <p class="error-message" id="ErrorMsgModalBody"><spring:message code="msg.processfailed" text="Process failed"/></p>
                <p class="error-submessage"><spring:message code="msg.errordesc" text="An error occurred while processing your request."/></p>
            </div>
            <div class="error-modal-footer">
                <button type="button" class="btn btn-error-close" data-dismiss="modal">
                    <i class="fas fa-times"></i> Close
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Confirm Modal -->
<div class="modal fade" id="GlobalConfirmModal" tabindex="-1" role="dialog" style="z-index:1055;"
     aria-labelledby="GlobalConfirmModalLabel" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" style="max-width:450px;">
        <div class="modal-content">
            <div class="confirm-modal-header">
                <h4><i class="fas fa-question-circle"></i> 확인</h4>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="confirm-modal-body">
                <div class="confirm-icon-wrapper">
                    <i class="fas fa-exclamation"></i>
                </div>
                <p class="confirm-message" id="GlobalConfirmModalBody">삭제하시겠습니까?</p>
            </div>
            <div class="confirm-modal-footer">
                <button type="button" class="btn btn-confirm-cancel" data-dismiss="modal">
                    취소
                </button>
                <button type="button" class="btn btn-confirm-ok" id="GlobalConfirmModalOk">
                    확인
                </button>
            </div>
        </div>
    </div>
</div>

<!-- The Modal -->
<div class="modal"  id="jobdetailmodal" <%--aria-hidden="true"--%> style="display: none; z-index: 1050; data-backdrop:static">
    <div class="modal-dialog modal-xl ">
        <div class="modal-content m-0 p-0">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard" >
                <h4 class="modal-title modal-title-unified"><i class="fas fa-tasks mr-2"></i><span id="jobdetailheader">Job Details</span></h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom m-0 p-0" id="jobdetailbody" >
                jobdetail Modal body..
            </div>

            <!-- Modal footer -->
            <!--         <div class="modal-footer">
                      <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
                    </div> -->

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- Logout Modal-->
<style>
    #logoutModal .modal-content {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    #logoutModal .logout-modal-header {
        background: linear-gradient(135deg, #64748b 0%, #475569 100%);
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    #logoutModal .logout-modal-header h4 {
        margin: 0;
        color: #fff;
        font-size: 1.1rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    #logoutModal .logout-modal-header h4 i {
        font-size: 1.2rem;
        opacity: 0.9;
    }
    #logoutModal .logout-modal-header .close {
        background: rgba(255,255,255,0.15);
        border: none;
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        font-size: 1.3rem;
        line-height: 1;
        opacity: 1;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
    }
    #logoutModal .logout-modal-header .close:hover {
        background: rgba(255,255,255,0.25);
    }
    #logoutModal .logout-modal-body {
        padding: 28px 24px;
        text-align: center;
    }
    #logoutModal .logout-icon-wrapper {
        width: 64px;
        height: 64px;
        background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
    }
    #logoutModal .logout-icon-wrapper i {
        font-size: 1.8rem;
        color: #64748b;
    }
    #logoutModal .logout-message {
        font-size: 0.95rem;
        color: #475569;
        line-height: 1.6;
    }
    #logoutModal .logout-modal-footer {
        padding: 16px 24px 24px;
        display: flex;
        justify-content: center;
        gap: 12px;
        border-top: none;
    }
    #logoutModal .btn-logout-cancel {
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: #f1f5f9;
        color: #64748b;
        border: 1px solid #e2e8f0;
        transition: all 0.2s;
    }
    #logoutModal .btn-logout-cancel:hover {
        background: #e2e8f0;
        color: #475569;
    }
    #logoutModal .btn-logout-confirm {
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: linear-gradient(135deg, #64748b 0%, #475569 100%);
        color: #fff;
        border: none;
        transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);
    }
    #logoutModal .btn-logout-confirm:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(100, 116, 139, 0.4);
    }
    #logoutModal .btn-logout-confirm i {
        margin-right: 6px;
    }
</style>
<div class="modal fade" id="logoutModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" style="z-index: 1061;">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="logout-modal-header">
                <h4><i class="fas fa-sign-out-alt"></i> Logout</h4>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <form style="margin: 0; padding: 0;" action="/customLogout" method='post'>
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="logout-modal-body">
                    <div class="logout-icon-wrapper">
                        <i class="fas fa-door-open"></i>
                    </div>
                    <p class="logout-message">
                        <spring:message code="msg.logout" text="Select \"Logout\" below if you are ready to end your current session"/>.
                    </p>
                </div>
                <div class="logout-modal-footer">
                    <button class="btn btn-logout-cancel" type="button" data-dismiss="modal">Cancel</button>
                    <button class="btn btn-logout-confirm" type="submit"><i class="fas fa-sign-out-alt"></i> Logout</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="errormodal" role="dialog" style="z-index: 1051;">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">Error Message</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm" id="errormodalbody" >

            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="messagemodal" role="dialog" style="z-index: 1051;">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified">Message</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm" id="messagemodalbody" >
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="magnifymodal" role="dialog" style="z-index: 1070;">
    <div class="modal-dialog modal-lg" style="max-width: 780px;">
        <div class="modal-content" style="border: none; border-radius: 10px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.25);">

            <!-- Modal Header -->
            <div class="modal-header" style="background: linear-gradient(135deg, #dc2626, #b91c1c); padding: 12px 20px; border: none;">
                <h4 class="modal-title" style="font-size: 0.85rem; font-weight: 700; color: #fff; display: flex; align-items: center; gap: 8px;">
                    <i class="fas fa-exclamation-triangle"></i> Error Details
                </h4>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body" id="magnifymodalbody" style="background: #fef2f2; padding: 20px;">
                <div id="magnifymodalmsg"></div>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer" style="background: #fff; border-top: 1px solid #fecaca; padding: 10px 20px;">
                <button type="button" class="btn btn-sm" data-dismiss="modal"
                        style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; padding: 5px 16px; font-size: 0.75rem; font-weight: 600;">
                    Close
                </button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="magnifyxlsqlstrmodal" role="dialog" >
    <div class="modal-dialog modal-xl"  >
        <div class="modal-content" style="width: 1400px;">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><i class='fas fa-search-plus'></i> Details</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm p-2" id="magnifyxlsqlstrmodalbody" style="width: 1400px;">
        	<textarea autofocus spellcheck="false" rows="33" class="form-control form-control-sm" id='magnifysqlstr' style="width: 1380px;font-size: 13px;background-color: white;"  >
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	</textarea>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="magnifyxlwherestrmodal" role="dialog" >
    <div class="modal-dialog modal-xl"  >
        <div class="modal-content" style="width: 1400px;">

            <!-- Modal Header -->
            <div class="modal-header modal-wizard">
                <h4 class="modal-title modal-title-unified"><i class='fas fa-search-plus'></i> Details</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm p-2" id="magnifyxlwherestrmodalbody" style="width: 1400px;">
        	<textarea autofocus spellcheck="false" rows="33" class="form-control form-control-sm" id='magnifywherestr' style="width: 1380px;font-size: 13px;background-color: white;" readonly >
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	</textarea>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->

<!-- The Modal -->
<div class="modal fade" id="magnifyxl2wherestrmodal" role="dialog"  >
    <div class="modal-dialog modal-xl"  >
        <div class="modal-content" style="width: 1400px;">

            <!-- Modal Header -->
            <div class="modal-header" >
                <h4 class="modal-title modal-title-unified"><i class='fas fa-search-plus'></i> Details</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm p-2" id="magnifyxl2wherestrmodalbody" style="width: 1400px;">
        	<textarea autofocus spellcheck="false"  rows="35" class="form-control form-control-sm" id='magnify2wherestr' style="width: 1380px;font-size: 13px;" >
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	</textarea>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
                <button data-oper='applywherestr' class="btn btn-primary btn-sm p-0 pb-2 button ">Apply</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal -->
<div class="modal fade" id="magnifyxl2sqlstrmodal" role="dialog"  >
    <div class="modal-dialog modal-xl"  >
        <div class="modal-content" style="width: 1400px;">

            <!-- Modal Header -->
            <div class="modal-header" >
                <h4 class="modal-title modal-title-unified"><i class='fas fa-search-plus'></i> Details</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>

            <!-- Modal body -->
            <div class="modal-body modal-body-custom modal-sm p-2" id="magnifyxl2sqlstrmodalbody" style="width: 1400px;">
        	<textarea autofocus spellcheck="false"  rows="35" class="form-control form-control-sm" id='magnify2sqlstr' style="width: 1380px;font-size: 13px;" >
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	
        	</textarea>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm p-0 pb-2 button" data-dismiss="modal">Close</button>
                <button data-oper='applysqlstr' class="btn btn-primary btn-sm p-0 pb-2 button ">Apply</button>
            </div>

        </div>
    </div>
</div>
<!-- The Modal end-->
<!-- The Modal -->
<div class="modal fade" id="dialogmetadataupdate" role="dialog">
    <div class="modal-dialog modal-xl">
        <div class="modal-content" style="border-radius: 12px; overflow: hidden; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <!-- Modal Header -->
            <div class="modal-header" style="background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%); border-bottom: none; padding: 16px 20px;">
                <h4 class="modal-title modal-title-unified" style="color: #fff; font-size: 1.1rem;">
                    <i class="fas fa-edit" style="margin-right: 10px;"></i>
                    <spring:message code="etc.metadatamodify" text="Meta data modify"/>
                </h4>
                <button type="button" class="close" data-dismiss="modal" style="color: #fff; opacity: 0.8; text-shadow: none;">&times;</button>
            </div>
            <!-- Modal body -->
            <div class="modal-body modal-body-custom" id="dialogmetadataupdatebody" style="padding: 0; background: #f8fafc;">
            </div>
        </div>
    </div>
</div>
<!-- The Modal end-->

<span id="downloadIcon" style="display:none;">
    <!-- 아이콘 또는 이미지 등 추가 -->
    <i class="fa fa-spinner fa-spin"></i>
</span>


<script>
    function ingHide() {console.log("ingHide()")
        //var downloadIcon = document.getElementById('downloadIcon');
        // 아이콘 숨김 처리
        downloadIcon.style.display = 'none';
    }
    function ingShow() { console.log("ingShow()")
        //var downloadIcon = document.getElementById('downloadIcon');
        // 아이콘 숨김 처리
        downloadIcon.style.display = 'inline';
    }
</script>


<!-- Bootstrap core JavaScript-->
<%-- <script src="/resources/vendor/jquery/jquery.min.js"></script>
 <script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

 <!-- Core plugin JavaScript-->
 <script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

 <!-- Custom scripts for all pages-->
 <script src="/resources/js/sb-admin-2.min.js"></script>--%>

<!-- Numbered textarea-->
<script src="/resources/js/jquery.numberedtextarea.js"></script>

<sec:authorize access="hasRole('ROLE_ADMIN')">
    <script>
        var is_admin = true;
    </script>
</sec:authorize>
<sec:authorize access="!hasRole('ROLE_ADMIN')">
    <script>
        var is_admin = false;
    </script>
</sec:authorize>

<script type="text/javascript">

    // 세션 만료 처리 — 서버가 AJAX에 대해 401 + X-Session-Expired 헤더를 반환
    (function() {
        var _redirecting = false;
        function gotoLogin() {
            if (_redirecting) return;
            _redirecting = true;
            try { showToast('세션이 만료되었습니다. 로그인 페이지로 이동합니다.', true); } catch(e){}
            setTimeout(function(){
                window.location.href = '/customLogin?expired=1';
            }, 500);
        }

        // 모든 jQuery AJAX 요청에 AJAX 식별 헤더 부착 (하위 beforeSend에 덮이지 않도록 ajaxSend 사용)
        $(document).ajaxSend(function(evt, xhr) {
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            xhr.setRequestHeader('X-Ajax-Request', '1');
        });

        $(document).ajaxError(function(event, xhr) {
            if (xhr.status === 401 || xhr.getResponseHeader('X-Session-Expired') === 'true') {
                gotoLogin();
            }
        });

        // fetch() 포괄 래퍼 — SPA 스타일 호출까지 커버
        if (window.fetch) {
            var _origFetch = window.fetch;
            window.fetch = function(input, init) {
                init = init || {};
                var headers = new Headers(init.headers || {});
                if (!headers.has('X-Ajax-Request')) headers.set('X-Ajax-Request', '1');
                if (!headers.has('X-Requested-With')) headers.set('X-Requested-With', 'XMLHttpRequest');
                init.headers = headers;
                return _origFetch.call(this, input, init).then(function(res) {
                    if (res.status === 401 || res.headers.get('X-Session-Expired') === 'true') {
                        gotoLogin();
                    }
                    return res;
                });
            };
        }
    })();

    $(document).ready(function() {
        $('#GlobalSuccessMsgModal').on('shown.bs.modal', function () {
            $(document).on('keyup.modal.close', function(e) {
                if (e.which === 13) { // 13은 Enter 키의 keyCode입니다.
                    $('#GlobalSuccessMsgModal').modal('hide');
                }
            });
        }).on('hidden.bs.modal', function () {
            $(document).off('keyup.modal.close');
        });
    });

    var db_steptable_index ;
    var owner_steptable_index ;
    var table_name_steptable_index ;

    // 공통 토스트 알림
    function showToast(msg, isError) {
        var $t = $('#globalToast');
        if ($t.length === 0) {
            $('body').append(
                '<div id="globalToast" style="position:fixed;bottom:24px;right:24px;z-index:99999;' +
                'padding:14px 28px;border-radius:10px;font-size:0.9rem;font-weight:500;color:#fff;' +
                'box-shadow:0 4px 16px rgba(0,0,0,0.15);transform:translateY(100px);opacity:0;' +
                'transition:all 0.3s;pointer-events:none;display:flex;align-items:center;gap:8px;"></div>'
            );
            $t = $('#globalToast');
        }
        var icon = isError ? 'times-circle' : 'check-circle';
        $t.html('<i class="fas fa-' + icon + '"></i> ' + msg);
        $t.css({ background: isError ? '#dc2626' : '#059669', transform: 'translateY(0)', opacity: 1 });
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
            $t.css({ transform: 'translateY(100px)', opacity: 0 });
        }, 2500));
    }

    function checkResultModal(result) {
        if (result === '') {
            return;
        }
        if (result == 'success') {
            showToast("<spring:message code="msg.processcompleted" text="처리가 완료되었습니다."/>", false);
        } else {
            showToast("<spring:message code="msg.processfailed" text="처리에 실패했습니다."/>", true);
        }
    }

    var _confirmCallback = null;
    var _confirmCancelCallback = null;
    var _confirmOkClicked = false;
    function showConfirm(message, callback, cancelCallback) {
        $('#GlobalConfirmModalBody').text(message);
        _confirmCallback = callback;
        _confirmCancelCallback = cancelCallback || null;
        _confirmOkClicked = false;
        $("#GlobalConfirmModal").modal("show");
    }
    $(document).ready(function() {
        $('#GlobalConfirmModalOk').on('click', function() {
            _confirmOkClicked = true;
            $("#GlobalConfirmModal").modal("hide");
            if (typeof _confirmCallback === 'function') {
                _confirmCallback();
            }
            _confirmCallback = null;
            _confirmCancelCallback = null;
        });
        $('#GlobalConfirmModal').on('hidden.bs.modal', function() {
            if (!_confirmOkClicked && typeof _confirmCancelCallback === 'function') {
                _confirmCancelCallback();
            }
            _confirmOkClicked = false;
            _confirmCallback = null;
            _confirmCancelCallback = null;
        });
    });

    function characterCheck(obj) {
        //var RegExp = /[ \{\}\[\]\/?.,;:|\)*~`!^\-_+┼<>@\#$%&\'\"\\\(\=]/gi;//정규식 구문
        var RegExp = /[ \{\}\/?.,;:|\)*~`!^\-+┼<>@\#$%&\'\"\\\(\=]/gi;//정규식 구문
        //var obj = document.getElementsByName("search1")[0]
        if (RegExp.test(obj.value)) {;
            $("#messagemodalbody").html("특수문자는 입력하실 수 없습니다.");$("#messagemodal").modal("show");
            obj.value = obj.value.substring(0, obj.value.length - 1);//특수문자를 지우는 구문
            obj.focus();
        }

        var sqlArray = new Array( //sql 예약어 "OR",
            "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "DROP", "EXEC",
            "UNION", "FETCH", "DECLARE", "TRUNCATE",
            "JOIN", "AND", "SUBSTR", "FROM", "WHERE", "OPENROWSET", "USER_TABLES", "USER_TAB_COLUMNS", "ROWNUM", "ROW_NUM"
        );

        for (var i = 0; i	< sqlArray.length; i++) {
            if(obj.value.indexOf(sqlArray[i]) != -1) {
                $("#messagemodalbody").html("\"" + sqlArray[i] + "\"와(과) 같은 예약어로 검색할 수 없습니다.");$("#messagemodal").modal("show");
                obj.value = obj.value.replace(sqlArray[i], "");
                obj.focus();
            }else if(obj.value.indexOf(sqlArray[i].toLowerCase()) != -1) {
                $("#messagemodalbody").html("\"" + sqlArray[i].toLowerCase() + "\"와(과) 같은 예약어로 검색할 수 없습니다.");$("#messagemodal").modal("show");
                obj.value = obj.value.replace(sqlArray[i].toLowerCase(), "");
                obj.focus();
            }

        }

        /*           var sqlArray = new Array( //sql 예약어 "OR",
                            "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "DROP", "EXEC",
                            "UNION", "FETCH", "DECLARE", "TRUNCATE" );
                  var regex;

                  for (var i = 0; i	< sqlArray.length; i++) {
                      regex = new RegExp(sqlArray[i], "gi");
                      if(regex.test(obj)) {
                          alert("\"" + sqlArray[i] + "\"와(과) 같은 특정문자로 검색할 수 없습니다.");
                            obj = obj.replace(regex, "");
                      }
                  }
                   */
    }

    function isEmpty(value) {
        if (value === null || value === undefined || (typeof value === "string" && value.trim() === "") || (typeof value === "object" && Object.keys(value).length === 0)) {
            return true;
        } else {
            return false;
        }
    }


    function isDate(txtDate) {
        var currVal = txtDate;
        if (currVal == '')
            return false;

        var rxDatePattern = /^(\d{4})(\d{1,2})(\d{1,2})$/; //Declare Regex
        var dtArray = currVal.match(rxDatePattern); // is format OK?

        if (dtArray == null)
            return false;

        //Checks for yyyymmdd format.
        dtYear = dtArray[1];
        dtMonth = dtArray[2];
        dtDay = dtArray[3];

        //alert(dtArray);
        //alert(dtYear);
        //alert(dtMonth);
        //alert(dtDay);

        if (dtMonth < 1 || dtMonth > 12)
            return false;
        else if (dtDay < 1 || dtDay > 31)
            return false;
        else if ((dtMonth == 4 || dtMonth == 6 || dtMonth == 9 || dtMonth == 11) && dtDay == 31)
            return false;
        else if (dtMonth == 2) {
            var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
            if (dtDay > 29 || (dtDay == 29 && !isleap))
                return false;
        }
        return true;
    }

    function getToday(){
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var date = now.getDate();
        month = month >=10 ? month : "0" + month;
        date  = date  >= 10 ? date : "0" + date;
        return today = ""+year + month + date;
    }
    // 현재 날짜를 가져오는 함수
    function getCurrentDate() {
        var today = new Date();
        var year = today.getFullYear();
        var month = ('0' + (today.getMonth() + 1)).slice(-2); // 월은 0부터 시작하므로 +1
        var day = ('0' + today.getDate()).slice(-2);
        return year + '/' + month + '/' + day;
    }
    // function objectifyForm(formArray) {//serializeArray data function
    //       var returnArray = {};
    //       for (var i = 0; i < formArray.length; i++) {
    //           returnArray[formArray[i]['name']] = formArray[i]['value'];
    //       }
    //       return returnArray;
    // }

    function serializeObject (formArray) {
        var obj = null;
        try {
            obj = {};
            jQuery.each(formArray, function() {
                obj[this.name] = this.value;
            });
        } catch (e) {
            dlmAlert(e.message);
        } finally {
        }

        return obj;
    };

    $('textarea').numberedtextarea();
</script>


</body>

<!-- DLM Alert Modal (replaces native alert()) -->
<style>
    #DlmAlertModal .modal-content {
        border: none;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
    }
    #DlmAlertModal .dlm-alert-header {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        padding: 20px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    #DlmAlertModal .dlm-alert-header h4 {
        margin: 0;
        color: #fff;
        font-size: 1.1rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    #DlmAlertModal .dlm-alert-header h4 i {
        font-size: 1.2rem;
    }
    #DlmAlertModal .dlm-alert-header .close {
        background: rgba(255,255,255,0.15);
        border: none;
        color: #fff;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        font-size: 1.3rem;
        line-height: 1;
        opacity: 1;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
    }
    #DlmAlertModal .dlm-alert-header .close:hover {
        background: rgba(255,255,255,0.25);
    }
    #DlmAlertModal .dlm-alert-body {
        padding: 28px 24px;
        text-align: center;
    }
    #DlmAlertModal .dlm-alert-icon-wrapper {
        width: 70px;
        height: 70px;
        background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
        animation: dlmAlertPop 0.4s ease-out;
    }
    @keyframes dlmAlertPop {
        0% { transform: scale(0.5); opacity: 0; }
        70% { transform: scale(1.05); }
        100% { transform: scale(1); opacity: 1; }
    }
    #DlmAlertModal .dlm-alert-icon-wrapper i {
        font-size: 2rem;
        color: #2563eb;
    }
    #DlmAlertModal .dlm-alert-message {
        font-size: 0.95rem;
        color: #1e293b;
        font-weight: 500;
        margin-bottom: 0;
        line-height: 1.6;
        word-break: break-word;
        white-space: pre-line;
    }
    #DlmAlertModal .dlm-alert-footer {
        padding: 16px 24px 24px;
        display: flex;
        justify-content: center;
        border-top: none;
    }
    #DlmAlertModal .btn-dlm-alert-ok {
        padding: 10px 36px;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        color: #fff;
        border: none;
        transition: all 0.2s;
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
    }
    #DlmAlertModal .btn-dlm-alert-ok:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
    }
    #DlmAlertModal .btn-dlm-alert-ok:focus {
        outline: none;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3);
    }
</style>
<div class="modal fade" id="DlmAlertModal" tabindex="-1" role="dialog" style="z-index:1070;"
     aria-labelledby="DlmAlertModalLabel">
    <div class="modal-dialog modal-dialog-centered" style="max-width:440px;">
        <div class="modal-content">
            <div class="dlm-alert-header">
                <h4><i class="fas fa-info-circle"></i> <span id="DlmAlertModalTitle">Notice</span></h4>
                <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="dlm-alert-body">
                <div class="dlm-alert-icon-wrapper" id="DlmAlertIconWrapper">
                    <i class="fas fa-info" id="DlmAlertIcon"></i>
                </div>
                <p class="dlm-alert-message" id="DlmAlertModalBody"></p>
            </div>
            <div class="dlm-alert-footer">
                <button type="button" class="btn btn-dlm-alert-ok" data-dismiss="modal">OK</button>
            </div>
        </div>
    </div>
</div>
<script>
/**
 * dlmAlert - Styled modal replacement for native alert()
 * @param {string} message - Message to display
 * @param {function} [callback] - Optional callback after modal is dismissed
 */
function dlmAlert(message, callback) {
    var $modal = $('#DlmAlertModal');
    // Set message (supports \n for newlines)
    $('#DlmAlertModalBody').text(message);
    // Reset to default info style
    $('#DlmAlertModalTitle').text('Notice');
    $('#DlmAlertIconWrapper').css('background', 'linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%)');
    $('#DlmAlertIcon').attr('class', 'fas fa-info').css('color', '#2563eb');
    $('.dlm-alert-header').css('background', 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)');
    // Handle callback on modal hidden
    if (callback) {
        $modal.one('hidden.bs.modal', callback);
    }
    $modal.modal('show');
    // Auto-focus OK button for keyboard accessibility
    $modal.one('shown.bs.modal', function() {
        $modal.find('.btn-dlm-alert-ok').focus();
    });
}
</script>

<!-- Flatpickr 스크립트 -->
<script src="/resources/js/flatpickr.min.js"></script>
<script src="/resources/js/ko.js"></script>
<script src="/resources/js/flatpickr/plugins/monthSelect/index.js"></script>

</html>
