package datablocks.dlm.domain;

import lombok.Data;

@Data
public class InnerStepVO {
	private int orderid;
	private String stepid;
	private int seq1;
	private int seq2;
	private int seq3;
	private int inner_step_seq;
	private String inner_step_name;
	private String status;
	private String execnt;
	private String exetime;
	private String exestart;
	private String exeend;
	private String message;
	private String result;

}
