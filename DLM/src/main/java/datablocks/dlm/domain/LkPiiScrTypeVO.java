package datablocks.dlm.domain;

import lombok.Data;

@Data
public class LkPiiScrTypeVO {
	private String piicode;
	private String piigradeid;
	private String piigradename;
	private String piigroupid;
	private String piigroupname;
	private String piitypeid;
	private String piitypename;
	private String scrtype;
	private String scrmethod;
	private String scrcategory;
	private String scrdigits;
	private String scrvalidity;
	private String remarks;
	private String encdecfunctype;
	private String encfunc;
	private String decfunc;

}
