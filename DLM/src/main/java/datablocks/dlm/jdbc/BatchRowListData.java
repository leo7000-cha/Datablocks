package datablocks.dlm.jdbc;

import java.util.List;
import java.util.Map;

public class BatchRowListData {
    private int intValue;
    private List<Map<Integer, Object>> batchRowList;

    public BatchRowListData(int intValue, List<Map<Integer, Object>> batchRowList) {
        this.intValue = intValue;
        this.batchRowList = batchRowList;
    }

    public int getIntValue() {
        return intValue;
    }

    public List<Map<Integer, Object>> getBatchRowList() {
        return batchRowList;
    }
}
