package datablocks.dlm.engine;

import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import datablocks.dlm.client.PrivacyAiClient;
import datablocks.dlm.domain.*;
import datablocks.dlm.jdbc.ConnectionProvider;
import datablocks.dlm.mapper.DiscoveryMapper;
import datablocks.dlm.util.AES256Util;
import datablocks.dlm.util.LogUtil;

/**
 * Discovery Engine Implementation
 * PII 자동탐지 엔진 구현체 (멀티스레드 + 스마트 필터링)
 */
@Component
public class DiscoveryEngineImpl implements DiscoveryEngine {

    private static final Logger logger = LoggerFactory.getLogger(DiscoveryEngineImpl.class);

    @Autowired
    private DiscoveryMapper mapper;

    @Autowired
    private PrivacyAiClient privacyAiClient;

    // 실행 중인 작업 관리
    private final Map<String, Boolean> runningExecutions = new ConcurrentHashMap<>();
    private final Map<String, ExecutorService> executorMap = new ConcurrentHashMap<>();

    // 진행 상황 관리
    private final Map<String, DiscoveryScanProgressVO> progressMap = new ConcurrentHashMap<>();

    // 규칙 캐시 (volatile로 스레드 간 가시성 보장)
    private volatile List<DiscoveryRuleVO> cachedRules;
    private volatile long cacheTime = 0;
    private static final long CACHE_TTL = 5 * 60 * 1000; // 5분

    // Weight 설정 캐시 (volatile로 스레드 간 가시성 보장)
    private volatile int weightMeta = 40;
    private volatile int weightPattern = 35;
    private volatile int weightAI = 25;
    private volatile long weightCacheTime = 0;

    // Privacy-AI 설정 캐시
    private volatile String privacyAiUrl = "";
    private volatile boolean privacyAiEnabled = false;

    // 제외할 데이터 타입 (기본값)
    private static final Set<String> DEFAULT_EXCLUDE_TYPES = new HashSet<>(Arrays.asList(
            "NUMBER", "INT", "INTEGER", "BIGINT", "SMALLINT", "TINYINT",
            "FLOAT", "DOUBLE", "DECIMAL", "NUMERIC", "REAL",
            "DATE", "DATETIME", "TIMESTAMP", "TIME",
            "BLOB", "CLOB", "NCLOB", "BFILE", "RAW", "LONG RAW", "LONG"
    ));

    // 제외할 컬럼명 패턴 (기본값)
    private static final List<String> DEFAULT_EXCLUDE_PATTERNS = Arrays.asList(
            "*_CD", "*_YN", "*_FLAG", "*_TYPE", "*_SEQ", "*_IDX", "*_CNT", "*_AMT", "*_DIV", "*_ORD",
            "REG_DATE", "UPD_DATE", "DEL_YN", "USE_YN", "SORT_*", "ORDER_*"
    );

