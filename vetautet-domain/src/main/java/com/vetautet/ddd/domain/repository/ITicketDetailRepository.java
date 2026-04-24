package com.vetautet.ddd.domain.repository;

import com.vetautet.ddd.domain.model.entity.TicketDetail;

import java.util.Optional;

public interface ITicketDetailRepository {

    Optional<TicketDetail> findById(Long id);
}