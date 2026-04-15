package datablocks.dlm.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import datablocks.dlm.controller.PiiExtractController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.ModelAndView;

@RestControllerAdvice
public class PiiExceptionHandler {
	private static final Logger logger = LoggerFactory.getLogger(PiiExceptionHandler.class);

	@ExceptionHandler(value = Exception.class)
	@ResponseStatus (HttpStatus.INTERNAL_SERVER_ERROR)
	public ModelAndView exceptionHandler( HttpServletRequest request, HttpServletResponse response, Exception exception) {
		String contentType = request.getHeader("Content-Type");
		ModelAndView model=null;
		String reason= HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase();
		int statusCode= HttpStatus.INTERNAL_SERVER_ERROR.value();

		// 상세 에러 메시지 구성
		String errorDetail = exception.getClass().getSimpleName() + ": "
			+ (exception.getMessage() != null ? exception.getMessage() : "(no message)");
		if (exception.getCause() != null) {
			errorDetail += " / Caused by: " + exception.getCause().getClass().getSimpleName()
				+ ": " + exception.getCause().getMessage();
		}

		// Content-Type 확인, json 만 View를 따로 처리함.
		if(contentType!=null && MediaType.APPLICATION_JSON_VALUE.equals(contentType)){
			model = new ModelAndView("jsonView");
			ResponseStatus annotation = exception.getClass().getAnnotation(ResponseStatus.class);
			if(annotation!=null){
				reason = annotation.reason();
				statusCode = annotation.value().value();
			}
		} else {
			//json 이 아닐경우 error page 로 이동
			model = new ModelAndView("error_page");
			logger.warn("warn contentType: {} exception: {}", contentType, errorDetail);
			logger.warn("warn stacktrace:", exception);
		}
		model.addObject("reason", errorDetail);
		model.addObject("statusCode",statusCode);
		response.setStatus(statusCode);
		return model;
	} 
}