    @Override
    public List<DiscoveryScanResultVO> executeScan(DiscoveryScanJobVO job, PiiDatabaseVO dbInfo, String executionId) {
        LogUtil.log("INFO", "DiscoveryEngine executeScan: " + job.getJobId() + " (execution: " + executionId + ")");

        List<DiscoveryScanResultVO> allResults = Collections.synchronizedList(new ArrayList<>());
        int threadCount = job.getThreadCount() != null ? job.getThreadCount() : 5;

        // 진행 상황 초기화
        DiscoveryScanProgressVO progressVO = new DiscoveryScanProgressVO();
        progressVO.setExecutionId(executionId);
        progressVO.setJobId(job.getJobId());
        progressVO.setJobName(job.getJobName());
        progressVO.setStatus("RUNNING");
        progressVO.setThreadCount(threadCount);
        progressVO.setStartTime(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
        progressMap.put(executionId, progressVO);
        runningExecutions.put(executionId, true);

        // DB 상태 업데이트: PENDING -> RUNNING
        mapper.updateExecutionStatus(executionId, "RUNNING", 0);

        long startTimeMillis = System.currentTimeMillis();

        // ThreadPoolExecutor 생성
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        executorMap.put(executionId, executor);

        // HikariCP 커넥션 풀 (threadCount 크기 - 물리 Connection 재사용, Oracle INACTIVE 세션 최소화)
        javax.sql.DataSource scanDataSource = null;
        ScheduledExecutorService progressScheduler = null;
        try {
            // 1. 데이터베이스 연결 풀 생성 (비밀번호 복호화)
            AES256Util aes = new AES256Util();
            final String decryptedPwd = aes.decrypt(dbInfo.getPwd());

            scanDataSource = ConnectionProvider.getDataSource(
                    threadCount,
                    dbInfo.getDbtype(),
                    dbInfo.getHostname(),
                    dbInfo.getPort(),
                    dbInfo.getId_type(),
                    dbInfo.getId(),
                    dbInfo.getDb(),
                    dbInfo.getDbuser(),
                    decryptedPwd
            );
            final javax.sql.DataSource finalDataSource = scanDataSource;

            // DB 제품명 확인 (풀에서 커넥션 하나 빌려서 확인 후 즉시 반환)
            String dbProductName;
            try (Connection testConn = finalDataSource.getConnection()) {
                dbProductName = testConn.getMetaData().getDatabaseProductName().toUpperCase();
            }

            // 2. 제외 설정 파싱
            Set<String> excludeTypes = parseExcludeTypes(job.getExcludeDataTypes());
            List<String> excludePatterns = parseExcludePatterns(job.getExcludePatterns());
            int minColumnLength = job.getMinColumnLength() != null ? job.getMinColumnLength() : 2;
            boolean skipConfirmed = "Y".equals(job.getSkipConfirmedPii());
            boolean isNewMode = "NEW".equals(job.getScanMode());

            // 3. 스킵할 컬럼 목록 조회
            // - NEW 모드: Registry에 등록된 모든 컬럼 스킵 (신규 컬럼만 스캔)
            // - FULL 모드 + skipConfirmed: CONFIRMED/EXCLUDED 컬럼만 스킵
            Set<String> skipColumns;
            if (isNewMode) {
                skipColumns = getRegisteredColumns(dbInfo.getDb());
                LogUtil.log("INFO", "NEW mode: Skipping " + skipColumns.size() + " already scanned columns");
            } else if (skipConfirmed) {
                skipColumns = getRegisteredColumns(dbInfo.getDb());
            } else {
                skipColumns = new HashSet<>();
            }

            // 4. 대상 스키마 목록 처리
            List<String> targetSchemas = new ArrayList<>();
            if (job.getTargetSchema() != null && !job.getTargetSchema().isEmpty()) {
                for (String schema : job.getTargetSchema().split(",")) {
                    schema = schema.trim();
                    if (!schema.isEmpty()) {
                        targetSchemas.add(schema);
                    }
                }
            }
            if (targetSchemas.isEmpty()) {
                targetSchemas.add(null);
            }

            // 5. 각 스키마별로 테이블 목록 조회 (TBL_METATABLE 기반 - 원천DB 카탈로그 미접근)
            String tablePattern = "%";
            if (job.getTargetTables() != null && !job.getTargetTables().isEmpty() && !"*".equals(job.getTargetTables())) {
                tablePattern = job.getTargetTables().replace("*", "%");
            }

            List<String[]> allTables = new ArrayList<>();
            // 스키마별 컬럼 정보를 TBL_METATABLE에서 한 번에 로드 (Map<테이블명, List<컬럼>>)
            Map<String, List<MetaTableVO>> metaColumnMap = new HashMap<>();
            for (String schema : targetSchemas) {
                String ownerKey = schema != null ? schema : "";
                List<String> tables = mapper.selectMetaTableNames(dbInfo.getDb(), ownerKey, tablePattern);
                for (String table : tables) {
                    allTables.add(new String[]{schema, table});
                }
                // 해당 스키마의 전체 컬럼 정보를 한 번에 로드
                List<MetaTableVO> allColumns = mapper.selectMetaColumnsByDbOwner(dbInfo.getDb(), ownerKey);
                for (MetaTableVO col : allColumns) {
                    metaColumnMap.computeIfAbsent(col.getTable_name(), k -> new ArrayList<>()).add(col);
                }
            }
            LogUtil.log("INFO", "Loaded " + metaColumnMap.size() + " tables from TBL_METATABLE (no catalog query to source DB)");

            // 5-1. 이전 Execution에서 완료된 테이블 목록 로드 (재시작 시 스킵용)
            Set<String> completedTableKeys = new HashSet<>();
            try {
                List<String> completedList = mapper.selectCompletedTables(executionId);
                if (completedList != null) {
                    completedTableKeys.addAll(completedList);
                }
                if (!completedTableKeys.isEmpty()) {
                    LogUtil.log("INFO", "Resume mode: " + completedTableKeys.size() + " tables already completed, will skip");
                }
            } catch (Exception e) {
                logger.debug("No previous table scan status found (new execution)");
            }

            int totalTables = allTables.size();
            AtomicInteger processedTables = new AtomicInteger(0);
            AtomicInteger skippedTables = new AtomicInteger(0);
            AtomicInteger totalColumns = new AtomicInteger(0);
            AtomicInteger scannedColumns = new AtomicInteger(0);
            AtomicInteger excludedColumns = new AtomicInteger(0);
            AtomicInteger piiCount = new AtomicInteger(0);

            // 테이블 목록 초기화
            List<DiscoveryScanProgressVO.TableScanStatus> tableStatusList = Collections.synchronizedList(new ArrayList<>());
            for (String[] schemaTable : allTables) {
                tableStatusList.add(new DiscoveryScanProgressVO.TableScanStatus(schemaTable[0], schemaTable[1]));
            }
            progressVO.setTableList(tableStatusList);
            progressVO.setTotalTables(totalTables);
            progressVO.setRemainingTables(totalTables);

            LogUtil.log("INFO", "Found " + totalTables + " tables to scan with " + threadCount + " threads");

            // 6. 탐지 규칙 미리 로드
            List<DiscoveryRuleVO> rules = loadRules();

            // 6-1. 진행률 DB 업데이트 전용 스케줄러 (단일 스레드, 3초 간격)
            //      워커 스레드에서 DB UPDATE를 하지 않고, 이 스케줄러만 DB에 접근하여 Lock 경합 방지
            progressScheduler = Executors.newSingleThreadScheduledExecutor(r -> {
                Thread t = new Thread(r, "progress-updater-" + executionId.substring(0, 8));
                t.setDaemon(true);
                return t;
            });
            progressScheduler.scheduleAtFixedRate(() -> {
                try {
                    if (!isRunning(executionId)) return;
                    int currentProgress = progressVO.getProgress();
                    if (currentProgress > 0) {
                        mapper.updateExecutionStatus(executionId, "RUNNING", currentProgress);
                    }
                } catch (Exception e) {
                    logger.warn("Scheduled progress update failed: {}", e.getMessage());
                }
            }, 3, 3, java.util.concurrent.TimeUnit.SECONDS);

            // 7. 테이블별 스캔 작업 제출 (각 스레드가 독립 Connection 사용)
            List<Future<?>> futures = new ArrayList<>();
            final String finalDbProductName = dbProductName;
            final Set<String> finalCompletedTableKeys = completedTableKeys;

            for (int i = 0; i < allTables.size(); i++) {
                // 취소 요청 시 추가 submit 중단 (RejectedExecutionException 방지)
                if (!isRunning(executionId)) {
                    LogUtil.log("INFO", "Scan cancelled, skipping remaining table submissions");
                    break;
                }

                final int tableIndex = i;
                final String[] schemaTable = allTables.get(i);
                final String schema = schemaTable[0];
                final String tableName = schemaTable[1];

                // 테이블 단위 스킵: 이전 실행에서 이미 완료된 테이블은 건너뜀
                String tableKey = (schema != null ? schema : "") + "." + tableName;
                if (finalCompletedTableKeys.contains(tableKey)) {
                    tableStatusList.get(i).setStatus("COMPLETED");
                    processedTables.incrementAndGet();
                    skippedTables.incrementAndGet();
                    continue;
                }

                Future<?> future = executor.submit(() -> {
                    if (!isRunning(executionId)) {
                        tableStatusList.get(tableIndex).setStatus("SKIPPED");
                        skippedTables.incrementAndGet();
                        processedTables.incrementAndGet();
                        return;
                    }

                    // 현재 테이블 스캔 시작
                    tableStatusList.get(tableIndex).setStatus("SCANNING");
                    progressVO.setCurrentSchema(schema);
                    progressVO.setCurrentTable(tableName);

                    long tableScanStart = System.currentTimeMillis();

                    // HikariCP 풀에서 Connection 빌려 사용 (close 시 풀에 반환, 물리 종료 아님)
                    Connection threadConn = null;
                    try {
                        threadConn = finalDataSource.getConnection();

                        // TBL_METATABLE에서 로드한 컬럼 정보 사용 (원천DB 카탈로그 미접근)
                        List<MetaTableVO> metaColumns = metaColumnMap.get(tableName);

                        // 테이블 스캔 수행
                        TableScanResult result = scanTableWithMetaColumns(
                                threadConn, job, dbInfo.getDb(), finalDbProductName, schema, tableName,
                                rules, excludeTypes, excludePatterns, minColumnLength, skipColumns,
                                executionId, metaColumns
                        );

                        allResults.addAll(result.results);
                        totalColumns.addAndGet(result.totalColumns);
                        scannedColumns.addAndGet(result.scannedColumns);
                        excludedColumns.addAndGet(result.excludedColumns);
                        piiCount.addAndGet(result.results.size());

                        // 테이블 상태 업데이트
                        long scanTime = System.currentTimeMillis() - tableScanStart;
                        DiscoveryScanProgressVO.TableScanStatus tableStatus = tableStatusList.get(tableIndex);
                        tableStatus.setStatus("COMPLETED");
                        tableStatus.setColumnCount(result.totalColumns);
                        tableStatus.setPiiCount(result.results.size());
                        tableStatus.setScanTime(scanTime);

                        // 테이블 완료 상태를 DB에 기록 (재시작 시 스킵용)
                        try {
                            mapper.insertTableScanComplete(executionId, schema, tableName,
                                    result.totalColumns, result.results.size(), scanTime);
                        } catch (Exception ex) {
                            logger.debug("Failed to record table scan status: " + ex.getMessage());
                        }

                    } catch (Exception e) {
                        logger.error("Error scanning table: " + tableName, e);
                        tableStatusList.get(tableIndex).setStatus("SKIPPED");
                        skippedTables.incrementAndGet();
                    } finally {
                        closeConnection(threadConn);
                    }

                    // 진행률 업데이트
                    int processed = processedTables.incrementAndGet();
                    int progress = (int) ((processed * 100.0) / totalTables);
                    progressVO.setProgress(progress);
                    progressVO.setScannedTables(processed - skippedTables.get());
                    progressVO.setRemainingTables(totalTables - processed);
                    progressVO.setTotalColumns(totalColumns.get());
                    progressVO.setScannedColumns(scannedColumns.get());
                    progressVO.setExcludedColumns(excludedColumns.get());
                    progressVO.setPiiCount(piiCount.get());

                    // 경과 시간 및 예상 남은 시간 계산
                    long elapsed = System.currentTimeMillis() - startTimeMillis;
                    progressVO.setElapsedSeconds(elapsed / 1000);
                    if (processed > 0) {
                        long avgTimePerTable = elapsed / processed;
                        long estimatedRemaining = avgTimePerTable * (totalTables - processed);
                        progressVO.setEstimatedRemaining(formatDuration(estimatedRemaining / 1000));
                    }

                    // DB 진행률은 별도 progressScheduler가 3초 간격으로 단일 스레드에서 업데이트
                    // (워커 스레드에서 DB UPDATE를 직접 호출하지 않아 Lock 경합 완전 방지)
                });

                futures.add(future);
            }

            // 8. 모든 작업 완료 대기
            //    cancelScan() → shutdownNow() 시, 큐에서 제거된 미시작 태스크의 future.get()은
            //    무한 블로킹되므로 5초 타임아웃 + isRunning() 체크로 교착 상태 방지
            for (Future<?> future : futures) {
                if (!isRunning(executionId)) {
                    future.cancel(true);
                    continue;
                }
                try {
                    while (!future.isDone()) {
                        try {
                            future.get(5, java.util.concurrent.TimeUnit.SECONDS);
                        } catch (java.util.concurrent.TimeoutException e) {
                            // 취소 요청 확인 후 미완료 Future 강제 취소
                            if (!isRunning(executionId)) {
                                future.cancel(true);
                                break;
                            }
                        }
                    }
                } catch (ExecutionException e) {
                    logger.error("Error waiting for scan task", e);
                } catch (InterruptedException e) {
                    logger.error("Scan interrupted, cancelling remaining tasks", e);
                    for (Future<?> f : futures) {
                        f.cancel(true);
                    }
                    Thread.currentThread().interrupt();
                    break;
                } catch (java.util.concurrent.CancellationException e) {
                    // shutdownNow() 이후 취소된 태스크 (정상)
                }
            }

            // 8-1. 진행률 스케줄러 종료 (완료 처리 전에 중지하여 DB 충돌 방지)
            // runningExecutions를 먼저 false로 설정하여 스케줄러의 isRunning() 체크로 DB 업데이트 차단
            boolean wasRunning = isRunning(executionId);
            runningExecutions.put(executionId, false);
            progressScheduler.shutdownNow();  // 큐에 남은 태스크도 즉시 취소
            try {
                progressScheduler.awaitTermination(5, java.util.concurrent.TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                // ignore
            }

            // 9. 완료 처리
            if (wasRunning) {
                progressVO.setStatus("COMPLETED");
                progressVO.setProgress(100);
                // DB 상태 업데이트: RUNNING -> COMPLETED
                mapper.updateExecutionComplete(executionId,
                        progressVO.getTotalTables(),
                        progressVO.getScannedTables(),
                        totalTables - processedTables.get() + skippedTables.get(), // skippedTables
                        progressVO.getTotalColumns(),
                        progressVO.getScannedColumns(),
                        progressVO.getExcludedColumns(),
                        progressVO.getPiiCount());
            } else {
                progressVO.setStatus("CANCELLED");
                // DB 상태 업데이트: RUNNING -> CANCELLED
                mapper.updateExecutionStatus(executionId, "CANCELLED", progressVO.getProgress());
            }
            progressVO.setCurrentTable(null);
            progressVO.setCurrentSchema(null);

        } catch (Exception e) {
            logger.error("Scan failed: " + job.getJobId(), e);
            progressVO.setStatus("FAILED");
            progressVO.setErrorMsg(e.getMessage());
            // DB 상태 업데이트: RUNNING -> FAILED
            mapper.updateExecutionFailed(executionId, e.getMessage());
        } finally {
            // 진행률 스케줄러 종료 (먼저)
            if (progressScheduler != null) {
                progressScheduler.shutdownNow();
            }
            // Executor 종료 및 작업 완료 대기
            executor.shutdown();
            try {
                if (!executor.awaitTermination(30, java.util.concurrent.TimeUnit.MINUTES)) {
                    executor.shutdownNow();
                    logger.warn("Executor did not terminate within 30 minutes, forced shutdown: " + executionId);
                }
            } catch (InterruptedException e) {
                executor.shutdownNow();
                Thread.currentThread().interrupt();
            }
            executorMap.remove(executionId);
            runningExecutions.remove(executionId);

            // HikariCP 풀 종료 (물리 Connection 모두 반환)
            if (scanDataSource instanceof com.zaxxer.hikari.HikariDataSource) {
                ((com.zaxxer.hikari.HikariDataSource) scanDataSource).close();
            }

            // 소요 시간 계산
            long elapsedMs = System.currentTimeMillis() - startTimeMillis;
            progressVO.setElapsedSeconds(elapsedMs / 1000);

            // 진행 상황 10분 후 삭제
            scheduleProgressCleanup(executionId);

            // 스캔 완료 시 오래된 결과 정리 (최근 3회만 유지)
            if ("COMPLETED".equals(progressVO.getStatus())) {
                cleanupOldResults(job.getJobId(), 3);
            }
        }

        return allResults;
    }

    /**
     * 컬럼 정보 내부 클래스
     */
    private static class ColumnInfo {
        String columnName;
        String dataType;
        int columnSize;
        String columnComment;

        ColumnInfo(String columnName, String dataType, int columnSize, String columnComment) {
            this.columnName = columnName;
            this.dataType = dataType;
            this.columnSize = columnSize;
            this.columnComment = columnComment;
        }
    }

    /**
     * 테이블 스캔 (TBL_METATABLE 기반) - 원천DB 카탈로그 미접근 최적화 버전
     * 컬럼 정보는 TBL_METATABLE에서 미리 로드한 데이터 사용, 원천DB에는 샘플 데이터 SELECT만 수행
     */
    private TableScanResult scanTableWithMetaColumns(
            Connection conn, DiscoveryScanJobVO job, String dbName, String dbProductName,
            String schema, String tableName, List<DiscoveryRuleVO> rules,
            Set<String> excludeTypes, List<String> excludePatterns, int minColumnLength,
            Set<String> skipColumns, String executionId, List<MetaTableVO> metaColumns) {

        TableScanResult scanResult = new TableScanResult();
        List<ColumnInfo> targetColumns = new ArrayList<>();

        try {
            // 1. TBL_METATABLE에서 미리 로드한 컬럼 정보로 필터링 (원천DB 카탈로그 조회 없음)
            if (metaColumns == null || metaColumns.isEmpty()) {
                return scanResult;
            }

            for (MetaTableVO col : metaColumns) {
                String columnName = col.getColumn_name();
                String dataType = col.getData_type();
                int columnSize = 0;
                try {
                    if (col.getData_length() != null && !col.getData_length().isEmpty()) {
                        columnSize = Integer.parseInt(col.getData_length());
                    }
                } catch (NumberFormatException ignored) {}
                String columnComment = col.getColumn_comment();

                scanResult.totalColumns++;

                String columnKey = buildColumnKey(dbName, schema, tableName, columnName);

                if (skipColumns.contains(columnKey)) {
                    scanResult.excludedColumns++;
                    continue;
                }

                if (shouldExcludeByType(dataType, excludeTypes)) {
                    scanResult.excludedColumns++;
                    continue;
                }

                if (shouldExcludeBySize(dataType, columnSize, minColumnLength)) {
                    scanResult.excludedColumns++;
                    continue;
                }

                if (shouldExcludeByPattern(columnName, excludePatterns)) {
                    scanResult.excludedColumns++;
                    continue;
                }

                targetColumns.add(new ColumnInfo(columnName, dataType, columnSize, columnComment));
                scanResult.scannedColumns++;
            }

            // 2. 대상 컬럼이 없으면 종료
            if (targetColumns.isEmpty()) {
                return scanResult;
            }

            // 3. 텍스트 타입 컬럼만 추출 (패턴 매칭용 샘플 데이터 조회 대상)
            List<String> textColumns = new ArrayList<>();
            for (ColumnInfo col : targetColumns) {
                if (isTextType(col.dataType)) {
                    textColumns.add(col.columnName);
                }
            }

            // 4. 스트리밍 패턴 매칭: fetchSize(2000)으로 row 단위 즉시 매칭 (메모리 절약)
            //    - 전체 데이터를 메모리에 적재하지 않고, 2000건씩 읽으면서 패턴 매칭
            //    - 컬럼별 매칭 카운트, 전체 카운트, 샘플 5건만 저장
            Map<String, StreamingMatchResult> streamingResults = new HashMap<>();
            if ("Y".equals(job.getEnablePattern()) && !textColumns.isEmpty()) {
                streamingResults = streamingPatternMatch(conn, dbProductName, schema, tableName,
                        textColumns, job.getSampleSize(), rules);
            }

            // 5. AI PII 탐지 (테이블 단위 배치 호출)
            Map<String, PrivacyAiClient.AiDetectResult> aiResults = Collections.emptyMap();
            if ("Y".equals(job.getEnableAi())) {
                aiResults = callAiDetect(tableName, schema, targetColumns, streamingResults, null);
            }

            // 6. 각 컬럼 분석 수행 (스트리밍 매칭 결과 + AI 결과 활용)
            for (ColumnInfo col : targetColumns) {
                StreamingMatchResult matchResult = streamingResults.get(col.columnName);
                PrivacyAiClient.AiDetectResult aiResult = aiResults.get(col.columnName);

                DiscoveryScanResultVO result = analyzeColumnWithStreamingResult(
                        job, dbName, schema, tableName, col.columnName,
                        col.dataType, col.columnComment, rules, matchResult, aiResult
                );

                if (result != null) {
                    result.setResultId(UUID.randomUUID().toString());
                    result.setJobId(job.getJobId());
                    result.setExecutionId(executionId);
                    mapper.insertScanResult(result);
                    if (result.getScore() > 0) {
                        scanResult.results.add(result);
                    }
                }
            }

        } catch (Exception e) {
            logger.error("Error scanning table (meta-based): " + tableName, e);
        }

        return scanResult;
    }

    /**
     * 스트리밍 패턴 매칭 결과 내부 클래스
     * 메모리에 전체 데이터를 올리지 않고, row 단위 매칭 결과만 저장
     */
    private static class StreamingMatchResult {
        int totalRows = 0;                              // 스캔한 전체 행 수
        Map<String, Integer> ruleMatchCounts = new HashMap<>();  // 규칙별 매칭 건수
        String bestMatchRuleId = null;                  // 최고 매칭률 규칙 ID
        double bestMatchRatio = 0;                      // 최고 매칭률
        List<String> sampleValues = new ArrayList<>();  // 샘플 데이터 (최대 5건)
    }

    /**
     * 스트리밍 방식 패턴 매칭 - fetchSize(2000)으로 2000건씩 읽으며 즉시 매칭
     * 대용량 테이블(1000만건+)에서도 메모리 안전
     */
    private Map<String, StreamingMatchResult> streamingPatternMatch(
            Connection conn, String dbProductName, String schema, String tableName,
            List<String> textColumns, Integer sampleSize, List<DiscoveryRuleVO> rules) {

        Map<String, StreamingMatchResult> results = new HashMap<>();
        for (String col : textColumns) {
            results.put(col, new StreamingMatchResult());
        }

        // PATTERN 규칙만 미리 컴파일
        List<DiscoveryRuleVO> patternRules = new ArrayList<>();
        Map<String, Pattern> compiledPatterns = new HashMap<>();
        for (DiscoveryRuleVO rule : rules) {
            if ("PATTERN".equals(rule.getRuleType()) && "ACTIVE".equals(rule.getStatus())) {
                try {
                    compiledPatterns.put(rule.getRuleId(), Pattern.compile(rule.getPattern()));
                    patternRules.add(rule);
                } catch (Exception e) {
                    logger.debug("Invalid pattern: " + rule.getPattern());
                }
            }
        }

        if (patternRules.isEmpty()) {
            return results;
        }

        Statement stmt = null;
        ResultSet rs = null;

        try {
            String fullTableName = schema != null ?
                    escapeIdentifier(schema, dbProductName) + "." + escapeIdentifier(tableName, dbProductName) :
                    escapeIdentifier(tableName, dbProductName);

            // 컬럼 목록 생성
            StringBuilder colList = new StringBuilder();
            for (int i = 0; i < textColumns.size(); i++) {
                if (i > 0) colList.append(", ");
                colList.append(escapeIdentifier(textColumns.get(i), dbProductName));
            }

            // SQL 생성 (DB별 행 제한 구문)
            String sql;
            int size = sampleSize != null ? sampleSize : 100;
            sql = buildLimitedSelectSql(colList.toString(), fullTableName, size, dbProductName);

            stmt = conn.createStatement();
            stmt.setFetchSize(2000);  // 2000건씩 네트워크 전송 (Oracle/Tibero 정상 동작)
            rs = stmt.executeQuery(sql);

            // Row 단위 스트리밍 매칭: 메모리에는 현재 row만 존재
            while (rs.next()) {
                for (String colName : textColumns) {
                    String value = rs.getString(colName);
                    if (value == null || value.isEmpty()) {
                        continue;
                    }

                    StreamingMatchResult mr = results.get(colName);
                    mr.totalRows++;

                    // 샘플 데이터 수집 (최대 5건만)
                    if (mr.sampleValues.size() < 5) {
                        mr.sampleValues.add(value);
                    }

                    // 각 패턴 규칙으로 즉시 매칭
                    for (DiscoveryRuleVO rule : patternRules) {
                        Pattern p = compiledPatterns.get(rule.getRuleId());
                        if (p != null && p.matcher(value).matches()) {
                            mr.ruleMatchCounts.merge(rule.getRuleId(), 1, Integer::sum);
                        }
                    }
                }
            }

            // 컬럼별 최고 매칭률 규칙 결정
            for (String colName : textColumns) {
                StreamingMatchResult mr = results.get(colName);
                if (mr.totalRows == 0) continue;

                for (DiscoveryRuleVO rule : patternRules) {
                    int matchCount = mr.ruleMatchCounts.getOrDefault(rule.getRuleId(), 0);
                    if (matchCount > 0) {
                        double ratio = (double) matchCount / mr.totalRows;
                        if (ratio > mr.bestMatchRatio) {
                            mr.bestMatchRatio = ratio;
                            mr.bestMatchRuleId = rule.getRuleId();
                        }
                    }
                }
            }

        } catch (SQLException e) {
            logger.debug("Error in streaming pattern match for table: " + tableName + " - " + e.getMessage());
        } finally {
            closeResultSet(rs);
            closeStatement(stmt);
        }

        return results;
    }

    /**
     * 컬럼 분석 (스트리밍 매칭 결과 기반)
     * analyzeColumnWithSample의 스트리밍 버전 - 메모리에 전체 데이터를 올리지 않음
     */
    private DiscoveryScanResultVO analyzeColumnWithStreamingResult(DiscoveryScanJobVO job,
            String dbName, String schemaName, String tableName, String columnName,
            String dataType, String columnComment,
            List<DiscoveryRuleVO> rules, StreamingMatchResult matchResult,
            PrivacyAiClient.AiDetectResult aiResult) {

        int metaScore = 0;
        int patternScore = 0;
        int aiScore = 0;

        String matchedPiiType = null;
        String matchedRule = null;
        String matchedPattern = null;
        String sampleDataForResult = null;
        boolean metaMatch = false;
        boolean patternMatch = false;
        boolean aiMatch = false;

        // 1. 메타데이터 분석 (컬럼명/코멘트 기반)
        if ("Y".equals(job.getEnableMeta())) {
            for (DiscoveryRuleVO rule : rules) {
                if (!"META".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }

                String[] keywords = rule.getPattern().split(",");
                for (String keyword : keywords) {
                    keyword = keyword.trim().toUpperCase();
                    String upperColumnName = columnName.toUpperCase();
                    String upperComment = columnComment != null ? columnComment.toUpperCase() : "";

                    if (upperColumnName.contains(keyword) || upperComment.contains(keyword)) {
                        int score = (int) (rule.getWeight() * 100);
                        if (score > metaScore) {
                            metaScore = score;
                            matchedPiiType = rule.getPiiTypeCode();
                            matchedRule = rule.getRuleName();
                            metaMatch = true;
                        }
                        break;
                    }
                }
            }
        }

        // 2. 패턴 매칭 (스트리밍 결과 활용 - 이미 row 단위로 매칭 완료)
        if ("Y".equals(job.getEnablePattern()) && isTextType(dataType) && matchResult != null) {
            // 샘플 데이터 저장 (최대 5건)
            if (!matchResult.sampleValues.isEmpty()) {
                sampleDataForResult = String.join("\n", matchResult.sampleValues);
            }

            // 스트리밍 매칭 결과에서 최고 점수 산출
            for (DiscoveryRuleVO rule : rules) {
                if (!"PATTERN".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }
                int matchCount = matchResult.ruleMatchCounts.getOrDefault(rule.getRuleId(), 0);
                if (matchCount > 0 && matchResult.totalRows > 0) {
                    double matchRatio = (double) matchCount / matchResult.totalRows;
                    int score = (int) (rule.getWeight() * matchRatio * 100);
                    if (score > patternScore) {
                        patternScore = score;
                        if (matchedPiiType == null) {
                            matchedPiiType = rule.getPiiTypeCode();
                        }
                        matchedPattern = rule.getPattern();
                        patternMatch = true;
                    }
                }
            }
        }

        // 3. AI 탐지 결과 적용
        if ("Y".equals(job.getEnableAi()) && aiResult != null && aiResult.score > 0) {
            aiScore = aiResult.score;
            aiMatch = true;
            if (matchedPiiType == null && aiResult.piiType != null) {
                matchedPiiType = aiResult.piiType;
            }
        }

        // 최종 점수 계산
        boolean enableMeta = "Y".equals(job.getEnableMeta());
        boolean enablePattern = "Y".equals(job.getEnablePattern());
        boolean enableAI = "Y".equals(job.getEnableAi());
        int totalScore = calculateTotalScore(metaScore, patternScore, aiScore, enableMeta, enablePattern, enableAI);

        // 결과 생성
        DiscoveryScanResultVO result = new DiscoveryScanResultVO();
        result.setDbName(dbName);
        result.setSchemaName(schemaName != null ? schemaName : "");
        result.setTableName(tableName);
        result.setColumnName(columnName);
        result.setDataType(dataType);
        result.setColumnComment(columnComment);
        result.setMetaScore(metaScore);
        result.setPatternScore(patternScore);
        result.setAiScore(aiScore);
        result.setMetaMatch(metaMatch ? "Y" : "N");
        result.setPatternMatch(patternMatch ? "Y" : "N");
        result.setAiMatch(aiMatch ? "Y" : "N");
        result.setMatchedRule(matchedRule);
        result.setMatchedPattern(matchedPattern);
        result.setSampleData(sampleDataForResult);

        if (totalScore == 0) {
            result.setPiiTypeCode("NOT_PII");
            result.setPiiTypeName("PII 아님");
            result.setConfirmStatus("NOT_PII");
        } else {
            result.setPiiTypeCode(matchedPiiType != null ? matchedPiiType : "NOT_PII");
            result.setPiiTypeName(getPiiTypeName(matchedPiiType));
            result.setConfirmStatus("PENDING");
        }
        result.setScore(totalScore);

        // 암호화 탐지 (샘플값 기반 후처리)
        if (matchResult != null && !matchResult.sampleValues.isEmpty()) {
            EncryptionDetector.EncryptionResult encResult = EncryptionDetector.detect(matchResult.sampleValues);
            result.setEncryptionStatus(encResult.status);
            result.setEncryptionMethod(encResult.method);
            result.setEncryptionRatio(encResult.ratio);

            if (!"NONE".equals(encResult.status)) {
                // 암호화 감지 시 patternScore에 반영 (기존 패턴 점수가 없는 경우만)
                if (patternScore == 0) {
                    patternScore = encResult.ratio;
                    patternMatch = true;
                    result.setPatternScore(patternScore);
                    result.setPatternMatch("Y");
                    // 최종 점수 재계산
                    totalScore = calculateTotalScore(metaScore, patternScore, aiScore, enableMeta, enablePattern, enableAI);
                    result.setScore(totalScore);
                }
                // NOT_PII → ENCRYPTED_PII로 유형 변경
                if ("NOT_PII".equals(result.getPiiTypeCode())) {
                    result.setPiiTypeCode("ENCRYPTED_PII");
                    result.setPiiTypeName("암호화 PII");
                }
                result.setConfirmStatus("PENDING");
            }
        } else {
            result.setEncryptionStatus("NONE");
            result.setEncryptionRatio(0);
        }

        return result;
    }

    /**
     * 테이블 스캔 (필터링 적용) - 원천DB 카탈로그 직접 조회 버전 (단일 테이블 스캔용)
     * 테이블당 1회 SELECT로 모든 대상 컬럼의 샘플 데이터 조회
     */
    private TableScanResult scanTableWithFiltering(
            Connection conn, DiscoveryScanJobVO job, String dbName, String dbProductName,
            String schema, String tableName, List<DiscoveryRuleVO> rules,
            Set<String> excludeTypes, List<String> excludePatterns, int minColumnLength,
            Set<String> skipColumns, String executionId) {

        TableScanResult scanResult = new TableScanResult();
        ResultSet columns = null;
        List<ColumnInfo> targetColumns = new ArrayList<>();

        try {
            DatabaseMetaData metaData = conn.getMetaData();
            columns = metaData.getColumns(null, schema, tableName, null);

            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String dataType = columns.getString("TYPE_NAME");
                int columnSize = columns.getInt("COLUMN_SIZE");
                String columnComment = columns.getString("REMARKS");

                scanResult.totalColumns++;

                String columnKey = buildColumnKey(dbName, schema, tableName, columnName);

                if (skipColumns.contains(columnKey)) {
                    scanResult.excludedColumns++;
                    continue;
                }
                if (shouldExcludeByType(dataType, excludeTypes)) {
                    scanResult.excludedColumns++;
                    continue;
                }
                if (shouldExcludeBySize(dataType, columnSize, minColumnLength)) {
                    scanResult.excludedColumns++;
                    continue;
                }
                if (shouldExcludeByPattern(columnName, excludePatterns)) {
                    scanResult.excludedColumns++;
                    continue;
                }

                targetColumns.add(new ColumnInfo(columnName, dataType, columnSize, columnComment));
                scanResult.scannedColumns++;
            }
            closeResultSet(columns);
            columns = null;

            if (targetColumns.isEmpty()) {
                return scanResult;
            }

            List<String> textColumns = new ArrayList<>();
            for (ColumnInfo col : targetColumns) {
                if (isTextType(col.dataType)) {
                    textColumns.add(col.columnName);
                }
            }

            Map<String, String> sampleDataMap = new HashMap<>();
            if ("Y".equals(job.getEnablePattern()) && !textColumns.isEmpty()) {
                sampleDataMap = getTableSampleData(conn, dbProductName, schema, tableName,
                                                   textColumns, job.getSampleSize());
            }

            // AI PII 탐지 (테이블 단위 배치 호출)
            Map<String, PrivacyAiClient.AiDetectResult> aiResults = Collections.emptyMap();
            if ("Y".equals(job.getEnableAi())) {
                aiResults = callAiDetect(tableName, schema, targetColumns, null, sampleDataMap);
            }

            for (ColumnInfo col : targetColumns) {
                String sampleData = sampleDataMap.get(col.columnName);
                PrivacyAiClient.AiDetectResult aiResult = aiResults.get(col.columnName);

                DiscoveryScanResultVO result = analyzeColumnWithSample(
                        job, dbName, schema, tableName, col.columnName,
                        col.dataType, col.columnComment, rules, sampleData, aiResult
                );

                if (result != null) {
                    result.setResultId(UUID.randomUUID().toString());
                    result.setJobId(job.getJobId());
                    result.setExecutionId(executionId);
                    mapper.insertScanResult(result);
                    if (result.getScore() > 0) {
                        scanResult.results.add(result);
                    }
                }
            }

        } catch (SQLException e) {
            logger.error("Error scanning table: " + tableName, e);
        } finally {
            closeResultSet(columns);
        }

        return scanResult;
    }

    /**
     * 테이블 단위로 여러 컬럼의 샘플 데이터 조회 (최적화)
     * @return Map<컬럼명, 샘플데이터(줄바꿈 구분)>
     */
    private Map<String, String> getTableSampleData(Connection conn, String dbProductName,
            String schema, String tableName, List<String> columns, Integer sampleSize) {

        Map<String, String> result = new HashMap<>();
        if (columns == null || columns.isEmpty()) {
            return result;
        }

        int size = sampleSize != null ? sampleSize : 100;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            String fullTableName = schema != null ?
                    escapeIdentifier(schema, dbProductName) + "." + escapeIdentifier(tableName, dbProductName) :
                    escapeIdentifier(tableName, dbProductName);

            // 컬럼 목록 생성
            StringBuilder colList = new StringBuilder();
            for (int i = 0; i < columns.size(); i++) {
                if (i > 0) colList.append(", ");
                colList.append(escapeIdentifier(columns.get(i), dbProductName));
            }

            // SQL 생성 (DB별 행 제한 구문)
            String sql = buildLimitedSelectSql(colList.toString(), fullTableName, size, dbProductName);

            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            // 컬럼별 StringBuilder 초기화
            Map<String, StringBuilder> builders = new HashMap<>();
            for (String col : columns) {
                builders.put(col, new StringBuilder());
            }

            // 결과 처리
            while (rs.next()) {
                for (String col : columns) {
                    String value = rs.getString(col);
                    if (value != null && !value.isEmpty()) {
                        StringBuilder sb = builders.get(col);
                        if (sb.length() > 0) sb.append("\n");
                        sb.append(value);
                    }
                }
            }

            // 결과 맵 생성
            for (String col : columns) {
                String data = builders.get(col).toString();
                if (!data.isEmpty()) {
                    result.put(col, data);
                }
            }

        } catch (SQLException e) {
            logger.debug("Error getting table sample data: " + e.getMessage());
        } finally {
            closeResultSet(rs);
            closeStatement(stmt);
        }

        return result;
    }

