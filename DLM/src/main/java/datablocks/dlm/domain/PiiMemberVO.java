package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiMemberVO {
	private String userid;
	private String userpw;
	private String username;
	private String regdate;
	private String updatedate;
	private String enabled;
	private String dept_cd;
	private String dept_name;
}
