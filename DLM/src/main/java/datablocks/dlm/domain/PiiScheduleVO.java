package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiScheduleVO {
	private String scheduleid;
	private String schedulename;
	private String cronval;
	private String jobno;
	private String var_basedt;
	private String var_param1;
	private String var_param2;
	private String var_param3;
	private String status;
	private String confirmflag;
	private String nextschedule;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
