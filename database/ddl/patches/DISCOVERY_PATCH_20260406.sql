-- ============================================================
-- Discovery 모듈 패치: DLM PIICODE 체계 정렬 + 규칙 보강
-- ============================================================
-- 적용 대상: 기존 운영 환경 (Discovery 테이블이 이미 존재하는 경우)
-- 적용 날짜: 2026-04-06
-- 적용 순서: 이 파일 하나만 실행하면 됩니다.
--
-- [변경 내용]
-- 1. TBL_LKPIISCRTYPE: 1_2_criminalHistory PIIGROUPNAME 수정 ('인증정보'→'민감정보')
-- 2. pii_type_code 컬럼 VARCHAR(20) → VARCHAR(50) 확장
--    - DLM PIICODE(예: 1_2_sexualOrientation=22자) 수용을 위해 확장
--    - 대상: TBL_DISCOVERY_PII_TYPE, TBL_DISCOVERY_RULE, TBL_DISCOVERY_SCAN_RESULT
-- 3. PII Type Master를 DLM PIICODE 체계로 전면 교체 (51개 유형)
-- 4. Detection Rules을 DLM 체계 + 한국 금융사 표준으로 전면 교체
--    - META 규칙 41개 (컬럼명/코멘트 키워드)
--    - PATTERN 규칙 33개 (정규식 데이터 매칭)
-- 5. 카테고리 체계 변경 (6개→11개)
--    - 변경전: NAME, SSN, CONTACT, FINANCIAL, ADDRESS, CUSTOM
--    - 변경후: ID, SENSITIVE, AUTH, FINANCIAL, MEDICAL, PERSONAL,
--             CONTACT, PRIVATE, AUTO, LIMITED_ID, CUSTOM
--
-- [주의]
-- - 기존 스캔 결과(TBL_DISCOVERY_SCAN_RESULT)의 pii_type_code는
--   이전 코드(RRN, NAME 등)로 저장되어 있으므로 기존 결과 조회 시 참고
-- - 필요 시 섹션 5의 UPDATE문으로 기존 결과의 코드를 마이그레이션 가능
-- ============================================================


-- ============================================================
-- 1. DLM 마스터 데이터 수정: TBL_LKPIISCRTYPE
-- ============================================================
-- 1_2_criminalHistory의 PIIGROUPNAME이 '인증정보'로 잘못 등록 → '민감정보'로 수정
UPDATE COTDL.TBL_LKPIISCRTYPE SET PIIGROUPNAME = '민감정보' WHERE PIICODE = '1_2_criminalHistory';


-- ============================================================
-- 2. DDL 변경: pii_type_code VARCHAR(20) → VARCHAR(50)
-- ============================================================
ALTER TABLE COTDL.TBL_DISCOVERY_PII_TYPE    MODIFY COLUMN pii_type_code VARCHAR(50) NOT NULL;
ALTER TABLE COTDL.TBL_DISCOVERY_RULE        MODIFY COLUMN pii_type_code VARCHAR(50);
ALTER TABLE COTDL.TBL_DISCOVERY_SCAN_RESULT MODIFY COLUMN pii_type_code VARCHAR(50) NOT NULL;


-- ============================================================
-- 3. 기존 데이터 정리
-- ============================================================
DELETE FROM COTDL.TBL_DISCOVERY_RULE;
DELETE FROM COTDL.TBL_DISCOVERY_PII_TYPE;


-- ============================================================
-- 4. PII Type Master (DLM PIICODE 체계)
-- ============================================================
INSERT INTO COTDL.TBL_DISCOVERY_PII_TYPE
    (pii_type_code, pii_type_name, pii_type_name_en, category, description, scramble_type, sort_order) VALUES

-- ── 1급-그룹1: 고유식별정보 → ID ──
('1_1_rrn',             '주민/외국인등록번호',  'Resident Registration Number',  'ID',         '주민등록번호 13자리, 외국인등록번호',              'SCRAMBLE_RRN_AFTER7',       101),
('1_1_driverLicense',   '운전면허번호',         'Driver License Number',         'ID',         '운전면허번호 12자리',                              'SCRAMBLE_NORMAL_AFTER3',    102),
('1_1_passport',        '여권번호',             'Passport Number',               'ID',         '여권번호 (영문1+숫자8)',                            'SCRAMBLE_NORMAL_AFTER2',    103),
('1_1_governmentID',    '공무원증번호',         'Government Employee ID',        'ID',         '공무원증 번호',                                    'SCRAMBLE_NORMAL_AFTER3',    104),

-- ── 1급-그룹2: 민감정보 → SENSITIVE ──
('1_2_beliefs',         '사상·신념',            'Beliefs',                       'SENSITIVE',  '사상, 신념 관련 정보',                             'FIXED_*',                   111),
('1_2_politicalViews',  '정치적 견해',          'Political Views',               'SENSITIVE',  '정치적 견해, 정당 가입 등',                        'FIXED_*',                   112),
('1_2_health',          '건강',                 'Health Information',             'SENSITIVE',  '건강 상태 정보',                                   'FIXED_*',                   113),
('1_2_sexualOrientation','성적취향',            'Sexual Orientation',            'SENSITIVE',  '성적 취향 정보',                                   'FIXED_*',                   114),
('1_2_geneticInfo',     '유전자 검사정보',      'Genetic Information',           'SENSITIVE',  '유전자 검사 결과',                                 'FIXED_*',                   115),
('1_2_criminalHistory', '범죄 경력정보',        'Criminal History',              'SENSITIVE',  '범죄 전과 기록',                                   'FIXED_*',                   116),
('1_2_unionParty',      '노동조합·정당',        'Union/Party Membership',        'SENSITIVE',  '노동조합, 정당 가입/탈퇴 정보',                    'FIXED_*',                   117),

