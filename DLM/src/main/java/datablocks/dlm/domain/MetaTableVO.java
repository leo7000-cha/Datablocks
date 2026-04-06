package datablocks.dlm.domain;

import lombok.Data;

@Data
public class MetaTableVO {
	private String db;
	private String owner;
	private String table_name;
	private String column_name;
	private String column_id;
	private String pk_yn;
	private String pk_position;
	private String full_data_type;
	private String data_type;
	private String data_length;
	private String domain;
	private String piitype;
	private String piigrade;
	private String encript_flag;
	private String scramble_type;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;
	private String masterkey;
	private String masteryn;
	private String table_comment;
	private String column_comment;
	private String val1;
	private String val2;
	private String val3;
	private String val4;
}
