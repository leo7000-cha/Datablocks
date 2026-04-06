package datablocks.dlm.domain;

import lombok.Data;

@Data
public class LogFileVO {
	private String type;
	private String path;
	private String filename;
	private String contents;

}
