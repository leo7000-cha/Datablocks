package datablocks.dlm.util;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellReference;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@Component
public class excelUtil {

	/**
     * Cell에 해당하는 Column Name을 가젼온다(A,B,C..)
     * 만약 Cell이 Null이라면 int cellIndex의 값으로
     * Column Name을 가져온다.
     * @param cell
     * @param cellIndex
     * @return
     */
    public static String getName(Cell cell, int cellIndex) {
        int cellNum = 0;
        if(cell != null) {
            cellNum = cell.getColumnIndex();
        }
        else {
            cellNum = cellIndex;
        }
        
        return CellReference.convertNumToColString(cellNum);
    }
    
    public static String getValue(Cell cell) {
		String value = "";
		
		if(cell == null){
			return value;
		}

		switch (cell.getCellType()) {
			case STRING:
				value = cell.getStringCellValue();
				break;
			case NUMERIC:
				value = (int) cell.getNumericCellValue() + "";
				break;
			default:
				value = cell.toString();
				break;
		}
		
		return value;
    }
    public static int getValueInt(Cell cell) {

    	return (int) cell.getNumericCellValue();
    	
    }

	  public static Workbook getWorkbook(String filePath) {

	        FileInputStream fis = null;
	        try {
	            fis = new FileInputStream(filePath);
	        } catch (FileNotFoundException e) {
	            throw new RuntimeException(e.getMessage(), e);
	        }

	        Workbook wb = null;

	        if(filePath.toUpperCase().endsWith(".XLS")) {
	            try {
	                wb = new HSSFWorkbook(fis);
	            } catch (IOException e) {
	                throw new RuntimeException(e.getMessage(), e);
	            }
	        }
	        else if(filePath.toUpperCase().endsWith(".XLSX")) {
	            try {
	                wb = new XSSFWorkbook(fis);
	            } catch (IOException e) {
	                throw new RuntimeException(e.getMessage(), e);
	            }
	        }

	        return wb;

	    }
	  public static Workbook getWorkbook(MultipartFile multipartFile) {
		  
		  Workbook wb = null;
		  
		  if(multipartFile.getOriginalFilename().toUpperCase().endsWith(".XLS")) {
			  try {
				  wb = new HSSFWorkbook(multipartFile.getInputStream());
			  } catch (IOException e) {
				  throw new RuntimeException(e.getMessage(), e);
			  }
		  }
		  else if(multipartFile.getOriginalFilename().toUpperCase().endsWith(".XLSX")) {
			  try {
				  wb = new XSSFWorkbook(multipartFile.getInputStream());
			  } catch (IOException e) {
				  throw new RuntimeException(e.getMessage(), e);
			  }
		  }
		  
		  return wb;
		  
	  }
	  
	  public static void excelCreate(Sheet oldSheet, int rowCount, String fileName, int cnt, int rowParam) throws IOException {
	        //엑셀시트 0번째
	        Row row = oldSheet.getRow(0);
	        
	        //새로만들 sheet
	        Workbook newWorkbook = new XSSFWorkbook();
	        Sheet sheet = newWorkbook.createSheet();
	        sheet.setDefaultColumnWidth(20);
	        Row newRow = null;
	        Cell newCell = null;
	        
	        //0번째 ROW = 엑셀시트 0번째 값을 넣어준다.
	        newRow = sheet.createRow(0);
	        for (int i = 0; i < row.getLastCellNum(); i++) {
	            if(i != 0) { //Seg를 제외한 행 생성
	                newCell = newRow.createCell(i-1);
	                newCell.setCellValue(row.getCell(i).getStringCellValue());
	            }
	        }
	        int start = cnt * rowParam - rowParam +1;
	        int end = cnt * rowParam; 
	 
	        int rowData = 1;
	        for (int i = start; i <= end; i++) {
	            row = oldSheet.getRow(i); //가져올 행
	            newRow = sheet.createRow(rowData);
	            if(!"".equals(row) && row != null) {
	                for (int j = 0; j < row.getLastCellNum(); j++) { //행에 셀 갯수만큼 읽어온뒤, 타입에 맡도록 변경

	                    if(j != 0) { //Seg를 제외한 행 생성
	                        if(row.getCell(j) != null) {
	                     
	                            //한 cell씩 읽어서 새로운 행에 저장
	                            newCell = newRow.createCell(j-1);
	                            newCell.setCellValue(getValue(row.getCell(j)));
	                        }
	                    }
	                }
	                rowData++;
	            }
	        }
	 
	        String path = "C:/download/" + fileName +".xlsx";
	        FileOutputStream outputStream = new FileOutputStream(path);
	        newWorkbook.write(outputStream);
	        outputStream.close();
	        System.out.println("저장완료");
	    }


}// End of Class