package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiDetectConfigVO;
import datablocks.dlm.domain.PiiDetectResultVO;

import java.util.List;

public interface PiiDetectService {

	public void register(PiiDetectConfigVO config);

	public PiiDetectConfigVO get(String conf_id);

	public boolean modify(PiiDetectConfigVO config);

	public boolean remove(String conf_id);

	public List<PiiDetectConfigVO> getList();

	public List<PiiDetectConfigVO> getList(Criteria cri);

	public int getTotal(Criteria cri);

	public List<PiiDetectResultVO> getResultList(Criteria cri);

	public int getResultTotal(Criteria cri);
	


}