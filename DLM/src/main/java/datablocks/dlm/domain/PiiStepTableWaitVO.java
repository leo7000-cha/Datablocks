package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepTableWaitVO {
	private String jobid;
	private String version;
	private String stepid;
	private String db;
	private String owner;
	private String table_name;
	private String type;
	private String db_w;
	private String owner_w;
	private String table_name_w;

}
