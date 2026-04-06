package datablocks.dlm.domain;
import lombok.Data;

@Data
public class TestDataCombinedStatusVO {
    private String deptname;
    private String userName;
    private int autoGenRequestCount;
    private int autoGenCustomerCount;
    private int tableLoadRequestCount;
    private int tableLoadTableCount;
}