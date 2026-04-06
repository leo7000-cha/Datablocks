package datablocks.dlm.config;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

/**
 * ApplicationContextProvider
 * Static 메소드에서 Spring Bean을 가져올 수 있도록 하는 유틸리티
 *
 * 사용 예시:
 *   ArchiveNamingService service = ApplicationContextProvider.getBean(ArchiveNamingService.class);
 */
@Component
public class ApplicationContextProvider implements ApplicationContextAware {

    private static ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext context) throws BeansException {
        applicationContext = context;
    }

    /**
     * ApplicationContext 조회
     */
    public static ApplicationContext getApplicationContext() {
        return applicationContext;
    }

    /**
     * Bean 조회 (타입 기반)
     *
     * @param beanClass Bean 클래스
     * @return Bean 인스턴스 (없으면 null)
     */
    public static <T> T getBean(Class<T> beanClass) {
        if (applicationContext == null) {
            return null;
        }
        try {
            return applicationContext.getBean(beanClass);
        } catch (BeansException e) {
            return null;
        }
    }

    /**
     * Bean 조회 (이름 기반)
     *
     * @param beanName Bean 이름
     * @return Bean 인스턴스 (없으면 null)
     */
    public static Object getBean(String beanName) {
        if (applicationContext == null) {
            return null;
        }
        try {
            return applicationContext.getBean(beanName);
        } catch (BeansException e) {
            return null;
        }
    }

    /**
     * Bean 조회 (이름 + 타입 기반)
     *
     * @param beanName  Bean 이름
     * @param beanClass Bean 클래스
     * @return Bean 인스턴스 (없으면 null)
     */
    public static <T> T getBean(String beanName, Class<T> beanClass) {
        if (applicationContext == null) {
            return null;
        }
        try {
            return applicationContext.getBean(beanName, beanClass);
        } catch (BeansException e) {
            return null;
        }
    }

    /**
     * ApplicationContext 초기화 여부 확인
     */
    public static boolean isInitialized() {
        return applicationContext != null;
    }

}
