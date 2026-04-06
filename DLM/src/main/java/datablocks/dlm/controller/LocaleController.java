package datablocks.dlm.controller;

import datablocks.dlm.schedule.JobScheduler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.LocaleResolver;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Locale;

@Controller
public class LocaleController {
    private static final Logger logger = LoggerFactory.getLogger(LocaleController.class);
    @Autowired
    private LocaleResolver localeResolver;

    @GetMapping("/changeLocale")
    public String changeLocale(@RequestParam("lang") String lang, HttpServletRequest request, HttpServletResponse response) {
        Locale locale = Locale.forLanguageTag(lang.replace('_', '-'));
        logger.warn("lang = "+lang);
        localeResolver.setLocale(request, response, locale);
        return "redirect:/index"; // 또는 원하는 페이지로 리다이렉트
    }
}

