package datablocks.dlm.domain;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ReportJsonVO {
    private String srvy_id;
    private String form_name;
    private String form_json;
    private String input_json;
    private String created_at;
}