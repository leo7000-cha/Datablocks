package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiExtractVO {
	private int orderid;
	private String jobid;
	private String actid;
	private String custid;
	private String basedate;
	private String exclude_reason;
	private String actrole_end_date;
	private String archive_date;
	private String delete_date;
	private String restore_date;
	private String arc_del_date;
	private String last_base_date;
	private String expected_arc_del_date;
	private String cust_nm;
	private String birth_dt;
	private String address;
	private String rsdnt_altrntv_id;
	private String cust_pin;
	private String inst_cd;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;
	private String val1;
	private String val2;
	private String val3;
	private String val4;
	private String val5;
	private String val6;
	private String val7;
}
