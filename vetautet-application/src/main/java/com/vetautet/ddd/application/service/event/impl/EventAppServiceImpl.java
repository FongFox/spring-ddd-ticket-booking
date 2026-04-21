package com.vetautet.ddd.application.service.event.impl;

import org.springframework.stereotype.Service;

import com.vetautet.ddd.application.service.event.IEventAppService;
import com.vetautet.ddd.domain.service.IHiDomainService;

@Service
public class EventAppServiceImpl implements IEventAppService{
    // Call Domain Service 
    private final IHiDomainService hiDomainService;

    public EventAppServiceImpl(IHiDomainService hiDomainService) {
        this.hiDomainService = hiDomainService;
    }

    @Override
    public String sayHi(String who) {
        return hiDomainService.sayHi("Gustav who? Gustav who? who?");
    }

}
