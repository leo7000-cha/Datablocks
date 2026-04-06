package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiSystemVO {
	private String system_id;
	private String system_name;
	private String system_info;
	private String use_flag;
}
