package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiPolicyVO {
	private String policy_id;
	private String policy_name;
	private String version;
	private String phase;
	private String status;
	private String del_deadline;
	private String del_deadline_unit;
	private String archive_flag;
	private String arc_del_deadline;
	private String arc_del_deadline_unit;
	private String related_law;
	private String comments;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;


}
