package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiUploadTemplateVO {
	private String jobid;
	private String version;
	private String stepid;
	private String db;
	private String owner;
	private String table_name;
	private String exetype;
	private int seq;
	private String pk_col;
	private String where_col;
	private String where_key_name;
	private String parallelcnt;
	private String commitcnt;
	private String pre_owner;
	private String pre_table_name;
	private String update_cols;
	private String pagitypedetail;

}
