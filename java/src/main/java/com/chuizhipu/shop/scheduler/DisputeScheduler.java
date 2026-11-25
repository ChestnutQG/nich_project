package com.chuizhipu.shop.scheduler;

import com.chuizhipu.shop.service.DisputeService;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@EnableScheduling
public class DisputeScheduler {

    private final DisputeService disputeService;

    public DisputeScheduler(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    /** 每 60 秒检查超时纠纷并自动裁决 */
    @Scheduled(fixedDelay = 60000)
    public void autoResolveDisputes() {
        disputeService.resolveOverdueDisputes();
    }
}
