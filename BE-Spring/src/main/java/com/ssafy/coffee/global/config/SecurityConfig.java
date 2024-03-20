package com.ssafy.coffee.global.config;

import org.springframework.http.HttpMethod;
import com.ssafy.coffee.domain.auth.service.CustomOAuth2UserService;
import com.ssafy.coffee.domain.auth.service.JwtService;
import com.ssafy.coffee.domain.auth.service.OAuth2LoginFailHandler;
import com.ssafy.coffee.domain.auth.service.OAuth2LoginSuccessHandler;
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

import java.util.List;


@Configuration
@EnableWebSecurity //시큐리티 활성화 -> 기본 스프링 필터 체인에 등록
@RequiredArgsConstructor
@Slf4j
public class SecurityConfig {

    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2LoginSuccessHandler oAuth2LoginSuccessHandler;
    private final OAuth2LoginFailHandler oAuth2LoginFailHandler;
    private final JwtService jwtService;
    private final CorsConfig corsConfig;
    private static final String[] PERMIT_PATTERNS = List.of(
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
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin((FormLoginConfigurer::disable))
                .cors((customCorsConfig) -> customCorsConfig.configurationSource(corsConfig.corsConfigurationSource()))

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PERMIT_PATTERNS).permitAll()
                        .requestMatchers("/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**", "/swagger-resources/**", "/webjars/**").permitAll()

                        .requestMatchers(HttpMethod.POST, "/api/auth/register", "/api/auth/refresh", "/api/auth/login").permitAll()
                        .requestMatchers(HttpMethod.DELETE, "/api/auth/logout").hasAnyRole("ADMIN", "USER")

                        .requestMatchers(HttpMethod.POST, "/api/roasting/**", "/api/bean/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/roasting/**", "/api/bean/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/roasting/**", "/api/bean/**").hasRole("ADMIN")

                        .requestMatchers("/api/**").hasAnyRole("ADMIN", "USER")
                        .anyRequest().authenticated())
                .formLogin(AbstractHttpConfigurer::disable)
                .oauth2Login((oauth2) -> oauth2
                        .successHandler(oAuth2LoginSuccessHandler)
                        .failureHandler(oAuth2LoginFailHandler)
                        .userInfoEndpoint((userInfoEndpoint) ->
                                userInfoEndpoint.userService(customOAuth2UserService))

                )

                .addFilterBefore(new JwtFilter(jwtService), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}