# 접속기록 AI 분석 엔진 — DLM-Privacy-AI 확장 설계서

> 작성일: 2026-04-10
> 버전: v1.1
> 로드맵 위치: Phase 3-B (Privacy Monitor AI 이상행위 탐지)

---

## 1. 개요

### 1.1 목적

다양한 채널(PSM Agent, Application SDK, DB Audit Log)로 수집된 접속기록(TBL_ACCESS_LOG)을 DLM-Privacy-AI에서 AI 기반으로 분석하여 **이상행위 탐지**, **사용자 위험도 스코어링**, **접근 패턴 요약**을 수행한다.

### 1.2 현재 상태 (As-Is)

```
WAS (-javaagent)                    DLM Server                    DLM-Privacy-AI
┌────────────────┐    HTTP POST    ┌──────────────────┐          ┌──────────────────┐
│ PSM Java Agent │ ──────────────► │ AgentApiController│          │ PII 탐지만 수행   │
│ (ByteBuddy BCI)│  /api/agent/logs│ → TBL_ACCESS_LOG │          │ (detect API)     │
└────────────────┘                 └──────────────────┘          └──────────────────┘
```

- **PSM Agent**: WAS JVM에 `-javaagent`로 주입, JDBC 바이트코드 가로채기로 SQL 캡처 → 3초마다 500건 배치 전송
- **DLM Server**: `TBL_ACCESS_LOG`에 해시 체인과 함께 적재 완료
- **Privacy-AI**: PII 컬럼 탐지(`/api/v1/privacy/detect`)만 구현, **접속기록 분석 기능 없음**
- **Application SDK**: 미구현 (BCI 불가 환경을 위한 대안 필요)
- **DB Audit Log 파싱**: 설계만 완료 (Privacy_Monitor 설계서 M1.1)

### 1.3 목표 상태 (To-Be)

```
┌──────────────────────────────────────────────────────────────────────────┐
│  채널 A: PSM Agent (BCI)           채널 B: App SDK            채널 C    │
│  ┌────────────────┐    HTTP POST   ┌──────────────┐   DB Audit│         │
│  │ ByteBuddy BCI  │──────┐         │ @AccessLog   │──┐  Log   │         │
│  │ JDBC 가로채기   │      │         │ AOP/REST API │  │  파싱   │         │
│  └────────────────┘      │         └──────────────┘  │        │         │
│                          ▼                           ▼        ▼         │
│                   ┌──────────────────────────────────────────────┐      │
│                   │           DLM Server                         │      │
│                   │  AgentApiController / AccessLogController    │      │
│                   │  → TBL_ACCESS_LOG (access_channel로 구분)    │      │
│                   │     WAS_AGENT / APP_SDK / DB_AUDIT           │      │
│                   └─────────────────┬────────────────────────────┘      │
│                                     │ 호출                               │
│                                     ▼                                    │
│                   ┌──────────────────────────────────────────────┐      │
│                   │         DLM-Privacy-AI                        │      │
│                   │  ① 이상행위 분석  ② 위험도 스코어링            │      │
│                   │  ③ 패턴 요약      ④ 통계 기반 탐지            │      │
│                   └──────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────────────────┘
```

### 1.4 업계 현황 및 전략적 포지셔닝

| 방식 | 대표 솔루션 | 시장 점유율 | SQL 전문 | 정보주체(Whom) | WAS 부담 |
|------|-----------|-----------|---------|-------------|---------|
| **BCI Agent** | WEEDS (위즈코리아) | **60%+ (1위)** | O | O (DB결과값) | 있음 |
| **WAS Agent** | TScan, PARGOS, LogCatch | 20%+ | O | O | 있음 |
| **네트워크 미러링** | 소만사, INFOSAFER | 10%+ | O | △ (제한적) | 없음 |
| **앱 자체개발** | (솔루션 없음) | 감소 추세 | △ | △ | 없음 |

**DLM 전략: 3채널 하이브리드** — 고객 환경에 따라 최적 채널을 선택할 수 있도록 3가지 수집 방식 모두 지원.

---

## 2. 접속기록 수집 — 3채널 아키텍처

### 2.1 채널 A: PSM Agent (BCI 방식) — 이미 구현 완료

JDBC 호출을 **JVM 바이트코드 변조**로 가로채는 방식. 애플리케이션 코드 수정 0줄.

```
❌ WAS 로그파일 → 파싱 → 적재 (비효율적, 로그 포맷 종속, 사용자 식별 불가)
✅ JVM 내부 JDBC 메서드를 가로채기 → 적재 (실시간, 포맷 무관, WAS 사용자 식별 가능)
```

**적용 대상**: Agent 설치 가능한 WAS (권장 방식)
**기능 수준**: ★★★★★ (SQL 전문, 정보주체, 다운로드, 응답시간 모두 수집)

### 2.2 채널 B: Application SDK (직접 코딩 방식) — 신규 개발

BCI Agent 설치가 **불가능하거나 거부하는** 고객사를 위한 대안.
개발자가 접속기록 생성 코드를 애플리케이션에 직접 삽입하되, DLM이 **공통 라이브러리와 자동화 도구**를 제공하여 누락을 최소화한다.

**적용 대상**: BCI 거부 금융사, 비-Java 환경 (REST API), 레거시 시스템
**기능 수준**: ★★★☆☆ (SQL 전문 제한적, 정보주체 식별은 개발자 구현에 의존)

#### 2.2.1 Java SDK 방식 — Spring AOP + 어노테이션

