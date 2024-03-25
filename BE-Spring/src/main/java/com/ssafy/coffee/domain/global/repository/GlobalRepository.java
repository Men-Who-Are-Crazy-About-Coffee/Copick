package com.ssafy.coffee.domain.global.repository;

import com.ssafy.coffee.domain.global.entity.Global;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GlobalRepository extends JpaRepository<Global, String> {

}
