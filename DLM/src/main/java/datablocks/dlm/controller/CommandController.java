package datablocks.dlm.controller;
import java.io.*;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.*;
import datablocks.dlm.service.PiiConfigService;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/command/*")
@AllArgsConstructor
public class CommandController {
    private static final Logger logger = LoggerFactory.getLogger(CommandController.class);
    private PiiConfigService configSV;

    @GetMapping("/console")
    @PreAuthorize("isAuthenticated()")
    public void console(Criteria cri, Model model) {
        LogUtil.log("INFO", "console   cri: " + cri);
        //cri.setSearch1("D:\\Datablocks\\workspace-DLM\\DLM\\src\\main\\webapp\\WEB-INF\\log");
        List<LogFileVO> logfiles = new ArrayList<LogFileVO>();
        boolean filenamenull = StrUtil.checkString(cri.getSearch2());
        String DLM_LOG_PATH = EnvConfig.getConfig("DLM_LOG_PATH");

        if (StrUtil.checkString(cri.getSearch1()))
            cri.setSearch1(DLM_LOG_PATH);

        try {
            File dir = new File(cri.getSearch1());
            File path[] = dir.listFiles();
            String[] filenames = dir.list();

            for (int i = 0; i < path.length; i++) {
                if (!filenamenull)
                    if (!filenames[i].contains(cri.getSearch2()))
                        continue;
                LogFileVO logfilevo = new LogFileVO();
                if (path[i].isDirectory()) {
                    logfilevo.setType("D");
                } else {
                    logfilevo.setType("F");
                }
                logfilevo.setPath("" + path[i]);
                logfilevo.setFilename("" + filenames[i]);
                logfiles.add(logfilevo);
                LogUtil.log("INFO", filenames[i]);
            }
        } catch (Exception e) {
            logger.warn("warn "+cri + " " + e.getMessage());
        }
        model.addAttribute("list", logfiles);
        int total = logfiles.size();
        PageDTO pageMaker = new PageDTO(cri, total);
        model.addAttribute("pageMaker", pageMaker);


    }

    @ResponseBody
    @RequestMapping(value = "readLogfile", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String readLogfile(@RequestBody LogFileVO logfilevo, Criteria cri, Model model) {
        LogUtil.log("INFO", "readLogfile(: " + cri);
        StringBuilder contents = null;
        try {
            //BufferedReader reader = new BufferedReader(new FileReader(logfilevo.getPath()));
            BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(logfilevo.getPath()), Charset.forName("UTF-8")));

            String str;
            contents = new StringBuilder();
            while ((str = reader.readLine()) != null) {
                LogUtil.log("INFO", str);
                contents.append(str + "\n");
            }
            reader.close();
        } catch (Exception e) {
            logger.warn("warn "+"readLogfile => " + logfilevo.getPath() + " " + e.getMessage());
        }

        return contents.toString();

    }

    @ResponseBody
    @RequestMapping(value = "writefile", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String writefile(@RequestBody LogFileVO logfilevo, Criteria cri, Model model) {
        LogUtil.log("INFO", "writefile: " + cri);
        String filePath = logfilevo.getPath();
        String filename = logfilevo.getFilename();
        String contents = logfilevo.getContents();
        String result = "success";
        int fileMode = 776; // 권한 모드;//rwxrwxrw-
//        logger.warn("warn "+"writefile: " + logfilevo.toString());
        try {
            // Check if the file already exists
            File file = new File(filePath, filename);
            if (file.exists()) {
                // Delete the existing file
                if (!file.delete()) {
                    throw new IOException("Failed to delete existing file: " + file.getAbsolutePath());
                }
                logger.warn("warn "+"Existing file deleted: " + file.getAbsolutePath());
            }
            boolean isWindows  = System.getProperty("os.name").toLowerCase().startsWith("windows");

            if(isWindows) {logger.warn("warn "+"isWindows: "+"true");
                FileWriter fileWriter = new FileWriter(filePath+"\\"+logfilevo.getFilename());
                BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

                bufferedWriter.write(contents);

                bufferedWriter.close();
            }else {logger.warn("warn "+"isWindows: "+"false");
                FileOutputStream fos = new FileOutputStream(filePath+"/"+logfilevo.getFilename());
                fos.write(contents.getBytes());

                // 파일 권한 설정
                Runtime.getRuntime().exec("chmod " + fileMode + " " + filePath + "/" +logfilevo.getFilename());

                fos.close();
            }

            result = "success";
            LogUtil.log("INFO", "File updated successfully.");
        } catch (Exception e) {
            result = "fail";
            logger.warn("warn "+"An error occurred while updating the file: " + e.getMessage());
        }
        return result;
    }

    @ResponseBody
    @RequestMapping(value = "executecommand", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String executeCommand(@RequestBody CommandVO commandvo, Criteria cri, Model model) {
        StringBuilder output = new StringBuilder();

        try {
            // 실행할 명령어
//            String command = "ls -l"; // 원하는 명령어를 입력하세요.
//            String command = "dir"; // 원하는 명령어를 입력하세요.
            String command = commandvo.getCommand(); // 원하는 명령어를 입력하세요.
            logger.warn("info$ "+"command: "+command +"  "+System.getProperty("os.name"));
            // 명령어 실행
            ProcessBuilder builder = new ProcessBuilder();

            boolean isWindows  = System.getProperty("os.name").toLowerCase().startsWith("windows");

            if(isWindows) {
                builder.command("cmd.exe", "/c", command); // Windows OS
            }else {
                //builder.command("bash", "-c", command); // Linux OS
                // Linux 환경에서 sudo로 실행
                builder.command("sudo", "bash", "-c", command);
            }

            Process process = builder.start();
            logger.warn("info$ "+"builder.start(): "+command);
            // 명령어 실행 결과 읽기
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(),"UTF-8"));
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
//            logger.warn("warn "+"output.toString(): "+output.toString());
            // 프로세스 종료 대기
            if(process != null) {
                process.destroy();
            }

        } catch (Exception e) {
            logger.warn("warn "+"Exception: "+e.getMessage());
            e.printStackTrace();
        }

        return output.toString();
    }

    @ResponseBody
    @RequestMapping(value = "rmWar", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String rmWar(@RequestBody CommandVO commandvo) {
        StringBuilder output = new StringBuilder();
        String command = commandvo.getCommand(); // 원하는 명령어를 입력하세요.
        LogUtil.log("INFO", "command: "+command);
        // 1️⃣ DLM.war 파일 삭제
        String warFilePath = "/datablocks/DLM.war"; // 삭제할 파일 경로
        ProcessBuilder deleteBuilder = new ProcessBuilder("/usr/bin/sudo", "rm", "-f", warFilePath);

        try {
            Process deleteProcess = deleteBuilder.start();
            int deleteExitCode = deleteProcess.waitFor();
            logger.warn("Delete Process exited with code: " + deleteExitCode);

            // 명령어 실행 결과 읽기 (try-with-resources 적용)
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(deleteProcess.getInputStream(), "UTF-8"))) {

                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
                logger.warn("Command Output: " + output.toString());
            }
        } catch (IOException | InterruptedException e) {
            logger.error("Error executing delete command", e);
        }

        return output.toString();
    }

    @ResponseBody
    @RequestMapping(value = "deploy", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String deploy(@RequestBody CommandVO commandvo) {
        StringBuilder output = new StringBuilder();
        logger.info("info$ " + "Starting deployment process...");

        // 1️⃣ 디렉토리 이동 및 스크립트 실행
        String directoryPath = "/opt/tomcat/apache-tomcat-9.0.68/webapps/DLM"; // 이동할 디렉토리
        String scriptPath = "./dlmdeploy.sh"; // 실행할 스크립트

        // 명령어 설정 (cd와 스크립트 실행을 한 번에 처리)
        ProcessBuilder deployBuilder = new ProcessBuilder("/usr/bin/sudo", "sh", "-c", "cd " + directoryPath + " && " + scriptPath);

        try {
            Process deployProcess = deployBuilder.start();
            int deployExitCode = deployProcess.waitFor();
            logger.warn("Deploy Process exited with code: " + deployExitCode);

            // 명령어 실행 결과 읽기 (try-with-resources 적용)
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(deployProcess.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
                logger.warn("Deploy Output: " + output.toString());
            }
        } catch (IOException | InterruptedException e) {
            logger.error("Error executing deploy command", e);
        }

        return output.toString();
    }

    @GetMapping("/terminal")
    @PreAuthorize("isAuthenticated()")
    public void terminal(Criteria cri, Model model) {
        LogUtil.log("INFO", "terminal   cri: " + cri);
        //cri.setSearch1("D:\\Datablocks\\workspace-DLM\\DLM\\src\\main\\webapp\\WEB-INF\\log");

    }

    @ResponseBody
    @RequestMapping(value = "executejschcommand", produces = "application/text;charset=UTF-8", method = RequestMethod.POST)
    @PreAuthorize("isAuthenticated()")
    public String executejschcommand(@RequestBody CommandJschVO commandvo) {
        StringBuilder output = new StringBuilder();

        try {
            JSch jsch = new JSch();
            Session session = jsch.getSession(commandvo.getUsername(), commandvo.getHost(), commandvo.getPort());
            session.setPassword(commandvo.getPassword());

            // 보안 호스트 키 확인 방지
            session.setConfig("StrictHostKeyChecking", "no");

            session.connect();

            ChannelExec channelExec = (ChannelExec) session.openChannel("exec");
            String commandToExecute = "echo '" + commandvo.getRootPassword() + "' | su -c 'cd " + commandvo.getDirectory() + " && " + commandvo.getCommand() + "'";
            channelExec.setCommand(commandToExecute);

            BufferedReader reader = new BufferedReader(new InputStreamReader(channelExec.getInputStream(), "UTF-8"));
            channelExec.connect();

            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }

            channelExec.disconnect();
            session.disconnect();
        } catch (Exception e) {
            output.append("Error: ").append(e.getMessage());
        }

        return output.toString();
    }
}