```java
// ── DLM이 제공하는 라이브러리 (dlm-accesslog-sdk.jar) ──

// 방법 1: @DlmAccessLog 어노테이션 (가장 간편)
@DlmAccessLog(table = "CUSTOMER", action = ActionType.SELECT)
@GetMapping("/customer/{id}")
public CustomerVO getCustomer(@PathVariable String id) {
    return customerService.findById(id);
}

// 방법 2: 프로그래밍 방식 (세밀한 제어)
@GetMapping("/customer/search")
public List<CustomerVO> searchCustomer(CustomerSearchDTO dto) {
    List<CustomerVO> results = customerService.search(dto);

    DlmAccessLog.builder()
        .action(ActionType.SELECT)
        .table("CUSTOMER")
        .columns("name", "ssn", "phone")          // 접근한 PII 컬럼
        .affectedRows(results.size())               // 조회 건수
        .searchCondition(dto.toString())            // 검색 조건 (Whom)
        .submit();                                   // 비동기 전송

    return results;
}

// 방법 3: AOP 자동 스캔 (Controller 전체 자동 적용)
// → DLM이 @Controller 메서드를 자동으로 AOP 포인트컷 적용
// → 개발자는 예외(제외) 대상만 @DlmAccessLogExclude로 표시
```

#### 2.2.2 REST API 방식 — 비-Java 환경 (Node.js, Python, PHP 등)

```
POST http://dlm-server:8080/api/accesslog/submit
Content-Type: application/json
X-DLM-API-Key: {api-key}

{
  "user_account": "hong_gd",
  "client_ip": "10.0.1.55",
  "action_type": "SELECT",
  "target_table": "CUSTOMER",
  "target_columns": "name,ssn,phone",
  "affected_rows": 15,
  "search_condition": "dept=영업부",
  "access_channel": "APP_SDK",
  "timestamp": "2026-04-10T14:30:00"
}
```

#### 2.2.3 SDK 아키텍처

```
애플리케이션 (WAS)
├── @DlmAccessLog 어노테이션 또는 DlmAccessLog.builder()
│         │
│         ▼
├── DlmAccessLogAspect (AOP Interceptor)
│   ├─ 사용자 자동 추출 (SecurityContext / Session / Header)
│   ├─ IP 자동 추출 (X-Forwarded-For / RemoteAddr)
│   ├─ 타임스탬프 자동 생성
│   └─ 비동기 버퍼 (LinkedBlockingQueue, 5000건)
│         │
│         ▼
├── DlmAccessLogShipper (백그라운드 스레드)
│   ├─ 5초마다 200건씩 배치 전송
│   ├─ HTTP POST /api/accesslog/submit-batch
│   └─ 전송 실패 시 로컬 파일 저장
│         │
└─────────┘
```

#### 2.2.4 SDK vs BCI Agent 비교

| 항목 | 채널 A: BCI Agent | 채널 B: SDK |
|------|-------------------|-------------|
| **코드 수정** | 없음 (JVM 옵션만) | 필요 (어노테이션/API 호출) |
| **SQL 전문 기록** | 자동 (JDBC 가로채기) | 수동 (개발자가 명시해야 함) |
| **정보주체 식별** | 자동 (DB 결과값 분석) | 수동 (개발자가 전달해야 함) |
| **다운로드 탐지** | 자동 | 수동 (`action=DOWNLOAD` 명시) |
| **누락 위험** | 없음 (100% 캡처) | 있음 (개발자 누락 가능) |
| **WAS 부담** | JVM 바이트코드 변조 | 라이브러리 의존성만 |
| **적용 대상** | Java WAS 전용 | 모든 언어/플랫폼 |
| **금융사 수용성** | 보통 (BCI 우려) | 높음 (자체 코드이므로) |

#### 2.2.5 누락 방지 전략

애플리케이션 SDK의 가장 큰 약점은 **개발자 누락**. 이를 최소화하는 장치:

| 장치 | 구현 |
|------|------|
| **AOP 자동 스캔** | `@Controller` + `@GetMapping/@PostMapping` 메서드를 자동 포인트컷 → 기본적으로 전체 로깅 |
| **제외 방식** | 로깅할 메서드를 지정(Opt-in)이 아닌, 제외할 메서드를 지정(Opt-out): `@DlmAccessLogExclude` |
| **커버리지 리포트** | DLM이 주기적으로 "접속기록이 안 남는 URL 목록"을 분석하여 관리자에게 알림 |
| **ISMS-P 증적** | SDK 적용 현황 자동 리포트 (적용 URL 수 / 미적용 URL 수 / 커버리지 %) |

### 2.3 채널 C: DB Audit Log 파싱 — Privacy Monitor 설계서 참조

대상 DB의 감사 로그를 DLM이 직접 조회하여 수집하는 방식.
상세 설계는 `Privacy_Monitor_기능개발요건설계서.md` §M1.1 참조.

**적용 대상**: WAS에 아무것도 설치 못하는 환경, DB 직접 접근 모니터링
**기능 수준**: ★★☆☆☆ (SQL은 있으나 WAS 사용자 미식별, DB 계정만 기록)

### 2.4 access_channel 컬럼 값 정의

| 값 | 수집 채널 | 설명 |
|----|----------|------|
| `WAS_AGENT` | 채널 A | PSM Java Agent (BCI) |
| `APP_SDK` | 채널 B | Application SDK (어노테이션/REST API) |
| `DB_AUDIT` | 채널 C | DB Audit Log 파싱 |
| `WEB` | DLM 자체 | DLM 웹 UI를 통한 작업 |
| `BATCH` | DLM 자체 | DLM 배치 Job 실행 |
| `API` | DLM 자체 | DLM REST API 호출 |

---

## 3. 채널 A 상세: PSM Agent BCI 동작 원리 (구현 완료)

### 3.1 핵심: JDBC 호출을 바이트코드 레벨에서 가로채기

### 3.2 구체적 실행 흐름

