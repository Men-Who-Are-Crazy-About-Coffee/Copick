package com.ssafy.coffee.domain.member.repository;

import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.global.constant.AuthType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByIdAndAuthType(String id, AuthType authType);
    Optional<Member> findById(String memberId);
    Optional<Member> findByIndexAndIsDeletedFalse(Long index);
}
