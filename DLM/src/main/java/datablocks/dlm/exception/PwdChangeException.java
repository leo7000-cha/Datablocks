package datablocks.dlm.exception;

public class PwdChangeException extends RuntimeException {

    public PwdChangeException(String msg){
        super(msg);
    }       
    public PwdChangeException(Exception ex){
        super(ex);
    }
}