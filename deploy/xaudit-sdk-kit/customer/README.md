# X-Audit SDK — 고객사 처리계 적용 가이드

Spring Boot 처리계(WAS)에 dependency 한 줄 + YAML 설정 10줄만 추가하면 접속기록·SQL 실행기록을 자동 수집하여 DLM 서버로 실시간 전송합니다.

**Mapper XML / DAO / Service 코드 수정 0 줄. 처리계 DB 스키마 변경 0.**

---

## 이 디렉토리의 용도

| 경로 | 설명 |
|------|------|
| `lib/dlm-aop-sdk-1.0.0.jar` | 처리계 classpath 에 추가할 SDK JAR (47 KB) |
| `lib/dlm-aop-sdk-1.0.0-sources.jar` | 소스 JAR (금융권 보안 검수용) |
| `snippets/pom-snippet.xml` | Maven `pom.xml` 의 `<dependencies>` 에 병합할 조각 |
| `snippets/build-snippet.gradle` | Gradle `build.gradle` 의 `dependencies` 에 병합할 조각 |
| `snippets/xaudit-config-snippet.yml` | 고객사 `application.yml` 에 병합할 YAML 설정 조각 |
| `snippets/xaudit-config-snippet.properties` | 고객사 `application.properties` 에 병합할 properties 설정 조각 |
| `snippets/README.md` | snippets 폴더 사용법 상세 (병합 예시 포함) |
| `scripts/smoke-test.sh` | DLM 서버 수신 엔드포인트 동작 확인 (처리계 적용 후 1회) |

> **snippets/ 폴더의 파일들은 모두 "병합용 조각" 입니다.** 단독 실행 불가능 — 고객사 기존 파일에 복붙(merge) 해서 사용합니다.

> DB 스키마(DDL)는 여기 없습니다. **처리계는 DB를 건드리지 않습니다.** DLM 서버 운영자가 별도로 처리합니다.

---

## 요구사항

| 항목 | 지원 |
|------|------|
| Java | 8 / 11 / 17 |
| Spring Boot | 2.x (2.3 ~ 2.7 검증) / javax.servlet |
| 데이터 접근 | MyBatis 3.5.x (필수), JdbcTemplate/JPA (DataSource-Proxy 옵션) |

> Spring Boot 3.x (jakarta) 는 Phase 2 별도 모듈로 제공 예정.

---

## 적용 3 단계

### Step 1. SDK 등록
**Maven:**
```bash
mvn install:install-file \
  -Dfile=lib/dlm-aop-sdk-1.0.0.jar \
  -DgroupId=datablocks -DartifactId=dlm-aop-sdk \
  -Dversion=1.0.0 -Dpackaging=jar
```
그 다음 `pom.xml` 의 `<dependencies>` 안에 `snippets/pom-snippet.xml` 블록 병합.

**Gradle:** `build.gradle` 의 `dependencies { }` 안에 `snippets/build-snippet.gradle` 블록 병합.

### Step 2. 설정 파일 병합

고객사가 YAML 을 쓰면 → `snippets/xaudit-config-snippet.yml` 의 `xaudit:` 섹션을 `application.yml` 에 병합
고객사가 properties 를 쓰면 → `snippets/xaudit-config-snippet.properties` 의 `xaudit.*` 라인을 `application.properties` 에 병합

**최소 3줄만으로 동작 가능** (나머지는 기본값):
```yaml
xaudit:
  service-name: LOAN_CORE
  server:
    url: https://dlm.bank.internal:8443/api/xaudit/events
```

> snippets 파일들 상단의 상세 주석과 `snippets/README.md` 의 병합 예시를 참조하세요.

### Step 3. 처리계 재기동
로그에 다음이 찍히면 정상:
```
INFO  [X-Audit] activated: service=LOAN_CORE, server=https://..., queue=10000
INFO  [X-Audit] MyBatis interceptor registered on all SqlSessionFactory beans
INFO  [X-Audit] HTTP sender started (workers=1, url=...)
```

### 확인
```bash
./scripts/smoke-test.sh https://dlm.bank.internal:8443
```
`{"inserted":2,"success":true,"received":2}` 응답 + DLM UI `/xaudit/dashboard` 에서 수신 건수 확인.

---

## 사용자 식별 우선순위

1. `xaudit.user.header` — 게이트웨이/WAF가 `X-User-Id` 같은 헤더로 주입
2. `xaudit.user.session-attribute` — 세션 속성 (예: `LOGIN_USER`)
3. Spring Security `SecurityContextHolder` (기본 true)
4. `HttpServletRequest.getRemoteUser()` / `getUserPrincipal()`
5. 최종 fallback → `"anonymous"`

특수한 세션 구조는 `XauditUserResolver.CustomResolver` 빈 주입으로 커스터마이즈.

---

## 동작 원리

