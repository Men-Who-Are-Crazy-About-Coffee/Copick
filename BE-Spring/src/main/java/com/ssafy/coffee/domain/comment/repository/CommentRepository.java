package com.ssafy.coffee.domain.comment.repository;

import com.ssafy.coffee.domain.comment.entity.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    Page<Comment> findAllByBoardIndex(Long boardIndex, Pageable pageable);

    Page<Comment> findAllByCreatedByIndex(Long userIndex, Pageable pageable);
}
