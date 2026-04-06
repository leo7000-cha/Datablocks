package datablocks.dlm.aop;

import datablocks.dlm.util.LogUtil;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Aspect

@Component
public class LogAdvice {
	private static final Logger logger = LoggerFactory.getLogger(LogAdvice.class);

	@Before("execution(* datablocks.dlm.service.PiiConfKeymapService*.*(..))")
	public void logBefore() {
		LogUtil.log("INFO", "AOP TEST $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ logBefore $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
	}
	
	@Before("execution(* datablocks.dlm.service.PiiConfKeymapService*.get(Long)) && args(arg1)")
	public void logBeforeWithParam(Long arg1) {
		LogUtil.log("INFO", "AOP TEST $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ logBeforeWithParam $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
		LogUtil.log("INFO", "str1: " + arg1);
		LogUtil.log("INFO", "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");

	}
	
	@AfterThrowing(pointcut = "execution(* datablocks.dlm.service.PiiConfKeymapService*.*(..))",throwing="exception")
	public void logException(Exception exception) {
		LogUtil.log("INFO", "AOP TEST $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ logException $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
		LogUtil.log("INFO", "exception: " + exception);
		LogUtil.log("INFO", "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
	}

	@Around("execution(* datablocks.dlm.service.PiiConfKeymapService*.*(..))")
	public Object logTime(ProceedingJoinPoint pjp) {

		long start = System.currentTimeMillis();

		LogUtil.log("INFO", "Target: " + pjp.getTarget());
		LogUtil.log("INFO", "Param: " + Arrays.toString(pjp.getArgs()));

		// invoke method
		Object result = null;

		try {
			result = pjp.proceed();
		} catch (Throwable e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		long end = System.currentTimeMillis();

		LogUtil.log("INFO", "TIME: " + (end - start));
		LogUtil.log("INFO", "AOP TEST $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ logTime $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
		LogUtil.log("INFO", "TIME: " + (end - start));
		LogUtil.log("INFO", "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
		return result;
	}

}
