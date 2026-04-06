package datablocks.dlm.domain;

import lombok.Data;

@Data
public class TestDataVO {
	private int testdataid;
	private String system;
	private String sourcedb;
	private String targetdb;
	private String phase;
	private String apply_type;
	private int new_orderid;
	private String jobid;
	private String idtype;
	private String custid;
	private String custid_new;
	private String cust_nm;
	private String ssn;
	private String new_jobid;
	private String status;
	private String approve_date;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;
	private String disposal_status;
	private String disposal_sche_date;
	private String disposal_exec_date;


}
