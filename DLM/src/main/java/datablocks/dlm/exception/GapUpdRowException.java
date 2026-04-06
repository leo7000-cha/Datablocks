package datablocks.dlm.exception;

public class GapUpdRowException extends RuntimeException {

    public GapUpdRowException(String msg){
        super(msg);
    }       
    public GapUpdRowException(Exception ex){
        super(ex);
    }
}