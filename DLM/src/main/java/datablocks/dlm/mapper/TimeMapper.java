package datablocks.dlm.mapper;

import org.apache.ibatis.annotations.Select;

public interface TimeMapper {

	/* @Select("SELECT sysdate FROM dual") */
	@Select("SELECT SYSDATE FROM SYSIBM.SYSDUMMY1")
	public String getTime();

	public String getTime2();

}
