package com.vetautet.ddd.controller.resource;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vetautet.ddd.application.service.event.IEventAppService;

@RestController
@RequestMapping("hello")
public class HiController {
    private final IEventAppService eventAppService;

    public HiController(IEventAppService eventAppService) {
        this.eventAppService = eventAppService;
    }

    @GetMapping("hi")
    public String getHello() {
        // return new String("Hello world!");
        return eventAppService.sayHi("who???");
    }

    @GetMapping("hi/v1")
    public String getHi() {
        // return new String("Hello world!");
        return eventAppService.sayHi("who???");
    }
}