package datablocks.dlm.util;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import datablocks.dlm.config.ApplicationContextProvider;
import datablocks.dlm.domain.PiiDatabaseVO;
import datablocks.dlm.domain.PiiOrderStepTableVO;
import datablocks.dlm.domain.PiiTableVO;
import datablocks.dlm.exception.AES256Exception;
import datablocks.dlm.jdbc.JdbcUtil;
import datablocks.dlm.service.ArchiveNamingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static java.util.Map.entry;

public class SqlUtil {
    private static final Logger logger = LoggerFactory.getLogger(SqlUtil.class);

    // ============================================================
    // Archive Schema Naming Helper Methods
    // ============================================================

    /**
     * 아카이브 스키마명 생성 (TBL_PIICONFIG에서 설정 자동 조회)
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @return 변환된 아카이브 스키마명 (예: PIICUSTOMER)
     */
    public static String getArchiveSchemaName(String configType, String db, String owner) {
        ArchiveNamingService service = ApplicationContextProvider.getBean(ArchiveNamingService.class);
        if (service != null) {
            return service.getArchiveSchemaName(configType, db, owner);
        }
        // 폴백: 기존 방식 (Spring Context가 없는 경우)
        if ("ILM".equalsIgnoreCase(configType)) {
            return "ILM" + owner.toUpperCase();
        }
        return "PII" + owner.toUpperCase();
    }

    /**
     * 아카이브 테이블 전체 경로 생성 (TBL_PIICONFIG에서 설정 자동 조회)
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @param tableName  테이블명
     * @return "스키마.테이블" 형태 (예: PIICUSTOMER.TB_USER)
     */
    public static String getArchiveTablePath(String configType, String db, String owner, String tableName) {
        return getArchiveSchemaName(configType, db, owner) + "." + tableName;
    }

    /**
     * SQL용 아카이브 스키마명 생성 (따옴표 포함)
     *
     * @param configType 설정 타입 (PII, ILM)
     * @param db         데이터베이스명
     * @param owner      원본 스키마/오너명
     * @return 따옴표 포함 스키마명 (예: 'PIICUSTOMER')
     */
    public static String getArchiveSchemaNameForSql(String configType, String db, String owner) {
        return "'" + getArchiveSchemaName(configType, db, owner) + "'";
    }

    public static String convertDateformat(String dbtype, String wherestr) {
        String rst = wherestr;
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")
                || dbtype.equalsIgnoreCase("DB2")) {//TO_DATE
            rst = wherestr;
        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {//TO_DATE
            if (!StrUtil.checkString(rst)) {
                rst = rst.replaceAll("(?i)sysdate", "now()");
            }
        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            if (!StrUtil.checkString(rst)) {
                rst = rst.replaceAll("(?i)sysdate", "now()");
                rst = rst.replaceAll("(?i)(?<!str_)to_date", "str_to_date");
                rst = rst.replaceAll("(?i)yyyy/mm/dd", "%Y/%m/%d");
                rst = rst.replaceAll("(?i)yyyymmdd", "%Y%m%d");
                rst = rst.replaceAll("(?i)hh24:mi:ss", "%H:%i:%s");
            }
        }
        return rst;
    }

    public static String getSqlSelect1(String dbtype) {
        String query = "SELECT 1 AS NAME FROM DUAL"; // Default for Oracle and Tibero

        if (dbtype.equalsIgnoreCase("MARIADB")
                || dbtype.equalsIgnoreCase("MYSQL")
                || dbtype.equalsIgnoreCase("POSTGRESQL")
                || dbtype.equalsIgnoreCase("MSSQL")
                || dbtype.equalsIgnoreCase("SAP_IQ"))
        {
            query = "SELECT 1";
        } else if (dbtype.equalsIgnoreCase("DB2")) {
            query = "SELECT 1 FROM SYSIBM.SYSDUMMY1"; // Corrected for DB2
        }

        return query;
    }


