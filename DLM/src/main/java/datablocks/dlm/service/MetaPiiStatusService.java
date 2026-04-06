package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.MetaTableGapVO;
import datablocks.dlm.domain.MetaPiiStatusVO;
import datablocks.dlm.domain.PiiStepTableTargetVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MetaPiiStatusService {

	public MetaPiiStatusVO get(String system_name, String db, String owner);
	public List<MetaPiiStatusVO> getList();
	public List<MetaPiiStatusVO> getListByDb();

}