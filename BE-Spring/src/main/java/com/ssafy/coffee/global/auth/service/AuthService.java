package com.ssafy.coffee.global.auth.service;

import ch.qos.logback.core.Context;
import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.global.auth.dto.LoginDto;
import com.ssafy.coffee.global.auth.dto.RegisterMemberRequestDto;
import com.ssafy.coffee.global.auth.dto.TokenInfoDto;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final JwtService jwtService;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final PasswordEncoder passwordEncoder;
    private final MemberRepository memberRepository;


    public TokenInfoDto login(LoginDto loginDto){

        return createAuthenticationToken(loginDto.getId(), loginDto.getPassword());
    }
    public TokenInfoDto createAuthenticationToken(String userName, String userPassword) {
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(userName,userPassword);
        // authenticate 메소드가 실행이 될 때 CustomUserDetailsService class의 loadUserByUsername 메소드가 실행
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        // 해당 객체를 SecurityContextHolder에 저장하고
        SecurityContextHolder.getContext().setAuthentication(authentication);
        // authentication 객체를 createToken 메소드를 통해서 JWT Token을 생성
        TokenInfoDto tokenInfoDto = jwtService.createToken(authentication);
        try {
            jwtService.createAndSaveRefreshToken((Member) authentication.getPrincipal());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tokenInfoDto;
    }
    @Transactional
    public void registerMember(RegisterMemberRequestDto memberRequestDto){
        if(memberRepository.existsByIdAndAuthType(memberRequestDto.getId(), AuthType.LOCAL))
            return;
        memberRepository.save(Member.builder()
                .id(memberRequestDto.getId())
                .role(Role.USER)
                .authType(AuthType.LOCAL)
                .nickname(memberRequestDto.getNickname())
                .password(passwordEncoder.encode(memberRequestDto.getPassword()))
                .build());
    }

}
