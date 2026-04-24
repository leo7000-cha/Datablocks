# DLM 운영 매뉴얼 — 한국손사

> 환경: Ubuntu / MariaDB Docker 컨테이너 / DLM 포트 8082
> 접속: http://서버IP:8082 (admin / admin1234)


## 1. 배포

```bash
# 최초 배포
bash scripts/deploy.sh

# 패치 배포 (이미지 교체)
cd /app/Datablocks
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down
docker load < /tmp/patch/dlm-app.tar.gz
docker load < /tmp/patch/dlm-privacy-ai.tar.gz
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d
```


## 2. 시작 / 중지 / 재시작

```bash
cd /app/Datablocks

# 전체
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down
docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart

# 개별
docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart dlm
docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart dlm-privacy-ai
```


## 3. 상태 확인

```bash
# 컨테이너 상태
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm|mariadb"

# 리소스 (CPU/메모리)
docker stats dlm-app dlm-privacy-ai --no-stream

# 디스크
docker system df
```


## 4. 로그

```bash
# 실시간
docker logs -f dlm-app
docker logs -f dlm-privacy-ai

# 최근 100줄 + 실시간
docker logs -f --tail 100 dlm-app

# 최근 30분
docker logs --since 30m dlm-app

# 에러만
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20

# 로그 파일 위치
docker volume inspect dlm-app-logs --format '{{.Mountpoint}}'
```


## 5. DB 접속 / 패치

```bash
# mariadb 컨테이너 접속
docker exec -it mariadb mysql -u cotdl -p'!Dlm1234' cotdl

# SQL 파일 실행
docker exec -i mariadb mysql -u cotdl -p'!Dlm1234' cotdl < database/ddl/DLM_DDL_MASTER_ACCESSLOG.sql
docker exec -i mariadb mysql -u cotdl -p'!Dlm1234' cotdl < database/ddl/DLM_DDL_MASTER_DISCOVERY.sql

# 테이블 수 확인
docker exec mariadb mysql -u cotdl -p'!Dlm1234' cotdl -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='cotdl';"
```


## 6. 백업 / 복원

```bash
mkdir -p /home/dlm/backup

# 백업
docker exec mariadb mysqldump -u root -p'!Dlm1234' \
  --single-transaction --routines --triggers \
  --default-character-set=utf8mb4 \
  cotdl | gzip > /home/dlm/backup/cotdl_$(date +%Y%m%d_%H%M%S).sql.gz

# 복원
gunzip < /home/dlm/backup/cotdl_20260415_120000.sql.gz \
  | docker exec -i mariadb mysql -u root -p'!Dlm1234' --default-character-set=utf8mb4 cotdl
```


## 7. 이미지 백업 / 롤백

```bash
mkdir -p /app/backup

# 현재 이미지 백업
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-$(date +%Y%m%d).tar.gz

# 롤백
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down
docker load < /app/backup/dlm-app-20260415.tar.gz
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d
```


## 8. 진단

```bash
# DB 연결 테스트
docker exec dlm-app sh -c "nc -zv mariadb 3306 2>&1"

# tbl_piidatabase hostname 확인 (반드시 'mariadb')
docker exec mariadb mysql -u cotdl -p'!Dlm1234' cotdl -e \
  "SELECT db, hostname, port FROM tbl_piidatabase;"

# 네트워크 확인
docker network inspect $(grep '^MARIADB_NETWORK=' /app/Datablocks/.env.hanson | cut -d= -f2) \
  2>/dev/null | grep -A2 '"Name"'

# 컨테이너 환경변수
docker exec dlm-app env | grep -i "spring\|jasypt"
```


## 9. 단축 명령 등록

```bash
cat >> ~/.bashrc << 'EOF'
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm|mariadb"'
alias dlm-up='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d'
alias dlm-down='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml down'
alias dlm-restart='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart'
alias dlm-log='docker logs -f dlm-app'
alias dlm-log-ai='docker logs -f dlm-privacy-ai'
EOF
source ~/.bashrc
```
