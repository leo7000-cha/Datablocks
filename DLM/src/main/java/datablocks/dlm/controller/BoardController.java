package datablocks.dlm.controller;

import datablocks.dlm.domain.BoardAttachVO;
import datablocks.dlm.domain.BoardVO;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PageDTO;
import datablocks.dlm.service.BoardService;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Controller
@RequestMapping("/board/*")
@AllArgsConstructor
public class BoardController {
    private static final Logger logger = LoggerFactory.getLogger(BoardController.class);
    private BoardService service;

    @GetMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public void register() {

    }

    // @GetMapping("/list")
    // public void list(Model model) {
    //
    // LogUtil.log("INFO", "list");
    // model.addAttribute("list", service.getList());
    //
    // }

    // @GetMapping("/list")
    // public void list(Criteria cri, Model model) {
    //
    // LogUtil.log("INFO", "list: " + cri);
    // model.addAttribute("list", service.getList(cri));
    //
    // }

    @GetMapping("/list")
    public void list(Criteria cri, Model model) {

        LogUtil.log("INFO", "list: " + cri);
        try { cri.setOffset((cri.getPagenum()-1)*cri.getAmount()); } catch (Exception ex) {cri.setOffset(0); }// Maria DB 용
        model.addAttribute("list", service.getList(cri));
        // model.addAttribute("pageMaker", new PageDTO(cri, 123));

        int total = service.getTotal(cri);

        LogUtil.log("INFO", "total: " + total);

        model.addAttribute("pageMaker", new PageDTO(cri, total));

    }

    // @PostMapping("/register")
    // public String register(BoardVO board, RedirectAttributes rttr) {
    //
    // LogUtil.log("INFO", "register: " + board);
    //
    // service.register(board);
    //
    // rttr.addFlashAttribute("result", board.getBno());
    //
    // return "redirect:/board/list";
    // }

    @PostMapping("/register")
    @PreAuthorize("isAuthenticated()")
    public String register(BoardVO board, RedirectAttributes rttr) {

        LogUtil.log("INFO", "==========================");

        LogUtil.log("INFO", "register: " + board);

        if (board.getAttachList() != null) {

            board.getAttachList().forEach(attach -> logger.info(String.valueOf(attach)));

        }

        LogUtil.log("INFO", "==========================");

        service.register(board);

        rttr.addFlashAttribute("result", board.getBno());

        return "redirect:/board/list";
    }

    // @GetMapping({ "/get", "/modify" })
    // public void get(@RequestParam("bno") Long bno, Model model) {
    //
    // LogUtil.log("INFO", "/get or modify ");
    // model.addAttribute("board", service.get(bno));
    // }

    @GetMapping({"/get", "/modify"})
    public void get(@RequestParam("bno") Long bno, @ModelAttribute("cri") Criteria cri, Model model) {

        LogUtil.log("INFO", "/get or modify");
        model.addAttribute("board", service.get(bno));
    }

    // @PostMapping("/modify")
    // public String modify(BoardVO board, RedirectAttributes rttr) {
    // LogUtil.log("INFO", "modify:" + board);
    //
    // if (service.modify(board)) {
    // rttr.addFlashAttribute("result", "success");
    // }
    // return "redirect:/board/list";
    // }

//	@PostMapping("/modify")
//	public String modify(BoardVO board, @ModelAttribute("cri") Criteria cri, RedirectAttributes rttr) {
//		LogUtil.log("INFO", "modify:" + board);
//
//		if (service.modify(board)) {
//			rttr.addFlashAttribute("result", "success");
//		}
//
//		rttr.addAttribute("pagenum", cri.getPagenum());
//		rttr.addAttribute("amount", cri.getAmount());
//		rttr.addAttribute("type", cri.getType());
//		rttr.addAttribute("keyword", cri.getKeyword());
//
//		return "redirect:/board/list";
//	}

    @PreAuthorize("principal.username == #board.writer")
    @PostMapping("/modify")
    public String modify(BoardVO board, Criteria cri, RedirectAttributes rttr) {
        LogUtil.log("INFO", "modify:" + board);

        if (service.modify(board)) {
            rttr.addFlashAttribute("result", "success");
        }

        return "redirect:/board/list" + cri.getListLink();
    }


    // @PostMapping("/remove")
    // public String remove(@RequestParam("bno") Long bno, RedirectAttributes rttr)
    // {
    //
    // LogUtil.log("INFO", "remove..." + bno);
    // if (service.remove(bno)) {
    // rttr.addFlashAttribute("result", "success");
    // }
    // return "redirect:/board/list";
    // }

    // @PostMapping("/remove")
    // public String remove(@RequestParam("bno") Long bno, Criteria cri,
    // RedirectAttributes rttr) {
    //
    // LogUtil.log("INFO", "remove..." + bno);
    // if (service.remove(bno)) {
    // rttr.addFlashAttribute("result", "success");
    // }
    // rttr.addAttribute("pagenum", cri.getPagenum());
    // rttr.addAttribute("amount", cri.getAmount());
    // rttr.addAttribute("type", cri.getType());
    // rttr.addAttribute("keyword", cri.getKeyword());
    //
    // return "redirect:/board/list";
    // }

    @PreAuthorize("principal.username == #writer")
    @PostMapping("/remove")
    public String remove(@RequestParam("bno") Long bno, Criteria cri, RedirectAttributes rttr, String writer) {

        LogUtil.log("INFO", "remove..." + bno);

        List<BoardAttachVO> attachList = service.getAttachList(bno);

        if (service.remove(bno)) {

            // delete Attach Files
            deleteFiles(attachList);

            rttr.addFlashAttribute("result", "success");
        }
        return "redirect:/board/list" + cri.getListLink();
    }

    private void deleteFiles(List<BoardAttachVO> attachList) {

        if (attachList == null || attachList.size() == 0) {
            return;
        }

        LogUtil.log("INFO", "delete attach files...................");
        logger.info(String.valueOf(attachList));

        attachList.forEach(attach -> {
            try {
                Path file = Paths.get(
                        "C:\\upload\\" + attach.getUploadPath() + "\\" + attach.getUuid() + "_" + attach.getFileName());

                Files.deleteIfExists(file);

                if (Files.probeContentType(file).startsWith("image")) {

                    Path thumbNail = Paths.get("C:\\upload\\" + attach.getUploadPath() + "\\s_" + attach.getUuid() + "_"
                            + attach.getFileName());

                    Files.delete(thumbNail);
                }

            } catch (Exception e) {
                logger.error("delete file error" + e.getMessage());
            } // end catch
        });// end foreachd
    }

    @GetMapping(value = "/getAttachList", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    @ResponseBody
    public ResponseEntity<List<BoardAttachVO>> getAttachList(Long bno) {

        LogUtil.log("INFO", "getAttachList " + bno);

        return new ResponseEntity<>(service.getAttachList(bno), HttpStatus.OK);

    }

}
