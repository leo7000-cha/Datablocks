package datablocks.dlm.domain;

import lombok.Data;

@Data
public class ArcTabExpectedLengthVO {
	private String db;
	private String owner;
	private String table_name;
	private int all_row_size;
	private int all_row_size_1000;
	private int all_row_size_500;
	private int page_row_size;
	private int page_row_size_40;
	private int page_row_size_20;
}