```
① JVM 시작 시 Agent 주입
   java -javaagent:dlm-agent-1.0.0.jar=dlm-agent.properties -jar app.jar
         │
         ▼
② ByteBuddy가 JDBC 클래스의 바이트코드를 변조 (DlmAgentMain.premain)
   ┌─────────────────────────────────────────────────────────────────────┐
   │  대상 클래스:                                                       │
   │  - java.sql.Statement       → execute(), executeQuery()            │
   │  - java.sql.Connection      → prepareStatement(sql) ← SQL 등록    │
   │  - java.sql.PreparedStatement → execute() ← SQL 조회 후 로그 생성  │
   │                                                                     │
   │  변조 방식: @Advice.OnMethodEnter / @Advice.OnMethodExit            │
   │  원래 메서드 코드 앞뒤에 가로채기 코드를 "끼워넣기"                    │
   └─────────────────────────────────────────────────────────────────────┘
         │
         ▼
③ WAS 사용자의 SQL 실행 (애플리케이션 코드 변경 없음)
   예: stmt.executeQuery("SELECT name, ssn FROM customer WHERE id = 123")
         │
         ▼
④ ByteBuddy Advice가 자동 실행
   ┌─────────────────────────────────────────────────────────────────────┐
   │ @OnMethodEnter:                                                     │
   │   startTime = System.nanoTime()                                     │
   │                                                                     │
   │ ── 원래 JDBC 코드 실행 (변경 없음) ──                                │
   │                                                                     │
   │ @OnMethodExit:                                                      │
   │   a) SQL 텍스트 캡처 (Statement: 파라미터에서, PS: WeakHashMap에서)  │
   │   b) 실행 시간 계산: (nanoTime - startTime) / 1,000,000 ms          │
   │   c) UserContextFilter의 ThreadLocal에서 사용자 정보 추출            │
   │      → userId, clientIp, sessionId                                  │
   │   d) SqlAnalyzer로 SQL 파싱 (JSqlParser, LRU 1000건 캐시)          │
   │      → actionType, targetTable, targetColumns                       │
   │   e) PiiPolicyCache에서 PII 매칭                                    │
   │      → piiTypeCodes, piiGrade                                       │
   │   f) AccessLogEntry 생성 → LogBuffer.offer() (non-blocking)         │
   └─────────────────────────────────────────────────────────────────────┘
         │
         ▼
⑤ LogShipper 데몬 스레드 (3초마다, 500건씩)
   ┌─────────────────────────────────────────────────────────────────────┐
   │ LogBuffer.drain(500)                                                │
   │   → JSON 직렬화 (Gson)                                              │
   │   → HTTP POST http://dlm-server:8080/api/agent/logs                │
   │     Header: X-Agent-Id, X-Agent-Secret                              │
   │     Body: [{"sql":"SELECT...","userId":"hong","elapsedMs":45,...}]  │
   │                                                                     │
   │ 전송 실패 시: FileFailover → /tmp/dlm-agent-failover/*.json         │
   │ 복구 후: 자동 또는 수동 재전송                                       │
   └─────────────────────────────────────────────────────────────────────┘
         │
         ▼
⑥ DLM Server 수신 및 적재
   ┌─────────────────────────────────────────────────────────────────────┐
   │ AgentApiController.receiveAgentLogs()                               │
   │   → AgentLogEntry → AccessLogVO 변환                                │
   │   → 해시 체인 생성: SHA-256(logId + user + time + action + prevHash)│
   │   → AccessLogMapper.insertAccessLogBatch()                          │
   │   → TBL_ACCESS_LOG (월별 파티션, partition_key=YYYYMMDD)            │
   └─────────────────────────────────────────────────────────────────────┘
```

### 3.3 WAS 사용자 식별 방법 (UserContextFilter)

```
HTTP 요청 수신 → UserContextFilter.doFilter()
                      │
                      ├─ ① HTTP 헤더 확인 (SSO 연동: X-User-Id 등, 설정 가능)
                      ├─ ② Session 속성 확인 (dlm.user.session-attr 설정)
                      ├─ ③ Spring Security 리플렉션 (SecurityContextHolder)
                      └─ ④ request.getRemoteUser()
                      │
                      ▼
                 UserContext.set(ThreadLocal)
                      │
                 ── 애플리케이션 로직 실행 (SQL 포함) ──
                      │
                 UserContext.clear()
```

**핵심**: 에이전트가 독립적으로 동작하며 WAS 프레임워크에 의존하지 않음.
Spring Security도 **리플렉션**으로 접근하여 agent 빌드에 Spring 의존성이 불필요.

### 3.4 PreparedStatement의 2단계 캡처

PreparedStatement는 SQL이 생성 시점에 전달되고, 실행 시점에는 전달되지 않는 특수성이 있다.

```
Stage 1 — Connection.prepareStatement(sql) 가로채기
   → WeakHashMap<PreparedStatement, String>에 SQL 저장
   → WeakHashMap이므로 PS가 GC되면 자동 정리 (메모리 누수 없음)

Stage 2 — PreparedStatement.execute*() 가로채기
   → @Advice.This로 PS 인스턴스 획득
   → WeakHashMap.get(this)으로 SQL 조회
   → 이후 Statement와 동일한 로그 생성 흐름
```

### 3.5 성능 보호 설계

| 보호 장치 | 구현 | 효과 |
|-----------|------|------|
| **Non-blocking offer** | `LinkedBlockingQueue.offer()` (put 아님) | WAS 스레드 절대 블로킹 안 됨 |
| **큐 오버플로우 시 드롭** | 큐 가득 차면 로그 버림 (dropCount 메트릭) | WAS OOM 방지 |
| **별도 데몬 스레드** | LogShipper는 daemon thread | WAS 종료 시 자동 종료 |
| **SQL 제외 패턴** | INFORMATION_SCHEMA, SHOW, PING 등 | 시스템 SQL 노이즈 제거 |
| **사용자 제외** | SYSTEM, DBA, MONITOR 등 | 시스템 계정 제외 |
| **JSqlParser LRU 캐시** | 동일 SQL 구조 재파싱 방지 (1000건) | CPU 절감 |
| **Failover 파일** | 서버 장애 시 로컬 JSON 저장 | 로그 유실 방지 |

---

## 4. AI 분석 엔진 설계

### 4.1 기능 구조

