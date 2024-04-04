package com.ssafy.coffee.domain.result.repository;

import com.ssafy.coffee.domain.result.entity.Flaw;
import com.ssafy.coffee.domain.result.entity.Result;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FlawRepository extends JpaRepository<Flaw, Long> {
    List<Flaw> findAllByResultIndex(Long resultIndex);
    List<Flaw> findAllByResultIndexAndIsDeleted(Long resultIndex,boolean isDeleted);
    @Modifying
    @Query("update Flaw f set f.isDeleted = true where f.flawIndex in :flawIndexes")
    void updateAllByIndex(List<Long> flawIndexes);

}
