package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.DepartmentVO;

import java.util.List;

public interface DepartmentService {

	public void register(DepartmentVO dept);

	public DepartmentVO get(String deptcode);

	public boolean modify(DepartmentVO dept);

	public boolean remove(String deptcode);

	public List<DepartmentVO> getList();

	public List<DepartmentVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	


}