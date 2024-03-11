package com.ssafy.coffee.global.config;

import com.ssafy.coffee.global.auth.service.CustomOAuth2UserService;
import com.ssafy.coffee.global.auth.service.JwtService;
import com.ssafy.coffee.global.auth.service.OAuth2LoginFailHandler;
import com.ssafy.coffee.global.auth.service.OAuth2LoginSuccessHandler;
import com.ssafy.coffee.global.config.CorsConfig;
import com.ssafy.coffee.global.filter.JwtFilter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.*;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import java.util.List;


@Configuration
@EnableWebSecurity //시큐리티 활성화 -> 기본 스프링 필터 체인에 등록
@RequiredArgsConstructor
@Slf4j
public class SecurityConfig  {

    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2LoginSuccessHandler oAuth2LoginSuccessHandler;
    private final OAuth2LoginFailHandler oAuth2LoginFailHandler;
    private final JwtService jwtService;
    private final CorsConfig corsConfig;
    private static final String[] PERMIT_PATTERNS=List.of(
            "/login"
    ).toArray(String[]::new);

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .httpBasic(HttpBasicConfigurer::disable)
                .sessionManagement((session) -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .csrf((csrf)->csrf.disable())
                .formLogin((FormLoginConfigurer::disable))
                .cors((customCorsConfig)->customCorsConfig.configurationSource(corsConfig.corsConfigurationSource()))

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PERMIT_PATTERNS).permitAll()
                        .requestMatchers(new AntPathRequestMatcher("/**")).permitAll() // 개발시 편하게 하기 위한 설정 반드시 나중에 제거
                        .anyRequest().authenticated())
                .formLogin(AbstractHttpConfigurer::disable)
                .oauth2Login((oauth2)->oauth2
                        .successHandler(oAuth2LoginSuccessHandler)
                        .failureHandler(oAuth2LoginFailHandler)
                        .userInfoEndpoint((userInfoEndpoint)->
                                userInfoEndpoint.userService(customOAuth2UserService))

                )

                .addFilterBefore(new JwtFilter(jwtService), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}