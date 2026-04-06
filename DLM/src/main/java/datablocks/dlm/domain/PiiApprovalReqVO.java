package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApprovalReqVO {
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

}
