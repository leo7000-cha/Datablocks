package datablocks.dlm.util;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;

import java.io.*;
import java.net.URL;

public class HtmlToPdfUtil {

    public static void convertUrlToPdf(String urlString, OutputStream outputStream) throws Exception {
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.useFastMode();
        // ✅ PDF로 만들 HTML 주소
        builder.withUri(urlString);

        // ✅ 폰트 설정 추가 (이 부분을 반드시 넣어야 한글 깨짐 방지됨)
        InputStream fontStream = HtmlToPdfUtil.class.getClassLoader()
                .getResourceAsStream("fonts/NanumGothic.ttf");

        builder.useFont(() -> fontStream, "NanumGothic");

        // ✅ PDF로 출력
        builder.toStream(outputStream);
        builder.run();
    }
}
