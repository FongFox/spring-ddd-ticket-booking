package com.vetautet.ddd.domain.service.impl;

import com.vetautet.ddd.domain.model.entity.TicketDetail;
import com.vetautet.ddd.domain.repository.ITicketDetailRepository;
import com.vetautet.ddd.domain.service.ITicketDetailDomainService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TicketDetailDomainServiceImpl implements ITicketDetailDomainService {

    // Call repository in domain
    @Autowired
    private ITicketDetailRepository ticketDetailRepository;

    @Override
    public TicketDetail getTicketDetailById(Long ticketId) {
        log.info("Implement Domain : {}", ticketId);
        return ticketDetailRepository.findById(ticketId).orElse(null);
    }
}