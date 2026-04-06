package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiConfKeymapRefVO {
	private String keymap_id;
	private String key_name;
	private String key_cols;
	private String pk_col;
}
