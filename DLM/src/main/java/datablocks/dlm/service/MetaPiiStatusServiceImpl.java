package datablocks.dlm.service;

import datablocks.dlm.domain.*;
import datablocks.dlm.mapper.MetaPiiStatusMapper;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.excelUtil;
import lombok.AllArgsConstructor;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


@Service
@AllArgsConstructor
public class MetaPiiStatusServiceImpl implements MetaPiiStatusService {
	private static final Logger logger = LoggerFactory.getLogger(MetaPiiStatusServiceImpl.class);
	@Autowired
	private MetaPiiStatusMapper mapper;

	@Override
	public List<MetaPiiStatusVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<MetaPiiStatusVO> getListByDb() {
		
		LogUtil.log("INFO", "getListByDb: " );
		
		return mapper.getListByDb();
	}



	@Override
	public MetaPiiStatusVO get(String system_name, String db, String owner) {

		LogUtil.log("INFO", "getListForOneTable......" + system_name +" "+ db +" "+ owner);

		return mapper.read(system_name, db, owner);
	}


}
