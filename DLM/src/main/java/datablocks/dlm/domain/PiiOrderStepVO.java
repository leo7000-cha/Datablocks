package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderStepVO {
	private int orderid;
	private String status;
	private String confirmflag;
	private String holdflag;
	private String forceokflag;
	private String killflag;
	private String basedate;
	private String threadcnt;
	private String commitcnt;
	private String runcnt;
	private String jobid;
	private String version;
	private String stepid;
	private String stepname;
	private String steptype;
	private String stepseq;
	private String db;
	private String totaltabcnt;
	private String successtabcnt;
	private String runningtime;
	private String realstarttime;
	private String realendtime;
	private String orderuserid;
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
