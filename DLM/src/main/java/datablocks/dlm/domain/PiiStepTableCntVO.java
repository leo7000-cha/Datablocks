package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepTableCntVO {
	private String jobid;
	private String version;
	private String stepid;
	private String exetype;
	private int tablecnt;
}
