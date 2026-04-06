package datablocks.dlm.domain;

import lombok.Data;

@Data
public class OrderDdlVO {
	private int orderid;
	private String stepid;
	private int seq1;
	private int seq2;
	private int seq3;
	private String db;
	private String owner;
	private String table_name;
	private String constraint_type;
	private String object_type;
	private String object_owner;
	private String object_name;
	private String status;
	private String result;
	private String ddl;

}
