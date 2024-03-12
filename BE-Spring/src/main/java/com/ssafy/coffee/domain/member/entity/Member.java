package com.ssafy.coffee.domain.member.entity;

import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@ToString
@NoArgsConstructor
public class Member extends BaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_index", nullable = true)
    private Long index;

    @Column(name = "member_id", nullable = true, length = 255)
    private String id;

    @Column(name = "member_password", nullable = true, length = 255)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(name = "member_role", nullable = true)
    private Role role = Role.USER;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "member_auth_type", nullable = true)
    private AuthType authType;

    @Setter
    @Column(name = "member_nickname", nullable = true, length = 255)
    private String nickname;

    @Setter
    @Column(name = "member_profile_image", nullable = true, length = 255)
    private String profileImage;

    @Builder
    public Member(Long index, String id, String password, Role role, AuthType authType, String nickname, String profileImage) {
        this.index = index;
        this.id = id;
        this.password = password;
        this.role = role;
        this.authType = authType;
        this.nickname = nickname;
        this.profileImage = profileImage;
    }
}
