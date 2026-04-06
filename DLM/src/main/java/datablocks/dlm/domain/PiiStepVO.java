package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepVO {
	private String jobid;
	private String version;
	private String stepid;
	private String stepname;
	private String steptype;
	private String stepseq;
	private String db;
	private String status;
	private String phase;
	private String threadcnt;
	private String commitcnt;
	private String enddate;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;
	private String data_handling_method;
	private String processing_method;
	private String fk_disable_flag;
	private String index_unusual_flag;
	private String val1;
	private String val2;
	private String val3;
	private String val4;
	private String val5;


}