```
DLM-Privacy-AI 확장
├── A1. 접근 패턴 통계 분석 (Statistics)
│   ├── A1.1 사용자별 접근 프로파일 생성
│   ├── A1.2 시간대별/테이블별 접근 분포
│   └── A1.3 기준선(Baseline) 자동 학습
│
├── A2. 이상행위 탐지 (Anomaly Detection)
│   ├── A2.1 통계 기반 탐지 (Z-Score / IQR)
│   ├── A2.2 LLM 기반 패턴 분석
│   └── A2.3 복합 시나리오 탐지
│
├── A3. 사용자 위험도 스코어링 (Risk Score)
│   ├── A3.1 행위 기반 위험도 산출
│   ├── A3.2 PII 접근 빈도 반영
│   └── A3.3 위험도 추이 트렌드
│
└── A4. 분석 보고 (Report)
    ├── A4.1 일간/주간 분석 요약
    └── A4.2 LLM 기반 자연어 보고서
```

### 4.2 API 엔드포인트 설계

| Method | Path | 기능 | 호출 주체 |
|--------|------|------|-----------|
| POST | `/api/v1/accesslog/analyze` | 배치 이상행위 분석 실행 | DLM 스케줄러 (5분) |
| POST | `/api/v1/accesslog/analyze-realtime` | 실시간 로그 배치 분석 | DLM AgentApiController |
| GET | `/api/v1/accesslog/risk-score/{userId}` | 사용자 위험도 조회 | DLM UI |
| GET | `/api/v1/accesslog/risk-score/ranking` | 위험도 랭킹 TOP N | DLM 대시보드 |
| GET | `/api/v1/accesslog/baseline/{userId}` | 사용자 기준선 조회 | DLM UI |
| POST | `/api/v1/accesslog/summary` | 기간별 분석 요약 생성 | DLM 보고서 |
| GET | `/api/v1/accesslog/analysis-status` | 분석 엔진 상태 | DLM 관리자 |

### 4.3 데이터 흐름

```
┌─── 주기적 분석 (5분) ─────────────────────────────────────────────┐
│                                                                    │
│  DLM JobScheduler (cron 5분)                                       │
│    │                                                               │
│    │  POST /api/v1/accesslog/analyze                               │
│    │  Body: { "from": "2026-04-10T14:00:00", "to": "..." }        │
│    ▼                                                               │
│  Privacy-AI                                                        │
│    │                                                               │
│    ├─ ① MariaDB 직접 조회: TBL_ACCESS_LOG (기간 내 로그)           │
│    ├─ ② 사용자별 기준선(Baseline) 조회: TBL_ACCESSLOG_BASELINE     │
│    ├─ ③ 통계 이상 탐지 (Z-Score ≥ 3.0 또는 IQR 1.5배)            │
│    ├─ ④ LLM 분석 (의심 패턴 요약 + 위험도 판단)                    │
│    ├─ ⑤ 위험도 스코어 업데이트: TBL_ACCESSLOG_RISK_SCORE           │
│    └─ ⑥ 탐지 결과 반환 → DLM이 TBL_ACCESS_LOG_ALERT에 INSERT      │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘

┌─── 실시간 분석 (Agent 로그 수신 시) ──────────────────────────────┐
│                                                                    │
│  AgentApiController.receiveAgentLogs()                             │
│    │  TBL_ACCESS_LOG 적재 완료 후                                   │
│    │                                                               │
│    │  POST /api/v1/accesslog/analyze-realtime                      │
│    │  Body: [로그 배치 원본]                                        │
│    ▼                                                               │
│  Privacy-AI                                                        │
│    │                                                               │
│    ├─ ① 경량 룰 체크 (대량조회, 야간접근, 1급PII 등)               │
│    ├─ ② 기준선 초과 여부 빠른 판단                                  │
│    └─ ③ 의심 건만 반환 → DLM이 즉시 Alert 생성                     │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 5. 상세 기능 설계

### 5.1 A1. 접근 패턴 기준선 (Baseline)

사용자별 "정상 행위" 프로파일을 자동 학습하여 이상 탐지의 기준으로 사용한다.

#### 기준선 테이블: `TBL_ACCESSLOG_BASELINE`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `baseline_id` | BIGINT (PK, AUTO_INCREMENT) | 기준선 ID |
| `user_account` | VARCHAR(100) | 사용자 계정 |
| `metric_type` | VARCHAR(30) | 메트릭 유형 (아래 참조) |
| `time_window` | VARCHAR(10) | 시간 윈도우 (HOURLY/DAILY/WEEKLY) |
| `day_of_week` | TINYINT | 요일 (1=월~7=일, WEEKLY일 때) |
| `hour_of_day` | TINYINT | 시간대 (0~23, HOURLY일 때) |
| `avg_value` | DOUBLE | 평균값 |
| `std_value` | DOUBLE | 표준편차 |
| `min_value` | DOUBLE | 최소값 |
| `max_value` | DOUBLE | 최대값 |
| `sample_count` | INT | 학습 샘플 수 |
| `last_updated` | DATETIME | 마지막 갱신 시간 |
| `source_system_id` | VARCHAR(36) | 소스 시스템 (NULL이면 전체) |

**metric_type 종류:**

| metric_type | 설명 | 단위 |
|-------------|------|------|
| `QUERY_COUNT` | 쿼리 실행 횟수 | 건/시간 |
| `PII_ACCESS_COUNT` | PII 테이블 접근 횟수 | 건/시간 |
| `PII_GRADE1_COUNT` | 1급(고위험) PII 접근 횟수 | 건/시간 |
| `DISTINCT_TABLE_COUNT` | 접근한 고유 테이블 수 | 개/일 |
| `DOWNLOAD_COUNT` | 다운로드 횟수 | 건/일 |
| `AVG_ELAPSED_MS` | 평균 쿼리 응답시간 | ms |
| `FAIL_COUNT` | 실패한 쿼리 수 | 건/시간 |
| `DATA_VOLUME` | 조회 데이터 볼륨 (affected_rows 합) | 건/시간 |

#### 기준선 학습 알고리즘

```python
# 지수 가중 이동 평균 (EWMA) — 최근 데이터에 더 높은 가중치
def update_baseline(current_baseline, new_observation, alpha=0.3):
    """
    alpha = 0.3: 최근 값에 30% 가중치 (2주 치면 안정적)
    alpha = 0.1: 보수적 (변화 둔감, 1개월 이상 데이터 필요)
    """
    if current_baseline is None:
        return Baseline(avg=new_observation, std=0, count=1)

    new_avg = alpha * new_observation + (1 - alpha) * current_baseline.avg
    new_var = alpha * (new_observation - new_avg) ** 2 + (1 - alpha) * current_baseline.std ** 2
    new_std = math.sqrt(new_var)

    return Baseline(avg=new_avg, std=new_std, count=current_baseline.count + 1)
