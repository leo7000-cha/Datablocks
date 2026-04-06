package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiRecoveryVO {
	private int recoveryid;
	private String phase;
	private int old_orderid;
	private int new_orderid;
	private String keymap_id;
	private String basedate;
	private String old_jobid;
	private String old_version;
	private String new_jobid;
	private String status;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;

}
