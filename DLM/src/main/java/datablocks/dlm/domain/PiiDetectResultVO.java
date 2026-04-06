package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiDetectResultVO {
	private String db;
	private String owner;
	private String table_name;
	private String column_name;
	private String orderid;
	private String piitype;
	private String piicnt;
	private String detect_all_cnt;
	private String pii_ratio;
	private String regdate;
	private String sampledata;

}
