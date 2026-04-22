package datablocks.dlm.aop.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * AOP 접속기록 수집용 어노테이션.
 *
 * 컨트롤러 메서드에 부착하면 {@link datablocks.dlm.aop.AccessLogAspect} 가
 * 실행 전후를 감싸 {@code WAS_AOP} 수집원으로 접속기록을 적재한다.
 *
 * 모든 필드는 선택적이며, 비어 있을 경우 URI/HTTP 메서드/메뉴 카탈로그에서 자동 추론한다.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface LogAccess {

    /** 메뉴 ID (예: "PII_POLICY"). 비어있으면 MenuResolver 가 URI prefix로 결정 */
    String menu() default "";

    /** messages.properties 키 (예: "memu.policy"). 지정 시 Locale 기반 메뉴명 사용 */
    String menuKey() default "";

    /** 수행업무: SELECT/INSERT/UPDATE/DELETE/DOWNLOAD/EXPORT. 비어있으면 URI/HTTP 메서드로 추론 */
    String action() default "";

    /** 중요도 (HIGH/MEDIUM/LOW). AOP_MIN_IMPORTANCE 설정과 비교해 필터링 */
    String importance() default "MEDIUM";

    /** 업무구분 (예: "PII_POLICY"). 리포트 그룹핑용 */
    String business() default "";

    /** 메서드별 추가 마스킹 필드 (전역 AOP_MASK_FIELDS 와 합집합) */
    String[] maskParams() default {};

    /** 파라미터 JSON 기록 여부 (false 시 searchCondition 미기록) */
    boolean recordParams() default true;

    /** 임시 비활성화 용 (false 면 어노테이션 모드에서도 기록 안 함) */
    boolean record() default true;
}