-- ── 1급-그룹3: 인증정보 → AUTH ──
('1_3_biometrics',      '바이오정보',           'Biometric Data',                'AUTH',       '홍체, 지문, 안면인식 등 바이오인증 정보',          'FIXED_*',                   121),
('1_3_pwd',             '비밀번호',             'Password',                      'AUTH',       '비밀번호, 인증번호, PIN',                          'FIXED_1111',                122),

-- ── 1급-그룹4: 금융정보 → FINANCIAL ──
('1_4_account',         '계좌번호',             'Account Number',                'FINANCIAL',  '은행 계좌번호',                                    'SCRAMBLE_NORMAL_LAST8',     131),
('1_4_creditCard',      '신용카드번호',         'Credit Card Number',            'FINANCIAL',  '신용카드, 체크카드 번호 16자리',                   'SCRAMBLE_NORMAL_LAST8',     132),
('1_4_cardReplacement', '카드대체번호',         'Card Replacement Number',       'FINANCIAL',  '카드 대체번호(토큰)',                              'SCRAMBLE_NORMAL_LAST8',     133),
('1_4_cardExpiration',  '카드유효년월',         'Card Expiration Date',          'FINANCIAL',  '카드 유효기간 (MM/YY)',                            'FIXED_11/11',               134),
('1_4_cvv',             'CVV/CVC',              'CVV/PVV/ICVV',                  'FINANCIAL',  'CVV, PVV, ICVV, ICVC 보안코드',                   'FIXED_111',                 135),

-- ── 1급-그룹5,6: 의료/위치정보 → MEDICAL ──
('1_5_medicalRecords',  '진료기록',             'Medical Records',               'MEDICAL',    '진료기록, 처방전, 진단서',                         'FIXED_*',                   141),
('1_5_healthStatus',    '건강상태',             'Health Status',                 'MEDICAL',    '건강진단 결과, 건강상태',                          'FIXED_*',                   142),
('1_6_location',        '개인 위치 정보',       'Location Data',                 'MEDICAL',    'GPS, 위도/경도 등 개인 위치 정보',                 'FIXED_*',                   151),

-- ── 2급-그룹1: 개인식별정보 → PERSONAL ──
('2_1_name',            '성명(개인/법인)',       'Name',                          'PERSONAL',   '성명 (개인/법인)',                                 'SCRAMBLE_NORMAL_ALL',       201),
('2_1_dob',             '생년월일',             'Date of Birth',                 'PERSONAL',   '생년월일 (YYYYMMDD)',                              'SCRAMBLE_YYMMDD_ALL',       202),
('2_1_gender',          '성별',                 'Gender',                        'PERSONAL',   '성별 코드',                                        'FIXED_*',                   203),
('2_1_age',             '연령',                 'Age',                           'PERSONAL',   '나이, 연령',                                       'PASS_-',                    204),
('2_1_cidi',            'CI/DI',                'CI/DI',                         'PERSONAL',   '연계정보(CI), 중복가입확인정보(DI)',               'SCRAMBLE_NORMAL_ALL',       205),

-- ── 2급-그룹2: 연락정보 → CONTACT ──
('2_2_telno',           '전화번호',             'Phone Number',                  'CONTACT',    '휴대폰, 유선전화, FAX 번호',                       'SCRAMBLE_NORMAL_LAST7',     211),
('2_2_email',           '이메일',               'Email Address',                 'CONTACT',    '이메일 주소',                                      'SCRAMBLE_EMAIL_ALL',        212),
('2_2_address1',        '주소 상(행정구역)',     'Address (Region)',              'CONTACT',    '주소 상 - 시/도/구/군 행정구역',                   'PASS_',                     213),
('2_2_address2',        '주소 하(상세영역)',     'Address (Detail)',              'CONTACT',    '주소 하 - 동/번지/아파트 상세주소',                'SCRAMBLE_NORMAL_ALL',       214),
('2_2_zipcode',         '우편번호',             'Zip Code',                      'CONTACT',    '우편번호',                                         'PASS_',                     215),

-- ── 2급-그룹3: 개인관련정보 → PRIVATE ──
('2_3_job',             '직업',                 'Occupation',                    'PRIVATE',    '직업, 직종',                                       'FIXED_*',                   221),
('2_3_education',       '학력',                 'Education',                     'PRIVATE',    '학력, 학교 정보',                                  'FIXED_*',                   222),
('2_3_maritalStatus',   '혼인여부',             'Marital Status',                'PRIVATE',    '혼인 상태',                                        'FIXED_*',                   223),
('2_3_familyStatus',    '가족상황',             'Family Status',                 'PRIVATE',    '가족관계, 부양가족 수 등',                         'FIXED_*',                   224),
('2_3_hobbies',         '취미',                 'Hobbies',                       'PRIVATE',    '취미, 관심사',                                     'FIXED_*',                   225),
('2_3_height',          '키',                   'Height',                        'PRIVATE',    '신장',                                             'FIXED_*',                   226),
('2_3_weight',          '몸무게',               'Weight',                        'PRIVATE',    '체중',                                             'FIXED_*',                   227),
('2_3_photo',           '사진',                 'Photo',                         'PRIVATE',    '증명사진, 프로필 사진',                            'FIXED_*',                   228),

-- ── 3급-그룹1,2: 자동생성/가공정보 → AUTO ──
('3_1_ipAddress',       'IP 주소',              'IP Address',                    'AUTO',       'IPv4/IPv6 주소',                                   'SCRAMBLE_NORMAL_ALL',       301),
('3_1_macAddress',      'MAC 주소',             'MAC Address',                   'AUTO',       '네트워크 MAC 주소',                                'SCRAMBLE_NORMAL_ALL',       302),
('3_1_imei',            'IMEI',                 'IMEI',                          'AUTO',       '단말기 고유번호',                                  'SCRAMBLE_NORMAL_ALL',       303),
('3_1_usim',            'USIM',                 'USIM',                          'AUTO',       'USIM 일련번호',                                    'SCRAMBLE_NORMAL_ALL',       304),
('3_1_uuid',            'UUID',                 'UUID',                          'AUTO',       'UUID 식별자',                                      'SCRAMBLE_NORMAL_ALL',       305),
('3_1_cookies',         '쿠키',                 'Cookie',                        'AUTO',       '쿠키 식별자',                                      'FIXED_*',                   306),
('3_1_websiteHistory',  '사이트 방문 기록',     'Website History',               'AUTO',       '웹사이트 방문 이력',                               'FIXED_*',                   307),
('3_2_membershipInfo',  '가입자 성향',          'Membership Profile',            'AUTO',       '가입자 성향 분석 정보',                            'FIXED_*',                   311),
('3_2_statistics',      '통계성 정보',          'Statistical Data',              'AUTO',       '가공된 통계 정보',                                 'FIXED_*',                   312),

