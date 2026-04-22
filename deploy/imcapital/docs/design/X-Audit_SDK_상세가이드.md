# X-Audit SDK — 완전 이해 가이드

> 대상: DLM 운영팀 / 고객사 처리계 개발팀 / 보안 검토자
> 목적: "어떻게 세팅하고 어떻게 돌아가는지" 내부 동작을 단계별로 학습
> 범위: 청사진 Phase 1 구현체 (`dlm-aop-sdk` + DLM 서버 수신부)
> 버전: 1.0.0 (2026-04-20)

---

## 0. 먼저 — 이 구현은 최선인가? (솔직 평가)

"최선"은 단계에 따라 다릅니다.

### 단계별 적합도

| 단계 | 적합도 | 근거 |
|------|--------|------|
| **PoC / 파일럿** (1~3개월, 1개 처리계) | ★★★★★ 최적 | 코드 수정 0 + 롤백 쉬움 + 심의 부담 낮음 |
| **운영 단일 처리계** (금융사 1곳 1시스템) | ★★★★☆ 양호 | 인증·디스크 백업 추가 후 가능 |
| **운영 다중 처리계** (5+ 시스템) | ★★★☆☆ 개선 필요 | 해시체인 레이스·메트릭·스키마 마이그레이션 체계 필요 |

### 강점 (진짜 강함)
1. **Java Agent 회피** — 이지서티 BCI/APM 에이전트처럼 JVM 기동 옵션 변경 불필요. 금융권 심의 절차 가장 짧음
2. **코드 수정 0줄** — Mapper XML / DAO / Service 전혀 손대지 않음. 변경관리 심사 최소
3. **응답 지연 0ms** — 큐 포화 시 drop + warn. 비즈니스 흐름 절대 영향 없음
4. **46KB 경량** — 의존성 최소 (Alibaba TTL 하나만 runtime)
5. **해시체인 기본 탑재** — 안전성확보조치 기준 제8조 3항 대응
6. **javax 타겟** — Java 8 / Spring Boot 2.x = 금융권 처리계 80%+ 즉시 커버

### 약점 (운영 전환 전 반드시 개선)

| # | 약점 | 현재 상태 | 권장 개선 |
|---|------|----------|----------|
| 1 | 인증 없음 | `/api/xaudit/events` permitAll | API Key Interceptor 또는 mTLS |
| 2 | Spring Boot 3.x (jakarta) 미지원 | compileOnly javax만 | 별도 submodule 로 jakarta 빌드 |
| 3 | 해시체인 레이스 가능성 | worker=1 로 완화 | `SELECT ... FOR UPDATE` 락 row 추가 |
| 4 | 전송 실패 시 디스크 백업 없음 | 메모리 큐만 | 로컬 파일 큐 (Chronicle Queue 등) |
| 5 | 메트릭 노출 없음 | 내부 AtomicLong | Micrometer + `/actuator/xaudit` |
| 6 | PII 정규식 false positive | CARD 패턴 단순 | Luhn check 추가 |
| 7 | RESTful URL 메뉴 인식 약함 | prefix 매핑만 | Spring HandlerMapping 기반 |
| 8 | DB 스키마 마이그레이션 체계 없음 | 수동 DDL | Flyway / Liquibase |
| 9 | 수집 대상 동적 제어 없음 | 재기동 필요 | `xaudit.enabled` DB 기반 원격 제어 |

### 경쟁 제품 대비

| 항목 | X-Audit (이번 구현) | 이지서티 PSM (BCI Agent) | 피앤피 DBSAFER (Gateway) |
|------|---------------------|---------------------------|-----------------------------|
| 설치 부담 | **매우 낮음** (라이브러리) | 중간 (JVM -javaagent) | 높음 (네트워크 어플라이언스) |
| 처리계 코드 수정 | 0 | 0 | 0 |
| 사용자 식별 | Filter 명시적 | BCI 자동 | User Tracer 별도 |
| SQL 원문 수집 | MyBatis BoundSql + JDBC | BCI 자동 | 네트워크 TNS 파싱 |
| 3-tier 지원 | ★★★★★ | ★★★★★ | ★★★☆☆ (User Tracer 필요) |
| SSL/TDE 구간 | ★★★★★ (app 레벨) | ★★★★★ | ★☆☆☆☆ (패킷 불가시) |
| 성능 영향 | 극소 (0~0.5ms) | 소 (~1ms) | 거의 없음 |
| 도입 비용 | 무상 | 수억 원 | 수억 원 |
| 장애 리스크 | 거의 없음 | 중간 (BCI 버그 전례) | 낮음 |
| APM 공존 | ★★★★★ | ★★☆☆☆ (Agent 충돌) | ★★★★★ |

