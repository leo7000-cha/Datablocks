package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;


@Service
@AllArgsConstructor
public class ExcelServiceImpl implements ExcelService {
	private static final Logger logger = LoggerFactory.getLogger(ExcelServiceImpl.class);
	@Autowired
	MessageSource messageSource;

	@Override
	public SXSSFWorkbook makeStepTableExcelWB(List<PiiStepTableVO> list) {// NOT used
		SXSSFWorkbook workbook = new SXSSFWorkbook();

		// 시트 생성
		SXSSFSheet sheet = workbook.createSheet("Step Tables");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_2 = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.LEFT);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_2.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_2.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_2.setBorderLeft(BorderStyle.THIN);
		contentStyle_2.setBorderTop(BorderStyle.THIN);
		contentStyle_2.setBorderBottom(BorderStyle.THIN);
		contentStyle_2.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_2.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_2.setFont(contentFont);

		//시트 열 너비 설정
		sheet.setColumnWidth(0, 7000);
		sheet.setColumnWidth(1, 3000);
		sheet.setColumnWidth(2, 5000);
		sheet.setColumnWidth(3, 3000);
		sheet.setColumnWidth(4, 3000);
		sheet.setColumnWidth(5, 6000);
		sheet.setColumnWidth(6, 3000);
		sheet.setColumnWidth(7, 3000);
		sheet.setColumnWidth(8, 3000);
//        sheet.setColumnWidth(9, 1200);
//        sheet.setColumnWidth(10, 3000);
//        sheet.setColumnWidth(11, 3000);
//        sheet.setColumnWidth(12, 3000);
		sheet.setColumnWidth(13-4, 3000);
		sheet.setColumnWidth(14-4, 3000);
		sheet.setColumnWidth(15-4, 3000);
//        sheet.setColumnWidth(16-4, 100);
		sheet.setColumnWidth(17-5, 3000);
		sheet.setColumnWidth(18-5, 3000);
		sheet.setColumnWidth(19-5, 3000);
		sheet.setColumnWidth(20-5, 3000);
		sheet.setColumnWidth(21-5, 3000);
		sheet.setColumnWidth(22-5, 3000);
		sheet.setColumnWidth(23-5, 3000);
		sheet.setColumnWidth(24-5, 3000);
		sheet.setColumnWidth(25-5, 3000);
		sheet.setColumnWidth(26-5, 3000);
		sheet.setColumnWidth(27-5, 3000);
		sheet.setColumnWidth(28-5, 3000);
		sheet.setColumnWidth(29-5, 3000);
		sheet.setColumnWidth(30-5, 3000);
		sheet.setColumnWidth(31-5, 3000);
		sheet.setColumnWidth(32-5, 3000);



		// 헤더 행 생
		Row headerRow = sheet.createRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;