-- ── 3급-그룹3: 제한적 식별정보 → LIMITED_ID ──
('3_3_corpno',          '법인번호',             'Corporate Number',              'LIMITED_ID', '법인번호 13자리',                                  'SCRAMBLE_CORPNO_ALL',       321),
('3_3_employeeID',      '사번',                 'Employee ID',                   'LIMITED_ID', '사원번호',                                         'SCRAMBLE_NORMAL_AFTER2',    322),
('3_3_internalID',      '내부용 개인식별정보',  'Internal Personal ID',          'LIMITED_ID', '내부용 고객/회원 식별키',                          'SCRAMBLE_NORMAL_AFTER2',    323),
('3_3_memberID',        '회원번호',             'Member ID',                     'LIMITED_ID', '회원번호, 고객번호',                               'SCRAMBLE_NORMAL_AFTER2',    324),

-- ── 시스템 ──
('NOT_PII',             'PII 아님',             'Not PII',                       'NONE',       'PII가 아닌 것으로 판단된 컬럼',                    NULL,                        999);


-- ============================================================
-- 5-A. Discovery Rules - META (컬럼명/코멘트 키워드 매칭)
-- ============================================================
INSERT INTO COTDL.TBL_DISCOVERY_RULE
    (rule_id, rule_name, rule_type, pii_type_code, category, pattern, description, weight, priority, status) VALUES

-- ── ID: 고유식별정보 (1급-그룹1) ──
(UUID(), '주민/외국인등록번호 컬럼',  'META', '1_1_rrn',           'ID',
 'SSN,JUMIN,RRN,RESIDENT,REG_NO,주민번호,주민등록,외국인등록,FOREIGNER_REG,주민,SOCIAL_SEC,NATL_ID,PERSONAL_ID,PERS_REG_NO,FRN_REG_NO,RES_REG_NO,RESIDENT_NO,IDNT_NO,IDEN_NO,식별번호,JUMIN_NO,RRN_NO,SSN_NO,CUST_RRN,CUST_JUMIN,ID_NO',
 '주민/외국인등록번호 관련 컬럼', 0.70, 10, 'ACTIVE'),

(UUID(), '운전면허번호 컬럼',         'META', '1_1_driverLicense', 'ID',
 'DRIVER,LICENSE,DRV_LIC,DL_NO,운전면허,면허번호,DRVR_LIC_NO,DRV_LICENSE,DRIVING_LIC,DL_NUM,DRIVER_NO,면허',
 '운전면허번호 관련 컬럼', 0.60, 10, 'ACTIVE'),

(UUID(), '여권번호 컬럼',             'META', '1_1_passport',      'ID',
 'PASSPORT,여권,PASS_NO,PASSPORT_NO,PSPRT_NO,PASS_NUM,PASSPORT_NUM,PPORT_NO,여권번호',
 '여권번호 관련 컬럼', 0.60, 10, 'ACTIVE'),

(UUID(), '공무원증번호 컬럼',         'META', '1_1_governmentID',  'ID',
 'GOV_ID,GOVT_NO,공무원증,공무원번호,GOVERNMENT_ID',
 '공무원증번호 관련 컬럼', 0.50, 10, 'ACTIVE'),

-- ── SENSITIVE: 민감정보 (1급-그룹2) ──
(UUID(), '사상·신념 컬럼',            'META', '1_2_beliefs',        'SENSITIVE',
 'BELIEF,RELIGION,종교,신념,사상,FAITH,신앙,교파',
 '사상, 신념, 종교 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '정치적 견해 컬럼',          'META', '1_2_politicalViews', 'SENSITIVE',
 'POLITICAL,POLITIC,정치,정당,PARTY_NM,정치성향,정당가입',
 '정치적 견해, 정당 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '건강 컬럼',                 'META', '1_2_health',         'SENSITIVE',
 'HEALTH,건강,DISEASE,질병,DIAGNOSIS,진단,DISABILITY,장애,장애등급,HANDICAP,DISORDER',
 '건강 상태 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '유전자 검사정보 컬럼',      'META', '1_2_geneticInfo',    'SENSITIVE',
 'GENETIC,유전자,DNA,GENE,GENOME,유전체,유전검사',
 '유전자 검사 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '범죄 경력정보 컬럼',        'META', '1_2_criminalHistory','SENSITIVE',
 'CRIMINAL,CRIME,범죄,전과,CONVICTION,OFFENSE,형사,ARREST,체포,구속',
 '범죄 경력 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '노동조합·정당 컬럼',        'META', '1_2_unionParty',     'SENSITIVE',
 'UNION,LABOR,노동조합,노조,PARTY_JOIN,정당가입,조합원,LABOR_UNION',
 '노동조합, 정당 가입 관련 컬럼', 0.50, 20, 'ACTIVE'),

-- ── AUTH: 인증정보 (1급-그룹3) ──
(UUID(), '바이오정보 컬럼',           'META', '1_3_biometrics',     'AUTH',
 'BIOMETRIC,FINGERPRINT,IRIS,FACE_ID,지문,홍체,안면,바이오,FIDO,VOICE_PRINT,성문,FACE_RECOG,안면인식,생체,PALM',
 '바이오인증 관련 컬럼', 0.60, 15, 'ACTIVE'),

