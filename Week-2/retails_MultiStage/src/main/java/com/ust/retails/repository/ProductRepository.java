package com.ust.retails.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ust.retails.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
}