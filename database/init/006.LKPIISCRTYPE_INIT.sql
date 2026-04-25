-- ============================================================
-- DLM_LKPIISCRTYPE_INIT : 개인정보 유형별 스크램블 정책 초기 데이터
-- ============================================================
-- 개인정보보호법 기준 등급별(1급/2급/3급) 개인정보 유형과
-- 각 유형에 대한 비식별화(스크램블) 방식을 정의하는 룩업 테이블 초기 데이터.
--
-- [등급 체계]
--   1급 : 생명·신체 위해 우려 정보, 민감정보, 인증정보, 신용/금융정보, 의료정보, 위치정보
--   2급 : 개인식별정보, 연락정보, 개인관련정보
--   3급 : 자동생성정보, 가공정보, 제한적 본인식별정보
--
-- [스크램블 방식]
--   SCRAMBLE : 일부/전체 문자를 랜덤 치환 (NORMAL, RRN, YYMMDD, EMAIL, CORPNO 등)
--   FIXED    : 고정값으로 대체 (*, 1111 등)
--   PASS     : 변환하지 않고 통과
--
-- [암호화 설정 (ENCDECFUNCTYPE = 'DB')]
--   ENCFUNC / DECFUNC 컬럼에 DB 함수 지정 시 암복호화 적용
--   예: cotdl.encrypt(#COLNAME) / cotdl.decrypt(#COLNAME)
--
-- ============================================================
-- 사이트별 배포 시 아래 변수를 해당 사이트 값으로 치환(Replace All)하세요.
--
--   COTDL  -> DLM 스키마명  (기본값: COTDL)
-- ============================================================


-- 기존 데이터 삭제 (초기화 용도)
DELETE FROM COTDL.TBL_LKPIISCRTYPE;


-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹1: 생명·신체에 중대한 위해를 초래할 우려가 있는 정보
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('1_1_driverLicense',1,'1급',1,'생명·신체에 중대한 위해를 초래할 우려가 있는 정보','driverLicense','운전면허번호','SCRAMBLE_NORMAL_AFTER3','SCRAMBLE','NORMAL','AFTER3','','',NULL,NULL,NULL),
	 ('1_1_governmentID',1,'1급',1,'생명·신체에 중대한 위해를 초래할 우려가 있는 정보','governmentID','공무원증번호','SCRAMBLE_NORMAL_AFTER3','SCRAMBLE','NORMAL','AFTER3','','',NULL,NULL,NULL),
	 ('1_1_passport',1,'1급',1,'생명·신체에 중대한 위해를 초래할 우려가 있는 정보','passport','여권번호','SCRAMBLE_NORMAL_AFTER2','SCRAMBLE','NORMAL','AFTER2','','',NULL,NULL,NULL),
	 ('1_1_rrn',1,'1급',1,'생명·신체에 중대한 위해를 초래할 우려가 있는 정보','rrn','주민/외국인등록번호','SCRAMBLE_RRN_AFTER7','SCRAMBLE','RRN','AFTER7','RRN','ALL, AFTER7 선택 가능','DB','COTDL.encrypt(#COLNAME)','COTDL.decrypt(#COLNAME)'),
-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹2: 민감정보
-- ────────────────────────────────────────────────────────────
	 ('1_2_beliefs',1,'1급',2,'민감정보','beliefs','사상ㆍ신념','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_2_criminalHistory',1,'1급',2,'민감정보','criminalHistory','범죄 경력정보','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_2_geneticInfo',1,'1급',2,'민감정보','geneticInfo','유전자 검사정보','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_2_health',1,'1급',2,'민감정보','health','건강','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_2_politicalViews',1,'1급',2,'민감정보','politicalViews','정치적 견해','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_2_sexualOrientation',1,'1급',2,'민감정보','sexualOrientation','성적취향','FIXED_*','FIXED','*','','','',NULL,NULL,NULL);
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('1_2_unionParty',1,'1급',2,'민감정보','unionParty','노동조합ㆍ정당의 가입ㆍ탈퇴','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹3: 인증정보
-- ────────────────────────────────────────────────────────────
	 ('1_3_biometrics',1,'1급',3,'인증정보','biometrics','바이오정보(홍체,  지문 등)','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_3_pwd',1,'1급',3,'인증정보','pwd','비밀번호','FIXED_1111','FIXED','1111','','','','DB','COTDL.encrypt(#COLNAME)','COTDL.decrypt(#COLNAME)'),
-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹4: 신용정보/금융정보
-- ────────────────────────────────────────────────────────────
	 ('1_4_account',1,'1급',4,'신용정보/금융정보','account','계좌번호','SCRAMBLE_NORMAL_LAST8','SCRAMBLE','NORMAL','LAST8','','','DB','COTDL.encrypt(#COLNAME)','COTDL.decrypt(#COLNAME)'),
	 ('1_4_cardExpiration',1,'1급',4,'신용정보/금융정보','cardExpiration','카드유효년월','FIXED_11/11','FIXED','11/11','','','',NULL,NULL,NULL),
	 ('1_4_cardReplacement',1,'1급',4,'신용정보/금융정보','cardReplacement','카드대체번호','SCRAMBLE_NORMAL_LAST8','SCRAMBLE','NORMAL','LAST8','','',NULL,NULL,NULL),
	 ('1_4_creditCard',1,'1급',4,'신용정보/금융정보','creditCard','신용카드번호','SCRAMBLE_NORMAL_LAST8','SCRAMBLE','NORMAL','LAST8','','',NULL,NULL,NULL),
	 ('1_4_cvv',1,'1급',4,'신용정보/금융정보','cvv','CVV/PVV/ICVV/ICVC','FIXED_111','FIXED','111','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹5: 의료정보
-- ────────────────────────────────────────────────────────────
	 ('1_5_healthStatus',1,'1급',5,'의료정보','healthStatus','건강상태','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('1_5_medicalRecords',1,'1급',5,'의료정보','medicalRecords','진료기록','FIXED_*','FIXED','*','','','',NULL,NULL,NULL);
-- ────────────────────────────────────────────────────────────
-- 1급 - 그룹6: 위치정보
-- ────────────────────────────────────────────────────────────
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('1_6_location',1,'1급',6,'위치정보','location','개인 위치 정보','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 2급 - 그룹1: 개인식별정보
-- ────────────────────────────────────────────────────────────
	 ('2_1_age',2,'2급',1,'개인식별정보','age','연령','PASS_-','PASS','-','','','숫자로 변환해야','','',''),
	 ('2_1_cidi',2,'2급',1,'개인식별정보','cidi','CI/DI','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('2_1_dob',2,'2급',1,'개인식별정보','dob','생년월일','SCRAMBLE_YYMMDD_ALL','SCRAMBLE','YYMMDD','ALL','','',NULL,NULL,NULL),
	 ('2_1_gender',2,'2급',1,'개인식별정보','gender','성별','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_1_name',2,'2급',1,'개인식별정보','name','성명(개인/법인)','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 2급 - 그룹2: 연락정보
-- ────────────────────────────────────────────────────────────
	 ('2_2_address1',2,'2급',2,'연락정보','address1','주소 상(행정구역)','PASS_','PASS','','','','',NULL,NULL,NULL),
	 ('2_2_address2',2,'2급',2,'연락정보','address2','주소 하(상세영역)','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('2_2_email',2,'2급',2,'연락정보','email','이메일','SCRAMBLE_EMAIL_ALL','SCRAMBLE','EMAIL','ALL','','@ 이전까지 변환','DB','COTDL.encrypt(#COLNAME)','COTDL.decrypt(#COLNAME)'),
	 ('2_2_telno',2,'2급',2,'연락정보','telno','전화번호','SCRAMBLE_NORMAL_LAST7','SCRAMBLE','NORMAL','LAST7','','',NULL,NULL,NULL);
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('2_2_zipcode',2,'2급',2,'연락정보','zipcode','우편번호','PASS_','PASS','','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 2급 - 그룹3: 개인관련정보
-- ────────────────────────────────────────────────────────────
	 ('2_3_education',2,'2급',3,'개인관련정보','education','학력','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_familyStatus',2,'2급',3,'개인관련정보','familyStatus','가족상황','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_height',2,'2급',3,'개인관련정보','height','키','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_hobbies',2,'2급',3,'개인관련정보','hobbies','취미','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_job',2,'2급',3,'개인관련정보','job','직업','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_maritalStatus',2,'2급',3,'개인관련정보','maritalStatus','혼인여부','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_photo',2,'2급',3,'개인관련정보','photo','사진','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('2_3_weight',2,'2급',3,'개인관련정보','weight','몸무게','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 3급 - 그룹1: 자동 생성 정보
-- ────────────────────────────────────────────────────────────
	 ('3_1_cookies',3,'3급',1,'자동 생성 정보','cookies','쿠키','FIXED_*','FIXED','*','','','',NULL,NULL,NULL);
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('3_1_imei',3,'3급',1,'자동 생성 정보','imei','IMEI','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('3_1_ipAddress',3,'3급',1,'자동 생성 정보','ipAddress','IP 주소','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('3_1_macAddress',3,'3급',1,'자동 생성 정보','macAddress','MAC 주소','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('3_1_usim',3,'3급',1,'자동 생성 정보','usim','USIM','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('3_1_uuid',3,'3급',1,'자동 생성 정보','uuid','UUID','SCRAMBLE_NORMAL_ALL','SCRAMBLE','NORMAL','ALL','','',NULL,NULL,NULL),
	 ('3_1_websiteHistory',3,'3급',1,'자동 생성 정보','websiteHistory','사이트 방문 기록','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 3급 - 그룹2: 가공정보
-- ────────────────────────────────────────────────────────────
	 ('3_2_membershipInfo',3,'3급',2,'가공정보','membershipInfo','가입자 성향','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
	 ('3_2_statistics',3,'3급',2,'가공정보','statistics','통계성 정보','FIXED_*','FIXED','*','','','',NULL,NULL,NULL),
-- ────────────────────────────────────────────────────────────
-- 3급 - 그룹3: 제한적 본인 식별정보
-- ────────────────────────────────────────────────────────────
	 ('3_3_corpno',3,'3급',3,'제한적 본인 식별정보','corpno','법인번호','SCRAMBLE_CORPNO_ALL','SCRAMBLE','CORPNO','ALL','','','DB','COTDL.encrypt(#COLNAME)','COTDL.decrypt(#COLNAME)'),
	 ('3_3_employeeID',3,'3급',3,'제한적 본인 식별정보','employeeID','사번','SCRAMBLE_NORMAL_AFTER2','SCRAMBLE','NORMAL','AFTER2','','',NULL,NULL,NULL);
INSERT INTO COTDL.TBL_LKPIISCRTYPE (PIICODE,PIIGRADEID,PIIGRADENAME,PIIGROUPID,PIIGROUPNAME,PIITYPEID,PIITYPENAME,SCRTYPE,SCRMETHOD,SCRCATEGORY,SCRDIGITS,SCRVALIDITY,REMARKS,ENCDECFUNCTYPE,ENCFUNC,DECFUNC) VALUES
	 ('3_3_internalID',3,'3급',3,'제한적 본인 식별정보','internalID','내부용 개인식별정보','SCRAMBLE_NORMAL_AFTER2','SCRAMBLE','NORMAL','AFTER2','','',NULL,NULL,NULL),
	 ('3_3_memberID',3,'3급',3,'제한적 본인 식별정보','memberID','회원번호','SCRAMBLE_NORMAL_AFTER2','SCRAMBLE','NORMAL','AFTER2','','',NULL,NULL,NULL);


COMMIT;