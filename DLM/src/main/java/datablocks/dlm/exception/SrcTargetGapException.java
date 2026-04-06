package datablocks.dlm.exception;

public class SrcTargetGapException extends RuntimeException {

    public SrcTargetGapException(String msg){
        super(msg);
    }
    public SrcTargetGapException(Exception ex){
        super(ex);
    }
}