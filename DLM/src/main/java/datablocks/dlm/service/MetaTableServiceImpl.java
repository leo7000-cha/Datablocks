package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.MetaTableMapper;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import datablocks.dlm.util.excelUtil;
import lombok.AllArgsConstructor;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


@Service
@AllArgsConstructor
public class MetaTableServiceImpl implements MetaTableService {
	private static final Logger logger = LoggerFactory.getLogger(MetaTableServiceImpl.class);
	@Autowired
	private MetaTableMapper mapper;

	@Override
	public List<MetaTableVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<MetaTableVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "getList with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	public List<MetaTableVO> getListOneTable(String db, String owner, String table_name) {

		LogUtil.log("INFO", "getListOneTable......" + db +" "+owner+" "+table_name);

		return mapper.getListOneTable(db, owner, table_name);
	}

	@Override
	public List<MetaTableVO> getListForOneTable(Criteria cri) {

		LogUtil.log("INFO", "getListForOneTable......" + cri.toString());

		return mapper.getListForOneTable(cri);
	}

	@Override
	public List<MetaTableVO> getListOneTableScramble(String db, String owner, String table_name) {

		logger.warn("warn "+"getListOneTable......" + db +" "+owner+" "+table_name + "  "+mapper.getListOneTableScramble(db, owner, table_name).size());

		return mapper.getListOneTableScramble(db, owner, table_name);
	}
	@Override
	public List<PiiStepTableTargetVO> getListEntireTableToScramble(String jobid, String version, String stepid) {

		logger.warn("warn "+"getListEntireTableToScramble......" + jobid +" "+version +" "+stepid);

		return mapper.getListEntireTableToScramble(jobid, version, stepid);
	}

	@Override
	public List<MetaTableGapVO> getList_GapVO(Criteria cri) {

		LogUtil.log("INFO", "getListWithPaging_GapVO with criteria: " + cri);

		return mapper.getListWithPaging_GapVO(cri);
	}

	@Override
	@Transactional
	public void register(MetaTableVO metatable) {
		
		 LogUtil.log("INFO", "register......" + metatable);
		if (metatable.getPiitype() != null && metatable.getPiitype().isEmpty()) {
			metatable.setPiitype(null);
		}
		if (metatable.getScramble_type() != null && metatable.getScramble_type().isEmpty()) {
			metatable.setScramble_type(null);
		}
//		 mapper.insert(metatable); 
		 mapper.insertSelectKey(metatable); 
	}
		 
	@Override
	@Transactional
	public boolean remove(MetaTableVO metatable) {
		
		LogUtil.log("INFO", "remove...." + metatable);
		 
		return mapper.delete(metatable) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}
	@Override
	public int getTotalCount_GapVO(Criteria cri) {

		LogUtil.log("INFO", "getTotalCount_GapVO total count");
		return mapper.getTotalCount_GapVO(cri);
	}

	@Override
	public MetaTableVO get(String db, String owner, String table_name, String column_name) {
		
		 LogUtil.log("INFO", "get......" + db +" "+owner+" "+table_name+" "+column_name);
		 
		 return mapper.read(db, owner, table_name, column_name);
	}

	@Override
	@Transactional
	public boolean modify(MetaTableVO metatable) {
		
		LogUtil.log("INFO", "modify......" + metatable);
		if (metatable.getPiitype() != null && metatable.getPiitype().isEmpty()) {
			metatable.setPiitype(null);
		}
		if (metatable.getScramble_type() != null && metatable.getScramble_type().isEmpty()) {
			metatable.setScramble_type(null);
		}
		return mapper.update(metatable) == 1;
	}
	@Override
	@Transactional
	public boolean piimodify(MetaTableVO metatable) {

		LogUtil.log("INFO", "piimodify......" + metatable);
		if (metatable.getPiitype() != null && metatable.getPiitype().isEmpty()) {
			metatable.setPiitype(null);
		}
		if (metatable.getScramble_type() != null && metatable.getScramble_type().isEmpty()) {
			metatable.setScramble_type(null);
		}
		return mapper.piiupdate(metatable) == 1;
	}

	@Override
	@Transactional
	public boolean verifymodify(MetaTableVO metatable) {

		LogUtil.log("INFO", "verifymodify......" + metatable);

		return mapper.vefifyupdate(metatable) == 1;
	}

	@Override
	@Transactional
	public String uploadMetadata(MultipartFile[] uploadFile) {

			String rst = "successfully uploaded";
			List<PiiAttachFileDTO> list = new ArrayList<>();
			List<PiiStepTableVO> datalist = new ArrayList<>();
			String uploadFolder = "C:\\upload";

			int dupcnt = 0;
			int updatecnt = 0;
			int uploadedcnt = 0;
			// make folder --------
			File uploadPath = new File(uploadFolder, uploadFolder);

			if (uploadPath.exists() == false) {
				uploadPath.mkdirs();
			}
			// make yyyy/MM/dd folder

			for (MultipartFile multipartFile : uploadFile) {

				PiiAttachFileDTO attachDTO = new PiiAttachFileDTO();

				String uploadFileName = multipartFile.getOriginalFilename();

				// IE has file path
				uploadFileName = uploadFileName.substring(uploadFileName.lastIndexOf("\\") + 1);
				LogUtil.log("INFO", "only file name: " + uploadFileName);
				attachDTO.setFileName(uploadFileName);

				UUID uuid = UUID.randomUUID();

				uploadFileName = uuid.toString() + "_" + uploadFileName;
				MetaTableVO metatable = new MetaTableVO();
				try {
					attachDTO.setUuid(uuid.toString());
					attachDTO.setUploadPath(uploadFolder);

//        				// add to List
					list.add(attachDTO);

					Workbook wb = excelUtil.getWorkbook(multipartFile);

					Sheet worksheet = wb.getSheetAt(0);
					int startline = 3;
					uploadedcnt = worksheet.getPhysicalNumberOfRows()-startline+1;
					/** Validation */
					/*for (int i = startline-1; i < worksheet.getPhysicalNumberOfRows(); i++) { // from 11st line
						Row row = worksheet.getRow(i);
					}*/

					for (int i = startline-1; i < worksheet.getPhysicalNumberOfRows(); i++) { // from 11st line
						LogUtil.log("INFO", "row "+i+"    "+worksheet.getPhysicalNumberOfRows());
						Row row = worksheet.getRow(i);

						// 각 셀 값을 읽어서 MetaTable 객체에 세팅
						metatable.setDb(row.getCell(1).getStringCellValue().toUpperCase());
						metatable.setOwner(row.getCell(2).getStringCellValue().toUpperCase());
						metatable.setTable_name(row.getCell(3).getStringCellValue().toUpperCase());
						metatable.setColumn_name(row.getCell(4).getStringCellValue().toUpperCase());
						metatable.setColumn_comment(row.getCell(5).getStringCellValue());
						metatable.setColumn_id(row.getCell(6).getStringCellValue());
						metatable.setPk_yn(row.getCell(7).getStringCellValue());
						metatable.setData_type(row.getCell(8).getStringCellValue());
						metatable.setData_length(row.getCell(9).getStringCellValue());
						metatable.setDomain(row.getCell(10).getStringCellValue());
						metatable.setEncript_flag(row.getCell(11).getStringCellValue());
						metatable.setPiigrade(row.getCell(12).getStringCellValue());
						metatable.setPiitype(row.getCell(13).getStringCellValue());
						metatable.setScramble_type(row.getCell(14).getStringCellValue());
						metatable.setMasterkey(row.getCell(15).getStringCellValue());
						metatable.setMasteryn(row.getCell(16).getStringCellValue());
						metatable.setVal1(row.getCell(17).getStringCellValue());

						if(modify(metatable)){
							updatecnt++;
						}

					}

				} catch (Exception e) {
					e.printStackTrace();
					logger.warn("warn "+"metatable : "+metatable +"  Exception: "+e.getMessage());
					return e.getMessage();

					//throw e;
				}

			} // end for

			//return new ResponseEntity<>(list, HttpStatus.OK);

			rst = "successfully processed <br> uploaded:"+uploadedcnt+"  <br> updated:"+updatecnt;
			return rst;
		}

	@Override
	public java.util.Map<String, Object> getStats() {
		LogUtil.log("INFO", "getStats......");
		return mapper.getStats();
	}

	@Override
	public java.util.List<java.util.Map<String, Object>> getDistinctDbOwners() {
		LogUtil.log("INFO", "getDistinctDbOwners......");
		return mapper.getDistinctDbOwners();
	}

}
