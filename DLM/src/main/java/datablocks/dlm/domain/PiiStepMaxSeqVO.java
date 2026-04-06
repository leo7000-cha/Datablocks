package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepMaxSeqVO {
	private String jobid;
	private String version;
	private String stepid;
	private int seq1;
	private int seq2;
	private int seq3;
	
}