		headerCell = headerRow.createCell(0); headerCell.setCellValue("JOBID");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(1); headerCell.setCellValue("VERSION");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(2); headerCell.setCellValue("STEPID");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(3); headerCell.setCellValue("DATABASEID");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(4); headerCell.setCellValue("OWNER");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(5); headerCell.setCellValue("TABLE_NAME");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(6); headerCell.setCellValue("PAGITYPE");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(7); headerCell.setCellValue("PAGITYPEDETAIL");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(8); headerCell.setCellValue("EXETYPE");headerCell.setCellStyle(cellStyle);
//        headerCell = headerRow.createCell(9); headerCell.setCellValue("ARCHIVEFLAG");headerCell.setCellStyle(cellStyle);
//        headerCell = headerRow.createCell(10); headerCell.setCellValue("STATUS");headerCell.setCellStyle(cellStyle);
//        headerCell = headerRow.createCell(11); headerCell.setCellValue("PRECEDING");headerCell.setCellStyle(cellStyle);
//        headerCell = headerRow.createCell(12); headerCell.setCellValue("SUCCEDDING");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(13-4); headerCell.setCellValue("SEQ1");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(14-4); headerCell.setCellValue("SEQ2");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(15-4); headerCell.setCellValue("SEQ3");headerCell.setCellStyle(cellStyle);
//        headerCell = headerRow.createCell(16-4); headerCell.setCellValue("PIPELINE");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(17-5); headerCell.setCellValue("PK_COL");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(18-5); headerCell.setCellValue("WHERE_COL");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(19-5); headerCell.setCellValue("WHERE_KEY_NAME");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(20-5); headerCell.setCellValue("PARALLELCNT");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(21-5); headerCell.setCellValue("COMMITCNT");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(22-5); headerCell.setCellValue("WHERESTR");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(23-5); headerCell.setCellValue("SQLSTR");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(24-5); headerCell.setCellValue("KEYMAP_ID");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(25-5); headerCell.setCellValue("KEY_NAME");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(26-5); headerCell.setCellValue("KEY_COLS");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(27-5); headerCell.setCellValue("KEY_REFSTR");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(28-5); headerCell.setCellValue("SQLTYPE");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(29-5); headerCell.setCellValue("REGDATE");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(30-5); headerCell.setCellValue("UPDDATE");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(31-5); headerCell.setCellValue("REGUSERID");headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.createCell(32-5); headerCell.setCellValue("UPDUSERID");headerCell.setCellStyle(cellStyle);


		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;
		for(int i=0; i<list.size(); i++) {
			PiiStepTableVO piisteptable = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+1);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(piisteptable.getJobid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(piisteptable.getVersion());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(piisteptable.getStepid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(piisteptable.getDb());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(piisteptable.getOwner());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(piisteptable.getTable_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(piisteptable.getPagitype());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(piisteptable.getPagitypedetail());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(piisteptable.getExetype());bodyCell.setCellStyle(contentStyle);
//            bodyCell = bodyRow.createCell(9);bodyCell.setCellValue(piisteptable.getArchiveflag());bodyCell.setCellStyle(contentStyle);
//            bodyCell = bodyRow.createCell(10);bodyCell.setCellValue(piisteptable.getStatus());bodyCell.setCellStyle(contentStyle);
//            bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(piisteptable.getPreceding());bodyCell.setCellStyle(contentStyle);
//            bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(piisteptable.getSuccedding());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(13-4); bodyCell.setCellValue(piisteptable.getSeq1());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14-4); bodyCell.setCellValue(piisteptable.getSeq2());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(15-4); bodyCell.setCellValue(piisteptable.getSeq3());bodyCell.setCellStyle(contentStyle);
//            bodyCell = bodyRow.createCell(16-4); bodyCell.setCellValue(piisteptable.getPipeline());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(17-5); bodyCell.setCellValue(piisteptable.getPk_col());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(18-5); bodyCell.setCellValue(piisteptable.getWhere_col());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(19-5); bodyCell.setCellValue(piisteptable.getWhere_key_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(20-5); bodyCell.setCellValue(piisteptable.getParallelcnt());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(21-5); bodyCell.setCellValue(piisteptable.getCommitcnt());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(22-5); bodyCell.setCellValue(piisteptable.getWherestr());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(23-5); bodyCell.setCellValue(piisteptable.getSqlstr());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(24-5); bodyCell.setCellValue(piisteptable.getKeymap_id());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(25-5); bodyCell.setCellValue(piisteptable.getKey_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(26-5); bodyCell.setCellValue(piisteptable.getKey_cols());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(27-5); bodyCell.setCellValue(piisteptable.getKey_refstr());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(28-5); bodyCell.setCellValue(piisteptable.getSqltype());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(29-5); bodyCell.setCellValue(piisteptable.getRegdate());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(30-5); bodyCell.setCellValue(piisteptable.getUpddate());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(31-5); bodyCell.setCellValue(piisteptable.getReguserid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(32-5); bodyCell.setCellValue(piisteptable.getUpduserid());bodyCell.setCellStyle(contentStyle);

		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeStepTableExcelTemplate(String path, String exeType, String jobid, List<PiiStepTableWithWaitVO> list, List<PiiConfKeymapRefVO> list_Keymap) {
		XSSFWorkbook workbook = null;
		File fullpath = null;

		String fileSeparator = System.getProperty("file.separator");
		String fileName = exeType;

		try {
			if((exeType.equalsIgnoreCase("SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN"))){
				fileName = "AUTOGEN_"+exeType;
			}
			fullpath = new File(path + fileSeparator+ "Template_" + fileName+".xlsx");
			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + fileName+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");      

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_2 = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정   
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정   
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.LEFT);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_2.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_2.setBorderRight(BorderStyle.THIN);              //테두리 설정   
		contentStyle_2.setBorderLeft(BorderStyle.THIN);
		contentStyle_2.setBorderTop(BorderStyle.THIN);
		contentStyle_2.setBorderBottom(BorderStyle.THIN);
		contentStyle_2.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_2.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_2.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		if(list.size() > 0)
			for(int i=2; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}

		if(exeType.equalsIgnoreCase("KEYMAP")) {
			for(int i=0; i<list.size(); i++) {
				PiiStepTableWithWaitVO piisteptable = list.get(i);

				// 행 생성
				bodyRow = sheet.createRow(i+2);
				// 데이터 번호 표시
				bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(piisteptable.getJobid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(piisteptable.getVersion());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(piisteptable.getStepid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(piisteptable.getKeymap_id());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(piisteptable.getKey_name());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(piisteptable.getPk_col());bodyCell.setCellStyle(contentStyle);
				//bodyCell = bodyRow.createCell(6); bodyCell.setCellValue(piisteptable.getSeq1());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7-1); bodyCell.setCellValue(piisteptable.getSeq2());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(8-1); bodyCell.setCellValue(piisteptable.getSeq3());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(9-1);bodyCell.setCellValue(piisteptable.getKey_cols());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(10-1);bodyCell.setCellValue(piisteptable.getDb());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(11-1);bodyCell.setCellValue(piisteptable.getOwner());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(12-1);bodyCell.setCellValue(piisteptable.getTable_name());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(13-1); bodyCell.setCellValue(piisteptable.getWhere_col());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(14-1); bodyCell.setCellValue(piisteptable.getWhere_key_name());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(15-1); bodyCell.setCellValue(piisteptable.getParallelcnt());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(16-1); bodyCell.setCellValue(piisteptable.getSqltype());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(17-1); bodyCell.setCellValue(piisteptable.getSqlstr());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(18-1); bodyCell.setCellValue(piisteptable.getWherestr());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(19-1); bodyCell.setCellValue(piisteptable.getKey_refstr());bodyCell.setCellStyle(contentStyle);
			}
		}
		else if(exeType.equalsIgnoreCase("EXTRACT")) {
			for(int i=0; i<list.size(); i++) {
				PiiStepTableWithWaitVO piisteptable = list.get(i);
				// 행 생성
				bodyRow = sheet.createRow(i+2);
				// 데이터 번호 표시
				bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(piisteptable.getJobid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(piisteptable.getVersion());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(piisteptable.getStepid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(piisteptable.getDb());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(piisteptable.getPagitypedetail());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(piisteptable.getPk_col());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(piisteptable.getExetype());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7); bodyCell.setCellValue(piisteptable.getSeq2());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getSqlstr());bodyCell.setCellStyle(contentStyle);
			}
		}
		else {
			for(int i=0; i<list.size(); i++) {
				PiiStepTableWithWaitVO piisteptable = list.get(i);

				// 행 생성
				bodyRow = sheet.createRow(i+2);
				// 데이터 번호 표시
				bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(piisteptable.getJobid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(piisteptable.getVersion());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(piisteptable.getStepid());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(piisteptable.getDb());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(piisteptable.getOwner());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(piisteptable.getTable_name());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(piisteptable.getExetype());bodyCell.setCellStyle(contentStyle);
				//bodyCell = bodyRow.createCell(7); bodyCell.setCellValue(piisteptable.getSeq1());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7); bodyCell.setCellValue(piisteptable.getSeq2());bodyCell.setCellStyle(contentStyle);
				//bodyCell = bodyRow.createCell(9); bodyCell.setCellValue(piisteptable.getSeq3());bodyCell.setCellStyle(contentStyle);
				if(exeType.equalsIgnoreCase("DELETE") || exeType.equalsIgnoreCase("UPDATE")){
					bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getPk_col());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(9); bodyCell.setCellValue(piisteptable.getWhere_col());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(10); bodyCell.setCellValue(piisteptable.getWhere_key_name());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(11); bodyCell.setCellValue(piisteptable.getParallelcnt());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(12); bodyCell.setCellValue(piisteptable.getCommitcnt());bodyCell.setCellStyle(contentStyle);
				}else if(exeType.equalsIgnoreCase("SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN")){
					bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getPk_col());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(9); bodyCell.setCellValue(piisteptable.getWhere_col());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(10); bodyCell.setCellValue(piisteptable.getWhere_key_name());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(11); bodyCell.setCellValue(piisteptable.getWherestr());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(12); bodyCell.setCellValue(piisteptable.getSqltype());bodyCell.setCellStyle(contentStyle);
				}else if(exeType.equalsIgnoreCase("MIGRATE") || (exeType.equalsIgnoreCase("SCRAMBLE") && !jobid.startsWith("TESTDATA_AUTO_GEN"))){
					bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getPk_col()); bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(9); bodyCell.setCellValue(piisteptable.getPipeline()); bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(10); bodyCell.setCellValue(piisteptable.getPreceding()); bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(11); bodyCell.setCellValue(piisteptable.getPagitypedetail()); bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(12); bodyCell.setCellValue(piisteptable.getWherestr()); bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(13); bodyCell.setCellValue(piisteptable.getHintselect()); bodyCell.setCellStyle(contentStyle);
				}else if(exeType.equalsIgnoreCase("FINISH")){
					bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getSqlstr());bodyCell.setCellStyle(contentStyle);
				}else if(exeType.equalsIgnoreCase("BROADCAST")){
					bodyCell = bodyRow.createCell(8); bodyCell.setCellValue(piisteptable.getWherestr());bodyCell.setCellStyle(contentStyle);
				}

				if(exeType.equalsIgnoreCase("UPDATE")){
					bodyCell = bodyRow.createCell(13); bodyCell.setCellValue(piisteptable.getUpdates());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(14); bodyCell.setCellValue(piisteptable.getPagitypedetail());bodyCell.setCellStyle(contentStyle);
				}else if(exeType.equalsIgnoreCase("DELETE")){
					bodyCell = bodyRow.createCell(13); bodyCell.setCellValue(piisteptable.getOwner_w());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(14); bodyCell.setCellValue(piisteptable.getTable_name_w());bodyCell.setCellStyle(contentStyle);
					bodyCell = bodyRow.createCell(15); bodyCell.setCellValue(piisteptable.getPagitypedetail());bodyCell.setCellStyle(contentStyle);
				}

			}
		}

		if(exeType.equalsIgnoreCase("DELETE") || exeType.equalsIgnoreCase("UPDATE") || (exeType.equalsIgnoreCase("SCRAMBLE") && jobid.startsWith("TESTDATA_AUTO_GEN"))){
			sheet = workbook.getSheetAt(1);
			//  내용 행 및 셀 생성
			bodyRow = null;
			bodyCell = null;

			if(list_Keymap.size() > 0)
				for(int i=1; i<100; i++) {
					try {
						sheet.removeRow(sheet.getRow(i));
					} catch (Exception e) {
						LogUtil.log("INFO", "Can't removeRow => "+i);
						//e.printStackTrace();
						break;
					}

				}
			for(int i=0; i<list_Keymap.size(); i++) {
				PiiConfKeymapRefVO keymapvo = list_Keymap.get(i);
				// 행 생성
				bodyRow = sheet.createRow(i+1);
				// 데이터 번호 표시
				bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(keymapvo.getKey_cols());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(keymapvo.getKey_name());bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(keymapvo.getPk_col());bodyCell.setCellStyle(contentStyle);

			}
		}

		return workbook;
	}

	@Override
	public XSSFWorkbook makeMetadataExcelTemplate(String path, String exeType, List<MetaTableVO> list) {logger.warn("warn "+"list.size => "+list.size());
		XSSFWorkbook workbook = null;
		File fullpath = null;
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_2 = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.LEFT);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_2.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_2.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_2.setBorderLeft(BorderStyle.THIN);
		contentStyle_2.setBorderTop(BorderStyle.THIN);
		contentStyle_2.setBorderBottom(BorderStyle.THIN);
		contentStyle_2.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_2.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_2.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		if(list.size() > 0)
			for(int i=2; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}

		for(int i=0; i<list.size(); i++) {
			MetaTableVO metatable = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+2);
			// 데이터 번호 표시

			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(i+1);bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(metatable.getDb());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(metatable.getOwner());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(metatable.getTable_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(metatable.getColumn_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(metatable.getColumn_comment());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(metatable.getColumn_id());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(metatable.getPk_yn());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(metatable.getData_type());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(9);bodyCell.setCellValue(metatable.getData_length());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(10);bodyCell.setCellValue(metatable.getDomain());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(metatable.getEncript_flag());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(metatable.getPiigrade());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(13);bodyCell.setCellValue(metatable.getPiitype());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14);bodyCell.setCellValue(metatable.getScramble_type());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(15);bodyCell.setCellValue(metatable.getMasterkey());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(16);bodyCell.setCellValue(metatable.getMasteryn());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(17);bodyCell.setCellValue(metatable.getVal1());bodyCell.setCellStyle(contentStyle);
		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeMetadataGapExcelTemplate(String path, String exeType, List<MetaTableGapVO> list) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_2 = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.LEFT);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_2.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_2.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_2.setBorderLeft(BorderStyle.THIN);
		contentStyle_2.setBorderTop(BorderStyle.THIN);
		contentStyle_2.setBorderBottom(BorderStyle.THIN);
		contentStyle_2.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_2.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_2.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		if(list.size() > 0)
			for(int i=2; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}

		for(int i=0; i<list.size(); i++) {
			MetaTableGapVO metatable = list.get(i);
			LogUtil.log("INFO", metatable.toString());
			// 행 생성
			bodyRow = sheet.createRow(i+2);
			// 데이터 번호 표시

			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(i+1);bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(metatable.getDb());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(metatable.getOwner());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(metatable.getTable_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(metatable.getColumn_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(metatable.getColumn_comment());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(metatable.getColumn_id());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(metatable.getPk_yn());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(metatable.getData_type());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(9);bodyCell.setCellValue(metatable.getData_length());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(10);bodyCell.setCellValue(metatable.getDomain());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(metatable.getPiitype());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(metatable.getPiigrade());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(13);bodyCell.setCellValue(metatable.getEncript_flag());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14);bodyCell.setCellValue(metatable.getScramble_type());bodyCell.setCellStyle(contentStyle);

			bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(metatable.getEncript_flag());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(metatable.getPiigrade());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(13);bodyCell.setCellValue(metatable.getPiitype());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14);bodyCell.setCellValue(metatable.getScramble_type());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(15);bodyCell.setCellValue(metatable.getVal1());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(16);bodyCell.setCellValue(metatable.getJobid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(17);bodyCell.setCellValue(metatable.getConfregdate());bodyCell.setCellStyle(contentStyle);
		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeCustHistoryExcel(Locale locale,String path, String exeType, List<PiiExtractVO> list, Criteria cri, String username) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();
		CellStyle contentStyle_L = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 오른정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_L.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_L.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_L.setBorderLeft(BorderStyle.THIN);
		contentStyle_L.setBorderTop(BorderStyle.THIN);
		contentStyle_L.setBorderBottom(BorderStyle.THIN);
		contentStyle_L.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_L.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_L.setFont(contentFont);
		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("memu.report_cust_list" , null, "PII_destruction_history", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.custid" , null, "CustID", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); if(!StrUtil.checkString(cri.getSearch1())) titleCell.setCellValue(cri.getSearch1());
		titleCell = titleRow.getCell(4); titleCell.setCellValue(messageSource.getMessage("col.cust_nm" , null, "Custname", locale.KOREA) +" :");
		titleCell = titleRow.getCell(5); if(!StrUtil.checkString(cri.getSearch2())) titleCell.setCellValue(cri.getSearch2()+"");
		titleCell = titleRow.getCell(11); titleCell.setCellValue(messageSource.getMessage("col.birth_dt" , null, "Birthdate", locale.KOREA) +" :");
		titleCell = titleRow.getCell(12); if(!StrUtil.checkString(cri.getSearch3())) titleCell.setCellValue(cri.getSearch3()+"");
		titleCell = titleRow.getCell(18); titleCell.setCellValue(messageSource.getMessage("etc.print_user" , null, "Print user", locale.KOREA) +" :");
		titleCell = titleRow.getCell(19); if(!StrUtil.checkString(username)) titleCell.setCellValue(username);

		titleRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
		String period = "  ";
		if(!StrUtil.checkString(cri.getSearch4())){
			period = cri.getSearch4();
		}
		if(!StrUtil.checkString(cri.getSearch5())){
			period = period +"~"+cri.getSearch5();
		}
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.period" , null, "Period", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(period);
		titleCell = titleRow.getCell(4); titleCell.setCellValue(messageSource.getMessage("etc.pii_reason" , null, "PII reason", locale.KOREA) +" :");
		titleCell = titleRow.getCell(5); if(!StrUtil.checkString(cri.getSearch7())) titleCell.setCellValue(cri.getSearch7()+"");

//		titleCell = titleRow.getCell(11); titleCell.setCellValue(messageSource.getMessage("col.pii_status" , null, "PII Status", locale.KOREA) +" :");
		//		아래 라인 추가하면...boundary 에러가 난다...일단 필요없어서 코멘트 처리함
//		titleCell = titleRow.getCell(12); if(!StrUtil.checkString(cri.getSearch8())) titleCell.setCellValue(cri.getSearch8()+"");logger.warn("warn "+"3  "+cri.toString());



		// 헤더 행 생성
		Row headerRow = sheet.getRow(4);

		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(0); headerCell.setCellValue(messageSource.getMessage("col.custid" , null, "Custid", locale));
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("col.cust_nm" , null, "Cust_Nm", locale));
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("col.birth_dt" , null, "Birth_dt", locale));
		headerCell = headerRow.getCell(3); headerCell.setCellValue(messageSource.getMessage("col.last_base_date" , null, "Close date", locale));
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("etc.pii_reason" , null, "PII reason", locale));
		headerCell = headerRow.getCell(5); headerCell.setCellValue(messageSource.getMessage("etc.del_contents" , null, "Deleted contents", locale));

		headerCell = headerRow.getCell(11); headerCell.setCellValue(messageSource.getMessage("etc.progress_classification" , null, "Progress classification", locale));
		headerCell = headerRow.getCell(12); headerCell.setCellValue(messageSource.getMessage("etc.datatype" , null, "Data type", locale));
		headerCell = headerRow.getCell(13); headerCell.setCellValue(messageSource.getMessage("col.archive_date" , null, "Archive_Date", locale));
		headerCell = headerRow.getCell(14); headerCell.setCellValue(messageSource.getMessage("col.delete_date" , null, "Delete_Date", locale));
		headerCell = headerRow.getCell(15); headerCell.setCellValue(messageSource.getMessage("col.restore_date" , null, "Restore_Date", locale));
		headerCell = headerRow.getCell(16); headerCell.setCellValue(messageSource.getMessage("col.expected_arc_del_date" , null, "Expected_Archive_Date", locale));
		headerCell = headerRow.getCell(17); headerCell.setCellValue(messageSource.getMessage("col.arc_del_date" , null, "Arc_del_date", locale));
		headerCell = headerRow.getCell(18); headerCell.setCellValue(messageSource.getMessage("etc.person_in_charge" , null, "Person in charge", locale));
		headerCell = headerRow.getCell(19); headerCell.setCellValue(messageSource.getMessage("etc.head_in_charge" , null, "Head in charge", locale));
		// 헤더 행 생성
		headerRow = sheet.getRow(5);

		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell2 = null;
		headerCell2 = headerRow.getCell(5); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind1" , null, "Unique identification", locale));
		headerCell2 = headerRow.getCell(6); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind2" , null, "General personal", locale));
		headerCell2 = headerRow.getCell(7); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind3" , null, "Credit transaction", locale));
		headerCell2 = headerRow.getCell(8); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind4" , null, "Credit capability", locale));
		headerCell2 = headerRow.getCell(9); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind5" , null, "Credit judgment", locale));
		headerCell2 = headerRow.getCell(10); headerCell2.setCellValue(messageSource.getMessage("etc.pii_kind6" , null, "Public information, etc.", locale));

		// 내용 행 및 셀 생성
		for(int i=0; i<list.size(); i++) {
			PiiExtractVO piiextract = list.get(i);
			// 행 생성
			bodyRow = sheet.createRow(i+6);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(piiextract.getCustid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(piiextract.getCust_nm());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getBirth_dt()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(piiextract.getLast_base_date());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(4);
			if("PII_POLICY1".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy1_title" , null, "Only sign up customer", locale));}
			else if("PII_POLICY2".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy2_title" , null, "Unconfirmed customer", locale));}
			else if("PII_POLICY3".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy3_title" , null, "Termination of transaction customer", locale));}
			bodyCell.setCellStyle(contentStyle_L);
			if("PII_POLICY1".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(6);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(8);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(9);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(10);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(messageSource.getMessage("etc.customer_registration" , null, "Customer registration", locale));bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(messageSource.getMessage("etc.customer_registration_file" , null, "Customer registration files", locale));bodyCell.setCellStyle(contentStyle);
			}
			else if("PII_POLICY2".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(6);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(8);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(9);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(10);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(messageSource.getMessage("etc.counseling" , null, "Counseling", locale));bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(messageSource.getMessage("etc.counseling_file" , null, "Counseling files", locale));bodyCell.setCellStyle(contentStyle);
			}
			else if("PII_POLICY3".equalsIgnoreCase(piiextract.getJobid().substring(0,11))) {
				bodyCell = bodyRow.createCell(5);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(6);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(7);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(8);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(9);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(10);bodyCell.setCellValue("O");bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(messageSource.getMessage("etc.contract" , null, "Contract", locale));bodyCell.setCellStyle(contentStyle);
				bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(messageSource.getMessage("etc.contract_file" , null, "Contract files", locale));bodyCell.setCellStyle(contentStyle);
			}

			bodyCell = bodyRow.createCell(13);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getArchive_date()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getDelete_date()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(15);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getRestore_date()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(16);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getExpected_arc_del_date()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(17);bodyCell.setCellValue(StrUtil.changeNotNull(piiextract.getArc_del_date()));bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(18);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(19);bodyCell.setCellValue("");bodyCell.setCellStyle(contentStyle);
		}

		return workbook;
	}

	@Override
	public XSSFWorkbook makeCustStatExcel(Locale locale,String path, String exeType, List<PiiCustStatVO> list, Criteria cri, String username) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		DecimalFormat decFormat = new DecimalFormat("###,###");
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();
		CellStyle contentStyle_L = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 오른정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_L.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_L.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_L.setBorderLeft(BorderStyle.THIN);
		contentStyle_L.setBorderTop(BorderStyle.THIN);
		contentStyle_L.setBorderBottom(BorderStyle.THIN);
		contentStyle_L.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_L.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_L.setFont(contentFont);
		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("menu.pii_pagi_stat" , null, "PII Processing Report", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0);
		titleCell.setCellValue(messageSource.getMessage("etc.report_type" , null, "Report type", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1);
		String period = null;
		if("MONTHLY".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4();
			titleCell.setCellValue(messageSource.getMessage("etc.monthly_report" , null, "Monthly report", locale.KOREA));
		}else if("QUARTERLY".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4() + " ~ " +cri.getSearch5();
			titleCell.setCellValue(messageSource.getMessage("etc.annual_report" , null, "Annually report", locale.KOREA));
		}else if("MONTHLY_CONSENT".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4();
			titleCell.setCellValue(messageSource.getMessage("etc.monthly_report_consent" , null, "Monthly report(Consent form)", locale.KOREA));
		}

		titleCell = titleRow.getCell(8); titleCell.setCellValue(messageSource.getMessage("etc.print_user" , null, "Print user", locale.KOREA) +" :");
		titleCell = titleRow.getCell(9); titleCell.setCellValue(username);

		titleRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
//		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.report_organization_unit" , null, "Organization unit", locale.KOREA) +" :");
//		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch7());
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.period" , null, "Period", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(period);
		titleCell = titleRow.getCell(8); titleCell.setCellValue(messageSource.getMessage("etc.print_date" , null, "Print date", locale.KOREA) +" :");
		Date today = new Date();
		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		String curdate = yyyymmdd.format(today);
		titleCell = titleRow.getCell(9); titleCell.setCellValue(curdate);
		// 헤더 행 생성
		Row headerRow = sheet.getRow(4);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(0); headerCell.setCellValue(messageSource.getMessage("etc.criteria" , null, "Criteria", locale.KOREA));;
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("etc.policy1_title" , null, "Only sign up customer", locale.KOREA));;
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("etc.policy2_title" , null, "Unconfirmed customer", locale.KOREA));;
		headerCell = headerRow.getCell(7); headerCell.setCellValue(messageSource.getMessage("etc.policy3_title" , null, "Termination of transaction customer", locale.KOREA));;

		headerRow = sheet.getRow(5);
		// 해당 행의 첫번째 열 셀 생성
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("etc.archive_cnt" , null, "Archive_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("etc.restore_cnt" , null, "Restore_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(3); headerCell.setCellValue(messageSource.getMessage("etc.arc_del_cnt" , null, "Arc_del_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("etc.archive_cnt" , null, "Archive_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(5); headerCell.setCellValue(messageSource.getMessage("etc.restore_cnt" , null, "Restore_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(6); headerCell.setCellValue(messageSource.getMessage("etc.arc_del_cnt" , null, "Arc_del_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(7); headerCell.setCellValue(messageSource.getMessage("etc.archive_cnt" , null, "Archive_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(8); headerCell.setCellValue(messageSource.getMessage("etc.restore_cnt" , null, "Restore_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(9); headerCell.setCellValue(messageSource.getMessage("etc.arc_del_cnt" , null, "Arc_del_Cnt", locale.KOREA));;

		int archive_cnt1=0;
		int restore_cnt1=0;
		int arc_del_cnt1=0;
		int archive_cnt2=0;
		int restore_cnt2=0;
		int arc_del_cnt2=0;
		int archive_cnt3=0;
		int restore_cnt3=0;
		int arc_del_cnt3=0;
		for(int i=0; i<list.size(); i++) {
			PiiCustStatVO vo = list.get(i);
			archive_cnt1 += vo.getArchive_cnt1();
			restore_cnt1 += vo.getRestore_cnt1();
			arc_del_cnt1 += vo.getArc_del_cnt1();

			archive_cnt2 += vo.getArchive_cnt2();
			restore_cnt2 += vo.getRestore_cnt2();
			arc_del_cnt2 += vo.getArc_del_cnt2();

			archive_cnt3 += vo.getArchive_cnt3();
			restore_cnt3 += vo.getRestore_cnt3();
			arc_del_cnt3 += vo.getArc_del_cnt3();
		}

		// 행 생성
		bodyRow = sheet.getRow(6);
		// 데이터 번호 표시
		bodyCell = bodyRow.getCell(0);
		bodyCell.setCellValue(messageSource.getMessage("etc.sum", null, "Sum", locale.KOREA));
		bodyCell = bodyRow.getCell(1);bodyCell.setCellValue(decFormat.format(archive_cnt1));
		bodyCell = bodyRow.getCell(2);bodyCell.setCellValue(decFormat.format(restore_cnt1));
		bodyCell = bodyRow.getCell(3);bodyCell.setCellValue(decFormat.format(arc_del_cnt1));
		bodyCell = bodyRow.getCell(4);bodyCell.setCellValue(decFormat.format(archive_cnt2));
		bodyCell = bodyRow.getCell(5);bodyCell.setCellValue(decFormat.format(restore_cnt2));
		bodyCell = bodyRow.getCell(6);bodyCell.setCellValue(decFormat.format(arc_del_cnt2));
		bodyCell = bodyRow.getCell(7);bodyCell.setCellValue(decFormat.format(archive_cnt3));
		bodyCell = bodyRow.getCell(8);bodyCell.setCellValue(decFormat.format(restore_cnt3));
		bodyCell = bodyRow.getCell(9);bodyCell.setCellValue(decFormat.format(arc_del_cnt3));

		for(int i=0; i<list.size(); i++) {
			PiiCustStatVO vo = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+7);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(vo.getMon());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(decFormat.format(vo.getArchive_cnt1()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(decFormat.format(vo.getRestore_cnt1()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(decFormat.format(vo.getArc_del_cnt1()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(decFormat.format(vo.getArchive_cnt2()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(decFormat.format(vo.getRestore_cnt2()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(decFormat.format(vo.getArc_del_cnt2()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(decFormat.format(vo.getArchive_cnt3()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(decFormat.format(vo.getRestore_cnt3()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(9);bodyCell.setCellValue(decFormat.format(vo.getArc_del_cnt3()));bodyCell.setCellStyle(contentStyle_R);
		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeCustStatConsentExcel(Locale locale,String path, String exeType, List<PiiCustStatConsentVO> list, Criteria cri, String username) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		DecimalFormat decFormat = new DecimalFormat("###,###");
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();
		CellStyle contentStyle_L = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);
		logger.warn("warn "+"@@ 2");
		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 오른정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_L.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_L.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_L.setBorderLeft(BorderStyle.THIN);
		contentStyle_L.setBorderTop(BorderStyle.THIN);
		contentStyle_L.setBorderBottom(BorderStyle.THIN);
		contentStyle_L.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_L.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_L.setFont(contentFont);
		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("menu.pii_pagi_stat" , null, "PII Processing Report", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0);
		String period = null;
		if("MONTHLY".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4();
			titleCell.setCellValue(messageSource.getMessage("etc.report_type" , null, "Report type", locale.KOREA) +" : " + messageSource.getMessage("etc.monthly_report" , null, "Monthly report", locale.KOREA));
		}else if("QUARTERLY".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4() + " ~ " +cri.getSearch5();
			titleCell.setCellValue(messageSource.getMessage("etc.report_type" , null, "Report type", locale.KOREA) +" : " + messageSource.getMessage("etc.annual_report" , null, "Annually report", locale.KOREA));
		}else if("MONTHLY_CONSENT".equalsIgnoreCase(cri.getSearch6())){ period = cri.getSearch4();
			titleCell.setCellValue(messageSource.getMessage("etc.report_type" , null, "Report type", locale.KOREA) +" : " + messageSource.getMessage("etc.monthly_report_consent" , null, "Monthly report(Consent form)", locale.KOREA));
		}
		titleCell = titleRow.getCell(2);
		titleCell.setCellValue(messageSource.getMessage("etc.print_user" , null, "Print user", locale.KOREA) +" : " + username);

		titleRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
//		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.report_organization_unit" , null, "Organization unit", locale.KOREA) +" :");
//		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch7());
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("etc.period" , null, "Period", locale.KOREA) +" : " +period);

		Date today = new Date();
		SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
		String curdate = yyyymmdd.format(today);
		titleCell = titleRow.getCell(2); titleCell.setCellValue(messageSource.getMessage("etc.print_date" , null, "Print date", locale.KOREA) +" : " +curdate);
		// 헤더 행 생성
		Row headerRow = sheet.getRow(5);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("etc.archive_cnt" , null, "Archive_Cnt", locale.KOREA));;
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("etc.arc_del_cnt" , null, "Arc_del_Cnt", locale.KOREA));;
		for(int i=0; i<list.size(); i++) {
			PiiCustStatConsentVO vo = list.get(i);
			// 행 생성
			bodyRow = sheet.createRow(i+6);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(vo.getMon());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(decFormat.format(vo.getArccnt()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(decFormat.format(vo.getDelarccnt()));bodyCell.setCellStyle(contentStyle_R);
		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeRealDocMgmtExcel(Locale locale,String path, String exeType, List<PiiContractVO> list, Criteria cri) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

/*		if(list.size() > 0)
			for(int i=5; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}*/



		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("menu.real_doc_del_mgmt" , null, "Document destruction management", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(1);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.custid" , null, "CUSTID", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch1());

		titleCell = titleRow.getCell(7); titleCell.setCellValue(messageSource.getMessage("col.dept_name" , null, "Department", locale.KOREA) +" :");
		titleCell = titleRow.getCell(8); titleCell.setCellValue(cri.getSearch2());

		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.status" , null, "Status", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1);
		if("Y".equalsIgnoreCase(cri.getSearch3())){
			titleCell.setCellValue(messageSource.getMessage("etc.real_doc_del_complete" , null,"Document destruction completed" , locale.KOREA));
		}else if("N".equalsIgnoreCase(cri.getSearch3())){
			titleCell.setCellValue(messageSource.getMessage("etc.real_doc_del_not_complete" , null,"Document destruction not completed" , locale.KOREA));
		}else{
			titleCell.setCellValue("");
		}

		titleCell = titleRow.getCell(7); titleCell.setCellValue(messageSource.getMessage("col.arc_del_date" , null, "Destruct Date", locale.KOREA) +" :");
		titleCell = titleRow.getCell(8); titleCell.setCellValue(cri.getSearch4());
		titleCell = titleRow.getCell(9); titleCell.setCellValue(" ~ ");
		titleCell = titleRow.getCell(10); titleCell.setCellValue(cri.getSearch5());

		// 헤더 행 생성
		Row headerRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(0); headerCell.setCellValue(messageSource.getMessage("col.custid" , null,"Custid" , locale.KOREA));
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("col.contractno" , null,"Contractno" , locale.KOREA));
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("col.dept_cd" , null,"Dept_Cd" , locale.KOREA));
		headerCell = headerRow.getCell(3); headerCell.setCellValue(messageSource.getMessage("col.dept_name" , null,"Dept_Name" , locale.KOREA));
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("col.contract_opn_dt" , null,"Contract_Opn_Dt" , locale.KOREA));
		headerCell = headerRow.getCell(5); headerCell.setCellValue(messageSource.getMessage("col.contract_close_dt" , null,"Contract_Close_Dt" , locale.KOREA));
		headerCell = headerRow.getCell(6); headerCell.setCellValue(messageSource.getMessage("col.pd_cd" , null,"Pd_Cd" , locale.KOREA));
		headerCell = headerRow.getCell(7); headerCell.setCellValue(messageSource.getMessage("col.pd_nm" , null,"Pd_Nm" , locale.KOREA));
		headerCell = headerRow.getCell(8); headerCell.setCellValue(messageSource.getMessage("col.status" , null,"Status" , locale.KOREA));
		headerCell = headerRow.getCell(9); headerCell.setCellValue(messageSource.getMessage("col.rsdnt_altrntv_id" , null,"Rsdnt_Altrntv_Id" , locale.KOREA));
		headerCell = headerRow.getCell(10); headerCell.setCellValue(messageSource.getMessage("col.cust_nm" , null,"Cust_Nm" , locale.KOREA));
		headerCell = headerRow.getCell(11); headerCell.setCellValue(messageSource.getMessage("col.birth_dt" , null,"Birth_Dt" , locale.KOREA));
		headerCell = headerRow.getCell(12); headerCell.setCellValue(messageSource.getMessage("col.archive_date" , null,"Archive_Date" , locale.KOREA));
		headerCell = headerRow.getCell(13); headerCell.setCellValue(messageSource.getMessage("col.arc_del_date" , null,"Arc_Del_Date" , locale.KOREA));
		headerCell = headerRow.getCell(14); headerCell.setCellValue(messageSource.getMessage("col.real_doc_del_date" , null,"Real_Doc_Del_Date" , locale.KOREA));
		headerCell = headerRow.getCell(15); headerCell.setCellValue(messageSource.getMessage("col.real_doc_del_userid" , null,"Real_Doc_Del_Userid" , locale.KOREA));
		for(int i=0; i<list.size(); i++) {
			PiiContractVO vo = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+4);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(vo.getCustid());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(vo.getContractno());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(vo.getDept_cd());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(vo.getDept_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(vo.getContract_opn_dt());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(vo.getContract_close_dt());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(vo.getPd_cd());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(vo.getPd_nm());bodyCell.setCellStyle(contentStyle);
			if("Y".equalsIgnoreCase(vo.getStatus())){
				bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(messageSource.getMessage("etc.real_doc_del_complete" , null,"Document destruction completed" , locale.KOREA));bodyCell.setCellStyle(contentStyle);
			}else{
				bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(messageSource.getMessage("etc.real_doc_del_not_complete" , null,"Document destruction not completed" , locale.KOREA));bodyCell.setCellStyle(contentStyle);
			}
			bodyCell = bodyRow.createCell(9);bodyCell.setCellValue(vo.getRsdnt_altrntv_id());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(10);bodyCell.setCellValue(vo.getCust_nm());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(11);bodyCell.setCellValue(vo.getBirth_dt());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(12);bodyCell.setCellValue(vo.getArchive_date());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(13);bodyCell.setCellValue(vo.getArc_del_date());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(14);bodyCell.setCellValue(vo.getReal_doc_del_date());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(15);bodyCell.setCellValue(vo.getReal_doc_del_userid());bodyCell.setCellStyle(contentStyle);
		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeRealDocStatExcel(Locale locale,String path, String exeType, List<PiiContractStatVO> list, Criteria cri) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		DecimalFormat decFormat = new DecimalFormat("###,###");
		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}

		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

/*		if(list.size() > 0)
			for(int i=5; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}*/



		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("menu.month_real_doc_pagi_stat" , null, "Monthly document destruction status", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(1);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.dept_name" , null, "Department", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch2());

		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.arc_del_date" , null, "Destruct Date", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch4()+" ~ "+cri.getSearch5());

		// 헤더 행 생성
		Row headerRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(0); headerCell.setCellValue(messageSource.getMessage("etc.pagi_month" , null,"Month" , locale.KOREA));
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("col.dept_cd" , null,"Dept_Cd" , locale.KOREA));
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("col.dept_name" , null,"Dept_Name" , locale.KOREA));
		headerCell = headerRow.getCell(3); headerCell.setCellValue(messageSource.getMessage("etc.real_doc_del_all_cnt" , null,"All cnt" , locale.KOREA));
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("etc.real_doc_del_not_complete_cnt" , null,"Not completed cnt" , locale.KOREA));
		headerCell = headerRow.getCell(5); headerCell.setCellValue(messageSource.getMessage("etc.real_doc_del_complete_cnt" , null,"completed cnt" , locale.KOREA));
		headerCell = headerRow.getCell(6); headerCell.setCellValue(messageSource.getMessage("etc.real_doc_del_ratio" , null,"Progress ratio" , locale.KOREA));

		for(int i=0; i<list.size(); i++) {
			PiiContractStatVO vo = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+4);
			// 데이터 번호 표시
			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(vo.getMon());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(vo.getMgmt_dept_cd());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(vo.getMgmt_dept_name());bodyCell.setCellStyle(contentStyle);
			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(decFormat.format(vo.getAcount()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(decFormat.format(vo.getNcount()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(decFormat.format(vo.getYcount()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(vo.getProgress());bodyCell.setCellStyle(contentStyle_R);

		}

		return workbook;
	}

	@Override
	public XSSFWorkbook makeTableDelStatExcel(Locale locale,String path, String exeType, List<PiiOrderReportVO> list, Criteria cri) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		DecimalFormat decFormat = new DecimalFormat("###,###");

		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}
		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();
		CellStyle contentStyle_L = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);
		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_L.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_L.setBorderLeft(BorderStyle.THIN);
		contentStyle_L.setBorderTop(BorderStyle.THIN);
		contentStyle_L.setBorderBottom(BorderStyle.THIN);
		contentStyle_L.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_L.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_L.setFont(contentFont);

		// 내용 행 및 셀 생성
		Row bodyRow = null;
		Cell bodyCell = null;

/*		if(list.size() > 0)
			for(int i=5; i<100; i++) {
				try {
					sheet.removeRow(sheet.getRow(i));
				} catch (Exception e) {
					LogUtil.log("INFO", "Can't removeRow => "+i);
					//e.printStackTrace();
					break;
				}

			}*/



		// 타이블 행 생성
		Row titleRow = sheet.getRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell titleCell = null;
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("memu.table_del_stat" , null, "Table destruction report", locale.KOREA));

		// 검색 조건 행
		titleRow = sheet.getRow(1);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.system" , null, "System", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch1());
		titleCell = titleRow.getCell(5); titleCell.setCellValue(messageSource.getMessage("col.jobid" , null, "JOBID", locale.KOREA) +" :");
		titleCell = titleRow.getCell(6); titleCell.setCellValue(cri.getSearch2());

		titleRow = sheet.getRow(2);
		// 해당 행의 첫번째 열 셀 생성
		titleCell = titleRow.getCell(0); titleCell.setCellValue(messageSource.getMessage("col.basedate" , null, "Basedate", locale.KOREA) +" :");
		titleCell = titleRow.getCell(1); titleCell.setCellValue(cri.getSearch3()+" ~ "+cri.getSearch4());

		// 헤더 행 생성
		Row headerRow = sheet.getRow(3);
		// 해당 행의 첫번째 열 셀 생성
		Cell headerCell = null;
		headerCell = headerRow.getCell(0); headerCell.setCellValue(messageSource.getMessage("col.system" , null, "System", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(1); headerCell.setCellValue(messageSource.getMessage("col.jobid" , null, "Jobid", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(2); headerCell.setCellValue(messageSource.getMessage("etc.pii_reason" , null, "PII reason", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(3); headerCell.setCellValue(messageSource.getMessage("col.db" , null, "DB", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(4); headerCell.setCellValue(messageSource.getMessage("col.owner" , null, "Owner", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(5); headerCell.setCellValue(messageSource.getMessage("col.table_name" , null, "Table_name", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(6); headerCell.setCellValue(messageSource.getMessage("etc.delcnt" , null, "Delcnt", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(7); headerCell.setCellValue(messageSource.getMessage("col.arccnt" , null, "Arccnt", locale));headerCell.setCellStyle(cellStyle);
		headerCell = headerRow.getCell(8); headerCell.setCellValue(messageSource.getMessage("col.arc_del_cnt" , null, "ArcDelcnt", locale));headerCell.setCellStyle(cellStyle);
		// 내용 행 및 셀 생성
		for(int i=0; i<list.size(); i++) {
			PiiOrderReportVO vo = list.get(i);

			// 행 생성
			bodyRow = sheet.createRow(i+4);
			// 데이터 번호 표시

			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(vo.getSystem());bodyCell.setCellStyle(contentStyle_L);
			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(vo.getJobid());bodyCell.setCellStyle(contentStyle_L);
			bodyCell = bodyRow.createCell(2);
			if("PII_POLICY1".equalsIgnoreCase(vo.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy1_title" , null, "Only sign up customer", locale));}
			else if("PII_POLICY2".equalsIgnoreCase(vo.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy2_title" , null, "Unconfirmed customer", locale));}
			else if("PII_POLICY3".equalsIgnoreCase(vo.getJobid().substring(0,11))) {bodyCell.setCellValue(messageSource.getMessage("etc.policy3_title" , null, "Termination of transaction customer", locale));}
			bodyCell.setCellStyle(contentStyle_L);

			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(vo.getDb());bodyCell.setCellStyle(contentStyle_L);
			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(vo.getOwner());bodyCell.setCellStyle(contentStyle_L);
			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(vo.getTable_name());bodyCell.setCellStyle(contentStyle_L);
			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(decFormat.format(vo.getDelcnt()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(decFormat.format(vo.getArccnt()));bodyCell.setCellStyle(contentStyle_R);
			bodyCell = bodyRow.createCell(8);bodyCell.setCellValue(decFormat.format(vo.getDelarccnt()));bodyCell.setCellStyle(contentStyle_R);

		}

		return workbook;
	}
	@Override
	public XSSFWorkbook makeQueryResultExcel(Locale locale,String query,String path, String exeType, ResultSetMetaData rsmd, ResultSet rs) {
		XSSFWorkbook workbook = null;
		File fullpath = null;

		String fileSeparator = System.getProperty("file.separator");
		try {
			fullpath = new File(path + fileSeparator+ "Template_" + exeType+".xlsx");

			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn "+"Can't find the file => "+path + fileSeparator+ "Template_" + exeType+".xlsx");
			e.printStackTrace();
		}
		// query sql 담는다.
		XSSFSheet sqlSheet =  workbook.getSheetAt(1);
		Row sqlRow = sqlSheet.createRow(0);
		// 해당 행의 첫번째 열 셀 생성
		Cell sqlCell = sqlRow.createCell(0);
		sqlCell.setCellValue(query);

		// query 결과 담는다.
		XSSFSheet sheet =  workbook.getSheetAt(0);
		// 시트 생성
		//XSSFSheet sheet = workbook.createSheet("(참조1)" +"설정현황_"+""+ jobid +"");

		/* STYLE START */

		CellStyle titleStyle = workbook.createCellStyle();
		CellStyle cellStyle = workbook.createCellStyle();
		CellStyle contentStyle = workbook.createCellStyle();
		CellStyle contentStyle_R = workbook.createCellStyle();
		CellStyle contentStyle_L = workbook.createCellStyle();

		/* 폰트 설정*/
		// 타이틀 폰트
		Font titleFont = workbook.createFont();

		titleFont.setFontHeightInPoints((short)13);
		titleFont.setFontName("맑은 고딕");

		// 컬럼명 폰트
		Font colNameFont = workbook.createFont();

		colNameFont.setFontHeightInPoints((short)10);
		colNameFont.setFontName("맑은 고딕");

		// 내용 폰트
		Font contentFont = workbook.createFont();
		contentFont.setFontHeightInPoints((short)10);
		contentFont.setFontName("맑은 고딕");

		/* 타이틀 폰트 스타일 지정 */
		titleStyle.setFont(titleFont);

		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setAlignment(HorizontalAlignment.CENTER);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setFont(colNameFont);

		/* 내용 셀 테두리 / 폰트 지정 */
		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle.setBorderLeft(BorderStyle.THIN);
		contentStyle.setBorderTop(BorderStyle.THIN);
		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle.setAlignment(HorizontalAlignment.CENTER);
		contentStyle.setBorderBottom(BorderStyle.THIN);
		contentStyle.setFont(contentFont);

		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_R.setBorderLeft(BorderStyle.THIN);
		contentStyle_R.setBorderTop(BorderStyle.THIN);
		contentStyle_R.setBorderBottom(BorderStyle.THIN);
		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
		contentStyle_R.setFont(contentFont);
		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
		contentStyle_L.setBorderRight(BorderStyle.THIN);              //테두리 설정
		contentStyle_L.setBorderLeft(BorderStyle.THIN);
		contentStyle_L.setBorderTop(BorderStyle.THIN);
		contentStyle_L.setBorderBottom(BorderStyle.THIN);
		contentStyle_L.setVerticalAlignment(VerticalAlignment.CENTER);
		contentStyle_L.setAlignment(HorizontalAlignment.LEFT);
		contentStyle_L.setFont(contentFont);
		try {
			// 내용 행 및 셀 생성
			Row bodyRow = null;
			Cell bodyCell = null;
			int columnCount = rsmd.getColumnCount();
			int rownum = 0;
			// 헤더 행 생성
			Row headerRow = sheet.createRow(rownum++);
			// 해당 행의 첫번째 열 셀 생성
			Cell headerCell = null;
			for (int i = 1; i <= columnCount; i++ ) {
				headerCell = headerRow.createCell(i-1);
				headerCell.setCellValue(rsmd.getColumnName(i));
				headerCell.setCellStyle(cellStyle);
			}

			// 내용 행 및 셀 생성
			while( rs.next() ) {
				// 행 생성
				bodyRow = sheet.createRow(rownum++);
				// 데이터 번호 표시
				for (int i = 1; i <= columnCount; i++ ) {
					bodyCell = bodyRow.createCell(i-1);
					bodyCell.setCellValue(rs.getString(i));
					bodyCell.setCellStyle(contentStyle_L);
				}

			}
		}catch(Exception e){
			logger.warn("warn "+e.getMessage());
		}
		return workbook;
	}

//	@Override
//	public XSSFWorkbook makeMetadataExcel(Locale locale, List<MetaTableGapVO> list) {
//		XSSFWorkbook workbook = new XSSFWorkbook();
//
//		// 시트 생성
//		//XSSFSheet sheet = workbook.createSheet(messageSource.getMessage("memu.report_job_results" , null, "Job Result Report", locale));
//		XSSFSheet sheet = workbook.createSheet("Sheet1");
//
//		/* STYLE START */
//
//		CellStyle titleStyle = workbook.createCellStyle();
//		CellStyle cellStyle = workbook.createCellStyle();
//		CellStyle contentStyle = workbook.createCellStyle();
//		CellStyle contentStyle_R = workbook.createCellStyle();
//
//		/* 폰트 설정*/
//		// 타이틀 폰트
//		Font titleFont = workbook.createFont();
//
//		titleFont.setFontHeightInPoints((short)15);
//		titleFont.setFontName("맑은 고딕");
//
//		// 컬럼명 폰트
//		Font colNameFont = workbook.createFont();
//
//		colNameFont.setFontHeightInPoints((short)10);
//		colNameFont.setFontName("맑은 고딕");
//
//		// 내용 폰트
//		Font contentFont = workbook.createFont();
//		contentFont.setFontHeightInPoints((short)10);
//		contentFont.setFontName("맑은 고딕");
//
//		/* 타이틀 폰트 스타일 지정 */
//		titleStyle.setFont(titleFont);
//		titleStyle.setAlignment(HorizontalAlignment.CENTER);
//
//		/* 컬럼 셀 테두리 / 폰트 스타일 지정 */
//		cellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex()); // 셀 색상
//		cellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
//		cellStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
//		cellStyle.setBorderLeft(BorderStyle.THIN);
//		cellStyle.setBorderTop(BorderStyle.THIN);
//		cellStyle.setAlignment(HorizontalAlignment.CENTER);
//		cellStyle.setBorderBottom(BorderStyle.THIN);
//		cellStyle.setFont(colNameFont);
//
//		/* 내용 셀 테두리 / 폰트 지정 */
//		//contentStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
//		contentStyle.setBorderRight(BorderStyle.THIN);              //테두리 설정
//		contentStyle.setBorderLeft(BorderStyle.THIN);
//		contentStyle.setBorderTop(BorderStyle.THIN);
//		contentStyle.setVerticalAlignment(VerticalAlignment.CENTER);
//		contentStyle.setAlignment(HorizontalAlignment.LEFT);
//		contentStyle.setBorderBottom(BorderStyle.THIN);
//		contentStyle.setFont(contentFont);
//
//		/* 내용 셀 테두리 / 폰트 지정 왼쪽정렬*/
//		//contentStyle_R.setFillPattern(FillPatternType.SOLID_FOREGROUND);
//		contentStyle_R.setBorderRight(BorderStyle.THIN);              //테두리 설정
//		contentStyle_R.setBorderLeft(BorderStyle.THIN);
//		contentStyle_R.setBorderTop(BorderStyle.THIN);
//		contentStyle_R.setBorderBottom(BorderStyle.THIN);
//		contentStyle_R.setVerticalAlignment(VerticalAlignment.CENTER);
//		contentStyle_R.setAlignment(HorizontalAlignment.RIGHT);
//		contentStyle_R.setFont(contentFont);
//
//		//시트 열 너비 설정
//		sheet.setColumnWidth(0, 2000);
//		sheet.setColumnWidth(1, 2000);
//		sheet.setColumnWidth(2, 2000);
//		sheet.setColumnWidth(3, 2000);
//		sheet.setColumnWidth(4, 4000);
//		sheet.setColumnWidth(5, 4000);
//		sheet.setColumnWidth(6, 2000);
//		sheet.setColumnWidth(7, 2000);
//		sheet.setColumnWidth(8, 2000);
//		sheet.setColumnWidth(9, 3000);
//		sheet.setColumnWidth(10, 3000);
//		sheet.setColumnWidth(11, 2000);
//		sheet.setColumnWidth(12, 2000);
//		sheet.setColumnWidth(13, 3000);
//		sheet.setColumnWidth(14, 4000);
////		sheet.setColumnWidth(14, 3000);
////		sheet.setColumnWidth(15, 3000);
//
//		// 타이블 행 생성
//		Row titleRow = sheet.createRow(0);
//		// 해당 행의 첫번째 열 셀 생성
//		Cell titleCell = null;
//		titleCell = titleRow.createCell(0); titleCell.setCellValue(messageSource.getMessage("memu.matadata_list" , null, "Meta data information", locale));titleCell.setCellStyle(titleStyle);
//		sheet.addMergedRegion(new CellRangeAddress(0,(short)0,0,(short)7));
//		// 헤더 행 생성
//		Row headerRow = sheet.createRow(2);
//		// 해당 행의 첫번째 열 셀 생성
//		Cell headerCell = null;
//		headerCell = headerRow.createCell(0); headerCell.setCellValue("NO");headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(1); headerCell.setCellValue(messageSource.getMessage("col.system" , null, "System", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(2); headerCell.setCellValue(messageSource.getMessage("col.jobid" , null, "Jobid", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(3); headerCell.setCellValue(messageSource.getMessage("col.db" , null, "DB", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(4); headerCell.setCellValue(messageSource.getMessage("col.owner" , null, "Owner", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(5); headerCell.setCellValue(messageSource.getMessage("col.table_name" , null, "Table_name", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(6); headerCell.setCellValue(messageSource.getMessage("col.arccnt" , null, "Arccnt", locale));headerCell.setCellStyle(cellStyle);
//		headerCell = headerRow.createCell(7); headerCell.setCellValue(messageSource.getMessage("col.delcnt" , null, "Delcnt", locale));headerCell.setCellStyle(cellStyle);
//
//		// 내용 행 및 셀 생성
//		Row bodyRow = null;
//		Cell bodyCell = null;
//		for(int i=0; i<list.size(); i++) {
//			PiiOrderReportVO vo = list.get(i);
//
//			// 행 생성
//			bodyRow = sheet.createRow(i+3);
//			// 데이터 번호 표시
//			bodyCell = bodyRow.createCell(0);bodyCell.setCellValue(i+1);bodyCell.setCellStyle(contentStyle_R);
//			bodyCell = bodyRow.createCell(1);bodyCell.setCellValue(vo.getSystem());bodyCell.setCellStyle(contentStyle);
//			bodyCell = bodyRow.createCell(2);bodyCell.setCellValue(vo.getJobid());bodyCell.setCellStyle(contentStyle);
//			bodyCell = bodyRow.createCell(3);bodyCell.setCellValue(vo.getDb());bodyCell.setCellStyle(contentStyle);
//			bodyCell = bodyRow.createCell(4);bodyCell.setCellValue(vo.getOwner());bodyCell.setCellStyle(contentStyle);
//			bodyCell = bodyRow.createCell(5);bodyCell.setCellValue(vo.getTable_name());bodyCell.setCellStyle(contentStyle);
//			bodyCell = bodyRow.createCell(6);bodyCell.setCellValue(vo.getArccnt());bodyCell.setCellStyle(contentStyle_R);
//			bodyCell = bodyRow.createCell(7);bodyCell.setCellValue(vo.getDelcnt());bodyCell.setCellStyle(contentStyle_R);
//
//		}
//
//		return workbook;
//	}
//    public List<Fruit> uploadExcelFile(MultipartFile excelFile){
//        List<Fruit> list = new ArrayList<Fruit>();
//        try {
//            OPCPackage opcPackage = OPCPackage.open(excelFile.getInputStream());
//            XSSFWorkbook workbook = new XSSFWorkbook(opcPackage);
//            
//            // 첫번째 시트 불러오기
//            XSSFSheet sheet = workbook.getSheetAt(0);
//            
//            for(int i=1; i<sheet.getLastRowNum() + 1; i++) {
//                Fruit fruit = new Fruit();
//                XSSFRow row = sheet.getRow(i);
//                
//                // 행이 존재하기 않으면 패스
//                if(null == row) {
//                    continue;
//                }
//                
//                // 행의 두번째 열(이름부터 받아오기) 
//                XSSFCell cell = row.getCell(1);
//                if(null != cell) fruit.setName(cell.getStringCellValue());
//                // 행의 세번째 열 받아오기
//                cell = row.getCell(2);
//                if(null != cell) fruit.setPrice((long)cell.getNumericCellValue());
//                // 행의 네번째 열 받아오기
//                cell = row.getCell(3);
//                if(null != cell) fruit.setQuantity((int)cell.getNumericCellValue());
//                
//                list.add(fruit);
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return list;
//    }

	@Override
	public XSSFWorkbook makeTestDataStatusTemplateExcel(String path, String templateName, List<TestDataCombinedStatusVO> list, String startDate, String endDate
			, long totalAutoGenRequestCount
			, long totalAutoGenCustomerCount
			, long totalTableLoadRequestCount
			, long totalTableLoadTableCount) {
		XSSFWorkbook workbook = null;
		File fullpath = null;
		DecimalFormat decFormat = new DecimalFormat("###,###");
		String fileSeparator = System.getProperty("file.separator");

		try {
			fullpath = new File(path + fileSeparator + "Template_" + templateName + ".xlsx");
			InputStream fis = new FileInputStream(fullpath);
			workbook = new XSSFWorkbook(fis);
		} catch (IOException e) {
			logger.warn("warn " + "Can't find the file => " + fullpath);
			e.printStackTrace();
		}

		XSSFSheet sheet = workbook.getSheetAt(0);

		// 엑셀 템플릿의 두 번째 행(인덱스 1)에 날짜 값을 채워 넣습니다.
		Row dateRow = sheet.getRow(1);
		if (dateRow == null) {
			dateRow = sheet.createRow(1);
		}

		// 시작일(Start Date)은 첫 번째 셀(인덱스 0)에
		Cell startDateCell = dateRow.getCell(0);
		if (startDateCell == null) {
			startDateCell = dateRow.createCell(0);
		}
		startDateCell.setCellValue("조회기간: "+startDate+" ~ "+endDate);

		// 스타일 객체를 생성합니다.
		CellStyle cellStyle = workbook.createCellStyle();
		cellStyle.setBorderTop(BorderStyle.THIN);
		cellStyle.setBorderBottom(BorderStyle.THIN);
		cellStyle.setBorderLeft(BorderStyle.THIN);
		cellStyle.setBorderRight(BorderStyle.THIN);

		// 데이터 삽입 후 총계(합계) 행을 추가합니다.
		Row totalRow = sheet.getRow(3);
		totalRow.getCell(2).setCellValue(decFormat.format(totalAutoGenRequestCount));
		totalRow.getCell(3).setCellValue(decFormat.format(totalAutoGenCustomerCount));
		totalRow.getCell(4).setCellValue(decFormat.format(totalTableLoadRequestCount));
		totalRow.getCell(5).setCellValue(decFormat.format(totalTableLoadTableCount));

		// 엑셀 템플릿의 네 번째 행(인덱스 3)부터 데이터가 시작됩니다.
		int startRowIndex = 4;

		// 데이터 삽입
		for (int i = 0; i < list.size(); i++) {
			TestDataCombinedStatusVO data = list.get(i);
			Row row = sheet.createRow(i + startRowIndex);

			// 각 셀에 데이터를 입력하면서 스타일을 적용합니다.
			Cell cell0 = row.createCell(0);
			cell0.setCellValue(data.getDeptname());
			cell0.setCellStyle(cellStyle);

			Cell cell1 = row.createCell(1);
			cell1.setCellValue(data.getUserName());
			cell1.setCellStyle(cellStyle);

			Cell cell2 = row.createCell(2);
			cell2.setCellValue(data.getAutoGenRequestCount());
			cell2.setCellStyle(cellStyle);

			Cell cell3 = row.createCell(3);
			cell3.setCellValue(data.getAutoGenCustomerCount());
			cell3.setCellStyle(cellStyle);

			Cell cell4 = row.createCell(4);
			cell4.setCellValue(data.getTableLoadRequestCount());
			cell4.setCellStyle(cellStyle);

			Cell cell5 = row.createCell(5);
			cell5.setCellValue(data.getTableLoadTableCount());
			cell5.setCellStyle(cellStyle);
		}



		return workbook;
	}

}
