package datablocks.dlm.domain;

import org.springframework.web.util.UriComponentsBuilder;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;


@ToString
@Setter
@Getter
@AllArgsConstructor
public class Criteria {

  private int pagenum;
  private int amount;
  private int offset; // 마리아DB용 NEXT 처리위해 신규 추가
  
  private String type;
  private String keyword;
	
  private String search1;
  private String search2;
  private String search3;
  private String search4;
  private String search5;
  private String search6;
  private String search7;
  private String search8;
  private String search9;
  private String search10;
  private String search11;//20240617
  private String search12;//20240617
  private String search13;//20240617
  private String search14;//20240621
  private String search15;//20240621
  private String search16;//개인정보탐지 필터용
  private String executionId; // Discovery executionId 필터용
  private String filterTable;  // Discovery table 필터용
  private String filterColumn; // Discovery column 필터용
  private String archiveOwner; // 아카이브 스키마명 (동적 네이밍 지원)

  public Criteria() {
    this(1, 100);
  }

  public Criteria(int pagenum, int amount) {
    this.pagenum = pagenum;
    this.amount = amount;
    this.offset = (pagenum-1)*amount; // 마리아DB용 NEXT 처리위해 신규 추가
  }
  
	public String[] getTypeArr() {

		return type == null ? new String[] {} : type.split("");
	}

	public String getListLink() {

		UriComponentsBuilder builder = UriComponentsBuilder.fromPath("")
				.queryParam("pagenum", this.pagenum)
				.queryParam("amount", this.getAmount())
				.queryParam("type", this.getType())
				.queryParam("keyword", this.getKeyword());

		return builder.toUriString();

	}

}
