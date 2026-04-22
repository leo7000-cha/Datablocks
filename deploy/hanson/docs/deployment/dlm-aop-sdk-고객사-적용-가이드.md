# dlm-aop-sdk 고객사 적용 가이드

> 고객사 기간계/정보계/채널계 WAS 에 dlm-aop-sdk 를 배포하여
> 접속기록·SQL 수집을 DLM 서버로 송신하는 절차를 정리한 문서.
> (JB우리캐피탈 등 프로젝트 적용 시 체크리스트)

---

## 0. 왜 필요한가

**법적 요구사항의 99%는 "실제 개인정보를 취급하는 시스템"의 접속기록이다.**

- DLM 자체 WAS → 내장 AOP 로 관리자 감사 (보조)
- **고객사 기간계 WAS (여신/채권/고객관리 등)** → **dlm-aop-sdk** 로 현업 사용자 감사 (핵심)
- 직접 DB 접속 Tool (SQL*Plus/TOAD) → dlm-agent (옵션)

JB우리캐피탈 "점검현황" 엑셀의 핵심 항목 — 고객관리/채권상담 화면 접근이력, 과다조회자 점검, 다운로드 사유 확인 — 은 **모두 기간계 WAS 로그가 있어야 충족 가능.**

---

## 1. 고객사 적용 절차 (5단계)

### STEP 1 — SDK 파일 전달
고객사 인프라팀에 아래 jar 전달:

| 파일 | 용도 | 크기 |
|---|---|---|
| `dlm-aop-sdk-1.0.0.jar` | SDK 본체 | ~150 KB |
| `dlm-aop-sdk-1.0.0-sources.jar` | 소스 (보안검토용) | ~80 KB |
| `transmittable-thread-local-2.14.5.jar` | 유일한 외부 의존성 | ~80 KB |

→ 본체 2개 jar + 의존성 1개. 총 ~300KB.

### STEP 2 — 기간계 WAS build 파일에 dependency 추가

**Gradle**:
```gradle
dependencies {
    implementation 'datablocks:dlm-aop-sdk:1.0.0'
    implementation 'com.alibaba:transmittable-thread-local:2.14.5'
}
```

**Maven**:
```xml
<dependency>
    <groupId>datablocks</groupId>
    <artifactId>dlm-aop-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>transmittable-thread-local</artifactId>
    <version>2.14.5</version>
</dependency>
```

**빌드 툴 없이 jar 직접 배포**도 가능 (`WEB-INF/lib/` 에 jar 복사).

→ **고객사 소스코드 수정: 0줄**

### STEP 3 — `application.properties` 설정 추가

```properties
# ========= X-Audit SDK 활성화 =========
xaudit.enabled=true
xaudit.service-name=LOAN                               # 시스템 식별자 (여신/카드/채권 등)

# ========= DLM 수집 서버 =========
xaudit.server.url=http://10.x.x.x:8080/api/xaudit/events
xaudit.server.api-key=XXXXXXXXXXXX                     # DLM에서 발급받은 인증키
xaudit.server.connect-timeout-ms=2000
xaudit.server.read-timeout-ms=5000

# ========= 사용자 식별 방식 (고객사 인증체계에 맞춰 택1) =========
xaudit.user.use-security-context=true                  # Spring Security 사용 시
# xaudit.user.session-attribute=USER_ID                # 기존 세션키 사용 시
# xaudit.user.header=X-User-Id                         # 게이트웨이 헤더 사용 시

# ========= 메뉴 식별 =========
# [방식 A] 프런트엔드가 헤더로 메뉴ID 전송하는 경우 (최우선, 권장)
#   xaudit.menu.header=X-Menu-Id
#
# [방식 B] URI prefix 로 역추론 (프런트 수정 없음 — 대부분 이 방식 사용)
#   헤더 설정은 생략 가능. 기본값(X-Menu-Id)이 있지만 고객사가 해당 헤더를
#   안 보내면 자동으로 URI 매핑으로 fallback 하므로 동작에 차이 없음.
xaudit.menu.uri-prefix-map.여신심사=/loan/review/
xaudit.menu.uri-prefix-map.대출상담=/loan/apply/
xaudit.menu.uri-prefix-map.고객관리=/cust/mgmt/
xaudit.menu.uri-prefix-map.채권상담=/collection/
xaudit.menu.uri-prefix-map.신용조회=/credit/inquiry/

# ========= SQL 수집 옵션 =========
xaudit.sql.capture-text=true
xaudit.sql.capture-bind-params=true
xaudit.sql.max-text-length=8000
xaudit.sql.mask-patterns=JUMIN,CARD,ACCOUNT            # 자동 마스킹 대상

# ========= Oracle (선택) =========
xaudit.oracle.set-client-info=true                     # V$SESSION.CLIENT_IDENTIFIER 세팅 → DAM 연계

# ========= 성능 보호 (기본값 적정) =========
xaudit.batch.queue-capacity=10000                      # 폭주 시 DROP — 서비스 영향 zero
xaudit.batch.size=100
xaudit.batch.flush-interval-ms=3000
xaudit.batch.worker-threads=1

# ========= 제외 경로 =========
xaudit.exclude-uri-patterns=/health,/actuator,/css/,/js/,/images/,/favicon
```

