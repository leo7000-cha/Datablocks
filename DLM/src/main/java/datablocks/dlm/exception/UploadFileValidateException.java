package datablocks.dlm.exception;

public class UploadFileValidateException extends RuntimeException {

    public UploadFileValidateException(String msg){
        super(msg);
    }       
    public UploadFileValidateException(Exception ex){
        super(ex);
    }
}