    /**
     * 테이블 스캔 결과 내부 클래스
     */
    private static class TableScanResult {
        List<DiscoveryScanResultVO> results = new ArrayList<>();
        int totalColumns = 0;
        int scannedColumns = 0;
        int excludedColumns = 0;
    }

    /**
     * 제외 데이터 타입 파싱
     */
    private Set<String> parseExcludeTypes(String excludeDataTypes) {
        Set<String> types = new HashSet<>(DEFAULT_EXCLUDE_TYPES);
        if (excludeDataTypes != null && !excludeDataTypes.isEmpty()) {
            for (String type : excludeDataTypes.split(",")) {
                type = type.trim().toUpperCase();
                if (!type.isEmpty()) {
                    types.add(type);
                }
            }
        }
        return types;
    }

    /**
     * 제외 패턴 파싱
     */
    private List<String> parseExcludePatterns(String excludePatterns) {
        List<String> patterns = new ArrayList<>(DEFAULT_EXCLUDE_PATTERNS);
        if (excludePatterns != null && !excludePatterns.isEmpty()) {
            for (String pattern : excludePatterns.split(",")) {
                pattern = pattern.trim().toUpperCase();
                if (!pattern.isEmpty() && !patterns.contains(pattern)) {
                    patterns.add(pattern);
                }
            }
        }
        return patterns;
    }

