package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiBizDayVO;

import java.util.List;

public interface PiiBizDayService {

	public void register(PiiBizDayVO piibizday);

	public PiiBizDayVO get(String base_dt);

	public boolean modify(PiiBizDayVO piibizday);

	public boolean remove(PiiBizDayVO piibizday);

	public List<PiiBizDayVO> getList();

	public List<PiiBizDayVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	public String getDeadline(String basedate, String cnt);
	public String getArcDeadline(String basedate, String cnt);
}