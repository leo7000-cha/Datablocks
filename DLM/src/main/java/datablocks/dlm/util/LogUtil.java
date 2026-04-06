package datablocks.dlm.util;

import datablocks.dlm.config.EnvConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LogUtil {
    private static final Logger logger = LoggerFactory.getLogger(LogUtil.class);

    public static void log(String level, String message, Object... args) {
        String logLevel = EnvConfig.getConfig("LOG_LEVEL").toUpperCase();
        String levelUpper = level.toUpperCase();
        boolean shouldLog = false;

        // 원본 코드의 논리: 설정 레벨이 가장 포괄적일 때부터 확인

        // 1. 설정 레벨이 ERROR일 때: 모든 4개 레벨(DEBUG, WARN, INFO, ERROR) 허용
        if ("ERROR".equals(logLevel)) {
            shouldLog = true; // 가장 포괄적이므로 단순 true
        }
        // 2. 설정 레벨이 DEBUG일 때: DEBUG, WARN, INFO 허용
        else if ("DEBUG".equals(logLevel)) {
            shouldLog = "DEBUG".equals(levelUpper) || "INFO".equals(levelUpper) || "WARN".equals(levelUpper);
        }
        // 3. 설정 레벨이 INFO일 때: INFO, WARN 허용
        else if ("INFO".equals(logLevel)) {
            shouldLog = "INFO".equals(levelUpper) || "WARN".equals(levelUpper);
        }
        // 4. 설정 레벨이 WARN일 때: WARN만 허용
        else if ("WARN".equals(logLevel)) {
            shouldLog = "WARN".equals(levelUpper);
        }

        if (!shouldLog) return;

        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        StackTraceElement caller = stackTrace.length > 2 ? stackTrace[2] : null;

        String file = caller != null ? caller.getFileName() : "unknown";
        int line = caller != null ? caller.getLineNumber() : -1;
        String formattedMessage = (args == null || args.length == 0) ? message : String.format(message, args);
        String fullMessage = String.format("[%s:%d] %s", file, line, formattedMessage);

        logger.warn(fullMessage);
    }
}
