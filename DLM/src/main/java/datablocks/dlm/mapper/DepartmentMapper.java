package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.DepartmentVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface DepartmentMapper {

	public List<DepartmentVO> getList();
	
	public List<DepartmentVO> getListWithPaging(Criteria cri);

	public void insert(DepartmentVO dept);

	public void insertSelectKey(DepartmentVO dept);

	public DepartmentVO read(String deptcode);

	public int delete(@Param("deptcode") String deptcode);
	
	public int update(DepartmentVO dept);
	
	public int getTotalCount(Criteria cri);

}
