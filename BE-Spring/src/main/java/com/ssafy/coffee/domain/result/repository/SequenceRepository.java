package com.ssafy.coffee.domain.result.repository;

import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SequenceRepository extends JpaRepository<Sequence, Long> {
    List<Sequence> findAllByResultIndex(Long resultIndex);
}