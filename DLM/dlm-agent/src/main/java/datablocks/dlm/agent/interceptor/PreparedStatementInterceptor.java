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
import java.sql.PreparedStatement;
import java.util.Collections;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

/**
 * PreparedStatement SQL 추출.
 * PreparedStatement는 생성 시점에 SQL을 받으므로 2단계 인터셉트:
 * 1) Connection.prepareStatement(sql) → SQL을 WeakHashMap에 등록
 * 2) PreparedStatement.execute*() → WeakHashMap에서 SQL 조회 후 로그 생성
 */
public class PreparedStatementInterceptor {

    // PreparedStatement 인스턴스 → SQL 매핑 (WeakHashMap으로 GC 친화적)
    static final Map<Object, String> SQL_REGISTRY =
            Collections.synchronizedMap(new WeakHashMap<>(256));

    /**
     * Connection.prepareStatement() 가로채기 — SQL 등록
     */
    public static class ConnectionTransformer implements AgentBuilder.Transformer {
        @Override
        public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder,
                                                 TypeDescription typeDescription,
                                                 ClassLoader classLoader,
                                                 JavaModule module,
                                                 ProtectionDomain protectionDomain) {
            return builder.visit(
                    Advice.to(PrepareAdvice.class)
                            .on(ElementMatchers.named("prepareStatement")
                                    .and(ElementMatchers.takesArgument(0, String.class))
                                    .and(ElementMatchers.returns(ElementMatchers.isSubTypeOf(PreparedStatement.class))))
            );
        }
    }

    /**
     * PreparedStatement.execute*() 가로채기 — 로그 생성
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
                                    .and(ElementMatchers.takesNoArguments()))
            ).visit(
                    Advice.to(ExecuteAdvice.class)
                            .on(ElementMatchers.named("executeQuery")
                                    .and(ElementMatchers.takesNoArguments()))
            ).visit(
                    Advice.to(ExecuteAdvice.class)
                            .on(ElementMatchers.named("executeUpdate")
                                    .and(ElementMatchers.takesNoArguments()))
            );
        }
    }

    /**
     * Connection.prepareStatement(sql) 종료 시점 — 반환된 PreparedStatement에 SQL 태깅
     */
    public static class PrepareAdvice {

        @Advice.OnMethodExit
        public static void onExit(
                @Advice.Argument(0) String sql,
                @Advice.Return Object preparedStatement) {
            try {
                if (sql != null && preparedStatement != null) {
                    SQL_REGISTRY.put(preparedStatement, sql);
                }
            } catch (Throwable ignored) {}
        }
    }

    /**
     * PreparedStatement.execute*() 진입/종료 시점
     */
    public static class ExecuteAdvice {

        @Advice.OnMethodEnter
        public static long onEnter() {
            return System.nanoTime();
        }

        @Advice.OnMethodExit(onThrowable = Throwable.class)
        public static void onExit(
                @Advice.This Object self,
                @Advice.Enter long startTime,
                @Advice.Thrown Throwable thrown) {

            try {
                String sql = SQL_REGISTRY.get(self);
                if (sql == null || sql.isEmpty()) return;

                // 시스템 SQL 필터링
                AgentConfig config = AgentConfig.getInstance();
                if (config != null) {
                    String upper = sql.trim().toUpperCase();
                    Set<String> patterns = config.getExcludeSqlPatterns();
                    for (String pattern : patterns) {
                        if (upper.startsWith(pattern)) return;
                    }
                }

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

                // PII 분석
                SqlAnalyzer.enrichPiiInfo(entry);

                // 비동기 버퍼에 추가
                LogBuffer.getInstance().offer(entry);
            } catch (Throwable ignored) {
                // Agent 오류가 WAS에 영향 주지 않도록 전부 삼킴
            }
        }
    }
}
