package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiMemberVO;
import datablocks.dlm.service.PiiMemberService;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.security.Principal;

@Controller
@RequestMapping("/piimember/*")
@AllArgsConstructor
public class PiiMemberController {
    private static final Logger logger = LoggerFactory.getLogger(PiiMemberController.class);
    private PiiMemberService service;

    @Autowired
    private PasswordEncoder PasswordEncoder;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(Model model) {
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model, HttpServletRequest request, Principal principal) {

        LogUtil.log("INFO", "/piimember list(Criteria cri, Model model): " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        int total = 0;
        if (request.isUserInRole("ROLE_ADMIN")) {
            model.addAttribute("list", service.getList(cri));
            total = service.getTotal(cri);
        } else {
            cri.setSearch1(null);
            cri.setSearch2(null);
            cri.setSearch3(principal.getName());
            model.addAttribute("list", service.getList(cri));
            total = service.getTotal(cri);
        }
        //LogUtil.log("INFO", "/piimember total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piimember pageMaker: " + pageMaker);
    }

    @GetMapping("/diologsearchmember")
    @PreAuthorize("isAuthenticated()")
    public void diologsearchmember(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piimember list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        logger.warn("warn "+service.getList(cri).toString());
        int total = service.getTotal(cri);
        //LogUtil.log("INFO", "/piimember total: " + total);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
        //LogUtil.log("INFO", "/piimember pageMaker: " + pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(PiiMemberVO piimember, RedirectAttributes rttr) throws Exception {

        LogUtil.log("INFO", "register: " + piimember);
        try {
            piimember.setUserpw(PasswordEncoder.encode(piimember.getUserpw()));
        } catch (Exception ex) {
            logger.warn("warn "+"/piimember @PostMapping  /register Exception= " + ex.toString());
            throw ex;
        }
        service.register(piimember);

        rttr.addFlashAttribute("result", "success");

        return "redirect:/piimember/list";
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("userid") String userid, Criteria cri, Model model) {

        LogUtil.log("INFO", "/piimember @GetMapping  /get or modify = " + userid);
        PiiMemberVO membervo = service.get(userid);
        //membervo.setUserpw(""); //20210713 to check the new pwd is not same as the old pwd  by cha.
        model.addAttribute("piimember", membervo);
        model.addAttribute("cri", cri);
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String authenticatedUserId = authentication.getName();

        model.addAttribute("authenticatedUserId", authenticatedUserId);

        //logger.info(cri.toString());
    }

    @GetMapping("/getJson")
    @ResponseBody
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PiiMemberVO> getJson(@RequestParam("userid") String userid) {
        LogUtil.log("INFO", "/piimember @GetMapping /getJson = " + userid);
        PiiMemberVO membervo = service.get(userid);
        if (membervo != null) {
            membervo.setUserpw(null); // Don't expose password
            return ResponseEntity.ok(membervo);
        }
        return ResponseEntity.notFound().build();
    }

    @ResponseBody
    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> modify(@RequestBody PiiMemberVO piimember, Model model, HttpServletRequest request) throws Exception {
        LogUtil.log("INFO", "@PostMapping modify:" + piimember);

        // 본인 계정 또는 ADMIN만 수정 가능
        String authenticatedUserId = SecurityContextHolder.getContext().getAuthentication().getName();
        if (!request.isUserInRole("ROLE_ADMIN") && !authenticatedUserId.equals(piimember.getUserid())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only modify your own account");
        }

        String rst = "success";
        if (StrUtil.checkString(piimember.getUserpw())){
            if (service.modifyWithoutPw(piimember)) {
                model.addAttribute("result", "success");
                rst = "successfully processed";
                return ResponseEntity.ok(rst);
            }
        } else {
            try {
                LogUtil.log("INFO", "password change requested for userId=" + piimember.getUserid());

                if (PasswordEncoder.matches(piimember.getUserpw(), service.get(piimember.getUserid()).getUserpw())) {
                    model.addAttribute("result", "fail");
                    rst = "The new password must be different from the existing password";
                    logger.info(rst);
                    return ResponseEntity.badRequest().body(rst);
                } else {
                    piimember.setUserpw(PasswordEncoder.encode(piimember.getUserpw()));
                    if (service.modify(piimember)) {
                        model.addAttribute("result", "success");
                        //LogUtil.log("INFO", "/piimember @PostMapping  /modify service.modify(piimember)");
                        rst = "successfully processed";
                        return ResponseEntity.ok(rst);
                    } else {
                        model.addAttribute("result", "fail");
                        rst = "failed";
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(rst);
                    }
                }
            } catch (Exception ex) {
                model.addAttribute("result", "fail");
                logger.warn("warn "+"/piimember @PostMapping  /modify Exception= "+ex.toString());
                rst = ex.getMessage();
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(rst);
            }
        }

        return ResponseEntity.ok(rst);
    }

    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiMemberVO piimember, Criteria cri, RedirectAttributes rttr) {

        LogUtil.log("INFO", "@PostMapping remove..." + piimember.getUserid());
        if (service.remove(piimember.getUserid())) {
            rttr.addFlashAttribute("result", "success");
        } else
            logger.warn("warn "+"/piimember @PostMapping  /remove == fail to remove - service.remove(piimember.getUserid()");
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piimember/list";
    }


}
