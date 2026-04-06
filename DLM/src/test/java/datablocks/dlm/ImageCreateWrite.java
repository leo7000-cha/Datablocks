package datablocks.dlm;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
public class ImageCreateWrite {
    public static void main(String[] args) throws SQLException {
        try {
            // Oracle 데이터베이스에 연결
            Connection oracleConnection = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "cotdl", "cotdl23");

            // MySQL 데이터베이스에 연결
            Connection mysqlConnection = DriverManager.getConnection("jdbc:mariadb://192.168.0.33:3306/cotdl", "cotdl", "!Dlm1234");

            // 이미지 파일을 읽습니다.
            byte[] imageData = Files.readAllBytes(Paths.get("C:/Users/Win/Pictures/KakaoTalk_20230116_171324950.jpg"));

            // 이미지 데이터를 Blob 객체로 변환합니다.
            Blob imageBlob = new javax.sql.rowset.serial.SerialBlob(imageData);

            // PreparedStatement를 생성합니다.
            PreparedStatement oraclePrepareStatement = oracleConnection.prepareStatement("INSERT INTO images (id, image) VALUES (?,?)");

            // id 열의 데이터를 설정합니다.
            int id = 5;
            oraclePrepareStatement.setInt(1, id);

            // image 열의 데이터를 설정합니다.
            oraclePrepareStatement.setBlob(2, imageBlob);

            // 이미지를 데이터베이스에 삽입합니다.
            oraclePrepareStatement.executeUpdate();

        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
