package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiReportVO {
	private int reportid;
	private String phase;
	private String aprvlineid;
	private String approvalid;
	private String report_type;
	private String date_from;
	private String date_to;
	private String val1;
	private String val2;
	private String val3;
	private String apply_date;
	private String apply_userid;
	private String approve_date;
	private String approve_userid;

}
