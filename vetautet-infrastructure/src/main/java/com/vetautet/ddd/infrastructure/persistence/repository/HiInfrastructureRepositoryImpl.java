package com.vetautet.ddd.infrastructure.persistence.repository;

import org.springframework.stereotype.Repository;

import com.vetautet.ddd.domain.repository.IHiDomainRepository;

@Repository
public class HiInfrastructureRepositoryImpl implements IHiDomainRepository{

    @Override
    public String sayHi(String who) {
        return new String("Hi from Infrastructure!\n");
    }

}
