package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApiRequestCustidVO {
	private String reqtype;		// "SEARCH":분리보관여부 조회 "RESTORE":복원신청 "SEARCH&RESTORE":분리보관여부 조회하여 복원대상이면 복원처리
	private String reqfrom; 	// "PLATFORM": 플랫폼 유입 자동복원 결재라인  "USER": 사용자 직접 신청 자동복원 결재라인
	private String valtype;     // val type : SSN, CUSTID, DI
	private String val;  		// 데이터 : 주민번호, 고객번호, DI
	private String requserid;	// 신청자사번
	private String requsername;	// 신청자명
}
