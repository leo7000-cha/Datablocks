# DLM 접속기록 수집 3가지 방식 설계서

> 작성일: 2026-04-17  
> 목적: 금융사 환경별 수용 가능한 접속기록 수집 방식 제안

---

## 1. 개요

금융사마다 WAS 환경, 보안 정책, 개발 역량이 다르므로, 단일 방식으로는 시장 전체를 커버할 수 없다.  
DLM은 **3가지 수집 방식**을 제공하여 고객사가 자사 환경에 맞는 방식을 선택할 수 있도록 한다.

```
수용 난이도 (금융사 기준)

A. Java Agent (BCI)    ████████████░  어려움 (WAS JVM 개입)
B. Servlet Filter      █████████░░░  중간   (WAS 설정 변경)
C. 로그 수집            ████░░░░░░░░  쉬움   (파일 읽기만)
```

### 공통 아키텍처

어떤 방식이든 **DLM 서버의 수신 측은 동일**하다.

```
[고객사 WAS]                         [DLM 서버]
                                     
 A. Agent   ─┐                       POST /api/agent/logs
 B. Filter  ─┼─ JSON 로그 ────────→  AgentApiController
 C. Collector┘                        ↓
                                     AccessLogService
                                      ↓
                                     TBL_ACCESS_LOG (해시체인)
```

세 방식 모두 최종적으로 `POST /api/agent/logs`로 동일한 JSON 형식의 접속기록을 전송한다.

---

## 2. 방식 A: Java Agent (BCI) — 이미 구현됨

### 2.1 개요

| 항목 | 내용 |
|------|------|
| **구현 상태** | 완료 (dlm-agent 서브프로젝트) |
| **기술** | ByteBuddy BCI, JVM -javaagent |
| **설치 위치** | 고객사 WAS의 JVM 옵션 |
| **수집 레벨** | JDBC (모든 SQL 자동 캡처) |
| **고객사 개발 필요** | 없음 |
| **금융사 수용도** | 낮음 (~10%) |

### 2.2 동작 원리

```
[고객사 WAS - JVM 내부]

  HTTP 요청 → FilterChain.doFilter()
                    ↓ (ByteBuddy가 가로챔)
              UserContextFilter: 세션에서 사용자ID 추출
                    ↓ (ThreadLocal에 저장)
              
  업무 로직 → PreparedStatement.execute()
                    ↓ (ByteBuddy가 가로챔)  
              PreparedStatementInterceptor:
                - SQL 텍스트 캡처
                - UserContext에서 사용자 매핑
                - PII 컬럼 분석 (SqlAnalyzer)
                - AccessLogEntry 생성
                    ↓
              LogBuffer (비동기 큐, 10,000건)
                    ↓ (3초마다 배치 전송)
              LogShipper → POST /api/agent/logs
```

### 2.3 설치 방법

```bash
# 1. dlm-agent.jar를 고객사 WAS 서버에 배포
scp dlm-agent-1.0.0.jar target-server:/opt/dlm/

# 2. dlm-agent.properties 설정
cat > /opt/dlm/dlm-agent.properties << 'EOF'
dlm.server.url=https://dlm-server:8443
dlm.agent.id=BANK-WAS-01
dlm.agent.secret=xxxxx
dlm.user.session-attr=loginVO.id
dlm.user.header=X-User-Id
EOF

# 3. WAS JVM 옵션 추가 (Tomcat 예시: setenv.sh)
CATALINA_OPTS="$CATALINA_OPTS -javaagent:/opt/dlm/dlm-agent-1.0.0.jar=/opt/dlm/dlm-agent.properties"

# 4. WAS 재시작
```

### 2.4 수집 데이터 예시

```json
{
  "sql": "SELECT name, ssn, phone FROM TB_CUSTOMER WHERE cust_id = ?",
  "userId": "kim.ms",
  "userName": "김민석",
  "clientIp": "10.0.5.33",
  "sessionId": "ABC123",
  "elapsedMs": 12,
  "success": true,
  "actionType": "SELECT",
  "targetTable": "TB_CUSTOMER",
  "targetColumns": "name,ssn,phone",
  "piiTypeCodes": "NAME,SSN,PHONE",
  "piiGrade": "HIGH",
  "agentId": "BANK-WAS-01",
  "timestamp": "2026-04-17T09:31:22.456"
}
```

### 2.5 장단점

```
장점:
  + 고객사 개발 공수 제로
  + 모든 SQL 자동 캡처 (누락 없음)
  + 사용자-SQL 완벽 매핑
  + PII 컬럼 자동 분석
  
단점:
  - WAS JVM에 직접 개입 → 금융사 보안팀 거부감
  - JVM/WAS 버전 호환성 테스트 필요
  - Agent 버그 시 WAS 장애 가능성 (이론적)
  - 클래스로딩 충돌 위험 (다른 Agent와)
```

### 2.6 적합한 고객

- 개발 인력이 부족한 중소 금융사
- 신규 시스템 구축 시 (검증 기간 충분)
- 정보계/비핵심 시스템 (계정계 제외)
- 보안팀이 Agent 설치를 허용하는 조직

---

## 3. 방식 B: Servlet Filter — 신규 개발 필요

### 3.1 개요

| 항목 | 내용 |
|------|------|
| **구현 상태** | 미구현 (신규 개발 필요) |
| **기술** | 표준 Servlet Filter (javax/jakarta) |
| **설치 위치** | 고객사 WAS의 web.xml 또는 WAR 내 JAR |
| **수집 레벨** | HTTP 요청/응답 (업무 단위) |
| **고객사 개발 필요** | 없음 (JAR + 설정만) |
| **금융사 수용도** | 중간 (~50%) |

### 3.2 동작 원리

```
[고객사 WAS 내부]

  HTTP 요청 ─────────────────────────────────┐
       ↓                                      │
  ┌──────────────────────────────────┐        │
  │ DlmAccessFilter (Servlet Filter) │        │
  │                                  │        │
  │ 1. 요청 정보 추출                 │        │
  │    - 사용자ID (세션/헤더)          │        │
  │    - 클라이언트IP                  │        │
  │    - 요청 URL + 파라미터           │        │
  │                                  │        │
  │ 2. chain.doFilter() 호출 ─────────────→ [업무 로직] → [DB]
  │                                  │        │
  │ 3. 응답 완료 후 로그 생성          │ ←──────┘
  │    - 응답 코드                     │
  │    - 처리 시간                     │
  │                                  │
  │ 4. 비동기 큐에 적재 → 전송         │
  └──────────────────────────────────┘
```

