# dlm-aop-sdk 적용 사전 기술질의서 — LG CNS DevOn 프레임워크

> 이 문서는 고객사(JB우리캐피탈 등 LG DevOn 기반 기간계) 담당자에게
> **그대로 포워딩**할 수 있는 질의서입니다.
>
> dlm-aop-sdk(X-Audit)를 고객사 WAS 에 적용하기 전에 확인이 필요한
> 기술 정보 6개 항목을 정리했습니다.
>
> **각 항목마다 "어디서 찾는지 / 어떻게 찾는지 / 답이 어떻게 생겼는지"를
> 구체적으로 안내**하여, 고객사 담당자가 헤매지 않고 답할 수 있도록 했습니다.
>
> 작성일: 2026-04-21

---

## 📋 질의 대상

- **시스템**: (예: 여신 기간계 / 고객관리 / 채권 관리 등)
- **담당자**: _______________
- **작성일**: _______________
- **DevOn 설치 프로젝트 경로**: _______________ (예: `/app/was/loan-core`)

---

## Q1. DevOn 버전 및 계열 (가장 중요)

**왜 필요한가:** DevOn 은 계열이 2가지 있고, 각각 우리 SDK 적용 방식이 완전히 다릅니다.
- **DevOn NCD** (Next-gen Cloud Development, Spring Boot 기반) → SDK 그대로 적용 가능
- **DevOn Framework** (기존 Spring MVC + XML) → 수동 설치 가이드 추가 필요

### 답변해야 할 내용

- [ ] DevOn NCD
- [ ] DevOn Framework 3.x
- [ ] DevOn Framework 2.x
- [ ] 기타 (구체적으로: _______________)

### 어디서 찾는가

**방법 1 — `lib` 디렉터리의 jar 파일명 확인**
```bash
# 프로젝트 루트에서 실행
find . -name "devon*.jar" -o -name "DevOn*.jar"
```
→ 결과 예시:
- `devon-ncd-framework-1.5.0.jar` → **DevOn NCD**
- `devon-framework-3.8.2.jar` → **DevOn Framework 3.x**
- `DevonCore-2.x.x.jar` → **DevOn Framework 2.x**

**방법 2 — 설치 문서/README 확인**
프로젝트 루트의 `README.md`, `설치가이드.docx`, `설계서` 등에 DevOn 버전이 명시된 경우가 많음.

**방법 3 — LG CNS 현장지원 담당자에게 직접 문의**
위 방법으로 안 나오면 LG CNS PM/기술지원 담당자에게 "이 프로젝트의 DevOn 버전이 뭐냐" 이메일 한 통으로 해결됨.

### 답변 예시
```
답: DevOn Framework 3.8.2 (자체 Core 라이브러리 devon-core-3.8.jar)
```

---

## Q2. Spring Boot 사용 여부 — 핵심 분기점

**왜 필요한가:** 우리 SDK 는 Spring Boot Auto-Configuration 으로 자동 활성화됩니다. Spring MVC legacy(비-Boot) 환경이면 XML Bean 등록으로 바꿔야 합니다.

### 답변해야 할 내용

- [ ] **Spring Boot 사용** (application.yml/properties 중심, @SpringBootApplication 존재)
- [ ] **Spring MVC Legacy** (web.xml + XML Bean 중심, 전통적 WAS 배포)
- [ ] **혼합** (일부만 Boot, 일부 Legacy)

### 어디서 찾는가 — 순서대로 체크 (위에서부터)

> **⚠ 중요 — 헷갈리기 쉬운 점**
>
> - `application.yml` 또는 `application.properties` 가 있다고 Spring Boot 가 아닙니다.
>   → Spring MVC Legacy 도 `@PropertySource` 로 이 파일들을 로드합니다.
> - `web.xml` 이 있다고 Legacy 가 아닙니다.
>   → Spring Boot 도 WAR 배포 시 `web.xml` 을 가질 수 있습니다 (드물지만).
>
> 확정적 판별은 **아래 "체크 1" 하나면 끝납니다**. 체크 2, 3 은 보조 확인용입니다.

