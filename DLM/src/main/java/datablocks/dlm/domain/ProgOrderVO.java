package datablocks.dlm.domain;

import lombok.Data;

@Data
public class ProgOrderVO {
	private String progJobNm;
	private String db;  // 추가: DB 이름을 받을 필드
	private String selectQuery; // 추가: 배치정보를 SELECT SQL
	private String updateQuery; // 추가: 실행 결과를 업데이트 할 SQL
	private String insertQuery; // 추가: 실행 log정보를 insert 할 SQL

}
