package com.ssafy.coffee.domain.RefreshToken.repository;

import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RefreshTokenRepository extends CrudRepository<RefreshToken, String> {
}
