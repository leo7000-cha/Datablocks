package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderStepTableUpdateVO {
	private int orderid;
	private String jobid;
	private String version;
	private String stepid;
	private int seq1;
	private int seq2;
	private int seq3;
	private String column_name;
	private String update_val;
	private String status;


}
