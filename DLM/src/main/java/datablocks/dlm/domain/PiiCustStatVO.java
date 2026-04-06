package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiCustStatVO {

	private String mon;
	private int archive_cnt1;
	private int restore_cnt1;
	private int arc_del_cnt1;
	private int archive_cnt2;
	private int restore_cnt2;
	private int arc_del_cnt2;
	private int archive_cnt3;
	private int restore_cnt3;
	private int arc_del_cnt3;
}