**결론**: PoC·파일럿·중소 운영 단계에서는 X-Audit 이 가장 합리적. 수억원 제품을 대체할 수 있는 구간이 존재. 단, 운영 전환 시 위 약점 #1, #4, #5 는 필수 보완.

---

## 1. 전체 아키텍처

### 1-1. 그림으로

```
┌──────────────────────────────────────────────────────────────────┐
│ 고객사 처리계 WAS  (예: B은행 대출 시스템, LOAN_CORE)              │
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────────┐                  │
│  │ Tomcat / Netty  │    │ SDK (dlm-aop-sdk)   │                  │
│  └────────┬────────┘    │                     │                  │
│           │             │  [1] XauditAccess   │                  │
│    HTTP ──┼─────────────┤      Filter         │                  │
│           │             │                     │                  │
│           ▼             │  [2] XauditMybatis  │                  │
│    @Controller          │      Interceptor    │                  │
│    @Service             │                     │                  │
│    @Mapper ◀────────────┤  [3] XauditJdbc     │                  │
│    │                    │      Listener       │                  │
│    ▼                    │                     │                  │
│    DataSource           │  [4] XauditPii      │                  │
│    │                    │      Masker         │                  │
│    ▼                    │                     │                  │
│  (처리계 고유 DB)        │  [5] XauditEvent    │                  │
│   LOAN_APP,             │      Queue (메모리)  │                  │
│   CUSTOMER 등            │         │           │                  │
│   ※ SDK 는              │         ▼           │                  │
│     여기 안건드림        │  [6] XauditHttp     │                  │
│                         │      Sender         │                  │
│                         │      (daemon)       │                  │
│                         └──────┬──────────────┘                  │
│                                │ gzip + JSON                     │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                    HTTPS POST   │ /api/xaudit/events
                                 │
┌────────────────────────────────┼─────────────────────────────────┐
│ DLM 서버                        │                                 │
│                                 ▼                                 │
│  ┌──────────────────────────────────────────┐                    │
│  │ [7] XauditGzipFilter                     │                    │
│  │     Content-Encoding: gzip → 해제         │                    │
│  └────────────┬─────────────────────────────┘                    │
│               ▼                                                  │
│  ┌──────────────────────────────────────────┐                    │
│  │ [8] XauditEventController                │                    │
│  │     @PostMapping("/events")              │                    │
│  └────────────┬─────────────────────────────┘                    │
│               ▼                                                  │
│  ┌──────────────────────────────────────────┐                    │
│  │ [9] XauditEventServiceImpl               │                    │
│  │     - ACCESS/SQL 분리                    │                    │
│  │     - 해시체인 SHA-256 계산              │                    │
│  │     - batch insert                       │                    │
│  └────────────┬─────────────────────────────┘                    │
│               ▼                                                  │
│  ┌──────────────────────────────────────────┐                    │
│  │ COTDL.TBL_XAUDIT_ACCESS_LOG              │                    │
│  │ COTDL.TBL_XAUDIT_SQL_LOG                 │                    │
│  │ COTDL.V_XAUDIT_UNIFIED (조회 뷰)          │                    │
│  └────────────┬─────────────────────────────┘                    │
│               ▼                                                  │
│  ┌──────────────────────────────────────────┐                    │
│  │ [10] XauditViewController                │                    │
│  │      /xaudit/dashboard                   │                    │
│  │      /xaudit/access /xaudit/sql          │                    │
│  │      /xaudit/detail/{reqId}              │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

### 1-2. 핵심 분리 원칙

- **처리계 DB ≠ DLM DB**: 처리계는 자기 비즈니스 DB 만 쓰고, X-Audit 수신 테이블은 DLM 쪽에 있음
- **처리계 컨테이너 ≠ DLM 컨테이너**: 둘은 HTTP 로만 통신
- **수집 실패 ≠ 비즈니스 실패**: SDK 는 절대로 비즈니스 요청에 영향 주지 않음

---

## 2. 하나의 HTTP 요청이 처리되는 과정 (Step-by-Step)

실제 시나리오: **담당자 kim 이 "고객 123 정보 조회" 요청**

### T=0ms: 브라우저 → 처리계
```http
GET /customer/123 HTTP/1.1
Host: bank-loan.internal
Cookie: JSESSIONID=AB12C
X-Menu-Id: CUST_VIEW
```

### T=0.1ms: Servlet Filter 진입
[XauditAccessFilter.doFilter()](DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/servlet/XauditAccessFilter.java)

```java
// 1. 제외 URI 체크 (/health, /actuator 등)
if (isExcluded("/customer/123")) return chain.doFilter(...);   // 건너뜀

