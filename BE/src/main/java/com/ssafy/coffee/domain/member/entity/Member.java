package com.ssafy.coffee.domain.member.entity;

import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor
@ToString
public class Member extends BaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_index", nullable = false)
    private Long index;

    @Column(name = "member_id", nullable = false, length = 255)
    private String id;

    @Column(name = "member_password", length = 255)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(name="member_role",nullable = false)
    private Role role =Role.USER;

    @Enumerated(EnumType.ORDINAL)
    @Column(name = "member_auth_type", nullable = false)
    private AuthType authType;

    @Setter
    @Column(name = "member_nickname", length = 255)
    private String nickname;

    @Setter
    @Column(name = "member_profile_image", length = 255)
    private String profileImage;

    // Constructors, Setters
    @Builder
    public Member(Long index, String id, String password, Role role, AuthType authType, String nickname, String profileImage) {
        this.index=index;
        this.id = id;
        this.password = password;
        this.role = role;
        this.authType = authType;
        this.nickname = nickname;
        this.profileImage = profileImage;
    }
}
