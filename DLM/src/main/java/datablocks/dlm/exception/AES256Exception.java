package datablocks.dlm.exception;

public class AES256Exception extends RuntimeException {

    public AES256Exception(String msg){
        super(msg);
    }       
    public AES256Exception(Exception ex){
        super(ex);
    }
}