(UUID(), '비밀번호 컬럼',             'META', '1_3_pwd',            'AUTH',
 'PASSWORD,PASSWD,PWD,비밀번호,암호,PIN,PIN_NO,OTP,SECRET,CREDENTIALS,AUTH_KEY,인증번호,PASSCODE,LOGIN_PW,USER_PW,USERPW,USER_PWD,SIGN_KEY,SECURE_KEY,인증키,LOGIN_PWD,ACCESS_KEY',
 '비밀번호, PIN, 인증정보 관련 컬럼', 0.70, 15, 'ACTIVE'),

-- ── FINANCIAL: 금융정보 (1급-그룹4) ──
(UUID(), '계좌번호 컬럼',             'META', '1_4_account',        'FINANCIAL',
 'ACCT,ACCOUNT,계좌,통장,BANK_ACCT,ACCT_NO,ACCTNO,DEPOSIT_NO,예금계좌,SAVING,출금계좌,ACNO,AC_NO,BANK_NO,BANKNO,WITHDRAW_ACCT,입금계좌,RECV_ACCT,SEND_ACCT,수취계좌,이체계좌,가상계좌,VIRTUAL_ACCT,DPST_ACCT,WDRL_ACCT,SETL_ACCT,LOAN_ACCT,대출계좌,결제계좌',
 '계좌번호 관련 컬럼', 0.60, 10, 'ACTIVE'),

(UUID(), '신용카드번호 컬럼',         'META', '1_4_creditCard',     'FINANCIAL',
 'CARD_NO,CARD_NUM,CARDNO,카드번호,신용카드,CREDIT_CARD,CHECK_CARD,체크카드,CARD_NUMBER,CDNO,CD_NO,PAN,DEBIT_CARD,직불카드,선불카드,PREPAID_CARD,CARD_ID,카드번',
 '카드번호 관련 컬럼', 0.60, 10, 'ACTIVE'),

(UUID(), '카드대체번호 컬럼',         'META', '1_4_cardReplacement','FINANCIAL',
 'TOKEN,CARD_TOKEN,CARD_REPLACE,대체번호,토큰,REPLACEMENT,TOKEN_NO,카드토큰',
 '카드 대체번호/토큰 관련 컬럼', 0.50, 10, 'ACTIVE'),

(UUID(), '카드유효년월 컬럼',         'META', '1_4_cardExpiration', 'FINANCIAL',
 'EXPIRY,EXPIRE,CARD_EXP,유효기간,유효년월,EXP_DATE,VALID_THRU,EXPIRATION,EXP_YM,유효월',
 '카드 유효기간 관련 컬럼', 0.50, 10, 'ACTIVE'),

(UUID(), 'CVV/CVC 컬럼',             'META', '1_4_cvv',            'FINANCIAL',
 'CVV,CVC,PVV,ICVV,ICVC,보안코드,SECURITY_CODE,SEC_CODE,CVV2,CVC2,카드보안',
 'CVV/CVC 보안코드 관련 컬럼', 0.70, 10, 'ACTIVE'),

-- ── MEDICAL: 의료/위치정보 (1급-그룹5,6) ──
(UUID(), '진료기록 컬럼',             'META', '1_5_medicalRecords', 'MEDICAL',
 'MEDICAL,TREATMENT,진료,처방,PRESCRIPTION,진단서,DIAGNOSIS_RECORD,병원,HOSPITAL,CLINIC,의료,수술,SURGERY,입원,ADMISSION,외래,OUTPATIENT',
 '진료기록 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '건강상태 컬럼',             'META', '1_5_healthStatus',   'MEDICAL',
 'HEALTH_STATUS,건강상태,건강진단,CHECKUP,PHYSICAL_EXAM,검진결과,BMI,혈압,BLOOD_PRESSURE,혈당,건강검진,HEALTH_CHECK',
 '건강상태/검진 관련 컬럼', 0.50, 20, 'ACTIVE'),

(UUID(), '위치정보 컬럼',             'META', '1_6_location',       'MEDICAL',
 'GPS,LATITUDE,LONGITUDE,위도,경도,위치,LOCATION,COORD,LAT,LNG,LON,GEOLOCATION,GEO_X,GEO_Y,좌표',
 '위치정보 관련 컬럼', 0.50, 20, 'ACTIVE'),

-- ── PERSONAL: 개인식별정보 (2급-그룹1) ──
(UUID(), '성명 컬럼',                 'META', '2_1_name',           'PERSONAL',
 'NAME,NM,성명,이름,고객명,사용자명,CUST_NM,USER_NM,EMP_NM,FULL_NAME,KOR_NM,ENG_NM,한글명,영문명,PERSON_NM,담당자명,수취인명,예금주명,DEPOSITOR,FIRST_NM,LAST_NM,FAMILY_NM,GIVEN_NM,사원명,대표자명,REPR_NM,차주명,보증인명,CORP_NM,COMP_NM,INSURED_NM,BENEFICIARY_NM,SURNAME,성,법인명,회사명,OWNER_NM,소유자명,피보험자명,수익자명',
 '성명 관련 컬럼', 0.50, 10, 'ACTIVE'),

(UUID(), '생년월일 컬럼',             'META', '2_1_dob',            'PERSONAL',
 'BIRTH,DOB,BIRTHDAY,생년월일,생일,BIRTH_DATE,BIRTHDATE,BIRTH_DT,BDAY,BRTH_DT,BORN_DATE,BIRTH_YMD,DATE_OF_BIRTH,출생일,BIRTH_YYYYMMDD',
 '생년월일 관련 컬럼', 0.50, 10, 'ACTIVE'),

(UUID(), '성별 컬럼',                 'META', '2_1_gender',         'PERSONAL',
 'GENDER,SEX,성별,GENDER_CD,SEX_CD,SEX_FLAG,GENDER_FLAG,남녀구분',
 '성별 관련 컬럼', 0.40, 10, 'ACTIVE'),

