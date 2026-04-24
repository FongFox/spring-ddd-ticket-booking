package com.vetautet.ddd.application.service.ticket;

import com.vetautet.ddd.domain.model.entity.TicketDetail;

public interface ITicketDetailAppService {

    TicketDetail getTicketDetailById(Long ticketId);
}