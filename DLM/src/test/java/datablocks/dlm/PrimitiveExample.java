package datablocks.dlm;

public class PrimitiveExample {
    public static void main(String[] args) {
        int num = 10;
        System.out.println("Before function call: " + num);
        modifyValue(num);
        System.out.println("After function call: " + num);
    }

    public static void modifyValue(int value) {
        value = 20;
        System.out.println("Inside function: " + value);
    }
}
