package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiArcCustBrowseVO {
	private String custid;
	private String db;
	private String owner;
	private String table_name;
	private String runtype;
}
