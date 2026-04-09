package datablocks.dlm.agent;

import datablocks.dlm.agent.analyzer.PiiPolicyCache;
import datablocks.dlm.agent.buffer.LogBuffer;
import datablocks.dlm.agent.context.UserContextFilter;
import datablocks.dlm.agent.interceptor.PreparedStatementInterceptor;
import datablocks.dlm.agent.interceptor.StatementInterceptor;
import datablocks.dlm.agent.shipper.LogShipper;
import net.bytebuddy.agent.builder.AgentBuilder;

import java.lang.instrument.Instrumentation;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;

import static net.bytebuddy.matcher.ElementMatchers.*;

/**
 * DLM Agent 진입점.
 * JVM -javaagent 옵션으로 로드되어 JDBC 호출을 투명하게 가로챔.
 *
 * 사용법:
 *   -javaagent:/path/to/dlm-agent.jar=/path/to/dlm-agent.properties
 */
public class DlmAgentMain {

    public static void premain(String agentArgs, Instrumentation inst) {
        try {
            System.out.println("[DLM-Agent] ========================================");
            System.out.println("[DLM-Agent] DLM Access Log Agent v1.0.0 starting...");
            System.out.println("[DLM-Agent] ========================================");

            // 1. 설정 로드
            AgentConfig config = AgentConfig.load(agentArgs);
            System.out.println("[DLM-Agent] Config loaded: serverUrl=" + config.getServerUrl()
                    + ", agentId=" + config.getAgentId());

            // 2. PII 정책 캐시 초기화 (데몬 스레드로 주기적 동기화)
            PiiPolicyCache.getInstance().init(config);

            // 3. 로그 버퍼 초기화
            LogBuffer.getInstance().init(config);

            // 4. 전송 + Heartbeat 데몬 스레드 시작
            LogShipper.getInstance().start(config);

            // 5. ByteBuddy 인스트루멘테이션 설치
            installInstrumentation(inst);

            // 6. Servlet Filter 자동 등록 (WAS 시작 후 감지)
            inst.addTransformer(new UserContextFilter.Installer(), true);

            System.out.println("[DLM-Agent] Agent successfully installed.");
            System.out.println("[DLM-Agent] ========================================");

        } catch (Throwable t) {
            System.err.println("[DLM-Agent] FATAL: Agent initialization failed!");
            t.printStackTrace(System.err);
            // Agent 실패 시에도 WAS는 정상 기동되어야 함
        }
    }

    private static void installInstrumentation(Instrumentation inst) {
        AgentBuilder builder = new AgentBuilder.Default()
                .with(AgentBuilder.RedefinitionStrategy.RETRANSFORMATION)
                .with(new AgentBuilder.Listener.StreamWriting(System.out)
                        .withErrorsOnly())
                .ignore(nameStartsWith("datablocks.dlm.agent")
                        .or(nameStartsWith("datablocks.shadow"))
                        .or(nameStartsWith("net.bytebuddy")));

        // Statement.execute*(String sql) 가로채기
        builder = builder.type(
                isSubTypeOf(Statement.class)
                        .and(not(isSubTypeOf(PreparedStatement.class)))
                        .and(not(isInterface()))
                        .and(not(nameStartsWith("datablocks")))
        ).transform(new StatementInterceptor.Transformer());

        // Connection.prepareStatement(sql) 가로채기 — SQL 등록
        builder = builder.type(
                isSubTypeOf(Connection.class)
                        .and(not(isInterface()))
                        .and(not(nameStartsWith("datablocks")))
        ).transform(new PreparedStatementInterceptor.ConnectionTransformer());

        // PreparedStatement.execute*() 가로채기 — 로그 생성
        builder = builder.type(
                isSubTypeOf(PreparedStatement.class)
                        .and(not(isInterface()))
                        .and(not(nameStartsWith("datablocks")))
        ).transform(new PreparedStatementInterceptor.Transformer());

        builder.installOn(inst);

        System.out.println("[DLM-Agent] ByteBuddy instrumentation installed.");
    }
}
