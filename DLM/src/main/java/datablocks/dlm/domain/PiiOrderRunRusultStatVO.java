package datablocks.dlm.domain;

import lombok.Data;

@Data
public class PiiOrderRunRusultStatVO {

	private int ok;
	private int run;
	private int wait;
	private int ko;
	private int recovered;
	private int total;

}
