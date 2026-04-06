package datablocks.dlm;

import java.util.Calendar;
import java.util.TimeZone;

public class CalendarTest {



    public static void main(String[] args) {
        // 주어진 문자열
        Calendar calendar1 = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"));
        int hour1 = calendar1.get(Calendar.HOUR_OF_DAY);
        System.out.println(hour1 + "");
        System.out.println( "rrrrrrrrrrrrrr");

    }
}
