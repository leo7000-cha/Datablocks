package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiConfTableVO {
	
	private String db;
	private String owner;
	private String table_name;
	private String pagitype;
	private String pagitypedetail;
	private String archiveflag;
	private String status;
	private String preceding;
	private String succedding;
	private int seq1;
	private int seq2;
	private int seq3;
	private String pipeline;
	private String pk_columns;
	private String pk_data_type;
	private String imatable_name;
	private String masterkey;
	private String where_col;
	private String where_key_name;
	private String parallelcnt;
	private String totalcnt;
	private String wherestr;
	private String regdate;
	private String upddate;
	private String reguserid;
	private String upduserid;


}