**핵심 차이**: Agent(A)는 SQL을 캡처하지만, Filter(B)는 **HTTP 요청 단위**로 캡처한다.

### 3.3 구현 설계

#### 배포물 구성

```
dlm-filter-1.0.0.jar          ← 고객사 WAS의 WEB-INF/lib에 배포
dlm-filter.properties         ← 설정 파일
```

#### 핵심 클래스

```java
/**
 * DLM 접속기록 수집 Servlet Filter.
 * 고객사 WAS의 web.xml에 등록하여 사용.
 * WAS 표준 확장 포인트만 사용 — JVM/바이트코드 개입 없음.
 */
public class DlmAccessFilter implements javax.servlet.Filter {

    private AsyncLogQueue queue;
    private LogTransmitter transmitter;
    private FilterConfig filterConfig;

    @Override
    public void init(FilterConfig config) {
        // dlm-filter.properties 로드
        this.filterConfig = loadConfig(config);
        this.queue = new AsyncLogQueue(10000);
        this.transmitter = new LogTransmitter(filterConfig);
        this.transmitter.startDaemon();  // 비동기 전송 스레드
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, 
                          FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest httpReq = (HttpServletRequest) req;
        HttpServletResponse httpRes = (HttpServletResponse) res;
        
        // ── URL 패턴 필터링 (감사 대상만) ──
        String uri = httpReq.getRequestURI();
        if (!isAuditTarget(uri)) {
            chain.doFilter(req, res);  // 감사 대상 아니면 그냥 통과
            return;
        }
        
        long startTime = System.currentTimeMillis();
        
        try {
            // ── 원래 업무 로직 실행 ──
            chain.doFilter(req, res);
            
        } finally {
            // ── 접속기록 생성 (업무 로직 완료 후) ──
            long elapsed = System.currentTimeMillis() - startTime;
            
            AccessRecord record = AccessRecord.builder()
                .userId(extractUserId(httpReq))         // 세션/헤더에서 추출
                .clientIp(extractClientIp(httpReq))      // X-Forwarded-For 등
                .uri(uri)
                .httpMethod(httpReq.getMethod())
                .params(sanitizeParams(httpReq))         // 민감정보 마스킹
                .responseStatus(httpRes.getStatus())
                .elapsedMs(elapsed)
                .timestamp(Instant.now())
                .build();
            
            queue.offer(record);  // 비동기 큐에 넣기 (non-blocking)
        }
    }

    /**
     * 사용자 ID 추출 우선순위:
     * 1. 설정된 HTTP 헤더 (예: X-User-Id)
     * 2. 세션 속성 (예: loginVO.id)
     * 3. Spring Security Principal
     * 4. UNKNOWN
     */
    private String extractUserId(HttpServletRequest req) {
        // ... Agent의 UserContextFilter와 동일한 로직
    }
}
```

#### 고객사 설치 방법

```xml
<!-- 방법 1: web.xml에 추가 (소스코드 수정 없음) -->
<filter>
    <filter-name>dlmAccessFilter</filter-name>
    <filter-class>datablocks.dlm.filter.DlmAccessFilter</filter-class>
    <init-param>
        <param-name>configPath</param-name>
        <param-value>/opt/dlm/dlm-filter.properties</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>dlmAccessFilter</filter-name>
    <url-pattern>/customer/*</url-pattern>    <!-- 개인정보 조회 URL만 -->
    <url-pattern>/account/*</url-pattern>
    <url-pattern>/loan/*</url-pattern>
</filter-mapping>
```

```properties
# dlm-filter.properties
dlm.server.url=https://dlm-server:8443
dlm.agent.id=BANK-WAS-01
dlm.agent.secret=xxxxx
dlm.user.session-attr=loginVO.id
dlm.user.header=X-User-Id
dlm.audit.url-patterns=/customer/*,/account/*,/loan/*
dlm.exclude.url-patterns=/css/*,/js/*,/images/*,/health
dlm.queue.capacity=10000
dlm.transmit.interval-ms=3000
dlm.transmit.batch-size=100
```

### 3.4 수집 데이터 예시

```json
{
  "userId": "kim.ms",
  "clientIp": "10.0.5.33",
  "uri": "/customer/search",
  "httpMethod": "POST",
  "params": {"name": "홍길동", "birthDate": "1990****"},
  "responseStatus": 200,
  "elapsedMs": 45,
  "agentId": "BANK-WAS-01",
  "collectType": "WAS_FILTER",
  "timestamp": "2026-04-17T09:31:22.456"
}
```

**주의**: SQL 텍스트는 캡처하지 못함. URL + 파라미터로 "어떤 업무를 했는가"만 기록.

### 3.5 A방식(Agent) vs B방식(Filter) 수집 범위 비교

```
[같은 요청에 대해]

사용자가 "고객 검색" 버튼 클릭

A방식 (Agent - SQL 레벨):
  → SELECT c.name, c.ssn FROM TB_CUSTOMER c WHERE c.name LIKE '%홍길동%'
  → SELECT a.acct_no FROM TB_ACCOUNT a WHERE a.cust_id = 12345
  → SELECT t.txn_date FROM TB_TRANSACTION t WHERE t.acct_no = '110-xxx'
  (SQL 3건 기록, 테이블/컬럼 정확히 식별)

B방식 (Filter - HTTP 레벨):
  → POST /customer/search {name: "홍길동"}
  (HTTP 1건 기록, 실제 어떤 테이블에 접근했는지는 모름)
```

### 3.6 장단점

