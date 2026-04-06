package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiTableVO {
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
	private String nullable;
	private String comments;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
