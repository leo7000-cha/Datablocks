package datablocks.dlm.config;

import datablocks.dlm.aop.LogAdvice;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.AsyncTaskExecutor;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

import java.util.concurrent.Callable;
import java.util.concurrent.Executor;
import java.util.concurrent.Future;

@Configuration
@EnableAsync
public class SpringAsyncConfig {

    protected Logger logger = LoggerFactory.getLogger(SpringAsyncConfig.class);
    protected Logger errorLogger = LoggerFactory.getLogger("error");

    @Bean
    public TaskScheduler taskScheduler() {
        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(2);
        scheduler.setThreadNamePrefix("Scheduler-");
        scheduler.initialize();
        return scheduler;
    }

    @Bean(name = "threadPoolTaskExecutor", destroyMethod = "destroy")
    public Executor threadPoolTaskExecutor() {
        ThreadPoolTaskExecutor taskExecutor = new ThreadPoolTaskExecutor();
        taskExecutor.setCorePoolSize(3);
        taskExecutor.setMaxPoolSize(30);
        taskExecutor.setQueueCapacity(10);
        taskExecutor.setThreadNamePrefix("Executor-");
        taskExecutor.initialize();
        return new HandlingExecutor(taskExecutor); // HandlingExecutor로 wrapping 합니다.
    }

    /**
     * AOP 접속기록 전용 Executor.
     * - core=2 로 낮춰 해시체인 레이스(selectLastHash 중복) 가능성을 최소화
     * - queue=200 로 버스트 흡수
     * - UI 비동기 작업과 분리해 서로 영향 차단
     */
    @Bean(name = "accessLogAopExecutor", destroyMethod = "destroy")
    public Executor accessLogAopExecutor() {
        ThreadPoolTaskExecutor taskExecutor = new ThreadPoolTaskExecutor();
        taskExecutor.setCorePoolSize(2);
        taskExecutor.setMaxPoolSize(8);
        taskExecutor.setQueueCapacity(200);
        taskExecutor.setThreadNamePrefix("AopAccessLog-");
        taskExecutor.setWaitForTasksToCompleteOnShutdown(true);
        taskExecutor.setAwaitTerminationSeconds(10);
        taskExecutor.initialize();
        return new HandlingExecutor(taskExecutor);
    }

    public class HandlingExecutor implements AsyncTaskExecutor {
        private AsyncTaskExecutor executor;

        public HandlingExecutor(AsyncTaskExecutor executor) {
            this.executor = executor;
        }

        @Override
        public void execute(Runnable task) {
            executor.execute(createWrappedRunnable(task));
        }

        @Override
        public void execute(Runnable task, long startTimeout) {
            executor.execute(createWrappedRunnable(task), startTimeout);
        }

        @Override
        public Future<?> submit(Runnable task) {
            return executor.submit(createWrappedRunnable(task));
        }

        @Override
        public <T> Future<T> submit(final Callable<T> task) {
            return executor.submit(createCallable(task));
        }

        private <T> Callable<T> createCallable(final Callable<T> task) {
            final String taskName = task.getClass().getName();
            return new Callable<T>() {
                @Override
                public T call() throws Exception {
                    try {
                        return task.call();
                    } catch (Throwable t) {
                        handle(taskName, t);
                        if (t instanceof Exception) throw (Exception) t;
                        throw new RuntimeException(t);
                    }
                }
            };
        }

        private Runnable createWrappedRunnable(final Runnable task) {
            final String taskName = task.getClass().getName();
            return new Runnable() {
                @Override
                public void run() {
                    try {
                        task.run();
                    } catch (Throwable t) {
                        // Bug G 보강 (2026-04-28): Exception → Throwable 로 확대 (OOM 등 Error 도 캐치)
                        handle(taskName, t);
                    }
                }
            };
        }

        private void handle(String taskName, Throwable t) {
            // Bug G: INFO → ERROR 통일 + task 식별자 포함
            errorLogger.error("Async task failed: task={}, cause={}", taskName, t.getMessage(), t);
        }

        public void destroy() {
            if(executor instanceof ThreadPoolTaskExecutor){
                ((ThreadPoolTaskExecutor) executor).shutdown();
            }
        }
    }

}