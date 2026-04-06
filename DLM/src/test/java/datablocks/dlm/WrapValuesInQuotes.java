package datablocks.dlm;

public class WrapValuesInQuotes {
    public static void main(String[] args) {
        // 주어진 문자열
        String inputString = "1111,22222,333,4444,666";

        // 쉼표로 문자열을 분리하여 배열로 만듭니다.
        String[] valuesArray = inputString.split(",");

        // 각 값을 작은 따옴표로 감싸고 다시 문자열로 조합합니다.
        StringBuilder resultStringBuilder = new StringBuilder();
        for (String value : valuesArray) {
            resultStringBuilder.append("'").append(value.trim()).append("', ");
        }

        // 마지막 쉼표 제거
        String resultString = resultStringBuilder.toString().replaceAll(", $", "");

        System.out.println(resultString);


    }
}

