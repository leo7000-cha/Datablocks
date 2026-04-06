package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.PiiOrderStepTableUpdateWithPkYnVO;
import org.apache.ibatis.annotations.Param;

import datablocks.dlm.domain.PiiOrderStepTableUpdateVO;

public interface PiiOrderStepTableUpdateService {

	public void register(PiiOrderStepTableUpdateVO piisteptableupdate);
	public PiiOrderStepTableUpdateVO get(PiiOrderStepTableUpdateVO piisteptableupdate);

	public String modifyordersteptableupdate(List<PiiOrderStepTableUpdateVO> steptableupdatelist);
	public boolean modify(PiiOrderStepTableUpdateVO piisteptableupdate);
	public boolean remove(PiiOrderStepTableUpdateVO piisteptableupdate);
	public boolean removebyseq(@Param("orderid") int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public boolean removebyjobid(@Param("orderid") int orderid, String jobid, String version);
	public boolean removebystepid(@Param("orderid") int orderid, String jobid, String version, String stepid);
	public List<PiiOrderStepTableUpdateVO> getJobList(@Param("orderid") int orderid, String jobid, String version);
	public List<PiiOrderStepTableUpdateVO> getList(@Param("orderid") int orderid, String stepid, int seq1, int seq2, int seq3);
	public List<PiiOrderStepTableUpdateWithPkYnVO> getListWithPkYn(@Param("orderid") int orderid, String stepid, int seq1, int seq2, int seq3);
	public int getTotal(@Param("orderid") int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);

}