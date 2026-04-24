package com.vetautet.ddd.infrastructure.persistence.repository;

import com.vetautet.ddd.domain.model.entity.TicketDetail;
import com.vetautet.ddd.domain.repository.ITicketDetailRepository;
import com.vetautet.ddd.infrastructure.persistence.mapper.TicketDetailJPAMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Slf4j
public class TicketDetailInfrasRepositoryImpl implements ITicketDetailRepository {

    // CALL JPA MAPPER
    @Autowired
    private TicketDetailJPAMapper ticketDetailJPAMapper;

    @Override
    public Optional<TicketDetail> findById(Long id) {
        log.info("Implement Infrastructure : {}", id);
        return ticketDetailJPAMapper.findById(id);
    }
}