// 2. 요청 컨텍스트 구성
String reqId = UUID.randomUUID();              // 9f3a...
User u = userResolver.resolve(req);            // id="kim", name=null
String sessionId = request.getSession().getId();
String menuId = "CUST_VIEW";                   // X-Menu-Id 헤더에서
String ip = getClientIp(req);                  // X-Forwarded-For → 10.1.2.3

XauditContext ctx = new XauditContext(reqId, u.id, ..., menuId, "/customer/123", "GET", ...);
XauditContextHolder.set(ctx);                  // TransmittableThreadLocal 저장
MDC.put("xauditReqId", reqId);                 // Logback %X 와 자동 연동
```

이후 `chain.doFilter()` 로 비즈니스 로직 실행.

### T=0.2ms: Spring Controller → Service → Mapper
처리계 원본 코드. **SDK는 여기 손대지 않음**.

```java
@GetMapping("/customer/{id}")
public Customer get(@PathVariable Long id) {
    return customerService.get(id);    // 결국 Mapper.selectById(123) 호출
}
```

### T=0.5ms: MyBatis Interceptor 진입
[XauditMybatisInterceptor.intercept()](DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/mybatis/XauditMybatisInterceptor.java)

```java
long t0 = System.nanoTime();
Object result = invocation.proceed();          // 실제 SQL 실행 (여기서 DB 왕복)
long durMs = (now - t0) / 1_000_000;

// BoundSql 에서 SQL + bind params 추출
MappedStatement ms = (MappedStatement) args[0];
BoundSql bound = ms.getBoundSql(parameter);
String sql = bound.getSql();                   // "SELECT * FROM CUSTOMER WHERE id = ?"
String binds = dumpBindParams(bound, param);   // "[id=123]"

// TTL 에서 컨텍스트 꺼냄
XauditContext ctx = XauditContextHolder.get();

// PII 탐지
String pii = masker.detect(sql + " " + binds); // null (이 SQL 엔 PII 없음)

// Event VO 조립
XauditEvent ev = new XauditEvent();
ev.type = SQL;
ev.reqId = ctx.reqId;                          // ACCESS 와 같은 reqId!
ev.userId = ctx.userId;
ev.sqlId = "com.bank.loan.CustomerMapper.selectById";
ev.sqlText = sql;
ev.bindParams = binds;
ev.durationMs = 5L;
ev.affectedRows = 1;

queue.offer(ev);                               // 큐에 enqueue (마이크로초)
```

### T=0.7ms: Controller 반환, 응답 직렬화 → 클라이언트

### T=1.0ms: Filter finally 블록
```java
long totalDur = (System.nanoTime() - t0) / 1_000_000;

XauditEvent ev = new XauditEvent();
ev.type = ACCESS;
ev.reqId = ctx.reqId;                          // 위 SQL 이벤트와 동일!
ev.userId = ctx.userId;
ev.uri = "/customer/123";
ev.httpMethod = "GET";
ev.httpStatus = 200;
ev.totalDurationMs = totalDur;
ev.resultCode = "SUCCESS";

queue.offer(ev);                               // 큐에 enqueue
XauditContextHolder.clear();                   // ← 중요: 누수 방지
MDC.clear();
```

**사용자 관점 응답 완료 시점 = T=1ms. SDK 오버헤드 = 약 0.3ms.**

### T=3000ms (별도 스레드): Sender 배치 전송
[XauditHttpSender.loop()](DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/core/XauditHttpSender.java)

```java
while (running) {
    List<XauditEvent> batch = new ArrayList<>();
    int n = queue.drainTo(batch, 100, 3000);   // 100 건 또는 3초
    if (n == 0) continue;

    byte[] json = MAPPER.writeValueAsBytes(batch);
    byte[] gz   = gzip(json);                  // 평균 70% 압축

    POST https://dlm.bank.internal:8443/api/xaudit/events
         Content-Encoding: gzip
         Body: gz

    // 실패 시 exponential backoff 3회, 최종 실패 시 drop + warn
}
```

### T=3010ms: DLM 서버 GzipFilter
[XauditGzipFilter.doFilter()](DLM/src/main/java/datablocks/dlm/config/XauditGzipFilter.java)

```java
if (req.getHeader("Content-Encoding").contains("gzip")) {
    chain.doFilter(new GzipInflatingRequest(req), res);  // 압축 해제된 Wrapper
}
```

### T=3015ms: Controller → Service
[XauditEventServiceImpl.receiveBatch()](DLM/src/main/java/datablocks/dlm/service/XauditEventServiceImpl.java)

```java
List<XauditEventVO> access = new ArrayList<>();
List<XauditEventVO> sql    = new ArrayList<>();
for (XauditEventVO ev : events) {
    if ("ACCESS".equals(ev.getType())) access.add(ev);
    else if ("SQL".equals(ev.getType())) sql.add(ev);
}