    public static String getRownum(String dbtype) {
        String str = "rownum";
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            str = "rownum";
        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL") || dbtype.equalsIgnoreCase("POSTGRESQL")) {
            str = "(row_number() over())";
        } else if (dbtype.equalsIgnoreCase("DB2")) {
            str = "rownumber() over()";
        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            str = "row_number() over(order by (select 1))";
        }
        return str;
    }

    public static String getSelectWithQuery(String dbtype, int cnt, String selStr) {
        String str = "select " + SqlUtil.getRownum(dbtype) + " as No, a.* from (" + selStr + ") a where rownum <= " + cnt;
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            str = "select " + SqlUtil.getRownum(dbtype) + " as No, a.* from (" + selStr + ") a where rownum <= " + cnt;
        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL") || dbtype.equalsIgnoreCase("POSTGRESQL")) {
            str = "select " + SqlUtil.getRownum(dbtype) + " as No, a.* from (" + selStr + ") a limit " + cnt;
        } else if (dbtype.equalsIgnoreCase("DB2")) {
            str = "select " + SqlUtil.getRownum(dbtype) + " as No, a.* from (" + selStr + ") a where rownum <= " + cnt;
        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            str = "select * from (select " + SqlUtil.getRownum(dbtype) + " as No, a.* from (" + selStr + ") a) where No <= " + cnt;
        }
        return str;
    }

    public static String getCurrentDate(String dbtype) {
        String curdate = "SYSDATE";
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            curdate = "SYSDATE";
        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL") || dbtype.equalsIgnoreCase("POSTGRESQL")) {
            curdate = "NOW()";
        } else if (dbtype.equalsIgnoreCase("DB2")) {
            curdate = "SYSDATE";
        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            curdate = "getdate()";
        }
        return curdate;
    }

    public static String getDelDeadlineDate(String dbtype, String del_deadline_unit, String policy_deadline, String bizdeadline) {
        String del_deadline = null;
        if (!StrUtil.checkString(policy_deadline)) {
            if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO") || dbtype.equalsIgnoreCase("DB2")) {
                if ("Y".equals(del_deadline_unit))
                    del_deadline = "ADD_MONTHS(TO_DATE('#BASEDATE','YYYY/MM/DD'),-" + (Integer.parseInt(policy_deadline) * 12) + ")";
                else if ("M".equals(del_deadline_unit))
                    del_deadline = "ADD_MONTHS(TO_DATE('#BASEDATE','YYYY/MM/DD'),-" + policy_deadline + ")";
                else if ("D".equals(del_deadline_unit))
                    del_deadline = "TO_DATE('#BASEDATE','YYYY/MM/DD')-" + policy_deadline;
                else if ("D_BIZ".equals(del_deadline_unit)) del_deadline = bizdeadline;
            } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
                if ("Y".equals(del_deadline_unit))
                    del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL -" + (Integer.parseInt(policy_deadline) * 12) + " MONTH)";
                else if ("M".equals(del_deadline_unit))
                    del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL -" + policy_deadline + " MONTH)";
                else if ("D".equals(del_deadline_unit))
                    del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL -" + policy_deadline + " DAY)";
                else if ("D_BIZ".equals(del_deadline_unit)) del_deadline = bizdeadline;
            } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
                if ("Y".equals(del_deadline_unit))
                    del_deadline = "date '#BASEDATE' - interval '" + (Integer.parseInt(policy_deadline) * 12) + " months'";
                else if ("M".equals(del_deadline_unit))
                    del_deadline = "date '#BASEDATE' - interval '" + policy_deadline + " months'";
                else if ("D".equals(del_deadline_unit))
                    del_deadline = "date '#BASEDATE' - interval '" + policy_deadline + " day'";
                else if ("D_BIZ".equals(del_deadline_unit)) del_deadline = bizdeadline;
            } else if (dbtype.equalsIgnoreCase("MSSQL")) {
                if ("Y".equals(del_deadline_unit))
                    del_deadline = "DATEADD(MONTH, -" + (Integer.parseInt(policy_deadline) * 12) + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("M".equals(del_deadline_unit))
                    del_deadline = "DATEADD(MONTH, -" + policy_deadline + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("D".equals(del_deadline_unit))
                    del_deadline = "DATEADD(DAY, -" + policy_deadline + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("D_BIZ".equals(del_deadline_unit)) del_deadline = bizdeadline;
            }
        }
        return del_deadline;
    }


    public static String getArcDelDeadlineDate(String dbtype, String archiveflag, String arc_del_deadline_unit, String policy_arcdeadline, String bizarcdeadline) {
        String arc_del_deadline = null;
        if (archiveflag.equals("Y") && !StrUtil.checkString(policy_arcdeadline)) {
            if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO") || dbtype.equalsIgnoreCase("DB2")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "ADD_MONTHS(TO_DATE('#BASEDATE','YYYY/MM/DD')," + (Integer.parseInt(policy_arcdeadline) * 12) + ")";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "ADD_MONTHS(TO_DATE('#BASEDATE','YYYY/MM/DD')," + policy_arcdeadline + ")";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "TO_DATE('#BASEDATE','YYYY/MM/DD')+" + policy_arcdeadline;
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL + " + (Integer.parseInt(policy_arcdeadline) * 12) + " MONTH)";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL + " + policy_arcdeadline + " MONTH)";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(STR_TO_DATE('#BASEDATE','%Y/%m/%d'), INTERVAL + " + policy_arcdeadline + " DAY)";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "date '#BASEDATE' + interval '" + (Integer.parseInt(policy_arcdeadline) * 12) + " months'";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "date '#BASEDATE' + interval '" + policy_arcdeadline + " months'";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "date '#BASEDATE' + interval '" + policy_arcdeadline + " day'";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("MSSQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(MONTH, " + (Integer.parseInt(policy_arcdeadline) * 12) + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(MONTH, " + policy_arcdeadline + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(DAY, " + policy_arcdeadline + " , CONVERT(DATE,'#BASEDATE'))";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            }
        }
        return arc_del_deadline;
    }

    public static String getArcDelDeadlineDatePolicy3(String dbtype, String archiveflag, String arc_del_deadline_unit, String policy_arcdeadline, String bizarcdeadline) {
        String arc_del_deadline = null;
        if (archiveflag.equals("Y") && !StrUtil.checkString(policy_arcdeadline)) {
            if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO") || dbtype.equalsIgnoreCase("DB2")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "ADD_MONTHS(last_base_date," + (Integer.parseInt(policy_arcdeadline) * 12) + ")";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "ADD_MONTHS(last_base_date," + policy_arcdeadline + ")";
                else if ("D".equals(arc_del_deadline_unit)) arc_del_deadline = "last_base_date+" + policy_arcdeadline;
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(last_base_date, INTERVAL " + (Integer.parseInt(policy_arcdeadline) * 12) + " MONTH)";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(last_base_date, INTERVAL " + policy_arcdeadline + " MONTH)";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATE_ADD(last_base_date, INTERVAL " + policy_arcdeadline + " DAY)";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "last_base_date + interval '" + (Integer.parseInt(policy_arcdeadline) * 12) + " months'";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "last_base_date + interval '" + policy_arcdeadline + " months'";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "last_base_date + interval '" + policy_arcdeadline + " day'";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            } else if (dbtype.equalsIgnoreCase("MSSQL")) {
                if ("Y".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(MONTH, " + (Integer.parseInt(policy_arcdeadline) * 12) + " , last_base_date)";
                else if ("M".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(MONTH, " + policy_arcdeadline + " , last_base_date)";
                else if ("D".equals(arc_del_deadline_unit))
                    arc_del_deadline = "DATEADD(DAY, " + policy_arcdeadline + " , last_base_date)";
                else if ("D_BIZ".equals(arc_del_deadline_unit)) arc_del_deadline = bizarcdeadline;
            }
        }
        return arc_del_deadline;
    }

    /**
     * 소스 DB에서 컬럼 메타데이터를 조회하여 중립 타입(Neutral Type) DDL 조각을 반환한다.
     * 반환 형식: "COLUMN_NAME NEUTRAL_TYPE" (예: "ORDER_ID DECIMAL(15, 2)")
     *
     * 중립 타입 규격: DECIMAL, VARCHAR, CHAR, DATETIME, TIMESTAMP, FLOAT, LONGTEXT, LONGBLOB
     * 이 결과는 getArcTabCreateSql(아카이브DB타입)을 통해 최종 변환된다.
     */
    public static String getArcTabCreate(String dbtype, String db, String owner, String table_name) {
        String sql = "";
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT (\n" +
                    "\t\t\tA.COLUMN_NAME ||' '|| \n" +
                    "\t           (case when A.DATA_TYPE  = 'NUMBER' and A.DATA_PRECISION is not null then 'DECIMAL' || '(' ||A.DATA_PRECISION|| ', '||A.DATA_SCALE|| ')'\n" +
                    "\t                when A.DATA_TYPE  = 'NUMBER' and A.DATA_PRECISION is null then 'DECIMAL' || '(19,3)'\n" +
                    "\t                when A.DATA_TYPE  = 'CHAR' then 'CHAR' || '(' || A.DATA_LENGTH || ')'\n" +
                    "\t                when A.DATA_TYPE  LIKE 'VARCHAR%' then 'VARCHAR' || '(' || A.DATA_LENGTH || ')'\n" +
                    "\t                when A.DATA_TYPE  = 'FLOAT' then 'FLOAT' || '(' ||A.DATA_PRECISION|| ')'\n" +
                    "\t                when A.DATA_TYPE  = 'DATE' then 'DATETIME'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP' then 'TIMESTAMP'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(0)' then 'TIMESTAMP(0)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(1)' then 'TIMESTAMP(1)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(2)' then 'TIMESTAMP(2)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(3)' then 'TIMESTAMP(3)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(4)' then 'TIMESTAMP(4)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(5)' then 'TIMESTAMP(5)'\n" +
                    "\t                when A.DATA_TYPE  = 'TIMESTAMP(6)' then 'TIMESTAMP(6)'\n" +
                    "\t                when A.DATA_TYPE  in ('LONGBLOB','BLOB') then 'LONGBLOB'\n" +
                    "\t                when A.DATA_TYPE  in ('CLOB','NCLOB','LONG','NVARCHAR2') then 'LONGTEXT'\n" +
                    "\t                else 'VARCHAR'\n" +
                    "\t            END )\n" +
                    "       ) AS CREATE_SQL\n" +
                    " FROM ALL_TAB_COLUMNS A\n" +
                    "  WHERE  1=1 \n" +
                    " AND  A.OWNER = '" + owner + "'\n" +
                    " AND  A.TABLE_NAME = '" + table_name + "'\n" +
                    " ORDER BY   A.OWNER\n" +
                    "    , A.TABLE_NAME\n" +
                    "    , A.COLUMN_ID"
            ;

        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            // MariaDB/MySQL 소스: INFORMATION_SCHEMA.COLUMNS → 중립 타입 변환
            sql = "SELECT CONCAT(UPPER(A.COLUMN_NAME), ' ',\n" +
                    "  CASE\n" +
                    "    WHEN A.DATA_TYPE IN ('tinyint','smallint','mediumint','int','integer','bigint') THEN\n" +
                    "      CONCAT('DECIMAL(', CASE WHEN A.NUMERIC_PRECISION IS NOT NULL THEN A.NUMERIC_PRECISION ELSE 19 END, ',0)')\n" +
                    "    WHEN A.DATA_TYPE = 'decimal' THEN\n" +
                    "      CONCAT('DECIMAL(', COALESCE(A.NUMERIC_PRECISION,19), ',', COALESCE(A.NUMERIC_SCALE,0), ')')\n" +
                    "    WHEN A.DATA_TYPE = 'float' THEN 'FLOAT'\n" +
                    "    WHEN A.DATA_TYPE = 'double' THEN 'FLOAT'\n" +
                    "    WHEN A.DATA_TYPE IN ('char') THEN\n" +
                    "      CONCAT('CHAR(', COALESCE(A.CHARACTER_MAXIMUM_LENGTH, 1), ')')\n" +
                    "    WHEN A.DATA_TYPE IN ('varchar') THEN\n" +
                    "      CONCAT('VARCHAR(', COALESCE(A.CHARACTER_MAXIMUM_LENGTH, 255), ')')\n" +
                    "    WHEN A.DATA_TYPE IN ('date','datetime','timestamp') THEN 'DATETIME'\n" +
                    "    WHEN A.DATA_TYPE IN ('time') THEN 'VARCHAR(20)'\n" +
                    "    WHEN A.DATA_TYPE IN ('text','mediumtext','longtext','tinytext') THEN 'LONGTEXT'\n" +
                    "    WHEN A.DATA_TYPE IN ('blob','mediumblob','longblob','tinyblob') THEN 'LONGBLOB'\n" +
                    "    WHEN A.DATA_TYPE = 'bit' THEN 'DECIMAL(1,0)'\n" +
                    "    WHEN A.DATA_TYPE = 'enum' THEN 'VARCHAR(255)'\n" +
                    "    WHEN A.DATA_TYPE = 'set' THEN 'VARCHAR(1000)'\n" +
                    "    WHEN A.DATA_TYPE = 'json' THEN 'LONGTEXT'\n" +
                    "    ELSE 'VARCHAR(255)'\n" +
                    "  END\n" +
                    ") AS CREATE_SQL\n" +
                    "FROM INFORMATION_SCHEMA.COLUMNS A\n" +
                    "WHERE A.TABLE_SCHEMA = '" + owner + "'\n" +
                    "  AND A.TABLE_NAME = '" + table_name + "'\n" +
                    "ORDER BY A.ORDINAL_POSITION"
            ;

        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL 소스: information_schema.columns → 중립 타입 변환
            sql = "SELECT UPPER(A.column_name) || ' ' ||\n" +
                    "  CASE\n" +
                    "    WHEN A.data_type IN ('smallint','integer','bigint') THEN\n" +
                    "      'DECIMAL(' || COALESCE(A.numeric_precision, 19) || ',0)'\n" +
                    "    WHEN A.data_type = 'numeric' THEN\n" +
                    "      'DECIMAL(' || COALESCE(A.numeric_precision, 19) || ',' || COALESCE(A.numeric_scale, 0) || ')'\n" +
                    "    WHEN A.data_type IN ('real','double precision') THEN 'FLOAT'\n" +
                    "    WHEN A.data_type = 'character' THEN\n" +
                    "      'CHAR(' || COALESCE(A.character_maximum_length, 1) || ')'\n" +
                    "    WHEN A.data_type = 'character varying' THEN\n" +
                    "      'VARCHAR(' || COALESCE(A.character_maximum_length, 255) || ')'\n" +
                    "    WHEN A.data_type IN ('timestamp without time zone','timestamp with time zone') THEN 'DATETIME'\n" +
                    "    WHEN A.data_type = 'date' THEN 'DATETIME'\n" +
                    "    WHEN A.data_type = 'time without time zone' THEN 'VARCHAR(20)'\n" +
                    "    WHEN A.data_type = 'text' THEN 'LONGTEXT'\n" +
                    "    WHEN A.data_type = 'bytea' THEN 'LONGBLOB'\n" +
                    "    WHEN A.data_type = 'boolean' THEN 'DECIMAL(1,0)'\n" +
                    "    WHEN A.data_type = 'json' OR A.data_type = 'jsonb' THEN 'LONGTEXT'\n" +
                    "    WHEN A.data_type = 'uuid' THEN 'VARCHAR(36)'\n" +
                    "    ELSE 'VARCHAR(255)'\n" +
                    "  END AS CREATE_SQL\n" +
                    "FROM information_schema.columns A\n" +
                    "WHERE UPPER(A.table_schema) = '" + owner + "'\n" +
                    "  AND UPPER(A.table_name) = '" + table_name + "'\n" +
                    "ORDER BY A.ordinal_position"
            ;

        } else if (dbtype.equalsIgnoreCase("DB2")) {
            sql = "";
        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            sql = "";
        }
        return sql;
    }

    /**
     * 소스 DB에서 특정 컬럼 메타를 조회하여 ALTER TABLE ADD DDL을 중립 타입으로 반환한다.
     * 반환 형식: "ALTER TABLE {archiveOwner}.{table} ADD {column} {neutral_type}"
     *
     * 주의: 반환된 DDL은 중립 타입이므로, 호출부에서 getArcTabCreateSql(아카이브DB타입)으로 변환해야 한다.
     */
    public static String getArcTabColsCreate(String configType, String dbtype, String db, String owner, String table_name, String column_name) {
        String archiveOwner = getArchiveSchemaName(configType, db, owner);
        String sql = "";
        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT (\n" +
                    "\t\t\t'ALTER TABLE " + archiveOwner + "." + table_name + " ADD '||A.COLUMN_NAME ||' '|| \n" +
                    "\t           (case when A.DATA_TYPE  = 'NUMBER' and A.DATA_PRECISION is not null then 'DECIMAL' || '(' ||A.DATA_PRECISION|| ', '||A.DATA_SCALE|| ')'\n" +
                    "\t                when A.DATA_TYPE  = 'NUMBER' and A.DATA_PRECISION is null then 'DECIMAL' || '(19,3)'\n" +
                    "\t                when A.DATA_TYPE  = 'CHAR' then 'CHAR' || '(' || A.DATA_LENGTH || ')'\n" +
                    "\t                when A.DATA_TYPE  LIKE 'VARCHAR%' then 'VARCHAR' || '(' || A.DATA_LENGTH || ')'\n" +
                    "\t                when A.DATA_TYPE  = 'FLOAT' then 'FLOAT' || '(' ||A.DATA_PRECISION|| ')'\n" +
                    "\t                when A.DATA_TYPE  = 'DATE' then 'DATETIME'\n" +
                    "\t                when A.DATA_TYPE  in ('LONGBLOB','BLOB') then 'LONGBLOB'\n" +
                    "\t                when A.DATA_TYPE  in ('CLOB','NCLOB','LONG','NVARCHAR2') then 'LONGTEXT'\n" +
                    "\t                else 'VARCHAR'\n" +
                    "\t            END )\n" +
                    "       ) AS CREATE_SQL\n" +
                    " FROM ALL_TAB_COLUMNS A\n" +
                    "  WHERE  1=1 \n" +
                    " AND  A.OWNER = '" + owner + "'\n" +
                    " AND  A.TABLE_NAME = '" + table_name + "'\n" +
                    " AND  A.COLUMN_NAME = '" + column_name + "'\n" +
                    " ORDER BY   A.OWNER\n" +
                    "    , A.TABLE_NAME\n" +
                    "    , A.COLUMN_ID"
            ;

        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            // MariaDB/MySQL 소스: ALTER TABLE DDL을 중립 타입으로 생성
            sql = "SELECT CONCAT('ALTER TABLE " + archiveOwner + "." + table_name + " ADD COLUMN ',\n" +
                    "  UPPER(A.COLUMN_NAME), ' ',\n" +
                    "  CASE\n" +
                    "    WHEN A.DATA_TYPE IN ('tinyint','smallint','mediumint','int','integer','bigint') THEN\n" +
                    "      CONCAT('DECIMAL(', CASE WHEN A.NUMERIC_PRECISION IS NOT NULL THEN A.NUMERIC_PRECISION ELSE 19 END, ',0)')\n" +
                    "    WHEN A.DATA_TYPE = 'decimal' THEN\n" +
                    "      CONCAT('DECIMAL(', COALESCE(A.NUMERIC_PRECISION,19), ',', COALESCE(A.NUMERIC_SCALE,0), ')')\n" +
                    "    WHEN A.DATA_TYPE IN ('float','double') THEN 'FLOAT'\n" +
                    "    WHEN A.DATA_TYPE = 'char' THEN\n" +
                    "      CONCAT('CHAR(', COALESCE(A.CHARACTER_MAXIMUM_LENGTH, 1), ')')\n" +
                    "    WHEN A.DATA_TYPE = 'varchar' THEN\n" +
                    "      CONCAT('VARCHAR(', COALESCE(A.CHARACTER_MAXIMUM_LENGTH, 255), ')')\n" +
                    "    WHEN A.DATA_TYPE IN ('date','datetime','timestamp') THEN 'DATETIME'\n" +
                    "    WHEN A.DATA_TYPE IN ('text','mediumtext','longtext','tinytext') THEN 'LONGTEXT'\n" +
                    "    WHEN A.DATA_TYPE IN ('blob','mediumblob','longblob','tinyblob') THEN 'LONGBLOB'\n" +
                    "    ELSE 'VARCHAR(255)'\n" +
                    "  END\n" +
                    ") AS CREATE_SQL\n" +
                    "FROM INFORMATION_SCHEMA.COLUMNS A\n" +
                    "WHERE A.TABLE_SCHEMA = '" + owner + "'\n" +
                    "  AND A.TABLE_NAME = '" + table_name + "'\n" +
                    "  AND UPPER(A.COLUMN_NAME) = '" + column_name + "'\n" +
                    "ORDER BY A.ORDINAL_POSITION"
            ;

        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL 소스: ALTER TABLE DDL을 중립 타입으로 생성
            sql = "SELECT 'ALTER TABLE " + archiveOwner + "." + table_name + " ADD COLUMN ' ||\n" +
                    "  UPPER(A.column_name) || ' ' ||\n" +
                    "  CASE\n" +
                    "    WHEN A.data_type IN ('smallint','integer','bigint') THEN\n" +
                    "      'DECIMAL(' || COALESCE(A.numeric_precision, 19) || ',0)'\n" +
                    "    WHEN A.data_type = 'numeric' THEN\n" +
                    "      'DECIMAL(' || COALESCE(A.numeric_precision, 19) || ',' || COALESCE(A.numeric_scale, 0) || ')'\n" +
                    "    WHEN A.data_type IN ('real','double precision') THEN 'FLOAT'\n" +
                    "    WHEN A.data_type = 'character' THEN\n" +
                    "      'CHAR(' || COALESCE(A.character_maximum_length, 1) || ')'\n" +
                    "    WHEN A.data_type = 'character varying' THEN\n" +
                    "      'VARCHAR(' || COALESCE(A.character_maximum_length, 255) || ')'\n" +
                    "    WHEN A.data_type IN ('timestamp without time zone','timestamp with time zone','date') THEN 'DATETIME'\n" +
                    "    WHEN A.data_type = 'text' THEN 'LONGTEXT'\n" +
                    "    WHEN A.data_type = 'bytea' THEN 'LONGBLOB'\n" +
                    "    ELSE 'VARCHAR(255)'\n" +
                    "  END AS CREATE_SQL\n" +
                    "FROM information_schema.columns A\n" +
                    "WHERE UPPER(A.table_schema) = '" + owner + "'\n" +
                    "  AND UPPER(A.table_name) = '" + table_name + "'\n" +
                    "  AND UPPER(A.column_name) = '" + column_name + "'\n" +
                    "ORDER BY A.ordinal_position"
            ;

        } else if (dbtype.equalsIgnoreCase("DB2")) {
            sql = "";
        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            sql = "";
        }
        return sql;
    }

    /**
     * 아카이브 DB에서 생성된 테이블의 컬럼 정보를 조회하여 TBL_PIITABLE 카탈로그 INSERT용 데이터를 반환한다.
     * 아카이브 DB 타입에 따라 메타 딕셔너리 쿼리를 분기한다.
     */
    public static String getInsDlmarcPiitable(String configType, String dbtype, String db, String owner, String table_name) {
        String archiveOwner = getArchiveSchemaName(configType, db, owner);
        String sql = "";
        if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            sql = "SELECT  '" + db + "'\n" +
                            "    , UPPER(A.TABLE_SCHEMA) as OWNER\n" +
                            "    , UPPER(A.TABLE_NAME)\n" +
                            "    , UPPER(A.COLUMN_NAME)\n" +
                            "    , A.ORDINAL_POSITION AS COL_ORDER\n" +
                            "    , CASE WHEN A.COLUMN_KEY='PRI' THEN 'Y'\n" +
                            "           ELSE NULL\n" +
                            "       END AS PK_YN\n" +
                            "    , null AS PK_POSITION\n" +
                            "    , UPPER(A.COLUMN_TYPE) AS FULL_DATA_TYPE\n" +
                            "    , UPPER(A.DATA_TYPE)\n" +
                            "    , A.CHARACTER_MAXIMUM_LENGTH\n" +
                            "    , CASE WHEN A.IS_NULLABLE='YES' THEN 'Y'\n" +
                            "           ELSE 'N'\n" +
                            "       END AS NULLABLE\n" +
                            "    , SUBSTRING(A.COLUMN_COMMENT, 1 ,200) AS COMMENTS\n" +
                            "    , NOW() \n" +
                            "    , NOW() \n" +
                            "    ,'admin'\n" +
                            "    ,'admin'\n" +
                            " FROM INFORMATION_SCHEMA.COLUMNS A\n" +
                            " WHERE 1=1\n" +
                            " AND  A.TABLE_SCHEMA = '" + archiveOwner + "'\n" +
                            " and A.TABLE_NAME = '" + table_name + "'\n" +
                            " ORDER BY 1,2,3,5"
            ;

        } else if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT '" + db + "' AS DB\n" +
                    "    , A.OWNER\n" +
                    "    , A.TABLE_NAME\n" +
                    "    , A.COLUMN_NAME\n" +
                    "    , A.COLUMN_ID AS COL_ORDER\n" +
                    "    , CASE WHEN EXISTS (\n" +
                    "        SELECT 1 FROM ALL_CONS_COLUMNS CC\n" +
                    "        JOIN ALL_CONSTRAINTS C ON C.CONSTRAINT_NAME = CC.CONSTRAINT_NAME AND C.OWNER = CC.OWNER\n" +
                    "        WHERE C.CONSTRAINT_TYPE = 'P'\n" +
                    "          AND CC.OWNER = A.OWNER AND CC.TABLE_NAME = A.TABLE_NAME AND CC.COLUMN_NAME = A.COLUMN_NAME\n" +
                    "      ) THEN 'Y' ELSE NULL END AS PK_YN\n" +
                    "    , NULL AS PK_POSITION\n" +
                    "    , A.DATA_TYPE AS FULL_DATA_TYPE\n" +
                    "    , A.DATA_TYPE\n" +
                    "    , A.DATA_LENGTH\n" +
                    "    , A.NULLABLE\n" +
                    "    , SUBSTR(B.COMMENTS, 1, 200) AS COMMENTS\n" +
                    "    , SYSDATE\n" +
                    "    , SYSDATE\n" +
                    "    , 'admin'\n" +
                    "    , 'admin'\n" +
                    " FROM ALL_TAB_COLUMNS A\n" +
                    " LEFT JOIN ALL_COL_COMMENTS B ON B.OWNER = A.OWNER AND B.TABLE_NAME = A.TABLE_NAME AND B.COLUMN_NAME = A.COLUMN_NAME\n" +
                    " WHERE A.OWNER = '" + archiveOwner + "'\n" +
                    "   AND A.TABLE_NAME = '" + table_name + "'\n" +
                    " ORDER BY A.OWNER, A.TABLE_NAME, A.COLUMN_ID"
            ;

        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
            sql = "SELECT '" + db + "' AS DB\n" +
                    "    , UPPER(A.table_schema) AS OWNER\n" +
                    "    , UPPER(A.table_name) AS TABLE_NAME\n" +
                    "    , UPPER(A.column_name) AS COLUMN_NAME\n" +
                    "    , A.ordinal_position AS COL_ORDER\n" +
                    "    , CASE WHEN EXISTS (\n" +
                    "        SELECT 1 FROM information_schema.key_column_usage K\n" +
                    "        JOIN information_schema.table_constraints T ON T.constraint_name = K.constraint_name AND T.table_schema = K.table_schema\n" +
                    "        WHERE T.constraint_type = 'PRIMARY KEY'\n" +
                    "          AND K.table_schema = A.table_schema AND K.table_name = A.table_name AND K.column_name = A.column_name\n" +
                    "      ) THEN 'Y' ELSE NULL END AS PK_YN\n" +
                    "    , NULL AS PK_POSITION\n" +
                    "    , UPPER(A.data_type) AS FULL_DATA_TYPE\n" +
                    "    , UPPER(A.udt_name) AS DATA_TYPE\n" +
                    "    , A.character_maximum_length AS DATA_LENGTH\n" +
                    "    , CASE WHEN A.is_nullable = 'YES' THEN 'Y' ELSE 'N' END AS NULLABLE\n" +
                    "    , NULL AS COMMENTS\n" +
                    "    , NOW()\n" +
                    "    , NOW()\n" +
                    "    , 'admin'\n" +
                    "    , 'admin'\n" +
                    " FROM information_schema.columns A\n" +
                    " WHERE UPPER(A.table_schema) = '" + archiveOwner + "'\n" +
                    "   AND UPPER(A.table_name) = '" + table_name + "'\n" +
                    " ORDER BY 1, 2, 3, 5"
            ;
        }
        return sql;
    }

    /**
     * 아카이브 DB에서 특정 컬럼 정보를 조회하여 TBL_PIITABLE 카탈로그 INSERT용 데이터를 반환한다.
     */
    public static String getInsDlmarcPiitableCols(String configType, String dbtype, String db, String owner, String table_name, String column_name) {
        String archiveOwner = getArchiveSchemaName(configType, db, owner);
        String sql = "";
        if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            sql = "SELECT  '" + db + "'\n" +
                            "    , UPPER(A.TABLE_SCHEMA) as OWNER\n" +
                            "    , UPPER(A.TABLE_NAME)\n" +
                            "    , UPPER(A.COLUMN_NAME)\n" +
                            "    , A.ORDINAL_POSITION AS COL_ORDER\n" +
                            "    , CASE WHEN A.COLUMN_KEY='PRI' THEN 'Y'\n" +
                            "           ELSE NULL\n" +
                            "       END AS PK_YN\n" +
                            "    , null AS PK_POSITION\n" +
                            "    , UPPER(A.COLUMN_TYPE) AS FULL_DATA_TYPE\n" +
                            "    , UPPER(A.DATA_TYPE)\n" +
                            "    , A.CHARACTER_MAXIMUM_LENGTH\n" +
                            "    , CASE WHEN A.IS_NULLABLE='YES' THEN 'Y'\n" +
                            "           ELSE 'N'\n" +
                            "       END AS NULLABLE\n" +
                            "    , SUBSTRING(A.COLUMN_COMMENT, 1 ,200) AS COMMENTS\n" +
                            "    , NOW() \n" +
                            "    , NOW() \n" +
                            "    ,'admin'\n" +
                            "    ,'admin'\n" +
                            " FROM INFORMATION_SCHEMA.COLUMNS A\n" +
                            " WHERE 1=1\n" +
                            " AND  A.TABLE_SCHEMA = '" + archiveOwner + "'\n" +
                            " and A.TABLE_NAME = '" + table_name + "'\n" +
                            " and A.COLUMN_NAME = '" + column_name + "'\n" +
                            " ORDER BY 1,2,3,5"
            ;

        } else if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT '" + db + "' AS DB\n" +
                    "    , A.OWNER\n" +
                    "    , A.TABLE_NAME\n" +
                    "    , A.COLUMN_NAME\n" +
                    "    , A.COLUMN_ID AS COL_ORDER\n" +
                    "    , CASE WHEN EXISTS (\n" +
                    "        SELECT 1 FROM ALL_CONS_COLUMNS CC\n" +
                    "        JOIN ALL_CONSTRAINTS C ON C.CONSTRAINT_NAME = CC.CONSTRAINT_NAME AND C.OWNER = CC.OWNER\n" +
                    "        WHERE C.CONSTRAINT_TYPE = 'P'\n" +
                    "          AND CC.OWNER = A.OWNER AND CC.TABLE_NAME = A.TABLE_NAME AND CC.COLUMN_NAME = A.COLUMN_NAME\n" +
                    "      ) THEN 'Y' ELSE NULL END AS PK_YN\n" +
                    "    , NULL AS PK_POSITION\n" +
                    "    , A.DATA_TYPE AS FULL_DATA_TYPE\n" +
                    "    , A.DATA_TYPE\n" +
                    "    , A.DATA_LENGTH\n" +
                    "    , A.NULLABLE\n" +
                    "    , SUBSTR(B.COMMENTS, 1, 200) AS COMMENTS\n" +
                    "    , SYSDATE\n" +
                    "    , SYSDATE\n" +
                    "    , 'admin'\n" +
                    "    , 'admin'\n" +
                    " FROM ALL_TAB_COLUMNS A\n" +
                    " LEFT JOIN ALL_COL_COMMENTS B ON B.OWNER = A.OWNER AND B.TABLE_NAME = A.TABLE_NAME AND B.COLUMN_NAME = A.COLUMN_NAME\n" +
                    " WHERE A.OWNER = '" + archiveOwner + "'\n" +
                    "   AND A.TABLE_NAME = '" + table_name + "'\n" +
                    "   AND A.COLUMN_NAME = '" + column_name + "'\n" +
                    " ORDER BY A.OWNER, A.TABLE_NAME, A.COLUMN_ID"
            ;

        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
            sql = "SELECT '" + db + "' AS DB\n" +
                    "    , UPPER(A.table_schema) AS OWNER\n" +
                    "    , UPPER(A.table_name) AS TABLE_NAME\n" +
                    "    , UPPER(A.column_name) AS COLUMN_NAME\n" +
                    "    , A.ordinal_position AS COL_ORDER\n" +
                    "    , CASE WHEN EXISTS (\n" +
                    "        SELECT 1 FROM information_schema.key_column_usage K\n" +
                    "        JOIN information_schema.table_constraints T ON T.constraint_name = K.constraint_name AND T.table_schema = K.table_schema\n" +
                    "        WHERE T.constraint_type = 'PRIMARY KEY'\n" +
                    "          AND K.table_schema = A.table_schema AND K.table_name = A.table_name AND K.column_name = A.column_name\n" +
                    "      ) THEN 'Y' ELSE NULL END AS PK_YN\n" +
                    "    , NULL AS PK_POSITION\n" +
                    "    , UPPER(A.data_type) AS FULL_DATA_TYPE\n" +
                    "    , UPPER(A.udt_name) AS DATA_TYPE\n" +
                    "    , A.character_maximum_length AS DATA_LENGTH\n" +
                    "    , CASE WHEN A.is_nullable = 'YES' THEN 'Y' ELSE 'N' END AS NULLABLE\n" +
                    "    , NULL AS COMMENTS\n" +
                    "    , NOW()\n" +
                    "    , NOW()\n" +
                    "    , 'admin'\n" +
                    "    , 'admin'\n" +
                    " FROM information_schema.columns A\n" +
                    " WHERE UPPER(A.table_schema) = '" + archiveOwner + "'\n" +
                    "   AND UPPER(A.table_name) = '" + table_name + "'\n" +
                    "   AND UPPER(A.column_name) = '" + column_name + "'\n" +
                    " ORDER BY 1, 2, 3, 5"
            ;
        }
        return sql;
    }

    public static String getSelDlmarcPiitable(String dbtype, String db, String owner, String table_name) {
        String sql = "";
        if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            sql = "select  *" +
                    " from cotdl.tbl_piitable a\n" +
                    " where 1=1\n" +
                    " and  a.db = '" + db + "'\n" +
                    " and  a.owner = '" + owner + "'\n" +
                    " and a.table_name = '" + table_name + "'\n" +
                    " order by 1,2,3,5"
            ;

        }
        return sql;
    }

    /**
     * 아카이브 테이블의 PII 5개 컬럼에 대해 개별 인덱스 CREATE DDL 목록을 반환한다.
     * 인덱스명은 Oracle 30자 제한을 고려하여 테이블명을 20자로 절단한다.
     *
     * @param arcDbType   아카이브 DB 타입
     * @param arcSchema   아카이브 스키마명
     * @param tableName   테이블명
     * @return CREATE INDEX DDL 문자열 배열 (5개)
     */
    public static String[] getArcTableIndexDdls(String arcDbType, String arcSchema, String tableName) {
        String[] piiCols = {"PII_ORDER_ID", "PII_BASE_DATE", "PII_CUST_ID", "PII_JOB_ID", "PII_DESTRUCT_DATE"};
        String[] ddls = new String[piiCols.length];

        // Oracle 인덱스명 30자 제한, PostgreSQL 63자, MySQL 64자 — 안전하게 30자 기준
        String tblShort = tableName.length() > 16 ? tableName.substring(0, 16) : tableName;

        for (int i = 0; i < piiCols.length; i++) {
            // 인덱스명: IDX_{테이블축약}_{컬럼축약} (예: IDX_CUSTOMER_PORDID)
            String colShort = piiCols[i].replace("PII_", "P").replace("DESTRUCT_", "D");
            String idxName = "IDX_" + tblShort + "_" + colShort;
            // 최종 30자 초과 시 절단
            if (idxName.length() > 30) {
                idxName = idxName.substring(0, 30);
            }

            if (arcDbType.equalsIgnoreCase("ORACLE") || arcDbType.equalsIgnoreCase("TIBERO")) {
                // Oracle: 스키마.인덱스명 ON 스키마.테이블명
                ddls[i] = "CREATE INDEX " + arcSchema + "." + idxName +
                        " ON " + arcSchema + "." + tableName + " (" + piiCols[i] + ")";
            } else {
                // MariaDB/MySQL/PostgreSQL: 인덱스명 ON 스키마.테이블명
                ddls[i] = "CREATE INDEX " + idxName +
                        " ON " + arcSchema + "." + tableName + " (" + piiCols[i] + ")";
            }
        }
        return ddls;
    }

    /**
     * 중립 타입(Neutral Type)을 아카이브 DB 타입으로 변환한다.
     *
     * 중립 타입 규격: DECIMAL, VARCHAR, CHAR, DATETIME, TIMESTAMP, FLOAT, LONGTEXT, LONGBLOB
     * (Oracle 소스 getArcTabCreate()가 출력하는 포맷과 동일)
     *
     * 변환 매트릭스:
     *   중립 타입        Oracle/Tibero    MariaDB/MySQL    PostgreSQL
     *   ──────────────  ──────────────   ──────────────   ──────────────
     *   DECIMAL(p,s)    NUMBER(p,s)      DECIMAL(p,s)     NUMERIC(p,s)
     *   VARCHAR(n)      VARCHAR2(n)      VARCHAR(n)       VARCHAR(n)
     *   CHAR(n)         CHAR(n)          CHAR(n)          CHAR(n)
     *   DATETIME        DATE             DATETIME         TIMESTAMP
     *   TIMESTAMP(n)    TIMESTAMP(n)     TIMESTAMP(n)     TIMESTAMP(n)
     *   FLOAT(p)        FLOAT(p)         FLOAT            DOUBLE PRECISION
     *   LONGTEXT        CLOB             LONGTEXT         TEXT
     *   LONGBLOB        BLOB             LONGBLOB         BYTEA
     *   ENGINE=InnoDB.. (제거)           (유지)            (제거)
     */
    public static String getArcTabCreateSql(String dbtype, String str) {
        if (str == null || str.isEmpty()) return str;
        String rst = str;

        if (dbtype.equalsIgnoreCase("ORACLE") || dbtype.equalsIgnoreCase("TIBERO")) {
            // 순서 중요: LONGTEXT/LONGBLOB를 먼저 변환 (VARCHAR 치환이 LONGTEXT 내부 매칭 방지)
            rst = rst.replaceAll("(?i)\\bLONGTEXT\\b", "CLOB");
            rst = rst.replaceAll("(?i)\\bLONGBLOB\\b", "BLOB");
            rst = rst.replaceAll("(?i)\\bDECIMAL\\b", "NUMBER");
            // VARCHAR2 이미 들어온 경우 대비: VARCHAR 뒤에 숫자가 오지 않는 경우만 (VARCHAR2→VARCHAR22 방지)
            rst = rst.replaceAll("(?i)\\bVARCHAR\\b(?!2)", "VARCHAR2");
            rst = rst.replaceAll("(?i)\\bDATETIME\\b", "DATE");
            rst = rst.replaceAll("(?i) ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4", "");

        } else if (dbtype.equalsIgnoreCase("MARIADB") || dbtype.equalsIgnoreCase("MYSQL")) {
            // 중립 타입이 MariaDB/MySQL 네이티브와 동일하므로 변환 불필요

        } else if (dbtype.equalsIgnoreCase("POSTGRESQL")) {
            rst = rst.replaceAll("(?i)\\bLONGTEXT\\b", "TEXT");
            rst = rst.replaceAll("(?i)\\bLONGBLOB\\b", "BYTEA");
            rst = rst.replaceAll("(?i)\\bDECIMAL\\b", "NUMERIC");
            rst = rst.replaceAll("(?i)\\bDATETIME\\b", "TIMESTAMP");
            // FLOAT(p) → DOUBLE PRECISION (PostgreSQL은 정밀도 파라미터 없이 사용)
            rst = rst.replaceAll("(?i)\\bFLOAT\\(\\d+\\)", "DOUBLE PRECISION");
            rst = rst.replaceAll("(?i)\\bFLOAT\\b", "DOUBLE PRECISION");
            rst = rst.replaceAll("(?i) ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4", "");

        } else if (dbtype.equalsIgnoreCase("DB2")) {
            rst = rst.replaceAll("(?i)\\bLONGTEXT\\b", "CLOB");
            rst = rst.replaceAll("(?i)\\bLONGBLOB\\b", "BLOB");
            rst = rst.replaceAll("(?i)\\bDATETIME\\b", "TIMESTAMP");
            rst = rst.replaceAll("(?i) ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4", "");

        } else if (dbtype.equalsIgnoreCase("MSSQL")) {
            rst = rst.replaceAll("(?i)\\bLONGTEXT\\b", "NVARCHAR(MAX)");
            rst = rst.replaceAll("(?i)\\bLONGBLOB\\b", "VARBINARY(MAX)");
            rst = rst.replaceAll("(?i)\\bDATETIME\\b", "DATETIME2");
            rst = rst.replaceAll("(?i) ENGINE=INNODB DEFAULT CHARACTER SET = UTF8MB4", "");
        }
        return rst;
    }

    /**
     * MariaDB/MySQL "Row size too large" 에러 판별.
     * MySQL error 1118 (ER_TOO_BIG_ROWSIZE) 또는 에러 메시지에 "Row size too large" 포함 시 true.
     */
    public static boolean isRowSizeTooLargeError(SQLException e) {
        if (e == null) return false;
        if (e.getErrorCode() == 1118) return true;
        String msg = e.getMessage();
        return msg != null && msg.toLowerCase().contains("row size too large");
    }

    /**
     * ALTER TABLE ADD COLUMN DDL 내 VARCHAR(n) → TEXT 변환.
     * MariaDB InnoDB row size 초과 시, 추가되는 컬럼만 off-page 저장되는 TEXT로 변환한다.
     * (TEXT는 in-row ~20 bytes 포인터만 차지하므로 row size 제한을 회피할 수 있다)
     *
     * @param alterDdl ALTER TABLE ADD COLUMN DDL (단일 컬럼)
     * @return VARCHAR(n) → TEXT 치환된 DDL
     */
    public static String convertVarcharToTextForRowSize(String alterDdl) {
        if (alterDdl == null || alterDdl.isEmpty()) return alterDdl;
        Pattern p = Pattern.compile("(?i)\\bVARCHAR\\(\\d+\\)");
        Matcher m = p.matcher(alterDdl);
        StringBuffer sb = new StringBuffer();
        String original = null;
        while (m.find()) {
            original = m.group();
            m.appendReplacement(sb, "TEXT");
        }
        m.appendTail(sb);
        if (original != null) {
            logger.warn("[ROW_SIZE_FIX] Converted {} → TEXT for row size limit", original);
        }
        return sb.toString();
    }

    // ── Row Size 추정 및 CREATE TABLE DDL 자동 최적화 ──────────────────────

    private static final int MAX_ROW_SIZE = 65000; // 65,535에서 여유분 확보
    private static final int TEXT_POINTER_SIZE = 20; // TEXT off-page 포인터 크기

    /**
     * CREATE TABLE DDL의 row size를 추정한다.
     * MariaDB/MySQL InnoDB 기준 UTF8MB4 worst-case 계산.
     *
     * VARCHAR(n): n × 4 + 2 bytes (UTF8MB4 최대 + length prefix)
     * CHAR(n):    n × 4 bytes
     * DECIMAL(p): p/2 + 1 bytes
     * DATETIME:   8 bytes
     * TIMESTAMP:  4 bytes
     * FLOAT:      8 bytes
     * TEXT/LONGTEXT/LONGBLOB: ~20 bytes (off-page pointer)
     */
    public static int estimateRowSize(String ddl) {
        if (ddl == null || ddl.isEmpty()) return 0;
        int size = 0;

        // VARCHAR(n) → n * 4 + 2
        Matcher m = Pattern.compile("(?i)\\bVARCHAR\\((\\d+)\\)").matcher(ddl);
        while (m.find()) size += Integer.parseInt(m.group(1)) * 4 + 2;

        // CHAR(n) → n * 4 (VARCHAR 내부의 CHAR는 \b로 구분)
        m = Pattern.compile("(?i)(?<!VAR)\\bCHAR\\((\\d+)\\)").matcher(ddl);
        while (m.find()) size += Integer.parseInt(m.group(1)) * 4;

        // DECIMAL(p,...) → p/2 + 1
        m = Pattern.compile("(?i)\\bDECIMAL\\((\\d+)").matcher(ddl);
        while (m.find()) size += Integer.parseInt(m.group(1)) / 2 + 1;

        // DATETIME → 8
        m = Pattern.compile("(?i)\\bDATETIME\\b").matcher(ddl);
        while (m.find()) size += 8;

        // TIMESTAMP → 4
        m = Pattern.compile("(?i)\\bTIMESTAMP(\\(\\d+\\))?\\b").matcher(ddl);
        while (m.find()) size += 4;

        // FLOAT → 8
        m = Pattern.compile("(?i)\\bFLOAT(\\(\\d+\\))?\\b").matcher(ddl);
        while (m.find()) size += 8;

        // TEXT, LONGTEXT → 20 (off-page pointer)
        m = Pattern.compile("(?i)\\b(LONG)?TEXT\\b").matcher(ddl);
        while (m.find()) size += TEXT_POINTER_SIZE;

        // LONGBLOB → 20
        m = Pattern.compile("(?i)\\bLONGBLOB\\b").matcher(ddl);
        while (m.find()) size += TEXT_POINTER_SIZE;

        return size;
    }

    /**
     * CREATE TABLE DDL의 row size가 MariaDB 제한(65,535 bytes)을 초과하면,
     * 가장 큰 VARCHAR 컬럼부터 TEXT로 반복 변환하여 row size를 맞춘다.
     * MariaDB/MySQL 아카이브 DB일 때만 적용되며, Oracle/PostgreSQL 등은 row size 제한이 다르므로 원본 DDL을 그대로 반환한다.
     *
     * @param arcDbtype 아카이브 DB 타입 (MARIADB, MYSQL, ORACLE, POSTGRESQL 등)
     * @param createDdl CREATE TABLE DDL 전체
     * @return row size가 제한 이내로 최적화된 DDL (MariaDB/MySQL 아닌 경우 또는 변환 불필요 시 원본 반환)
     */
    public static String optimizeDdlForRowSize(String arcDbtype, String createDdl) {
        // MariaDB/MySQL만 65,535 bytes row size 제한 적용
        if (arcDbtype == null || (!arcDbtype.equalsIgnoreCase("MARIADB") && !arcDbtype.equalsIgnoreCase("MYSQL"))) {
            return createDdl;
        }
        if (createDdl == null || createDdl.isEmpty()) return createDdl;

        String result = createDdl;
        int estimated = estimateRowSize(result);
        if (estimated <= MAX_ROW_SIZE) return result;

        logger.warn("[ROW_SIZE_FIX] Estimated row size {} bytes exceeds limit {} bytes. Optimizing...", estimated, MAX_ROW_SIZE);

        while (estimated > MAX_ROW_SIZE) {
            // 가장 큰 VARCHAR(n) 찾기
            Matcher m = Pattern.compile("(?i)\\bVARCHAR\\((\\d+)\\)").matcher(result);
            int maxLen = 0;
            int matchStart = -1;
            int matchEnd = -1;
            while (m.find()) {
                int len = Integer.parseInt(m.group(1));
                if (len > maxLen) {
                    maxLen = len;
                    matchStart = m.start();
                    matchEnd = m.end();
                }
            }
            if (matchStart == -1) break; // VARCHAR 없음 → 더 이상 변환 불가

            // VARCHAR(n) → TEXT 치환
            result = result.substring(0, matchStart) + "TEXT" + result.substring(matchEnd);
            estimated = estimateRowSize(result);
            logger.warn("[ROW_SIZE_FIX] VARCHAR({}) → TEXT (estimated row size: {} bytes)", maxLen, estimated);
        }

        return result;
    }

    /**
     * ResultSet를 Map으로 변환하는 함수
     */
    public static Map<Integer, Object> resultSetToMap(ResultSet resultSet) throws SQLException {
        ResultSetMetaData metaData = resultSet.getMetaData();
        int columnCount = metaData.getColumnCount();
        Map<Integer, Object> rowData = new HashMap<>();


        for (int i = 1; i <= columnCount; i++) {
            //String columnName = metaData.getColumnName(i);
            Object columnValue = resultSet.getObject(i);
            rowData.put(i, columnValue);
        }

        return rowData;
    }

    /**
     *  INDEX 와 CONSTRAINT 을 모두 추출한다.
     * */
    public static String getSqlAllIndexCons(String dbType, String table_owner, String table_name) throws SQLException {
        /**    ORACLE, TIBERO 테스트 함     */
        String sql = "";
        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "SELECT INDEX_NAME " +
                    "FROM information_schema.statistics " +
                    "WHERE table_schema = '" + table_owner + "' AND table_name = '" + table_name + "'";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "SELECT indexname AS INDEX_NAME " +
                    "FROM pg_indexes " +
                    "WHERE schemaname = '" + table_owner + "' AND tablename = '" + table_name + "'";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "SELECT name AS INDEX_NAME " +
                    "FROM sys.indexes " +
                    "WHERE object_id = OBJECT_ID(?)";
        }
        else if (dbType.equalsIgnoreCase("ORACLE")) {
            /*sql = "SELECT * FROM (" +
                    "SELECT i.OWNER AS INDEX_OWNER, i.INDEX_NAME, i.TABLE_OWNER, i.TABLE_NAME AS TABLE_NAME, c.CONSTRAINT_TYPE, i.STATUS AS STATUS, 'INDEX' AS OBJECT_TYPE,\n" +
                    "       DBMS_LOB.SUBSTR(DBMS_METADATA.GET_DDL('INDEX', i.INDEX_NAME, i.OWNER), 4000, 1) || ' PARALLEL' AS CONSTRAINT_DDL\n" +
                    "FROM ALL_INDEXES i\n" +
                    "LEFT JOIN ALL_CONSTRAINTS c ON i.OWNER = c.OWNER AND i.INDEX_NAME = c.CONSTRAINT_NAME\n" +
                    "WHERE i.TABLE_OWNER = '" + table_owner + "' AND i.TABLE_NAME = '" + table_name + "'\n" +
                    "UNION\n" +
                    "SELECT c.OWNER AS INDEX_OWNER, c.CONSTRAINT_NAME AS INDEX_NAME, c.OWNER AS TABLE_OWNER, c.TABLE_NAME AS TABLE_NAME, c.CONSTRAINT_TYPE, c.STATUS AS STATUS, 'CONSTRAINT' AS OBJECT_TYPE,\n" +
                    "      CASE\n" +
                    "        WHEN c.CONSTRAINT_TYPE IN ('P', 'U') THEN\n" +
                    "            DBMS_LOB.SUBSTR(DBMS_METADATA.GET_DDL('CONSTRAINT', c.CONSTRAINT_NAME, c.OWNER), 4000, 1)\n" +
                    "        ELSE\n" +
                    "            NULL\n" +
                    "       END AS CONSTRAINT_DDL\n" +
                    "FROM ALL_CONSTRAINTS c\n" +
                    "WHERE c.CONSTRAINT_TYPE IN ('P', 'U', 'R') AND c.OWNER = '" + table_owner + "' AND c.TABLE_NAME = '" + table_name + "'\n" +
                    ")\n" +
                    "ORDER BY OBJECT_TYPE, CONSTRAINT_TYPE";*/
            /*20250315 CONSTRAINT 생성 시 기존 PK, UNIQUE 인덱스와 연결하는 DDL로 수정*/
            sql = "SELECT * FROM (" +
                    "SELECT i.OWNER AS INDEX_OWNER, i.INDEX_NAME, i.TABLE_OWNER, i.TABLE_NAME AS TABLE_NAME, c.CONSTRAINT_TYPE, i.STATUS AS STATUS, 'INDEX' AS OBJECT_TYPE,\n" +
                    "       DBMS_LOB.SUBSTR(DBMS_METADATA.GET_DDL('INDEX', i.INDEX_NAME, i.OWNER), 4000, 1) || ' PARALLEL' AS CONSTRAINT_DDL\n" +
                    "FROM ALL_INDEXES i\n" +
                    "LEFT JOIN ALL_CONSTRAINTS c ON i.OWNER = c.OWNER AND i.INDEX_NAME = c.CONSTRAINT_NAME\n" +
                    "WHERE i.TABLE_OWNER = '" + table_owner + "' AND i.TABLE_NAME = '" + table_name + "'\n" +
                    "UNION\n" +
                    "SELECT \n" +
                    "    c.OWNER AS INDEX_OWNER, \n" +
                    "    c.CONSTRAINT_NAME AS INDEX_NAME, \n" +
                    "    c.OWNER AS TABLE_OWNER, \n" +
                    "    c.TABLE_NAME AS TABLE_NAME, \n" +
                    "    c.CONSTRAINT_TYPE, \n" +
                    "    c.STATUS AS STATUS, \n" +
                    "    'CONSTRAINT' AS OBJECT_TYPE, \n" +
                    "    CASE \n" +
                    "        WHEN c.CONSTRAINT_TYPE IN ('P', 'U') THEN \n" +
                    "            'ALTER TABLE \"' || c.OWNER || '\".\"' || c.TABLE_NAME || '\" ' || \n" +
                    "            'ADD CONSTRAINT \"' || c.CONSTRAINT_NAME || '\" ' || \n" +
                    "            CASE \n" +
                    "                WHEN c.CONSTRAINT_TYPE = 'P' THEN 'PRIMARY KEY (' \n" +
                    "                ELSE 'UNIQUE (' \n" +
                    "            END || \n" +
                    "            LISTAGG(cc.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY cc.POSITION) || ') ' || \n" +
                    "            'USING INDEX \"' || i.OWNER || '\".\"' || i.INDEX_NAME  \n" +
                    "        WHEN c.CONSTRAINT_TYPE = 'R' THEN \n" +
                    "            NULL \n" +
                    "        ELSE \n" +
                    "            NULL \n" +
                    "    END AS CONSTRAINT_DDL \n" +
                    "FROM \n" +
                    "    ALL_CONSTRAINTS c \n" +
                    "JOIN \n" +
                    "    ALL_CONS_COLUMNS cc ON c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME AND c.OWNER = cc.OWNER \n" +
                    "JOIN \n" +
                    "    ALL_INDEXES i ON c.OWNER = i.TABLE_OWNER AND c.CONSTRAINT_NAME = i.INDEX_NAME \n" +
                    "WHERE \n" +
                    "    c.CONSTRAINT_TYPE IN ('P', 'U', 'R') \n" +
                    "    AND c.OWNER = '" + table_owner + "' \n" +
                    "    AND c.TABLE_NAME = '" + table_name + "' \n" +
                    "GROUP BY \n" +
                    "    c.OWNER, c.CONSTRAINT_NAME, c.TABLE_NAME, c.CONSTRAINT_TYPE, c.STATUS, \n" +
                    "    i.OWNER, i.INDEX_NAME \n"  +
                ")\n" +
                    "ORDER BY OBJECT_TYPE, CONSTRAINT_TYPE";
        }
        else if (dbType.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT * FROM (\n" +
                    "    SELECT i.OWNER AS INDEX_OWNER, i.INDEX_NAME, i.TABLE_OWNER, i.TABLE_NAME AS TABLE_NAME, c.CONSTRAINT_TYPE, i.STATUS AS STATUS, 'INDEX' AS OBJECT_TYPE,\n" +
                    "         CASE\n" +
                        "        WHEN CAST(SUBSTR(DBMS_METADATA.GET_DDL('INDEX', i.INDEX_NAME, i.OWNER), 1, 4000) AS VARCHAR2(4000)) IS NULL THEN\n" +
                        "            (SELECT 'CREATE INDEX ' ||  INDEX_OWNER || '.' || INDEX_NAME || ' ON ' || MAX(TABLE_OWNER) || '.' || MAX(TABLE_NAME) || ' ('||WM_CONCAT(COLUMN_NAME)||')' AS DDLSQL\n" +
                        "            FROM ALL_IND_COLUMNS n\n" +
                        "            WHERE TABLE_OWNER = '" + table_owner + "' AND TABLE_NAME = '" + table_name + "' AND n.INDEX_NAME = i.INDEX_NAME\n" +
                        "            GROUP BY INDEX_OWNER, INDEX_NAME)\n" +
                        "        ELSE\n" +
                        "            RTRIM(CAST(SUBSTR(DBMS_METADATA.GET_DDL('INDEX', i.INDEX_NAME, i.OWNER), 1, 4000) AS VARCHAR2(4000)), ';') \n" +
                    "           END AS CONSTRAINT_DDL\n" +
                    "    FROM ALL_INDEXES i\n" +
                    "    LEFT JOIN ALL_CONSTRAINTS c ON i.OWNER = c.OWNER AND i.INDEX_NAME = c.CONSTRAINT_NAME\n" +
                    "    WHERE i.TABLE_OWNER = '" + table_owner + "' AND i.TABLE_NAME = '" + table_name + "'\n" +
                    "    UNION\n" +
                    "    SELECT c.OWNER AS INDEX_OWNER, c.CONSTRAINT_NAME AS INDEX_NAME, c.OWNER AS TABLE_OWNER, c.TABLE_NAME AS TABLE_NAME, c.CONSTRAINT_TYPE, c.STATUS AS STATUS, 'CONSTRAINT' AS OBJECT_TYPE,\n" +
                    "        CASE\n" +
                    "            WHEN c.CONSTRAINT_TYPE IN ('P', 'U') THEN\n" +
                    "                CAST(SUBSTR(DBMS_METADATA.GET_DDL('CONSTRAINT', c.CONSTRAINT_NAME, c.OWNER), 1, 4000) AS VARCHAR2(4000))\n" +
                    "            ELSE\n" +
                    "                NULL\n" +
                    "        END AS CONSTRAINT_DDL\n" +
                    "    FROM ALL_CONSTRAINTS c\n" +
                    "    WHERE c.CONSTRAINT_TYPE IN ('P', 'U', 'R') AND c.OWNER = '" + table_owner + "' AND c.TABLE_NAME = '" + table_name + "'\n" +
                    ")\n" +
                    "ORDER BY OBJECT_TYPE, CONSTRAINT_TYPE";
        }


        return sql;
    }

    /**
     * 테이블의 컬럼별 인덱스 정보(인덱스명, 포지션) 조회 SQL 생성
     */
    public static String getSqlColumnIndexInfo(String dbType, String table_owner, String table_name) throws SQLException {
        String sql = "";
        if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT COLUMN_NAME, INDEX_NAME, COLUMN_POSITION " +
                    "FROM ALL_IND_COLUMNS " +
                    "WHERE TABLE_OWNER = '" + table_owner + "' AND TABLE_NAME = '" + table_name + "' " +
                    "ORDER BY COLUMN_NAME, INDEX_NAME, COLUMN_POSITION";
        } else if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "SELECT COLUMN_NAME, INDEX_NAME, SEQ_IN_INDEX AS COLUMN_POSITION " +
                    "FROM information_schema.STATISTICS " +
                    "WHERE TABLE_SCHEMA = '" + table_owner + "' AND TABLE_NAME = '" + table_name + "' " +
                    "ORDER BY COLUMN_NAME, INDEX_NAME, SEQ_IN_INDEX";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "SELECT a.attname AS COLUMN_NAME, i.relname AS INDEX_NAME, " +
                    "array_position(ix.indkey, a.attnum) AS COLUMN_POSITION " +
                    "FROM pg_class t " +
                    "JOIN pg_index ix ON t.oid = ix.indrelid " +
                    "JOIN pg_class i ON i.oid = ix.indexrelid " +
                    "JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey) " +
                    "JOIN pg_namespace n ON n.oid = t.relnamespace " +
                    "WHERE n.nspname = '" + table_owner + "' AND t.relname = '" + table_name + "' " +
                    "ORDER BY a.attname, i.relname";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "SELECT COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME, " +
                    "i.name AS INDEX_NAME, ic.key_ordinal AS COLUMN_POSITION " +
                    "FROM sys.indexes i " +
                    "JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id " +
                    "WHERE i.object_id = OBJECT_ID('" + table_owner + "." + table_name + "') " +
                    "ORDER BY COLUMN_NAME, INDEX_NAME, COLUMN_POSITION";
        }
        return sql;
    }

    public static String getChildTableConstraintsSql(String dbType, String table_owner, String table_name) throws SQLException {
        String sql = "";
        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "SELECT CONSTRAINT_NAME, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, null AS CONSTRAINT_DDL " +
                    "FROM information_schema.key_column_usage " +
                    "WHERE referenced_table_schema = '" + table_owner + "' " +
                    "  AND referenced_table_name = '" + table_name + "'";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "SELECT conname AS CONSTRAINT_NAME, confrelid::regclass AS TABLE_NAME, confkey AS COLUMN_NAME, null AS CONSTRAINT_DDL " +
                    "FROM pg_constraint " +
                    "WHERE confrelid = '" + table_owner + "." + table_name + "'::regclass";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "SELECT name AS CONSTRAINT_NAME, OBJECT_NAME(parent_object_id) AS TABLE_NAME, " +
                    "COL_NAME(parent_object_id, parent_column_id) AS COLUMN_NAME, null AS CONSTRAINT_DDL " +
                    "FROM sys.foreign_keys " +
                    "WHERE referenced_object_id = OBJECT_ID(?)";
        }
        else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            sql = "SELECT\n" +
                    "    c.OWNER AS INDEX_OWNER,\n" +
                    "    c.CONSTRAINT_NAME AS INDEX_NAME,\n" +
                    "    c.OWNER AS TABLE_OWNER,\n" +
                    "    c.TABLE_NAME AS TABLE_NAME,\n" +
                    "    c.CONSTRAINT_TYPE,\n" +
                    "    c.STATUS AS STATUS,\n" +
                    "    'CONSTRAINT' AS OBJECT_TYPE,\n" +
                    "    NULL AS CONSTRAINT_DDL\n" +
                    "FROM ALL_CONSTRAINTS c " +
                    "WHERE R_CONSTRAINT_NAME IN (" +
                    "    SELECT CONSTRAINT_NAME " +
                    "    FROM ALL_CONSTRAINTS " +
                    "    WHERE TABLE_NAME = '" + table_name + "' AND OWNER = '" + table_owner + "' AND CONSTRAINT_TYPE IN ('P', 'U')" +
                    ")";
        }

        return sql;
    }


    public static String getForeignKeySql(String dbType) throws SQLException {
        String sql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            // MySQL 및 MariaDB에서는 현재 테이블의 PK를 참조하는 FK 및 다른 테이블에서 참조하는 FK를 모두 조회하는 SQL
            sql = "SELECT CONSTRAINT_NAME " +
                    "FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE " +
                    "WHERE (TABLE_SCHEMA = ? AND TABLE_NAME = ?) " +
                    "OR (REFERENCED_TABLE_SCHEMA = ? AND REFERENCED_TABLE_NAME = ?)";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL에서는 현재 테이블의 PK를 참조하는 FK 및 다른 테이블에서 참조하는 FK를 모두 조회하는 SQL
            sql = "SELECT conname AS CONSTRAINT_NAME " +
                    "FROM pg_constraint " +
                    "WHERE conrelid  = ?::regclass " + //-- FK를 참조하는 경우
                    "UNION " +
                    "SELECT conname AS CONSTRAINT_NAME " +
                    "FROM pg_constraint " +
                    "WHERE confrelid != ?::regclass";  //-- FK를 참조당하는 경우
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            // MSSQL에서는 현재 테이블의 PK를 참조하는 FK 및 다른 테이블에서 참조하는 FK를 모두 조회하는 SQL
            sql = "SELECT name AS CONSTRAINT_NAME " +
                    "FROM sys.foreign_keys " +
                    "WHERE (parent_object_id = OBJECT_ID(?)) " +
                    "OR (referenced_object_id = OBJECT_ID(?))";
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            // Oracle 및 Tibero에서는 현재 테이블의 PK를 참조하는 FK 및 다른 테이블에서 참조하는 FK를 모두 조회하는 SQL
            sql = "SELECT CONSTRAINT_NAME " +
                    "FROM ALL_CONSTRAINTS " +
                    "WHERE (OWNER = ? and TABLE_NAME = ? AND CONSTRAINT_TYPE = 'R') " +
                    "OR (R_CONSTRAINT_NAME IN (" +
                    "    SELECT CONSTRAINT_NAME " +
                    "    FROM ALL_CONSTRAINTS " +
                    "    WHERE OWNER = ? and TABLE_NAME = ? AND CONSTRAINT_TYPE = 'P'" +
                    "  ) " +
                    "  AND CONSTRAINT_TYPE = 'R')";
        }

        return sql;
    }
    public static String getSqlUnusableIndexCons(String dbType, String indexOwner, String indexName, String constraint_type, String object_type, String tableOwner, String tableName) {
        String sql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "ALTER INDEX " + indexOwner + "." + indexName + " UNUSABLE";  // MySQL/MariaDB에서 UNUSABLE 처리
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "ALTER INDEX " + indexName + " UNUSABLE";  // PostgreSQL에서 UNUSABLE 처리
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "ALTER INDEX " + indexName + " DISABLE";  // MSSQL에서 비활성화 처리 (UNUSABLE에 대응)
        } else if (dbType.equalsIgnoreCase("ORACLE")) {
            if ("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type)) {
                if (object_type.equalsIgnoreCase("CONSTRAINT")) {
                    sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;  // PK/Unique 제약조건 비활성화
                } else {
                    sql = "ALTER INDEX " + indexOwner + "." + indexName + " UNUSABLE";  // 인덱스 UNUSABLE 처리
                }
            } else if ("R".equalsIgnoreCase(constraint_type)) {
                // 'R'인 경우에는 FK 제약 조건을 DISABLE 하는 로직 추가
                sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;
            } else {
                sql = "ALTER INDEX " + indexOwner + "." + indexName + " UNUSABLE";  // 기타 인덱스 UNUSABLE 처리
            }
        } else if (dbType.equalsIgnoreCase("TIBERO")) {
            if ("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type)) {
                // Tibero에서는 PK 제약 조건을 먼저 비활성화해야 함
                if (object_type.equalsIgnoreCase("CONSTRAINT")) {
                    sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;  // PK/Unique 제약조건 비활성화
                } else {
                    sql = "ALTER INDEX " + indexOwner + "." + indexName + " UNUSABLE";  // 인덱스 UNUSABLE 처리
                }
            } else if ("R".equalsIgnoreCase(constraint_type)) {
                sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;  // FK 제약조건 비활성화
            } else {
                sql = "ALTER INDEX " + indexOwner + "." + indexName + " UNUSABLE";  // 기타 인덱스 UNUSABLE 처리
            }
        }

        return sql;
    }

    public static String getSqlDropIndexCons(String dbType, String indexOwner, String indexName, String constraint_type, String object_type, String tableOwner, String tableName) {
        String sql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "DROP INDEX " + indexOwner + "." + indexName + " ON " + indexName;// 인덱스 소유자 제거
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "DROP INDEX "  + indexName;
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "DROP INDEX " + indexName;
        } else if (dbType.equalsIgnoreCase("ORACLE") ) {
            if ("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type)) {
                if (object_type.equalsIgnoreCase("CONSTRAINT")) {
                    sql = "ALTER TABLE " + tableOwner + "." + tableName + " DROP " +
                            ("P".equalsIgnoreCase(constraint_type) ? "PRIMARY KEY" : "UNIQUE");
                } else {
                    sql = "DROP INDEX " + indexOwner + "." +  indexName;
                }
            } else if ("R".equalsIgnoreCase(constraint_type)) {
                // 'R'인 경우에는 CONSTRAINT를 DISABLE 하는 로직 추가
                sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;
            } else {
                sql = "DROP INDEX " + indexOwner + "." +  indexName;
            }

        } else if (dbType.equalsIgnoreCase("TIBERO")) {
            if ("P".equalsIgnoreCase(constraint_type) || "U".equalsIgnoreCase(constraint_type)) {
                // Tibero에서는 PK 제약 조건을 먼저 삭제해야 함 아래 쿼리가 INDEX 까지 DROP 한다
                if (object_type.equalsIgnoreCase("CONSTRAINT")) {
                    sql = "ALTER TABLE " + tableOwner + "." + tableName + " DROP CONSTRAINT " + indexName;
                } else {
                    sql = "DROP INDEX " + indexOwner + "." +  indexName;
                }
            } else if ("R".equalsIgnoreCase(constraint_type)) {
                // 'R'인 경우에는 CONSTRAINT를 DISABLE 하는 로직 추가
                sql = "ALTER TABLE " + tableOwner + "." + tableName + " DISABLE CONSTRAINT " + indexName;
            } else {
                sql = "DROP INDEX " + indexOwner + "." +  indexName;
            }
        }

        return sql;
    }

    public static String getDisableIndexSql(String dbType, String owner, String tableName, String indexName) throws SQLException {
        String sql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "ALTER TABLE " + tableName + " DISABLE INDEX " + indexName;
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "ALTER INDEX " + indexName + " DISABLE";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "ALTER INDEX " + indexName + " ON " + tableName + " DISABLE";
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            sql = "ALTER INDEX " + indexName + " UNUSABLE";//Oracle과 Tibero에서는 인덱스 이름에 소유자를 포함하지 않습니다.
        } else {
            throw new IllegalArgumentException("Unsupported database type: " + dbType);
        }

        return sql;
    }


    public static String[] getRebuildIndexSql(String dbType, String owner, String tableName, String indexOwner, String indexName, int numScrambleThreads) throws SQLException {
        String[] sqlStatements;
        String fullTableName =  owner + "." + tableName;
        String fullIndexName =  indexOwner + "." + indexName;
        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            // MySQL/MariaDB: 병렬 힌트 직접 지원 안 함. FORCE INDEX 사용
            sqlStatements = new String[] {
                    "ALTER TABLE " + fullTableName + " FORCE INDEX (" + indexName  + ")"
            };
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL: CONCURRENTLY 옵션 사용
            sqlStatements = new String[] {
                    "REINDEX INDEX CONCURRENTLY " + fullIndexName
            };
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            // MSSQL: FILLFACTOR와 ONLINE 옵션 사용
            sqlStatements = new String[] {
                    "ALTER INDEX " + fullIndexName + " ON " + fullTableName + " REBUILD WITH (FILLFACTOR = 80, ONLINE = ON)"
            };
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            // Oracle/Tibero: 병렬 처리 후 NOPARALLEL 해제 필요
            sqlStatements = new String[] {
                    "ALTER INDEX " + fullIndexName + " REBUILD PARALLEL "+numScrambleThreads+" NOLOGGING",  // 병렬 재빌드
                    "ALTER INDEX " + fullIndexName + " NOPARALLEL"                    // 병렬 해제
            };
        } else {
            throw new IllegalArgumentException("Unsupported database type: " + dbType);
        }

        return sqlStatements;
    }

    public static String getEnableConstraintSql(String dbType, String owner, String tableName, String constraintName) throws SQLException {
        String sql = "";
        String fullTableName = owner + "." + tableName;

        switch (dbType.toUpperCase()) {
            case "MARIADB":
            case "MYSQL":
                // MySQL/MariaDB에서는 제약 조건을 ENABLE 할 필요 없이, 제약 조건을 다시 추가하는 방식
                sql = "ALTER TABLE " + fullTableName + " ADD CONSTRAINT " + constraintName + " PRIMARY KEY (" + constraintName + ")";
                break;

            case "POSTGRESQL":
                // PostgreSQL에서 제약 조건 활성화
                sql = "ALTER TABLE " + fullTableName + " ENABLE CONSTRAINT " + constraintName;
                break;

            case "MSSQL":
                // SQL Server에서 제약 조건을 ENABLE 하기 위한 SQL
                sql = "ALTER TABLE " + fullTableName + " WITH CHECK CHECK CONSTRAINT " + constraintName;
                break;

            case "ORACLE":
            case "TIBERO":
                // Oracle/Tibero에서 제약 조건 활성화
                sql = "ALTER TABLE " + fullTableName + " ENABLE CONSTRAINT " + constraintName;
                break;

            default:
                throw new IllegalArgumentException("Unsupported database type: " + dbType);
        }

        return sql;
    }



    public static String getDisableForeignKeySql(String dbType, String tableName, String fkName) throws SQLException {
        String sql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            sql = "ALTER TABLE " + tableName + " DROP FOREIGN KEY " + fkName;
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            sql = "ALTER TABLE " + tableName + " DROP CONSTRAINT " + fkName;
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            sql = "ALTER TABLE " + tableName + " NOCHECK CONSTRAINT " + fkName;
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            sql = "ALTER TABLE " + tableName + " DISABLE CONSTRAINT " + fkName;
        } else {
            throw new IllegalArgumentException("Unsupported database type: " + dbType);
        }

        return sql;
    }

    public static boolean checkTableExists(Connection connection, String dbType, String owner, String tableName) throws SQLException {
        String checkTableSql;
        switch (dbType.toUpperCase()) {
            case "ORACLE":
            case "TIBERO":
                checkTableSql = "SELECT COUNT(*) FROM all_tables WHERE owner = UPPER(?) AND table_name = UPPER(?)";
                break;

            case "MARIADB":
            case "MYSQL":
            case "POSTGRESQL":
                checkTableSql = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = ?";
                break;

            case "MSSQL":
                checkTableSql = "SELECT COUNT(*) FROM tempdb.sys.tables WHERE schema_id = SCHEMA_ID(?) AND name = ?";
                break;

            default:
                throw new SQLException("Unsupported database type: " + dbType);
        }

        try (PreparedStatement checkStatement = connection.prepareStatement(checkTableSql);) {
            checkStatement.setString(1, owner);
            checkStatement.setString(2, tableName);

            // 결과 가져오기
            try (ResultSet resultSet = checkStatement.executeQuery()) {
                resultSet.next();
                int tableCount = resultSet.getInt(1);
                return tableCount > 0;
            }
        }
    }
    private static String getCreateTableSql(String dbType, String targetTableName, String owner, String tableName) {
        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            return "CREATE TABLE " + targetTableName + " AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            return "CREATE TABLE " + targetTableName + " AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            return "CREATE TABLE " + targetTableName + " (SELECT * FROM " + owner + "." + tableName + " WHERE 1=2)";
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            return "CREATE TABLE " + targetTableName + " AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2" +
                    (dbType.equalsIgnoreCase("TIBERO") ? " TEMPORARY" : "") +
                    (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO") ? " NOLOGGING" : "");
        } else {
            throw new IllegalArgumentException("Unsupported database type: " + dbType);
        }
    }

    public static String makeTmpTableName(String tableName, int orderid) {
        return "X_" + orderid + "_" + tableName;
    }

    public static String createCotdlPartTmpTable(Connection connSelect, String dbType, String owner, String tableName, int orderid, String hashCol, String hashColType, int partitionCnt) throws SQLException {
        String dropTableSql = null;
        String createTableSql = null;
        String alterNologging = null;

        String hashColumn = hashCol;
        if (hashColType.equalsIgnoreCase("DATE") || hashColType.equalsIgnoreCase("DATETIME") || hashColType.equalsIgnoreCase("TIMESTAMP") || hashColType.equalsIgnoreCase("TIMESTAMP(6)")) {
            hashColumn = "TO_NUMBER(TO_CHAR(" + hashCol + ", 'YYYYMMDD'))";
        }

        String targetTableName = makeTmpTableName(tableName, orderid);

        /** 테이블 존재 여부 확인하여 재수행이면 drop 처리*/
        if (checkTableExists(connSelect, dbType, "COTDL", targetTableName)) {
            // 테이블이 존재하므로 삭제 후 생성
            dropTable(connSelect, dbType, "COTDL", targetTableName);
        }

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " PARTITION BY HASH(" + hashColumn + ") PARTITIONS " + partitionCnt;
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " PARTITION BY HASH(" + hashColumn + ") PARTITIONS " + partitionCnt + " WITH (NOLOGGING)";  // NOLOGGING 옵션 추가
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " (SELECT * FROM " + owner + "." + tableName + " WHERE 1=2) WITH (NOLOGGING)";  // NOLOGGING 옵션 추가
        } else if (dbType.equalsIgnoreCase("ORACLE") ) {
            createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " PARTITION BY HASH(" + hashColumn + ") PARTITIONS " + partitionCnt + " NOLOGGING AS SELECT * FROM " + owner + "." + tableName + " where 1=2";  // NOLOGGING 옵션 추가
        } else if (dbType.equalsIgnoreCase("TIBERO")) {
            createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " PARTITION BY HASH(" + hashColumn + ") PARTITIONS " + partitionCnt + " AS SELECT * FROM " + owner + "." + tableName + " where 1=2";  // NOLOGGING 옵션 추가
            alterNologging = "ALTER TABLE " + "COTDL" + "." + targetTableName + " NOLOGGING" ;  // NOLOGGING 옵션 추가
        }

        LogUtil.log("WARN", "createCotdlPartTmpTable 1=> "+createTableSql);
        try (Statement statement = connSelect.createStatement()) {
            statement.executeUpdate(createTableSql);
            if (dbType.equalsIgnoreCase("TIBERO")) {
                statement.executeUpdate(alterNologging);
            }
            LogUtil.log("WARN", "createCotdlPartTmpTable 2=> "+"succeed");
        } /*catch (Exception e){LogUtil.log("INFO", "createCotdlPartTmpTable 2-2=> "+createTableSql);
            e.printStackTrace();
            throw e;
        }*/
        //LogUtil.log("WARN", "info$ "+"createCotdlPartTmpTable 3=> "+createTableSql);
        return "createCotdlPartTmpTable: " + dropTableSql + "  createTableSql:" + createTableSql;
    }


    public static String createCotdlTargetTmpTable(Connection connInsert, String dbType, String owner, String tableName, String hashCol, String hashColType, int partitionCnt) throws SQLException {
        String dropTableSql = null;
        String createTableSql = null;

        for (int i = 1; i <= partitionCnt; i++) {
            String targetTableName = tableName + i;

            if (checkTableExists(connInsert, dbType, "COTDL", targetTableName)) {
                // 테이블이 존재하므로 삭제 후 생성
                dropTable(connInsert, dbType, "COTDL", targetTableName);
            }

            if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
                createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2";  // NOLOGGING 옵션이 지원되지 않음
            } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
                createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " WITH (NOLOGGING) AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2";
            } else if (dbType.equalsIgnoreCase("MSSQL")) {
                createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " (SELECT * FROM " + owner + "." + tableName + " WHERE 1=2) WITH (NOLOGGING)";
            } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
                createTableSql = "CREATE TABLE " + "COTDL" + "." + targetTableName + " NOLOGGING AS SELECT * FROM " + owner + "." + tableName + " WHERE 1=2";
            }

            try (Statement statement = connInsert.createStatement()) {
                statement.executeUpdate(createTableSql);
            }

        }

        return "createCotdlTargetTmpTable:" + dropTableSql + " createTableSql:" + createTableSql;
    }

    public static void executeTruncateTable(Connection connection, String dbType, String owner, String tableName, String partitionName) throws SQLException {
        String truncateTableSql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            // MySQL 및 MariaDB는 파티션 TRUNCATE를 지원하지 않습니다.
            truncateTableSql = "TRUNCATE TABLE " + owner + "." + tableName + "";
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL은 파티션 TRUNCATE를 지원하지 않습니다.
            truncateTableSql = "TRUNCATE TABLE " + owner + "." + tableName + " RESTART IDENTITY CASCADE";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            // MSSQL은 파티션 TRUNCATE를 지원하지 않습니다.
            truncateTableSql = "TRUNCATE TABLE " + owner + "." + tableName + "";
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            // Oracle 및 Tibero는 파티션 TRUNCATE를 지원합니다.
            if (partitionName != null && !partitionName.trim().isEmpty()) {
                // partitionName이 있을 경우 파티션만 TRUNCATE
                truncateTableSql = "ALTER TABLE " + owner + "." + tableName + " TRUNCATE PARTITION " + partitionName + " DROP STORAGE";
            } else {
                // partitionName이 없을 경우 전체 테이블 TRUNCATE
                truncateTableSql = "TRUNCATE TABLE " + owner + "." + tableName + " DROP STORAGE";
            }
        }
        LogUtil.log("WARN", "info; executeTruncateTable=" + truncateTableSql);
        try(Statement statement = connection.createStatement()) {
            statement.executeUpdate(truncateTableSql);
        }
    }

    public static void executeCreateCopyTable(Connection connection, String dbType, String owner, String tableName) throws SQLException {

        dropTable(connection, dbType, owner, tableName + "_copy");

        String createTableSql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            createTableSql = "CREATE TABLE " + owner + "." + tableName + "_copy AS SELECT * FROM " + owner + "." + tableName;
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            createTableSql = "CREATE TABLE IF NOT EXISTS " + owner + "." + tableName + "_copy (SELECT * FROM " + owner + "." + tableName + ")";
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            createTableSql = "CREATE TABLE " + owner + "." + tableName + "_copy (SELECT * FROM " + owner + "." + tableName + " AS t)";
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            createTableSql = "CREATE /*+ PARALLEL (" + owner + "." + tableName + ", 4) NOLOGGING */ TABLE " + owner + "." + tableName + "_copy AS "
                    + "SELECT /*+ PARALLEL (" + owner + "." + tableName + ", 4) */ * from " + owner + "." + tableName;
        }

        try(Statement statement = connection.createStatement()) {
            statement.executeUpdate(createTableSql);
        }

    }

    /**
     * 파티션 테이블에 데이터 insert 하고 target 테이블은 truncate한다.
     */
    public static long insertPartTmpFromTargetAndTrunc(Connection connSelect, Connection connInsert, String dbType, String owner, String tableName, String dbTypeTarget, String ownerTarget, String tableNameTarget, int orderid, String whereStr, boolean truncFlag, int numScrambleThreads, String fromWhereStr, String hintSelectSTR, String truncPartitionName, String maxParallelCnt) throws SQLException {
        String insertSql = "";
        int parallelCnt = 1;
        if (numScrambleThreads < 5) {
            parallelCnt =  numScrambleThreads; // 5보다 작으면 그대로 반환
        } else {
            parallelCnt = Math.min(numScrambleThreads, 10); // 너무 세션이 SELECT INSERT 각각 많이 떠서 줄임
            //parallelCnt = Math.min(numScrambleThreads + 2, 16); // 5 이상이면 2를 더하고, 16을 초과하지 않도록 함
        }
         /** maxParallelCnt가 0이 아니면 parallelCnt의 최대값을 제한  20250326*/
        int maxParallelCntInt = StrUtil.parseInt(maxParallelCnt);
        if (maxParallelCntInt > 0) {
            parallelCnt = Math.min(parallelCnt, maxParallelCntInt);
        }
        // 기본 SELECT SQL 생성
        String fwStr = StrUtil.checkString(fromWhereStr)
                ? " * FROM " + owner + "." + tableName + " WHERE " + whereStr
                : " A.* FROM " + fromWhereStr;

        switch (dbType.toUpperCase()) {
            case "MARIADB":
            case "MYSQL":
            case "POSTGRESQL":
                insertSql = "INSERT INTO COTDL." + makeTmpTableName(tableName, orderid) + " SELECT " + fwStr;
                break;
            case "MSSQL":
                insertSql = "INSERT INTO COTDL." + makeTmpTableName(tableName, orderid) + " WITH (TABLOCK) SELECT " + fwStr;
                break;
            case "ORACLE":
            case "TIBERO":
                insertSql = "INSERT /*+ APPEND PARALLEL(" + parallelCnt + ") NOLOGGING */ INTO COTDL." + makeTmpTableName(tableName, orderid) + " SELECT /*+ PARALLEL(" + parallelCnt + ") "+hintSelectSTR+" */ " + fwStr;
                break;
            default:
                throw new SQLException("Unsupported database type: " + dbType);
        }
        LogUtil.log("WARN", "1 before : insertPartTmpFromTarget-> " + insertSql);
        long insRowCount = 0;
        String tmpTableFullName = "COTDL." + makeTmpTableName(tableName, orderid);

        // 재시도 시 TMP에 이미 데이터가 있는지 확인 (멱등성 보장)
        long existingTmpCount = 0;
        try (Statement cntStmt = connSelect.createStatement();
             ResultSet cntRs = cntStmt.executeQuery("SELECT COUNT(*) FROM " + tmpTableFullName)) {
            if (cntRs.next()) {
                existingTmpCount = cntRs.getLong(1);
            }
        } catch (SQLException e) {
            // TMP 테이블이 없거나 접근 불가 시 0으로 처리
            logger.warn("TMP count check failed (may not exist yet): {}", e.getMessage());
        }

        if (existingTmpCount > 0) {
            // 재시도 시 TMP에 이미 데이터가 있으면 INSERT skip
            logger.info("TMP table {} already has {} rows, skipping INSERT (retry scenario)", tmpTableFullName, existingTmpCount);
            insRowCount = existingTmpCount;
        } else {
            try (Statement statement = connSelect.createStatement()) {
                /** 20241008 long type return method */
                if (dbType.equalsIgnoreCase("ORACLE")) {
                    statement.execute("ALTER SESSION ENABLE PARALLEL DML");
                    insRowCount = statement.executeLargeUpdate(insertSql);
                } else {
                    insRowCount = statement.executeUpdate(insertSql);
                }
                JdbcUtil.commit(connSelect);
            }
        }
        LogUtil.log("WARN", "2 after : insertPartTmpFromTarget-> succeed =" + insRowCount);

        /** Target table truncate - TMP 건수 검증 후 수행 */
        if (truncFlag) {
            // TRUNCATE 전 TMP 건수 재검증
            long verifyCount = 0;
            try (Statement verifyStmt = connSelect.createStatement();
                 ResultSet verifyRs = verifyStmt.executeQuery("SELECT COUNT(*) FROM " + tmpTableFullName)) {
                if (verifyRs.next()) {
                    verifyCount = verifyRs.getLong(1);
                }
            }
            if (verifyCount <= 0) {
                throw new SQLException("TMP table " + tmpTableFullName + " has 0 rows. Refusing to TRUNCATE target to prevent data loss.");
            }
            if (verifyCount != insRowCount) {
                logger.warn("TMP row count mismatch: expected={}, actual={}. Proceeding with caution.", insRowCount, verifyCount);
            }
            executeTruncateTable(connInsert, dbTypeTarget, ownerTarget, tableNameTarget, truncPartitionName);
            LogUtil.log("WARN", "info$ "+" after 3:  executeTruncateTable--> success (verified TMP rows=" + verifyCount + ")" );
        }

        return insRowCount;
    }

    /**
     * deleteDupData
     */
    public static long deleteDupData(Connection connInsert, String dbType, String owner,
                                     String tableName, String whereStr, int parallelCnt, boolean isTestDataAutoGen)
            throws SQLException {
        // 기본 DELETE SQL 생성
        String deleteSql = "DELETE FROM " + owner + "." + tableName + " WHERE " + whereStr;

        // 데이터베이스 타입에 따른 SQL 최적화
        switch (dbType.toUpperCase()) {
            case "MARIADB":
            case "MYSQL":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE A FROM " + owner + "." + tableName + " A "
                        + "INNER JOIN COTDL.TBL_PIIKEYMAP B ON 1=1 "
                        + "WHERE " + whereStr;
                } else {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " WHERE " + whereStr;
                }
                break;

            case "POSTGRESQL":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " A "
                        + "USING COTDL.TBL_PIIKEYMAP B "
                        + "WHERE " + whereStr;
                } else {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " WHERE " + whereStr;
                }
                break;

            case "MSSQL":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE A FROM " + owner + "." + tableName + " A WITH (TABLOCK) "
                        + "WHERE EXISTS ("
                        + "  SELECT 1 FROM COTDL.TBL_PIIKEYMAP B "
                        + "  WHERE " + whereStr
                        + ")";
                } else {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " WITH (TABLOCK) WHERE " + whereStr;
                }
                break;

            case "ORACLE":
            case "TIBERO":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE /*+ ENABLE_PARALLEL_DML PARALLEL(" + parallelCnt + ") NOLOGGING */ "
                        + "FROM " + owner + "." + tableName + " A "
                        + "WHERE EXISTS ("
                        + "  SELECT 1 FROM COTDL.TBL_PIIKEYMAP B "
                        + "  WHERE " + whereStr
                        + ")";
                } else {
                    deleteSql = "DELETE /*+ ENABLE_PARALLEL_DML PARALLEL(" + parallelCnt + ") NOLOGGING */ "
                            + "FROM " + owner + "." + tableName + " WHERE " + whereStr;
                }
                break;

            case "DB2":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " A "
                        + "WHERE EXISTS ("
                        + "  SELECT 1 FROM COTDL.TBL_PIIKEYMAP B "
                        + "  WHERE " + whereStr
                        + ") OPTIMIZE FOR " + (parallelCnt * 1000) + " ROWS";
                } else {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " WHERE " + whereStr
                            + " OPTIMIZE FOR " + (parallelCnt * 1000) + " ROWS";
                }
                break;

            case "SQLITE":
                if (isTestDataAutoGen) {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " "
                        + "WHERE EXISTS ("
                        + "  SELECT 1 FROM COTDL.TBL_PIIKEYMAP B "
                        + "  WHERE " + whereStr.replace("A.COFID", owner + "." + tableName + ".COFID")
                        + ")";
                } else {
                    deleteSql = "DELETE FROM " + owner + "." + tableName + " WHERE " + whereStr;
                }
                break;

            default:
                throw new SQLException("Unsupported database type: " + dbType);
        }


        // Oracle 전용 세션 설정
        if (dbType.equalsIgnoreCase("ORACLE")) {
            try (Statement alterStmt = connInsert.createStatement()) {
                alterStmt.execute("ALTER SESSION ENABLE PARALLEL DML"); // [1][4][8]
            }
        }
        LogUtil.log("INFO","deleteSql:"+deleteSql);

        // 멱등성 보장: DELETE 전 대상 건수 확인 (재시도 시 이미 삭제된 경우 skip)
        long targetCount = 0;
        String countSql = "SELECT COUNT(*) FROM " + owner + "." + tableName + " WHERE " + whereStr;
        try (Statement cntStmt = connInsert.createStatement();
             ResultSet cntRs = cntStmt.executeQuery(countSql)) {
            if (cntRs.next()) {
                targetCount = cntRs.getLong(1);
            }
        } catch (SQLException e) {
            logger.warn("deleteDupData count check failed (proceeding with delete): {}", e.getMessage());
            targetCount = -1; // 건수 확인 실패 시 삭제 진행
        }

        if (targetCount == 0) {
            logger.info("deleteDupData: no rows to delete (already cleaned or retry). table={}.{}", owner, tableName);
            return 0;
        }

        // SQL 실행
        long insRowCount = 0;
        try (Statement stmt = connInsert.createStatement()) {
            insRowCount = stmt.executeUpdate(deleteSql);
            JdbcUtil.commit(connInsert);
        } catch (SQLException e) {
            JdbcUtil.rollback(connInsert);
            throw new SQLException("DELETE 실패: " + e.getMessage(), e);
        }
        logger.info("deleteDupData completed: table={}.{}, deleted={}, preCount={}", owner, tableName, insRowCount, targetCount);
        return insRowCount;
    }

    /**
     * Target에 insert from COTDL tmps & DROP tmps  타켓에 분산 처리 시에만 사용된다.....실제 성능이 안나와서  사용안함.
     */
    public static long insertTargetFromTmpsAndDrop(Connection connection, String dbType, PiiOrderStepTableVO piiordersteptable, String owner, String tableName, int partitionIdx) throws SQLException {
        String tmpTableName = makeTmpTableName(tableName, partitionIdx);
        String insertSql = "";

        if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL")) {
            // MySQL 및 MariaDB에서는 INSERT SQL을 생성
            insertSql = "INSERT INTO " + owner + "." + tableName + " SELECT * FROM " + "COTDL" + "." + tmpTableName;
        } else if (dbType.equalsIgnoreCase("POSTGRESQL")) {
            // PostgreSQL에서는 INSERT SQL을 생성
            insertSql = "INSERT INTO " + owner + "." + tableName + " SELECT * FROM " + "COTDL" + "." + tmpTableName;
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            // MSSQL에서는 INSERT SQL을 생성
            insertSql = "INSERT INTO " + owner + "." + tableName + " SELECT * FROM " + "COTDL" + "." + tmpTableName;
        } else if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            // Oracle 및 Tibero에서는 INSERT SQL을 생성
            insertSql = "INSERT /*+ APPEND NOLOGGING */ INTO " + owner + "." + tableName + " SELECT * FROM " + "COTDL" + "." + tmpTableName;
        }

        long insRowCount = 0;
        try(Statement statement = connection.createStatement()) {
            /** 20241008 long type return method */
            if (dbType.equalsIgnoreCase("ORACLE")){
                insRowCount = statement.executeLargeUpdate(insertSql);
            } else {
                insRowCount = statement.executeUpdate(insertSql);
            }
            JdbcUtil.commit(connection);
        }
        LogUtil.log("WARN", "info$ "+"insertTargetFromTmpsAndDrop-> " + insRowCount + "==" + insertSql);
        /** Drop COTDL Tmp tables */
        dropTable(connection, dbType, "COTDL", tmpTableName);

        LogUtil.log("WARN", "info$ "+"#### insertTargetFromTmpsAndDrop completed ##" + tmpTableName + "   insRowCount: " + insRowCount);

        return insRowCount;
    }
    public static void dropTable(Connection connection, String dbType, String owner, String tableName) throws SQLException {
        // 테이블 존재 여부 확인
        if (!checkTableExists(connection, dbType, owner, tableName)) {
            // 테이블이 존재하지 않으므로 에러 처리 또는 적절한 로그 기록
            return; // 메서드 종료
        }

        String dropTableSql = null;

        if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            dropTableSql = "DROP TABLE " + owner + "." + tableName + " PURGE";
        } else if (dbType.equalsIgnoreCase("MARIADB") || dbType.equalsIgnoreCase("MYSQL") || dbType.equalsIgnoreCase("POSTGRESQL")) {
            dropTableSql = "DROP TABLE " + owner + "." + tableName;
        } else if (dbType.equalsIgnoreCase("MSSQL")) {
            dropTableSql = "DROP TABLE " + owner + "." + tableName;
        } else {
            throw new SQLException("Unsupported database type: " + dbType);
        }

        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate(dropTableSql);
        }
    }


    public static FileWriter generateCtlFile(String owner, String table_name, int tabIndex, String data_handling_method, String dbType, List<PiiTableVO> piitablecols_target, String sqlldr_path) throws IOException {
        String ctlFilename = null;
        String dataFilename = null;
        String logFilename = null;
        if (dbType.equalsIgnoreCase("ORACLE") || dbType.equalsIgnoreCase("TIBERO")) {
            if (dbType.equalsIgnoreCase("ORACLE")) {
                ctlFilename = sqlldr_path + "/" + owner + "_" + table_name + "_" + tabIndex + ".ctl";
            } else {
                ctlFilename = sqlldr_path + "/" + owner + "_" + table_name + "_" + tabIndex + ".tbf";
            }
            dataFilename = sqlldr_path + "/" + owner + "_" + table_name + "_" + tabIndex + ".dat";
            logFilename = sqlldr_path + "/" + owner + "_" + table_name + "_" + tabIndex + ".log";

            File file = new File(ctlFilename);
            if (file.exists()) {
                file.delete();
            }
            file = new File(dataFilename);
            if (file.exists()) {
                file.delete();
            }
            file = new File(logFilename);
            if (file.exists()) {
                file.delete();
            }

            try (BufferedWriter writer = new BufferedWriter(new FileWriter(ctlFilename))) {
                // CTL 파일 내용 작성
                writer.write("LOAD DATA");
                writer.newLine();
                writer.write("INFILE '" + dataFilename + "'");
                writer.newLine();
                if ("TRUNCSERT".equals(data_handling_method)) {
                    if (tabIndex == 0) {
                        writer.write("TRUNCATE");
                        writer.newLine();
                    } else {
                        writer.write("APPEND");
                        writer.newLine();
                    }
                } else {
                    writer.write("REPLACE");
                    writer.newLine();
                }
                writer.write("INTO TABLE " + owner + "." + table_name);
                writer.newLine();
                writer.write("FIELDS TERMINATED BY ','");
                writer.newLine();
                writer.write("TRAILING NULLCOLS");
                writer.newLine();
                writer.write("(");
                writer.newLine();

                // 각 컬럼에 대한 매핑 추가
                for (int i = 0; i < piitablecols_target.size(); i++) {
                    PiiTableVO piitable = piitablecols_target.get(i);
                    String hashColType = piitable.getData_type();
                    String columnName = piitable.getColumn_name() + " ";
                    String columnLength = piitable.getData_length();
                    if (hashColType.equalsIgnoreCase("DATE")) {
                        columnName = columnName + "DATE 'YYYY-MM-DD HH24:MI:SS'";
                    } else if (hashColType.equalsIgnoreCase("TIMESTAMP ")) {
                        columnName = columnName + "TIMESTAMP 'YYYY-MM-DD HH24:MI:SS.FF'";
                    } else if (hashColType.equalsIgnoreCase("CLOB")) {
                        columnName = columnName + "CHAR(" + columnLength + ")";
                    } else if (hashColType.equalsIgnoreCase("BLOB")) {
                        columnName = columnName + "CHAR(" + columnLength + ")";
                    } else {
                        /** 대부분의 경우 SQLLoader에서 DATE 및 TIMESTAMP 데이터 유형을 제외하고
                         * 다른 데이터 유형을 명시적으로 정의하지 않아도 문제가 발생하지 않으며
                         * 성능에 큰 영향을 주지 않습니다. Oracle SQLLoader는 데이터 파일을 데이터베이스 테이블에 로드하는 데
                         * 다양한 데이터 유형을 자동으로 처리할 수 있습니다.
                         * */
                        //columnName = columnName + hashColType + "(" + columnLength + ")";
                    }
                    if (i == piitablecols_target.size() - 1) {
                        writer.write(columnName);
                    } else {
                        writer.write(columnName + ",");
                    }
                    writer.newLine();
                }

                writer.write(")");

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return new FileWriter(dataFilename);
    }

    public static String generateSelectCols(String owner, String tableName, String ctlFilename, String dataFilename, List<PiiTableVO> piitablecols_target) throws IOException {
        StringBuilder selectQuery = new StringBuilder("SELECT ");
        for (int i = 0; i < piitablecols_target.size(); i++) {
            PiiTableVO piitable = piitablecols_target.get(i);
            String hashColType = piitable.getData_type();
            String columnName = piitable.getColumn_name();

            // 추가적인 컬럼 매핑 처리
            if (hashColType.equalsIgnoreCase("DATE")) {
                selectQuery.append("TO_CHAR(").append(columnName).append(", 'YYYY-MM-DD HH24:MI:SS') AS ").append(columnName);
            } else if (hashColType.equalsIgnoreCase("TIMESTAMP")) {
                selectQuery.append("TO_CHAR(").append(columnName).append(", 'YYYY-MM-DD HH24:MI:SS.FF') AS ").append(columnName);
            } else if (hashColType.equalsIgnoreCase("CLOB") || hashColType.equalsIgnoreCase("BLOB")) {
                // CLOB 및 BLOB은 CHAR로 캐스팅할 것인지에 따라 처리
                selectQuery.append("TO_CHAR(").append(columnName).append(") AS ").append(columnName);
            } else {
                // 다른 데이터 유형에 대한 처리
                selectQuery.append(columnName);
            }

            // 컬럼 간 구분자 추가
            if (i < piitablecols_target.size() - 1) {
                selectQuery.append(", ");
            }
        }
        return selectQuery.toString();
    }

    public static List<String> getPartitionNames(Connection connection, String dbType, String tableowner, String tableName) throws SQLException {
        List<String> partitionNames = new ArrayList<>();
        String table_owner = "COTDL";
        try (Statement stmt = connection.createStatement()) {
            ResultSet rs = null;

            switch (dbType.toLowerCase()) {
                case "oracle":
                    rs = stmt.executeQuery("SELECT partition_name FROM all_tab_partitions WHERE table_owner = UPPER('" + table_owner + "')" +
                            " AND table_name = UPPER('" + tableName + "') ORDER BY partition_name");
                    break;
                case "tibero":
                    rs = stmt.executeQuery("SELECT partition_name FROM all_tab_partitions WHERE owner = '" + table_owner + "' AND table_name = '" + tableName + "' ORDER BY partition_name");
                    break;
                case "postgresql": /** 에러남.......나중에 필요시 업데이트 필요 20240120*/
                    rs = stmt.executeQuery("SELECT table_name, partition_name, subpartition_name FROM pg_partitions " +
                            "WHERE schemaname = '" + table_owner + "' AND tablename = '" + tableName + "' ORDER BY partition_name");
                    break;
                case "mysql":
                    rs = stmt.executeQuery("SELECT partition_name FROM information_schema.partitions WHERE table_name = '" + tableName + "' ORDER BY partition_name");
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported DB type: " + dbType);
            }


            while (rs.next()) {
                partitionNames.add(rs.getString("partition_name"));
            }
        }

        return partitionNames;
    }

    // keyname과 val1을 기준으로 newval1을 찾는 메서드
    public static String findNewVal(Map<String, Map<String, String>> dataMap, String keyname, String val1) {
        Map<String, String> innerMap = dataMap.get(keyname);

        if (innerMap != null) {
            return innerMap.get(val1);
        } else {
            return val1;
        }
    }

    // 데이터를 Map에 추가하는 메서드
    public static void addData(Map<String, Map<String, String>> dataMap, String keyName, String val1, String newval1) {
        Map<String, String> innerMap = dataMap.computeIfAbsent(keyName, k -> new HashMap<>());
        innerMap.put("VAL1", val1);
        innerMap.put("NEWVAL1", newval1);
    }
    /** 20250111
     * sql에서 mappingColumn 바로 앞의 칼럼명을 리턴한다.
     * 예)ACTID, ACTID , #CUSTIDSFIEXED   에서 getColumnNameBeforeMapping(sql, "#CUSTIDSFIEXED") 하면 ACTID를 가져온다.
     * */
    public static String getColumnNameBeforeMapping(String sql, String mappingColumn) {
        // SELECT와 FROM 부분을 분리
        String[] parts = sql.split("FROM");
        if (parts.length < 1) {
            return null; // 유효하지 않은 SQL일 경우 null 반환
        }

        // SELECT 부분에서 #CUSTIDSFIEXED 앞의 칼럼명 찾기
        String selectPart = parts[0];

        // #CUSTIDSFIEXED를 기준으로 분리
        String[] selectColumns = selectPart.split(",");

        for (int i = 0; i < selectColumns.length; i++) {
            String column = selectColumns[i].trim();
            if (column.equalsIgnoreCase(mappingColumn.trim())) {
                if (i > 0) {
                    // #CUSTIDSFIEXED 앞의 칼럼명을 반환
                    return selectColumns[i - 1].trim();
                }
            }
        }

        return null; // 해당 칼럼명이 없을 경우 null 반환
    }

    public static Map<String, Map<String, String>> getDatabaseColumnDefaults() {
        Map<String, Map<String, String>> databaseDefaults = new HashMap<>();

        // ORACLE, TIBERO
        Map<String, String> oracleDefaults = new HashMap<>();
        oracleDefaults.put("VARCHAR2", "' '");
        oracleDefaults.put("NVARCHAR2", "' '");
        oracleDefaults.put("CHAR", "' '");
        oracleDefaults.put("NCHAR", "' '");
        oracleDefaults.put("CLOB", "EMPTY_CLOB()");
        oracleDefaults.put("NCLOB", "EMPTY_NCLOB()");
        oracleDefaults.put("BLOB", "EMPTY_BLOB()");
        oracleDefaults.put("DATE", "SYSDATE");
        oracleDefaults.put("TIMESTAMP", "SYSTIMESTAMP");
        oracleDefaults.put("NUMBER", "0");
        oracleDefaults.put("INTEGER", "0");
        oracleDefaults.put("FLOAT", "0.0");
        oracleDefaults.put("BINARY_FLOAT", "0.0");
        oracleDefaults.put("BINARY_DOUBLE", "0.0");
        oracleDefaults.put("RAW", "NULL");
        oracleDefaults.put("LONG RAW", "NULL");
        oracleDefaults.put("ROWID", "NULL");
        oracleDefaults.put("UROWID", "NULL");
        oracleDefaults.put("XMLTYPE", "NULL");
        oracleDefaults.put("JSON", "NULL");
        databaseDefaults.put("ORACLE", oracleDefaults);
        databaseDefaults.put("TIBERO", oracleDefaults);

        // MYSQL, MARIADB
        Map<String, String> mysqlDefaults = new HashMap<>();
        mysqlDefaults.put("VARCHAR", "' '");
        mysqlDefaults.put("CHAR", "' '");
        mysqlDefaults.put("TEXT", "' '");
        mysqlDefaults.put("TINYTEXT", "' '");
        mysqlDefaults.put("MEDIUMTEXT", "' '");
        mysqlDefaults.put("LONGTEXT", "' '");
        mysqlDefaults.put("BLOB", "NULL");
        mysqlDefaults.put("TINYBLOB", "NULL");
        mysqlDefaults.put("MEDIUMBLOB", "NULL");
        mysqlDefaults.put("LONGBLOB", "NULL");
        mysqlDefaults.put("DATE", "CURDATE()");
        mysqlDefaults.put("DATETIME", "NOW()");
        mysqlDefaults.put("TIMESTAMP", "NOW()");
        mysqlDefaults.put("TIME", "'00:00:00'");
        mysqlDefaults.put("YEAR", "'0000'");
        mysqlDefaults.put("INT", "0");
        mysqlDefaults.put("INTEGER", "0");
        mysqlDefaults.put("TINYINT", "0");
        mysqlDefaults.put("SMALLINT", "0");
        mysqlDefaults.put("MEDIUMINT", "0");
        mysqlDefaults.put("BIGINT", "0");
        mysqlDefaults.put("DECIMAL", "0.0");
        mysqlDefaults.put("NUMERIC", "0.0");
        mysqlDefaults.put("FLOAT", "0.0");
        mysqlDefaults.put("DOUBLE", "0.0");
        mysqlDefaults.put("BIT", "0");
        mysqlDefaults.put("BOOLEAN", "0");
        mysqlDefaults.put("JSON", "NULL");
        databaseDefaults.put("MYSQL", mysqlDefaults);
        databaseDefaults.put("MARIADB", mysqlDefaults);

        // MSSQL
        Map<String, String> mssqlDefaults = new HashMap<>();
        mssqlDefaults.put("VARCHAR", "' '");
        mssqlDefaults.put("NVARCHAR", "' '");
        mssqlDefaults.put("CHAR", "' '");
        mssqlDefaults.put("NCHAR", "' '");
        mssqlDefaults.put("TEXT", "' '");
        mssqlDefaults.put("NTEXT", "' '");
        mssqlDefaults.put("BINARY", "NULL");
        mssqlDefaults.put("VARBINARY", "NULL");
        mssqlDefaults.put("IMAGE", "NULL");
        mssqlDefaults.put("DATE", "GETDATE()");
        mssqlDefaults.put("DATETIME", "GETDATE()");
        mssqlDefaults.put("DATETIME2", "GETDATE()");
        mssqlDefaults.put("DATETIMEOFFSET", "GETDATE()");
        mssqlDefaults.put("SMALLDATETIME", "GETDATE()");
        mssqlDefaults.put("TIME", "'00:00:00'");
        mssqlDefaults.put("INT", "0");
        mssqlDefaults.put("BIGINT", "0");
        mssqlDefaults.put("SMALLINT", "0");
        mssqlDefaults.put("TINYINT", "0");
        mssqlDefaults.put("DECIMAL", "0.0");
        mssqlDefaults.put("NUMERIC", "0.0");
        mssqlDefaults.put("FLOAT", "0.0");
        mssqlDefaults.put("REAL", "0.0");
        mssqlDefaults.put("BIT", "0");
        mssqlDefaults.put("UNIQUEIDENTIFIER", "NULL");
        mssqlDefaults.put("SQL_VARIANT", "NULL");
        mssqlDefaults.put("XML", "NULL");
        mssqlDefaults.put("JSON", "NULL");
        databaseDefaults.put("MSSQL", mssqlDefaults);

        // POSTGRESQL
        Map<String, String> postgresqlDefaults = new HashMap<>();
        postgresqlDefaults.put("VARCHAR", "' '");
        postgresqlDefaults.put("CHAR", "' '");
        postgresqlDefaults.put("TEXT", "' '");
        postgresqlDefaults.put("BYTEA", "NULL");
        postgresqlDefaults.put("DATE", "CURRENT_DATE");
        postgresqlDefaults.put("TIMESTAMP", "CURRENT_TIMESTAMP");
        postgresqlDefaults.put("TIME", "'00:00:00'");
        postgresqlDefaults.put("INTERVAL", "'00:00:00'");
        postgresqlDefaults.put("INT", "0");
        postgresqlDefaults.put("INTEGER", "0");
        postgresqlDefaults.put("SMALLINT", "0");
        postgresqlDefaults.put("BIGINT", "0");
        postgresqlDefaults.put("DECIMAL", "0.0");
        postgresqlDefaults.put("NUMERIC", "0.0");
        postgresqlDefaults.put("REAL", "0.0");
        postgresqlDefaults.put("DOUBLE PRECISION", "0.0");
        postgresqlDefaults.put("BIT", "B'0'");
        postgresqlDefaults.put("BOOLEAN", "FALSE");
        postgresqlDefaults.put("JSON", "'{}'");
        postgresqlDefaults.put("JSONB", "'{}'");
        databaseDefaults.put("POSTGRESQL", postgresqlDefaults);

        return databaseDefaults;
    }

    public static String getDefaultValue(String databaseType, String columnType) {
        Map<String, Map<String, String>> databaseDefaults = getDatabaseColumnDefaults();
        Map<String, String> defaults = databaseDefaults.get(databaseType.toUpperCase());

        if (defaults != null) {
            return defaults.getOrDefault(columnType.toUpperCase(), "NULL");
        } else {
            return "NULL";
        }
    }

    public static String bind(String sql, Object... params) {
        if (sql == null) throw new IllegalArgumentException("sql is null");
        int need = (int) sql.chars().filter(ch -> ch == '?').count();
        if (need != params.length) {
            throw new IllegalArgumentException("placeholder count (" + need + ") != params length (" + params.length + ")");
        }
        String bound = sql;
        for (Object p : params) {
            String lit = toSqlLiteral(p);
            // replaceFirst는 정규식 치환이라 replacement에 quote 필요
            bound = bound.replaceFirst("\\?", Matcher.quoteReplacement(lit));
        }
        return bound;
    }

    private static String toSqlLiteral(Object v) {
        if (v == null) return "NULL";
        if (v instanceof Number || v instanceof Boolean) return v.toString();
        // 문자열류: 단일 따옴표를 SQL 표준 방식으로 이스케이프
        String s = v.toString().replace("'", "''");
        return "'" + s + "'";
    }

    public static String genTestdataDeleteQuery(String owner, String table, String rawWhereClause) {
        // 1) 필수 파라미터 방어
        if (owner == null || owner.trim().isEmpty()) {
            throw new IllegalArgumentException("Owner는 null이거나 비어있을 수 없습니다.");
        }
        if (table == null || table.trim().isEmpty()) {
            throw new IllegalArgumentException("TableName은 null이거나 비어있을 수 없습니다.");
        }
        if (rawWhereClause == null || rawWhereClause.trim().isEmpty()) {
            throw new IllegalArgumentException("WHERE 절이 비어 있습니다.");
        }
        // 1. 내부 함수를 호출하여 WHERE 절을 먼저 변환합니다.
        String transformedWhereClause = generalizeSqlWhere(rawWhereClause);
        if (transformedWhereClause == null || transformedWhereClause.trim().isEmpty()) {
            // 안전을 위해 명시적 실패 (원치 않으면 여기서 "1=1" 같은 기본값을 넣을 수도 있으나 매우 위험)
            throw new IllegalStateException("변환 결과 WHERE 절이 비어 쿼리를 생성할 수 없습니다.");
        }
        // 2. 변환된 WHERE 절을 DELETE 템플릿에 삽입합니다.
        String deleteTemplate = "DELETE FROM %s.%s A\n" +
                "WHERE EXISTS (SELECT /*+ INDEX(B TBL_PIIMASTERKEYMAP_IDX01) */ 1\n" +
                "              FROM COTDL.TBL_PIIMASTERKEYMAP B\n" +
                "              WHERE %s)";

        return String.format(deleteTemplate, owner, table, transformedWhereClause);
    }

    /**
     * WHERE 절을 변환하는 내부 로직 (private 헬퍼 함수)
     */
    private static String generalizeSqlWhere(String sqlWhereClause) {
        // AND를 기준으로 조건을 분리합니다.
        String[] conditions = sqlWhereClause.trim().split("(?i)\\s+AND\\s+");
        List<String> newConditions = new ArrayList<>();

        // 정규식 패턴을 미리 컴파일합니다.
        Pattern keyNameHasKeyPrefix = Pattern.compile("(?i)\\bB\\.KEY_NAME\\s*=\\s*'KEY_([^']*)'");
        Pattern hasBaseDate = Pattern.compile("(?i)\\bB\\.BASEDATE\\b");
        // ⭐ B.VAL2, B.VAL3, B.VAL10 등 'B.VAL1'을 제외한 나머지 VAL 컬럼을 찾는 패턴 (수정됨)
        Pattern bValToRemove = Pattern.compile("(?i)\\bB\\.VAL([2-9]|[1-9][0-9]+)\\b");

        for (String rawCond : conditions) {
            String c = rawCond.trim();
            if (c.isEmpty()) continue;

            // 1) BASEDATE 포함 조건은 통째로 제거
            if (hasBaseDate.matcher(c).find()) {
                continue;
            }

            // 2) B.VAL2 이상의 컬럼이 포함된 조건은 통째로 제거 (수정된 규칙)
            if (bValToRemove.matcher(c).find()) {
                continue;
            }

            // 3) KEY_NAME = 'KEY_xxx' -> 'xxx' 로 정규화
            c = keyNameHasKeyPrefix.matcher(c).replaceAll("B.KEY_NAME = '$1'");

            // 4) 컬럼명 치환 (단어 경계를 사용하여 안전하게)
            c = c.replaceAll("(?i)\\bB\\.KEYMAP_ID\\b", "B.ORDERID");
            c = c.replaceAll("(?i)\\bB\\.VAL\\b", "B.NEWVAL"); // B.VAL은 B.NEWVAL로 변경

            // 5) 처리된 조건을 리스트에 추가
            if (!c.isEmpty()) {
                newConditions.add(c);
            }
        }

        // 남은 조건들을 ' AND '로 다시 조합하여 반환
        return String.join(" AND ", newConditions);
    }
}


