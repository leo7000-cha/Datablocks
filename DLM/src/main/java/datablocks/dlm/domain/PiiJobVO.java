package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiJobVO {
	private String jobid;
	private String version;
	private String jobname;
	private String system;
	private String policy_id;
	private String keymap_id;
	private String jobtype;
	private String runtype;
	private String calendar;
	private String time;
	private String cronval;
	private String confirmflag;
	private String status;
	private String phase;
	private String job_owner_id1;
	private String job_owner_name1;
	private String job_owner_id2;
	private String job_owner_name2;
	private String job_owner_id3;
	private String job_owner_name3;
	private String enddate;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
