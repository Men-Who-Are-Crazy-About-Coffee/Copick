package com.ssafy.coffee.domain.auth.service;


import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.auth.dto.KakaoUserInfo;
import com.ssafy.coffee.domain.auth.dto.NaverUserInfo;
import com.ssafy.coffee.domain.auth.dto.OAuth2UserInfo;
import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final MemberRepository memberRepository;
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        OAuth2UserInfo oAuth2UserInfo =switch (userRequest.getClientRegistration().getRegistrationId()){
            case "naver" -> new NaverUserInfo((Map)oAuth2User.getAttributes().get("response"));
            case "kakao" -> new KakaoUserInfo((Map)oAuth2User.getAttributes().get("kakao_account"),
                    String.valueOf(oAuth2User.getAttributes().get("id")));
            default -> null;
        };
        String memberId = oAuth2UserInfo.getProviderId();
        String userEmail= oAuth2UserInfo.getEmail();
        String userName = oAuth2UserInfo.getName();
        String userBirthYear= oAuth2UserInfo.getBirthYear();
        String memberNickname = oAuth2UserInfo.getNickname();
        String memberProfileImageUrl= oAuth2UserInfo.getProfileImageUrl();
        AuthType snsType= switch (oAuth2UserInfo.getProvider()){
            case "naver" -> AuthType.NAVER;
            case "kakao" -> AuthType.KAKAO;
            default -> throw new RuntimeException("소셜로그인 Provider 에러");
        };
        log.debug("providerId {}, Objet : {}",memberId, oAuth2UserInfo.toString());
        Member member = memberRepository.findByIdAndAuthType(memberId,snsType).orElse(
                null
        );


        if(member==null){
            member=Member.builder()
                    .id(memberId)
                    .authType(snsType)
                    .role(Role.USER)
                    .nickname(memberNickname)
                    .profileImage(memberProfileImageUrl)
                .build();

            memberRepository.save(member);


        }
        return PrincipalMember.builder()
                .member(member)
                .attributes(oAuth2User.getAttributes())
                .build();
    }

}