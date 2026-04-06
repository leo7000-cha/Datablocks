package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiUploadTemplateVO;
import datablocks.dlm.mapper.PiiUploadTemplateMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiUploadTemplateServiceImpl implements PiiUploadTemplateService {
	private static final Logger logger = LoggerFactory.getLogger(PiiUploadTemplateServiceImpl.class);
	@Autowired
	private PiiUploadTemplateMapper mapper;


	@Override
	public List<PiiUploadTemplateVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiUploadTemplateVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	@Transactional
	public void register(PiiUploadTemplateVO piiuploadtemplate) {
		
		 LogUtil.log("INFO", "register......" + piiuploadtemplate);
		 
		 mapper.insert(piiuploadtemplate);
//		 mapper.insertSelectKey(piiuploadtemplate);
	}
		 
	@Override
	@Transactional
	public boolean remove(String jobid, String version, String stepid, String seq) {
		
		LogUtil.log("INFO", "remove...." + jobid +" "+ version +" "+ stepid +" "+ seq);
		 
		return mapper.delete(jobid, version, stepid, seq) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiUploadTemplateVO get(String uploadtemplate_id, String item_val) {
		
		 LogUtil.log("INFO", "get......" + uploadtemplate_id);
		 
		 return mapper.read(uploadtemplate_id, item_val);
	}

	@Override
	@Transactional
	public boolean modify(PiiUploadTemplateVO piiuploadtemplate) {
		
		LogUtil.log("INFO", "modify......" + piiuploadtemplate);
		
		return mapper.update(piiuploadtemplate) == 1;
	}
	
}