---

### ✅ 체크 1 — `@SpringBootApplication` 어노테이션 + starter 의존성 (결정적)

**1-A. 어노테이션 확인**
```bash
grep -rn "@SpringBootApplication" --include="*.java" src/
```

**1-B. 의존성 확인 (Maven)**
```bash
grep -E "spring-boot-starter|spring-boot-dependencies" pom.xml
```

**1-C. 의존성 확인 (Gradle)**
```bash
grep -E "spring-boot-starter|org.springframework.boot" build.gradle
```

**판정**:

| 1-A 결과 | 1-B 또는 1-C 결과 | 판정 |
|---|---|---|
| `@SpringBootApplication` 있음 | `spring-boot-starter-*` 있음 | ✅ **Spring Boot 확정** |
| `@SpringBootApplication` 없음 | `spring-boot-starter-*` 없음 | ⚠ **Spring MVC Legacy 확정** |
| 한쪽만 있음 | (드문 케이스) | 마이그레이션 중 또는 이상 상태 — 담당자에게 문의 |

---

### 📋 체크 2 — 보조 확인 (체크 1 결과 뒷받침)

체크 1로 이미 결론이 났다면 참고용. 두 결과가 모순되면 체크 1을 우선.

**2-A. 설정 파일**
```bash
find . -name "application.yml" -o -name "application.properties"
find . -name "web.xml"
find . -name "dispatcher-servlet.xml" -o -name "servlet-context.xml"
```

| 발견된 파일 | Spring Boot 에서 흔함 | Legacy 에서 흔함 |
|---|---|---|
| `application.yml` | ✅ (표준) | 드물게 사용 |
| `application.properties` | ✅ (표준) | 흔히 사용 (`@PropertySource`) |
| `web.xml` | 드묾 (WAR 배포 시만) | ✅ (필수) |
| `dispatcher-servlet.xml` | 거의 없음 | ✅ (DispatcherServlet 선언) |

→ 이 파일들만으로는 **확정 불가**. 체크 1의 보강 증거로만 사용.

**2-B. 빌드 결과물 형태**
```bash
find . -name "pom.xml" -exec grep -A1 "<packaging>" {} \;
grep "bootJar\|bootWar" build.gradle
```

| 빌드 산출물 | 판정 |
|---|---|
| `<packaging>jar</packaging>` + Spring Boot 의존성 | ✅ Spring Boot (실행 가능 JAR, 내장 Tomcat) |
| `<packaging>war</packaging>` + Spring Boot 의존성 | ✅ Spring Boot (외부 WAS 배포용 WAR) |
| `<packaging>war</packaging>` + Spring Boot 의존성 없음 | ⚠ Spring MVC Legacy |

### 답변 예시

**예시 1 — Spring MVC Legacy 인 경우**:
```
답: Spring MVC Legacy
  체크 1 (결정적):
    - @SpringBootApplication 검색 결과: 없음 (grep 결과 0건)
    - pom.xml 의 spring-boot-starter-*: 없음
    → 결론: Legacy 확정
  체크 2 (보조):
    - web.xml: src/main/webapp/WEB-INF/web.xml 존재
    - servlet-context.xml: WEB-INF/spring/appServlet/servlet-context.xml
    - 빌드: loan-core.war (Tomcat 9에 배포)
```

**예시 2 — Spring Boot 인 경우**:
```
답: Spring Boot
  체크 1 (결정적):
    - @SpringBootApplication: src/main/java/com/jb/Application.java 에 1건
    - pom.xml: spring-boot-starter-web 2.7.15, spring-boot-starter-data-jpa 등
    → 결론: Spring Boot 확정
  체크 2 (보조):
    - application.yml: src/main/resources/application.yml 존재
    - web.xml: 없음
    - 빌드: loan-core.jar (내장 Tomcat)
```

---

## Q3. Java 버전 / Spring 버전 / Servlet API

**왜 필요한가:** SDK 는 Java 8+, javax.servlet 기반. jakarta.servlet (Java EE 9+) 은 별도 모듈 필요.