(UUID(), '연령 컬럼',                 'META', '2_1_age',            'PERSONAL',
 'AGE,연령,나이,CUSTOMER_AGE,CUST_AGE,AGE_CD,연령대',
 '연령 관련 컬럼', 0.30, 10, 'ACTIVE'),

(UUID(), 'CI/DI 컬럼',                'META', '2_1_cidi',           'PERSONAL',
 'CI,DI,CI_VAL,DI_VAL,연계정보,중복가입,CI_NO,DI_NO,CONNECTING_INFO,DUPLICATION_INFO,CI_VALUE,DI_VALUE,본인확인,CI_KEY,DI_KEY,본인인증,CONN_INFO,DUP_CHK_INFO',
 'CI/DI 관련 컬럼', 0.60, 10, 'ACTIVE'),

-- ── CONTACT: 연락정보 (2급-그룹2) ──
(UUID(), '전화번호 컬럼',             'META', '2_2_telno',          'CONTACT',
 'PHONE,TEL,HP,MOBILE,전화,휴대폰,연락처,FAX,CELL,TEL_NO,TELNO,HP_NO,HPNO,PHONE_NO,MOBILE_NO,자택전화,직장전화,비상연락처,CELLPHONE,CELL_NO,HANDPHONE,핸드폰,FAX_NO,FAXNO,팩스,CONTACT_NO,EMERGENCY_TEL,긴급연락처,OFFICE_TEL,HOME_TEL,회사전화,HP_NUM,TEL_NUM,SMS_NO',
 '전화번호 관련 컬럼', 0.55, 10, 'ACTIVE'),

(UUID(), '이메일 컬럼',               'META', '2_2_email',          'CONTACT',
 'EMAIL,MAIL,이메일,메일,E_MAIL,MAIL_ADDR,EMAIL_ADDR,EMAIL_ID,MAIL_ID,전자우편,EMAIL_ADDRESS,EMAILADDR',
 '이메일 관련 컬럼', 0.55, 10, 'ACTIVE'),

(UUID(), '주소 컬럼',                 'META', '2_2_address2',       'CONTACT',
 'ADDR,ADDRESS,주소,거주지,ADDRESS1,ADDRESS2,ROAD_ADDR,JIBUN_ADDR,도로명,지번,자택주소,직장주소,HOME_ADDR,OFFICE_ADDR,ROAD_NM_ADDR,LOT_ADDR,DTL_ADDR,FULL_ADDR,실거주지,배송주소,SHIP_ADDR,DLVR_ADDR,BLDG_NM,APT_NM,상세주소,SIDO,SIGUNGU',
 '주소 관련 컬럼 (기본: 상세주소)', 0.50, 10, 'ACTIVE'),

(UUID(), '우편번호 컬럼',             'META', '2_2_zipcode',        'CONTACT',
 'ZIP,ZIPCODE,ZIP_CODE,우편번호,POST_NO,POSTNO,POSTAL,POSTAL_CD,POST_CD,우편',
 '우편번호 관련 컬럼', 0.40, 10, 'ACTIVE'),

-- ── PRIVATE: 개인관련정보 (2급-그룹3) ──
(UUID(), '직업 컬럼',                 'META', '2_3_job',            'PRIVATE',
 'JOB,OCCUPATION,직업,직종,WORK_TYPE,JOB_TYPE,JOB_NM,직장명,WORKPLACE,근무지,EMPLOYER,JOB_CD,직업코드',
 '직업 관련 컬럼', 0.35, 20, 'ACTIVE'),

(UUID(), '학력 컬럼',                 'META', '2_3_education',      'PRIVATE',
 'EDUCATION,SCHOOL,학력,학교,DEGREE,GRADUATE,졸업,EDU_LEVEL,UNIVERSITY,대학,학위,SCHOOL_NM,최종학력',
 '학력 관련 컬럼', 0.35, 20, 'ACTIVE'),

(UUID(), '혼인여부 컬럼',             'META', '2_3_maritalStatus',  'PRIVATE',
 'MARITAL,MARRIAGE,혼인,결혼,배우자,SPOUSE,MARITAL_STATUS,결혼여부,WEDDING',
 '혼인여부 관련 컬럼', 0.35, 20, 'ACTIVE'),

(UUID(), '가족상황 컬럼',             'META', '2_3_familyStatus',   'PRIVATE',
 'FAMILY,가족,부양가족,DEPENDENT,FAMILY_CNT,HOUSEHOLD,가구,세대,세대원,FAMILY_MEMBER,가족수',
 '가족 관련 컬럼', 0.30, 20, 'ACTIVE'),

-- ── AUTO: 자동생성/가공정보 (3급-그룹1,2) ──
(UUID(), 'IP 주소 컬럼',              'META', '3_1_ipAddress',      'AUTO',
 'IP,IP_ADDR,IP_ADDRESS,IPADDR,접속IP,CLIENT_IP,REMOTE_IP,SERVER_IP,SRC_IP,DST_IP,ACCESS_IP,LOGIN_IP,CONN_IP',
 'IP주소 관련 컬럼', 0.50, 15, 'ACTIVE'),

(UUID(), 'MAC 주소 컬럼',             'META', '3_1_macAddress',     'AUTO',
 'MAC,MAC_ADDR,MAC_ADDRESS,MACADDR,MAC_NO',
 'MAC주소 관련 컬럼', 0.50, 15, 'ACTIVE'),

(UUID(), 'IMEI 컬럼',                 'META', '3_1_imei',           'AUTO',
 'IMEI,IMEI_NO,단말기번호,DEVICE_ID,DEVICE_NO,DEVICE_SERIAL,기기번호,SERIAL_NO',
 'IMEI/단말기 관련 컬럼', 0.50, 15, 'ACTIVE'),

(UUID(), 'USIM 컬럼',                 'META', '3_1_usim',           'AUTO',
 'USIM,USIM_NO,ICCID,SIM,SIM_NO,USIM_SERIAL,유심',
 'USIM 관련 컬럼', 0.50, 15, 'ACTIVE'),

