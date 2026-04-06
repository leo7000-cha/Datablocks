package datablocks.dlm;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ExtractCommentedSql {

    public static void main(String[] args) {
        String sqlString = "insert into cotdl.TBL_PIIMASTERKEYMAP\n" +
                "SELECT \n" +
                "103178,\n" +
                "DB,\n" +
                "SUBSTR(KEY_NAME, 5),\n" +
                "BASEDATE,\n" +
                "VAL1,\n" +
                "#CURVAL+rownum\n" +
                "from \n" +
                "cotdl.TBL_PIIKEYMAP\n" +
                "WHERE KEY_NAME = 'KEY_ACTID' and KEYMAP_ID = '103178' /*\n" +
                "UPDATE COOWNSER.TCMSRNINFOQ\n" +
                "    SET RPRS_SRNO = RPRS_SRNO + (SELECT COUNT(1)\n" +
                "\t\t           FROM cotdl.TBL_PIIKEYMAP\n" +
                "\t\t          WHERE  KEY_NAME = 'KEY_ACTID' and KEYMAP_ID = '103178' \n" +
                "\t\t          )\n" +
                "    WHERE SRNO_SVCD = 'CM05001'\n" +
                ";\n" +
                "SELECT RPRS_SRNO FROM COOWNSER.TCMSRNINFOQ WHERE SRNO_SVCD = 'CM05001'\n" +
                ";\n" +
                "SELECT COUNT(1) FROM cotdl.TBL_PIIKEYMAP WHERE  KEY_NAME = 'KEY_ACTID' and KEYMAP_ID = '103178' \n" +
                "*/";

        // Regular expression to match comment block
        String regex = "/\\*\\s*(.*?)\\s*\\*/";
        Pattern pattern = Pattern.compile(regex, Pattern.DOTALL); // Allow . to match newline characters

        Matcher matcher = pattern.matcher(sqlString);

        if (matcher.find()) {
            String commentedSql = matcher.group(1);
            System.out.println("Extracted commented SQL:");
            System.out.println(commentedSql);
            //System.out.println("sqlString: " + sqlString);
            String[] sqlStatements = commentedSql.split(";");
            int currentValue = 0;
            int updatedValue = 0;
            int increasedValue = 0;
            // Process each extracted SQL statement
            for (int i = 0; i < sqlStatements.length; i++) {
                String trimmedStatement = sqlStatements[i].trim(); // Remove leading/trailing whitespace
                if (!trimmedStatement.isEmpty() && i == 0) {
                    System.out.println("SQL Statement " + (i + 1) + ":");
                    System.out.println(trimmedStatement);
                } else if (!trimmedStatement.isEmpty() && i == 1) {
                    System.out.println("SQL Statement " + (i + 1) + ":");
                    System.out.println(trimmedStatement);
                } else if (!trimmedStatement.isEmpty() && i == 2) {
                    System.out.println("SQL Statement " + (i + 1) + ":");
                    System.out.println(trimmedStatement);
                }
            }
        } else {
            System.out.println("No commented SQL found.");
        }
    }
}
