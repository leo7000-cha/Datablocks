# X-PURGE 접속기록 모듈, BCI를 넘어설 설계 청사진

**결론부터 말하면**, 국내 금융권 환경에서 WAS 접속기록과 SQL 실행기록을 "한 줄로" 통합 저장하는 가장 현실적인 조합은 **MyBatis Interceptor + Servlet Filter + SQL Comment Injection + Oracle setClientInfo**의 4중 하이브리드다. 이 설계는 **운영계 소스코드를 단 한 줄도 수정하지 않고**도 개인정보보호법 제29조·전자금융감독규정 시행세칙 제13조제1항제9호(2025.2.3 신설)·신용정보업감독규정 별표3을 동시 충족한다. 경쟁 제품 이지서티 UBI SAFER-PSM이 BCI(Byte Code Injection) Java Agent로 22년 연속 1위를 지키고 있으나, X-PURGE는 **"애플리케이션 레이어 Plugin + 기존 DAM 연계"** 라는 가볍고 친(親)SI 전략으로 차별화 가능하다. 아이엠캐피탈·JB우리캐피탈 같은 2금융권은 피앤피시큐어 DBSAFER 또는 이지서티 PSM을 이미 보유한 경우가 많아, **경쟁이 아닌 보완 포지셔닝**이 실제 수주 확률을 높인다.

아래 5개 섹션은 이 결론을 뒷받침하는 기술·제품·법규 근거를 담는다.

## 8가지 수집 방식의 냉정한 비교

WAS에서 사용자 행위와 SQL을 잡아낼 기술은 8가지가 경쟁한다. 이 중 **코드 수정 제로**와 **사용자-SQL 완전 연결**이라는 두 조건을 동시에 만족하는 후보는 셋뿐이다.

**MyBatis Interceptor 방식**은 `org.apache.ibatis.plugin.Interceptor`의 `@Intercepts({@Signature(type=Executor.class, method="query/update")})` 지점에서 `MappedStatement.getBoundSql()`을 통해 PreparedStatement의 `?` 치환 전후 SQL과 ParameterMapping 리스트를 모두 얻는다. Mapper XML이나 DAO 코드를 **한 줄도 수정하지 않고** Plugin 클래스 하나와 `SqlSessionFactoryBean.setPlugins()` Bean 등록만으로 전체 쿼리를 포착하며, 쿼리당 오버헤드는 비동기 Appender 기준 **0.1~0.5ms**에 불과하다. HikariCP·DBCP·Tomcat JDBC Pool 어느 풀에서도 동일하게 동작한다. **단, JdbcTemplate이나 Spring Batch JobRepository 쿼리는 누락**된다는 한계가 있어 보완이 필요하다.

**네트워크 TAP/Mirror + WAS Agent 방식**은 피앤피 DBSAFER·이지서티 PSM이 채택한 금융권 표준이다. WAS↔DB 구간 스위치의 SPAN 포트로 TNS/T3/TDS 프로토콜 패킷을 복사해 어플라이언스가 SQL과 결과셋을 파싱한다. 3-tier 사용자 식별 문제는 WAS에 "User Tracer"(DBSAFER) 또는 "BCI Agent"(PSM)를 함께 설치해 해결한다. **애플리케이션 코드 수정은 제로**지만 어플라이언스 수억 원, SSL/TDE 구간은 가시성 상실, DB 서버 내 Agent 추가 설치라는 이중 부담이 있다.

**JDBC Driver 프록시(DataSource-Proxy, P6Spy)** 는 DataSource Bean 하나만 `ProxyDataSourceBuilder`로 감싸면 MyBatis·JdbcTemplate·JPA·Native JDBC **모두를 공통 캡처**하여 MyBatis Plugin의 사각지대를 완벽히 메운다. Tibero와 P6Spy 조합에서 `SQLFeatureNotSupportedException` 사례가 있어 PoC 검증이 필수이지만, **DataSource-Proxy(net.ttddyy)는 최신이고 안정적**이다.

