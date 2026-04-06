package datablocks.dlm.service;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiArcTableVO;
import datablocks.dlm.domain.PiiOrderReportVO;
import datablocks.dlm.domain.PiiOrderStepTableVO;
import datablocks.dlm.mapper.PiiOrderMapper;
import datablocks.dlm.mapper.PiiOrderStepMapper;
import datablocks.dlm.mapper.PiiOrderStepTableMapper;
import datablocks.dlm.util.LogUtil;
import datablocks.dlm.util.StrUtil;
import lombok.AllArgsConstructor;
import org.apache.ibatis.annotations.Param;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


@Service
@AllArgsConstructor
public class PiiOrderStepTableServiceImpl implements PiiOrderStepTableService {
	private static final Logger logger = LoggerFactory.getLogger(PiiOrderStepTableServiceImpl.class);
	@Autowired
	private PiiOrderStepTableMapper mapper;

//	@Autowired
//	private PiiOrderStepMapper stepmapper;
//
//	@Autowired
//	private PiiOrderMapper ordermapper;
	
	@Override
	public List<PiiOrderStepTableVO> getList() {
		
		LogUtil.log("INFO", "get List: " );
		return mapper.getList();
	}
	@Override
	public List<PiiArcTableVO> getArcTableList() {
		LogUtil.log("INFO", "get getArcTableList: " );
		return mapper.getArcTableList();
	}
	@Override
	public List<PiiOrderStepTableVO> getStepTableList(int orderid, String stepid) {
		
		LogUtil.log("INFO", "getStepTableList: " );
		return mapper.getStepTableList(orderid, stepid);
	}
	
	@Override
	public List<PiiOrderStepTableVO> getStepTableListasc(int orderid, String stepid) {
		
		LogUtil.log("INFO", "getStepTableListasc: " );
		return mapper.getStepTableListasc(orderid, stepid);
	}
	@Override
	public List<PiiOrderStepTableVO> getStepTableList_keymap(int orderid, String stepid) {

		LogUtil.log("INFO", "getStepTableList_keymap: " );
		return mapper.getStepTableList_keymap(orderid, stepid);
	}
	@Override
	public List<PiiOrderStepTableVO> getRunnableStepTableList(int orderid, String stepid) {

		LogUtil.log("INFO", "getRunnableStepTableList: " );
		return mapper.getRunnableStepTableList(orderid, stepid);
	}
	
