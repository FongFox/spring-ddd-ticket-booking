package com.vetautet.ddd.domain.service.impl;

import org.springframework.stereotype.Service;

import com.vetautet.ddd.domain.repository.IHiDomainRepository;
import com.vetautet.ddd.domain.service.IHiDomainService;

@Service
public class HiDomainServiceImpl implements IHiDomainService{
    private final IHiDomainRepository hiDomainRepository;

    public HiDomainServiceImpl(IHiDomainRepository hiDomainRepository) {
        this.hiDomainRepository = hiDomainRepository;
    }

    @Override
    public String sayHi(String who) {
        return hiDomainRepository.sayHi("gustav who? gustav who? who?");
    }
    
}
