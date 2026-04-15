-- ============================================================
-- ORDER 관련 테이블 상태 조회/변경 SQL 모음
-- 용도: 실행 Order의 상태를 확인하고 수동으로 변경할 때 사용
-- ============================================================

-- ★ 대상 ORDERID를 변경하세요
-- @ORDERID = '20260317_001'


-- ============================================================
-- [1] 현재 상태 조회
-- ============================================================

-- 1-1. Order (Job 실행 단위)
SELECT orderid, jobid, version, jobname, status, confirmflag, holdflag, forceokflag, killflag,
       DATE_FORMAT(realstarttime,'%Y/%m/%d %H:%i:%s') AS realstarttime,
       DATE_FORMAT(realendtime,'%Y/%m/%d %H:%i:%s') AS realendtime,
       runningtime
FROM COTDL.TBL_PIIORDER
WHERE orderid = '20260317_001';

-- 1-2. Order Step (Step 실행 단위)
SELECT orderid, stepid, stepname, steptype, status, confirmflag, holdflag, forceokflag, killflag,
       totaltabcnt, successtabcnt, runningtime,
       DATE_FORMAT(realstarttime,'%Y/%m/%d %H:%i:%s') AS realstarttime,
       DATE_FORMAT(realendtime,'%Y/%m/%d %H:%i:%s') AS realendtime
FROM COTDL.TBL_PIIORDERSTEP
WHERE orderid = '20260317_001'
ORDER BY stepseq;

-- 1-3. Order Step Table (테이블 실행 단위)
SELECT orderid, stepid, db, owner, table_name, status, forceokflag,
       arccnt, arctime, execnt, exetime, sqlmsg,
       DATE_FORMAT(arcstart,'%Y/%m/%d %H:%i:%s') AS arcstart,
       DATE_FORMAT(exestart,'%Y/%m/%d %H:%i:%s') AS exestart,
       DATE_FORMAT(exeend,'%Y/%m/%d %H:%i:%s') AS exeend
FROM COTDL.TBL_PIIORDERSTEPTABLE
WHERE orderid = '20260317_001'
ORDER BY stepid, seq1, seq2, seq3;


-- ============================================================
-- [2] TBL_PIIORDER 상태 변경
-- ============================================================
-- Status 값: 'Wait condition' | 'Ended OK' | 'Ended Not OK' | 'Recovered' | 'Hold'

-- 2-1. Ended OK (정상 완료 처리)
UPDATE COTDL.TBL_PIIORDER SET status = 'Ended OK' WHERE orderid = '20260317_001';

-- 2-2. Ended Not OK (에러 처리)
UPDATE COTDL.TBL_PIIORDER SET status = 'Ended Not OK' WHERE orderid = '20260317_001';

-- 2-3. Recovered (복구 처리 - 재실행 대상에서 제외)
UPDATE COTDL.TBL_PIIORDER SET status = 'Recovered' WHERE orderid = '20260317_001';

-- 2-4. Wait condition (대기 상태로 되돌리기)
UPDATE COTDL.TBL_PIIORDER SET status = 'Wait condition' WHERE orderid = '20260317_001';

-- 2-5. Hold (보류)
UPDATE COTDL.TBL_PIIORDER SET status = 'Hold' WHERE orderid = '20260317_001';


-- ============================================================
-- [3] TBL_PIIORDERSTEP 상태 변경
-- ============================================================
-- Status 값: 'Wait condition' | 'Ended OK' | 'Ended not OK' | 'Hold'

-- 3-1. 특정 Step만 Ended OK 처리
UPDATE COTDL.TBL_PIIORDERSTEP
   SET status = 'Ended OK'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01';

-- 3-2. 특정 Step만 Wait condition으로 되돌리기 (재실행)
UPDATE COTDL.TBL_PIIORDERSTEP
   SET status = 'Wait condition'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01';

-- 3-3. 전체 Step을 Ended OK 처리
UPDATE COTDL.TBL_PIIORDERSTEP
   SET status = 'Ended OK'
 WHERE orderid = '20260317_001';

-- 3-4. killflag 해제 (kill 후 재시작 시)
UPDATE COTDL.TBL_PIIORDERSTEP
   SET killflag = 'N'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01';


-- ============================================================
-- [4] TBL_PIIORDERSTEPTABLE 상태 변경
-- ============================================================
-- Status 값: 'Wait condition' | 'Ended OK' | 'Ended not OK' | 'Running'

-- 4-1. 특정 테이블만 Ended OK 처리
UPDATE COTDL.TBL_PIIORDERSTEPTABLE
   SET status = 'Ended OK'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01'
   AND owner = 'SCHEMA1' AND table_name = 'TABLE1';

-- 4-2. 특정 테이블만 Wait condition으로 되돌리기 (재실행)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE
   SET status = 'Wait condition'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01'
   AND owner = 'SCHEMA1' AND table_name = 'TABLE1';

-- 4-3. 에러난 테이블만 전부 Wait condition으로 (재실행 대상으로)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE
   SET status = 'Wait condition'
 WHERE orderid = '20260317_001'
   AND status = 'Ended not OK';

-- 4-4. forceokflag 설정 (강제 OK 처리)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE
   SET forceokflag = 'Y'
 WHERE orderid = '20260317_001' AND stepid = 'STEP01'
   AND owner = 'SCHEMA1' AND table_name = 'TABLE1';


-- ============================================================
-- [5] 복합 시나리오 (자주 쓰는 운영 작업)
-- ============================================================

-- 5-1. 에러난 Order를 통째로 재실행 가능 상태로 되돌리기
--      (Order + Step + StepTable 모두 Wait condition)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE SET status = 'Wait condition' WHERE orderid = '20260317_001' AND status != 'Ended OK';
UPDATE COTDL.TBL_PIIORDERSTEP      SET status = 'Wait condition' WHERE orderid = '20260317_001' AND status != 'Ended OK';
UPDATE COTDL.TBL_PIIORDER          SET status = 'Wait condition' WHERE orderid = '20260317_001';
COMMIT;

-- 5-2. 에러난 Order를 강제 정상 완료 처리
--      (Order + Step + StepTable 모두 Ended OK)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE SET status = 'Ended OK' WHERE orderid = '20260317_001';
UPDATE COTDL.TBL_PIIORDERSTEP      SET status = 'Ended OK' WHERE orderid = '20260317_001';
UPDATE COTDL.TBL_PIIORDER          SET status = 'Ended OK' WHERE orderid = '20260317_001';
COMMIT;

-- 5-3. Kill 후 Recovered 처리 (재실행 대상에서 완전히 제외)
UPDATE COTDL.TBL_PIIORDERSTEPTABLE SET status = 'Ended OK'  WHERE orderid = '20260317_001';
UPDATE COTDL.TBL_PIIORDERSTEP      SET status = 'Ended OK', killflag = 'N' WHERE orderid = '20260317_001';
UPDATE COTDL.TBL_PIIORDER          SET status = 'Recovered', killflag = 'N' WHERE orderid = '20260317_001';
COMMIT;
