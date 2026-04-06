package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApiResponseCustidVO {
	private String reqtype;		// "SEARCH":분리보관여부 조회 "RESTORE":복원신청 "SEARCH&RESTORE":분리보관여부 조회하여 복원대상이면 복원처리
	private String status;
	private String existyn;
	private String custid;
	private String custname;
	private String msg;
}
