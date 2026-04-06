package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderStepTablePkVO {
	private int orderid;
	private String stepid;
	private int seq1;
	private int seq2;
	private int seq3;

}
