package com.nonheritage.demo.scheduler;

import com.nonheritage.demo.service.DisputeService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** 纠纷定时调度器：每60秒检查一次超时纠纷，自动裁决 */
@Component
public class DisputeScheduler {
    private final DisputeService disputeService;

    public DisputeScheduler(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    /** 定时执行纠纷裁决，间隔60秒 */
    @Scheduled(fixedDelay = 60000)
    public void resolveDisputes() {
        disputeService.resolveOverdueDisputes();
    }
}
