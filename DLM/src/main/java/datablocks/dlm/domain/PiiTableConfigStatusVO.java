package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiTableConfigStatusVO {
	private String policy_id;
	private String jobid;
	private String exetype;
	private int tablecnt;

}