(UUID(), 'UUID 컬럼',                 'META', '3_1_uuid',           'AUTO',
 'UUID,GUID,UNIQUE_ID,TRACE_ID',
 'UUID 관련 컬럼', 0.30, 15, 'ACTIVE'),

-- ── LIMITED_ID: 제한적 식별정보 (3급-그룹3) ──
(UUID(), '법인번호/사업자번호 컬럼',  'META', '3_3_corpno',         'LIMITED_ID',
 'CORP_NO,CORPNO,법인번호,CORP_REG,CORP_REG_NO,사업자등록,BIZ_NO,BIZNO,BIZ_REG,사업자번호,BRNO,BR_NO,BUSINESS_NO,BUSINESS_REG,TAX_NO,납세번호,TXPR_NO,사업자,법인등록,COMP_REG_NO',
 '법인번호/사업자번호 관련 컬럼', 0.50, 15, 'ACTIVE'),

(UUID(), '사번 컬럼',                 'META', '3_3_employeeID',     'LIMITED_ID',
 'EMP_ID,EMP_NO,EMPNO,사번,사원번호,EMPLOYEE_ID,STAFF_NO,STAFF_ID,직원번호,EMP_NUM',
 '사번 관련 컬럼', 0.40, 15, 'ACTIVE'),

(UUID(), '내부용 개인식별정보 컬럼',  'META', '3_3_internalID',     'LIMITED_ID',
 'CUST_ID,CUSTID,CUST_NO,CUSTNO,고객번호,고객ID,USER_ID,USERID,PERSON_ID,개인식별,INDIVIDUAL_ID,고객키,CUST_KEY',
 '내부 개인식별 ID 관련 컬럼', 0.35, 15, 'ACTIVE'),

(UUID(), '회원번호 컬럼',             'META', '3_3_memberID',       'LIMITED_ID',
 'MEMBER_ID,MEMBER_NO,MEMBERNO,회원번호,MEMBERSHIP_NO,가입번호,MEMBER_NUM,MBR_NO,MBR_ID',
 '회원번호 관련 컬럼', 0.35, 15, 'ACTIVE');


-- ============================================================
-- 5-B. Discovery Rules - PATTERN (정규식 기반 데이터 패턴 매칭)
-- ============================================================
INSERT INTO COTDL.TBL_DISCOVERY_RULE
    (rule_id, rule_name, rule_type, pii_type_code, category, pattern, description, weight, priority, status) VALUES

-- ── ID: 고유식별정보 ──
(UUID(), '주민등록번호 (하이픈)',          'PATTERN', '1_1_rrn',           'ID',
 '^\\d{6}-[1-4]\\d{6}$',
 '주민등록번호 13자리 (하이픈 포함)', 0.95, 5, 'ACTIVE'),

(UUID(), '주민등록번호 (연속)',            'PATTERN', '1_1_rrn',           'ID',
 '^\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])[1-4]\\d{6}$',
 '주민등록번호 13자리 (연속, 날짜유효성 검증)', 0.80, 6, 'ACTIVE'),

(UUID(), '외국인등록번호',                 'PATTERN', '1_1_rrn',           'ID',
 '^\\d{6}-[5-8]\\d{6}$',
 '외국인등록번호 (성별코드 5-8)', 0.90, 5, 'ACTIVE'),

(UUID(), '주민등록번호 (마스킹)',          'PATTERN', '1_1_rrn',           'ID',
 '^\\d{6}-[1-8]\\*{6}$',
 '마스킹된 주민등록번호 (뒷자리 *)', 0.70, 8, 'ACTIVE'),

(UUID(), '운전면허번호 (하이픈)',          'PATTERN', '1_1_driverLicense', 'ID',
 '^\\d{2}-\\d{2}-\\d{6}-\\d{2}$',
 '운전면허번호 12자리 (표준형)', 0.85, 5, 'ACTIVE'),

(UUID(), '운전면허번호 (연속)',            'PATTERN', '1_1_driverLicense', 'ID',
 '^(1[1-9]|2[0-8])\\d{10}$',
 '운전면허번호 12자리 (하이픈 없음, 지역코드 검증)', 0.70, 7, 'ACTIVE'),

(UUID(), '여권번호 (구형)',                'PATTERN', '1_1_passport',      'ID',
 '^[MSRGD]\\d{8}$',
 '한국 여권번호 구형 (영문1+숫자8)', 0.80, 5, 'ACTIVE'),

(UUID(), '여권번호 (신형 차세대)',         'PATTERN', '1_1_passport',      'ID',
 '^[MSRGD]\\d{3}[A-Z]\\d{4}$',
 '차세대 여권번호 (2021.12~ 발급)', 0.85, 5, 'ACTIVE'),

-- ── FINANCIAL: 금융정보 ──
(UUID(), '카드번호 16자리',                'PATTERN', '1_4_creditCard',    'FINANCIAL',
 '^\\d{4}-?\\d{4}-?\\d{4}-?\\d{4}$',
 '카드번호 16자리 (하이픈 옵션)', 0.85, 5, 'ACTIVE'),

(UUID(), '카드번호 (공백 구분)',           'PATTERN', '1_4_creditCard',    'FINANCIAL',
 '^\\d{4}\\s\\d{4}\\s\\d{4}\\s\\d{4}$',
 '카드번호 16자리 (공백 구분)', 0.85, 5, 'ACTIVE'),

(UUID(), 'AMEX 카드번호 (15자리)',         'PATTERN', '1_4_creditCard',    'FINANCIAL',
 '^3[47]\\d{2}-?\\d{6}-?\\d{5}$',
 'AMEX 카드번호 15자리', 0.80, 6, 'ACTIVE'),

(UUID(), '계좌번호 (3파트)',               'PATTERN', '1_4_account',       'FINANCIAL',
 '^\\d{3,6}-\\d{2,6}-\\d{3,7}$',
 '계좌번호 3파트 (주요 은행)', 0.75, 6, 'ACTIVE'),

