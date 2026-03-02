package com.example.demo;

import org.springframework.stereotype.Service;

@Service
public class InfoService {

    public String info() {
        return "This is a Monolithic Spring Boot Application with 2 Services.";
    }
}
