package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApprovalStepUserVO {
	private String aprvlineid;
	private String seq;
	private String stepname;
	private String approvalid;
	private String approvalname;
	private String approverid;
	private String approvername;

}
