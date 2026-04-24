package com.vetautet.ddd.application.service.ticket.impl;

import com.vetautet.ddd.application.service.ticket.ITicketDetailAppService;
import com.vetautet.ddd.application.service.ticket.cache.TicketDetailCacheService;
import com.vetautet.ddd.domain.model.entity.TicketDetail;
import com.vetautet.ddd.domain.service.ITicketDetailDomainService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TicketDetailAppServiceImpl implements ITicketDetailAppService {

    // CALL Service Domain Module
    @Autowired
    private ITicketDetailDomainService ticketDetailDomainService;

    // CALL CACHE
    @Autowired
    private TicketDetailCacheService ticketDetailCacheService;

    @Override
    public TicketDetail getTicketDetailById(Long ticketId) {
        log.info("Implement Application : {}", ticketId);
//        return ticketDetailDomainService.getTicketDetailById(ticketId);
//        return ticketDetailCacheService.getTicketDefaultCacheNormal(ticketId, System.currentTimeMillis());
        return ticketDetailCacheService.getTicketDefaultCacheVip(ticketId, System.currentTimeMillis());
    }
}