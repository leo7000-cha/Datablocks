package datablocks.dlm;
import java.util.Scanner;
import java.util.Random;

public class JiHyeok {
    public static void main(String[] args) {
        // 랜덤 숫자 생성기
        Random random = new Random();
        int randomNumber = random.nextInt(100) + 1; // 1부터 100까지의 숫자

        // 사용자 입력 받기
        Scanner scanner = new Scanner(System.in);
        int userGuess = 0;
        int attempts = 0;

        System.out.println("숫자 맞추기 게임 시작!");
        System.out.println("1부터 100 사이의 숫자를 맞춰보세요.");

        // 게임 진행
        while (userGuess != randomNumber) {
            System.out.print("숫자를 입력하세요: ");
            userGuess = scanner.nextInt();
            attempts++; // 시도 횟수 증가

            if (userGuess < randomNumber) {
                System.out.println("더 큰 숫자입니다.");
            } else if (userGuess > randomNumber) {
                System.out.println("더 작은 숫자입니다.");
            } else {
                System.out.println("축하합니다! 정답은 " + randomNumber + "였습니다.");
                System.out.println("게임을 " + attempts + "번 만에 맞추셨습니다.");
            }
        }

        scanner.close();
    }
}

