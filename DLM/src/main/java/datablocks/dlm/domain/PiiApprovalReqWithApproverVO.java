package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApprovalReqWithApproverVO {
	private String reqid;
	private String aprvlineid;
	private String seq;
	private String approvalid;
	private String phase;
	private String jobid;
	private String version;
	private String requesterid;
	private String requestername;
	private String regdate;
	private String upddate;
	private String reqreason;
	private String approverid;
	private String approvername;
	private String custid;
	//20230129
	private String report_type;
	private String date_from;
	private String date_to;
	private String val1;
	private String val2;
	private String val3;
	private String apply_date;
	private String apply_userid;

}