### STEP 4 — 네트워크 방화벽 허용

| 출발지 | 목적지 | 포트/프로토콜 | 방향 |
|---|---|---|---|
| 고객사 기간계 WAS | DLM 서버 | TCP 8080 (HTTP) 또는 HTTPS | **단방향** |

→ 고객사 네트워크팀에 **기간계 → DLM 단방향 HTTP(S) 허용** 신청.
   역방향 통신 없음.

### STEP 5 — 재기동 및 검증

```bash
# 1. WAS 재기동
# 2. 기동 로그 확인 (INFO 레벨)
[X-Audit] activated: service=LOAN, server=http://dlm..., queue=10000
[X-Audit] MyBatis interceptor registered on all SqlSessionFactory beans
```

→ DLM 접속기록 화면에서 `collectType=WAS_SDK`, `sourceSystemId=LOAN` 이벤트 수신 확인.

---

## 2. SDK가 자동 수집하는 항목

| 수집 레이어 | 기술 | 잡는 대상 | 활성 조건 |
|---|---|---|---|
| **Servlet Filter** (`XauditAccessFilter`) | `FilterRegistrationBean` 자동 등록 | 모든 HTTP 요청 URL, User, IP, 메뉴 | 기본 활성 |
| **MyBatis Interceptor** (`XauditMybatisInterceptor`) | SqlSessionFactory 런타임 부착 | 모든 MyBatis SQL + 바인딩 파라미터 | MyBatis 있을 때 자동 |
| **DataSource-Proxy Listener** | `net.ttddyy.dsproxy` 감지 시 | 네이티브 JDBC SQL | 고객사가 dsProxy 쓸 때 자동 |
| **Oracle ClientInfo** | `V$SESSION.CLIENT_IDENTIFIER` 세팅 | DBSAFER/PSM DAM 장비에 사용자 식별 주입 | `xaudit.oracle.set-client-info=true` |

---

## 3. 고객사 저항 포인트 & 대응 논거

| 우려 | 대응 |
|---|---|
| **성능 영향은?** | Queue 비동기 + DROP-on-overflow. 큐 가득차면 로그만 버림, **비즈니스는 절대 안 막힘** |
| **장애 시 서비스 죽는가?** | HTTP 전송 실패해도 WAS 무관 (별도 데몬 스레드). 타임아웃 2초/5초 |
| **소스 수정해야 하나?** | **0줄**. jar + properties 만 |
| **JVM 옵션 변경?** | 없음. Spring Boot Auto-Config 가 기동 |
| **재기동 필수?** | 1회 필수. 이후 `xaudit.*` 핫리로드 불가 |
| **기존 DAM 장비와 충돌?** | SQL Comment Injection + Oracle ClientInfo 로 **DAM 패킷에 사용자 정보 주입** → 오히려 보완 |
| **개인정보 원문 전송 우려** | `xaudit.sql.mask-patterns=JUMIN,CARD,ACCOUNT` 자동 마스킹. SQL 본문·바인딩값 모두 전송 전 치환 |

---

## 4. 사전 확인 체크리스트 (고객사 미팅 전 수집)

### 4.1 WAS 환경
- [ ] Spring Boot 버전 (2.x / 3.x 모두 지원, Java 8 이상)
- [ ] Servlet API (javax / jakarta) — SDK 자동 감지
- [ ] MyBatis 사용 여부 → 사용하면 SQL 수집 자동 활성
- [ ] DataSource-Proxy 사용 여부 → 사용하면 JDBC 수집 자동 활성