```

#### 기준선 갱신 스케줄

| 주기 | 대상 | 처리 |
|------|------|------|
| 매시간 | HOURLY 메트릭 | 직전 1시간 통계 → EWMA 업데이트 |
| 매일 02:00 | DAILY 메트릭 | 직전 1일 통계 → EWMA 업데이트 |
| 매주 월 03:00 | WEEKLY 메트릭 | 직전 1주 통계 → EWMA 업데이트 |
| 초기 학습 | 전체 | 최근 30일 데이터로 일괄 학습 (cold start 해소) |

### 5.2 A2. 이상행위 탐지

#### A2.1 통계 기반 탐지

```python
def detect_statistical_anomaly(user_account, metric_type, current_value, baseline):
    """
    Z-Score 기반 이상 탐지
    - |Z| ≥ 3.0: 심각 (CRITICAL) — 99.7% 신뢰구간 벗어남
    - |Z| ≥ 2.5: 높음 (HIGH)
    - |Z| ≥ 2.0: 보통 (MEDIUM)
    """
    if baseline is None or baseline.std == 0:
        return None  # 기준선 미확보

    z_score = (current_value - baseline.avg) / baseline.std

    if abs(z_score) >= 3.0:
        return AnomalyResult(severity="CRITICAL", z_score=z_score)
    elif abs(z_score) >= 2.5:
        return AnomalyResult(severity="HIGH", z_score=z_score)
    elif abs(z_score) >= 2.0:
        return AnomalyResult(severity="MEDIUM", z_score=z_score)

    return None  # 정상
```

**탐지 시나리오:**

| ID | 시나리오 | 메트릭 | 조건 | 심각도 |
|----|---------|--------|------|--------|
| S01 | 대량 쿼리 | QUERY_COUNT | Z ≥ 3.0 (시간당) | CRITICAL |
| S02 | PII 대량 접근 | PII_ACCESS_COUNT | Z ≥ 2.5 (시간당) | HIGH |
| S03 | 1급 PII 이상 접근 | PII_GRADE1_COUNT | Z ≥ 2.0 (시간당) | HIGH |
| S04 | 이례적 테이블 접근 | DISTINCT_TABLE_COUNT | Z ≥ 3.0 (일간) | MEDIUM |
| S05 | 대량 다운로드 | DOWNLOAD_COUNT | Z ≥ 2.5 (일간) | CRITICAL |
| S06 | 비정상 응답시간 | AVG_ELAPSED_MS | Z ≥ 3.0 | LOW |
| S07 | 반복 실패 | FAIL_COUNT | Z ≥ 3.0 (시간당) | HIGH |
| S08 | 데이터 대량 조회 | DATA_VOLUME | Z ≥ 3.0 (시간당) | HIGH |

#### A2.2 LLM 기반 패턴 분석

통계 탐지에서 의심 건이 발생하면 LLM에게 상세 분석을 의뢰한다.

```python
LLM_ANOMALY_SYSTEM_PROMPT = """당신은 개인정보 접속기록 보안 분석 전문가입니다.
사용자의 접속기록 패턴을 분석하여 이상행위 여부를 판단하세요.

분석 관점:
1. 업무 패턴 일탈: 평소와 다른 시간/빈도/대상
2. 정보 유출 징후: 대량 조회, 순차적 전수 조회, 다운로드 패턴
3. 권한 남용 가능성: 불필요한 고위험 PII 접근
4. 계정 도용 가능성: IP 변경, 비정상 세션

응답 형식 (JSON만):
{
  "risk_level": "CRITICAL|HIGH|MEDIUM|LOW|NORMAL",
  "confidence": 0-100,
  "findings": ["발견 사항 1", "발견 사항 2"],
  "recommendation": "조치 권고 사항",
  "summary": "종합 분석 요약 (50자 이내)"
}
"""
```

**LLM에 전달하는 컨텍스트:**

```json
{
  "user_account": "hong_gd",
  "analysis_period": "2026-04-10 14:00 ~ 15:00",
  "triggered_rules": ["S01: 대량 쿼리 (Z=3.8)", "S03: 1급 PII 접근 (Z=2.3)"],
  "current_stats": {
    "query_count": 847,
    "pii_access_count": 312,
    "pii_grade1_count": 45,
    "distinct_tables": 12,
    "top_tables": ["CUSTOMER", "ACCOUNT", "CARD_INFO"],
    "action_distribution": {"SELECT": 820, "UPDATE": 27},
    "unique_ips": ["10.0.1.55"]
  },
  "baseline": {
    "query_count_avg": 120,
    "query_count_std": 35,
    "pii_access_avg": 40,
    "usual_hours": "09:00-18:00",
    "usual_tables": ["CUSTOMER", "ORDER"]
  },
  "recent_alerts": ["2026-04-08: 대량 다운로드 (소명 완료)"]
}
```

#### A2.3 복합 시나리오 탐지

단일 룰이 아닌, 복수 조건의 조합으로 고도화된 탐지:

| 복합 시나리오 | 조건 조합 | 위험도 |
|-------------|----------|--------|
| **정보 유출 의심** | 야간 접근 + 대량 조회 + 1급 PII + 다운로드 | CRITICAL |
| **계정 도용 의심** | 새로운 IP + 비정상 시간 + 이례적 테이블 | CRITICAL |
| **내부자 위협** | 퇴직 예정자 + PII 접근 급증 + 대량 다운로드 | CRITICAL |
| **권한 남용** | 타 부서 테이블 + 반복 조회 + 업무외 시간 | HIGH |
| **탐색적 접근** | 다수 테이블 순회 + 소량씩 조회 + 새로운 테이블 | MEDIUM |

### 5.3 A3. 사용자 위험도 스코어링

#### 위험도 테이블: `TBL_ACCESSLOG_RISK_SCORE`

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `score_id` | BIGINT (PK, AUTO_INCREMENT) | 스코어 ID |
| `user_account` | VARCHAR(100) | 사용자 계정 |
| `risk_score` | INT | 위험도 점수 (0~100) |
| `risk_level` | VARCHAR(10) | CRITICAL/HIGH/MEDIUM/LOW/NORMAL |
| `score_breakdown` | JSON | 항목별 점수 상세 |
| `trend` | VARCHAR(10) | RISING/STABLE/DECLINING |
| `alert_count_30d` | INT | 최근 30일 알림 건수 |
| `last_alert_time` | DATETIME | 최근 알림 시간 |
| `calculated_at` | DATETIME | 산출 시간 |

#### 위험도 산출 공식

```python
def calculate_risk_score(user_account, period_days=30):
    """
    위험도 = Σ(항목별 점수 × 가중치) / Σ(가중치)
    범위: 0 (안전) ~ 100 (위험)
    """
    factors = {
        # 항목                          가중치    점수 산출
        "alert_frequency":      (0.25,  alert_count_30d / threshold * 100),
        "pii_grade1_ratio":     (0.20,  grade1_access / total_access * 100),
        "off_hours_ratio":      (0.15,  offhours_count / total_count * 100),
        "volume_deviation":     (0.15,  avg_z_score / 3.0 * 100),
        "unclarified_alerts":   (0.15,  pending_clarification / total_alerts * 100),
        "table_diversity":      (0.10,  new_tables_ratio * 100),
    }

    total = sum(score * weight for weight, score in factors.values())
    total_weight = sum(weight for weight, _ in factors.values())

    return min(100, max(0, int(total / total_weight)))
