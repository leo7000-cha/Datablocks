package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiContractStatVO;
import datablocks.dlm.domain.PiiContractVO;

import java.security.Principal;
import java.util.List;

public interface PiiContractService {

	public void register(PiiContractVO contract);

	public PiiContractVO get(String custid, String contractno);

	public boolean modify(PiiContractVO contract);
	public boolean modifyStatus(PiiContractVO contract);
	public String modifyStatusListAsY(List<PiiContractVO> contractlist, Principal principal);

	public boolean remove(String custid, String contractno);

	public List<PiiContractVO> getList();

	public List<PiiContractVO> getList(Criteria cri);
	public List<PiiContractStatVO> getStatList(Criteria cri);
	public List<PiiContractStatVO> getStatList12Month();

	//추가
	public int getTotal(Criteria cri);
	public int getStatTotal(Criteria cri);

	public List<PiiContractVO> getDistinctMgmtDept();

}