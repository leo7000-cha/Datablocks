package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiAttachFileDTO {

	private String fileName;
	private String uploadPath;
	private String uuid;
	private boolean image;

}