```
장점:
  + 소스코드 수정 없음 (JAR 배포 + web.xml 설정)
  + WAS 표준 확장 포인트 (Servlet Filter) → 보안팀 수용 쉬움
  + JVM 바이트코드 개입 없음 → 안정성 높음
  + WAS 종류/Java 버전에 덜 민감
  
단점:
  - SQL 텍스트를 캡처하지 못함
  - 어떤 테이블/컬럼에 접근했는지 직접 알 수 없음
  - URL과 테이블의 매핑을 별도 관리해야 함
  - 내부 API 호출(서비스간 통신)은 캡처 어려움
```

### 3.7 적합한 고객

- Agent(A) 설치를 거부하지만 개발 공수도 투입 어려운 조직
- URL 기반으로 "누가 어떤 업무 화면을 조회했는가" 수준이면 충분한 경우
- 기존 DB접근제어(DBSAFER 등)와 병행하여 사용자 식별만 보완하는 경우

---

## 4. 방식 C: 로그 수집 (Log Collector)

### 4.1 개요

| 항목 | 내용 |
|------|------|
| **구현 상태** | 미구현 (Collector 신규 개발 필요) |
| **기술** | 로그 파일 tail + 전송 |
| **설치 위치** | 고객사 WAS 서버에 Collector 프로세스 |
| **수집 레벨** | 고객사가 로그에 남긴 만큼 |
| **고객사 개발 필요** | 있음 (로그 출력 코드 추가) |
| **금융사 수용도** | 높음 (~80%) |

### 4.2 "개발이 필요하다"는 게 뭔 뜻인가?

#### 핵심: "로그 줄 추가"가 맞지만, 그 줄을 고객사 개발팀이 넣어야 한다

```
Q: 그냥 로그 쌓는 줄 추가하면 되는 거 아니야?
A: 맞다. 하지만 "누구의" "어느 소스에" 추가하느냐가 문제다.

DLM 솔루션 입장:  우리가 고객사 소스를 수정할 수 없다
고객사 입장:       우리 개발자가 공통 모듈에 한 줄 넣으면 된다
```

#### 고객사가 해야 하는 일 (전부)

```java
// ============================================================
// 고객사 소스코드에서 추가할 부분 — 이것뿐이다
// ============================================================

// 이미 있는 고객 조회 서비스
@Service
public class CustomerService {
    
    // 이미 있는 로거
    private static final Logger log = LoggerFactory.getLogger(CustomerService.class);
    
    // ★ 이 로거 한 줄 추가 ★
    private static final Logger auditLog = LoggerFactory.getLogger("DLM_AUDIT");
    
    // 이미 있는 메서드
    public CustomerDTO searchCustomer(String name, LoginUser user) {
        
        // ★ 이 한 줄 추가 ★
        auditLog.info("{}", AuditLog.of(user, "CUSTOMER_SEARCH", "TB_CUSTOMER", name));
        
        // 기존 코드 그대로
        return customerMapper.searchByName(name);
    }
    
    public CustomerDTO getCustomerDetail(Long custId, LoginUser user) {
        
        // ★ 이 한 줄 추가 ★  
        auditLog.info("{}", AuditLog.of(user, "CUSTOMER_DETAIL", "TB_CUSTOMER", custId));
        
        return customerMapper.selectById(custId);
    }
}
```

#### "한 줄"이 아니라 "여러 군데에 한 줄씩"

```
고객사 시스템에 개인정보 조회 메서드가 50개 있다면?
→ 50군데에 auditLog.info() 한 줄씩 추가

고객사 시스템이 10개라면?
→ 10개 시스템 × 50군데 = 500군데에 추가

이게 "개발 공수"다.
```

#### 하지만 공통화하면 훨씬 줄어든다

```java
// ============================================================
// 방법 1: Spring AOP로 공통화 (가장 깔끔)
// ============================================================
// 고객사 개발팀이 AOP 클래스 1개만 만들면 끝

@Aspect
@Component
public class DlmAuditAspect {
    
    private static final Logger auditLog = LoggerFactory.getLogger("DLM_AUDIT");
    
    // 개인정보 조회 서비스에만 적용
    @AfterReturning("execution(* com.bank.service.Customer*.*(..))" +
                    " || execution(* com.bank.service.Account*.*(..))" +
                    " || execution(* com.bank.service.Loan*.*(..))")
    public void auditLog(JoinPoint jp) {
        
        // 현재 로그인 사용자 (Spring Security 등)
        String userId = SecurityContextHolder.getContext()
                          .getAuthentication().getName();
        
        // 메서드명에서 업무 유형 추출
        String action = jp.getSignature().getName();  // "searchCustomer"
        String target = jp.getTarget().getClass().getSimpleName();  // "CustomerService"
        
        auditLog.info("{}|{}|{}|{}|{}", 
            userId,
            RequestContextHolder.getRequestAttributes() != null ? 
                ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes())
                    .getRequest().getRemoteAddr() : "N/A",
            action,
            target,
            Arrays.toString(jp.getArgs())  // 조회 조건
        );
    }
}

// → 이 클래스 1개 추가하면 Customer/Account/Loan 서비스의
//   모든 메서드가 자동으로 감사 로그에 기록됨
```

```java
// ============================================================
// 방법 2: Spring Interceptor로 공통화 (URL 기반)
// ============================================================
// Filter(B방식)와 비슷하지만, 고객사 소스에 들어감

@Component
public class DlmAuditInterceptor implements HandlerInterceptor {
    
    private static final Logger auditLog = LoggerFactory.getLogger("DLM_AUDIT");
    
    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res,
                                 Object handler, Exception ex) {
        
        String userId = getUserId(req);
        String uri = req.getRequestURI();
        
        // 개인정보 관련 URL만 기록
        if (isAuditTarget(uri)) {
            auditLog.info("{}|{}|{}|{}|{}|{}", 
                userId,
                getClientIp(req),
                req.getMethod(),
                uri,
                sanitize(req.getParameterMap()),
                res.getStatus()
            );
        }
    }
}
```

