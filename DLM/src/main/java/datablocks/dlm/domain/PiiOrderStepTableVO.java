package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderStepTableVO {
	private int orderid;
	private String status;
	private String forceokflag;
	private String basedate;
	private String jobid;
	private String version;
	private String stepid;
	private String stepname;
	private String steptype;
	private String stepseq;
	private String db;
	private String owner;
	private String table_name;
	private String pagitype;
	private String pagitypedetail;
	private String exetype;
	private String archiveflag;
	private String preceding;
	private String succedding;
	private int seq1;
	private int seq2;
	private int seq3;
	private String pipeline;
	private String pk_col;
	private String where_col;
	private String where_key_name;
	private String parallelcnt;
	private String commitcnt;
	private String wherestr;
	private String sqlstr;
	private String arccnt;
	private String arctime;
	private String arcstart;
	private String arcend;
	private String execnt;
	private String exetime;
	private String exestart;
	private String exeend;
	private String sqlmsg;
	/*20250301 added*/
	private String hintselect;
	private String hintinsert;
	private String uval1;
	private String uval2;
	private String uval3;
	private String uval4;
	private String uval5;

}
