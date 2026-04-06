package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.*;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class ReportJsonServiceImpl implements ReportJsonService {
	private static final Logger logger = LoggerFactory.getLogger(ReportJsonServiceImpl.class);
	@Autowired
	private ReportJsonMapper mapper;

	@Override
	public ReportJsonVO get(String srvyId, String formName) {
		
		LogUtil.log("WARN", "getList with srvyId:%s   , formName:%s " , srvyId, formName);
		
		return mapper.selectReportJsonById(srvyId, formName);
	}

	@Override
	public String saveReportJson(String srvyId, String formName, String formJson, String inputJson) {
		LogUtil.log("INFO", "[saveReportJson] 진입 완료   srvyId:%s   , formName:%s " , srvyId, formName);

		String rst = "success";
		ReportJsonVO data = new ReportJsonVO();
		try {
			data.setSrvy_id(srvyId);
			data.setForm_name(formName);
			data.setForm_json(formJson);
			data.setInput_json(inputJson);
			if(mapper.selectReportJsonCountById(srvyId, formName) > 0) {
				mapper.updateReportJsonById(data);
			} else {
				mapper.insertReportJson(data);
			}
		} catch (Exception e) {
			e.printStackTrace();
			logger.warn("warn "+"saveReportJson=> " + e.getMessage() );
			rst = e.getMessage();
		}

		return rst;
			
	}

	
}