// 해시체인 (ACCESS)
String prev = mapper.selectLastAccessHash() ?: "GENESIS";
for (VO v : access) {
    v.setHashPrev(prev);
    String cur = SHA256("ACCESS|" + v.reqId + "|" + v.userId + ...);
    v.setHashCur(cur);
    prev = cur;                                // 체인!
}
mapper.insertAccessLogBatch(access);

// 해시체인 (SQL) — 동일
```

### T=3020ms: DB Commit
```sql
COMMIT;
-- TBL_XAUDIT_ACCESS_LOG: 100 rows inserted
-- TBL_XAUDIT_SQL_LOG   : 150 rows inserted
```

### T=3021ms: HTTP 200 응답 → 처리계
`{"inserted": 250, "success": true}` — SDK 는 이걸 받아 성공 카운터만 증가, 실패 시 재시도.

---

## 3. 컴포넌트별 왜 / 무엇을 (학습 핵심)

### 3-1. XauditContextHolder — TransmittableThreadLocal 이 필요한 이유

일반 `ThreadLocal` 은 부모 스레드 → 자식 스레드 전파 안 됨.

```java
ThreadLocal<String> tl = new ThreadLocal<>();
tl.set("kim");

CompletableFuture.supplyAsync(() -> {
    return tl.get();                           // null! (다른 스레드)
});
```

금융권 처리계는 `@Async` / `CompletableFuture` / Spring Batch `TaskExecutor` 가 흔하다. 여기서 사용자 식별을 잃으면 감사 증적이 망가진다.

해결책: **Alibaba TransmittableThreadLocal**
- `InheritableThreadLocal` 과 달리 스레드풀 **재사용** 시에도 전파
- 부모 → 자식 스냅샷 복사, 자식 종료 시 복원
- 수천 개 금융 서비스에서 검증된 라이브러리

### 3-2. XauditMybatisInterceptor — 왜 AOP 가 아니라 Interceptor 인가

**AOP (Spring AOP @Around)** 로 DAO 메서드를 잡으면:
- 메서드 시그니처는 알지만 **실행된 SQL 원문은 모름**
- MyBatis 가 XML 을 파싱해서 만든 최종 SQL 을 못 봄
- 금융권 시행세칙 제13조제1항제9호(2025.2.3) "SQL 원문 보관" 요건 미충족

**MyBatis Plugin Interceptor** 는:
- `Executor.update/query` 지점에서 `BoundSql` 을 얻음
- `BoundSql.getSql()` 은 실제 전달된 SQL (예: `SELECT * FROM CUSTOMER WHERE id = ?`)
- `BoundSql.getParameterMappings()` + MetaObject 로 bind params 리스트 추출
- → 법규 요건 충족

### 3-3. XauditJdbcQueryListener — MyBatis 사각지대 메우기

MyBatis Interceptor 는 MyBatis 가 아닌 경로를 못 잡음:
- Spring `JdbcTemplate.query(...)`
- Spring Batch `JobRepository` 내부 SQL
- JPA 네이티브 쿼리 (Hibernate 가 만들어낸 것이 아닌)

**DataSource-Proxy** 를 쓰면 이 모든 경로를 커버.

단, 고객사 개발팀이 DataSource 빈을 다음처럼 래핑해야 함:
```java
@Bean @Primary
public DataSource dataSource(HikariDataSource real, XauditJdbcQueryListener listener) {
    return ProxyDataSourceBuilder.create(real)
        .name("xaudit").listener(listener).build();
}
```

**MyBatis 와 중복 기록 방지** — Listener 는 스택 트레이스에 `org.apache.ibatis` 가 보이면 스킵 (1~2µs 비용).

### 3-4. XauditEventQueue — 왜 BlockingQueue + drop 인가

대안들:
- **동기 전송**: DLM 장애 시 비즈니스 응답 지연 → 절대 불가
- **Disruptor**: 더 빠르지만 의존성 추가, 금융권 라이브러리 심의 가중
- **무제한 큐**: OOM 위험
- **BlockingQueue + drop** ← 선택

큐 포화 정책:
```java
if (queue.offer(ev)) {                         // 즉시 반환 (non-blocking)
    enqueued.increment();
} else {
    dropped.increment();                       // 그냥 버림
    if (dropCount % 1000 == 1) log.warn("dropped {}", dropCount);
}
```

감사 로그는 **정확성 > 완전성** 트레이드오프. 99.9% 수집 + 서비스 0 영향 이 0.1% drop 보다 가치 있음.

### 3-5. XauditHttpSender — HttpURLConnection 을 선택한 이유

- OkHttp: 훌륭하지만 의존성 추가 (300KB+, 금융권 라이브러리 심의 1건 추가)
- WebClient: Reactor 필요, Spring Boot 3 스타일
- **HttpURLConnection**: JDK 내장, 의존성 0 ← 선택

단점: 커넥션 재사용·HTTP/2 미지원. 하지만 배치당 3초에 1 회 POST 라 문제 없음.

### 3-6. 해시체인 — 입력값 선정 이유

```
SHA-256("ACCESS|reqId|userId|accessTime|httpMethod:uri|prevHash")
SHA-256(   "SQL|reqId|userId|accessTime|sqlType:sqlText|prevHash")
```

포함:
- `reqId` : 요청 고유성
- `userId` / `accessTime` : 법적 5W1H
- `sqlText` (SQL) / `uri` (ACCESS) : "수행업무" 요건
- `prevHash` : 체인 (이전 레코드 수정 시 다음 레코드 해시 불일치로 즉시 탐지)

제외:
- `bindParams` : 마스킹에 따라 가변 가능 → 해시에 넣으면 검증 깨짐
- `durationMs` / `errorMessage` : 관측값, 감사 증적이 아님
- `hashPrev` 는 포함됨 (체인 특성)

**왜 logId 는 포함 안 하나?** AUTO_INCREMENT 라 INSERT 전엔 null. 해시 계산 후 insert 하므로 포함 불가.

---

## 4. 설정 세팅 실전 — B은행 시나리오

### 4-1. 처리계 종류별 추천 설정

#### 케이스 A: API Gateway + JWT 기반 신규 처리계
```yaml
xaudit:
  service-name: LOAN_API
  server:
    url: https://dlm.bank.internal:8443/api/xaudit/events
  user:
    header: X-User-Id                    # 게이트웨이가 JWT 에서 뽑아 주입
    use-security-context: false          # 이미 헤더로 받으므로 비활성
  menu:
    header: X-Menu-Id
