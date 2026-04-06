package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiCodeVO {
	private String code_id;
	private String item_val;
	private String item_name;
	private String use_flag;
}
