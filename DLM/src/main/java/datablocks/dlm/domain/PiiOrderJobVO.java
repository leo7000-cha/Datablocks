package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderJobVO {
	private String jobid;
	private String version;
	private String jobtype;
	private String runtype;
	private String system;
	private String calendar;
	private String time;
	private String job_owner_name1;
	private String policy_id;
	private String keymap_id;
	private String runcnt;
	private String basedate_min;
	private String basedate_max;
	private String lastexedatetime;

}