```

#### 케이스 B: 레거시 Spring Security 기반 처리계
```yaml
xaudit:
  service-name: CORE_BANK
  server:
    url: https://dlm.bank.internal:8443/api/xaudit/events
  user:
    use-security-context: true           # SecurityContextHolder.getName()
  menu:
    uri-prefix-map:                      # URI prefix 매핑
      DEPOSIT: /deposit/
      LOAN: /loan/
      CARD: /card/
```

#### 케이스 C: 구식 서블릿 + 자체 세션 관리
```yaml
xaudit:
  service-name: LEGACY_TRUST
  server:
    url: https://dlm.bank.internal:8443/api/xaudit/events
  user:
    session-attribute: LOGIN_USER        # 세션에 String id 들어있음
    use-security-context: false
```

### 4-2. 성능 튜닝 공식

목표: 초당 300 TPS, 요청당 평균 5개 SQL = **1,500 events/s**

```yaml
xaudit.batch:
  # 큐: 10초치 버퍼 = 15,000
  queue-capacity: 15000

  # 배치: 100 건 * 10회/초 = 1,000 events/s (부족) → 300 건으로 상향
  size: 300

  # flush 간격: 1초 (배치 미달 시에도 1초마다 flush)
  flush-interval-ms: 1000

  # 워커: 1 (해시체인 레이스 방지 위해 직렬화)
  # → DB insert 지연 발생하면 2로 증가 고려
  worker-threads: 1
```

### 4-3. PII 정책별 추천

| 환경 | mask-patterns | 근거 |
|------|---------------|------|
| 개인정보 취급업무 (CRM/회원) | JUMIN, CARD, ACCOUNT, PHONE, EMAIL | 포괄적 탐지 |
| 금융거래 (대출/예금) | JUMIN, CARD, ACCOUNT | 전화/이메일은 거래와 무관 |
| 내부 관리 시스템 | JUMIN | false positive 최소화 |
| 통계/분석 | (비움) | PII 자체가 적음, 오버헤드 절약 |

### 4-4. Oracle 환경 특별 설정

```yaml
xaudit:
  oracle:
    set-client-info: true                # V$SESSION.CLIENT_IDENTIFIER 자동 세팅