나머지 방식들의 명확한 한계를 정리하면 다음과 같다. Spring AOP/AspectJ는 Mapper 메서드 시그니처만 잡아 **SQL 원문이 없으므로** 법적 증적으로 부적합하다. 자체 제작 Java Agent는 ClassLoader Leak·JVM 크래시 리스크로 금융권이 절대 수용하지 않는다. WAS Access Log(Tomcat AccessLogValve, JEUS access log)는 HTTP 레이어 전용이라 **SQL이 전혀 없다**. APM(Pinpoint·Scouter·Jennifer)은 기본적으로 바인딩 파라미터 실제 값을 수집하지 않고 샘플링(기본 20샘플당 1개)을 쓰기 때문에 **"감사용이 아닌 성능 모니터링용"** 이다.

## 이지서티 BCI의 실체와 경쟁 지형

국내 DAM 시장의 지배적 사업자 지형은 둘로 나뉜다. **이지서티 UBI SAFER-PSM**이 "개인정보 접속기록 관리"라는 카테고리 자체를 정의한 1위 사업자(누적 22,781개 구축·개인정보 원천특허 34개)이고, **피앤피시큐어 DBSAFER**가 "DB 접근제어" 카테고리의 지배자(6,000개 이상 고객사, 국내 금융권 사실상 전수 도입)다. X-PURGE가 경쟁할 핵심 제품은 이지서티 PSM이다.

이지서티의 **BCI(Byte Code Instrumentation/Injection)** 는 Java Agent 방식의 한국식 명명이다. JVM 기동 시 `-javaagent` 옵션으로 Instrumentation API를 얻어 JDBC 드라이버 클래스(`oracle.jdbc.driver.*`, `com.tmax.tibero.*`)의 `executeQuery/executeUpdate` 바이트코드에 Advice를 동적 주입한다. KT M모바일 2025년 RFP에 명시된 바에 따르면 PSM은 BCI 외에도 **Contents Filtering(네트워크 스니핑)·DB-to-DB(감사 테이블 직수집)·Application API 연동**을 선택·혼합 적용하는 **"다중 수집 아키텍처"** 가 핵심 차별점이다. 보안뉴스 보도에 따르면 BCI 모드에서 PSM은 "일체 누락 없는 접속기록 생성, 데이터 무결성 100% 보장, 사번·ID·이름 등 취급자 식별정보와 SQL문 완벽 기록, 다운로드 자동 식별"을 표방한다.

피앤피시큐어 DBSAFER는 세계 최초 Gateway 방식 DB보안 제품(2003)이며 **User Tracer 모듈**로 WAS 접속자를 식별한다. Gateway Proxy + Server Agent + 네트워크 스니핑 3중 구조가 특징이며, 금융권은 대부분 Gateway 방식으로 SQL 차단·결재·마스킹을 활용한다. 신시웨이 PETRA는 Gateway·Sniffing·Agent 3종 하이브리드에 11종 DBMS 지원과 자체 MMDBMS "SOHA" 기반 Insert-Only 감사 테이블이 강점이며, 전국 16개 시·도교육청 NEIS를 구축했다. 웨어밸리 Chakra Max는 **인박스(요청 SQL)/아웃박스(Result)** 양방향 로깅으로 "응답 건수 기반 대량조회 탐지"가 특징이다. 소만사는 **WAS-i 전용 어플라이언스**로 "수십만 사용자 IP가 WAS에서 하나의 IP로 세탁되는" 문제를 네트워크 수준 상관분석으로 해결하나 금융권 레퍼런스는 약하다. 넷앤드 HIWARE는 특권계정 IAM 1위지만 WAS 3-tier 식별은 제한적이며, 엔소프테크 TScan은 "거래 단위 접속기록" 관점으로 차별화한다.

| 벤더/제품 | 수집 방식 | 3-tier 사용자 식별 | 금융권 레퍼런스 | 강점 |
|---|---|---|---|---|
| **이지서티 PSM** | BCI Java Agent + 네트워크 + DB-to-DB + API | BCI가 HTTP 세션-JDBC 호출 직접 매핑 | 공공·금융·의료 광범위 | 접속기록 시장 1위, 누락 없음 |
| **피앤피 DBSAFER** | Gateway Proxy + 스니핑 + Server Agent | User Tracer, Agent | 금융권 거의 전부, 6,000+ | DB접근제어 1위 |
| **신시웨이 PETRA** | 하이브리드 3종 | ID기반 SQL 처리 특허 | 공공·국방·금융 400+ | 11종 DBMS 지원 |
| **웨어밸리 Chakra Max** | 인박스/아웃박스 양방향 | 전용 커넥터 | 은행·카드·증권 | 결과값 제어 |
| **소만사 WAS-i** | WAS 전용 어플라이언스 | HTTP-DB 상관분석 | LG전자·한수원·통계청 | IP 세탁 해결 |
| **넷앤드 HIWARE** | Gateway + IAM | 제한적 | IAM 1위 | 특권계정 중심 |

