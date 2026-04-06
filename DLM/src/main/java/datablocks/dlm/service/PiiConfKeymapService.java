package datablocks.dlm.service;

import java.util.List;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfKeymapRefVO;
import datablocks.dlm.domain.PiiConfKeymapVO;

public interface PiiConfKeymapService {

	public void register(PiiConfKeymapVO piiconfkeymap);

	public PiiConfKeymapVO get(String keymap_id, String key_name, String db, int seq1, int seq2, int seq3);

	public boolean modify(PiiConfKeymapVO piiconfkeymap);

	public boolean remove(String keymap_id, String key_name, String db, int seq1, int seq2, int seq3);

	public List<PiiConfKeymapVO> getList();

	public List<PiiConfKeymapRefVO> getList_distinct(String keymap_id);
	public List<PiiConfKeymapVO> getList(Criteria cri);

	//추가
	public int getTotal(Criteria cri);
	
	//스케줄 test
	void testJobMethod();

}