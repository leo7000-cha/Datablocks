package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiBizDayVO {
	private String base_dt;
	private String bf_bf_biz_dt;
	private String bf_biz_dt;
	private String biz_dt;
	private String nxt_biz_dt;
	private String nxt_nxt_biz_dt;
	private String hldy_yn;
	private String inst_cd;

}
