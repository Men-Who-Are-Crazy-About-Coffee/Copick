package com.ssafy.coffee.domain.auth.service;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;

import javax.crypto.SecretKey;

import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.domain.auth.dto.TokenInfoDto;
import com.ssafy.coffee.domain.RefreshToken.repository.RefreshTokenRepository;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import com.ssafy.coffee.global.util.JwtUtil;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;

/**
 * 토큰 관련 메소드 제공 유틸, 서비스 클래스
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class JwtService {
    @Value("${jwt-config.secret}")
    private String secretKey;

    @Value("${JWT-TIME-ZONE:Asia/Seoul}")
    public String TIME_ZONE;

    private final RefreshTokenRepository tokenRepository;
    private final MemberRepository memberRepository;


    private Key key;
    private final long refreshTokenExpiredTime =JwtUtil.getRefreshTokenExpiredTime();
    private final long accessTokenExpiredTime= JwtUtil.getAccessTokenExpiredTime();

    @PostConstruct
    private void init() {
        byte[] keyBytes = this.secretKey.getBytes(StandardCharsets.UTF_8);
        this.key= Keys.hmacShaKeyFor(keyBytes);
    }

    public TokenInfoDto createToken(Authentication authentication) {
        Member member = (Member) authentication.getPrincipal();

        String accessToken= createAccessToken(member.getIndex(),authentication.getAuthorities(),member.getAuthType());

        String refreshToken= createRefreshToken(String.valueOf(member.getIndex()));

        return TokenInfoDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }




    public String createAccessToken(Long memberIndex, Collection<? extends GrantedAuthority> authorities, AuthType authType) {
        String authoritiesString = authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","));
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        Member member= memberRepository.findById(memberIndex).orElseThrow(()->new RuntimeException(""));
        return Jwts.builder()
                .subject("access_token")
                .claim("userIndex",member.getIndex())
                .claim("userNickName",member.getNickname())
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .claim("hasGrade", authoritiesString)
                .claim("authType",authType)
                .expiration(Date.from(now.plusSeconds(accessTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }


    public String createRefreshToken(String userIndex) {

        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));

        return Jwts.builder()
                .subject("refreshToken")
                .claim("userIndex",userIndex)
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .expiration(Date.from(now.plusSeconds(refreshTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }

    // 토큰에서 회원 정보 추출
    public Claims parseClaims(String token) {
        return Jwts.parser().verifyWith((SecretKey) key).build().parseSignedClaims(token).getPayload();
    }

    // JWT 토큰에서 인증 정보 조회
    public Authentication getAuthentication(String token) {
        Claims claims = parseClaims(token);

        Collection<? extends GrantedAuthority> authorities =
                Arrays.stream(claims.get("hasGrade").toString().split(","))
                        .map(SimpleGrantedAuthority::new)
                        .collect(Collectors.toList());

        switch (AuthType.valueOf(claims.get("authType").toString())) {
            case GUEST -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .nickname("GUEST")
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .build()
                        )
                        .build();
                return new OAuth2AuthenticationToken(principal, authorities, claims.get("authType").toString());
            }
            case LOCAL -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .index(Long.valueOf(claims.get("userIndex").toString()))
                                .nickname(claims.get("userNickName").toString())
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .authType(AuthType.valueOf(claims.get("authType").toString()))
                                .build()
                        )
                        .build();
                return new UsernamePasswordAuthenticationToken(principal,token,authorities);
            }
            case KAKAO,NAVER -> {
                PrincipalMember principal = PrincipalMember.builder()
                        .member(Member.builder()
                                .index(Long.valueOf(claims.get("userIndex").toString()))
                                .nickname(claims.get("userNickName").toString())
                                .role(Role.valueOf(claims.get("hasGrade").toString()))
                                .authType(AuthType.valueOf(claims.get("authType").toString()))
                                .build()
                        )
                        .build();

                return new OAuth2AuthenticationToken(principal, authorities, claims.get("authType").toString());
            }
        }
        return null;

    }

    public boolean validateAccessToken(String token) {
        try {
            LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
            Claims claims = parseClaims(token);
            return claims.getExpiration().before(Date.from(now.plusSeconds(accessTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant()));
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.error("오류 내용 {} : aaa {}",e.getMessage(),e.toString());
            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {

            log.info("만료된 JWT 토큰입니다.");


        } catch (UnsupportedJwtException e) {

            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {

            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    public boolean validateRefreshToken(String token) {
        try {
            LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
            Claims claims = parseClaims(token);
            return claims.getExpiration().before(Date.from(now.plusSeconds(JwtUtil.getRefreshTokenExpiredTime()).atZone(ZoneId.of(TIME_ZONE)).toInstant()));
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.error("오류 내용 {} : aaa {}",e.getMessage(),e.toString());
            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {

            log.info("만료된 JWT 토큰입니다.");

        } catch (UnsupportedJwtException e) {

            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {

            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    public RefreshToken findRefreshToken(String refreshToken) {
        try {
            return tokenRepository.findById(refreshToken).orElseThrow(()->new RuntimeException("존재하지 않는 리프레시 토큰"));
        } catch (Exception e) {

            log.info("refreshToken finder error : {}",e.getMessage());
        }
        return null;

    }


    public String createAndSaveRefreshToken(Member member) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        LocalDateTime expireTime=now.plusSeconds(refreshTokenExpiredTime);
        String refreshToekn= Jwts.builder()
                .subject("refreshToken")
                .claim("userIndex",member.getIndex())
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .expiration(Date.from(expireTime.atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();


        tokenRepository.save(RefreshToken.builder()
                .refreshToken(refreshToekn)
                .authType(member.getAuthType())
                .role(member.getRole())
                .expireTime(refreshTokenExpiredTime)
                .build()
        );
        return refreshToekn;
    }

    public String createGuestAccessToken(String guestMemberName, Collection<? extends GrantedAuthority> authorities, AuthType authType) {
        String authoritiesString = authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","));
        LocalDateTime now = LocalDateTime.now(ZoneId.of(TIME_ZONE));
        return Jwts.builder()
                .subject("access_token")
                .claim("userNickName",guestMemberName)
                .issuedAt(Date.from(now.atZone(ZoneId.of(TIME_ZONE)).toInstant()))
                .claim("hasGrade", authoritiesString)
                .claim("authType",authType)
                .expiration(Date.from(now.plusSeconds(accessTokenExpiredTime).atZone(ZoneId.of(TIME_ZONE)).toInstant())) // set Expire Time
                .signWith(key)
                .compact();
    }
}