```xml
<!-- ============================================================ -->
<!-- 방법 3: MyBatis Interceptor (SQL 레벨 — A방식에 가장 가까움)  -->
<!-- ============================================================ -->
<!-- 고객사가 MyBatis 쓰면 이 방법이 가장 정밀 -->

@Intercepts({
    @Signature(type = Executor.class, method = "query", args = {...}),
    @Signature(type = Executor.class, method = "update", args = {...})
})
public class DlmMybatisAuditPlugin implements Interceptor {
    
    private static final Logger auditLog = LoggerFactory.getLogger("DLM_AUDIT");
    
    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        // SQL 추출
        MappedStatement ms = (MappedStatement) invocation.getArgs()[0];
        BoundSql boundSql = ms.getBoundSql(invocation.getArgs()[1]);
        String sql = boundSql.getSql();
        
        // 실행
        Object result = invocation.proceed();
        
        // 감사 로그
        auditLog.info("{}|{}|{}", getUserId(), ms.getId(), sql);
        
        return result;
    }
}
```

### 4.3 로그 형식 규격 (DLM이 제공하는 표준)

DLM이 파싱할 수 있도록 JSON 형식을 표준으로 정의한다.

```
# /logs/app/dlm-audit.log (고객사 WAS에 쌓이는 파일)

{"ts":"2026-04-17T09:31:22.456","user":"kim.ms","ip":"10.0.5.33","action":"CUSTOMER_SEARCH","target":"TB_CUSTOMER","params":{"name":"홍길동"},"result":"OK"}
{"ts":"2026-04-17T09:31:25.123","user":"park.jh","ip":"10.0.5.41","action":"ACCOUNT_DETAIL","target":"TB_ACCOUNT","params":{"acctNo":"110-***-4567"},"result":"OK"}
{"ts":"2026-04-17T09:32:01.789","user":"kim.ms","ip":"10.0.5.33","action":"CUSTOMER_DOWNLOAD","target":"TB_CUSTOMER","params":{"type":"excel","count":500},"result":"OK"}
```

#### Logback 설정 (고객사 logback.xml에 추가)

```xml
<!-- DLM 감사 로그 전용 Appender — 업무 로그와 완전 분리 -->
<appender name="DLM_AUDIT_FILE" 
          class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>/logs/app/dlm-audit.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>/logs/app/dlm-audit.%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>365</maxHistory>  <!-- 1년 보관 (개인정보보호법) -->
    </rollingPolicy>
    <encoder>
        <pattern>%msg%n</pattern>  <!-- JSON 그대로, 타임스탬프는 JSON 안에 -->
    </encoder>
</appender>

<!-- DLM_AUDIT 로거 — 업무 로거와 독립 -->
<logger name="DLM_AUDIT" level="INFO" additivity="false">
    <appender-ref ref="DLM_AUDIT_FILE" />
</logger>
```

### 4.4 DLM Collector (DLM이 개발하여 제공)

고객사 WAS 서버에서 로그 파일을 읽어 DLM 서버로 전송하는 경량 프로세스.

```
[고객사 WAS 서버]

  WAS 프로세스 (Java)
    ↓ (Logback이 파일에 기록)
  /logs/app/dlm-audit.log
    ↓ (파일시스템 — WAS와 무관한 별도 프로세스)
  ┌───────────────────────────────┐
  │  DLM Collector (별도 프로세스)  │
  │                               │
  │  1. tail -f로 신규 라인 감지    │
  │  2. JSON 파싱 + 검증           │
  │  3. 배치로 묶어서 전송          │
  │     POST /api/agent/logs      │
  │  4. 전송 완료 위치 기록         │
  │     (offset 파일)             │
  │                               │
  │  ★ WAS 프로세스와 완전 독립 ★  │
  │  ★ WAS 메모리/CPU 사용 안 함 ★ │
  └───────────────────────────────┘
    ↓ (HTTP)
  [DLM 서버]
```

#### Collector 핵심 설계

```properties
# dlm-collector.properties

# 수집 대상 로그 파일
dlm.collector.log-path=/logs/app/dlm-audit.log

# 오프셋 파일 (어디까지 읽었는지 기록 — 재시작 시 중복 방지)
dlm.collector.offset-file=/opt/dlm/collector-offset.dat

# DLM 서버 연결
dlm.server.url=https://dlm-server:8443
dlm.agent.id=BANK-WAS-01
dlm.agent.secret=xxxxx

# 전송 설정
dlm.collector.batch-size=100
dlm.collector.flush-interval-ms=5000

# 로그 로테이션 대응
dlm.collector.follow-rotation=true
```

```
Collector 동작 흐름:

  시작 → offset 파일 읽기 (마지막 읽은 위치)
    ↓
  로그 파일 열기 (offset 위치부터)
    ↓
  ┌─ 무한 루프 ─────────────────────┐
  │                                  │
  │  새 라인 있나? ── 없음 → 100ms 대기 후 재확인
  │       ↓ 있음                     │
  │  JSON 파싱                       │
  │       ↓                          │
  │  배치 버퍼에 추가                 │
  │       ↓                          │
  │  버퍼 full 또는 5초 경과?         │
  │       ↓ Yes                      │
  │  POST /api/agent/logs 전송       │
  │       ↓                          │
  │  offset 파일 업데이트             │
  │       ↓                          │
  │  로그 파일 로테이션 감지?         │
  │       ↓ Yes                      │
  │  새 파일로 전환                   │
  │                                  │
  └──────────────────────────────────┘
```

### 4.5 전체 설치 절차

```
[DLM이 제공하는 것]
  1. DLM Collector 실행 파일 (dlm-collector.jar 또는 바이너리)
  2. 로그 형식 표준 규격서 (JSON 필드 정의)
  3. 연동 가이드 (AOP/Interceptor/MyBatis Plugin 예제 코드)
  4. Logback 설정 예시

[고객사가 해야 하는 것]
  1. 공통 감사 로그 모듈 개발 (AOP 1개 또는 Interceptor 1개)
     → 개발 공수: 1~3일 (경험 있는 개발자 기준)
  2. logback.xml에 DLM_AUDIT appender 추가
     → 설정 공수: 30분
  3. 테스트 및 검증
     → 1~2일

[운영팀이 해야 하는 것]
  1. DLM Collector를 WAS 서버에 설치 (systemd 서비스 등록)
  2. /logs/app/ 디렉토리 읽기 권한 부여
  3. Collector → DLM 서버 네트워크 방화벽 오픈
```

