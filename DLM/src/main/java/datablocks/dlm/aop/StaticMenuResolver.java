package datablocks.dlm.aop;

import java.lang.reflect.Method;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Component;

import datablocks.dlm.aop.annotation.LogAccess;

/**
 * URI prefix → (menuId, messageKey, business, defaultImportance) 정적 매핑.
 *
 * 금융권 감사 표준을 충족하기 위해 PII 관련 업무는 HIGH, 설정·조회류는 MEDIUM/LOW 로 구분.
 * 매핑 테이블 DB 확장은 추후 과제.
 */
@Component
public class StaticMenuResolver implements MenuResolver {

    /** 제외 URI prefix: 순환 기록 방지 + 노이즈 억제 */
    private static final String[] EXCLUDED_PREFIXES = {
        "/accesslog/", "/common/", "/locale/", "/home",
        "/api/agent/", "/dlmapi/", "/resources/", "/favicon"
    };

    /** URI prefix → MenuInfo. 매칭은 longest-prefix 우선이므로 LinkedHashMap 에 구체 경로를 먼저 등록 */
    private static final Map<String, MenuInfo> MENU_MAP = new LinkedHashMap<>();
    static {
        put("/piipolicy/",        "PII_POLICY",         "memu.policy",                      "PII_POLICY",    "HIGH");
        put("/piitable/",         "PII_TABLE",          "memu.table",                       "PII_TABLE",     "HIGH");
        put("/piiauth/",          "PII_AUTH",           "memu.auth_management",             "PII_AUTH",      "HIGH");
        put("/piimember/",        "PII_MEMBER",         "memu.user_management",             "PII_MEMBER",    "HIGH");
        put("/piidatabase/",      "PII_DATABASE",       "memu.db_connection",               "PII_CONFIG",    "HIGH");
        put("/piiapprovaluser/",  "PII_APPROVAL_USER",  "memu.piiapprovaluser_management",  "PII_APPROVAL",  "HIGH");
        put("/piiapprovalreq/",   "PII_APPROVAL_REQ",   "memu.approval_request",            "PII_APPROVAL",  "MEDIUM");
        put("/piicontract/",      "PII_CONTRACT",       "menu.pii_contract",                "PII_CONTRACT",  "HIGH");
        put("/piijob/",           "PII_JOB",            "memu.job",                         "PII_JOB",       "HIGH");
        put("/piiorder/",         "PII_ORDER",          "memu.job_management",              "PII_ORDER",     "HIGH");
        put("/piisteptable/",     "PII_STEP_TABLE",     "menu.pii_steptable",               "PII_ORDER",     "MEDIUM");
        put("/piistep/",          "PII_STEP",           "menu.pii_step",                    "PII_ORDER",     "MEDIUM");
        put("/piirecovery/",      "PII_RECOVERY",       "memu.restore_management",          "PII_RECOVERY",  "HIGH");
        put("/piirestore/",       "PII_RESTORE",        "memu.restore",                     "PII_RESTORE",   "HIGH");
        put("/piiupload/",        "PII_UPLOAD",         "menu.pii_upload",                  "PII_UPLOAD",    "MEDIUM");
        put("/piidiscovery/",     "PII_DISCOVERY",      "menu.pii_discovery",               "PII_DISCOVERY", "MEDIUM");
        put("/piidetect/",        "PII_DETECT",         "memu.detect_management",           "PII_DETECT",    "MEDIUM");
        put("/piiextract/",       "PII_EXTRACT",        "menu.pii_extract",                 "PII_EXTRACT",   "HIGH");
        put("/piidashboard/",     "PII_DASHBOARD",      "memu.dashboard",                   "PII_DASHBOARD", "LOW");
        put("/piiconfig/",        "PII_CONFIG",         "memu.env_configuration",           "PII_CONFIG",    "MEDIUM");
        put("/piisystem/",        "PII_SYSTEM",         "memu.systemmgmt",                  "PII_SYSTEM",    "MEDIUM");
        put("/lkpiiscrtype/",     "LK_PII_SCR_TYPE",    "memu.lkpiiscr_mgmt",               "PII_CONFIG",    "MEDIUM");
        put("/metatable/",        "META_TABLE",         "menu.meta_table",                  "META",          "MEDIUM");
        put("/testdata/",         "TEST_DATA",          "memu.testdata",                    "TEST_DATA",     "MEDIUM");
        put("/reportform/",       "REPORT_FORM",        "menu.report_form",                 "REPORT",        "LOW");
        put("/report/",           "REPORT",             "memu.report",                      "REPORT",        "LOW");
        put("/board/",            "BOARD",              "menu.board",                       "BOARD",         "LOW");
        put("/reply/",            "REPLY",              "menu.reply",                       "BOARD",         "LOW");
    }

    private static void put(String prefix, String menuId, String key, String business, String importance) {
        MENU_MAP.put(prefix, new MenuInfo(menuId, key, business, importance, false));
    }

    @Override
    public MenuInfo resolve(Class<?> controller, Method method, String uri, LogAccess ann) {
        if (uri == null) return new MenuInfo("UNKNOWN", null, "UNKNOWN", "LOW", false);

        for (String ex : EXCLUDED_PREFIXES) {
            if (uri.startsWith(ex)) return MenuInfo.excluded();
        }

        MenuInfo best = null;
        int bestLen = -1;
        for (Map.Entry<String, MenuInfo> e : MENU_MAP.entrySet()) {
            if (uri.startsWith(e.getKey()) && e.getKey().length() > bestLen) {
                best = e.getValue();
                bestLen = e.getKey().length();
            }
        }
        if (best != null) {
            // 어노테이션이 명시한 menu/menuKey/business 가 있으면 덮어씀
            String menuId  = (ann != null && !ann.menu().isEmpty())     ? ann.menu()     : best.getMenuId();
            String key     = (ann != null && !ann.menuKey().isEmpty())  ? ann.menuKey()  : best.getMenuNameKey();
            String biz     = (ann != null && !ann.business().isEmpty()) ? ann.business() : best.getBusiness();
            return new MenuInfo(menuId, key, biz, best.getDefaultImportance(), false);
        }

        // 매핑 없음: 컨트롤러 클래스 short name 으로 fallback
        String fallbackMenu = controller != null ? controller.getSimpleName().replaceAll("Controller$", "").toUpperCase() : "UNKNOWN";
        return new MenuInfo(fallbackMenu, null, fallbackMenu, "LOW", false);
    }

    @Override
    public String inferAction(String httpMethod, String uri) {
        if (uri == null) uri = "";
        String lower = uri.toLowerCase();
        if (lower.contains("download") || lower.contains("excel") || lower.contains("export")) return "DOWNLOAD";
        if (lower.contains("remove")   || lower.contains("delete")) return "DELETE";
        if (lower.contains("modify")   || lower.contains("update") || lower.contains("edit")) return "UPDATE";
        if (lower.contains("register") || lower.contains("insert") || lower.contains("save") || lower.contains("create")) return "INSERT";
        if ("POST".equalsIgnoreCase(httpMethod)) return "UPDATE";
        return "SELECT";
    }
}
