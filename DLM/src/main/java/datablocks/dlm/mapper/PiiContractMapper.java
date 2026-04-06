package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiContractStatVO;
import datablocks.dlm.domain.PiiContractVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface PiiContractMapper {

   
	public List<PiiContractVO> getList();
	
	public List<PiiContractVO> getListWithPaging(Criteria cri);
	public List<PiiContractStatVO> getStatListWithPaging(Criteria cri);
	public List<PiiContractStatVO> getStatList12Month();

	public void delete_piicontractstat();
	public void insertStatList12Month();
	public void insert(PiiContractVO contract);

	public void insertSelectKey(PiiContractVO contract);

	public PiiContractVO read(@Param("custid") String custid, @Param("contractno") String contractno);

	public int delete(@Param("custid") String custid, @Param("contractno") String contractno);
	public int updateStatus(PiiContractVO contract);

	public int update(PiiContractVO contract);
	
	public int getTotalCount(Criteria cri);
	public int getStatTotalCount(Criteria cri);

	public List<PiiContractVO> getDistinctMgmtDept();

}
