package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiJobWaitVO {
	private String jobid;
	private String version;
	private String type;
	private String jobid_w;
	private String jobname_w;
}
