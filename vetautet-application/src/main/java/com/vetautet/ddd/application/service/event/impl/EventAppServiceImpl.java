package com.vetautet.ddd.application.service.event.impl;

import org.springframework.stereotype.Service;

import com.vetautet.ddd.application.service.event.IEventAppService;

@Service
public class EventAppServiceImpl implements IEventAppService{
    @Override
    public String sayHi(String who) {
        return new String("Hello from Event DDD Application Service\n");
    }

}
