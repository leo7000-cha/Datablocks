# DLM 문서 인덱스

## architecture/ — 프로젝트 구조 및 설계
| 문서 | 설명 |
|------|------|
| [overview.md](architecture/overview.md) | 프로젝트 개요, 시스템 아키텍처, 서비스 구성 |
| [pii-discovery-flow.md](architecture/pii-discovery-flow.md) | PII 자동탐지 엔진 흐름 (Meta+Pattern+AI 스코어링) |

## design/ — 설계서 및 분석
| 문서 | 설명 |
|------|------|
| [DLM_Privacy_Platform_로드맵.md](design/DLM_Privacy_Platform_로드맵.md) | Privacy Platform 전체 로드맵 |
| [Privacy_Monitor_기능개발요건설계서.md](design/Privacy_Monitor_기능개발요건설계서.md) | Privacy Monitor 기능 설계서 |
| [PURGE_tbl_piiextract_설계서.md](design/PURGE_tbl_piiextract_설계서.md) | tbl_piiextract 파기 설계서 |
| [PURGE_tbl_piiorder_설계서.md](design/PURGE_tbl_piiorder_설계서.md) | tbl_piiorder 파기 설계서 |
| [STEP_RUNNING_고착_분석.md](design/STEP_RUNNING_고착_분석.md) | STEP RUNNING 고착 현상 분석 |

## development/ — 개발 환경
| 문서 | 설명 |
|------|------|
| [dev-setup.md](development/dev-setup.md) | 개발 환경 설정, 빌드, 서비스 시작/중지 |
| [docker-concepts.md](development/docker-concepts.md) | Docker 핵심 개념 (컨테이너, 볼륨, 네트워크) |

## deployment/ — 배포
| 문서 | 설명 |
|------|------|
| [prod-deploy.md](deployment/prod-deploy.md) | 운영 환경 배포 (서버 준비, SSL, 롤백) |
| [docker-배포-가이드.md](deployment/docker-배포-가이드.md) | Docker 배포 초보자 가이드 |
| [고객사-현장적용-가이드.md](deployment/고객사-현장적용-가이드.md) | 고객사 현장 배포 매뉴얼 (처음부터 끝까지) |
| [패치-배포-가이드.md](deployment/패치-배포-가이드.md) | 패치/업데이트 배포 절차 |

## operations/ — 운영
| 문서 | 설명 |
|------|------|
| [operations.md](operations/operations.md) | 일상 운영 (모니터링, 백업, 헬스체크) |
| [troubleshooting.md](operations/troubleshooting.md) | 문제 해결 가이드 |
| [resource-allocation.md](operations/resource-allocation.md) | 리소스 설정 (JVM, MariaDB 튜닝) |

## guide/ — 사용자 가이드
| 문서 | 설명 |
|------|------|
| [Privacy_Monitor_사용자가이드.md](guide/Privacy_Monitor_사용자가이드.md) | Privacy Monitor 사용자 매뉴얼 |

## sites/ — 고객사별 현장 정보
| 고객사 | 문서 |
|--------|------|
| [hanson/](sites/hanson/) | 한국손사 — [wireguard.md](sites/hanson/wireguard.md) (VPN), [mscha.conf](sites/hanson/mscha.conf) |

---

## 기타 프로젝트 폴더 참조
| 폴더 | 설명 |
|------|------|
| [/database/](/database/) | DDL, 초기데이터, 배치잡, SQL 워크북 |
| [/deploy/](/deploy/) | 고객사별 Docker Compose 배포 설정 |
| [/_old/](/_old/) | 구 WAR 배포 방식 스크립트 (참고용) |