### 4.6 WAS 부하 분석

```
[이 방식에서 WAS가 하는 추가 작업]

  auditLog.info(json)  ← 이것뿐

구체적으로:
  1. JSON 문자열 생성        → ~0.01ms (StringBuilder)
  2. Logback이 파일에 쓰기   → ~0.05ms (비동기 Appender 사용 시)
  ─────────────────────────
  합계: 요청당 ~0.06ms 추가

비교:
  A방식 (Agent):  요청당 +1~3ms  (JDBC 가로채기 + 분석)
  B방식 (Filter): 요청당 +1~3ms  (응답 버퍼링 + 분석)
  C방식 (로그):   요청당 +0.06ms (로그 한 줄 쓰기)
                  ↑
            사실상 부하 제로
```

### 4.7 장단점

```
장점:
  + WAS에 아무것도 안 심음 (Collector는 별도 프로세스)
  + WAS 부하 사실상 제로 (로그 한 줄 쓰기뿐)
  + WAS 장애와 완전 독립
  + Collector가 죽어도 로그 파일은 남아있음 (유실 없음)
  + 금융사 보안팀 수용 가장 쉬움 ("로그 파일 읽기 권한만 주세요")
  + WAS 종류/Java 버전 무관
  
단점:
  - 고객사 개발팀이 감사 로그 코드를 넣어야 함
  - 레거시 시스템이 많으면 적용 공수가 커짐
  - 개발자가 빠뜨린 메서드는 영원히 기록 안 됨
  - SQL 텍스트는 기록 안 됨 (MyBatis Plugin 쓰면 가능하지만 추가 개발)
  - 실시간성 떨어짐 (파일 쓰기→읽기→전송: 수초 지연)
```

### 4.8 적합한 고객

- WAS에 절대 아무것도 설치 불가인 금융사 (1금융권 계정계)
- 자체 개발팀이 있어서 공통 모듈 추가가 가능한 조직
- 신규 시스템 개발 시 (처음부터 감사 로그를 설계에 포함)
- DB접근제어(DBSAFER 등)와 병행하여 WAS 레벨 사용자 매핑만 보완

---

## 5. 3가지 방식 종합 비교

### 5.1 기능 비교

| 비교 항목 | A. Java Agent (BCI) | B. Servlet Filter | C. 로그 수집 |
|-----------|-------------------|-----------------|-------------|
| **수집 레벨** | SQL (JDBC) | HTTP (요청/응답) | 고객사 정의 |
| **SQL 캡처** | O (자동) | X | 추가 개발 시 가능 |
| **실사용자 식별** | O (자동) | O (자동) | O (고객사 코드) |
| **테이블/컬럼 식별** | O (자동 파싱) | X | 고객사가 명시 |
| **PII 자동 분석** | O | X | X |
| **설치 방식** | JVM 옵션 | web.xml + JAR | Collector + 고객사 개발 |
| **고객사 소스 수정** | 불필요 | 불필요 | **필요** |
| **WAS 재시작** | 필요 | 필요 | 불필요 (Collector만) |
| **WAS 프로세스 개입** | JVM 내부 | JVM 내부 | **외부** |

### 5.2 비기능 비교

| 비교 항목 | A. Java Agent | B. Servlet Filter | C. 로그 수집 |
|-----------|-------------|-----------------|-------------|
| **WAS 부하** | +1~3ms/요청 | +1~3ms/요청 | **+0.06ms/요청** |
| **안정성 리스크** | 중간 (BCI) | 낮음 (표준 API) | **거의 없음** |
| **장애 영향** | WAS와 같이 죽을 수 있음 | WAS와 같이 죽을 수 있음 | **독립** |
| **실시간성** | ~3초 (배치전송) | ~3초 (배치전송) | ~5~10초 (파일경유) |
| **데이터 정밀도** | 최고 (SQL 레벨) | 중간 (URL 레벨) | 고객사에 따라 다름 |
| **도입 공수 (DLM)** | 완료 | 2~3주 | 1~2주 |
| **도입 공수 (고객)** | 0.5일 | 0.5일 | **3~5일** |

### 5.3 금융사 유형별 추천

| 금융사 유형 | 추천 방식 | 이유 |
|------------|----------|------|
| **1금융권 계정계** | C (로그 수집) | WAS 무관용, 자체 개발팀 있음 |
| **1금융권 정보계** | B (Filter) 또는 C | 상대적으로 유연, 성능 덜 민감 |
| **2금융권/캐피탈** | B (Filter) | 개발 인력 부족, 설정만으로 적용 |
| **보험사** | A (Agent) 또는 B | 상대적으로 수용적 |
| **증권사 (트레이딩)** | C (로그 수집) | latency 극도로 민감 |
| **공공/준금융** | A (Agent) | 규제 준수 압박, 빠른 도입 필요 |
| **신규 시스템** | A + C 병행 | Agent로 정밀 + 로그로 백업 |

### 5.4 영업 제안 시나리오

```
[미팅 시 제안 순서]

1단계: "어떤 방식을 선호하시나요?"
  → 대부분 C(로그) 또는 B(Filter)를 선택

2단계: "로그 방식은 개발이 필요합니다. 저희가 가이드와 예제를 제공합니다."
  → 고객사 개발팀과 별도 미팅

3단계: "더 정밀한 분석이 필요하시면 Agent 방식도 있습니다."
  → 테스트 환경에서 검증 → 점진적 확대

4단계: "혼합 구성도 가능합니다."
  → 핵심 시스템은 C(로그), 비핵심은 A(Agent)
```

---

## 6. 금융권 영업 전략: 상대방 포지션별 제안 화법

### 6.1 핵심 원칙

금융사 프로젝트에서 통하는 유일한 정답:

> **"안정성을 해치지 않으면서(운영), 규제는 완벽히 지킨다(보안)"**

이 두 가지 명분을 동시에 줘야 한다. 하나만 충족하면 반드시 다른 쪽에서 반대한다.

### 6.2 고객사 포지션별 제안 화법

#### 운영팀 대상 (인프라/시스템 운영 담당자)