(UUID(), '계좌번호 (4파트)',               'PATTERN', '1_4_account',       'FINANCIAL',
 '^\\d{3,4}-\\d{2,4}-\\d{4,6}-\\d{1,5}$',
 '계좌번호 4파트 (농협/부산은행 등)', 0.75, 6, 'ACTIVE'),

(UUID(), '카드유효기간 (MM/YY)',           'PATTERN', '1_4_cardExpiration','FINANCIAL',
 '^(0[1-9]|1[0-2])/?([2-3]\\d)$',
 '카드 유효기간 (MM/YY 또는 MMYY)', 0.50, 8, 'ACTIVE'),

(UUID(), 'CVV 3자리',                      'PATTERN', '1_4_cvv',          'FINANCIAL',
 '^\\d{3}$',
 'CVV 3자리 숫자 (META 결합 시 유효)', 0.30, 10, 'ACTIVE'),

-- ── PERSONAL: 개인식별정보 ──
(UUID(), '한글 이름 2~5자',                'PATTERN', '2_1_name',          'PERSONAL',
 '^[가-힣]{2,5}$',
 '한글 이름 (2~5자)', 0.40, 10, 'ACTIVE'),

(UUID(), '생년월일 YYYYMMDD',              'PATTERN', '2_1_dob',           'PERSONAL',
 '^(19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])$',
 '생년월일 8자리 (연속)', 0.60, 8, 'ACTIVE'),

(UUID(), '생년월일 YYYY-MM-DD',            'PATTERN', '2_1_dob',           'PERSONAL',
 '^(19|20)\\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])$',
 '생년월일 (하이픈 구분)', 0.65, 7, 'ACTIVE'),

(UUID(), '생년월일 YYYY/MM/DD',            'PATTERN', '2_1_dob',           'PERSONAL',
 '^(19|20)\\d{2}/(0[1-9]|1[0-2])/(0[1-9]|[12]\\d|3[01])$',
 '생년월일 (슬래시 구분)', 0.65, 7, 'ACTIVE'),

(UUID(), '생년월일 YYYY.MM.DD',            'PATTERN', '2_1_dob',           'PERSONAL',
 '^(19|20)\\d{2}\\.(0[1-9]|1[0-2])\\.(0[1-9]|[12]\\d|3[01])$',
 '생년월일 (점 구분)', 0.65, 7, 'ACTIVE'),

(UUID(), 'CI (88byte Base64)',             'PATTERN', '2_1_cidi',          'PERSONAL',
 '^[A-Za-z0-9+/]{86}==$',
 '본인확인 연계정보(CI) 88byte Base64', 0.90, 5, 'ACTIVE'),

(UUID(), 'DI (64byte)',                    'PATTERN', '2_1_cidi',          'PERSONAL',
 '^[A-Za-z0-9+/=]{60,70}$',
 '중복가입확인정보(DI) 64byte', 0.70, 7, 'ACTIVE'),

-- ── CONTACT: 연락정보 ──
(UUID(), '휴대폰 번호',                    'PATTERN', '2_2_telno',         'CONTACT',
 '^01[016789]-?\\d{3,4}-?\\d{4}$',
 '한국 휴대폰 번호', 0.85, 5, 'ACTIVE'),

(UUID(), '유선 전화번호',                  'PATTERN', '2_2_telno',         'CONTACT',
 '^0[2-6][1-5]?-?\\d{3,4}-?\\d{4}$',
 '유선 전화번호 (지역번호 포함)', 0.80, 6, 'ACTIVE'),

(UUID(), '국제 전화번호 (+82)',            'PATTERN', '2_2_telno',         'CONTACT',
 '^\\+82-?10-?\\d{4}-?\\d{4}$',
 '한국 국제전화 형식 (+82)', 0.85, 5, 'ACTIVE'),

(UUID(), '이메일 패턴',                    'PATTERN', '2_2_email',         'CONTACT',
 '^[\\w.-]+@[\\w.-]+\\.\\w+$',
 '이메일 주소', 0.90, 5, 'ACTIVE'),

(UUID(), '한국 주소 (시도 포함)',          'PATTERN', '2_2_address2',      'CONTACT',
 '(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주).{2,}(시|군|구)',
 '한국 주소 (행정구역 포함)', 0.70, 7, 'ACTIVE'),

(UUID(), '우편번호 5자리',                 'PATTERN', '2_2_zipcode',       'CONTACT',
 '^\\d{5}$',
 '신 우편번호 5자리 (META 결합 시 유효)', 0.30, 10, 'ACTIVE'),

(UUID(), '우편번호 구형 (6자리)',          'PATTERN', '2_2_zipcode',       'CONTACT',
 '^\\d{3}-\\d{3}$',
 '구 우편번호 6자리 (하이픈 포함)', 0.60, 8, 'ACTIVE'),

-- ── AUTO: 자동생성정보 ──
(UUID(), 'IPv4 패턴',                      'PATTERN', '3_1_ipAddress',     'AUTO',
 '^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$',
 'IPv4 주소', 0.80, 5, 'ACTIVE'),

(UUID(), 'IPv6 패턴',                      'PATTERN', '3_1_ipAddress',     'AUTO',
 '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$',
 'IPv6 주소 (전체형)', 0.85, 5, 'ACTIVE'),

(UUID(), 'MAC 주소 패턴',                  'PATTERN', '3_1_macAddress',    'AUTO',
 '^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$',
 'MAC 주소 (콜론/하이픈 구분)', 0.85, 5, 'ACTIVE'),

(UUID(), 'UUID 패턴',                      'PATTERN', '3_1_uuid',          'AUTO',
 '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
 'UUID v4 표준형', 0.80, 5, 'ACTIVE'),

