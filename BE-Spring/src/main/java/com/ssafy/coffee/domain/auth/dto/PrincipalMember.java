package com.ssafy.coffee.domain.auth.dto;


import com.ssafy.coffee.domain.member.entity.Member;
import lombok.Builder;
import lombok.ToString;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
@ToString
public class PrincipalMember implements OAuth2User, UserDetails   {

    private Member member;
    private Map<String, Object> attributes;

    @Builder
    public PrincipalMember(Member member, Map<String, Object> attributes) {
        this.member = member;
        this.attributes = attributes;
    }
    @Builder
    public PrincipalMember(Member member){
        this.member=member;
    }

    @Override
    public String getName() {
        return String.valueOf(member.getIndex());
    }

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        Collection<GrantedAuthority> collection = new ArrayList<>();
        collection.add((GrantedAuthority) () -> String.valueOf(member.getRole()));
        return collection;
    }

    @Override
    public String getPassword() {
        return member.getPassword();
    }

    @Override
    public String getUsername() {
        return member.getId();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return !member.isDeleted();
    }


    public Member toEntity() {
        return member;
    }

    public String getNickname() { return member.getNickname();}

    public Long getIndex() {return member.getIndex();}
}
