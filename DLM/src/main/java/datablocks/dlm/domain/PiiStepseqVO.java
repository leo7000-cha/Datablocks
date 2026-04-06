package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepseqVO {
	private Integer stepseq;
	private String jobid;
	private String version;
	private String stepid;
}
