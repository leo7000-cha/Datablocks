package datablocks.dlm.domain;

import lombok.Data;

@Data
public class MetaPiiStatusVO {
	private String system_name;
	private String db;
	private String owner;
	private String total_tables;
	private String total_columns;
	private String pii_notconfirmed;
	private String pii_tables;
	private String pii_columns;
	private String pii3_del_columns;
	private String pii3_upd_columns;
	private String pii3_notregistered;
}