# DLM 배포 — Linux 명령어 사용 권한 신청서

> **사이트**: JB우리캐피탈 (Rocky Linux 9 / 폐쇄망)
> **신청 대상**: 시스템 운영팀 (보안 금지어 해지)
> **신청 사유**: DLM (개인정보 접속기록 관리) 솔루션 반입 / 운영
> **사용 위치**: `/app/Datablocks/deploy/jbwoori/scripts/deploy.sh`, `PROCEDURE.md`, 일상 운영
> **요청 계정**: root (또는 sudo 권한 일반 계정)

---

## 1. ★ 필수 — 이거 없으면 배포·운영 불가

### 1.1 Docker 패키지 (오프라인 RPM 설치)

| 명령 | 사용 위치 | 사유 |
|------|----------|------|
| `rpm -e --noscripts <pkg>` | `install-docker.sh` | 기존 podman/buildah 제거 (Rocky 9 기본 podman-docker 가 docker compose 호환 안됨) |
| `rpm -Uvh --force --nodeps <pkg>.rpm` | `install-docker.sh` | docker-ce / containerd / cli / compose-plugin 오프라인 설치 |
| `dnf remove -y <pkg>` | `install-docker.sh` | 충돌 패키지(podman, buildah) 제거 |
| `systemctl start/enable docker` | `install-docker.sh`, 운영 | Docker 데몬 기동/자동시작 |
| `systemctl stop/disable docker` | 장애 대응 | 점검 시 임시 중지 |
| `usermod -aG docker <user>` | `install-docker.sh` | 일반 계정의 docker 그룹 가입 (sudo 없이 docker 명령) |

### 1.2 Docker 명령 (★ 일상 운영 핵심)

| 명령 | 사용 빈도 | 사유 |
|------|----------|------|
| `docker compose up -d / down / restart` | 매일 | 컨테이너 기동/중지/재시작 — 운영 필수 |
| `docker ps`, `docker ps -a` | 수시 | 컨테이너 상태 확인 |
| `docker images` | 가끔 | 이미지 목록 확인 |
| `docker load < image.tar.gz` | 패치 시 | 신규 이미지 적재 (레지스트리 없는 폐쇄망 운영) |
| **`docker logs`** ★ | **장애 대응 시 필수** | 애플리케이션 stdout/stderr 확인. **이게 막히면 1차 대응 자체가 불가능** |
| `docker logs -f` | 장애 대응 | 실시간 로그 모니터링 |
| `docker exec <container> <cmd>` | 진단 시 | 컨테이너 내부 진단 (DB 연결 테스트 등) |
| `docker inspect <container>` | 장애 대응 | 컨테이너 메타정보 (재시작횟수/종료코드/에러) 확인 |
| `docker rm`, `docker rmi` | 정리 시 | 미사용 컨테이너/이미지 정리 |

### 1.3 MariaDB 클라이언트 (DDL 적용 / 운영 검증)

| 명령 | 사용 위치 | 사유 |
|------|----------|------|
| `mariadb -h <host> -u <user> -p <db>` | DDL 적용 / 운영 | DLM 스키마(cotdl) 의 DDL 적용 + 검증 SQL 실행 |
| `mariadb -e "<query>"` | 운영 점검 | 접속기록 저장량/해시체인 무결성 검증 |
| `mysqldump -h <host> -u <user> -p <db>` | 백업 시 | DDL 적용 전 운영 DB 백업 (필수) |

### 1.4 시스템 정보 / 상태

| 명령 | 사용 위치 | 사유 |
|------|----------|------|
| `systemctl status mariadb` | 사전 점검 | 호스트 MariaDB 기동 여부 확인 |
| `systemctl is-active mariadb` | `deploy.sh` | 자동 분기 |
| `ss -tlnp \| grep <port>` | 사전 점검 | 8080/8443/3306 포트 충돌 확인 |
| `netstat -tlnp` | `deploy.sh` (ss 폴백) | ss 미설치 환경 폴백 |

### 1.5 파일 권한 / 설치

| 명령 | 사용 위치 | 사유 |
|------|----------|------|
| `chmod 644 <keystore>` | `deploy.sh:125` | SSL keystore 컨테이너 마운트용 권한 (non-root Java 가 읽어야 함) |
| `chmod` (일반) | 운영 | 설정 파일 권한 조정 |
| `cp -r /mnt/usb/... /app/Datablocks/deploy/` | 반입 | USB 패키지 복사 |
| `mkdir -p /app/Datablocks/...` | `deploy.sh` | 설치 디렉토리 생성 |
| `gunzip -c <image>.tar.gz \| docker load` | `deploy.sh` | 이미지 압축 해제 + 적재 |
| `sed -i ... <file>` | `deploy.sh` | .env 의 포트/IP 자동 치환 |
| `vi /app/Datablocks/.env.jbwoori` | 운영 | 환경 변수 수동 수정 |

---

## 2. ★ 통신 검증 / 헬스체크용

| 명령 | 사용 위치 | 사유 |
|------|----------|------|
| `curl http://localhost:8080/...` | 동작 검증 (PROCEDURE §7) | DLM API 헬스체크 / smoke test |
| `curl -k https://localhost:8443/...` | HTTPS 검증 | HTTPS 모드 헬스체크 |
| `nc -z <host> <port>` | `deploy.sh` 폴백 | TCP 연결 테스트 (DB 접속 확인) |