```

**위험도 등급:**

| 점수 | 등급 | 의미 | 조치 |
|------|------|------|------|
| 80~100 | CRITICAL | 즉시 대응 필요 | 자동 알림 + 소명 요청 |
| 60~79 | HIGH | 면밀 모니터링 필요 | 관리자 알림 |
| 40~59 | MEDIUM | 주의 관찰 | 주간 보고서 포함 |
| 20~39 | LOW | 경미한 이상 | 월간 보고서 포함 |
| 0~19 | NORMAL | 정상 | 기록만 |

---

## 6. DLM-Privacy-AI 코드 구조 설계

### 6.1 신규 파일 구조

```
DLM-Privacy-AI/
├── app/
│   ├── main.py                          # 기존 (router 추가)
│   ├── config.py                        # 기존 (DB 설정 추가)
│   ├── database.py                      # [신규] SQLAlchemy async 세션
│   │
│   ├── routers/
│   │   ├── privacy.py                   # 기존 (PII 탐지)
│   │   └── accesslog.py                 # [신규] 접속기록 분석 API
│   │
│   ├── services/
│   │   ├── llm_service.py               # 기존 (PII 탐지용 LLM)
│   │   ├── accesslog_analyzer.py        # [신규] 이상행위 분석 엔진
│   │   ├── baseline_service.py          # [신규] 기준선 학습/관리
│   │   ├── risk_scorer.py               # [신규] 위험도 스코어링
│   │   └── anomaly_llm_service.py       # [신규] 이상행위 LLM 분석
│   │
│   ├── schemas/
│   │   ├── detect.py                    # 기존 (PII 탐지)
│   │   └── accesslog.py                 # [신규] 접속기록 분석 스키마
│   │
│   ├── models/
│   │   └── accesslog.py                 # [신규] SQLAlchemy 모델
│   │
│   └── repositories/
│       └── accesslog_repo.py            # [신규] DB 조회 레포지토리
```

### 6.2 핵심 모듈 역할

| 모듈 | 역할 | 의존성 |
|------|------|--------|
| `accesslog.py` (router) | API 엔드포인트, 요청/응답 처리 | analyzer, risk_scorer |
| `accesslog_analyzer.py` | 분석 오케스트레이션 (통계+LLM 조합) | baseline, anomaly_llm, repo |
| `baseline_service.py` | EWMA 기준선 학습/갱신/조회 | repo |
| `risk_scorer.py` | 위험도 점수 산출 | repo |
| `anomaly_llm_service.py` | LLM 기반 이상패턴 상세 분석 | llm_service (기존 클라이언트 재사용) |
| `accesslog_repo.py` | TBL_ACCESS_LOG 집계 쿼리 | database (SQLAlchemy) |

### 6.3 DLM Server 연동 변경점

| 파일 (DLM) | 변경 내용 |
|------------|-----------|
| `AgentApiController.java` | 로그 적재 후 Privacy-AI `/analyze-realtime` 비동기 호출 추가 |
| `JobScheduler.java` | 5분 주기 배치로 Privacy-AI `/analyze` 호출 추가 |
| `PrivacyAiClient.java` | 분석 API 호출 메서드 추가 |
| `AccessLogService.java` | AI 분석 결과 → TBL_ACCESS_LOG_ALERT INSERT 로직 추가 |
| `accesslog.jsp` (대시보드) | 위험도 랭킹, AI 분석 결과 표시 영역 추가 |

---

## 7. DB 설계

### 7.1 신규 테이블

#### `TBL_ACCESSLOG_BASELINE` (기준선)

```sql
CREATE TABLE COTDL.TBL_ACCESSLOG_BASELINE (
    baseline_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_account      VARCHAR(100)  NOT NULL,
    metric_type       VARCHAR(30)   NOT NULL,
    time_window       VARCHAR(10)   NOT NULL DEFAULT 'HOURLY',
    day_of_week       TINYINT       DEFAULT NULL,
    hour_of_day       TINYINT       DEFAULT NULL,
    avg_value         DOUBLE        NOT NULL DEFAULT 0,
    std_value         DOUBLE        NOT NULL DEFAULT 0,
    min_value         DOUBLE        NOT NULL DEFAULT 0,
    max_value         DOUBLE        NOT NULL DEFAULT 0,
    sample_count      INT           NOT NULL DEFAULT 0,
    source_system_id  VARCHAR(36)   DEFAULT NULL,
    last_updated      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_baseline (user_account, metric_type, time_window, day_of_week, hour_of_day, source_system_id),
    INDEX idx_user (user_account),
    INDEX idx_updated (last_updated)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### `TBL_ACCESSLOG_RISK_SCORE` (위험도)

```sql
CREATE TABLE COTDL.TBL_ACCESSLOG_RISK_SCORE (
    score_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_account      VARCHAR(100)  NOT NULL,
    risk_score        INT           NOT NULL DEFAULT 0,
    risk_level        VARCHAR(10)   NOT NULL DEFAULT 'NORMAL',
    score_breakdown   JSON          DEFAULT NULL,
    trend             VARCHAR(10)   DEFAULT 'STABLE',
    alert_count_30d   INT           NOT NULL DEFAULT 0,
    last_alert_time   DATETIME      DEFAULT NULL,
    calculated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user (user_account),
    INDEX idx_risk_level (risk_level),
    INDEX idx_score (risk_score DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### `TBL_ACCESSLOG_ANALYSIS_LOG` (분석 실행 이력)

```sql
CREATE TABLE COTDL.TBL_ACCESSLOG_ANALYSIS_LOG (
    analysis_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    analysis_type     VARCHAR(20)   NOT NULL,  -- BATCH / REALTIME
    period_from       DATETIME      NOT NULL,
    period_to         DATETIME      NOT NULL,
    log_count         INT           NOT NULL DEFAULT 0,
    anomaly_count     INT           NOT NULL DEFAULT 0,
    users_analyzed    INT           NOT NULL DEFAULT 0,
    llm_used          BOOLEAN       NOT NULL DEFAULT FALSE,
    llm_tokens        INT           DEFAULT 0,
    elapsed_ms        INT           NOT NULL DEFAULT 0,
    status            VARCHAR(10)   NOT NULL DEFAULT 'SUCCESS',
    error_message     TEXT          DEFAULT NULL,
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created (created_at),
    INDEX idx_type (analysis_type, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 8. 개발 단계

### Phase 1: 통계 기반 분석 (2주)

| 순서 | 작업 | 설명 |
|------|------|------|
| 1 | DDL 실행 | 3개 신규 테이블 생성 |
| 2 | `database.py` | SQLAlchemy async 세션 설정 |
| 3 | `models/accesslog.py` | ORM 모델 정의 |
| 4 | `accesslog_repo.py` | TBL_ACCESS_LOG 집계 쿼리 (사용자별, 시간별, 메트릭별) |
| 5 | `baseline_service.py` | EWMA 기준선 학습 + 갱신 로직 |
| 6 | `accesslog_analyzer.py` | Z-Score 이상 탐지 엔진 |
| 7 | `risk_scorer.py` | 위험도 스코어 산출 |
| 8 | `accesslog.py` (router) | API 엔드포인트 구현 |
| 9 | DLM `PrivacyAiClient` | 분석 API 호출 메서드 추가 |
| 10 | DLM `JobScheduler` | 5분 배치 + 기준선 갱신 스케줄 추가 |

### Phase 2: LLM 기반 분석 (1주)

| 순서 | 작업 | 설명 |
|------|------|------|
| 11 | `anomaly_llm_service.py` | 이상행위 LLM 프롬프트 + 분석 서비스 |
| 12 | `accesslog_analyzer.py` 확장 | 통계 탐지 → LLM 연계 파이프라인 |
| 13 | 복합 시나리오 룰 | 다중 조건 조합 탐지 |
| 14 | `/analyze-realtime` | 실시간 분석 API (경량 버전) |

### Phase 3: Application SDK (1.5주)

| 순서 | 작업 | 설명 |
|------|------|------|
| 15 | `dlm-accesslog-sdk` 모듈 생성 | DLM Gradle 서브프로젝트 (Java 11 타겟, dlm-agent와 동일) |
| 16 | `@DlmAccessLog` 어노테이션 | 어노테이션 + AOP Aspect 구현 |
| 17 | `DlmAccessLog.builder()` | 프로그래밍 방식 API |
| 18 | SDK 비동기 버퍼 + Shipper | Agent와 동일 패턴 (LinkedBlockingQueue + HTTP 배치 전송) |
| 19 | `AccessLogController.java` | SDK 전용 수신 API (`POST /api/accesslog/submit-batch`) |
| 20 | REST API 수신 | 비-Java 환경용 범용 REST 엔드포인트 |
| 21 | SDK 커버리지 리포트 | 미적용 URL 탐지 + 관리자 알림 |

### Phase 4: DLM UI 연동 (1주)

| 순서 | 작업 | 설명 |
|------|------|------|
| 22 | DLM `AgentApiController` | 실시간 분석 비동기 호출 연동 |
| 23 | 대시보드 위험도 위젯 | 위험 사용자 TOP 10, 위험도 추이 차트 |
| 24 | 분석 결과 상세 UI | AI 분석 결과, 소명 연계 |
| 25 | 분석 보고서 API | 기간별 요약 + LLM 자연어 보고서 |
| 26 | 수집 채널별 현황 | WAS_AGENT / APP_SDK / DB_AUDIT 채널별 통계 |

---

## 9. config.py 확장 설계

```python
class Settings(BaseSettings):
    # ... 기존 설정 유지 ...

    # Access Log Analysis
    analysis_enabled: bool = True
    analysis_batch_interval_min: int = 5
    analysis_z_score_critical: float = 3.0
    analysis_z_score_high: float = 2.5
    analysis_z_score_medium: float = 2.0
    analysis_baseline_alpha: float = 0.3        # EWMA 가중치
    analysis_baseline_min_samples: int = 10      # 최소 학습 샘플
    analysis_llm_enabled: bool = False           # LLM 분석 활성화 (별도)
    analysis_realtime_enabled: bool = True       # 실시간 분석 활성화
    analysis_risk_score_interval_min: int = 60   # 위험도 갱신 주기
```

---

## 10. 수정 파일 목록 (전체)

### DLM-Privacy-AI (Python)

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `app/main.py` | 수정 | accesslog router 등록, DB 초기화 |
| `app/config.py` | 수정 | 분석 설정 추가 |
| `app/database.py` | **신규** | SQLAlchemy async 세션 |
| `app/routers/accesslog.py` | **신규** | 7개 API 엔드포인트 |
| `app/services/accesslog_analyzer.py` | **신규** | 이상행위 분석 오케스트레이터 |
| `app/services/baseline_service.py` | **신규** | EWMA 기준선 학습/관리 |
| `app/services/risk_scorer.py` | **신규** | 위험도 스코어링 |
| `app/services/anomaly_llm_service.py` | **신규** | LLM 이상행위 분석 |
| `app/schemas/accesslog.py` | **신규** | 요청/응답 스키마 |
| `app/models/accesslog.py` | **신규** | SQLAlchemy ORM 모델 |
| `app/repositories/accesslog_repo.py` | **신규** | DB 집계 쿼리 |

### DLM Server (Java)

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `PrivacyAiClient.java` | 수정 | 분석 API 호출 메서드 추가 |
| `AgentApiController.java` | 수정 | 실시간 분석 비동기 호출 |
| `AccessLogController.java` | **신규** | SDK 전용 로그 수신 API |
| `JobScheduler.java` | 수정 | 배치 분석 + 기준선 갱신 스케줄 |
| `AccessLogService.java` | 수정 | AI 분석 결과 → Alert 저장, SDK 로그 처리 |

### DLM Application SDK (`dlm-accesslog-sdk` 서브프로젝트)

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `build.gradle` | **신규** | Java 11 타겟, Spring AOP 의존성 |
| `DlmAccessLog.java` | **신규** | 어노테이션 정의 |
| `DlmAccessLogExclude.java` | **신규** | 제외 어노테이션 |
| `DlmAccessLogAspect.java` | **신규** | AOP Aspect (사용자/IP 자동 추출) |
| `DlmAccessLogBuilder.java` | **신규** | 프로그래밍 방식 API |
| `DlmAccessLogBuffer.java` | **신규** | 비동기 버퍼 (LinkedBlockingQueue) |
| `DlmAccessLogShipper.java` | **신규** | HTTP 배치 전송 (5초/200건) |
| `DlmAccessLogConfig.java` | **신규** | SDK 설정 (dlm-accesslog.properties) |

### DDL

| 파일 | 설명 |
|------|------|
| `ACCESSLOG_AI_DDL_DEPLOY.sql` | 3개 신규 테이블 DDL |

---

## 11. 경쟁 솔루션 대비 차별점

### 11.1 수집 방식 비교

| 솔루션 | 수집 방식 | DLM 차별점 |
|--------|----------|-----------|
| WEEDS (위즈코리아) | BCI 단일 | **3채널 하이브리드** (BCI + SDK + DB Audit) |
| TScan (엔소프) | WAS Agent 단일 | SDK 대안으로 BCI 거부 고객 대응 가능 |
| INFOSAFER (피앤피) | 네트워크 단일 | BCI의 정보주체 식별 + 네트워크의 무부담 양쪽 장점 |
| 소만사 | 프록시 + Agent | 비-Java REST API로 전 플랫폼 지원 |

### 11.2 AI 분석 비교

| 솔루션 | 이상 탐지 방식 | DLM 차별점 |
|--------|--------------|-----------|
| WEEDS | AI 이상행위 탐지 (상세 미공개) | **오픈 LLM 기반** 자연어 분석 (이유를 설명함) |
| SEECLID (삼오) | 지도+비지도 학습 | **EWMA 기준선 자동 학습** + LLM 하이브리드 |
| UBI SAFER (이지서티) | AI 위험도 측정 | **위험도 스코어링 공식 투명 공개** (설명 가능한 AI) |
| Chakra Max | 룰 기반 + 임계치 고정 | **사용자별 개인화 기준선** (고정 임계치 아님) |

### 11.3 금융사 대응 전략

| 고객 유형 | 권장 채널 | 설득 포인트 |
|----------|----------|-----------|
| BCI 수용 가능 | 채널 A (PSM Agent) | 100% 누락 없음, 정보주체 식별, ISMS-P 완벽 대응 |
| BCI 거부 (보수적 금융사) | 채널 B (SDK) | 자체 코드이므로 통제 가능, AOP Opt-out으로 누락 최소화 |
| WAS 접근 불가 | 채널 C (DB Audit) | WAS 무관, DB만 있으면 수집 가능 |
| 단계적 도입 | C → B → A | DB Audit로 시작 → SDK 보완 → Agent로 고도화 |

---

*본 문서는 DLM Privacy Platform Phase 3-B (AI 이상행위 탐지 + 3채널 수집) 구현을 위한 상세 설계서입니다.*
*상위 요건: Privacy_Monitor_기능개발요건설계서.md → M1 수집 + M3.2 이상행위 탐지 (통계/AI)*
