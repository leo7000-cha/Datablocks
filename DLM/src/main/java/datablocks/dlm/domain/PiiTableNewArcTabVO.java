package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiTableNewArcTabVO {
	private String db;
	private String owner;
	private String table_name;
	private String column_id;
	private String column_name;
	private String data_type;
	private String data_length;

}
