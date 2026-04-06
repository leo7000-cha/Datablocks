package datablocks.dlm;

import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.util.LogUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

public class ConnectionTest {
    private static final Logger logger = LoggerFactory.getLogger(ConnectionTest.class);
//#spring.datasource.driver-class-name==net.sf.log4jdbc.sql.jdbcapi.DriverSpy
//#spring.datasource.jdbc-url=jdbc:log4jdbc:oracle:thin:@192.168.0.7:1521:XE
//#spring.dataSource.username=cotdl
//#spring.dataSource.password=!Dlm1234
    private String ip = "localhost";
    private int port = 8629;
    private String database = "tibero";
    private String user = "cotdl";
    private String password = "cotdl";
    private final String DRIVER_NAME = "com.tmax.tibero.jdbc.TbDriver";
    private final String TIBERO_JDBC_URL = "jdbc:tibero:thin:@" + ip + ":" + port + ":" + database;
    private Connection conn = null;
    private void connect() {
        try {
            LogUtil.log("WARN", DRIVER_NAME);
            Class.forName(DRIVER_NAME);
//            LogUtil.log("WARN", "5"+DRIVER_NAME);
            conn = DriverManager.getConnection(TIBERO_JDBC_URL, user, password);
        } catch(ClassNotFoundException e) {
            System.err.println(e);
        } catch(SQLException e) {
            System.err.println(e);
        }
    }

    private void executeQuery() {
        String sql = "select ST_AsText(GEOM) from tstGIS";
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while(rs.next()) {
                System.out.println(rs.getString(1));
            }
        } catch(SQLException e) {
            System.err.println(e);
        }
    }

    private void disconnect() {
        if(conn != null) {
            try {
                conn.close();
            } catch(SQLException e) {
                System.err.println(e);
            }
        }
    }

    public static void main(String[] args) {
        ConnectionTest tibero = new ConnectionTest();

        tibero.connect();
        tibero.executeQuery();
        tibero.disconnect();
    }
}
