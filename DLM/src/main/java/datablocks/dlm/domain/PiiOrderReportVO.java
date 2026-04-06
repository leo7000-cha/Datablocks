package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderReportVO {
	private String system;
	private String jobid;
	private String stepid;
	private String db;
	private String owner;
	private String table_name;
	private int seq1;
	private int seq2;
	private int seq3;
	private int delcnt;
	private int arccnt;
	private int delarccnt;


}
