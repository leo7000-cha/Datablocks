package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiContractStatVO {
	private String mon;
	private String mgmt_dept_cd;
	private String mgmt_dept_name;
	private int acount;
	private int ncount;
	private int ycount;
	private String progress;


}
