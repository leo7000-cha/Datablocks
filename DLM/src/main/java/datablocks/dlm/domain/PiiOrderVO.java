package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderVO {
	private int orderid;
	private String basedate;
	private int runcnt;
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
	private String status;
	private String confirmflag;
	private String holdflag;
	private String forceokflag;
	private String killflag;
	private String eststarttime;
	private String runningtime;
	private String realstarttime;
	private String realendtime;
	private String job_owner_id1;
	private String job_owner_name1;
	private String job_owner_id2;
	private String job_owner_name2;
	private String job_owner_id3;
	private String job_owner_name3;
	private String orderdate;
	private String orderuserid;

}
