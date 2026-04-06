package datablocks.dlm;

import java.sql.*;
public class ImagArcRestore {
    public static void main(String[] args) throws SQLException {
        try {
            int testcode = 16;
            // Oracle 데이터베이스에 연결
            Connection oracleConnection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "cotdl", "cotdl23");

            // MySQL 데이터베이스에 연결
            Connection mysqlConnection = DriverManager.getConnection("jdbc:mariadb://192.168.0.33:3306/cotdl", "cotdl", "!Dlm1234");

            // Oracle에서 이미지 데이터를 MySQL로 백업
            Statement oracleStatement = oracleConnection.createStatement();
            ResultSet oracleResultSet = oracleStatement.executeQuery("SELECT * FROM test_a where code=5");

            // Oracle 데이터를 삭제
            Statement deleteStatementmysql = mysqlConnection.createStatement();
            deleteStatementmysql.execute("DELETE FROM test_a where code="+testcode);


            //
            while (oracleResultSet.next()) {
                int code = oracleResultSet.getInt("code");
                String filename = oracleResultSet.getString("filename");
                /// Oracle의 Blob 데이터를 byte 배열로 변환합니다.
//                Blob imageBlob = oracleResultSet.getBlob("blobdata");
//                byte[] imageBytes = imageBlob.getBytes(1, (int) imageBlob.length());
//                Blob mysqlBlob = new SerialBlob(imageBytes);
                Blob mysqlBlob = oracleResultSet.getBlob("blobdata");

                // MySQL에 이미지를 삽입합니다.
                String sql = "INSERT INTO test_a (code, filename, blobdata) VALUES (?,?,?)";
                PreparedStatement mysqlPepareStatement = mysqlConnection.prepareStatement(sql);
                mysqlPepareStatement.setInt(1, testcode);
                mysqlPepareStatement.setString(2, filename);
                mysqlPepareStatement.setBlob(3, mysqlBlob);
                mysqlPepareStatement.execute();
            }
//            while (oracleResultSet.next()) {
//                Blob imageBlob = oracleResultSet.getBlob("blobdata");
//                int code = oracleResultSet.getInt("code");
//                String filename = oracleResultSet.getString("filename");
//
//
//                // MySQL에 이미지를 삽입합니다.
//                String sql = "INSERT INTO test_a (code, filename, blobdata) VALUES (?,?,?)";
//                PreparedStatement oraclePrepareStatement = oracleConnection.prepareStatement("INSERT INTO test_a (code, filename, blobdata) VALUES (?,?,?)");
//                oraclePrepareStatement.setInt(1, 11);
//                oraclePrepareStatement.setString(2, filename);
//                oraclePrepareStatement.setBlob(3, imageBlob);
//                oraclePrepareStatement.execute();
//            }
            // Oracle 데이터를 삭제
//            Statement deleteStatement = oracleConnection.createStatement();
//            deleteStatement.execute("DELETE FROM test_a where code=4");

            // MySQL에서 이미지 데이터를 Oracle로 다시 삽입
           Statement mysqlStatement = mysqlConnection.createStatement();
            ResultSet mysqlResultSet = mysqlStatement.executeQuery("SELECT * FROM test_a where code="+testcode);


            oracleStatement.execute("DELETE FROM test_a where code="+testcode);

            PreparedStatement oraclePrepareStatement = oracleConnection.prepareStatement("INSERT INTO test_a (code, filename, blobdata) VALUES (?,?,?)");

            while (mysqlResultSet.next()) {
                int code = mysqlResultSet.getInt("code");
                String filename = mysqlResultSet.getString("filename");

                // MariaDB의 Blob 객체를 byte 배열로 변환합니다.
                Blob imageBlob = mysqlResultSet.getBlob("blobdata");
                byte[] imageBytes = imageBlob.getBytes(1, (int) imageBlob.length());

                /** Oracle의 Blob 객체를 생성합니다. */
                Blob oracleBlob = oracleConnection.createBlob();
                oracleBlob.setBytes(1, imageBytes);

                // Oracle에 이미지를 삽입합니다.
                //PreparedStatement oraclePrepareStatement = oracleConnection.prepareStatement("INSERT INTO image (code, filename, blobdata) VALUES (?,?,?)");
                oraclePrepareStatement.setInt(1, code);
                oraclePrepareStatement.setString(2, filename);
                oraclePrepareStatement.setBlob(3, oracleBlob);
                oraclePrepareStatement.execute();
            }
            //oracleConnection.commit();
            // 데이터베이스 연결을 닫습니다.
            oracleConnection.close();
            mysqlConnection.close();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