```
[처리계 WAS]
  XauditAccessFilter (Servlet Filter)
    → 요청 UUID, 사용자, IP, 메뉴, 세션 → TTL ThreadLocal
  XauditMybatisInterceptor (MyBatis Plugin)
    → BoundSql 에서 실제 SQL + bind params 추출
  XauditJdbcQueryListener (DataSource-Proxy, 선택)
    → JdbcTemplate/Batch 사각지대 커버
       ↓ BlockingQueue (10 K) → 배치 100 건 / 3초 → gzip + JSON
  HTTP POST → https://dlm.../api/xaudit/events
```

### 성능·안정성 보장
- **응답 지연 0ms**: 수집 실패/전송 실패는 큐에 drop + warn. 비즈니스 흐름 0 영향
- **비동기**: 전용 daemon thread 1~8개. HikariCP·Tomcat·@Async 어느 스레드든 컨텍스트 전파
- **서버 장애 대응**: HTTP 3회 재시도(exponential backoff) 후 drop. 복구 후 자동 재개
- **큐 포화 대응**: `queue-capacity` 초과 시 drop. 메모리 폭주 불가

---

## 주요 설정

| 키 | 기본값 | 설명 |
|----|--------|------|
| `xaudit.enabled` | `true` | 비상 시 `false` 로 즉시 비활성화 (재기동 필요) |
| `xaudit.service-name` | `UNKNOWN` | 처리계 식별자 |
| `xaudit.server.url` | `http://dlm.internal:8080/api/xaudit/events` | DLM 수집 서버 |
| `xaudit.batch.queue-capacity` | `10000` | 큐 용량 (초과 시 drop) |
| `xaudit.batch.size` | `100` | 배치 크기 |
| `xaudit.batch.flush-interval-ms` | `3000` | 강제 flush 주기 |
| `xaudit.user.header` | `""` | 게이트웨이 주입 사용자 ID 헤더 |
| `xaudit.user.session-attribute` | `""` | 세션 속성 키 |
| `xaudit.user.use-security-context` | `true` | Spring Security 연동 |
| `xaudit.menu.header` | `X-Menu-Id` | 메뉴 ID 헤더 |
| `xaudit.menu.uri-prefix-map` | (빈) | URI prefix → 메뉴ID 매핑 |
| `xaudit.sql.max-text-length` | `8000` | SQL 본문 최대 길이 |
| `xaudit.sql.comment-injection` | `false` | DAM 연계용 SQL 주석 prepend (고정값만) |
| `xaudit.sql.mask-patterns` | `JUMIN,CARD,ACCOUNT` | PII 자동 탐지 유형 |
| `xaudit.oracle.set-client-info` | `false` | V$SESSION.CLIENT_IDENTIFIER 자동 세팅 (Oracle만) |
| `xaudit.exclude-uri-patterns` | `/health,/actuator,...` | 수집 제외 URI |

---

## FAQ

**Q. 처리계 DB에 테이블이 생기나?** 아니요. SDK는 HTTP POST만 합니다. 처리계 DB는 절대 건드리지 않습니다.

**Q. 수집 서버가 장애나면?** 큐에 쌓이다가 포화 시 drop + warn. **비즈니스 응답은 전혀 지연되지 않습니다.**

**Q. 비밀번호·주민번호 평문 저장?** 정규식 탐지가 기본 활성. `pii_detected` 컬럼에 유형만 기록, 원문 저장을 막으려면 `mask-patterns` 활용.

**Q. `@Async` 에서 사용자 식별?** 네. Alibaba TransmittableThreadLocal로 스레드풀 재사용 시에도 컨텍스트 전파. 별도 Executor 쓰면 `XauditTaskDecorator` 주입.

**Q. 기존 APM (제니퍼/핀포인트) 충돌?** 없음. X-Audit 는 **Java Agent 가 아니라 순수 라이브러리**. APM Agent 와 메커니즘이 달라 간섭 없음.

**Q. 제거하려면?** `xaudit.enabled=false` + 재기동. 완전 제거는 dependency 삭제.

---

## 운영 체크리스트

- [ ] SDK JAR 사내 Nexus 업로드 또는 로컬 설치
- [ ] `application.yml` 에 `service-name` + `server.url` 설정
- [ ] 재기동 후 `[X-Audit] activated` 로그 확인
- [ ] `scripts/smoke-test.sh` 성공
- [ ] DLM 운영팀과 협의: DLM UI `/xaudit/dashboard` 에서 처리계별 수신 확인됨
- [ ] 부하 테스트 (100+ TPS 시 `queue-capacity` 상향 검토)
- [ ] Oracle 환경: `oracle.set-client-info=true` + HikariCP `connectionInitSql=BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;`
- [ ] 기존 DAM(DBSAFER/PSM) 연계 시 `sql.comment-injection=true`

---

**버전**: 1.0.0 (2026-04-20) · **타겟**: Java 8 · Spring Boot 2.x · javax.servlet
