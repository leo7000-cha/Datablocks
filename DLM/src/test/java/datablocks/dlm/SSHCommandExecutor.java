package datablocks.dlm;

import com.jcraft.jsch.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class SSHCommandExecutor {

    public static void main(String[] args) {
        String host = "192.168.0.7";
        String user = "Win";
        String password = null;//"your_ssh_password"; // 또는 SSH 키 파일 사용 가능
        int port = 22; // SSH 포트 번호

        /*try {
            JSch jsch = new JSch();
            Session session = jsch.getSession(user, host, port);
            session.setPassword(password); // 또는 SSH 키 파일 설정

            // 호스트 키 검사 무시 (보안상 주의)
            session.setConfig("StrictHostKeyChecking", "no");

            // SSH 세션 연결
            session.connect();

            // 명령 실행
            String command = "sqlldr cotdl/cotdl23@localhost:1521/XE control=D:/tmp/COOWNORG_ARAGRID_0.ct log=D:/tmp/tbloader.log";
            //String command = "ipconfig";
            ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
            channelExec.setCommand(command);

            // 명령 실행 결과 출력
            BufferedReader reader = new BufferedReader(new InputStreamReader(channelExec.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }

            // 명령 종료 대기
            channelExec.wait();

            // 연결 종료
            channelExec.disconnect();
            session.disconnect();

        } catch (JSchException | IOException | InterruptedException e) {
            e.printStackTrace();
        }*/
    }
}

