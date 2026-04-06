package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiConfigVO {
	private String cfgkey;
	private String value;
	private String comments;

}
