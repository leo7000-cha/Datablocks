package datablocks.dlm.mapper;

import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.MasterKeymapVO;
import datablocks.dlm.domain.ReportJsonVO;
import datablocks.dlm.domain.TestDataVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ReportJsonMapper {

	// 1. SELECT - 단건 조회
	ReportJsonVO selectReportJsonById(@Param("srvyId") String srvyId,
									  @Param("formName") String formName);

	// 2. COUNT - 존재 여부 확인
	int selectReportJsonCountById(@Param("srvyId") String srvyId,
								  @Param("formName") String formName);

	// 3. DELETE - 삭제
	int deleteReportJsonById(@Param("srvyId") String srvyId,
							 @Param("formName") String formName);

	// 4. UPDATE - 저장된 JSON 수정
	int updateReportJsonById(ReportJsonVO vo);

	// 5. INSERT (필요 시 추가)
	int insertReportJson(ReportJsonVO vo);

}
