package datablocks.dlm;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class RemoteTBLoader {

    public static void main(String[] args) {
        try {
            // 원격 Tibero 서버의 호스트, 포트, 데이터베이스 설정
            String remoteHost = "192.168.0.7";
            int remotePort = 8629; // Tibero 서버의 포트 번호
            String remoteDatabase = "tibero"; // 실제 데이터베이스 이름으로 대체

            // 제어 파일 경로 설정
            String ctlFilename = "D:/tmp/COOWNORG_ARAGRID_0.ctl";

            // tbLoader 명령 구성

            String tbLoaderCommand = "tbloader userid=cotdl/cotdl@" + remoteHost + ":" + remotePort + "/" + remoteDatabase
                    + " control=" + ctlFilename + " log=" + "D:/tmp/tbloader.log";

            System.out.println(tbLoaderCommand);
            // 명령 실행
            Process process = Runtime.getRuntime().exec(tbLoaderCommand);

            // 명령 실행 결과 출력
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }

            // 명령 종료 대기
            int exitCode = process.waitFor();
            System.out.println("tbLoader process exited with code " + exitCode);

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}

