package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiContractVO {
	private String custid;
	private String contractno;
	private String dept_cd;
	private String dept_name;
	private String mgmt_dept_cd;
	private String mgmt_dept_name;
	private String contract_opn_dt;
	private String contract_close_dt;
	private String pd_cd;
	private String pd_nm;
	private String status;
	private String actid;
	private String rsdnt_altrntv_id;
	private String cust_nm;
	private String birth_dt;
	private String cb_dt;
	private String cust_pin;
	private String inst_cd;
	private String basedate;
	private String actrole_end_date;
	private String archive_date;
	private String delete_date;
	private String arc_del_date;
	private String real_doc_del_date;
	private String real_doc_del_userid;

}
