package datablocks.dlm.controller;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import static java.text.DateFormat.getDateTimeInstance;

/**
 * Handles requests for the application home page.
 */
@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    /**
     * Simply selects the home view to render by returning its name.
     */

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String home(Locale locale, Model model) {
        logger.info("[PERF] GET / → redirect to /hub");
        LogUtil.log("INFO", "Welcome DATABLOCKS X-One", locale);

        Date date = new Date();
        DateFormat dateFormat =
                //DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
                getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, Locale.KOREA);
                //getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, Locale.US);

        //LocaleContextHolder.setLocale(Locale.US);

        String formattedDate = dateFormat.format(date);

        model.addAttribute("serverTime", formattedDate);
        return "redirect:hub";
//        return "index";
    }


    @RequestMapping(value = "/hub", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    public String hub(Model model) {
        logger.info("[PERF] GET /hub → rendering hub.jsp");
        model.addAttribute("moduleXpurge", !"N".equalsIgnoreCase(EnvConfig.getConfig("MODULE_XPURGE")));
        model.addAttribute("moduleXgen", !"N".equalsIgnoreCase(EnvConfig.getConfig("MODULE_XGEN")));
        model.addAttribute("moduleXscan", !"N".equalsIgnoreCase(EnvConfig.getConfig("MODULE_XSCAN")));
        model.addAttribute("moduleXaudit", !"N".equalsIgnoreCase(EnvConfig.getConfig("MODULE_XAUDIT")));
        return "hub";
    }

    @RequestMapping(value = "/index", method = RequestMethod.GET)
    @PreAuthorize("isAuthenticated()")
    public String index(Locale locale, Model model,
                        @RequestParam(value = "page", required = false) String page,
                        @RequestParam(value = "db", required = false) String db,
                        @RequestParam(value = "mode", required = false) String mode) {
        logger.info("[PERF] GET /index → page={}, db={}, mode={}", page, db, mode);
        LogUtil.log("INFO", "####### X-One #######  "+ locale.toLanguageTag() + " page=" + page + " db=" + db + " mode=" + mode);
        // 현재 로케일을 모델에 추가
        model.addAttribute("currentLocale", locale.toLanguageTag());
        // 페이지 파라미터 전달 (SQL Manager 등 직접 로드용)
        model.addAttribute("loadPage", page);
        model.addAttribute("loadDb", db);
        // 모드 전달 (purge/gen)
        model.addAttribute("appMode", mode);
        return "index";
    }

}
