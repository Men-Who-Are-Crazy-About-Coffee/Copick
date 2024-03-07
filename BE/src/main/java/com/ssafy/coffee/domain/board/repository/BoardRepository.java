package com.ssafy.coffee.domain.board.repository;

import com.ssafy.coffee.domain.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BoardRepository extends JpaRepository<Member, Long> {

}
