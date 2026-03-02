package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MainController {

    private final GreetingService greetingService;
    private final InfoService infoService;

    public MainController(GreetingService greetingService, InfoService infoService) {
        this.greetingService = greetingService;
        this.infoService = infoService;
    }

    @GetMapping("/")
    public String home() {
        return greetingService.greet() + "\n" + infoService.info();
    }
}
