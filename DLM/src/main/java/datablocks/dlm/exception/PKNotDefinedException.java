package datablocks.dlm.exception;

public class PKNotDefinedException extends RuntimeException {

    public PKNotDefinedException(String msg){
        super(msg);
    }       
    public PKNotDefinedException(Exception ex){
        super(ex);
    }
}