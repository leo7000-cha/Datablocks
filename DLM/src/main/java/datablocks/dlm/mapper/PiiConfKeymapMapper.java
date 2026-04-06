package datablocks.dlm.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfKeymapRefVO;
//import org.apache.ibatis.annotations.Select;
import datablocks.dlm.domain.PiiConfKeymapVO;

public interface PiiConfKeymapMapper {

	// @Select("select * from PIICONFKEYMAP)
	public List<PiiConfKeymapVO> getList();
	public List<PiiConfKeymapRefVO> getList_distinct(@Param("keymap_id") String keymap_id);
	public List<PiiConfKeymapVO> getListWithPaging(Criteria cri);

	public void insert(PiiConfKeymapVO piiConfKey);

	public void insertSelectKey(PiiConfKeymapVO piiConfKey);

	//public PiiConfKeymapVO read(PiiConfKeymapVO piiConfKey);
	public PiiConfKeymapVO read(@Param("keymap_id") String keymap_id, @Param("key_name") String key_name, @Param("db") String db,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);

	public int delete(@Param("keymap_id") String keymap_id, @Param("key_name") String key_name, @Param("db") String db,@Param("seq1") int seq1, @Param("seq2") int seq2, @Param("seq3") int seq3);
	
	public int update(PiiConfKeymapVO piiConfKey);
	
	public int getTotalCount(Criteria cri);

}


