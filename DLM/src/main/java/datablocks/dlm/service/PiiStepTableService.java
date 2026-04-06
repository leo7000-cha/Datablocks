package datablocks.dlm.service;

import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletResponse;

import datablocks.dlm.domain.*;
import org.springframework.web.multipart.MultipartFile;

public interface PiiStepTableService {

	public String register(PiiStepTableVO piisteptable);
	public String registerEntireToScramble(String jobid, String version, String stepid);
	public List<PiiStepTableTargetVO> getListEntireToScramble(String jobid, String version, String stepid);
	public PiiStepTableVO get(String jobid,String version ,String stepid,String db,String owner,String table_name);
	public PiiStepTableVO getEtc(String jobid, String stepid);
	public int getEtcCnt(String jobid, String stepid);
	public PiiStepTableVO getWithSeq(String jobid,String version ,String stepid,int seq1, int seq2, int seq3);
	public int getWithSeqExetype(String jobid,String version ,String exetype,int seq1, int seq2, int seq3);

	public String modify(PiiStepTablePkNewVO piisteptable);
	public boolean modifyArchiveFromDel(PiiStepTablePkNewVO piisteptable);

	public String remove(PiiStepTableVO piisteptable);
	public void removeStepTable(String jobid, String version, String stepid);
	public void removeJobTable(String jobid, String version);

	public List<PiiStepTableVO> getList();
	public List<PiiStepTableVO> getList(Criteria cri);
	public List<PiiStepTableVO> getExeStepTableList(Criteria cri);
	public List<PiiStepTableWithWaitVO> getListWithWait(Criteria cri);
	public List<PiiStepTableVO> getArcStepTableList();
	
	public List<PiiStepTableVO> getJobTableList(String jobid,String version);
	public List<PiiStepTableVO> getJobStepTableList(String jobid, String version, String stepid);
	public List<PiiStepTableVO> getStepTableList(Criteria cri);
	public List<PiiConfKeymapRefVO> getList_Keymap(String jobid,String version);
	public void checkout(String jobid, String version);
	
	//추가
	
	public int getTotalDistinctTabCount();
	public int getTotal(Criteria cri);
	public int getTotalCountExeStepTable(Criteria cri);
	public int getTotalTabCnt(String jobid,String version ,String stepid);
	public int getExistSameTableCnt(String jobid, String version, String db,String owner,String table_name, String exetype);
	public PiiStepMaxSeqVO getStepMaxseq(String jobid,String version ,String stepid);
	public List<PiiStepTableCntVO> getTotalTabCntWithExetype();
	public List<PiiTableConfigStatusVO> getTableConfigStatus();
	public String uploadExcelSteptable(MultipartFile[] uploadFile, String jobid, String version, String stepid, String userid) ;
	public String uploadExcelSteptableFromDB(String jobid, String version, String stepid, String userid) ;
	public void createArcTable(PiiStepTableVO piisteptable);
	public int registerArcTab(PiiStepTableVO piisteptable, Criteria cri);
	public int registerArcTabCols(PiiStepTableVO piisteptable, Criteria cri);
	public Map<String, String> getTDUpdateWhereClauseData(String jobid, String version, String stepid, String owner, String table_name);

	/** 아카이브 DDL 상태 확인: 테이블 존재 여부 + DDL 스크립트 반환 */
	public Map<String, Object> checkArcDdlStatus(PiiStepTableVO piisteptable);

	/** 아카이브 DDL 재실행 */
	public Map<String, Object> retryArcDdl(PiiStepTableVO piisteptable);
}