package com.ssafy.coffee.domain.board.repository;

import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.entity.BoardLike;
import com.ssafy.coffee.domain.member.entity.Member;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BoardLikeRepository extends JpaRepository<BoardLike, Long> {

    Optional<BoardLike> findByBoardAndMember(Board board, Member member);

    boolean existsByBoardAndMember(Board board, Member member);

    Page<BoardLike> findAllByMemberIndex(Long memberIndex, Pageable pageable);
}
