package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApprovalStepReqVO {
	private String reqid;
	private String aprvlineid;
	private String seq;
	private String stepname;
	private String status;
	private String approverid;
	private String approvername;
	private String regdate;
	private String comment;

}