	@Override
	public List<PiiOrderStepTableVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);

		return mapper.getListWithPaging(cri);
	}
	@Override
	public List<PiiOrderReportVO> getOrderReportList(Criteria cri){
		
		LogUtil.log("INFO", "getOrderReportList: " );
		
		return mapper.getOrderReportList(cri);
	}

	@Override
	@Transactional
	public void register(PiiOrderStepTableVO piiordersteptable) {
		
		 LogUtil.log("INFO", "register......" + piiordersteptable);
		  
		 mapper.insert(piiordersteptable); 
		 }
		 
	@Override
	@Transactional
	public boolean remove(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "remove...." + orderid +" "+ jobid+" "+ version+" "+ stepid);
		 
		return mapper.delete(orderid, jobid, version, stepid, seq1, seq2, seq3) == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}
	@Override
	public int getTotalReportCount(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalReportCount(cri);
	}

	@Override
	public PiiOrderStepTableVO get(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name) {
		
		LogUtil.log("INFO", "get...." + orderid +" "+ jobid+" "+ version+" "+ stepid);
		 
		 return mapper.read(orderid, jobid, version, stepid , db, owner, table_name);
	}
	@Override
	public PiiOrderStepTableVO getWithSeq(int orderid, String stepid, int seq1, int seq2, int seq3) {
		
		LogUtil.log("INFO", "get......" +stepid+" "+ seq1 +" "+ seq2 +" "+ seq3 +" ");
		
		return mapper.readWithSeq(orderid, stepid, seq1, seq2, seq3);
	}

	@Override
	@Transactional
	public boolean modify(PiiOrderStepTableVO piiordersteptable) {
		
		LogUtil.log("INFO", "modify......" + piiordersteptable);
		
		return mapper.update(piiordersteptable) == 1;
	}
	
	@Override
	@Transactional
	public boolean modifyOrderTableDetail(PiiOrderStepTableVO piiordersteptable) {
		
		LogUtil.log("INFO", "modify......" +piiordersteptable);
		//mapper.updateOrderDetail(piiordersteptable);
		//stepmapper.updateend(piiordersteptable.getOrderid(), piiordersteptable.getJobid(), piiordersteptable.getVersion(), piiordersteptable.getStepid());
	    //ordermapper.updateend(piiordersteptable.getOrderid());
		
		/* To avoid DB2 sql error for number format data updating if the data is '' */
    	if(StrUtil.checkString(piiordersteptable.getParallelcnt())) {
    		piiordersteptable.setParallelcnt(null);
		}
    	if(StrUtil.checkString(piiordersteptable.getCommitcnt())) {
    		piiordersteptable.setCommitcnt(null);
    	}
				
    	if(piiordersteptable.getExetype().equalsIgnoreCase("BROADCAST")) {
			StringBuilder sqlInsert = new StringBuilder();
	    	sqlInsert.append("insert into " +  piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name() + " -- Target DB : "+piiordersteptable.getDb()+"\n");
			sqlInsert.append("select * from " + piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name() + " -- "+"DB in Step"+"\n");
			if(!StrUtil.checkString(piiordersteptable.getWherestr())) {sqlInsert.append(" where " + piiordersteptable.getWherestr()); }
			piiordersteptable.setSqlstr(sqlInsert.toString());
    	}else if(piiordersteptable.getExetype().equalsIgnoreCase("HOMECAST")) {
			StringBuilder sqlInsert = new StringBuilder();
			sqlInsert.append("insert into " +  piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name() + " -- "+"DB in Step"+"\n");
			sqlInsert.append("select * from " + piiordersteptable.getOwner() +"."+ piiordersteptable.getTable_name() + " -- Sorce DB : "+piiordersteptable.getDb()+"\n");
			if(!StrUtil.checkString(piiordersteptable.getWherestr())) {sqlInsert.append(" where " + piiordersteptable.getWherestr()); }
			piiordersteptable.setSqlstr(sqlInsert.toString());
    	}

		return mapper.updateOrderDetail(piiordersteptable) == 1;

	}

	@Override
	public boolean updateactionflag(PiiOrderStepTableVO piiordersteptable) {

		LogUtil.log("INFO", "updateactionflag......" + piiordersteptable);

		return mapper.updateactionflag(piiordersteptable) == 1;
	}
	@Override
	public boolean updatecnt(int orderid, String stepid, int seq1, int seq2, int seq3, long execnt) {

		LogUtil.log("INFO", "updatecnt......" + orderid +", "+ stepid +", "+ seq1 +", "+ seq2 +", "+ seq3 +", "+ execnt);

		return mapper.updatecnt(orderid, stepid, seq1, seq2, seq3, execnt) == 1;
	}
	@Override
	public boolean updatebefore(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "updatebefore......" + orderid +", "+ jobid +", "+ version +", "+ stepid +", "+ seq1 +", "+ seq2 +", "+ seq3 +", ");

		return mapper.updatebefore(orderid, jobid, version, stepid, seq1, seq2, seq3) == 1;
	}
	@Override
	public boolean updateend(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3, String status, long execnt, String sqlmsg) {

		LogUtil.log("INFO", "updateend......" + orderid +", "+ jobid +", "+ version +", "+ stepid +", "+ seq1 +", "+ seq2 +", "+ seq3 +", "+ status +", "+ execnt +", "+ sqlmsg +", ");

		return mapper.updateend(orderid, jobid, version, stepid, seq1, seq2, seq3, status, execnt, sqlmsg) == 1;
	}
	@Override
	public boolean updateendBySteptype(int orderid, String jobid, String version, int seq1, int seq2, int seq3, String status, long execnt, String sqlmsg) {

		LogUtil.log("INFO", "updatecnt......" + orderid +", "+ jobid +", "+ version +", "+ seq1 +", "+ seq2 +", "+ seq3 +", "+ status +", "+ execnt +", "+ sqlmsg +", ");

		return mapper.updateendBySteptype(orderid, jobid, version, seq1, seq2, seq3, status, execnt, sqlmsg) == 1;
	}
	@Override
	@Transactional
	public boolean deletebyorderid(int orderid) {

		LogUtil.log("INFO", "deletebyorderid......" + orderid );

		return mapper.deletebyorderid(orderid) == 1;
	}

	@Override
	public int readArchiveCntWithSeq(int orderid, String exetype, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "readArchiveCntWithSeq");
		return mapper.readArchiveCntWithSeq(orderid, exetype, seq1, seq2, seq3);
	}
	@Override
	public int readArchiveRowCntWithSeq(int orderid, String exetype, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "readArchiveRowCntWithSeq");
		return mapper.readArchiveRowCntWithSeq(orderid, exetype, seq1, seq2, seq3);
	}
	@Override
	public int readCntBeforeAsc(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "readCntBeforeAsc");
		return mapper.readCntBeforeAsc(orderid, jobid, version, stepid, seq1, seq2, seq3);
	}
	@Override
	public int readCntBeforeDesc(int orderid, String jobid, String version, String stepid, int seq1, int seq2, int seq3) {

		LogUtil.log("INFO", "readCntBeforeDesc");
		return mapper.readCntBeforeDesc(orderid, jobid, version, stepid, seq1, seq2, seq3);
	}

	@Override
	public int readWaitTableList(int orderid, String jobid, String version, String stepid, String db, String owner, String table_name) {
		LogUtil.log("INFO", "readCntBeforeDesc");
		return mapper.getWaitTableList(orderid, jobid, version, stepid, db, owner, table_name);
	}

	@Override
	@Transactional
	public boolean rerun(int orderid) {
		LogUtil.log("INFO", "rerun......" + orderid);
		return mapper.rerun(orderid) == 1;
	}

	@Override
	public int getRestoreTableNotCompleteCount(int orderid) {
		LogUtil.log("INFO", "getRestoreTableNotCompleteCount......" + orderid);
		return mapper.getRestoreTableNotCompleteCount(orderid);
	}

}
