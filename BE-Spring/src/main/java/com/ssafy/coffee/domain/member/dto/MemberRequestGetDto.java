package com.ssafy.coffee.domain.member.dto;

import com.ssafy.coffee.domain.member.entity.Member;
import lombok.Data;

@Data
public class MemberRequestGetDto {
    private Long index;
    private String id;
    private String role;
    private String nickname;
    private String profileImage;

    public MemberRequestGetDto(Member member) {
        this.index = member.getIndex();
        this.id = member.getId();
        this.role = member.getRole().name();
        this.nickname = member.getNickname();
        this.profileImage = member.getProfileImage();
    }
}
