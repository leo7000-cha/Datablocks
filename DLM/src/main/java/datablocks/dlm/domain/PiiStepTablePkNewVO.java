package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepTablePkNewVO {
	private String jobid;
	private String version;
	private String stepid;
	private String db;
	private String owner;
	private String table_name;
	private String pagitype;
	private String pagitypedetail;
	private String exetype;
	private String archiveflag;
	private String status;
	private String preceding;
	private String succedding;
	private int seq1;
	private int seq2;
	private int seq3;
	private String pipeline;
	private String pk_col;
	private String where_col;
	private String where_key_name;
	private String parallelcnt;
	private String commitcnt;
	private String wherestr;
	private String sqlstr;
	private String keymap_id;
	private String key_name;
	private String key_cols;
	private String key_refstr;
	private String sqltype;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;
	/*20250301 added*/
	private String hintselect;
	private String hintinsert;
	private String uval1;
	private String uval2;
	private String uval3;
	private String uval4;
	private String uval5;
	/*additional field for PiiStepTablePkNewVO*/
	private int seq2_new;

}
