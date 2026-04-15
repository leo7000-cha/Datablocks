# 리소스 설정 가이드

## 목차
1. [개발 vs 운영 환경 비교](#1-개발-vs-운영-환경-비교)
2. [JVM 튜닝 파라미터 설명](#2-jvm-튜닝-파라미터-설명)
3. [MariaDB InnoDB 튜닝 설명](#3-mariadb-innodb-튜닝-설명)
4. [다른 서버 사양에 맞는 조정 방법](#4-다른-서버-사양에-맞는-조정-방법)
5. [리소스 사용량 모니터링](#5-리소스-사용량-모니터링)

---

## 1. 개발 vs 운영 환경 비교

### 1.1 전체 리소스 할당 비교

| 서비스 | 개발 (32GB RAM) | 운영 (64GB RAM) | 비고 |
|-------|----------------|----------------|------|
| **MariaDB** | | | |
| - CPU (limit) | 2.0 Core | 2.0 Core | |
| - CPU (reservation) | 1.0 Core | 1.0 Core | |
| - Memory (limit) | 4 GB | 10 GB | |
| - Memory (reservation) | 2 GB | 4 GB | |
| - InnoDB Buffer Pool | 2 GB | 6 GB | |
| **DLM (Spring Boot)** | | | |
| - CPU (limit) | 3.0 Core | 3.0 Core | |
| - CPU (reservation) | 1.5 Core | 1.5 Core | |
| - Memory (limit) | 12 GB | 24 GB | |
| - Memory (reservation) | 4 GB | 8 GB | |
| - JVM Heap 최소 (-Xms) | 2 GB | 8 GB | |
| - JVM Heap 최대 (-Xmx) | 8 GB | 16 GB | |
| **DLM-Privacy-AI** | | | |
| - CPU (limit) | 2.0 Core | 2.0 Core | |
| - CPU (reservation) | 1.0 Core | 1.0 Core | |
| - Memory (limit) | 8 GB | 20 GB | |
| - Memory (reservation) | 2 GB | 4 GB | |
| **Portainer** | | | |
| - CPU (limit) | 0.5 Core | 0.5 Core | 동일 |
| - Memory (limit) | 512 MB | 512 MB | 동일 |
| **OS/Docker 예약** | 1 Core / 8 GB | 1 Core / 10 GB | |
| **합계 (limit 기준)** | 7.5 Core / 25 GB | 7.5 Core / 35 GB | |
| **서버 여유분** | 0.5 Core / 7 GB | 0.5 Core / 29 GB | |

### 1.2 사용하는 Compose 파일 위치

```
개발 환경:
  /app/Datablocks/docker-compose.yml
  /app/Datablocks/mariadb/conf.d/custom.cnf

운영 환경 (오버라이드):
  /app/Datablocks/docker-compose.yml          (기본)
  /app/Datablocks/docker-compose.prod.yml     (오버라이드)
  /app/Datablocks/mariadb/conf.d/custom-prod.cnf
```

---

## 2. JVM 튜닝 파라미터 설명

### 2.1 개발 환경 JVM 설정 (Dockerfile ENV 기본값)

```
JAVA_OPTS=
  -Xms2g                          # 힙 초기 크기: 2GB
  -Xmx8g                          # 힙 최대 크기: 8GB
  -XX:+UseG1GC                    # G1 GC 사용
  -XX:MaxGCPauseMillis=200        # GC 최대 정지 시간 목표: 200ms
  -XX:+UseContainerSupport        # 컨테이너 메모리 한도 인식
  -XX:MaxRAMPercentage=70.0       # 컨테이너 메모리의 70%를 힙 최대로
  -XX:+HeapDumpOnOutOfMemoryError # OOM 시 힙 덤프 생성
  -XX:HeapDumpPath=/app/logs/heapdump.hprof
  -Djava.security.egd=file:/dev/./urandom   # 난수 생성기 (시작 속도)
  -Dfile.encoding=UTF-8
  -Duser.timezone=Asia/Seoul
```

### 2.2 운영 환경 JVM 설정 (docker-compose.prod.yml 오버라이드)

```
JAVA_OPTS=
  -Xms8g                          # 힙 초기 크기: 8GB (운영에서 메모리 예약 확실히)
  -Xmx16g                         # 힙 최대 크기: 16GB
  -XX:+UseG1GC
  -XX:MaxGCPauseMillis=200
  -XX:+UseContainerSupport
  -XX:MaxRAMPercentage=70.0
  -XX:+HeapDumpOnOutOfMemoryError
  -XX:HeapDumpPath=/app/logs/heapdump.hprof
  -Djava.security.egd=file:/dev/./urandom
  -Dfile.encoding=UTF-8
  -Duser.timezone=Asia/Seoul
```

### 2.3 각 파라미터 상세 설명

#### 힙 메모리 설정

| 파라미터 | 설명 | 권장값 계산 |
|---------|------|-----------|
| `-Xms` | JVM 힙 초기 크기. 시작 시 미리 할당. | 컨테이너 메모리의 25~40% |
| `-Xmx` | JVM 힙 최대 크기. 이 이상 사용 시 OOM. | 컨테이너 메모리의 60~70% |

> **팁**: `-Xms`와 `-Xmx`를 같은 값으로 설정하면 힙 크기 변경으로 인한 GC 오버헤드를 줄일 수 있습니다. 단, 시작 시 메모리를 모두 예약하므로 전체 메모리 사용량이 증가합니다.

#### GC(가비지 컬렉션) 설정

| 파라미터 | 설명 |
|---------|------|
| `-XX:+UseG1GC` | G1(Garbage First) GC 사용. Java 9+ 기본값. 대규모 힙(4GB+)에 적합. |
| `-XX:MaxGCPauseMillis=200` | GC로 인한 최대 정지 시간 목표(200ms). 실제로는 목표이며 보장되지 않음. |

> **팁**: 대규모 힙(16GB+)에서는 `-XX:MaxGCPauseMillis=100` 으로 줄이면 응답성이 향상될 수 있지만, GC 빈도가 증가할 수 있습니다.

#### 컨테이너 지원

| 파라미터 | 설명 |
|---------|------|
| `-XX:+UseContainerSupport` | Docker/cgroup 메모리 제한을 인식하여 JVM이 컨테이너 메모리를 기준으로 설정. Java 8u191+ 기본 활성화. |
| `-XX:MaxRAMPercentage=70.0` | `UseContainerSupport` 와 함께 작동. 컨테이너 메모리의 70%를 힙 최대로 설정. `-Xmx`가 명시되면 해당 값 우선. |

#### 유틸리티 설정

| 파라미터 | 설명 |
|---------|------|
| `-XX:+HeapDumpOnOutOfMemoryError` | OOM 발생 시 힙 덤프를 파일로 저장. 원인 분석에 필수. |
| `-XX:HeapDumpPath=/app/logs/heapdump.hprof` | 힙 덤프 저장 경로 (볼륨에 마운트됨). |
| `-Djava.security.egd=file:/dev/./urandom` | `/dev/random` 대신 `/dev/urandom` 사용. 컨테이너 환경에서 난수 생성 블로킹 방지. |
| `-Dfile.encoding=UTF-8` | 파일 인코딩 명시. 한글 처리 필수. |
| `-Duser.timezone=Asia/Seoul` | JVM 타임존. TZ 환경변수와 함께 설정. |

---

## 3. MariaDB InnoDB 튜닝 설명

### 3.1 핵심 설정 비교

| 설정 항목 | 개발 (custom.cnf) | 운영 (custom-prod.cnf) | 설명 |
|---------|-----------------|---------------------|------|
| `innodb_buffer_pool_size` | 2G | 6G | 가장 중요한 설정 |
| `innodb_log_file_size` | 256M | 512M | Redo log 크기 |
| `innodb_log_buffer_size` | 32M | 64M | 로그 버퍼 크기 |
| `tmp_table_size` | 128M | 256M | 메모리 임시 테이블 최대 크기 |
| `max_heap_table_size` | 128M | 256M | MEMORY 엔진 테이블 최대 크기 |
| `sort_buffer_size` | 2M | 4M | 정렬 버퍼 (연결당 할당) |
| `join_buffer_size` | 2M | 4M | 조인 버퍼 (연결당 할당) |

### 3.2 각 파라미터 상세 설명

#### innodb_buffer_pool_size (가장 중요)

```
개발:  innodb_buffer_pool_size = 2G   (4GB 컨테이너의 50%)
운영:  innodb_buffer_pool_size = 6G   (10GB 컨테이너의 60%)
```

InnoDB 데이터와 인덱스를 메모리에 캐시하는 버퍼. **가장 중요한 MariaDB 성능 설정**.

- **너무 작으면**: 디스크 I/O 증가, 쿼리 속도 저하
- **너무 크면**: 운영체제 스왑 발생, 전체 성능 저하
- **권장**: 컨테이너 메모리의 50~70%

버퍼풀 히트율 확인:
```sql
SELECT
  (1 - Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests) * 100
  AS hit_rate
FROM (
  SELECT
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS
     WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') AS Innodb_buffer_pool_reads,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS
     WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') AS Innodb_buffer_pool_read_requests
) t;
-- 95% 이상이 목표
```

#### innodb_log_file_size

Redo log 파일 크기. 트랜잭션 쓰기 성능에 영향.

- **너무 작으면**: 체크포인트 빈발로 I/O 증가
- **너무 크면**: 충돌 복구 시간 증가
- **권장**: `innodb_buffer_pool_size`의 25~50%

#### innodb_flush_log_at_trx_commit

```
innodb_flush_log_at_trx_commit = 1  (기본값, ACID 완전 준수)
```

| 값 | 의미 | 안전성 | 성능 |
|----|------|--------|------|
| 0 | 1초마다 디스크에 쓰기 | 낮음 | 빠름 |
| 1 | 매 커밋마다 디스크에 쓰기 | 높음 (권장) | 보통 |
| 2 | 매 커밋마다 OS 캐시에 쓰기 | 중간 | 빠름 |

> **운영 환경**: 반드시 `1`로 설정하여 데이터 무결성을 보장하세요.

#### max_connections

```
max_connections = 500  (개발/운영 동일)
```

동시 접속 수 제한. 연결당 메모리(약 1~2MB)를 차지하므로 실제 필요한 수로 조정합니다.

메모리 사용량 계산:
```
max_connections * (sort_buffer_size + join_buffer_size + read_buffer_size + ...)
= 500 * (2M + 2M + 1M + ...) ≈ 500 * 8M = 4GB (최대, 실제는 훨씬 적음)
```

---

## 4. 다른 서버 사양에 맞는 조정 방법

### 4.1 16GB RAM 서버에서 실행하는 경우

`docker-compose.yml`을 다음과 같이 수정합니다:

```yaml
services:
  mariadb:
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 3G       # 변경: 4G → 3G
        reservations:
          memory: 1G

  dlm:
    environment:
      JAVA_OPTS: >-
        -Xms1g -Xmx4g     # 변경: 2g/8g → 1g/4g
        -XX:+UseG1GC
        -XX:MaxGCPauseMillis=200
        -XX:+UseContainerSupport
        -XX:MaxRAMPercentage=70.0
        -XX:+HeapDumpOnOutOfMemoryError
        -XX:HeapDumpPath=/app/logs/heapdump.hprof
        -Djava.security.egd=file:/dev/./urandom
        -Dfile.encoding=UTF-8
        -Duser.timezone=Asia/Seoul
    deploy:
      resources:
        limits:
          cpus: "3.0"
          memory: 6G       # 변경: 12G → 6G
        reservations:
          memory: 2G

  dlm-privacy-ai:
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 4G       # 변경: 8G → 4G
        reservations:
          memory: 1G
```

MariaDB 설정도 조정 (`mariadb/conf.d/custom.cnf`):
```ini
innodb_buffer_pool_size = 1G    # 3G 컨테이너의 33%
tmp_table_size = 64M
max_heap_table_size = 64M
```

### 4.2 128GB RAM 서버에서 실행하는 경우

`docker-compose.prod.yml`을 다음과 같이 수정합니다:

```yaml
services:
  mariadb:
    deploy:
      resources:
        limits:
          memory: 20G      # 버퍼풀 12G 예상
        reservations:
          memory: 8G

  dlm:
    environment:
      JAVA_OPTS: >-
        -Xms16g -Xmx32g   # 40G 컨테이너의 40%/80%
        -XX:+UseG1GC
        -XX:MaxGCPauseMillis=200
        -XX:+UseContainerSupport
        -XX:MaxRAMPercentage=80.0
        -XX:+HeapDumpOnOutOfMemoryError
        -XX:HeapDumpPath=/app/logs/heapdump.hprof
        -Djava.security.egd=file:/dev/./urandom
        -Dfile.encoding=UTF-8
        -Duser.timezone=Asia/Seoul
    deploy:
      resources:
        limits:
          memory: 40G
        reservations:
          memory: 16G

  dlm-privacy-ai:
    deploy:
      resources:
        limits:
          memory: 48G      # AI 모델 대용량
        reservations:
          memory: 8G
```

### 4.3 리소스 조정 가이드라인

#### 메모리 계산 공식

```
총 RAM = MariaDB_limit + DLM_limit + AI_limit + Portainer_limit + OS_예약

OS 예약 = 총 RAM의 15~20%
MariaDB_limit = 원하는 버퍼풀_크기 / 0.6 (버퍼풀은 컨테이너 메모리의 60%)
DLM_limit = 원하는 JVM_Xmx / 0.7 (JVM 힙은 컨테이너 메모리의 70%)
```

#### 예시: 48GB RAM 서버

```
OS 예약:    48GB * 0.18 = 8.6GB → 9GB
AI 서비스:  48GB * 0.25 = 12GB  (모델 크기에 따라 조정)
MariaDB:   필요 버퍼풀 4GB → limit = 4GB/0.6 = 6.7GB → 7GB
DLM JVM:   Xmx = 14GB → limit = 14GB/0.7 = 20GB
           합계: 9 + 12 + 7 + 20 = 48GB ← 딱 맞음
```

---

## 5. 리소스 사용량 모니터링

### 5.1 실시간 모니터링

```bash
# 1초마다 갱신 (Ctrl+C로 종료)
watch -n 1 'docker stats --no-stream --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"'
```

### 5.2 메모리 사용 추세 기록

```bash
# 10분간 30초마다 메모리 기록
for i in $(seq 1 20); do
  echo "=== $(date) ==="
  docker stats --no-stream --format \
    "{{.Name}}: CPU={{.CPUPerc}} MEM={{.MemUsage}} ({{.MemPerc}})"
  sleep 30
done > /tmp/memory_trend.txt

# 결과 확인
cat /tmp/memory_trend.txt | grep dlm-app
```

### 5.3 JVM 상세 메모리 확인

```bash
# JVM 힙 사용량 (jcmd 사용, JDK 포함 필요)
docker exec dlm-app sh -c "jcmd 1 VM.native_memory summary 2>/dev/null" || \
echo "jcmd를 사용할 수 없음. eclipse-temurin:11-jre에는 포함되지 않을 수 있음"

# /proc/meminfo로 실제 RSS 확인 (cgroup)
docker exec dlm-app sh -c "cat /proc/1/status | grep -E 'VmRSS|VmSize|VmPeak'"

# cgroup v2 메모리
docker exec dlm-app sh -c "cat /sys/fs/cgroup/memory.current 2>/dev/null || \
  cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null"
```

### 5.4 MariaDB 메모리 사용량 계산

```bash
docker exec dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
SELECT
  ROUND(@@innodb_buffer_pool_size / 1024 / 1024 / 1024, 2) AS buffer_pool_GB,
  ROUND(@@innodb_log_buffer_size / 1024 / 1024, 0) AS log_buffer_MB,
  @@max_connections AS max_connections,
  ROUND(@@sort_buffer_size / 1024 / 1024, 1) AS sort_buf_MB,
  ROUND(@@join_buffer_size / 1024 / 1024, 1) AS join_buf_MB,
  -- 예상 최대 메모리 사용량 (rough estimate)
  ROUND((@@innodb_buffer_pool_size +
         @@innodb_log_buffer_size +
         @@max_connections * (@@sort_buffer_size + @@join_buffer_size + 1024*1024*2)
        ) / 1024 / 1024 / 1024, 2) AS estimated_max_GB
\G
" 2>/dev/null
```

### 5.5 리소스 경보 스크립트

```bash
# 메모리 80% 초과 시 경보 출력
cat > /usr/local/bin/dlm-alert.sh << 'EOF'
#!/bin/bash
THRESHOLD=80

while true; do
  docker stats --no-stream --format "{{.Name}} {{.MemPerc}}" | \
  grep dlm | while read name pct; do
    # % 기호 제거
    val=${pct%\%}
    # 소수점 처리 (정수 비교)
    int_val=${val%.*}
    if [ -n "$int_val" ] && [ "$int_val" -gt "$THRESHOLD" ]; then
      echo "[경보] $(date) $name 메모리 $pct 사용 (임계값: ${THRESHOLD}%)"
    fi
  done
  sleep 60
done
EOF
chmod +x /usr/local/bin/dlm-alert.sh

# 백그라운드 실행
nohup /usr/local/bin/dlm-alert.sh >> /var/log/dlm-alert.log 2>&1 &
```

### 5.6 리소스 제한 변경 시 주의사항

> **MariaDB**: 컨테이너 메모리 limit을 줄이면 InnoDB 버퍼풀도 줄여야 합니다. 그렇지 않으면 MariaDB가 시작되지 않습니다.
>
> `innodb_buffer_pool_size < 컨테이너 메모리 limit * 0.7` 을 반드시 지키세요.

> **DLM**: `-Xmx` 값이 컨테이너 메모리 limit보다 크면 JVM이 OOMKilled 됩니다.
>
> `-Xmx < 컨테이너 메모리 limit * 0.8` 을 반드시 지키세요.

> **DLM-Privacy-AI**: AI 모델 파일 크기에 따라 필요 메모리가 크게 달라집니다. 모델 로딩 시 메모리 사용량을 사전에 확인하세요.