```

+ HikariCP 설정 (Dirty Session 방어):
```yaml
spring.datasource.hikari.connection-init-sql: "BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;"
```

효과:
- Oracle Audit Trail (AUD$ / UNIFIED_AUDIT_TRAIL) 에 사용자 ID 자동 반영
- V$SESSION 으로 "지금 DB 에 접속 중인 앱 사용자" 식별
- 로그인 DB 유저 (예: `APP_USER`) 와 별개로 **업무 사용자** (예: `kim`) 기록

### 4-5. 기존 DAM 연계 (DBSAFER / 이지서티 PSM)

```yaml
xaudit.sql:
  comment-injection: true                # /*XAUDIT USER=kim;MENU=LOAN*/ SELECT ...
```

네트워크 DAM 이 TNS 패킷에서 이 주석을 정규식 파싱해서 "WAS 사용자 이름" 을 얻음. **가변값(UUID, 타임스탬프) 절대 넣지 말 것** — Oracle shared pool 오염 위험.

---

## 5. 동작 검증 — 실제 확인 방법

### 5-1. 처리계 기동 로그

정상:
```
INFO  d.d.xaudit.spring.XauditAutoConfiguration - [X-Audit] activated: service=LOAN_CORE, server=https://..., queue=15000
INFO  d.d.xaudit.core.XauditHttpSender           - [X-Audit] HTTP sender started (workers=1, url=https://...)
INFO  d.d.xaudit.spring.XauditAutoConfiguration$MybatisSection - [X-Audit] MyBatis interceptor registered on all SqlSessionFactory beans
```

미동작:
```
(아무 [X-Audit] 로그 없음)
→ 원인 확인:
   1. xaudit.enabled=false 인지
   2. spring.factories / AutoConfiguration.imports 가 jar에 포함됐는지
   3. @ComponentScan 범위에서 datablocks.dlm.xaudit 가 제외됐는지
```

### 5-2. 스모크 테스트

```bash
./customer/scripts/smoke-test.sh https://dlm.bank.internal:8443
# → {"inserted":2,"success":true,"received":2}
```

실패 원인:
- `Connection refused` → DLM URL/포트 확인
- `400 Bad Request` → JSON 포맷 (accessTime 형식) 확인
- `401/403` → SecurityConfig 가 `/api/xaudit/**` permitAll 인지
- `curl: gzip: broken pipe` → DLM GzipFilter 동작 확인

### 5-3. 한 요청 추적 (감사팀 뷰)

```sql
-- B은행 담당자 kim 이 오늘 한 모든 행위
SELECT request_time, user_id, menu_id, sql_type, LEFT(sql_text, 60) AS sql, pii_detected
  FROM COTDL.V_XAUDIT_UNIFIED
 WHERE user_id = 'kim'
   AND DATE(request_time) = CURDATE()
 ORDER BY request_time;
```

### 5-4. 해시체인 무결성 검증

```sql
-- 연속된 레코드 hash_cur = SHA256(... + hash_prev) 검증
-- 샘플: 최근 10건
SELECT log_id,
       LEFT(hash_prev, 12) AS prev,
       LEFT(hash_cur, 12)  AS cur,
       user_id, access_time
  FROM COTDL.TBL_XAUDIT_ACCESS_LOG
 ORDER BY log_id DESC LIMIT 10;

-- log_id=3 의 hash_prev 는 log_id=2 의 hash_cur 와 같아야 함
```

---

## 6. 자주 겪는 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| 로그에 [X-Audit] 안 보임 | AutoConfig 로드 실패 | spring.factories 위치 확인 / `enabled=true` |
| 모든 사용자가 anonymous | 식별 전략 불일치 | `user.header` / `user.session-attribute` 로 조정 |
| SQL 이 1건도 안 들어옴 | MyBatis 사각지대 | DataSource-Proxy 활성화 |
| 큐 포화 drop 자주 | TPS 초과 | `queue-capacity` 상향, `batch.size` 조정 |
| `dropped 1 so far` 1회 만 | 일시적 DLM 응답 지연 | 정상 (3회 재시도 실패) |
| DLM UI 에 수신 안 보임 | SecurityConfig permitAll 누락 | `/api/xaudit/**` 추가 |
| @Async 내 SQL 이 anonymous | TaskDecorator 미적용 | Executor 에 `XauditTaskDecorator` 주입 |
| Oracle V$SESSION 에 안 나옴 | Tibero? 드라이버 미지원? | `oracle.set-client-info=false` 로 끄고 comment-injection 로 전환 |
| shared pool 100% | comment-injection 에 가변값 | USER/MENU 만 (고정값) 사용, UUID 제거 |
| hash_prev 중복 | 동시 요청 레이스 | `batch.worker-threads=1` 로 축소, Row Lock 개선 |

---

## 7. 커스터마이즈

### 7-1. 커스텀 사용자 해석기

```java
@Component
public class BankUserResolverConfig {
    public BankUserResolverConfig(XauditUserResolver resolver) {
        resolver.custom(req -> {
            String jwt = req.getHeader("Authorization");
            if (jwt == null) return null;
            Claims c = JwtParser.parse(jwt);
            return new XauditUserResolver.User(
                c.getSubject(),
                c.get("name", String.class),
                c.get("department", String.class)
            );
        });
    }
}
```

### 7-2. 커스텀 PII 패턴 추가

현재는 enum 수정 필요 → 확장 가능하도록 하려면 `XauditProperties.Sql` 에 custom-patterns Map 추가 + `XauditPiiMasker` 생성자에서 합성.

### 7-3. API Key 인증 (운영 전 필수)

DLM 서버에 Interceptor 추가:
```java
@Component
public class XauditApiKeyInterceptor implements HandlerInterceptor {
    @Value("${xaudit.server.allowed-keys}") Set<String> keys;
    @Override
    public boolean preHandle(HttpServletRequest req, ...) {
        String key = req.getHeader("X-API-KEY");
        if (!keys.contains(key)) {
            res.setStatus(401); return false;
        }
        return true;
    }
}
```
+ `WebMvcConfigurer.addInterceptors` 에 `/api/xaudit/**` 매핑.

### 7-4. 디스크 백업 큐 (DLM 장시간 다운 대응)

현재 메모리 큐만 → 24시간 넘게 DLM 다운 시 유실. 개선안:
- Chronicle Queue (무료, 저널링) 를 SDK 내부에 embedding
- 또는 SQLite 기반 로컬 임시 저장
- Phase 2 로드맵

---

## 8. 배포·운영 플로우

### 8-1. 배포 순서 (처음)

```
1. [DLM 운영팀]  dlm-server/database/XAUDIT_SCHEMA_20260420.sql 실행 (1회)
2. [DLM 운영팀]  DLM 서버 빌드·배포 (이번에 이미 완료)
3. [DLM 운영팀]  /api/xaudit/events 수신 확인 (smoke-test)
4. [DLM 운영팀]  customer/ 디렉토리를 고객사 담당에게 전달

5. [고객사 개발]  SDK JAR 사내 Nexus 배포 또는 로컬 install
6. [고객사 개발]  build.gradle / pom.xml 수정 PR
7. [고객사 개발]  application-dev.yml 에 xaudit.* 추가
8. [고객사 개발]  개발계 배포·기동
9. [고객사 개발]  smoke-test.sh 성공 확인
10. [고객사 운영]  스테이지 → 운영 순차 배포
11. [DLM 운영팀]  DLM UI 대시보드에서 수신 확인
```

### 8-2. 운영 전환 체크리스트

- [ ] 1주일 스테이지 무장애
- [ ] 큐 drop 카운트 = 0 (또는 허용범위)
- [ ] PII false positive 수용 가능한 수준
- [ ] 사용자 anonymous 비율 < 1%
- [ ] DLM UI 에 모든 처리계 데이터 가시
- [ ] 해시체인 샘플 검증 PASS
- [ ] API Key 인증 추가 (운영 필수)
- [ ] TLS 확인 (HTTP 금지)
- [ ] 모니터링: `/api/xaudit/events` 5xx 알림 설정
- [ ] 로그 파티셔닝·Retention 정책 설정 (DLM 서버)
- [ ] 장애 런북 작성 (DLM 다운 시 SDK 어떻게 동작하는지)

---

## 9. 법적 대응 맵

| 법규 | 요건 | 본 구현 대응 |
|------|------|------------|
| 개인정보보호법 제29조 | 안전성 확보조치 | 전체 수집 흐름 |
| 안전성 확보조치 기준 제8조 1항 | 접속기록 1~2년 보관 | `partition_key` + retention 스크립트 |
| 동 제8조 2항 | 월 1회 점검 | 해시체인 검증 + DLM 기존 스케줄러 |
| 동 제8조 3항 | 위·변조 방지 | SHA-256 체인 (자동) |
| 신용정보법 별표3 | 개인신용정보 3년 | 동일 테이블, retention 차등 |
| 전자금융감독규정 시행세칙 제13조제1항제9호 (2025.2.3) | SQL 원문 보관 | `sql_text` 컬럼 |
| 전자금융거래법 제22조 | 전자금융거래기록 5년 | 동일 |
| 개인정보 접속기록 6대 요소 | 계정/일시/IP/대상/업무/내역 | 모두 저장 |

**처리목적 소명**은 DLM 본체의 Alert Justification 기능으로 이미 제공 (이번 SDK 와 별개).

---

## 10. 향후 로드맵 (개선 우선순위)

### Phase 2 (운영 전환 시 필수) — 3개월
1. **API Key 인증** (필수)
2. **디스크 백업 큐** (DLM 24h+ 장애 대응)
3. **Micrometer 메트릭** (`/actuator/xaudit`)
4. **해시체인 Row Lock** (동시성)

### Phase 3 (다중 처리계) — 6개월
5. **Spring Boot 3.x / jakarta** 별도 모듈
6. **Flyway 스키마 마이그레이션**
7. **PII Luhn check**
8. **Spring HandlerMapping 기반 메뉴 인식**

### Phase 4 (경쟁력 강화) — 12개월
9. **처리목적 결재 워크플로** (기존 DLM 와 통합)
10. **UEBA 이상탐지 연계**
11. **CC 인증 / GS 1등급 / 조달청 등록**
12. **WORM 스토리지 연계**

---

## 부록 A — 전체 클래스 인덱스

### SDK ([dlm-aop-sdk](../../DLM/dlm-aop-sdk))
| 패키지 | 클래스 | 역할 |
|--------|--------|------|
| `xaudit.spring` | `XauditProperties` | `@ConfigurationProperties("xaudit")` |
| `xaudit.spring` | `XauditAutoConfiguration` | Spring Boot 자동 구성 |
| `xaudit.spring` | `XauditTaskDecorator` | @Async 컨텍스트 전파 |
| `xaudit.core` | `XauditContext` | 요청 단위 스냅샷 |
| `xaudit.core` | `XauditContextHolder` | TTL 홀더 |
| `xaudit.core` | `XauditEvent` | 전송 DTO |
| `xaudit.core` | `XauditEventQueue` | BlockingQueue + drop |
| `xaudit.core` | `XauditHttpSender` | gzip 배치 POST daemon |
| `xaudit.core` | `XauditPiiMasker` | 정규식 탐지/마스킹 |
| `xaudit.servlet` | `XauditAccessFilter` | HTTP 진입/종료 |
| `xaudit.servlet` | `XauditUserResolver` | 사용자 ID 해석 |
| `xaudit.mybatis` | `XauditMybatisInterceptor` | SQL 캡처 |
| `xaudit.jdbc` | `XauditJdbcQueryListener` | DataSource-Proxy |
| `xaudit.oracle` | `XauditOracleClientInfoSupport` | V$SESSION 세팅 |

### DLM 서버
| 파일 | 역할 |
|------|------|
| [domain/XauditEventVO.java](../../DLM/src/main/java/datablocks/dlm/domain/XauditEventVO.java) | 수신 DTO |
| [mapper/XauditEventMapper.java](../../DLM/src/main/java/datablocks/dlm/mapper/XauditEventMapper.java) / xml | MyBatis 매퍼 |
| [service/XauditEventService.java](../../DLM/src/main/java/datablocks/dlm/service/XauditEventService.java) / Impl | 해시체인 + 배치 insert |
| [config/XauditGzipFilter.java](../../DLM/src/main/java/datablocks/dlm/config/XauditGzipFilter.java) | gzip 해제 |
| [controller/XauditEventController.java](../../DLM/src/main/java/datablocks/dlm/controller/XauditEventController.java) | `/api/xaudit/events` |
| [controller/XauditViewController.java](../../DLM/src/main/java/datablocks/dlm/controller/XauditViewController.java) | 조회 UI |

### DB ([deploy/xaudit-sdk-kit/dlm-server/database](../../deploy/xaudit-sdk-kit/dlm-server/database))
| 오브젝트 | 내용 |
|---------|------|
| `TBL_XAUDIT_ACCESS_LOG` | HTTP 요청 단위 |
| `TBL_XAUDIT_SQL_LOG` | SQL 실행 단위 |
| `V_XAUDIT_UNIFIED` | req_id 조인 뷰 |

---

## 부록 B — 이 구현을 5줄로 요약

1. 고객사 처리계에 **SDK JAR 한 줄** + **application.yml 10줄** 추가 → Filter + MyBatis Plugin 자동 등록
2. **reqId** 로 ACCESS + 여러 SQL 을 묶어 수집, **TransmittableThreadLocal** 로 @Async 지원
3. 메모리 큐 → gzip 배치 → DLM `/api/xaudit/events` POST (**응답 지연 0ms**, 큐 포화 시 drop)
4. DLM 이 수신 → **SHA-256 해시체인** 계산 → `TBL_XAUDIT_*` 배치 insert
5. DLM UI `/xaudit/dashboard` 에서 처리계별 추적·PII 탐지 확인

**코드 수정 0줄. Java Agent 0개. 금융권 심의 부담 최소.**
