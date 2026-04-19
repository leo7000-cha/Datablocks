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

import java.util.List;

@Controller
@RequestMapping("/piistep")
@AllArgsConstructor
public class PiiStepController {
    private static final Logger logger = LoggerFactory.getLogger(PiiStepController.class);
    private PiiStepService service;
    private PiiDatabaseService databaseservice;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(@RequestParam("jobid") String jobid, @RequestParam("version") String version, Model model) {
        LogUtil.log("INFO", "@GetMapping register: " + jobid);
        model.addAttribute("jobid", jobid);
        model.addAttribute("version", version);
        model.addAttribute("phase", "CHECKIN");
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("mode", "new");
        model.addAttribute("piistep", new PiiStepVO());
        return "piistep/detailform";
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
                return new ResponseEntity<>("The STEPID is already registered.", HttpStatus.BAD_REQUEST);
            }

            service.register(piistep);
            return new ResponseEntity<>("Successfully registered", HttpStatus.OK);

        } catch (Exception e) {
            return new ResponseEntity<>("An error occurred during registration.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping({"/get", "/modify"})
    @PreAuthorize("isAuthenticated()")
    public String get(@RequestParam("jobid") String jobid, @RequestParam("version") String version, @RequestParam("stepid") String stepid, Criteria cri, Model model) {
        LogUtil.log("INFO", "@GetMapping  /get or modify = " + stepid + "  " + version);
        model.addAttribute("piistep", service.get(jobid, version, stepid));
        model.addAttribute("piidatabaselist", databaseservice.getList());
        model.addAttribute("cri", cri);
        model.addAttribute("mode", "edit");
        return "piistep/detailform";
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
    }

    @PostMapping("/modify")
    @PreAuthorize("isAuthenticated()")
    @ResponseBody
    public ResponseEntity<String> modify(PiiStepVO piistep) {
        LogUtil.log("INFO", "@PostMapping modify:" + piistep);
        try {
            if (service.modify(piistep)) {
                return new ResponseEntity<>("Successfully saved", HttpStatus.OK);
            }
            return new ResponseEntity<>("Failed to save step.", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return new ResponseEntity<>("An error occurred while saving.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
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
    @ResponseBody
    public ResponseEntity<String> remove(PiiStepVO piistep) {
        LogUtil.log("INFO", "@PostMapping remove..." + piistep.getStepid());
        try {
            if (service.remove(piistep)) {
                return new ResponseEntity<>("Successfully removed", HttpStatus.OK);
            }
            return new ResponseEntity<>("Failed to remove step.", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return new ResponseEntity<>("An error occurred while removing.", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}
