package datablocks.dlm.config;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.tomcat.util.descriptor.web.ContextResource;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.embedded.tomcat.TomcatWebServer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JndiResource {

    @Bean
    public TomcatServletWebServerFactory tomcatFactory() {
        return new TomcatServletWebServerFactory() {
            @Override
            protected TomcatWebServer getTomcatWebServer(Tomcat tomcat) {
                tomcat.enableNaming();
                return super.getTomcatWebServer(tomcat);
            }

            @Override
            protected void postProcessContext(Context context) {
                context.getNamingResources().addResource(getResource());
            }
        };
    }

    public ContextResource getResource() {
        ContextResource resource = new ContextResource();
        resource.setName("jndi/dlmhome"); // 사용될 jndi 이름
        resource.setType("javax.sql.DataSource");
        resource.setAuth("Container");
        resource.setProperty("factory", "org.apache.commons.dbcp2.BasicDataSourceFactory");

        // datasource 정보
        //resource.setProperty("driverClassName", "oracle.jdbc.OracleDriver");
        //resource.setProperty("url", "jdbc:oracle:thin:@localhost:1521:XE");
        resource.setProperty("driverClassName", "org.mariadb.jdbc.Driver");
        resource.setProperty("url", "jdbc:mariadb://192.168.0.33:3306/cotdl");
        //resource.setProperty("url", "jdbc:mariadb://localhost:3306/cotdl");
        resource.setProperty("username", "cotdl");
        resource.setProperty("password", "!Dlm1234");
        return resource;
    }
}
