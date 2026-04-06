package datablocks.dlm.exception;

public class ArcDecGapException extends RuntimeException {

    public ArcDecGapException(String msg){
        super(msg);
    }       
    public ArcDecGapException(Exception ex){
        super(ex);
    }
}