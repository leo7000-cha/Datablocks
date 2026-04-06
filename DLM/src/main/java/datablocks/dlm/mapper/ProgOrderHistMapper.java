package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.ProgOrderHistOkVO;
import datablocks.dlm.domain.ProgOrderHistVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ProgOrderHistMapper {

	public List<ProgOrderHistVO> getList();
	public List<ProgOrderHistOkVO> getListEndedOK();

	public List<ProgOrderHistVO> getListWithPaging(Criteria cri);

	public void insert(ProgOrderHistVO errorHist);

	public void insertSelectKey(ProgOrderHistVO errorHist);

	public ProgOrderHistVO read(@Param("orderid") String orderid);

	public int delete(@Param("orderid") String orderid);
	
	public int update(ProgOrderHistVO errorHist);
	
	public int getTotalCount(Criteria cri);

}
