package datablocks.dlm.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import com.ibm.ims.db.spi.ConnectionPool;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import datablocks.dlm.controller.PiiDatabaseController;
import org.springframework.beans.factory.annotation.Autowired;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class ConnectionProvider {

	private static final Logger logger = LoggerFactory.getLogger(ConnectionProvider.class);

	/**
	 * @deprecated DriverManager 직접 사용 (풀링 안 됨).
	 * 배치 처리에는 {@link DataSourceCache} 또는 {@link #getDataSource(int, String, String, String, String, String, String, String, String)}를 사용할 것.
	 * 단발성 커넥션(DB 연결 테스트, 메타데이터 조회 등)에만 사용 권장.
	 */
	@Deprecated
	public static Connection getConnection(String dbtype, String host, String port, String id_type, String id, String db, String user, String pw) throws SQLException {
	
		Connection conn = null;
		String driverClass = "";
		String url = "";
		if(dbtype.equalsIgnoreCase("MARIADB")) {		
			driverClass = "org.mariadb.jdbc.Driver";
			url = "jdbc:mariadb://"+host+":"+port+"/"+id+"?" + 
					"useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
		}
		else if(dbtype.equalsIgnoreCase("MYSQL")) {		
			driverClass = "com.mysql.cj.jdbc.Driver";
			url = "jdbc:mysql://"+host+":"+port+"/"+id+"?" + 
					"useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
		}
		else if(dbtype.equalsIgnoreCase("DB2")) {		
			driverClass = "com.ibm.db2.jcc.DB2Driver";
			url = "jdbc:db2://"+host+":"+port+"/"+id;
		}
		else if(dbtype.equalsIgnoreCase("IMS")) {
			driverClass = "com.ibm.ims.jdbc.IMSDriver";
			url = "jdbc:mysql://"+host+":"+port+"/"+id;
//			"jdbc:ims://tst.svl.ibm.com:8888/class://BMP2.BMP2DatabaseView";
		}
		else if(dbtype.equalsIgnoreCase("ORACLE")) {
			driverClass = "oracle.jdbc.OracleDriver";
			if(id_type.equals("SID"))
					url = "jdbc:oracle:thin:@"+host+":"+port+":"+id;//연결문자열 jdbc:oracle:thin:@호스트:포트:sid
			else
				    url = "jdbc:oracle:thin:@"+host+":"+port+"/"+id;//연결문자열 jdbc:oracle:thin:@호스트:포트/servicename
		}
		else if(dbtype.equalsIgnoreCase("TIBERO")) {
			driverClass = "com.tmax.tibero.jdbc.TbDriver";
			url = "jdbc:tibero:thin:@"+host+":"+port+":"+id;
		}
		else if(dbtype.equalsIgnoreCase("POSTGRESQL")) {
			driverClass = "org.postgresql.Driver";
			url="jdbc:postgresql://"+host+":"+port+"/"+id; // 호스트:포트/db
		}
		else if(dbtype.equalsIgnoreCase("MSSQL")) {
			driverClass = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
			url = "jdbc:sqlserver://"+host+":"+port+";DatabaseName="+db;//jdbc:sqlserver://서버IP주소:1433;DatabaseName=데이터베이스명

		}
		else if (dbtype.equalsIgnoreCase("SAP_IQ")) {
			driverClass = "sap.jdbc4.sqlanywhere.IDriver";
			url = "jdbc:sqlanywhere:Server=" + id
					+ ";DBN=" + db
					+ ";Host=" + host + ":" + port;
		}
		logger.debug("info$ "+driverClass);
		logger.debug("info$ "+url);
		loadJDBCDriver(driverClass);
        
        try{
        	conn = DriverManager.getConnection(url, user, pw);
            logger.debug("info$ "+"Successfully connected-DriverManager.getConnection(url, user, pw)=> "+url);
            //conn.close();
        }catch(Exception e) {
            e.printStackTrace();
            throw e;
        }
        
        return conn;

	}
	public static HikariDataSource getDataSource( int maximumPoolSize, String dbtype, String host, String port, String id_type, String id, String db, String user, String pw) throws SQLException {

		String driverClass = "";
		String url = "";
		if(dbtype.equalsIgnoreCase("MARIADB")) {
			driverClass = "org.mariadb.jdbc.Driver";
			url = "jdbc:mariadb://"+host+":"+port+"/"+id+"?" +
					"useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
		}
		else if(dbtype.equalsIgnoreCase("MYSQL")) {
			driverClass = "com.mysql.cj.jdbc.Driver";
			url = "jdbc:mysql://"+host+":"+port+"/"+id+"?" +
					"useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
		}
		else if(dbtype.equalsIgnoreCase("DB2")) {
			driverClass = "com.ibm.db2.jcc.DB2Driver";
			url = "jdbc:db2://"+host+":"+port+"/"+id;
		}
		else if(dbtype.equalsIgnoreCase("IMS")) {
			driverClass = "com.ibm.ims.jdbc.IMSDriver";
			url = "jdbc:mysql://"+host+":"+port+"/"+id;
//			"jdbc:ims://tst.svl.ibm.com:8888/class://BMP2.BMP2DatabaseView";
		}
		else if(dbtype.equalsIgnoreCase("ORACLE")) {
			driverClass = "oracle.jdbc.OracleDriver";
			if(id_type.equals("SID"))
				url = "jdbc:oracle:thin:@"+host+":"+port+":"+id;//연결문자열 jdbc:oracle:thin:@호스트:포트:sid
			else
				url = "jdbc:oracle:thin:@"+host+":"+port+"/"+id;//연결문자열 jdbc:oracle:thin:@호스트:포트/servicename
		}
		else if(dbtype.equalsIgnoreCase("TIBERO")) {
			driverClass = "com.tmax.tibero.jdbc.TbDriver";
			url = "jdbc:tibero:thin:@"+host+":"+port+":"+id;
		}
		else if(dbtype.equalsIgnoreCase("POSTGRESQL")) {
			driverClass = "org.postgresql.Driver";
			url="jdbc:postgresql://"+host+":"+port+"/"+id; // 호스트:포트/db
		}
		else if(dbtype.equalsIgnoreCase("MSSQL")) {
			driverClass = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
			url = "jdbc:sqlserver://"+host+":"+port+";DatabaseName="+db;//jdbc:sqlserver://서버IP주소:1433;DatabaseName=데이터베이스명

		}
		else if (dbtype.equalsIgnoreCase("SAP_IQ")) {
			driverClass = "sap.jdbc4.sqlanywhere.IDriver";
			url = "jdbc:sqlanywhere:Server=" + id
					+ ";DBN=" + db
					+ ";Host=" + host + ":" + port;
		}
		HikariDataSource dataSource = null;
		try{
			dataSource = createDataSource(driverClass, url, user, pw, maximumPoolSize);
		}catch(Exception e) {
			e.printStackTrace();
			throw e;
		}

		return dataSource;

	}
	public static HikariDataSource createDataSource(String driverClassName, String jdbcUrl, String username, String password, int maximumPoolSize) {
		HikariConfig config = new HikariConfig();
		config.setDriverClassName(driverClassName);
		config.setJdbcUrl(jdbcUrl);
		config.setUsername(username);
		config.setPassword(password);
		config.setMaximumPoolSize(maximumPoolSize);
		if (maximumPoolSize > 1) {
			// MinimumIdle: 최소 1개 유지하여 재작업 시 매번 새 커넥션 생성 방지
			config.setMinimumIdle(Math.max(1, maximumPoolSize / 4));
			config.setIdleTimeout(120_000);                 // 2분 유휴 시 물리 커넥션 제거 (MinIdle 초과분)
		}
		// poolSize=1이면 minimumIdle 기본값(=maximumPoolSize)으로 고정 풀 동작, idleTimeout 불필요
		config.setMaxLifetime(30 * 60 * 1000);              // 30분 수명 (방화벽 idle timeout 대비)
		config.setKeepaliveTime(5 * 60 * 1000);             // 5분마다 keepalive (장시간 배치 대비)
		config.setConnectionTimeout(10_000);                // 10초 대기 후 실패
		config.setLeakDetectionThreshold(5 * 60 * 1000);    // 5분 이상 미반환 시 경고 로그
		config.setPoolName("DLM-Batch");
		// Validation: stale 커넥션 감지
		// HikariCP는 JDBC4 isValid()를 기본 사용하므로 connectionTestQuery는
		// JDBC4 미지원 드라이버를 위한 폴백으로만 설정
		if (jdbcUrl.contains("oracle") || jdbcUrl.contains("tibero")) {
			config.setConnectionTestQuery("SELECT 1 FROM DUAL");
		} else {
			config.setConnectionTestQuery("SELECT 1");
		}
		config.setValidationTimeout(3_000);                 // validation 타임아웃 3초

		return new HikariDataSource(config);
	}

	private static void loadJDBCDriver(String driverClass) {
		try {
			Class.forName(driverClass);
		} catch (ClassNotFoundException ex) {
			throw new RuntimeException("fail to load JDBC Driver", ex);
		}
	}
}