# Step "Running" 고착 문제 분석

## 증상
- Docker Tomcat 배포 환경에서 order 실행 시 step이 "Running"으로 바뀐 후 실제 BatchStepWorker가 동작하지 않음
- step이 영구 "Running" 상태로 고착되어 이후 스케줄링에서도 재처리 안됨

## 원인 분석

### 코드 흐름 (JobScheduler.java)

```
L517: orderStepMapper.updatebefore(...)   <- step = "Running" 으로 변경
L529: new AES256Util()                    <- try-catch 바깥 (예외 시 미포착)
L530: new DataSourceCache(...)            <- try-catch 바깥 (예외 시 미포착)
       ...
L549: try {                               <- 여기부터 catch 범위
L560:   Executors.newFixedThreadPool()    <- thread pool 생성
```

### 고착 메커니즘

**1회차 runOrder() 호출:**
1. L517에서 step -> "Running" 설정
2. L529~530에서 AES256Util 또는 DataSourceCache 생성 중 예외 발생
3. 예외가 try-catch(L549) 범위 바깥이므로 doRunOrder() -> runOrder() 까지 전파
4. SpringAsyncConfig의 HandlingExecutor.createWrappedRunnable()이 예외를 catch만 하고 삼킴 (rethrow 안함)
5. 결과: step = "Running"인데 worker는 한 번도 시작 안됨

**2회차 이후 runOrder() 호출 (6초 주기):**
```java
// JobScheduler.java L468
if (piiorderstep.getStatus().equals("Running")) break;
```
- "이미 실행 중"으로 판단하여 break -> 영원히 재처리 안됨

### updateend()로 복구 불가

모든 테이블이 "Wait condition" 상태일 때 updateend() SQL:
```sql
ok     = N (> 0)   -- Wait condition은 Ended OK가 아님
notok  = 0
running = 0
wait   = N (> 0)   -- when wait > 0 -> 'Running'
```
-> step이 다시 "Running"으로 설정되어 고착 반복

## 진단 로그 (추가됨)

JobScheduler.java에 3개 구간 로그 추가:

```
1. "Initializing AES/DataSourceCache"   <- 이것만 찍히면 AES/DataSourceCache 생성 실패
2. "AES/DataSourceCache initialized OK" <- 여기까지 찍히면 초기화 성공
3. "ThreadPool creating"                <- 여기까지 찍히면 thread pool 생성 진입
4. "BatchStepWorker started" (기존)     <- 여기까지 찍히면 worker 실제 실행
```

- 1번만 찍히고 2번 없음: AES 또는 DataSourceCache 초기화 문제 (DB 접속, 암호화 키 등)
- 3번까지 찍히고 4번 없음: thread 생성 자체 실패 (Docker 리소스 제한 등)

## 수정 방안

AES256Util, DataSourceCache 생성을 try 블록 안으로 이동하고, 실패 시 step 상태 복구:

```java
DataSourceCache dsCache = null;
try {
    AES256Util aes = new AES256Util();
    dsCache = new DataSourceCache(databaseMapper, aes, threadcnt);
    // ... warm-up, thread pool 생성/실행 ...
} catch (Exception e) {
    LogUtil.log("ERROR", "BatchStepWorker failed to start: ...");
    // 1단계: 미완료 테이블 "Ended not OK"로 마킹 (Wait condition -> Ended not OK)
    for (PiiOrderStepTableVO tbl : ordersteptablelist) {
        if (!"Ended OK".equals(tbl.getStatus()) && !"Ended not OK".equals(tbl.getStatus())) {
            orderStepTableUpdateMapper.updateStepTableStatus(
                tbl.getOrderid(), tbl.getStepid(), tbl.getTableid(),
                "Ended not OK", 0, "BatchStepWorker init failed: " + e.getMessage());
        }
    }
    // 2단계: step 상태 재계산 (notok > 0 -> "Ended not OK")
    orderStepMapper.updateend(...);
} finally {
    if (dsCache != null) dsCache.close();
}
```

**주의:** updateend()만 호출하면 모든 테이블이 Wait condition이라 step이 다시 "Running"이 됨.
반드시 테이블을 "Ended not OK"로 먼저 변경한 후 updateend()를 호출해야 함.

## 정상 흐름에 미치는 영향

- 정상 케이스: 코드 실행 경로 100% 동일 (변수 스코프만 try 안으로 이동)
- catch 블록: 예외 발생 시에만 실행 (현재는 조용히 죽는 구간)
- finally의 dsCache null 체크: dsCache 생성 전 예외 시 NPE 방지
