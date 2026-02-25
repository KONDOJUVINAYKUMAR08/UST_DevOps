package com.ust.retails.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import com.ust.retails.entity.Product;
import com.ust.retails.service.ProductService;

@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    public Product createProduct(@RequestBody Product product) {
        return productService.save(product);
    }

    @GetMapping
    public List<Product> getProducts() {
        return productService.getAll();
    }
}