**경쟁 지형의 시사점**: 이지서티는 BCI Agent로 이기종 프레임워크(Struts·순수 Servlet·Spring)에서도 작동하나, **Agent 자체에 대한 금융권 일부 고객의 심리적 거부감**이 실존한다. Datablocks는 **"Agent 없이 애플리케이션 빌드 레이어에서 해결"** 이라는 역(逆)포지셔닝으로 시장에 진입할 여지가 있다.

## Application User Identification 문제의 진짜 해법

커넥션 풀이 야기하는 3-tier 사용자 식별 문제를 푸는 기술은 네 가지이며, 실무에서는 **두세 가지를 조합**해야 제대로 작동한다.

**ThreadLocal + MDC 방식**은 가장 정통적이다. Servlet Filter에서 세션의 로그인 사용자 ID·세션ID·메뉴ID·IP를 UUID 요청식별자와 함께 `ThreadLocal`에 저장하고, MyBatis Interceptor에서 이를 꺼내 SQL 로그에 병기한다. **문제는 비동기 환경이다.** `@Async`·`CompletableFuture`·`ThreadPoolTaskExecutor` 에서 기본 ThreadLocal은 유실되므로 **Alibaba의 TransmittableThreadLocal(TTL)** 을 사용하여 스레드 풀 재사용 시에도 값이 전파되도록 해야 한다. 강남언니 기술블로그가 공개한 `TaskDecorator` 패턴을 따라 `MDC.getCopyOfContextMap()` 복사와 `UserContextHolder.set()` 재주입을 `try-finally`로 감싸면 안전하다. **ThreadLocal 누수는 WAS OOM의 단골 원인**이므로 Filter `finally` 블록의 `clear()` 호출은 타협 불가능한 코딩 규약이다.

**SQL Comment Injection 방식**이 국내 DAM 연계의 사실상 표준이다. MyBatis Interceptor의 `StatementHandler.prepare` 지점에서 `BoundSql`을 리플렉션으로 수정해 원문 SQL 앞에 `/*XPURGE USER=minsuk;SID=abc;IP=10.0.1.5;MENU=CUST_VIEW;REQ=uuid*/`를 prepend하면, 네트워크 DAM 어플라이언스는 TNS 패킷에서 이 주석을 정규식으로 파싱해 사용자 식별자를 확보한다. **중요한 함정은 Oracle shared pool 폭주**다. 주석에 타임스탬프나 요청 UUID 같은 가변값을 넣으면 라이브러리 캐시가 매 요청마다 Miss되어 shared pool 메모리가 폭증한다. 해결책은 **주석에 고정값(USER, MENU)만 넣고 가변 요청ID는 별도 Kafka 이벤트로 송신**하는 것이다. 또한 Oracle 힌트(`/*+ ... */`)와 구분하기 위해 `+` 없는 일반 주석 형태를 써야 한다.

**Oracle setClientInfo / CLIENT_IDENTIFIER 방식**은 DB Native 감사의 정통 답이다. JDBC 4.0 표준 `Connection.setClientInfo("OCSID.CLIENTID", userId)` 호출은 **추가 roundtrip 없이 다음 SQL 실행 시 piggyback 전송**되어(Franck Pachot 실측) `V$SESSION.CLIENT_IDENTIFIER`·Audit Trail·ASH·SQL Trace 전역에 사용자 식별자가 자동 반영된다. **치명적 이슈는 Dirty Session 버그(Oracle MOS Doc ID 2487572.1)** 다. HikariCP가 커넥션을 반환할 때 CLIENT_IDENTIFIER가 자동 clear되지 않아 다음 사용자의 SQL에 이전 사용자의 ID가 남는다. 방어책은 MyBatis Interceptor `finally` 블록의 명시적 `setClientInfo(null)` 호출과 HikariCP `connectionInitSql="BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;"` 의 이중 안전장치다. Tibero는 Oracle OCSID 네임스페이스 호환성이 버전별로 상이하므로 PoC 검증이 필수이며, MSSQL은 2016+ 기준 `sp_set_session_context`로 대체한다.

