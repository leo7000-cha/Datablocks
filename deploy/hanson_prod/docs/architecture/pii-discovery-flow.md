# PII Discovery - 개인정보 자동탐지 엔진 흐름

## 목차
1. [개요](#1-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [스캔 실행 흐름](#3-스캔-실행-흐름)
4. [3단계 스코어링 시스템](#4-3단계-스코어링-시스템)
5. [AI/LLM 탐지 상세](#5-aillm-탐지-상세)
6. [최종 점수 계산](#6-최종-점수-계산)
7. [결과 처리 및 워크플로우](#7-결과-처리-및-워크플로우)
8. [설정 및 구성](#8-설정-및-구성)
9. [주요 파일 목록](#9-주요-파일-목록)

---

## 1. 개요

DLM PII Discovery는 데이터베이스 테이블의 컬럼을 자동으로 스캔하여 개인정보(PII)를 탐지하는 엔진입니다. 세 가지 탐지 방법을 조합하여 정확도를 높입니다.

| 탐지 방법 | 입력 | 가중치(기본) | 설명 |
|-----------|------|:----------:|------|
| **Metadata** | 컬럼명, 코멘트 | 40% | 키워드 기반 메타데이터 매칭 |
| **Pattern** | 샘플 데이터 | 35% | 정규표현식 패턴 매칭 |
| **AI (LLM)** | 메타 + 샘플 5건 | 25% | LLM 기반 지능형 분석 |

최종 점수(0~100)에 따라 자동 분류됩니다:

```
 0-29%  →  NOT_PII     (PII 아님)
30-89%  →  PENDING     (수동 검토 필요)
  90%+  →  CONFIRMED   (자동 확정)
```

---

## 2. 시스템 아키텍처

```
┌──────────────────┐
│   사용자 브라우저   │
│  (Settings / Jobs) │
└────────┬─────────┘
         │ HTTP :8080
         ▼
┌──────────────────────────────────────────────────────────────┐
│                      dlm-app (Spring Boot)                   │
│                                                              │
│  PiiDiscoveryController                                      │
│    ├─ POST /api/jobs/{id}/execute   ← 스캔 시작              │
│    ├─ GET  /api/executions/{id}/progress  ← 진행률 조회      │
│    ├─ POST /api/llm/settings        ← LLM 설정 저장         │
│    └─ POST /api/llm/test-connection ← 연결 테스트            │
│                                                              │
│  DiscoveryEngineImpl (멀티스레드 스캔 엔진)                    │
│    ├─ executeScan()             ← 엔진 진입점 (비동기)        │
│    ├─ scanTableWithMetaColumns()← 테이블 단위 스캔            │
│    ├─ streamingPatternMatch()   ← 패턴 매칭 (메모리 최적화)   │
│    ├─ callAiDetect()            ← AI 배치 호출               │
│    └─ calculateTotalScore()     ← 가중 점수 계산             │
│                                                              │
│  PrivacyAiClient (HTTP 클라이언트)                            │
│    ├─ detectPii()               ← Privacy-AI API 호출        │
│    └─ checkLlmStatus()          ← LLM 상태 확인             │
└──────────────────────────────┬───────────────────────────────┘
                               │ HTTP (내부 네트워크)
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                  dlm-privacy-ai (FastAPI)                     │
│                                                              │
│  POST /api/v1/privacy/detect    ← PII 탐지 요청              │
│  GET  /api/v1/privacy/llm-status← LLM 연결 상태              │
│                                                              │
│  LlmService                                                  │
│    ├─ System Prompt (PII 유형 정의)                           │
│    ├─ User Prompt (테이블 JSON)                               │
│    └─ OpenAI 호환 API 호출 ──────────────────► 내부 LLM 서버  │
└──────────────────────────────────────────────────────────────┘
```

---

## 3. 스캔 실행 흐름

### 3.1 전체 흐름 다이어그램

```
사용자: "Execute Scan" 클릭
  │
  ▼
① POST /api/jobs/{jobId}/execute
  │  ├─ Job 정의 로드 (DB Connection, 대상 테이블, 옵션)
  │  ├─ Execution 레코드 생성 (status=PENDING)
  │  └─ 비동기 엔진 실행 트리거
  │
  ▼
② DiscoveryEngine.executeScan() [비동기 스레드]
  │
  ├─ 초기화
  │  ├─ HikariCP 커넥션 풀 생성 (스레드 수만큼)
  │  ├─ DB 비밀번호 복호화 (AES256)
  │  ├─ 제외 필터 파싱 (데이터 타입, 컬럼 패턴, 최소 길이)
  │  ├─ TBL_METATABLE에서 메타데이터 미리 로드
  │  ├─ 탐지 규칙 로드 (5분 캐시)
  │  └─ 스레드 풀 생성 (기본 5개)
  │
  ├─ status: PENDING → RUNNING
  │
  ├─ 테이블 병렬 스캔 (스레드 풀)
  │  │
  │  ├─ [Thread-1] scanTableWithMetaColumns("TB_CUSTOMER")
  │  ├─ [Thread-2] scanTableWithMetaColumns("TB_ORDER")
  │  ├─ [Thread-3] scanTableWithMetaColumns("TB_EMPLOYEE")
  │  ├─ [Thread-4] scanTableWithMetaColumns("TB_PAYMENT")
  │  └─ [Thread-5] scanTableWithMetaColumns("TB_ADDRESS")
  │
  ├─ 진행률 업데이트 (5테이블 또는 10% 마다)
  │
  └─ 완료 처리
     ├─ status: RUNNING → COMPLETED
     ├─ 이전 결과 정리 (최근 3회만 유지)
     └─ 진행 정보 메모리 해제 (10분 후)
```

### 3.2 테이블 단위 스캔 상세 (scanTableWithMetaColumns)

```
scanTableWithMetaColumns(TB_CUSTOMER)
  │
  ├─ ① 컬럼 필터링
  │  │  전체 컬럼: 50개
  │  │    ├─ NUMBER/DATE 타입 제외    → -15
  │  │    ├─ *_CD, *_YN 패턴 제외    → -8
  │  │    ├─ 이미 확인된 PII 제외     → -2
  │  │    └─ 대상 컬럼               → 25개
  │  │
  │  └─ 텍스트 타입 컬럼 추출 (패턴 매칭용): 18개
  │
  ├─ ② 스트리밍 패턴 매칭 (enablePattern=Y 일 때)
  │  │  SELECT col1, col2, ... FROM TB_CUSTOMER LIMIT 100
  │  │    ├─ fetchSize=2000 (메모리 최적화)
  │  │    ├─ Row 단위 즉시 매칭 (전체 적재 안 함)
  │  │    └─ 컬럼별 결과: {매칭건수, 매칭률, 샘플 5건}
  │  │
  │  └─ Map<컬럼명, StreamingMatchResult>
  │
  ├─ ③ AI PII 탐지 (enableAI=Y 일 때)
  │  │  25개 컬럼의 메타+샘플을 모아서 1회 배치 호출
  │  │    POST http://dlm-privacy-ai:8000/api/v1/privacy/detect
  │  │    {table_name, columns: [{name, type, comment, samples}]}
  │  │
  │  └─ Map<컬럼명, AiDetectResult{piiType, score, reason}>
  │
  └─ ④ 컬럼별 분석 & 저장 (25개 반복)
     │
     ├─ analyzeColumnWithStreamingResult()
     │  ├─ metaScore  ← 컬럼명/코멘트 키워드 매칭
     │  ├─ patternScore ← 정규표현식 매칭률
     │  ├─ aiScore    ← LLM 분석 결과
     │  └─ totalScore ← 가중 평균 (정규화)
     │
     └─ INSERT → TBL_DISCOVERY_SCAN_RESULT
```

---

## 4. 3단계 스코어링 시스템

### 4.1 Metadata Score (메타데이터 분석)

컬럼명과 코멘트에서 키워드를 매칭합니다.

```
규칙 예시:
  ┌─────────────────────────────────────────────┐
  │ PII 유형: PERSON_NAME                        │
  │ 키워드:   NAME, NM, 성명, 이름              │
  │ 가중치:   0.8                               │
  └─────────────────────────────────────────────┘

컬럼: CUST_NM (VARCHAR, 코멘트: "고객명")

매칭 과정:
  "CUST_NM".contains("NM")  →  매칭!
  metaScore = weight × 100 = 0.8 × 100 = 80
```

- 여러 규칙이 매칭되면 **최고 점수** 채택
- 매칭된 규칙의 `piiTypeCode`가 결과의 PII 유형으로 설정

### 4.2 Pattern Score (패턴 매칭)

샘플 데이터에 정규표현식을 적용합니다.

```
규칙 예시:
  ┌─────────────────────────────────────────────┐
  │ PII 유형: SSN (주민등록번호)                  │
  │ 패턴:     ^\d{6}-\d{7}$                     │
  │ 가중치:   0.9                               │
  └─────────────────────────────────────────────┘

스트리밍 매칭 (100건 샘플):
  Row 1: "880523-1234567"  → 매칭 ✓
  Row 2: "920101-2345678"  → 매칭 ✓
  ...
  Row 100: "N/A"           → 미매칭 ✗

  매칭률 = 78/100 = 0.78

  patternScore = weight × matchRatio × 100
               = 0.9 × 0.78 × 100 = 70
```

**스트리밍 방식의 메모리 최적화:**
- `fetchSize=2000`: 네트워크 왕복 최소화
- Row 단위 즉시 처리: 전체 데이터를 메모리에 올리지 않음
- **1,000만 건 이상 테이블도 안전하게 스캔 가능**

### 4.3 AI Score (LLM 탐지)

Privacy-AI 서비스를 통해 LLM에 분석을 요청합니다.

```
요청 (DLM → Privacy-AI):
  {
    "table_name": "TB_CUSTOMER",
    "schema_name": "PUBLIC",
    "columns": [
      {
        "name": "CUST_NM",
        "type": "VARCHAR(100)",
        "comment": "고객명",
        "samples": ["김철수", "이영희", "박민수", "최동현", "정수현"]
      },
      {
        "name": "REG_DT",
        "type": "DATE",
        "comment": "등록일",
        "samples": ["2024-01-15", "2024-02-20"]
      }
    ]
  }

응답 (Privacy-AI → DLM):
  {
    "status": "success",
    "results": [
      {"column": "CUST_NM", "pii_type": "PERSON_NAME", "score": 92, "reason": "성명 패턴"},
      {"column": "REG_DT",  "pii_type": null,          "score": 0,  "reason": "일반 날짜"}
    ],
    "token_usage": 1523,
    "elapsed_ms": 2341
  }
```

---

## 5. AI/LLM 탐지 상세

### 5.1 Privacy-AI 내부 흐름

```
POST /api/v1/privacy/detect
  │
  ├─ LLM 비활성화 → 모든 컬럼 score=0 즉시 반환
  │
  └─ LLM 활성화
     │
     ├─ System Prompt 구성
     │  "당신은 데이터베이스 개인정보 탐지 전문가입니다.
     │   테이블의 컬럼 정보를 분석하여 각 컬럼이 개인정보에
     │   해당하는지 판별하세요.
     │
     │   개인정보 유형:
     │   - PERSON_NAME: 성명
     │   - SSN: 주민등록번호
     │   - PHONE: 전화번호/휴대전화
     │   - EMAIL: 이메일 주소
     │   - ADDRESS: 주소
     │   - BIRTH_DATE: 생년월일
     │   - ACCOUNT_NO: 계좌번호
     │   - CARD_NO: 카드번호
     │   - PASSPORT: 여권번호
     │   - DRIVER_LICENSE: 운전면허번호
     │   - IP_ADDRESS: IP 주소
     │   - OTHER_PII: 기타 개인정보
     │
     │   JSON 배열로만 응답하세요:
     │   [{column, pii_type, score, reason}]"
     │
     ├─ User Prompt 구성
     │  → DetectRequest를 JSON으로 직렬화
     │
     ├─ OpenAI 호환 API 호출 (/v1/chat/completions)
     │  ├─ model: settings.llm_model
     │  ├─ temperature: 0.1 (일관된 결과)
     │  ├─ max_tokens: 4096
     │  └─ timeout: 60초
     │
     └─ 응답 파싱
        ├─ JSON 추출 (마크다운 펜스 제거)
        ├─ 점수 범위 보정 (0~100 클램핑)
        ├─ 누락 컬럼 → score=0으로 채움
        └─ 파싱 실패 → 전체 score=0 fallback
```

### 5.2 LLM 호환성

OpenAI 호환 API(`/v1/chat/completions`)를 사용하므로 다양한 LLM 서버와 호환됩니다:

| LLM 서버 | 설정 예시 |
|----------|---------|
| **vLLM** | `LLM_API_URL=http://vllm-server:8080/v1` |
| **Ollama** | `LLM_API_URL=http://ollama:11434/v1` |
| **OpenAI** | `LLM_API_URL=https://api.openai.com/v1` |
| **Azure OpenAI** | `LLM_API_URL=https://xxx.openai.azure.com/v1` |

### 5.3 토큰 사용량 예상

```
테이블 1개 (30컬럼, 샘플 5건):
  System Prompt :   ~500 토큰
  Input         : ~1,800 토큰
  Output        :   ~900 토큰
  합계          : ~3,200 토큰/테이블
  소요 시간     : ~2-3초

100 테이블 전체 스캔 (5스레드):
  총 토큰  : ~320K 토큰
  소요 시간 : ~1-2분
```

### 5.4 안전 설계 (Fallback)

```
LLM_ENABLED=false          → aiScore=0 (기존 동작 그대로)
Privacy-AI 연결 실패        → aiScore=0 (스캔 중단 안 됨)
LLM API timeout (60초)     → aiScore=0 (스캔 계속 진행)
LLM 응답 파싱 실패          → aiScore=0 (에러 로그만 기록)
```

**모든 실패 상황에서 스캔은 중단되지 않고 계속 진행됩니다.**

---

## 6. 최종 점수 계산

### 6.1 가중 평균 (Weight Normalization)

활성화된 탐지 방법만으로 가중치를 100%로 재분배합니다.

```
기본 가중치: Meta(40) + Pattern(35) + AI(25) = 100

예시 1: 3가지 모두 활성화
  metaScore=80, patternScore=70, aiScore=92

  totalEnabledWeight = 40 + 35 + 25 = 100

  score = 80×(40/100) + 70×(35/100) + 92×(25/100)
        = 32.0 + 24.5 + 23.0
        = 79.5 → 80

예시 2: Meta + Pattern만 활성화 (AI 비활성)
  metaScore=80, patternScore=70

  totalEnabledWeight = 40 + 35 = 75

  score = 80×(40/75) + 70×(35/75)
        = 42.7 + 32.7
        = 75.3 → 75
```

### 6.2 강력 매칭 보정

어느 하나의 방법이라도 90% 이상이면 최종 점수를 최소 80%로 보장합니다.

```
예시: metaScore=20, patternScore=10, aiScore=95

  가중 평균 = 20×0.4 + 10×0.35 + 95×0.25 = 8+3.5+23.75 = 35

  maxSingleScore = 95 ≥ 90 → 강력 매칭!
  finalScore = max(35, 80) = 80
```

---

## 7. 결과 처리 및 워크플로우

### 7.1 스캔 결과 저장

각 컬럼의 분석 결과는 `TBL_DISCOVERY_SCAN_RESULT`에 저장됩니다:

| 필드 | 설명 |
|------|------|
| resultId | UUID |
| jobId / executionId | 스캔 작업 참조 |
| dbName / schemaName / tableName / columnName | 컬럼 위치 |
| metaScore / patternScore / aiScore | 개별 점수 |
| score | 최종 합산 점수 |
| piiTypeCode | PII 유형 코드 |
| metaMatch / patternMatch / aiMatch | 매칭 여부 (Y/N) |
| matchedRule / matchedPattern | 매칭된 규칙/패턴 |
| sampleData | 샘플 데이터 (최대 5건) |
| confirmStatus | NOT_PII / PENDING / CONFIRMED / EXCLUDED |

### 7.2 확인 워크플로우

```
스캔 완료
  │
  ├─ score = 0     →  confirmStatus = NOT_PII (자동)
  ├─ score 30-89   →  confirmStatus = PENDING (수동 검토 필요)
  │                     ├─ 사용자: "CONFIRM" → PII Registry 등록
  │                     └─ 사용자: "EXCLUDE" → 오탐으로 제외
  └─ score ≥ 90    →  confirmStatus = CONFIRMED (자동 확정)
                        └─ PII Registry에 자동 등록
```

### 7.3 진행률 추적

```
UI에서 실시간 조회: GET /api/executions/{id}/progress

{
  status: "RUNNING",
  progress: 65,           // 전체 진행률 %
  totalTables: 100,
  scannedTables: 65,
  remainingTables: 35,
  totalColumns: 3000,
  scannedColumns: 1950,
  piiCount: 127,
  currentTable: "TB_PAYMENT",
  elapsedSeconds: 180,
  estimatedRemaining: 97
}
```

---

## 8. 설정 및 구성

### 8.1 Settings UI (피이아이 탐지 설정)

```
┌─────────────────────────────────────────────────────────┐
│ Default Scan Job Settings                               │
│  Exclude Data Types: NUMBER,INT,FLOAT,DATE,BLOB,...     │
│  Exclude Patterns:  *_CD,*_YN,*_FLAG,*_TYPE,...         │
│  [✓] Metadata Analysis                                 │
│  [✓] Pattern Matching                                  │
│  [✓] Skip Confirmed PII                                │
├─────────────────────────────────────────────────────────┤
│ Detection Threshold                                     │
│  Min Score:      [30] %  (이하 → NOT_PII)              │
│  Auto Confirm:   [90] %  (이상 → 자동 CONFIRMED)       │
├─────────────────────────────────────────────────────────┤
│ AI/LLM Settings                                        │
│  AI PII Detection:  [ON] / OFF                         │
│  Privacy-AI URL:    http://dlm-privacy-ai:8000         │
│  [Test Connection]  ✅ Connected (Model: llama3)       │
└─────────────────────────────────────────────────────────┘
```

### 8.2 TBL_DISCOVERY_CONFIG 설정 키

| 키 | 기본값 | 설명 |
|----|-------|------|
| `weight.metadata` | 40 | 메타데이터 가중치 |
| `weight.pattern` | 35 | 패턴 매칭 가중치 |
| `weight.ai` | 25 | AI 가중치 |
| `llm.enabled` | N | AI 탐지 활성화 (Y/N) |
| `llm.api.url` | - | Privacy-AI URL |
| `threshold.min_score` | 30 | 최소 점수 임계값 |
| `threshold.auto_confirm` | 90 | 자동 확정 임계값 |

### 8.3 Privacy-AI 환경변수 (.env)

```properties
# LLM 연결 설정 (Privacy-AI 서비스용)
PRIVACY_AI_LLM_ENABLED=false           # LLM 활성화
PRIVACY_AI_LLM_API_URL=                # LLM API URL (OpenAI 호환)
PRIVACY_AI_LLM_API_KEY=                # API 키
PRIVACY_AI_LLM_MODEL=                  # 모델명 (gpt-4o, llama3 등)
```

### 8.4 LLM 설정 변경 절차

```
1. .env에서 LLM 연결정보 설정
   PRIVACY_AI_LLM_ENABLED=true
   PRIVACY_AI_LLM_API_URL=http://your-llm:8080/v1
   PRIVACY_AI_LLM_API_KEY=your-key
   PRIVACY_AI_LLM_MODEL=your-model

2. Privacy-AI 재시작
   docker compose up -d --build dlm-privacy-ai

3. DLM Settings UI에서
   ├─ AI PII Detection → ON
   ├─ Privacy-AI URL → http://dlm-privacy-ai:8000
   └─ [Test Connection] → 연결 확인

4. Scan Job에서 enableAI=Y로 실행
```

---

## 9. 주요 파일 목록

### DLM Spring Boot

| 파일 | 역할 |
|------|------|
| `engine/DiscoveryEngineImpl.java` | 스캔 엔진 핵심 (멀티스레드, 스트리밍 매칭, AI 연동) |
| `client/PrivacyAiClient.java` | Privacy-AI HTTP 클라이언트 |
| `controller/PiiDiscoveryController.java` | REST API (스캔 실행, 설정, LLM 테스트) |
| `service/DiscoveryServiceImpl.java` | 서비스 레이어 (Job/Execution/Config CRUD) |
| `mapper/DiscoveryMapper.java` | MyBatis 매퍼 인터페이스 |
| `views/piidiscovery/settings.jsp` | Settings UI (AI/LLM 설정 포함) |

### DLM-Privacy-AI (FastAPI)

| 파일 | 역할 |
|------|------|
| `app/config.py` | Settings (LLM 연결 설정) |
| `app/routers/privacy.py` | detect, llm-status 엔드포인트 |
| `app/services/llm_service.py` | LLM API 호출 엔진 (System/User Prompt) |
| `app/schemas/detect.py` | Pydantic Request/Response 모델 |
