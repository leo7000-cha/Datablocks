package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderStepRunStatusVO {
	private int orderid;
	private String jobid;
	private String version;
	private String stepid;
	private String stepname;
	private String stepseq;
	private int total;
	private int ok;
	private int notok;
	private int running;
	private int wait;
}
