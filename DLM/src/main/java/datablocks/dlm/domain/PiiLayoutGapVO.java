package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiLayoutGapVO {
	private int rn;
	private String owner_src;
	private String table_name_src;
	private String column_id_src;
	private String column_name_src;
	private String data_length_src;
	private String owner_arc;
	private String table_name_arc;
	private String column_id_arc;
	private String column_name_arc;
	private String data_length_arc;
	private String gapdate;
}


