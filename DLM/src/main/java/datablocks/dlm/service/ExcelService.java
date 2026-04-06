package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.List;
import java.util.Locale;

public interface ExcelService {


	public SXSSFWorkbook makeStepTableExcelWB(List<PiiStepTableVO> list);
	public XSSFWorkbook makeStepTableExcelTemplate(String path, String exeType, String jobid, List<PiiStepTableWithWaitVO> list, List<PiiConfKeymapRefVO> list_Keymap);
	public XSSFWorkbook makeMetadataExcelTemplate(String path, String exeType, List<MetaTableVO> list);
	public XSSFWorkbook makeMetadataGapExcelTemplate(String path, String exeType, List<MetaTableGapVO> list);//20240531
	public XSSFWorkbook makeCustHistoryExcel(Locale locale,String path, String exeType, List<PiiExtractVO> list, Criteria cri, String username);
	public XSSFWorkbook makeTableDelStatExcel(Locale locale,String path, String exeType, List<PiiOrderReportVO> list, Criteria cri);
	public XSSFWorkbook makeQueryResultExcel(Locale locale,String query, String path, String exeType, ResultSetMetaData rsmd, ResultSet rs);
	public XSSFWorkbook makeCustStatExcel(Locale locale,String path, String exeType, List<PiiCustStatVO> list, Criteria cri, String username);
	public XSSFWorkbook makeCustStatConsentExcel(Locale locale,String path, String exeType, List<PiiCustStatConsentVO> list, Criteria cri, String username);
	public XSSFWorkbook makeRealDocMgmtExcel(Locale locale,String path, String exeType, List<PiiContractVO> list, Criteria cri);
	public XSSFWorkbook makeRealDocStatExcel(Locale locale,String path, String exeType, List<PiiContractStatVO> list, Criteria cri);
	public XSSFWorkbook makeTestDataStatusTemplateExcel(String path, String templateName, List<TestDataCombinedStatusVO> list, String startDate, String endDate
			, long totalAutoGenRequestCount
			, long totalAutoGenCustomerCount
			, long totalTableLoadRequestCount
			, long totalTableLoadTableCount);
	//public List<Fruit> uploadExcelFile(MultipartFile excelFile);

}