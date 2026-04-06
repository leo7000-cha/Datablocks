package datablocks.dlm.domain;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ProgOrderHistVO {
	private int orderid;
	private String prog_job_nm;
	private String bgnn_chng_dvcd;
	private String param_base_dt;
	private String update_query;
	private String insert_query;
	private String db;
	private LocalDateTime created_at;
	private String error_message;
}
