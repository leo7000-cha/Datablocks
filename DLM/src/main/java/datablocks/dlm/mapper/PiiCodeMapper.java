package datablocks.dlm.mapper;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiCodeVO;
import org.apache.ibatis.annotations.Param;

public interface PiiCodeMapper {

   //@Select("select * from piicode")
	public List<PiiCodeVO> getList();
	
	public List<PiiCodeVO> getListWithPaging(Criteria cri);

	public void insert(PiiCodeVO piicode);

	public void insertSelectKey(PiiCodeVO piicode);

	//public PiiCodeVO read(PiiCodeVO PiiCode);
	public PiiCodeVO read(@Param("code_id") String code_id, @Param("item_val") String item_val);

	public int delete(@Param("code_id") String code_id, @Param("item_val") String item_val);
	
	public int update(PiiCodeVO piicode);
	
	public int getTotalCount(Criteria cri);

}
