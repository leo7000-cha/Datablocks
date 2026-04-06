package datablocks.dlm.domain;

import lombok.Data;

@Data
public class CommandJschVO {
	private String command;
	private String username;
	private String password;
	private String host;
	private int port;
	private String rootPassword;
	private String directory;

}
