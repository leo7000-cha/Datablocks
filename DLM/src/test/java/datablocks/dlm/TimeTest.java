package datablocks.dlm;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class TimeTest {
    public static void main(String[] args) {
        Date today = new Date();
        SimpleDateFormat yyyymmdd = new SimpleDateFormat("yyyy/MM/dd");
        SimpleDateFormat yyyymmddhms = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        String basedate = yyyymmdd.format(today);
        String curtime = yyyymmddhms.format(today);

        System.out.println(basedate);
        System.out.println(curtime);


    }
}
