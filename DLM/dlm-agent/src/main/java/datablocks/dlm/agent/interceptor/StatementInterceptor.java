package datablocks.dlm.agent.interceptor;

import datablocks.dlm.agent.AgentConfig;
import datablocks.dlm.agent.analyzer.SqlAnalyzer;
import datablocks.dlm.agent.buffer.LogBuffer;
import datablocks.dlm.agent.context.UserContext;
import datablocks.dlm.agent.model.AccessLogEntry;
import net.bytebuddy.agent.builder.AgentBuilder;
import net.bytebuddy.asm.Advice;
import net.bytebuddy.description.type.TypeDescription;
import net.bytebuddy.dynamic.DynamicType;
import net.bytebuddy.matcher.ElementMatchers;
import net.bytebuddy.utility.JavaModule;

import java.security.ProtectionDomain;
import java.util.Set;

/**
 * Statement.execute*() 메서드를 ByteBuddy Advice로 가로채기.
 * SQL 텍스트 + 실행시간 + 사용자 정보를 캡처하여 LogBuffer에 추가.
 */
public class StatementInterceptor {

    /**
     * AgentBuilder.Transformer — Statement 하위 클래스에 Advice 적용
     */
    public static class Transformer implements AgentBuilder.Transformer {
        @Override
        public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder,
                                                 TypeDescription typeDescription,
                                                 ClassLoader classLoader,
                                                 JavaModule module,
                                                 ProtectionDomain protectionDomain) {
            return builder.visit(
                    Advice.to(ExecuteAdvice.class)
                            .on(ElementMatchers.named("execute")
                                    .and(ElementMatchers.takesArgument(0, String.class)))
            ).visit(
                    Advice.to(ExecuteAdvice.class)
                            .on(ElementMatchers.named("executeQuery")
                                    .and(ElementMatchers.takesArgument(0, String.class)))
            ).visit(
                    Advice.to(ExecuteAdvice.class)
                            .on(ElementMatchers.named("executeUpdate")
                                    .and(ElementMatchers.takesArgument(0, String.class)))
            );
        }
    }

    /**
     * Advice — Statement.execute*(String sql) 진입/종료 시점 가로채기
     */
    public static class ExecuteAdvice {

        @Advice.OnMethodEnter
        public static long onEnter() {
            return System.nanoTime();
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(
                @Advice.Argument(0) String sql,
                @Advice.Enter long startTime,
                @Advice.Thrown Throwable thrown) {

            try {
                if (sql == null || sql.isEmpty()) return;

                // 시스템 SQL 필터링
                AgentConfig config = AgentConfig.getInstance();
                if (config != null && shouldExclude(sql, config)) return;

                long elapsed = (System.nanoTime() - startTime) / 1_000_000; // ms

                UserContext ctx = UserContext.current();

                // 사용자 필터링
                if (config != null && ctx != null && ctx.getUserId() != null) {
                    if (config.getExcludeUsers().contains(ctx.getUserId().toUpperCase())) return;
                }

                AccessLogEntry entry = new AccessLogEntry();
                entry.setSql(sql);
                entry.setUserId(ctx != null ? ctx.getUserId() : "UNKNOWN");
                entry.setUserName(ctx != null ? ctx.getUserName() : null);
                entry.setClientIp(ctx != null ? ctx.getClientIp() : null);
                entry.setSessionId(ctx != null ? ctx.getSessionId() : null);
                entry.setElapsedMs(elapsed);
                entry.setTimestamp(System.currentTimeMillis());
                entry.setSuccess(thrown == null);
                entry.setActionType(SqlAnalyzer.detectActionType(sql));

                // PII 분석 (경량)
                SqlAnalyzer.enrichPiiInfo(entry);

                // 비동기 버퍼에 추가 (논블로킹)
                LogBuffer.getInstance().offer(entry);
            } catch (Throwable t) {
                // Agent 오류가 WAS에 영향 주지 않도록 전부 삼킴
            }
        }

        private static boolean shouldExclude(String sql, AgentConfig config) {
            String upper = sql.trim().toUpperCase();
            Set<String> patterns = config.getExcludeSqlPatterns();
            for (String pattern : patterns) {
                if (upper.startsWith(pattern)) return true;
            }
            return false;
        }
    }
}
