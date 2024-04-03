package com.ssafy.coffee.domain.board.repository;

import com.ssafy.coffee.domain.board.entity.BoardRedisLike;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface BoardRedisLikeRepository extends CrudRepository<BoardRedisLike, Integer> {
    List<BoardRedisLike> findAllByBoardIndex(Long boardIndex);
    List<BoardRedisLike> findAllByMemberIndex(Long memberIndex);
}
