package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiStepTableTargetVO {
	private String db;
	private String owner;
	private String table_name;
	private int seq2;

}