**운영팀의 최우선 관심사**: WAS 안정성, 장애 리스크, 관리 포인트 최소화

```
제안 화법:

"저희는 WAS 안정성을 위해 Agentless(로그 연동) 방식을 기본으로 하며, 
 서비스에 부하를 주지 않는 비동기 로깅 가이드를 제공합니다."
```

**뒷받침 근거**:

| 운영팀 우려 사항 | DLM 대응 | 수치 근거 |
|----------------|---------|----------|
| "WAS에 뭔가 설치하면 장애 나면?" | C방식: WAS 프로세스에 아무것도 안 심음 | Collector는 별도 프로세스, WAS와 독립 |
| "성능 영향은?" | 비동기 AsyncAppender: 큐에 넣고 즉시 리턴 | 요청당 +0.06ms (사실상 0) |
| "디스크 I/O 부하?" | Logback이 기존에 하던 로그 쓰기와 동일 | 로그 한 줄(~200byte) 추가뿐 |
| "Collector가 죽으면?" | 로그 파일은 남아있음, 재시작 시 이어서 처리 | offset 기반 무중단 복구 |
| "WAS 재시작 필요?" | 불필요 (Collector만 기동/중지) | 무중단 배포 가능 |

**추가 어필 포인트**:

```
"만약 보다 정밀한 SQL 레벨 분석이 필요한 비핵심 시스템이 있다면,
 선별적으로 Servlet Filter 방식이나 Agent 방식도 지원합니다.
 고객사 환경에 맞게 유연하게 구성할 수 있습니다."
```

#### 보안팀/감사팀 대상 (CISO, 정보보호 담당, 컴플라이언스)

**보안팀의 최우선 관심사**: 법적 요건 충족, 감사 무결성, 사각지대 제거

```
제안 화법:

"게이트웨이 방식과 로그 연동을 결합하여, 
 직접 접속자부터 웹 실사용자까지 단 하나의 빈틈도 없는 
 통합 감사 체계를 구축합니다."
```

**뒷받침 근거**:

| 보안팀 요구 사항 | DLM 대응 | 법적 근거 |
|----------------|---------|----------|
| "실사용자 식별(Who) 되나?" | AOP/Filter에서 세션 기반 실사용자 추출 | 개인정보보호법 제29조 |
| "접속기록 위변조 방지는?" | SHA-256 해시체인으로 무결성 보장 | 전자금융감독규정 제27조의5 |
| "DBA 직접 접속도 기록되나?" | DB접근제어(게이트웨이) 연동으로 커버 | 접속기록 5년 보존 의무 |
| "감사 보고서 자동 생성?" | DLM 관리 화면에서 기간별/사용자별 리포트 | 금감원 현장 검사 대응 |
| "이상행위 탐지?" | 대량 조회, 야간 접속, 퇴직예정자 등 룰 기반 탐지 | 내부통제 강화 |

**통합 감사 체계 구성도**:

```
[감사 사각지대 제로 아키텍처]

경로 1: 웹/앱 사용자 (텔러, 콜센터)
  브라우저 → WAS → DB
  수집: C방식(로그 연동) 또는 B방식(Filter)
  식별: 세션 기반 실사용자 ID ← ★ 이게 핵심

경로 2: DBA/개발자 직접 접속
  SQL 툴(DBeaver 등) → DB접근제어(DBSAFER) → DB
  수집: 게이트웨이가 자체 기록 → DLM 연동(DB_DAC)
  식별: 게이트웨이 인증 ID

경로 3: 배치/스케줄러
  Cron/Spring Batch → DB
  수집: A방식(Agent) 또는 배치 로그 연동
  식별: 배치 Job ID + 실행 계정

경로 4: 외부 API 연동
  파트너사 → API Gateway → WAS → DB
  수집: B방식(Filter) 또는 C방식(로그)
  식별: API Key + 클라이언트 인증서

→ 4가지 경로 모두 DLM의 TBL_ACCESS_LOG에 통합 저장
→ 해시체인으로 위변조 불가
→ 단일 관리 화면에서 통합 조회/분석
```

#### 개발팀 대상 (SI 개발자, 공통 프레임워크 담당)

**개발팀의 최우선 관심사**: 개발 공수, 기존 코드 영향, 유지보수 부담

```
제안 화법:

"Spring AOP 클래스 1개와 Logback 설정 10줄만 추가하면 됩니다.
 기존 업무 소스코드는 한 줄도 수정하지 않습니다.
 저희가 예제 코드와 연동 가이드를 제공합니다."
```

**뒷받침 근거**:

| 개발팀 우려 사항 | DLM 대응 |
|----------------|---------|
| "기존 소스 다 고쳐야 하나?" | AOP 1개로 자동 적용, 업무 소스 수정 없음 |
| "성능 테스트 다시 해야?" | 비동기 로깅이라 업무 응답시간 영향 없음 |
| "로그 형식 맞추기 어렵지 않나?" | JSON 표준 규격 + 예제 코드 제공 |
| "MyBatis SQL도 남기고 싶은데?" | MyBatis Plugin 예제도 제공 (A방식 수준 정밀도) |
| "나중에 유지보수는?" | AOP pointcut만 수정하면 대상 확대/축소 가능 |

### 6.3 미팅 시나리오: 실전 대화 흐름

