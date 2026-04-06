package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiDetectConfigVO {
	private String conf_id;
	private String conf_name;
	private String detect_type;
	private String detect_pattern1;
	private String detect_pattern2;
	private String detect_pattern3;
	private String detect_pattern4;
	private String detect_pattern5;
	private String detect_pattern6;
	private String detect_pattern7;
	private String detect_pattern8;
	private String lenth_min;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
