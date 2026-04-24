package com.vetautet.ddd.domain.service;

import com.vetautet.ddd.domain.model.entity.TicketDetail;

public interface ITicketDetailDomainService {

    TicketDetail getTicketDetailById(Long ticketId);
}