package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiUploadTemplateVO;

import java.util.List;

public interface PiiUploadTemplateService {

	public void register(PiiUploadTemplateVO piiuploadtemplate);

	public PiiUploadTemplateVO get(String uploadtemplate_id, String item_val);

	public boolean modify(PiiUploadTemplateVO piiuploadtemplate);

	public boolean remove(String jobid, String version, String stepid, String seq);

	public List<PiiUploadTemplateVO> getList();

	public List<PiiUploadTemplateVO> getList(Criteria cri);

	public int getTotal(Criteria cri);
	


}