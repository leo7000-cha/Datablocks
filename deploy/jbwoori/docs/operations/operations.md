# 일상 운영 가이드

## 목차
1. [Portainer를 이용한 모니터링](#1-portainer를-이용한-모니터링)
2. [로그 관리](#2-로그-관리)
3. [데이터베이스 백업 및 복원](#3-데이터베이스-백업-및-복원)
4. [헬스체크 확인](#4-헬스체크-확인)
5. [리소스 모니터링](#5-리소스-모니터링)
6. [컨테이너 셸 접속](#6-컨테이너-셸-접속)
7. [개별 서비스 업데이트](#7-개별-서비스-업데이트)
8. [MariaDB 유지보수](#8-mariadb-유지보수)

---

## 1. Portainer를 이용한 모니터링

### 1.1 접속

- **URL**: `http://서버IP:9000`
- 최초 설정: admin 계정 생성 후 "local" 환경 선택

### 1.2 컨테이너 상태 모니터링

```
Portainer 접속
  → 왼쪽 메뉴: local
  → Containers
```

| 상태 표시 | 의미 |
|---------|------|
| running (green) | 정상 실행 중 |
| healthy | 헬스체크 통과 |
| unhealthy | 헬스체크 실패 (주의) |
| exited | 종료됨 (오류 확인 필요) |

### 1.3 Portainer에서 로그 확인

```
Containers → [컨테이너 클릭] → Logs
  → Auto-refresh logs 체크 시 실시간 갱신
  → Lines 값을 늘려 더 많은 로그 확인
```

### 1.4 Portainer에서 리소스 통계 확인

```
Containers → [컨테이너 클릭] → Stats
  → CPU 사용률, 메모리 사용량, 네트워크 I/O, 디스크 I/O 실시간 확인
```

### 1.5 Portainer에서 컨테이너 재시작

```
Containers → [컨테이너 클릭] → 상단 Restart 버튼
```

---

## 2. 로그 관리

### 2.1 Docker Compose 로그 확인

```bash
# 모든 서비스 로그 (최근 200줄 + 실시간)
docker compose logs -f --tail=200

# 특정 서비스만
docker compose logs -f --tail=200 dlm
docker compose logs -f --tail=200 dlm-privacy-ai
docker compose logs -f --tail=200 mariadb

# 운영 환경에서
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f --tail=200 dlm
```

### 2.2 타임스탬프 포함 로그

```bash
# 타임스탬프 포함
docker compose logs -f --timestamps dlm

# 특정 시간 이후 로그 (Docker 24.0+)
docker compose logs --since="2024-01-01T09:00:00" dlm
docker compose logs --since="1h" dlm      # 최근 1시간
docker compose logs --since="30m" dlm     # 최근 30분
```

### 2.3 에러 로그 필터링

```bash
# ERROR 레벨 로그만 추출
docker compose logs dlm 2>&1 | grep -i "error\|exception\|warn"

# Spring Boot 예외 스택트레이스 확인
docker compose logs dlm 2>&1 | grep -A 20 "Exception"
```

### 2.4 Docker JSON 로그 파일 직접 접근

```bash
# 컨테이너 로그 파일 위치 확인
docker inspect dlm-app --format='{{.LogPath}}'
# 예: /var/lib/docker/containers/<ID>/<ID>-json.log

# 로그 파일 직접 읽기 (root 권한 필요)
sudo tail -f $(docker inspect dlm-app --format='{{.LogPath}}')
```

### 2.5 로그 로테이션 설정

DLM 프로젝트는 이미 `docker-compose.yml`에서 로그 로테이션이 설정되어 있습니다.

```yaml
# 현재 설정 (docker-compose.yml 참조)
logging:
  driver: json-file
  options:
    max-size: "100m"   # 최대 100MB
    max-file: "5"      # 최대 5개 파일 (총 500MB)
```

수동으로 로그를 비우고 싶을 때:

```bash
# 특정 컨테이너 로그 비우기 (root 권한 필요)
sudo truncate -s 0 $(docker inspect dlm-app --format='{{.LogPath}}')
```

### 2.6 애플리케이션 로그 (볼륨에 저장된 로그)

```bash
# DLM Spring Boot 로그 확인
docker exec -it dlm-app ls /app/logs/
docker exec -it dlm-app tail -f /app/logs/application.log

# DLM Logback 로그 (컨테이너 내 /app/logs 경로)
docker exec -it dlm-app ls /app/logs/

# AI 서비스 로그
docker exec -it dlm-privacy-ai ls /app/logs/
docker exec -it dlm-privacy-ai tail -f /app/logs/app.log

# MariaDB 슬로우 쿼리 로그
docker exec -it dlm-mariadb tail -f /var/log/mysql/slow-query.log
```

---

## 3. 데이터베이스 백업 및 복원

### 3.1 전체 데이터베이스 백업

```bash
# 백업 디렉토리 생성
mkdir -p /backup/mariadb

# 전체 데이터베이스 백업 (트랜잭션 일관성 보장)
docker exec dlm-mariadb mariadb-dump \
  -u root -p"${MARIADB_ROOT_PASSWORD}" \
  --all-databases \
  --single-transaction \
  --flush-logs \
  --master-data=2 \
  > /backup/mariadb/all_databases_$(date +%Y%m%d_%H%M%S).sql

# 실제 사용 시 (환경변수가 없는 경우 직접 입력)
docker exec dlm-mariadb mariadb-dump \
  -u root -p'실제_root_비밀번호' \
  --all-databases --single-transaction \
  > /backup/mariadb/all_$(date +%Y%m%d_%H%M%S).sql
```

### 3.2 cotdl 데이터베이스만 백업

```bash
# cotdl DB 백업
docker exec dlm-mariadb mariadb-dump \
  -u cotdl -p'cotdl_비밀번호' \
  --single-transaction \
  cotdl \
  > /backup/mariadb/cotdl_$(date +%Y%m%d_%H%M%S).sql

# 압축 백업 (용량 절약)
docker exec dlm-mariadb mariadb-dump \
  -u root -p'root_비밀번호' \
  --single-transaction cotdl | \
  gzip > /backup/mariadb/cotdl_$(date +%Y%m%d_%H%M%S).sql.gz

echo "백업 완료: $(ls -lh /backup/mariadb/ | tail -1)"
```

### 3.3 특정 테이블만 백업

```bash
# 특정 테이블 백업
docker exec dlm-mariadb mariadb-dump \
  -u root -p'root_비밀번호' \
  cotdl \
  테이블명1 테이블명2 \
  > /backup/mariadb/tables_$(date +%Y%m%d_%H%M%S).sql
```

### 3.4 자동 백업 스크립트 (cron 등록)

```bash
# 백업 스크립트 생성
cat > /usr/local/bin/dlm-db-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=/backup/mariadb
CONTAINER=dlm-mariadb
DB_PASS=$(grep MARIADB_ROOT_PASSWORD /app/Datablocks/.env | cut -d= -f2)
DATE=$(date +%Y%m%d_%H%M%S)
KEEP_DAYS=7

mkdir -p $BACKUP_DIR

# 백업 실행
docker exec $CONTAINER mariadb-dump \
  -u root -p"$DB_PASS" \
  --all-databases --single-transaction \
  | gzip > $BACKUP_DIR/all_$DATE.sql.gz

# 성공 여부 확인
if [ $? -eq 0 ]; then
  echo "[$(date)] 백업 성공: all_$DATE.sql.gz" >> /var/log/dlm-backup.log
else
  echo "[$(date)] 백업 실패!" >> /var/log/dlm-backup.log
fi

# 오래된 백업 삭제 (7일 이전)
find $BACKUP_DIR -name "*.sql.gz" -mtime +$KEEP_DAYS -delete
echo "[$(date)] 7일 이전 백업 정리 완료" >> /var/log/dlm-backup.log
EOF

chmod +x /usr/local/bin/dlm-db-backup.sh

# cron 등록 (매일 새벽 2시)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/dlm-db-backup.sh") | crontab -
```

### 3.5 데이터베이스 복원

```bash
# 전체 DB 복원
docker exec -i dlm-mariadb mariadb \
  -u root -p'root_비밀번호' \
  < /backup/mariadb/all_20240101_020000.sql

# gzip 압축 백업에서 복원
gunzip -c /backup/mariadb/cotdl_20240101_020000.sql.gz | \
  docker exec -i dlm-mariadb mariadb \
  -u root -p'root_비밀번호' cotdl

# cotdl DB만 복원
docker exec -i dlm-mariadb mariadb \
  -u root -p'root_비밀번호' cotdl \
  < /backup/mariadb/cotdl_20240101_020000.sql
```

> **주의**: 복원 전 반드시 현재 상태를 백업하고, DLM 서비스를 중지하세요.
> ```bash
> docker compose stop dlm dlm-privacy-ai
> # 복원 실행
> docker compose start dlm-privacy-ai dlm
> ```

---

## 4. 헬스체크 확인

### 4.1 Docker 헬스체크 상태

```bash
# 모든 컨테이너 헬스 상태
docker ps --format "table {{.Names}}\t{{.Status}}"

# 특정 컨테이너 헬스체크 상세 이력
docker inspect dlm-mariadb | python3 -c "
import json, sys
data = json.load(sys.stdin)
health = data[0]['State']['Health']
print('Status:', health['Status'])
for log in health['Log'][-5:]:
    print(f\"  {log['Start']}: {log['Output'].strip()}\")
"
```

### 4.2 서비스별 헬스체크 수동 실행

```bash
# MariaDB 헬스체크
docker exec dlm-mariadb healthcheck.sh --connect --innodb_initialized && echo "OK" || echo "FAIL"

# DLM Spring Boot (HTTP 응답 확인)
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/
# 200 또는 302 반환 시 정상

# DLM-Privacy-AI
curl -s http://localhost:8000/health
# {"status":"ok"} 반환 시 정상
```

### 4.3 헬스체크 실패 시 즉시 확인

```bash
# unhealthy 컨테이너 확인
docker ps --filter "health=unhealthy"

# 해당 컨테이너 로그 확인
docker logs --tail=50 dlm-mariadb
docker logs --tail=50 dlm-app
```

---

## 5. 리소스 모니터링

### 5.1 실시간 리소스 사용량

```bash
# 모든 컨테이너 실시간 리소스 (1초 갱신)
docker stats

# 특정 컨테이너만
docker stats dlm-app dlm-mariadb dlm-privacy-ai

# 한 번만 출력 (스크립트 활용 시)
docker stats --no-stream

# 사람이 읽기 쉬운 형식으로 출력
docker stats --no-stream --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
```

### 5.2 특정 서비스 메모리 사용량 모니터링

```bash
# DLM JVM 메모리 상세 확인
docker exec -it dlm-app sh -c \
  "jcmd 1 VM.native_memory summary 2>/dev/null || \
   cat /proc/1/status | grep -i vmrss"

# 컨테이너 cgroup 메모리 확인 (정확한 사용량)
docker exec dlm-app cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null || \
docker exec dlm-app cat /sys/fs/cgroup/memory.current 2>/dev/null
```

### 5.3 Docker 전체 리소스 현황

```bash
# Docker 디스크 사용량
docker system df

# 상세 디스크 사용량
docker system df -v

# 이미지/컨테이너/볼륨 개수
echo "이미지: $(docker images -q | wc -l)개"
echo "컨테이너: $(docker ps -aq | wc -l)개 (실행중: $(docker ps -q | wc -l)개)"
echo "볼륨: $(docker volume ls -q | wc -l)개"
```

### 5.4 호스트 리소스 모니터링

```bash
# CPU, 메모리, 디스크 요약
free -h && df -h / && uptime

# 상세 CPU 사용률 (top 대신)
vmstat 1 5

# I/O 모니터링
iostat -x 1 5 2>/dev/null || iotop -n 3 2>/dev/null
```

### 5.5 모니터링 대시보드 스크립트

```bash
# 간단한 상태 확인 스크립트
cat > /usr/local/bin/dlm-status.sh << 'EOF'
#!/bin/bash
echo "============================================"
echo " DLM 서비스 상태 - $(date)"
echo "============================================"
echo ""
echo "[컨테이너 상태]"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep dlm
echo ""
echo "[리소스 사용량]"
docker stats --no-stream --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep dlm
echo ""
echo "[디스크 사용량]"
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"
echo ""
echo "[호스트 메모리]"
free -h
EOF
chmod +x /usr/local/bin/dlm-status.sh

# 실행
dlm-status.sh
```

---

## 6. 컨테이너 셸 접속

### 6.1 각 컨테이너에 셸 접속

```bash
# DLM Spring Boot (sh 사용, bash 없음)
docker exec -it dlm-app /bin/sh

# DLM-Privacy-AI (sh 또는 bash)
docker exec -it dlm-privacy-ai /bin/sh

# MariaDB
docker exec -it dlm-mariadb /bin/bash

# Portainer
docker exec -it dlm-portainer /bin/sh
```

### 6.2 MariaDB 클라이언트 접속

```bash
# root로 접속
docker exec -it dlm-mariadb mariadb -u root -p

# cotdl 계정으로 접속
docker exec -it dlm-mariadb mariadb -u cotdl -p cotdl

# 바로 DB 선택하여 접속
docker exec -it dlm-mariadb mariadb -u cotdl -p'cotdl_비밀번호' cotdl

# 쿼리 직접 실행 (비대화형)
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT COUNT(*) FROM cotdl.테이블명;"
```

### 6.3 컨테이너 내 파일 확인

```bash
# DLM 로그 파일 목록
docker exec dlm-app ls -la /app/logs/

# DLM 업로드 파일 목록
docker exec dlm-app ls -la /app/upload/

# AI 서비스 모델 파일 확인
docker exec dlm-privacy-ai ls -la /app/models/

# MariaDB 데이터 디렉토리 크기
docker exec dlm-mariadb du -sh /var/lib/mysql/
```

### 6.4 컨테이너 파일 복사

```bash
# 컨테이너에서 호스트로 복사
docker cp dlm-app:/app/logs/application.log /tmp/dlm-application.log

# 호스트에서 컨테이너로 복사
docker cp /tmp/config.xml dlm-app:/app/config.xml

# 로그 전체 디렉토리 복사
docker cp dlm-app:/app/logs/ /backup/dlm-logs-$(date +%Y%m%d)/
```

---

## 7. 개별 서비스 업데이트

### 7.1 DLM 애플리케이션 업데이트

```bash
cd /app/Datablocks

# 소스 업데이트
git pull origin main

# 재빌드 및 재시작 (운영 환경)
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d --build dlm

# 기동 확인
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  logs -f --tail=100 dlm
```

### 7.2 DLM-Privacy-AI 업데이트

```bash
cd /app/Datablocks

# AI 서비스만 재빌드
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d --build dlm-privacy-ai

# Python 패키지 변경 시 캐시 없이 재빌드
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  build --no-cache dlm-privacy-ai
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d dlm-privacy-ai
```

### 7.3 Portainer 업데이트

```bash
# 최신 LTS 이미지로 업데이트
docker compose pull portainer
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d portainer
```

### 7.4 MariaDB 마이너 버전 업데이트

```bash
# 백업 먼저!
docker exec dlm-mariadb mariadb-dump -u root -p'root_비밀번호' \
  --all-databases --single-transaction \
  > /backup/pre_mariadb_upgrade.sql

# 이미지 업데이트
docker compose pull mariadb
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d mariadb

# 업그레이드 후 테이블 점검
docker exec dlm-mariadb mariadb-upgrade -u root -p'root_비밀번호'
```

---

## 8. MariaDB 유지보수

### 8.1 슬로우 쿼리 분석

```bash
# 슬로우 쿼리 로그 확인
docker exec -it dlm-mariadb tail -100 /var/log/mysql/slow-query.log

# 슬로우 쿼리 상위 10개 분석
docker exec -it dlm-mariadb mysqldumpslow \
  -t 10 /var/log/mysql/slow-query.log

# 현재 실행 중인 쿼리 목록
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW PROCESSLIST;"

# 5초 이상 실행 중인 쿼리
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT * FROM information_schema.PROCESSLIST WHERE TIME > 5;"
```

### 8.2 InnoDB 버퍼풀 상태 확인

```bash
# 버퍼풀 히트율 및 상태
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';
"

# 버퍼풀 히트율 계산
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
SELECT
  (1 - (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS
         WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') /
       (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS
         WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
  ) * 100 AS buffer_pool_hit_rate;
"
# 95% 이상이 정상 (낮으면 버퍼풀 크기 증가 고려)
```

### 8.3 테이블 최적화

```bash
# cotdl DB 전체 테이블 분석 및 최적화 (서비스 중에도 가능하나 부하 주의)
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
USE cotdl;
ANALYZE TABLE 테이블명;
"

# 단편화된 테이블 최적화 (테이블 잠금 발생, 점검 시간에 수행)
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
OPTIMIZE TABLE cotdl.테이블명;
"
```

### 8.4 MariaDB 연결 수 모니터링

```bash
# 현재 연결 수
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
SHOW STATUS WHERE Variable_name = 'Threads_connected';
SHOW VARIABLES WHERE Variable_name = 'max_connections';
"

# 연결 통계
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
SHOW STATUS LIKE 'Connection%';
SHOW STATUS LIKE 'Max_used_connections';
"
```

### 8.5 바이너리 로그 관리

```bash
# 바이너리 로그 목록 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW BINARY LOGS;"

# 오래된 바이너리 로그 삭제 (3일 이전)
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);"

# 바이너리 로그 디스크 사용량
docker exec dlm-mariadb du -sh /var/lib/mysql/mysql-bin.*
```

### 8.6 MariaDB 정기 점검 스크립트

```bash
# 주간 점검 스크립트
cat > /usr/local/bin/dlm-db-check.sh << 'EOF'
#!/bin/bash
DB_PASS=$(grep MARIADB_ROOT_PASSWORD /app/Datablocks/.env | cut -d= -f2)

echo "=== MariaDB 주간 점검 $(date) ==="

echo ""
echo "[1] 연결 상태"
docker exec dlm-mariadb mariadb -u root -p"$DB_PASS" \
  -e "SHOW STATUS WHERE Variable_name IN ('Threads_connected','Max_used_connections','Uptime');" 2>/dev/null

echo ""
echo "[2] 슬로우 쿼리 건수"
docker exec dlm-mariadb mariadb -u root -p"$DB_PASS" \
  -e "SHOW STATUS LIKE 'Slow_queries';" 2>/dev/null

echo ""
echo "[3] 버퍼풀 상태"
docker exec dlm-mariadb mariadb -u root -p"$DB_PASS" \
  -e "SHOW STATUS LIKE 'Innodb_buffer_pool_read%';" 2>/dev/null

echo ""
echo "[4] 디스크 사용량"
docker exec dlm-mariadb du -sh /var/lib/mysql/ 2>/dev/null

echo ""
echo "=== 점검 완료 ==="
EOF
chmod +x /usr/local/bin/dlm-db-check.sh
```