### 답변해야 할 내용

- [ ] Java 버전: _______ (예: 1.8 / 11 / 17 / 21)
- [ ] Spring 버전: _______ (예: Spring 5.3.x / Spring Boot 2.7.x / Spring Boot 3.x)
- [ ] Servlet API: ☐ javax.servlet ☐ jakarta.servlet

### 어디서 찾는가

**Java 버전**
```bash
# 실제 구동 JDK
java -version

# Maven 빌드 설정
grep -A 3 "java.version\|maven.compiler.source\|maven.compiler.target" pom.xml

# Gradle 빌드 설정
grep "sourceCompatibility\|targetCompatibility" build.gradle
```
→ 답: `java.version = 1.8` 이면 Java 8, `11` 이면 Java 11, ...

**Spring 버전**
```bash
# Maven
grep -E "spring-(core|boot)" pom.xml | head -20

# Gradle
grep -E "spring-(core|boot)" build.gradle | head -20

# 또는 실제 로드된 jar 확인
find . -name "spring-core-*.jar"
find . -name "spring-boot-*.jar"
```
→ 답 예시: `spring-core-5.3.23.jar`, `spring-boot-2.7.15.jar`

**Servlet API**
```bash
grep -E "javax.servlet-api|jakarta.servlet-api" pom.xml
# 또는
find . -name "javax.servlet-api-*.jar" -o -name "jakarta.servlet-api-*.jar"
```
→ `javax.servlet-api-4.0.1.jar` → javax (Java EE 8 이전)
→ `jakarta.servlet-api-6.0.0.jar` → jakarta (Jakarta EE 9+)

### 답변 예시
```
답:
- Java: 1.8 (OpenJDK 1.8.0_362)
- Spring: Spring 5.3.23 (Spring MVC, Boot 미사용)
- Servlet API: javax.servlet-api 4.0.1
```

---

## Q4. 인증/세션 구조 — 사용자 식별 방식

**왜 필요한가:** SDK 가 "누가 이 요청을 보냈는가"를 알아야 접속기록에 사용자 ID 를 기록할 수 있습니다. DevOn 은 자체 세션 관리 방식이 있어서 어떻게 꺼내는지 확인 필요.

### 답변해야 할 내용

**4-1. Spring Security 사용 여부**
- [ ] 사용 → SecurityContext 에서 자동 추출 가능
- [ ] 미사용 → 세션 attribute 확인 필요

**4-2. 로그인 처리 클래스명 / 세션 attribute 키**
- 로그인 컨트롤러/인터셉터 클래스명: _______________
- 세션에 저장하는 로그인 객체 클래스명: _______________ (예: `LoginUser`, `SessionUser`, `UserVO`)
- 세션 attribute 키 (문자열): _______________ (예: `"LOGIN_USER"`, `"USER_INFO"`)

**4-3. 사용자 ID 필드명** (세션 객체 안의)
- 로그인 ID 필드명: _______________ (예: `userId`, `loginId`, `empNo`)

### 어디서 찾는가

**Spring Security 사용 여부**
```bash
grep -r "spring-security" pom.xml build.gradle
grep -r "@EnableWebSecurity\|SecurityFilterChain\|WebSecurityConfigurerAdapter" --include="*.java" src/
```
→ 위에 뭐라도 걸리면 **Spring Security 사용**.

**세션 attribute 키 찾기 — 로그인 처리 지점 grep**
```bash
# 로그인 성공 시 세션에 사용자 저장하는 코드 찾기
grep -rn "session.setAttribute" --include="*.java" src/main/java | head -20
```
→ 결과 예시:
```java
LoginController.java:82:    session.setAttribute("LOGIN_USER", loginUser);
```
→ 세션 키 = `"LOGIN_USER"`, 저장 객체 = `loginUser` (타입은 위 줄에서 확인)

