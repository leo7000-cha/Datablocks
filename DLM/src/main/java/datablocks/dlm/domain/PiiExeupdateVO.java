package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiExeupdateVO {
	private String db;
	private String sqlstr;
	private String amho;
	private String splitter;
	private String runtype;
	private int maxrowcnt;
}
