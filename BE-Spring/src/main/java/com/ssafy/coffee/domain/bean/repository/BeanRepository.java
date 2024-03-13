package com.ssafy.coffee.domain.bean.repository;

import com.ssafy.coffee.domain.bean.entity.Bean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BeanRepository extends JpaRepository<Bean, Long> {

}