```
[고객사 미팅 — 참석자: 운영팀장, 보안담당, 개발PM]

── 1단계: 현황 파악 ──

DLM: "현재 DB접근제어는 어떤 솔루션을 쓰고 계신가요?"
고객: "DBSAFER로 게이트웨이 방식 쓰고 있습니다."

DLM: "웹을 통한 업무 사용자의 접속기록은 어떻게 관리하시나요?"
고객: "솔직히 그 부분이 좀 미흡합니다. DBA 접속은 DBSAFER로 
      기록되는데, 창구 직원이 웹으로 조회한 건 실사용자가 안 잡혀요."

── 2단계: 문제 공감 ──

DLM: "맞습니다. 게이트웨이 방식은 WAS→DB 구간에서 WAS IP만 보이기 
      때문에 '누가' 조회했는지 식별이 어렵습니다. 
      금감원 검사에서 지적받는 핵심 포인트가 바로 이 부분입니다."

── 3단계: 솔루션 제안 ──

[운영팀장 향해]
DLM: "저희 DLM은 WAS 안정성을 최우선으로 고려하여 
      Agentless 로그 연동 방식을 기본으로 합니다. 
      WAS에 아무것도 설치하지 않고, 비동기 로깅으로 
      서비스 부하도 사실상 제로입니다."

운영팀장: "WAS에 Agent 안 심는 거예요?"
DLM: "네. 로그 파일만 읽어가는 별도 Collector를 두는 방식입니다.
      WAS 프로세스와 완전히 독립적이어서 장애 위험이 없습니다."

[보안담당 향해]
DLM: "기존 DBSAFER의 게이트웨이 기록과 저희 로그 연동을 결합하면,
      DBA 직접 접속부터 웹 실사용자까지 빈틈없는 통합 감사 체계를 
      구축할 수 있습니다. 접속기록은 SHA-256 해시체인으로 
      위변조 불가능하게 관리됩니다."

[개발PM 향해]
DLM: "개발 측면에서는 Spring AOP 클래스 1개와 Logback 설정만 
      추가하시면 됩니다. 기존 업무 소스코드 수정은 없습니다.
      저희가 예제 코드와 연동 가이드를 제공해 드립니다."

── 4단계: 차별화 ──

DLM: "그리고 만약 향후 더 정밀한 SQL 레벨 분석이 필요한 
      시스템이 생기면, Agent 방식이나 Filter 방식도 
      같은 플랫폼에서 지원합니다. 
      시스템별로 최적의 방식을 선택하실 수 있습니다."
```

### 6.4 C방식 비동기 로깅 상세 구현

운영팀에 "부하가 없다"고 말할 때의 기술적 근거를 상세히 기술한다.

#### 비동기(Async) 처리의 핵심 원리

```
[동기 방식 — 이렇게 하면 안 됨]

업무 스레드: ── 업무처리(50ms) ── 로그파일쓰기(0.05ms) ── 응답 ──
                                        ↑
                                  디스크 I/O 기다림
                                  (보통 0.05ms이지만 
                                   디스크 느리면 수십ms 가능)


[비동기 방식 — 이렇게 해야 함 (AsyncAppender)]

업무 스레드: ── 업무처리(50ms) ── 큐넣기(0.001ms) ── 응답 ──
                                       ↑
                                 메모리 큐에 넣고 즉시 리턴
                                 (디스크 I/O 안 기다림!)

별도 스레드: ─────── 큐에서 꺼내기 ── 파일쓰기 ──────────
                           ↑
                    업무와 무관하게 알아서 처리
```

#### Logback AsyncAppender 설정

```xml
<!-- 1단계: 실제 파일에 쓰는 Appender -->
<appender name="DLM_AUDIT_FILE" 
          class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>/logs/app/dlm-audit.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>/logs/app/dlm-audit.%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>365</maxHistory>
    </rollingPolicy>
    <encoder>
        <pattern>%msg%n</pattern>
    </encoder>
</appender>

<!-- 2단계: ★ 비동기 래퍼 ★ -->
<appender name="DLM_AUDIT_ASYNC" 
          class="ch.qos.logback.classic.AsyncAppender">
    
    <!-- 메모리 큐 크기: 10,000건 버퍼링 -->
    <queueSize>10000</queueSize>
    
    <!-- 큐 80% 차면 TRACE/DEBUG 버림 (INFO 감사로그는 절대 안 버림) -->
    <discardingThreshold>20</discardingThreshold>
    
    <!-- ★ 핵심: 큐가 가득 차도 업무 스레드를 블로킹하지 않음 ★ -->
    <!-- true = 로그를 버릴지언정 업무를 멈추지 않음 -->
    <neverBlock>true</neverBlock>
    
    <appender-ref ref="DLM_AUDIT_FILE" />
</appender>

<!-- 3단계: 감사 로거 연결 -->
<logger name="DLM_AUDIT" level="INFO" additivity="false">
    <appender-ref ref="DLM_AUDIT_ASYNC" />
</logger>
```

#### Spring AOP 비동기 감사 로깅 구현

```java
/**
 * 개인정보 접속기록 자동 생성 AOP.
 * 
 * 동작: 개인정보 관련 서비스 메서드 실행 완료 후, 
 *       비동기 로거(DLM_AUDIT)에 접속기록을 남긴다.
 * 
 * 성능: auditLog.info() → AsyncAppender 큐에 넣기 = 0.001ms
 *       업무 응답시간에 사실상 영향 없음.
 * 
 * 안전성: AOP 자체에서 예외 발생해도 업무 로직에 영향 없음
 *         (AfterReturning이므로 업무 완료 후 실행)
 */
@Aspect
@Component
public class DlmAuditAspect {

    private static final Logger auditLog = LoggerFactory.getLogger("DLM_AUDIT");

    @AfterReturning(
        pointcut = "execution(* com.bank.service.Customer*.*(..))" +
                   " || execution(* com.bank.service.Account*.*(..))" +
                   " || execution(* com.bank.service.Loan*.*(..))",
        returning = "result"
    )
    public void writeAuditLog(JoinPoint jp, Object result) {
        try {
            // 1. 누가 (Who) — Spring Security 세션에서 추출
            String userId = "UNKNOWN";
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated()) {
                userId = auth.getName();
            }

            // 2. 어디서 (Where) — HTTP 요청의 클라이언트 IP
            String clientIp = "N/A";
            ServletRequestAttributes attrs = (ServletRequestAttributes)
                RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest req = attrs.getRequest();
                clientIp = req.getHeader("X-Forwarded-For");
                if (clientIp == null || clientIp.isEmpty()) {
                    clientIp = req.getRemoteAddr();
                }
            }

            // 3. 뭘 했나 (What) — AOP가 자동 추출
            String service = jp.getTarget().getClass().getSimpleName();
            String method = jp.getSignature().getName();

            // 4. 조회 조건 (민감정보 마스킹)
            String params = maskSensitive(jp.getArgs());

            // 5. ★ 비동기 로그 기록 ★
            //    이 줄이 실행되면:
            //    → AsyncAppender 큐에 넣기 (0.001ms)
            //    → 즉시 리턴 (업무 스레드 해방)
            //    → 별도 스레드가 파일에 기록
            auditLog.info(
                "{\"ts\":\"{}\",\"user\":\"{}\",\"ip\":\"{}\",\"svc\":\"{}\",\"act\":\"{}\",\"params\":\"{}\"}",
                Instant.now(),
                userId,
                clientIp,
                service,
                method,
                params
            );

        } catch (Exception e) {
            // ★ 감사 로깅 실패가 업무에 절대 영향을 주지 않음 ★
            // 로깅 자체의 에러는 별도 에러 로그에 기록
            LoggerFactory.getLogger(DlmAuditAspect.class)
                .warn("Audit log failed: {}", e.getMessage());
        }
    }

    private String maskSensitive(Object[] args) {
        if (args == null || args.length == 0) return "";
        String raw = Arrays.toString(args);
        // 주민번호: 6자리-7자리 → 앞6자리만
        raw = raw.replaceAll("(\\d{6})-?(\\d{7})", "$1-*******");
        // 카드번호: 16자리 → 앞4 뒤4만
        raw = raw.replaceAll("(\\d{4})\\d{8}(\\d{4})", "$1********$2");
        return raw.replace("\"", "'");  // JSON 안전 처리
    }
}
```

