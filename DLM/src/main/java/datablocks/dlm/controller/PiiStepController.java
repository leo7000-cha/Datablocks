package datablocks.dlm.controller;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.domain.PiiStepVO;
import datablocks.dlm.domain.PiiStepseqVO;
import datablocks.dlm.service.PiiDatabaseService;
import datablocks.dlm.service.PiiStepService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/piistep")
@AllArgsConstructor
public class PiiStepController {
    private static final Logger logger = LoggerFactory.getLogger(PiiStepController.class);
    private PiiStepService service;
    private PiiDatabaseService databaseservice;
    //private String jobid;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register(@RequestParam("jobid") String jobid, @RequestParam("version") String version, Model model) {
        LogUtil.log("INFO", "@GetMapping register: " + jobid);
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("phase", "CHECKIN");
        model.addAttribute("piidatabaselist", databaseservice.getList());
        //logger.info(model.toString());
    }

    @GetMapping("/list")
    @PreAuthorize("isAuthenticated()")
    public void list(Criteria cri, Model model) {
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        LogUtil.log("INFO", "/piistep list(Criteria cri, Model model): " + cri);
        model.addAttribute("list", service.getList(cri));
        int total = service.getTotal(cri);
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);
    }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<String> register(PiiStepVO piistep, Criteria cri) {
        try {
            PiiStepVO existStep = service.get(piistep.getJobid(), piistep.getVersion(), piistep.getStepid());

            if (existStep != null) {
                // 이미 존재하는 경우, 에러 메시지와 함께 BAD_REQUEST 상태 반환
                return new ResponseEntity<>("The STEPID is already registered.", HttpStatus.BAD_REQUEST);
            }

            service.register(piistep);
            // 성공 시, 성공 메시지와 함께 OK 상태 반환
            return new ResponseEntity<>("Successfully registered", HttpStatus.OK);

        } catch (Exception e) {
            // 기타 에러 처리
            return new ResponseEntity<>("An error occurred during registration.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public void get(@RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping  /get or modify = " + stepid + "  " + version);
        model.addAttribute("piistep", service.get(jobid, version, stepid));
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @GetMapping({"/modifydialog"})
    @PreAuthorize("isAuthenticated()")
    public void getJobStepList(@RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping /modifydialog = " + jobid + "  " + version);
        model.addAttribute("list", service.getJobList(jobid, version));
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("stepid", stepid);

        model.addAttribute("cri", cri);
        //logger.info(cri.toString());
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    public String modify(PiiStepVO piistep, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping modify:" + piistep);
        //model.addAttribute("list", service.getJobList(piistep.getJobid()));
        if (service.modify(piistep)) {
            rttr.addFlashAttribute("result1", "success");
        }

        rttr.addAttribute("jobid", piistep.getJobid());
        rttr.addAttribute("version", piistep.getVersion());
        rttr.addAttribute("stepid", piistep.getStepid());

        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());

        return "redirect:/piistep/modifydialog";
    }

    @ResponseBody
    @RequestMapping(value = "/modify_seq")
    @PreAuthorize("isAuthenticated()")
    public String modify_seq(@RequestBody List<PiiStepseqVO> steplist, Criteria cri, Model model) {
        LogUtil.log("INFO", "@RequestMapping(value=modify_seq" + cri);
        boolean okflag = false;
        for (PiiStepseqVO piistepseq : steplist) {
            if (service.modify_seq(piistepseq))
                okflag = true;
            else {
                okflag = false;
                break;
            }
        }
        if (okflag)
            return "Successfully saved";
        else
            return "Process failed";
    }


    @PostMapping("/remove")
    @PreAuthorize("isAuthenticated()")
    public String remove(PiiStepVO piistep, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "@PostMapping remove..." + piistep.getStepid());
        if (service.remove(piistep)) {
            rttr.addFlashAttribute("step_modifydiolog_result", "Successfully removed");
        }

        rttr.addAttribute("jobid", piistep.getJobid());
        rttr.addAttribute("version", piistep.getVersion());
        rttr.addAttribute("stepid", piistep.getStepid());
        rttr.addAttribute("pagenum", cri.getPagenum());
        rttr.addAttribute("amount", cri.getAmount());
        rttr.addAttribute("search1", cri.getSearch1());
        rttr.addAttribute("search2", cri.getSearch2());
        return "redirect:/piistep/modifydialog";
    }

}
