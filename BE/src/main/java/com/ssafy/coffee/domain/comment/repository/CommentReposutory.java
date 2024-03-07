package com.ssafy.coffee.domain.comment.repository;

import com.ssafy.coffee.domain.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentReposutory extends JpaRepository<Member, Long> {

}