**4가지 방식 조합의 실전 패턴**은 Filter+Plugin+Kafka 3층 구조다. Filter가 요청 UUID와 access_log를 Kafka `access-log` 토픽에 async 송신하고, Plugin이 동일 UUID와 sql_log를 `sql-log` 토픽에 송신한다. Collector가 UUID로 JOIN해 unified audit record를 생성하고 PII 정규식(주민번호·카드번호·계좌번호) 탐지와 HASH 체인 무결성을 부여한 뒤 WORM 스토리지와 Elasticsearch에 이중 저장한다. 아래 최소 스키마면 "한 줄 조회"가 즉시 가능하다.

```sql
CREATE TABLE access_log (
  req_id VARCHAR(36) PRIMARY KEY, user_id VARCHAR(50), user_ip VARCHAR(45),
  menu_id VARCHAR(100), uri VARCHAR(500), session_id VARCHAR(64),
  ts TIMESTAMP, hash_prev VARCHAR(64), hash_cur VARCHAR(64));

CREATE TABLE sql_log (
  sql_log_id BIGSERIAL PRIMARY KEY, req_id VARCHAR(36) NOT NULL,
  sql_id VARCHAR(200), sql_text CLOB, sql_type VARCHAR(10),
  bind_params CLOB, affected_rows INT, duration_ms INT,
  pii_detected VARCHAR(200), ts TIMESTAMP);

SELECT a.user_id, a.menu_id, s.sql_text, s.pii_detected
  FROM access_log a JOIN sql_log s ON a.req_id = s.req_id
 WHERE a.user_id='minsuk' AND a.ts BETWEEN ? AND ?;
```

## 3중으로 겹치는 금융권 규제 요건

금융회사가 맞추어야 할 접속기록 규제는 한 법이 아니라 **개보법·신용정보법·전자금융감독규정 세 축이 동시에 적용**된다. 아이엠캐피탈과 JB우리캐피탈처럼 여신전문금융회사는 세 축 전부를 중첩 준수해야 한다.

**개인정보보호위원회 고시 제2023-6호(2023.9.22 시행) 제8조**는 접속기록 1년 이상 보관을 원칙으로 하되, **5만명 이상 정보주체·고유식별정보·민감정보를 처리하거나 기간통신사업자인 경우 2년**으로 연장한다. 월 1회 이상 점검이 의무이며, **다운로드 발견 시 사유 확인이 강제**된다. 위·변조·도난·분실 방지는 제3항에 명문화되어 WORM 스토리지 또는 해시체인을 사실상 요구한다. 최신 제2025-9호(2025.10.31 시행)는 일부 정의 개정에 그쳐 제8조는 실질 유지되었다.

**접속기록 6대 요소**(제2조제19호)는 ①계정(취급자 ID), ②접속일시, ③접속지 정보(IP·MAC), ④처리한 정보주체 정보(고객번호·CI), ⑤수행업무(조회/수정/삭제/다운로드), ⑥처리내역(실제 SQL·조회건수)이다. 2024.9.15 확대 시행으로 기록 대상이 "개인정보처리시스템에 접속한 자(정보주체 제외)"로 넓어져 오픈마켓 판매자·외주 운영자까지 포함된다. **제17조(공공시스템)**는 자동화된 분석으로 불법 유출·오남용 시도를 탐지하고 "그 사유를 소명"하도록 요구하는데, 이 소명 개념이 민간 금융권으로 확산 중이다.

금융권은 여기에 두 층을 더 얹어야 한다. **신용정보업감독규정 별표3**은 개인신용정보 수집·이용·제공·폐기 내역을 **3년** 보존하도록 요구한다. **전자금융감독규정시행세칙 제13조제1항제9호(2025.2.3 신설)** 는 "사용자 로그인·액세스 로그 등 접근기록"을 명시하여 **SQL 원문 로깅이 사실상 의무**가 되었다. 전자금융거래법 제22조의 전자금융거래기록은 **5년**이다. 따라서 금융권 실무 기준은 **"3법 중 가장 엄격한 요건 = 최소 3년, 전자금융거래기록은 5년"** 이다.

