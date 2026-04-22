package datablocks.dlm.xaudit;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Arrays;

import org.junit.jupiter.api.Test;

import datablocks.dlm.xaudit.core.XauditPiiMasker;

public class XauditPiiMaskerTest {

    @Test
    public void detectsJumin() {
        XauditPiiMasker m = new XauditPiiMasker(Arrays.asList("JUMIN"));
        assertTrue(m.detect("INSERT INTO CUST VALUES ('871205-1234567')").contains("JUMIN"));
    }

    @Test
    public void detectsCard() {
        XauditPiiMasker m = new XauditPiiMasker(Arrays.asList("CARD"));
        assertTrue(m.detect("4111-1111-1111-1111").contains("CARD"));
    }

    @Test
    public void masksJumin() {
        XauditPiiMasker m = new XauditPiiMasker(Arrays.asList("JUMIN"));
        assertEquals("x=*** y", m.mask("x=871205-1234567 y"));
    }

    @Test
    public void returnsNullWhenNoMatch() {
        XauditPiiMasker m = new XauditPiiMasker(Arrays.asList("JUMIN", "CARD"));
        assertNull(m.detect("no sensitive data here"));
    }

    @Test
    public void returnsNullWhenDisabled() {
        XauditPiiMasker m = new XauditPiiMasker(Arrays.asList());
        assertNull(m.detect("871205-1234567 4111-1111-1111-1111"));
    }
}
