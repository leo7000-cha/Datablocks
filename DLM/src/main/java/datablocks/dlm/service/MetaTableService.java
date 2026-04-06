package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.MetaTableGapVO;
import datablocks.dlm.domain.MetaTableVO;
import datablocks.dlm.domain.PiiStepTableTargetVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MetaTableService {

	public void register(MetaTableVO metatable);

	public MetaTableVO get(String db, String owner, String table_name, String column_name);
	public List<MetaTableVO> getListForOneTable(Criteria cri);
	public List<MetaTableVO> getListOneTable(String db, String owner, String table_name);
	public List<MetaTableVO> getListOneTableScramble(String db, String owner, String table_name);
	public List<PiiStepTableTargetVO> getListEntireTableToScramble(String jobid, String version, String stepid);

	public boolean modify(MetaTableVO metatable);
	public boolean piimodify(MetaTableVO metatable);
	public boolean verifymodify(MetaTableVO metatable);

	public boolean remove(MetaTableVO metatable);

	public List<MetaTableVO> getList();

	public List<MetaTableVO> getList(Criteria cri);
	public List<MetaTableGapVO> getList_GapVO(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public int getTotalCount_GapVO(Criteria cri);
	public String uploadMetadata(MultipartFile[] uploadFile);

	public java.util.Map<String, Object> getStats();

	public java.util.List<java.util.Map<String, Object>> getDistinctDbOwners();

}