### 4.2 인증 체계 (`xaudit.user.*` 결정)
- [ ] Spring Security 사용 → `use-security-context=true`
- [ ] 세션 기반 → 세션 attribute 키명 확인 (예: `USER_ID`, `LOGIN_ID`)
- [ ] 게이트웨이/SSO → 전달 헤더명 확인 (예: `X-User-Id`)
- [ ] 부서/직무 정보가 사용자 객체 어디에 있는지 — 과다조회자 점검용

### 4.3 메뉴 체계 (`xaudit.menu.*` 매핑)
- [ ] **대부분 프로젝트는 방식 B (URI prefix) 사용** — 헤더 설정 불필요
- [ ] 고객사로부터 **"화면별 URL 패턴표"** 수령 → `xaudit.menu.uri-prefix-map.*` 에 그대로 옮겨 적음
- [ ] 예외) 고객사 프런트엔드에서 이미 메뉴 헤더(예: `X-Menu-Id`)를 전송 중이면 방식 A 도 가능

### 4.4 DB 환경
- [ ] DBMS 종류 (Oracle / MySQL / PostgreSQL / MariaDB)
- [ ] Oracle이면 DAM 장비 연계 필요 여부 → `xaudit.oracle.set-client-info=true`
- [ ] DataSource 구성 방식 (HikariCP / DBCP2 등)

### 4.5 네트워크
- [ ] 기간계 WAS → DLM 서버 HTTP(S) 방화벽 오픈 가능 여부
- [ ] HTTPS 강제 여부 (인증서 설치 필요)
- [ ] Proxy 서버 경유 여부

### 4.6 개인정보 보호 검토
- [ ] 마스킹 대상 컬럼 정의 (JUMIN/CARD/ACCOUNT 외 추가 필요?)
- [ ] SQL 본문 전송 가능 여부 (보안 정책)
- [ ] 바인딩 파라미터 수집 가능 여부

### 4.7 테스트/배포 계획
- [ ] POC 대상 시스템 선정 (1개 업무 → 전체 확장)
- [ ] 기간계 테스트 환경 존재 여부
- [ ] 배포 주기/재기동 타이밍 (주말 정기 배포?)

---

## 5. 고객사에 요청할 자료 (필수 수령 목록)

프로젝트 킥오프 시 고객사 담당자(주로 개발팀장/아키텍트)에게 아래 자료를 요청하세요.
이 자료들이 모이면 SDK 설정 파일 작성이 30분 안에 끝납니다.

### 📋 자료 ①: **화면별 URL 패턴표** (가장 중요)

| 업무화면 | URL 패턴 | 비고 |
|---|---|---|
| 여신심사 | `/loan/review/` 로 시작하는 모든 요청 | |
| 대출상담 | `/loan/apply/` | |
| 고객관리 | `/cust/mgmt/` | |
| 채권상담 | `/collection/` | |
| 신용조회 | `/credit/inquiry/` | 과다조회자 점검 대상 |
| 계약관리 | `/contract/` | |
| ... | ... | |

→ 이 표를 받으면 `xaudit.menu.uri-prefix-map.*` 에 **그대로 옮겨 적기만 하면 끝**.

**대안**: 기존에 고객사가 쓰는 **메뉴코드표 / 화면정의서 / ERD 문서** 에 보통 포함되어 있음. 없다면 고객사 개발팀에 "각 업무화면의 Controller RequestMapping 경로" 를 요청.

### 📋 자료 ②: **인증 체계 설명**

아래 중 어떤 방식인지 확인:
- [ ] Spring Security 사용 → Principal 에서 사용자 식별
- [ ] 세션 기반 → 세션 attribute 의 키명 (예: `USER_ID`, `LOGIN_ID`, `EMP_NO`)
- [ ] 게이트웨이/SSO → 전달되는 헤더명 (예: `X-User-Id`)
- [ ] 사용자 객체(예: `UserVO`) 구조 — 부서/직무 필드가 어디에 있는지 (과다조회자 점검용)

### 📋 자료 ③: **시스템 식별자**

복수 시스템 적용 시 각각 고유 식별자 부여:
| 시스템명 | service-name |
|---|---|
| 여신 기간계 | `LOAN` |
| 고객관리 시스템 | `CUST` |
| 채권 시스템 | `COLLECTION` |
| ... | ... |