---

## 3. ★ 방화벽 (firewalld 가 운영 중일 때만 — 본 사이트는 미해당이라 신청 불요)

| 명령 | 사유 | 본 사이트 |
|------|------|---------|
| `firewall-cmd --add-port=...` | DLM 포트 8080/8443/8000 오픈 | **불요** (firewalld off 확인됨) |
| `firewall-cmd --reload` | 방화벽 룰 적용 | 불요 |

---

## 4. 일반 쉘 명령 (보통 기본 허용 — 누락 시만 추가 신청)

`ls`, `cat`, `cd`, `pwd`, `grep`, `tail`, `head`, `awk`, `cp`, `mv`, `mkdir`, `echo`, `bash`, `sh`, `for`, `read`

---

## 5. 본 사이트 운영에 ★ 필요 없음 (참고만)

다음 명령은 **DLM 운영에는 필요 없으나** 일반적인 보안 정책에서 같이 묶어 막혀 있는 경우가 많아 명시:

| 명령 | DLM 사용 여부 |
|------|-------------|
| `iptables` (직접) | 사용 안 함 (Docker 가 자동 관리) |
| `tcpdump`, `nmap` | 사용 안 함 |
| `wget` | 사용 안 함 (curl 만 사용) |
| `find /` (전체 탐색) | 사용 안 함 (제한된 경로만) |
| `ssh-keygen` 등 SSH 도구 | 사용 안 함 |
| `kill -9` 등 강제 종료 | docker 명령으로 갈음 |

---

## 6. ★ 우선순위 정리 (한 번에 다 풀어달라고 못 할 경우)

**1순위 (이거 없으면 배포 불가):**
1. `docker compose up -d / down / restart`
2. `docker ps`, `docker images`, `docker load`
3. `mariadb` 클라이언트 + `mysqldump`
4. `rpm -Uvh`, `dnf remove`, `systemctl start docker`
5. `chmod`, `cp`, `mkdir`, `gunzip`
6. `ss -tlnp` (포트 점검)

**2순위 (장애 대응 시 필수):**
1. **`docker logs`** ← 막혀 있으면 1차 진단 시간 10배 늘어남
2. `docker exec`
3. `docker inspect`
4. `curl`

**3순위 (있으면 편한 것):**
1. `nc -z`
2. `vi`
3. `firewall-cmd` (firewalld 운영 시)

---

## 7. 근거 자료

- 주 스크립트: `/app/Datablocks/deploy/jbwoori/scripts/deploy.sh`
- 설치 스크립트: `/app/Datablocks/deploy/jbwoori/scripts/install-docker.sh`
- 운영 절차서: `/app/Datablocks/deploy/jbwoori/PROCEDURE.md`
- 본사 담당: 차민석 (minseokcha7753@gmail.com)

---

## 8. 신청 시 참고 — `docker logs` 가 정책상 절대 풀리지 않을 경우

대안: Docker 의 stdout/stderr json 로그 파일을 호스트 파일로 직접 읽기.

```bash
# 컨테이너 로그 파일 경로
LOG=$(grep -l '"Name":"/dlm-app"' /var/lib/docker/containers/*/config.v2.json \
       | head -1 | xargs -I{} dirname {} \
       | xargs -I{} sh -c 'ls "$1"/*-json.log 2>/dev/null' _ {} | head -1)

tail -300 "$LOG"
```

이 방법은 일반 파일 읽기(`tail`)만 사용하므로 docker 명령 없이 동작.
다만 **출력이 json 형식이라 가독성이 매우 떨어집니다** — `docker logs` 정상 허용이 훨씬 효율적.

---

**작성일**: 2026-04-29
**작성자**: 차민석 (Datablocks)

---

## 9. ★ 신청 단어 리스트 (양식 붙여넣기용)

```
docker
docker compose
docker-compose
docker logs
docker exec
docker inspect
docker ps
docker images
docker load
docker rm
docker rmi
docker network
docker volume
docker stats
docker info
mariadb
mysql
mysqldump
rpm
dnf
yum
systemctl
usermod
ss
netstat
firewall-cmd
chmod
chown
cp
mv
rm
mkdir
rmdir
ln
gunzip
gzip
tar
sed
awk
grep
find
xargs
cat
tail
head
less
more
ls
cd
pwd
echo
vi
vim
bash
sh
curl
wget
nc
ping
hostname
ip
ifconfig
free
df
du
ps
kill
top
date
who
id
sudo
su
read
for
while
```

---

> **사용 예시 (양식이 명령어 단위로 받는 경우):**
> 위 목록을 줄바꿈/콤마로 변환해서 그대로 제출하면 됩니다.
>
> ```
> docker, docker compose, docker logs, docker exec, docker inspect, docker ps, docker images, docker load, docker rm, docker rmi, docker network, docker volume, docker stats, docker info, mariadb, mysql, mysqldump, rpm, dnf, yum, systemctl, usermod, ss, netstat, firewall-cmd, chmod, chown, cp, mv, rm, mkdir, rmdir, ln, gunzip, gzip, tar, sed, awk, grep, find, xargs, cat, tail, head, less, more, ls, cd, pwd, echo, vi, vim, bash, sh, curl, wget, nc, ping, hostname, ip, ifconfig, free, df, du, ps, kill, top, date, who, id, sudo, su, read, for, while
> ```
