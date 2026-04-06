package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiArcTableVO {
	private String db;
	private String owner;
	private String table_name;
}
