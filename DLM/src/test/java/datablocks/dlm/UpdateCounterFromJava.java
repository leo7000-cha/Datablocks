package datablocks.dlm;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Types;

public class UpdateCounterFromJava {
    public static void main(String[] args) {
        // JDBC 연결 변수 초기화
        Connection connection = null;
        CallableStatement callableStatement = null;

        try {
            // JDBC 드라이버 로드
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Oracle 데이터베이스 연결
            String url = "jdbc:oracle:thin:@//호스트주소:포트번호/데이터베이스이름";
            String username = "사용자이름";
            String password = "비밀번호";
            connection = DriverManager.getConnection(url, username, password);

            // 프로시저 호출을 위한 CallableStatement 생성
            callableStatement = connection.prepareCall("{call update_counter_table(?, ?)}");

            // 프로시저의 인자 설정
            callableStatement.setString(1, "your_counter_id");
            callableStatement.registerOutParameter(2, Types.INTEGER);

            // 프로시저 실행
            callableStatement.execute();

            // 업데이트된 값 가져오기
            int updatedValue = callableStatement.getInt(2);
            System.out.println("Updated value: " + updatedValue);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // JDBC 연결 해제
            try {
                if (callableStatement != null) {
                    callableStatement.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
