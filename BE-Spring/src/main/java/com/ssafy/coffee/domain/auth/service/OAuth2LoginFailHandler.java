package com.ssafy.coffee.domain.auth.service;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;

@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2LoginFailHandler implements AuthenticationFailureHandler {
    @Value("${app.baseurl.frontend}")
    private String frontendBaseurl;
    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
        log.info("OAuth2 Login 실패");
        try {
            log.debug("실패한 로그인 요청: {}, 에러 :{}",request.getRequestURI(),exception.getMessage());
            loginFailure(response); // 로그인 실패하여 에러 리다이렉트
        } catch (IOException e) {
            log.debug("로그인 실패처리 실패");
            log.debug(e.getLocalizedMessage());
        }
        log.info("처리 절차완료");
    }
    private void loginFailure(HttpServletResponse response) throws IOException {
        UriComponents uriComponent= UriComponentsBuilder.fromHttpUrl(frontendBaseurl)
                .pathSegment("auth","login")
                .queryParam("resultCode",403)
                .queryParam("error","loginFail")
                .encode()
                .build();
        response.sendRedirect(uriComponent.toString());
    }
}
