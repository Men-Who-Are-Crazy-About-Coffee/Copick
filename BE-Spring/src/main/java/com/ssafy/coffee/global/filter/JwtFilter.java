package com.ssafy.coffee.global.filter;

import com.ssafy.coffee.domain.RefreshToken.entity.RefreshToken;
import com.ssafy.coffee.domain.auth.service.JwtService;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import com.ssafy.coffee.global.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Jwt 필터
 * 한번만 인증하기 위해 OnePerRequestFilter 상속(요청당 한번만 통과하면됨)
 *
 */
@Slf4j
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private static final List<String> allowUrlList=List.of("/api/auth/refresh","/api/auth/register","/api/auth/login");
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        if(allowUrlList.contains(request.getRequestURI())){
            return super.shouldNotFilter(request);
        }
        return false;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String jwt = JwtUtil.resolveToken(request);
        String requestURI =request.getRequestURI();
        log.debug(jwt+" : "+requestURI+  ": " +(StringUtils.hasText(jwt) && jwtService.validateAccessToken(jwt)));
        if (StringUtils.hasText(jwt)) {
            if(jwtService.validateAccessToken(jwt)) {
                Authentication authentication = jwtService.getAuthentication(jwt);
                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.debug("Security Context에 '{}' 인증 정보를 저장했습니다, uri: {}", authentication.getName(), requestURI);
            }else {
                String refreshTokenCookie="";
                Cookie[] cookies = request.getCookies();
                if(cookies!=null) {
                    for (Cookie cookie : cookies) {
                        if("refresh_token".equals(cookie.getName())) {
                            refreshTokenCookie=cookie.getValue();
                        }
                    }
                    if(StringUtils.hasText(refreshTokenCookie)
                            && jwtService.validateRefreshToken(refreshTokenCookie)) {
                        RefreshToken refreshToken = jwtService.findRefreshToken(refreshTokenCookie);
                        if(refreshToken==null) return;
                        response.setHeader(JwtUtil.AUTHORIZATION_HEADER, jwtService.createAccessToken(refreshToken.getMemberIndex(),List.of(() -> refreshToken.getRole().toString()), refreshToken.getAuthType()));
                    }
                }

            }
        } else {
            log.debug("유효한 JWT 토큰이 없습니다, uri: {}", requestURI);
            response.setHeader(JwtUtil.AUTHORIZATION_HEADER, jwtService.createGuestAccessToken("Guest",List.of(Role.GUEST::toString), AuthType.GUEST));
            filterChain.doFilter(request, response);
            return;
        }
        log.debug("필터이동");
        filterChain.doFilter(request, response);
    }
}
