package datablocks.dlm.config;

import datablocks.dlm.mapper.PiiConfigMapper;
import org.springframework.stereotype.Component;
import java.util.concurrent.ConcurrentHashMap;

public class EnvConfig {

    private static final ConcurrentHashMap<String, String> configMap = new ConcurrentHashMap<>();

    public static void setConfig(String key, String value) {
        configMap.put(key, value);
    }

    public static String getConfig(String key) {
        return configMap.getOrDefault(key, "");
    }

    public static boolean hasConfig(String key) {
        return configMap.containsKey(key);
    }

    public static void removeConfig(String key) {
        configMap.remove(key);
    }

    public static void clearAllConfigs() {
        configMap.clear();
    }
}
