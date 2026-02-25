package com.ust.retails.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ust.retails.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {
}