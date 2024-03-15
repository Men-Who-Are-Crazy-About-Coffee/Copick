package com.ssafy.coffee.domain.board.repository;

import com.ssafy.coffee.domain.board.entity.Board;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface BoardRepository extends JpaRepository<Board, Long> {

    @Query("SELECT b FROM Board b WHERE b.title LIKE %:keyword% AND b.domain = :domain")
    Page<Board> findByKeywordAndDomain(@Param("keyword") String keyword, @Param("domain") String domain, Pageable pageable);

}
