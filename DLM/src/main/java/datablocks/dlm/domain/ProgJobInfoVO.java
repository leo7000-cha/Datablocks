package datablocks.dlm.domain;

import lombok.Data;

@Data
public class ProgJobInfoVO {
	private String progJobNm;      // PROG_JOB_NM
	private String bgnnChngDvcd;   // BGNN_CHNG_DVCD
	private String paramBaseDt;    // PARAM_BASE_DT (MCMM_ETT_JOB_MST_M 의 기준일 컬럼)
}
