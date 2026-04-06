package datablocks.dlm;
import java.util.Hashtable;
/*
스크램블 규칙 생성 시 범위를 입력하면 해당 범위의 값을 유니크 하게 채번한다.

 */
public class GenUniqueRandom {
    public static void main(String[] args) {

        int min = 530;
        int max = 557;

        Hashtable<Integer, Integer> ruleHan1  = new Hashtable<Integer, Integer>();
        System.out.println("");
        int key = min;
        while(ruleHan1.size() < max-min+1) {
            //int random_number = min + (int)(Math.random() * ((max - 1) + 1));
            int random_number = (int) (Math.random() * (max - min + 1) + min);
            if(key == random_number) continue;

            if(!ruleHan1.contains(random_number)) {
                ruleHan1.put(key, random_number);
                //System.out.println(key+":"+random_number);
                System.out.println(random_number);
                key++;
            }
        }

    }
}
