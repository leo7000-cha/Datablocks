package datablocks.dlm.domain;

import java.sql.Date;
import java.util.List;

import lombok.Data;

@Data
public class MemberVO {

	private String userid;
	private String userpw;
	private String userName;
	private boolean enabled;

	private Date regDate;
	private Date updateDate;
	private List<AuthVO> authList;

	private String email;
	private String managerId;
	private String position;

}