    /**
     * 컬럼 키 생성 (확인된 PII 조회용)
     */
    private String buildColumnKey(String dbName, String schema, String tableName, String columnName) {
        return (dbName + "." + (schema != null ? schema : "") + "." + tableName + "." + columnName).toUpperCase();
    }

    /**
     * Registry에 등록된 컬럼 목록 조회 (CONFIRMED + EXCLUDED + PENDING 모두 포함)
     * - 이미 스캔되어 Registry에 등록된 모든 컬럼
     * - NEW 모드: 이 목록에 없는 컬럼만 스캔 (신규 테이블/컬럼 탐지)
     * - FULL 모드 + skipConfirmed: 이 목록의 컬럼 스킵
     *
     * NOTE: Registry 테이블 (TBL_DISCOVERY_PII_REGISTRY)에서 조회
     */
    private Set<String> getRegisteredColumns(String dbName) {
        Set<String> registered = new HashSet<>();
        try {
            // MetaTable에서 PII 확정 + 오탐 제외 컬럼 키 조회
            List<String> piiKeys = mapper.selectMetaTablePiiColumnKeys(dbName);
            registered.addAll(piiKeys);

            logger.info("Loaded {} PII/EXCLUDED columns from MetaTable for skip", registered.size());
        } catch (Exception e) {
            logger.error("Error getting PII columns from MetaTable", e);
        }
        return registered;
    }

