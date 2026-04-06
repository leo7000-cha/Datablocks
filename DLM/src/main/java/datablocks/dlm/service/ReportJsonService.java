package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import org.apache.ibatis.annotations.Param;

import java.security.Principal;
import java.util.List;

public interface ReportJsonService {

	public String saveReportJson(String srvyId, String formName, String formJson, String inputJson);
	public ReportJsonVO get(String srvyId, String formName);
}
