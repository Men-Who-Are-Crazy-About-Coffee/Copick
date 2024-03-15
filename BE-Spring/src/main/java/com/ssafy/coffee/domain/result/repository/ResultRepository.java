package com.ssafy.coffee.domain.result.repository;

import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.global.constant.AuthType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ResultRepository extends JpaRepository<Result, Long> {
    Optional<Result> findByIndex(Long index);
}