→ `xaudit.service-name=LOAN` 으로 설정. DLM 접속기록 화면에서 시스템별 필터링 기준이 됨.

### 📋 자료 ④: **네트워크 정보**

- [ ] 기간계 WAS IP 대역
- [ ] DLM 서버 IP/Port (내부망)
- [ ] HTTPS 강제 여부
- [ ] Proxy 경유 여부

### 📋 자료 ⑤: **기술 환경**

- [ ] Spring Boot 버전 (2.x / 3.x)
- [ ] Java 버전 (8 이상 필수)
- [ ] Servlet API (javax / jakarta)
- [ ] MyBatis 사용 여부
- [ ] DataSource-Proxy 사용 여부
- [ ] DBMS (Oracle / MySQL / PostgreSQL / MariaDB)
- [ ] DAM 장비 사용 여부 (DBSAFER/PSM) → Oracle ClientInfo 연계 검토

### 📋 자료 ⑥: **개인정보 보호 정책**

- [ ] 마스킹 대상 컬럼 (기본: JUMIN/CARD/ACCOUNT 외 추가 필요?)
- [ ] SQL 본문 외부 전송 가능 여부
- [ ] 바인딩 파라미터 수집 가능 여부

---

## 6. "메뉴(Menu)" 개념 — 세부 설명

SDK 에서 말하는 **메뉴**는 "이 사용자가 **어느 업무화면**에서 발생시킨 요청인가" 를 식별하는 고수준 태그.

단순 URI 만으로는 감사 시 "/loan/review/detail?id=123" 이 뜨지만, **"여신심사"** 라는 의미 단위가 있어야
- 부서별/직무별 권한 적정성 점검
- 테마점검 (화면 단위 증감율 분석)
- 과다조회자 선별
같은 분석이 가능.

### 해석 우선순위
1. **헤더** (`X-Menu-Id`): 고객사 프런트엔드가 이미 메뉴ID를 주입하면 그대로 사용 (최우선)
2. **URI prefix 매핑**: 헤더 없으면 `/loan/review/` → `여신심사` 등으로 변환
3. **없으면 null**: 제외 URI 는 애초 수집 안 함

### 설정 방식 선택

| 방식 | 설명 | 필요 설정 |
|---|---|---|
| **방식 A (헤더)** | 프런트엔드가 `X-Menu-Id` 헤더로 메뉴ID 전송 | `xaudit.menu.header=X-Menu-Id` + URI 매핑(선택) |
| **방식 B (URI만)** | URI 패턴으로 역추론 (프런트 수정 없음) | URI 매핑만 설정. **헤더 설정은 생략 가능** |

> **💡 방식 B 사용 시 `xaudit.menu.header=` 설정 불필요**
> 기본값이 `X-Menu-Id` 로 박혀있지만, 고객사가 해당 헤더를 안 보내면
> `req.getHeader()` 가 null 반환 → 자동으로 URI 매핑으로 fallback.
> 성능 차이는 헤더 조회 1회(나노초 수준), 동작은 100% 동일.
> 대부분의 프로젝트는 **방식 B**를 사용하므로 헤더 설정은 **생략 권장**.

### 실제 예시 (JB우리캐피탈 — 방식 B)
```properties
# 헤더 설정 생략 (기본값 X-Menu-Id 로 두고 프런트가 안 보내면 자동 fallback)
xaudit.menu.uri-prefix-map.여신심사=/loan/review/
xaudit.menu.uri-prefix-map.대출상담=/loan/apply/
xaudit.menu.uri-prefix-map.고객관리=/cust/mgmt/
xaudit.menu.uri-prefix-map.채권상담=/collection/
xaudit.menu.uri-prefix-map.신용조회=/credit/inquiry/
xaudit.menu.uri-prefix-map.계약관리=/contract/
```

→ DLM 접속기록 화면에서 `menu=여신심사, 사용자=홍길동, SQL=...` 형태로 표시.

---

## 7. LG CNS DevOn 프레임워크 적용 시 체크포인트

> JB우리캐피탈 등 **LG CNS DevOn 기반 기간계**는 일반 Spring Boot 프로젝트와
> 구조가 다를 수 있어 SDK 적용 전 추가 확인이 필요합니다.

### 7.1 DevOn 2가지 계열 — 적용 방식이 완전히 다름

