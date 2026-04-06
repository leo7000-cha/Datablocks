package datablocks.dlm.exception;

public class OrderDupException extends RuntimeException {

    public OrderDupException(String msg){
        super(msg);
    }       
    public OrderDupException(Exception ex){
        super(ex);
    }
}