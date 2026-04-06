package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiDatabaseVO {
	private String db;
	private String system;
	private String env;
	private String dbtype;
	private String dbuser;
	private String pwd;
	private String hostname;
	private String port;
	private String id_type;
	private String id;
	private String comments;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
