package com.ssafy.coffee.global.auth.service;

import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.global.auth.dto.PrincipalMember;
import com.ssafy.coffee.global.util.JwtUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collection;

/**
 * Oauth2 로그인 성공시 처리 핸들러 사용자 정의 구현
 *
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final JwtService jwtService;
    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        log.info("OAuth2 Login 성공");
        try {
            Member oAuth2User = ((PrincipalMember) authentication.getPrincipal()).toEntity();
            System.out.println(oAuth2User.toString());
            log.debug(oAuth2User.toString());
            loginSuccess(response, oAuth2User,authentication.getAuthorities()); // 로그인에 성공한 경우 access, refresh 토큰 생성
        } catch (Exception e) {

            log.debug("로그인 에러: {} 원인 :{}, {}",e.getMessage(),e.getCause(),e.getStackTrace());
        }
        log.info("로그인 절차 완료!");


    }

    private void loginSuccess(HttpServletResponse response, Member oAuth2User, Collection<? extends GrantedAuthority> authorities) throws IOException, URISyntaxException {
        String accessToken = jwtService.createAccessToken(oAuth2User.getIndex(), authorities, oAuth2User.getAuthType());
        String refreshToken = jwtService.createAndSaveRefreshToken(oAuth2User);
        response.addHeader(JwtUtil.AUTHORIZATION_HEADER, JwtUtil.JWT_TYPE + accessToken);

        URI cookieDomain=new URI(frontendBaseurl);

        Cookie cookie = new Cookie("refresh_token", refreshToken);
        cookie.setHttpOnly(true);
        cookie.setMaxAge(JwtUtil.getRefreshTokenExpiredTime());
        cookie.setPath("/");
        cookie.setDomain(cookieDomain.getHost());
        cookie.setSecure(true); // https가 아니므로 아직 안됨
        response.addCookie(cookie);
        log.debug("토큰 :{}",accessToken);
        UriComponents uriComponent= UriComponentsBuilder.fromHttpUrl(frontendBaseurl)
                .pathSegment("auth","login")
                .queryParam("resultCode",200)
                .queryParam("accessToken",accessToken)
                .queryParam("refreshToken", refreshToken)
                .encode()
                .build();
        response.sendRedirect(uriComponent.toString());

    }
}