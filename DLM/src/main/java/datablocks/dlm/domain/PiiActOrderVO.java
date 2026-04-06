package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiActOrderVO {
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
	private String orderdate;
	private String orderuserid;
	private String archive_date;
	private String delete_date;
	private String restore_date;
	private String arc_del_date;
	private String last_base_date;
	private String expected_arc_del_date;
	private String custid;
	private String cust_nm;
	private String birth_dt;
	private String rsdnt_altrntv_id;
	private String cust_pin;
	private String exclude_reason;

}
