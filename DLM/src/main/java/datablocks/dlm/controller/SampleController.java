package datablocks.dlm.controller;

import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

//@RestController
@RequestMapping("/sample/*")
@Controller
public class SampleController {
    private static final Logger logger = LoggerFactory.getLogger(SampleController.class);

    @GetMapping("/hello")
    public void hello() {
        //return new String[]{"Hello","World"};
        LogUtil.log("INFO", "sample/hello");
    }

    @GetMapping("/index")
    public void index() {
        LogUtil.log("INFO", "sample/index");
        //return "index";
    }
}
