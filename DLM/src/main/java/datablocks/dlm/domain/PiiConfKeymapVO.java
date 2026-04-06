package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiConfKeymapVO {
	private String keymap_id;
	private String key_name;
	private String db;
	private int seq1;
	private int seq2;
	private int seq3;
	private String key_cols;
	private String src_owner;
	private String src_table_name;
	private String where_col;
	private String where_key_name;
	private String parallelcnt;
	private String status;
	private String sqltype;
	private String insertstr;
	private String wherestr;
	private String refstr;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
