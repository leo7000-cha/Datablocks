package datablocks.dlm.config;

import org.apache.catalina.connector.Connector;
import org.apache.tomcat.util.descriptor.web.SecurityCollection;
import org.apache.tomcat.util.descriptor.web.SecurityConstraint;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

// Customizes the existing TomcatServletWebServerFactory (see JndiResource) to add
// an HTTP 8080 connector alongside the HTTPS main connector, and enforces CONFIDENTIAL
// → Tomcat returns 302 from 8080 to redirectPort (8443). Uses WebServerFactoryCustomizer
// rather than defining a new factory bean to coexist with JndiResource.tomcatFactory().
// Loaded only when SPRING_PROFILES_ACTIVE includes "ssl".
@Configuration
@Profile("ssl")
public class TomcatSslConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> sslConnectorCustomizer() {
        return factory -> {
            factory.addAdditionalTomcatConnectors(httpConnector());
            factory.addContextCustomizers(context -> {
                SecurityConstraint constraint = new SecurityConstraint();
                constraint.setUserConstraint("CONFIDENTIAL");
                SecurityCollection collection = new SecurityCollection();
                collection.addPattern("/*");
                constraint.addCollection(collection);
                context.addConstraint(constraint);
            });
        };
    }

    private Connector httpConnector() {
        Connector connector = new Connector(TomcatServletWebServerFactory.DEFAULT_PROTOCOL);
        connector.setScheme("http");
        connector.setPort(8080);
        connector.setSecure(false);
        connector.setRedirectPort(8443);
        return connector;
    }
}
