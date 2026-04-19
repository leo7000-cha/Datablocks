
package datablocks.dlm.config;

import datablocks.dlm.security.CustomLoginSuccessHandler;
import datablocks.dlm.security.CustomUserDetailsService;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.DelegatingAuthenticationEntryPoint;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import org.springframework.security.web.authentication.rememberme.JdbcTokenRepositoryImpl;
import org.springframework.security.web.authentication.rememberme.PersistentTokenRepository;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.session.InvalidSessionStrategy;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.OrRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpServletResponse;
import javax.sql.DataSource;
import java.util.LinkedHashMap;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Autowired
    private DataSource dataSource;

    private static AntPathRequestMatcher ant(String pattern) {
        return new AntPathRequestMatcher(pattern);
    }

    private static RequestMatcher ajaxRequestMatcher() {
        RequestMatcher xhr = req -> "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"));
        RequestMatcher customHdr = req -> req.getHeader("X-Ajax-Request") != null;
        RequestMatcher acceptsJson = req -> {
            String accept = req.getHeader("Accept");
            return accept != null && (accept.contains("application/json") || accept.contains("text/json"));
        };
        return new OrRequestMatcher(xhr, customHdr, acceptsJson);
    }

    private static AuthenticationEntryPoint buildAuthenticationEntryPoint() {
        AuthenticationEntryPoint ajaxEp = (req, res, ex) -> {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.setHeader("X-Session-Expired", "true");
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write("{\"error\":\"UNAUTHENTICATED\"}");
        };
        LinkedHashMap<RequestMatcher, AuthenticationEntryPoint> map = new LinkedHashMap<>();
        map.put(ajaxRequestMatcher(), ajaxEp);
        DelegatingAuthenticationEntryPoint aep = new DelegatingAuthenticationEntryPoint(map);
        aep.setDefaultEntryPoint(new LoginUrlAuthenticationEntryPoint("/customLogin"));
        return aep;
    }

    private static InvalidSessionStrategy buildInvalidSessionStrategy() {
        RequestMatcher ajax = ajaxRequestMatcher();
        return (req, res) -> {
            // 만료 쿠키를 대체할 새 세션을 발급 (응답에 Set-Cookie: DLMSESSIONID=NEW)
            // 이렇게 하지 않으면 브라우저가 계속 expired 쿠키를 들고 다녀 /login POST도 인터셉트됨
            req.getSession();

            if (ajax.matches(req)) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.setHeader("X-Session-Expired", "true");
                res.setContentType("application/json;charset=UTF-8");
                res.getWriter().write("{\"error\":\"SESSION_EXPIRED\"}");
            } else {
                res.sendRedirect("/customLogin?expired=1");
            }
        };
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http.authorizeHttpRequests(auth -> auth
                // Spring Security 6.x: FORWARD/ERROR dispatch 허용 (JSP 뷰 렌더링)
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()

                .requestMatchers(ant("/customLogin"), ant("/login"), ant("/customLogout"), ant("/accessError")).permitAll()
                .requestMatchers(ant("/resources/**"), ant("/favicon.ico")).permitAll()
                .requestMatchers(ant("/sample/*")).permitAll()
                .requestMatchers(ant("/piijob/order/by-prog")).permitAll()
                .requestMatchers(ant("/pii/database/bridgeQuery")).permitAll()
                .requestMatchers(ant("/dlmapi/**")).permitAll()
                .requestMatchers(ant("/api/agent/**")).permitAll()
                .requestMatchers(ant("/accesslog/justify/**")).permitAll()

                .requestMatchers(ant("/hub")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/index")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piidashboard/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiupload/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiconfkeymap/*")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconftable/*")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiapprovaluser/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/modifyjoballinfo")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/getsteptable")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/modifysteptable")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piijob/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/modifyjobwaitdialog")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/modifyjobwait")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/checkout")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/checkin")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/order")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piijob/api/**")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piijob/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piistep/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piistep/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piistep/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piistep/modifydialog")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piistep/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piistep/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piistep/order")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piistep/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piisteptable/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piisteptable/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piisteptable/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piisteptable/modifydialog")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piisteptable/modifystepallinfo")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piisteptable/searchtabledialog")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisteptable/getstepallinfo")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisteptable/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisteptable/steptablelist")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisteptable/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisteptable/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piidatabase/register")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piidatabase/modify")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piidatabase/remove")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piidatabase/exeupdate")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piidatabase/exeupdate_download_excel")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piidatabase/list")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piidatabase/get")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piidatabase/connectiontest")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piidatabase/*")).hasAnyRole("IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piiapprovalreq/approve")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/reject")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/register")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/modify")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/remove")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/myrequestlist")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiapprovalreq/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piiorder/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/rerun")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/updateactionflag")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/jobcontrol")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piiorder/getorderdetail")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiorder/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiorder/report")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiorder/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiorder/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piiextract/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiextract/custstatlist")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piiextract/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piipolicy/register")).hasAnyRole("SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/modify")).hasAnyRole("SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/remove")).hasAnyRole("SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/checkout")).hasAnyRole("SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/checkin")).hasAnyRole("SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piipolicy/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piirecovery/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/requestapproval")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/approve")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/reject")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/orderlist")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piirecovery/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piirecovery/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piirecovery/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piirestore/register")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/modify")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/remove")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/requestapproval")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/approve")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/reject")).hasAnyRole("BIZ","IT","ADMIN")
                .requestMatchers(ant("/piirestore/actorderlist")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piirestore/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piirestore/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piirestore/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/testdata/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piitable/register")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piitable/modify")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piitable/remove")).hasAnyRole("IT","ADMIN")
                .requestMatchers(ant("/piitable/layoutgaplist")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piitable/piigaplist")).hasAnyRole("IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piitable/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piitable/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piitable/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piiauth/register")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiauth/modify")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiauth/remove")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiauth/list")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiauth/get")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiauth/*")).hasAnyRole("ADMIN")

                .requestMatchers(ant("/piimember/register")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piimember/modify")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piimember/remove")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piimember/list")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piimember/get")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piimember/diologsearchmember")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piimember/modifypwd")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piimember/*")).hasAnyRole("ADMIN")

                .requestMatchers(ant("/piiconfig/register")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconfig/modify")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconfig/remove")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconfig/list")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconfig/get")).hasAnyRole("ADMIN")
                .requestMatchers(ant("/piiconfig/*")).hasAnyRole("ADMIN")

                .requestMatchers(ant("/command/*")).hasAnyRole("IT","ADMIN")

                .requestMatchers(ant("/metatable/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piisystem/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")
                .requestMatchers(ant("/piicontract/*")).hasAnyRole("USER","IT","BIZ","SEC","ADMIN")

                .requestMatchers(ant("/piidiscovery/**")).hasAnyRole("IT","SEC","ADMIN")
                .requestMatchers(ant("/accesslog/**")).hasAnyRole("IT","SEC","ADMIN")
                .anyRequest().authenticated()
        );

        http.exceptionHandling(eh -> eh
                .authenticationEntryPoint(buildAuthenticationEntryPoint())
        );

        http.sessionManagement(sm -> sm
                .invalidSessionStrategy(buildInvalidSessionStrategy())
        );

        http.formLogin(form -> form
                .loginPage("/customLogin")
                .loginProcessingUrl("/login")
                .successHandler(loginSuccessHandler())
                .failureHandler((request, response, exception) -> {
                    datablocks.dlm.util.LogUtil.log("INFO", "Login FAILED - " + exception.getClass().getSimpleName() + ": " + exception.getMessage());
                    request.getSession().setAttribute("SPRING_SECURITY_LAST_EXCEPTION", exception);
                    response.sendRedirect("/customLogin?error");
                })
                .permitAll()
        );
    /*
    *    API 서비스용 배포에는 아래줄 코맨트 풀고 Build 해야함. 20230308  -> 안풀고 그대로 배포해되 됨! 화면을 안불려서 그런거 같음.
    * */

        http.csrf(csrf -> csrf
                .ignoringRequestMatchers(ant("/dlmapi/**"), ant("/piijob/order/by-prog"), ant("/pii/database/bridgeQuery"), ant("/accesslog/api/**"), ant("/api/agent/**"), ant("/accesslog/justify/**"))
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
        );

        http.logout(logout -> logout
                .logoutUrl("/customLogout")
                .invalidateHttpSession(true)
                .deleteCookies("remember-me","DLMSESSIONID")
        );

        http.rememberMe(rm -> rm
                .key("datablocks.dlm")
                .tokenRepository(persistentTokenRepository())
                .tokenValiditySeconds(604800)
        );

        return http.build();
    }

    @Bean
    PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService customUserService() {
        return new CustomUserDetailsService();
    }

    @Bean
    public AuthenticationSuccessHandler loginSuccessHandler() {
        return new CustomLoginSuccessHandler();
    }

    @Bean
    public PersistentTokenRepository persistentTokenRepository() {
        JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
        repo.setDataSource(dataSource);
        return repo;
    }
    /* * SqlSessionFactory 설정 */
    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception{
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource);

        // application.properties의 mybatis 설정이 커스텀 빈에 의해 무시되므로 직접 설정
        // mapUnderscoreToCamelCase=false: VO 필드가 underscore 네이밍(pk_col, table_name 등)이므로 변환하지 않음
        // camelCase가 필요한 매핑은 resultMap에서 명시적으로 처리 (MemberMapper 등)
        org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(false);
        sessionFactory.setConfiguration(configuration);

        return sessionFactory.getObject();
    }

}
