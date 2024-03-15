package com.ssafy.coffee.domain.bean.repository;

import com.ssafy.coffee.domain.bean.entity.Bean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BeanRepository extends JpaRepository<Bean, Long> {
    <Optional> Bean findByIndex(Long index);
}