| 요건 | 개보법 제8조 | 신용정보법 별표3 | 전자금융감독규정 |
|---|---|---|---|
| 보관 기간 | 1년 (특례 2년) | 개인신용정보 내역 3년 | 가동기록 1년 / 전자금융거래기록 5년 |
| 점검 주기 | 월 1회 + 다운로드 사유 확인 | CISO 정기 점검 (3년 보존) | CISO 정기 점검 |
| 위변조 방지 | 명문 요구 (제3항) | 별표3 통제 | 별도 보호대책 |
| SQL 원문 | "수행업무" 권고 | 처리 내용 명시 | **2025.2.3 신설로 사실상 의무** |

**처리목적 소명 트렌드**는 더 이상 선택이 아니다. LG유플러스(2024.1, 과징금 68.1억)는 "접근권한·접속기록 관리 미비, 대량 추출·전송 기록 미보존, 비정상 행위 탐지 부실"이 처분 핵심이었고, 카카오페이·애플(2025.1.23, 83.7억)은 4,000만명 542억건의 알리페이 국외이전에서 "**왜 조회·전송했는가의 처리목적 소명 실패**"가 결정적이었다. 카카오(2024.5, 역대 최대 151.4억) 역시 조회 사유 증빙 부재가 핵심이었다. 감독기관의 요구는 이미 **단순 접속기록 존재 여부를 넘어 조회 사유의 사전 입력·사후 증빙·UEBA 기반 이상행위 탐지**로 이동했다.

X-PURGE가 충족해야 할 기능 체크리스트는 다음과 같다. 6대 요소 자동 수집, 3법 차등 보관정책(1년/2년/3년/5년 테이블별 retention 엔진), WORM 기반 해시체인 위변조 방지, 민감정보 AES-256 저장과 KMS 연동, 월 1회 자동점검 리포트, **다운로드 사유 소명 워크플로**(결재 연계), UEBA 이상행위 탐지, SQL 원문 로깅과 정책 기반 마스킹, 공공시스템 제17조 대응 자동화 분석 모듈, 감독기관 제출 패키지의 1-클릭 export.

## X-PURGE의 단·중·장기 아키텍처 청사진

위 네 영역의 교차점에서 X-PURGE가 나아갈 길은 명확하다. **이지서티 BCI Agent의 완결성을 노릴 것이 아니라, "Agent 없이 애플리케이션 빌드 경로로 충분하다"는 가벼움**을 무기로 삼아야 한다. 아이엠캐피탈·JB우리캐피탈 같은 2금융권 고객에게는 기존 DAM(대개 피앤피 DBSAFER나 이지서티 PSM)을 교체하자는 제안이 아니라, **"기존 DAM으로 못 잡는 애플리케이션 컨텍스트와 처리목적 소명 레이어를 X-PURGE가 채운다"** 는 보완 포지셔닝이 수주 확률을 극대화한다.

**단기 PoC 아키텍처(1~3개월, 개발계 즉시 적용 가능)** 는 **MyBatis Interceptor + Servlet Filter + TransmittableThreadLocal** 3종 세트다. Filter에서 세션 사용자·요청UUID를 TTL ThreadLocal에 저장하고 MyBatis Plugin이 BoundSql의 ParameterMapping을 리플렉션으로 풀어 실제 바인딩 값이 포함된 SQL을 재구성한다. 로그는 Logback MDC에 `%X{userId}`·`%X{reqId}` 패턴으로 자동 삽입되고, 비동기 Appender로 파일 또는 Kafka에 기록한다. 이 단계는 **기존 Mapper XML·DAO·Service 코드 수정 0줄, 설정파일과 Bean 등록만으로 완료**되며 운영 변경관리 심사 부담이 최소다. 비동기 환경 유실을 막기 위해 `@Async` 풀에는 `ClonedTaskDecorator`를 반드시 적용한다.

