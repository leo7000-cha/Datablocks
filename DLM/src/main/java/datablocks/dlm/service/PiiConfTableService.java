package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiConfTableVO;
import datablocks.dlm.domain.Criteria;

public interface PiiConfTableService {

	public void register(PiiConfTableVO piiconftable);

	public PiiConfTableVO get(String db,String owner,String table_name) ;

	public boolean modify(PiiConfTableVO piiconftable);

	public boolean remove(String db,String owner,String table_name) ;

	public List<PiiConfTableVO> getList();

	public List<PiiConfTableVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	
	//스케줄 test
	void testJobMethod();

}