**로그인 객체의 ID 필드 찾기**
위에서 찾은 클래스(`LoginUser.java`)를 열어 필드 확인:
```bash
find . -name "LoginUser.java" -exec head -50 {} \;
```
→ 결과 예시:
```java
public class LoginUser {
    private String userId;      // ← 이게 사용자 ID 필드
    private String userName;
    private String deptCode;
    ...
}
```

### 답변 예시
```
답:
- Spring Security: 미사용 (DevOn 자체 인터셉터 LoginInterceptor 사용)
- 로그인 객체 클래스: com.jbwoori.common.vo.SessionUserVO
- 세션 attribute 키: "SESSION_USER"
- 사용자 ID 필드명: loginId
- 사용자 이름 필드명: userName
- 부서코드 필드명: deptCd
```

> 위 답이 있으면 우리 SDK 에 다음 설정으로 매핑됩니다:
> ```yaml
> xaudit.user.session-attribute: SESSION_USER
> # 커스텀 Resolver 로 SessionUserVO.loginId 추출
> ```

---

## Q5. MyBatis 사용 여부 및 SqlSessionFactory 등록 방식

**왜 필요한가:** SDK 는 MyBatis Interceptor 로 SQL 을 자동 캡처합니다. DevOn 이 MyBatis 를 자체 관리하는 경우 SDK 가 Interceptor 를 못 붙일 수 있음 → 확인 필요.

### 답변해야 할 내용

- [ ] MyBatis 사용 여부: ☐ 사용 ☐ 미사용 (다른 것: _______)
- [ ] MyBatis 버전: _______
- [ ] SqlSessionFactory 빈 등록 방식:
  - [ ] `@Bean` 메서드 (Java Config)
  - [ ] XML Bean 정의
  - [ ] DevOn 자체 관리 (확인 불가)
- [ ] Mapper XML 위치: _______________ (예: `classpath:mapper/**/*.xml`)

### 어디서 찾는가

**MyBatis 사용 여부**
```bash
grep -E "mybatis" pom.xml build.gradle
```
→ `mybatis-3.5.x`, `mybatis-spring-2.x`, `mybatis-spring-boot-starter-*` 등 걸리면 사용.

**SqlSessionFactory 빈 등록 위치**
```bash
# Java Config 방식
grep -rn "SqlSessionFactory" --include="*.java" src/main/java | head -10

# XML 방식
grep -rn "SqlSessionFactory\|SqlSessionFactoryBean" --include="*.xml" src/ | head -10
```
→ 결과 예시:
```
src/main/resources/spring/context-mybatis.xml:5:
  <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
```
→ **XML Bean 방식** 확인.

**Mapper XML 위치**
위에서 찾은 SqlSessionFactory 빈 정의 근처의 `mapperLocations` 속성값:
```xml
<property name="mapperLocations" value="classpath:mapper/**/*.xml"/>
```

### 답변 예시
```
답:
- MyBatis 사용: Yes (mybatis-3.5.11, mybatis-spring-2.0.7)
- SqlSessionFactory: XML Bean 방식
  - 정의 위치: src/main/resources/spring/context-mybatis.xml
  - 빈 이름: sqlSessionFactory
- Mapper XML 위치: classpath:mapper/**/*.xml
```

---

## Q6. URL 패턴 / 업무화면 매핑

**왜 필요한가:** SDK 가 "여신심사 화면 접근" 같은 메뉴 단위로 접속기록을 집계하려면, 각 업무화면의 URL 패턴이 필요합니다. DevOn 은 `.do` 방식 등 URL 패턴이 일반 Spring Boot 와 다를 수 있습니다.

### 답변해야 할 내용

**6-1. URL 패턴 스타일**
- [ ] `.do` suffix (예: `/loan/review.do`)
- [ ] RESTful (예: `/loan/review/{id}`)
- [ ] Query 기반 (예: `/action?screen=loanReview`)
- [ ] 기타 (구체적으로: _______________)

**6-2. 주요 업무화면 URL 매핑표** (이게 핵심)

아래 표를 채워주세요. **각 업무화면에 접근할 때 브라우저 주소창/개발자도구에 어떤 URL 이 뜨는지** 기록.