    /**
     * 데이터 타입으로 제외 여부 확인
     */
    private boolean shouldExcludeByType(String dataType, Set<String> excludeTypes) {
        if (dataType == null) return false;
        String upper = dataType.toUpperCase();
        for (String excludeType : excludeTypes) {
            if (upper.contains(excludeType)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 컬럼 크기로 제외 여부 확인
     */
    private boolean shouldExcludeBySize(String dataType, int columnSize, int minLength) {
        if (dataType == null) return false;
        String upper = dataType.toUpperCase();
        if ((upper.contains("CHAR") || upper.contains("VARCHAR")) && columnSize > 0 && columnSize < minLength) {
            return true;
        }
        return false;
    }

    /**
     * 컬럼명 패턴으로 제외 여부 확인
     */
    private boolean shouldExcludeByPattern(String columnName, List<String> excludePatterns) {
        if (columnName == null) return false;
        String upper = columnName.toUpperCase();

        for (String pattern : excludePatterns) {
            pattern = pattern.toUpperCase();
            if (pattern.startsWith("*") && pattern.endsWith("*")) {
                // *ABC* -> contains
                String middle = pattern.substring(1, pattern.length() - 1);
                if (upper.contains(middle)) return true;
            } else if (pattern.startsWith("*")) {
                // *_CD -> endsWith
                String suffix = pattern.substring(1);
                if (upper.endsWith(suffix)) return true;
            } else if (pattern.endsWith("*")) {
                // SORT_* -> startsWith
                String prefix = pattern.substring(0, pattern.length() - 1);
                if (upper.startsWith(prefix)) return true;
            } else {
                // exact match
                if (upper.equals(pattern)) return true;
            }
        }
        return false;
    }

    @Override
    public List<DiscoveryScanResultVO> scanTable(DiscoveryScanJobVO job, PiiDatabaseVO dbInfo, String tableName, String executionId) {
        Connection conn = null;
        try {
            AES256Util aes = new AES256Util();
            String decryptedPwd = aes.decrypt(dbInfo.getPwd());

            conn = ConnectionProvider.getConnection(
                    dbInfo.getDbtype(),
                    dbInfo.getHostname(),
                    dbInfo.getPort(),
                    dbInfo.getId_type(),
                    dbInfo.getId(),
                    dbInfo.getDb(),
                    dbInfo.getDbuser(),
                    decryptedPwd
            );

            String schema = null;
            if (job.getTargetSchema() != null && !job.getTargetSchema().isEmpty()) {
                String[] schemas = job.getTargetSchema().split(",");
                schema = schemas[0].trim();
            }

            List<DiscoveryRuleVO> rules = loadRules();
            String dbProductName = conn.getMetaData().getDatabaseProductName().toUpperCase();

            TableScanResult result = scanTableWithFiltering(
                    conn, job, dbInfo.getDb(), dbProductName, schema, tableName, rules,
                    parseExcludeTypes(job.getExcludeDataTypes()),
                    parseExcludePatterns(job.getExcludePatterns()),
                    job.getMinColumnLength() != null ? job.getMinColumnLength() : 2,
                    new HashSet<>(), executionId
            );

            return result.results;
        } catch (Exception e) {
            logger.error("Table scan failed: " + tableName, e);
            return new ArrayList<>();
        } finally {
            closeConnection(conn);
        }
    }

    @Override
    public void cancelScan(String executionId) {
        runningExecutions.put(executionId, false);

        ExecutorService executor = executorMap.get(executionId);
        if (executor != null) {
            executor.shutdownNow();
        }
    }

    @Override
    public boolean isRunning(String executionId) {
        return runningExecutions.getOrDefault(executionId, false);
    }

    @Override
    public DiscoveryScanProgressVO getScanProgress(String executionId) {
        return progressMap.get(executionId);
    }

    /**
     * 시간 포맷팅 (초 -> 분:초)
     */
    private String formatDuration(long seconds) {
        if (seconds < 60) {
            return seconds + "s";
        } else if (seconds < 3600) {
            return (seconds / 60) + "m " + (seconds % 60) + "s";
        } else {
            long hours = seconds / 3600;
            long mins = (seconds % 3600) / 60;
            return hours + "h " + mins + "m";
        }
    }

    /**
     * DB별 행 제한 SELECT SQL 생성
     * Oracle/Tibero: ROWNUM, MSSQL: TOP N, DB2: FETCH FIRST, MySQL/MariaDB/PostgreSQL: LIMIT
     */
    private String buildLimitedSelectSql(String columns, String fullTableName, int limit, String dbProductName) {
        if (dbProductName.contains("ORACLE") || dbProductName.contains("TIBERO")) {
            return "SELECT " + columns + " FROM " + fullTableName + " WHERE ROWNUM <= " + limit;
        } else if (dbProductName.contains("SQL SERVER") || dbProductName.contains("MICROSOFT")) {
            return "SELECT TOP " + limit + " " + columns + " FROM " + fullTableName;
        } else if (dbProductName.contains("DB2")) {
            return "SELECT " + columns + " FROM " + fullTableName + " FETCH FIRST " + limit + " ROWS ONLY";
        } else {
            // MySQL, MariaDB, PostgreSQL
            return "SELECT " + columns + " FROM " + fullTableName + " LIMIT " + limit;
        }
    }

    /**
     * 진행 상황 정리 스케줄링 (10분 후 삭제)
     */
    private void scheduleProgressCleanup(String executionId) {
        Thread cleanupThread = new Thread(() -> {
            try {
                Thread.sleep(10 * 60 * 1000);
                progressMap.remove(executionId);
            } catch (InterruptedException e) {
                // ignore
            }
        });
        cleanupThread.setDaemon(true);
        cleanupThread.setName("discovery-cleanup-" + executionId.substring(0, 8));
        cleanupThread.start();
    }

    /**
     * 대상 테이블 목록 조회
     */
    private List<String> getTargetTables(Connection conn, DiscoveryScanJobVO job, String schema) throws SQLException {
        List<String> tables = new ArrayList<>();
        ResultSet rs = null;

        try {
            DatabaseMetaData metaData = conn.getMetaData();

            String tablePattern = "%";
            if (job.getTargetTables() != null && !job.getTargetTables().isEmpty() && !"*".equals(job.getTargetTables())) {
                tablePattern = job.getTargetTables().replace("*", "%");
            }

            rs = metaData.getTables(null, schema, tablePattern, new String[]{"TABLE"});
            while (rs.next()) {
                tables.add(rs.getString("TABLE_NAME"));
            }
        } finally {
            closeResultSet(rs);
        }

        return tables;
    }

    /**
     * 컬럼 PII 분석
     */
    private DiscoveryScanResultVO analyzeColumn(Connection conn, DiscoveryScanJobVO job,
                                                String dbName, String dbProductName, String schemaName, String tableName, String columnName,
                                                String dataType, String columnComment,
                                                List<DiscoveryRuleVO> rules) {
        int metaScore = 0;
        int patternScore = 0;
        int aiScore = 0;

        String matchedPiiType = null;
        String matchedRule = null;
        String matchedPattern = null;
        String sampleDataForResult = null;  // 샘플 데이터 저장용
        boolean metaMatch = false;
        boolean patternMatch = false;

        // 1. 메타데이터 분석 (컬럼명/코멘트 기반)
        if ("Y".equals(job.getEnableMeta())) {
            for (DiscoveryRuleVO rule : rules) {
                if (!"META".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }

                String[] keywords = rule.getPattern().split(",");
                for (String keyword : keywords) {
                    keyword = keyword.trim().toUpperCase();
                    String upperColumnName = columnName.toUpperCase();
                    String upperComment = columnComment != null ? columnComment.toUpperCase() : "";

                    if (upperColumnName.contains(keyword) || upperComment.contains(keyword)) {
                        int score = (int) (rule.getWeight() * 100);
                        if (score > metaScore) {
                            metaScore = score;
                            matchedPiiType = rule.getPiiTypeCode();
                            matchedRule = rule.getRuleName();
                            metaMatch = true;
                        }
                        break;
                    }
                }
            }
        }

        // 2. 패턴 매칭 (데이터 샘플 기반)
        if ("Y".equals(job.getEnablePattern()) && isTextType(dataType)) {
            String sampleData = getSampleData(conn, dbProductName, schemaName, tableName, columnName, job.getSampleSize());
            // 샘플 데이터 저장 (최대 5건)
            if (sampleData != null && !sampleData.isEmpty()) {
                sampleDataForResult = limitSampleData(sampleData, 5);
            }

            for (DiscoveryRuleVO rule : rules) {
                if (!"PATTERN".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }

                try {
                    Pattern p = Pattern.compile(rule.getPattern());
                    if (sampleData != null) {
                        String[] samples = sampleData.split("\n");
                        int matchCount = 0;
                        for (String sample : samples) {
                            if (sample != null && p.matcher(sample).matches()) {
                                matchCount++;
                            }
                        }
                        if (matchCount > 0) {
                            double matchRatio = (double) matchCount / samples.length;
                            int score = (int) (rule.getWeight() * matchRatio * 100);
                            if (score > patternScore) {
                                patternScore = score;
                                if (matchedPiiType == null) {
                                    matchedPiiType = rule.getPiiTypeCode();
                                }
                                matchedPattern = rule.getPattern();
                                patternMatch = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.debug("Invalid pattern: " + rule.getPattern());
                }
            }
        }

        // 최종 점수 계산 (Weight 재분배 + 강력 매칭 보정)
        boolean enableMeta = "Y".equals(job.getEnableMeta());
        boolean enablePattern = "Y".equals(job.getEnablePattern());
        boolean enableAI = "Y".equals(job.getEnableAi());
        int totalScore = calculateTotalScore(metaScore, patternScore, aiScore, enableMeta, enablePattern, enableAI);

        // 결과 생성
        DiscoveryScanResultVO result = new DiscoveryScanResultVO();
        result.setDbName(dbName);
        result.setSchemaName(schemaName != null ? schemaName : "");
        result.setTableName(tableName);
        result.setColumnName(columnName);
        result.setDataType(dataType);
        result.setColumnComment(columnComment);
        result.setMetaScore(metaScore);
        result.setPatternScore(patternScore);
        result.setAiScore(aiScore);
        result.setMetaMatch(metaMatch ? "Y" : "N");
        result.setPatternMatch(patternMatch ? "Y" : "N");
        result.setAiMatch(aiScore > 0 ? "Y" : "N");
        result.setMatchedRule(matchedRule);
        result.setMatchedPattern(matchedPattern);
        result.setSampleData(sampleDataForResult);

        // Score가 0이면 NOT_PII로 표시 (사용자가 검토 가능)
        if (totalScore == 0) {
            result.setPiiTypeCode("NOT_PII");
            result.setPiiTypeName("Not PII");
            result.setScore(0);
            result.setConfirmStatus("NOT_PII");
        } else {
            result.setPiiTypeCode(matchedPiiType);
            result.setPiiTypeName(getPiiTypeName(matchedPiiType));
            result.setScore(totalScore);
            result.setConfirmStatus("PENDING");
        }

        return result;
    }

    /**
     * 컬럼 PII 분석 (샘플 데이터를 파라미터로 받는 최적화 버전)
     * getTableSampleData()로 미리 조회된 샘플 데이터를 사용
     */
    private DiscoveryScanResultVO analyzeColumnWithSample(DiscoveryScanJobVO job,
                                                          String dbName, String schemaName, String tableName, String columnName,
                                                          String dataType, String columnComment,
                                                          List<DiscoveryRuleVO> rules, String sampleData,
                                                          PrivacyAiClient.AiDetectResult aiResult) {
        int metaScore = 0;
        int patternScore = 0;
        int aiScore = 0;

        String matchedPiiType = null;
        String matchedRule = null;
        String matchedPattern = null;
        String sampleDataForResult = null;
        boolean metaMatch = false;
        boolean patternMatch = false;
        boolean aiMatch = false;

        // 1. 메타데이터 분석 (컬럼명/코멘트 기반)
        if ("Y".equals(job.getEnableMeta())) {
            for (DiscoveryRuleVO rule : rules) {
                if (!"META".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }

                String[] keywords = rule.getPattern().split(",");
                for (String keyword : keywords) {
                    keyword = keyword.trim().toUpperCase();
                    String upperColumnName = columnName.toUpperCase();
                    String upperComment = columnComment != null ? columnComment.toUpperCase() : "";

                    if (upperColumnName.contains(keyword) || upperComment.contains(keyword)) {
                        int score = (int) (rule.getWeight() * 100);
                        if (score > metaScore) {
                            metaScore = score;
                            matchedPiiType = rule.getPiiTypeCode();
                            matchedRule = rule.getRuleName();
                            metaMatch = true;
                        }
                        break;
                    }
                }
            }
        }

        // 2. 패턴 매칭 (샘플 데이터 기반 - 파라미터로 전달받음)
        if ("Y".equals(job.getEnablePattern()) && isTextType(dataType)) {
            // 샘플 데이터 저장 (최대 5건)
            if (sampleData != null && !sampleData.isEmpty()) {
                sampleDataForResult = limitSampleData(sampleData, 5);
            }

            for (DiscoveryRuleVO rule : rules) {
                if (!"PATTERN".equals(rule.getRuleType()) || !"ACTIVE".equals(rule.getStatus())) {
                    continue;
                }

                try {
                    Pattern p = Pattern.compile(rule.getPattern());
                    if (sampleData != null) {
                        String[] samples = sampleData.split("\n");
                        int matchCount = 0;
                        for (String sample : samples) {
                            if (sample != null && p.matcher(sample).matches()) {
                                matchCount++;
                            }
                        }
                        if (matchCount > 0) {
                            double matchRatio = (double) matchCount / samples.length;
                            int score = (int) (rule.getWeight() * matchRatio * 100);
                            if (score > patternScore) {
                                patternScore = score;
                                if (matchedPiiType == null) {
                                    matchedPiiType = rule.getPiiTypeCode();
                                }
                                matchedPattern = rule.getPattern();
                                patternMatch = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.debug("Invalid pattern: " + rule.getPattern());
                }
            }
        }

        // 3. AI 탐지 결과 적용
        if ("Y".equals(job.getEnableAi()) && aiResult != null && aiResult.score > 0) {
            aiScore = aiResult.score;
            aiMatch = true;
            if (matchedPiiType == null && aiResult.piiType != null) {
                matchedPiiType = aiResult.piiType;
            }
        }

        // 최종 점수 계산 (Weight 재분배 + 강력 매칭 보정)
        boolean enableMeta = "Y".equals(job.getEnableMeta());
        boolean enablePattern = "Y".equals(job.getEnablePattern());
        boolean enableAI = "Y".equals(job.getEnableAi());
        int totalScore = calculateTotalScore(metaScore, patternScore, aiScore, enableMeta, enablePattern, enableAI);

        // 결과 생성
        DiscoveryScanResultVO result = new DiscoveryScanResultVO();
        result.setDbName(dbName);
        result.setSchemaName(schemaName != null ? schemaName : "");
        result.setTableName(tableName);
        result.setColumnName(columnName);
        result.setDataType(dataType);
        result.setColumnComment(columnComment);
        result.setMetaScore(metaScore);
        result.setPatternScore(patternScore);
        result.setAiScore(aiScore);
        result.setMetaMatch(metaMatch ? "Y" : "N");
        result.setPatternMatch(patternMatch ? "Y" : "N");
        result.setAiMatch(aiMatch ? "Y" : "N");
        result.setMatchedRule(matchedRule);
        result.setMatchedPattern(matchedPattern);
        result.setSampleData(sampleDataForResult);

        // Score가 0이면 NOT_PII로 표시
        if (totalScore == 0) {
            result.setPiiTypeCode("NOT_PII");
            result.setPiiTypeName("Not PII");
            result.setScore(0);
            result.setConfirmStatus("NOT_PII");
        } else {
            result.setPiiTypeCode(matchedPiiType);
            result.setPiiTypeName(getPiiTypeName(matchedPiiType));
            result.setScore(totalScore);
            result.setConfirmStatus("PENDING");
        }

        // 암호화 탐지 (샘플데이터 기반 후처리)
        if (sampleDataForResult != null && !sampleDataForResult.isEmpty()) {
            java.util.List<String> samples = java.util.Arrays.asList(sampleDataForResult.split("\n"));
            EncryptionDetector.EncryptionResult encResult = EncryptionDetector.detect(samples);
            result.setEncryptionStatus(encResult.status);
            result.setEncryptionMethod(encResult.method);
            result.setEncryptionRatio(encResult.ratio);

            if (!"NONE".equals(encResult.status)) {
                // 암호화 감지 시 patternScore에 반영 (기존 패턴 점수가 없는 경우만)
                if (patternScore == 0) {
                    patternScore = encResult.ratio;
                    patternMatch = true;
                    result.setPatternScore(patternScore);
                    result.setPatternMatch("Y");
                    totalScore = calculateTotalScore(metaScore, patternScore, aiScore, enableMeta, enablePattern, enableAI);
                    result.setScore(totalScore);
                }
                // NOT_PII → ENCRYPTED_PII로 유형 변경
                if ("NOT_PII".equals(result.getPiiTypeCode())) {
                    result.setPiiTypeCode("ENCRYPTED_PII");
                    result.setPiiTypeName("암호화 PII");
                }
                result.setConfirmStatus("PENDING");
            }
        } else {
            result.setEncryptionStatus("NONE");
            result.setEncryptionRatio(0);
        }

        return result;
    }

    /**
     * 샘플 데이터 제한 (최대 N건만 저장)
     */
    private String limitSampleData(String sampleData, int maxCount) {
        if (sampleData == null || sampleData.isEmpty()) {
            return null;
        }
        String[] samples = sampleData.split("\n");
        StringBuilder result = new StringBuilder();
        int count = 0;
        for (String sample : samples) {
            if (sample == null || sample.trim().isEmpty()) continue;
            if (count >= maxCount) break;

            if (count > 0) result.append("\n");
            result.append(sample.trim());
            count++;
        }
        return result.toString();
    }

    /**
     * 총점 계산 (Weight 재분배 + 강력 매칭 보정)
     *
     * 설계 원칙:
     * 1. 적용된 방법만으로 Weight 재분배 (100%로 정규화)
     * 2. 강력 매칭 보정: 어느 하나라도 90% 이상이면 최소 80% 보장
     *
     * @param metaScore 메타데이터 점수 (0-100)
     * @param patternScore 패턴 매칭 점수 (0-100)
     * @param aiScore AI 점수 (0-100)
     * @param enableMeta 메타데이터 분석 활성화 여부
     * @param enablePattern 패턴 매칭 활성화 여부
     * @param enableAI AI 분석 활성화 여부
     */
    private int calculateTotalScore(int metaScore, int patternScore, int aiScore,
                                    boolean enableMeta, boolean enablePattern, boolean enableAI) {
        // 1. Weight 설정 로드
        loadWeightConfig();

        // 2. 활성화된 방법의 총 Weight 계산
        int totalEnabledWeight = 0;
        if (enableMeta) totalEnabledWeight += weightMeta;
        if (enablePattern) totalEnabledWeight += weightPattern;
        if (enableAI) totalEnabledWeight += weightAI;

        // 활성화된 방법이 없으면 0
        if (totalEnabledWeight == 0) {
            return 0;
        }

        // 3. Weight 재분배하여 점수 계산
        double normalizedScore = 0;
        if (enableMeta) {
            normalizedScore += metaScore * ((double) weightMeta / totalEnabledWeight);
        }
        if (enablePattern) {
            normalizedScore += patternScore * ((double) weightPattern / totalEnabledWeight);
        }
        if (enableAI) {
            normalizedScore += aiScore * ((double) weightAI / totalEnabledWeight);
        }

        int finalScore = (int) Math.round(normalizedScore);

        // 4. 강력 매칭 보정: 어느 하나라도 90% 이상이면 최소 80% 보장
        int maxSingleScore = Math.max(metaScore, Math.max(patternScore, aiScore));
        if (maxSingleScore >= 90 && finalScore < 80) {
            finalScore = 80;
            logger.debug("Strong match correction applied: single score {} >= 90, adjusted to {}", maxSingleScore, finalScore);
        }

        return Math.min(100, finalScore);
    }

    /**
     * Weight 설정 로드 (캐시)
     */
    private synchronized void loadWeightConfig() {
        long now = System.currentTimeMillis();
        if ((now - weightCacheTime) > CACHE_TTL) {
            try {
                List<DiscoveryConfigVO> configs = mapper.selectConfigList();
                for (DiscoveryConfigVO config : configs) {
                    if ("weight.metadata".equals(config.getConfigKey())) {
                        weightMeta = Integer.parseInt(config.getConfigValue());
                    } else if ("weight.pattern".equals(config.getConfigKey())) {
                        weightPattern = Integer.parseInt(config.getConfigValue());
                    } else if ("weight.ai".equals(config.getConfigKey())) {
                        weightAI = Integer.parseInt(config.getConfigValue());
                    } else if ("llm.api.url".equals(config.getConfigKey())) {
                        privacyAiUrl = config.getConfigValue();
                    } else if ("llm.enabled".equals(config.getConfigKey())) {
                        privacyAiEnabled = "Y".equals(config.getConfigValue());
                    }
                }
                weightCacheTime = now;
                logger.debug("Loaded weight config: meta={}, pattern={}, ai={}", weightMeta, weightPattern, weightAI);
            } catch (Exception e) {
                logger.warn("Failed to load weight config, using defaults", e);
            }
        }
    }

    /**
     * 총점 계산 (하위 호환성 - enableAI=false)
     */
    private int calculateTotalScore(int metaScore, int patternScore, int aiScore) {
        // 기본: Meta, Pattern 활성화, AI 비활성화
        return calculateTotalScore(metaScore, patternScore, aiScore, true, true, false);
    }

    /**
     * AI PII 탐지 배치 호출 (테이블 단위)
     * 모든 대상 컬럼의 메타+샘플을 모아서 Privacy-AI에 한 번에 전송
     *
     * @param tableName 테이블명
     * @param schemaName 스키마명
     * @param targetColumns 대상 컬럼 리스트
     * @param streamingResults 스트리밍 매칭 결과 (샘플 데이터 포함)
     * @param sampleDataMap 샘플 데이터 맵 (non-streaming 버전용, null 가능)
     * @return 컬럼명 → AiDetectResult 매핑. 실패 시 빈 Map
     */
    private Map<String, PrivacyAiClient.AiDetectResult> callAiDetect(
            String tableName, String schemaName, List<ColumnInfo> targetColumns,
            Map<String, StreamingMatchResult> streamingResults,
            Map<String, String> sampleDataMap) {

        loadWeightConfig(); // privacyAiUrl, privacyAiEnabled 갱신

        if (!privacyAiEnabled || privacyAiUrl == null || privacyAiUrl.isEmpty()) {
            return Collections.emptyMap();
        }

        List<PrivacyAiClient.ColumnDetectInfo> columnInfos = new ArrayList<>();
        for (ColumnInfo col : targetColumns) {
            List<String> samples = new ArrayList<>();

            // 1. 스트리밍 결과에서 샘플 추출
            if (streamingResults != null && streamingResults.containsKey(col.columnName)) {
                samples = streamingResults.get(col.columnName).sampleValues;
            }
            // 2. sampleDataMap에서 샘플 추출 (non-streaming 버전)
            else if (sampleDataMap != null && sampleDataMap.containsKey(col.columnName)) {
                String raw = sampleDataMap.get(col.columnName);
                if (raw != null && !raw.isEmpty()) {
                    String[] parts = raw.split("\n");
                    for (int i = 0; i < Math.min(parts.length, 5); i++) {
                        if (parts[i] != null && !parts[i].trim().isEmpty()) {
                            samples.add(parts[i].trim());
                        }
                    }
                }
            }

            columnInfos.add(new PrivacyAiClient.ColumnDetectInfo(
                    col.columnName, col.dataType,
                    col.columnComment != null ? col.columnComment : "",
                    samples));
        }

        return privacyAiClient.detectPii(privacyAiUrl, tableName, schemaName, columnInfos);
    }

    /**
     * 샘플 데이터 조회
     */
    private String getSampleData(Connection conn, String dbProductName, String schema, String tableName, String columnName, Integer sampleSize) {
        StringBuilder sb = new StringBuilder();
        int size = sampleSize != null ? sampleSize : 100;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            String fullTableName = schema != null ?
                    escapeIdentifier(schema, dbProductName) + "." + escapeIdentifier(tableName, dbProductName) :
                    escapeIdentifier(tableName, dbProductName);
            String escapedColName = escapeIdentifier(columnName, dbProductName);

            String sql;
            String selectPart = "SELECT " + escapedColName + " FROM " + fullTableName +
                    " WHERE " + escapedColName + " IS NOT NULL";
            if (dbProductName.contains("ORACLE") || dbProductName.contains("TIBERO")) {
                sql = selectPart + " AND ROWNUM <= " + size;
            } else if (dbProductName.contains("SQL SERVER") || dbProductName.contains("MICROSOFT")) {
                sql = "SELECT TOP " + size + " " + escapedColName + " FROM " + fullTableName +
                        " WHERE " + escapedColName + " IS NOT NULL";
            } else if (dbProductName.contains("DB2")) {
                sql = selectPart + " FETCH FIRST " + size + " ROWS ONLY";
            } else {
                sql = selectPart + " LIMIT " + size;
            }

            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                String value = rs.getString(1);
                if (value != null && !value.isEmpty()) {
                    sb.append(value).append("\n");
                }
            }
        } catch (SQLException e) {
            logger.debug("Error getting sample data: " + e.getMessage());
        } finally {
            closeResultSet(rs);
            closeStatement(stmt);
        }

        return sb.toString();
    }

    /**
     * 식별자 이스케이프 (ANSI SQL 기본 - Oracle, PostgreSQL 등)
     */
    private String escapeIdentifier(String identifier) {
        return "\"" + identifier.replace("\"", "\"\"") + "\"";
    }

    /**
     * DB 타입에 맞는 식별자 이스케이프
     * MySQL/MariaDB는 backtick, 나머지는 double quote (ANSI SQL)
     */
    private String escapeIdentifier(String identifier, String dbProductName) {
        if (dbProductName != null &&
            (dbProductName.contains("MYSQL") || dbProductName.contains("MARIADB"))) {
            return "`" + identifier.replace("`", "``") + "`";
        }
        return "\"" + identifier.replace("\"", "\"\"") + "\"";
    }

    /**
     * 텍스트 타입 여부 확인
     */
    private boolean isTextType(String dataType) {
        if (dataType == null) return false;
        String upper = dataType.toUpperCase();
        return upper.contains("CHAR") || upper.contains("TEXT") || upper.contains("STRING");
    }

    /**
     * 탐지 규칙 로드 (캐시)
     */
    private synchronized List<DiscoveryRuleVO> loadRules() {
        long now = System.currentTimeMillis();
        if (cachedRules == null || (now - cacheTime) > CACHE_TTL) {
            Criteria cri = new Criteria();
            cri.setAmount(1000);
            cachedRules = mapper.selectRuleList(cri);
            cacheTime = now;
        }
        return cachedRules;
    }

    /**
     * PII 유형명 조회
     */
    private String getPiiTypeName(String piiTypeCode) {
        if (piiTypeCode == null) return null;
        DiscoveryPiiTypeVO type = mapper.selectPiiType(piiTypeCode);
        return type != null ? type.getPiiTypeName() : piiTypeCode;
    }

    /**
     * 연결 종료
     */
    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.debug("Error closing connection", e);
            }
        }
    }

    /**
     * ResultSet 종료
     */
    private void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.debug("Error closing ResultSet", e);
            }
        }
    }

    /**
     * Statement 종료
     */
    private void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.debug("Error closing Statement", e);
            }
        }
    }

    /**
     * 오래된 스캔 결과 정리 (최근 N회만 유지)
     */
    private void cleanupOldResults(String jobId, int keepCount) {
        try {
            LogUtil.log("INFO", "Cleaning up old scan results for job: " + jobId + ", keeping last " + keepCount);

            // 오래된 Execution ID 목록 조회
            List<String> oldExecutionIds = mapper.selectOldExecutionIds(jobId, keepCount);

            if (oldExecutionIds == null || oldExecutionIds.isEmpty()) {
                LogUtil.log("DEBUG", "No old executions to cleanup for job: " + jobId);
                return;
            }

            int totalDeleted = 0;
            for (String executionId : oldExecutionIds) {
                // 테이블 스캔 완료 기록 삭제
                mapper.deleteTableScanComplete(executionId);

                // 스캔 결과 삭제
                int deleted = mapper.deleteScanResultByExecutionId(executionId);
                totalDeleted += deleted;

                // Execution 삭제
                mapper.deleteExecution(executionId);
            }

            LogUtil.log("INFO", "Cleanup completed: deleted " + totalDeleted + " results, " + oldExecutionIds.size() + " executions");

        } catch (Exception e) {
            logger.error("Failed to cleanup old results for job: " + jobId, e);
        }
    }

}
