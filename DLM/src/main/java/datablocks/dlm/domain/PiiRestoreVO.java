package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiRestoreVO {
	private int restoreid;
	private String phase;
	private String apply_type;
	private int old_orderid;
	private int new_orderid;
	private String keymap_id;
	private String basedate;
	private String custid;
	private String cust_nm;
	private String birth_dt;
	private String rsdnt_altrntv_id;
	private String cust_pin;
	private String old_jobid;
	private String old_version;
	private String new_jobid;
	private String status;
	private String browse_deadline_dt;
	private String approve_date;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