| 업무화면 | URL 패턴 | 비고 |
|---|---|---|
| 여신심사 (목록/상세) | 예: `/front/loan/review*.do` | |
| 대출상담 | | |
| 고객관리 | | |
| 채권상담 | | 과다조회 점검 대상 |
| 신용조회 | | |
| 계약관리 | | |
| 파기관리 | | |
| (기타 개인정보 취급 화면) | | |

### 어디서 찾는가

**방법 1 — 메뉴코드표/화면정의서 활용 (가장 빠름)**
LG CNS 가 설계 단계에 만든 **메뉴코드표 / 화면정의서 / URL 매핑표** 가 이미 있을 가능성 큼. 기획/설계팀에 "각 업무화면의 URL 매핑 자료" 요청.

**방법 2 — Controller @RequestMapping 분석**
```bash
# Spring MVC
grep -rn "@RequestMapping\|@GetMapping\|@PostMapping" --include="*.java" src/main/java \
  | grep -v "^.*test" | head -50
```
→ 각 Controller 의 URL 이 목록으로 나옴.

**방법 3 — 운영 중인 시스템에서 직접 클릭**
개발/스테이징 환경에서 각 메뉴 클릭 후 **브라우저 개발자도구 > Network 탭**에서 요청 URL 확인.

**방법 4 — DevOn 자체 메뉴 테이블**
DevOn 은 DB 에 메뉴 테이블(`TB_MENU` 등)을 두는 경우가 많음. 메뉴명과 URL 을 매핑해둔 테이블이 있으면 SELECT 로 일괄 추출:
```sql
-- 테이블명은 DevOn 버전/고객사별 차이 있음. 아래는 일반적 패턴:
SELECT menu_nm, url FROM TB_MENU WHERE use_yn = 'Y';
-- 또는
SELECT menu_name, menu_url FROM COM_MENU_M;
```

### 답변 예시
```
답:
- URL 패턴 스타일: .do suffix (DevOn 표준)
- 주요 URL 매핑:
  여신심사: /front/loan/review*.do
  대출상담: /front/loan/apply*.do
  고객관리: /front/customer/manage*.do
  채권상담: /front/collection/*.do
  신용조회: /front/credit/inquiry*.do
  계약관리: /front/contract/*.do
```

---

## 🎯 답변 제출 방식

위 6개 항목을 채워 다음 형식으로 회신 부탁드립니다:

```
=== dlm-aop-sdk 적용 사전질의서 회신 ===
작성일: 2026-__-__
작성자: __________ (__________팀)
대상 시스템: __________

Q1. DevOn 버전 및 계열
  답: __________

Q2. Spring Boot 사용 여부
  답: __________
  근거 파일: __________

Q3. Java / Spring / Servlet
  Java: __________
  Spring: __________
  Servlet API: __________

Q4. 인증/세션
  Spring Security: __________
  로그인 객체 클래스: __________
  세션 attribute 키: __________
  사용자 ID 필드: __________

Q5. MyBatis
  사용 여부: __________
  SqlSessionFactory 등록: __________
  Mapper 경로: __________

Q6. URL 패턴
  스타일: __________
  주요 매핑표: (별도 표 첨부)
```

---

## 📌 참고: 답변이 어려운 경우

**상황별 대응**:

| 상황 | 대응 |
|---|---|
| 코드 접근이 막힌 경우 | LG CNS 현장지원 담당자에게 이 질의서 그대로 전달 |
| 설계 문서가 없는 경우 | 실제 운영 중인 WAS 에서 `deploy/lib/` 디렉터리 jar 목록 확인 |
| 시간이 없는 경우 | 최소 **Q1, Q2, Q6** 만이라도 회신 (나머지는 POC 단계에 현장 확인 가능) |

이 질의서 내용으로 자체 확인이 어려우면, 우리 기술팀이 **원격 접속해서 2시간 이내 파악** 가능합니다. 주저 없이 요청 주세요.

---

**문의처**: Datablocks 기술팀 / (담당자 이름 + 연락처)
