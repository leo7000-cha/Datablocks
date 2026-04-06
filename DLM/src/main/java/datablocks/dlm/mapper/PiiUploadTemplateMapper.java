package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiUploadTemplateVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiUploadTemplateMapper {

   //@Select("select * from uploadtemplate")
	public List<PiiUploadTemplateVO> getList();
	
	public List<PiiUploadTemplateVO> getListWithPaging(Criteria cri);

	public void insert(PiiUploadTemplateVO uploadtemplate);

//	public void insertSelectKey(PiiUploadTemplateVO uploadtemplate);

	//public PiiUploadTemplateVO read(PiiUploadTemplateVO PiiUploadTemplate);
	public PiiUploadTemplateVO read(String code_id, String item_val);

	public int delete(@Param("jobid") String jobid, @Param("version")  String version, @Param("stepid")  String stepid, @Param("seq")  String seq);
	
	public int update(PiiUploadTemplateVO uploadtemplate);
	
	public int getTotalCount(Criteria cri);

}
