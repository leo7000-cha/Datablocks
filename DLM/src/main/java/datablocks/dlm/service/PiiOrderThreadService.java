package datablocks.dlm.service;


import datablocks.dlm.domain.PiiOrderThreadVO;

import java.util.List;

public interface PiiOrderThreadService {

	public List<PiiOrderThreadVO> getList(int orderid, String jobid, String version);
	public boolean delete(int orderid);
	public int deleteEndOkTabs();
	public int getListCnt(int orderid, String jobid, String version);
	public PiiOrderThreadVO get(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3);
	public int register(PiiOrderThreadVO piiorderthread);




}