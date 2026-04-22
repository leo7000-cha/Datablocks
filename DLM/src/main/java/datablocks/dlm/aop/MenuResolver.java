package datablocks.dlm.aop;

import java.lang.reflect.Method;

import datablocks.dlm.aop.annotation.LogAccess;

/**
 * 컨트롤러 Class/Method/URI → 메뉴 메타데이터 매핑 인터페이스.
 *
 * 초기 구현은 {@link StaticMenuResolver} (정적 Map). 추후 DB 카탈로그 기반
 * 동적 구현으로 교체 가능하도록 인터페이스로 분리한다.
 */
public interface MenuResolver {

    /**
     * @param controller 실행 컨트롤러 클래스
     * @param method     실행 메서드
     * @param uri        요청 URI (쿼리스트링 제외)
     * @param ann        메서드에 부착된 @LogAccess (없으면 null)
     * @return 메뉴 메타데이터. URI가 제외 대상이면 {@link MenuInfo#isExcluded()} = true
     */
    MenuInfo resolve(Class<?> controller, Method method, String uri, LogAccess ann);

    /** HTTP 메서드/URI 기반 액션 타입 추론 */
    String inferAction(String httpMethod, String uri);

    /**
     * 메뉴 메타데이터 DTO.
     */
    class MenuInfo {
        private final String menuId;
        private final String menuNameKey;
        private final String business;
        private final String defaultImportance;
        private final boolean excluded;

        public MenuInfo(String menuId, String menuNameKey, String business,
                        String defaultImportance, boolean excluded) {
            this.menuId = menuId;
            this.menuNameKey = menuNameKey;
            this.business = business;
            this.defaultImportance = defaultImportance;
            this.excluded = excluded;
        }

        public static MenuInfo excluded() {
            return new MenuInfo(null, null, null, null, true);
        }

        public String getMenuId()            { return menuId; }
        public String getMenuNameKey()       { return menuNameKey; }
        public String getBusiness()          { return business; }
        public String getDefaultImportance() { return defaultImportance; }
        public boolean isExcluded()          { return excluded; }
    }
}