**중기 금융권 정식 납품 아키텍처(3~9개월)** 는 여기에 **SQL Comment Injection, Oracle setClientInfo, DataSource-Proxy, Kafka 기반 Collector** 를 추가한다. MyBatis Plugin이 `/*XPURGE USER=minsuk;MENU=CUST_VIEW*/` 주석을 SQL 앞에 prepend하여 피앤피 DBSAFER와 이지서티 PSM이 패킷 레벨에서 이를 즉시 파싱하도록 한다. 주석은 고정값 중심으로 설계해 shared pool 폭주를 방지하고, 가변 요청UUID는 Kafka 이벤트로만 송신한다. Oracle 환경에서는 `Connection.setClientInfo("OCSID.CLIENTID", userId)`를 병행 호출하여 V\$SESSION·Audit Trail·ASH에도 사용자 식별자가 기록되도록 하고, `finally` 블록의 null clear와 HikariCP `connectionInitSql` 이중 방어로 Dirty Session 버그를 차단한다. JdbcTemplate·Batch 누락을 메우기 위해 DataSource-Proxy Listener를 병행하여 MyBatis Plugin의 사각지대를 덮는다. **차별화 포인트는 "DAM 원문 SQL + X-PURGE의 메뉴·처리목적·PII 자동 라벨링·소명 워크플로"** 의 JOIN 가능한 저장 구조다. 경쟁사가 6요소만 기록할 때 X-PURGE는 **"왜 이 SQL이 실행됐는가의 업무 맥락"** 을 제공한다. 저장소는 WORM 객체 스토리지와 Elasticsearch 이원화, 해시체인 무결성, 3법 차등 retention 엔진(1/2/3/5년 테이블별 정책)을 기본 탑재한다.

**장기 제품화 로드맵(9~24개월)** 은 이기종 WAS·프레임워크 커버리지 확대다. Tibero·Altibase·Goldilocks 등 국산 DB의 `setClientInfo` 호환성 검증과 fallback 자동 전환, MSSQL `SESSION_CONTEXT` 어댑터, **JPA/Hibernate StatementInspector 연동**, Spring WebFlux Reactor Context 대응을 추가한다. 선택적 옵션으로 **경량 Java Agent** 를 제공하되 BCI 방식의 바이트코드 변조 대신 **Agent는 Filter+Plugin Bean을 자동 등록하는 역할만 수행**하여 코드 무수정을 유지한다. 금융권 인증(CC EAL3 이상, GS 1등급, CSAP), 조달청 우수조달제품 등록, 개인정보보호위원회·금감원 제출용 표준 포맷 export 기능, UEBA 기반 이상행위 탐지(심야 대량조회·동일계정 다지역 접속·비정기 조회 패턴), 다운로드 사유 소명 결재 연계가 완성되면 이지서티 PSM과 동등 경쟁 가능한 제품이 된다.

## 고객 앞에서 말할 수 있는 세 문장

**첫째**, X-PURGE는 MyBatis Interceptor 기반으로 설계되어 고객사의 운영계 코드를 단 한 줄도 수정하지 않고 설정 파일과 Bean 등록만으로 WAS 접속기록과 SQL 실행기록을 Request UUID로 결합해 저장합니다. **둘째**, 기존에 운영 중인 피앤피 DBSAFER나 이지서티 PSM을 교체하는 것이 아니라, SQL Comment Injection으로 그 솔루션들이 수집한 패킷에 사용자·메뉴 컨텍스트를 자동으로 실어 보내 기존 투자를 그대로 살리면서 동시에 2025년 2월 신설된 전자금융감독규정시행세칙 제13조제1항제9호의 "사용자 액세스 로그 SQL 원문 보관" 요건을 별도 어플라이언스 추가 없이 충족합니다. **셋째**, LG유플러스·카카오페이 처분 사례에서 감독기관이 핵심으로 본 "처리목적 소명" 요건에 대해, X-PURGE는 단순 기록을 넘어 다운로드 사유 결재 워크플로와 UEBA 이상행위 탐지를 내장하여 금감원·개인정보보호위원회 조사에서 즉시 제출 가능한 감사 증적 패키지를 1-클릭으로 산출합니다.

이 세 문장은 기술 증빙(MyBatis Plugin 코드 샘플), 경쟁 우위(DAM 연계·보완 포지셔닝), 법규 대응(2025.2.3 신설 세칙·최근 처분 판례)을 모두 담고 있어 캐피탈사 IT 담당자·보안 담당자·법무팀 어느 자리에서든 자신감 있게 발화 가능한 수준이다.