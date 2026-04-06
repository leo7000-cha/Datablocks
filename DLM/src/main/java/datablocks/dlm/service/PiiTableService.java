package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.*;

public interface PiiTableService {

	public void register(PiiTableVO piitable);
	public int registerArcTab(PiiStepTableVO piisteptable, Criteria cri);
	public int registerArcTabCols(PiiStepTableVO piisteptable, Criteria cri);

	public PiiTableVO get(String db,String owner,String table_name,String column_name) ;
	public List<PiiTableVO> getTable(String db,String owner,String table_name) ;
	public int getTableCnt(String db,String owner,String table_name) ;

	public boolean modify(PiiTableVO piitable);

	public boolean remove(String db,String owner,String table_name,String column_name) ;

	public List<PiiTableVO> getList();

	public List<PiiTableVO> getList(Criteria cri);
	public List<PiiTableNewArcTabVO> getListNewArcTabCols(Criteria cri);
	public List<PiiTableWithMetaVO> getListWithMeta(Criteria cri);
	public List<PiiTablePkVO> getTableList(Criteria cri);

	public int getTableTotal(Criteria cri);
	public int getTotalCountNewArcTab(Criteria cri);
	public int getTotalCountNewArcTabCols(Criteria cri);
	public int getTotal(Criteria cri);
	
	//추가
	public List<PiiLayoutGapVO> getLayoutGapList(Criteria cri);
	public int getLayoutGapTotal(Criteria cri);
	


}