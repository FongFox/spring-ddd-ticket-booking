package com.vetautet.ddd.domain.repository;

import org.springframework.stereotype.Repository;

@Repository
public interface IHiDomainRepository {
    String sayHi(String who);
}
