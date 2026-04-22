package datablocks.dlm.xaudit.spring;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.apache.ibatis.session.SqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;

import datablocks.dlm.xaudit.core.XauditEventQueue;
import datablocks.dlm.xaudit.core.XauditHttpSender;
import datablocks.dlm.xaudit.core.XauditPiiMasker;
import datablocks.dlm.xaudit.jdbc.XauditJdbcQueryListener;
import datablocks.dlm.xaudit.mybatis.XauditMybatisInterceptor;
import datablocks.dlm.xaudit.servlet.XauditAccessFilter;
import datablocks.dlm.xaudit.servlet.XauditUserResolver;

/**
 * 고객사 처리계에 dependency 만 추가하면 자동으로 활성화되는 Spring Boot Auto-Configuration.
 *
 * 활성 조건:
 *   - {@code xaudit.enabled=true} (기본값 true)
 *
 * 구성요소는 선택적으로 로드 (처리계에 해당 라이브러리가 없으면 스킵):
 *   - MyBatis Interceptor   → org.apache.ibatis.session.SqlSessionFactory 존재 시
 *   - DataSource-Proxy      → net.ttddyy.dsproxy.listener.QueryExecutionListener 존재 시
 */
@Configuration
@EnableConfigurationProperties(XauditProperties.class)
@ConditionalOnProperty(prefix = "xaudit", name = "enabled", havingValue = "true", matchIfMissing = true)
public class XauditAutoConfiguration {

    private static final Logger log = LoggerFactory.getLogger(XauditAutoConfiguration.class);

    private final XauditProperties props;
    private final XauditEventQueue queue;
    private final XauditHttpSender sender;

    public XauditAutoConfiguration(XauditProperties props) {
        this.props  = props;
        this.queue  = new XauditEventQueue(props.getBatch().getQueueCapacity());
        this.sender = new XauditHttpSender(queue, props);
    }

    @PostConstruct
    public void start() {
        sender.start();
        log.info("[X-Audit] activated: service={}, server={}, queue={}",
                props.getServiceName(), props.getServer().getUrl(), props.getBatch().getQueueCapacity());
    }

    @PreDestroy
    public void stop() {
        sender.stop();
    }

    @Bean @ConditionalOnMissingBean
    public XauditEventQueue xauditEventQueue() { return queue; }

    @Bean @ConditionalOnMissingBean
    public XauditHttpSender xauditHttpSender() { return sender; }

    @Bean @ConditionalOnMissingBean
    public XauditPiiMasker xauditPiiMasker() {
        return new XauditPiiMasker(props.getSql().getMaskPatterns());
    }

    @Bean @ConditionalOnMissingBean
    public XauditUserResolver xauditUserResolver() {
        return new XauditUserResolver(props);
    }

    @Bean @ConditionalOnMissingBean
    public XauditTaskDecorator xauditTaskDecorator() {
        return new XauditTaskDecorator();
    }

    // ----- Servlet Filter (javax.servlet 기반) -----
    @Bean
    @ConditionalOnClass(name = "javax.servlet.Filter")
    public FilterRegistrationBean<XauditAccessFilter> xauditAccessFilterReg(
            ObjectProvider<XauditUserResolver> userResolvers) {
        XauditUserResolver r = userResolvers.getIfAvailable(() -> new XauditUserResolver(props));
        XauditAccessFilter filter = new XauditAccessFilter(props, queue, r);
        FilterRegistrationBean<XauditAccessFilter> reg = new FilterRegistrationBean<>(filter);
        reg.setName("xauditAccessFilter");
        reg.addUrlPatterns("/*");
        reg.setOrder(Ordered.HIGHEST_PRECEDENCE + 50);
        return reg;
    }

    // ----- MyBatis Plugin -----
    @Configuration
    @ConditionalOnClass(SqlSessionFactory.class)
    public static class MybatisSection {
        @Bean
        @ConditionalOnMissingBean
        public XauditMybatisInterceptor xauditMybatisInterceptor(
                XauditProperties props, XauditEventQueue queue, XauditPiiMasker masker,
                ObjectProvider<SqlSessionFactory> factories) {
            XauditMybatisInterceptor interceptor = new XauditMybatisInterceptor(props, queue, masker);
            // 이미 기동된 SqlSessionFactory 에 Plugin 추가 (MyBatis 는 런타임 addInterceptor 지원)
            factories.stream().forEach(f -> {
                try {
                    f.getConfiguration().addInterceptor(interceptor);
                } catch (Throwable t) {
                    log.warn("[X-Audit] addInterceptor failed on SqlSessionFactory {}: {}", f, t.toString());
                }
            });
            log.info("[X-Audit] MyBatis interceptor registered on all SqlSessionFactory beans");
            return interceptor;
        }
    }

    // ----- DataSource-Proxy Listener -----
    @Configuration
    @ConditionalOnClass(name = "net.ttddyy.dsproxy.listener.QueryExecutionListener")
    public static class DataSourceProxySection {
        @Bean
        @ConditionalOnMissingBean
        public XauditJdbcQueryListener xauditJdbcQueryListener(
                XauditProperties props, XauditEventQueue queue, XauditPiiMasker masker) {
            log.info("[X-Audit] DataSource-Proxy listener bean created (DataSource 래핑은 호스트가 수행)");
            return new XauditJdbcQueryListener(props, queue, masker);
        }
    }
}