-- ── LIMITED_ID: 제한적 식별정보 ──
(UUID(), '사업자등록번호 패턴',            'PATTERN', '3_3_corpno',        'LIMITED_ID',
 '^\\d{3}-\\d{2}-\\d{5}$',
 '사업자등록번호 10자리 (하이픈)', 0.85, 5, 'ACTIVE'),

(UUID(), '법인번호 패턴',                  'PATTERN', '3_3_corpno',        'LIMITED_ID',
 '^\\d{6}-\\d{7}$',
 '법인번호 13자리 (하이픈)', 0.80, 5, 'ACTIVE');


-- ============================================================
-- 6. 기존 스캔 결과 pii_type_code 마이그레이션 (선택사항)
-- ============================================================
-- 기존 단축코드 → DLM PIICODE 변환
-- 기존 스캔 결과를 유지하려면 아래 UPDATE문의 주석을 해제하고 실행하세요.
-- 새로 스캔하면 자동으로 DLM PIICODE가 적용되므로 필수는 아닙니다.
-- ============================================================
/*
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_1_rrn'             WHERE pii_type_code = 'RRN';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_1_driverLicense'   WHERE pii_type_code = 'DRIVER';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_1_passport'        WHERE pii_type_code = 'PASSPORT';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_1_governmentID'    WHERE pii_type_code = 'GOV_ID';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_beliefs'         WHERE pii_type_code = 'BELIEFS';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_politicalViews'  WHERE pii_type_code = 'POLITICAL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_health'          WHERE pii_type_code = 'HEALTH';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_sexualOrientation' WHERE pii_type_code = 'SEXUAL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_geneticInfo'     WHERE pii_type_code = 'GENETIC';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_criminalHistory' WHERE pii_type_code = 'CRIMINAL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_2_unionParty'      WHERE pii_type_code = 'UNION_PARTY';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_3_biometrics'      WHERE pii_type_code = 'BIOMETRICS';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_3_pwd'             WHERE pii_type_code = 'PASSWORD';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_4_account'         WHERE pii_type_code = 'ACCOUNT';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_4_creditCard'      WHERE pii_type_code = 'CARD';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_4_cardReplacement' WHERE pii_type_code = 'CARD_REPLACE';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_4_cardExpiration'  WHERE pii_type_code = 'CARD_EXP';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_4_cvv'             WHERE pii_type_code = 'CVV';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_5_medicalRecords'  WHERE pii_type_code = 'MEDICAL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_5_healthStatus'    WHERE pii_type_code = 'HEALTH_STATUS';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '1_6_location'        WHERE pii_type_code = 'LOCATION';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_1_name'            WHERE pii_type_code = 'NAME';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_1_dob'             WHERE pii_type_code = 'BIRTH';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_1_gender'          WHERE pii_type_code = 'GENDER';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_1_age'             WHERE pii_type_code = 'AGE';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_1_cidi'            WHERE pii_type_code = 'CIDI';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_2_telno'           WHERE pii_type_code = 'PHONE';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_2_email'           WHERE pii_type_code = 'EMAIL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_2_address2'        WHERE pii_type_code = 'ADDRESS';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_2_zipcode'         WHERE pii_type_code = 'ZIPCODE';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_3_job'             WHERE pii_type_code = 'JOB';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_3_education'       WHERE pii_type_code = 'EDUCATION';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_3_maritalStatus'   WHERE pii_type_code = 'MARITAL';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '2_3_familyStatus'    WHERE pii_type_code = 'FAMILY';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_1_ipAddress'       WHERE pii_type_code = 'IP';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_1_macAddress'      WHERE pii_type_code = 'MAC';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_1_imei'            WHERE pii_type_code = 'IMEI';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_1_usim'            WHERE pii_type_code = 'USIM';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_3_corpno'          WHERE pii_type_code IN ('CORP_NO', 'CORP_REG');
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_3_employeeID'      WHERE pii_type_code = 'EMP_ID';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_3_internalID'      WHERE pii_type_code = 'INTERNAL_ID';
UPDATE COTDL.TBL_DISCOVERY_SCAN_RESULT SET pii_type_code = '3_3_memberID'        WHERE pii_type_code = 'MEMBER_ID';

-- PII Registry도 동일하게 마이그레이션
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_1_rrn'             WHERE pii_type_code = 'RRN';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_1_driverLicense'   WHERE pii_type_code = 'DRIVER';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_1_passport'        WHERE pii_type_code = 'PASSPORT';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '2_1_name'            WHERE pii_type_code = 'NAME';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '2_2_telno'           WHERE pii_type_code = 'PHONE';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '2_2_email'           WHERE pii_type_code = 'EMAIL';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '2_2_address2'        WHERE pii_type_code = 'ADDRESS';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_4_creditCard'      WHERE pii_type_code = 'CARD';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_4_account'         WHERE pii_type_code = 'ACCOUNT';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '2_1_dob'             WHERE pii_type_code = 'BIRTH';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '1_3_pwd'             WHERE pii_type_code = 'PASSWORD';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '3_1_ipAddress'       WHERE pii_type_code = 'IP';
UPDATE COTDL.TBL_DISCOVERY_PII_REGISTRY SET pii_type_code = '3_3_corpno'          WHERE pii_type_code IN ('CORP_NO', 'CORP_REG');
*/


-- ============================================================
-- 7. 검증
-- ============================================================
SELECT 'PII Type Master' AS DATA, COUNT(*) AS CNT FROM COTDL.TBL_DISCOVERY_PII_TYPE
UNION ALL
SELECT 'META Rules',              COUNT(*)        FROM COTDL.TBL_DISCOVERY_RULE WHERE rule_type = 'META'
UNION ALL
SELECT 'PATTERN Rules',           COUNT(*)        FROM COTDL.TBL_DISCOVERY_RULE WHERE rule_type = 'PATTERN'
UNION ALL
SELECT 'Total Rules',             COUNT(*)        FROM COTDL.TBL_DISCOVERY_RULE;

SELECT 'DISCOVERY_PATCH_20260406 applied successfully' AS MESSAGE;
