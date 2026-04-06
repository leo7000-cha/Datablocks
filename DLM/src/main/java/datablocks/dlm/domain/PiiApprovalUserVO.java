package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiApprovalUserVO {
	private String aprvlineid;
	private String seq;
	private String stepname;
	private String approverid;
	private String approvername;

}
