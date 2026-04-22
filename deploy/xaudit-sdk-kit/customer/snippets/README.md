# snippets/ — 병합용 조각 파일들

> **⚠ 이 폴더의 파일들은 모두 "병합용 스니펫(snippet)" 입니다. 단독 실행 불가능합니다.**

고객사 기존 프로젝트의 해당 파일에 **복사 후 붙여넣기(copy & merge)** 해서 사용합니다.

---

## 파일 구성

| 파일 | 형식 | 병합 대상 | 쓰는 경우 |
|---|---|---|---|
| `pom-snippet.xml` | Maven XML 조각 | 고객사 `pom.xml` 의 `<dependencies>` 안 | 고객사가 Maven 사용 시 |
| `build-snippet.gradle` | Gradle DSL 조각 | 고객사 `build.gradle` 의 `dependencies { }` 안 | 고객사가 Gradle 사용 시 |
| `xaudit-config-snippet.yml` | YAML 조각 | 고객사 `application.yml` 루트에 `xaudit:` 섹션 추가 | 고객사가 YAML 형식 사용 시 |
| `xaudit-config-snippet.properties` | Properties 조각 | 고객사 `application.properties` 끝에 `xaudit.*` 라인 추가 | 고객사가 properties 형식 사용 시 |

---

## 사용 조합 (택일)

**빌드 도구**: `pom-snippet.xml` 또는 `build-snippet.gradle` 중 고객사 환경에 맞는 것 1개

**설정 파일**: `xaudit-config-snippet.yml` 또는 `xaudit-config-snippet.properties` 중 고객사 환경에 맞는 것 1개

> 두 설정 형식을 동시에 넣으면 Spring Boot 가 양쪽을 병합하여 로드하지만, 중복/혼동 방지를 위해 **하나만 사용**하는 게 안전합니다.

---

## 왜 "snippets" 인가 (파일명 규칙)

### ❌ `examples/application-xaudit.yml`
이전 폴더명(`examples/`)과 파일명(`application-xaudit.yml`)은 2가지 오해를 부름:

1. **"examples"** → "그냥 샘플/예제라 꼭 써야 하는 건 아니네"
2. **`application-xaudit.yml`** → Spring Boot 의 프로파일 파일 명명 규칙과 혼동
   (`--spring.profiles.active=xaudit` 으로 활성화되는 프로파일 파일로 오해)

### ✅ `snippets/xaudit-config-snippet.yml`
현재 명명은 2가지 의도 전달:

1. **"snippets"** → "복붙용 조각이구나" 명확
2. **`xaudit-config-snippet.yml`** → 파일명 자체가 "snippet" 을 포함 → Profile 파일 아님이 자명

---

## 병합 실제 예시 — YAML

**고객사 기존 `application.yml`**:
```yaml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:oracle:thin:@...
mybatis:
  mapper-locations: classpath:mapper/**/*.xml
```

**`xaudit-config-snippet.yml` 의 `xaudit:` 섹션을 복붙한 후**:
```yaml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:oracle:thin:@...
mybatis:
  mapper-locations: classpath:mapper/**/*.xml

# ━━━━━━ 여기서부터 xaudit-config-snippet.yml 에서 복붙 ━━━━━━
xaudit:
  enabled: true
  service-name: LOAN_CORE
  server:
    url: https://dlm.bank.internal:8443/api/xaudit/events
  menu:
    uri-prefix-map:
      여신심사: /loan/review/
      고객관리: /cust/mgmt/
  # ... (필요한 설정만 골라서 병합)
```

---

## 병합 실제 예시 — properties

**고객사 기존 `application.properties`**:
```properties
server.port=8080
spring.datasource.url=jdbc:oracle:thin:@...
mybatis.mapper-locations=classpath:mapper/**/*.xml
```

**`xaudit-config-snippet.properties` 의 xaudit.* 라인을 복붙한 후**:
```properties
server.port=8080
spring.datasource.url=jdbc:oracle:thin:@...
mybatis.mapper-locations=classpath:mapper/**/*.xml

# ━━━━━━ 여기서부터 xaudit-config-snippet.properties 에서 복붙 ━━━━━━
xaudit.enabled=true
xaudit.service-name=LOAN_CORE
xaudit.server.url=https://dlm.bank.internal:8443/api/xaudit/events
xaudit.menu.uri-prefix-map.여신심사=/loan/review/
xaudit.menu.uri-prefix-map.고객관리=/cust/mgmt/
# ... (필요한 설정만 골라서 병합)
```

---

## 자주 묻는 질문

### Q1. 전체를 다 복붙해야 하나요?
아니요. **최소 3줄** (`enabled`, `service-name`, `server.url`) 만 있어도 동작합니다. 나머지는 기본값 적용. 필요한 것만 선택 복붙.

### Q2. 이 파일을 그대로 `src/main/resources/` 에 복사해서 쓰면 안 되나요?
Spring Boot 가 load 는 하지만 권장 안 함:
- YAML 스니펫은 파일명이 Profile 형식이 아니라 **아예 로드 안 됨**
- `properties` 스니펫도 파일명이 `application.properties` 가 아니면 기본 로드 안 됨
- 결과: "설정이 안 먹는다" 트러블슈팅 시간 낭비

→ **"고객사 기존 application.yml/properties 에 섹션만 병합"** 이 정석입니다.

### Q3. YAML 과 properties 중 뭘 써야 하나요?
**고객사 기존 프로젝트 형식에 맞춰 택1.**
- 고객사가 `application.yml` 을 쓰면 → YAML 스니펫
- 고객사가 `application.properties` 를 쓰면 → properties 스니펫
- 섞어 쓰면 Spring Boot 가 병합 로드는 하지만 혼동 유발 → 한 가지만 쓰는 게 관행

### Q4. xaudit.menu.header 는 꼭 설정해야 하나요?
**대부분 프로젝트는 설정 불필요.**
- 프런트엔드가 `X-Menu-Id` 커스텀 헤더를 매 요청마다 보내는 경우에만 의미 있음
- 대부분은 URI prefix 매핑(`uri-prefix-map`) 만으로 충분
- 자세한 내용은 `xaudit-config-snippet.yml` 의 "메뉴 식별" 섹션 주석 참조

---

**관련 문서**:
- [../README.md](../README.md) — 고객사 처리계 적용 가이드 전체
- [../../README.md](../../README.md) — X-Audit SDK Kit 전체 설명
