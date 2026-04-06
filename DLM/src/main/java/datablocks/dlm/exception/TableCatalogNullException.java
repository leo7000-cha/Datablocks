package datablocks.dlm.exception;

public class TableCatalogNullException extends RuntimeException {

    public TableCatalogNullException(String msg){
        super(msg);
    }       
    public TableCatalogNullException(Exception ex){
        super(ex);
    }
}