package datablocks.dlm.domain;

import lombok.Data;

@Data
public class ErrorHistVO {
	private long id             ;
	private String module_name    ;
	private String error_message  ;
	private String stack_trace    ;
	private String created_at     ;
}
