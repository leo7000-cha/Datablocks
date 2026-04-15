package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import jakarta.servlet.http.HttpSession;

@Controller
public class CommonController {
    private static final Logger logger = LoggerFactory.getLogger(CommonController.class);

    @GetMapping("/accessError")
    public void accessDenied(Authentication auth, Model model) {

        LogUtil.log("INFO", "access Denied : " + auth);

        model.addAttribute("msg", "Access Denied");
    }

    @GetMapping("/login")
    public void login(String error, String logout, Model model, HttpSession session) {

        LogUtil.log("INFO", "/login error: " + error);
        LogUtil.log("INFO", "/loginlogout: " + logout);

        if (error != null) {
            String errorMessage = getLoginErrorMessage(session);
            model.addAttribute("error", errorMessage);
        }

        if (logout != null) {
            model.addAttribute("logout", "로그아웃 되었습니다.");
        }
    }

    @GetMapping("/customLogin")
    public void loginInput(String error, String logout, Model model, HttpSession session,
                           jakarta.servlet.http.HttpServletRequest request) {

        LogUtil.log("INFO", "/customLogin error: " + error);
        LogUtil.log("INFO", "/customLogin logout: " + logout);
        LogUtil.log("INFO", "/customLogin sessionId=" + session.getId() + ", isNew=" + session.isNew() + ", remoteAddr=" + request.getRemoteAddr());

        if (error != null) {
            String errorMessage = getLoginErrorMessage(session);
            model.addAttribute("error", errorMessage);
        }

        if (logout != null) {
            model.addAttribute("logout", "로그아웃 되었습니다.");
        }
    }

    private String getLoginErrorMessage(HttpSession session) {
        Object exception = session.getAttribute("SPRING_SECURITY_LAST_EXCEPTION");

        if (exception instanceof BadCredentialsException) {
            return "아이디 또는 비밀번호가 올바르지 않습니다.";
        } else if (exception instanceof UsernameNotFoundException) {
            return "존재하지 않는 사용자입니다.";
        } else if (exception instanceof DisabledException) {
            return "비활성화된 계정입니다. 관리자에게 문의하세요.";
        } else if (exception instanceof LockedException) {
            return "계정이 잠겨있습니다. 관리자에게 문의하세요.";
        } else if (exception instanceof AccountExpiredException) {
            return "만료된 계정입니다. 관리자에게 문의하세요.";
        } else if (exception instanceof CredentialsExpiredException) {
            return "비밀번호가 만료되었습니다. 비밀번호를 변경해주세요.";
        } else if (exception instanceof AuthenticationException) {
            return "인증에 실패했습니다: " + ((AuthenticationException) exception).getMessage();
        }

        return "로그인에 실패했습니다. 다시 시도해주세요.";
    }

    @GetMapping("/customLogout")
    public void logoutGET() {

        LogUtil.log("INFO", "custom logout");
    }

    @PostMapping("/customLogout")
    public void logoutPost() {

        LogUtil.log("INFO", "post custom logout");
    }

    @PostMapping("/changePassword")
    public void changePassword() {

        LogUtil.log("INFO", "changePassword");
    }


}