| 계열 | 기반 | SDK 적용 |
|---|---|---|
| **DevOn NCD** (Next-gen Cloud Development) | Spring Boot + Cloud 네이티브 | ✅ 현재 SDK 그대로 |
| **DevOn Framework** (Legacy) | Spring MVC + web.xml + XML Bean | ⚠ 수동 Bean 등록 가이드 필요 |

→ 어느 쪽인지 **확인 전에는 POC 착수 불가**.

### 7.2 Legacy Framework 인 경우 추가 작업

Spring Boot Auto-Config 가 동작하지 않으므로 SDK 를 XML Bean 으로 수동 등록:

```xml
<!-- dispatcher-servlet.xml 에 추가 -->
<bean class="datablocks.dlm.xaudit.spring.XauditAutoConfiguration"/>
<bean class="datablocks.dlm.xaudit.spring.XauditProperties" id="xauditProperties">
    <!-- xaudit.* 프로퍼티 수동 주입 -->
</bean>

<!-- web.xml 에 Filter 수동 등록 -->
<filter>
    <filter-name>xauditAccessFilter</filter-name>
    <filter-class>datablocks.dlm.xaudit.servlet.XauditAccessFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>xauditAccessFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

(실제 legacy 확인 시 전용 스니펫 추가 예정)

### 7.3 고객사 사전질의서 — 담당자 포워딩용

POC 착수 전 **LG CNS 담당자에게 전달할 상세 질의서**를 별도 문서로 준비했습니다.
Q1 ~ Q6 각 항목마다 "어디서 찾는지 / 어떻게 찾는지 / 답이 어떻게 생겼는지" 를
구체적으로 안내해 담당자가 헤매지 않고 답할 수 있도록 작성:

📄 **[dlm-aop-sdk-LG-DevOn-사전질의서.md](dlm-aop-sdk-LG-DevOn-사전질의서.md)**

질의 항목 요약:
- Q1: DevOn 버전 및 계열 (NCD / Legacy)
- Q2: Spring Boot 사용 여부 (핵심 분기점)
- Q3: Java / Spring / Servlet API 버전
- Q4: 인증/세션 구조 (로그인 객체 클래스, 세션 attribute 키)
- Q5: MyBatis 사용 및 SqlSessionFactory 등록 방식
- Q6: URL 패턴 스타일 (`.do` suffix 등) + 업무화면 매핑표

### 7.4 DevOn 특화 예상 이슈

| 이슈 | 영향 | 대응 |
|---|---|---|
| `.do` URL 패턴 | `uri-prefix-map` 매핑 패턴 달라짐 | `/front/loan/review` 형태로 prefix 등록 또는 wildcard 고려 |
| DevOn 자체 ThreadLocal | xaudit TTL 과 충돌 가능 | `XauditTaskDecorator` 주입 테스트 |
| 자체 MyBatis 래퍼 | MyBatis Plugin 자동 부착 실패 가능 | SqlSessionFactory 빈 직접 확인 후 수동 addInterceptor |
| 자체 세션 키 (비-SecurityContext) | 사용자 식별 실패 | `xaudit.user.session-attribute` 로 매핑 + 커스텀 Resolver |
| JSESSIONID 기본 쿠키 | DLM 세션과 충돌 가능 | DLM 측 쿠키명 분리 (이미 적용) |

---

## 8. 관련 파일

### SDK 내부 구조
- [dlm-aop-sdk/build.gradle](../../DLM/dlm-aop-sdk/build.gradle)
- [XauditAutoConfiguration.java](../../DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/spring/XauditAutoConfiguration.java) — Auto-Config 진입점
- [XauditProperties.java](../../DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/spring/XauditProperties.java) — 설정 프로퍼티
- [XauditAccessFilter.java](../../DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/servlet/XauditAccessFilter.java) — HTTP 요청 Filter
- [XauditMybatisInterceptor.java](../../DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/mybatis/XauditMybatisInterceptor.java) — MyBatis SQL 가로채기
- [XauditJdbcQueryListener.java](../../DLM/dlm-aop-sdk/src/main/java/datablocks/dlm/xaudit/jdbc/XauditJdbcQueryListener.java) — DataSource-Proxy Listener

### DLM 수신측
- `AgentApiController` — `/api/agent/logs` 및 `/api/xaudit/events` 수신
- `TBL_ACCESS_LOG` — 수신 로그 적재 테이블 (`collectType='WAS_SDK'`)