#### 시간순 동작 추적 (운영팀 설명용)

```
09:31:22.000  텔러(teller01)가 "고객 조회" 버튼 클릭
09:31:22.001  Controller.searchCustomer() 호출
09:31:22.002  ┌─ Spring AOP 프록시 진입 ──────────────────┐
09:31:22.002  │                                           │
09:31:22.002  │  CustomerService.searchCustomer("홍길동")   │
09:31:22.003  │       ↓                                   │
09:31:22.003  │  MyBatis → DB 쿼리 실행                    │
09:31:22.045  │  DB 결과 수신 (42ms)                       │
09:31:22.045  │       ↓                                   │
09:31:22.045  │  ★ AOP @AfterReturning 실행 ★             │
09:31:22.045  │  userId="teller01", ip="10.0.5.33"        │
09:31:22.046  │  auditLog.info(json)                      │
09:31:22.046  │    → AsyncAppender 큐에 넣기 (0.001ms)     │
09:31:22.046  │    → 즉시 리턴                             │
09:31:22.046  │                                           │
09:31:22.046  └───────────────────────────────────────────┘
09:31:22.046  Controller → 텔러에게 응답 전송 (총 46ms)
              ↑
              업무 완료. 텔러는 정상 응답 받음.

[이 아래는 업무와 무관한 백그라운드 처리]
09:31:22.048  Logback 별도 스레드: 큐에서 꺼냄
09:31:22.049  Logback 별도 스레드: /logs/app/dlm-audit.log에 기록
09:31:25.000  DLM Collector: 새 라인 감지 → DLM 서버로 전송
09:31:25.050  DLM 서버: 해시체인 생성 → TBL_ACCESS_LOG 저장
```

---

## 7. 구현 로드맵

### DLM 솔루션 측 개발 필요 항목

| 우선순위 | 항목 | 방식 | 예상 공수 |
|---------|------|------|----------|
| 1 | DLM Collector 개발 | C | 1~2주 |
| 2 | 고객사 연동 가이드 문서 | C | 2~3일 |
| 3 | DlmAccessFilter JAR 개발 | B | 2~3주 |
| 4 | AgentApiController collectType 확장 | B, C | 1일 |
| 5 | 관리 UI에서 수집방식별 통계 | 공통 | 2~3일 |

### 수집방식 구분 (collectType 필드)

```
기존:    WAS_AGENT   → A방식 (Java Agent)
추가:    WAS_FILTER  → B방식 (Servlet Filter)  
추가:    LOG_COLLECT → C방식 (로그 수집)
기존:    DB_AUDIT    → DB 감사 로그 (Oracle Audit 등)
기존:    DB_DAC      → DB접근제어 연동 (DBSAFER 등)
```

---

## 7. 부록: C방식 "고객사 개발" 난이도 정리

### "개발이 필요하다"는 말이 과장인 경우

```
케이스 1: Spring Boot + AOP 가능한 환경
  → AOP 클래스 1개 + logback.xml 설정 = 반나절이면 끝
  → "개발"이라기보다 "설정"에 가까움

케이스 2: MyBatis 사용 환경
  → MyBatis Plugin 1개 + logback.xml = SQL까지 기록 가능
  → A방식(Agent)에 거의 근접한 정밀도

케이스 3: Spring Interceptor로 URL 기반
  → Interceptor 1개 + WebMvcConfigurer = B방식과 거의 동일
  → 차이: JAR이 아니라 고객사 소스에 포함
```

### "개발이 필요하다"는 말이 현실인 경우

```
케이스 4: 레거시 JSP/Servlet (Spring 없음)
  → 각 Servlet마다 로그 코드 추가 필요
  → 수십~수백 군데 수정 = 진짜 개발 공수

케이스 5: EJB/Struts 기반 오래된 시스템
  → AOP 불가, 공통 모듈화 어려움
  → 이런 경우 B방식(Filter)이 더 현실적

케이스 6: 다수의 이기종 시스템
  → Java, .NET, PHP 혼재
  → 언어별로 각각 개발 필요 = 큰 공수
```

### 고객사에 제공할 연동 키트 구성

```
dlm-integration-kit/
├── README.md                          # 연동 가이드
├── examples/
│   ├── spring-aop/                    # AOP 방식 예제
│   │   └── DlmAuditAspect.java
│   ├── spring-interceptor/            # Interceptor 방식 예제
│   │   └── DlmAuditInterceptor.java
│   ├── mybatis-plugin/                # MyBatis Plugin 예제
│   │   └── DlmMybatisAuditPlugin.java
│   └── servlet-filter/                # 순수 Servlet 예제
│       └── DlmAuditFilter.java
├── logback-config/
│   └── logback-dlm-audit.xml          # Logback 설정 예시
└── log-format-spec.md                 # JSON 로그 형식 규격서
```
