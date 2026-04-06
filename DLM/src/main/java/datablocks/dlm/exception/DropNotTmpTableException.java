package datablocks.dlm.exception;

public class DropNotTmpTableException extends RuntimeException {

    public DropNotTmpTableException(String msg){
        super(msg);
    }
    public DropNotTmpTableException(Exception ex){
        super(ex);
    }
}