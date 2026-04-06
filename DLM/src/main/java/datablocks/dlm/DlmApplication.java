package datablocks.dlm;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.PiiConfigVO;
import datablocks.dlm.mapper.PiiConfigMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.util.List;
import java.util.Locale;

@MapperScan(value="datablocks.dlm.mapper")
@SpringBootApplication
@EnableScheduling
public class DlmApplication implements CommandLineRunner {
    private static final Logger logger = LoggerFactory.getLogger(DlmApplication.class);
    @Autowired
    private PiiConfigMapper configMapper;

    public static void main(String[] args) {
        Locale.setDefault(Locale.KOREA);
        SpringApplication.run(DlmApplication.class, args);

    }

    public void run(String... args) throws Exception {
        initializeCompanyCode();
    }

    private void initializeCompanyCode() {
        try {
            List<PiiConfigVO> configList = configMapper.getList();

            for (PiiConfigVO config : configList) {
                String key = config.getCfgkey().trim();
                String value = config.getValue().trim();
                EnvConfig.setConfig(key, value);
                //LogUtil.log("INFO", "Initialized config: {} = {}", key, value);
            }

            logger.warn("INFO "+"successfully initialize code: " + EnvConfig.getConfig("SITE"));
        } catch (Exception e) {
            logger.warn("WARN "+"Failed to initialize code: " + e.getMessage());
            // 여기에 적절한 에러 처리 로직 추가
        }
    }

}
