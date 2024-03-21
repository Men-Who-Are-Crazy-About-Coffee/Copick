package com.ssafy.coffee.domain.auth.controller;

import com.ssafy.coffee.domain.RefreshToken.dto.RefreshTokenDto;
import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.RefreshToken.repository.RefreshTokenRepository;
import com.ssafy.coffee.domain.auth.dto.*;
import com.ssafy.coffee.domain.auth.service.AuthService;
import com.ssafy.coffee.domain.auth.service.JwtService;

import com.ssafy.coffee.domain.member.service.MemberService;
import com.ssafy.coffee.global.util.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;

@RestController
@Slf4j
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final MemberService memberService;
    private final AuthService authService;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;

    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;

    @PostMapping("/register")
    public ResponseEntity<Object> authJoin(@RequestBody MemberRegistRequestDto memberRegistRequestDto) {
        memberService.registerMember(memberRegistRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("register successfully");
    }

//

    @PostMapping("/login")
    public ResponseEntity<TokenInfoDto> authLogin(@RequestBody LoginDto loginDto, HttpServletResponse response) {
        log.debug("인증 시작");

        TokenInfoDto tokenInfoDto = authService.login(loginDto);

        Cookie cookie = new Cookie("refresh_token", tokenInfoDto.getRefreshToken());
        cookie.setHttpOnly(true);
        cookie.setMaxAge(JwtUtil.getRefreshTokenExpiredTime());
        cookie.setPath("/");
        cookie.setSecure(true);
        response.addCookie(cookie);

        return ResponseEntity.ok(tokenInfoDto);
    }



    @DeleteMapping("/logout")
    public ResponseEntity<?> logout(@RequestParam String refreshToken) {
        refreshTokenRepository.delete(RefreshToken.builder().refreshToken(refreshToken).build());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> requestAccessToken(HttpServletResponse response, HttpServletRequest request,@RequestBody RefreshTokenRequestDto refreshTokenDto) {
        log.debug("엑세스토큰 재발급");
        String refreshTokenString = refreshTokenDto.getRefreshToken();
        if (!StringUtils.hasText(refreshTokenString)) {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("refresh_token".equals(cookie.getName())) {
                        refreshTokenString = cookie.getValue();
                    }
                }
            }
        }
            log.debug("토큰 {}",refreshTokenString);
            if (StringUtils.hasText(refreshTokenString)
                    && jwtService.validateRefreshToken(refreshTokenString)) {
                RefreshToken refreshToken = jwtService.findRefreshToken(refreshTokenString);
                if(refreshToken==null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
                AccessTokenDto accessTokenDto = AccessTokenDto.builder()
                        .accessToken(jwtService.createAccessToken(refreshToken.getMemberIndex(), List.of(() -> refreshToken.getRole().toString()), refreshToken.getAuthType()))
                        .build();
                response.setHeader(JwtUtil.AUTHORIZATION_HEADER, accessTokenDto.getAccessToken());
                return ResponseEntity.ok(accessTokenDto);
            }
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }


}
