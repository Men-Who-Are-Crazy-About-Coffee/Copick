package com.ssafy.coffee.domain.auth.controller;

import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.RefreshToken.repository.RefreshTokenRepository;
import com.ssafy.coffee.domain.auth.dto.AccessTokenDto;
import com.ssafy.coffee.domain.auth.dto.LoginDto;
import com.ssafy.coffee.domain.auth.dto.RegisterMemberRequestDto;
import com.ssafy.coffee.domain.auth.dto.TokenInfoDto;
import com.ssafy.coffee.domain.auth.service.AuthService;
import com.ssafy.coffee.domain.auth.service.JwtService;

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
    private final AuthService authService;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;
    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;
    @PostMapping("/register")
    public ResponseEntity<? extends AccessTokenDto> authJoin(@RequestBody RegisterMemberRequestDto registerDto, HttpServletResponse response) {

        try {
            authService.registerMember(registerDto);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }


    }

    @PostMapping("/login")
    public ResponseEntity<TokenInfoDto> authLogin(@RequestBody LoginDto loginDto, HttpServletResponse response) throws URISyntaxException {
        log.debug("인증 시작");

        TokenInfoDto tokenInfoDto = authService.login(loginDto);
        URI cookieDomain=new URI(frontendBaseurl);
        UriComponents uriComponent= UriComponentsBuilder.fromHttpUrl(frontendBaseurl)
                .pathSegment("auth","login")
                .queryParam("resultCode",200)
                .queryParam("accessToken",tokenInfoDto.getAccessToken())
                .queryParam("refreshToken", tokenInfoDto.getRefreshToken())
                .encode()
                .build();
        HttpHeaders httpHeaders = new HttpHeaders();
        // response header에 jwt token에 넣어줌
        httpHeaders.add(JwtUtil.AUTHORIZATION_HEADER, JwtUtil.JWT_TYPE + tokenInfoDto.getAccessToken());
        Cookie cookie = new Cookie("refresh_token", tokenInfoDto.getRefreshToken());
        cookie.setHttpOnly(true);
        cookie.setMaxAge(JwtUtil.getRefreshTokenExpiredTime());
        cookie.setPath("/");
        cookie.setDomain(cookieDomain.getHost());
        cookie.setSecure(true); // https가 아니므로 아직 안됨
        response.addCookie(cookie);
        httpHeaders.setLocation(uriComponent.toUri());

        return ResponseEntity.status(HttpStatus.MOVED_PERMANENTLY).headers(httpHeaders).build();
    }


    @DeleteMapping("/logout")
    public ResponseEntity<?> logout(@RequestParam String refreshToken) {
        refreshTokenRepository.delete(RefreshToken.builder().refreshToken(refreshToken).build());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> requestAccessToken(HttpServletResponse response, HttpServletRequest request) {
        log.debug("엑세스토큰 재발급");

        String refreshTokenCookie = "";
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("refresh_token".equals(cookie.getName())) {
                    refreshTokenCookie = cookie.getValue();
                }
            }
            if (StringUtils.hasText(refreshTokenCookie)
                    && jwtService.validateRefreshToken(refreshTokenCookie)) {
                RefreshToken refreshToken = jwtService.findRefreshToken(refreshTokenCookie);
                AccessTokenDto accessTokenDto = AccessTokenDto.builder()
                        .accessToken(jwtService.createAccessToken(refreshToken.getMemberIndex(), List.of(() -> refreshToken.getRole().toString()), refreshToken.getAuthType()))
                        .build();
                response.setHeader(JwtUtil.AUTHORIZATION_HEADER, accessTokenDto.getAccessToken());
                return ResponseEntity.ok(accessTokenDto);
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }


}
